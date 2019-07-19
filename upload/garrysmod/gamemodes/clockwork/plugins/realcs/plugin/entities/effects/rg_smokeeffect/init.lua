function EFFECT:Init(data)
	local particleEmitter = ParticleEmitter(data:GetOrigin());
	local scale = data:GetScale() or 2;
	
	for i = 1, (16 * scale) do
		local randomThing = math.random(200, 240);
		local startSize = math.Rand(16 * scale, 32 * scale);
		local position = Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-2, 2));
		local particle = particleEmitter:Add("particle/particle_smokegrenade", data:GetOrigin() + position);
		
		if (particle) then
			particle:SetAirResistance(math.Rand(256, 384));
			particle:SetStartAlpha(175);
			particle:SetStartSize(startSize * 2);
			particle:SetRollDelta(math.Rand(-0.2, 0.2));
			particle:SetEndAlpha(math.Rand(0, 128));
			particle:SetVelocity(Vector(0, 0, 1) * math.Rand(32, 64));
			particle:SetLifeTime(0);
			particle:SetLighting(0);
			particle:SetGravity(Vector(math.Rand(-8, 8), math.Rand(-8, 8), math.Rand(16, -16)));
			particle:SetCollide(true);
			particle:SetEndSize(startSize);
			particle:SetDieTime(math.random(1, 3));
			particle:SetBounce(0.5);
			particle:SetColor(randomThing, randomThing, randomThing);
			particle:SetRoll(math.Rand(-180, 180));
		end;
	end;
	
	particleEmitter:Finish()
end;

-- Called when the effect should be rendered.
function EFFECT:Render() end;

-- Called each frame.
function EFFECT:Think()
	return false;
end;