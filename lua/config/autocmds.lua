-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Writing loads of Nix module files that require the same
-- basic starting template is tedious. This automates that
-- away.
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("nix_module_template", { clear = true }),
  desc = "Inject template for new Nix module files in specified patterns",
  pattern = {
    vim.fn.expand("~") .. "/Proyectos/nixos-config/system/*.nix",
    vim.fn.expand("~") .. "/Proyectos/nixos-config-new/system/*.nix",
    vim.fn.expand("~") .. "/Proyectos/nixos-config/home/*.nix",
    vim.fn.expand("~") .. "/Proyectos/nixos-config-new/home/*.nix",
  },
  callback = function(event)
    local size = vim.fn.getfsize(event.file)
    local new = size == -1
    local empty = size == 0

    if not new and not empty then
      return
    end

    ---@param s? string String to indent or `""`
    ---@param level? integer Indentation level or `1`
    ---@return string indented_s Indented `s`
    local function indent(s, level)
      return string.rep("  ", level or 1) .. (s or "")
    end

    ---@param dirpath string Path of directory to list imports for
    ---@return string[]? imports List of directory and Nix file names to import
    local function getimports(dirpath)
      assert(vim.fn.isdirectory(dirpath), "'" .. dirpath .. "' is not a directory")

      local dirs = {} ---@type string[]
      local files = {} ---@type string[]

      for n, t in vim.fs.dir(dirpath) do
        if n == "default.nix" then
          goto continue
        end

        if t == "directory" then
          local default = string.format("%s/%s/default.nix", dirpath, n)
          local default_stat = vim.uv.fs_stat(default)

          if default_stat and default_stat.type == "file" then
            table.insert(dirs, n)
          end
        elseif t == "file" and vim.endswith(n, ".nix") then
          table.insert(files, n)
        end

        ::continue::
      end

      if #dirs == 0 and #files == 0 then
        return nil
      end

      return vim.list_extend(dirs, files)
    end

    local template = {
      "{ ... }:",
      "{",
      indent(),
      "}",
    }

    -- Insert imports boilerplate if a "default"
    -- file and there is something to import.
    if vim.endswith(event.file, "/default.nix") then
      local dirpath = vim.fs.dirname(event.file)
      local imports = getimports(dirpath)

      local opener = indent("imports = [")
      local closer = indent("];")

      if imports then
        template[3] = opener
        table.insert(template, 4, closer)

        for _, x in ipairs(imports) do
          local pathed = "./" .. x
          table.insert(template, #template - 1, indent(pathed, 2))
        end
      end
    end

    local cursor_start_pos = { 3, #template[3] }
    local win = vim.api.nvim_get_current_win()

    vim.api.nvim_buf_set_lines(event.buf, 0, -1, true, template)
    vim.api.nvim_win_set_cursor(win, cursor_start_pos)

    vim.notify("Nix module template written to buffer", vim.log.levels.INFO)
  end,
})
