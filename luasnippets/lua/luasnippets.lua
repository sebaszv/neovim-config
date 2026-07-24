local s = require("luasnip").snippet
local t = require("luasnip").text_node
local i = require("luasnip").insert_node

--- Whether at the top-level of a Lua buffer.
---@param buf integer? Buffer to check or the current buffer.
---@param cursor_or_win ([integer, integer] | integer)?  Cursor to check position of. A window ID can be specified instead, whose cursor will be used. Otherwise, the cursor for the current window is used.
---@return boolean
local function cursor_at_lua_top_level(buf, cursor_or_win)
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

  return not parent or parent:type() == "chunk"
end

--- Whether at the top-level of a luasnippet.
---@return boolean
local function at_top_level_of_luasnippet()
  local file = vim.api.nvim_buf_get_name(0)
  local ok_pat = "^" .. vim.fn.stdpath("config") .. "/luasnippets/.+%.lua$"

  return file:match(ok_pat) and cursor_at_lua_top_level(0, 0)
end

return {
  s({
    trig = "sniphelp",
    desc = "LuaSnip snippet definer helper functions",
    condition = at_top_level_of_luasnippet,
    show_condition = at_top_level_of_luasnippet,
  }, {
    t({
      'local s = require("luasnip").snippet',
      'local t = require("luasnip").text_node',
      'local i = require("luasnip").insert_node',
      'local d = require("luasnip").dynamic_node',
      'local sn = require("luasnip").snippet_node',
    }),
    i(1),
  }),
}
