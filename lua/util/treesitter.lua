local win_util = require("util.window")

---@class util.treesitter
local M = {}

--- Whether the cursor (or cursor of the window) is positioned inside the treesitter node.
---@param ts_node TSNode Treesitter node to check in.
---@param cursor_or_win ([integer, integer] | integer)? Cursor to check position of. A window ID can be specified instead, whose cursor will be used. Otherwise, the cursor for the current window is used.
---@return boolean
function M.cursor_in_ts_node(ts_node, cursor_or_win)
  local start_row, start_col, end_row, end_col = ts_node:range()

  return win_util.cursor_in_range(cursor_or_win, start_row, start_col, end_row, end_col)
end

return M
