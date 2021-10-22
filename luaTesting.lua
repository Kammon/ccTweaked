inv = require("/repos/Kammon/ccTweaked/libraries/inventories")

for i= 1, inv.core.SLOT_COUNT do
	turtle.getItemDetails(i)
end
