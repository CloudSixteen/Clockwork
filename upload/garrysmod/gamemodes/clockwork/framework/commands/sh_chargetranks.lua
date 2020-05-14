--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("CharGetRanks");

COMMAND.tip = "Gets all available ranks from a character.";
COMMAND.text = "<string Name>";
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);

	if (!target) then
		Clockwork.player:Notify(player, {"NotValidCharacter", arguments[1]});
		return;
	end;

	local faction = Clockwork.faction:FindByID(target:GetFaction());
	local ranksCollection = "";

	if (faction and istable(faction.ranks)) then
		local i = 0;
		local count = table.Count(faction.ranks);

		for k, v in pairs(faction.ranks) do
			i = i + 1;

			if (i != count) then
				ranksCollection = ranksCollection.. k ..", ";
			else
				ranksCollection = ranksCollection.. k;
			end;
		end;

		Clockwork.player:Notify(player, {"FactionRanksPrintedConsole"});

		player:PrintMessage(2, {"AvailableRanksForFaction", faction.name});
		player:PrintMessage(2, ranksCollection);
	else
		Clockwork.player:Notify(player, {"CharFactionNoRanks"});
	end;
end;

COMMAND:Register();
