--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.kernel:IncludePrefixed("shared.lua")

-- Called when the entity is drawn.
function ENT:Draw()
	self:SetModelScale(0.6, 0);
	self:DrawModel();
end;

-- Called every frame.
function ENT:Think()
	if (!self.cwOriginalPos) then
		self.cwOriginalPos = self:GetPos();
	end;
	
	self:SetPos(self.cwOriginalPos + Vector(0, 0, math.sin(UnPredictedCurTime()) * 2.5));
	
	if (self.cwNextChangeAngle <= UnPredictedCurTime()) then
		self:SetAngles(self:GetAngles() + Angle(0, 0.25, 0));
		self.cwNextChangeAngle = self.cwNextChangeAngle + (1 / 60);
	end;
end;

-- Called when the entity initializes.
function ENT:Initialize()
	self.cwNextChangeAngle = UnPredictedCurTime();
end;