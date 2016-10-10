if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "AUG"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4
	
end;

SWEP.HoldType				= "smg"
SWEP.Base					= "bs_base"
SWEP.Category				= "BackSword 2"
SWEP.ViewModelFOV			= 60
SWEP.ViewModelFlip			= false

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.UseHands				= true

SWEP.ViewModel				= "models/weapons/cstrike/c_rif_aug.mdl"
SWEP.WorldModel				= "models/weapons/w_rif_aug.mdl"

SWEP.Primary.Sound			= Sound( "weapon_aug.Single" )
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 30
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.01
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.09
SWEP.Primary.DefaultClip	= 150
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"


SWEP.IronSightsPos 			= Vector(-3.641, -6.031, 2.519)
SWEP.IronSightsAng 			= Vector(2.321, 0, 0)

SWEP.CrouchCone				= 0.01
SWEP.CrouchWalkCone			= 0.02
SWEP.WalkCone				= 0.025
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.015