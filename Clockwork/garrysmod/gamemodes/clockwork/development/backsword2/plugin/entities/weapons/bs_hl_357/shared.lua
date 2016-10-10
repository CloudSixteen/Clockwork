if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "357"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4
	
end;

SWEP.HoldType			= "pistol"
SWEP.Base				= "bs_base"
SWEP.Category			= "BackSword 2: HL2"

SWEP.Spawnable			= true;
SWEP.AdminSpawnable		= true;

SWEP.ViewModel			= "models/weapons/c_357.mdl"
SWEP.WorldModel			= "models/weapons/w_357.mdl"
SWEP.ViewModelFlip		= false;
SWEP.UseHands			= true;
SWEP.ViewModelFOV		= 57

SWEP.Primary.Sound			= Sound( "weapons/357/357_fire2.wav" )
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 6
SWEP.Primary.Delay			= 0.7
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= false;
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = nil;
SWEP.IronSightsAng = nil;

SWEP.CrouchCone				= 0.02
SWEP.CrouchWalkCone			= 0.025
SWEP.WalkCone				= 0.03
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.02

function SWEP:PrimaryAttack()
			self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay);
			self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
			self.Owner:ViewPunch( Angle( -9,math.random(-2,2),0 ) )
	
		if (!self:CanPrimaryAttack()) then return; end; 
			self.Weapon:EmitSound(self.Primary.Sound);
			self:HandleBullets(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone);
			self:TakePrimaryAmmo(1);
		if (self.Owner:IsNPC()) then return; end;
		if ((game.SinglePlayer() and SERVER) || CLIENT) then
			self.dt.LastFire = CurTime();
	end;
end;