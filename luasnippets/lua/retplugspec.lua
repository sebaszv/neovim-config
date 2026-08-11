local s = require("luasnip").snippet
local t = require("luasnip").text_node
local i = require("luasnip").insert_node
local d = require("luasnip").dynamic_node
local sn = require("luasnip").snippet_node

local util = require("util")

--- Whether the buffer is a plugin module in the user Neovim plugin directory.
---@return boolean
local function at_top_level_of_config_plugin_module()
  local file = vim.api.nvim_buf_get_name(0)
  local ok_pat = "^" .. vim.pesc(vim.fn.stdpath("config")) .. "/lua/plugins/.+%.lua$"

  return file:match(ok_pat) and util.treesitter.cursor_at_top_level("chunk", 0, 0)
end

return {
  s({
    trig = "retplugspec",
    desc = "Return lazy.nvim plugin module spec template.",
    condition = at_top_level_of_config_plugin_module,
    show_condition = at_top_level_of_config_plugin_module,
  }, {
    d(1, function()
      -- A dynamic node is used to track the
      -- real current buffer shiftwidth.
      local indent = util.whitespace.indenter()

      return sn(nil, {
        t({
          "return {",
          indent("{"),
          indent(2),
        }),
        i(1),
        t({
          ",",
          indent("},"),
          "}",
        }),
      })
    end),
  }),
}
