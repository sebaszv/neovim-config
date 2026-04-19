return {
  {
    "nvim-mini/mini.files",
    opts = function(_, opts)
      -- Move files to trash instead of
      -- outright removing.
      -- TODO: Implement and upstream use of
      --       actual system trash instead of
      --       special module trash path.
      --       `folke/snacks_explorer` implements
      --       this correctly, so porting the
      --       functionality into the
      --       `nvim-mini/mini.files` codebase
      --       would be the goal.
      -- opts.options.permanent_delete = false
    end,
  },
}
