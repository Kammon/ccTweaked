local fuel = {}

local core = require("/repos/Kammon/ccTweaked/libraries/core");
local fsUtils = require("/repos/Kammon/ccTweaked/libraries/fsUtils");
--local inventories = require("/repos/Kammon/ccTweaked/libraries/inventories");

local fuelList = fsUtils.getContents(core.bp.."/data/inventory/fuel.txt");
local FUEL_THRESHOLD = 1000;

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
	local amount = amount or nil;
	if turtle.getFuelLevel() < FUEL_THRESHOLD then
		local amount, refueled, currSlot, fuelSources, msg = amount or nil, false, turtle.getSelectedSlot(), getFuelSources(), "Refueling in progress...";
		if fuelSources then
			for i = 1,#fuelSources do
				turtle.select(fuelSources[i].slot);
				while turtle.getItemCount(fuelSources[i].slot) > 0 and turtle.getFuelLevel() < FUEL_Threshold do
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
end


return fuel
