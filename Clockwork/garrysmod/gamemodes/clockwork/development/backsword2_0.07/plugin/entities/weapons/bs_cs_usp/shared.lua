if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "USP"			
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 4
	
end;

SWEP.HoldType			= "pistol"
SWEP.Base				= "bs_base"
SWEP.Category			= "BackSword 2"

SWEP.Spawnable			= true;
SWEP.AdminSpawnable		= true;

SWEP.ViewModel			= "models/weapons/cstrike/c_pist_usp.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_usp.mdl"
SWEP.ViewModelFlip		= false;
SWEP.UseHands			= true;
SWEP.ViewModelFOV		= 57

SWEP.Primary.Sound			= Sound( "Weapon_usp.Single" )
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 12
SWEP.Primary.Delay			= 0.08
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= false;
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 			= Vector(-5.921, -6.231, 2.519)
SWEP.IronSightsAng 			= Vector(0, 0, 0)

SWEP.CrouchCone				= 0.02
SWEP.CrouchWalkCone			= 0.025
SWEP.WalkCone				= 0.03
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.02