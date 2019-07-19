--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyKick");

COMMAND.tip = "CmdPlyKick";
COMMAND.text = "CmdPlyKickDesc";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local reason = table.concat(arguments, " ", 2);
	
	if (!reason or reason == "") then
		reason = "N/A";
	end;
	
	if (target) then
		if (!Clockwork.player:IsProtected(arguments[1])) then
			Clockwork.player:NotifyAll({"PlayerKickedPlayer", player:Name(), target:Name(), reason});
				target:Kick(reason);
			target.kicked = true;
		else
			Clockwork.player:Notify(player, {"PlayerHasProtectionStatus", target:Name()});
		end;
	else
		Clockwork.player:Notify(player, {"NotValidPlayer", arguments[1]});
	end;
end;

COMMAND:Register();