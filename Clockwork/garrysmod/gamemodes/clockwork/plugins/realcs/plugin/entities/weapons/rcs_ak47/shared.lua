--REAL CS BASE
--sorry for no comments to show what everything does im too lazy to do it LOL!

if (SERVER) then

	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5


end

if (CLIENT) then
	SWEP.PrintName			= "AK47"	
	SWEP.Author				= "cheesylard"
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "b"
	SWEP.NameOfSWEP			= "rcs_ak47" --always make this the name of the folder the SWEP is in.
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base"

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.Penetrating = true
	SWEP.HoldType			= "ar2"
SWEP.ViewModel				= "models/weapons/v_rif_ak47.mdl"
SWEP.WorldModel				= "models/weapons/w_rif_ak47.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("Weapon_ak47.Single")
SWEP.Primary.Recoil			= 0.25
SWEP.Primary.Damage			= 30
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0001
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.11
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.MaxReserve		= 90
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.MoveSpread				= 2 --multiplier for spread when you are moving
SWEP.JumpSpread				= 4 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.12 --multiplier for spread when you are crouching

--[[SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.5 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.HandleCut		= 15 --the higher the number, the less it spreads, you may need to increase it with SWEP.Primary.Handle,  as it can effect the spread
SWEP.Primary.SpreadIncrease	= 0.21 --how much you add to the cone after each shot]]

SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.5 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.SpreadIncrease	= 0.21/15 --how much you add to the cone after each shot

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = Vector (6.0876, -2.6783, 1.7266)
SWEP.IronSightsAng = Vector (3.8043, -0.1006, 0)
