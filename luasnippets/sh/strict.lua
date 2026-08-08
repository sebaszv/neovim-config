local s = require("luasnip").snippet
local t = require("luasnip").text_node
local i = require("luasnip").insert_node

local util = require("util")

--- Whether the current cursor is at the top-level of a shell script buffer.
---@return boolean
local function current_cursor_at_sh_top_level()
  return util.treesitter.cursor_at_top_level("program", 0, 0)
end

return {
  s({
    trig = "strict",
    desc = '"Strict" mode options',
    condition = current_cursor_at_sh_top_level,
    show_condition = current_cursor_at_sh_top_level,
  }, {
    t({
      "set -o errexit",
      "set -o nounset",
      "set -o pipefail",
    }),
    i(1),
  }),
}
