--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("AnimDeny");

COMMAND.tip = "Make your character stick his hand out to deny access.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.cwNextStance or curTime >= player.cwNextStance) then
		player.cwNextStance = curTime + 2;
		
		local modelClass = Clockwork.animation:GetModelClass(player:GetModel());
		
		if (modelClass == "civilProtection") then
			local forcedAnimation = player:GetForcedAnimation();
			
			if (forcedAnimation and cwEmoteAnims.stanceList[forcedAnimation.animation]) then
				Clockwork.player:Notify(player, {"CannotActionRightNow"});
			else
				player:SetForcedAnimation("harassfront2", 1.5);
				player:SetSharedVar("StancePos", player:GetPos());
				player:SetSharedVar("StanceAng", player:GetAngles());
				player:SetSharedVar("StanceIdle", false);
			end;
		else
			Clockwork.player:Notify(player, {"ModelCannotDoThisAction"});
		end;
	else
		Clockwork.player:Notify(player, {"CannotDoAnotherGestureYet"});
	end;
end;

COMMAND:Register();

if (CLIENT) then
	Clockwork.quickmenu:AddCommand(COMMAND.name, "Emotes", COMMAND.name);
end;