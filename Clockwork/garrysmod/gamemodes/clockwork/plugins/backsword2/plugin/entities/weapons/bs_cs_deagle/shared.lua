
if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end;

if ( CLIENT ) then

	SWEP.PrintName			= "DESERT EAGLE"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4

end;

SWEP.HoldType			= "pistol"
SWEP.Base				= "bs_base"
SWEP.Category			= "BackSword 2"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_deagle.mdl"
SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 40

SWEP.Primary.Sound			= Sound( "Weapon_Deagle.Single" )
SWEP.Primary.Recoil			= 5
SWEP.Primary.Damage			= 60
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.015
SWEP.Primary.ClipSize		= 7
SWEP.Primary.Delay			= 0.2
SWEP.Primary.DefaultClip	= 35
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"

SWEP.IronSightsPos 			= Vector(-6.381, 0, 2.119)
SWEP.IronSightsAng 			= Vector(0, 0, 0)

SWEP.CrouchCone				= 0.01
SWEP.CrouchWalkCone			= 0.02
SWEP.WalkCone				= 0.025
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.015