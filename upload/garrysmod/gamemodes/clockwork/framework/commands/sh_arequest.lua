--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("ARequest");

COMMAND.tip = "CmdARequest";
COMMAND.text = "CmdARequestDesc";
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (!Clockwork.player:IsAdmin(player)) then
		Clockwork.player:NotifyAdmins("o", {"RequestFromMsg", player:Name(), table.concat(arguments, " ")});
	else
		Clockwork.player:Notify(player, {"RequestAdminRedirect"});
	end;
end;

COMMAND:Register();
