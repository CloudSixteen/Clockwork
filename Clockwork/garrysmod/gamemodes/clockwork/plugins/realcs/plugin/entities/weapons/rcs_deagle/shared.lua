--REAL CS BASE
--sorry for no comments to show what everything does im too lazy to do it LOL!

if (SERVER) then

	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5


end

if (CLIENT) then
	SWEP.PrintName			= "Desert Eagle"	
	SWEP.Author				= "cheesylard"
	SWEP.SlotPos			= 2
	SWEP.Slot				= 1
	SWEP.IconLetter			= "f"
	SWEP.NameOfSWEP			= "rcs_deagle" --always make this the name of the folder the SWEP is in.
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base_pistol"

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

	SWEP.HoldType			= "pistol"
SWEP.ViewModel				= "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel				= "models/weapons/w_pist_deagle.mdl"
SWEP.Penetrating = true
SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("Weapon_deagle.Single")
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 36
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.001 --starting cone, it WILL increase to something higher, so keep it low
SWEP.Primary.ClipSize		= 7
SWEP.Primary.Delay			= 0.19
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.MaxReserve		= 35
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "357"

SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.5 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.SpreadIncrease	= 0.21/15 --how much you add to the cone after each shot

SWEP.MoveSpread				= 6 --multiplier for spread when you are moving
SWEP.JumpSpread				= 10 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.5 --multiplier for spread when you are crouching

SWEP.DryFires				= true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = Vector (5.1623, 0, 2.7762)
SWEP.IronSightsAng = Vector (0, 0, 0)
