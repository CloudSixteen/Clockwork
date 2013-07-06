--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("SpawnPointAdd");
COMMAND.tip = "Add a spawn point at your target position.";
COMMAND.text = "<string Class|Faction|Default> [number Rotate]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local faction = Clockwork.faction:FindByID(arguments[1]);
	local class = Clockwork.class:FindByID(arguments[1]);
	local name = nil;
	local rotate = tonumber(arguments[2]) or nil;
	
	if (class or faction) then
		if (faction) then
			name = faction.name;
		else
			name = class.name;
		end;
		
		cwSpawnPoints.spawnPoints[name] = cwSpawnPoints.spawnPoints[name] or {};
		cwSpawnPoints.spawnPoints[name][#cwSpawnPoints.spawnPoints[name] + 1] = {position = player:GetEyeTraceNoCursor().HitPos, rotate = rotate};
		cwSpawnPoints:SaveSpawnPoints();
		
		Clockwork.player:Notify(player, "You have added a spawn point for "..name..".");
	elseif (string.lower(arguments[1]) == "default") then
		cwSpawnPoints.spawnPoints["default"] = cwSpawnPoints.spawnPoints["default"] or {};
		cwSpawnPoints.spawnPoints["default"][#cwSpawnPoints.spawnPoints["default"] + 1] = {position = player:GetEyeTraceNoCursor().HitPos, rotate = rotate};
		cwSpawnPoints:SaveSpawnPoints();
		
		Clockwork.player:Notify(player, "You have added a default spawn point.");
	else
		Clockwork.player:Notify(player, "This is not a valid class or faction!");
	end;
end;

COMMAND:Register();