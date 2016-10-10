if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end;

if ( CLIENT ) then

	SWEP.PrintName			= "PISTOL"			
	SWEP.Author				= "Zig"
	SWEP.Slot				= 4
	
end;

SWEP.HoldType			= "pistol"
SWEP.Base				= "bs_base"
SWEP.Category			= "BackSword 2: HL2"

SWEP.Spawnable			= true;
SWEP.AdminSpawnable		= true;

SWEP.ViewModel			= "models/weapons/c_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"
SWEP.ViewModelFlip		= false;
SWEP.UseHands			= true;
SWEP.ViewModelFOV		= 57

SWEP.Primary.Sound			= Sound( "weapons/pistol/pistol_fire2.wav" )
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 8
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 18
SWEP.Primary.Delay			= 0.08
SWEP.Primary.DefaultClip	= 18
SWEP.Primary.Automatic		= false;
SWEP.Primary.Ammo			= "pistol"
SWEP.Primary.Reload			= Sound( "weapons/pistol/pistol_reload1.wav" )
SWEP.ReloadSound			= true;

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = nil;
SWEP.IronSightsAng = nil;

SWEP.CrouchCone				= 0.03
SWEP.CrouchWalkCone			= 0.03
SWEP.WalkCone				= 0.03
SWEP.AirCone				= 0.03
SWEP.StandCone				= 0.03

function SWEP:PrimaryAttack()
			self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay);
			self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
			self.Owner:ViewPunch( Angle( 0.3,math.random(-0.4,0.4),0 ) )
	
		if (!self:CanPrimaryAttack()) then return; end; 
			self.Weapon:EmitSound(self.Primary.Sound);
			self:HandleBullets(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone);
			self:TakePrimaryAmmo(1);
		if (self.Owner:IsNPC()) then return; end;
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