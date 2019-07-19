--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when Clockwork has loaded all of the entities.
function cwSalesmen:ClockworkInitPostEntity()
	self:LoadSalesmen();
end;

-- Called just after data should be saved.
function cwSalesmen:PostSaveData()
	self:SaveSalesmen();
end;

-- Called when a player attempts to use a salesman.
function cwSalesmen:PlayerCanUseSalesman(player, entity)
	local numFactions = table.Count(entity.cwFactions);
	local numClasses = table.Count(entity.cwClasses);
	local bDisallowed = nil;
	
	if (numFactions > 0) then
		if (!entity.cwFactions[player:GetFaction()]) then
			bDisallowed = true;
		end;
	end;
	
	if (numClasses > 0) then
		if (!entity.cwClasses[cwTeam.GetName(player:Team())]) then
			bDisallowed = true;
		end;
	end;
	
	if (bDisallowed) then
		entity:TalkToPlayer(player, entity.cwTextTab.noSale, "I cannot trade my inventory with you!");
		return false;
	end;
end;

-- Called when a player uses a salesman.
function cwSalesmen:PlayerUseSalesman(player, entity)
	Clockwork.datastream:Start(player, "Salesmenu", {
		buyInShipments = entity.cwBuyInShipments,
		priceScale = entity.cwPriceScale,
		factions = entity.cwFactions,
		buyRate = entity.cwBuyRate,
		classes = entity.cwClasses,
		entity = entity,
		stock = entity.cwStock,
		sells = entity.cwSellTab,
		cash = entity.cwCash,
		text = entity.cwTextTab,
		buys = entity.cwBuyTab,
		name = entity:GetNetworkedString("Name")
	});

	entity:TalkToPlayer(player,	entity.cwTextTab.start,	"How can I help you today?");
end;