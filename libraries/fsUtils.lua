local fsUtils = {}

function fsUtils.getContents(path)
	local contents = {}
	local handle = fs.open(path,"r")
	if handle then
		local line = handle.readLine()
		while line ~= nil do
			contents[#contents + 1] = line
			line = handle.readLine()
		end
		handle.close()
	else
		if path then print("Error opening ", path) else print("Error: No file given") end
	end
	return contents
end

return fsUtils
