local actions = require('telescope.actions')
local state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
-- local previewers = require("telescope.previewers")
local Terminal = require("toggleterm.terminal").Terminal

local M = {}
M.scripts = function(opts)
  opts = opts or {}

  local filePath = vim.fn.getcwd() .. '/package.json'

  local file = io.open(filePath, "rb")
  if file == nil then
    error("Package.json could not be found")
  end

  local jsonString = file:read "*a"
  file:close()

  local scriptsFromJson = vim.fn.json_decode(jsonString)['scripts']
  local scriptsNames    = {}
  for name, code in pairs(scriptsFromJson) do
    table.insert(scriptsNames, { name, code })
  end

  -- find the length of the longest script name
  local longestScriptName = 0
  for _, script in ipairs(scriptsNames) do
    if #script[1] > longestScriptName then
      longestScriptName = #script[1]
    end
  end

  pickers.new(opts, {
    prompt_title = 'Search',
    results_title = 'Scripts',
    layout_strategy = "horizontal",
    layout_config = {
      width = 0.8,
      height = 0.4,
      preview_width = 0.6,
    },
    finder = finders.new_table {
      results = scriptsNames,
      entry_maker = function(entry)
        -- fill string with spaces to make it the same length as the longest script name
        local spaces = string.rep(" ", longestScriptName - #entry[1])
        local display = entry[1] .. spaces .. "  ||  " .. entry[2]
        return {
          value = entry[1],
          ordinal = entry[1],
          display = display,
          code = entry[2]
        }
      end,
    },
    sorter = sorters.get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      local execute_script_with_params = function(with_params)
        local selection = state.get_selected_entry()
        actions.close(prompt_bufnr)

        local params = ''
        if with_params then
          params = ' ' .. vim.fn.input(selection.code .. ' ')
        end

        local cmdTerm = Terminal:new({
          cmd = 'yarn ' .. selection.value .. params,
          hidden = true,
          close_on_exit = false,
        })

        cmdTerm:toggle()
        -- print(vim.inspect(scriptsFromJson[selection.value]))
        -- print(vim.inspect(selection.value))
      end

      local execute_script = function()
        execute_script_with_params(false)
      end

      local execute_script_with_input = function()
        execute_script_with_params(true)
      end


      map('i', '<CR>', execute_script)
      map('n', '<CR>', execute_script)

      map('i', '<C-i>', execute_script_with_input)
      map('n', '<C-i>', execute_script_with_input)

      return true
    end
  }):find()
end

return M
