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
--- Same as `util.conform.ArgsType`, but excludes `string` since `conform` doesn't always
--- handle string values correctly despite advertising it in the signature. In practice,
--- simply wrapping the string value in a table is cheap assurance.
---@alias util.conform.SafeArgsType string[]|util.conform.ArgsFunc

---@class util.conform
local M = {}

--- `conform` formatter arguments added via
--- `require("util.conform").prepend_args` or
--- `require("util.conform").append_args` can
--- register config filenames. If a path matches
--- upward in the parent directories, the added
--- arguments are nullified to respect the file
--- the formatter may use for its configuration.
--- This behaviour is toggleable and queryable
--- here.
M.config_files = {}

--- Whether config files are being respected.
---@param buf? integer Buffer to check for. The default is the current buffer.
function M.config_files.enabled(buf)
  vim.validate("buf", buf, "number", true)

  local g = vim.g.util_conform_respect_config_files ---@type nil|boolean
  local b = vim.b[buf or 0].util_conform_respect_config_files ---@type nil|boolean

  if b ~= nil then
    return b
  end

  return (g == nil) or g
end

--- Set whether to respect or ignore config files.
---@param enable? boolean Whether to enable or disable. Enabling is the default.
---@param buf? integer|boolean Specify an integer to set for a specific buffer or `true` to set for the current buffer. Otherwise, the global toggle is enabled.
function M.config_files.enable(enable, buf)
  vim.validate("enable", enable, "boolean", true)
  vim.validate("buf", buf, { "number", "boolean" }, true)

  enable = (enable == nil) and true or enable
  buf = (buf == true) and 0 or buf

  if buf then
    vim.b[buf].util_conform_respect_config_files = enable ---@type nil|boolean
  else
    vim.b.util_conform_respect_config_files = nil ---@type nil|boolean
    vim.g.util_conform_respect_config_files = enable ---@type nil|boolean
  end
end

---@param buf? integer|boolean Specify an integer to toggle for a specific buffer or `true` to toggle for the current buffer. Otherwise, the global toggle is flipped.
function M.config_files.toggle(buf)
  if buf == true then
    buf = 0
  elseif buf == false then
    buf = nil
  end

  ---@cast buf nil|integer

  M.config_files.enable(not M.config_files.enabled(buf), buf)
end

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
    -- Avoid further nesting the
    -- callback chain for no benefit.
    if vim.tbl_isempty(args) then
      return
    end

    -- Guard from mutation outside the
    -- function since this table may be
    -- referenced in callback functions.
    args = vim.list_extend({}, args)
  end

  ---@cast args util.conform.SafeArgsType

  if type(config_filenames) == "string" then
    config_filenames = { config_filenames }
  elseif type(config_filenames) == "table" then
    -- Avoid further nesting the callback
    -- chain for no benefit.
    if vim.tbl_isempty(config_filenames) then
      config_filenames = nil
    else
      -- Guard from mutation outside the function since
      -- this table may be referenced in callback functions.
      config_filenames = vim.list_extend({}, config_filenames)
      -- Reduce work done during filesystem traversal
      -- looking for these in case of duplicate entries.
      vim.list.unique(config_filenames)
    end
  end

  ---@cast config_filenames nil|string[]

  --- Merge the passed `prev` "args" with `args` from the parent function, and embed skip on presence of config files from `config_filenames`, if any.
  ---@param prev nil|util.conform.ArgsType
  ---@return util.conform.SafeArgsType
  local function render_merged(prev)
    if (prev == nil) and (config_filenames == nil) then
      return args
    end

    -- stylua: ignore
    local is_static = not (
      type(prev) == "function"
      or type(args) == "function"
      or config_filenames ~= nil
    )

    if is_static then
      local lhs = normalise_args(prev) or {}
      local rhs = normalise_args(args) or {}
      local merged = vim.list_extend({}, lhs)

      return vim.list_extend(merged, rhs)
    end

    return function(self_, ctx)
      local lhs = normalise_args(prev, self_, ctx) or {}
      local has_config_file = (config_filenames ~= nil)
        and M.config_files.enabled(ctx.buf)
        and (
          vim.fs.find(config_filenames, {
            limit = 1,
            path = ctx.dirname,
            upward = true,
          })[1] ~= nil
        )

      if has_config_file then
        return lhs
      end

      local rhs = normalise_args(args, self_, ctx) or {}
      local merged = vim.list_extend({}, lhs)

      return vim.list_extend(merged, rhs)
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

      config[args_label] = render_merged(config[args_label])

      return config
    end

    return
  end

  opts.formatters[formatter][args_label] = render_merged(opts.formatters[formatter][args_label])
end

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
