-- Documentation: <https://github.com/kdheepak/lazygit.nvim>
---@module 'lazy'
---@type LazyPluginSpec
local M = {
  "kdheepak/lazygit.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  keys = {
    {
      "<LEADER>lg",
      function()
        vim.cmd("LazyGit")
      end,
      desc = "Open LazyGit overlay window",
    },
  },
}

return { M }
