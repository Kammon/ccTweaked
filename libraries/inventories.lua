local fsu = require("/libraries/fsUtils") -- not entirely sure how I want these to work
local core = require("/libraries/core")

function getInventories()
	return fsu.getContents("/libraries/datasets/inventories.lua")
end

function getInventoryTypes()
	return fsu.getContents("/libraries/datasets/inventoryTypes.lua")
end

function isInventory(slot)
	local slotItem, isInv = turtle.getItemDetail(slot), false
	for k,v in pairs(getInventories()) do
		if slotItem then
			if slotItem.name == v then isInv = true end
		end
	end
	return isInv
end

function checkInventory(slot)
	local slotInv, thisInv, currSlot = slot, "unknown", turtle.getSelectedSlot()
	local invTypes = {}
	for k,v in pairs(getInventoryTypes()) do
		--working on improving fileRead and split to make k,v pairs
		core
	end
	while turtle.detectUp() do turtle.digUp(); os.sleep(1) end
	turtle.select(slotInv)
	turtle.placeUp()
	for k, v in pairs(invTypes) do
		turtle.suckUp()
		local invType = turtle.getItemDetail()
		if invType then
			if invType.name == v then thisInv = k end -- NOTE: This won't work atm. Current fileRead only supports numbered indexes
			turtle.dropUp()
		else
			thisInv = "empty"
		end
	end
	turtle.digUp() -- NOTE: not entirely sure the behavior I want here. Do I leave the inventory up there and let the caller decide what to do, or do I note the invType and slot and relay that to the caller instead?
	return thisInv
end
