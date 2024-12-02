local M = {}

function M.setup(opts)
  opts = opts or {}

  require("line_notes.notes").load_notes()

  vim.api.nvim_set_keymap("n", opts.add_note_key or "<leader>an", ":lua require('line_notes.notes').add_note()<CR>",
    { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", opts.list_notes_key or "<leader>ln",
    ":lua require('line_notes.telescope_picker').open_notes_picker()<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", opts.delete_note_key or "<leader>dn",
    ":lua require('line_notes.notes').delete_note()<CR>",
    { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", opts.delete_note_key or "<leader>sn",
    ":lua require('line_notes.notes').show_note()<CR>",
    { noremap = true, silent = true })
end

return M
