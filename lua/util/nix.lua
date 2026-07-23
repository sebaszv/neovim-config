local ts_util = require("util.treesitter")

---@class util.nix
local M = {}

--- List Nix directory and file names to use for `imports = [ ... ]` in a module.
---@param dirpath string Path of directory to list imports for.
---@return string[]? importables List of directory and Nix file names to import.
function M.list_nix_importables(dirpath)
  if vim.fn.isdirectory(dirpath) == 0 then
    return nil
  end

  local dirs = {}
  local files = {}

  for nm, typ in vim.fs.dir(dirpath) do
    if nm == "default.nix" then
      goto continue
    end

    if typ == "directory" then
      local st = vim.uv.fs_stat(("%s/%s/default.nix"):format(dirpath, nm))

      if st and st.type == "file" then
        dirs[#dirs + 1] = nm
      end

      goto continue
    end

    if (typ == "file") and vim.endswith(nm, ".nix") then
      files[#files + 1] = nm
    end

    ::continue::
  end

  if (#dirs == 0) and (#files == 0) then
    return nil
  end

  return vim.list_extend(dirs, files)
end

--- Whether the buffer has any Nix expression at all (excludes comments and whitespace).
--- This is stricter than the context provided by `util.nix.root_nix_expression_context`
--- as this even excludes let-bindings. This is useful for validating that a buffer would
--- be suitable for being a Nix flake file, which must be a top-level attribute set. Nothing
--- else is permitted.
---@param buf integer? Buffer to check or the current buffer.
---@return boolean
function M.has_no_nix_expr(buf)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "nix")

  if not (ok and parser) then
    return false
  end

  local trees = parser:parse()

  if not trees then
    return false
  end

  local root = trees[1]:root()

  for child in root:iter_children() do
    if child:named() and child:type() ~= "comment" then
      return false
    end
  end

  return true
end

--- Inspect the buffer and window cursor for context about the top-level Nix expression, if any.
---@param buf integer? Buffer to check or the current buffer.
---@param win integer? Window whose cursor to check or the current window.
---@return boolean has_root Whether the buffer has a top-level Nix expression yet (not "empty" in other words). Top-level let-bindings are ignored; only if it has a body does it count.
---@return boolean cursor_in_expr Whether the window cursor is inside such top-level Nix expression or its parent let-binding, if any.
function M.root_nix_expression_context(buf, win)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "nix")

  if not (ok and parser) then
    return false, false
  end

  local trees = parser:parse()

  if not trees then
    return false, false
  end

  local root = trees[1]:root()
  local cursor = vim.api.nvim_win_get_cursor(win or 0)

  local has_root, cursor_in_expr = false, false

  for child in root:iter_children() do
    if child:named() and child:type() ~= "comment" then
      if child:type() == "let_expression" then
        local body = child:field("body")[1]

        has_root = body and not body:has_error()
        cursor_in_expr = ts_util.cursor_in_ts_node(child, cursor)

        if not has_root then
          break
        end
      end

      has_root = true
      cursor_in_expr = cursor_in_expr or ts_util.cursor_in_ts_node(child, cursor)

      break
    end
  end

  return has_root, cursor_in_expr
end

return M
