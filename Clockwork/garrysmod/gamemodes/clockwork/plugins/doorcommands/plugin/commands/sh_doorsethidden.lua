--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
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
			
			Clockwork.player:Notify(player, "You have hidden this door.");
		else
			Clockwork.entity:SetDoorHidden(door, false);
			
			cwDoorCmds.doorData[door] = nil;
			cwDoorCmds:SaveDoorData();
			
			Clockwork.player:Notify(player, "You have unhidden this door.");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid door!");
	end;
end;

COMMAND:Register();