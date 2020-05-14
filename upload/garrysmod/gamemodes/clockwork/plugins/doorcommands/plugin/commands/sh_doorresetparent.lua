--[[
	© CloudSixteen.com do not share, re-distribute or modify
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

		Clockwork.player:Notify(player, {"DoorParentReset"});
		Clockwork.datastream:Start(player, "doorParentESP", cwDoorCmds.infoTable);
	else
		Clockwork.player:Notify(player, {"NotSelectedValidParentDoor"});
	end;
end;

COMMAND:Register();