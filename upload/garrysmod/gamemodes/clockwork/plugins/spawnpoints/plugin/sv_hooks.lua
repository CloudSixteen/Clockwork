--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when Clockwork has loaded all of the entities.
function cwSpawnPoints:ClockworkInitPostEntity()
	self:LoadSpawnPoints();
end;

-- Called when a player spawns.
function cwSpawnPoints:PlayerSpawn(player)
	if (player:HasInitialized()) then
		local position = nil;
		local rotate = nil;
		local randomSpawn = nil;
		local faction = player:GetFaction();
		local class = Clockwork.class:FindByID(player:Team());
		
		if (class) then
			if (self.spawnPoints[class.name] and #self.spawnPoints[class.name] > 0) then
				randomSpawn = math.random(1, #self.spawnPoints[class.name]);
				position = self.spawnPoints[class.name][randomSpawn].position;
				rotate = self.spawnPoints[class.name][randomSpawn].rotate;
				
				if (position) then
					player:SetPos(position + Vector(0, 0, 8));
				end;
				
				if (rotate) then
					player:SetEyeAngles(Angle(0, rotate, 0));
				end;
			end;
		end;
		
		if (!position) then
			if (self.spawnPoints[faction] and #self.spawnPoints[faction] > 0) then
				randomSpawn = math.random(1, #self.spawnPoints[faction]);
				position = self.spawnPoints[faction][randomSpawn].position;
				rotate = self.spawnPoints[faction][randomSpawn].rotate;
				
				if (position) then
					player:SetPos(position + Vector(0, 0, 8));
				end;
				
				if (rotate) then
					player:SetEyeAngles(Angle(0, rotate, 0));
				end;
			elseif (self.spawnPoints["default"]) then
				if (#self.spawnPoints["default"] > 0) then
					randomSpawn = math.random(1, #self.spawnPoints["default"]);
					position = self.spawnPoints["default"][randomSpawn].position;
					rotate = self.spawnPoints["default"][randomSpawn].rotate;
					
					if (position) then
						player:SetPos(position + Vector(0, 0, 8));
					end;
					
					if (rotate) then
						player:SetEyeAngles(Angle(0, rotate, 0));
					end;
				end;
			end;
		end;

		if (player:IsAdmin()) then
			Clockwork.datastream:Start(player, "SpawnPointESPSync", self:GetSpawnPoints());
		end;
	end;
end;

local groupCheck = {
	owner = true,
	superadmin = true,
	admin = true,
	operator = true
};

-- Called when a player's usergroup has been set.
function cwSpawnPoints:OnPlayerUserGroupSet(player, usergroup)
	if (groupCheck[string.lower(usergroup)]) then
		Clockwork.datastream:Start(player, "SpawnPointESPSync", self:GetSpawnPoints());
	end;
end;