--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

--[[
	This is an updated and supported version of Backsword I'll be updating from now on with Kurozael's permission.
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua");
	SWEP.Weight	= 5;
	SWEP.AutoSwitchTo = false;
	SWEP.AutoSwitchFrom	= false;
end;

if (CLIENT) then
	SWEP.DrawAmmo = true; -- Draw our own ammo display?
	SWEP.IconLetter = "SMG"; -- The icon letter of the font.
	SWEP.DrawCrosshair = false; -- Draw the crosshair, or draw our own?
	SWEP.ViewModelFOV = 82;
	SWEP.ViewModelFlip = true; -- Some view models are incorrectly flipped.
	SWEP.CSMuzzleFlashes = true; -- Use Counter-Strike muzzle flashes?
	SWEP.PrintName			= "SMG"			
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "SMG"
	
	--[[ The font used for the killicons. --]]
	surface.CreateFont("CSKillIcons", 
	{
		font		= "csd",
		size		= ScreenScale(30),
		weight		= 500,
		antialiase	= true,
		additive 	= true
	});
	surface.CreateFont("CSSelectIcons", 
	{
		font		= "csd",
		size		= ScreenScale(60),
		weight		= 500,
		antialiase	= true,
		additive 	= true
	});
end;

--[[ Basic SWEP information to display to the client. --]]
SWEP.Author	= ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""

--[[ Set whether the SWEP is spawnable (by users or by admins). --]]
SWEP.Spawnable = false;
SWEP.AdminSpawnable	= false;

--[[ Set the SWEP's primary fire information. --]]
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Automatic = false;
SWEP.Primary.NumShots = 1;
SWEP.Primary.Damage	= 10;
SWEP.Primary.Recoil	= 1;
SWEP.Primary.Sound = Sound("Weapon_AK47.Single");
SWEP.Primary.Delay = 0.15;
SWEP.Primary.Ammo = "none";
SWEP.Primary.Cone = 0.05;

--[[ Set the SWEP's primary fire information. --]]
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.ClipSize	= -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo	= "none";

--[[ Define the bullet information for later use. --]]
SWEP.BulletTracerFreq = 1; -- Show a tracer every x bullets.
SWEP.BulletTracerName = nil -- Use a custom effect for the tracer.
SWEP.BulletForce = 30;

--[[ Set up the ironsight's position and angles. --]]
SWEP.IronSightsPos = nil;
SWEP.IronSightsAng = nil;

--[[Set up the accuracy for the weapon. --]]
SWEP.CrouchCone				= 0.01 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.02 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.025 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.015 -- Accuracy when we're standing still
SWEP.IronSightsCone			= 0.006 -- Accuracy when we're aiming

--[[
	AR2, AlyxGun, Pistol, SMG1, 357, XBowBolt, Buckshot,
	RPG_Round, SMG1_Grenade, SniperRound, SniperPenetratedRound,
	Grenade, Thumper, Gravity, Battery, GaussEnergy, CombineCannon,
	AirboatGun, StriderMinigun, HelicopterGun, AR2AltFire, Slam
--]]

--[[ Begin giving definitions of virtual functions. --]]

-- Called when the SWEP's iron sights value has changed.
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

--[[
	Called when when the SWEP is being reloaded.
	Return true to override the default action.
--]]
function SWEP:OnReload() end;

-- Called every frame.
function SWEP:OnThink() end;

--[[ Begin giving definitions of base functions and hooks. --]]

-- Called when the SWEP has initialized.
function SWEP:Initialize()
	if (SERVER) then
		self:SetNPCMinBurst(30);
		self:SetNPCMaxBurst(30);
		self:SetNPCFireRate(0.01);
	end;
	
	self:SetWeaponHoldType(self.HoldType);
	
	if (self.OnInitialize) then
		self:OnInitialize();
	end;
end;

-- Called when the SWEP's data tables should be setup.
function SWEP:SetupDataTables()
	self:DTVar("Bool", 0, "IronSights");
	self:DTVar("Float", 0, "LastFire");
	
	if (self.OnSetupDataTables) then
		self:OnSetupDataTables();
	end;
end;

-- Called when when the SWEP is being reloaded.
function SWEP:Reload()

	if self.Owner:KeyDown(IN_ATTACK) then return end;
	if( self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self.Weapon:Clip1() >= self.Primary.ClipSize)	then return end;
	if (!self.OnReload or self:OnReload() != true) then
		self.Weapon:DefaultReload(ACT_VM_RELOAD);
		self:SetIronSights(false);
		
	if (self.ReloadSound) then 
		self.Weapon:EmitSound(self.Primary.Reload)
		end;
	end;
end;

-- Called every frame.
function SWEP:Think()
	if (self.OnThink) then
		self:OnThink();
	end;
end;

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
		self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
	return true
end;

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

-- Called when the SWEP's secondary attack is fired.
function SWEP:SecondaryAttack()
	if (!self.IronSightsPos) then return; end;
	
	self:SetIronSights(!self.dt.IronSights);
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.3);
end;

--[[
	A function to handle bullet firing given specific parameters.
	You can override this to handle it in your own way.
--]]
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

--[[
	Called when the weapon select should be drawn.
	Override this in your SWEP if you want it differently.
--]]
function SWEP:DrawWeaponSelection(x, y, width, height, alpha)
	draw.SimpleText(
		self.IconLetter, "CSSelectIcons", x + (width / 2), y + (height * 0.2), Color(255, 200, 0, 255), TEXT_ALIGN_CENTER
	);
end;

local IRONSIGHT_TIME = 0.25;

-- Called when the view model position is needed.
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

-- A function to set whether the iron sights are enabled.
function SWEP:SetIronSights(bEnabled)
	self.dt.IronSights = bEnabled;
	
	if (self.OnIronSightsChanged) then
		self.OnIronSightsChanged(bEnabled);
	end;
end;

-- A function for spreading.
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

function SWEP:Think()
	self:SpreadSystem();
end;