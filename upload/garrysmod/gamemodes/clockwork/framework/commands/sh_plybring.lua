--[[
  © CloudSixteen.com do not share, re-distribute or modify
  without permission of its author (kurozael@gmail.com).

  Clockwork was created by Conna Wiles (also known as kurozael.)
  http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyBring");

COMMAND.tip = "CmdPlyBring";
COMMAND.text = "CmdPlyBringDesc";
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
			Clockwork.player:NotifyAll({"PlayerBroughtPlayerTo", player:Name(), target:Name()});
		end;
	else
		Clockwork.player:Notify(player, {"NotValidPlayer", arguments[1]});
	end;
end;

COMMAND:Register();