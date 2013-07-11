--RealM4A1
--If you want to edit this so it's a pistol, this is NOT for you. Edit rcs_usp

if (SERVER) then

	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end
--9270723, 9270713, 6232709
if (CLIENT) then
	SWEP.PrintName			= "M4A1"	
	SWEP.Author				= "cheesylard"
	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
	
	
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "w"
		
	SWEP.NameOfSWEP			= "rcs_m4a1" --always make this the name of the folder the SWEP is in.
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

	SWEP.HoldType			= "ar2"
SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base_silencer_rifle"
SWEP.Penetrating = true
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel				= "models/weapons/v_rif_m4a1.mdl"
SWEP.WorldModel				= "models/weapons/w_rif_m4a1.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("Weapon_m4a1.Single")
SWEP.Primary.Recoil			= 0.15
SWEP.Primary.Damage			= 36
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.001
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.08
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.MaxReserve		= 90
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.SilencedDamage			= 40
SWEP.SilencedRecoil			= 0.1
SWEP.SilencedCone			= 0.005
SWEP.SilencedSound			= Sound("Weapon_M4a1.Silenced")
SWEP.SilencedNumShots		= 1
SWEP.IsSilenced				= false
SWEP.SilenceTime			= 2

SWEP.Primary.MaxSpread		= 0.1 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.5 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.SpreadIncrease	= 0.21/15 --how much you add to the cone after each shot

SWEP.SilencedSpreadIncrease	= 0.19/15
SWEP.SilencedMaxSpread		= 0.13
SWEP.SilencedHandle			= 0.4

SWEP.MoveSpread				= 6 --multiplier for spread when you are moving
SWEP.JumpSpread				= 8 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.5 --multiplier for spread when you are crouching

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"


SWEP.IronSightsPos = Vector(4, 0, 1)
SWEP.IronSightsAng = Vector (3.2776, 1.3466, 2.6221)