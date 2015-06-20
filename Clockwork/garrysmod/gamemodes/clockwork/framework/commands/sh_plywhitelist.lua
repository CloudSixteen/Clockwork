--[[
	� 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlyWhitelist");
COMMAND.tip = "Add a player to a whitelist.";
COMMAND.text = "<string Name> <string Faction>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1])
	
	if (target) then
		local factionTable = Clockwork.faction:FindByID(table.concat(arguments, " ", 2));
		
		if (factionTable) then
			if (factionTable.whitelist) then
				if (!Clockwork.player:IsWhitelisted(target, factionTable.name)) then
					Clockwork.player:SetWhitelisted(target, factionTable.name, true);
					Clockwork.player:SaveCharacter(target);
					
					Clockwork.player:NotifyAll(player:Name().." has added "..target:Name().." to the "..factionTable.name.." whitelist.");
				else
					Clockwork.player:Notify(player, target:Name().." is already on the "..factionTable.name.." whitelist!");
				end;
			else
				Clockwork.player:Notify(player, factionTable.name.." does not have a whitelist!");
			end;
		else
			Clockwork.player:Notify(player, table.concat(arguments, " ", 2).." is not a valid faction!");
		end;
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

COMMAND:Register();