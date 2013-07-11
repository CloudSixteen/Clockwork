--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("W");
COMMAND.tip = "Whisper to characters near you.";
COMMAND.text = "<string Text>";
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_DEATHCODE);
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local talkRadius = math.min(Clockwork.config:Get("talk_radius"):Get() / 3, 80);
	local text = table.concat(arguments, " ");
	
	if (text == "") then
		Clockwork.player:Notify(player, "You did not specify enough text!");
		
		return;
	end;
	
	Clockwork.chatBox:AddInRadius(player, "whisper", text, player:GetPos(), talkRadius);
end;

COMMAND:Register();