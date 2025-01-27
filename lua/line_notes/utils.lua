local M = {}
local Popup = require('nui.popup')

function M.where()
  local line = vim.fn.line('.')
  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.fn.expand('%:p')
  return { line = line, bufnr = bufnr, file = file }
end

function M.note_at_line(notes, file)
  local where = M.where()

  local idx = nil
  local original = nil
  for i, mark in ipairs(notes) do
    if mark.file == file and mark.line + 1 == where.line then
      original = mark.note
      idx = i
      break
    end
  end

  if not original then
    return
  end

  return { idx = idx, original = original }
end

function M.popup()
  local popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = 'rounded',
    },
    position = '50%',
    size = {
      width = '80%',
      height = '60%',
    },
    buf_options = {
      filetype = 'line_notes',
      buftype = 'nofile',
      modifiable = true,
      swapfile = false,
    },
  })

  popup:map('n', ':w', function()
    print('exit buf to save note')
  end, { noremap = true, silent = true })

  popup:mount()
  return popup
end

return M
