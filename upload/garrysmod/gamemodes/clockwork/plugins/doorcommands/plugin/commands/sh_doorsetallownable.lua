--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("DoorSetAllOwnable");

COMMAND.tip = "Set all doors ownable.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local validDoors = 0;
	
	for k,v in pairs(ents.GetAll()) do
		if (IsValid(v) and Clockwork.entity:IsDoor(v)) then
			local data = {
				customName = true,
				position = v:GetPos(),
				entity = v,
				name = table.concat(arguments or {}, " ") or ""
			};
			Clockwork.entity:SetDoorUnownable(data.entity, false);
			Clockwork.entity:SetDoorText(data.entity, false);
			Clockwork.entity:SetDoorName(data.entity, data.name);
		
			cwDoorCmds.doorData[data.entity] = data;
			cwDoorCmds:SaveDoorData();
			
			validDoors = validDoors + 1;
		end;
	end;
	
	Clockwork.player:Notify(player, {"AllDoorsOwnable"});
end;

COMMAND:Register();