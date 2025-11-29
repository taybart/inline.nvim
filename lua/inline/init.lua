local M = {
  config = {},
  -- export notes module
  notes = require("inline.notes"),
}

local notes = require("inline.notes")
local snacks_picker = require("inline.snacks_picker")
local utils = require("inline.utils")

local function autocmds()
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    callback = function(ev)
      local ft = vim.api.nvim_get_option_value("filetype", { buf = ev.buf })
      -- TODO: do we need this?
      local exclude = {}
      if vim.tbl_contains(exclude, ft) then
        return
      end
      notes.set_extmarks()
    end,
  })
  -- easy escape from float
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "inline_notes",
    callback = function()
      vim.bo.filetype = "markdown"
      vim.keymap.set("n", "q", "<cmd>close!<CR>", { buffer = true, silent = true })
      vim.keymap.set("n", "<esc>", "<cmd>close!<CR>", { buffer = true, silent = true })
    end,
  })
end

local function user_command()
  utils.create_user_command("Inline", {
    default = function()
      notes.show({ focus = false })
    end,
    show = function()
      notes.show({ focus = false })
    end,
    edit = function()
      notes.edit()
    end,
    add = function()
      notes.add()
    end,
    move = function()
      notes.move()
    end,
    delete = function()
      notes.delete()
    end,
    search = function()
      snacks_picker.pick_notes()
    end,
  })
end

-- Define signs based on configuration
local function signs()
  local sign_config = M.config.signcolumn
  vim.fn.sign_define("InlineNote", {
    text = sign_config.icon,
    texthl = sign_config.highlight,
    numhl = sign_config.number_highlight,
  })
end

local function keymaps()
  if not M.config.keymaps.enabled then
    return
  end

  local function map(key, cmd)
    vim.keymap.set("n", key, cmd, { noremap = true, silent = true })
  end

  local km = M.config.keymaps

  map(km.add_note, notes.add_note)
  map(km.delete_note, notes.delete_note)
  map(km.show_note, notes.show_note)
  -- map(km.list_notes, telescope_picker.open_notes_picker)
  map(km.list_notes, snacks_picker.pick_notes)
end

function M.setup(opts)
  -- Initialize configuration
  M.config = require("inline.config").new(opts)

  -- keymaps()
  user_command()
  autocmds()
  signs()
  require("inline.code-actions").register_code_actions()
  vim.treesitter.language.register("markdown", "inline_notes")
end

return M
