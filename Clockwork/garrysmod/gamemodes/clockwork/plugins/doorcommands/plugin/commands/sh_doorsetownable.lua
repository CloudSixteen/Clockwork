--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("DoorSetOwnable");
COMMAND.tip = "Set an ownable door.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		local data = {
			customName = true,
			position = door:GetPos(),
			entity = door,
			name = table.concat(arguments or {}, " ") or ""
		};
		
		Clockwork.entity:SetDoorUnownable(data.entity, false);
		Clockwork.entity:SetDoorText(data.entity, false);
		Clockwork.entity:SetDoorName(data.entity, data.name);
		
		cwDoorCmds.doorData[data.entity] = data;
		cwDoorCmds:SaveDoorData();
		
		Clockwork.player:Notify(player, "You have set an ownable door.");
	else
		Clockwork.player:Notify(player, "This is not a valid door!");
	end;
end;

COMMAND:Register();