--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("SetVoicemail");

COMMAND.tip = "CmdSetVoicemail";
COMMAND.text = "CmdSetVoicemailDesc";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (arguments[1] == "none") then
		player:SetCharacterData("Voicemail", nil);
		Clockwork.player:Notify(player, {"YouRemovedVoicemail"});
	else
		player:SetCharacterData("Voicemail", arguments[1]);
		Clockwork.player:Notify(player, {"YouSetVoicemail", arguments[1]});
	end;
end;

COMMAND:Register();