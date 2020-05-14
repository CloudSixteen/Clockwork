--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("DoorSetHidden");

COMMAND.tip = "Set whether a door is hidden.";
COMMAND.text = "<bool IsHidden>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		if (Clockwork.kernel:ToBool(arguments[1])) then
			local data = {
				position = door:GetPos(),
				entity = door
			};				
		
			Clockwork.entity:SetDoorHidden(door, true);
			
			cwDoorCmds.doorData[data.entity] = {
				position = door:GetPos(),
				entity = door,
				text = "hidden",
				name = "hidden"
			};
			
			cwDoorCmds:SaveDoorData();
			
			Clockwork.player:Notify(player, {"YouMadeDoorHidden"});
		else
			Clockwork.entity:SetDoorHidden(door, false);
			
			cwDoorCmds.doorData[door] = nil;
			cwDoorCmds:SaveDoorData();
			
			Clockwork.player:Notify(player, {"YouMadeDoorUnhidden"});
		end;
	else
		Clockwork.player:Notify(player, {"ThisIsNotAValidDoor"});
	end;
end;

COMMAND:Register();