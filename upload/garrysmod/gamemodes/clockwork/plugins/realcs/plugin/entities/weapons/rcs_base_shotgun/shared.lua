

if (SERVER) then

	AddCSLuaFile("shared.lua")

end

if (CLIENT) then
	SWEP.PrintName			= "Benelli M3 Super 90"	
	SWEP.Author				= "cheesylard"
	SWEP.SlotPos			= 2
	SWEP.IconLetter			= "k"

	SWEP.NameOfSWEP			= "rcs_m3" --always make this the name of the folder the SWEP is in.
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base"
	SWEP.HoldType			= "crossbow"
SWEP.Spawnable				= false
SWEP.AdminSpawnable			= false

SWEP.IsShotgun				= true
SWEP.ViewModel				= "models/weapons/v_shot_m3super92.mdl"
SWEP.WorldModel				= "models/weapons/w_shot_m3super90.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("Weapon_M3.Single")
SWEP.ReloadSnd = Sound("Weapon_Shotgun.Reload")
SWEP.Primary.Recoil			= 5
SWEP.Primary.Damage			= 20
SWEP.Primary.NumShots		= 8
SWEP.Primary.Cone			= 0.05
SWEP.Primary.ClipSize		= 8
SWEP.Primary.Delay			= 0.95
SWEP.Primary.DefaultClip	= 16
SWEP.Primary.Automatic		= true
SWEP.IncreasesSpread		= false --does not do the spread thing, it's a shotgun
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

SWEP.IronSightsPos = Vector (5.7779, 0, 3.3952)
SWEP.IronSightsAng = Vector (0, 0, 0)

--[[
function SWEP:CanPrimaryAttack()

	if (self.Weapon:Clip1() <= 0) then
	
		if (self.Weapon:GetNetworkedBool("reloading", false)) then return end
	
		-- Start reloading if we can
		if (self.Weapon:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then
			self.Reloading = "yes"
			self.Weapon:SetNetworkedBool("reloading", true)
			self.Weapon:SetVar("reloadtimer", CurTime() + 0.5)
			self.Weapon:SetNextPrimaryFire(CurTime() + 0.49)
			self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
			self:SetIronsights(false)
		end
	
	return false
	end

return true
end
]]
function SWEP:RCSAttack1()
	self.Weapon:SetNetworkedBool("reloading", false)
	self.Reloading = "no"
end

--[[function SWEP:RCSReload()
	if (self.Weapon:GetNetworkedBool("reloading", false)) then return end
	
	--// Start reloading if we can
	if (self.Weapon:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then
		
		self.Weapon:SetNetworkedBool("reloading", true)
		self.Weapon:SetVar("reloadtimer", CurTime() + 0.5)
		self.Reloading = "yes"
		
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.49)
		self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
		self:SetIronsights(false)
		
	end

end]]

function SWEP:RCSHolster()
	self:RCSAttack1()
end

function SWEP:RCSThink()
	if self.Weapon:Clip1() > self.Primary.ClipSize then
		self.Weapon:SetClip1(self.Primary.ClipSize)
	end
--timer.Simple(0.5, function() self:TReloadShotty() end)
	if self.Weapon:GetNetworkedBool("reloading") == true then
	
		if self.Weapon:GetNetworkedInt("reloadtimer") < CurTime() then
			if self.unavailable then return end
			
				
			//r/e/a//l/cs w/a/s m/ad/e b/y/ c h/ee/syl a/r/ /d
			--// Finish filling, final pump
			if ((self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) && self.Weapon:GetNetworkedInt("reloadtimer") < CurTime()) then
			--//if (self.Reloading == "yes") then
				local o = CurTime()+.5
				self.Weapon:SetNextPrimaryFire(o)
				self.Weapon:SetNextPrimaryFire(o)
				self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
				self.Weapon:SetNetworkedBool("reloading", false)
				
				if (self.PlayReloadSounds) then
					if (!self.nextReloadSound or CurTime() >= self.nextReloadSound) then
						self.nextReloadSound = CurTime() + 1
						self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav")
					end
				end
				--//self.Reloading = "no"
			--//end
			else
				if (self.PlayReloadSounds) then
					self.Owner:EmitSound(self.ReloadSnd, math.random(50, 80))
				end
				--// Next cycle
				self.Weapon:SetNetworkedInt("reloadtimer", CurTime() + .5)
				self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
				self.Owner:RemoveAmmo(1, self.Primary.Ammo, false)
				self.Weapon:SetClip1( self.Weapon:Clip1() + 1)
				if (self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then
					self.Weapon:SetNextPrimaryFire(CurTime()+1.5)
					self.Weapon:SetNextSecondaryFire(CurTime()+1.5)
				else
					self.Weapon:SetNextPrimaryFire(CurTime()+.49)
					self.Weapon:SetNextSecondaryFire(CurTime()+.5)
				end
			end
			
		end
	
	end
end
