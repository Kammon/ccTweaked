local movement = {}

local core = require("/repos/Kammon/ccTweaked/libraries/core")
local fsUtils = require("/repos/Kammon/ccTweaked/libraries/fsUtils")
local position = require("/repos/Kammon/ccTweaked/libraries/position") -- placeholder until if/when positioning is implemented
local fuel = require("/repos/Kammon/ccTweaked/libraries/fuel")

--local pos = position.readFromFile();

function movement.turn(turnDirection)
	local turnDir = turnDirection;
	if turnDir == "right" then turtle.turnRight(); pos = position.updateDirection(pos, "right");
	elseif turnDir == "left" then turtle.turnLeft(); pos = position.updateDirection(pos, "left");
	elseif turnDir == "around" then for i = 1, 2 do turtle.turnRight(); pos = position.updateDirection(pos, "right"); end
	else print("Invalid turn direction supplied.");
	end
	return pos;
end

function movement.move(direction)
	local pos, dir, moveStatus, fuelStatus = position.readFromFile(), direction or nil, { moved = false, msg = "Move in progress..." }, fuel.recharge(1);
	if not fuelStatus.refueled and not string.find(fuelStatus.fuelMsg, "not yet below") then
		-- Code to call home for fuel resupply should go here. Needs nested inventories, and code added to fuel.lua library for fuel.resupply(), then reassign fuelStatus to a new fuel.recharge(1) call.
		print(textutils.serialize(fuelStatus));
		print("Placeholder for fuel resupply code.");
	end
	if fuelStatus.currentFuel > 0 then
		if direction then
			if direction == "forward" then
				while turtle.detect() do turtle.dig(); os.sleep(1); end
				moveStatus.moved = turtle.forward();
				if moveStatus.moved then pos = position.updatePosition(pos, "forward"); end
			elseif direction == "back" then
				pos = movement.turn("around");
				--for i = 1, 2 do pos.dir = movement.turn("right");  --[[turtle.turnRight();--]] end
				while turtle.detect() do turtle.dig(); os.sleep(1); end
				moveStatus.moved = turtle.forward();
				pos = movement.turn("around");
				--for i = 1, 2 do pos.dir = movement.turn("left"); --[[turtle.turnLeft();--]] end
				if moveStatus.moved then pos = position.updatePosition(pos, "back"); end
			elseif direction == "left" then
				pos = movement.turn("left"); --[[turtle.turnLeft();--]]
				while turtle.detect() do turtle.dig(); os.sleep(1); end
				moveStatus.moved = turtle.forward();
				pos = movement.turn("right"); --[[turtle.turnRight();--]]
				if moveStatus.moved then pos = position.updatePosition(pos, "left"); end
			elseif direction == "right" then
				pos = movement.turn("right"); --[[turtle.turnRight();--]]
				while turtle.detect() do turtle.dig(); os.sleep(1); end
				moveStatus.moved = turtle.forward();
				pos = movement.turn("left"); --[[turtle.turnLeft();--]]
				if moveStatus.moved then pos = position.updatePosition(pos, "right"); end
			elseif direction == "up" then
				local blockAbove = turtle.inspectUp()
				while turtle.detectUp() and blockAbove and blockAbove.name ~= "minecraft:bedrock" do turtle.digUp(); os.sleep(1); end
				moveStatus.moved = turtle.up();
				if moveStatus.moved then pos = position.updatePosition(pos, "up"); end
			elseif direction == "down" then
				local blockBelow = turtle.inspectDown();
				while turtle.detectDown() and blockBelow and blockBelow.name ~= "minecraft:bedrock"  do turtle.digDown(); os.sleep(1); end
				moveStatus.moved = turtle.down();
				if moveStatus.moved then pos = position.updatePosition(pos, "down"); end
			else
				moveStatus.msg = "Invalid direction supplied.";
			end
		else
			moveStatus.msg = "No direction supplied.";
		end
	else
		moveStatus.msg = "No fuel remaining. Shutting down.";
	end
	if moveStatus.moved then moveStatus.msg = "Moved successfully."; end
	if not fuelStatus.refueled and not string.find(fuelStatus.fuelMsg, "not yet below") then
		if moveStatus.moved then
			moveStatus.warnMsg = "Not enough fuel to stay above minimum reserve threshold. Shutdown without fuel resupply in "..(fuelStatus.currentFuel - 1).." steps."; -- this is kinda hacky. if the turtle doesn't move successfully, then the current fuel isn't decreasing like we're declaring here. Messaging should happen after movement.
		else 
			moveStatus.warnMsg = "Not enough fuel to stay above minimum reserve threshold. Shutdown without fuel resupply in "..fuelStatus.currentFuel.." steps."; -- this is kinda hacky. if the turtle doesn't move successfully, then the current fuel isn't decreasing like we're declaring here. Messaging should happen after movement.
		end
	end
	position.writeToFile(pos);
	return moveStatus;
end

return movement
