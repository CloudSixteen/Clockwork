--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("PlyRespawnTP");

COMMAND.tip = "CmdPlyRespawnTP";
COMMAND.text = "CmdPlyRespawnTPDesc";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;
COMMAND.access = "o";
COMMAND.alias = {"PlyRTP"};

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local isSilent = Clockwork.kernel:ToBool(arguments[2]);
	local trace = player:GetEyeTraceNoCursor();
	
	if (target) then
		Clockwork.player:LightSpawn(target, true, true, true);
		Clockwork.player:SetSafePosition(target, trace.HitPos);
		Clockwork.player:Notify(player, {"PlayerWasRespawnedToTarget", target:GetName()});
	else
		Clockwork.player:Notify(player, {"NotValidTarget", arguments[1]});
	end;
end;

COMMAND:Register();