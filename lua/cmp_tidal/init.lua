local open = io.open

local source = {}

local function read_file(path)
    local file = open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

local get_absolute_path = function()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match('(.*/)')
end

source.is_available = function()
  return vim.bo.filetype == 'tidal'
end

source.new = function()
  local self = setmetatable({}, {__index = source})
  self.commit_items = nil
  self.insert_items = nil
  return self
end

source.complete = function(_, _, callback)
  local working_directory = get_absolute_path()
  local file_name = 'tidal.json'
  local path = string.format('%s%s', working_directory, file_name)

  local ok, data = pcall(read_file, path)
  if not ok then
    print(path)
    vim.notify 'Failed to read json file'
    return
  end

  local ok, parsed = pcall(vim.json.decode, data)
  if not ok then
    vim.notify 'Failed to parse json file'
    return
  end

  local items = {}
  for _, item in ipairs(parsed) do
    -- item.body = string.gsub(item.body or '', '\r', '')

    table.insert(items, {
      label = string.format('%s', item.name),
      -- documentation = {kind = 'html', value = string.format('%s\n\n%s', item.display_html, item.module)}
    })
  end

  callback {items = items, isIncomplete = true}
end

source.option = function(_, params)
  return vim.tbl_extend('force', {insert = false}, params.option)
end

return source

