--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyBan");

COMMAND.tip = "CmdPlyBan";
COMMAND.text = "CmdPlyBanDesc";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 2;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local schemaFolder = Clockwork.kernel:GetSchemaFolder();
	local duration = tonumber(arguments[2]);
	local reason = table.concat(arguments, " ", 3);
	
	if (!reason or reason == "") then
		reason = nil;
	end;
	
	if (!Clockwork.player:IsProtected(arguments[1])) then
		if (duration) then
			Clockwork.bans:Add(arguments[1], duration * 60, reason, function(steamName, duration, reason)
				if (IsValid(player)) then
					if (steamName) then
						if (duration > 0) then
							local hours = math.Round(duration / 3600);
							
							if (hours >= 1) then
								Clockwork.player:NotifyAll({"PlayerBannedPlayerHours", player:Name(), steamName, hours, reason});
							else
								Clockwork.player:NotifyAll({"PlayerBannedPlayerMinutes", player:Name(), steamName, math.Round(duration / 60), reason});
							end;
						else
							Clockwork.player:NotifyAll({"PlayerBannedPlayerPerma", player:Name(), steamName, reason});
						end;
					else
						Clockwork.player:Notify(player, {"IdentifierIsNotValid", steamName});
					end;
				end;
			end);
		else
			Clockwork.player:Notify(player, {"DurationNotValid"});
		end;
	else
		local target = Clockwork.player:FindByID(arguments[1]);
		
		if (target) then
			Clockwork.player:Notify(player, {"PlayerHasProtectionStatus", target:Name()});
		else
			Clockwork.player:Notify(player, {"PlayerHasProtectionOffline"});
		end;
	end;
end;

COMMAND:Register();