local M = {
  ns_id = vim.api.nvim_create_namespace("InlineNotesGroup"),
}
local popup = require("inline.popup")
local db = require("inline.db").new()

local function where()
  local line = vim.fn.line(".")
  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.fn.expand("%:p")
  return { line = line, bufnr = bufnr, file = file }
end

function M.has()
  local wh = where()
  local note = db:get(wh.file, wh.line) or {}
  return note.content ~= nil
end

function M.add()
  M.edit()
end

function M.edit()
  local wh = where()
  local note = db:get(wh.file, wh.line)
  local p = popup:new()
  p:on_save(function()
    local edited_lines = vim.api.nvim_buf_get_lines(p.bufnr, 0, -1, false)
    db:upsert({
      file = wh.file,
      row = wh.line,
      content = table.concat(edited_lines, "\n"),
    })
  end)

  if note then
    local note_lines = vim.split(note.content, "\n", { plain = true })
    vim.api.nvim_buf_set_lines(p.bufnr, 0, -1, false, note_lines)
    p:set_content(note_lines)
  end

  p:mount()

  p:map("n", "<enter>", function()
    -- save_note()
  end, { noremap = true, silent = true })
  p:on("BufLeave", function()
    -- don't save
    -- M.save()
    -- M.save(wh.file, wh.line, p.bufnr)
    p:unmount()
  end)
end

function M.show(opts)
  opts = opts or { focus = true, file = false }
  if opts.focus == nil then
    opts.focus = true
  end
  if opts.file == nil then
    opts.file = false
  end

  local wh = where()

  local note = db:get(wh.file, wh.line)
  if not note then
    print("no note at line")
    return
  end

  -- TODO: refact into "edit" function since this is a repeat of add
  local p = popup:new()
  p:on_save(function()
    local edited_lines = vim.api.nvim_buf_get_lines(p.bufnr, 0, -1, false)
    db:upsert({
      file = wh.file,
      row = wh.line,
      content = table.concat(edited_lines, "\n"),
    })
  end)
  p:on("BufLeave", function()
    -- M.save(wh.file, wh.line, p.bufnr)
    p:unmount()
  end)

  p:mount(opts.focus, opts.file)

  local note_lines = vim.split(note.content, "\n", { plain = true })
  vim.api.nvim_buf_set_lines(p.bufnr, 0, -1, false, note_lines)

  -- if its a hover win remove on navigate
  if not opts.focus then
    vim.api.nvim_create_autocmd("CursorMoved", {
      buffer = wh.bufnr,
      once = true,
      callback = function()
        p:unmount()
      end,
    })
  end
end

function M.delete()
  local wh = where()

  if not vim.api.nvim_buf_is_valid(wh.bufnr) then
    error("invalid buffer!")
    return
  end

  db:del(wh.file, wh.line)

  M.set_extmarks()
end

function M.clear_extmarks()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.fn.sign_unplace("InlineNotesGroup", { buffer = bufnr })
  vim.api.nvim_buf_clear_namespace(bufnr, M.ns_id, 0, -1)
end

function M.set_extmarks()
  local bufnr = vim.api.nvim_get_current_buf()
  local config = require("inline").config

  local notes = db:get_file(vim.api.nvim_buf_get_name(bufnr)) or {}

  M.clear_extmarks()
  for _, note in ipairs(notes) do
    if config.signcolumn.enabled then
      vim.fn.sign_place(0, "InlineNotesGroup", "InlineNote", bufnr, { lnum = note.row })
    end
    if config.virtual_text.enabled then
      -- stylua: ignore
      vim.api.nvim_buf_set_extmark(bufnr, M.ns_id, note.row - 1, 0,
        {
          virt_text = {
            {
              config.virtual_text.icon,
              config.virtual_text.highlight,
            },
          }
        })
    end
  end
end

return M
