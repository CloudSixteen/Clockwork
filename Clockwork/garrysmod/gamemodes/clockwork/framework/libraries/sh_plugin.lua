--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local AddCSLuaFile = AddCSLuaFile;
local ErrorNoHalt = ErrorNoHalt;
local pairs = pairs;
local pcall = pcall;
local scripted_ents = scripted_ents;
local effects = effects;
local weapons = weapons;
local string = string;
local table = table;
local file = file;
local util = util;
local debug = debug;

--[[ The plugin library is already defined! --]]
if (Clockwork.plugin) then return; end;

Clockwork.plugin = Clockwork.kernel:NewLibrary("Plugin");

--[[
	We do local variables instead of global ones for performance increase.
	Most CW libraries use functions to return their tables anyways.
--]]
local stored = {};
local modules = {};
local unloaded = {};
local extras = {};
local hookCache = {};

--[[
	@codebase Shared
	@details A function to get the local stored table that contains all registered plugins.
	@returns {Table} The local stored plugin table.
--]]
function Clockwork.plugin:GetStored()
	return stored;
end;

--[[
	@codebase Shared
	@details A function to get the local plugin module table that contains all registered plugin modules.
	@returns {Table} The local plugin module table.
--]]
function Clockwork.plugin:GetModules()
	return modules;
end;

--[[
	@codebase Shared
	@details A function to get the local unloaded table that contains all unloaded plugins.
	@returns {Table} The local stored unloaded plugin table.
--]]
function Clockwork.plugin:GetUnloaded()
	return unloaded;
end;

--[[
	@codebase Shared
	@details A function to get the extras that will be included in each plugin.
	@returns {Table} The local table of extras to be searched for in plugins.
--]]
function Clockwork.plugin:GetExtras()
	return extras;
end;

--[[
	@codebase Shared
	@details A function to get the local plugin hook cache.
	@returns {Table} The local plugin hook cache table.
--]]
function Clockwork.plugin:GetHookCache()
	return hookCache;
end;

PLUGIN_META = {__index = PLUGIN_META};
PLUGIN_META.description = "An undescribed plugin or schema.";
PLUGIN_META.hookOrder = 0;
PLUGIN_META.version = "1.0";
PLUGIN_META.author = "Unknown";
PLUGIN_META.name = "Unknown";

PLUGIN_META.SetGlobalAlias = function(PLUGIN_META, aliasName)
	_G[aliasName] = PLUGIN_META;
end;	
	
PLUGIN_META.GetDescription = function(PLUGIN_META)
	return PLUGIN_META.description;
end;
	
PLUGIN_META.GetBaseDir = function(PLUGIN_META)
	return PLUGIN_META.baseDir;
end;

PLUGIN_META.GetHookOrder = function(PLUGIN_META)
	return PLUGIN_META.hookOrder;
end;
	
PLUGIN_META.GetVersion = function(PLUGIN_META)
	return PLUGIN_META.version;
end;
	
PLUGIN_META.GetAuthor = function(PLUGIN_META)
	return PLUGIN_META.author;
end;
	
PLUGIN_META.GetName = function(PLUGIN_META)
	return PLUGIN_META.name;
end;
	
PLUGIN_META.Register = function(PLUGIN_META)
	Clockwork.plugin:Register(PLUGIN_META);
end;

debug.getregistry().Plugin = PLUGIN_META;

--[[
	CloudScript
--]]

if (SERVER) then
	CloudAuthX.External("NGQ85o7ykGYYIvF19dwNWgETqdlNQXIwlN9QJeNMFV+DHIzBhAdfbGRLkn9SZFUyqxs/W/YDJgxnjKdGEX+wfZr9pNf0yvzOQ6BVQMCftOtnZjVthoPF92eAZRxB2AjO2Xp1eCrqgLwYYgesc6KT6PiTl6o/d/WmGno9om1W/dZUYZrfXTOuU0c5CVHswtOOz8iohM3M6GVJT1sNCMpKu+bCAebqX7Z0Jf2n3Qka6V5rimLsXAZ7CgR1i5IO85jdO5HNnI7N7zqGW9FS8tlqNnf3zjNdGdT7Gj+7yZvMvYBOgK+xhuBDUgPqHVcM0pKK0UPNAawL7twzSs8UA+Bterl4TPkVayoIRkKL+Mem1QYDf3bg7j7kw3emY6g2AmfitXNA5mIKgNwpPucsxSmODJj4ZtiYBNzAEm7lJjSSMorAYxphWQCjYea2N3tAZAzWjS8bkFW3d3JwUnSWUw02uq5k/coXzaKDMz7o0W/lgdZXyvrGbQgjjrUP4OlD5j6HY7vcbjJGbG8XcBoFUYHgkbQfTyIU8XGxcOyTj8Rxcugi1LKQt2dMaqJ6bKUbag7Br39/fPIHl8DiXpy1lVHYlzLGH+WBscNWI+6mY8G606ZfIf+lgsAJ78/8Bx4KdSZc5tGd9U15jtlUt3slWcuccmecE1H+F4Zok19byicJUoYigz/AfRdjnIUse5kyPvv2Dm1Bv6QnhUF5EWSLTU+xi/Z16ZTk2VvTGF7QPirV0tC+BM7hVYewG7qhHhS2v+aDP8TeRIXSXl+lQ0OMc4IBDTW9G3Vja4I2OAQc2TNYtuXGy2/1YY/tqeI+LmKgfiWl06nfvTUSzEdQg8mZm97/cA==");
end;

if (SERVER) then
	function Clockwork.plugin:SetUnloaded(name, isUnloaded)
		local plugin = self:FindByID(name);
		
		if (plugin and plugin != Schema) then
			if (isUnloaded) then
				unloaded[plugin.folderName] = true;
			else
				unloaded[plugin.folderName] = nil;
			end;
			
			Clockwork.kernel:SaveSchemaData("plugins", unloaded);
			return true;
		end;
		
		return false;
	end;
	
	--[[
		@codebase Shared
		@details A function to get whether a plugin is disabled.
		@param {Unknown} Missing description for name.
		@param {Unknown} Missing description for bFolder.
		@returns {Unknown}
	--]]
	function Clockwork.plugin:IsDisabled(name, bFolder)
		if (!bFolder) then
			local plugin = self:FindByID(name);
			
			if (plugin and plugin != Schema) then
				for k, v in pairs(unloaded) do
					local unloaded = self:FindByID(k);
					
					if (unloaded and unloaded != Schema
					and plugin.folderName != unloaded.folderName) then
						if (table.HasValue(unloaded.plugins, plugin.folderName)) then
							return true;
						end;
					end;
				end;
			end;
		else
			for k, v in pairs(unloaded) do
				local unloaded = self:FindByID(k);
				
				if (unloaded and unloaded != Schema and name != unloaded.folderName) then
					if (table.HasValue(unloaded.plugins, name)) then
						return true;
					end;
				end;
			end;
		end;
		
		return false;
	end;
	
	--[[
		@codebase Shared
		@details A function to get whether a plugin is unloaded.
		@param {Unknown} Missing description for name.
		@param {Unknown} Missing description for bFolder.
		@returns {Unknown}
	--]]
	function Clockwork.plugin:IsUnloaded(name, bFolder)
		if (!bFolder) then
			local plugin = self:FindByID(name);
			
			if (plugin and plugin != Schema) then
				return (unloaded[plugin.folderName] == true);
			end;
		else
			return (unloaded[name] == true);
		end;
		
		return false;
	end;
else
	Clockwork.plugin.override = Clockwork.plugin.override or {};
	
	--[[
		@codebase Shared
		@details A function to set whether a plugin is unloaded.
		@param {Unknown} Missing description for name.
		@param {Unknown} Missing description for isUnloaded.
		@returns {Unknown}
	--]]
	function Clockwork.plugin:SetUnloaded(name, isUnloaded)
		local plugin = self:FindByID(name);
		
		if (plugin) then
			self.override[plugin.folderName] = isUnloaded;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to get whether a plugin is disabled.
		@param {Unknown} Missing description for name.
		@param {Unknown} Missing description for bFolder.
		@returns {Unknown}
	--]]
	function Clockwork.plugin:IsDisabled(name, bFolder)
		if (!bFolder) then
			local plugin = self:FindByID(name);
			
			if (plugin and plugin != Schema) then
				for k, v in pairs(unloaded) do
					local unloaded = self:FindByID(k);
					
					if (unloaded and unloaded != Schema
					and plugin.folderName != unloaded.folderName) then
						if (table.HasValue(unloaded.plugins, plugin.folderName)) then
							return true;
						end;
					end;
				end;
			end;
		else
			for k, v in pairs(unloaded) do
				local unloaded = self:FindByID(k);
				
				if (unloaded and unloaded != Schema
				and name != unloaded.folderName) then
					if (table.HasValue(unloaded.plugins, name)) then
						return true;
					end;
				end;
			end;
		end;
		
		return false;
	end;
	
	--[[
		@codebase Shared
		@details A function to get whether a plugin is unloaded.
		@param {Unknown} Missing description for name.
		@param {Unknown} Missing description for bFolder.
		@returns {Unknown}
	--]]
	function Clockwork.plugin:IsUnloaded(name, bFolder)
		if (!bFolder) then
			local plugin = self:FindByID(name);
			
			if (plugin and plugin != Schema) then
				if (self.override[plugin.folderName] != nil) then
					return self.override[plugin.folderName];
				end;
				
				return (unloaded[plugin.folderName] == true);
			end;
		else
			if (self.override[name] != nil) then
				return self.override[name];
			end;
			
			return (unloaded[name] == true);
		end;
		
		return false;
	end;
end;

--[[
	@codebase Shared
	@details A function to set if the plugin system is initialized.
	@param {Unknown} Missing description for bInitialized.
	@returns {Unknown}
--]]
function Clockwork.plugin:SetInitialized(bInitialized)
	self.cwInitialized = bInitialized;
end;

--[[
	@codebase Shared
	@details A function to get whether the config has initialized.
	@returns {Unknown}
--]]
function Clockwork.plugin:HasInitialized()
	return self.cwInitialized;
end;

--[[
	@codebase Shared
	@details A function to initialize the plugin system.
	@returns {Unknown}
--]]
function Clockwork.plugin:Initialize()
	if (self:HasInitialized()) then
		return;
	end;

	if (SERVER) then
		unloaded = Clockwork.kernel:RestoreSchemaData("plugins");
	end;
	
	self:SetInitialized(true);
end;

--[[
	@codebase Shared
	@details A function to check Schema function mismatches.
	@returns {Unknown}
--]]
function Clockwork.plugin:CheckMismatches()
	if (Schema) then
		local funcIdxMismatches = {};
		
		for k, v in pairs(Schema) do
			if (type(v) == "function" and Schema.__funcIdx[k]
			and tostring(v) ~= Schema.__funcIdx[k]) then
				table.insert(funcIdxMismatches, k);
			end;
		end;
		
		for k, v in ipairs(funcIdxMismatches) do
			MsgC(Color(255, 100, 0, 255), "[Clockwork:Plugin] The Schema hook '"..v.."' was overriden by a plugin, this is not good!\n");
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to register a new plugin.
	@param {Unknown} Missing description for pluginTable.
	@returns {Unknown}
--]]
function Clockwork.plugin:Register(pluginTable)
	local newBaseDir = Clockwork.kernel:RemoveTextFromEnd(pluginTable.baseDir, "/schema");
	local files, pluginFolders = cwFile.Find(newBaseDir.."/plugins/*", "LUA", "namedesc");

	stored[pluginTable.name] = pluginTable;
	stored[pluginTable.name].plugins = {};
	
	for k, v in pairs(pluginFolders) do
		if (v != ".." and v != ".") then
			table.insert(stored[pluginTable.name].plugins, v);
		end;
	end;
	
	if (!self:IsUnloaded(pluginTable.folderName)) then
		self:IncludeExtras(pluginTable:GetBaseDir());
	
		if (CLIENT and Schema != pluginTable) then
			pluginTable.helpID = Clockwork.directory:AddCode("HelpPlugins", [[
				<div class="cwTitleSeperator">
					<lang>]]..pluginTable:GetName()..[[</lang>
				</div>
				<div class="cwContentText">
					<div class="cwCodeText">]]..pluginTable:GetAuthor()..[[</div>
					<lang>]]..string.gsub(pluginTable:GetDescription(), "\\n", "<br>")..[[</lang>
				</div>
				<br>
			]], true, pluginTable:GetAuthor());
		end;
	end;
	
	--[[
		Schema functions shouldn't be overriden. There's always a way to do it
		with plugins, so this will be warned against!
	--]]
	if (Schema == pluginTable) then
		Schema.__funcIdx = {};
		
		for k, v in pairs(Schema) do
			if (type(v) == "function") then
				Schema.__funcIdx[k] = tostring(v);
			end;
		end;
	end;

	self:IncludePlugins(newBaseDir);
end;

--[[
	@codebase Shared
	@details A function to find a plugin by an ID.
	@param {Unknown} Missing description for identifier.
	@returns {Unknown}
--]]
function Clockwork.plugin:FindByID(identifier)
	return stored[identifier];
end;

--[[
	@codebase Shared
	@details A function to determine whether the framework supports a particular plugin.
	@param {Unknown} Missing description for compatibility.
	@param {Unknown} Missing description for name.
	@param {Unknown} Missing description for version.
	@param {Unknown} Missing description for build.
	@returns {Unknown}
--]]
function Clockwork.plugin:CompareVersion(compatibility, name, version, build)
	if (tostring(compatibility) == Clockwork.kernel:GetVersionBuild()) then
		return false;
	end;

	local exploded = string.Explode("-", compatibility);
	local pluginVersion = exploded[1] or {compatibility};
	local pluginBuild = exploded[2];

	if (pluginVersion > version) then
		return true;
	elseif (pluginVersion == version) then
		if (pluginBuild and build) then
			if (pluginBuild > build) then
				return true;
			end;
		elseif (!pluginBuild) then
			return true;
		end;
	end;

	return false;
end;

--[[
	@codebase Shared
	@details A function to include a plugin.
	@param {Unknown} Missing description for directory.
	@param {Unknown} Missing description for isSchema.
	@returns {Unknown}
--]]
function Clockwork.plugin:Include(directory, isSchema)
	local schemaFolder = Clockwork.kernel:GetSchemaFolder();
	local explodeDir = string.Explode("/", directory);
	local folderName = explodeDir[#explodeDir - 1];
	local pathCRC = util.CRC(directory);
	
	PLUGIN_BASE_DIR = directory;
	PLUGIN_FOLDERNAME = folderName;
	
	if (isSchema) then
		PLUGIN = self:New(); Schema = PLUGIN;
		
		if (SERVER) then
			local schemaInfo = Clockwork.kernel:GetSchemaGamemodeInfo();
			
			table.Merge(Schema, schemaInfo);
			
			CW_SCRIPT_SHARED.schemaData = schemaInfo;
		elseif (CW_SCRIPT_SHARED.schemaData) then
			table.Merge(Schema, CW_SCRIPT_SHARED.schemaData);
		end;
		
		if (cwFile.Exists(directory.."/sh_schema.lua", "LUA")) then
			AddCSLuaFile(directory.."/sh_schema.lua");
			include(directory.."/sh_schema.lua");
		else
			MsgC(Color(255, 100, 0, 255), "\n[Clockwork:Plugin] The schema has no sh_schema.lua.\n");
		end;

		Schema:Register();
	else
		local originalPLUGIN = PLUGIN;

		PLUGIN = self:New();
		
		if (SERVER) then
			local iniDir = "gamemodes/"..Clockwork.kernel:RemoveTextFromEnd(directory, "/plugin"); 
			local iniTable = Clockwork.config:LoadINI(iniDir.."/plugin.ini", true, true);

			if (iniTable) then
				if (iniTable["Plugin"]) then
					iniTable = iniTable["Plugin"];
					iniTable.isUnloaded = self:IsUnloaded(PLUGIN_FOLDERNAME, true);
					
					table.Merge(PLUGIN, iniTable);
					
					CW_SCRIPT_SHARED.plugins[pathCRC] = iniTable;
				else
					MsgC(Color(255, 100, 0, 255), "\n[Clockwork:Plugin] The "..PLUGIN_FOLDERNAME.." plugin has no plugin.ini!\n");
				end;

				if (iniTable["compatibility"]) then
					local compatibility = iniTable["compatibility"];
					local versionBuild = Clockwork.kernel:GetVersionBuild();
					local version = Clockwork.kernel:GetVersion();
					local build = Clockwork.kernel:GetBuild();
					local name = iniTable["name"] or PLUGIN_FOLDERNAME;
					
					if (self:CompareVersion(compatibility, name, version, build)) then
						MsgC(Color(255, 165, 0), "[Clockwork:Plugin] The "..name.." plugin ["..compatibility.."] may not be compatible with Clockwork "..versionBuild.."!\nYou might need to update your framework!\n");
					end;
				else
					MsgC(Color(255,165,0),"[Clockwork:Plugin] The "..PLUGIN_FOLDERNAME.." plugin has no compatibility value set!\n");
				end
			end;
		else
			local iniTable = CW_SCRIPT_SHARED.plugins[pathCRC];
			
			if (iniTable) then
				table.Merge(PLUGIN, iniTable);
				
				if (iniTable.isUnloaded) then
					unloaded[PLUGIN_FOLDERNAME] = true;
				end;
			else
				MsgC(Color(255, 100, 0, 255), "\n[Clockwork:Plugin] The "..PLUGIN_FOLDERNAME.." plugin has no plugin.ini!\n");
			end;
		end;
		
		local isUnloaded = self:IsUnloaded(PLUGIN_FOLDERNAME, true);
		local isDisabled = self:IsDisabled(PLUGIN_FOLDERNAME, true);
		local shPluginDir = directory.."/sh_plugin.lua";
		local addCSLua = true;
		
		if (!isUnloaded and !isDisabled) then
			if (cwFile.Exists(shPluginDir, "LUA")) then
				Clockwork.kernel:IncludePrefixed(shPluginDir);
			end;
			
			addCSLua = false;
		end;
		
		if (SERVER and addCSLua) then
			AddCSLuaFile(shPluginDir);
		end;
		
		PLUGIN:Register();
		PLUGIN = originalPLUGIN;
	end;
end;

--[[
	@codebase Shared
	@details A function to create a new plugin.
	@returns {Unknown}
--]]
function Clockwork.plugin:New()
	local pluginTable = Clockwork.kernel:NewMetaTable(PLUGIN_META);
	pluginTable.baseDir = PLUGIN_BASE_DIR;
	pluginTable.folderName = PLUGIN_FOLDERNAME;
	
	return pluginTable;
end;

--[[
	@codebase Shared
	@details A function to sort a list of plugins storted by k, v.
	@param {Unknown} Missing description for pluginList.
	@returns {Unknown}
--]]
function Clockwork.plugin:SortList(pluginList)
	local sortedTable = {};
	
	for k, v in pairs(pluginList) do
		sortedTable[#sortedTable + 1] = v;
	end;
	
	--[[table.sort(sortedTable, function(a, b)
		return a:GetHookOrder() > b:GetHookOrder();
	end);]]
	
	return sortedTable;
end;

--[[
	@codebase Shared
	@details A function to clear the hook cache for all hooks or a specific one.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
function Clockwork.plugin:ClearHookCache(name)
	if (!name) then
		hookCache = {};
	elseif (hookCache[name]) then
		hookCache[name] = nil;
	else
	    MsgC(Color(255, 100, 0, 255), "[Clockwork:Plugin] Attempted to clear cache for invalid hook '"..name.."'");
	end;
end;

--[[
	@codebase Shared
	@details A function to run the plugin hooks.
	@param {Unknown} Missing description for name.
	@param {Unknown} Missing description for isGamemode.
	@param {Unknown} Missing description for ....
	@returns {Unknown}
--]]
function Clockwork.plugin:RunHooks(name, isGamemode, ...)
	if (not self.sortedModules) then
		self.sortedModules = self:SortList(modules);
	end;
	
	if (not self.sortedPlugins) then
		self.sortedPlugins = self:SortList(stored);
	end;

	local cache = hookCache[name];
	
	if (not cache) then
		cache = {};
		
		for k, v in ipairs(self.sortedModules) do
			if (modules[v.name] and v[name]) then
				table.insert(cache, {v[name], v});
			end;
		end;

		for k, v in ipairs(self.sortedPlugins) do
			if (stored[v.name] and Schema != v and v[name]) then
				table.insert(cache, {v[name], v});
			end;
		end;

		if (Schema and Schema[name]) then
			table.insert(cache, {Schema[name], Schema});
		end;

		hookCache[name] = cache;
	end;

	for k, v in ipairs(cache) do
		local wasSuccess, value = pcall(v[1], v[2], ...);
			
		if (!wasSuccess) then
			MsgC(Color(255, 100, 0, 255), "\n[Clockwork:"..v[2].name.."]\nThe '"..name.."' hook has failed to run.\n"..value.."\n");
		elseif (value != nil) then
			return value;
		end;
	end;

	if (isGamemode and Clockwork[name]) then
		local wasSuccess, value = pcall(Clockwork[name], Clockwork, ...);
		
		if (!wasSuccess) then
			MsgC(Color(255, 100, 0, 255), "\n[Clockwork:Kernel]\nThe '"..name.."' Clockwork hook has failed to run.\n"..value.."\n");
		elseif (value != nil) then
			return value;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to call a function for all plugins.
	@param {Unknown} Missing description for name.
	@param {Unknown} Missing description for ....
	@returns {Unknown}
--]]
function Clockwork.plugin:Call(name, ...)
	return self:RunHooks(name, true, ...);
end;

--[[
	@codebase Shared
	@details A function to remove a module by name.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
function Clockwork.plugin:Remove(name)
	modules[name] = nil;
end;

--[[
	@codebase Shared
	@details A function to add a table as a module.
	@param {Unknown} Missing description for name.
	@param {Unknown} Missing description for moduleTable.
	@param {Unknown} Missing description for hookOrder.
	@returns {Unknown}
--]]
function Clockwork.plugin:Add(name, moduleTable, hookOrder)
	if (not moduleTable.name) then
		moduleTable.name = name;
	end;
	
	moduleTable.hookOrder = hookOrder or 0;
	
	modules[name] = moduleTable;
end;

--[[
	@codebase Shared
	@details A function to include a plugin's entities.
	@param {Unknown} Missing description for directory.
	@returns {Unknown}
--]]
function Clockwork.plugin:IncludeEntities(directory)
	local files, entityFolders = cwFile.Find(directory.."/entities/entities/*", "LUA", "namedesc");

	for k, v in pairs(entityFolders) do
		if (v != ".." and v != ".") then
			ENT = {Type = "anim", Folder = directory.."/entities/entities/"..v};
			
			if (SERVER) then
				if (file.Exists("gamemodes/"..directory.."/entities/entities/"..v.."/init.lua", "GAME")) then
					include(directory.."/entities/entities/"..v.."/init.lua");
				elseif (file.Exists("gamemodes/"..directory.."/entities/entities/"..v.."/shared.lua", "GAME")) then
					include(directory.."/entities/entities/"..v.."/shared.lua");
				end;
				
				if (file.Exists("gamemodes/"..directory.."/entities/entities/"..v.."/cl_init.lua", "GAME")) then
					AddCSLuaFile(directory.."/entities/entities/"..v.."/cl_init.lua");
				end;
			elseif (cwFile.Exists(directory.."/entities/entities/"..v.."/cl_init.lua", "LUA")) then
				include(directory.."/entities/entities/"..v.."/cl_init.lua");
			elseif (cwFile.Exists(directory.."/entities/entities/"..v.."/shared.lua", "LUA")) then
				include(directory.."/entities/entities/"..v.."/shared.lua");
			end;
			
			scripted_ents.Register(ENT, v); ENT = nil;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to include a plugin's effects.
	@param {Unknown} Missing description for directory.
	@returns {Unknown}
--]]
function Clockwork.plugin:IncludeEffects(directory)
	local files, effectFolders = cwFile.Find(directory.."/entities/effects/*", "LUA", "namedesc");
	
	for k, v in pairs(effectFolders) do
		if (v != ".." and v != ".") then
			if (SERVER) then
				if (cwFile.Exists("gamemodes/"..directory.."/entities/effects/"..v.."/cl_init.lua", "GAME")) then
					AddCSLuaFile(directory.."/entities/effects/"..v.."/cl_init.lua");
				elseif (cwFile.Exists("gamemodes/"..directory.."/entities/effects/"..v.."/init.lua", "GAME")) then
					AddCSLuaFile(directory.."/entities/effects/"..v.."/init.lua");
				end;
			elseif (cwFile.Exists(directory.."/entities/effects/"..v.."/cl_init.lua", "LUA")) then
				EFFECT = {Folder = directory.."/entities/effects/"..v};
					include(directory.."/entities/effects/"..v.."/cl_init.lua");
				effects.Register(EFFECT, v); EFFECT = nil;
			elseif (cwFile.Exists(directory.."/entities/effects/"..v.."/init.lua", "LUA")) then
				EFFECT = {Folder = directory.."/entities/effects/"..v};
					include(directory.."/entities/effects/"..v.."/init.lua");
				effects.Register(EFFECT, v); EFFECT = nil;
			end;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to include a plugin's weapons.
	@param {Unknown} Missing description for directory.
	@returns {Unknown}
--]]
function Clockwork.plugin:IncludeWeapons(directory)
	local files, weaponFolders = cwFile.Find(directory.."/entities/weapons/*", "LUA");

	for k, v in pairs(weaponFolders) do
		if (v != ".." and v != ".") then
			SWEP = { Folder = directory.."/entities/weapons/"..v, Base = "weapon_base", Primary = {}, Secondary = {} };
			
			if (SERVER) then
				if (file.Exists("gamemodes/"..directory.."/entities/weapons/"..v.."/init.lua", "GAME")) then
					include(directory.."/entities/weapons/"..v.."/init.lua");
				elseif (file.Exists("gamemodes/"..directory.."/entities/weapons/"..v.."/shared.lua", "GAME")) then
					include(directory.."/entities/weapons/"..v.."/shared.lua");
				end;
				
				if (file.Exists("gamemodes/"..directory.."/entities/weapons/"..v.."/cl_init.lua", "GAME")) then
					AddCSLuaFile(directory.."/entities/weapons/"..v.."/cl_init.lua");
				end;
			elseif (cwFile.Exists(directory.."/entities/weapons/"..v.."/cl_init.lua", "LUA")) then
				include(directory.."/entities/weapons/"..v.."/cl_init.lua");
			elseif (cwFile.Exists(directory.."/entities/weapons/"..v.."/shared.lua", "LUA")) then
				include(directory.."/entities/weapons/"..v.."/shared.lua");
			end;
			
			weapons.Register(SWEP, v); SWEP = nil;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to include a plugin's plugins.
	@param {Unknown} Missing description for directory.
	@returns {Unknown}
--]]
function Clockwork.plugin:IncludePlugins(directory)
	local files, pluginFolders = cwFile.Find(directory.."/plugins/*", "LUA", "namedesc");
	
	if (!self:HasInitialized()) then
		self:Initialize();
	end;
	
	for k, v in pairs(pluginFolders) do
		self:Include(directory.."/plugins/"..v.."/plugin");
	end;
end;

--[[
	@codebase Shared
	@details A function to add an extra folder to include for plugins.
	@param {Unknown} Missing description for folderName.
	@returns {Unknown}
--]]
function Clockwork.plugin:AddExtra(folderName)
	if (!table.HasValue(extras, folderName)) then
		extras[#extras + 1] = folderName;
	end;
end;

--[[
	@codebase Shared
	@details A function to include a plugin's extras.
	@param {Unknown} Missing description for directory.
	@returns {Unknown}
--]]
function Clockwork.plugin:IncludeExtras(directory)
	self:IncludeEffects(directory);
	self:IncludeWeapons(directory);
	self:IncludeEntities(directory);

	for k, v in ipairs(extras) do
		Clockwork.kernel:IncludeDirectory(directory..v);
	end;
end;

Clockwork.plugin:AddExtra("/libraries/");
Clockwork.plugin:AddExtra("/directory/");
Clockwork.plugin:AddExtra("/system/");
Clockwork.plugin:AddExtra("/factions/");
Clockwork.plugin:AddExtra("/classes/");
Clockwork.plugin:AddExtra("/traits/");
Clockwork.plugin:AddExtra("/attributes/");
Clockwork.plugin:AddExtra("/items/");
Clockwork.plugin:AddExtra("/derma/");
Clockwork.plugin:AddExtra("/commands/");
Clockwork.plugin:AddExtra("/language/");
Clockwork.plugin:AddExtra("/config/");
Clockwork.plugin:AddExtra("/tools/");
Clockwork.plugin:AddExtra("/blueprints/");
Clockwork.plugin:AddExtra("/themes/");

--[[ This table will hold the plugin info, if it doesn't already exist. --]]
CW_SCRIPT_SHARED.plugins = CW_SCRIPT_SHARED.plugins or {};
