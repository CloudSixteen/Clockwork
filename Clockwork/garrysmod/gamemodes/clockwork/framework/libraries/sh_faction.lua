--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local tonumber = tonumber;
local pairs = pairs;
local table = table;
local game = game;
local math = math;
local util = util;

Clockwork.faction = Clockwork.kernel:NewLibrary("Faction");
Clockwork.faction.stored = {};
Clockwork.faction.buffer = {};

FACTION_CITIZENS_FEMALE = {
	"models/humans/group01/female_01.mdl",
	"models/humans/group01/female_02.mdl",
	"models/humans/group01/female_03.mdl",
	"models/humans/group01/female_04.mdl",
	"models/humans/group01/female_06.mdl",
	"models/humans/group01/female_07.mdl"
};

FACTION_CITIZENS_MALE = {
	"models/humans/group01/male_01.mdl",
	"models/humans/group01/male_02.mdl",
	"models/humans/group01/male_03.mdl",
	"models/humans/group01/male_04.mdl",
	"models/humans/group01/male_05.mdl",
	"models/humans/group01/male_06.mdl",
	"models/humans/group01/male_07.mdl",
	"models/humans/group01/male_08.mdl",
	"models/humans/group01/male_09.mdl"
};

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {__index = CLASS_TABLE};

-- A function to register a new faction.
function CLASS_TABLE:Register()
	return Clockwork.faction:Register(self, self.name);
end;

-- A function to get a new faction.
function Clockwork.faction:New(name)
	local object = Clockwork.kernel:NewMetaTable(CLASS_TABLE);
		object.name = name or "Unknown";
	return object;
end;

-- A function to register a new faction.
function Clockwork.faction:Register(data, name)
	if (data.models) then
		data.models.female = data.models.female or FACTION_CITIZENS_FEMALE;
		data.models.male = data.models.male or FACTION_CITIZENS_MALE;
	else
		data.models = {
			female = FACTION_CITIZENS_FEMALE,
			male = FACTION_CITIZENS_MALE
		};
	end;
	
	for k, v in pairs(data.models.female) do
		util.PrecacheModel(v);
	end;
	
	for k, v in pairs(data.models.male) do
		util.PrecacheModel(v);
	end;
	
	data.limit = data.limit or 128;
	data.index = Clockwork.kernel:GetShortCRC(name);
	data.name = data.name or name;
	
	self.buffer[data.index] = data;
	self.stored[data.name] = data;
	
	if (SERVER) then
		if (data.models) then
			for k, v in pairs(data.models.female) do
				Clockwork.kernel:AddFile(v);
			end;
			
			for k, v in pairs(data.models.male) do
				Clockwork.kernel:AddFile(v);
			end;
		end;
	
		if (data.material) then
			Clockwork.kernel:AddFile("materials/"..data.material..".png");
		end;
	end;
	
	return data.name;
end;

-- A function to get the faction limit.
function Clockwork.faction:GetLimit(name)
	local faction = self:FindByID(name);
	
	if (faction) then
		if (faction.limit != 128) then
			return math.ceil(faction.limit / (128 / #cwPlayer.GetAll()));
		else
			return game.MaxPlayers();
		end;
	else
		return 0;
	end;
end;

-- A function to get whether a gender is valid.
function Clockwork.faction:IsGenderValid(faction, gender)
	local factionTable = self:FindByID(faction);
	
	if (factionTable and (gender == GENDER_MALE or gender == GENDER_FEMALE)) then
		if (!factionTable.singleGender or gender == factionTable.singleGender) then
			return true;
		end;
	end;
end;

-- A function to get whether a model is valid.
function Clockwork.faction:IsModelValid(faction, gender, model)
	if (gender and model) then
		local factionTable = self:FindByID(faction);
		
		if (factionTable
		and table.HasValue(factionTable.models[string.lower(gender)], model)) then
			return true;
		end;
	end;
end;

-- A function to find a faction by an identifier.
function Clockwork.faction:FindByID(identifier)
	if (!identifier) then return; end;
	
	if (tonumber(identifier)) then
		return self.buffer[tonumber(identifier)];
	elseif (self.stored[identifier]) then
		return self.stored[identifier];
	else
		local shortest = nil;
		local shortestLength = math.huge;
		local lowerIdentifier = string.lower(identifier);

		for k, v in pairs(self:GetAll())do
			if (string.find(string.lower(k), lowerIdentifier)
				and string.len(k) < shortestLength) then
				shortestLength = string.len(k);
				shortest = v;
			end;
		end;

		return shortest;
	end;
end;

-- A function to get all factions.
function Clockwork.faction:GetAll()
	return self.stored;
end;

-- A function to get each player in a faction.
function Clockwork.faction:GetPlayers(faction)
	local players = {};
	
	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:HasInitialized()) then
			if (v:GetFaction() == faction) then
				players[#players + 1] = v;
			end;
		end;
	end;
	
	return players;
end;

-- A function to get the rank with the lowest 'position' (highest rank) in this faction.
function Clockwork.faction:GetHighestRank(faction)
	local faction = Clockwork.faction:FindByID(faction);
	
	if (istable(faction.ranks)) then
		local lowestPos;
		local highestRank;
		
		for k, v in pairs(faction.ranks) do
			if (!lowestPos) then
				lowestPos = v.position;
				highestRank = k;
			else
				if (v.position) then
					if (math.min(lowestPos, v.position) == v.position) then
						highestRank = k;
						lowestPos = v.position;
					end;
				end;
			end;
		end;
		
		return highestRank;
	end;
end;

-- A function to get the rank with the highest 'position' (lowest rank) in this faction.
function Clockwork.faction:GetLowestRank(faction)
	local faction = Clockwork.faction:FindByID(faction);
	
	if (istable(faction.ranks)) then
		local highestPos;
		local lowestRank;
		
		for k, v in pairs(faction.ranks) do
			if (!highestPos) then
				highestPos = v.position;
				lowestRank = k;
			else
				if (v.position) then
					if (math.max(highestPos, v.position) == v.position) then
						lowestRank = k;
						highestPos = v.position;
					end;
				end;
			end;
		end;
		
		return lowestRank;
	end;
end;

if (SERVER) then
	function Clockwork.faction:HasReachedMaximum(player, faction)
		local factionTable = self:FindByID(faction);
		local characters = player:GetCharacters();
		
		if (factionTable and factionTable.maximum) then
			local totalCharacters = 0;
			
			for k, v in pairs(characters) do
				if (v.faction == factionTable.name) then
					totalCharacters = totalCharacters + 1;
				end;
			end;
			
			if (totalCharacters >= factionTable.maximum) then
				return true;
			end;
		end;
	end;
else
	function Clockwork.faction:HasReachedMaximum(faction)
		local factionTable = self:FindByID(faction);
		local characters = Clockwork.character:GetAll();
		
		if (factionTable and factionTable.maximum) then
			local totalCharacters = 0;
			
			for k, v in pairs(characters) do
				if (v.faction == factionTable.name) then
					totalCharacters = totalCharacters + 1;
				end;
			end;
			
			if (totalCharacters >= factionTable.maximum) then
				return true;
			end;
		end;
	end;
end;