local win_util = require("util.window")

---@class util.treesitter
local M = {}

--- Whether at the top-level of a buffer.
---@param root_node_type string Type of parent of all nodes that marks the root of the node tree.
---@param buf integer? Buffer to check or the current buffer.
---@param cursor_or_win ([integer, integer] | integer)?  Cursor to check position of. A window ID can be specified instead, whose cursor will be used. Otherwise, the cursor for the current window is used.
---@return boolean
function M.cursor_at_top_level(root_node_type, buf, cursor_or_win)
  local cursor

  if type(cursor_or_win) == "table" then
    cursor = cursor_or_win
  else
    cursor = vim.api.nvim_win_get_cursor(cursor_or_win or 0)
  end

  local row, col = cursor[1] - 1, cursor[2]
  local node = vim.treesitter.get_node({
    bufnr = buf or 0,
    pos = { row, col },
  })

  if not node then
    return true
  end

  local parent = node:parent()

  return not parent or parent:type() == root_node_type
end

--- Whether the cursor (or cursor of the window) is positioned inside the treesitter node.
---@param ts_node TSNode Treesitter node to check in.
---@param cursor_or_win ([integer, integer] | integer)? Cursor to check position of. A window ID can be specified instead, whose cursor will be used. Otherwise, the cursor for the current window is used.
---@return boolean
function M.cursor_in_ts_node(ts_node, cursor_or_win)
  local start_row, start_col, end_row, end_col = ts_node:range()

  return win_util.cursor_in_range(cursor_or_win, start_row, start_col, end_row, end_col)
end

return M
