--IF YOU WANT TO MODIFY THIS SWEP GO TO RCS_SG552 INSTEAD, UNLESS IF YOU WANT TO EDIT THE FUNCTIONS OR SOMETHING THEN GO AHEAD

if (SERVER) then

	AddCSLuaFile("shared.lua")


end

if (CLIENT) then
	SWEP.PrintName			= "Steyr AUG"	
	SWEP.Author				= "cheesylard"
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
	SWEP.NameOfSWEP			= "rcs_aug" --always make this the name of the folder the SWEP is in.
	
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "e"
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base"
	SWEP.HoldType			= "ar2"
SWEP.Spawnable				= false
SWEP.AdminSpawnable			= false

SWEP.ViewModel				= "models/weapons/v_rif_aug.mdl"
SWEP.WorldModel				= "models/weapons/w_rif_aug.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("Weapon_Aug.Single")
SWEP.Primary.Recoil			= 0.4
SWEP.Primary.Damage			= 22
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0001 --starting cone, it WILL increase to something higher, so keep it low
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.12
SWEP.Primary.DefaultClip	= 90
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"
SWEP.Zoom					= 0
SWEP.Zoom1					= 40 --FOV for when you are zooming in

SWEP.Zoom0Cone				= 0.03 --cone when not zoomed
SWEP.Zoom0Delay				= 0.12 --cone when not zoomed

SWEP.Zoom1Cone				= 0.01 --cone when zoomed
SWEP.Zoom1Delay				= 0.24 --delay when zoomed

SWEP.MoveSpread				= 5 --multiplier for spread when you are moving
SWEP.JumpSpread				= 8 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.5 --multiplier for spread when you are crouching

SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.6 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.HandleCut		= 15 --the higher the number, the less it spreads, you may need to increase it with SWEP.Primary.Handle,  as it can effect the spread
SWEP.Primary.SpreadIncrease	= 0.4/15 --how much you add to the cone after each shot, you should want a fraction over 15 or so, and just increase the 15 or decrease it until it suits your needs

SWEP.Primary.Zoom1MaxSpread		= 0.1 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Zoom1Handle			= 0.3 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.Zoom1SpreadIncrease	= 0.15/15 --how much you add to the cone after each shot
SWEP.Primary.Zoom1HandleCut		= 15 --the higher the number, the less it spreads, you may need to increase it with SWEP.Primary.Handle,  as it can effect the spread
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = Vector (6.0109, 0, 1.1575)
SWEP.IronSightsAng = Vector (-0.0064, 2.1166, 10.2459)


function SWEP:RCSAttack2()
	if self.Weapon:GetNetworkedInt("Zoom") == 1 then
		self.Zoom = 0
		self.Weapon:SetNetworkedInt("Zoom", 0)
		self.Weapon:GetOwner():SetFOV(0, 0.2)
		self.Primary.Cone = self.Zoom0Cone * 1
		self.Primary.Delay = self.Zoom0Delay * 1	
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.35)
		self:SetIronsights(false)		
		self.MouseSensitivity = 1
	else
		self.Weapon:GetOwner():SetFOV(self.Zoom1, 0.2)
		self.Zoom = 1
		self.Weapon:SetNetworkedInt("Zoom", 1)
		self.Primary.Cone = self.Zoom1Cone * 1
		self.Primary.Delay = self.Zoom1Delay * 1
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.35)
		self:SetIronsights(false)
		self.MouseSensitivity = self.Zoom1/45
	end	
	return false
end

function SWEP:RCSReload()
	if self.Weapon:Clip1() < self.Primary.ClipSize then
		self.Zoom = 0
		self.Weapon:SetNetworkedInt("Zoom", 0)
		self.Weapon:GetOwner():SetFOV(0, 0.2)
		self.Primary.Cone = self.Zoom0Cone * 1
		self.Primary.Delay = self.Zoom0Delay * 1
		self:SetIronsights(false)
		self.MouseSensitivity = 1
	end
end

function SWEP:RCSDeploy()
	self.Weapon:SetNetworkedInt("Zoom", 0)
	self.Zoom = 0
	self.Primary.Cone = self.Zoom0Cone * 1
	self.Primary.Delay = self.Zoom0Delay * 1
	self.MouseSensitivity = 1
end
--monkey



