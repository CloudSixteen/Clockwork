if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "M249"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4
	
end;

SWEP.HoldType			= "ar2"
SWEP.Base				= "bs_base"
SWEP.Category			= "BackSword 2"

SWEP.Spawnable			= true;
SWEP.AdminSpawnable		= true;

SWEP.ViewModel			= "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.WorldModel			= "models/weapons/w_mach_m249para.mdl"
SWEP.ViewModelFOV		= 60
SWEP.UseHands			= true;
SWEP.ViewModelFlip		= false;

SWEP.Primary.Sound			= Sound( "Weapon_m249.Single" )
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= 30
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.05
SWEP.Primary.ClipSize		= 100
SWEP.Primary.Delay			= 0.09
SWEP.Primary.DefaultClip	= 200
SWEP.Primary.Automatic		= true;
SWEP.Primary.Ammo			= "smg1"

SWEP.IronSightsPos 			= Vector(-5.981, 0, 2.359)
SWEP.IronSightsAng 			= Vector(0, -0.066, 0)

SWEP.CrouchCone				= 0.02
SWEP.CrouchWalkCone			= 0.05
SWEP.WalkCone				= 0.09
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.07