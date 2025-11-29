---@class NotesTable
---@field insert fun(self: NotesTable, data: table)
---@field update fun(self: NotesTable, opts: table)
---@field delete fun(self: NotesTable, where: table)
---@field get fun(self: NotesTable, where: table): table[]

---@class SqliteConnection
---@field notes NotesTable
---@field execute fun(self: SqliteConnection, sql: string): any

---@class InlineNotesDB
---@field conn SqliteConnection|nil
local db = {
  conn = nil,
}
db.__index = db

local sqlite = require("sqlite")

---@return InlineNotesDB
function db.new()
  local conn = sqlite({
    uri = vim.fn.stdpath("data") .. "/inline_notes.db",
    notes = {
      file = "text",
      row = "integer",
      content = "text",
      created_at = { "timestamp", default = sqlite.lib.strftime("%s", "now") },
    },
  })
  conn:open()

  -- Create composite primary key using raw SQL after table is created
  conn:execute([[
    CREATE UNIQUE INDEX IF NOT EXISTS
      notes_file_row_idx ON notes(file, row)
  ]])
  local _db = {
    conn = conn,
  }
  setmetatable(_db, db)

  return _db
end

---@param note table
function db:add(note)
  self.conn.notes:insert({ file = note.file, row = note.row, content = note.content })
end

---@param note table
function db:upsert(note)
  local existing = self.conn.notes:get({ where = { file = note.file, row = note.row } })
  if existing then
    self.conn.notes:update({
      where = { file = note.file, row = note.row },
      set = { content = note.content },
    })
  else
    self:add(note)
  end
end

---@param note table
function db:del(file, row)
  self.conn.notes:remove({ file = file, row = row })
end

---@param file string
---@param row integer
---@return table
function db:get(file, row)
  return self.conn.notes:get({ where = { file = file, row = row } })[1]
end

---@param file string
---@return table
function db:get_file(file)
  return self.conn.notes:get({ where = { file = file } })
end

return db
