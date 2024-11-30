local M = {}

function M.setup(opts)
	opts = opts or {}
	vim.api.nvim_set_keymap("n", "<leader>am", ":lua require('line_notes.marks').add_mark()<CR>",
		{ noremap = true, silent = true })
	vim.api.nvim_set_keymap("n", "<leader>lm", ":lua require('line_notes.telescope_picker').open_marks_picker()<CR>",
		{ noremap = true, silent = true })
	vim.api.nvim_set_keymap("n", "<leader>dm", ":lua require('line_notes.marks').delete_mark()<CR>",
		{ noremap = true, silent = true })
end

return M
