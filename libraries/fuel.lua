local fuel = {}

local core = require("/repos/Kammon/ccTweaked/libraries/core");
local fsUtils = require("/repos/Kammon/ccTweaked/libraries/fsUtils");
--local inventories = require("/repos/Kammon/ccTweaked/libraries/inventories");

local fuelList = fsUtils.getContents(core.bp.."/data/inventory/fuel.txt");
local FUEL_THRESHOLD = 1000;

--[[
-- Testing code
function fuel.isFuel(slot)
	local slotItem, isFuel = turtle.getItemDetail(slot), false;
	for k,v in pairs(fuelList) do
		if slotItem and slotItem.name == v then isFuel = true end
	end
	return isFuel, slotItem;
end
--]]

function isFuel(slot)
	local slotItem, isFuel = turtle.getItemDetail(slot), false;
	for k,v in pairs(fuelList) do
		if slotItem and slotItem.name == v then isFuel = true end
	end
	return isFuel, slotItem;
end

function getFuelSources()
	local isFuelSource, fuelSource, fuelSources = nil, nil, {}
	for i = 1, core.SLOT_COUNT do
		isFuelSource, fuelSource = isFuel(i);
		if isFuelSource then fuelSources[#fuelSources + 1] = {type = fuelSource.name, slot = i} end
	end
	return fuelSources;
end

function fuel.recharge(amount)
	local refueled, currFuel, newFuel, fuelAdded, msg, fuelStatus = false, turtle.getFuelLevel(), nil, nil, "Fuel not yet below minimum reserve threshold of "..FUEL_THRESHOLD..".", {};
	if currFuel < FUEL_THRESHOLD then
		local amount, currSlot, fuelSources = amount or nil, turtle.getSelectedSlot(), getFuelSources();
		if #fuelSources > 0 then
			for i = 1,#fuelSources do
				turtle.select(fuelSources[i].slot);
				while turtle.getItemCount(fuelSources[i].slot) > 0 and turtle.getFuelLevel() < FUEL_THRESHOLD do
					if amount then turtle.refuel(amount) else turtle.refuel(1) end
				end
			end
			if turtle.getFuelLevel() > FUEL_THRESHOLD then
				msg = "Refueling complete."; refueled = true;
			else
				msg = "Not enough fuel to pass minimum fuel threshold of "..FUEL_THRESHOLD..". Turtle will cease function if not refueled."; refueled = false;
			end
		else
			msg = "No fuel sources present. Turtle is running on reserve power below minimum threshold of "..FUEL_THRESHOLD.." and will cease function if not refueled."; refueled = false;
		end
	end
	fuelAdded = turtle.getFuelLevel() - currFuel;
	fuelStatus.refueled, fuelStatus.fuelAdded, fuelStatus.currentFuel, fuelStatus.fuelMsg = refueled, fuelAdded, turtle.getFuelLevel(), msg;
	return fuelStatus;
end


return fuel
