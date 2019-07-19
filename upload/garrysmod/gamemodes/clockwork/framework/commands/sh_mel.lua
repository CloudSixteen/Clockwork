--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("MeL");

COMMAND.tip = "CmdMeL";
COMMAND.text = "CmdMeLDesc";
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_DEATHCODE);

COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	if (text == "") then
		Clockwork.player:Notify(player, {"NotEnoughText"});
		return;
	end;

	Clockwork.chatBox:AddInTargetRadius(player, "mel", string.gsub(text, "^.", string.lower), player:GetPos(), Clockwork.config:Get("talk_radius"):Get() * 4);
end;

COMMAND:Register();