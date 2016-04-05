--[[
  © 2015 CloudSixteen.com do not share, re-distribute or modify
  without permission of its author (kurozael@gmail.com).

  Clockwork was created by Conna Wiles (also known as kurozael.)
  http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyBring");

COMMAND.tip = "Bring a player to your crosshair position.";
COMMAND.text = "<string Target> <bool isSilent>";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;
COMMAND.access = "o";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local trace = player:GetEyeTraceNoCursor();
	local isSilent = Clockwork.kernel:ToBool(arguments[2]);

	if (target) then
		Clockwork.player:SetSafePosition(target, trace.HitPos);

		if (!isSilent) then
			Clockwork.player:NotifyAll(player:Name().." has brought "..target:Name().." to their target location.");
		end;
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

COMMAND:Register();