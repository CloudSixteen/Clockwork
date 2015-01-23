--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

--[[
	You don't have to do this, but I think it's nicer.
	Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias("cwStaticEnts");

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
Clockwork.kernel:IncludePrefixed("cl_plugin.lua");
Clockwork.kernel:IncludePrefixed("sv_plugin.lua");
Clockwork.kernel:IncludePrefixed("sv_hooks.lua");

-- A function to check if an entity can be static.
function cwStaticEnts:CanStatic(entity)
	if (entity:IsValid()) then
		local class = entity:GetClass();
		
		if (class == "prop_vehicle_airboat" or class == "prop_vehicle_jeep" or class == "Jeep" or class == "Airboat") then
			return "nope";
		end;
		
		return class;
	end;
	
	return false;
end;