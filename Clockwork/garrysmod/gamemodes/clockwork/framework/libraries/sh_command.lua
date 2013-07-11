--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
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
Clockwork.command.stored = {};
Clockwork.command.hidden = {};

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

-- A function to register a new command.
function CLASS_TABLE:Register()
	return Clockwork.command:Register(self, self.name);
end;

-- A function to get a new command.
function Clockwork.command:New(name)
	local object = Clockwork.kernel:NewMetaTable(CLASS_TABLE);
		object.name = name or "Unknown";
	return object;
end;

-- A function to set whether a command is hidden.
function Clockwork.command:SetHidden(name, hidden)
	local uniqueID = string.lower(string.gsub(name, "%s", ""));
	
	if (!hidden and self.hidden[uniqueID]) then
		self.stored[uniqueID] = self.hidden[uniqueID];
		self.hidden[uniqueID] = nil;
	elseif (hidden and self.stored[uniqueID]) then
		self.hidden[uniqueID] = self.stored[uniqueID];
		self.stored[uniqueID] = nil;
	end;
	
	if (SERVER) then
		Clockwork.datastream:Start(nil, "HideCommand", {
			index = Clockwork.kernel:GetShortCRC(uniqueID), hidden = hidden
		});
	elseif (hidden and self.hidden[uniqueID]) then
		self:RemoveHelp(self.hidden[uniqueID]);
	elseif (!hidden and self.stored[uniqueID]) then
		self:AddHelp(self.stored[uniqueID]);
	end;
end;

-- A function to register a new command.
function Clockwork.command:Register(data, name)
	local realName = string.gsub(name, "%s", "");
	local uniqueID = string.lower(realName);
	
	if (CLIENT) then
		if (self.stored[uniqueID]) then
			self:RemoveHelp(self.stored[uniqueID]);
		end;
	end;
	
	self.stored[uniqueID] = data;
	self.stored[uniqueID].name = realName;
	self.stored[uniqueID].text = data.text or "<none>";
	self.stored[uniqueID].flags = data.flags or 0;
	self.stored[uniqueID].access = data.access or "b";
	self.stored[uniqueID].arguments = data.arguments or 0;
	
	if (CLIENT) then
		self:AddHelp(self.stored[uniqueID]);
	end;
	
	return self.stored[uniqueID];
end;

-- A function to find a command by an identifier.
function Clockwork.command:FindByID(identifier)
	return self.stored[string.lower(string.gsub(identifier, "%s", ""))];
end;

if (SERVER) then
	function Clockwork.command:ConsoleCommand(player, command, arguments)
		if (player:HasInitialized()) then
			if (arguments and arguments[1]) then
				local realCommand = string.lower(arguments[1]);
				local commandTable = self.stored[realCommand];
				local commandPrefix = Clockwork.config:Get("command_prefix"):Get();
				
				if (commandTable) then
					table.remove(arguments, 1);
					
					for k, v in pairs(arguments) do
						arguments[k] = Clockwork.kernel:Replace(arguments[k], " ' ", "'");
						arguments[k] = Clockwork.kernel:Replace(arguments[k], " : ", ":");
					end;
					
					if (Clockwork.plugin:Call("PlayerCanUseCommand", player, commandTable, arguments)) then
						if (#arguments >= commandTable.arguments) then
							if (Clockwork.player:HasFlags(player, commandTable.access)) then
								local flags = commandTable.flags;
								
								if (Clockwork.player:GetDeathCode(player, true)) then
									if (flags == 0 and CMD_DEATHCODE == 0) then
										Clockwork.player:TakeDeathCode(player);
									end;
								end;
								
								if (bit.band(flags, CMD_DEAD) > 0 and !player:Alive()) then
									if (!player.cwDeathCodeAuth) then
										Clockwork.player:Notify(player, "You cannot do this action at the moment!");
									end; return;
								elseif (bit.band(flags, CMD_VEHICLE) > 0 and player:InVehicle()) then
									if (!player.cwDeathCodeAuth) then
										Clockwork.player:Notify(player, "You cannot do this action at the moment!");
									end; return;
								elseif (bit.band(flags, CMD_RAGDOLLED) > 0 and player:IsRagdolled()) then
									if (!player.cwDeathCodeAuth) then
										Clockwork.player:Notify(player, "You cannot do this action at the moment!");
									end; return;
								elseif (bit.band(flags, CMD_FALLENOVER) > 0 and player:GetRagdollState() == RAGDOLL_FALLENOVER) then
									if (!player.cwDeathCodeAuth) then
										Clockwork.player:Notify(player, "You cannot do this action at the moment!");
									end; return;
								elseif (bit.band(flags, CMD_KNOCKEDOUT) > 0 and player:GetRagdollState() == RAGDOLL_KNOCKEDOUT) then
									if (!player.cwDeathCodeAuth) then
										Clockwork.player:Notify(player, "You cannot do this action at the moment!");
									end; return;
								end;
								
								if (commandTable.OnRun) then
									local bSuccess, value = pcall(commandTable.OnRun, commandTable, player, arguments);

									if (!bSuccess) then
										ErrorNoHalt("[Clockwork] The '"..commandTable.name.."' command has failed to run.\n"..value.."\n");
									elseif (Clockwork.player:GetDeathCode(player, true)) then
										Clockwork.player:UseDeathCode(player, commandTable.name, arguments);
									end;
									
									if (bSuccess) then
										if (table.concat(arguments, " ") != "") then
											Clockwork.kernel:PrintLog(LOGTYPE_GENERIC, player:Name().." has used '"..commandPrefix..commandTable.name.." "..table.concat(arguments, " ").."'.");
										else
											Clockwork.kernel:PrintLog(LOGTYPE_GENERIC, player:Name().." has used '"..commandPrefix..commandTable.name.."'.");
										end;
										
										return value;
									end;
								end;
							else
								Clockwork.player:Notify(player, "You do not have access to this command, "..player:Name()..".");
							end;
						else
							Clockwork.player:Notify(player, commandTable.name.." "..commandTable.text.."!");
						end;
					end;
				elseif (!Clockwork.player:GetDeathCode(player, true)) then
					Clockwork.player:Notify(player, "This is not a valid command!");
				end;
			elseif (!Clockwork.player:GetDeathCode(player, true)) then
				Clockwork.player:Notify(player, "This is not a valid command!");
			end;
			
			if (Clockwork.player:GetDeathCode(player)) then
				Clockwork.player:TakeDeathCode(player);
			end;
		else
			Clockwork.player:Notify(player, "You cannot use commands yet!");
		end;
	end;

	concommand.Add("cwCmd", function(player, command, arguments)
		Clockwork.command:ConsoleCommand(player, command, arguments);
	end);


	hook.Add("PlayerInitialSpawn", "Clockwork.command:PlayerInitialSpawn", function(player)
		local hiddenCommands = {};
		
		for k, v in pairs(Clockwork.command.hidden) do
			hiddenCommands[#hiddenCommands + 1] = Clockwork.kernel:GetShortCRC(k);
		end;
		
		Clockwork.datastream:Start(player, "HiddenCommands", hiddenCommands);
	end);
else
	function Clockwork.command:AddHelp(commandTable)
		local text = string.gsub(string.gsub(commandTable.text, ">", "&gt;"), "<", "&lt;");
		
		if (!commandTable.helpID) then
			commandTable.helpID = Clockwork.directory:AddCode("Commands", [[
				<div class="cwTitleSeperator">
					$command_prefix$]]..string.upper(commandTable.name)..[[
				</div>
				<div class="cwContentText">
					<div class="cwCodeText">
						<i>]]..text..[[</i>
					</div>
					]]..commandTable.tip..[[
				</div>
			]], true, commandTable.name);
		end;
	end;

	-- A function to remove a command's help.
	function Clockwork.command:RemoveHelp(commandTable)
		if (commandTable.helpID) then
			Clockwork.directory:RemoveCode("Commands", commandTable.helpID);
			commandTable.helpID = nil;
		end;
	end;
end;