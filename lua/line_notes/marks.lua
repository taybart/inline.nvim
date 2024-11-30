local M = {}
local ns_id = vim.api.nvim_create_namespace("line_notes")
local marks = {}

function M.add_mark()
  local line = vim.fn.line('.') - 1
  local note = vim.fn.input("Add a note: ")

  table.insert(marks, { line = line, note = note, file = vim.fn.expand("%") })

  vim.api.nvim_buf_set_extmark(0, ns_id, line, 0, {
    virt_text = { { "⭑ " .. note, "Comment" } },
    virt_text_pos = "eol"
  })
end

function M.delete_mark()
  local line = vim.fn.line('.') - j
  for i, mark in ipairs(marks) do
    if mark.file == vim.fn.expand("%") and mark.line == line then
      table.remove(marks, i)
      vim.api.nvim_buf_clear_namespace(0, ns_id, line, line + 1)
      print("Mark deleted")
      return
    end
  end
  print("No mark found on this line")
end

return M
