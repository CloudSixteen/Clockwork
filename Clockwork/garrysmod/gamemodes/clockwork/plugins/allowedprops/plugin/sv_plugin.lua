--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

cwAllowedProps.defaultAllowedProps = {
	"models/props_junk/wood_crate001a.mdl",
	"models/props_junk/wood_crate001a_damaged.mdl",
	"models/props_junk/wood_crate002a.mdl",
	"models/props_junk/wood_pallet001a.mdl",
	"models/props_junk/cardboard_box001a.mdl",
	"models/props_junk/cardboard_box001a_gib01.mdl",
	"models/props_junk/cardboard_box001b.mdl",
	"models/props_junk/cardboard_box002a.mdl",
	"models/props_junk/cardboard_box002a_gib01.mdl",
	"models/props_junk/cardboard_box002b.mdl",
	"models/props_junk/cardboard_box003a.mdl",
	"models/props_junk/cardboard_box003a_gib01.mdl",
	"models/props_junk/cardboard_box003b.mdl",
	"models/props_junk/cardboard_box003b_gib01.mdl",
	"models/props_junk/cardboard_box004a.mdl",
	"models/props_junk/cardboard_box004a_gib01.mdl",
	"models/props_junk/PlasticCrate01a.mdl",
	"models/props_junk/PopCan01a.mdl",
	"models/props_junk/TrafficCone001a.mdl",
	"models/props_junk/TrashBin01a.mdl",
	"models/props_c17/FurnitureCouch001a.mdl",
	"models/props_c17/FurnitureCouch002a.mdl",
	"models/props_c17/door01_left.mdl",
	"models/props_c17/door02_double.mdl",
	"models/props_c17/FurnitureShelf001a.mdl",
	"models/props_c17/FurnitureShelf001b.mdl",
	"models/props_c17/FurnitureCupboard001a.mdl",
	"models/props_c17/FurnitureDrawer001a.mdl",
	"models/props_c17/FurnitureDrawer002a.mdl",
	"models/props_c17/FurnitureDrawer003a.mdl",
	"models/props_c17/FurnitureDresser001a.mdl",
	"models/props_c17/FurnitureTable001a.mdl",
	"models/props_c17/FurnitureTable002a.mdl",
	"models/props_c17/FurnitureTable003a.mdl",
	"models/props_c17/FurnitureRadiator001a.mdl",
	"models/props_c17/FurnitureBed001a.mdl",
	"models/props_c17/FurnitureChair001a.mdl",
	"models/props_c17/FurnitureWashingmachine001a.mdl",
	"models/props_c17/shelfunit01a.mdl",
	"models/props_interiors/pot02a.mdl",
	"models/props_interiors/pot01a.mdl",
	"models/props_interiors/Furniture_chair01a.mdl",
	"models/props_interiors/Furniture_chair03a.mdl",
	"models/props_interiors/Furniture_Couch02a.mdl",
	"models/props_interiors/Furniture_Desk01a.mdl",
	"models/props_interiors/Furniture_Lamp01a.mdl",
	"models/props_interiors/Furniture_shelf01a.mdl",
	"models/props_interiors/Furniture_Vanity01a.mdl",
	"models/props_interiors/SinkKitchen01a.mdl",
	"models/props_junk/plasticbucket001a.mdl",
	"models/props_junk/CinderBlock01a.mdl",
	"models/props_c17/chair_stool01a.mdl",
	"models/props_c17/chair_office01a.mdl",
	"models/props_c17/clock01.mdl",
	"models/props_c17/computer01_keyboard.mdl",
	"models/props_c17/BriefCase001a.mdl",
	"models/props_c17/metalPot001a.mdl",
	"models/props_c17/FurnitureSink001a.mdl",
	"models/props_c17/SuitCase001a.mdl",
	"models/props_c17/tv_monitor01.mdl",
	"models/props_c17/SuitCase_Passenger_Physics.mdl",
	"models/props_combine/breenglobe.mdl",
	"models/props_interiors/BathTub01a.mdl",
	"models/props_lab/partsbin01.mdl",
	"models/props_lab/cactus.mdl",
	"models/props_junk/MetalBucket01a.mdl",
	"models/props_junk/MetalBucket02a.mdl"
};

-- A function to load the banned props.
function cwAllowedProps:LoadAllowedProps()
	self.allowedProps = Clockwork.kernel:RestoreSchemaData("allowedprops");
	
	if (#self.allowedProps == 0) then
		self.allowedProps = self.defaultAllowedProps;
		
		self:SaveAllowedProps();
	end;
end;

-- A function to save the banned props.
function cwAllowedProps:SaveAllowedProps()
	local allowedProps = {};
	
	for k, v in pairs(self.allowedProps) do
		allowedProps[#allowedProps + 1] = v;
	end;
	
	Clockwork.kernel:SaveSchemaData("allowedprops", allowedProps);
end;