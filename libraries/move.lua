local movement = {}

local core = require("/repos/Kammon/ccTweaked/libraries/core")
local fsUtils = require("/repos/Kammon/ccTweaked/libraries/fsUtils")
local position = {} -- placeholder until if/when positioning is implemented
local fuel = require("/repos/Kammon/ccTweaked/libraries/fuel")

function move(direction)
	local dir, moveStatus, fuelStatus = direction or nil, { moved = false, msg = "Move in progress..." }, fuel.recharge(1);
	if not refueled and not string.find(fuelStatus.fuelMsg, "not yet below") then
		-- Code to call home for fuel resupply should go here. Needs nested inventories, and code added to fuel.lua library for fuel.resupply(), then reassign fuelStatus to a new fuel.recharge(1) call.
		print(textutils.serialize(fuelStatus));
		print("Placeholder for fuel resupply code.");
	end
	if fuelStatus.currentFuel > 0 then
		if direction then
			if direction == "forward" then
				while turtle.detect() do turtle.dig(); os.sleep(1); end
				moveStatus.moved = turtle.forward();
			elseif direction == "back" then
				for i = 1, 2 do turtle.turnRight(); end
				while turtle.detect() do turtle.dig(); os.sleep(1); end
				moveStatus.moved = turtle.forward();
				for i = 1, 2 do turtle.turnLeft(); end
			elseif direction == "left" then
				turtle.turnLeft();
				while turtle.detect() do turtle.dig(); os.sleep(1); end
				moveStatus.moved = turtle.forward();
				turtle.turnRight();
			elseif direction == "right" then
				turtle.turnRight();
				while turtle.detect() do turtle.dig(); os.sleep(1); end
				moveStatus.moved = turtle.forward();
				turtle.turnLeft();
			elseif direction == "up" then
				local blockAbove = turtle.inspectUp()
				while turtle.detectUp() and blockAbove and blockAbove.name ~= "minecraft:bedrock" do turtle.digUp(); os.sleep(1); end
				moveStatus.moved = turtle.up();
			elseif direction == "down" then
				local blockBelow = turtle.inspectDown();
				while turtle.detectDown() and blockBelow and blockBelow.name ~= "minecraft:bedrock"  do turtle.digDown(); os.sleep(1); end
				moveStatus.moved = turtle.down();
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
	if not refueled and not string.find(fuelStatus.fuelMsg, "not yet below") then
		if moveStatus.moved then
			moveStatus.warnMsg = "Not enough fuel to stay above minimum reserve threshold. Shutdown without fuel resupply in "..(fuelStatus.currentFuel - 1).." steps."; -- this is kinda hacky. if the turtle doesn't move successfully, then the current fuel isn't decreasing like we're declaring here. Messaging should happen after movement.
		else 
			moveStatus.warnMsg = "Not enough fuel to stay above minimum reserve threshold. Shutdown without fuel resupply in "..fuelStatus.currentFuel.." steps."; -- this is kinda hacky. if the turtle doesn't move successfully, then the current fuel isn't decreasing like we're declaring here. Messaging should happen after movement.
		end
	end
	return moveStatus;
end

return movement
