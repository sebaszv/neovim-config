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
    end,
  },
}
