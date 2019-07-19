--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("AnimSitWall");

COMMAND.tip = "Make your character sit back up against a wall.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.cwNextStance or curTime >= player.cwNextStance) then
		player.cwNextStance = curTime + 2;
		
		local modelClass = Clockwork.animation:GetModelClass(player:GetModel());
		local position = player:GetPos() + Vector(0, 0, 16);
		local angles = player:GetAngles():Forward();
		
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			
			if (forcedAnimation and forcedAnimation.animation == "plazaidle4") then
				cwEmoteAnims:MakePlayerExitStance(player);
			elseif (!forcedAnimation or !cwEmoteAnims.stanceList[forcedAnimation.animation]) then
				if (player:Crouching()) then
					Clockwork.player:Notify(player, {"CannotDoThisCrouching"});
				else
					local traceLine = util.TraceLine({
						start = position,
						endpos = position + (angles * -20),
						filter = player
					});
					
					if (traceLine.Hit) then
						player.cwPreviousPos = player:GetPos();
						
						player:SetPos(player:GetPos() + (angles * 4));
						player:SetEyeAngles(traceLine.HitNormal:Angle());
						player:SetForcedAnimation("plazaidle4", 0, nil, function()
							cwEmoteAnims:MakePlayerExitStance(player);
						end);
						
						player:SetSharedVar("StancePos", player:GetPos());
						player:SetSharedVar("StanceAng", player:GetAngles());
						player:SetSharedVar("StanceIdle", true);
					else
						Clockwork.player:Notify(player, {"MustBeFacingAwayFromWall"});
					end;
				end;
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