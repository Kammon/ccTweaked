local position = {}

local core = require("/repos/Kammon/ccTweaked/libraries/core");
local fsUtils = require("/repos/Kammon/ccTweaked/libraries/fsUtils");

--[[


-- Temporary positioning code until Ender GPS network is enabled


--]]

position.direction = { "south", "west", "north", "east" };

function position.initialize()
	local currPos, newPos, i, delta = {}, {}, 1, {};
	currPos.x, currPos.y, currPos.z = gps.locate();
	while turtle.detect() and i <= 4 do turtle.turnLeft(); i = i + 1; end
	if turtle.forward() then
		newPos.x, newPos.y, newPos.z = gps.locate();
		turtle.back();
	else
		assert(false,"Unable to move to determine direction.");
	end
	for k, v in pairs(currPos) do
		for k2, v2 in pairs(newPos) do
			if k == k2 then delta.change = v2 - v; delta.plane = k; end
		end
	end
	if delta.change > 0 then
		if delta.plane == "x" then currPos.dir == "east"; else currPos.dir == "south"; end
	else
		if delta.plane == "x" then currPos.dir == "west"; else currPos.dir == "north"; end
	end
	return currPos;
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
	local pos, move, dirIndex = Position or position.initialize(), movement, nil;
	local deltaVector = changeVector(pos.dir);
	for k, v in ipairs(position.direction) do if pos.dir == v then dirIndex = k end end
	if move == "forward" then pos.x = pos.x + deltaVector[1]; pos.z = pos.z + deltaVector[2];
	elseif move == "back" then pos.x = pos.x - deltaVector[1]; pos.z = pos.z - deltaVector[2];
	elseif move == "left" then
		if position.direction[dirIndex % 2] ~= 0 then
			pos.x = pos.x - deltaVector[2]; pos.z = pos.z - deltaVector[1];
		else
			pos.x = pos.x + deltaVector[2]; pos.z = pos.z + deltaVector[1];
		end
	elseif move == "right" then
		if position.direction[dirIndex % 2] ~= 0 then
			pos.x = pos.x + deltaVector[2]; pos.z = pos.z + deltaVector[1];
		else
			pos.x = pos.x - deltaVector[2]; pos.z = pos.z - deltaVector[1];
		end
	elseif move == "up" then pos.y = pos.y + 1;
	elseif move == "down" then pos.y = pos.y - 1;
	else
		print("Invalid direction. Unable to update position.");
	end
	return pos;
end

function position.updateDirection(Position, turnDirection)
	local pos, turnDir, dirIndex = Position, turnDirection, nil;
	for k, v in ipairs(position.direction) do if pos.dir == v then dirIndex = k end end
	if turnDir == "right" then
		pos.dir = position.direction[dirIndex % 4 + 1]
	else
		if dirIndex - 1 > 0 then
			pos.dir = position.direction[dirIndex - 1]
		else
			pos.dir = position.direction[4]
		end
	end
	return pos
end

return position
