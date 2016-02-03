if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "GLOCK"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4

end;

SWEP.HoldType			= "pistol"
SWEP.Base				= "bs_base"
SWEP.Category			= "BackSword 2"

SWEP.Spawnable			= true;
SWEP.AdminSpawnable		= true;

SWEP.ViewModel			= "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_glock18.mdl"
SWEP.UseHands			= true;
SWEP.ViewModelFlip		= false;
SWEP.ViewModelFOV		= 60

SWEP.Primary.Sound			= Sound( "Weapon_Glock.Single" )
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 15
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 20
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= 500
SWEP.Primary.Automatic		= false;
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 			= Vector(-5.779, -5.755, 2.799)
SWEP.IronSightsAng 			= Vector(0.423, 0, 0)

SWEP.CrouchCone				= 0.02
SWEP.CrouchWalkCone			= 0.025
SWEP.WalkCone				= 0.03
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.02