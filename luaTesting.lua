inv = require("/repos/Kammon/ccTweaked/libraries/inventories")
turtle = require("/rom/apis/turtle/turtle")

for i= 1, inv.core.SLOT_COUNT do
	turtle.getItemDetails(i)
end
