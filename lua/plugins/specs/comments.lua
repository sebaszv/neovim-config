-- Documentation: <https://github.com/folke/todo-comments.nvim>
---@module 'lazy'
---@type LazyPluginSpec
local M = {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},
}

return { M }
