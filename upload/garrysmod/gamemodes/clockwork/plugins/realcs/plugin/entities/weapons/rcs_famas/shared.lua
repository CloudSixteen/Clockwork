--REAL famas!!
--actually has comments!!!

--lines with two dashes (-) in front of them have no effect on the code at all whatsoever


if (SERVER) then

	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if (CLIENT) then
	SWEP.PrintName			= "Famas"	
	SWEP.Author				= "cheesylard"
	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= true
	SWEP.NameOfSWEP			= "rcs_famas" --always make this the name of the folder the SWEP is in.
	SWEP.Slot				= 0
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "t"
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Category				= "RealCS" --duh
SWEP.Base					= "rcs_base_burst_rifle" --dont mess with this unless if you want to royally screw this gun up
SWEP.Penetrating = true
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
	SWEP.HoldType			= "ar2"
SWEP.ViewModel				= "models/weapons/v_rif_famas.mdl" --duh
SWEP.WorldModel				= "models/weapons/w_rif_famas.mdl" --duh

SWEP.BurstType = "auto"

SWEP.Weight					= 5 --dont change this
SWEP.AutoSwitchTo			= false --no
SWEP.AutoSwitchFrom			= false --no

SWEP.delaytime				= 0.5
SWEP.Primary.Sound			= Sound("Weapon_fAMAS.Single") --shoot sound, NOT THE RELOAD SOUND, JUST THE SHOOT SOUND, in order to change the reload sound you have to hex
SWEP.Primary.Recoil			= 0.25 --pushback on shooting, fucking annoying as hell, leave as is
SWEP.Primary.Damage			= 32 --duh
SWEP.Primary.NumShots		= 1 --durr, set to something higher if you want a shotty or soemthing
SWEP.Primary.Cone			= 0.0004 --spread of bullets, set higher if you want inaccurate, set to 0 if you want it dead center
SWEP.Primary.ClipSize		= 25 --duh
SWEP.Primary.Delay			= 0.12 --delay between shots
SWEP.Primary.DefaultClip	= 0 --extra ammo
SWEP.Primary.MaxReserve		= 75
SWEP.Primary.Automatic		= true --set to false for shotguns and pistols
SWEP.Primary.Ammo			= "smg1" --leave as is
SWEP.PistolBurst			= false

SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.5 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.SpreadIncrease	= 0.21/15 --how much you add to the cone after each shot

SWEP.BurstDamage			= 20 --burst damage, just in case if you want to customize or or soemthing
SWEP.BurstRecoil			= 0.5 --duh
SWEP.BurstCone				= 0.001 --makes it like the real famas
SWEP.BurstSound				= Sound("Weapon_fAMAS.Single") --more customization woot
SWEP.FamasBurst				= false --default starting firemode, set to yep if you want it as default.
SWEP.BurstDelay				= 0.6 --delay between bursts, like time between each 3 shots

SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.5 --the higher the number, the longer you have to wait in order for the spread to go back to normal
SWEP.Primary.SpreadIncrease	= 0.21/15 --how much you add to the cone after each shot

SWEP.BurstMaxSpread			= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.BurstHandle			= 0 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.BurstSpreadIncrease	= 0 --how much you add to the cone after each shot

SWEP.Secondary.ClipSize		= -1 --dont change
SWEP.Secondary.DefaultClip	= -1 --dont change
SWEP.Secondary.Automatic	= true --dont change
SWEP.Secondary.Ammo			= "none" --dont change

SWEP.MoveSpread				= 3 --multiplier for spread when you are moving
SWEP.JumpSpread				= 6 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.3 --multiplier for spread when you are crouching

SWEP.IronSightsPos = Vector (-4.6856, 0, 1.144)
SWEP.IronSightsAng = Vector (0, 0, -1.2628)