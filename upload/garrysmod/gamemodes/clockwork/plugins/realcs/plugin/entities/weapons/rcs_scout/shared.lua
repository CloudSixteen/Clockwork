--real scout


if (SERVER) then

	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if (CLIENT) then
	SWEP.PrintName			= "Scout"	
	SWEP.Author				= "cheesylard"
	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
		
		
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "n"
	SWEP.NameOfSWEP			= "rcs_scout" --always make this the name of the folder the SWEP is in. 
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end
	SWEP.HoldType			= "ar2"
SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base_bsnip"
SWEP.Penetrating = true
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel				= "models/weapons/v_snip_scout.mdl"
SWEP.WorldModel				= "models/weapons/w_snip_scout.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("Weapon_scout.Single")
SWEP.Primary.Recoil			= 0.25
SWEP.Primary.Damage			= 75
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.00001 --starting cone, it WILL increase to something higher, so keep it low
SWEP.Primary.ClipSize		= 10
SWEP.Primary.Delay			= 1.2
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.MaxReserve		= 90
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ar2"
SWEP.MoveSpread				= 6 --multiplier for spread when you are moving
SWEP.JumpSpread				= 10 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.5 --multiplier for spread when you are crouching

SWEP.Zoom					= "no" --pretty self explanitory, don't change this unless if you want the gun to be fucked up
SWEP.ZoomOutDelay			= 0.1 -- this is used for the delay between when you shoot and when it zooms out to pull the bolt
SWEP.ZoomInDelay			= 1.4 --always set this 0.2 higher than SWEP.Primary.Delay
SWEP.Zoom1					= 30 --Field of view for the first zoom
SWEP.Zoom2					= 15 --field of view for the second zoom

SWEP.Zoom0Cone				= 0.00001 --cone when not zoomed
SWEP.Zoom1Cone				= 0.001 --cone when zoomed once
SWEP.Zoom2Cone				= 0.0001 --cone when zoomed twice


SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = Vector (5.0377, 0, 2.3766)
SWEP.IronSightsAng = Vector (0, 0, 0)
