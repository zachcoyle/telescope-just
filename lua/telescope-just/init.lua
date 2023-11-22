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
            display = entry["cmd"] .. " " .. entry["doc"],
            ordinal = entry["cmd"],
          }
        end,
      }),

      sorter = conf.generic_sorter(opts),

      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          -- TODO: check to see if recipe has parameters and open a dialog to accept them
          local selection = action_state.get_selected_entry()
          vim.fn.jobstart("just " .. selection["value"]["cmd"])
        end)
        return true
      end,
    })
    :find()
end

M.just(require("telescope.themes").get_dropdown({}))

return M
