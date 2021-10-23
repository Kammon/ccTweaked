--local core = require("/repos/Kammon/ccTweaked/libraries/core")
--local fsu = require(core.bp.."libraries/fsUtils") -- not entirely sure how I want these to work

local inventories = {}
inventories.core = require("/repos/Kammon/ccTweaked/libraries/core")
inventories.fsu = require(inventories.core.bp.."libraries/fsUtils")

function inventories.getInventories()
	return inventories.fsu.getContents(inventories.core.bp.."data/inventory/inventories.txt")
end

--list resources/blocks/inventories/etc
inventories.blocks = inventories.fsu.getContents(inventories.core.bp.."data/inventory/blocks.txt")
inventories.fuel = inventories.fsu.getContents(inventories.core.bp.."data/inventory/fuel.txt")
inventories.resources = inventories.fsu.getContents(inventories.core.bp.."data/inventory/resources.txt")
inventories.unwanted = inventories.fsu.getContents(inventories.core.bp.."data/inventory/unwanted.txt")
inventories.lighting = inventories.fsu.getContents(inventories.core.bp.."data/inventory/lighting.txt")
inventories.invList = inventories.getInventories()

function inventories.getInventoryTypes()
	--[[
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
	--]]
	return inventories.core.getKeyValuePairs(inventories.fsu.getContents(inventories.core.bp.."data/inventory/inventoryTypes.txt"))
end

inventories.invTypeList = inventories.getInventoryTypes()

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
	local invType = nil
	if turtle.suckUp() then
		for k, v in pairs(inventories.invTypeList) do
			--turtle.suckUp()
			if thisInv.type == "unknown" then
				invType = turtle.getItemDetail()
				if invType then
					if invType.name == v then thisInv.type = k; thisInv.slot = slotInv end -- NOTE: This won't work atm. Current fileRead only supports numbered indexes
					--turtle.dropUp()
				end
				-- else
				-- 	thisInv.type = "empty"; thisInv.slot = slotInv
				-- end
			end
		end
		turtle.dropUp()
	else
		thisInv.type = "empty"; thisInv.slot = slotInv
	end
	if thisInv.type == "unknown" then --[[ print("ERROR: unknown item key: "..invType.name.." in slot "..tostring(slotInv)); --]] thisInv.type = thisInv.type.." -- "..invType.name; thisInv.slot = slotInv end
	turtle.digUp() -- NOTE: not entirely sure the behavior I want here. Do I leave the inventory up there and let the caller decide what to do, or do I note the invType and slot and relay that to the caller instead?
	turtle.select(currSlot)
	return thisInv
end

function inventories.getTurtleInventories()
	local tInventories = {}
	for i=1, inventories.core.SLOT_COUNT do
		if inventories.isInventory(i) then tInventories[#tInventories + 1] = inventories.checkInventory(i) end
	end
	return tInventories
end

function inventories.getTurtleInventory(detailed)
	local detail, slotItem, tInventory = false or detailed, nil, {}
	for i=1, inventories.core.SLOT_COUNT do
		slotItem = turtle.getItemDetail(i, detail)
		if slotItem then
			tInventory[#tInventory + 1] = slotItem
		else
			if detail then
				tInventory[#tInventory + 1] = { count = 0, displayName = "Empty Slot", maxCount = 1, name = nil, tags = {} }
			else	
				tInventory[#tInventory + 1] = { name = nil, count = 0 }
			end
		end
	end
	return tInventory
end

function inventories.getEmptySlots()
	local slotItem, emptySlots, hasEmptySlots = nil, {}, false
	for i=1, inventories.core.SLOT_COUNT do
		slotItem = turtle.getItemDetail(i)
		if not slotItem then
			emptySlots[#emptySlots + 1] = i
			hasEmptySlots = true
		end
	end
	return hasEmptySlots, emptySlots
end

function inventories.extractFromInventory(slot)
	local currSlot, gotItem = turtle.getSelectedSlot(), false
	if inventories.getEmptySlots() then
		while turtle.detectUp() do
			turtle.digUp()
			os.sleep(1)
		end
		turtle.select(slot)
		turtle.placeUp()
		turtle.suckUp()
		gotItem = turtle.suckUp()
		turtle.dropUp()
		turtle.digUp()
		turtle.select(currSlot)
	end
	return gotItem
end

function inventories.getStack(inventory)
	local currSlot, gotItem, tInventories = turtle.getSelectedSlot(), false, inventories.getTurtleInventories()
	for i = 1, #tInventories do
		if not gotItem and tInventories[i].type == inventory then
			gotItem = inventories.extractFromInventory(tInventories[i].slot)
		end
	end
	return gotItem
end

function inventories.storeInInventory(slot, inventory)
	local currSlot, storedItem, tInventories = turtle.getSelectedSlot(), false, inventories.getTurtleInventories()
	for i = 1, #tInventories do
		-- inventories.
	end

end

return inventories
