---@module "conform"

--- Function signature for `conform` `args`, `prepend_args`, and `append_args` values
--- for `conform.FormatterConfigOverride` tables, which are used for configuring formatter
--- command-line arguments. This signature _may_ change, but considering it is used extensively
--- and is verbosely long, aliasing helps reduce clutter.
---@alias util.conform.ArgsFunc fun(self: conform.FormatterConfig, ctx: conform.Context): string|string[]
--- Signature for the accepted types for `conform` `args`, `prepend_args`, and `append_args`
--- values for `conform.FormatterConfigOverride` tables which are used for configuring
--- formatter command-line arguments. This signature _may_ change, but considering it is
--- used extensively and is verbosely long, aliasing helps reduce clutter.
---@alias util.conform.ArgsType string|string[]|util.conform.ArgsFunc

--- Normalise the passed value (recognised types for `args`, `prepend_args`, or `append_args`)
--- into a mergeable value. If the value ends up a table, it is assumed to be a list, but no
--- actual checks are performed. If the value is a function, it is assumed that it will accept
--- `self` and `ctx` arguments, as is expected of `prepend_args` or `append_args` function
--- values, though no validation is performed. The normalised rendered value is returned. If
--- the final value is a table, it is *not* copied; the same reference is returned. If
--- mutation is a concern, that should be handled by the caller.
---@param x nil|util.conform.ArgsType
---@param self_ nil|conform.FormatterConfig
---@param ctx nil|conform.Context
---@return nil|string[]
local function normalise_args(x, self_, ctx)
  if x == nil then
    return nil
  end

  if type(x) == "function" then
    ---@diagnostic disable-next-line: param-type-mismatch
    x = x(self_, ctx) ---@cast x string|string[]
  end

  if type(x) == "string" then
    return { x }
  end

  return x
end

--- Prepend or append args to formatter list.
---@param opts nil|conform.setupOpts Set-up opts table to modify. The `require("conform")` table is modified by default.
---@param prepend_or_append "prepend"|"append" Whether to append or append to the base formatter args.
---@param formatter string Formatter to modify args for.
---@param args util.conform.ArgsType Args to prepend or append, or a context-aware function to render them. This is the same signature that can be used for `prepend_args` or `append_args`. This will be joined with whatever is currently set.
---@param config_filenames? string|string[] Names of config files to skip modifying the formatter args if found.
local function modify_args(opts, prepend_or_append, formatter, args, config_filenames)
  vim.validate("opts", opts, { "nil", "table" })
  vim.validate("prepend_or_append", prepend_or_append, function(x)
    return (x == "prepend") or (x == "append")
  end)
  vim.validate("formatter", formatter, "string")
  vim.validate("args", args, { "string", "table", "function" })
  vim.validate("config_filenames", config_filenames, { "string", "table" }, true)

  if type(args) == "string" then
    args = { args }
  elseif type(args) == "table" then
    -- Avoid further nesting the callback chain for no benefit.
    if vim.tbl_isempty(args) then
      return
    end

    -- Safeguard from mutation outside the function
    -- since this table may be referenced in callback
    -- functions.
    args = vim.list_extend({}, args)
  end

  if config_filenames then
    if type(config_filenames) == "string" then
      config_filenames = { config_filenames }
    else
      -- Avoid further nesting the callback chain for no benefit.
      if vim.tbl_isempty(config_filenames) then
        config_filenames = nil
      else
        -- Safeguard from mutation outside the function
        -- since this table may be referenced in callback
        -- functions.
        config_filenames = vim.list_extend({}, config_filenames)
        -- Reduce work done during filesystem traversal
        -- looking for these in case of duplicate entries.
        vim.list.unique(config_filenames)
      end
    end
  end

  if not opts then
    opts = require("conform")
  end

  ---@type "prepend_args"|"append_args"
  local args_label = prepend_or_append .. "_args"

  opts.formatters = opts.formatters or {}
  opts.formatters[formatter] = opts.formatters[formatter] or {}

  if type(opts.formatters[formatter]) == "function" then
    local orig_buf_func = opts.formatters[formatter]

    opts.formatters[formatter] = function(bufnr)
      local config = orig_buf_func(bufnr) or {}

      if not config[args_label] then
        if config_filenames then
          ---@type util.conform.ArgsFunc
          config[args_label] = function(self_, ctx)
            local has_config_file = vim.fs.find(config_filenames, {
              limit = 1,
              path = ctx.dirname,
              upward = true,
            })[1] ~= nil

            if has_config_file then
              return {}
            end

            return normalise_args(args, self_, ctx) or {}
          end
        else
          config[args_label] = args
        end

        return config
      end

      if
        -- stylua: ignore
        config_filenames
        or (type(config[args_label]) == "function")
        or (type(args) == "function")
      then
        local prev = config[args_label]

        config[args_label] = function(self_, ctx)
          local base_args = normalise_args(prev, self_, ctx)
          local has_config_file = false

          if config_filenames then
            has_config_file = vim.fs.find(config_filenames, {
              limit = 1,
              path = ctx.dirname,
              upward = true,
            })[1] ~= nil
          end

          if has_config_file then
            return base_args
          end

          local new_args = normalise_args(args, self_, ctx)
          local merged = vim.list_extend({}, base_args or {})

          return vim.list_extend(merged, new_args or {})
        end

        return config
      end

      local base_args = normalise_args(config[args_label])
      local new_args = normalise_args(args)
      local merged = vim.list_extend({}, base_args or {})

      config[args_label] = vim.list_extend(merged, new_args or {})

      return config
    end

    return
  end

  if not opts.formatters[formatter][args_label] then
    if config_filenames then
      ---@type util.conform.ArgsFunc
      opts.formatters[formatter][args_label] = function(self_, ctx)
        local has_config_file = vim.fs.find(config_filenames, {
          limit = 1,
          path = ctx.dirname,
          upward = true,
        })[1] ~= nil

        if has_config_file then
          return {}
        end

        return normalise_args(args, self_, ctx) or {}
      end
    else
      opts.formatters[formatter][args_label] = args
    end

    return
  end

  if
    -- stylua: ignore
    config_filenames
    or (type(opts.formatters[formatter][args_label]) == "function")
    or (type(args) == "function")
  then
    local prev = opts.formatters[formatter][args_label]

    opts.formatters[formatter][args_label] = function(self_, ctx)
      local base_args = normalise_args(prev, self_, ctx)
      local has_config_file = false

      if config_filenames then
        has_config_file = vim.fs.find(config_filenames, {
          limit = 1,
          path = ctx.dirname,
          upward = true,
        })[1] ~= nil
      end

      if has_config_file then
        return base_args
      end

      local new_args = normalise_args(args, self_, ctx)
      local merged = vim.list_extend({}, base_args or {})

      return vim.list_extend(merged, new_args or {})
    end

    return
  end

  local base_args = normalise_args(opts.formatters[formatter][args_label])
  local new_args = normalise_args(args)

  opts.formatters[formatter][args_label] = vim.list_extend(base_args or {}, new_args or {})
end

---@class util.conform
local M = {}

--- Prepend args to formatter list.
---@param opts nil|conform.setupOpts Set-up opts table to modify. The `require("conform")` table is modified by default.
---@param formatter string Formatter to prepend args for.
---@param args util.conform.ArgsType Args to prepend or a context-aware function to render them. This is the same signature that can be used for `prepend_args`. This will be joined with whatever is currently set.
---@param config_filenames? string|string[] Names of config files to skip modifying the formatter args if found.
function M.prepend_args(opts, formatter, args, config_filenames)
  modify_args(opts, "prepend", formatter, args, config_filenames)
end

--- Append args to formatter list.
---@param opts nil|conform.setupOpts Set-up opts table to modify. The `require("conform")` table is modified by default.
---@param formatter string Formatter to append args for.
---@param args util.conform.ArgsType Args to append or a context-aware function to render them. This is the same signature that can be used for `append_args`. This will be joined with whatever is currently set.
---@param config_filenames? string|string[] Names of config files to skip modifying the formatter args if found.
function M.append_args(opts, formatter, args, config_filenames)
  modify_args(opts, "append", formatter, args, config_filenames)
end

return M
