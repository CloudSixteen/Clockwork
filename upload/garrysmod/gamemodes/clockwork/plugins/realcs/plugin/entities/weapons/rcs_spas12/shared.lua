

if (SERVER) then

	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5

end

if (CLIENT) then
	SWEP.PrintName			= "SPAS-12"	
	SWEP.Author				= "kuropixel"
	SWEP.SlotPos			= 2
	SWEP.IconLetter			= "k"
	SWEP.ViewModelFlip		= false
	SWEP.ViewModelFOV		= 60
	SWEP.DefaultVFOV		= 60

	SWEP.NameOfSWEP			= "rcs_spas12" --always make this the name of the folder the SWEP is in.
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

	SWEP.HoldType			= "ar2"
SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base_shotgun"
SWEP.PlayReloadSounds = true
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.DefaultVFOV = 60;
SWEP.ViewModelFOV			= 60
SWEP.IsShotgun				= true
SWEP.ViewModel				= "models/weapons/v_shotgun.mdl"
SWEP.WorldModel				= "models/weapons/w_shotgun.mdl"
SWEP.Penetrating = true
SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("Weapon_Shotgun.Single")
SWEP.Primary.Recoil			= 1.2
SWEP.Primary.Damage			= 30
SWEP.Primary.NumShots		= 8
SWEP.Primary.Cone			= 0.05
SWEP.Primary.ClipSize		= 8
SWEP.Primary.Delay			= 0.95
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.MaxReserve		= 24
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "buckshot"
SWEP.EjectDelay				= 0.53

SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.5 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.SpreadIncrease	= 0.21/15 --how much you add to the cone after each shot

SWEP.MoveSpread				= 1 --multiplier for spread when you are moving
SWEP.JumpSpread				= 3 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 1 --multiplier for spread when you are crouching


SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = Vector (-8.94, -11.356, 4.0395);
SWEP.IronSightsAng = Vector (0.4146, -0.0641, 0.1913);

