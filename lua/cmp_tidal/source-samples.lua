local utils = require("cmp_tidal.utils")
local cmp = require("cmp")
local scan = require("plenary.scandir")

local source = {}

local default_option = { dirt_samples = utils.get_dirt_samples_path() }

source.is_available = function()
	return vim.bo.filetype == "tidal"
end

source.new = function()
	return setmetatable({}, { __index = source })
end

source._validate_options = function(_, params)
	local opts = vim.tbl_deep_extend("keep", params.option, default_option)
	vim.validate({ dirt_samples = { opts.dirt_samples, "string" } })
	return opts
end

source.complete = function(self, params, callback)
	local opts = self:_validate_options(params)
	local dirt_samples = opts.dirt_samples

	scan.scan_dir_async(dirt_samples, {
		depth = 1,
		only_dirs = true,
		on_exit = function(folders)
			-- Folders
			local folder_table = {}
			for _, folder in ipairs(folders) do
				local folder_name = folder:match("^.+/(.+)$")
				local folder_item = { label = folder_name, kind = cmp.lsp.CompletionItemKind.Folder, path = folder }
				table.insert(folder_table, folder_item)
			end

			callback({ items = folder_table, isIncomplete = true })
		end,
	})
end

-- List files of selected folder in documentation
source.resolve = function(_, completion_item, callback)
	scan.scan_dir_async(completion_item.path, {
		depth = 1,
		search_pattern = { "%.wav$", "%.WAV$", "%.flac$", "%.FLAC$", "%.aiff$", "%.AIFF$" },
		on_exit = function(files)
			local files_table = {}
			for index, file in ipairs(files) do
				local file_name = file:match("^.+/(.+)$")
				table.insert(files_table, string.format("**:%s ::** %s", index, file_name))
			end

			-- Add documentation
			local file_count = table.maxn(files_table)
			local documentation_string = table.concat(files_table, "\n")
			completion_item.documentation = {
				kind = "markdown",
				value = string.format("**Samples**: %s\n\n%s", file_count, documentation_string),
			}

			callback(completion_item)
		end,
	})
end

return source
