# cmp-tidal

Autocompletion for [Tidal Cycles](https://tidalcycles.org/) powered by [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) and [hoogle](http://hackage.haskell.org/cgi-bin/hackage-scripts/package/hoogle).

![Showcase](showcase.gif)

## Requirements
- [neovim](https://github.com/neovim/neovim)
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [hoogle](http://hackage.haskell.org/cgi-bin/hackage-scripts/package/hoogle)

## Installation

[vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'fools-mate/cmp-tidal'
```

[packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {'fools-mate/cmp-tidal', requires = 'nvim-lua/plenary.nvim'}
```

[hoogle](http://hackage.haskell.org/cgi-bin/hackage-scripts/package/hoogle)

```sh
cabal install hoogle
hoogle generate
```

## Configuration

```lua
require("cmp").setup({
    sources = {
        { name = 'tidal' },
        -- ...more sources
    }
})
```

## Roadmap

- [ ] Autocompletions for samples

