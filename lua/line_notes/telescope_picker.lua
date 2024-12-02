local M = {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local notes_file = vim.fn.stdpath("data") .. "/line_notes.json"
local notes = {}

local function load_notes_from_file()
  local file = io.open(notes_file, "r")
  if not file then return {} end

  local content = file:read("*a")
  file:close()

  local decoded = vim.fn.json_decode(content)
  return decoded or {}
end

local function get_relative_path(filepath)
  local cwd = vim.fn.getcwd()
  if filepath:sub(1, #cwd) == cwd then
    return filepath:sub(#cwd + 2)
  end
  return filepath
end

function M.open_notes_picker()
  notes = load_notes_from_file()

  pickers.new({}, {
    prompt_title = "Line Notes",
    finder = finders.new_table({
      results = notes,
      entry_maker = function(mark)
        local note_preview = mark.note:gsub("\n", " "):sub(1, 500) .. (mark.note:len() > 500 and "..." or "")
        return {
          value = mark,
          display = string.format("%s:%d - %s", get_relative_path(mark.file), mark.line + 1, note_preview),
          ordinal = string.format("%s %d %s", mark.file, mark.line + 1, mark.note),
        }
      end,
    }),
    sorter = require("telescope.config").values.generic_sorter({}),
    previewer = require("telescope.previewers").new_buffer_previewer({
      define_preview = function(self, entry)
        local note_content = entry.value.note
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(note_content, "\n", { plain = true }))
        vim.api.nvim_buf_set_option(self.state.bufnr, "modifiable", false)
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        vim.cmd("edit " .. selection.value.file)
        vim.schedule(function()
          local line_count = vim.api.nvim_buf_line_count(0)
          local target_line = selection.value.line + 1

          if target_line > line_count then
            print(string.format("Error: Line %d does not exist in %s", target_line, selection.value.file))
          else
            vim.api.nvim_win_set_cursor(0, { target_line, 0 })
          end
        end)
      end)
      return true
    end,
  }):find()
end

return M

