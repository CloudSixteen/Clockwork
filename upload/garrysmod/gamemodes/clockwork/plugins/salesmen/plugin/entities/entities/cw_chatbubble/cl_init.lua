--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.kernel:IncludePrefixed("shared.lua")

-- Called when the entity is drawn.
function ENT:Draw()
	self:SetModelScale(0.6, 0);
	self:DrawModel();
end;

-- Called every frame.
function ENT:Think()
	local salesman = self:GetNWEntity("salesman");

	if (IsValid(salesman) and salesman:IsValid()) then
		self:SetPos(salesman:GetPos() + Vector(0, 0, 90) + Vector(0, 0, math.sin(UnPredictedCurTime()) * 2.5));
		
		if (self.cwNextChangeAngle <= UnPredictedCurTime()) then
			self:SetAngles(self:GetAngles() + Angle(0, 0.25, 0));
			self.cwNextChangeAngle = self.cwNextChangeAngle + (1 / 60);
		end;
	end;
end;

-- Called when the entity initializes.
function ENT:Initialize()
	self.cwNextChangeAngle = UnPredictedCurTime();
end;