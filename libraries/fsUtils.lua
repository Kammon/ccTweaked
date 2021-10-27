local fsUtils = {}

function fsUtils.getContents(path)
	local contents = {}
	local handle = fs.open(path,"r")
	if handle then
		local line = handle.readLine()
		while line ~= nil do
			if not string.find(line, "^$") and not (string.find(line, "^#") or string.find(line,"^%-%-")) then
				contents[#contents + 1] = line
			end
			line = handle.readLine()
		end
		handle.close()
	else
		if path then print("Error opening ", path) else print("Error: No file given") end
	end
	return contents
end

function fsUtils.writeToFile(path, data)
	local handle = fs.open(path, "w");
	for k, v in pairs(data) do
		-- Should add consideration for nested tables, but not necessary for right now. ie if type(v) == table then...
		handle.writeLine(k.."="..v);
	end
	handle.close()
end

return fsUtils
