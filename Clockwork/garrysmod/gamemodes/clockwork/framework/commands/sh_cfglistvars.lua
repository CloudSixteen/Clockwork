--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CfgListVars");
COMMAND.tip = "List the Clockwork config variables.";
COMMAND.text = "[string Find]";
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local searchData = arguments[1] or "";
		Clockwork.datastream:Start(player, "CfgListVars", searchData);
	Clockwork.player:Notify(player, "The config variables have been printed to the console.");
end;

COMMAND:Register();