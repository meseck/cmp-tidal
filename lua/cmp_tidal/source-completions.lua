local utils = require("cmp_tidal.utils")
local cmp = require("cmp")
local Job = require("plenary.job")

local source = {}

source.is_available = function()
	return vim.bo.filetype == "tidal"
end

source.new = function()
	return setmetatable({}, { __index = source })
end

source.complete = function(_, params, callback)
	local input = string.sub(params.context.cursor_before_line, params.offset)

	Job
		:new({
			command = "hoogle",
			args = { "+tidal", input },

			on_exit = function(job)
				local job_output = job:result()

				local completion_items = {}
				for _, element in ipairs(job_output) do
					local completion_table = utils.split_string(element)
					local label = completion_table[2]

					local item = { label = label, kind = cmp.lsp.CompletionItemKind.Function }
					table.insert(completion_items, item)

					callback({ items = completion_items, isIncomplete = true })
				end
			end,
		})
		:start()
end

-- Search for documentation when item is selected
source.resolve = function(_, completion_item, callback)
	Job
		:new({
			command = "hoogle",
			args = { "-i", "+tidal", completion_item.label },

			on_exit = function(job)
				local documenation_table = job:result()
				local description_table = {}

				local type = documenation_table[1]
				local module = documenation_table[2]

				-- Get description from documentation_table
				for i = 3, table.maxn(documenation_table), 1 do
					table.insert(description_table, documenation_table[i])
				end

				-- Convert description_table to string
				local description_string = table.concat(description_table, "\n")

				if documenation_table ~= nil then
					completion_item.documentation = {
						kind = "markdown",
						value = string.format("**Type:** %s\n**Module:** %s\n\n%s", type, module, description_string),
					}
					callback(completion_item)
				end
			end,
		})
		:start()
end

return source
