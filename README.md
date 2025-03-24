# Inline

Forked from: https://github.com/asmorris/line_notes.nvim

**Inline.nvim** is a Neovim plugin to mark specific lines in your code and add notes for future reference. It is meant as a supplement to code comments that you might want to add but don't need or want to be public, or small quick notes to yourself that are tied to a particular line, and are a quicker alternative to Obsidian or Notion or similar.

## Demo

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
    "taybart/inline.nvim",
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
        local in = require('inline')
        in.setup({
            signcolumn = {
                enabled = false,
            },
            virtual_text = {
                icon = "🗒️",  -- Icon shown at the end of the line
            },
        })
        vim.keymap.set('n', '<leader>N', function()
            in.notes.show(false) -- don't enter note (i.e. just display in hover)
        end)
    end
}
```

## Default Configuration

```lua
require('inline').setup({
  keymaps = {
    enabled = true,
    add_note = '<leader>an',
    list_notes = '<leader>ln',
    delete_note = '<leader>dn',
    show_note = '<leader>sn',
  },
  signcolumn = {
    enabled = true,
    icon = '>',
    highlight = 'Comment',
    number_highlight = '',
  },
  virtual_text = {
    enabled = true,
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
})
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
}
```

### TODO

- [ ] Lazy load inital file read
