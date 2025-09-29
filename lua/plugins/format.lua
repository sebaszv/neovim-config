---@module "conform"

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    ---@param opts conform.setupOpts
    opts = function(_, opts)
      local util = require("util.conform")

      util.prepend_args(opts, "shfmt", { "--binary-next-line" })
    end,
  },
}
