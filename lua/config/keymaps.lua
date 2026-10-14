-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local conform_util = require("util.conform")

Snacks.toggle({
  name = "Conform Config Files (Global)",
  get = function()
    return (vim.g.util_conform_respect_config_files == nil) or vim.g.util_conform_respect_config_files
  end,
  set = function(state)
    conform_util.config_files.enable(state, false)
  end,
}):map("<leader>u<leader>f")

Snacks.toggle({
  name = "Conform Config Files (Buffer)",
  get = function()
    return conform_util.config_files.enabled(0)
  end,
  set = function(state)
    conform_util.config_files.enable(state, true)
  end,
}):map("<leader>u<leader>F")
