if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "SHOTGUN"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4
	
end;

SWEP.HoldType			= "shotgun"
SWEP.Base				= "bs_shotgun_base"
SWEP.Category			= "BackSword 2: HL2"

SWEP.Spawnable			= true;
SWEP.AdminSpawnable		= true;

SWEP.ViewModel			= "models/weapons/c_shotgun.mdl"
SWEP.WorldModel			= "models/weapons/w_shotgun.mdl"
SWEP.ViewModelFlip		= false;
SWEP.UseHands			= true;
SWEP.ViewModelFOV		= 57

SWEP.Primary.Sound			= Sound( "weapons/shotgun/shotgun_fire7.wav" )
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 5
SWEP.Primary.NumShots		= 6
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 6
SWEP.Primary.Delay			= 1.1
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.Automatic		= false;
SWEP.Primary.Ammo			= "buckshot"
SWEP.Primary.Reload			= Sound( "weapons/shotgun/shotgun_reload1.wav" )
SWEP.ReloadSound			= true;

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = nil;
SWEP.IronSightsAng = nil;

	/**************************
		Initialize/cache
	**************************/

function SWEP:Initialize()
util.PrecacheSound(self.Primary.Sound) 
        self:SetWeaponHoldType( self.HoldType )
end 

	/**************************
		Primary Attack
	**************************/

function SWEP:PrimaryAttack()
 
if ( !self:CanPrimaryAttack() ) then return end

	self.Weapon:EmitSound(self.Primary.Sound);
	self:HandleBullets(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone);
	self:TakePrimaryAmmo(1);
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	timer.Simple( 0.5, function() self.Weapon:SendWeaponAnim(ACT_SHOTGUN_PUMP) end )
	timer.Simple( 0.5, function() self.Weapon:EmitSound("weapons/shotgun/shotgun_cock.wav") end )
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)
	self.Owner:ViewPunch( Angle( -1,math.random(-1,1),0 ) )

	bullet = {}
		bullet.Num    = 6
		bullet.Src    = self.Owner:GetShootPos()
		bullet.Dir    = self.Owner:GetAimVector()
		bullet.Spread = Vector(.06,.06,.06)
		bullet.Tracer = 1
		bullet.Force  = 1
		bullet.Damage = 5
	self.Owner:FireBullets( bullet )
	
	self:ShootEffects()
 
	self:EmitSound(Sound(self.Primary.Sound)) 
 
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay ) 
end

	/**************************
		Secondary Attack
	**************************/

function SWEP:SecondaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end

	self.Weapon:EmitSound(self.Primary.Sound);
	self:HandleBullets(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone);
	self:TakePrimaryAmmo(2);
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	timer.Simple( 0.5, function() self.Weapon:SendWeaponAnim(ACT_SHOTGUN_PUMP) end )
	timer.Simple( 0.5, function() self.Weapon:EmitSound("weapons/shotgun/shotgun_cock.wav") end )
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)
	self.Owner:ViewPunch( Angle( -1,math.random(-1,1),0 ) )
	self.Weapon:EmitSound("weapons/shotgun/shotgun_dbl_fire7.wav")
	
	bullet = {} -- We're using this because the cone system simply wasn't cutting it, and we also needed a way to alternate the number of shots fired for the secondary fire!
		bullet.Num    = 12
		bullet.Src    = self.Owner:GetShootPos()
		bullet.Dir    = self.Owner:GetAimVector()
		bullet.Spread = Vector(.09,.09,.09)
		bullet.Tracer = 1
		bullet.Force  = 2
		bullet.Damage = 10
	self.Owner:FireBullets( bullet )
	
	self:ShootEffects()
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay ) 
end

	/**************************
		Deploy
	**************************/

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )

	return true
end 

	/**************************
		Regular Reload
	**************************/

function SWEP:Reload()
	//if ( CLIENT ) then return end
	
	// Already reloading
	if ( self.Weapon:GetNetworkedBool( "reloading", false ) ) then return end
	
	// Start reloading if we can
	if ( self.Weapon:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
		
		self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)

		if (game.SinglePlayer() ) then
		timer.Simple( 0.5, function()
		self.Weapon:SetNetworkedBool( "reloading", true )
		self.Weapon:SetVar( "reloadtimer", CurTime())
		end)
		else
		self.Weapon:SetNetworkedBool( "reloading", true )
		end
		
	end
end

	/**************************
		Shotgun Reload
	**************************/

	function SWEP:ShotgunReload()
		
		if self.Owner:KeyPressed(IN_ATTACK) then 
			self.Weapon:SetNetworkedBool( "reloading", false )
		end
	
	if ( self.Weapon:GetNetworkedBool( "reloading", false ) ) then
	
		if ( self.Weapon:GetVar( "reloadtimer", 0 ) < CurTime()) then
			
			//  reload 
			if ( self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then
				self.Weapon:SetNetworkedBool( "reloading", false )
				return
			end
			
			// Next cycle
			self.Weapon:SetVar( "reloadtimer", CurTime() + 0.5 ) 
			self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
			self.Weapon:EmitSound("weapons/shotgun/shotgun_reload1.wav")
                local AnimationTime = self.Owner:GetViewModel():SequenceDuration()
                self.ReloadingTime = CurTime() + AnimationTime
                self:SetNextPrimaryFire(CurTime() + AnimationTime)
                self:SetNextSecondaryFire(CurTime() + AnimationTime)
			
			// Add ammo
			self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
			self.Weapon:SetClip1(  self.Weapon:Clip1() + 1 )
			
			// Finish filling, final pump. Current Clip is = to ClipSize or No more ammo in the reserve
			if ( self.Weapon:Clip1() == self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0) then
				self.Weapon:SetNetworkedBool( "reloading", false )
				timer.Simple( 0.4, function() 
				if self.Weapon == nil then return end
				self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
			end )
			
		end
	end
end
end

	/**************************
		Think!
	**************************/

function SWEP:Think()
		self:ShotgunReload()

	if ( self.Weapon:GetNetworkedBool( "reloading", true ) ) then
	
		if ( self.Weapon:GetVar( "reloadtimer", 0 ) < CurTime() ) then
			
			// Finished reload -
			if ( self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then
				self.Weapon:SetNetworkedBool( "reloading", false )
				return
			end
			
			// Next cycle
			self.Weapon:SetVar( "reloadtimer", CurTime() + 0.4 ) 
			self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
                local AnimationTime = self.Owner:GetViewModel():SequenceDuration()
                self.ReloadingTime = CurTime() + AnimationTime
                self:SetNextPrimaryFire(CurTime() + AnimationTime)
                self:SetNextSecondaryFire(CurTime() + AnimationTime)

			// Add ammo
			self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
			self.Weapon:SetClip1(  self.Weapon:Clip1() + 1 )
			local AnimationTime = self.Owner:GetViewModel():SequenceDuration()
            self.ReloadingTime = CurTime() + AnimationTime
            self:SetNextPrimaryFire(CurTime() + AnimationTime)
            self:SetNextSecondaryFire(CurTime() + AnimationTime)
			
			// Finish filling, final pump
			if ( self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then
			vm:SendViewModelMatchingSequence( vm:LookupSequence( "reload_end" ) )
			else
			
			end
			
		end
	
	end
	
end