local PLUGIN = PLUGIN;

local COMMAND = Clockwork.command:New("PlyIgnite");
COMMAND.tip = "Ignite/unignite a player.";
COMMAND.text = "<string Name> [number Seconds]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local seconds = arguments[2] or 30;
	local echo = Clockwork.config:Get("admin_echoes"):Get();
	if (target and target:Alive()) then
		if (target:IsOnFire() and !arguments[2]) then
			target:Extinguish();
			
			if (echo) then
				Clockwork.player:NotifyAll(player:Name().." has unignited "..target:Name()..".");
			end
			
			return;
		end
		
		target:Ignite(seconds);
		if (echo) then
			Clockwork.player:NotifyAll(player:Name().." has ignited "..target:Name()..".");
		end
	else		
		Clockwork.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

COMMAND:Register();