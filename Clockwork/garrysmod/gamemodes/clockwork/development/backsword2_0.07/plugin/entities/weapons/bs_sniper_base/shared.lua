if (SERVER) then

	AddCSLuaFile( "shared.lua" );
	AddCSLuaFile("cl_init.lua")

end

if (CLIENT) then

	SWEP.PrintName			= "AWP" -- The name of the weapon.
	SWEP.Author				= "ntkrz" -- The author.
	SWEP.Purpose			= "" -- The purpose of the weapon. (Optional of course.)
	SWEP.Instructions		= "" -- The instructions to use the weapon. (For dummies.)
	SWEP.Contact			= "" -- Where to go to get help. 
	SWEP.CSMuzzleFlashes = true; -- Use Counter-Strike muzzle flashes?

end;

SWEP.Spawnable = false;
SWEP.AdminSpawnable	= false;

--[[ Misc. SWEP Content --]]

SWEP.HoldType			= "ar2"
SWEP.Base				= "bs_base" -- The base we are using for the SWEP, a base always runs off a base unless a base! Confusing, right?
SWEP.Category			= "Backsword 2"
SWEP.ViewModelFOV 		= 70
SWEP.ViewModelFlip 		= false;
SWEP.UseHands 			= true;

SWEP.ViewModel			= "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_awp.mdl"

SWEP.DrawAmmo = true;
SWEP.DrawCrosshair = false;

--[[ These really aren't important. Keep them at false, and the weight at five. --]]

SWEP.Weight			= 5
SWEP.AutoSwitchTo 	= false;
SWEP.AutoSwitchFrom	= false;

--[[ Set the SWEP's primary fire information. --]]

SWEP.Primary.DefaultClip 	= 8; -- How much ammunition are you given when spawning the SWEP. (Make sure you set this to the Clipsize at minimum to not annoy people.)
SWEP.Primary.ClipSize 		= 8;
SWEP.Primary.Automatic 		= false;
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Damage			= 22;
SWEP.Primary.Recoil			= 0.50;
SWEP.Primary.Sound			= Sound("sound")
SWEP.ReloadHolster			= 0.1

SWEP.Primary.Delay 			= 1.3; -- Make sure we keep this at 1.3 so the bolt animation can play!
SWEP.Primary.Ammo 			= "smg1";
SWEP.Primary.Cone 			= 0.0001;

--[[ Basic Scope Options. ]]--

SWEP.UseScope				= true
SWEP.ScopeScale 			= 0.55
SWEP.ScopeZoom				= 6
SWEP.IronsightTime 			= 0.35
SWEP.Scope1					= false -- Regular Scope
SWEP.Scope2					= false -- Red Dot Scope
SWEP.BoltAction				= true -- Is this weapon a bolt action?

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

SWEP.CrouchCone				= 0.001
SWEP.CrouchWalkCone			= 0.009
SWEP.WalkCone				= 0.025
SWEP.AirCone				= 0.1
SWEP.StandCone				= 0.015

	/**************************
		Deploy
	**************************/

function SWEP:Deploy()
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )

	self:SetWeaponHoldType( self.HoldType )
	
	self.Reloadaftershoot = CurTime() + 1
				
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
				if self.Weapon == nil then return end;
				self:SetNWInt("skipthink", false)
			end)
	
		self.Weapon:SetNetworkedBool( "Ironsights", false)
		if CLIENT or SERVER then
		self.Owner:SetFOV(0, 0.35)
		end;
	end;
	
	if not self.Owner:OnGround() then return end;
	if self.Owner:KeyDown(IN_SPEED) then return end;
	if self.Owner:KeyDown(IN_USE) then return end;
	
	if ( self.NextSecondaryAttack > CurTime() ) then return end;
	
	bIronsights = !self.Weapon:GetNetworkedBool( "Ironsights", false )
	
	self:SetIronsights( bIronsights )
	
	self.NextSecondaryAttack = CurTime() + 0.3
end;

	/**************************
		SetScope
	**************************/

function SWEP:SetScope(b, player)
if CLIENT then return end
	
	if self.Weapon:GetNetworkedBool("Scope") then 
	self.Owner:DrawViewModel(false)
	else
	self.Owner:DrawViewModel(true)
	end;
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
	self:SetHoldType(self.HoldType)
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
	
	if ( self.Reloadaftershoot > CurTime() ) then return end;
	
	if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then

		self.Weapon:SetNetworkedBool("Ironsights", false)

		self:SetScope(false, self.Owner)
		
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
	self:SetHoldType(self.HoldType)
end;