if (SERVER) then
	AddCSLuaFile("shared.lua")

end;

if (CLIENT) then
	SWEP.PrintName 			= "SG550"
	SWEP.Author				= "Zig"
	SWEP.Slot 				= 4

end;

SWEP.Base 					= "bs_sniper_base"
SWEP.Category				= "BackSword 2"
SWEP.HoldType 				= "ar2"

SWEP.Spawnable 				= true;
SWEP.AdminSpawnable 		= true;

SWEP.ViewModel 				= "models/weapons/cstrike/c_snip_sg550.mdl"
SWEP.WorldModel 			= "models/weapons/w_snip_sg550.mdl"
SWEP.ViewModelFlip			= false;
SWEP.UseHands				= true;
SWEP.ViewModelFOV			= 62

SWEP.Primary.Sound 			= Sound("Weapon_SG550.Single")
SWEP.Primary.Damage 		= 45
SWEP.Primary.Recoil 		= 1.5
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.001
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0.2
SWEP.Primary.DefaultClip 	= 90
SWEP.Primary.Automatic 		= true;
SWEP.Primary.Ammo 			= "smg1"

SWEP.IronSightsPos 			= nil;
SWEP.IronSightsAng 			= nil;

SWEP.UseScope				= true;
SWEP.ScopeZoom				= 3

SWEP.Scope1					= true;
SWEP.BoltAction				= false;

SWEP.CrouchCone				= 0.001
SWEP.CrouchWalkCone			= 0.005
SWEP.WalkCone				= 0.025
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.001