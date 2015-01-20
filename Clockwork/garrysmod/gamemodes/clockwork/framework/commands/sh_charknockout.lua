local PLUGIN = PLUGIN;

local COMMAND = Clockwork.command:New("CharKnockOut");
COMMAND.tip = "Knockout a character.";
COMMAND.text = "<string Name> [number Seconds] [boolean Force Knockout]";
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);

	if (target) then
		if (target:IsFrozen()) then
			player:Notify(target:Name().." is frozen. Ragdolling them will result in unfreezing them: unfreeze them first.");
			return;
		end;

		if (!arguments[2]) then
			Clockwork.player:SetRagdollState(target, RAGDOLL_KNOCKEDOUT, Clockwork.config:Get("knockout_time"):Get());
			target:Notify("Your have been knocked out for "..Clockwork.config:Get("knockout_time"):Get().." seconds.");
			player:Notify("You knocked "..target:Name().." out for "..Clockwork.config:Get("knockout_time"):Get().." seconds.");
		else
			Clockwork.player:SetRagdollState(target, RAGDOLL_KNOCKEDOUT, tonumber(arguments[2]));
			target:Notify("Your have been knocked out for "..tonumber(arguments[2]).." seconds.");
			player:Notify("You knocked "..target:Name().." out for "..tonumber(arguments[2]).." seconds.");
		end;
	else
		player:Notify(arguments[1].." is not a valid player!");
	end;
end;

COMMAND:Register();