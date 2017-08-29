--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- A function to get a weapon's muzzle position.
function cwBacksword:GetMuzzlePos(weapon, attachment)
	if (!IsValid(weapon)) then
		return vector_origin, Angle(0, 0, 0);
	end;

	local origin = weapon:GetPos();
	local angle = weapon:GetAngles();
		
	if (weapon:IsWeapon() and weapon:IsCarriedByLocalPlayer()) then
		local owner = weapon:GetOwner();
		
		if (IsValid(owner) and GetViewEntity() == owner) then
			local viewmodel = owner:GetViewModel();
				
			if (IsValid(viewmodel)) then
				weapon = viewmodel;
			end;
		end;
	end;

	local attachment = weapon:GetAttachment(attachment or 1);
		
	if (!attachment) then
		return origin, angle;
	end;
		
	return attachment.Pos, attachment.Ang;
end;