--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("DoorResetParent");
COMMAND.tip = "Reset the player's active parent door.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	cwDoorCmds.infoTable = cwDoorCmds.infoTable or {};

	if (IsValid(player.cwParentDoor)) then
		player.cwParentDoor = nil;
		cwDoorCmds.infoTable = {};

		Clockwork.player:Notify(player, "You have cleared your active parent door.");
		Clockwork.datastream:Start(player, "doorParentESP", cwDoorCmds.infoTable);
	else
		Clockwork.player:Notify(player, "You do not have an active parent door.");
	end;
end;

COMMAND:Register();