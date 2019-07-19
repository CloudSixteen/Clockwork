--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyVoiceBan");

COMMAND.tip = "CmdPlyVoiceBan";
COMMAND.text = "CmdPlyVoiceBanDesc";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	
	if (IsValid(target)) then
		if (!target:GetData("VoiceBan")) then
			target:SetData("VoiceBan", true);
		else
			Clockwork.player:Notify(player, {"PlayerAlreadyBannedFromVoice", target:Name()});
		end;
	end;
end;

COMMAND:Register();