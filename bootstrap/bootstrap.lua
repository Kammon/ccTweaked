-- shell.run("rm startup/")
thisP = shell.getRunningProgram()

tbPath="repos/Kammon/ccTweaked"
rbPath="https://raw.githubusercontent.com/Kammon/ccTweaked/main"
pathsPath="https://raw.githubusercontent.com/Kammon/ccTweaked/main/bootstrap/fileList.txt"
filename="toDownload"
paths={}

--download Paths for files
local resp = http.get(pathsPath)
if resp.getResponseCode() == 200 and tonumber(resp.getResponseHeaders()["content-length"]) > 0 then
	local file = fs.open(filename,"w")
	local line = resp.readLine(true)
	while line ~= nil do
		file.write(line)
		line=resp.readLine(true)
	end
	file.close()
end
resp.close()

assert(fs.exists(filename))
input=fs.open(filename,"r")
line=input.readLine()
while line ~= nil do
	paths[#paths+1]=line
	-- join({line},paths)
	line=input.readLine()
end
input.close()


-- build paths
for k,v in pairs(paths) do
	if string.find(v,"/",1,true)~=1 then paths[k]="/"..paths[k] end -- prepend w/ '/' if not present
	paths[k] = {base=paths[k],repo=paths[k],turtle=tbPath..paths[k]} -- build various paths
	-- clean up turtle paths to avoid trailing whitespace errors
	paths[k].turtle = string.gsub(paths[k].turtle,"%s*$","") -- remove trailing whitespace, if any
	paths[k].turtle = string.gsub(paths[k].turtle,"%s","_") -- replace whitespace with underscores
	-- url encoding characters for git repo
	paths[k].repo = string.gsub(paths[k].repo,"%%","%%25") -- replace all '%' first, as it's used in encoding
	paths[k].repo = string.gsub(paths[k].repo," ","%%20")
	paths[k].repo = string.gsub(paths[k].repo,"!","%%21")
	paths[k].repo = string.gsub(paths[k].repo,'"','%%22')
	paths[k].repo = string.gsub(paths[k].repo,"#","%%23")
	paths[k].repo = string.gsub(paths[k].repo,"%$","%%24")
	paths[k].repo = string.gsub(paths[k].repo,"&","%%26")
	paths[k].repo = string.gsub(paths[k].repo,"'","%%27")
	paths[k].repo = string.gsub(paths[k].repo,"%(","%%28")
	paths[k].repo = string.gsub(paths[k].repo,"%)","%%29")
	paths[k].repo = string.gsub(paths[k].repo,"%*","%%2A")
	paths[k].repo = string.gsub(paths[k].repo,"%+","%%2B")
	paths[k].repo = string.gsub(paths[k].repo,",","%%2C")
	paths[k].repo = string.gsub(paths[k].repo,"%-","%%2D")
	paths[k].repo = string.gsub(paths[k].repo,"%.","%%2E")
	paths[k].repo = string.gsub(paths[k].repo,":","%%3A")
	paths[k].repo = string.gsub(paths[k].repo,";","%%3B")
	paths[k].repo = string.gsub(paths[k].repo,"<","%%3C")
	paths[k].repo = string.gsub(paths[k].repo,"=","%%3D")
	paths[k].repo = string.gsub(paths[k].repo,">","%%3E")
	paths[k].repo = string.gsub(paths[k].repo,"%?","%%3F")
	paths[k].repo = string.gsub(paths[k].repo,"@","%%40")
	paths[k].repo = string.gsub(paths[k].repo,"%[","%%5B")
	paths[k].repo = string.gsub(paths[k].repo,"\\","%%5C")
	paths[k].repo = string.gsub(paths[k].repo,"%]","%%5D")
	paths[k].repo = string.gsub(paths[k].repo,"%^","%%5E")
	paths[k].repo = string.gsub(paths[k].repo,"_","%%5F")
	paths[k].repo = string.gsub(paths[k].repo,"`","%%60")
	paths[k].repo = string.gsub(paths[k].repo,"{","%%7B")
	paths[k].repo = string.gsub(paths[k].repo,"|","%%7C")
	paths[k].repo = string.gsub(paths[k].repo,"}","%%7D")
	paths[k].repo = string.gsub(paths[k].repo,"~","%%7E")
	paths[k].repo = rbPath..paths[k].repo -- prepend repo url with base repository url
end

-- start downloading files
for k,v in pairs(paths) do
	local resp = http.get(paths[k].repo)
	if resp.getResponseCode() == 200 and tonumber(resp.getResponseHeaders()["content-length"]) > 0 then
		if fs.exists(paths[k].turtle) then print("File '"..paths[k].turtle.."' exists. Overwriting...") end
		local file = fs.open(paths[k].turtle,"w")
		local line = resp.readLine(true)
		while line ~= nil do
			file.write(line)
			line=resp.readLine(true)
		end
		file.close()
	end
	resp.close()
end

shell.run("rm startup")
shell.run("rm "..filename)
shell.run("rm "..thisP)

print("Finished cleaning up! :D")
