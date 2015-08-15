local cwThirdPerson = cwThirdPerson;

function cwThirdPerson:Disable(player)
	local entity = player:GetViewEntity();

	player:SetNWBool("thirdperson", false);
	player:SetViewEntity(player);

	entity:Remove();
end;

function cwThirdPerson:Enable(player)
	local entity = ents.Create("prop_dynamic");

	entity:SetModel("models/error.mdl");
	entity:SetColor(Color(0,0,0,0));
	
	entity:Spawn();

	entity:SetNoDraw(true);
	entity:SetAngles(player:GetAngles());
	entity:SetMoveType(MOVETYPE_NONE);
	entity:SetParent(player);
	entity:SetPos(player:GetPos() + Vector(0, 0, 60));
	entity:SetRenderMode(RENDERMODE_NONE);
	entity:SetSolid(SOLID_NONE);
	player:SetViewEntity(entity);
	player:SetNWBool("thirdperson", true);
end;

function cwThirdPerson:SetThirdPerson(player, value)
	if (!value) then
		value = !player:GetThirdPerson();
	end;

	if (value) then
		if (player:GetThirdPerson()) then
			return;
		else
			self:Enable();
		end;
	else
		if (!player:GetThirdPerson()) then
			return;
		else
			self:Disable();
		end;
	end;	
end;

local PLAYER_META = FindMetaTable("Player");

function PLAYER_META:SetThirdPerson(value)
	return cwThirdPerson:SetThirdPerson(self, value);
end;

concommand.Add("chasecam_zoom", function(player, command, arguments)
	if (player:GetVar("thirdperson_zoom") == 1) then
		player:SetVar("thirdperson_zoom", 0);
	else
		player:SetVar("thirdperson_zoom", 1);
	end;
end);

concommand.Add("chasecam", function(player, command, arguments)
	player:SetThirdPerson(arguments[1]);
end);