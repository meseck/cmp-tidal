local source = {}

---Return this source is available in current context or not. (Optional)
---@return boolean
function source:is_available()
  return vim.bo.filetype == 'tidal'
end

---Return the debug name of this source. (Optional)
---@return string
function source:get_debug_name()
  return 'debug name'
end

---Invoke completion. (Required)
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
  callback({
    {label = 'January'}, {label = 'February'}, {label = 'March'}, {label = 'April'}, {label = 'May'}, {label = 'June'},
    {label = 'July'}, {label = 'August'}, {label = 'September'}, {label = 'October'}, {label = 'November'},
    {label = 'December'}
  })
end

---Resolve completion item. (Optional)
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback)
  callback(completion_item)
end

---Executecommand after item was accepted.
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:execute(completion_item, callback)
  callback(completion_item)
end

return source

