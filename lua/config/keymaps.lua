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

Snacks.toggle({
  name = "Read-Only (Global Default)",
  get = function()
    return vim.g.global_readonly_buffer_default or false ---@type boolean
  end,
  set = function(state)
    vim.g.global_readonly_buffer_default = state ---@type boolean
    vim.bo.readonly = state ---@type boolean

    -- If `state` is `false`, re-creating the group will clear
    -- the group if it already exists, which removes the old
    -- autocmd if it was created.
    local group = vim.api.nvim_create_augroup("GlobalReadonlyBufferDefault", { clear = true })

    if state then
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        group = group,
        callback = function()
          vim.bo.readonly = true
        end,
      })
    end
  end,
}):map("<leader>u<leader>r")

Snacks.toggle({
  name = "Read-Only (Buffer)",
  get = function()
    return vim.bo.readonly or false
  end,
  set = function(state)
    vim.bo.readonly = state
  end,
}):map("<leader>u<leader>R")
