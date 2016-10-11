--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("RankDemote");

COMMAND.tip = "Demote someone to the next rank down.";
COMMAND.text = "<string Name> [boolean IsForced]";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local isForced = tobool(arguments[2]);

	if (isForced) then
		if (player:IsAdmin()) then
			local lowestRank, rankTable = Clockwork.faction:GetLowestRank(target:GetFaction());
			local targetRank, targetRankTable = Clockwork.player:GetFactionRank(target);

			if (istable(rankTable) and targetRankTable.position and targetRankTable.position != rankTable.position) then
				local rank, rankTable = target:GetFactionRank();
				
				Clockwork.player:SetFactionRank(target, Clockwork.faction:GetLowerRank(target:GetFaction(), rankTable));

				Clockwork.player:NotifyAll({"PlayerForceDemoted", player:Name(), target:Name(), target:GetFactionRank()});
			else
				Clockwork.player:Notify(player, {"YouCannotDemotePlayer"})
			end;
		else
			Clockwork.player:Notify(player, {"ForceDemoteAdminNeeded"});
		end;
	else
		if (player:GetFaction() == target:GetFaction()) then
			if (Clockwork.player:CanDemote(player, target)) then
				local rank, rankTable = target:GetFactionRank();

				Clockwork.player:SetFactionRank(target, Clockwork.faction:GetHigherRank(target:GetFaction(), rankTable));

				Clockwork.player:NotifyAll(player:Name().." has demoted "..target:Name().." to rank "..target:GetFactionRank());
			else
				Clockwork.player:Notify(player, {"DemotePermsNeeded"});
			end;
		else
			Clockwork.player:Notify(player, {"DemoteFactionOnly"});
		end;
	end;
end;

COMMAND:Register();