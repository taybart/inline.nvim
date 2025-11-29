# Inline

Forked from: https://github.com/asmorris/line_notes.nvim

**Inline.nvim** is a Neovim plugin to mark specific lines in your code and add notes for future reference. It is meant as a supplement to code comments that you might want to add but don't need or want to be public, or small quick notes to yourself that are tied to a particular line, and are a quicker alternative to Obsidian or Notion or similar.

## Features

- Add marks with notes to specific lines. Just press enter and you're good to go!
- List all marks and notes using a picker.
- Navigate to marked lines directly from the list.
- Delete existing notes
- Edit existing notes, just need to close the floating window with the note.

## Installation

Using `lazy.nvim`:

```lua
{
    "taybart/inline.nvim",
    dependencies = { 
        -- needed to keep track of notes
        'kkharji/sqlite.lua',
        -- optional, for adding 'Add/Edit/View/Delete' code actions
        'taybart/code-actions.nvim',
        -- optional, note picker (Inline search)
        'folke/snacks.nvim'
    },
    opts = {
        signcolumn = { enabled = false },
        virtual_text = {
            enabled = true,
            icon = "📝",  -- Icon shown at the end of the line
        },
    },
    keys = {
        { '<leader>N', function() require('inline').notes.show(false) end }
    },
}
```

## Default Configuration

```lua
{
  signcolumn = {
    enabled = true,
    icon = '>',
    highlight = 'Comment',
    number_highlight = '',
  },
  virtual_text = {
    enabled = false,
    icon = '!',
    highlight = 'Comment',
  },
  popup = {
    relative = 'cursor',
    width = 50,
    height = 10,
    row = 1,
    col = 1,
    style = 'minimal',
    border = 'rounded',
  },
}
```



## Usage

```vim
:Inline show
:Inline edit
:Inline file
:Inline add
:Inline move
:Inline delete
:Inline search
```

also available in lua:

```lua
local notes = require('inline.notes')
notes.show()
notes.edit()
notes.file()
notes.add()
notes.move()
notes.delete()
notes.search()
```
