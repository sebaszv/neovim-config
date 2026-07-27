local s = require("luasnip").snippet
local t = require("luasnip").text_node
local i = require("luasnip").insert_node
local d = require("luasnip").dynamic_node
local sn = require("luasnip").snippet_node

local util = require("util")

--- Whether at the top-level of a Python buffer.
---@param buf integer? Buffer to check or the current buffer.
---@param cursor_or_win ([integer, integer] | integer)?  Cursor to check position of. A window ID can be specified instead, whose cursor will be used. Otherwise, the cursor for the current window is used.
---@return boolean
local function cursor_at_python_top_level(buf, cursor_or_win)
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

  return not parent or parent:type() == "module"
end

--- Whether the current cursor is at the top-level of a Python buffer.
---@return boolean
local function current_cursor_at_python_top_level()
  return cursor_at_python_top_level(0, 0)
end

return {
  s({
    trig = "cliboil",
    desc = "CLI boilerplate",
    condition = current_cursor_at_python_top_level,
    show_condition = current_cursor_at_python_top_level,
  }, {
    d(1, function()
      local indent = util.whitespace.indenter()

      return sn(nil, {
        t({
          "import sys",
          "from argparse import ArgumentParser, ArgumentTypeError, Namespace",
          "",
          "",
          "class _Args(Namespace):",
          indent('"""'),
          indent("Command-line arguments."),
          indent('"""'),
          "",
          indent("pass"),
          "",
          "",
          "def main() -> int:",
          indent("args: _Args = _parse_args()"),
        }),
        i(1),
        t({
          "",
          "",
          indent("return 0"),
          "",
          "",
          "def _parse_args() -> _Args:",
          indent('"""'),
          indent("Parse command-line arguments."),
          indent('"""'),
          indent("parser: ArgumentParser = ArgumentParser(allow_abbrev=False)"),
          "",
          indent("return parser.parse_args(namespace=_Args())"),
          "",
          "",
          'if __name__ == "__main__":',
          indent("sys.exit(main())"),
        }),
      })
    end),
  }),
}
