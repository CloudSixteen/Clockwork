--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua");
	
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
	SWEP.PrintName			= "Hands";
	SWEP.Author 			= "Cloud Sixteen";
	SWEP.Instructions		= "Primary Fire: Hit.\nSecondary Fire: Knock on a door.\nR: Drop an item.";
	SWEP.Purpose			= "Harming characters and knocking on doors.";
	SWEP.Contact			= "CloudSixteen.com";
	SWEP.DrawAmmo 			= false;
	SWEP.DrawCrosshair 		= false;
	SWEP.DrawSecondaryAmmo	= false;
	SWEP.ViewModelFOV		= 55;
	SWEP.ViewModelFlip		= false;
end;

SWEP.Category				= "Clockwork";
SWEP.HoldType				= "fist";
SWEP.Spawnable				= false;
SWEP.AdminSpawnable			= false;
SWEP.ViewModel 				= "models/weapons/c_arms.mdl";
SWEP.WorldModel 			= "" ;
SWEP.UseHands				= true;

SWEP.Primary.ClipSize		= -1;
SWEP.Primary.Damage			= 6;
SWEP.Primary.DefaultClip	= -1;
SWEP.Primary.Automatic		= false;
SWEP.Primary.Ammo			= "none";
SWEP.DrawAmmo 				= false;

SWEP.Secondary.ClipSize		= -1;
SWEP.Secondary.DefaultClip	= -1;
SWEP.Secondary.Damage		= 100;
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "";

SWEP.WallSound 				= Sound("Flesh.ImpactHard");
SWEP.SwingSound				= Sound("WeaponFrag.Throw");
SWEP.HitDistance			= 38;
SWEP.LoweredAngles 			= Angle(0.000, 0.000, -90.000)

function SWEP:Initialize() 
	self:SetWeaponHoldType(self.HoldType);
end;

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel();

	vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"));
	
	self.Weapon:SetNextPrimaryFire(CurTime() + 1);

	return true;
end;

function SWEP:PrimaryAttack()
	if (SERVER) then
		if (Clockwork.plugin:Call("PlayerCanThrowPunch", self.Owner)) then
			self:PlayPunchAnimation();
			self.Owner:SetAnimation(PLAYER_ATTACK1);
			self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
			self.Weapon:SetNextSecondaryFire(CurTime() + 0.7)
			
			timer.Simple(0.1, function()
				self.Weapon:EmitSound(self.SwingSound);
			end);	
			
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

function SWEP:PlayKnockSound()
	if (SERVER) then
		self.Weapon:CallOnClient("PlayKnockSound", "");
	end;
	
	self.Weapon:EmitSound("physics/wood/wood_crate_impact_hard2.wav");
end;

function SWEP:Reload()
	return false;
end;

function SWEP:OnRemove()
	return true;
end;

function SWEP:Holster()
	return true;
end;

function SWEP:ShootEffects() end;

function SWEP:OnDrop()
	self:Remove();
end;

function SWEP:SetupDataTables()  
	self:NetworkVar("Float", 0, "NextMeleeAttack") 
 	self:NetworkVar("Float", 1, "NextIdle")
end;

function SWEP:UpdateNextIdle() 
 	local vm = self.Owner:GetViewModel();

 	self:SetNextIdle(CurTime() + vm:SequenceDuration());
end;

function SWEP:PunchEntity()
	local bounds = Vector(0, 0, 0);
	local startPosition = self.Owner:GetShootPos();
	local finishPosition = startPosition + (self.Owner:GetAimVector() * 64);
	local traceLineAttack = util.TraceLine({
		start = startPosition,
		endpos = finishPosition,
		filter = self.Owner
	});

	timer.Simple(0.32, function ()self.Weapon:EmitSound(self.WallSound); end);
	
	if (SERVER) then
		self.Weapon:CallOnClient("PunchEntity", "");
		
		if (IsValid(traceLineAttack.Entity)) then
			traceLineAttack.Entity:TakeDamageInfo(
				Clockwork.kernel:FakeDamageInfo(self.Primary.Damage, self, self.Owner, traceLineAttack.HitPos, DMG_CLUB, 1)
			);
		end;
	end;
end;

function SWEP:PlayPunchAnimation()
	if (SERVER) then
		self.Weapon:CallOnClient("PlayPunchAnimation", "");
	end;

 	if (self.left == nil) then
		self.left = true;
	else
		self.left = !self.left;
	end;

	local anim = "fists_right";
	local ownerAnim = PLAYER_ATTACK1;
 
 	if (self.left) then
		anim = "fists_left";
	end;
 
 	local vm = self.Owner:GetViewModel();

 	self.Owner:SetAnimation(ownerAnim);
	
 	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim));
end;
