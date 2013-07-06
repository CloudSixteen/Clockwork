if (SERVER) then

	AddCSLuaFile("shared.lua")

end

if (CLIENT) then

	SWEP.PrintName			= "G3SG1"	
	SWEP.Author				= "cheesylard"

		
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "i"
	SWEP.NameOfSWEP		= "rcs_g3sg1" --always make this the name of the folder the SWEP is in. 
	killicon.AddFont(SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
	
end



SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base_autosniper"
	SWEP.HoldType			= "ar2"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.ViewModel				= "models/weapons/v_snip_g3sg1.mdl"
SWEP.WorldModel				= "models/weapons/w_snip_g3sg1.mdl"
SWEP.Penetrating = true
SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.MaxSpread		= 0.001 --the maximum amount the spread can go by, best left at 0.20 or lower
SWEP.Primary.Handle			= 0.3 --how many seconds you have to wait between each shot before the spread is at its best
SWEP.Primary.SpreadIncrease	= 0.00001 --how much you add to the cone after each shot

SWEP.LowLightUp = true;
SWEP.LowSmokeEffect = true;
SWEP.Primary.Sound			= Sound("Weapon_M4a1.Silenced")
SWEP.Primary.Recoil			= 0.125
SWEP.Primary.Damage			= 150
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0001 --starting cone, it WILL increase to something higher, so keep it low
SWEP.Primary.ClipSize		= 20
SWEP.Primary.Delay			= 0.25
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.MaxReserve		= 60
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ar2"
SWEP.NoDSPEffects = true;
SWEP.MoveSpread				= 8 --multiplier for spread when you are moving
SWEP.JumpSpread				= 15 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.5 --multiplier for spread when you are crouching
SWEP.EjectDelay				= 0

SWEP.Zoom					= 0 --pretty self explanitory, don't change this unless if you want the gun to be fucked up
//SWEP.ZoomOutDelay			= 0.2 -- this is used for the delay between when you shoot and when it zooms out to pull the bolt
//SWEP.ZoomInDelay			= 1.5 --always set this 0.2 higher than SWEP.Primary.Delay
SWEP.Zoom1					= 30 --Field of view for the first zoom
SWEP.Zoom2					= 10 --field of view for the second zoom

SWEP.Zoom0Cone				= 0.1 --spread for when not zoomed
SWEP.Zoom1Cone				= 0.00001 --spread for when zoomed once
SWEP.Zoom2Cone				= 0.000001 --spread for when zoomed twice

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"
SWEP.IronSightsPos = Vector (5.399, -0.631, 2.0466)
SWEP.IronSightsAng = Vector (0, 0, 0.4758)