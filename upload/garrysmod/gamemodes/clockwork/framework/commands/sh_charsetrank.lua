--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("CharSetRank");

COMMAND.tip = "Set a characters rank.";
COMMAND.text = "<string Name> <string Rank> [bool noModelChange]";
COMMAND.access = "a";
COMMAND.arguments = 2;
COMMAND.optionalArgument = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local rankArg = arguments[2];
	local noModelChange = tobool(arguments[3]);
	
	if (!target) then
		Clockwork.player:Notify(player, {"NotValidCharacter", arguments[1]});
		return;
	end;
	
	local faction = Clockwork.faction:FindByID(target:GetFaction());
	
	if (faction and istable(faction.ranks)) then
		local i = 0;
		for k, v in pairs(faction.ranks) do
			i = i + 1;
			if (string.lower(k) == string.lower(rankArg)) then
				Clockwork.player:SetFactionRank(target, k, noModelChange);
				
				Clockwork.player:NotifyAll(player:Name().." set "..target:Name().."'s rank to '"..k.."'.");
				
				break;
			end;
			
			if(i == table.Count(faction.ranks)) then
				Clockwork.player:Notify(player, rankArg.." is not a valid rank for this faction!");
			end;
		end;
	else
		Clockwork.player:Notify(player, "The faction might does not have any ranks!");
	end;
end;

COMMAND:Register();
