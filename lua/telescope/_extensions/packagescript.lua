local actions = require('telescope.actions')
local state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
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
      local scripts         = {}
      for name, code in pairs(scriptsFromJson) do
        table.insert(scriptsNames, name)
        table.insert(scripts, code)
      end

      pickers.new(opts, {
        prompt_title = 'Scripts',
        finder = finders.new_table {
          results = scriptsNames
        },
        sorter = sorters.get_generic_fuzzy_sorter(),
        attach_mappings = function(prompt_bufnr, map)
          local execute_script = function()
            local selection = state.get_selected_entry(prompt_bufnr)
            actions.close(prompt_bufnr)

            local cmdTerm = Terminal:new({
              cmd = scriptsFromJson[selection.value],
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
          end

          map('i', '<CR>', execute_script)
          map('n', '<CR>', execute_script)

          return true
        end
      }):find()
    end
  }
}
