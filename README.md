# Line Notes.nvim

**Line Notes.nvim** is a Neovim plugin to mark specific lines in your code and add notes for future reference. It is meant as a supplement to code comments that you might want to add but don't need or want to be public, or small quick notes to yourself that are tied to a particular line, and are a quicker alternative to Obsidian or Notion or similar.

## Demo
![lineNotes](https://github.com/user-attachments/assets/b361cf26-4d23-4eca-8e10-81a8fcf68954)


## Features

- Add marks with notes to specific lines. Just press enter and you're good to go!
- List all marks and notes using Telescope.
- Navigate to marked lines directly from the list.
- Delete existing notes
- Edit existing notes, just need to close the floating window with the note.

## Installation

Using `lazy.nvim`:

```lua
{
      "asmorris/line_notes.nvim",
      dependencies = { "nvim-telescope/telescope.nvim"  },
      config = function()
        -- Optional: Set custom key mappings here
          end

}
```
