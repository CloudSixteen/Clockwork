--REAL CS BASE
--sorry for no comments to show what everything does im too lazy to do it LOL!

if (SERVER) then

	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5


end

if (CLIENT) then
	SWEP.PrintName			= "FiveSeven"	
	SWEP.Author				= "cheesylard"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 2
	SWEP.IconLetter			= "u"
	SWEP.NameOfSWEP			= "rcs_57" --always make this the name of the folder the SWEP is in.
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base_pistol"

	SWEP.HoldType			= "pistol"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel				= "models/weapons/v_pist_fiveseven.mdl"
SWEP.WorldModel				= "models/weapons/w_pist_fiveseven.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("Weapon_FiveSeven.Single")
SWEP.Primary.Recoil			= 0.3
SWEP.Primary.Damage			= 24
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.001
SWEP.Primary.ClipSize		= 20
SWEP.Primary.Delay			= 0.08
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "xbowbolt"
SWEP.Primary.MaxReserve		= 60

SWEP.MoveSpread				= 2.0 --multiplier for spread when you are moving
SWEP.JumpSpread				= 4.3 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.26 --multiplier for spread when you are crouching

SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.5 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.SpreadIncrease	= 0.21/15 --how much you add to the cone after each shot

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = Vector (4.5359, 0, 3.3108)
SWEP.IronSightsAng = Vector (0, 0, 0)
