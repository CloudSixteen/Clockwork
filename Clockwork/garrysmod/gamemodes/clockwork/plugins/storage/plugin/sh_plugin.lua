--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

--[[
	You don't have to do this, but I think it's nicer.
	Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias("cwStorage");

--[[ You don't have to do this either, but I prefer to separate the functions. --]]
Clockwork.kernel:IncludePrefixed("cl_plugin.lua");
Clockwork.kernel:IncludePrefixed("sv_plugin.lua");
Clockwork.kernel:IncludePrefixed("sv_hooks.lua");
Clockwork.kernel:IncludePrefixed("cl_hooks.lua");

cwStorage.containerList = {
	["models/props_wasteland/controlroom_storagecloset001a.mdl"] = {8, "Closet"},
	["models/props_wasteland/controlroom_storagecloset001b.mdl"] = {15, "Closet"},
	["models/props_wasteland/controlroom_filecabinet001a.mdl"] = {4, "File Cabinet"},
	["models/props_wasteland/controlroom_filecabinet002a.mdl"] = {8, "File Cabinet"},
	["models/props_c17/suitcase_passenger_physics.mdl"] = {5, "Suitcase"},
	["models/props_junk/wood_crate001a_damagedmax.mdl"] = {8, "Wooden Crate"},
	["models/props_junk/wood_crate001a_damaged.mdl"] = {8, "Wooden Crate"},
	["models/props_interiors/furniture_desk01a.mdl"] = {4, "Desk"},
	["models/props_c17/furnituredresser001a.mdl"] = {10, "Dresser"},
	["models/props_c17/furnituredrawer001a.mdl"] = {8, "Drawer"},
	["models/props_c17/furnituredrawer002a.mdl"] = {4, "Drawer"},
	["models/props_c17/furniturefridge001a.mdl"] = {8, "Fridge"},
	["models/props_c17/furnituredrawer003a.mdl"] = {8, "Drawer"},
	["models/weapons/w_suitcase_passenger.mdl"] = {5, "Suitcase"},
	["models/props_junk/trashdumpster01a.mdl"] = {15, "Dumpster"},
	["models/props_junk/wood_crate001a.mdl"] = {8, "Wooden Crate"},
	["models/props_junk/wood_crate002a.mdl"] = {10, "Wooden Crate"},
	["models/items/ammocrate_rockets.mdl"] = {15, "Ammo Crate"},
	["models/props_lab/filecabinet02.mdl"] = {8, "File Cabinet"},
	["models/items/ammocrate_grenade.mdl"] = {15, "Ammo Crate"},
	["models/props_junk/trashbin01a.mdl"] = {10, "Trash Bin"},
	["models/props_c17/suitcase001a.mdl"] = {8, "Suitcase"},
	["models/items/item_item_crate.mdl"] = {4, "Item Crate"},
	["models/props_c17/oildrum001.mdl"] = {8, "Oildrum"},
	["models/items/ammocrate_smg1.mdl"] = {15, "Ammo Crate"},
	["models/items/ammocrate_ar2.mdl"] = {15, "Ammo Crate"}
};