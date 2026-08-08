local s = require("luasnip").snippet
local t = require("luasnip").text_node
local i = require("luasnip").insert_node

local util = require("util")

--- Whether at the top-level of a luasnippet.
---@return boolean
local function at_top_level_of_luasnippet()
  local file = vim.api.nvim_buf_get_name(0)
  local ok_pat = "^" .. vim.pesc(vim.fn.stdpath("config")) .. "/luasnippets/.+%.lua$"

  return file:match(ok_pat) and util.treesitter.cursor_at_top_level("chunk", 0, 0)
end

return {
  s({
    trig = "sniphelp",
    desc = "LuaSnip snippet definer helper functions",
    condition = at_top_level_of_luasnippet,
    show_condition = at_top_level_of_luasnippet,
    priority = 1002,
  }, {
    t({
      'local s = require("luasnip").snippet',
      'local t = require("luasnip").text_node',
      'local i = require("luasnip").insert_node',
      'local d = require("luasnip").dynamic_node',
      'local sn = require("luasnip").snippet_node',
      "",
      'local util = require("util")',
    }),
    i(1),
  }),
}
