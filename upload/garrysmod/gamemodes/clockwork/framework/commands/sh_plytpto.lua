--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyTeleportTo");

COMMAND.tip = "CmdPlyTeleportTo";
COMMAND.text = "CmdPlyTeleportToDesc";
COMMAND.access = "o";
COMMAND.arguments = 2;
COMMAND.optionalArguments = 1;
COMMAND.alias = {"PlyTPTo"};

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local other = Clockwork.player:FindByID(arguments[2]);
	local isSilent = Clockwork.kernel:ToBool(arguments[3]);

	if (target) then
		if (other) then
			Clockwork.player:SetSafePosition(target, other:GetPos());

			if (!isSilent) then
				Clockwork.player:NotifyAll({"PlayerTeleportedPlayerTo", player:Name(), target:Name(), other:Name()});
			end;
		else
			Clockwork.player:Notify(player, {"NotValidPlayer", arguments[2]});
		end;
	else
		Clockwork.player:Notify(player, {"NotValidPlayer", arguments[1]});
	end;
end;

COMMAND:Register();