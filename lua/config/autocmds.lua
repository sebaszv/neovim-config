-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- `snacks.nvim` sets the autocmd for autoenabling indent guides on
-- `BufReadPost`, which doesn't fire when opening new files. The
-- implementation was more or less copied, but for `BufNewFile` also.
-- The enabler function is idempotent so there is no clashing to worry
-- about. Opening an issue about this would be ideal, but the project
-- isn't too active, so it's unlikely to get any timely attention, so
-- this will do.
--
-- View:
-- <https://github.com/folke/snacks.nvim/blob/882c996cf28183f4d63640de0b4c02ec886d01f2/lua/snacks/init.lua#L158>
vim.api.nvim_create_autocmd("BufNewFile", {
  group = vim.api.nvim_create_augroup("snacks", { clear = false }),
  once = true,
  nested = true,
  callback = function()
    if Snacks.config.indent and Snacks.config.indent.enabled then
      -- Idempotent.
      Snacks.indent.enable()
    end
  end,
})
