--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("PlySlay");

COMMAND.tip = "CmdPlySlay";
COMMAND.text = "CmdPlySlayDesc";
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_FALLENOVER);

COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;
COMMAND.access = "o";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local isSilent = Clockwork.kernel:ToBool(arguments[2]);

	if (target) then
		target:Kill();

		if (!isSilent) then
			Clockwork.player:NotifyAll({"PlayerSlainBy", target:Name(), player:Name()});
		end;
	else
		Clockwork.player:Notify(player, {"NotValidTarget", arguments[1]});
	end;
end;

COMMAND:Register();
