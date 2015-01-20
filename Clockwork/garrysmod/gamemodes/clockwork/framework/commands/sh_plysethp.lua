local PLUGIN = PLUGIN;

local COMMAND = Clockwork.command:New("PlySetHP");
COMMAND.tip = "Set a player's HP.";
COMMAND.text = "<string Name> [number Amount]";
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	if (target) then
		if (!arguments[2]) then
			target:SetHealth(target:GetMaxHealth());
			target:Notify("Your health has been set to "..target:GetMaxHealth()..".");
			player:Notify("You set "..target:Name().."'s health to "..target:GetMaxHealth()..".");
			return;
		end;
		target:SetHealth(tonumber(arguments[2]));
		target:Notify("Your health has been set to "..tonumber(arguments[2])..".");
		player:Notify("You set "..target:Name().."'s health to "..tonumber(arguments[2])..".");
	else
		player:Notify(arguments[1].." is not a valid player!");
	end;
end;

COMMAND:Register();