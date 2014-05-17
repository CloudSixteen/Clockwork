--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
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
		Clockwork.player:Notify(player, "You have set the active parent door to this.");
		player.cwParentDoor = door;
	else
		Clockwork.player:Notify(player, "This is not a valid door!");
	end;
end;

COMMAND:Register();