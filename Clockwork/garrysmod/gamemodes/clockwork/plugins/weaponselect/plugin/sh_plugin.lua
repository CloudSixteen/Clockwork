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
PLUGIN:SetGlobalAlias("cwWeaponSelect");

--[[ You don't have to do this either, but I prefer to separate the functions. --]]
Clockwork.kernel:IncludePrefixed("cl_plugin.lua");
Clockwork.kernel:IncludePrefixed("sv_plugin.lua");
Clockwork.kernel:IncludePrefixed("cl_hooks.lua");

Clockwork.config:ShareKey("weapon_selection_multi");

if (CLIENT) then
	cwWeaponSelect.displaySlot = 0;
	cwWeaponSelect.displayFade = 0;
	cwWeaponSelect.displayAlpha = 0;
	cwWeaponSelect.displayDelay = 0;
	cwWeaponSelect.weaponPrintNames = {};
end;