--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("AnimSit");
COMMAND.tip = "Make your character sit on the ground.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.cwNextStance or curTime >= player.cwNextStance) then
		player.cwNextStance = curTime + 2;
		
		local modelClass = Clockwork.animation:GetModelClass(player:GetModel());
		local position = player:GetPos();
		
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			
			if (forcedAnimation and (forcedAnimation.animation == "sit_ground" or forcedAnimation.animation == "idle_to_sit_ground"
			or forcedAnimation.animation == "sit_ground_to_idle")) then
				player:SetForcedAnimation(false);
				
				player:SetForcedAnimation("sit_ground_to_idle", 2, nil, function(player)
					cwEmoteAnims:MakePlayerExitStance(player);
				end);
			elseif (!forcedAnimation or !cwEmoteAnimscwEmoteAnims[forcedAnimation.animation]) then
				if (player:Crouching()) then
					Clockwork.player:Notify(player, "You cannot do this while you are crouching!");
				elseif (player:IsOnGround() or IsValid(player:GetGroundEntity())) then
					player:SetSharedVar("StancePos", player:GetPos());
					player:SetSharedVar("StanceAng", player:GetAngles());
					player:SetSharedVar("StanceIdle", true);
					player:SetForcedAnimation("idle_to_sit_ground", 2, nil, function(player)
						player:SetForcedAnimation("sit_ground", 0, nil, function()
							local forcedAnimation = player:GetForcedAnimation();
							
							if (!forcedAnimation or forcedAnimation.animation != "sit_ground_to_idle") then
								cwEmoteAnims:MakePlayerExitStance(player);
							end;
						end);
					end);
				else
					Clockwork.player:Notify(player, "You must be standing on the ground!");
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
	Clockwork.quickmenu:AddCommand(string.gsub(COMMAND.name, "Anim", ""), "Emotes", COMMAND.name);
end;