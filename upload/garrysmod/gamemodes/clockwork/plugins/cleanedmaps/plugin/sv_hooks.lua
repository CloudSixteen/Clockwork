--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when Clockwork has loaded all of the entities.
function cwCleanedMaps:ClockworkInitPostEntity()
	if (Clockwork.config:Get("remove_map_physics"):Get()) then
		for k, v in pairs(ents.FindByClass("prop_vehicle*")) do
			v:Remove();
		end;
	end;
end;

-- Called when the map has loaded all the entities.
function cwCleanedMaps:InitPostEntity()
	local gunButtons = {"gundoor", "smgbutton", "shotgunbutton", "pistbutton", "gunstore"};
	local position = Vector(-1836.6316, 244.3225, 724.9510);
	
	if (Clockwork.config:Get("remove_map_physics"):Get()) then
		for k, v in pairs(Clockwork.kernel:GetPhysicsEntities()) do
			v:Remove();
		end;
	end;
	
	if (string.lower(game.GetMap()) == "rp_tb_city45_v02n") then
		for k, v in pairs(ents.FindInSphere(Vector(226.2188, 4550, 238.0313), 32)) do
			if (Clockwork.entity:IsDoor(v)) then
				v:Remove(); break;
			end;
		end;
		
		for k, v in pairs(ents.FindInSphere(Vector(2773, 1409, 239), 1024)) do
			if (string.find(tostring(v), "func_movelinear")) then
				v:Remove();
			end;
		end;
		
		for k, v in pairs(ents.FindInSphere(Vector(3589.3997, -6775.1030, 155.1662), 1024)) do
			if (string.find(tostring(v), "func_button")) then
				v:Remove();
			end;
		end;
	end;
	
	if (string.lower(game.GetMap()) == "md_venetianredux_b2") then
		for k, v in pairs(ents.FindByClass("trigger_hurt")) do
			v:Remove();
		end;
		
		for k, v in pairs(ents.FindByClass("point_servercommand")) do
			v:Remove();
		end;
		
		for k, v in pairs(ents.FindByClass("lua_run")) do
			v:Remove();
		end;
	end;
	
	for k, v in pairs(ents.FindByClass("func_button")) do
		for k2, v2 in pairs(gunButtons) do
			if (string.find(string.lower(v:GetName()), v2)) then
				v:Remove();
			end;
		end;
	end;
	
	for k, v in pairs(self.entityList) do
		for k2, v2 in pairs(ents.FindByClass(v)) do
			v2:Remove();
		end;
	end;
	
	for k, v in pairs(ents.FindInSphere(position, 512)) do
		if (v:GetModel() == "models/props_interiors/vendingmachinesoda01a.mdl") then
			v:Remove();
		end;
	end;
	
	timer.Simple(1, function()
		local specialDoor = ents.FindByName("JailFl1SCP");
		local coreTwo = ents.FindByName("core_refract2");
		local coreTwo = ents.FindByName("core_refract2");
		
		if (coreOne and IsValid(coreOne[1])) then coreOne[1]:Remove(); end;
		if (coreTwo and IsValid(coreTwo[1])) then coreTwo[1]:Remove(); end;
		
		if (specialDoor and IsValid(specialDoor[1])) then
			specialDoor[1]:Remove();
		end;
	end);
	
	if (string.lower(game.GetMap()) == "rp_evocity_v2d") then
		local barricades = {
			{ angles = Angle(-0.482, -8.456, -93.239), position = Vector(-6378.7979, -7698.8604, 224.9174) },
			{ angles = Angle(-1.011, 1.972, -91.502), position = Vector(-6382.2466, -7669.2017, 252.3531) },
			{ angles = Angle(0, 0, -90), position = Vector(-6407.5703, -7513.1294, 165.1916) }
		};
		
		local entities = {
			ents.Create("prop_physics"),
			ents.Create("prop_physics"),
			ents.Create("prop_physics")
		};
		
		for k, v in pairs(entities) do
			v:SetModel("models/props_buildings/building_002a.mdl");
			
			if (k == 3) then
				v:SetPos(Vector(3746.9451, 12137.5527, 847.3724));
				v:SetAngles(Angle(-0.042, -177.904, 0.374));
			elseif (k == 2) then
				v:SetPos(Vector(3733.2605, 13399.5029, 847.9582));
				v:SetAngles(Angle(-0.042, 177.916, 0.374));
			elseif (k == 1) then
				v:SetPos(Vector(3799.7908, 14593.2178, 800.7903));
				v:SetAngles(Angle(-0.042, 179.016, 0.374));
			end;
		end;
		
		for k, v in pairs(entities) do
			v:Spawn(); Clockwork.entity:MakeSafe(v, true, true, true);
		end;
	end;
end;