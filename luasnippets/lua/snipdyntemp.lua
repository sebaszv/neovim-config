local s = require("luasnip").snippet
local t = require("luasnip").text_node
local i = require("luasnip").insert_node
local d = require("luasnip").dynamic_node
local sn = require("luasnip").snippet_node

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
    trig = "snipdyntemp",
    desc = "LuaSnip dynamic snippet template",
    condition = at_top_level_of_luasnippet,
    show_condition = at_top_level_of_luasnippet,
  }, {
    d(1, function()
      local basename = vim.fs.basename(vim.api.nvim_buf_get_name(0))
      local extensionless_basename = vim.fn.fnamemodify(basename, ":r")
      -- A dynamic node is used to track the
      -- real current buffer shiftwidth.
      local indent = util.whitespace.indenter()

      return sn(nil, {
        t({
          'local s = require("luasnip").snippet',
          'local t = require("luasnip").text_node',
          'local i = require("luasnip").insert_node',
          'local d = require("luasnip").dynamic_node',
          'local sn = require("luasnip").snippet_node',
          "",
          'local util = require("util")',
          "",
          "return {",
          indent("s({"),
          indent(2, 'trig = "'),
        }),
        i(1, extensionless_basename),
        t({
          '",',
          indent(2, 'desc = "'),
        }),
        i(2),
        t({
          '",',
          indent(2, "condition = nil,"),
          indent(2, "show_condition = nil,"),
          indent("}, {"),
          indent(2, "d(1, function()"),
          indent(3, "-- A dynamic node is used to track the"),
          indent(3, "-- real current buffer shiftwidth."),
          indent(3, "local indent = util.whitespace.indenter()"),
          "",
          indent(3, "return sn(nil, {"),
          indent(4, "t({"),
          indent(5, '"'),
        }),
        i(3),
        t({
          '",',
          indent(4, "}),"),
          indent(4, "i(1),"),
          indent(3, "})"),
          indent(2, "end),"),
          indent("}),"),
          "}",
        }),
      })
    end),
  }),
}
