--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("Observer");

COMMAND.tip = "Enter or exit observer mode.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:Alive() and !player:IsRagdolled() and !player.cwObserverReset) then
		if (player:GetMoveType(player) == MOVETYPE_NOCLIP) then
			cwObserverMode:MakePlayerExitObserverMode(player);
		else
			cwObserverMode:MakePlayerEnterObserverMode(player);
		end;
	end;
end;

COMMAND:Register();