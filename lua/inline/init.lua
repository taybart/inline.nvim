local M = {}

local function setup_commands()
  local il = require('inline')
  -- Set up autocmd for buffer events
  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufEnter' }, {
    callback = function()
      il.notes.load_for_buffer()
    end,
  })
  -- easy escape from float
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'inline_notes',
    callback = function()
      vim.bo.filetype = 'markdown'
      vim.keymap.set('n', 'q', '<cmd>close!<CR>', { buffer = true, silent = true })
      vim.keymap.set('n', '<esc>', '<cmd>close!<CR>', { buffer = true, silent = true })
    end,
  })

  vim.api.nvim_create_user_command('Inline', function(opts)
    local args = vim.split(opts.args, '%s+', { trimempty = true })
    -- Default
    if #args == 0 then
      il.notes.show()
      return
    end

    local command = args[1]
    table.remove(args, 1) -- Remove command

    if command == 'show' then
      il.notes.show(false)
    elseif command == 'edit' then
      il.notes.show()
    elseif command == 'file' then
      il.notes.show(true, true)
    elseif command == 'add' then
      il.notes.add()
    elseif command == 'move' then
      il.notes.move()
    elseif command == 'delete' then
      il.notes.delete()
    elseif command == 'search' then
      il.telescope_picker.open_notes_picker()
    end
  end, {
    nargs = '*',
    complete = function(arg_lead)
      local commands = { 'show', 'edit', 'file', 'add', 'move', 'delete', 'search' }

      local pattern = arg_lead:gsub('(.)', function(c)
        return string.format('%s[^%s]*', c:lower(), c:lower())
      end)
      -- Case-insensitive fuzzy matching
      local matches = {}
      for _, command in ipairs(commands) do
        if string.find(command:lower(), pattern) then
          table.insert(matches, command)
        end
      end
      return matches
    end,
  })
end

-- Define signs based on configuration
local function setup_signs()
  local sign_config = require('inline.config').config.signcolumn
  vim.fn.sign_define('InlineNote', {
    text = sign_config.note_icon,
    texthl = sign_config.highlight,
    numhl = sign_config.number_highlight,
  })
end

local function setup_keymaps(keymaps)
  local il = require('inline')
  local function map(key, cmd)
    vim.keymap.set('n', key, cmd, { noremap = true, silent = true })
  end

  map(keymaps.add_note, il.notes.add_note)
  map(keymaps.delete_note, il.notes.delete_note)
  map(keymaps.show_note, il.notes.show_note)
  map(keymaps.list_notes, il.telescope_picker.open_notes_picker)
end

function M.setup(opts)
  -- Initialize configuration
  local config = require('inline.config').setup(opts)

  if config.keymaps.enabled then
    setup_keymaps(config.keymaps)
  end
  setup_commands()
  setup_signs()
  vim.treesitter.language.register('markdown', 'inline_notes')
  -- Load notes
  require('inline').notes.load()
  return M
end

M.config = require('inline.config')
M.notes = require('inline.notes')
M.telescope_picker = require('inline.telescope_picker')

return M
