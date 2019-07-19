--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CharTransfer");

COMMAND.tip = "CmdCharTransfer";
COMMAND.text = "CmdCharTransferDesc";
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
			Clockwork.player:Notify(player, {"FactionIsNotValid", faction});
			return;
		end;
		
		if (!Clockwork.faction.stored[faction].whitelist or Clockwork.player:IsWhitelisted(target, faction)) then
			local targetFaction = target:GetFaction();
			
			if (targetFaction == faction) then
				Clockwork.player:Notify(player, {"PlayerAlreadyIsFaction", target:Name(), faction});
				return;
			end;
			
			if (!Clockwork.faction:IsGenderValid(faction, target:GetGender())) then
				Clockwork.player:Notify(player, {"PlayerNotCorrectGenderForFaction", target:Name(), faction});
				return;
			end;
			
			if (!Clockwork.faction.stored[faction].OnTransferred) then
				Clockwork.player:Notify(player, {"PlayerCannotTransferToFaction", target:Name(), faction});
				return;
			end;
			
			local wasSuccess, fault = Clockwork.faction.stored[faction]:OnTransferred(target, Clockwork.faction.stored[targetFaction], arguments[3]);
			
			if (wasSuccess != false) then
				target:SetCharacterData("Faction", faction, true);
				
				Clockwork.player:LoadCharacter(target, Clockwork.player:GetCharacterID(target));
				Clockwork.player:NotifyAll({"PlayerTransferredPlayer", player:Name(), name, faction});
			else
				Clockwork.player:Notify(player, fault or {"PlayerCouldNotBeTransferred", target:Name(), faction});
			end;
		else
			Clockwork.player:Notify(player, {"PlayerNotOnFactionWhitelist", target:Name(), faction});
		end;
	else
		Clockwork.player:Notify(player, {"NotValidPlayer", arguments[1]});
	end;
end;

COMMAND:Register();