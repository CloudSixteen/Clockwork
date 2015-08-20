local cwThirdPerson = cwThirdPerson;
local Clockwork = Clockwork;

-- Called when the client initializes.
function cwThirdPerson:Initialize()
	CW_CONVAR_THIRDPERSON = Clockwork.kernel:CreateClientConVar("cwThirdPerson", 0, false, true);
	CW_CONVAR_CHASECAM_BOB = Clockwork.kernel:CreateClientConVar("cwChaseCamBob", 1, true, false);
	CW_CONVAR_CHASECAM_BOBSCALE = Clockwork.kernel:CreateClientConVar("cwChaseCamBobScale", 0.5, true, false);
	CW_CONVAR_CHASECAM_BACK = Clockwork.kernel:CreateClientConVar("cwChaseCamBack", 75, true, false);
	CW_CONVAR_CHASECAM_RIGHT = Clockwork.kernel:CreateClientConVar("cwChaseCamRight", 20, true, false);
	CW_CONVAR_CHASECAM_UP = Clockwork.kernel:CreateClientConVar("cwChaseCamUp", 5, true, false);
	CW_CONVAR_CHASECAM_SMOOTH = Clockwork.kernel:CreateClientConVar("cwChaseCamSmooth", 1, true, false);
	CW_CONVAR_CHASECAM_SMOOTHSCALE = Clockwork.kernel:CreateClientConVar("cwChaseCamSmoothScale", 0.2, true, false);
end;

-- Called when a PLUGIN ConVar has changed.
function cwThirdPerson:ClockworkConVarChanged()
	RunConsoleCommand("chasecam", tostring(CW_CONVAR_THIRDPERSON:GetInt()));
end;

-- All credit for third person script goes to cringerpants and his/her affiliates.
-- His/her email: cringerpants@phuce.com

function cwThirdPerson:CalcView(player, pos, angles, fov)
	local smooth = CW_CONVAR_CHASECAM_SMOOTH:GetInt();
	local smoothscale = CW_CONVAR_CHASECAM_SMOOTHSCALE:GetFloat();

	if (player:GetThirdPerson()) then
		angles = player:GetAimVector():Angle();

		local targetpos = Vector(0, 0, 60);

		if player:KeyDown(IN_DUCK) then
			if player:GetVelocity():Length() > 0 then
				targetpos.z = 50;
			else
				targetpos.z = 40;
			end;
		end;

		player:SetAngles(angles);

		local targetfov = fov;

		if (player:GetVelocity():DotProduct(player:GetForward()) > 10) then
			if (player:KeyDown(IN_SPEED)) then
				targetpos = targetpos + player:GetForward() * -10;

				if (CW_CONVAR_CHASECAM_BOB:GetInt() != 0 and player:OnGround()) then
					local bobScale = CW_CONVAR_CHASECAM_BOBSCALE:GetFloat();

					angles.pitch = angles.pitch + bobScale * math.sin(CurTime() * 10);
					angles.roll = angles.roll + bobScale * math.cos(CurTime() * 10);
					targetfov = targetfov + 3;
				end;
			else
				targetpos = targetpos + player:GetForward() * -5;
			end;
		end;

		-- tween to the target position
		pos = player:GetVar("thirdperson_pos") or targetpos;

		if (smooth != 0) then
			pos.x = math.Approach(pos.x, targetpos.x, math.abs(targetpos.x - pos.x) * smoothscale);
			pos.y = math.Approach(pos.y, targetpos.y, math.abs(targetpos.y - pos.y) * smoothscale);
			pos.z = math.Approach(pos.z, targetpos.z, math.abs(targetpos.z - pos.z) * smoothscale);
		else
			pos = targetpos;
		end;

		player:SetVar("thirdperson_pos", pos);

		-- offset it by the stored amounts, but trace so it stays outside walls
		-- we don't tween this so the camera feels like its tightly following the mouse
		local offset = Vector(5, 5, 5);

		if (player:GetVar("thirdperson_zoom") != 1) then
			offset.x = CW_CONVAR_CHASECAM_BACK:GetFloat();
			offset.y = CW_CONVAR_CHASECAM_RIGHT:GetFloat();
			offset.z = CW_CONVAR_CHASECAM_UP:GetFloat();
		end;

		local t = {};

		t.start = player:GetPos() + pos;
		t.endpos = t.start + angles:Forward() * -offset.x;
		t.endpos = t.endpos + angles:Right() * offset.y;
		t.endpos = t.endpos + angles:Up() * offset.z;
		t.filter = player;
		
		local tr = util.TraceLine(t);

		pos = tr.HitPos;

		if (tr.Fraction < 1.0) then
			pos = pos + tr.HitNormal * 5;
		end;
		
		player:SetVar("thirdperson_viewpos", pos);

		-- tween the fov
		fov = player:GetVar("thirdperson_fov") or targetfov;

		if (smooth != 0) then
			fov = math.Approach(fov, targetfov, math.abs(targetfov - fov) * smoothscale);
		else
			fov = targetfov;
		end;

		player:SetVar("thirdperson_fov", fov);

		return GAMEMODE:CalcView(player, pos, angles, fov);
	end;
end;

-- thanks to termy58's crosshair example
-- ... and thanks to termy58 for finding my stupid bug :P
function cwThirdPerson:HUDPaint()
	local player = Clockwork.Client;

	if (!player:GetThirdPerson()) then
		return;
	end;

	-- trace from muzzle to hit pos
	local t = {};

	t.start = player:GetShootPos();
	t.endpos = t.start + player:GetAimVector() * 9000;
	t.filter = player;

	local tr = util.TraceLine(t);
	local pos = tr.HitPos:ToScreen();
	local fraction = math.min((tr.HitPos - t.start):Length(), 1024) / 1024;
	local size = 10 + 20 * (1.0 - fraction);
	local offset = size * 0.5;
	local offset2 = offset - (size * 0.1);

	-- trace from camera to hit pos, if blocked, red cursor
	t = {};
	t.start = player:GetVar("thirdperson_viewpos") or player:GetPos();
	t.endpos = tr.HitPos + tr.HitNormal * 5;
	t.filter = player;

	local tr = util.TraceLine(t);

	if (tr.Fraction != 1.0) then
		surface.SetDrawColor(255, 48, 0, 255);
	else
		surface.SetDrawColor(255, 208, 64, 255);
	end;

	surface.DrawLine(pos.x - offset, pos.y, pos.x - offset2, pos.y);
	surface.DrawLine(pos.x + offset, pos.y, pos.x + offset2, pos.y);
	surface.DrawLine(pos.x, pos.y - offset, pos.x, pos.y - offset2);
	surface.DrawLine(pos.x, pos.y + offset, pos.x, pos.y + offset2);
	surface.DrawLine(pos.x - 1, pos.y, pos.x + 1, pos.y);
	surface.DrawLine(pos.x, pos.y - 1, pos.x, pos.y + 1);
end;

function cwThirdPerson:HUDShouldDraw(name)
	if (name == "CHudCrosshair" and Clockwork.Client:GetThirdPerson()) then
		return false;
	end;
end;