--local core = require("/repos/Kammon/ccTweaked/libraries/core")
--local fsu = require(core.bp.."libraries/fsUtils") -- not entirely sure how I want these to work

local inventories = {}
inventories.core = require("/repos/Kammon/ccTweaked/libraries/core")
inventories.fsu = require(inventories.core.bp.."libraries/fsUtils")
inventories.invList = inventories.getInventories()

function inventories.getInventories()
	return inventories.fsu.getContents(inventories.core.bp.."data/inventory/inventories.txt")
end

function inventories.getInventoryTypes()
	local invTypes, kvParts = {}, {}
	for k,v in pairs(inventories.fsu.getContents(inventories.core.bp.."data/inventory/inventoryTypes.txt")) do
		kvParts = inventories.core.split(v,"=",nil,false)
		if #kvParts == 2 then
			invTypes[inventories.core.trim(kvParts[1])] = inventories.core.trim(kvParts[2])
		else
			print("ERROR: Invalid Key/Value pair at "..v.." in "..shell.getRunningProgram())
			assert(false)
		end
	end
	--return inventories.fsu.getContents(inventories.core.bp.."data/inventory/inventoryTypes.txt")
	return invTypes
end

function inventories.isInventory(slot)
	local slotItem, isInv = turtle.getItemDetail(slot), false
	for k,v in pairs(inventories.invList) do
		if slotItem then
			if slotItem.name == v then isInv = true end
		end
	end
	return isInv
end

function inventories.checkInventory(slot)
	local slotInv, thisInv, currSlot = slot, {type="unknown", slot=-1}, turtle.getSelectedSlot()
	--local invTypes = getInventoryTypes()
	--[[
	for k,v in pairs(getInventoryTypes()) do
		--working on improving fileRead and split to make k,v pairs
		kvParts = core.split(v,"=",nil,false)
		if #kvParts == 2 then
			invTypes[core.trim(kvParts[1])] = core.trim(kvParts[2])
		else
			print("ERROR: Invalid Key/Value pair at "..v)
		end
	end
	--]]
	while turtle.detectUp() do turtle.digUp(); os.sleep(1) end
	turtle.select(slotInv)
	turtle.placeUp()
	for k, v in pairs(inventories.getInventoryTypes()) do
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
