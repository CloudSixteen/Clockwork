if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end;

if ( CLIENT ) then

	SWEP.PrintName			= "TMP"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4
	
end;

SWEP.HoldType			= "ar2"
SWEP.Base				= "bs_base"
SWEP.Category			= "BackSword 2"

SWEP.Spawnable			= true;
SWEP.AdminSpawnable		= true;

SWEP.ViewModel			= "models/weapons/cstrike/c_smg_tmp.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_tmp.mdl"
SWEP.ViewModelFOV		= 60
SWEP.UseHands			= true;
SWEP.ViewModelFlip		= false;

SWEP.Primary.Sound			= Sound( "Weapon_tmp.Single" )
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 25
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.04
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.075
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= true;
SWEP.Primary.Ammo			= "smg1"

SWEP.IronSightsPos 			= Vector(-2.881, -6.031, 1.919)
SWEP.IronSightsAng 			= Vector(0, 0, 0)

SWEP.CrouchCone				= 0.025
SWEP.CrouchWalkCone			= 0.03
SWEP.WalkCone				= 0.04
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.04