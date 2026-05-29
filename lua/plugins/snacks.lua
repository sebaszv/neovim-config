return {
  ---@module "snacks"
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      win = {
        wo = {
          number = true,
          relativenumber = true,
        },
      },
    },
  },
}
