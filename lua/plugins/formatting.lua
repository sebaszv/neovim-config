return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- Use nixpkgs-fmt for formatting Nix code
      -- instead of nixfmt, which is the default.
      opts.formatters_by_ft.nix = { "nixpkgs_fmt" }
    end,
  },
}
