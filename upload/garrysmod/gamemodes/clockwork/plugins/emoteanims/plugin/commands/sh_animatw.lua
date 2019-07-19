--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("AnimATW");

COMMAND.tip = "Make your character put their hands up against the wall.";
COMMAND.text = "[bool HandsUp]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.cwNextStance or curTime >= player.cwNextStance) then
		player.cwNextStance = curTime + 2;
		
		local modelClass = Clockwork.animation:GetModelClass(player:GetModel());
		local eyePos = player:EyePos();
		
		if (modelClass == "maleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			local angles = player:GetAngles():Forward();
			
			if (forcedAnimation and (forcedAnimation.animation == "spreadwallidle" or forcedAnimation.animation == "apcarrestidle")) then
				cwEmoteAnims:MakePlayerExitStance(player);
			elseif (!forcedAnimation or !cwEmoteAnims.stanceList[forcedAnimation]) then
				if (player:Crouching()) then
					Clockwork.player:Notify(player, {"CannotDoThisCrouching"});
				else
					local traceLine = util.TraceLine({
						start = eyePos,
						endpos = eyePos + (angles * 18),
						filter = player
					});
					
					if (traceLine.Hit) then
						player.cwPreviousPos = player:GetPos();
						
						if (!Clockwork.kernel:ToBool(arguments[1])) then
							player:SetPos(player:GetPos() + (angles * -24));
							player:SetForcedAnimation("apcarrestidle", 0, nil, function()
								cwEmoteAnims:MakePlayerExitStance(player);
							end);
						else
							player:SetPos(player:GetPos() + (angles * 14));
							player:SetForcedAnimation("spreadwallidle", 0, nil, function()
								cwEmoteAnims:MakePlayerExitStance(player);
							end);
						end;
						
						player:SetEyeAngles(traceLine.HitNormal:Angle() + Angle(0, 180, 0));
						player:SetSharedVar("StancePos", player:GetPos());
						player:SetSharedVar("StanceAng", player:GetAngles());
						player:SetSharedVar("StanceIdle", false);
					else
						Clockwork.player:Notify(player, {"MustBeFacingAWall"});
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