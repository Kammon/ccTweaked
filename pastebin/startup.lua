--[[
	
	
	Basic ccTweaked Computer Startup Script

	Startup (a static file hosted on Pastebin) does the following:
		-downloads a file from a given path as "bootstrap"
		-runs that file
	
	To-Do:
		-bootstrap will:
			-download repo paths file (github)
			-run download code on repo paths
			-erase basic pastebin startup (in favor of more robust startup dir from repo)
			-erase repo paths file
			-erase bootstrap


--]]


bootstrapPath="https://raw.githubusercontent.com/Kammon/ccTweaked/main/bootstrap/bootstrap.lua"

local resp = http.get(bootstrapPath)
if resp and resp.getResponseCode() == 200 and tonumber(resp.getResponseHeaders()["content-length"]) > 0 then
	local file = fs.open("bootstrap","w")
	local line = resp.readLine(true)
	while line ~= nil do
		file.write(line)
		line=resp.readLine(true)
	end
	file.close()
end
resp.close()

shell.run("bootstrap")
