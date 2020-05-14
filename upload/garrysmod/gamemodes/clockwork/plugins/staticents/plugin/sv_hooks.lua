--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when Clockwork has loaded all of the entities.
function cwStaticEnts:ClockworkInitPostEntity()
	self:LoadStaticEnts();
end;

-- Called just after data should be saved.
function cwStaticEnts:PostSaveData()
	if (#player.GetAll() > 0) then
		self:SaveStaticEnts();
	end;
end;

local groupCheck = {
	owner = true,
	superadmin = true,
	admin = true,
	operator = true
};

-- Called when a player's usergroup has been set.
function cwStaticEnts:OnPlayerUserGroupSet(player, usergroup)
	if (groupCheck[string.lower(usergroup)]) then
		local staticEnts = {};

		for k, v in ipairs(cwStaticEnts.staticEnts) do
			if (IsValid(v) and v:IsValid()) then
				table.insert(staticEnts, v);
			end;
		end;

		Clockwork.datastream:Start(player, "StaticESPSync", staticEnts);
	end;
end;

function cwStaticEnts:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (player:IsAdmin()) then
		local staticEnts = {};

		for k, v in ipairs(cwStaticEnts.staticEnts) do
			if (IsValid(v) and v:IsValid()) then
				table.insert(staticEnts, v);
			end;
		end;

		Clockwork.datastream:Start(player, "StaticESPSync", staticEnts);
	end;
end;

function cwStaticEnts:PlayerSpawnedProp(player, model, ent)
	if (self:GetStaticMode()) then		
		self:SaveEntity(ent);
	end;
end;

function cwStaticEnts:PlayerSpawnedSENT(player, ent)
	if (self:GetStaticMode()) then			
		self:SaveEntity(ent);
	end;
end;

function cwStaticEnts:PlayerSpawnedRagdoll(player, model, ent)
	if (self:GetStaticMode()) then		
		self:SaveEntity(ent);
	end;
end;