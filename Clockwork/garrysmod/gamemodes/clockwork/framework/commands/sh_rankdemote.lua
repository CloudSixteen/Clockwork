--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("RankDemote");

COMMAND.tip = "Demote someone to the next rank down.";
COMMAND.text = "<string Name> [boolean Force]";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local force = tobool(arguments[2]);

	if (force) then
		if (player:IsAdmin()) then
			local lowestRank, rankTable = Clockwork.faction:GetLowestRank(target:GetFaction());
			local targetRank, targetRankTable = Clockwork.player:GetFactionRank(target);

			if (istable(rankTable) and targetRankTable.position and targetRankTable.position != rankTable.position) then
				local rank, rankTable = target:GetFactionRank();
				
				Clockwork.player:SetFactionRank(target, Clockwork.faction:GetLowerRank(target:GetFaction(), rankTable));

				Clockwork.player:NotifyAll(player:Name().." has force-demoted "..target:Name().." to rank "..target:GetFactionRank());
			else
				Clockwork.player:Notify(player, "You cannot demote this player!")
			end;
		else
			Clockwork.player:Notify(player, "You must be an admin or superadmin to force demote!");
		end;
	else
		if (player:GetFaction() == target:GetFaction()) then
			if (Clockwork.player:CanDemote(player, target)) then
				local rank, rankTable = target:GetFactionRank();

				Clockwork.player:SetFactionRank(target, Clockwork.faction:GetHigherRank(target:GetFaction(), rankTable));

				Clockwork.player:NotifyAll(player:Name().." has demoted "..target:Name().." to rank "..target:GetFactionRank());
			else
				Clockwork.player:Notify(player, "You do not have permission to demote this player.");
			end;
		else
			Clockwork.player:Notify(player, "You can only demote someone within your own faction!");
		end;
	end;
end;

COMMAND:Register();