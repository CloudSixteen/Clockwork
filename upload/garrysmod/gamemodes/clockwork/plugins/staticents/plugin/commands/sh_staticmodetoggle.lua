--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("StaticModeToggle");

COMMAND.tip = "Toggle static mode, where ALL player spawned entities will be checked through the whitelist and staticed on spawn.";
COMMAND.access = "a";
COMMAND.alias = {"SMToggle"};

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)	
	cwStaticEnts.staticMode[1] = !cwStaticEnts.staticMode[1];

	Clockwork.kernel:SaveSchemaData("maps/"..game.GetMap().."/static_entities/static_mode", cwStaticEnts.staticMode);

	Clockwork.player:Notify(player, {"ToggledStaticModeTo", tostring(cwStaticEnts.staticMode[1])});
end;

COMMAND:Register();