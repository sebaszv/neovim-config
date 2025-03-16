local Components = {
  -- These are wrapped in a table for `lualine` to
  -- interpret these as Vim statusline item sequences.
  -- Lua functions can also be used to return
  -- component pieces, but that approach was far less
  -- performant to a noticeable degree compared to
  -- this, which is near instant.
  --
  -- View help page for 'statusline' to understand
  -- these sequences. It isn't too complex.
  column_location = { '%2v:%-2{virtcol("$") - 1}' },
  row_location = { "%2l:%-2L" },
}

-- Documentation: <https://github.com/nvim-lualine/lualine.nvim>
---@module 'lazy'
---@type LazyPluginSpec
local M = {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      icons_enabled = true,
      theme = "auto",
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = {
        statusline = {},
        winbar = {},
      },
      ignore_focus = {},
      always_divide_middle = true,
      always_show_tabline = true,
      globalstatus = false,
      refresh = {
        statusline = 100,
        tabline = 100,
        winbar = 100,
      },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { "filename" },
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = {
        -- `lualine` comes with a "location" component that
        -- displays the current line and column position.
        -- These are to replace that.
        Components.row_location,
        Components.column_location,
      },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = {
        -- `lualine` comes with a "location" component that
        -- displays the current line and column position.
        -- These are to replace that.
        Components.row_location,
        Components.column_location,
      },
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {},
  },
}

return { M }
