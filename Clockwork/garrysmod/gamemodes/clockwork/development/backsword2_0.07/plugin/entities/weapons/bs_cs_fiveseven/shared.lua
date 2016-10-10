

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "FIVE SEVEN"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4
	
end;

SWEP.HoldType			= "pistol"
SWEP.Base				= "bs_base"
SWEP.Category			= "BackSword 2"

SWEP.Spawnable			= true;
SWEP.AdminSpawnable		= true;

SWEP.ViewModel			= "models/weapons/cstrike/c_pist_fiveseven.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_fiveseven.mdl"
SWEP.ViewModelFOV		= 60
SWEP.UseHands 			= true;
SWEP.ViewModelFlip		= false;

SWEP.Primary.Sound			= Sound( "Weapon_FiveSeven.Single" )
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 20
SWEP.Primary.Delay			= 0.08
SWEP.Primary.DefaultClip	= 120
SWEP.Primary.Automatic		= false;
SWEP.Primary.Ammo			= "pistol"

SWEP.IronSightsPos 			= Vector(-5.961, -3.619, 2.759)
SWEP.IronSightsAng 			= Vector(0, 0, 0)

SWEP.CrouchCone				= 0.02
SWEP.CrouchWalkCone			= 0.025
SWEP.WalkCone				= 0.03
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.02
SWEP.Recoil					= 2.5
SWEP.RecoilZoom				= 0.7
SWEP.Delay					= 0.08
