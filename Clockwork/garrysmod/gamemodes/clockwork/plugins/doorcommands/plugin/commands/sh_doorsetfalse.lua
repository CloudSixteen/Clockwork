--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("DoorSetFalse");
COMMAND.tip = "Set whether a door is false.";
COMMAND.text = "<bool IsFalse>";
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
		
			Clockwork.entity:SetDoorFalse(door, true);
			
			cwDoorCmds.doorData[data.entity] = {
				position = door:GetPos(),
				entity = door,
				text = "hidden",
				name = "hidden"
			};
			
			cwDoorCmds:SaveDoorData();
			
			Clockwork.player:Notify(player, "You have made this door false.");
		else
			Clockwork.entity:SetDoorFalse(door, false);
			
			cwDoorCmds.doorData[door] = nil;
			cwDoorCmds:SaveDoorData();
			
			Clockwork.player:Notify(player, "You have no longer made this door false.");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid door!");
	end;
end;

COMMAND:Register();