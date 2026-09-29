---@module "overseer"

-- Keep in sync with <https://github.com/stevearc/overseer.nvim/blob/master/lua/overseer/component.lua#L24-L24>
---@type table<string, true>
local component_method_names = {
  on_init = true,
  on_pre_start = true,
  on_start = true,
  on_reset = true,
  on_pre_result = true,
  on_preprocess_result = true,
  on_result = true,
  on_complete = true,
  on_status = true,
  on_output = true,
  on_output_lines = true,
  on_exit = true,
  on_dispose = true,
}

---@type overseer.ComponentFileDefinition
return {
  desc = "Define custom component callbacks in task templates without needing to create file components nor manually subscribe tasks.",
  params = {
    component_skeleton = {
      desc = "Table of component names to callback functions.",
      type = "opaque",
      optional = false,
      validate = function(value)
        if type(value) ~= "table" then
          return false
        end

        for n, v in pairs(value) do
          if (not component_method_names[n]) or (type(v) ~= "function") then
            return false
          end
        end

        return true
      end,
    },
  },
  constructor = function(params)
    ---@type overseer.ComponentSkeleton
    return params.component_skeleton
  end,
}
