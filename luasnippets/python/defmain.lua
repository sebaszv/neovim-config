local s = require("luasnip").snippet
local t = require("luasnip").text_node
local i = require("luasnip").insert_node
local d = require("luasnip").dynamic_node
local sn = require("luasnip").snippet_node

local util = require("util")

--- Whether the current cursor is at the top-level of a Python buffer.
---@return boolean
local function current_cursor_at_python_top_level()
  return util.treesitter.cursor_at_top_level("module", 0, 0)
end

return {
  s({
    trig = "defmain",
    desc = "Main function boilerplate",
    condition = current_cursor_at_python_top_level,
    show_condition = current_cursor_at_python_top_level,
  }, {
    d(1, function()
      local indent = util.whitespace.indenter()

      return sn(nil, {
        t({
          "import sys",
          "",
          "",
          "def main() -> int:",
          indent("pass"),
        }),
        i(1),
        t({
          "",
          "",
          indent("return 0"),
          "",
          "",
          'if __name__ == "__main__":',
          indent("sys.exit(main())"),
        }),
      })
    end),
  }),
}
