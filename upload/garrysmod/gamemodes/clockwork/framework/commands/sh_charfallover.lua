--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("CharFallOver");

COMMAND.tip = "CmdCharFallOver";
COMMAND.text = "CmdCharFallOverDesc";
COMMAND.flags = CMD_DEFAULT;
COMMAND.optionalArguments = 1;
COMMAND.alias = {"Fallover"};

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.cwNextFallTime or curTime >= player.cwNextFallTime) then
		player.cwNextFallTime = curTime + 5;
		
		if (!player:InVehicle() and !Clockwork.player:IsNoClipping(player)) then
			local seconds = tonumber(arguments[1]);
			
			if (seconds) then
				seconds = math.Clamp(seconds, 2, 30);
			elseif (seconds == 0) then
				seconds = nil;
			end;
			
			if (!player:IsRagdolled()) then
				Clockwork.player:SetRagdollState(player, RAGDOLL_FALLENOVER, seconds);
				
				player:SetSharedVar("FallenOver", true);
			end;
		else
			Clockwork.player:Notify(player, {"CannotActionRightNow"});
		end;
	end;
end;

COMMAND:Register();