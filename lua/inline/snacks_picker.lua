local M = {}

function M.pick_notes()
  local has_snacks = pcall(require, "snacks")
  if not has_snacks then
    return
  end

  local db = require("inline.db").new()

  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file == "" then
    vim.notify("No file open", vim.log.levels.WARN)
    return
  end

  local notes = db:get_file(current_file)
  if not notes or #notes == 0 then
    vim.notify("No notes found for this file", vim.log.levels.INFO)
    return
  end

  local items = {}
  for i, note in ipairs(notes) do
    table.insert(items, {
      idx = i,
      text = string.format("[%d]: %s", note.row, note.content),
      note = note,
    })
  end

  require("snacks").picker.pick({
    items = items,
    prompt = "Select a note:",
    format = "text",
    confirm = function(picker, item)
      picker:close()
      if item then
        -- Jump to the note's line
        vim.api.nvim_win_set_cursor(0, { item.note.row, 0 })
        -- Optionally show the note content in a floating window
        vim.notify(item.note.content, vim.log.levels.INFO)
      end
    end,
  })
end

return M
