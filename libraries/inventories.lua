--local core = require("/repos/Kammon/ccTweaked/libraries/core")
--local fsu = require(core.bp.."libraries/fsUtils") -- not entirely sure how I want these to work

local inventories = {}
inventories.core = require("/repos/Kammon/ccTweaked/libraries/core")
inventories.fsu = require(inventories.core.bp.."libraries/fsUtils")
function inventories.getInventories()
	return inventories.fsu.getContents(inventories.core.bp.."data/inventory/inventories.lua")
end

function inventories.getInventoryTypes()
	return inventories.fsu.getContents(inventories.core.bp.."data/inventoryTypes.lua")
end

function inventories.isInventory(slot)
	local slotItem, isInv = turtle.getItemDetail(slot), false
	for k,v in pairs(getInventories()) do
		if slotItem then
			if slotItem.name == v then isInv = true end
		end
	end
	return isInv
end

function inventories.checkInventory(slot)
	local slotInv, thisInv, currSlot = slot, {type="unknown", slot=-1}, turtle.getSelectedSlot()
	local invTypes, kvParts = {}, {}
	for k,v in pairs(getInventoryTypes()) do
		--working on improving fileRead and split to make k,v pairs
		kvParts = core.split(v,"=",nil,false)
		if #kvParts == 2 then
			invTypes[core.trim(kvParts[1])] = core.trim(kvParts[2])
		else
			print("ERROR: Invalid Key/Value pair at "..v)
		end
	end
	while turtle.detectUp() do turtle.digUp(); os.sleep(1) end
	turtle.select(slotInv)
	turtle.placeUp()
	for k, v in pairs(invTypes) do
		turtle.suckUp()
		local invType = turtle.getItemDetail()
		if invType then
			if invType.name == v then thisInv.type = k; thisInv.slot = slotInv end -- NOTE: This won't work atm. Current fileRead only supports numbered indexes
			turtle.dropUp()
		else
			thisInv.type = "empty"; thisInv.slot = slotInv
		end
	end
	turtle.digUp() -- NOTE: not entirely sure the behavior I want here. Do I leave the inventory up there and let the caller decide what to do, or do I note the invType and slot and relay that to the caller instead?
	return thisInv
end

return inventories
