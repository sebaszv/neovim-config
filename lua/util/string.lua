---@class util.string
local M = {}

--- Parse shebang directly or from file, if present.
--- If `strict`, the interpreter value is only returned
--- if it is an absolute path pointing to an existing
--- executable file.
---@param line_or_filepath string Line to parse or path to file to parse.
---@param is_path boolean? Whether `line_or_filepath` is a path.
---@param strict boolean? Whether to enforce the intepreter is absolute, exists, and is an executable file.
---@return string interpreter Interpreter to execute.
---@return string? argument Single argument to the interpreter.
---@return nil err_msg Parsing error reason.
---@overload fun(line_or_filepath: string, is_path: boolean?, strict: boolean?): nil, nil, string
function M.parse_shebang(line_or_filepath, is_path, strict)
  ---@type string
  local ln

  if is_path then
    if not vim.fn.filereadable(line_or_filepath) then
      return nil, nil, "File not readable."
    end

    local first_ln = io.lines(line_or_filepath)() ---@type string?

    if not first_ln then
      return nil, nil, "File empty."
    end

    ln = first_ln
  else
    if not line_or_filepath then
      return nil, nil, "No argument specified."
    end

    if line_or_filepath == "" then
      return nil, nil, "Empty argument passed."
    end

    if line_or_filepath:find("[\n\r]") then
      return nil, nil, "Line breaks present."
    end

    ln = line_or_filepath
  end

  if not vim.startswith(ln, "#!") then
    return nil, nil, "Does not start with '#!'."
  end

  ln = ln:sub(3)
  local interpreter ---@type string?
  local argument ---@type string?
  local extra_parts_count = 0 ---@type integer

  for part in ln:gmatch("%S+") do
    if not interpreter then
      interpreter = part
    elseif not argument then
      argument = part
    else
      extra_parts_count = extra_parts_count + 1
    end
  end

  if extra_parts_count ~= 0 then
    return nil, nil, ("%d total whitespace-separated parts present; expected 1 or 2."):format(extra_parts_count + 2)
  end

  if not interpreter then
    return nil, nil, "Interpreter not present."
  end

  if strict then
    if not vim.fn.isabsolutepath(interpreter) then
      return nil, nil, "Interpreter is not absolute path."
    end

    if vim.fn.executable(interpreter) ~= 1 then
      return nil, nil, "Interpreter is not an executable file."
    end
  end

  return interpreter, argument, nil
end

return M
