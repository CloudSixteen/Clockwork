--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("EventLocal");

COMMAND.tip = "Send an event to characters around you.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	Clockwork.chatBox:AddInRadius(player, "localevent",  table.concat(arguments, " "), player:GetPos(), Clockwork.config:Get("talk_radius"):Get() * 4);
end;

COMMAND:Register();