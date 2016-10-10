if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "MP5"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4

end;

SWEP.HoldType			= "smg"
SWEP.Base				= "bs_base"
SWEP.Category			= "BackSword 2"

SWEP.Spawnable			= true;
SWEP.AdminSpawnable		= true;

SWEP.ViewModel			= "models/weapons/cstrike/c_smg_mp5.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_mp5.mdl"
SWEP.ViewModelFlip		= false;
SWEP.ViewModelFOV		= 55
SWEP.UseHands 			= true;

SWEP.Primary.Sound			= Sound( "Weapon_MP5Navy.Single" )
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 25
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.025
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.08
SWEP.Primary.DefaultClip	= 150
SWEP.Primary.Automatic		= true;
SWEP.Primary.Ammo			= "smg1"

SWEP.IronSightsPos 			= Vector(-5.34, -4.824, 2.012)
SWEP.IronSightsAng 			= Vector(0.282, 0, 0.135)

SWEP.CrouchCone				= 0.02
SWEP.CrouchWalkCone			= 0.03
SWEP.WalkCone				= 0.03
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.03
SWEP.Recoil					= 2.5
SWEP.RecoilZoom				= 0.8


