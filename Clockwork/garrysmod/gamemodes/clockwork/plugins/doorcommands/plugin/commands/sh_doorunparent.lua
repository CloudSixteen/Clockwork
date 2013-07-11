--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("DoorUnparent");
COMMAND.tip = "Unparent the target door.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		cwDoorCmds.parentData[door] = nil;
		cwDoorCmds:SaveParentData();
		
		Clockwork.entity:SetDoorParent(door, false);
		
		Clockwork.player:Notify(player, "You have unparented this door.");
	else
		Clockwork.player:Notify(player, "This is not a valid door!");
	end;
end;

COMMAND:Register();