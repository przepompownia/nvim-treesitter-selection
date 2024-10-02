<div align="center">
  <h1>nvim-treesitter-selection</h1>

At the moment the goal of this Neovim plugin is to extract incremental selection code from the master branch of [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) to make it working on Nvim 0.10 and later. Note that only `init_selection`, `node_incremental` and `node_decremental` equivalents are now included here. 

### Table of contents

- [Quickstart](#quickstart)

---

# Quickstart

## Requirements

- **Neovim 0.10** or later  ([nightly](https://github.com/neovim/neovim#install-from-source) recommended)

## Installation

You can install `nvim-treesitter-selection` with your favorite package manager (or using the native `package` feature of vim, see `:h packages`).

## Example usage
```lua
vim.keymap.set({'n'}, ',]', function() require('nvim-treesitter-selection.incremental_selection').init_selection() end)
vim.keymap.set({'x'}, ',]', function() require('nvim-treesitter-selection.incremental_selection').node_incremental() end)
vim.keymap.set({'x'}, ',[', function() require('nvim-treesitter-selection.incremental_selection').node_decremental() end)
```
