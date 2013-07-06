--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("AnimMotion");
COMMAND.tip = "Make your character motion to something in a direction.";
COMMAND.text = "<string Left|Right|Behind>";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.cwNextStance or curTime >= player.cwNextStance) then
		player.cwNextStance = curTime + 2.5;
		
		local modelClass = Clockwork.animation:GetModelClass(player:GetModel());
		local action = string.lower(arguments[1] or "");
		
		if (modelClass == "civilProtection") then
			local forcedAnimation = player:GetForcedAnimation();
			local animation = "luggage";
			
			if (action == "left") then
				animation = "motionleft";
			elseif (action == "right") then
				animation = "motionright";
			end;
			
			if (forcedAnimation and cwEmoteAnimscwEmoteAnims[forcedAnimation.animation]) then
				Clockwork.player:Notify(player, "You cannot do this action at the moment!");
			else
				player:SetForcedAnimation(animation, 2.5);
				player:SetSharedVar("StancePos", player:GetPos());
				player:SetSharedVar("StanceAng", player:GetAngles());
				player:SetSharedVar("StanceIdle", false);
			end;
		else
			Clockwork.player:Notify(player, "The model that you are using cannot perform this action!");
		end;
	else
		Clockwork.player:Notify(player, "You cannot do another stance or gesture yet!");
	end;
end;

COMMAND:Register();

if (CLIENT) then
	Clockwork.quickmenu:AddCommand(string.gsub(COMMAND.name, "Anim", ""), "Emotes", COMMAND.name, {"Left", "Right", "Behind"});
end;