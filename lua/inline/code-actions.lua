local M = {}

local function has_note()
  return require("inline.notes").has()
end
local function no_note()
  return not require("inline.notes").has()
end

function M.register_code_actions()
  local has_code_actions = pcall(require, "code-actions")
  if not has_code_actions then
    return
  end
  require("code-actions").add_server({
    name = "inline.nvim",
    -- stylua: ignore
    actions = {
      {
        command = 'Add Note',
        show = no_note,
        fn = function() require('inline.notes').add() end,
      },
      {
        command = 'Edit Note',
        show = has_note,
        fn = function()
          -- require('inline.notes').show(false)
          require('inline.notes').show()
        end,
      },
      {
        command = 'View Note',
        show = has_note,
        fn = function()
          -- require('inline.notes').show(false)
          require('inline.notes').show({ focus = false })
        end,
      },
      {
        command = 'Delete Note',
        show = has_note,
        -- TODO: add confirmation
        fn = function() require('inline.notes').delete() end,
      },
    },
  })
end

return M
