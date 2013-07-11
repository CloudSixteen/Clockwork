--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("SpawnPointRemove");
COMMAND.tip = "Remove spawn points at your target position.";
COMMAND.text = "<string Class|Faction|Default>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local faction = Clockwork.faction:FindByID(arguments[1]);
	local class = Clockwork.class:FindByID(arguments[1]);
	local name = nil;
	
	if (class or faction) then
		if (faction) then
			name = faction.name;
		else
			name = class.name;
		end;
		
		if (cwSpawnPoints.spawnPoints[name]) then
			local position = player:GetEyeTraceNoCursor().HitPos;
			local removed = 0;
			
			for k, v in pairs(cwSpawnPoints.spawnPoints[name]) do
				if (v.position:Distance(position) <= 256) then
					cwSpawnPoints.spawnPoints[name][k] = nil;
					
					removed = removed + 1;
				end;
			end;
			
			if (removed > 0) then
				if (removed == 1) then
					Clockwork.player:Notify(player, "You have removed "..removed.." "..name.." spawn point.");
				else
					Clockwork.player:Notify(player, "You have removed "..removed.." "..name.." spawn points.");
				end;
			else
				Clockwork.player:Notify(player, "There were no "..name.." spawn points near this position.");
			end;
		else
			Clockwork.player:Notify(player, "There are no "..name.." spawn points.");
		end;
		
		cwSpawnPoints:SaveSpawnPoints();
	elseif (string.lower(arguments[1]) == "default") then
		if (cwSpawnPoints.spawnPoints["default"]) then
			local position = player:GetEyeTraceNoCursor().HitPos;
			local removed = 0;
			
			for k, v in pairs(cwSpawnPoints.spawnPoints["default"]) do
				if (v.position:Distance(position) <= 256) then
					cwSpawnPoints.spawnPoints["default"][k] = nil;
					
					removed = removed + 1;
				end;
			end;
			
			if (removed > 0) then
				if (removed == 1) then
					Clockwork.player:Notify(player, "You have removed "..removed.." default spawn point.");
				else
					Clockwork.player:Notify(player, "You have removed "..removed.." default spawn points.");
				end;
			else
				Clockwork.player:Notify(player, "There were no default spawn points near this position.");
			end;
		else
			Clockwork.player:Notify(player, "There are no default spawn points.");
		end;
		
		cwSpawnPoints:SaveSpawnPoints();
	else
		Clockwork.player:Notify(player, "This is not a valid class or faction!");
	end;
end;

COMMAND:Register();