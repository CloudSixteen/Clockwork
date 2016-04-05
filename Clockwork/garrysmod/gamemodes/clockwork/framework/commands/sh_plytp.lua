--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyTeleport");
COMMAND.tip = "Teleport a player to your target location.";
COMMAND.text = "<string Name>";
COMMAND.access = "o";
COMMAND.arguments = 1;
COMMAND.alias = {"PlyTP"};

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);

	if (target) then
		Clockwork.player:SetSafePosition(target, player:GetEyeTraceNoCursor().HitPos);
		Clockwork.player:NotifyAll(player:Name().." has teleported "..target:Name().." to their target location.");
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

COMMAND:Register();
