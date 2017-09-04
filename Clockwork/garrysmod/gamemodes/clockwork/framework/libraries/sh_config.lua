--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local tonumber = tonumber;
local tostring = tostring;
local IsValid = IsValid;
local pairs = pairs;
local pcall = pcall;
local type = type;
local string = string;
local table = table;
local game = game;

--[[ We need the datastream library to add the hooks! --]]
if (!Clockwork.datastream) then include("sh_datastream.lua"); end;

Clockwork.config = Clockwork.kernel:NewLibrary("Config");
Clockwork.config.indexes = Clockwork.config.indexes or {};
Clockwork.config.stored = Clockwork.config.stored or {};
Clockwork.config.cache = Clockwork.config.cache or {};
Clockwork.config.map = Clockwork.config.map or {};

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {__index = CLASS_TABLE};

-- Called when the config is invoked as a function.
function CLASS_TABLE:__call(parameter, failSafe)
	return self:Query(parameter, failSafe);
end;

-- Called when the config is converted to a string.
function CLASS_TABLE.__tostring()
	return "CONFIG["..self("key").."]";
end;

-- A function to create a new config object.
function CLASS_TABLE:Create(key)
	local config = Clockwork.kernel:NewMetaTable(CLASS_TABLE);
		config.data = Clockwork.config.stored[key];
		config.key = key;
	return config;
end;

-- A function to check if the config is valid.
function CLASS_TABLE:IsValid()
	return self.data != nil;
end;

-- A function to query the config.
function CLASS_TABLE:Query(key, failSafe)
	if (self.data and self.data[key] != nil) then
		return self.data[key];
	else
		return failSafe;
	end;
end;

-- A function to get the config's value as a boolean.
function CLASS_TABLE:GetBoolean(failSafe)
	if (self.data) then
		return (self.data.value == true or self.data.value == "true"
		or self.data.value == "yes" or self.data.value == "1" or self.data.value == 1);
	elseif (failSafe != nil) then
		return failSafe;
	else
		return false;
	end;
end;

-- A function to get a config's value as a number.
function CLASS_TABLE:GetNumber(failSafe)
	if (self.data) then
		return tonumber(self.data.value) or failSafe or 0;
	else
		return failSafe or 0;
	end;
end;

-- A function to get a config's value as a string.
function CLASS_TABLE:GetString(failSafe)
	if (self.data) then
		return tostring(self.data.value);
	else
		return failSafe or "";
	end;
end;

-- A function to get a config's default value.
function CLASS_TABLE:GetDefault(failSafe)
	if (self.data) then
		return self.data.default;
	else
		return failSafe;
	end;
end;

-- A function to get the config's next value.
function CLASS_TABLE:GetNext(failSafe)
	if (self.data and self.data.nextValue != nil) then
		return self.data.nextValue;
	else
		return failSafe;
	end;
end;

-- A function to get the config's value.
function CLASS_TABLE:Get(failSafe)
	if (self.data and self.data.value != nil) then
		return self.data.value;
	else
		return failSafe;
	end;
end;

-- A function to set whether the config has initialized.
function Clockwork.config:SetInitialized(bInitalized)
	self.cwInitialized = bInitalized;
end;

-- A function to get whether the config has initialized.
function Clockwork.config:HasInitialized()
	return self.cwInitialized;
end;

-- A function to get whether a config value is valid.
function Clockwork.config:IsValidValue(value)
	return type(value) == "string" or type(value) == "number" or type(value) == "boolean";
end;

-- A function to share a config key.
function Clockwork.config:ShareKey(key)
	local shortCRC = Clockwork.kernel:GetShortCRC(key);
	
	if (SERVER) then
		self.indexes[key] = shortCRC;
	else
		self.indexes[shortCRC] = key;
	end;
end;

-- A function to get the stored config.
function Clockwork.config:GetStored()
	return self.stored;
end;

-- A function to import a config file.
function Clockwork.config:Import(fileName)
	local data = cwFile.Read(fileName, "GAME") or "";
	
	for k, v in pairs(string.Explode("\n", data)) do
		if (v != "" and !string.find(v, "^%s$")) then
			if (!string.find(v, "^%[.+%]$") and !string.find(v, "^//")) then
				local class, key, value = string.match(v, "^(.-)%s(.-)%s=%s(.+);");
				
				if (class and key and value) then
					if (string.find(class, "boolean")) then
						value = (value == "true" or value == "yes" or value == "1");
					elseif (string.find(class, "number")) then
						value = tonumber(value);
					end;
					
					local forceSet = string.find(class, "force") != nil;
					local isGlobal = string.find(class, "global") != nil;
					local isShared = string.find(class, "shared") != nil;
					local isStatic = string.find(class, "static") != nil;
					local isPrivate = string.find(class, "private") != nil;
					local needsRestart = string.find(class, "restart") != nil;
					
					if (value) then
						local config = self:Get(key);
						
						if (!config:IsValid()) then
							self:Add(key, value, isShared, isGlobal, isStatic, isPrivate, needsRestart);
						else
							config:Set(value, nil, forceSet);
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to load an INI file.
function Clockwork.config:LoadINI(fileName, bFromGame, bStripQuotes)
	local wasSuccess, value = pcall(file.Read, fileName, (bFromGame and "GAME" or "DATA"));
	
	if (wasSuccess and value != nil) then
		local explodedData = string.Explode("\n", value);
		local outputTable = {};
		local currentNode = "";
		
		local function StripComment(line)
			local startPos, endPos = line:find("[;#]");
			
			if (startPos) then
				line = line:sub(1, startPos - 1):Trim();
			end;
			
			return line;
		end;
		
		local function StripQuotes(line)
			return line:gsub("[\"]", ""):Trim();
		end;
		
		for k, v in pairs(explodedData) do
			local line = StripComment(v):gsub("\n", "");
			
			if (line != "") then
				if (bStripQuotes) then
					line = StripQuotes(line);
				end;
				
				if (line:sub(1, 1) == "[") then
					local startPos, endPos = line:find("%]");
					
					if (startPos) then
						currentNode = line:sub(2, startPos - 1);
						
						if (!outputTable[currentNode]) then
							outputTable[currentNode] = {};
						end;
					else
						return false;
					end;
				elseif (currentNode == "") then
					return false;
				else
					local data = string.Explode("=", line);
					
					if (#data > 1) then
						local key = data[1];
						local value = table.concat(data, "=", 2);
						
						if (tonumber(value)) then
							outputTable[currentNode][key] = tonumber(value);
						elseif (value == "true" or value == "false") then
							outputTable[currentNode][key] = (value == "true");
						else
							outputTable[currentNode][key] = value;
						end;
					end;
				end;
			end;
		end;
		
		return outputTable;
	end;
end;

-- A function to parse config keys.
function Clockwork.config:Parse(text)
	for key in string.gmatch(text, "%$(.-)%$") do
		local value = self:Get(key):Get();
		
		if (value != nil) then
			text = Clockwork.kernel:Replace(text, "$"..key.."$", tostring(value));
		end;
	end;
	
	return text;
end;

-- A function to get a config object.
function Clockwork.config:Get(key)
	if (!self.cache[key]) then
		local configObject = CLASS_TABLE:Create(key);
		
		if (configObject.data) then
			self.cache[key] = configObject;
		end;
		
		return configObject;
	else
		return self.cache[key];
	end;
end;

if (SERVER) then
	function Clockwork.config:Save(fileName, configTable)
		if (configTable) then
			local config = { global = {}, schema = {}};
			
			for k, v in pairs(configTable) do
				if (!v.map and !v.temporary and !string.find(k, "mysql_")) then
					local value = v.value;
					
					if (v.nextValue != nil) then
						value = v.nextValue;
					end;
					
					if (value != v.default) then
						if (v.isGlobal) then
							config.global[k] = {
								value = value,
								default = v.default
							};
						else
							config.schema[k] = {
								value = value,
								default = v.default
							};
						end;
					end;
				end;
			end;
			
			Clockwork.kernel:SaveClockworkData(fileName, config.global);
			Clockwork.kernel:SaveSchemaData(fileName, config.schema);
		else
			Clockwork.kernel:DeleteClockworkData(fileName);
			Clockwork.kernel:DeleteSchemaData(fileName);
		end;
	end;
	
	-- A function to send the config to a player.
	function Clockwork.config:Send(player, key)
		if (player and player:IsBot()) then
			Clockwork.plugin:Call("PlayerConfigInitialized", player);
				player.cwConfigInitialized = true;
			return;
		end;
		
		if (!player) then
			player = cwPlayer.GetAll();
		else
			player = {player};
		end;
		
		if (key) then
			if (self.stored[key]) then
				local value = self.stored[key].value;
				
				if (self.stored[key].isShared) then
					if (self.indexes[key]) then
						key = self.indexes[key];
					end;
					
					Clockwork.datastream:Start(player, "Config", { [key] = value });
				end;
			end;
		else
			local config = {};
			
			for k, v in pairs(self.stored) do
				if (v.isShared) then
					local index = self.indexes[k];
					
					if (index) then
						config[index] = v.value;
					else
						config[k] = v.value;
					end;
				end;
			end;
			
			Clockwork.datastream:Start(player, "Config", config);
		end;
	end;

	-- A function to load config from a file.
	function Clockwork.config:Load(fileName, loadGlobal)
		if (!fileName) then
			local configClasses = {"default", "map"};
			local configTable;
			local map = string.lower(game.GetMap());
			
			if (loadGlobal) then
				self.global = {
					default = self:Load("config", true),
					map = self:Load("config/"..map, true)
				};
				
				configTable = self.global;
			else
				self.schema = {
					default = self:Load("config"),
					map = self:Load("config/"..map)
				};
				
				configTable = self.schema;
			end;
			
			for k, v in pairs(configClasses) do
				for k2, v2 in pairs(configTable[v]) do
					local configObject = self:Get(k2);
					
					if (configObject:IsValid()) then
						if (configObject("default") == v2.default) then
							if (v == "map") then
								configObject:Set(v2.value, map, true);
							else
								configObject:Set(v2.value, nil, true);
							end;
						end;
					end;
				end;
			end;
		elseif (loadGlobal) then
			return Clockwork.kernel:RestoreClockworkData(fileName);
		else
			return Clockwork.kernel:RestoreSchemaData(fileName);
		end;
	end;
	
	-- A function to add a new config key.
	function Clockwork.config:Add(key, value, isShared, isGlobal, isStatic, isPrivate, needsRestart)
		if (self:IsValidValue(value)) then
			if (!self.stored[key]) then
				self.stored[key] = {
					category = PLUGIN and PLUGIN:GetName(),
					needsRestart = needsRestart,
					isPrivate = isPrivate,
					isShared = isShared,
					isStatic = isStatic,
					isGlobal = isGlobal,
					default = value,
					value = value
				};
				
				local configClasses = {"global", "schema"};
				local configObject = CLASS_TABLE:Create(key);
				
				if (!isGlobal) then
					table.remove(configClasses, 1);
				end;
				
				for k, v in pairs(configClasses) do
					local configTable = Clockwork.config[v];
					local map = string.lower(game.GetMap());
					
					if (configTable and configTable.default and configTable.default[key]) then
						if (configObject("default") == configTable.default[key].default) then
							configObject:Set(configTable.default[key].value, nil, true);
						end;
					end;
					
					if (configTable and configTable.map and configTable.map[key]) then
						if (configObject("default") == configTable.map[key].default) then
							configObject:Set(configTable.map[key].value, map, true);
						end;
					end;
				end;
				
				self:Send(nil, key);
				
				return configObject;
			end;
		end;
	end;
	
	-- A function to set the config's value.
	function CLASS_TABLE:Set(value, map, forceSet, temporary)
		if (map) then
			map = string.lower(map);
		end;
		
		if (tostring(value) == "-1.#IND") then
			value = 0;
		end;
		
		if (self.data and Clockwork.config:IsValidValue(value)) then
			if (self.data.value != value) then
				local previousValue = self.data.value;
				local default = (value == "!default");
				
				if (!default) then
					if (type(self.data.value) == "number") then
						value = tonumber(value) or self.data.value;
					elseif (type(self.data.value) == "boolean") then
						value = (value == true or value == "true"
						or value == "yes" or value == "1" or value == 1);
					end;
				else
					value = self.data.default;
				end;
				
				if (!self.data.isStatic or forceSet) then
					if (!map or string.lower(game.GetMap()) == map) then
						if ((!Clockwork.config:HasInitialized() and self.data.value == self.data.default)
						or !self.data.needsRestart or forceSet) then
							self.data.value = value;
							
							if (self.data.isShared) then
								Clockwork.config:Send(nil, self.key);
							end;
						end;
					end;
					
					if (Clockwork.config:HasInitialized()) then
						self.data.temporary = temporary;
						self.data.forceSet = forceSet;
						self.data.map = map;
						
						if (self.data.needsRestart) then
							if (self.data.forceSet) then
								self.data.nextValue = nil;
							else
								self.data.nextValue = value;
							end;
						end;
						
						if (!self.data.map and !self.data.temporary) then
							Clockwork.config:Save("config", Clockwork.config.stored);
						end;
						
						if (self.data.map) then
							if (default) then
								if (Clockwork.config.map[self.data.map]) then
									Clockwork.config.map[self.data.map][self.key] = nil;
								end;
							else
								if (!Clockwork.config.map[self.data.map]) then
									Clockwork.config.map[self.data.map] = {};
								end;
								
								Clockwork.config.map[self.data.map][self.key] = {
									default = self.data.default,
									global = self.data.isGlobal,
									value = value
								};
							end;
							
							if (!self.data.temporary) then
								Clockwork.config:Save("config/"..self.data.map, Clockwork.config.map[self.data.map]);
							end;
						end;
					end;
				end;
				
				if (self.data.value != previousValue and Clockwork.config:HasInitialized()) then
					Clockwork.plugin:Call("ClockworkConfigChanged", self.key, self.data, previousValue, self.data.value);
				end;
			end;
			
			return value;
		end;
	end;
	
	Clockwork.datastream:Hook("ConfigInitialized", function(player, data)
		if (!player:HasConfigInitialized()) then
			player:SetConfigInitialized(true);
			Clockwork.plugin:Call("PlayerConfigInitialized", player);
		end;
	end);
else
	Clockwork.config.system = {};
	
	Clockwork.datastream:Hook("Config", function(data)
		for k, v in pairs(data) do
			if (Clockwork.config.indexes[k]) then
				k = Clockwork.config.indexes[k];
			end;
			
			if (!Clockwork.config.stored[k]) then
				Clockwork.config:Add(k, v);
			else
				Clockwork.config:Get(k):Set(v);
			end;
		end;
		
		if (!Clockwork.config:HasInitialized()) then
			Clockwork.config:SetInitialized(true);
			
			for k, v in pairs(Clockwork.config.stored) do
				Clockwork.plugin:Call("ClockworkConfigInitialized", k, v.value);
			end;
			
			if (IsValid(Clockwork.Client) and !Clockwork.config:HasSentInitialized()) then
				Clockwork.datastream:Start("ConfigInitialized", true);
				Clockwork.config:SetSentInitialized(true);
			end;
		end;
	end);
	
	-- A function to get whether the config has sent initialized.
	function Clockwork.config:SetSentInitialized(sentInitialized)
		self.sentInitialized = sentInitialized;
	end;

	-- A function to get whether the config has sent initialized.
	function Clockwork.config:HasSentInitialized()
		return self.sentInitialized;
	end;
	
	-- A function to add a config key entry to the system.
	function Clockwork.config:AddToSystem(name, key, help, minimum, maximum, decimals, category)
		category = PLUGIN and PLUGIN:GetName();

		self.system[key] = {
			key = key,
			name = name or key,
			decimals = tonumber(decimals) or 0,
			maximum = tonumber(maximum) or 100,
			minimum = tonumber(minimum) or 0,
			help = help or "ConfigNoHelpProvided",
			category = category or "ConfigClockworkCategory"
		};
	end;
	
	-- A function to get a config key's system entry.
	function Clockwork.config:GetFromSystem(key)
		return self.system[key];
	end;
	
	-- A function to add a new config key.
	function Clockwork.config:Add(key, value)
		if (self:IsValidValue(value)) then
			if (!self.stored[key]) then
				self.stored[key] = {
					default = value,
					value = value
				};
				
				return CLASS_TABLE:Create(key);
			end;
		end;
	end;
	
	-- A function to set the config's value.
	function CLASS_TABLE:Set(value)
		if (tostring(value) == "-1.#IND") then
			value = 0;
		end;
		
		if (self.data and Clockwork.config:IsValidValue(value)) then
			if (self.data.value != value) then
				local previousValue = self.data.value;
				local default = (value == "!default");
				
				if (!default) then
					if (type(self.data.value) == "number") then
						value = tonumber(value) or self.data.value;
					elseif (type(self.data.value) == "boolean") then
						value = (value == true or value == "true"
						or value == "yes" or value == "1" or value == 1);
					elseif (type(self.data.value) != type(value)) then
						return;
					end;
					
					self.data.value = value;
				else
					self.data.value = self.data.default;
				end;
				
				if (self.data.value != previousValue and Clockwork.config:HasInitialized()) then
					Clockwork.plugin:Call("ClockworkConfigChanged", self.key, self.data, previousValue, self.data.value);
				end;
			end;
			
			return self.data.value;
		end;
	end;
end;