if (SERVER) then
	AddCSLuaFile("shared.lua")
end;

if (CLIENT) then
	SWEP.PrintName 			= "G3SG1"
	SWEP.Author 			= "Zig"
	SWEP.ViewModelFOV		= 60
	SWEP.Slot 				= 4

end;

SWEP.Category				= "BackSword 2"
SWEP.Base 					= "bs_sniper_base"
SWEP.HoldType 				= "ar2"
SWEP.Spawnable 				= true;
SWEP.AdminSpawnable 		= true;

SWEP.ViewModel 				= "models/weapons/cstrike/c_snip_g3sg1.mdl"
SWEP.WorldModel 			= "models/weapons/w_snip_g3sg1.mdl"
SWEP.UseHands				= true;

SWEP.Primary.Sound 			= Sound("Weapon_G3SG1.Single")
SWEP.Primary.Damage 		= 45
SWEP.Primary.Recoil 		= 1.5
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.001
SWEP.Primary.ClipSize 		= 20
SWEP.Primary.Delay 			= 0.2
SWEP.Primary.DefaultClip 	= 110
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "smg1"

SWEP.Secondary.Automatic	= true

SWEP.IronSightsPos 			= nil;
SWEP.IronSightsAng 			= nil;

SWEP.UseScope				= true;
SWEP.ScopeScale 			= 0.55
SWEP.ScopeZoom				= 3

SWEP.Scope1					= false;
SWEP.Scope2					= true;
SWEP.Scope3					= false;
SWEP.BoltAction				= false;

SWEP.CrouchCone				= 0.001
SWEP.CrouchWalkCone			= 0.005
SWEP.WalkCone				= 0.025
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.001