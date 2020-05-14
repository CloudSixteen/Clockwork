--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua");
	
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
	SWEP.SlotPos = 2;
	SWEP.DrawAmmo = false;
	SWEP.PrintName = "Keys";
	SWEP.DrawCrosshair = false;
end

SWEP.Instructions 			= "Primary Fire: Lock.\nSecondary Fire: Unlock.";
SWEP.Contact 				= "CloudSixteen.com";
SWEP.Purpose 				= "Locking and unlocking entities that you have access to.";
SWEP.Author					= "Cloud Sixteen";

SWEP.Category				= "Clockwork";
SWEP.WorldModel 			= "";
SWEP.ViewModel 				= "models/weapons/c_arms.mdl";
SWEP.HoldType 				= "fist";

SWEP.AdminSpawnable 		= false;
SWEP.Spawnable 				= false;
  
SWEP.Primary.DefaultClip 	= 0;
SWEP.Primary.Automatic 		= true;
SWEP.Primary.ClipSize 		= -1;
SWEP.Primary.Damage 		= 1;
SWEP.Primary.Ammo 			= "";

SWEP.Secondary.DefaultClip 	= 0;
SWEP.Secondary.Automatic 	= false;
SWEP.Secondary.ClipSize 	= -1;
SWEP.Secondary.Ammo			= "";

SWEP.NoIronSightFovChange 	= true;
SWEP.NoIronSightAttack 		= true;
SWEP.IronSightPos 			= Vector(0, 0, 0);
SWEP.IronSightAng 			= Vector(0, 0, 0);
SWEP.NeverRaised 			= true;
SWEP.LoweredAngles 			= Angle(0.000, 0.000, -22.000)

-- Called when the SWEP is deployed.
function SWEP:Deploy()
	local vm = self.Owner:GetViewModel();
	vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"));
	
	return true;
end;

-- Called when the SWEP is holstered.
function SWEP:Holster(switchingTo)
	self:SendWeaponAnim(ACT_VM_HOLSTER);
	return true;
end;

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 1);
	
	if (SERVER) then
		local action = Clockwork.player:GetAction(self.Owner);
		local trace = self.Owner:GetEyeTraceNoCursor();
		
		if (self.Owner:GetPos():Distance(trace.HitPos) > 192
		or !IsValid(trace.Entity)) then
			return;
		end;
		
		local info = Clockwork.plugin:Call("PlayerGetLockInfo", self.Owner, trace.Entity);
		
		if (info and Clockwork.plugin:Call("PlayerCanLockEntity", self.Owner, trace.Entity)) then
			local isNotUnlocking = (action != "unlock");
			local isNotLocking = (action != "lock");
			
			if (isNotLocking or isNotUnlocking) then
				Clockwork.player:SetAction(self.Owner, "lock", info.duration);
				Clockwork.player:EntityConditionTimer(self.Owner, trace.Entity, nil, info.duration, 192,
					function()
						return (Clockwork.plugin:Call("PlayerCanLockEntity", self.Owner, trace.Entity)
						and self.Owner:Alive() and !self.Owner:IsRagdolled() and self.Owner:IsUsingKeys());
					end,
					function(success)
						if (success) then
							info.Callback(self.Owner, trace.Entity);
							
							if (!info.noSound) then
								self.Owner:EmitSound("doors/door_latch3.wav");
							end;
						else
							Clockwork.player:SetAction(self.Owner, "lock", false);
						end;
					end
				);
			end;
		end;
	end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + 1);
	
	if (SERVER) then
		local action = Clockwork.player:GetAction(self.Owner);
		local trace = self.Owner:GetEyeTraceNoCursor();
		
		if (self.Owner:GetPos():Distance(trace.HitPos) > 192
		or !IsValid(trace.Entity)) then
			return;
		end;
		
		local info = Clockwork.plugin:Call("PlayerGetUnlockInfo", self.Owner, trace.Entity);
		
		if (info and Clockwork.plugin:Call("PlayerCanUnlockEntity", self.Owner, trace.Entity)) then
			local isNotUnlocking = (action != "unlock");
			local isNotLocking = (action != "lock");
			
			if (isNotLocking or isNotUnlocking) then
				Clockwork.player:SetAction(self.Owner, "unlock", info.duration);
				Clockwork.player:EntityConditionTimer(self.Owner, trace.Entity, nil, info.duration, 192,
					function()
						return (Clockwork.plugin:Call("PlayerCanUnlockEntity", self.Owner, trace.Entity)
						and self.Owner:Alive() and !self.Owner:IsRagdolled() and self.Owner:IsUsingKeys());
					end,
					function(success)
						if (success) then
							info.Callback(self.Owner, trace.Entity);
							
							if (!info.noSound) then
								self.Owner:EmitSound("doors/door_latch3.wav");
							end;
						else
							Clockwork.player:SetAction(self.Owner, "unlock", false);
						end;
					end
				);
			end;
		end;
	end;
end;