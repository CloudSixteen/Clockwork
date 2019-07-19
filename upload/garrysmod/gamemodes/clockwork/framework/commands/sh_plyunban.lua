--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyUnban");

COMMAND.tip = "CmdPlyUnban";
COMMAND.text = "CmdPlyUnbanDesc";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playersTable = Clockwork.config:Get("mysql_players_table"):Get();
	local schemaFolder = Clockwork.kernel:GetSchemaFolder();
	local identifier = string.upper(arguments[1]);
	
	if (Clockwork.bans.stored[identifier]) then
		Clockwork.player:NotifyAll({"PlayerUnbannedPlayer", player:Name(), Clockwork.bans.stored[identifier].steamName});
		Clockwork.bans:Remove(identifier);
	else
		Clockwork.player:Notify(player, {"ThereAreNoBannedPlayersWithID", identifier});
	end;
end;

COMMAND:Register();