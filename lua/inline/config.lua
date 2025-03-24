local M = {}

-- Default configuration
M.defaults = {
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
  telescope_available = false,
}

-- Store the user's configuration
M.config = {}

-- Initialize configuration with user options
function M.setup(opts)
  -- Merge user options with defaults
  M.config = vim.tbl_deep_extend('force', M.defaults, opts or {})

  M.config.telescope_available = package.loaded['telescope']

  -- Validate configuration
  M.validate()

  return M.config
end

-- Get current configuration
function M.get()
  return M.config
end

-- Validate configuration values
function M.validate()
  if M.config.keymaps.enabled then
    -- Add any validation logic here if needed
    if type(M.config.keymaps) ~= 'table' then
      error('keymaps configuration must be a table')
    end

    -- Ensure all required keymap fields exist
    local required_keymaps = { 'add_note', 'list_notes', 'delete_note', 'show_note' }
    for _, keymap in ipairs(required_keymaps) do
      if not M.config.keymaps[keymap] then
        M.config.keymaps[keymap] = M.defaults.keymaps[keymap]
      end
    end
  end
end

return M
