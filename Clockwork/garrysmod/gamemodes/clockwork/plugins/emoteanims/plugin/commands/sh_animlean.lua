--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("AnimLean");
COMMAND.tip = "Make your character lean back up against a wall.";
COMMAND.text = "[string ArmsBack|ArmsDown]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.cwNextStance or curTime >= player.cwNextStance) then
		player.cwNextStance = curTime + 2;
		
		local modelClass = Clockwork.animation:GetModelClass(player:GetModel());
		local eyePos = player:EyePos();
		
		if (modelClass == "maleHuman" or modelClass == "femaleHuman" or modelClass == "civilProtection") then
			local forcedAnimation = player:GetForcedAnimation();
			local action = string.lower(arguments[1] or "");
			
			if (forcedAnimation and (forcedAnimation.animation == "lean_back" or forcedAnimation.animation == "plazaidle1"
			or forcedAnimation.animation == "plazaidle2" or forcedAnimation.animation == "idle_baton")) then
				cwEmoteAnims:MakePlayerExitStance(player);
			elseif (!forcedAnimation or !cwEmoteAnimscwEmoteAnims[forcedAnimation.animation]) then
				if (player:Crouching()) then
					Clockwork.player:Notify(player, "You cannot do this while you are crouching!");
				else
					local animation = "lean_back";
					local traceLine = util.TraceLine({
						start = eyePos,
						endpos = eyePos + (player:GetAngles():Forward() * -20),
						filter = player
					});
					
					if (modelClass != "civilProtection") then
						if (action == "armsback") then
							animation = "plazaidle2";
						elseif (action == "armsdown") then
							animation = "plazaidle1";
						end;
					else
						animation = "idle_baton";
					end;
					
					if (traceLine.Hit) then
						player:SetSharedVar("stance", true);
						player:SetEyeAngles(traceLine.HitNormal:Angle());
						player:SetForcedAnimation(animation, 0, nil, function()
							cwEmoteAnims:MakePlayerExitStance(player);
						end);
						
						player:SetSharedVar("StancePos", player:GetPos());
						player:SetSharedVar("StanceAng", player:GetAngles());
						player:SetSharedVar("StanceIdle", true);
					else
						Clockwork.player:Notify(player, "You must be facing away from, and near a wall!");
					end;
				end;
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
	Clockwork.quickmenu:AddCommand(string.gsub(COMMAND.name, "Anim", ""), "Emotes", COMMAND.name, {{"Arms Back", "ArmsBack"}, {"Arms Down", "ArmsDown"}, "Normal"});
end;