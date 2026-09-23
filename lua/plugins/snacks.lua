---@module "lazy"
---@module "snacks"

return {
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      ---@type snacks.Config
      local opts_overrides = {
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
              config = function(opts_)
                ---@cast opts_ snacks.picker.grep.Config
                opts_.dirs = {
                  -- Target only the current file specifically,
                  -- even if it isn't actually a "dir". These
                  -- are the paths that will be fed to ripgrep.
                  vim.api.nvim_buf_get_name(0),
                }

                return opts_
              end,
            },
          },
        },
        terminal = {
          shell = (vim.fn.executable("fish") == 1) and "fish" or nil,
          win = {
            position = "float",
            width = 0.85,
            height = 0.8,
            border = "rounded",
          },
        },
      }

      --- Close all snacks.nvim terminal instances,
      --- which are cached based on the arguments
      --- passed during the terminal spin-up. Exiting
      --- the terminal closes and removes the instance
      --- from the cache, but if it blocks, this can't
      --- happen, hence what this function is for. It
      --- could be targeted at specific instances, but
      --- a big button is sufficient for those rare cases
      --- where restarting the editor is inconvenient.
      local function snacks_terminal_close_all()
        for _, t in pairs(Snacks.terminal.list()) do
          t:close()
        end
      end

      vim.api.nvim_create_user_command("SnacksTerminalCloseAll", snacks_terminal_close_all, {})
      vim.api.nvim_create_user_command("SnacksTerminalSetShell", function(args)
        local shell = args.args

        if vim.fn.executable(shell) ~= 1 then
          vim.notify("'" .. shell .. "' not found", vim.log.levels.WARN)

          return
        end

        snacks_terminal_close_all()
        Snacks.config.terminal.shell = shell
        vim.notify("Snacks terminal shell set to '" .. shell .. "'")
      end, {
        nargs = 1,
        complete = function()
          return vim.tbl_filter(function(s)
            return vim.fn.executable(s) == 1
          end, {
            "bash",
            "fish",
            "nu",
            "zsh",
          })
        end,
      })

      return vim.tbl_deep_extend("force", opts, opts_overrides)
    end,
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
      {
        "<c-q>",
        function()
          Snacks.terminal.focus(nil, { cwd = LazyVim.root() })
        end,
        desc = "Terminal (Root Dir)",
        mode = { "n", "t" },
      },
    },
  },
}
