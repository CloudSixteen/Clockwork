--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("DoorSetUnownable");

COMMAND.tip = "Set an unownable door.";
COMMAND.text = "<string Name> [string Text]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.optionalArguments = true;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		local data = {
			position = door:GetPos(),
			entity = door,
			text = arguments[2],
			name = arguments[1]
		};
		
		Clockwork.entity:SetDoorName(data.entity, data.name);
		Clockwork.entity:SetDoorText(data.entity, data.text);
		Clockwork.entity:SetDoorUnownable(data.entity, true);
		
		cwDoorCmds.doorData[data.entity] = data;
		cwDoorCmds:SaveDoorData();
		
		Clockwork.player:Notify(player, {"YouSetUnownableDoor"});
	else
		Clockwork.player:Notify(player, {"ThisIsNotAValidDoor"});
	end;
end;

COMMAND:Register();