--RealUSP
--If you want to edit this so it's automatic, this is NOT for you. Edit rcs_m4a1.

if (SERVER) then

	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end
-- self.Primary.Automatic = true
if (CLIENT) then
	SWEP.PrintName			= "USP-T"	
	SWEP.Author				= "cheesylard"
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
	SWEP.Slot				= 1
	SWEP.SlotPos			= 2
	SWEP.IconLetter			= "a"
		
	-- This is the font that's used to draw the death icons
	SWEP.NameOfSWEP			= "rcs_usp" --always make this the name of the folder the SWEP is in.
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

	SWEP.HoldType			= "pistol"
SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base_silencer_pistol"
SWEP.Penetrating = true
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel				= "models/weapons/v_pist_usp.mdl"
SWEP.WorldModel				= "models/weapons/w_pist_usp.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("Weapon_usp.Single")
SWEP.Primary.Recoil			= 0.25
SWEP.Primary.Damage			= 26
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0001
SWEP.Primary.ClipSize		= 12
SWEP.Primary.Delay			= 0.12
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.MaxReserve		= 100
SWEP.Primary.Automatic		= false --it doesnt matter what you set this to, it will always be a pistol no matter what you do
SWEP.Primary.Ammo			= "pistol"

SWEP.SilencedDamage			= 30
SWEP.SilencedRecoil			= 0.00001
SWEP.SilencedCone			= 0.0001
SWEP.SilencedSound			= Sound("Weapon_usp.Silencedshot")
SWEP.SilencedNumShots		= 1
SWEP.IsSilenced				= false
SWEP.SilenceTime			= 3

SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.5 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.SpreadIncrease	= 0.21/15 --how much you add to the cone after each shot
SWEP.SilencedMaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.SilencedHandle			= 0.5 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.SilencedSpreadIncrease	= 0.21/15 --how much you add to the cone after each shot

SWEP.MoveSpread				= 8 --multiplier for spread when you are moving
SWEP.JumpSpread				= 10 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.5 --multiplier for spread when you are crouching

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = Vector(3, 0, 2)
SWEP.IronSightsAng = Vector(2, 0, 5)