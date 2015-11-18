--[[
	Â© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.player = Clockwork.kernel:NewLibrary("Player");
Clockwork.player.playerData = Clockwork.player.playerData or {};
Clockwork.player.characterData = Clockwork.player.characterData or {};

--[[
	@codebase Shared
	@details Add a new character data type that can be synced over the network.
	@param String The name of the data type (can be pretty much anything.)
	@param Int The type of the object (must be a type of NWTYPE_* enum).
	@param Various The default value of the data type.
	@param Function Alter the value that gets networked.
	@param Bool Whether or not the data is networked to the player only (defaults to false.)
--]]
function Clockwork.player:AddCharacterData(name, nwType, default, playerOnly, callback)
	Clockwork.player.characterData[name] = {
		default = default,
		nwType = nwType,
		callback = callback,
		playerOnly = playerOnly
	};
end;

--[[
	@codebase Shared
	@details Add a new player data type that can be synced over the network.
	@param String The name of the data type (can be pretty much anything.)
	@param Int The type of the object (must be a type of NWTYPE_* enum).
	@param Various The default value of the data type.
	@param Function Alter the value that gets networked.
	@param Bool Whether or not the data is networked to the player only (defaults to false.)
--]]
function Clockwork.player:AddPlayerData(name, nwType, default, playerOnly, callback)
	Clockwork.player.playerData[name] = {
		default = default,
		nwType = nwType,
		callback = callback,
		playerOnly = playerOnly
	};
end;

--[[
	@codebase Shared
	@details A function to get a player's rank within their faction.
	@param Userdata The player whose faction rank you are trying to obtain.
--]]
function Clockwork.player:GetFactionRank(player, character)
	if (character) then
		local faction = Clockwork.faction:FindByID(character.faction);
		
		if (faction and istable(faction.ranks)) then
			local rank;
			
			for k, v in pairs(faction.ranks) do
				if (k == character.data["factionrank"]) then
					rank = v;
					break;
				end;
			end;
			
			return character.data["factionrank"], rank;
		end;
	else
		local faction = Clockwork.faction:FindByID(player:GetFaction());
		
		if (faction and istable(faction.ranks)) then
			local rank;
			
			for k, v in pairs(faction.ranks) do
				if (k == player:GetCharacterData("factionrank")) then
					rank = v;
					break;
				end;
			end;
			
			return player:GetCharacterData("factionrank"), rank;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to check if a player can promote the target.
	@param Userdata The player whose permissions you are trying to check.
	@param Userdata The player who may be promoted.
--]]
function Clockwork.player:CanPromote(player, target)
	local stringRank, rank = Clockwork.player:GetFactionRank(player);

	if (rank) then
		if (rank.canPromote) then
			local stringTargetRank, targetRank = Clockwork.player:GetFactionRank(target);
			local highestRank, rankTable = Clockwork.faction:GetHighestRank(player:Faction()).position;

			if (targetRank.position and targetRank.position != rankTable.position) then
				return (rank.canPromote <= targetRank.position);
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to check if a player can demote the target.
	@param Userdata The player whose permissions you are trying to check.
	@param Userdata The player who may be demoted.
--]]
function Clockwork.player:CanDemote(player, target)
	local stringRank, rank = Clockwork.player:GetFactionRank(player);

	if (rank) then
		if (rank.canDemote) then
			local stringTargetRank, targetRank = Clockwork.player:GetFactionRank(target);
			local lowestRank, rankTable = Clockwork.faction:GetLowestRank(player:Faction()).position;

			if (targetRank.position and targetRank.position != rankTable.position) then
				return (rank.canDemote <= targetRank.position);
			end;
		end;
	end;
end;