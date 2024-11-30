# Line Notes.nvim

**Line Notes.nvim** is a Neovim plugin to mark specific lines in your code and add notes for future reference. It is meant as a supplement to code comments that you might want to add but don't need or want to be public.

## Features
- Add marks with notes to specific lines.
- List all marks and notes using Telescope.
- Navigate to marked lines directly from the list.

## Installation

Using `lazy.nvim`:
```lua
{
      "asmorris/line-notes.nvim",
      dependencies = { "nvim-telescope/telescope.nvim"  },
      config = function()
        -- Optional: Set custom key mappings here
          end
    
}```
