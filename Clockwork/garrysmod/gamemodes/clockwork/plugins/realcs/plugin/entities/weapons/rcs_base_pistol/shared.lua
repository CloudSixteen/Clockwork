if (SERVER) then

	AddCSLuaFile("shared.lua")


end

if (CLIENT) then
	SWEP.PrintName			= "RealAdminGun"	
	SWEP.Author				= "cheesylard"
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
	SWEP.NameOfSWEP			= "rcs_base_pistol" --always make this the name of the folder the SWEP is in.
	
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "D"
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(0, 230, 215, 255))
end

SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base"
	SWEP.HoldType			= "ar2"
SWEP.Spawnable				= false
SWEP.AdminSpawnable			= false

SWEP.ViewModel				= "models/weapons/v_pist_usp.mdl"
SWEP.WorldModel				= "models/weapons/w_pist_usp.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("Weapon_usp.Single")
SWEP.Primary.Recoil			= 0.00000000001
SWEP.Primary.Damage			= 100000000000
SWEP.Primary.NumShots		= 8
SWEP.Primary.Cone			= 0.1
SWEP.Primary.ClipSize		= 100000
SWEP.Primary.Delay			= 0.12
SWEP.Primary.DefaultClip	= 1000
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"


SWEP.MoveSpread				= 6 --multiplier for spread when you are moving
SWEP.JumpSpread				= 12 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.5 --multiplier for spread when you are crouching

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:RCSAttack1()
	self.Primary.Automatic = false
	self:RCSAttack1Pistol()
end

function SWEP:RCSReload()
	self.Primary.Automatic = true
	self:RCSReloadPistol()
end

function SWEP:RCSDeploy()
	self.Primary.Automatic = true
	self:RCSDeployPistol()
end

function SWEP:RCSAttack1Pistol() end
function SWEP:RCSReloadPistol() end
function SWEP:RCSDeployPistol() end
