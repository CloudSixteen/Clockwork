--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- A function to check if an entity can be static.
function cwStaticEnts:CanEntityStatic(entity)
	if (entity:IsValid()) then
		local class = entity:GetClass();
		local whitelist = {
			"prop_physics",
			"gmod_",
			"prop_ragdoll",
			"edit_"
		};
		local blacklist = {
			"gmod_tool"
		};

		Clockwork.plugin:Call("EditStaticWhitelist", whitelist);
		Clockwork.plugin:Call("EditStaticBlacklist", blacklist);

		for k, v in ipairs(blacklist) do
			if (string.find(class, v)) then
				return false;
			end;
		end;

		for k, v in ipairs(whitelist) do
			if (string.find(class, v)) then
				return class;
			end;
		end;
		
		return false;
	end;
end;

-- Called before the whitelist is checked when an entity is staticed.
function cwStaticEnts:EditStaticWhitelist(whitelist)
	table.Merge(whitelist, Clockwork.kernel:RestoreSchemaData("maps/"..game.GetMap().."/static_entities/whitelist"));
end;

-- A function to save an entity.
function cwStaticEnts:SaveEntity(entity)
	if (IsValid(entity) and Clockwork.plugin:Call("CanEntityStatic", entity)) then
		table.insert(self.staticEnts, entity);
	end;

	self:SaveStaticEnts();
end;

-- A function to return the static mode boolean variable.
function cwStaticEnts:GetStaticMode()
	return self.staticMode[1];
end;

-- A function to load the static entities.
function cwStaticEnts:LoadStaticEnts()
	self.whitelist = Clockwork.kernel:RestoreSchemaData("maps/"..game.GetMap().."/static_entities/whitelist") or {};
	self.staticMode = Clockwork.kernel:RestoreSchemaData("maps/"..game.GetMap().."/static_entities/static_mode") or {false};
	local classTable = Clockwork.kernel:RestoreSchemaData("maps/"..game.GetMap().."/static_entities/classtable");
	local staticEnts = {};
	self.staticEnts = {};
	
	if (classTable and type(classTable) == "table") then
		for k, v in pairs(classTable) do
			local loadTable = Clockwork.kernel:RestoreSchemaData("maps/"..game.GetMap().."/static_entities/"..v);
			
			if (loadTable and #loadTable > 0) then
				for k2, v2 in ipairs(loadTable) do
					table.insert(staticEnts, v2);
				end;

				if (v == "prop_physics") then
					Clockwork.kernel:SaveSchemaData("maps/"..game.GetMap().."/static_entities/backup/"..v, loadTable);
					Clockwork.kernel:DeleteSchemaData("maps/"..game.GetMap().."/static_entities/"..v);
				end;
			end;
		end;
	end;
	
	local staticProps = Clockwork.kernel:RestoreSchemaData("plugins/props/"..game.GetMap());
	
	if (staticProps and #staticProps > 0) then
		for k, v in ipairs(staticProps) do
			v.class = "prop_physics";

			table.insert(staticEnts, v);
		end;
	end;
	
	for k, v in pairs(staticEnts) do			
		local entity = ents.Create(v.class);

		entity:SetMaterial(v.material);
		entity:SetAngles(v.angles);
		entity:SetModel(v.model);
		entity:SetPos(v.position);

		if (!v.renderMode) then
			v.renderMode = 0;
			v.renderFX = 0;
		end;

		if (v.color.a < 255 and v.renderMode == 0) then
			v.renderMode = 1;
		end;

		entity:SetColor(v.color);
		entity:SetRenderMode(v.renderMode);
		entity:SetRenderFX(v.renderFX);

		entity:Spawn();

		if (v.ownerKey) then
			entity:SetOwnerKey(v.ownerKey);
		end;

		Clockwork.plugin:Call("OnStaticEntityLoaded", entity, v);

		table.insert(self.staticEnts, entity)
	end;
end;

-- A function to save the static entities.
function cwStaticEnts:SaveStaticEnts()
	local staticEnts = {};
	
	if (type(self.staticEnts) == "table") then
		for k, v in pairs(self.staticEnts) do
			if (IsValid(v)) then
				local entTable = {};
				local physicsObject = v:GetPhysicsObject();
				local class = v:GetClass();

				staticEnts[class] = staticEnts[class] or {};

				entTable.class = class;			
				entTable.color = v:GetColor();
				entTable.model = v:GetModel();
				entTable.angles = v:GetAngles();
				entTable.position = v:GetPos();
				entTable.material = v:GetMaterial();
				entTable.renderMode = v:GetRenderMode();
				entTable.renderFX = v:GetRenderFX();
				entTable.ownerKey = v:GetOwnerKey();
				
				if (IsValid(physicsObject)) then
					entTable.moveable = physicsObject:IsMoveable();
				end;

				Clockwork.plugin:Call("OnStaticEntitySaved", v, entTable);
				
				table.insert(staticEnts[class], entTable);
			end;
		end;
		
		local classTable = {};
	
		for k, v in pairs(staticEnts) do
			if (k == "prop_physics") then
				Clockwork.kernel:SaveSchemaData("plugins/props/"..game.GetMap(), v);
			else
				Clockwork.kernel:SaveSchemaData("maps/"..game.GetMap().."/static_entities/"..k, v);

				if (!classTable[k]) then
					table.insert(classTable, k);
				end;
			end;
		end;

		for k, v in pairs(_player.GetAll()) do
			if (Clockwork.player:IsAdmin(v)) then
				Clockwork.datastream:Start(v, "StaticESPSync", self.staticEnts);
			end;
		end;

		Clockwork.kernel:SaveSchemaData("maps/"..game.GetMap().."/static_entities/classtable", classTable);
	end;
end;

function cwStaticEnts:OnStaticEntitySaved(entity, entTable)
	if (entity:GetClass() == "gmod_lamp") then
		entTable.texture = entity:GetFlashlightTexture();
		entTable.fov = entity:GetLightFOV();
		entTable.distance = entity:GetDistance();
		entTable.brightness = entity:GetBrightness();	
	elseif (entity:GetClass() == "gmod_light") then
		entTable.brightness = entity:GetBrightness();
		entTable.size = entity:GetLightSize();
	elseif (entity:GetClass() == "prop_ragdoll") then
		local boneTable = {};
					
		for i = 0, entity:GetPhysicsObjectCount() - 1 do
			local bone = entity:GetPhysicsObjectNum(i);
			table.insert(boneTable, {
				ang = bone:GetAngles(),
				pos = bone:GetPos(),
				wake = bone:IsAsleep(),
				moveable = bone:IsMoveable()
			});
		end;
		entTable.bones = boneTable;
	end;
end;

function cwStaticEnts:OnStaticEntityLoaded(entity, entTable)
	if (entTable.bones) then
		for k, v in ipairs(entTable.bones) do
			local bone = entity:GetPhysicsObjectNum(k - 1);

			bone:EnableMotion(v.moveable);
			bone:Wake();					
			bone:SetAngles(v.ang);
			bone:SetPos(v.pos);
							
			if (v.wake == true) then
				bone:Sleep();
			end;
		end;
	elseif (IsValid(entity:GetPhysicsObject())) then
		entity:GetPhysicsObject():EnableMotion(entTable.moveable);
	end;
					
	if (entTable.texture) then
		entity:SetFlashlightTexture(entTable.texture);
		entity:SetLightFOV(entTable.fov);
		entity:SetDistance(entTable.distance);
		entity:SetBrightness(entTable.brightness);
		entity:SetToggle(false);
		entity:Switch(true);
	end;
			
	if (entTable.size) then
		entity:SetBrightness(entTable.brightness);
		entity:SetLightSize(entTable.size);
		entity:SetOn(true);
	end;
end;