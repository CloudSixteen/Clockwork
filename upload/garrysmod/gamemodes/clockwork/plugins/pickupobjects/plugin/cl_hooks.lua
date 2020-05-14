--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when the top text is needed.
function cwPickupObjects:GetTopText(topText)
	local beingDragged = Clockwork.Client:GetSharedVar("IsDragged");
	
	if (Clockwork.Client:IsRagdolled() and beingDragged) then
		topText:Add("BEING_DRAGGED", "You are being dragged");
	end;
end;

-- Called when the local player attempts to get up.
function cwPickupObjects:PlayerCanGetUp()
	local beingDragged = Clockwork.Client:GetSharedVar("IsDragged");
	
	if (beingDragged) then
		return false;
	end;
end;

timer.Simple(1, function()
	local SWEP = weapons.GetStored("cw_hands");

	if (SWEP) then
		SWEP.Instructions = "Reload: Drop\n"..SWEP.Instructions;
		
		SWEP.Instructions = Clockwork.kernel:Replace(SWEP.Instructions, "Knock.", "Knock/Pickup.");
		SWEP.Instructions = Clockwork.kernel:Replace(SWEP.Instructions, "Punch.", "Punch/Throw.");
	end;
end);