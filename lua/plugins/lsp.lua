return {
  {
    "williamboman/mason.nvim",
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
}
