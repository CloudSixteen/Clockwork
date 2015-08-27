--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyDemote");
COMMAND.tip = "Demote a player from their user group.";
COMMAND.text = "<string Name>";
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
				Clockwork.player:NotifyAll(player:Name().." has demoted "..target:Name().." from "..userGroup.." to user.");
					target:SetClockworkUserGroup("user");
				Clockwork.player:LightSpawn(target, true, true);
			else
				Clockwork.player:Notify(player, "This player is only a user and cannot be demoted!");
			end;
		else
			Clockwork.player:Notify(player, target:Name().." is protected!");
		end;
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

COMMAND:Register();