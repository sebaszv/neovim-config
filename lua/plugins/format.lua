---@module "conform"

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    ---@param opts conform.setupOpts
    opts = function(_, opts)
      local util = require("util.conform")

      util.prepend_args(opts, "prettier", function(_, ctx)
        if vim.bo[ctx.buf].filetype == "markdown" then
          return { "--prose-wrap=always" }
        end

        return {}
      end)

      util.prepend_args(opts, "shfmt", { "--binary-next-line" })
    end,
  },
}
