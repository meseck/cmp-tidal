local source = {}

source.is_available = function()
  return vim.bo.filetype == 'tidal'
end

source.new = function()
  local self = setmetatable({}, { __index = source })
  self.commit_items = nil
  self.insert_items = nil
  return self
end

source.complete = function(self, params, callback)
  callback({
    {label = 'January'}, {label = 'February'}, {label = 'March'}, {label = 'April'}, {label = 'May'}, {label = 'June'},
    {label = 'July'}, {label = 'August'}, {label = 'September'}, {label = 'October'}, {label = 'November'},
    {label = 'December'}
  })
end

source.option = function(_, params)
  return vim.tbl_extend('force', {
    insert = false,
  }, params.option)
end

return source

