return {
  {
    "echasnovski/mini.pairs",
    opts = function(_, opts)
      -- This is enabled by default. The
      -- pairs behaviour in command-mode
      -- is more of a pain that it helps.
      opts.modes.command = false
    end,
  },
}
