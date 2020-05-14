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
PLUGIN:SetGlobalAlias("cwDisplayTyping");

--[[ You don't have to do this either, but I prefer to separate the functions. --]]
Clockwork.kernel:IncludePrefixed("cl_hooks.lua");
Clockwork.kernel:IncludePrefixed("sv_plugin.lua");
Clockwork.kernel:IncludePrefixed("sv_hooks.lua");
Clockwork.kernel:IncludePrefixed("sh_enum.lua");

--[[
	A dictionary of commands and typing codes.
	The command a player is typing corresponds
	to a specific phrase code.
--]]
cwDisplayTyping.typingCodes = {
	["radio"] = "r",
	["me"] = "p",
	["pm"] = "o",
	["w"] = "w",
	["y"] = "y",
	["//"] = "o",
	[".//"] = "o"
};

-- Called when the Clockwork shared variables are added.
function cwDisplayTyping:ClockworkAddSharedVars(globalVars, playerVars)
	playerVars:Number("Typing");
end;