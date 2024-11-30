local M = {}

local ns_id = vim.api.nvim_create_namespace("line_notes")
local marks = {}

function M.add_mark()
	local line = vim.fn.line('.') - 1
	local note = vim.fn.input("Add a note: ")

	table.insert(marks, { line = line, note = note, file = vim.fn.expand("%") })

	vim.api.nvim_buf_set_extmark(0, ns_id, line, 0, {
		virt_text = { { "*" .. note, "Comment" } },
		virt_text_pos = "eol"
	})
end


function M.load_marks()
-- loading of maarks to come
end

function M.delete_marks()
	-- deletion of marks 
end

return M


