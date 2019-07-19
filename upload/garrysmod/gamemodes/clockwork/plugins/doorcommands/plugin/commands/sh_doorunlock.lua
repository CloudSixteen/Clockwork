--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("DoorUnlock");

COMMAND.tip = "Unlock a door.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		door:EmitSound("doors/door_latch3.wav");
		door:Fire("Unlock", "", 0);

		Clockwork.player:Notify(player, {"YouUnlockedDoor"});
	else
		Clockwork.player:Notify(player, {"ThisIsNotAValidDoor"});
	end;
end;

COMMAND:Register();