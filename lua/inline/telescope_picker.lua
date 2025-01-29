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

  local all_notes = require('inline.notes').notes
  local ns = all_notes[file] or {}
  local notes = {}
  for line, note in pairs(ns) do
    table.insert(notes, { file = file, line = line, content = note })
  end

  pickers
    .new({}, {
      prompt_title = 'Inline Notes',
      finder = finders.new_table({
        results = notes,
        entry_maker = function(note)
          local note_preview = note.content:gsub('\n', ' '):sub(1, 500)
            .. (note.content:len() > 500 and '...' or '')
          return {
            value = note,
            display = string.format(
              '%s:%s - %s',
              get_relative_path(note.file),
              note.line,
              note_preview
            ),
            ordinal = string.format('%s %s %s', note.file, note.line, note.content),
          }
        end,
      }),
      sorter = require('telescope.config').values.generic_sorter({}),
      previewer = require('telescope.previewers').new_buffer_previewer({
        define_preview = function(self, entry)
          vim.api.nvim_buf_set_lines(
            self.state.bufnr,
            0,
            -1,
            false,
            vim.split(entry.value.content, '\n', { plain = true })
          )
          vim.api.nvim_set_option_value('modifiable', false, { buf = self.state.bufnr })
        end,
      }),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          vim.cmd('edit ' .. selection.value.file)
          vim.schedule(function()
            local line_count = vim.api.nvim_buf_line_count(0)
            local target_line = selection.value.line

            if target_line == 'file' then
              require('inline').notes.show(true, true)
            elseif tonumber(target_line) <= line_count then
              vim.api.nvim_win_set_cursor(0, { tonumber(target_line), 0 })
              require('inline').notes.show()
            else
              print(
                string.format(
                  'Error: Line %s does not exist in %s',
                  target_line,
                  selection.value.file
                )
              )
            end
          end)
        end)
        return true
      end,
    })
    :find()
end

return M
