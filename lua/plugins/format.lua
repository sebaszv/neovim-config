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
      end, {
        ".editorconfig",
        ".prettierrc",
        ".prettierrc.cjs",
        ".prettierrc.cts",
        ".prettierrc.js",
        ".prettierrc.json",
        ".prettierrc.json5",
        ".prettierrc.mjs",
        ".prettierrc.mts",
        ".prettierrc.toml",
        ".prettierrc.ts",
        ".prettierrc.yaml",
        ".prettierrc.yml",
        "package.json",
        "package.yaml",
        "prettier.config.cjs",
        "prettier.config.cts",
        "prettier.config.js",
        "prettier.config.mjs",
        "prettier.config.mts",
        "prettier.config.ts",
      })

      util.prepend_args(opts, "shfmt", "--binary-next-line", ".editorconfig")
    end,
  },
}
