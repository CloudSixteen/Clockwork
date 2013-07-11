--this is NOT a template

if (SERVER) then

	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if (CLIENT) then
	SWEP.PrintName			= "Glock"	
	SWEP.Author				= "cheesylard"
	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
	SWEP.NameOfSWEP			= "rcs_glock" --always make this the name of the folder the SWEP is in.
	
	SWEP.Slot				= 1
	SWEP.SlotPos			= 2
	SWEP.IconLetter			= "c"
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base_burst_pistol"
	SWEP.HoldType			= "pistol"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel				= "models/weapons/v_pist_glock18.mdl"
SWEP.WorldModel				= "models/weapons/w_pist_glock18.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.BurstType = "pistol"

SWEP.Primary.Sound			= Sound("Weapon_Glock.Single")
SWEP.Primary.Recoil			= 0.25
SWEP.Primary.Damage			= 24
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0001 --starting cone, it WILL increase to something higher, so keep it low
SWEP.Primary.ClipSize		= 20
SWEP.Primary.Delay			= 0.12
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.MaxReserve		= 120
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"
SWEP.PistolBurst			= true

SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.5 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.SpreadIncrease	= 0.21/15 --how much you add to the cone after each shot

SWEP.BurstRecoil			= 0.5
SWEP.BurstCone				= 0.01
//SWEP.BurstSound				= Sound("Weapon_AWP.Single")
SWEP.BurstNumShots			= 3
SWEP.IsBurst				= false
SWEP.BurstDelay				= 0.6

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.MoveSpread				= 5 --multiplier for spread when you are moving
SWEP.JumpSpread				= 10 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.5 --multiplier for spread when you are crouching

SWEP.IronSightsPos = Vector (4.3646, 0, 2.9899)
SWEP.IronSightsAng = Vector (0, 0, 0)