if (SERVER) then

	AddCSLuaFile( "shared.lua" );
	AddCSLuaFile("cl_init.lua")

end

if (CLIENT) then

--[[
These comments are strictly for overviewing the base and understanding what each line does if they aren't sorta self-explanitory.
The reason for this is simply because if people want to start wanting to know what each line does and make their own they have a valid source.
It's suggested you don't put them in your shared files, but if that's how you roll, it's how you roll.
]]--

--[[ Basic SWEP Information to display to the client. ]]--

	SWEP.PrintName			= "AWP" -- The name of the weapon.
	SWEP.Author				= "Zig" -- The author.
	SWEP.Purpose			= "" -- The purpose of the weapon. (Optional of course.)
	SWEP.Instructions		= "" -- The instructions to use the weapon. (For dummies.)
	SWEP.Contact			= "" -- Where to go to get help. 
	SWEP.CSMuzzleFlashes = true; -- Use Counter-Strike muzzle flashes?

end;


--[[ Set whether the SWEP is spawnable (by users or by admins). Make sure to only pick one as true. --]]

SWEP.Spawnable = false; -- Is our weapon spawnable through the q-menu for normal players?
SWEP.AdminSpawnable	= false; -- Is our weapon only spawnable to admins?

--[[ Misc. SWEP Content --]]

SWEP.HoldType			= "smg" -- How you hold the SWEP in third person. (There are a whole bunch of holdtypes.)
SWEP.Base				= "bs_base" -- The base we are using for the SWEP, a base always runs off a base unless a base! Confusing, right?
SWEP.Category			= "Backsword" -- The category the weapon is listed under in the q-menu. This is pointless if you have the spawnables set to false.
SWEP.ViewModelFOV 		= 70 -- The FOV the viewmodel is set at.
SWEP.ViewModelFlip 		= false; -- Some view models are incorrectly flipped.
SWEP.UseHands 			= true; -- Do we want to use c_hands if they're available?

SWEP.ViewModel			= "models/weapons/cstrike/c_snip_awp.mdl" -- The view model of the SWEP.
SWEP.WorldModel			= "models/weapons/w_snip_awp.mdl" -- The world model of the SWEP.

SWEP.DrawAmmo = true; -- Draw our own ammo display?
SWEP.DrawCrosshair = false; -- Draw the crosshair, or draw our own?

--[[ These really aren't important. Keep them at false, and the weight at five. --]]

SWEP.Weight	= 5 -- How heavy is the gun, (Player speeds etc.)
SWEP.AutoSwitchTo = false; -- Is it autoswitched when picked up?
SWEP.AutoSwitchFrom	= false; -- Is it autoswitched when picked up?

--[[ Set the SWEP's primary fire information. --]]

SWEP.Primary.DefaultClip = 8; -- How much ammunition are you given when spawning the SWEP. (Make sure you set this to the Clipsize at minimum to not annoy people.)
SWEP.Primary.ClipSize = 8; -- How much ammo is in one magazine?
SWEP.Primary.Automatic = false; -- Is the SWEP automatic?
SWEP.Primary.NumShots = 1; -- How many bullets do you fire in one shot?
SWEP.Primary.Damage	= 22; -- How much damage does the SWEP do?
SWEP.Primary.Recoil	= 0.50; -- How large is the recoil?
SWEP.Primary.Sound	= Sound("sound") -- What's the firing sound of the SWEP?
SWEP.ReloadHolster	= 0.1 -- Irrelevant, keep at 0.1.

SWEP.Primary.Delay = 1.3; -- Make sure we keep this at 1.3 so the bolt animation can play! (If it's a bolt action rifle, of course. This also varies on models, however this is for CS:S.)
SWEP.Primary.Ammo = "smg1"; -- What's the primary ammunition type for the SWEP?
SWEP.Primary.Cone = 0.0001; -- What's the accuracy cone?

--[[ Basic Scope Options. ]]--

SWEP.UseScope				= true -- Use a scope instead of iron sights.
SWEP.ScopeScale 			= 0.55 -- The scale of the scope's reticle in relation to the player's screen size.
SWEP.ScopeZoom				= 6 -- How much is the zoom on the scope?
SWEP.IronsightTime 			= 0.35 -- How long does it take to zoom in?

--Only Select one... Only one.

SWEP.Scope1			= false
SWEP.BoltAction		= true -- Is this weapon a bolt action?

--[[ Set the SWEP's secondary fire information. --]]

SWEP.Secondary.ClipSize		= 1 -- Secondary Fire is useless, leave these be, they do nothing!
SWEP.Secondary.DefaultClip	= 100
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "smg2"

--[[ Define the bullet information for later use. --]]

SWEP.BulletTracerFreq = 1; -- Show a tracer every x bullets.
SWEP.BulletTracerName = nil -- Use a custom effect for the tracer.
SWEP.BulletForce = 5; -- How much force does a bullet give to a prop!

--[[ Set up the accuracy for the weapon. --]]

SWEP.CrouchCone				= 0.001 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.009 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.025 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 	-- Accuracy when we're in air
SWEP.StandCone				= 0.015 -- Accuracy when we're standing still

--[[ Below is a lot of stuff you probably shouldn't touch in order to not mess up the base. It's suggested that you really keep a lot of it alone.
Thanks xoxoxo, Zig.
]]--

	/**************************
		Deploy
	**************************/
function SWEP:Deploy()

	if self.Weapon:GetNetworkedBool("Silenced") == true then
			self.Weapon:SendWeaponAnim( ACT_VM_DRAW_SILENCED );
		else
			self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	end;
	
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self:SetScope(false, self.Owner)
	self.Reloadaftershoot = CurTime() + 1
	
	if timer.Exists("ReloadTimer") then
		timer.Destroy("ReloadTimer")
	end
	//Destroy the faggot timer on deploy if its running.

	self:SetNWInt("skipthink", false)
		
	return true
end;


	/**************************
		SecondaryAttack
	**************************/

function SWEP:SecondaryAttack()

	if self.Owner:KeyDown(IN_USE) then
	
		self:SetNWInt("skipthink", true)
		timer.Simple(self.SilenceHolster, 
			function() 
				if self.Weapon == nil then return end
				self:SetNWInt("skipthink", false)
			end)
			//Skip the entire Think Function
	
		self.Weapon:SetNetworkedBool( "Ironsights", false)
		//Set the ironsight to false
		if CLIENT or SERVER then
		self.Owner:SetFOV(0, 0.35)
		end
		self:Silence()
	end;
	
	if not self.Owner:OnGround() then return end
	if self.Owner:KeyDown(IN_SPEED) then return end
	if self.Owner:KeyDown(IN_USE) then return end
	
	if ( self.NextSecondaryAttack > CurTime() ) then return end
	
	bIronsights = !self.Weapon:GetNetworkedBool( "Ironsights", false )
	
	self:SetIronsights( bIronsights )
	
	self.IronSightsPos	= self.AimSightsPos
	self.IronSightsAng	= self.AimSightsAng
	
	self.NextSecondaryAttack = CurTime() + 0.3
end;

	/**************************
		SetScope
	**************************/

function SWEP:SetScope(b, player)
if CLIENT then return end

	local PlaySound = b ~= self.Weapon:GetNetworkedBool("Scope", not b)
	self.CurScopeZoom = 1
	

	if self.Weapon:GetNetworkedBool("Scope") then 
	self.Owner:DrawViewModel(false)
	else
	self.Owner:DrawViewModel(true)
	end
	self.Weapon:SetNetworkedBool("Scope", b) 
end;

	/**************************
		Reload
	**************************/

function SWEP:Reload()

	if self.Owner:KeyDown(IN_ATTACK) then return end

	if( self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self.Weapon:Clip1() >= self.Primary.ClipSize)	then return end

	if (!self.OnReload or self:OnReload() != true) then
	self.Weapon:DefaultReload(ACT_VM_RELOAD);
	self:SetIronSights(false);
		
	if (self.ReloadSound) then 
	self.Weapon:EmitSound(self.Primary.Reload)
		end;
	end;

	timer.Simple(self.ReloadHolster + .2,
		function() 
		if self.Weapon == nil then return end
		self:SetNWInt("skipthink", false)
	end)
	
	if ( self.Reloadaftershoot > CurTime() ) then return end 
	
	if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then

		self.Weapon:SetNetworkedBool("Ironsights", false)

		self:SetScope(false, self.Owner)
		
		self:SetWeaponHoldType( self.HoldType )
		
		if CLIENT or SERVER then
		self.Owner:SetFOV( 0, 0.15 )
		end;

		self.MouseSensitivity = 1
		
				if (game.SinglePlayer()) then
			self:SetNWInt("skipthink", true)
				timer.Create("ReloadTimer", self.ReloadHolster + .2, 1,
				function()
					if self.Weapon == nil then return end
				self:SetNWInt("skipthink", false)
			end)
		end;
		
		if timer.Exists("BoltTimer") then
			timer.Destroy("BoltTimer")
		end;
	
		if not CLIENT then
			self.Owner:DrawViewModel(true)
		end;
	end;
	return true
end;

	/**************************
		Primary Fire
	**************************/

function SWEP:PrimaryAttack()

	if (self.BoltAction) then
	self:SetIronsights(false)
		if (game.SinglePlayer()) then
			self:SetNWInt("skipthink", true)
				timer.Create("BoltTimer", self.Primary.Delay, 1,
				function()
					if self.Weapon == nil then return end
				self:SetNWInt("skipthink", false)
			end)
			
	else
			self:SetNWInt("skipthink", true)
				timer.Simple(self.Primary.Delay,
				function()
					if self.Weapon == nil then return end
				self:SetNWInt("skipthink", false)
			end)
	end;
end;
	if ( self.Owner:IsNPC() ) then return end
	
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.2) * 0.5, math.Rand(-0.1,0.1) * 0.5, 0 ) )

	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end;

	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay);
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	
	if (!self:CanPrimaryAttack()) then return; end;
	
	self.Weapon:EmitSound(self.Primary.Sound);
	
	self:HandleBullets(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone);
	self:TakePrimaryAmmo(1);	

	if (self.Owner:IsNPC()) then return; end;
	
	self.Owner:ViewPunch(
		Angle(math.Rand(-0.2, -0.1) * self.Primary.Recoil, math.Rand(-0.1, 0.1) * self.Primary.Recoil, 0)
	);
	
	if ((game.SinglePlayer() and SERVER) || CLIENT) then
		self.dt.LastFire = CurTime();
	end;
	
end;

	/**************************
		Sensability
	**************************/

local LastViewAng = false

local function SimilarizeAngles (ang1, ang2)

	ang1.y = math.fmod (ang1.y, 360)
	ang2.y = math.fmod (ang2.y, 360)

	if math.abs (ang1.y - ang2.y) > 180 then
		if ang1.y - ang2.y < 0 then
			ang1.y = ang1.y + 360
		else
			ang1.y = ang1.y - 360
		end;
	end;
end;

local function ReduceScopeSensitivity (uCmd)

	if LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon():IsValid() then
		local newAng = uCmd:GetViewAngles()
			if LastViewAng then
				SimilarizeAngles (LastViewAng, newAng)

				local diff = newAng - LastViewAng

				diff = diff * (LocalPlayer():GetActiveWeapon().MouseSensitivity or 1)
				uCmd:SetViewAngles (LastViewAng + diff)
			end;
	end;
	LastViewAng = uCmd:GetViewAngles()
end;
 
hook.Add ("CreateMove", "RSS", ReduceScopeSensitivity)


	/**************************
		SetIronsights
	**************************/

function SWEP:SetIronsights( b ) -- Thanks Fonix & Worshipper for lots of this nutty shit.

	self.Weapon:SetNetworkedBool( "Ironsights", b )
	if self.Owner:KeyDown(IN_USE) then return end
	if self.Weapon:GetNetworkedBool( "Ironsights", true ) then
	if CLIENT or SERVER then
	self.Owner:SetFOV(65, 0.2)
	timer.Simple(0.21, function()
	self.Weapon:SetNetworkedBool("Scope", true)
	self.Owner:SetFOV(80/self.ScopeZoom, 0)
	self.Weapon:GetNetworkedBool( "Ironsights", false )
	end)
	end;
	self.Weapon:EmitSound("")
	else
	if CLIENT or SERVER then
	self.Owner:SetFOV(0, 0.2)
	self.Weapon:SetNetworkedBool("Scope", false) 
	end;
	
		if !self.Owner:KeyDown(IN_ATTACK) then
			self.Weapon:EmitSound("")
		end;
	end;
	
end;

	/**************************
		Think
	**************************/

function SWEP:Think()

	if CLIENT and self.Weapon:GetNetworkedBool("Scope") then
		self.MouseSensitivity = self.Owner:GetFOV() / 80
	else
		self.MouseSensitivity = 1
	end;
	

	if not CLIENT and self.Weapon:GetNetworkedBool("Scope") and self.Owner:KeyDown(IN_ATTACK2) then

		self.Owner:DrawViewModel(true)
	elseif not CLIENT then

		self.Owner:DrawViewModel(true)
	end;

	self:SpreadSystem()
	
	end;

	/**************************
		ResetVars
	**************************/

function SWEP:ResetVars()

	self.NextSecondaryAttack = 0
	
	self.bLastIron = false
	self.Weapon:SetNetworkedBool("Ironsights", false)
	
	if self.UseScope then
		self.CurScopeZoom = 1
		self.fLastScopeZoom = 1
		self.bLastScope = false
		self.Weapon:SetNetworkedBool("Scope", false)
	end;
	
	if self.Owner then
		self.OwnerIsNPC = self.Owner:IsNPC()
	end;
	
end;

function SWEP:Holster(wep) 		self:ResetVars() return true end;
function SWEP:Equip(NewOwner) 	self:ResetVars() return true end;
function SWEP:OnRemove() 		self:ResetVars() return true end;
function SWEP:OnDrop() 			self:ResetVars() return true end;
function SWEP:OwnerChanged() 	self:ResetVars() return true end;
function SWEP:OnRestore() 		self:ResetVars() return true end;

	/**************************
		Initialize
	**************************/

function SWEP:Initialize()

	self:SetWeaponHoldType(self.HoldType)

	if CLIENT then

	local iScreenWidth = surface.ScreenWidth()
	local iScreenHeight = surface.ScreenHeight()

		self.ScopeTable = {}
		self.ScopeTable.l = iScreenHeight*self.ScopeScale
		self.ScopeTable.x1 = 0.5*(iScreenWidth + self.ScopeTable.l)
		self.ScopeTable.y1 = 0.5*(iScreenHeight - self.ScopeTable.l)
		self.ScopeTable.x2 = self.ScopeTable.x1
		self.ScopeTable.y2 = 0.5*(iScreenHeight + self.ScopeTable.l)
		self.ScopeTable.x3 = 0.5*(iScreenWidth - self.ScopeTable.l)
		self.ScopeTable.y3 = self.ScopeTable.y2
		self.ScopeTable.x4 = self.ScopeTable.x3
		self.ScopeTable.y4 = self.ScopeTable.y1
				
		self.ParaScopeTable = {}
		self.ParaScopeTable.x = 0.5*iScreenWidth - self.ScopeTable.l
		self.ParaScopeTable.y = 0.5*iScreenHeight - self.ScopeTable.l
		self.ParaScopeTable.w = 2*self.ScopeTable.l
		self.ParaScopeTable.h = 2*self.ScopeTable.l
		
		self.ScopeTable.l = (iScreenHeight + 1)*self.ScopeScale
		self.QuadTable = {}
		self.QuadTable.x1 = 0
		self.QuadTable.y1 = 0
		self.QuadTable.w1 = iScreenWidth
		self.QuadTable.h1 = 0.5*iScreenHeight - self.ScopeTable.l
		self.QuadTable.x2 = 0
		self.QuadTable.y2 = 0.5*iScreenHeight + self.ScopeTable.l
		self.QuadTable.w2 = self.QuadTable.w1
		self.QuadTable.h2 = self.QuadTable.h1
		self.QuadTable.x3 = 0
		self.QuadTable.y3 = 0
		self.QuadTable.w3 = 0.5*iScreenWidth - self.ScopeTable.l
		self.QuadTable.h3 = iScreenHeight
		self.QuadTable.x4 = 0.5*iScreenWidth + self.ScopeTable.l
		self.QuadTable.y4 = 0
		self.QuadTable.w4 = self.QuadTable.w3
		self.QuadTable.h4 = self.QuadTable.h3

		self.LensTable = {}
		self.LensTable.x = 2.5+self.QuadTable.w3
		self.LensTable.y = 1+self.QuadTable.h1
		self.LensTable.w = 2*self.ScopeTable.l
		self.LensTable.h = 2*self.ScopeTable.l

		self.CrossHairTable = {}
		self.CrossHairTable.x11 = 0
		self.CrossHairTable.y11 = 0.5*iScreenHeight
		self.CrossHairTable.x12 = iScreenWidth
		self.CrossHairTable.y12 = self.CrossHairTable.y11
		self.CrossHairTable.x21 = 0.5*iScreenWidth
		self.CrossHairTable.y21 = 0
		self.CrossHairTable.x22 = 0.5*iScreenWidth
		self.CrossHairTable.y22 = iScreenHeight
		
	end;

	self.ScopeZooms 		= self.ScopeZooms or {5}
	if self.UseScope then
		self.CurScopeZoom	= 1
	end;

	self:ResetVars()
	self.Weapon:SetNetworkedBool("Ironsights", false)
	self.Reloadaftershoot = 0

	//Spread Change
	self:SetNWInt("crouchcone", self.CrouchCone)
	self:SetNWInt("crouchwalkcone", self.CrouchWalkCone)
	self:SetNWInt("walkcone", self.WalkCone)
	self:SetNWInt("aircone", self.AirCone)
	self:SetNWInt("standcone", self.StandCone)
	self:SetNWInt("ironsightscone", self.IronsightsCone)
	//Recoil change
	self:SetNWInt("recoil", self.Recoil)
	self:SetNWInt("recoilzoom", self.RecoilZoom)
	//Delay change
	self:SetNWInt("delay", self.Delay)
	self:SetNWInt("delayzoom", self.DelayZoom)
	//ThinkSkip
	self:SetNWInt("thinkskip", self.ThinkSkip)
	self:SetNWInt("ironsighttoggle", false)
end;
