local M = {}

local notes_file = vim.fn.stdpath('data') .. '/line_notes.json'
M.notes = {}

local function where()
  local line = vim.fn.line('.')
  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.fn.expand('%:p')
  return { line = line, bufnr = bufnr, file = file }
end

function M.add()
  local wh = where()
  local file_notes = M.notes[wh.file] or {}
  local note = file_notes[tostring(wh.line)]

  local popup = require('line_notes.popup'):new()

  if note then
    local note_lines = vim.split(note, '\n', { plain = true })
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, note_lines)
    popup:set_content(note_lines)
  end

  local function save_note()
    print('saving note')
    local update = vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false)
    if update == nil or update == '' then
      return
    end
    vim.fn.sign_place(wh.line, 'LineNotesGroup', 'LineNote', wh.bufnr, { lnum = wh.line })
    file_notes[tostring(wh.line)] = table.concat(update, '\n')
    M.notes[wh.file] = file_notes
    M.save()
    popup:unmount()
  end

  popup:mount()

  popup:map('n', '<enter>', function()
    save_note()
  end, { noremap = true, silent = true })
  popup:map('n', '', function()
    save_note()
  end, { noremap = true, silent = true })
  popup:on('BufLeave', function()
    -- don't save
    popup:unmount()
  end)
end

function M.show()
  local wh = where()
  local file_notes = M.notes[wh.file] or {}
  local note = file_notes[tostring(wh.line)]
  if not note then
    print('no note at line')
    return
  end

  local note_lines = vim.split(note, '\n', { plain = true })

  local popup = require('line_notes.popup'):new()
  popup:mount()
  popup:on('BufLeave', function()
    local edited_lines = vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false)
    local new_note = table.concat(edited_lines, '\n')

    if note ~= new_note then
      file_notes[tostring(wh.line)] = new_note
      M.notes[wh.file] = file_notes
      M.save()
    else
      print('no changes made to the note')
    end
    popup:unmount()
  end)

  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, note_lines)
end

function M.delete()
  local wh = where()

  if vim.api.nvim_buf_is_valid(wh.bufnr) == false then
    error('invalid buffer!')
    return
  end

  if not wh.line then
    error('invalid line number!')
    return
  end

  local file_notes = M.notes[wh.file] or {}
  if not file_notes[tostring(wh.line)] then
    print('no note found on this line')
    return
  end
  local result = vim.fn.sign_unplace('LineNotesGroup', { id = wh.line, buffer = wh.bufnr })

  table.remove(M.notes, tostring(wh.line))
  if M.save() then
    print('note deleted')
  end
end

function M.load_for_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local current_file = vim.fn.expand('%:p')

  if not M.notes or type(M.notes) ~= 'table' then
    return
  end

  vim.fn.sign_unplace('LineNotesGroup', { buffer = bufnr })

  local file_notes = M.notes[current_file] or {}
  for lnum in pairs(file_notes) do
    local ret =
      vim.fn.sign_place(lnum, 'LineNotesGroup', 'LineNote', bufnr, { lnum = tonumber(lnum) })
  end
end

function M.load()
  local file = io.open(notes_file, 'r')
  if file then
    local content = file:read('*a')
    file:close()
    if not content or content == '' then
      return
    end
    local decoded = vim.fn.json_decode(content)
    if decoded then
      M.notes = decoded

      local bufnr = vim.api.nvim_get_current_buf()
      vim.fn.sign_unplace('LineNotesGroup', { buffer = bufnr })

      M.load_for_buffer()
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
    local encoded = vim.fn.json_encode(M.notes)
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
