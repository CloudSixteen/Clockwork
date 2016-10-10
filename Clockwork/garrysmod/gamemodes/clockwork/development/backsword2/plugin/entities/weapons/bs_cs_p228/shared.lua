if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "P228"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4
	
end;

SWEP.HoldType			= "pistol"
SWEP.Base				= "bs_base"
SWEP.Category			= "BackSword 2"

SWEP.Spawnable			= true;
SWEP.AdminSpawnable		= true;

SWEP.ViewModel			= "models/weapons/cstrike/c_pist_p228.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_p228.mdl"
SWEP.UseHands			= true;
SWEP.ViewModelFlip		= false;
SWEP.ViewModelFOV		= 60

SWEP.Primary.Sound			= Sound( "Weapon_p228.Single" )
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 13
SWEP.Primary.Delay			= 0.08
SWEP.Primary.DefaultClip	= 65
SWEP.Primary.Automatic		= false;
SWEP.Primary.Ammo			= "pistol"

SWEP.IronSightsPos 			= Vector(-6, -5.226, 2.559)
SWEP.IronSightsAng 			= Vector(0.275, -0.13, 0)

SWEP.CrouchCone				= 0.02
SWEP.CrouchWalkCone			= 0.025
SWEP.WalkCone				= 0.03
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.02