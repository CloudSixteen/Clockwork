--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyUnban");
COMMAND.tip = "Unban a Steam ID from the server.";
COMMAND.text = "<string SteamID|IPAddress>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playersTable = Clockwork.config:Get("mysql_players_table"):Get();
	local schemaFolder = Clockwork.kernel:GetSchemaFolder();
	local identifier = string.upper(arguments[1]);
	
	if (Clockwork.bans.stored[identifier]) then
		Clockwork.player:NotifyAll(player:Name().." has unbanned '"..Clockwork.bans.stored[identifier].steamName.."'.");
		Clockwork.bans:Remove(identifier);
	else
		Clockwork.player:Notify(player, "There are no banned players with the '"..identifier.."' identifier!");
	end;
end;

COMMAND:Register();