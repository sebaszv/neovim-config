-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- LazyVim has this set to 'unnamedplus' by default.
-- I prefer accessing the system clipboard through its
-- respective registers than syncing with the system clipboard.
vim.opt.clipboard = ""

-- Disable AI completion/suggestions.
-- LazyVim has this on by default.
-- It's not my cup of tea.
vim.g.ai_cmp = false
