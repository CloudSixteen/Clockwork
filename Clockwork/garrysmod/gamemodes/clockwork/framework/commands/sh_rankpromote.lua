--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("RankPromote");

COMMAND.tip = "CmdRankPromote";
COMMAND.text = "CmdRankPromoteDesc";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	
	if (!target) then
		Clockwork.player:Notify(player, {"NotValidCharacter", arguments[1]});
		return;
	end;
	
	local isForced = tobool(arguments[2]);

	if (isForced) then
		if (player:IsAdmin()) then
			local highestRank, rankTable = Clockwork.faction:GetHighestRank(target:GetFaction());
			local targetRank, targetRankTable = Clockwork.player:GetFactionRank(target);

			if (istable(rankTable) and targetRankTable.position and targetRankTable.position != rankTable.position) then
				local rank, rankTable = target:GetFactionRank();
				
				Clockwork.player:SetFactionRank(target, Clockwork.faction:GetHigherRank(target:GetFaction(), rankTable));

				Clockwork.player:NotifyAll({"PlayerForcePromoted", player:Name(), target:Name(), (target:GetFactionRank())});
			else
				Clockwork.player:Notify(player, {"YouCannotPromotePlayer"});
			end;
		else
			Clockwork.player:Notify(player, {"ForcePromoteAdminNeeded"});
		end;
	else
		if (player:GetFaction() == target:GetFaction()) then
			if (Clockwork.player:CanPromote(player, target)) then
				local rank, rankTable = target:GetFactionRank();

				Clockwork.player:SetFactionRank(target, Clockwork.faction:GetHigherRank(target:GetFaction(), rankTable));

				Clockwork.player:NotifyAll({"PlayerPromotedPlayer", player:Name(), target:Name(), (target:GetFactionRank())});
			else
				Clockwork.player:Notify(player, {"PromotePermsNeeded"});
			end;
		else
			Clockwork.player:Notify(player, {"PromoteFactionOnly"});
		end;
	end;
end;

COMMAND:Register();
