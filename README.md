# package-json-scripts.nvim

Integration for accessing package.json scripts in
[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)


# Installation

```lua
use {'nvim-lua/popup.nvim'}
use {'nvim-lua/plenary.nvim'}
use {'nvim-telescope/telescope.nvim'}
use {'voldikss/vim-floaterm'}
use {'kishikaisei/telescope-js-package-scripts.nvim}
```

# Usage

```lua
require('telescope').extensions.packagescript.scripts()
```

# Credits
Using the lua json parser from [rxi/json.lua](https://github.com/rxi/json.lua)
