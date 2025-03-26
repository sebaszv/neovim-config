return {
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      -- This is off by default, so we
      -- enable it here.
      opts.attach_to_untracked = true
    end,
  },
}
