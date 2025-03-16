-- Documentation: <https://github.com/folke/lazydev.nvim>
---@module 'lazy'
---@type LazyPluginSpec
local LazyDev = {
  "folke/lazydev.nvim",
  ft = "lua",

  ---@module 'lazydev'
  ---@type lazydev.Config
  opts = {
    library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
  },
}

-- Documentation: <https://cmp.saghen.dev>
---@module 'lazy'
---@type LazyPluginSpec
local BlinkCmp = {
  "saghen/blink.cmp",
  dependencies = { "rafamadriz/friendly-snippets", LazyDev },
  version = "*",

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = "default" },
    fuzzy = { implementation = "prefer_rust_with_warning" },
    -- NOTE: Still experimental.
    signature = { enabled = true },
    sources = {
      default = { "lazydev", "lsp", "path", "snippets", "buffer" },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- Boost priority for this completion source.
          score_offset = 100,
        },
      },
    },
    cmdline = { completion = { menu = { auto_show = true } } },
    appearance = {
      -- Sets the fallback highlight groups to nvim-cmp's highlight groups
      -- Useful for when your theme doesn't support blink.cmp
      -- Will be removed in a future release
      use_nvim_cmp_as_default = true,
      -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = "mono",
    },
  },
}

-- Documentation: <https://github.com/nvimtools/none-ls.nvim>
---@module 'lazy'
---@type LazyPluginSpec
local NoneLS = {
  -- NOTE: Current not in use, hence it isn't being loaded.
  "nvimtools/none-ls.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function(plugin, opts)
    require("null-ls").setup({ sources = {} })
  end,
}

---@module 'lazy'
---@type LazyPluginSpec
local M = {
  -- TODO: Rewrite LSP configurations for Neovim 0.11.
  -- -------------------------------------------------
  -- Resources:
  -- * <https://github.com/neovim/neovim/pull/31031>
  -- * <https://github.com/neovim/nvim-lspconfig/issues/3494>
  -- * <https://cmp.saghen.dev/installation.html>
  "neovim/nvim-lspconfig",
  dependencies = { BlinkCmp, LazyDev },
  config = function(plugin, opts)
    for server, config in pairs(opts.servers) do
      -- blink.cmp merges with `config.capabilities`, if defined.
      config.capabilities =
        require("blink.cmp").get_lsp_capabilities(config.capabilities)

      require("lspconfig")[server].setup(config)
    end
  end,
  opts = {
    servers = {
      jsonls = {},
      yamlls = {},

      basedpyright = {},
      bashls = {},
      ccls = {},
      gopls = {},
      lua_ls = {},
      nil_ls = {},
      ruff = {},
      rust_analyzer = {},
    },
  },
}

return { M }
