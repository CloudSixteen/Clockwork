local PLUGIN = PLUGIN;

local COMMAND = Clockwork.command:New("CharTie");
COMMAND.tip = "Tie/Untie a player.";
COMMAND.text = "<string Name>";
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);

	if (!Clockwork.command:FindByID("InvZipTie")) then
		player:Notify("This schema doesn't support tying.");
		return;
	end;

	if (target) then
		if (target:GetSharedVar("tied") != 0) then
			Schema:TiePlayer(target, false);
			player:Notify("You untied "..target:GetName()..".");
			target:Notify("You were untied by "..player:GetName()..".");
		else
			Schema:TiePlayer(target, true);
			player:Notify("You tied "..target:GetName()..".");
			target:Notify("You were tied by "..player:GetName()..".");
		end
	else
		player:Notify(arguments[2].." is not a valid player!");
	end
end;

COMMAND:Register();