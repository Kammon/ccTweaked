local movement = {}

local core = require("/repos/Kammon/ccTweaked/libraries/core")
local fsUtils = require("/repos/Kammon/ccTweaked/libraries/fsUtils")
local position = require("/repos/Kammon/ccTweaked/libraries/position") -- placeholder until if/when positioning is implemented
local inv = require("/repos/Kammon/ccTweaked/libraries/inventories")
local fuel = require("/repos/Kammon/ccTweaked/libraries/fuel")

--local pos = position.readFromFile();

funcDirections = { "forward", "back", "up", "down" };
funcBases = {"turtle.turn", "turtle.", "turtle.inspect", "turtle.detect", "turtle.dig", "turtle.suck", "turtle.drop", "turtle.compare" };

function movement.turn(Position, turnDirection)
	local turnDir = turnDirection;
	if turnDir == "right" then turtle.turnRight(); position.updateDirection(Position, "right");
	elseif turnDir == "left" then turtle.turnLeft(); position.updateDirection(Position, "left");
	elseif turnDir == "around" then for i = 1, 2 do turtle.turnRight(); position.updateDirection(Position, "right"); end
	else print("Invalid turn direction supplied.");
	end
	position.writeToFile(Position);
	return Position;
end

function movement.turnTest(direction)
		local turnFn = assert(loadstring([[
			return function(...) 
				assert(#arg >= 1,"Function expects >= 1 argument.");
				assert(type(arg[1]) == "number", "Function arg 1 expects number.");
				if #arg > 1 then
					assert(type(arg[2] == "number", "Function arg 2 expects a number"));
					for i = 1, arg[2] do turtle.turn]]..direction:gsub("^%l",string.upper)..[[() end
				else
					os.sleep(arg[1]); print("Yawn! Nice nap!");
				end
			end]]))();
		turnFn(.5);
		turnFn(9001, 3);
end

function movement.getTurnFn(direction)
	local dir, j = direction, 1;
	if dir == "back" then -- Randomize the turn direction for turning around, because you don't always turn around the same way, do you? Hmm, robot?
		local dirChoice = {"left", "right"};
		dir = dirChoice[(math.floor((math.random(1,1000) / 1000) + 1.5))]; 
		j = 2;
		-- print(dir); -- TEST CODE
	end
	return assert(loadstring([[
		return function() 
			local direction, j = "]]..dir..[[", ]]..j..[[;
			if direction == "left" or direction == "right" then
				for i = 1, j do turtle.turn]]..dir:gsub("^%l",string.upper)..[[(); position.updateDirection(Position, "]]..dir..[[") end
			else
				os.sleep(.05); print(os.getComputerLabel().." is slacking off!");
			end
		end]]
	))();
end

function movement.getFunction(funcBase, direction)
	assert(type(funcBase) =="string" and type(direction) == "string");
	local func = nil;
	for k, v in pairs(funcBases) do
		for k2, v2 in pairs(funcDirections) do
			if v2 == direction and v == funcBase then
				if v2 == "back" then
					if v == "turtle." then
						func == assert(loadstring([[return function()]]..v..v2..[[() end]]))();
					else
						assert(false, "Invalid function option for \"back\" direction.");
					end
				else
					func == assert(loadstring([[return function()]]..v..v2..[[() end]]))();
				end
			else
				assert(false, "Invalid option for function and/or direction.");
			end
		end
	end
	return func;
end

function movement.dig(direction)
	local dir, digFn, detectFn, inspectFn, present, block = direction or "forward", nil, nil, nil, false, nil;
	if direction == "forward" or direction == "up" or direction == "down" then
		--[[
		digFn = assert(loadstring("turtle.dig"..dir:gsub("^%l", string.upper).."()"))(); 
		detectFn = assert(loadstring("turtle.detect"..dir:gsub("^%l", string.upper).."()"))(); 
		inspectFn = assert(loadstring("turtle.inspect"..dir:gsub("^%l", string.upper).."()"))(); 
		--]]
		digFn = movement.getFunction("turtle.dig", direction);
		detectFn = movement.getFunction("turtle.detect", direction);
		inspectFn = movement.getFunction("turtle.inspect", direction);
	end
	present, block = inspectFn();
	while present do digFn(); for k, v in pairs(inv.gravBlocks) do
		if block.name == v then os.sleep(.25); end
		present, block = inspectFn();
	end
	return present;
end

function movement.move(Position, direction)
	local dir, digFn, detectFn, inspectFn, moveFn, moveStatus, fuelStatus = direction or nil, nil, nil, nil, nil, { moved = false, msg = "Move in progress..." }, fuel.recharge(1);
	if not fuelStatus.refueled and not string.find(fuelStatus.fuelMsg, "not yet below") then
		-- Code to call home for fuel resupply should go here. Needs nested inventories, and code added to fuel.lua library for fuel.resupply(), then reassign fuelStatus to a new fuel.recharge(1) call.
		print(textutils.serialize(fuelStatus));
		print("Placeholder for fuel resupply code.");
	end
	if fuelStatus.currentFuel > 0 then
		if direction then
			if direction == "forward" or direction == "up" or direction == "down" or direction == "left" or direction == "right" then
				moveFn = movement.getFunction("turtle.", direction); -- stopping here to check/debug getFunction and dig
			elseif direction == "up" then
			else
				moveStatus.msg = "Invalid direction supplied.";
			end
		else
			moveStatus.msg = "No direction supplied.";
		end
		local present, block = inspectFn();
		if direction == "left" or direction == "right" then
			turnFn = assert(loadstring('return turtle.turn'..direction:gsub("^%l", string.upper)..'(..)'));
		elseif direction == "back" then
			turnFn = assert(loadstring('return turtle.turnRight(..)'));
		else
			turnFn = assert(loadstring('return os.sleep(..)'));
		end
		turnFn(.05);
		turnFn = assert(loadstring('return function(...) assert(#arg >= 1,"Function expects >= 1 argument."); assert(type(arg[1]) == "number", "Function arg 1 expects number."); if #arg > 1 then assert(type(arg[2] == "number", "Function arg 2 expects a number")); for i = 1, arg[2] do turtle.turn'..direction:gsub("^%l",string.upper)..'() end else os.sleep(arg[1]); end end'))();
		while present do digFn(); for k,v in pairs(inv.gravBlocks) do if block == v then os.sleep(.25) end present, block = inspectFn(); end end
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
	position.writeToFile(Position);
	return moveStatus;
end

function movement.mine(Position, direction)
	local dir, digFn, detectFn, inspectFn, moveFn, moveStatus, fuelStatus = direction or nil, nil, nil, nil, nil, { moved = false, msg = "Move in progress..." }, fuel.recharge(1);
	if not fuelStatus.refueled and not string.find(fuelStatus.fuelMsg, "not yet below") then
		-- Code to call home for fuel resupply should go here. Needs nested inventories, and code added to fuel.lua library for fuel.resupply(), then reassign fuelStatus to a new fuel.recharge(1) call.
		print(textutils.serialize(fuelStatus));
		print("Placeholder for fuel resupply code.");
	end
	if fuelStatus.currentFuel > 0 then
		if direction then
			if direction == "forward" or direction == "back" or direction == "left" or direction == "right" then
				digFn = turtle.dig; detectFn = turtle.detect; inspectFn = turtle.inspect; moveFn = turtle.forward;
			elseif direction == "up" then
				digFn = turtle.digUp; detectFn = turtle.detectUp; inspectFn = turtle.inspectUp; moveFn = turtle.up;
			elseif direction == "down" then
				digFn = turtle.dig; detectFn = turtle.detect; inspectFn = turtle.inspect; moveFn = turtle.forward;
			else
				moveStatus.msg = "Invalid direction supplied.";
			end
		else
			moveStatus.msg = "No direction supplied.";
		end
		local present, block = inspectFn();
		if direction == "left" or direction == "right" then
			turnFn = assert(loadstring('return turtle.turn'..direction:gsub("^%l", string.upper)..'(..)'));
		elseif direction == "back" then
			turnFn = assert(loadstring('return turtle.turnRight(..)'));
		else
			turnFn = assert(loadstring('return os.sleep(..)'));
		end
		turnFn(.05);
		turnFn = assert(loadstring('return function(...) assert(#arg >= 1,"Function expects >= 1 argument."); assert(type(arg[1]) == "number", "Function arg 1 expects number."); if #arg > 1 then assert(type(arg[2] == "number", "Function arg 2 expects a number")); for i = 1, arg[2] do turtle.turn'..direction:gsub("^%l",string.upper)..'() end else os.sleep(arg[1]); end end'))();
		while present do digFn(); for k,v in pairs(inv.gravBlocks) do if block == v then os.sleep(.25) end present, block = inspectFn(); end end
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
	position.writeToFile(Position);
	return moveStatus;
end

--[[
function movement.move(Position, direction)
	local dir, digFn, detectFn, inspectFn, moveFn, moveStatus, fuelStatus = direction or nil, nil, nil, nil, nil, { moved = false, msg = "Move in progress..." }, fuel.recharge(1);
	if not fuelStatus.refueled and not string.find(fuelStatus.fuelMsg, "not yet below") then
		-- Code to call home for fuel resupply should go here. Needs nested inventories, and code added to fuel.lua library for fuel.resupply(), then reassign fuelStatus to a new fuel.recharge(1) call.
		print(textutils.serialize(fuelStatus));
		print("Placeholder for fuel resupply code.");
	end
	if fuelStatus.currentFuel > 0 then
		if direction then
			if direction == "forward" or direction == "back" or direction == "left" or direction == "right" then
				digFn = turtle.dig; detectFn = turtle.detect; inspectFn = turtle.inspect; moveFn = turtle.forward;
			elseif direction == "up" then
				digFn = turtle.digUp; detectFn = turtle.detectUp; inspectFn = turtle.inspectUp; moveFn = turtle.up;
			elseif direction == "down" then
				digFn = turtle.dig; detectFn = turtle.detect; inspectFn = turtle.inspect; moveFn = turtle.forward;
			else
				moveStatus.msg = "Invalid direction supplied.";
			end
		else
			moveStatus.msg = "No direction supplied.";
		end
		local present, block = inspectFn();
		if direction == "left" or direction == "right" then
			turnFn = assert(loadstring('return turtle.turn'..direction:gsub("^%l", string.upper)..'(..)'));
		elseif direction == "back" then
			turnFn = assert(loadstring('return turtle.turnRight(..)'));
		else
			turnFn = assert(loadstring('return os.sleep(..)'));
		end
		turnFn(.05);
		turnFn = assert(loadstring('return function(...) assert(#arg >= 1,"Function expects >= 1 argument."); assert(type(arg[1]) == "number", "Function arg 1 expects number."); if #arg > 1 then assert(type(arg[2] == "number", "Function arg 2 expects a number")); for i = 1, arg[2] do turtle.turn'..direction:gsub("^%l",string.upper)..'() end else os.sleep(arg[1]); end end'))();
		while present do digFn(); for k,v in pairs(inv.gravBlocks) do if block == v then os.sleep(.25) end present, block = inspectFn(); end end
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
	position.writeToFile(Position);
	return moveStatus;
end
--]]

return movement
