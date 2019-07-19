--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local ErrorNoHalt = ErrorNoHalt;
local pairs = pairs;
local pcall = pcall;
local concommand = concommand;
local string = string;
local table = table;
local hook = hook;

Clockwork.command = Clockwork.kernel:NewLibrary("Command");
Clockwork.command.stored = Clockwork.command.stored or {};

local hidden = {};
local alias = {};

CMD_KNOCKEDOUT = 2;
CMD_FALLENOVER = 4;
CMD_DEATHCODE = 8;
CMD_RAGDOLLED = 16;
CMD_VEHICLE = 32;
CMD_DEAD = 64;

CMD_DEFAULT = bit.bor(CMD_DEAD, CMD_KNOCKEDOUT);
CMD_HEAVY = bit.bor(CMD_DEAD, CMD_RAGDOLLED);
CMD_ALL = bit.bor(CMD_DEAD, CMD_VEHICLE, CMD_RAGDOLLED);

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {__index = CLASS_TABLE};

--[[
	@codebase Shared
	@details A function to register a new command.
	@returns {Unknown}
--]]
function CLASS_TABLE:Register()
	return Clockwork.command:Register(self, self.name);
end;

--[[
	@codebase Shared
	@details A function to get all stored commands.
	@returns {Unknown}
--]]
function Clockwork.command:GetAll()
	return self.stored;
end;

--[[
	@codebase Shared
	@details A function to get a new command.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
function Clockwork.command:New(name)
	local object = Clockwork.kernel:NewMetaTable(CLASS_TABLE);
		object.name = name or "Unknown";
	return object;
end;

--[[
	@codebase Shared
	@details A function to remove a command.
	@param {Unknown} Missing description for identifier.
	@returns {Unknown}
--]]
function Clockwork.command:RemoveByID(identifier)
	self.stored[string.lower(string.gsub(identifier, "%s", ""))] = nil;
end;

--[[
	@codebase Shared
	@details A function to set whether a command is hidden.
	@param {Unknown} Missing description for name.
	@param {Unknown} Missing description for isHidden.
	@returns {Unknown}
--]]
function Clockwork.command:SetHidden(name, isHidden)
	local uniqueID = string.lower(string.gsub(name, "%s", ""));

	if (!isHidden and hidden[uniqueID]) then
		self.stored[uniqueID] = hidden[uniqueID];
		hidden[uniqueID] = nil;
	elseif (hidden and self.stored[uniqueID]) then
		hidden[uniqueID] = self.stored[uniqueID];
		self.stored[uniqueID] = nil;
	end;

	if (SERVER) then
		Clockwork.datastream:Start(nil, "HideCommand", {
			index = Clockwork.kernel:GetShortCRC(uniqueID), 
			hidden = isHidden
		});
	elseif (isHidden and hidden[uniqueID]) then
		self:RemoveHelp(hidden[uniqueID]);
	elseif (!isHidden and self.stored[uniqueID]) then
		self:AddHelp(self.stored[uniqueID]);
	end;
end;

--[[
	@codebase Shared
	@details A function to register a new command.
	@param {Unknown} Missing description for data.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
function Clockwork.command:Register(data, name)
	local realName = string.gsub(name, "%s", "");
	local uniqueID = string.lower(realName);

	if (CLIENT) then
		if (self.stored[uniqueID]) then
			self:RemoveHelp(self.stored[uniqueID]);
		end;
	end;
	
 	alias[uniqueID] = uniqueID;
 
 	if (data.alias and type(data.alias) == "table") then
 		for k, v in pairs(data.alias) do
 			alias[string.lower(tostring(v))] = uniqueID;
 		end;
 	end;

	self.stored[uniqueID] = data;
	self.stored[uniqueID].name = realName;
	self.stored[uniqueID].text = data.text or "<none>";
	self.stored[uniqueID].flags = data.flags or 0;
	self.stored[uniqueID].access = data.access or "b";
	self.stored[uniqueID].arguments = data.arguments or 0;

	return self.stored[uniqueID];
end;

--[[
	@codebase Shared
	@details A function to find a command by an identifier.
	@param {Unknown} Missing description for identifier.
	@returns {Unknown}
--]]
function Clockwork.command:FindByID(identifier)
	return self.stored[string.lower(string.gsub(identifier, "%s", ""))];
end;

--[[
 	@codebase Shared
 	@details Returns command's table by alias or unique id.
	@param {String} Identifier of the command to find. Can be alias or original command name.
--]]
function Clockwork.command:FindByAlias(identifier)
	return self.stored[alias[string.lower(string.gsub(identifier, "%s", ""))]];
end;

--[[
	@codebase Shared
	@details Add a new alias for a command.
	@param {String} The identifier of the command to alias.
	@param {String} The name of the alias.
--]]
function Clockwork.command:AddAlias(identifier, name)
	local uniqueID = string.lower(string.gsub(identifier, "%s", ""));
	local lowerName = string.lower(string.gsub(name, "%s", ""));

	if (self.stored[uniqueID]) then
		alias[lowerName] = uniqueID;
	end;
end;
 
--[[
	@codebase Shared
	@details Returns table of all command alias indexed by alias' names.
--]]
function Clockwork.command:GetAlias()
	return alias;
end;

--[[
	@codebase Shared
	@details Whether or not the player has access to the command.
	@param {Userdata} The player whose access to check.
	@param {Table:String} The command name or command table to check against.
--]]
function Clockwork.command:HasAccess(player, command)
	if (type(command) == "string") then
		command = self:FindByAlias(command);
	end;
	
	if (!Clockwork.player:HasFlags(player, command.access)) then
		return false;
	end;
	
	local faction = player:GetFaction();
	local team = player:Team();
	
	if (command.factions) then
		if (!table.HasValue(command.factions, faction)) then
			return false;
		end;
	end;
	
	--[[ Backwards compatibility... --]]
	if (command.faction) then
		if (istable(command.faction)) then
			if (!table.HasValue(command.factions, faction)) then
				return false;
			end;
		elseif (command.faction != faction) then
			return false;
		end;
	end;
	
	if (command.classes) then
		local class = Clockwork.class:FindByID(team);
		
		if (class) then
			if (!table.HasValue(command.classes, team)
			and !table.HasValue(command.classes, class.name)) then
				return false;
			end;
		end;
	end;
	
	return true;
end;

if (SERVER) then
	function Clockwork.command:ConsoleCommand(player, command, arguments)
		if (arguments and arguments[1]) then
			local realCommand = string.lower(arguments[1]);
			local commandTable = self:FindByAlias(realCommand);
			local commandPrefix = Clockwork.config:Get("command_prefix"):Get();

			if (commandTable) then
				table.remove(arguments, 1);

				for k, v in pairs(arguments) do
					arguments[k] = Clockwork.kernel:Replace(arguments[k], " ' ", "'");
					arguments[k] = Clockwork.kernel:Replace(arguments[k], " : ", ":");
				end;

				if (IsValid(player)) then
					if (player:HasInitialized()) then
						if (Clockwork.plugin:Call("PlayerCanUseCommand", player, commandTable, arguments)) then
							if (#arguments >= commandTable.arguments) then
								if (Clockwork.command:HasAccess(player, commandTable)) then
									local flags = commandTable.flags;

									if (Clockwork.player:GetDeathCode(player, true)) then
										if (flags == 0 and CMD_DEATHCODE == 0) then
											Clockwork.player:TakeDeathCode(player);
										end;
									end;

									if (bit.band(flags, CMD_DEAD) > 0 and !player:Alive()) then
										if (!player.cwDeathCodeAuth) then
											Clockwork.player:Notify(player, {"CannotActionRightNow"});
										end; return;
									elseif (bit.band(flags, CMD_VEHICLE) > 0 and player:InVehicle()) then
										if (!player.cwDeathCodeAuth) then
											Clockwork.player:Notify(player, {"CannotActionRightNow"});
										end; return;
									elseif (bit.band(flags, CMD_RAGDOLLED) > 0 and player:IsRagdolled()) then
										if (!player.cwDeathCodeAuth) then
											Clockwork.player:Notify(player, {"CannotActionRightNow"});
										end; return;
									elseif (bit.band(flags, CMD_FALLENOVER) > 0 and player:GetRagdollState() == RAGDOLL_FALLENOVER) then
										if (!player.cwDeathCodeAuth) then
											Clockwork.player:Notify(player, {"CannotActionRightNow"});
										end; return;
									elseif (bit.band(flags, CMD_KNOCKEDOUT) > 0 and player:GetRagdollState() == RAGDOLL_KNOCKEDOUT) then
										if (!player.cwDeathCodeAuth) then
											Clockwork.player:Notify(player, {"CannotActionRightNow"});
										end; return;
									end;

									if (commandTable.OnRun) then
										local wasSuccess, value = pcall(commandTable.OnRun, commandTable, player, arguments);

										if (!wasSuccess) then
											MsgC(Color(255, 100, 0, 255), "\n[Clockwork:Command]\nThe '"..commandTable.name.."' command has failed to run.\n"..value.."\n");
										elseif (Clockwork.player:GetDeathCode(player, true)) then
											Clockwork.player:UseDeathCode(player, commandTable.name, arguments);
										end;

										if (wasSuccess) then
											if (table.concat(arguments, " ") != "") then
												Clockwork.kernel:PrintLog(LOGTYPE_GENERIC, {"LogPlayerUsedCommandArgs", player:Name(), commandPrefix..commandTable.name, table.concat(arguments, " ")});
											else
												Clockwork.kernel:PrintLog(LOGTYPE_GENERIC, {"LogPlayerUsedCommand", player:Name(), commandPrefix..commandTable.name});
											end;

											Clockwork.plugin:Call("PostCommandUsed", player, commandTable, arguments);
											
											return value;
										end;
									end;
								else
									Clockwork.player:Notify(player, {"NoAccessToCommand", player:Name()});
								end;
							else
								Clockwork.player:Notify(player, commandTable.name.." "..L(player, commandTable.text).."!");
							end;
						end;
					elseif (!Clockwork.player:GetDeathCode(player, true)) then
						Clockwork.player:Notify(player, {"CannotUseCommandsYet"});
					end;
					
					if (Clockwork.player:GetDeathCode(player)) then
						Clockwork.player:TakeDeathCode(player);
					end;
				elseif (commandTable.OnConsoleRun) then
					local wasSuccess, value = pcall(commandTable.OnConsoleRun, commandTable, arguments);

					if (!wasSuccess) then
						MsgC(Color(255, 100, 0, 255), "\n[Clockwork:Command]\nThe '"..commandTable.name.."' command has failed to run.\n"..value.."\n");
					end;
				else
					print(L("NotValidCommandOrAlias"));
				end;
			elseif (IsValid(player)) then
				Clockwork.player:Notify(player, {"NotValidCommandOrAlias"});
			end;
		end;
	end;
	
	concommand.Add("cwCmd", function(player, command, arguments)
		Clockwork.command:ConsoleCommand(player, command, arguments);
	end);
	
	hook.Add("PlayerInitialSpawn", "Clockwork.command:PlayerInitialSpawn", function(player)
		local hiddenCommands = {};

		for k, v in pairs(hidden) do
			hiddenCommands[#hiddenCommands + 1] = Clockwork.kernel:GetShortCRC(k);
		end;

		Clockwork.datastream:Start(player, "HiddenCommands", hiddenCommands);
	end);
else
	function Clockwork.command:AddHelp(commandTable)
		local text = string.gsub(string.gsub(commandTable.text, ">", "&gt;"), "<", "&lt;");

		if (!commandTable.helpID) then
			commandTable.helpID = Clockwork.directory:AddCode("HelpCommands", [[
				<div class="cwTitleSeperator">
					$command_prefix$]]..string.upper(commandTable.name)..[[
				</div>
				<div class="cwContentText">
					<div class="cwCodeText">
						<i><lang>]]..text..[[</lang></i>
					</div>
					<lang>]]..commandTable.tip..[[</lang>
				</div>
				<br>
			]], true, commandTable.name);
		end;
	end;

	--[[
		@codebase Shared
		@details A function to remove a command's help.
		@param {Unknown} Missing description for commandTable.
		@returns {Unknown}
	--]]
	function Clockwork.command:RemoveHelp(commandTable)
		if (commandTable.helpID) then
			Clockwork.directory:RemoveCode("Commands", commandTable.helpID);
			commandTable.helpID = nil;
		end;
	end;
end;
