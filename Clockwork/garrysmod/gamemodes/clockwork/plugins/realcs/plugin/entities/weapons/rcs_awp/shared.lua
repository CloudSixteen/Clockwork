--IF YOU WANT TO MODIFY THIS SWEP GO TO RCS_SCOUT INSTEAD, UNLESS IF YOU WANT TO EDIT THE FUNCTIONS OR SOMETHING THEN GO AHEAD


if (SERVER) then

	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false


end

if (CLIENT) then


	SWEP.PrintName			= "AWP"	
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

SWEP.Category				= "RealCS"
SWEP.Base					= "rcs_base_bsnip"
SWEP.Penetrating = true
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
	SWEP.HoldType			= "ar2"
SWEP.ViewModel				= "models/weapons/v_snip_awp.mdl"
SWEP.WorldModel				= "models/weapons/w_snip_awp.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("Weapon_AWP.Single")
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 125
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.01 --regular ol' spread
SWEP.Primary.ClipSize		= 10 --ammo in clip
SWEP.Primary.Delay			= 1.3 --durr
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true --duhhh
SWEP.Primary.Ammo			= "ar2" --keep as is, doesn't really effect the swep that much unless if in a gamemode then you make custom ammo
SWEP.Primary.MaxReserve		= 30


SWEP.IncreasesSpread		= false --does it increase spread the longer you hold down the trigger?
SWEP.Primary.MaxSpread		= 0.01 --the maximum amount the spread can go by, best left at 0.20 or lower
//SWEP.Primary.Handle
//SWEP.Primary.HandleCut		--these aren't needed because SWEP.SpreadIncrease is set to false
//SWEP.Primary.SpreadIncrease

SWEP.MoveSpread				= 100 --multiplier for spread when you are moving
SWEP.JumpSpread				= 200 --multiplier for spread when you are jumping
SWEP.CrouchSpread			= 0.5 --multiplier for spread when you are crouching

SWEP.Zoom					= 0 --pretty self explanitory, don't change this unless if you want the gun to be fucked up
SWEP.ZoomOutDelay			= 0.2 -- this is used for the delay between when you shoot and when it zooms out to pull the bolt
SWEP.ZoomInDelay			= 1.5 --always set this 0.2 higher than SWEP.Primary.Delay
SWEP.Zoom1					= 30 --Field of view for the first zoom
SWEP.Zoom2					= 10 --field of view for the second zoom

SWEP.Zoom0Cone				= 0.2 --spread for when not zoomed
SWEP.Zoom1Cone				= 0.0001 --spread for when zoomed once
SWEP.Zoom2Cone				= 0.00001 --spread for when zoomed twice
SWEP.EjectDelay				= 0.53

SWEP.Secondary.ClipSize		= -1 --dont need cuz it just zooms you in
SWEP.Secondary.DefaultClip	= -1 --dont need cuz it just zooms you in
SWEP.Secondary.Automatic	= true --dont need cuz it just zooms you in
SWEP.Secondary.Ammo			= "none" --dont need cuz it just zooms you in

SWEP.IronSightsPos = Vector (5.5739, 0, 2.0518)
SWEP.IronSightsAng = Vector (0, 0, 0)
