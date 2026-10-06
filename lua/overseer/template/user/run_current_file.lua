---@module "overseer"

local str_util = require("util.string")

---@type table<string, string[]>
local ft_to_cmd = {
  bash = { "bash" },
  fish = { "fish" },
  go = { "go", "run" },
  javascript = { "node" },
  nix = { "nix-instantiate", "--eval" },
  lua = { "nvim", "-l" },
  perl = { "perl" },
  python = { "python" },
  sh = { "sh" },
  typescript = { "node" },
}

--[[ TODO:
     Convert this into an `overseer.TemplateFileProvider`
     to make this task have a smarter condition checks.
     Filetype isn't a perfect indicator of if a file is
     runnable, so being able to check permissions and parse
     for a shebang is a better indicator.
     ###################################################################################################
     Reference: <https://github.com/stevearc/overseer.nvim/blob/master/doc/guides.md#template-providers>
--]]
---@type overseer.TemplateFileDefinition
return {
  name = "Run current file",
  desc = "Run the current file.",
  builder = function()
    local filepath = vim.fn.expand("%:p")
    local is_temp = false

    if vim.fn.filereadable(filepath) ~= 1 then
      filepath = vim.fn.tempname()
      is_temp = true

      local cur_buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
      local res = vim.fn.writefile(cur_buf_lines, filepath) ---@type 0|-1
      -- TODO: Handle errors.
      _ = assert(res == 0)
    end

    local interpreter, argument, _ = str_util.parse_shebang(filepath, true, true)
    local cmd

    if interpreter then
      if vim.fn.executable(filepath) == 1 then
        cmd = { filepath }
      else
        cmd = argument and {
          interpreter,
          argument,
          filepath,
        } or { interpreter, filepath }
      end
    else
      local base_cmd = ft_to_cmd[vim.bo.filetype]

      if base_cmd then
        cmd = vim.fn.copy(base_cmd)
        cmd[#cmd + 1] = filepath
      end
    end

    ---@type overseer.TaskDefinition
    return {
      cmd = cmd,
      components = is_temp
          and {
            {
              "user.subscribe",
              ---@type overseer.ComponentSkeleton
              component_skeleton = {
                on_exit = function()
                  local _, _, _ = os.remove(filepath)
                end,
              },
            },
            { "on_output_quickfix", set_diagnostics = true },
            "on_result_diagnostics",
            "default",
          }
        or {
          { "on_output_quickfix", set_diagnostics = true },
          "on_result_diagnostics",
          "default",
        },
    }
  end,
  condition = { filetype = vim.tbl_keys(ft_to_cmd) },
}
