--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua");
	
	resource.AddFile("models/weapons/v_punch.mdl");
	resource.AddFile("models/weapons/w_fists_t.mdl");
	
	SWEP.ActivityTranslate = {
		[ACT_HL2MP_GESTURE_RANGE_ATTACK] = ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST,
		[ACT_HL2MP_GESTURE_RELOAD] = ACT_HL2MP_GESTURE_RELOAD_FIST,
		[ACT_HL2MP_WALK_CROUCH] = ACT_HL2MP_WALK_CROUCH_FIST,
		[ACT_HL2MP_IDLE_CROUCH] = ACT_HL2MP_IDLE_CROUCH_FIST,
		[ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK1,
		[ACT_HL2MP_IDLE] = ACT_HL2MP_IDLE_FIST,
		[ACT_HL2MP_WALK] = ACT_HL2MP_WALK_FIST,
		[ACT_HL2MP_JUMP] = ACT_HL2MP_JUMP_FIST,
		[ACT_HL2MP_RUN] = ACT_HL2MP_RUN_FIST
	};
end;

if (CLIENT) then
	SWEP.Slot = 5;
	SWEP.SlotPos = 3;
	SWEP.DrawAmmo = false;
	SWEP.PrintName = "Hands";
	SWEP.DrawCrosshair = true;
end

SWEP.Instructions = "Primary Fire: Punch.\nSecondary Fire: Knock.";
SWEP.Contact = "";
SWEP.Purpose = "Punching characters and knocking on doors.";
SWEP.Author	= "kurozael";

SWEP.WorldModel = "models/weapons/w_fists_t.mdl";
SWEP.ViewModel = "models/weapons/v_punch.mdl";
SWEP.HoldType = "fist";

SWEP.AdminSpawnable = false;
SWEP.Spawnable = false;
  
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = true;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = 6;
SWEP.Primary.Ammo = "";

SWEP.Secondary.NeverRaised = true;
SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.Ammo	= "";

SWEP.NoIronSightFovChange = true;
SWEP.NoIronSightAttack = true;
SWEP.LoweredAngles = Angle(60, 60, 60);
SWEP.IronSightPos = Vector(0, 0, 0);
SWEP.IronSightAng = Vector(0, 0, 0);

-- Called when the SWEP is deployed.
function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW);
end;

-- Called when the SWEP is holstered.
function SWEP:Holster(switchingTo)
	self:SendWeaponAnim(ACT_VM_HOLSTER);
	return true;
end;

-- A function to punch an entity.
function SWEP:PunchEntity()
	local bounds = Vector(0, 0, 0);
	local startPosition = self.Owner:GetShootPos();
	local finishPosition = startPosition + (self.Owner:GetAimVector() * 64);
	local traceLineAttack = util.TraceLine({
		start = startPosition,
		endpos = finishPosition,
		filter = self.Owner
	});
	
	self.Weapon:EmitSound("weapons/crossbow/hitbod2.wav", 25);
	
	if (SERVER) then
		self.Weapon:CallOnClient("PunchEntity", "");
		
		if (IsValid(traceLineAttack.Entity)) then
			traceLineAttack.Entity:TakeDamageInfo(
				Clockwork.kernel:FakeDamageInfo(self.Primary.Damage, self, self.Owner, traceLineAttack.HitPos, DMG_CLUB, 1)
			);
		end;
	end;
end;

-- A function to play the knock sound.
function SWEP:PlayKnockSound()
	if (SERVER) then
		self.Weapon:CallOnClient("PlayKnockSound", "");
	end;
	
	self.Weapon:EmitSound("physics/wood/wood_crate_impact_hard2.wav");
end;

-- A function to play the punch animation.
function SWEP:PlayPunchAnimation()
	if (SERVER) then
		self.Weapon:CallOnClient("PlayPunchAnimation", "");
	end;
	
	self.Owner:EmitSound("npc/vort/claw_swing2.wav");
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
end;

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
	if (SERVER) then
		if (Clockwork.plugin:Call("PlayerCanThrowPunch", self.Owner)) then
			self:PlayPunchAnimation();
			self.Owner:SetAnimation(PLAYER_ATTACK1);
			
			local trace = self.Owner:GetEyeTraceNoCursor();
			
			if (self.Owner:GetShootPos():Distance(trace.HitPos) <= 64) then
				if (IsValid(trace.Entity)) then
					if (trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity:GetClass() == "prop_ragdoll") then
						if (trace.Entity:IsPlayer() and trace.Entity:Health() - self.Primary.Damage <= 10
						and Clockwork.plugin:Call("PlayerCanPunchKnockout", self.Owner, trace.Entity)) then
							Clockwork.player:SetRagdollState(trace.Entity, RAGDOLL_KNOCKEDOUT, 15);
							Clockwork.plugin:Call("PlayerPunchKnockout", self.Owner, trace.Entity);
						elseif (Clockwork.plugin:Call("PlayerCanPunchEntity", self.Owner, trace.Entity)) then
							self:PunchEntity();
							Clockwork.plugin:Call("PlayerPunchEntity", self.Owner, trace.Entity);
						end;
						
						if (trace.Entity:IsPlayer() or trace.Entity:IsNPC()) then
							local normal = trace.Entity:GetPos() - self.Owner:GetPos();
								normal:Normalize();
							local push = 128 * normal;
							
							trace.Entity:SetVelocity(push);
						end;
					elseif (IsValid(trace.Entity:GetPhysicsObject())) then
						if (Clockwork.plugin:Call("PlayerCanPunchEntity", self.Owner, trace.Entity)) then
							self:PunchEntity();
							
							Clockwork.plugin:Call("PlayerPunchEntity", self.Owner, trace.Entity);
						end;
					elseif (trace.Hit) then
						self:PunchEntity();
					end;
				elseif (trace.Hit) then
					self:PunchEntity();
				end;
			end;
			
			Clockwork.plugin:Call("PlayerPunchThrown", self.Owner);
			
			local info = {
				primaryFire = 0.5,
				secondaryFire = 0.5
			};
			
			Clockwork.plugin:Call("PlayerAdjustNextPunchInfo", self.Owner, info);
			
			self.Weapon:SetNextPrimaryFire(CurTime() + info.primaryFire);
			self.Weapon:SetNextSecondaryFire(CurTime() + info.secondaryFire);
			
			self.Owner:ViewPunch(Angle(
				math.Rand(-16, 16), math.Rand(-8, 8), 0
			));
		end;
	end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
	if (SERVER) then
		local trace = self.Owner:GetEyeTraceNoCursor();
		
		if (IsValid(trace.Entity) and Clockwork.entity:IsDoor(trace.Entity)) then
			if (self.Owner:GetShootPos():Distance(trace.HitPos) <= 64) then
				if (Clockwork.plugin:Call("PlayerCanKnockOnDoor", self.Owner, trace.Entity)) then
					self:PlayKnockSound();
					
					self.Weapon:SetNextPrimaryFire(CurTime() + 0.25);
					self.Weapon:SetNextSecondaryFire(CurTime() + 0.25);
					
					Clockwork.plugin:Call("PlayerKnockOnDoor", self.Owner, trace.Entity);
				end;
			end;
		end;
	end;
end;