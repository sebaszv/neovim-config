---@module "snacks"

return {
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
      picker = {
        sources = {
          -- Enable wrapping by default
          -- on the notification pane
          -- so messages can be fully
          -- read always.
          notifications = {
            win = {
              preview = {
                wo = { wrap = true },
              },
            },
          },
        },
      },
    },
  },
}
