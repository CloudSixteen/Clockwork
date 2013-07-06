--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("AnimPant");
COMMAND.tip = "Put your character into a panting stance.";
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
			
			if (forcedAnimation and (forcedAnimation.animation == "d2_coast03_postbattle_idle02" or forcedAnimation.animation == "d2_coast03_postbattle_idle02_entry")) then
				cwEmoteAnims:MakePlayerExitStance(player);
			elseif (!forcedAnimation or !cwEmoteAnimscwEmoteAnims[forcedAnimation.animation]) then
				if (player:Crouching()) then
					Clockwork.player:Notify(player, "You cannot do this while you are crouching!");
				elseif (player:IsOnGround() or IsValid(player:GetGroundEntity())) then
					player:SetSharedVar("StancePos", player:GetPos());
					player:SetSharedVar("StanceAng", player:GetAngles());
					player:SetSharedVar("StanceIdle", false);
					player:SetForcedAnimation("d2_coast03_postbattle_idle02_entry", 1.5, nil, function(player)
						player:SetForcedAnimation("d2_coast03_postbattle_idle02", 0, nil, function()
							cwEmoteAnims:MakePlayerExitStance(player);
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