
if (SERVER) then

	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if (CLIENT) then


	SWEP.PrintName			= "AI AWM (AWP)"	
	SWEP.Author				= "cheesylard"
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
		
	SWEP.Description		=    "Accuracy International Arctic Warfare Magnum "
							  .. "sniper rifle (Yeah, I didn't put that in the "
							  .. "name, because it's a really long)"
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "r"
	SWEP.NameOfSWEP			= "rcs_awp" --always make this the name of the folder the SWEP is in. 

	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))


end
	SWEP.HoldType			= "crossbow"
SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base"

SWEP.Spawnable				= false
SWEP.AdminSpawnable			= false

SWEP.ViewModel				= "models/weapons/v_snip_awp.mdl"
SWEP.WorldModel				= "models/weapons/w_snip_awp.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("Weapon_AWP.Single")
SWEP.Primary.Recoil			= 0.25
SWEP.Primary.Damage			= 121
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.09 --regular ol' spread
SWEP.Primary.ClipSize		= 10 --ammo in clip
SWEP.Primary.Delay			= 1.3 --durr
SWEP.Primary.DefaultClip	= 30 --extra rounds, this doesn't really help much but whatever
SWEP.Primary.Automatic		= true --duhhh
SWEP.Primary.Ammo			= "smg1" --keep as is, doesn't really effect the swep that much unless if in a gamemode then you make custom ammo

SWEP.IncreasesSpread		= false --does it increase spread the longer you hold down the trigger?
SWEP.Primary.MaxSpread		= 0.3 --the maximum amount the spread can go by, best left at 0.20 or lower
//SWEP.Primary.Handle
//SWEP.Primary.HandleCut		--these aren't needed because SWEP.SpreadIncrease is set to false
//SWEP.Primary.SpreadIncrease

SWEP.MoveSpread				= 5 --multiplier for spread when you are moving
SWEP.JumpSpread				= 10 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.5 --multiplier for spread when you are crouching

SWEP.Zoom					= 0 --pretty self explanitory, don't change this unless if you want the gun to be fucked up
SWEP.ZoomOutDelay			= 0.2 -- this is used for the delay between when you shoot and when it zooms out to pull the bolt
SWEP.ZoomInDelay			= 1.5 --always set this 0.2 higher than SWEP.Primary.Delay
SWEP.Zoom1					= 30 --Field of view for the first zoom
SWEP.Zoom2					= 10 --field of view for the second zoom

SWEP.Zoom0Cone				= 0.09 --spread for when not zoomed
SWEP.Zoom1Cone				= 0.005 --spread for when zoomed once
SWEP.Zoom2Cone				= 0.001 --spread for when zoomed twice
SWEP.EjectDelay				= 0.53

SWEP.Secondary.ClipSize		= -1 --dont need cuz it just zooms you in
SWEP.Secondary.DefaultClip	= -1 --dont need cuz it just zooms you in
SWEP.Secondary.Automatic	= true --dont need cuz it just zooms you in
SWEP.Secondary.Ammo			= "none" --dont need cuz it just zooms you in

SWEP.IronSightsPos = Vector (5.5739, 0, 2.0518)
SWEP.IronSightsAng = Vector (0, 0, 0)

if CLIENT then
	/* OLD CONCOMMAND FOR SCOPETYPE
	local normalscope = true
	local function setscope(pl, cmd, a)
		if tonumber(a[1]) == 1 then
			normalscope = true
		elseif tonumber(a[1]) == 0 then
			normalscope = false
		else
			Msg("0 = RCS Scope, 1 = Counter-Strike Scope\n")
		end
	end
	concommand.Add("rcs_scopetype", setscope)
	*/
	
	function SWEP:DrawHUD()
		local st = self.Owner:GetInfo("rcs_scopetype")
		if !st then
			CreateClientConVar("rcs_scopetype", "1", true, false)
		end
		local zoomed_in = self.Weapon:GetNetworkedInt("Zoom")
		if zoomed_in != 0 then
			
			local x = ScrW()
			local y = ScrH()
			local w = x/2
			local h = y/2
			
			render.UpdateRefractTexture()
			if x > y*4/3 then
				local e2s = (x - (y*4/3))/2 --algebra to find the center of the screen and shit blah blah i dont wanna bore you (for widescreen monitors (e2s means edge to side of scope)
				if st == "0" then
					surface.SetTexture(surface.GetTextureID("gmod/scope-refract")) --the material for that wicked cool water edge!
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRect(e2s, 0, x-(e2s*2), y)  --gets your screen resolution minus the extra edges
				elseif st != "1" then	
					Msg("0 = Watery, 1 = Normal\nSetting back to default (1)\n")
					RunConsoleCommand("rcs_scopetype","1")
				end
			
				surface.SetTexture(surface.GetTextureID("gmod/scope"))  --regular sCOPE overlay
				surface.SetDrawColor(0, 0, 0, 255)
				surface.DrawTexturedRect(e2s, 0, x-(e2s*2), y)  --gets your screen resolution minus the extra edges
				
				surface.SetDrawColor(0, 0, 0, 255)
				surface.DrawRect(0, 0, e2s, y)
				
				surface.SetDrawColor(0, 0, 0, 255)
				surface.DrawRect(x-e2s, 0, e2s, y)
			else
				if st == "0" then
					surface.SetTexture(surface.GetTextureID("gmod/scope-refract")) --the material for that wicked cool water edge!
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRect(0, 0, x, y)  --gets your screen resolution
				elseif st != "1" then	
					Msg("0 = Watery, 1 = Normal\nSetting back to default (1)\n")
					RunConsoleCommand("rcs_scopetype","1")
				end
			
				surface.SetTexture(surface.GetTextureID("gmod/scope"))  --regular sCOPE overlay
				surface.SetDrawColor(0, 0, 0, 255)
				surface.DrawTexturedRect(0, 0, x, y) --gets your screen resolution
			end
			--draw the little lines in the middle
			surface.SetDrawColor(0, 0, 0, 255) --black!!
			surface.DrawLine(w - x, h, w, h)
			surface.DrawLine(w + x, h, w, h)
			surface.DrawLine(w, h - x, w, h)
			surface.DrawLine(w, h + x, w, h)
			

		end
			
	end

end
function SWEP:RCSAttack1()

	if self.Weapon:GetOwner():GetFOV() == 0 then
		self.Zoom = 0
		self.Weapon:SetNetworkedInt("Zoom", 0)
	end
	if self.Weapon:GetNetworkedInt("Zoom") != 0 then --only does this if its not zoomed
		self.canzoom = false
		self.DidntSwitch = true
		timer.Simple(self.ZoomOutDelay, function()
			if self.unavailable then return end
			self:ZoomOut()
		end)
		timer.Simple(self.ZoomInDelay, function()
			if self.unavailable then return end
			self:ZoomBackIn()
		end)
	else
		self.DidntSwitch = false
		self.canzoom = true

	end
	

	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
end





function SWEP:ZoomBackIn()
	if self:Clip1() <= 0 then return end
	if (self.DidntSwitch == false) then 
	
		self.DidntSwitch = true
		self.canzoom = true
		self.Zoomt = 0
	return --this makes it so it ONLY does this bit of function instead of everything else too
	end --just in case if you switched then it doesnt zoom in with the gun you switched to
	
	if self.Zoomt == 1 then --makes you zoom back into the first scopelevel
		self.Weapon:GetOwner():SetFOV(self.Zoom1, 0.2)
		self.Primary.Cone = self.Zoom1Cone
		self.Zoomt = 0
		self.Zoom = 1
		self.Weapon:SetNetworkedInt("Zoom", 1)
		self.canzoom = true --now you can zoom in
		self:ALWAYSINZOOM(self.Zoom1/45)
	else
		self.Weapon:GetOwner():SetFOV(self.Zoom2, 0.2)
		self.Zoom = 2
		self.Weapon:SetNetworkedInt("Zoom", 2)
		self.Zoomt = 0
		self.Primary.Cone = self.Zoom2Cone
		self.canzoom = true
		self:ALWAYSINZOOM(self.Zoom2/45)

	end

	self.DidntSwitch = true
	self.canzoom = true
	
	self.Reloadaftershoot = CurTime() + 0.25
	
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)

end

function SWEP:ZoomOut() --zooming out after pulling the bolt

	self.Weapon:GetOwner():SetFOV(0, 0.2)
	self.Primary.Cone = self.Zoom0Cone
	self.scoped = 0
	if (self.Reloadaftershoot < 0.2) then
		self.Reloadaftershoot = CurTime() + 0.2
	end
	self.Zoomt = self.Weapon:GetNetworkedInt("Zoom")
	self.Zoom = 0
	self:ALWAYSINZOOM(1)
end
SWEP.Reloadaftersilence = 0
SWEP.ShootafterTakeout = 0

/*function SWEP:RCSIronsights()
	if (self.Reloadaftershoot > CurTime()) then return end
	if (self.canzoom != true) then return end
	if (self.Reloadaftersilence > CurTime()) then return end
	if (self.ShootafterTakeout > CurTime()) then return end
	if self.Weapon:GetNetworkedInt("Zoom") == 1 then return end
	if self.Weapon:GetNetworkedInt("Zoom") == 2 then return end
	if (!self.IronSightsPos) then return end
	if (self.NextSecondaryAttack > CurTime()) then return end
	//RealCS (including all this new spread and stuff, which is in v6/v7) is by ch/ee/sy/lar/d.
	bIronsights = !self.Weapon:GetNetworkedBool("Ironsights", false)
	self:SetIronsights(bIronsights)
	self.NextSecondaryAttack = CurTime() + 0.3
end*/
function SWEP:RCSAttack2()
		if self.Weapon:GetNetworkedInt("Zoom") == 1 then
			self.Weapon:GetOwner():SetFOV(self.Zoom2, 0.2)
			self.Zoom = 2
			self.scoped = 255
			self.Primary.Cone = self.Zoom2Cone
			self.Weapon:SetNextSecondaryFire(CurTime() + 0.35)
			self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)
			self.Reloadaftershoot = CurTime() + 0.2
			self:ALWAYSINZOOM(self.Zoom2/45)
		elseif self.Weapon:GetNetworkedInt("Zoom") == 2 then
			self.Zoom = 0
			self.Weapon:GetOwner():SetFOV(0, 0.2)
			self.Primary.Cone = self.Zoom0Cone
			self.Weapon:SetNextSecondaryFire(CurTime() + 0.35)
			self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)
			self.Reloadaftershoot = CurTime() + 0.2
			self:ALWAYSINZOOM(1)
		else
			self.Weapon:GetOwner():SetFOV(self.Zoom1, 0.2)
			self.Zoom = 1
			self.scoped = 255
			self.Primary.Cone = self.Zoom1Cone
			self.Weapon:SetNextSecondaryFire(CurTime() + 0.35)
			self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)
			self.Reloadaftershoot = CurTime() + 0.2
			self:ALWAYSINZOOM(self.Zoom1/45)
		end
	return false
end

--some weird thing with the awp
function SWEP:ReloadCheck()

	self.Zoom = 0
	self.Weapon:GetOwner():SetFOV(0, 0.2)
	self.Primary.Cone = self.Zoom0Cone * 1
	self.canzoom = true
	self.scoped = 0
	self.Zoomt = 0
	self.Weapon:SetNetworkedInt("Zoom", self.Zoom)
	self:SetIronsights(false)


end
function SWEP:RCSReload()
	if self.Weapon:Clip1() < self.Primary.ClipSize then
		self.Zoom = 0
		if CLIENT then self.Weapon:GetOwner():SetFOV(0, 0.1) end
		self.Primary.Cone = self.Zoom0Cone * 1
		self.canzoom = true
		self.scoped = 0
		self.Zoomt = 0
		self:ALWAYSINZOOM(1)
		if self.Zoom then
			timer.Simple(0.05, function() self:ReloadCheck() end)
			timer.Simple(0.1, function() self:ReloadCheck() end)
			timer.Simple(0.2, function() self:ReloadCheck() end)
		end
	end
	
end

function SWEP:RCSDeploy()
	self.unavailable = false
	self.Zoom = 0
	self.Weapon:SetNetworkedInt("Zoom", self.Zoom)
	self.Primary.Cone = self.Zoom0Cone
	self.canzoom = true
	self.scoped = 0
	self.DidntSwitch = false
	self:ALWAYSINZOOM(1, true)
end

function SWEP:RCSHolster()
	self.Zoom = 0
	self.Weapon:SetNetworkedInt("Zoom", self.Zoom)
	self.Primary.Cone = self.Zoom0Cone * 1
	self.canzoom = true
	self.scoped = 0
	self.DidntSwitch = false
	self:ALWAYSINZOOM(1)
end

