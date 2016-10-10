if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "XM1014"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4
	
end;

SWEP.HoldType			= "shotgun"
SWEP.Base				= "bs_shotgun_base"
SWEP.Category			= "BackSword 2"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel			= "models/weapons/w_shot_xm1014.mdl"
SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= true

SWEP.Primary.Sound			= Sound( "Weapon_xm1014.Single" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 10
SWEP.Primary.NumShots		= 8
SWEP.Primary.Cone			= 0.05
SWEP.Primary.ClipSize		= 7
SWEP.Primary.Delay			= 0.2
SWEP.Primary.DefaultClip	= 39
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "buckshot"

SWEP.IronSightsPos 			= Vector(-6.933, -6.433, 2.641)
SWEP.IronSightsAng 			= Vector(0.324, -0.726, 0)