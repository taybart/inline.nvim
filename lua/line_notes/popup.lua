local M = {}

function M:new()
  self.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value('filetype', 'line_notes', { buf = self.bufnr })
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = self.bufnr })
  vim.api.nvim_set_option_value('modifiable', true, { buf = self.bufnr })
  vim.api.nvim_set_option_value('swapfile', false, { buf = self.bufnr })
  return self
end

function M:mount()
  self.win = vim.api.nvim_open_win(self.bufnr, true, {
    relative = 'editor',
    width = 50,
    height = 10,
    row = math.floor((vim.o.lines - 10) / 2),
    col = math.floor((vim.o.columns - 50) / 2),
    style = 'minimal',
    border = 'rounded',
  })
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

function M:map(mode, key, action, opts)
  vim.keymap.set(
    mode,
    key,
    action,
    vim.tbl_deep_extend('keep', { buffer = self.bufnr }, opts or {})
  )
end

return M
