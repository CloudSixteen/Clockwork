--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("DoorSetParent");

COMMAND.tip = "Set the active parent door to your target.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		cwDoorCmds.infoTable = cwDoorCmds.infoTable or {};
		
		player.cwParentDoor = door;
		cwDoorCmds.infoTable.Parent = door;

		for k, parent in pairs(cwDoorCmds.parentData) do
			if (parent == door) then
				table.insert(cwDoorCmds.infoTable, k);
			end;
		end;

		Clockwork.player:Notify(player, {"YouSetActiveParentDoor"});

		if (cwDoorCmds.infoTable != {}) then
			Clockwork.datastream:Start(player, "doorParentESP", cwDoorCmds.infoTable);
		end;
	else
		Clockwork.player:Notify(player, {"ThisIsNotAValidDoor"});
	end;
end;

COMMAND:Register();