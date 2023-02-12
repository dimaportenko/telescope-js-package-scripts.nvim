local telescope = require('telescope')
local scripts = require('packagescript').scripts

return telescope.register_extension {
    exports = {
        scripts = scripts,
    }
}
