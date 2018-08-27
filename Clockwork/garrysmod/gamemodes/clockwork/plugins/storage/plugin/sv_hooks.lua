--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when Clockwork has loaded all of the entities.
function cwStorage:ClockworkInitPostEntity()
	self:LoadStorage();
	self.randomItems = {};
	
	for k, v in pairs(Clockwork.item:GetAll()) do
		if (!v("isRareItem") and !v("isBaseItem")) then
			self.randomItems[#self.randomItems + 1] = {
				v("uniqueID"),
				v("weight")
			};
		end;
	end;
end;

-- Called when data should be saved.
function cwStorage:SaveData()
	self:SaveStorage();
end;

-- Called when a player attempts to breach an entity.
function cwStorage:PlayerCanBreachEntity(player, entity)
	if (entity.cwInventory and entity.cwPassword) then
		return true;
	end;
end;

-- Called when an entity attempts to be auto-removed.
function cwStorage:EntityCanAutoRemove(entity)
	if (self.storage[entity] or entity:GetNetworkedString("Name") != "") then
		return false;
	end;
end;

-- Called when an entity's menu option should be handled.
function cwStorage:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass();
	
	if (class == "cw_locker" and arguments == "cwContainerOpen") then
		self:OpenContainer(player, entity);
	elseif (arguments == "cwContainerOpen") then
		if (Clockwork.entity:IsPhysicsEntity(entity)) then
			local model = string.lower(entity:GetModel());
			
			if (self.containerList[model]) then
				local containerWeight = self.containerList[model][1];
				
				if (!entity.cwPassword or entity.cwIsBreached) then
					self:OpenContainer(player, entity, containerWeight);
				else
					Clockwork.datastream:Start(player, "ContainerPassword", entity);
				end;
			end;
		end;
	end;
end;

-- Called when an entity has been breached.
function cwStorage:EntityBreached(entity, activator)
	if (entity.cwInventory and entity.cwPassword) then
		entity.cwIsBreached = true;
		
		Clockwork.kernel:CreateTimer("ResetBreach"..entity:EntIndex(), 120, 1, function()
			if (IsValid(entity)) then
				entity.cwIsBreached = nil;
			end;
		end);
	end;
end;

-- Called when an entity is removed.
function cwStorage:EntityRemoved(entity)
	if (IsValid(entity) and !entity.cwIsBelongings and !Clockwork.kernel:IsShuttingDown()) then
		Clockwork.entity:DropItemsAndCash(entity.cwInventory, entity.cwCash, entity:GetPos(), entity);
		entity.cwInventory = nil;
		entity.cwCash = nil;
	end;
end;

-- Called when a player's prop cost info should be adjusted.
function cwStorage:PlayerAdjustPropCostInfo(player, entity, info)
	local model = string.lower(entity:GetModel());
	
	if (self.containerList[model]) then
		info.name = self.containerList[model][2];
	end;
end;