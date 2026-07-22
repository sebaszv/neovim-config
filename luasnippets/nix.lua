local s = require("luasnip").snippet
local t = require("luasnip").text_node
local i = require("luasnip").insert_node
local d = require("luasnip").dynamic_node
local sn = require("luasnip").snippet_node

--- Return the indentation string for the current buffer.
---@return string
local function buf_ind()
  local sw = vim.bo.shiftwidth

  if sw == 0 then
    sw = vim.bo.tabstop
  end

  if vim.bo.expandtab then
    return string.rep(" ", sw)
  end

  return "\t"
end

---@param lvl integer? Indentation level or 1.
---@param s_ string? String to indent or "".
---@param sw string? Shiftwidth string to repeat or default for the current buffer.
---@return string # Indented string.
---@overload fun(s_: string): string
---@overload fun(s_: string, sw: string): string
local function indent(lvl, s_, sw)
  if type(lvl) == "string" then
    sw = s_
    s_ = lvl
    lvl = nil
  end

  return (sw or buf_ind()):rep(lvl or 1) .. (s_ or "")
end

--- Whether the cursor (or cursor of the window) is positioned inside the treesitter node.
---@param ts_node TSNode Treesitter node to check in.
---@param cursor_or_win ([integer, integer] | integer)? Cursor to check position of. A window ID can be specified instead, whose cursor will be used. Otherwise, the cursor for the current window is used.
---@return boolean
local function cursor_in_ts_node(ts_node, cursor_or_win)
  local cursor

  if type(cursor_or_win) == "table" then
    cursor = cursor_or_win
  else
    cursor = vim.api.nvim_win_get_cursor(cursor_or_win or 0)
  end

  local row, col = cursor[1] - 1, cursor[2]

  local start_row, start_col, end_row, end_col = ts_node:range()
  local past_start = row > start_row or (row == start_row and col >= start_col)
  local before_end = row < end_row or (row == end_row and col <= end_col)

  return past_start and before_end
end

--- List Nix directory and file names to use for `imports = [ ... ]` in a module.
---@param dirpath string Path of directory to list imports for.
---@return string[]? importables List of directory and Nix file names to import.
local function list_nix_importables(dirpath)
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

--- Inspect the buffer and window cursor for context about the top-level Nix expression, if any.
---@param buf integer? Buffer to check or the current buffer.
---@param win integer? Window whose cursor to check or the current window.
---@return boolean has_root Whether the buffer has a top-level Nix expression yet (not "empty" in other words). Top-level let-bindings are ignored; only if it has a body does it count.
---@return boolean cursor_in_expr Whether the window cursor is inside such top-level Nix expression or its parent let-binding, if any.
local function root_nix_expression_context(buf, win)
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
        cursor_in_expr = cursor_in_ts_node(child, cursor)

        if not has_root then
          break
        end
      end

      has_root = true
      cursor_in_expr = cursor_in_expr or cursor_in_ts_node(child, cursor)

      break
    end
  end

  return has_root, cursor_in_expr
end

return {
  s({
    trig = "module",
    desc = "Nix module boilerplate with optional imports",
  }, {
    d(1, function()
      local file = vim.api.nvim_buf_get_name(0)

      local is_default = vim.endswith(file, "default.nix")
      local has_root_expr, in_expr = root_nix_expression_context(0, 0)

      local importables

      if is_default and not has_root_expr and not in_expr then
        importables = list_nix_importables(vim.fs.dirname(file))
      end

      local sw = buf_ind()
      --- Passthrough `indent` wrapper with `sw` set to
      --- current buffer value to save some API calls.
      ---@param lvl integer? Indentation level or 1.
      ---@param s_ string? String to indent or "".
      ---@return string # Indented string.
      ---@overload fun(s_: string): string
      local function indent_(lvl, s_)
        if lvl and not s_ then
          s_ = lvl --[[@as string]]
          lvl = nil
        end

        return indent(lvl, s_, sw)
      end

      local nodes = { t({ "{ ... }:", "{" }) }

      if not importables then
        nodes[#nodes + 1] = t({ "", indent_() })
      else
        nodes[#nodes + 1] = t({ "", indent_("imports = [") })

        for _, name in ipairs(importables) do
          nodes[#nodes + 1] = t({ "", indent_(2, "./" .. name) })
        end

        nodes[#nodes + 1] = t({ "", indent_("];") })
      end

      nodes[#nodes + 1] = i(1)
      nodes[#nodes + 1] = t({ "", "}" })

      if in_expr then
        nodes[#nodes + 1] = t({ ";" })
      end

      return sn(nil, nodes)
    end),
  }),
}
