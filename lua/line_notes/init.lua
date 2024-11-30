local M = {}

function M.setup(opts)
	opts = opts or {}
	vim.api.nvim_set_keymap("n", opts.add_mark_key or "<leader>am", ":lua require('line_notes.marks').add_mark()<CR>",
		{ noremap = true, silent = true })
	vim.api.nvim_set_keymap("n", opts.list_marks_key or "<leader>lm",
		":lua require('line_notes.telescope_picker').open_marks_picker()<CR>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("n", opts.delete_mark_key or "<leader>dm", ":lua require('line_notes.marks').delete_mark()<CR>",
		{ noremap = true, silent = true })
end

return M
