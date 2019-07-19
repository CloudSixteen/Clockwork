--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyTeleport");

COMMAND.tip = "CmdPlyTeleport";
COMMAND.text = "CmdPlyTeleportDesc";
COMMAND.access = "o";
COMMAND.arguments = 1;
COMMAND.alias = {"PlyTP"};

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);

	if (target) then
		Clockwork.player:SetSafePosition(target, player:GetEyeTraceNoCursor().HitPos);
		Clockwork.player:NotifyAll({"PlayerTeleportedPlayerToLocation", player:Name(), target:Name()});
	else
		Clockwork.player:Notify(player, {"NotValidPlayer", arguments[1]});
	end;
end;

COMMAND:Register();
