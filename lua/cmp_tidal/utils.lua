local utils = {}

utils.split_string = function(string)
	local t = {}
	for str in string.gmatch(string, "([^" .. "%s" .. "]+)") do
		table.insert(t, str)
	end
	return t
end

utils.get_os = function()
	if vim.fn.has("win64") == 1 or vim.fn.has("win32") == 1 or vim.fn.has("win16") == 1 then
		return "Windows"
	else
		return vim.fn.substitute(vim.fn.system("uname"), "\n", "", "")
	end
end

utils.get_dirt_samples_path = function()
	local os = utils.get_os()
	local os_paths = {
		["Darwin"] = "/Library/Application Support/SuperCollider",
		["Linux"] = "/.local/share/SuperCollider",
		["Windows"] = "/AppData/Local/SuperCollider",
	}
	return vim.env.HOME .. os_paths[os] .. "/downloaded-quarks/Dirt-Samples"
end

return utils
