--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CharTransfer");
COMMAND.tip = "Transfer a character to a faction.";
COMMAND.text = "<string Name> <string Faction> [string Data]";
COMMAND.access = "o";
COMMAND.arguments = 2;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1])
	
	if (target) then
		local faction = arguments[2];
		local name = target:Name();
		
		if (!Clockwork.faction.stored[faction]) then
			Clockwork.player:Notify(player, faction.." is not a valid faction!");
			return;
		end;
		
		if (!Clockwork.faction.stored[faction].whitelist or Clockwork.player:IsWhitelisted(target, faction)) then
			local targetFaction = target:GetFaction();
			
			if (targetFaction == faction) then
				Clockwork.player:Notify(player, target:Name().." is already the "..faction.." faction!");
				return;
			end;
			
			if (!Clockwork.faction:IsGenderValid(faction, target:GetGender())) then
				Clockwork.player:Notify(player, target:Name().." is not the correct gender for the "..faction.." faction!");
				return;
			end;
			
			if (!Clockwork.faction.stored[faction].OnTransferred) then
				Clockwork.player:Notify(player, target:Name().." cannot be transferred to the "..faction.." faction!");
				return;
			end;
			
			local bSuccess, fault = Clockwork.faction.stored[faction]:OnTransferred(target, Clockwork.faction.stored[targetFaction], arguments[3]);
			
			if (bSuccess != false) then
				target:SetCharacterData("Faction", faction, true);
				
				Clockwork.player:LoadCharacter(target, Clockwork.player:GetCharacterID(target));
				Clockwork.player:NotifyAll(player:Name().." has transferred "..name.." to the "..faction.." faction.");
			else
				Clockwork.player:Notify(player, fault or target:Name().." could not be transferred to the "..faction.." faction!");
			end;
		else
			Clockwork.player:Notify(player, target:Name().." is not on the "..faction.." whitelist!");
		end;
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

COMMAND:Register();