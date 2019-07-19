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
PLUGIN:SetGlobalAlias("cwEmoteAnims");

--[[ You don't have to do this either, but I prefer to separate the functions. --]]
Clockwork.kernel:IncludePrefixed("sv_plugin.lua");
Clockwork.kernel:IncludePrefixed("cl_hooks.lua");
Clockwork.kernel:IncludePrefixed("sv_hooks.lua");

-- Called when the Clockwork shared variables are added.
function cwEmoteAnims:ClockworkAddSharedVars(globalVars, playerVars)
	playerVars:Bool("StanceIdle", true);
	playerVars:Angle("StanceAng");
	playerVars:Vector("StancePos");
end;

-- A function to get whether a player is in a stance.
function cwEmoteAnims:IsPlayerInStance(player)
	return player:GetSharedVar("StancePos") != Vector(0, 0, 0);
end;

-- Called when a player starts to move.
function cwEmoteAnims:Move(player, moveData)
	if (self:IsPlayerInStance(player)) then
		player:SetAngles(player:GetSharedVar("StanceAng"));
		return true;
	end;
end;

cwEmoteAnims.stanceList = {
	["d1_t03_tenements_look_out_window_idle"] = true,
	["d2_coast03_postbattle_idle02_entry"] = true,
	["d2_coast03_postbattle_idle01_entry"] = true,
	["d2_coast03_postbattle_idle02"] = true,
	["d2_coast03_postbattle_idle01"] = true,
	["d1_t03_lookoutwindow"] = true,
	["idle_to_sit_ground"] = true,
	["sit_ground_to_idle"] = true,
	["spreadwallidle"] = true,
	["apcarrestidle"] = true,
	["plazathreat2"] = true,
	["plazathreat1"] = true,
	["sit_ground"] = true,
	["lineidle04"] = true,
	["lineidle02"] = true,
	["lineidle01"] = true,
	["plazaidle4"] = true,
	["plazaidle2"] = true,
	["plazaidle1"] = true,
	["spreadwall"] = true,
	["wave_close"] = true,
	["idle_baton"] = true,
	["wave_smg1"] = true,
	["lean_back"] = true,
	["cheer1"] = true,
	["wave"] = true
};