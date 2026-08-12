---@module "lazy"
---@module "snacks"

return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      win = {
        wo = {
          number = true,
          relativenumber = true,
        },
      },
      picker = {
        sources = {
          -- Enable wrapping by default
          -- on the notification pane
          -- so messages can be fully
          -- read always.
          notifications = {
            win = {
              preview = {
                wo = { wrap = true },
              },
            },
          },
          -- Custom picker for grepping only
          -- the current buffer. The builtins
          -- offer grepping all currently
          -- opened buffers, recursive grepping,
          -- and fuzzy searching the current
          -- buffer lines, but not this. The
          -- chosen options were borrowed from
          -- the 'Buffer Lines' and 'Grep Buffers'
          -- builtin pickers.
          grep_buffer = {
            finder = "grep",
            format = "file",
            live = true,
            need_search = false,
            supports_live = true,
            layout = {
              preview = "main",
              preset = "ivy",
            },
            main = { current = true },
            config = function(opts)
              ---@cast opts snacks.picker.grep.Config
              opts.dirs = {
                -- Target only the current file specifically,
                -- even if it isn't actually a "dir". These
                -- are the paths that will be fed to ripgrep.
                vim.api.nvim_buf_get_name(0),
              }

              return opts
            end,
          },
        },
      },
    },
    ---@type LazyKeysSpec[]
    keys = {
      -- 'Buffer Lines' is mapped to `<leader>sb` by default.
      -- 'Grep Buffers' is mapped to `<leader>sB` by default.
      -- Having 'Grep Buffer' mapped to `<leader>sb` to match
      -- makes sense. Since `<leader>sf` is free in the default
      -- set-up, 'Buffer Lines' is set to it, with `f` meaning
      -- "fuzzy" to have the new mapping make sense.
      {
        "<leader>sf",
        function()
          Snacks.picker.lines()
        end,
        desc = "Buffer Lines",
      },
      {
        "<leader>sb",
        function()
          Snacks.picker.pick("grep_buffer")
        end,
        desc = "Grep Buffer",
      },
    },
  },
}
