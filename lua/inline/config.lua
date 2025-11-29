local M = {}

-- Default configuration
M.defaults = {
  signcolumn = {
    enabled = true,
    icon = ">",
    highlight = "Comment",
    number_highlight = "",
  },
  virtual_text = {
    enabled = false,
    icon = "!",
    highlight = "Comment",
  },
  -- redo with snacks
  popup = {
    relative = "cursor",
    width = 50,
    height = 10,
    row = 1,
    col = 1,
    style = "minimal",
    border = "rounded",
  },
  telescope_available = false,
}

-- Initialize configuration with user options
function M.new(opts)
  -- Merge user options with defaults
  local config = vim.tbl_deep_extend("force", M.defaults, opts or {})

  config.telescope_available = package.loaded["telescope"]

  -- Validate configuration
  M.validate(config)

  return config
end

-- Validate configuration values
function M.validate(config)
  -- if config.keymaps.enabled then
  --   -- Add any validation logic here if needed
  --   if type(config.keymaps) ~= "table" then
  --     error("keymaps configuration must be a table")
  --   end
  --
  --   -- Ensure all required keymap fields exist
  --   local required_keymaps = { "add_note", "list_notes", "delete_note", "show_note" }
  --   for _, keymap in ipairs(required_keymaps) do
  --     if not config.keymaps[keymap] then
  --       config.keymaps[keymap] = M.defaults.keymaps[keymap]
  --     end
  --   end
  -- end
end

return M
