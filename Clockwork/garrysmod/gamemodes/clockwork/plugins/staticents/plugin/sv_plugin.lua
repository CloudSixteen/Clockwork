--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- A function to load the static entities.
function cwStaticEnts:LoadStaticEnts()
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
			end;
		end;
	end;
	
	local staticProps = Clockwork.kernel:RestoreSchemaData("plugins/props/"..game.GetMap());
	
	if (#staticProps > 0) then
		for k, v in ipairs(staticProps) do
			table.insert(staticEnts, v);
		end;
		
		Clockwork.kernel:SaveSchemaData("plugins/props/"..game.GetMap(), {});
	end;
	
	for k, v in pairs(staticEnts) do
		if (!v.class) then
			v.class = "prop_physics";
		end;
			
		local entity = ents.Create(v.class);
			entity:SetMaterial(v.material);
			entity:SetAngles(v.angles);
			entity:SetColor(v.color);
			entity:SetModel(v.model);
			entity:SetPos(v.position);
			entity:Spawn();

			if (v.bones) then
				for k2, v2 in ipairs(v.bones) do
					local bone = entity:GetPhysicsObjectNum(k2 - 1);

					bone:EnableMotion(v2.moveable);
					bone:Wake();					
					bone:SetAngles(v2.ang);
					bone:SetPos(v2.pos);
							
					if (v2.wake == true) then
						bone:Sleep();
					end;
				end;
			elseif (IsValid(entity:GetPhysicsObject())) then
				entity:GetPhysicsObject():EnableMotion(v.moveable);
			end;
					
			if (v.texture) then
				entity:SetFlashlightTexture(v.texture);
				entity:SetLightFOV(v.fov);
				entity:SetDistance(v.distance);
				entity:SetBrightness(v.brightness);
				entity:SetToggle(false);
				entity:Switch(true);
			end;
					
			if (v.size) then
				entity:SetBrightness(v.brightness);
				entity:SetLightSize(v.size);
				entity:SetOn(true);
			end;

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

				staticEnts[v:GetClass()] = staticEnts[v:GetClass()] or {};

				entTable.class = v:GetClass();			
				entTable.color = v:GetColor();
				entTable.model = v:GetModel();
				entTable.angles = v:GetAngles();
				entTable.position = v:GetPos();
				entTable.material = v:GetMaterial();
				
				if (IsValid(physicsObject)) then
					entTable.moveable = physicsObject:IsMoveable();
				end;
				
				if (v:GetClass() == "gmod_lamp") then
					entTable.texture = v:GetFlashlightTexture();
					entTable.fov = v:GetLightFOV();
					entTable.distance = v:GetDistance();
					entTable.brightness = v:GetBrightness();	
				elseif (v:GetClass() == "gmod_light") then
					entTable.brightness = v:GetBrightness();
					entTable.size = v:GetLightSize();
				elseif (v:GetClass() == "prop_ragdoll") then
					local boneTable = {};
					
					for i = 0, v:GetPhysicsObjectCount() - 1 do
						local bone = v:GetPhysicsObjectNum(i);
						table.insert(boneTable, {
							ang = bone:GetAngles(),
							pos = bone:GetPos(),
							wake = bone:IsAsleep(),
							moveable = bone:IsMoveable()
						});
					end;
					entTable.bones = boneTable;
				end;
				
				table.insert(staticEnts[v:GetClass()], entTable);
			end;
		end;
		
		local classTable = {};
	
		for k, v in pairs(staticEnts) do
			Clockwork.kernel:SaveSchemaData("maps/"..game.GetMap().."/static_entities/"..k, v);

			if (!classTable[k]) then
				table.insert(classTable, k);
			end;
		end;

		Clockwork.kernel:SaveSchemaData("maps/"..game.GetMap().."/static_entities/classtable", classTable);
	end;
end;

-- Called every tick.
function cwStaticEnts:Tick()
	if (#self.staticEnts > 0) then
		if (!self.nextSync or self.nextSync < CurTime()) then
			local sendTable = {};
			local filter = {};
			
			for k, v in ipairs(player.GetAll()) do
				if (Clockwork.player:IsAdmin(v)) then
					table.insert(sendTable, v);
				end;
			end;
			
			
			for k, v in ipairs(self.staticEnts) do
				if (IsValid(v)) then
					if (v:IsValid()) then
						table.insert(filter, {
							pos = v:GetPos(),
							class = v:GetClass()
						});
					end;
				end;
			end;
				
			Clockwork.datastream:Start(sendTable, "staticESPSync", filter);
			self.nextSync = CurTime() + 2;
		end;
	end;
end;