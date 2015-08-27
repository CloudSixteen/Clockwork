--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlySetGroup");
COMMAND.tip = "Set a player's user group.";
COMMAND.text = "<string Name> <string UserGroup>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local userGroup = arguments[2];
	
	if (userGroup != "superadmin" and userGroup != "admin"
	and userGroup != "operator") then
		Clockwork.player:Notify(player, "The user group must be superadmin, admin or operator!");
		
		return;
	end;
	
	if (target) then
		if (!Clockwork.player:IsProtected(target)) then
			Clockwork.player:NotifyAll(player:Name().." has set "..target:Name().."'s user group to "..userGroup..".");
				target:SetClockworkUserGroup(userGroup);
			Clockwork.player:LightSpawn(target, true, true);
		else
			Clockwork.player:Notify(player, target:Name().." is protected!");
		end;
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

COMMAND:Register();