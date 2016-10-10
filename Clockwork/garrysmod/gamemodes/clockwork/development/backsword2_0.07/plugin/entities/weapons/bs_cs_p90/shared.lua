if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "P90"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4
	
end;

SWEP.HoldType			= "smg"
SWEP.Base				= "bs_base"
SWEP.Category			= "BackSword 2"

SWEP.Spawnable			= true;
SWEP.AdminSpawnable		= true;

SWEP.ViewModel			= "models/weapons/cstrike/c_smg_p90.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_p90.mdl"
SWEP.UseHands			= true;
SWEP.ViewModelFOV		= 60
SWEP.ViewModelFlip		= false;

SWEP.Primary.Sound			= Sound( "Weapon_p90.Single" )
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 20
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.03
SWEP.Primary.ClipSize		= 50
SWEP.Primary.Delay			= 0.07
SWEP.Primary.DefaultClip	= 150
SWEP.Primary.Automatic		= true;
SWEP.Primary.Ammo			= "smg1"

SWEP.IronSightsPos 			= Vector(-2.52, -5.428, 2.319)
SWEP.IronSightsAng 			= Vector(0, 0, 0)

SWEP.CrouchCone				= 0.025
SWEP.CrouchWalkCone			= 0.03
SWEP.WalkCone				= 0.04
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.04