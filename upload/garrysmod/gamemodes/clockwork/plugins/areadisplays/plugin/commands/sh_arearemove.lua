--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("AreaRemove");

COMMAND.tip = "Remove an area by looking near it.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos;
	local removed = 0;
	local name = string.lower(arguments[1]);
	
	for k, v in pairs(cwAreaDisplays.storedList) do
		if (string.lower(v.name) == name) then
			Clockwork.datastream:Start(nil, "AreaRemove", {
				name = v.name,
				minimum = v.minimum,
				maximum = v.maximum
			});
				
			cwAreaDisplays.storedList[k] = nil;
			removed = removed + 1;
		end;
	end;
	
	if (removed > 0) then
		Clockwork.player:Notify(player, {"AreaDisplayRemoved", removed});
	else
		Clockwork.player:Notify(player, {"AreaDisplayNoneNearPosition"});
	end;
	
	cwAreaDisplays:SaveAreaDisplays();
end;

COMMAND:Register();