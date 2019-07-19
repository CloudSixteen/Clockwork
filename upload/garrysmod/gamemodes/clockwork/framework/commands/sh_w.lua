--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("W");

COMMAND.tip = "CmdW";
COMMAND.text = "CmdWDesc";
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_DEATHCODE);

COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local talkRadius = math.min(Clockwork.config:Get("talk_radius"):Get() / 3, 80);
	local text = table.concat(arguments, " ");
	
	if (text == "") then
		Clockwork.player:Notify(player, {"NotEnoughText"});
		
		return;
	end;
	
	Clockwork.chatBox:SetMultiplier(0.75);
	Clockwork.chatBox:AddInRadius(player, "whisper", text, player:GetPos(), talkRadius);
end;

COMMAND:Register();