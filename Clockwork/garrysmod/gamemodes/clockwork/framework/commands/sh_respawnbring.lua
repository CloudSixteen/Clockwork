local PLUGIN = PLUGIN;

local COMMAND = Clockwork.command:New("RespawnBring");
COMMAND.tip = "Respawn a player at your crosshairs location.";
COMMAND.text = "<string Name>";
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1])
	local echo = Clockwork.config:Get("admin_echoes"):Get()
	if (target) then
		local trace = player:GetEyeTrace()
		local pos = trace.HitPos
		target:Spawn()
		target:SetPos(pos)
		if (echo) then
			Clockwork.player:NotifyAll(player:Name().." has respawned "..target:Name()..", and brought them to their crosshair location.")
		end;
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid player!")
	end;
end;

COMMAND:Register();