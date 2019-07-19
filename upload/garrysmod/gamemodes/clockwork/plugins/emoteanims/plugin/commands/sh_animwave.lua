--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
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
			
			if (forcedAnimation and cwEmoteAnims.stanceList[forcedAnimation.animation]) then
				Clockwork.player:Notify(player, {"CannotActionRightNow"});
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
			Clockwork.player:Notify(player, {"ModelCannotDoThisAction"});
		end;
	else
		Clockwork.player:Notify(player, {"CannotDoAnotherGestureYet"});
	end;
end;

COMMAND:Register();

if (CLIENT) then
	Clockwork.quickmenu:AddCommand(COMMAND.name, "Emotes", COMMAND.name, {{"AnimWaveClose", "Close"}, {"AnimWaveNormal", "Normal"}});
end;