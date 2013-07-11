--REAL sg552
--sorry for no comments to show what everything does im too lazy to do it LOL!

if (SERVER) then

	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if (CLIENT) then
	SWEP.PrintName			= "SG-552"	
	SWEP.Author				= "cheesylard"
	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
	
	
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "A"
		
	SWEP.NameOfSWEP			= "rcs_sg552" --always make this the name of the folder the SWEP is in.
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base_1scope"
SWEP.Penetrating = true
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
	SWEP.HoldType			= "ar2"
SWEP.ViewModel				= "models/weapons/v_rif_sg552.mdl"
SWEP.WorldModel				= "models/weapons/w_rif_sg552.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("Weapon_SG552.Single")
SWEP.Primary.Recoil			= 0.25
SWEP.Primary.Damage			= 32
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.001 --starting cone, it WILL increase to something higher, so keep it low
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.12
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.MaxReserve		= 90
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"
SWEP.Zoom					= "no"
SWEP.Zoom1					= 40

SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.5 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.SpreadIncrease	= 0.21/15 --how much you add to the cone after each shot

SWEP.Primary.Zoom1MaxSpread		= 0.1 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Zoom1Handle			= 0.3 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.Zoom1SpreadIncrease	= 0.15/15 --how much you add to the cone after each shot

SWEP.Zoom0Cone				= 0.07 --cone when not zoomed
SWEP.Zoom0Delay				= 0.10 --delay when not zoomed

SWEP.Zoom1Cone				= 0.0005 --cone when zoomed
SWEP.Zoom1Delay				= 0.15 --delay when zoomed

SWEP.MoveSpread				= 6 --multiplier for spread when you are moving
SWEP.JumpSpread				= 10 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.5 --multiplier for spread when you are crouching


SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"


SWEP.IronSightsPos = Vector (5.741, -3.7658, 3.2987)
SWEP.IronSightsAng = Vector (0.8252, -2.6023, -0.1554)