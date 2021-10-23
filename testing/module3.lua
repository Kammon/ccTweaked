--fuel library

local fuel = {}
fuel.core = require("/repos/Kammon/ccTweaked/libraries/core")
fuel.fsUtils = require("/repos/Kammon/ccTweaked/libraries/fsUtils")
fuel.inventories = require("/repos/Kammon/ccTweaked/libraries/inventories")

fuel.THRESHOLD = 100

function fuel.refuel(amount)
	if turtle.getFuelLevel() < fuel.THRESHOLD then
		local myInventory = fuel.inventories.getTurtleInventory();
		for k, v in pairs(myInventory) do
			print(k.." : "..v)
		end
	end
end

return fuel
