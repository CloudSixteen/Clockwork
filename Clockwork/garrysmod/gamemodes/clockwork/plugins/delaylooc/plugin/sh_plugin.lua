--[[
© 2013 CloudSixteen.com do not share, re-distribute or modify
without permission of its author (kurozael@gmail.com).

Clockwork was created by Conna Wiles (also known as kurozael.)
https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

--[[
You don't have to do this, but I think it's nicer.
Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias("cwDelayLOOC");

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
Clockwork.kernel:IncludePrefixed("sv_hooks.lua");

if (SERVER) then
	Clockwork.config:Add("looc_interval", 1);
else
	Clockwork.config:AddToSystem("Local out-of-character interval", "looc_interval", "The time that a player has to wait to locally speak out-of-character again (seconds).\nSet to 0 for never.", 0, 7200);
end;