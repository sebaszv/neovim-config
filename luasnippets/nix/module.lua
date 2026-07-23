local s = require("luasnip").snippet
local t = require("luasnip").text_node
local i = require("luasnip").insert_node
local d = require("luasnip").dynamic_node
local sn = require("luasnip").snippet_node

local util = require("util")

return {
  s({
    trig = "module",
    desc = "Nix module boilerplate with optional imports",
  }, {
    d(1, function()
      local file = vim.api.nvim_buf_get_name(0)

      local is_default = vim.endswith(file, "default.nix")
      local has_root_expr, in_expr = util.nix.root_nix_expression_context(0, 0)

      local importables

      if is_default and not has_root_expr and not in_expr then
        importables = util.nix.list_nix_importables(vim.fs.dirname(file))
      end

      local indent = util.whitespace.indenter()
      local nodes = { t({ "{ ... }:", "{" }) }

      if not importables then
        nodes[#nodes + 1] = t({ "", indent() })
      else
        nodes[#nodes + 1] = t({ "", indent("imports = [") })

        for _, name in ipairs(importables) do
          nodes[#nodes + 1] = t({ "", indent(2, "./" .. name) })
        end

        nodes[#nodes + 1] = t({ "", indent("];") })
      end

      nodes[#nodes + 1] = i(1)
      nodes[#nodes + 1] = t({ "", "}" })

      if in_expr then
        nodes[#nodes + 1] = t({ ";" })
      end

      return sn(nil, nodes)
    end),
  }),
}
