--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlySetGroup");

COMMAND.tip = "CmdPlySetGroup";
COMMAND.text = "CmdPlySetGroupDesc";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command is ran from the server console.
function COMMAND:OnConsoleRun(arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local userGroup = arguments[2];
	
	if (userGroup != "superadmin" and userGroup != "admin"
	and userGroup != "operator") then
		print(L("UserGroupMustBeAdminType"));
		return;
	end;
	
	if (target) then
		if (!Clockwork.player:IsProtected(target)) then
			Clockwork.player:NotifyAll({"PlayerSetPlayerGroupTo", L("ConsoleUser"), target:Name()});
			
			target:SetClockworkUserGroup(userGroup);
			
			Clockwork.player:LightSpawn(target, true, true);
		else
			print(L("PlayerHasProtectionStatus", target:Name()));
		end;
	else
		Clockwork.player:Notify(player, {"NotValidPlayer", arguments[1]});
	end;
end;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local userGroup = arguments[2];
	
	if (userGroup != "superadmin" and userGroup != "admin"
	and userGroup != "operator") then
		Clockwork.player:Notify(player, {"UserGroupMustBeAdminType"});
		return;
	end;
	
	if (target) then
		if (!Clockwork.player:IsProtected(target)) then
			Clockwork.player:NotifyAll({"PlayerSetPlayerGroupTo", player:Name(), target:Name()});
			
			target:SetClockworkUserGroup(userGroup);
			
			Clockwork.player:LightSpawn(target, true, true);
		else
			Clockwork.player:Notify(player, {"PlayerHasProtectionStatus", target:Name()});
		end;
	else
		Clockwork.player:Notify(player, {"NotValidPlayer", arguments[1]});
	end;
end;

COMMAND:Register();