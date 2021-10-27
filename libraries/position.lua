local position = {}

local core = require("/repos/Kammon/ccTweaked/libraries/core");
local fsUtils = require("/repos/Kammon/ccTweaked/libraries/fsUtils");

--[[


-- Temporary positioning code until Ender GPS network is enabled


--]]

local direction = { "south", "west", "north", "east" };

function position.initialize(Position)
	local pos = { x = Position.x or 0, y = Position.y or 0, z = Position.z or 0, dir = Position.dir or "south" };
	return pos;
end

function position.readFromFile()
	return position.initialize(core.getKeyValuePairs(fsUtils.getContents(core.bp.."data/position.txt")))
end

function position.writeToFile(position)
	fsUtils.writeToFile(core.bp.."data/position.txt", position);
end

return position
