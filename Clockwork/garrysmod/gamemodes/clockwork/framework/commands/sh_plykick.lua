--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyKick");
COMMAND.tip = "Kick a player from the server.";
COMMAND.text = "<string Name> <string Reason>";
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
			Clockwork.player:NotifyAll(player:Name().." has kicked '"..target:Name().."' ("..reason..").");
				target:Kick(reason);
			target.kicked = true;
		else
			Clockwork.player:Notify(player, target:Name().." is protected!");
		end;
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

COMMAND:Register();