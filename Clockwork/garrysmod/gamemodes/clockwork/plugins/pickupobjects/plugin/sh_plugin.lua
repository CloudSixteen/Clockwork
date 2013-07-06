--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

--[[
	You don't have to do this, but I think it's nicer.
	Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias("cwPickupObjects");

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
Clockwork.kernel:IncludePrefixed("cl_plugin.lua");
Clockwork.kernel:IncludePrefixed("sv_plugin.lua");
Clockwork.kernel:IncludePrefixed("sv_hooks.lua");
Clockwork.kernel:IncludePrefixed("cl_hooks.lua");

-- Called when the Clockwork shared variables are added.
function cwPickupObjects:ClockworkAddSharedVars(globalVars, playerVars)
	playerVars:Bool("IsDragged", true);
end;