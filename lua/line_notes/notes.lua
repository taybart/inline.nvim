local M = {}

local popup = require('line_notes.popup')

local ns_id = vim.api.nvim_create_namespace('LineNotesGroup')
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

  local p = popup:new()
  p:on_save(function()
    M.save(wh.file, wh.line, p.bufnr)
  end)

  if note then
    local note_lines = vim.split(note, '\n', { plain = true })
    vim.api.nvim_buf_set_lines(p.bufnr, 0, -1, false, note_lines)
    p:set_content(note_lines)
  end

  p:mount()

  p:map('n', '<enter>', function()
    -- save_note()
  end, { noremap = true, silent = true })
  p:on('BufLeave', function()
    -- don't save
    -- M.save()
    M.save(wh.file, wh.line, p.bufnr)
    p:unmount()
  end)
end

function M.show(enter, file)
  if enter == nil then
    enter = true
  end
  if file == nil then
    file = false
  end

  local wh = where()
  local file_notes = M.notes[wh.file] or {}
  local note = file_notes[tostring(wh.line)]
  if not note then
    note = ''
    if not file then
      print('no note at line')
      return
    end
  end
  if file then
    wh.line = 'file'
  end

  local note_lines = vim.split(note, '\n', { plain = true })

  local p = popup:new()
  p:on_save(function()
    M.save(wh.file, wh.line, p.bufnr)
  end)
  p:on('BufLeave', function()
    M.save(wh.file, wh.line, p.bufnr)
    p:unmount()
  end)

  p:mount(enter, file)

  vim.api.nvim_buf_set_lines(p.bufnr, 0, -1, false, note_lines)

  -- if its a hover win remove on navigate
  if not enter then
    vim.api.nvim_create_autocmd('CursorMoved', {
      buffer = wh.bufnr,
      once = true,
      callback = function()
        p:unmount()
      end,
    })
  end
end

function M.move()
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

  local new_line = vim.fn.input('Move ' .. wh.line .. ' to -> ')
  local note = file_notes[tostring(wh.line)]
  file_notes[tostring(wh.line)] = nil

  file_notes[new_line] = note
  M.notes[wh.file] = file_notes
  M.save_to_file()
  M.load_for_buffer()
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

  file_notes[tostring(wh.line)] = nil
  M.notes[wh.file] = file_notes
  M.save_to_file()
  M.load_for_buffer()
end

function M.load_for_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local current_file = vim.fn.expand('%:p')

  if not M.notes or type(M.notes) ~= 'table' then
    return
  end

  local config = require('line_notes.config').config

  M.clear_marks(bufnr)

  local file_notes = M.notes[current_file] or {}
  for lnum in pairs(file_notes) do
    if lnum == 'file' then
      goto continue
    end
    local lnum = tonumber(lnum)
    if not lnum then
      print('invalid line number')
      return
    end
    if config.signcolumn.enabled then
      vim.fn.sign_place(0, 'LineNotesGroup', 'LineNote', bufnr, { lnum = tonumber(lnum) })
    end
    if config.virtual_text.enabled then
      vim.api.nvim_buf_set_extmark(
        bufnr,
        ns_id,
        lnum - 1, -- 0 indexed
        0,
        { virt_text = { { config.virtual_text.icon, config.virtual_text.highlight } } }
      )
    end
    ::continue::
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
      M.clear_marks(bufnr)
    else
      error('failed to decode notes')
    end
  else
    print('no saved notes found')
  end
end

function M.save(filename, line, bufnr)
  local file_notes = M.notes[filename] or {}
  local note = file_notes[tostring(line)]

  local edited_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local new_note = table.concat(edited_lines, '\n')

  if note == new_note then
    print('no changes made to the note')
    return
  end

  file_notes[tostring(line)] = new_note
  M.notes[filename] = file_notes
  M.save_to_file()
end

function M.save_to_file()
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

function M.clear_marks(bufnr)
  vim.fn.sign_unplace('LineNotesGroup', { buffer = bufnr })
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
end

return M
