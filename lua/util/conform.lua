---@module "conform"

--- Normalise the passed value (recognised types for `prepend_args` or `append_args`) into a
--- mergeable value. If the value ends up a table, it is assumed to be a list, but no actual
--- checks are performed. If the value is a function, it is assumed that it will accept `self`
--- and `ctx` arguments, as is expected of `prepend_args` or `append_args` function values,
--- though no validation is performed. The normalised rendered value is returned. If the final
--- value is a table, it is *not* copied; the same reference is returned. If mutation is a
--- concern, that should be handled by the caller.
---@param x nil|string|string[]|fun(self: conform.FormatterConfig, ctx: conform.Context): string|string[]
---@param self_ nil|conform.FormatterConfig
---@param ctx nil|conform.Context
---@return nil|string[]
local function normalise(x, self_, ctx)
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
---@param prepend_or_append "prepend"|"append"
---@param formatter string Formatter to modify args for.
---@param args string[]|fun(self: conform.FormatterConfig, ctx: conform.Context): string|string[] Args to prepend or append, or a context-aware function to render them. This is the same signature that can be used for `prepend_args` or `append_args`. This will be joined with whatever is currently set.
local function modify_args(opts, prepend_or_append, formatter, args)
  vim.validate("opts", opts, { "nil", "table" })
  vim.validate("prepend_or_append", prepend_or_append, function(x)
    return (x == "prepend") or (x == "append")
  end)
  vim.validate("formatter", formatter, "string")
  vim.validate("args", args, { "table", "function" })

  if type(args) == "table" then
    -- Safeguard from mutation outside the function
    -- since this table may be referenced in callback
    -- functions.
    args = vim.list_extend({}, args)
  end

  if not opts then
    opts = require("conform")
  end

  local args_label = prepend_or_append .. "_args" ---@type "prepend_args"|"append_args"

  opts.formatters = opts.formatters or {}
  opts.formatters[formatter] = opts.formatters[formatter] or {}

  if type(opts.formatters[formatter]) == "function" then
    local orig_buf_func = opts.formatters[formatter]

    opts.formatters[formatter] = function(bufnr)
      local config = orig_buf_func(bufnr)

      if config == nil then
        return { [args_label] = args }
      end

      if not config[args_label] then
        config[args_label] = args

        return config
      end

      if (type(config[args_label]) == "function") or (type(args) == "function") then
        local prev = config[args_label]

        config[args_label] = function(self_, ctx)
          local base_args = normalise(prev, self_, ctx)
          local new_args = normalise(args, self_, ctx)
          local merged = vim.list_extend({}, base_args or {})

          return vim.list_extend(merged, new_args or {})
        end

        return config
      end

      local base_args = normalise(config[args_label])
      local new_args = normalise(args)
      local merged = vim.list_extend({}, base_args or {})

      config[args_label] = vim.list_extend(merged, new_args or {})

      return config
    end

    return
  end

  if not opts.formatters[formatter][args_label] then
    opts.formatters[formatter][args_label] = args

    return
  end

  if (type(opts.formatters[formatter][args_label]) == "function") or (type(args) == "function") then
    local prev = opts.formatters[formatter][args_label]

    opts.formatters[formatter][args_label] = function(self_, ctx)
      local base_args = normalise(prev, self_, ctx)
      local new_args = normalise(args, self_, ctx)
      local merged = vim.list_extend({}, base_args or {})

      return vim.list_extend(merged, new_args or {})
    end

    return
  end

  local base_args = normalise(opts.formatters[formatter][args_label])
  local new_args = normalise(args)

  opts.formatters[formatter][args_label] = vim.list_extend(base_args or {}, new_args or {})
end

---@class util.conform
local M = {}

--- Prepend args to formatter list.
---@param opts nil|conform.setupOpts Set-up opts table to modify. The `require("conform")` table is modified by default.
---@param formatter string Formatter to prepend args for.
---@param args string[]|fun(self: conform.FormatterConfig, ctx: conform.Context): string|string[] Args to prepend or a context-aware function to render them. This is the same signature that can be used for `prepend_args`. This will be joined with whatever is currently set.
function M.prepend_args(opts, formatter, args)
  modify_args(opts, "prepend", formatter, args)
end

--- Append args to formatter list.
---@param opts nil|conform.setupOpts Set-up opts table to modify. The `require("conform")` table is modified by default.
---@param formatter string Formatter to append args for.
---@param args string[]|fun(self: conform.FormatterConfig, ctx: conform.Context): string|string[] Args to append or a context-aware function to render them. This is the same signature that can be used for `append_args`. This will be joined with whatever is currently set.
function M.append_args(opts, formatter, args)
  modify_args(opts, "append", formatter, args)
end

return M
