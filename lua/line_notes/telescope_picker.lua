local M = {}
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local function get_relative_path(filepath)
  local cwd = vim.fn.getcwd()
  if filepath:sub(1, #cwd) == cwd then
    return filepath:sub(#cwd + 2)
  end
  return filepath
end

function M.open_notes_picker()
  local file = vim.fn.expand('%:p')

  local all_notes = require('line_notes.notes').notes
  local ns = all_notes[file] or {}
  local notes = {}
  for line, note in pairs(ns) do
    table.insert(notes, { file = file, line = tonumber(line), note = note })
  end

  pickers
    .new({}, {
      prompt_title = 'Line Notes',
      finder = finders.new_table({
        results = notes,
        entry_maker = function(note)
          local note_preview = note.note:gsub('\n', ' '):sub(1, 500)
            .. (note.note:len() > 500 and '...' or '')
          return {
            value = note,
            display = string.format(
              '%s:%d - %s',
              get_relative_path(note.file),
              note.line,
              note_preview
            ),
            ordinal = string.format('%s %d %s', note.file, note.line, note.note),
          }
        end,
      }),
      sorter = require('telescope.config').values.generic_sorter({}),
      previewer = require('telescope.previewers').new_buffer_previewer({
        define_preview = function(self, entry)
          local note_content = entry.value.note
          vim.api.nvim_buf_set_lines(
            self.state.bufnr,
            0,
            -1,
            false,
            vim.split(note_content, '\n', { plain = true })
          )
          vim.api.nvim_buf_set_option(self.state.bufnr, 'modifiable', false)
        end,
      }),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          vim.cmd('edit ' .. selection.value.file)
          vim.schedule(function()
            local line_count = vim.api.nvim_buf_line_count(0)
            local target_line = selection.value.line

            if target_line > line_count then
              print(
                string.format(
                  'Error: Line %d does not exist in %s',
                  target_line,
                  selection.value.file
                )
              )
            else
              vim.api.nvim_win_set_cursor(0, { target_line, 0 })
              require('line_notes').notes.show()
            end
          end)
        end)
        return true
      end,
    })
    :find()
end

return M
