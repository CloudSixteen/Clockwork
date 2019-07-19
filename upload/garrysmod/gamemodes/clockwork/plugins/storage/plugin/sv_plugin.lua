--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.datastream:Hook("ContainerPassword", function(player, data)
	local password = data[1];
	local entity = data[2];
	
	if (IsValid(entity) and Clockwork.entity:IsPhysicsEntity(entity)) then
		local model = string.lower(entity:GetModel());
		
		if (cwStorage.containerList[model]) then
			local containerWeight = cwStorage.containerList[model][1];
			
			if (entity.cwPassword == password) then
				cwStorage:OpenContainer(player, entity, containerWeight);
			else
				Clockwork.player:Notify(player, {"ContainerIncorrectPassword"});
			end;
		end;
	end;
end);

-- A function to get a random item.
function cwStorage:GetRandomItem(uniqueID)
	if (uniqueID) then
		uniqueID = string.lower(uniqueID);
	end;

	if (#self.randomItems <= 0) then
		return;
	end;

	local randomItem = self.randomItems[
		math.random(1, #self.randomItems)
	];

	if (randomItem) then
		local itemTable = Clockwork.item:FindByID(randomItem[1]);

		if (!uniqueID or string.find(string.lower(itemTable("category")), uniqueID)) then
			return randomItem;
		end;
	end;

	return self:GetRandomItem(uniqueID, runs);
end;

function cwStorage:CategoryExists(uniqueID)
	if (uniqueID) then 
		local uniqueID = string.lower(uniqueID);

		for i = 1, #self.randomItems do
			local item = Clockwork.item:FindByID(self.randomItems[i][1]);

			if (string.find(string.lower(item("category")), uniqueID)) then
				return true;
			end;
		end;

		return false;
	else
		return false;
	end;
end;

-- A function to save the storage.
function cwStorage:SaveStorage()
	local storage = {};
	
	for k, v in pairs(self.storage) do
		if (IsValid(v)) then
			if (v.cwInventory and v.cwCash and (v.cwMessage or table.Count(v.cwInventory) > 0 or v.cwCash > 0 or v:GetNetworkedString("Name") != "")) then
				local physicsObject = v:GetPhysicsObject();
				local bMoveable = nil;
				local startPos = v:GetStartPosition();
				local model = v:GetModel();
				
				if (v:IsMapEntity() and startPos) then
					model = nil;
				end;
				
				if (IsValid(physicsObject)) then
					bMoveable = physicsObject:IsMoveable();
				end;
				
				storage[#storage + 1] = {
					name = v:GetNetworkedString("Name"),
					model = model,
					cash = v.cwCash,
					color = { v:GetColor() },
					angles = v:GetAngles(),
					position = v:GetPos(),
					message = v.cwMessage,
					password = v.cwPassword,
					startPos = startPos,
					inventory = Clockwork.inventory:ToSaveable(v.cwInventory),
					isMoveable = bMoveable
				};
			end;
		end;
	end;
	
	Clockwork.kernel:SaveSchemaData("plugins/storage/"..game.GetMap(), storage);
end;

-- A function to load the storage.
function cwStorage:LoadStorage()
	local storage = Clockwork.kernel:RestoreSchemaData("plugins/storage/"..game.GetMap());
	
	self.storage = {};
	
	for k, v in pairs(storage) do
		if (!v.model) then
			local entity = ents.FindInSphere((v.startPos or v.position), 16)[1];
			
			if (IsValid(entity) and entity:IsMapEntity()) then
				self.storage[entity] = entity;
				
				entity.cwInventory = Clockwork.inventory:ToLoadable(v.inventory);
				entity.cwPassword = v.password;
				entity.cwMessage = v.message;
				entity.cwCash = v.cash;
				
				if (IsValid(entity:GetPhysicsObject())) then
					if (!v.isMoveable) then
						entity:GetPhysicsObject():EnableMotion(false);
					else
						entity:GetPhysicsObject():EnableMotion(true);
					end;
				end;
				
				if (v.angles) then
					entity:SetAngles(v.angles);
					entity:SetPos(v.position);
				end;
				
				if (v.color) then
					entity:SetColor(unpack(v.color));
				end;
				
				if (v.name != "") then
					entity:SetNetworkedString("Name", v.name);
				end;
			end;
		else
			local entity = ents.Create("prop_physics");
			
			entity:SetAngles(v.angles);
			entity:SetModel(v.model);
			entity:SetPos(v.position);
			entity:Spawn();
			
			if (IsValid(entity:GetPhysicsObject())) then
				if (!v.isMoveable) then
					entity:GetPhysicsObject():EnableMotion(false);
				end;
			end;
			
			if (v.color) then
				entity:SetColor(unpack(v.color));
			end;
			
			if (v.name != "") then
				entity:SetNetworkedString("Name", v.name);
			end;
			
			self.storage[entity] = entity;
			
			entity.cwInventory = Clockwork.inventory:ToLoadable(v.inventory);
			entity.cwPassword = v.password;
			entity.cwMessage = v.message;
			entity.cwCash = v.cash;
		end;
	end;
end;

-- A function to open a container for a player.
function cwStorage:OpenContainer(player, entity, weight)
	local inventory;
	local cash = 0;
	local model = string.lower(entity:GetModel());
	local name = "";
	
	if (!entity.cwInventory) then
		self.storage[entity] = entity;
		
		entity.cwInventory = {};
	end;
	
	if (!entity.cwCash) then
		entity.cwCash = 0;
	end;
	
	if (self.containerList[model]) then
		name = self.containerList[model][2];
	else
		name = "Container";
	end;
	
	inventory = entity.cwInventory;
	cash = entity.cwCash;
	
	if (!weight) then
		weight = 8;
	end;
	
	if (entity:GetNetworkedString("Name") != "") then
		name = entity:GetNetworkedString("Name");
	end;
	
	if (entity.cwMessage) then
		Clockwork.datastream:Start(player, "StorageMessage", {
			entity = entity, message = entity.cwMessage
		});
	end;
	
	Clockwork.storage:Open(player, {
		name = name,
		weight = weight,
		entity = entity,
		distance = 192,
		cash = cash,
		inventory = inventory,
		OnGiveCash = function(player, storageTable, cash)
			storageTable.entity.cwCash = storageTable.cash;
		end,
		OnTakeCash = function(player, storageTable, cash)
			storageTable.entity.cwCash = storageTable.cash;
		end
	});
end;