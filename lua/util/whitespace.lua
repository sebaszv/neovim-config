---@class util.whitespace
local M = {}

--- Return the indentation string for the current buffer.
---@return string
function M.buf_ind()
  local sw = vim.bo.shiftwidth

  if sw == 0 then
    sw = vim.bo.tabstop
  end

  if vim.bo.expandtab then
    return string.rep(" ", sw)
  end

  return "\t"
end

--- Indent string by given level with a specified indent string.
---@param lvl integer? Indentation level (default: 1).
---@param s string? String to indent (default: "").
---@param sw string? Shiftwidth string to repeat (default: current buffer's).
---@return string # Indented string.
---@overload fun(s: string): string
---@overload fun(s: string, sw: string): string
function M.indent(lvl, s, sw)
  if type(lvl) == "string" then
    sw = s
    s = lvl
    lvl = nil
  end

  return (sw or M.buf_ind()):rep(lvl or 1) .. (s or "")
end

--- Function that indents a string by a given level
--- using a pre-captured shiftwidth string. This is
--- just a wrapper for `util.whitespace.indent` to
--- save some API calls to check the buffer indentation
--- or having to specify it repeatedly if used in a
--- specific context.
---@alias util.whitespace.IndentFn fun(lvl: (integer|string)?, s_: string?): string
--- Return `util.whitespace.indent` wrapper function
--- with `sw` pre-captured to save some API calls to
--- check the buffer indentation or having to specify
--- it repeatedly if used in a specific context.
---@param sw string?  Shiftwidth string to repeat or default for the current buffer.
---@return util.whitespace.IndentFn
function M.indenter(sw)
  sw = sw or M.buf_ind()

  return function(lvl, s)
    if type(lvl) == "string" then
      s = lvl
      lvl = nil
    end

    return M.indent(lvl, s, sw)
  end
end

return M
