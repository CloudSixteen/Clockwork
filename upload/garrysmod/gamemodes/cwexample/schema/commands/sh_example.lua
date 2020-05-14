--[[
	This project is created with the Clockwork framework by Cloud Sixteen.
	http://cloudsixteen.com
--]]

local COMMAND = Clockwork.command:New("Example");

COMMAND.tip = "An example command.";
COMMAND.text = "<string Text>";
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_FALLENOVER);
COMMAND.arguments = 1;

-- Called when the command is ran from the server console.
function COMMAND:OnConsoleRun(arguments)
	Clockwork.player:NotifyAll(table.concat(arguments, " "));
end;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	Clockwork.player:NotifyAll(table.concat(arguments, " "));
end;

COMMAND:Register();