--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- A function to make a player exit their stance.
function cwEmoteAnims:MakePlayerExitStance(player, keepPosition)
	if (player.cwPreviousPos and !keepPosition) then
		for k, v in pairs(cwPlayer.GetAll()) do
			if (v != player and v:GetPos():Distance(player.cwPreviousPos) <= 32) then
				Clockwork.player:Notify(player, {"AnotherCharacterBlockingPos"});
				
				return;
			end;
		end;
		
		Clockwork.player:SetSafePosition(player, player.cwPreviousPos);
	end;
	
	player:SetForcedAnimation(false);
	player.cwPreviousPos = nil;
	player:SetSharedVar("StancePos", Vector(0, 0, 0));
	player:SetSharedVar("StanceAng", Angle(0, 0, 0));
	player:SetSharedVar("StanceIdle", false);
end;