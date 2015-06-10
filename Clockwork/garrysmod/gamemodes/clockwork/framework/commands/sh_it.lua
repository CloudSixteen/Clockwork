--[[
	� 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("It");
COMMAND.tip = "Describe a local action or event.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	if (string.len(text) < 8) then
		Clockwork.player:Notify(player, "You did not specify enough text!");
		
		return;
	end;
	
	player:SetCharacterData("Test", "CHANGED");

	Clockwork.chatBox:AddInTargetRadius(player, "it", text, player:GetPos(), Clockwork.config:Get("talk_radius"):Get() * 2);
end;

COMMAND:Register();