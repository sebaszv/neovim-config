return {
  {
    "L3MON4D3/LuaSnip",
    optional = true,
    opts = function()
      -- Only do this when the extra is enabled since this
      -- is only useful for intentional LuaSnip use, not
      -- when a transitive dependency.
      -- That module also calls the lazy VSCode loader.
      -- View that extras module to see how it's wired.
      if LazyVim.has_extra("coding.luasnip") then
        -- Scan for "snippets" at the root of all RTP entries.
        -- Load children snippets mapped to filetype by module
        -- name (e.g. `snippets/nix.snippets` -> `nix`) lazily
        -- whenever LuaSnip is actually set up. This includes
        -- `vim.fn.stdpath("config")` since it is an RTP entry.
        require("luasnip.loaders.from_snipmate").lazy_load()
        -- Scan for "luasnippets" at the root of all RTP entries.
        -- Load children snippets mapped to filetype by module
        -- name (e.g. `luasnippets/nix.lua` -> `nix`) lazily
        -- whenever LuaSnip is actually set up. This includes
        -- `vim.fn.stdpath("config")` since it is an RTP entry.
        require("luasnip.loaders.from_lua").lazy_load()
      end
    end,
  },
}
