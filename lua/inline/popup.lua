local M = {}

function M:new()
  self.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value('filetype', 'inline_notes', { buf = self.bufnr })
  vim.api.nvim_set_option_value('buftype', 'acwrite', { buf = self.bufnr })
  vim.api.nvim_set_option_value('modifiable', true, { buf = self.bufnr })
  vim.api.nvim_set_option_value('swapfile', false, { buf = self.bufnr })

  return self
end

function M:mount(enter, split)
  if enter == nil then
    enter = true
  end
  local win_opts = vim.tbl_deep_extend('force', {
    relative = 'cursor',
    width = 50,
    height = 10,
    row = 0,
    col = 0,
    style = 'minimal',
    border = 'rounded',
    title = 'Note',
  }, require('inline.config').config.popup)
  if split then
    win_opts = {
      split = 'right',
      win = 0,
    }
  end
  self.win = vim.api.nvim_open_win(self.bufnr, enter, win_opts)
end

function M:unmount()
  if vim.api.nvim_win_is_valid(self.win) then
    vim.api.nvim_win_close(self.win, true)
  end
  if vim.api.nvim_buf_is_valid(self.bufnr) then
    vim.api.nvim_buf_delete(self.bufnr, { force = true })
  end
end

function M:set_content(content)
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, content)
end

function M:on(event, callback)
  vim.api.nvim_create_autocmd(event, {
    buffer = self.bufnr,
    once = true,
    callback = callback,
  })
end

function M:on_save(callback)
  vim.api.nvim_buf_set_name(self.bufnr, 'inline_notes')
  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = self.bufnr,
    callback = function()
      callback()
      vim.bo.modified = false
      return true
    end,
  })
end

function M:map(mode, key, action, opts)
  vim.keymap.set(
    mode,
    key,
    action,
    vim.tbl_deep_extend('keep', { buffer = self.bufnr }, opts or {})
  )
end

function M:command(command, callback, opts)
  local opts = opts or {}
  vim.api.nvim_buf_create_user_command(self.bufnr, command, callback, opts)
end

return M
