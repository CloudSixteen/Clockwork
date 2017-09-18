--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("Y");

COMMAND.tip = "CmdY";
COMMAND.text = "CmdYDesc";
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_DEATHCODE);

COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	if (text == "") then
		Clockwork.player:Notify(player, {"NotEnoughText"});
		
		return;
	end;
	
	Clockwork.chatBox:SetMultiplier(1.25);
	Clockwork.chatBox:AddInRadius(player, "yell", text, player:GetPos(), Clockwork.config:Get("talk_radius"):Get() * 2);
end;

COMMAND:Register();