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
	util.Effect("RifleShellEject", effectdata)

	local emitter = ParticleEmitter(self.Position)
		
		for i=1,2 do
			local particle = emitter:Add("particle/particle_smokegrenade", self.Position)
			particle:SetVelocity(10*i*self.Forward + 1.02*AddVel)
			particle:SetDieTime(math.Rand(0.36,0.38))
			particle:SetStartAlpha(math.Rand(50,60))
			particle:SetStartSize(1)
			particle:SetEndSize(math.Rand(3,4)*i)
			particle:SetRoll(math.Rand(180,480))
			particle:SetRollDelta(math.Rand(-1,1))
			particle:SetColor(245,245,245)
			particle:SetLighting(true)
			particle:SetAirResistance(40)
		end

		
		if math.random(1,4) == 1 then
			for i=1,2 do
				local particle = emitter:Add("effects/muzzleflash"..math.random(1,4), self.Position)
				particle:SetVelocity(30*i*self.Forward + AddVel)
				particle:SetGravity(AddVel)
				particle:SetDieTime(0.1)
				particle:SetStartAlpha(150)
				particle:SetStartSize(0.5*i)
				particle:SetEndSize(3*i)
				particle:SetRoll(math.Rand(180,480))
				particle:SetRollDelta(math.Rand(-1,1))
				particle:SetColor(255,255,255)	
			end
		end

	emitter:Finish()

end


function EFFECT:Think()

	return false
	
end


function EFFECT:Render()


end



