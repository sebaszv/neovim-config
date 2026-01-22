return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- Ensure that Mason appends to PATH, rather than
      -- prepending, so that whatever was originally on
      -- PATH is tried first, with Mason installations
      -- serving as fallbacks. The reason for this is
      -- that some builds by Mason don't place nicely
      -- with NixOS.
      opts.PATH = "append"

      -- Filter out haskell-language-server so that Mason
      -- doesn't try to install it. Building it requires
      -- ghcup, which I don't have globally installed
      -- on my NixOS systems. Mason is able to use
      -- whatever is on PATH.
      opts.ensure_installed = vim.tbl_filter(function(x)
        return x ~= "haskell-language-server"
      end, opts.ensure_installed or {})
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}

      opts.formatters.shfmt = opts.formatters.shfmt or {}
      opts.formatters.shfmt.append_args = opts.formatters.shfmt.append_args or {}
      table.insert(opts.formatters.shfmt.append_args, "--binary-next-line")

      if vim.bo.filetype == "markdown" then
        opts.formatters.prettier = opts.formatters.prettier or {}
        opts.formatters.prettier.append_args = opts.formatters.prettier.append_args or {}
        table.insert(opts.formatters.prettier.append_args, "--prose-wrap")
        table.insert(opts.formatters.prettier.append_args, "always")
      end
    end,
  },
}
