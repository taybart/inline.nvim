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
      vim.b.filetype = 'markdown'
      vim.keymap.set('n', 'q', '<cmd>close!<CR>', { buffer = true, silent = true })
      vim.keymap.set('n', '<esc>', '<cmd>close!<CR>', { buffer = true, silent = true })
    end,
  })

  vim.api.nvim_create_user_command('LineNotes', function(opts)
    local args = vim.split(opts.args, '%s+', { trimempty = true })
    -- Default
    if #args == 0 then
      ln.notes.show()
      return
    end

    local command = args[1]
    table.remove(args, 1) -- Remove command

    if command == 'show' then
      ln.notes.show()
    elseif command == 'edit' then
      ln.notes.show()
    elseif command == 'file' then
      ln.notes.edit_file_note()
    elseif command == 'add' then
      ln.notes.add()
    elseif command == 'move' then
      ln.notes.move()
    elseif command == 'delete' then
      ln.notes.delete()
    elseif command == 'search' then
      ln.telescope_picker.open_notes_picker()
    end
  end, {
    nargs = '*',
    complete = function(arg_lead, cmd_line, cursor_pos)
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
  local sign_config = require('line_notes.config').config.signcolumn
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
  vim.treesitter.language.register('markdown', 'line_notes')
  -- Load notes
  require('line_notes').notes.load()
  return M
end

M.config = require('line_notes.config')
M.notes = require('line_notes.notes')
M.telescope_picker = require('line_notes.telescope_picker')

return M
