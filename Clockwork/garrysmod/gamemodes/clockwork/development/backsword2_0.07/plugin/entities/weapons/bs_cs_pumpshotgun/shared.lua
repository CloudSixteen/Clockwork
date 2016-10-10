if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "M3 SUPER 90"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4

end;

SWEP.HoldType			= "shotgun"
SWEP.Base				= "bs_shotgun_base"
SWEP.Category			= "BackSword 2"

SWEP.Spawnable			= true;
SWEP.AdminSpawnable		= true;

SWEP.ViewModel			= "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel			= "models/weapons/w_shot_m3super90.mdl"
SWEP.ViewModelFlip	    = false;
SWEP.ViewModelFOV       = 55
SWEP.UseHands		 	= true;

SWEP.Primary.Sound			= Sound( "Weapon_m3.Single" )
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= 15
SWEP.Primary.NumShots		= 8
SWEP.Primary.Cone			= 0.03
SWEP.Primary.ClipSize		= 8
SWEP.Primary.Delay			= 1.0
SWEP.Primary.DefaultClip	= 32
SWEP.Primary.Automatic		= false;
SWEP.Primary.Ammo			= "buckshot"

SWEP.IronSightsPos 			= Vector(-7.64, -2.412, 3.319)
SWEP.IronSightsAng 			= Vector(0, -0, 0)