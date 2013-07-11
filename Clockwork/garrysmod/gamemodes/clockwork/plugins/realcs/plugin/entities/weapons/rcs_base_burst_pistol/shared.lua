--this is NOT a template

if (SERVER) then

	AddCSLuaFile("shared.lua")

end

if (CLIENT) then
	SWEP.PrintName			= "Glock GmbH 9mm"	
	SWEP.Author				= "cheesylard"
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
	SWEP.NameOfSWEP			= "rcs_glock" --always make this the name of the folder the SWEP is in.
	
	SWEP.Slot				= 1
	SWEP.SlotPos			= 2
	SWEP.IconLetter			= "c"
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end
	SWEP.HoldType			= "pistol"
SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base"

SWEP.Spawnable				= false
SWEP.AdminSpawnable			= false

SWEP.ViewModel				= "models/weapons/v_pist_glock18.mdl"
SWEP.WorldModel				= "models/weapons/w_pist_glock18.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.BurstType = "pistol"

SWEP.Primary.Sound			= Sound("Weapon_Glock.Single")
SWEP.Primary.Recoil			= 0.25
SWEP.Primary.Damage			= 20
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0001 --starting cone, it WILL increase to something higher, so keep it low
SWEP.Primary.ClipSize		= 20
SWEP.Primary.Delay			= 0.12
SWEP.Primary.DefaultClip	= 90
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"
SWEP.PistolBurst			= true

SWEP.Primary.MaxSpread		= 0.15 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.5 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.SpreadIncrease	= 0.21/15 --how much you add to the cone after each shot

SWEP.BurstRecoil			= 0.5
SWEP.BurstCone				= 0.01
//SWEP.BurstSound				= Sound("Weapon_AWP.Single")
SWEP.BurstNumShots			= 3
SWEP.IsBurst				= false
SWEP.BurstDelay				= 0.6

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.MoveSpread				= 5 --multiplier for spread when you are moving
SWEP.JumpSpread				= 10 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.5 --multiplier for spread when you are crouching

SWEP.IronSightsPos = Vector (4.3646, 0, 2.9899)
SWEP.IronSightsAng = Vector (0, 0, 0)


--[[
function SWEP:PrimaryAttack()
	local cone, num, dmg, delay, recoil
	if self.Weapon:Clip1() < 3 then
		self.BurstNumShots = self.Weapon:Clip1()
	else
		self.BurstNumShots = 3
	end
	if (!self:CanPrimaryAttack()) then return	end
	cone = self.Primary.Spread
	self.Weapon:EmitSound(self.Primary.Sound)
	self:ConeStuff()
	if (self.IsBurst == true) then --only does this stuff if the gun is Burst
		num = self.BurstNumShots
		dmg = self.Primary.Damage
		delay = self.BurstDelay
		recoil = self.BurstRecoil
	
		timer.Simple(0.03, function() self.Weapon:EmitSound(self.Primary.Sound) end)
		timer.Simple(0.06, function() self.Weapon:EmitSound(self.Primary.Sound) end)

		self.Primary.Automatic = true
	else
		num = self.Primary.NumShots
		dmg = self.Primary.Damage
		delay = self.Primary.Delay
		recoil = self.Primary.Recoil

		self.Primary.Automatic = false
	end
	self.Reloadaftershoot = CurTime() + delay
	self.Weapon:SetNextPrimaryFire(CurTime() + delay)
	self.Weapon:SetNextSecondaryFire(CurTime() + delay)
	self:CSShootBullet(dmg, recoil, num, self.Primary.Spread)
	self:TakePrimaryAmmo(num)
end
]]
function SWEP:BurstLol()
	self.Weapon:EmitSound(self.Primary.Sound)
	self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.BurstCone)
end
function SWEP:RCSAttack1()
	if self.Weapon:GetNetworkedInt("Burst") == 1 then
		if self.Weapon:Clip1() == 1 then
			timer.Simple(0.03, function() self:BurstLol() end)
		elseif self.Weapon:Clip1() >= 2 then
			timer.Simple(0.06, function() self:BurstLol() end)
		end
		if self:Clip1() == 1 then
			self:TakePrimaryAmmo(1)
		else
			self:TakePrimaryAmmo(2)
		end
		self.Primary.Automatic = true
		self.Reloadaftershoot = CurTime() + self.BurstDelay
		self.Weapon:SetNextPrimaryFire(CurTime() + self.BurstDelay)
		self.Weapon:SetNextSecondaryFire(CurTime() + self.BurstDelay)
		if self:Clip1() <= 3 then timer.Simple(self.BurstDelay, function() self:OtherReload() end) end
	else
		self.Primary.Automatic = false
	end
end

function SWEP:RCSAttack2()
	if self.Weapon:GetNetworkedInt("Burst") == 0 then
		self.IsBurst = true
		self.Weapon:SetNetworkedInt("Burst", 1)
		self.Owner:PrintMessage(HUD_PRINTCENTER, "Switched to Burst-Fire mode")
		self.Primary.Automatic = true
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.25)
	else
		self.Weapon:SetNetworkedInt("Burst", 0)
		self.IsBurst = false
		self.Owner:PrintMessage(HUD_PRINTCENTER, "Switched to Semi-Automatic")
		self.Primary.Automatic = false
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.25)
	end
	return false
end

function SWEP:RCSReload()
	self.Primary.Automatic = true
end

SWEP.ShootafterTakeout = 0
function SWEP:RCSDeploy()
	self.Primary.Automatic = true
end
