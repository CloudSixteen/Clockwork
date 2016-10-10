if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "SMG"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4
	
end;

SWEP.HoldType			= "smg"
SWEP.Base				= "bs_base"
SWEP.Category			= "BackSword 2: HL2"

SWEP.Spawnable			= true;
SWEP.AdminSpawnable		= true;

SWEP.ViewModel			= "models/weapons/c_smg1.mdl"
SWEP.WorldModel			= "models/weapons/w_smg1.mdl"
SWEP.ViewModelFlip		= false;
SWEP.UseHands			= true;
SWEP.ViewModelFOV		= 57

SWEP.Primary.Sound			= Sound( "weapons/smg1/smg1_fire1.wav" )
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 4
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 45
SWEP.Primary.Delay			= 0.07
SWEP.Primary.DefaultClip	= 45
SWEP.Primary.Automatic		= true;
SWEP.Primary.Ammo			= "smg1"
SWEP.Primary.Reload			= Sound( "weapons/smg1/smg1_reload.wav" )
SWEP.ReloadSound			= true;

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = nil;
SWEP.IronSightsAng = nil;

function SWEP:PrimaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay);
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	self.Owner:ViewPunch( Angle( math.Rand(-0.3,-0.3) * self.Primary.Recoil, math.Rand(-0.5,0.5) *self.Primary.Recoil, math.Rand(-0.2,0.2) ) )
	
	if (!self:CanPrimaryAttack()) then return; end; 
		self.Weapon:EmitSound(self.Primary.Sound);
		self:HandleBullets(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
	if (self.Owner:IsNPC()) then return; end;
	
		self.Owner:ViewPunch(
		Angle(math.Rand(-0.2, -0.1) * self.Primary.Recoil, math.Rand(-0.1, 0.1) * self.Primary.Recoil, 0)
	);

	bullet = {} -- We're using this because the cone system simply wasn't cutting it for the HL2 Weapons.
		bullet.Num    = 1
		bullet.Src    = self.Owner:GetShootPos()
		bullet.Dir    = self.Owner:GetAimVector()
		bullet.Spread = Vector(.05,.05,.05)
		bullet.Tracer = 0
		bullet.Force  = 1
		bullet.Damage = 4
			self.Owner:FireBullets( bullet )
			self:TakePrimaryAmmo(1);
	
		if ((game.SinglePlayer() and SERVER) || CLIENT) then
			self.dt.LastFire = CurTime();
	end;
end;

function SWEP:Reload()

		if self.Owner:KeyDown(IN_ATTACK) then return end;
		if( self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self.Weapon:Clip1() >= self.Primary.ClipSize)	then return end;
		if (!self.OnReload or self:OnReload() != true) then
			self.Weapon:DefaultReload(ACT_VM_RELOAD);
			self:SetIronSights(false);
		
		if (self.ReloadSound) then 
			self.Weapon:EmitSound(self.Primary.Reload)
		end;
	end;
end;