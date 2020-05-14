--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("Announce");

COMMAND.tip = "CmdAnnounce";
COMMAND.text = "CmdAnnounceDesc";
COMMAND.arguments = 1;
COMMAND.access = "o";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	if (text ~= "") then
		Clockwork.player:NotifyAll(text);
	end;
end;

COMMAND:Register();