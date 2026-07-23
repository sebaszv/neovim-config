---@class util.window
local M = {}

--- Whether the cursor (or cursor of the window) is inside a given range.
---@param cursor_or_win ([integer, integer] | integer)?  Cursor to check position of. A window ID can be specified instead, whose cursor will be used. Otherwise, the cursor for the current window is used.
---@param start_row integer 0-indexed.
---@param start_col integer 0-indexed.
---@param end_row integer 0-indexed.
---@param end_col integer 0-indexed.
---@return boolean
function M.cursor_in_range(cursor_or_win, start_row, start_col, end_row, end_col)
  local cursor

  if type(cursor_or_win) == "table" then
    cursor = cursor_or_win
  else
    cursor = vim.api.nvim_win_get_cursor(cursor_or_win or 0)
  end

  local row, col = cursor[1] - 1, cursor[2]

  local past_start = row > start_row or (row == start_row and col >= start_col)
  local before_end = row < end_row or (row == end_row and col <= end_col)

  return past_start and before_end
end

return M
