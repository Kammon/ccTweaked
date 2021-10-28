local position = {}

local core = require("/repos/Kammon/ccTweaked/libraries/core");
local fsUtils = require("/repos/Kammon/ccTweaked/libraries/fsUtils");

--[[


-- Temporary positioning code until Ender GPS network is enabled


--]]

position.direction = { "south", "west", "north", "east" };

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

function changeVector(direction)
	local positionVector = { 0, 0 };
	if direction == "east" then positionVector[1] = 1; positionVector[2] = 0;
	elseif direction == "south" then positionVector[1] = 0; positionVector[2] = 1;
	elseif direction == "west" then positionVector[1] = -1; positionVector[2] = 0;
	elseif direction == "north" then positionVector[1] = 0; positionVector[2] = -1;
	else
		print("Invalid direction. Unable to update position.");
	end
	return positionVector;
end

function position.updatePosition(Position, movement)
	local pos, move, updated = Position or position.initialize(), movement, true;
	local deltaVector = changeVector(pos.dir);
	if move == "forward" then pos.x = pos.x + deltaVector[1]; pos.z = pos.z + deltaVector[2];
	elseif move == "back" then pos.x = pos.x - deltaVector[1]; pos.z = pos.z - deltaVector[2];
	elseif move == "left" then
		if position.direction[pos.dir] % 2 ~= 0 then
			pos.x = pos.x + deltaVector[2]; pos.z = pos.z + deltaVector[1];
		else
			pos.x = pos.x - deltaVector[2]; pos.z = pos.z - deltaVector[1];
		end
	elseif move == "right" then
		if position.direction[pos.dir] % 2 ~= 0 then
			pos.x = pos.x - deltaVector[2]; pos.z = pos.z - deltaVector[1];
		else
			pos.x = pos.x + deltaVector[2]; pos.z = pos.z + deltaVector[1];
		end
	elseif move == "up" then pos.y = pos.y + 1;
	elseif move == "down" then pos.y = pos.y - 1;
	else
		print("Invalid direction. Unable to update position.");
		updated = false;
	end
	return updated, pos;
end

function position.updateDirection(facing, turnDirection)
	local dir, turnDir, dirIndex = facing, turnDirection, nil;
	for k, v in ipairs(position.direction) do if dir == v then dirIndex = v end end
	if turnDir == "right" then
		dir = position.direction[dirIndex % 4 + 1]
	else
		if dirIndex - 1 > 0 then
			dir = position.direction[dirIndex - 1]
		else
			dir = position.direction[4]
		end
	end
	return dir
end

return position
