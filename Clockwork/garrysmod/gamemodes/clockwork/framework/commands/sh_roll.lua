--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("Roll");
COMMAND.tip = "Roll a number between 0 and 100.";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	Clockwork.chatBox:AddInRadius(player, "roll", "has rolled "..math.random(0, 100).." out of 100.", player:GetPos(), Clockwork.config:Get("talk_radius"):Get());
end;

COMMAND:Register();