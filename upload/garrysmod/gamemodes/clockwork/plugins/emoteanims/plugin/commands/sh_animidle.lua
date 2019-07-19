--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New("AnimIdle");

COMMAND.tip = "Put your character into an idle stance.";
COMMAND.text = "[bool ArmsCrossed]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local modelClass = Clockwork.animation:GetModelClass(player:GetModel());
	local curTime = CurTime();
	
	if (!player.cwNextStance or curTime >= player.cwNextStance) then
		player.cwNextStance = curTime + 2;
		
		if (modelClass == "maleHuman" or modelClass == "femaleHuman") then
			local forcedAnimation = player:GetForcedAnimation();
			
			if (forcedAnimation and string.find(forcedAnimation.animation, "lineidle")) then
				cwEmoteAnims:MakePlayerExitStance(player);
			elseif (!forcedAnimation or !cwEmoteAnims.stanceList[forcedAnimation.animation]) then
				if (player:Crouching()) then
					Clockwork.player:Notify(player, {"CannotDoThisCrouching"});
				else
					local animation = nil;
					
					if (Clockwork.kernel:ToBool(arguments[1])) then
						if (modelClass == "maleHuman") then
							animation = "lineidle02";
						else
							animation = "lineidle01";
						end;
					else
						if (modelClass == "femaleHuman") then
							animation = "lineidle0"..math.random(1, 2);
						else
							animation = "lineidle04";
						end;
					end;
					
					if (player:IsOnGround() or IsValid(player:GetGroundEntity())) then
						player:SetSharedVar("StancePos", player:GetPos());
						player:SetSharedVar("StanceAng", player:GetAngles());
						player:SetSharedVar("StanceIdle", true);
						player:SetForcedAnimation(animation, 0, nil, function()
							cwEmoteAnims:MakePlayerExitStance(player);
						end);
					else
						Clockwork.player:Notify(player, {"MustBeStandingOnGround"});
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