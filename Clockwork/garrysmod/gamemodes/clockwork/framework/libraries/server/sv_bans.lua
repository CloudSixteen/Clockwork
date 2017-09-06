--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local tonumber = tonumber;
local pairs = pairs;
local type = type;
local string = string;
local os = os;

Clockwork.bans = Clockwork.kernel:NewLibrary("Bans");
Clockwork.bans.stored = Clockwork.bans.stored or {};

--[[
	A local function to handle ban deletion.
	INTERNAL USE ONLY. DO NOT USE.
--]]
local function DELETE_BAN(identifier)
	Clockwork.bans.stored[identifier] = nil;
	
	local queryObj = Clockwork.database:Delete(bansTable);
		queryObj:AddWhere("_Schema = ?", schemaFolder);
		queryObj:AddWhere("_Identifier = ?", identifier);
	queryObj:Push();
end;

--[[
	A local function to handle the loading of bans.
	INTERNAL USE ONLY. DO NOT USE.
--]]
local function BANS_LOAD_CALLBACK(result)
	if (Clockwork.database:IsResult(result)) then
		Clockwork.bans.stored = Clockwork.bans.stored or {};
		
		for k, v in pairs(result)do
			Clockwork.bans.stored[v._Identifier] = {
				unbanTime = tonumber(v._UnbanTime),
				steamName = v._SteamName,
				duration = tonumber(v._Duration),
				reason = v._Reason
			};
		end;
	end;
end

--[[
	@codebase Server
	@details A function to load the bans.
	@returns {Unknown}
--]]
function Clockwork.bans:Load()
	local bansTable = Clockwork.config:Get("mysql_bans_table"):Get();
	local schemaFolder = Clockwork.kernel:GetSchemaFolder();
	local queryObj = Clockwork.database:Select(bansTable);
		queryObj:SetCallback(BANS_LOAD_CALLBACK);
		queryObj:AddWhere("_Schema = ?", schemaFolder);
	queryObj:Pull();
	
	local unixTime = os.time();
		
	for k, v in pairs(self.stored) do
		if (type(v) == "table") then
			if (v.unbanTime > 0 and unixTime >= v.unbanTime) then
				self:Remove(k, true);
			end;
		else
			DELETE_BAN(k);
		end;
	end;
end;

--[[
	@codebase Server
	@details A function to add a ban.
	@param {Unknown} Missing description for identifier.
	@param {Unknown} Missing description for duration.
	@param {Unknown} Missing description for reason.
	@param {Unknown} Missing description for Callback.
	@param {Unknown} Missing description for bSaveless.
	@returns {Unknown}
--]]
function Clockwork.bans:Add(identifier, duration, reason, Callback, bSaveless)
	local steamName = nil;
	local playerGet = Clockwork.player:FindByID(identifier);
	local bansTable = Clockwork.config:Get("mysql_bans_table"):Get();
	local schemaFolder = Clockwork.kernel:GetSchemaFolder();
		
	if (identifier) then
		identifier = string.upper(identifier);
	end;
		
	for k, v in pairs(cwPlayer.GetAll()) do
		local playerIP = v:IPAddress();
		local playerSteam = v:SteamID();
			
		if (playerSteam == identifier or playerIP == identifier or playerGet == v) then
			Clockwork.plugin:Call("PlayerBanned", v, duration, reason);
			
			if (playerIP == identifier) then
				identifier = playerIP;
			else
				identifier = playerSteam;
			end;
				
			steamName = v:SteamName();
			v:Kick(reason);
		end;
	end;
		
	if (!reason) then
		reason = "Banned for an unspecified reason.";
	end;
		
	if (steamName) then
		if (duration == 0) then
			self.stored[identifier] = {
				unbanTime = 0,
				steamName = steamName,
				duration = duration,
				reason = reason
			};
		else
			self.stored[identifier] = {
				unbanTime = os.time() + duration,
				steamName = steamName,
				duration = duration,
				reason = reason
			};
		end;
		
		if (!bSaveless) then
			local queryObj = Clockwork.database:Insert(bansTable);
				queryObj:SetValue("_Identifier", identifier);
				queryObj:SetValue("_UnbanTime", self.stored[identifier].unbanTime);
				queryObj:SetValue("_SteamName", self.stored[identifier].steamName);
				queryObj:SetValue("_Duration", self.stored[identifier].duration);
				queryObj:SetValue("_Reason", self.stored[identifier].reason);
				queryObj:SetValue("_Schema", schemaFolder);
			queryObj:Push();
		end;
		
		if (Callback) then
			Callback(steamName, duration, reason);
		end;
		
		return;
	end;
	
	local playersTable = Clockwork.config:Get("mysql_players_table"):Get();
	
	if (string.find(identifier, "STEAM_(%d+):(%d+):(%d+)")) then
		local queryObj = Clockwork.database:Select(playersTable);
			queryObj:AddWhere("_SteamID = ?", identifier);
			queryObj:SetCallback(function(result)
				local steamName = identifier;
				
				if (Clockwork.database:IsResult(result)) then
					steamName = result[1]._SteamName;
				end;
					
				if (duration == 0) then
					self.stored[identifier] = {
						unbanTime = 0,
						steamName = steamName,
						duration = duration,
						reason = reason
					};
				else
					self.stored[identifier] = {
						unbanTime = os.time() + duration,
						steamName = steamName,
						duration = duration,
						reason = reason
					};
				end;
				
				if (!bSaveless) then
					local insertObj = Clockwork.database:Insert(bansTable);
						insertObj:SetValue("_Identifier", identifier);
						insertObj:SetValue("_UnbanTime", self.stored[identifier].unbanTime);
						insertObj:SetValue("_SteamName", self.stored[identifier].steamName);
						insertObj:SetValue("_Duration", self.stored[identifier].duration);
						insertObj:SetValue("_Reason", self.stored[identifier].reason);
						insertObj:SetValue("_Schema", schemaFolder);
					insertObj:Push();
				end;
				
				if (Callback) then
					Callback(steamName, duration, reason);
				end;
			end);
		queryObj:Pull();
		
		return;
	end;
	
	--[[ In this case we're banning them by their IP address. --]]
	if (string.find(identifier, "%d+%.%d+%.%d+%.%d+")) then
		local queryObj = Clockwork.database:Select(playersTable);	
			queryObj:SetCallback(function(result)
				local steamName = identifier;
				
				if (Clockwork.database:IsResult(result)) then
					steamName = result[1]._SteamName;
				end;
				
				if (duration == 0) then
					self.stored[identifier] = {
						unbanTime = 0,
						steamName = steamName,
						duration = duration,
						reason = reason
					};
				else
					self.stored[identifier] = {
						unbanTime = os.time() + duration,
						steamName = steamName,
						duration = duration,
						reason = reason
					};
				end;
				
				if (!bSaveless) then
					local insertObj = Clockwork.database:Insert(bansTable);
						insertObj:SetValue("_Identifier", identifier);
						insertObj:SetValue("_UnbanTime", self.stored[identifier].unbanTime);
						insertObj:SetValue("_SteamName", self.stored[identifier].steamName);
						insertObj:SetValue("_Duration", self.stored[identifier].duration);
						insertObj:SetValue("_Reason", self.stored[identifier].reason);
						insertObj:SetValue("_Schema", schemaFolder);
					insertObj:Push();
				end;
				
				if (Callback) then
					Callback(steamName, duration, reason);
				end;
			end);
			queryObj:AddWhere("_IPAddress = ?", identifier);
		queryObj:Pull();
		
		return;
	end;
	
	if (duration == 0) then
		self.stored[identifier] = {
			unbanTime = 0,
			steamName = steamName,
			duration = duration,
			reason = reason
		};
	else
		self.stored[identifier] = {
			unbanTime = os.time() + duration,
			steamName = steamName,
			duration = duration,
			reason = reason
		};
	end;
	
	if (!bSaveless) then
		local queryObj = Clockwork.database:Insert(bansTable);
			queryObj:SetValue("_Identifier", identifier);
			queryObj:SetValue("_UnbanTime", self.stored[identifier].unbanTime);
			queryObj:SetValue("_SteamName", self.stored[identifier].steamName);
			queryObj:SetValue("_Duration", self.stored[identifier].duration);
			queryObj:SetValue("_Reason", self.stored[identifier].reason);
			queryObj:SetValue("_Schema", schemaFolder);
		queryObj:Push();
	end;
	
	if (Callback) then
		Callback(steamName, duration, reason);
	end;
end;

--[[
	@codebase Server
	@details A function to remove a ban.
	@param {Unknown} Missing description for identifier.
	@param {Unknown} Missing description for bSaveless.
	@returns {Unknown}
--]]
function Clockwork.bans:Remove(identifier, bSaveless)
	local bansTable = Clockwork.config:Get("mysql_bans_table"):Get();
	local schemaFolder = Clockwork.kernel:GetSchemaFolder();

	if (self.stored[identifier]) then
		self.stored[identifier] = nil;
		
		if (!bSaveless) then
			local queryObj = Clockwork.database:Delete(bansTable);
				queryObj:AddWhere("_Schema = ?", schemaFolder);
				queryObj:AddWhere("_Identifier = ?", identifier);
			queryObj:Push();
		end;
	end;
end;