--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

--[[ 
	We need the datastream and plugin libraries. 
--]]
if (!Clockwork.datastream) then include("sh_datastream.lua"); end;
if (!Clockwork.plugin) then include("sh_plugin.lua"); end;

--[[ 
	Micro Optimizations because local variables are faster than table
	lookups and global variables (which are table lookups).
--]]
local Clockwork = Clockwork;
local cwDatastream = Clockwork.datastream;
local cwConfig = Clockwork.config;
local cwPlugin = Clockwork.plugin;
local cwPly = Clockwork.player;
local CurTime = CurTime;
local Vector = Vector;
local IsValid = IsValid;

Clockwork.ironsights = Clockwork.ironsights or Clockwork.kernel:NewLibrary("CW Ironsights");

local nextIronSights = nil;

function Clockwork.ironsights:GetIronSights(player)
	if (cwConfig:Get("enable_ironsights"):Get()) then
		if (CLIENT) then
			return cwPlugin:Call("PlayerCanSeeIronSights", Clockwork.Client, Clockwork.Client.cwIronSights);
		else
			return player.cwIronSights;
		end;
	else
		return false;
	end;
end;

function Clockwork.ironsights:SetIronSights(player, bValue)
	player.cwIronSights = bValue;

	if (SERVER) then
		cwDatastream:Start(player, "SetClockworkIronSights", {bValue});
	else
		cwDatastream:Start("SetClockworkIronSights", {bValue});
	end;
end;

function Clockwork.ironsights:ToggleIronSights(player)
	if (SERVER) then
		if (IsValid(player) and player:IsValid()) then
			local bIronSights = self:GetIronSights(player);

			if (cwConfig:Get("enable_ironsights"):Get() and cwPlugin:Call("PlayerCanToggleIronSights", player, bIronSights)) then
				local curTime = CurTime();

				if (!nextIronSights or nextIronSights <= curTime) then
					self:SetIronSights(player, !bIronSights);
					nextIronSights = curTime + 0.4;
				end;
			end;
		end;
	else
		cwDatastream:Start("ToggleClockworkIronSights");
	end;
end;

function Clockwork.ironsights:PlayerCanToggleIronSights(player, bIronSights)
	return (cwPly:GetWeaponRaised(player) or bIronSights);
end;

function Clockwork.ironsights:EntityFireBullets(player, bulletInfo)
	if (IsValid(player) and player:IsValid() and player:IsPlayer()) then
		if (self:GetIronSights(player)) then
			local spread = bulletInfo.Spread;
			local spreadReduction = cwConfig:Get("ironsights_spread"):Get() or 1;

			bulletInfo.Spread = Vector(spread.x * spreadReduction, spread.y * spreadReduction, spread.z * spreadReduction);

			return true;
		end;
	end;
end;

if (SERVER) then
	cwDatastream:Hook("ToggleClockworkIronSights", function(player)
		Clockwork.ironsights:ToggleIronSights(player);
	end);

	cwDatastream:Hook("SetClockworkIronSights", function(player, data)
		player.cwIronSights = data[1];
	end);

	function Clockwork.ironsights:PlayerThink(player, curTime, infoTable)
		if (self:GetIronSights(player) and cwPly:GetWeaponRaised(player)) then
			infoTable.walkSpeed = infoTable.walkSpeed * cwConfig:Get("ironsights_spread"):Get() or 0.5;
		end;
	end;

	function Clockwork.ironsights:PlayerSwitchWeapon(player, oldWep, newWep)
		self:SetIronSights(player, false);
	end;
else
	--[[
		Ironsights hooks.
	--]]
	cwDatastream:Hook("SetClockworkIronSights", function(data)
		Clockwork.Client.cwIronSights = data[1];
	end);

	Clockwork.ironsights.ironFraction = 0;

	function Clockwork.ironsights:PlayerCanSeeIronSights(player, bIronSights)
		if (bIronSights) then
			return !player:IsRunning() and cwPly:GetWeaponRaised(player);
		end;

		return false;
	end;

	function Clockwork.ironsights:PlayerAdjustHeadbobInfo(info)
		if (self:GetIronSights()) then
			info.speed = 0;
			info.yaw = 0;
			info.roll = 0;
		end;
	end;

	function Clockwork.ironsights:CanDrawCrosshair(weapon)
		if (!cwConfig:Get("enable_crosshair"):Get()) then
			if (self:GetIronSights() and Clockwork.Client:GetThirdPerson()) then
				return true;
			end;
		end;
	end;

	function Clockwork.ironsights:PlayerBindPress(ply, bind, bPressed)
		if (bind == "+reload") then
			self:SetIronSights(Clockwork.Client, false);
		end;
	end;

	function Clockwork.ironsights:PlayerButtonDown(ply, key)
		if (key == MOUSE_MIDDLE) then
			self:ToggleIronSights(Clockwork.Client);
		end;
	end;

	function Clockwork.ironsights:GetWeaponIronsightsViewInfo(itemTable, weapon, viewTable)
		if (weapon) then
			local pos = weapon.IronSightsPos or weapon.SightsPos;
			local ang = weapon.IronSightsAng or weapon.SightsAng;

			if (pos) then
				viewTable.origin = pos;
			end;

			if (ang) then
				viewTable.angles = ang;
			end;
		end;

		if (itemTable) then
			local pos = itemTable.IronSightsPos;
			local ang = itemTable.IronSightsAng;

			if (pos) then
				viewTable.origin = pos;
			end;

			if (ang) then
				viewTable.angles = ang;
			end;
		end;
	end;

	function Clockwork.ironsights:CalcViewAdjustTable(view)
		if (Clockwork.ironsights:GetIronSights() or Clockwork.ironsights.ironFraction > 1) then
			view.fov = view.fov - (10 * (Clockwork.ironsights.ironFraction/100));
		end;
	end;

	concommand.Add("cwToggleIronSights", function(ply, cmd, args, argStr)
		Clockwork.ironsights:ToggleIronSights();
	end);
end;

cwPlugin:Add("Ironsights_Module", Clockwork.ironsights);