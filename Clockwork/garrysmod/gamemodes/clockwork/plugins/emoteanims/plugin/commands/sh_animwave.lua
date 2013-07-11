--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("AnimWave");
COMMAND.tip = "Make your character wave at another character.";
COMMAND.text = "[string Close|Normal]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.cwNextStance or curTime >= player.cwNextStance) then
		player.cwNextStance = curTime + 2.5;
		
		local modelClass = Clockwork.animation:GetModelClass(player:GetModel());
		
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			local action = string.lower(arguments[1] or "");
			
			if (forcedAnimation and cwEmoteAnimscwEmoteAnims[forcedAnimation.animation]) then
				Clockwork.player:Notify(player, "You cannot do this action at the moment!");
			else
				if (action == "close") then
					player:SetForcedAnimation("wave_close", 2);
				else
					player:SetForcedAnimation("wave", 2);
				end;
				
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
	Clockwork.quickmenu:AddCommand(string.gsub(COMMAND.name, "Anim", ""), "Emotes", COMMAND.name, {"Close", "Normal"});
end;