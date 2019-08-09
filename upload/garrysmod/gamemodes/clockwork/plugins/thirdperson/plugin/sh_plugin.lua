local PLUGIN = PLUGIN;

PLUGIN:SetGlobalAlias("cwThirdPerson");

local cwThirdPerson = cwThirdPerson;

Clockwork.kernel:IncludePrefixed("cl_plugin.lua");
Clockwork.kernel:IncludePrefixed("cl_hooks.lua");
Clockwork.kernel:IncludePrefixed("sv_plugin.lua");

function cwThirdPerson:UpdateAnimation(player)
	if player:KeyDown(IN_SPEED) then
		player:SetPlaybackRate(1.5);
	end;
end;

function cwThirdPerson:GetThirdPerson(player)
	return player:GetNWBool("thirdperson");
end;

function cwThirdPerson:GetThirdPersonCustom(player)
	return player:GetNWBool("thirdperson_custom");
end;

local PLAYER_META = FindMetaTable("Player");

function PLAYER_META:GetThirdPerson()
	return cwThirdPerson:GetThirdPerson(self);
end;

function PLAYER_META:GetThirdPersonCustom()
	return cwThirdPerson:GetThirdPersonCustom(self);
end;