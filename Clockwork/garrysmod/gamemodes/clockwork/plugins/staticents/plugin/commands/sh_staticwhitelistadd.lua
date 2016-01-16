--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("StaticWhitelistAdd");
COMMAND.tip = "Add a class of entity to the static whitelist so it can be staticed.";
COMMAND.text = "<string Class>";
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.alias = {"SWAdd"};

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)	
	if (!table.HasValue(cwStaticEnts.whitelist, arguments[1])) then
		table.insert(cwStaticEnts.whitelist, arguments[1]);
		Clockwork.kernel:SaveSchemaData("maps/"..game.GetMap().."/static_entities/whitelist", cwStaticEnts.whitelist);

		Clockwork.player:Notify(player, "You have added "..arguments[1].." to the list of entities that can be staticed.");
	else
		Clockwork.player:Notify(player, arguments[1].." is already in the static whitelist!");
	end;	
end;

COMMAND:Register();