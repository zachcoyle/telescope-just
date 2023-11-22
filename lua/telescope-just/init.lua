local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

local get_available_recipes = function()
  local handle = io.popen("just --dump-format json --dump")
  local output = handle:read("*a")
  local j = vim.fn.json_decode(output)
  local recipes = j["recipes"]
  local keys = {}
  for key, value in pairs(recipes) do
    table.insert(keys, key)
  end
  return keys
end

local recipes = function(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = "just (Available Recipes)",

      finder = finders.new_table({
        results = get_available_recipes(),
      }),

      sorter = conf.generic_sorter(opts),

      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.fn.jobstart("just " .. selection[1])
        end)
        return true
      end,
    })
    :find()
end

recipes(require("telescope.themes").get_dropdown({}))
