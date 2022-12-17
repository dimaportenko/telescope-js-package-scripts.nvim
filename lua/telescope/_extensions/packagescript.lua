local actions = require('telescope.actions')
local state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
local previewers = require("telescope.previewers")
local Terminal = require("toggleterm.terminal").Terminal

return require('telescope').register_extension {
  exports = {
    scripts = function(opts)
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
      -- local scripts         = {}
      for name, code in pairs(scriptsFromJson) do
        table.insert(scriptsNames, { name, code })
        -- table.insert(scripts, code)
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

        -- previewer = previewers.new_buffer_previewer {
        --   title = "Preview",
        --   get_buffer_by_name = function(_, entry)
        --     return entry.value
        --   end,
        --   define_preview = function(self, entry, _)
        --     pcall(vim.api.nvim_buf_set_lines, self.state.bufnr, 0, -1, false, { entry.code })
        --   end,
        --   -- add teardown
        --   teardown = function()
        --     -- print("teardown")
        --   end
        -- },

        attach_mappings = function(prompt_bufnr, map)
          local execute_script = function()
            local selection = state.get_selected_entry(prompt_bufnr)
            actions.close(prompt_bufnr)

            local cmdTerm = Terminal:new({
              -- cmd = 'yarn ' .. scriptsFromJson[selection.value],
              cmd = 'yarn ' .. selection.value,
              hidden = true,
              close_on_exit = false,
              -- on_open = fun(t: Terminal), -- function to run when the terminal opens
              -- on_close = fun(t: Terminal), -- function to run when the terminal closes
              -- on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
              -- on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr
              -- on_exit = fun(t: Terminal, job: number, exit_code: number, name: string) -- function to run when terminal process exits
            })

            cmdTerm:toggle()
            -- print(vim.inspect(scriptsFromJson[selection.value]))
            -- print(vim.inspect(selection.value))
          end

          map('i', '<CR>', execute_script)
          map('n', '<CR>', execute_script)

          return true
        end
      }):find()
    end
  }
}
