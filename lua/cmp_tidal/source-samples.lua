local utils = require("cmp_tidal.utils")
local cmp = require("cmp")
local scan = require("plenary.scandir")

local source = {}
local added_folders = {}  -- Table to keep track of added folders (custom_samples produced duplicates for some reason)

local default_option = {
    dirt_samples = utils.get_dirt_samples_path(),
    custom_samples = {},
}

source.is_available = function()
	return vim.bo.filetype == "tidal"
end

source.new = function()
	return setmetatable({}, { __index = source })
end

source._validate_options = function(_, params)
    local opts = vim.tbl_deep_extend("keep", params.option, default_option)

    -- Ensure dirt_samples is an array or convert it to an array
    if type(opts.dirt_samples) == "string" then
        opts.dirt_samples = { opts.dirt_samples }
    elseif type(opts.dirt_samples) ~= "table" then
        opts.dirt_samples = {}
    end

    -- Ensure custom_samples is an array or convert it to an array
    if type(opts.custom_samples) == "string" then
        opts.custom_samples = { opts.custom_samples }
    elseif type(opts.custom_samples) ~= "table" then
        opts.custom_samples = {}
    end

    -- Validate each path in the arrays
    for _, path in ipairs(vim.list_extend(opts.dirt_samples, opts.custom_samples)) do
        vim.validate({ samples = { path, "string" } })
    end

    return opts
end

source.complete = function(self, params, callback)
    local opts = self:_validate_options(params)
    local dirt_samples = opts.dirt_samples
    local custom_samples = opts.custom_samples

    local folder_table = {}

    local function completePath(index, paths)
        if index <= #paths then
            local current_path = paths[index]
            if not added_folders[current_path] then
                added_folders[current_path] = true

                scan.scan_dir_async(current_path, {
                    depth = 1,
                    only_dirs = true,
                    on_exit = function(folders)
                        for _, folder in ipairs(folders) do
                            local folder_name = folder:match("^.+/(.+)$")
                            local folder_item = { label = folder_name, kind = cmp.lsp.CompletionItemKind.Folder, path = folder }
                            table.insert(folder_table, folder_item)
                        end

                        completePath(index + 1, paths)
                    end,
                })
            else
                completePath(index + 1, paths)
            end
        else
            callback({ items = folder_table, isIncomplete = true })
        end
    end

    completePath(1, vim.list_extend(dirt_samples, custom_samples))
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
