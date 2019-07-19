--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyDemote");

COMMAND.tip = "CmdPlyDemote";
COMMAND.text = "CmdPlyDemoteDesc";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	
	if (target) then
		if (!Clockwork.player:IsProtected(target)) then
			local userGroup = target:GetClockworkUserGroup();
			
			if (userGroup != "user") then
				Clockwork.player:NotifyAll({"PlayerDemotedUserToGroup", player:Name(), target:Name(), userGroup, "user"});
					target:SetClockworkUserGroup("user");
				Clockwork.player:LightSpawn(target, true, true);
			else
				Clockwork.player:Notify(player, {"PlayerIsOnlyAUser"});
			end;
		else
			Clockwork.player:Notify(player, {"PlayerHasProtectionStatus", target:Name()});
		end;
	else
		Clockwork.player:Notify(player, {"NotValidPlayer", arguments[1]});
	end;
end;

COMMAND:Register();