--[[
© CloudSixteen.com do not share, re-distribute or modify
without permission of its author (kurozael@gmail.com).

Clockwork was created by Conna Wiles (also known as kurozael.)
https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

--[[
	Track player spawns so that we can calculate
	Daily Active User count and other useful information.
--]]

function cwTrackStats:PlayerInitialSpawn(player)
	self:Track("PlayerInitialSpawn", {
		name = player:SteamName(),
		steamId = tostring(player:SteamID64()),
		hostname = GetConVarString("hostname")
	});
end;

function cwTrackStats:PlayerCharacterCreated(player, character)
	self:Track("CharacterCreated", {
		name = player:SteamName(),
		steamId = tostring(player:SteamID64()),
		character = character.name,
		hostname = GetConVarString("hostname")
	});
end;

function cwTrackStats:PlayerCharacterLoaded(player)
	self:Track("CharacterLoaded", {
		name = player:SteamName(),
		steamId = tostring(player:SteamID64()),
		character = player:Name(),
		hostname = GetConVarString("hostname")
	});
end;

function cwTrackStats:Think()
	if (self.initialized) then return true; end;
	
	if (cwTrackStats:CheckLogTime("ServerStarted")) then
		local versionString = CloudAuthX.GetVersion();
		local operatingSystem = "[WINDOWS] ";
		
		if (system.IsLinux()) then
			operatingSystem = "[LINUX] ";
		end;
		
		cwTrackStats:Track("ServerStarted", {
			hostname = operatingSystem..GetConVarString("hostname"),
			cax = versionString,
			cwv = Clockwork.kernel:GetVersion(),
			map = game.GetMap()
		});
		
		cwTrackStats:SetLogTime("ServerStarted", 120);
	end;
	
	self.initialized = true;
end;