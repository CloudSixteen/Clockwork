--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

local ITEM = Clockwork.item:New(nil, true);

ITEM.name = "Generator Base";
ITEM.model = "models/props_combine/combine_mine01.mdl";
ITEM.batch = 1;
ITEM.weight = 3;
ITEM.category = "Entities";

-- Called when the item's shipment entity should be created.
function ITEM:OnCreateShipmentEntity(player, batch, position)
	return Clockwork.entity:CreateGenerator(
		player, self("generatorInfo").uniqueID, position
	);
end;

-- Called when the item's drop entity should be created.
function ITEM:OnCreateDropEntity(player, position)
	return Clockwork.entity:CreateGenerator(
		player, self("generatorInfo").uniqueID, position
	);
end;

-- Called when the item should be setup.
function ITEM:OnSetup()
	local generatorInfo = self("generatorInfo");
	
	if (generatorInfo) then
		Clockwork.generator:Register(
			generatorInfo.name,
			generatorInfo.power,
			generatorInfo.health,
			generatorInfo.maximum,
			generatorInfo.cash,
			generatorInfo.uniqueID,
			generatorInfo.powerName,
			generatorInfo.powerPlural
		);
	end;
end;

-- Called when a player attempts to order the item.
function ITEM:CanOrder(player)
	if (self.PreOrder) then
		self:PreOrder(player);
	end;
	
	local generatorInfo = self("generatorInfo");
	
	if (generatorInfo) then
		local generatorTable = Clockwork.generator:FindByID(generatorInfo.uniqueID);
		local maximum = generatorTable.maximum;
		
		if (self.OnGetMaximum) then
			maximum = self:OnGetMaximum(player, maximum);
		end;
		
		if (Clockwork.player:GetPropertyCount(player, generatorInfo.uniqueID) >= maximum) then
			Clockwork.player:Notify(player, {"YouHaveMaxOfThese"});
			return false;
		end;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (self.PreDrop) then self:PreDrop(player); end;
	
	local generatorInfo = self("generatorInfo");
	
	if (generatorInfo) then
		local generatorTable = Clockwork.generator:FindByID(generatorInfo.uniqueID);
		local maximum = generatorTable.maximum;
		
		if (self.OnGetMaximum) then
			maximum = self:OnGetMaximum(player, maximum);
		end;
		
		if (Clockwork.player:GetPropertyCount(player, generatorInfo.uniqueID) == maximum) then
			Clockwork.player:Notify(player, {"YouHaveMaxOfThese"});
			return false;
		end;
	end;
end;

Clockwork.item:Register(ITEM);