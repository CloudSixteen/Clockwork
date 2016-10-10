/************************************************************************
 
 BS2 ver 0.07 (experimental)
 change log ver 0.07

• fixed the holdtype bug 
• removed css selection 
• removed experimental hl2 sweps
• various optimization fixes 
• fixed a few fov issues with weapons 
• fixed the scope textures being broken 
• more optimization fixes 
• clean up + organization of code 
• fixed super powerful bullets

************************************************************************/


if (SERVER) then

	AddCSLuaFile( "shared.lua" );
--	AddCSLuaFile("cl_init.lua")

end

if (CLIENT) then

	SWEP.PrintName			= "AWP" -- The name of the weapon.
	SWEP.Author				= "ntkrz" -- The author.
	SWEP.Purpose			= "" -- The purpose of the weapon. (Optional of course.)
	SWEP.Instructions		= "" -- The instructions to use the weapon. (For dummies.)
	SWEP.Contact			= "" -- Where to go to get help. 
	SWEP.CSMuzzleFlashes 	= true; -- Use Counter-Strike muzzle flashes?

end;

SWEP.Spawnable = false;
SWEP.AdminSpawnable	= false;

--[[ Misc. SWEP Content --]]

SWEP.HoldType			= "ar2"
SWEP.Base				= "bs_base" -- The base we are using for the SWEP, a base always runs off a base unless a base! Confusing, right?
SWEP.Category			= "Backsword 2"
SWEP.ViewModelFOV 		= 70
SWEP.ViewModelFlip 		= false;
SWEP.UseHands 			= true;

SWEP.ViewModel			= "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_awp.mdl"

SWEP.DrawAmmo = true;
SWEP.DrawCrosshair = false;

--[[ These really aren't important. Keep them at false, and the weight at five. --]]

SWEP.Weight			= 5
SWEP.AutoSwitchTo 	= false;
SWEP.AutoSwitchFrom	= false;

--[[ Set the SWEP's primary fire information. --]]

SWEP.Primary.DefaultClip 	= 8; -- How much ammunition are you given when spawning the SWEP. (Make sure you set this to the Clipsize at minimum to not annoy people.)
SWEP.Primary.ClipSize 		= 8;
SWEP.Primary.Automatic 		= false;
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Damage			= 22;
SWEP.Primary.Recoil			= 0.50;
SWEP.Primary.Sound			= Sound("sound")
SWEP.ReloadHolster			= 0.1

SWEP.Primary.Delay 			= 0.1;
SWEP.Primary.Ammo 			= "smg1";
SWEP.Primary.Cone 			= 0.02;

--[[ Set the SWEP's secondary fire information. --]]

SWEP.Secondary.ClipSize		= 1 -- Secondary Fire is useless, leave these be, they do nothing!
SWEP.Secondary.DefaultClip	= 100
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "smg2"

--[[ Ironsights --]]

SWEP.IronSightsPos 			= Vector(-6.6, -10.117, 2.599)
SWEP.IronSightsAng 			= Vector(2.076, 0.134, 0)

--[[ Define the bullet information for later use. --]]

SWEP.BulletTracerFreq = 1; -- Show a tracer every x bullets.
SWEP.BulletTracerName = nil -- Use a custom effect for the tracer.
SWEP.BulletForce = 5; -- How much force does a bullet give to a prop!

--[[ Set up the accuracy for the weapon. --]]

SWEP.CrouchCone				= 0.001
SWEP.CrouchWalkCone			= 0.009
SWEP.WalkCone				= 0.025
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.015

	/**************************
		Minor Hooks (unused)
	**************************/

function SWEP:OnIronSightsChanged(bEnabled) end;

-- Called when the SWEP's data tables should be setup.
function SWEP:OnSetupDataTables() end;

-- Called when the SWEP has initialized.
function SWEP:OnInitialize() end;

--[[
	Called when the muzzle flash effect is handled.
	Return true to override the default effect.
--]]
function SWEP:OnMuzzleFlash() end;

function SWEP:OnReload() end;

-- Called every frame.
function SWEP:OnThink() end;

--[[ Begin giving definitions of base functions and hooks. --]]

	/**************************
		Data Tables (setup)
	**************************/

-- Called when the SWEP's data tables should be setup.
function SWEP:SetupDataTables()
	self:DTVar("Bool", 0, "IronSights");
	self:DTVar("Float", 0, "LastFire");
	
	if (self.OnSetupDataTables) then
		self:OnSetupDataTables();
	end;
end;

	/**************************
		Initialize
	**************************/
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 30 )
		self:SetNPCMaxBurst( 30 )
		self:SetNPCFireRate( 0.01 )
	end;
	
	self.Reloadaftershoot = 0 
	self.nextreload = 0 
	
	self:SetHoldType(self.HoldType)
end;

	/**************************
		Think
	**************************/
function SWEP:Think()
		self:SpreadSystem()
	end;

	/**************************
		Bullet Spread
	**************************/

function SWEP:SpreadSystem()

	if self.Owner:OnGround() and (self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVERIGHT) or self.Owner:KeyDown(IN_MOVELEFT)) then
		if self.Owner:KeyDown(IN_DUCK) then
			self.Primary.Cone = self.CrouchWalkCone
		elseif self.Owner:KeyDown(IN_SPEED) then
		self.Primary.Cone = self.AirCone
		else
			self.Primary.Cone = self.WalkCone
		end;
	elseif self.Owner:OnGround() and self.Owner:KeyDown(IN_DUCK) then
		self.Primary.Cone = self.CrouchCone
	elseif not self.Owner:OnGround() then
		self.Primary.Cone = self.AirCone
	else
			self.Primary.Cone = self.StandCone
	end;
	end;

	/**************************
		Deploy
	**************************/

function SWEP:Deploy()
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )

	self:SetWeaponHoldType( self.HoldType )
	
	self.Reloadaftershoot = CurTime() + 1
	
	if timer.Exists("ReloadTimer") then
		timer.Destroy("ReloadTimer")
	end;

	self:SetNWInt("skipthink", false)
				
	return true
end;

	/**************************
		Reload
	**************************/

function SWEP:Reload()
 
		if self.Owner:KeyDown(IN_ATTACK) then return end;
		
		if( self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self.Weapon:Clip1() >= self.Primary.ClipSize)	then return end;
		
		if ( self.Reloadaftershoot > CurTime() ) then return end ;
	
		self.Weapon:DefaultReload( ACT_VM_RELOAD );
	
		self:SetWeaponHoldType( self.HoldType )
	
		if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
		
		if not CLIENT then
			self.Owner:DrawViewModel(true)
		end;
		
		if (self.ReloadSound) then 
		self.Weapon:EmitSound(self.Primary.Reload)
		end;
	end;
end;

	/**************************
		Primary Attack (LMB)
	**************************/

-- Called when the SWEP's primary attack is fired.
function SWEP:PrimaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay);
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	
	if (!self:CanPrimaryAttack()) then return; end; 
	
	self.Weapon:EmitSound(self.Primary.Sound);
	
	self:HandleBullets(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone);
	self:TakePrimaryAmmo(1);
	
	if (self.Owner:IsNPC()) then return; end;
	
	self.Owner:ViewPunch(
		Angle(math.Rand(-0.2, -0.1) * self.Primary.Recoil, math.Rand(-0.1, 0.1) * self.Primary.Recoil, 0)
	);
	
	if ((game.SinglePlayer() and SERVER) || CLIENT) then
		self.dt.LastFire = CurTime();
	end;
end;

	/**************************
		Secondary Attack (RMB)
	**************************/

-- Called when the SWEP's secondary attack is fired.
function SWEP:SecondaryAttack()
	if (!self.IronSightsPos) then return; end;
	
	self:SetIronSights(!self.dt.IronSights);
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.3);
end;


	/**************************
		Bullets
	**************************/

function SWEP:HandleBullets(damage, recoil, numShots, cone)
	local bulletInfo = {}
		bulletInfo.TracerName = self.BulletTracerName;
		bulletInfo.Spread = Vector(cone, cone, 0);
		bulletInfo.Tracer = self.BulletTracerFreq;
		bulletInfo.Damage = damage;
		bulletInfo.Force = self.BulletForce;
		bulletInfo.Num = numShots;
		bulletInfo.Src = self.Owner:GetShootPos();
		bulletInfo.Dir = self.Owner:GetAimVector();
	self.Owner:FireBullets(bulletInfo);
	
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
	
	if (!self.OnMuzzleFlash or self.OnMuzzleFlash() != true) then
		self.Owner:MuzzleFlash();
	end;
	
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	
	if (self.Owner:IsNPC()) then return; end;
	
	if ((game.SinglePlayer() and SERVER) || (!game.SinglePlayer() and CLIENT and IsFirstTimePredicted())) then
		local eyeAngles = self.Owner:EyeAngles();
			eyeAngles.pitch = eyeAngles.pitch - recoil;
		self.Owner:SetEyeAngles(eyeAngles);
	end;
end;

local IRONSIGHT_TIME = 0.25;

	/**************************
		Set Ironsights
	**************************/

function SWEP:SetIronSights(bEnabled)
	self.dt.IronSights = bEnabled;
	
	if (self.OnIronSightsChanged) then
		self.OnIronSightsChanged(bEnabled);
	end;
end;

	/**************************
		Viewmodel Position (Ironsights basically.)
	**************************/

function SWEP:GetViewModelPosition(origin, angles)
	if (!self.IronSightsPos) then return origin, angles; end;

	if (self.dt.IronSights != self.bsLastIronSights) then
		self.bsLastIronSights = self.dt.IronSights; 
		self.bsIronSightsTime = CurTime();
		
		if (self.dt.IronSights) then
			self.SwayScale = 0.3;
			self.BobScale = 0.1;
		else 
			self.SwayScale = 1.0;
			self.BobScale = 1.0;
		end;
	end;
	
	local ironSightsTime = self.bsIronSightsTime or 0
	local multiplier = 1.0;
	local offsetPos = self.IronSightsPos;
	
	if (!self.dt.IronSights && ironSightsTime < CurTime() - IRONSIGHT_TIME) then
		return origin, angles;
	end;
	
	if (ironSightsTime > CurTime() - IRONSIGHT_TIME) then
		multiplier = math.Clamp((CurTime() - ironSightsTime) / IRONSIGHT_TIME, 0, 1);
		
		if (!self.dt.IronSights) then
			multiplier = 1 - multiplier;
		end;
	end;

	if (self.IronSightsAng) then
		angles = angles * 1;
		angles:RotateAroundAxis(angles:Right(), self.IronSightsAng.x * multiplier);
		angles:RotateAroundAxis(angles:Up(), self.IronSightsAng.y * multiplier);
		angles:RotateAroundAxis(angles:Forward(), self.IronSightsAng.z * multiplier);
	end;
	
	local forwardAng = angles:Forward();
	local rightAng = angles:Right();
	local upAng = angles:Up();

	origin = origin + offsetPos.x * rightAng * multiplier;
	origin = origin + offsetPos.y * forwardAng * multiplier;
	origin = origin + offsetPos.z * upAng * multiplier;
	
	return origin, angles;
end;