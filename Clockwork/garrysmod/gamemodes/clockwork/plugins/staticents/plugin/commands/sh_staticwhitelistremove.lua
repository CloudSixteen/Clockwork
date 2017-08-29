--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("StaticWhitelistRemove");

COMMAND.tip = "Remove a class of entity from the static whitelist.";
COMMAND.text = "<string Class>";
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.alias = {"SWRemove"};

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)	
	if (table.HasValue(cwStaticEnts.whitelist, arguments[1])) then
		table.RemoveByValue(cwStaticEnts.whitelist, arguments[1]);
		Clockwork.kernel:SaveSchemaData("maps/"..game.GetMap().."/static_entities/whitelist", cwStaticEnts.whitelist);

		Clockwork.player:Notify(player, {"StaticWhitelistRemoved", arguments[1]});
	else
		Clockwork.player:Notify(player, {"StaticNotWhitelisted", arguments[1]});
	end;	
end;

COMMAND:Register();