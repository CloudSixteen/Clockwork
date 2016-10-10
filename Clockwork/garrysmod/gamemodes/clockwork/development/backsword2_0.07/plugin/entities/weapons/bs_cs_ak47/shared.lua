if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "AK-47"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4

end;

SWEP.HoldType				= "ar2"
SWEP.Base					= "bs_base"
SWEP.Category				= "BackSword 2"
SWEP.ViewModelFlip			= false
SWEP.ViewModelFOV			= 57

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.UseHands				= true

SWEP.ViewModel				= "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel				= "models/weapons/w_rif_ak47.mdl"

SWEP.Primary.Sound			= Sound( "weapon_ak47.single" )
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 34
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= 120
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 			= Vector(-6.6, -10.117, 2.599)
SWEP.IronSightsAng 			= Vector(2.076, 0.134, 0)

SWEP.CrouchCone				= 0.01
SWEP.CrouchWalkCone			= 0.02
SWEP.WalkCone				= 0.025
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.015