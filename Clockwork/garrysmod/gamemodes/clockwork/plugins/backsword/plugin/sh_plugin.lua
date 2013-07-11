--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

--[[
	You don't have to do this, but I think it's nicer.
	Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias("cwBacksword");

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
Clockwork.kernel:IncludePrefixed("cl_plugin.lua");
Clockwork.kernel:IncludePrefixed("sv_plugin.lua");

-- A function to add a Backsword weapon.
function cwBacksword:AddWeapon(className)
	cwBacksword.weapons = cwBacksword.weapons or {};
	cwBacksword.weapons[#cwBacksword.weapons + 1] = className;
end;