--[[
	� CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New("alcohol_base");

ITEM.name = "ItemBeer";
ITEM.uniqueID = "beer";
ITEM.cost = 6;
ITEM.model = "models/props_junk/garbage_glassbottle003a.mdl";
ITEM.weight = 0.6;
ITEM.access = "w";
ITEM.business = true;
ITEM.attributes = {Strength = 2};
ITEM.description = "ItemBeerDesc";

ITEM:Register();