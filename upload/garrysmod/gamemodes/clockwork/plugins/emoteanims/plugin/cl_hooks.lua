--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when the local player should be drawn.
function cwEmoteAnims:ShouldDrawLocalPlayer()
	return self:IsPlayerInStance(Clockwork.Client);
end;

-- Called when a player's animation is updated.
function cwEmoteAnims:UpdateAnimation(player)
	if (self:IsPlayerInStance(player)) then
		player:SetRenderAngles(player:GetSharedVar("StanceAng"));
	end;
end;

-- Called when the calc view table should be adjusted.
function cwEmoteAnims:CalcViewAdjustTable(view)
	if (self:IsPlayerInStance(Clockwork.Client)) then
		local defaultOrigin = view.origin;
		local idleStance = Clockwork.Client:GetSharedVar("StanceIdle");
		local traceLine = nil;
		local headBone = "ValveBiped.Bip01_Head1";
		local position = Clockwork.Client:EyePos();
		local angles = Clockwork.Client:GetSharedVar("StanceAng"):Forward();
		
		if (string.find(Clockwork.Client:GetModel(), "vortigaunt")) then
			headBone = "ValveBiped.Head";
		end;
		
		if (idleStance) then
			local bonePosition = Clockwork.Client:GetBonePosition(Clockwork.Client:LookupBone(headBone));
			
			if (bonePosition) then
				position = bonePosition + Vector(0, 0, 8);
			end;
		end;
		
		if (defaultOrigin) then
			if (idleStance) then
				traceLine = util.TraceLine({
					start = position,
					endpos = position + (angles * 16);
					filter = Clockwork.Client
				});
			else
				traceLine = util.TraceLine({
					start = position,
					endpos = position - (angles * 128);
					filter = Clockwork.Client
				});
			end;
			
			if (traceLine.Hit) then
				view.origin = traceLine.HitPos + (angles * 4);
				
				if (view.origin:Distance(position) <= 32) then
					view.origin = defaultOrigin;
				end;
			else
				view.origin = traceLine.HitPos;
			end;
		end;
	end;
end;