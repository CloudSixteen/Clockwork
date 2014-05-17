--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("Roll");
COMMAND.tip = "Roll a number between 0 and the specified number.";
COMMAND.text = "[number Range]";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local number = math.Clamp(tonumber(arguments[1]) or 100, 0, 1000000000);
	
	Clockwork.chatBox:AddInRadius(player, "roll", "has rolled "..math.random(0, number).." out of "..number..".",
		player:GetPos(), Clockwork.config:Get("talk_radius"):Get());
end;

COMMAND:Register();