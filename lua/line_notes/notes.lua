local M = {}

local utils = require('line_notes.utils')

local notes_file = vim.fn.stdpath('data') .. '/line_notes.json'
local notes = {}

function M.add()
  local where = utils.where()
  local note = utils.note_at_line(notes)

  local popup = utils.popup()

  if note and note.idx == nil and note.original == nil then
    local note_lines = vim.split(note.original, '\n', { plain = true })
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, note_lines)
  end

  local function save_note()
    local update = vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false)
    if update == nil or update == '' then
      return
    end
    table.insert(
      notes,
      { line = where.line - 1, note = table.concat(update, '\n'), file = where.file }
    )
    vim.fn.sign_place(where.line, 'LineNotesGroup', 'LineNote', where.bufnr, { lnum = where.line })
    M.save()
    popup:unmount()
  end

  popup:map('n', '<enter>', function()
    print('saving note')
    save_note()
  end, { noremap = true, silent = true })
  popup:mount()
  popup:on('BufLeave', function()
    -- don't save
    popup:unmount()
  end)
end

function M.show()
  local note = utils.note_at_line(notes)
  if not note or note.idx == nil and note.original == nil then
    print('no note at line')
    return
  end

  local note_lines = vim.split(note.original, '\n', { plain = true })

  local popup = utils.popup()
  -- mount/open the component
  popup:mount()
  -- unmount component when cursor leaves buffer
  popup:on('BufLeave', function()
    local edited_lines = vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false)
    local new_note = table.concat(edited_lines, '\n')

    if note.idx and new_note ~= note.original then
      print('updating note')
      notes[note.idx].note = new_note
      M.save()
    else
      print('no changes made to the note')
    end
    popup:unmount()
  end)

  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, note_lines)
end

function M.delete()
  local where = utils.where()

  if vim.api.nvim_buf_is_valid(where.bufnr) == false then
    error('invalid buffer!')
    return
  end

  for i, mark in ipairs(notes) do
    if mark.file == vim.fn.expand('%:p') and mark.line == where.line - 1 then
      table.remove(notes, i)

      local result =
        vim.fn.sign_unplace('LineNotesGroup', { id = where.line, buffer = where.bufnr })
      if result == nil then
        error('failed to unplace sign')
        return
      end

      if M.save() then
        print('note deleted')
      end
      return
    end
  end

  print('no note found on this line')
end

function M.load_for_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local current_file = vim.fn.expand('%:p')

  if not notes or type(notes) ~= 'table' then
    return
  end

  vim.fn.sign_unplace('LineNotesGroup', { buffer = bufnr })

  for _, mark in ipairs(notes) do
    if mark.file == current_file then
      local lnum = mark.line + 1
      vim.fn.sign_place(lnum, 'LineNotesGroup', 'LineNote', bufnr, { lnum = lnum })
    end
  end
end

function M.load()
  local file = io.open(notes_file, 'r')
  if file then
    local content = file:read('*a')
    file:close()
    local decoded = vim.fn.json_decode(content)
    if decoded then
      notes = decoded

      local bufnr = vim.api.nvim_get_current_buf()
      vim.fn.sign_unplace('LineNotesGroup', { buffer = bufnr })

      for _, mark in ipairs(notes) do
        if mark.file == vim.fn.expand('%:p') then
          local lnum = mark.line + 1
          vim.fn.sign_place(lnum, 'LineNotesGroup', 'LineNote', bufnr, { lnum = lnum })
        end
      end
    else
      error('failed to decode notes')
    end
  else
    print('no saved notes found')
  end
end

function M.save()
  local file = io.open(notes_file, 'w')
  if file then
    local encoded = vim.fn.json_encode(notes)
    file:write(encoded)
    file:close()
    print('note updated')
    return true
  else
    print('unable to save notes')
    return false
  end
end

return M
