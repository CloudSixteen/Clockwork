--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("DoorSetChild");
COMMAND.tip = "Add a child to the active parent door.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		if (IsValid(player.cwParentDoor)) then
			cwDoorCmds.parentData[door] = player.cwParentDoor;
			cwDoorCmds:SaveParentData();
			
			Clockwork.entity:SetDoorParent(door, player.cwParentDoor);
			Clockwork.player:Notify(player, "You have added this as a child to the active parent door.");
		else
			Clockwork.player:Notify(player, "You have not selected a valid parent door!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid door!");
	end;
end;

COMMAND:Register();