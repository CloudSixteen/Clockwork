--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyVoiceUnban");
COMMAND.tip = "Ban a player from the server.";
COMMAND.text = "<string Name|SteamID|IPAddress>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	
	if (IsValid(target)) then
		if (target:GetData("VoiceBan")) then
			target:SetData("VoiceBan", false);
		else
			Clockwork.player:Notify(player, target:Name().." is not banned from using voice!");
		end;
	end;
end;

COMMAND:Register();