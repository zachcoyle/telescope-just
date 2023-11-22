local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

local format_doc = function(s)
  if s == vim.NIL then
    return ""
  else
    return "# " .. s
  end
end

local function format_entry_display(entry)
  local recipe_param_names = {}
  for _, v in ipairs(entry["body"][1]) do
    if type(v) ~= "string" then
      table.insert(recipe_param_names, v[1][2])
    end
  end
  return entry["cmd"] .. " " .. table.concat(recipe_param_names, " ") .. " " .. entry["doc"]
end

local function get_recipe_arg_values(section)
  if type(section) == "string" then
    return section
  else
    return vim.fn.input({ ["prompt"] = section[1][2] .. ": " })
  end
end

local get_available_recipes = function()
  local handle = io.popen("just --dump-format json --dump")
  local output = handle:read("*a")
  local j = vim.fn.json_decode(output)
  local recipes = j["recipes"]
  local keys = {}
  for key, value in pairs(recipes) do
    table.insert(keys, {
      ["cmd"] = key,
      ["doc"] = format_doc(value["doc"]),
      ["body"] = value["body"],
    })
  end
  return keys
end

local M = {}

M.just = function(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = "just (Available Recipes)",

      finder = finders.new_table({
        results = get_available_recipes(),
        entry_maker = function(entry)
          return {
            value = entry,
            display = format_entry_display(entry),
            ordinal = entry["cmd"],
          }
        end,
      }),

      sorter = conf.generic_sorter(opts),

      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          local command = {}
          for _, v in ipairs(selection["value"]["body"][1]) do
            local param = get_recipe_arg_values(v)
            table.insert(command, param)
          end
          actions.close(prompt_bufnr)
          local final_command = table.concat(command, " ")
          vim.fn.jobstart(final_command, {
            ["on_stdout"] = function()
              vim.cmd(string.format([[ echomsg "command: \"%s\" finished" ]], final_command))
            end,
          })
        end)
        return true
      end,
    })
    :find()
end

M.just(require("telescope.themes").get_dropdown({}))

return M
