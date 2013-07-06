--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("SetVoicemail");
COMMAND.tip = "Set your personal message voicemail.";
COMMAND.text = "[string Text]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (arguments[1] == "none") then
		player:SetCharacterData("Voicemail", nil);
		Clockwork.player:Notify(player, "You have removed your voicemail.");
	else
		player:SetCharacterData("Voicemail", arguments[1]);
		Clockwork.player:Notify(player, "You have set your voicemail to '"..arguments[1].."'.");
	end;
end;

COMMAND:Register();