if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "M4A1"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4
	
end;

SWEP.HoldType			= "ar2"
SWEP.Base				= "bs_base"
SWEP.Category			= "BackSword 2"

SWEP.Spawnable			= true;
SWEP.AdminSpawnable		= true;

SWEP.ViewModel			= "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_m4a1.mdl"
SWEP.ViewModelFlip		= false;
SWEP.ViewModelFOV		= 60
SWEP.UseHands			= true;

SWEP.Primary.Sound			= Sound( "Weapon_M4A1.Single" )
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 28
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.08
SWEP.Primary.DefaultClip	= 120
SWEP.Primary.Automatic		= true;
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 			= Vector(-4.04, -4.824, 0.839)
SWEP.IronSightsAng 			= Vector(1.315, 0, 0)

SWEP.CrouchCone				= 0.012
SWEP.CrouchWalkCone			= 0.02
SWEP.WalkCone				= 0.025
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.015