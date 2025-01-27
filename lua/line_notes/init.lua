local M = {}

local function setup_commands()
  local ln = require('line_notes')
  -- Set up autocmd for buffer events
  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufEnter' }, {
    callback = function()
      ln.notes.load_for_buffer()
    end,
  })
  -- easy escape from float
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'line_notes',
    callback = function()
      vim.keymap.set('n', 'q', '<cmd>close!<CR>', { buffer = true, silent = true })
      vim.keymap.set('n', '<esc>', '<cmd>close!<CR>', { buffer = true, silent = true })
    end,
  })
  vim.api.nvim_create_user_command('LineNotes', function(opts)
    local args = vim.split(opts.args, '%s+', { trimempty = true })
    if #args == 0 then
      -- Default
      ln.notes.show()
      return
    end

    local command = args[1]
    table.remove(args, 1) -- Remove command

    if command == 'show' then
      ln.notes.show()
    elseif command == 'add' then
      ln.notes.add()
    elseif command == 'delete' then
      ln.notes.delete()
    elseif command == 'search' then
      ln.telescope_picker.open_notes_picker()
    end
  end, { nargs = '*' })
end

-- Define signs based on configuration
local function setup_signs()
  local sign_config = require('line_notes.config').config.signs
  vim.fn.sign_define('LineNote', {
    text = sign_config.note_icon,
    texthl = sign_config.highlight,
    numhl = sign_config.number_highlight,
  })
end

local function setup_keymaps(keymaps)
  local ln = require('line_notes')
  local function map(key, cmd)
    vim.keymap.set('n', key, cmd, { noremap = true, silent = true })
  end

  map(keymaps.add_note, ln.notes.add_note)
  map(keymaps.delete_note, ln.notes.delete_note)
  map(keymaps.show_note, ln.notes.show_note)
  map(keymaps.list_notes, ln.telescope_picker.open_notes_picker)
end

function M.setup(opts)
  -- Initialize configuration
  local config = require('line_notes.config').setup(opts)

  if config.keymaps.enabled then
    setup_keymaps(config.keymaps)
  end
  setup_commands()
  setup_signs()
  -- Load notes
  require('line_notes').notes.load()
end

M.config = require('line_notes.config')
M.notes = require('line_notes.notes')
M.telescope_picker = require('line_notes.telescope_picker')

return M
