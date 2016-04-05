--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyTeleportTo");
COMMAND.tip = "Teleport a player to another player.";
COMMAND.text = "<string Target> <string Name> <bool isSilent>";
COMMAND.access = "o";
COMMAND.arguments = 2;
COMMAND.optionalArguments = 1;
COMMAND.alias = {"PlyTPTo"};

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local ply = Clockwork.player:FindByID(arguments[2]);
	local isSilent = Clockwork.kernel:ToBool(arguments[3]);

	if (target) then
		if (ply) then
			Clockwork.player:SetSafePosition(target, ply:GetPos());

			if (!isSilent) then
				Clockwork.player:NotifyAll(player:Name().." has teleported "..target:Name().." to "..ply:Name()..".");
			end;
		else
			Clockwork.player:Notify(player, arguments[2].." is not a valid player!");
		end;
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

COMMAND:Register();