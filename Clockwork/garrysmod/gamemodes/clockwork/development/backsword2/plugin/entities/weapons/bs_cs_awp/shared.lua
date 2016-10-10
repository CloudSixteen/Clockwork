if (SERVER) then
	AddCSLuaFile("shared.lua")
end;

if (CLIENT) then
	SWEP.PrintName 			= "AWP"
	SWEP.Slot 				= 4
	SWEP.Author				= "Zig"

end;

SWEP.Category				= "BackSword 2"
SWEP.Base					= "bs_sniper_base"
SWEP.HoldType 				= "ar2"
SWEP.Spawnable 				= true;
SWEP.AdminSpawnable 		= true;

SWEP.ViewModel 				= "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel 			= "models/weapons/w_snip_awp.mdl"
SWEP.UseHands				= true;
SWEP.ViewModelFOV			= 70
SWEP.ViewModelFOV			= 65
SWEP.Primary.Sound 			= Sound("Weapon_awp.Single")
SWEP.Primary.Damage 		= 95
SWEP.Primary.Recoil 		= 6
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.0001
SWEP.Primary.ClipSize 		= 10
SWEP.Primary.Delay 			= 1.2
SWEP.Primary.DefaultClip 	= 40
SWEP.Primary.Automatic 		= false;
SWEP.Primary.Ammo 			= "smg1"

SWEP.IronSightsPos 			= Vector(-7.481, -3.619, 2.24)
SWEP.IronSightsAng 			= Vector(0, 0, 0)

SWEP.UseScope				= true -- Use a scope instead of iron sights.
SWEP.ScopeScale 			= 0.55 -- The scale of the scope's reticle in relation to the player's screen size.
SWEP.ScopeZoom				= 4

SWEP.Scope1					= true;
SWEP.BoltAction				= true;

SWEP.CrouchCone				= 0.0001 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.2 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.2 -- Accuracy when we're walking
SWEP.AirCone				= 0.5 -- Accuracy when we're in air
SWEP.StandCone				= 0.0001 -- Accuracy when we're standing still