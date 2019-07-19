--IF YOU WANT TO MODIFY THIS SWEP GO TO RCS_G3SG1 INSTEAD, UNLESS IF YOU WANT TO EDIT THE FUNCTIONS OR SOMETHING THEN GO AHEAD

//http://forums.facepunchstudios.com/showthread.php?t=598694
if (SERVER) then

	AddCSLuaFile("shared.lua")

end

if (CLIENT) then

	SWEP.PrintName			= "SIG SG 550"	
	SWEP.Author				= "cheesylard"
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "o"
	SWEP.NameOfSWEP			= "rcs_sg550" --always make this the name of the folder the SWEP is in. 
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
	
end

SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base_bsnip"

SWEP.Spawnable				= false
SWEP.AdminSpawnable			= false
	SWEP.HoldType			= "ar2"
SWEP.ViewModel				= "models/weapons/v_snip_sg550.mdl"
SWEP.WorldModel				= "models/weapons/w_snip_sg550.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("Weapon_sg550.Single")
SWEP.Primary.Recoil			= 0.25
SWEP.Primary.Damage			= 15
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0001 --starting cone, it WILL increase to something higher, so keep it low
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.25
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"
SWEP.MoveSpread				= 8 --multiplier for spread when you are moving
SWEP.JumpSpread				= 15 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.5 --multiplier for spread when you are crouching

SWEP.Zoom					= 0 --pretty self explanitory, don't change this unless if you want the gun to be fucked up
//SWEP.ZoomOutDelay			= 0.2 -- Not used because this is an autosniper
//SWEP.ZoomInDelay			= 1.5 --Not used because this is an autosniper
SWEP.Zoom1					= 30 --Field of view for the first zoom
SWEP.Zoom2					= 15 --field of view for the second zoom

SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.5 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.SpreadIncrease	= 0.21/15 --how much you add to the cone after each shot

SWEP.IncreasesSpread		= true --unlike the AWP, this does increase spread, thus we need to declare this variable
SWEP.Primary.MaxSpread		= 0.10 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.6
SWEP.Primary.SpreadIncrease = 0.2/15

SWEP.Zoom0Cone				= 0.1 --spread for when not zoomed
SWEP.Zoom1Cone				= 0.01 --spread for when zoomed once
SWEP.Zoom2Cone				= 0.01 --spread for when zoomed twice

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = Vector (5.6005, 0, 1.8745)
SWEP.IronSightsAng = Vector (0, 0, 0)

function SWEP:ZoomOut() end
function SWEP:ZoomBackIn() end --this weapon does not have a pull-bolt action so we don't need these functions
