--[[
	This project is created with the Clockwork framework by Cloud Sixteen.
	http://cloudsixteen.com
--]]

local ITEM = Clockwork.item:New();

ITEM.name = "ItemExample";
ITEM.cost = 5;
ITEM.model = "models/props_junk/popcan01a.mdl";
ITEM.weight = 1;
ITEM.access = "1";
ITEM.uniqueID = "example_item";

--[[
	If you want to restrict this item so it can only be
	bought by certain classes or if the player has certain
	flags then you specify these:
	
	ITEM.access = "flags";
	ITEM.classes = {CLASS_EXAMPLE};
--]]

ITEM.business = true;
ITEM.category = "CategoryExample";
ITEM.description = "ItemExampleDesc";

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

ITEM:Register();