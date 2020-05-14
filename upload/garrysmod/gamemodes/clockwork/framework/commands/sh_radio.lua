--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("Radio");

COMMAND.tip = "CmdRadio";
COMMAND.text = "CmdRadioDesc";
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_DEATHCODE, CMD_FALLENOVER);

COMMAND.arguments = 1;
COMMAND.alias = {"R"};

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	Clockwork.player:SayRadio(player, table.concat(arguments, " "), true);
end;

COMMAND:Register();