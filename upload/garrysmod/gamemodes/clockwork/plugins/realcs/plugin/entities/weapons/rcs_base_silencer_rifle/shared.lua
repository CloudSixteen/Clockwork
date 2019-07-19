--RealM4A1
--If you want to edit this so it's a pistol, this is NOT for you. Edit rcs_usp

if (SERVER) then

	AddCSLuaFile("shared.lua")

end
--9270723, 9270713, 6232709
if (CLIENT) then
	SWEP.PrintName			= "Colt M4A1 Carbine"	
	SWEP.Author				= "cheesylard"
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
	
	
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "w"
		
	SWEP.NameOfSWEP			= "rcs_m4a1" --always make this the name of the folder the SWEP is in.
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base"
	SWEP.HoldType			= "ar2"
SWEP.Spawnable				= false
SWEP.AdminSpawnable			= false

SWEP.ViewModel				= "models/weapons/v_rif_m4a1.mdl"
SWEP.WorldModel				= "models/weapons/w_rif_m4a1.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("Weapon_m4a1.Single")
SWEP.Primary.Recoil			= 0.25
SWEP.Primary.Damage			= 22
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.001
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.08
SWEP.Primary.DefaultClip	= 90
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.SilencedDamage			= 18
SWEP.SilencedRecoil			= 0.3
SWEP.SilencedCone			= 0.005
SWEP.SilencedSound			= Sound("Weapon_M4a1.Silenced")
SWEP.SilencedNumShots		= 1
SWEP.IsSilenced				= false
SWEP.SilenceTime			= 2

SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
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


SWEP.IronSightsPos = Vector (5.9727, -2.2375, 1.1719)
SWEP.IronSightsAng = Vector (3.2776, 1.3466, 2.6221)

function SWEP:Silence()
	if  self.Weapon:GetNetworkedBool("Silenced") == false then
		self.IsSilenced = true
		self.Weapon:SetNetworkedBool("Silenced", true)
		self.Weapon:SendWeaponAnim(ACT_VM_ATTACH_SILENCER) 
		self.Primary.Spread = self.SilencedCone * 1
		self.CSMuzzleFlashes	= false
	
	else
		self.IsSilenced = false
		self.Weapon:SetNetworkedBool("Silenced", false)
		self.Weapon:SendWeaponAnim(ACT_VM_DETACH_SILENCER) 
		self.Primary.Spread = self.Primary.Cone * 1
		self.CSMuzzleFlashes	= true
	end
	self:SetIronsights(false)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.SilenceTime)
	self.Weapon:SetNextSecondaryFire(CurTime() + self.SilenceTime)
	self.Reloadaftershoot = CurTime() + self.SilenceTime
	self.Weapon:SetNetworkedInt("deploydelay", CurTime() + self.SilenceTime);
	if self:Clip1() == 0 then timer.Simple(self.SilenceTime, function() self:OtherReload() end) end
end

function SWEP:RCSAttack2()
	if (!self.AlwaysSilenced) then
		self:Silence()
	end;
end

function SWEP:RCSDeploy()
	if (self.AlwaysSilenced) then
		self.Weapon:SetNetworkedBool("Silenced", true)
	end;
	
	if self.Weapon:GetNetworkedBool("Silenced") == true then
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW_SILENCED) 
		self.Primary.Spread = self.SilencedCone * 1
	else
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self.Primary.Spread = self.Primary.Cone * 1
	end
	self.Primary.Automatic = true
end

