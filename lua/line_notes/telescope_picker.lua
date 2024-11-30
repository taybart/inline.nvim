local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

function M.open_marks_picker()
	pickers.new({}, {
		prompt_title = "Line Notes",
		finder = finders.new_table({
			results = marks,
			entry_maker = function(mark)
				return {
					value = mark,
					display = string.format("%s:%d - %s", mark.file, mark.line + 1, mark.note),
					ordinal = mark.note
				}
			end,
		}),

		sorter = require('telescope.config').values.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				vim.cmd("edit " .. selection.value.file)
				vim.api.nvim_win_set_cursor(0, { selection.value.line + 1, 0 })
			end
			)
			return true
		end,
	}):find()
end

return M
