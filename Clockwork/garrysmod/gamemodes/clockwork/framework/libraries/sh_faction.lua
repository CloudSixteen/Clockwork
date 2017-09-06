--[[
	© CloudSixteen.com do not share, re-distribute or modify
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
Clockwork.faction.stored = Clockwork.faction.stored or {};
Clockwork.faction.buffer = Clockwork.faction.buffer or {};

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

--[[
	@codebase Shared
	@details A function to register a new faction.
	@returns {Unknown}
--]]
function CLASS_TABLE:Register()
	return Clockwork.faction:Register(self, self.name);
end;

--[[
	@codebase Shared
	@details A function to get a new faction.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
function Clockwork.faction:New(name)
	local object = Clockwork.kernel:NewMetaTable(CLASS_TABLE);
		object.name = name or "Unknown";
	return object;
end;

--[[
	@codebase Shared
	@details A function to register a new faction.
	@param {Unknown} Missing description for data.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
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

--[[
	@codebase Shared
	@details A function to get the faction limit.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
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

--[[
	@codebase Shared
	@details A function to get whether a gender is valid.
	@param {Unknown} Missing description for faction.
	@param {Unknown} Missing description for gender.
	@returns {Unknown}
--]]
function Clockwork.faction:IsGenderValid(faction, gender)
	local factionTable = self:FindByID(faction);
	
	if (factionTable and (gender == GENDER_MALE or gender == GENDER_FEMALE)) then
		if (!factionTable.singleGender or gender == factionTable.singleGender) then
			return true;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether a model is valid.
	@param {Unknown} Missing description for faction.
	@param {Unknown} Missing description for gender.
	@param {Unknown} Missing description for model.
	@returns {Unknown}
--]]
function Clockwork.faction:IsModelValid(faction, gender, model)
	if (gender and model) then
		local factionTable = self:FindByID(faction);
		
		if (factionTable
		and table.HasValue(factionTable.models[string.lower(gender)], model)) then
			return true;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to find a faction by an identifier.
	@param {Unknown} Missing description for identifier.
	@returns {Unknown}
--]]
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
				and string.utf8len(k) < shortestLength) then
				shortestLength = string.utf8len(k);
				shortest = v;
			end;
		end;

		return shortest;
	end;
end;

--[[
	@codebase Shared
	@details A function to get all factions.
	@returns {Unknown}
--]]
function Clockwork.faction:GetAll()
	return self.stored;
end;

--[[
	@codebase Shared
	@details A function to get each player in a faction.
	@param {Unknown} Missing description for faction.
	@returns {Unknown}
--]]
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

--[[
	@codebase Shared
	@details A function to get the rank with the lowest 'position' (highest rank) in this faction.
	@param {Unknown} Missing description for faction.
	@returns {Unknown}
--]]
function Clockwork.faction:GetHighestRank(faction)
	local faction = Clockwork.faction:FindByID(faction);
	
	if (istable(faction.ranks)) then
		local lowestPos;
		local highestRank;
		local rankTable;
		
		for k, v in pairs(faction.ranks) do
			if (!lowestPos) then
				lowestPos = v.position;
				rankTable = v;
				highestRank = k;
			else
				if (v.position) then
					if (math.min(lowestPos, v.position) == v.position) then
						highestRank = k;
						rankTable = v;
						lowestPos = v.position;
					end;
				end;
			end;
		end;
		
		return highestRank, rankTable;
	end;
end;

--[[
	@codebase Shared
	@details A function to get the rank with the highest 'position' (lowest rank) in this faction.
	@param {Unknown} Missing description for faction.
	@returns {Unknown}
--]]
function Clockwork.faction:GetLowestRank(faction)
	local faction = Clockwork.faction:FindByID(faction);
	
	if (istable(faction.ranks)) then
		local highestPos;
		local lowestRank;
		local rankTable;
		
		for k, v in pairs(faction.ranks) do
			if (!highestPos) then
				highestPos = v.position;
				lowestRank = k;
				rankTable = v;
			else
				if (v.position) then
					if (math.max(highestPos, v.position) == v.position) then
						lowestRank = k;
						rankTable = v;
						highestPos = v.position;
					end;
				end;
			end;
		end;
		
		return lowestRank, rankTable;
	end;
end;

--[[
	@codebase Shared
	@details A function to get the rank with the next lowest 'position' (next highest rank).
	@param {Unknown} Missing description for faction.
	@param {Unknown} Missing description for rank.
	@returns {Unknown}
--]]
function Clockwork.faction:GetHigherRank(faction, rank)
	local highestRank, rankTable = self:GetHighestRank(faction);
	
	faction = Clockwork.faction:FindByID(faction);

	if (istable(faction.ranks) and istable(rank) and rank.position and rank.position != rankTable.position) then
		for k, v in pairs(faction.ranks) do
			if (v.position == (rank.position - 1)) then
				return k, v;
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get the rank with the next highest 'position' (next lowest rank).
	@param {Unknown} Missing description for faction.
	@param {Unknown} Missing description for rank.
	@returns {Unknown}
--]]
function Clockwork.faction:GetLowerRank(faction, rank)
	local lowestRank, rankTable = self:GetLowestRank(faction);

	faction = Clockwork.faction:FindByID(faction);

	if (istable(faction.ranks) and istable(rank) and rank.position and rank.position != rankTable.position) then
		for k, v in pairs(faction.ranks) do
			if (v.position == (rank.position + 1)) then
				return k, v;
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to get the default rank of a faction.
	@param {Unknown} Missing description for faction.
	@returns {Unknown}
--]]
function Clockwork.faction:GetDefaultRank(faction)
	local faction = Clockwork.faction:FindByID(faction);
	
	if (istable(faction.ranks)) then
		local lowestPos;
		local highestRank;
		
		for k, v in pairs(faction.ranks) do
			if (v.default) then
				return k, v;
			end
		end;
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