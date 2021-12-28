local cmp = require('cmp')
local Job = require 'plenary.job'

local source = {}

local split_string = function(input_string)
  local t = {}
  for str in string.gmatch(input_string, '([^' .. '%s' .. ']+)') do table.insert(t, str) end
  return t
end

source.is_available = function()
  return vim.bo.filetype == 'tidal'
end

source.new = function()
	return setmetatable({}, { __index = source })
end

source.complete = function(_, params, callback)
  local input = string.sub(params.context.cursor_before_line, params.offset)

  Job:new({
    command = 'hoogle',
    args = {'+tidal', input},

    on_exit = function(job)
      local completions_table = job:result()

      local items = {}
      for _, completion in ipairs(completions_table) do
        local completion_table = split_string(completion)
        local label = completion_table[2]

        local item = {label = label, kind = cmp.lsp.CompletionItemKind.Function}
        table.insert(items, item)
      end

      callback {items = items, isIncomplete = true}
    end
  }):start()
end

-- Search for documentation when item is selected
source.resolve = function(_, completion_item, callback)
  Job:new({
    command = 'hoogle',
    args = {'-i', '+tidal', completion_item.label},

    on_exit = function(job)
      local documenation_table = job:result()
      local description_table = {}

      local type = documenation_table[1]
      local module = documenation_table[2]

      -- Get description from documenation_table
      for i = 3, table.maxn(documenation_table), 1 do table.insert(description_table, documenation_table[i]) end

      -- Convert description_table to string
      local description_string = table.concat(description_table, '\n')

      if documenation_table ~= nil then
        completion_item.documentation = {
          kind = 'markdown',
          value = string.format('**Type:** %s\n**Module:** %s\n\n%s', type, module, description_string)
        }
      end

      callback(completion_item)
    end
  }):start()
end

source.option = function(_, params)
  return vim.tbl_extend('force', {insert = false}, params.option)
end

return source

