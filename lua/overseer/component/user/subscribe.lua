---@module "overseer"

---@type overseer.ComponentFileDefinition
return {
  desc = "Define task template callbacks.",
  long_desc = "To set event callbacks for task templates, components would be required normally. Those callbacks can be written right in the template.",
  params = {
    component_skeleton = {
      desc = "Table of component callback event names to functions.",
      long_desc = "View `overseer.ComponentSkeleton` for the schema.",
      type = "opaque",
      optional = false,
      validate = function(value)
        if type(value) ~= "table" then
          return false
        end

        for n, v in pairs(value) do
          if (type(n) ~= "string") or (type(v) ~= "function") then
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
