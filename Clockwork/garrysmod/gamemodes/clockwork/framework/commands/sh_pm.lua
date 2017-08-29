--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PM");

COMMAND.tip = "Send a private message to a player.";
COMMAND.text = "<string Name> <string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1])
	
	if (target) then
		local voicemail = target:GetCharacterData("Voicemail");
		
		if (voicemail and voicemail != "") then
			Clockwork.chatBox:Add(player, target, "pm", voicemail);
		else
			Clockwork.chatBox:Add({player, target}, player, "pm", table.concat(arguments, " ", 2));
		end;
	else
		Clockwork.player:Notify(player, {"NotValidPlayer", arguments[1]});
	end;
end;

COMMAND:Register();