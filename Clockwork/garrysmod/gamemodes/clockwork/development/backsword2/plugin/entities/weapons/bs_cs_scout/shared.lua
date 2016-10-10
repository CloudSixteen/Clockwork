if (SERVER) then
	AddCSLuaFile("shared.lua")

end;

if (CLIENT) then
	SWEP.PrintName 		= "SCOUT"
	SWEP.Author			= "Zig"
	SWEP.Slot 			= 3
	SWEP.SlotPos 		= 1

end;

SWEP.Category				= "BackSword 2"
SWEP.Base					= "bs_sniper_base"
SWEP.HoldType 				= "ar2"

SWEP.Spawnable 				= true;
SWEP.AdminSpawnable 		= true;

SWEP.ViewModel 				= "models/weapons/cstrike/c_snip_scout.mdl"
SWEP.WorldModel 			= "models/weapons/w_snip_scout.mdl"
SWEP.ViewModelFOV			= 60
SWEP.UseHands				= true;
SWEP.ViewModelFlip			= false;

SWEP.Primary.Sound 			= Sound("Weapon_SCOUT.Single")
SWEP.Primary.Damage 		= 70
SWEP.Primary.Recoil 		= 1.5
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.0001
SWEP.Primary.ClipSize 		= 10
SWEP.Primary.Delay 			= 1.2
SWEP.Primary.DefaultClip 	= 90
SWEP.Primary.Automatic 		= false;
SWEP.Primary.Ammo 			= "smg1"

SWEP.IronSightsPos 			= nil;
SWEP.IronSightsAng 			= nil;

SWEP.UseScope				= true;
SWEP.ScopeZoom				= 8

SWEP.Scope1					= true;
SWEP.BoltAction				= true;

SWEP.CrouchCone				= 0.001
SWEP.CrouchWalkCone			= 0.005
SWEP.WalkCone				= 0.025
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.001