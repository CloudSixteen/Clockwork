--this was made by TetaBonita, not me...


function EFFECT:Init(data)
	
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	if not (self.WeaponEnt:IsValid() and self.WeaponEnt:IsWeapon()) then return end
	
	self.Normal = data:GetNormal()

	if self.WeaponEnt:IsCarriedByLocalPlayer() and GetViewEntity() == LocalPlayer() then 
	
		local ViewModel = LocalPlayer():GetViewModel()
		if not ViewModel:IsValid() then return end
				
		self.EjectionPort = ViewModel:GetAttachment(self.Attachment)
		if not self.EjectionPort then return end

		self.Angle = self.EjectionPort.Ang
		self.Forward = self.Angle:Forward()
		self.Position = self.EjectionPort.Pos

		
	else

		self.EjectionPort = self.WeaponEnt:GetAttachment(self.Attachment)
		if not self.EjectionPort then return end
		
		self.Forward = self.Normal:Angle():Right()
		self.Angle = self.Forward:Angle()
		self.Position = self.EjectionPort.Pos - (0.5*self.WeaponEnt:BoundingRadius())*self.EjectionPort.Ang:Forward()	
		
	end

	local AddVel = self.WeaponEnt:GetOwner():GetVelocity()

	local effectdata = EffectData()
	effectdata:SetOrigin(self.Position)
	effectdata:SetAngles(self.Angle)
	effectdata:SetEntity(self.WeaponEnt)
	util.Effect("ShotgunShellEject", effectdata)

	local emitter = ParticleEmitter(self.Position)
		
		for i=1,3 do
			local particle = emitter:Add("particle/particle_smokegrenade", self.Position + self.Forward*2)
			particle:SetVelocity(math.Rand(5,9)*self.Forward + 1.02*AddVel)
			particle:SetGravity(math.Rand(5,9)*VectorRand() + Vector(0,0,-10))
			particle:SetDieTime(math.Rand(1,1.2))
			particle:SetStartAlpha(math.Rand(40,50))
			particle:SetStartSize(math.Rand(1,2))
			particle:SetEndSize(math.Rand(3,4))
			particle:SetRoll(math.Rand(180,480))
			particle:SetRollDelta(math.Rand(-1,1))
			particle:SetColor(245,245,245)
			particle:SetLighting(true)
			particle:SetAirResistance(40)
		end

	emitter:Finish()

end


function EFFECT:Think()

	return false
	
end


function EFFECT:Render()


end



