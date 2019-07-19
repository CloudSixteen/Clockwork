--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.salesmenu = Clockwork.kernel:NewLibrary("Salesmenu");

-- A function to get whether the salesmenu is open.
function Clockwork.salesmenu:IsSalesmenuOpen()
	local panel = self:GetPanel();
	
	if (IsValid(panel) and panel:IsVisible()) then
		return true;
	end;
end;

-- A function to get whether the items are bought shipments.
function Clockwork.salesmenu:BuyInShipments()
	return self.buyInShipments;
end;

-- A function to get the salesmenu price scale.
function Clockwork.salesmenu:GetPriceScale()
	return self.priceScale or 1;
end;

-- A function to get the salesmenu buy rate.
function Clockwork.salesmenu:GetBuyRate()
	return self.buyRate;
end;

-- A function to get the salesmenu classes.
function Clockwork.salesmenu:GetClasses()
	return self.classes;
end;

-- A function to get the salesmenu factions.
function Clockwork.salesmenu:GetFactions()
	return self.factions;
end;

-- A function to get the salesmenu stock.
function Clockwork.salesmenu:GetStock()
	return self.stock;
end;

-- A function to get the salesmenu cash.
function Clockwork.salesmenu:GetCash()
	return self.cash;
end;

-- A function to get the salesmenu text.
function Clockwork.salesmenu:GetText()
	return self.text;
end;

-- A function to get the salesmenu entity.
function Clockwork.salesmenu:GetEntity()
	return self.entity;
end;

-- A function to get the salesmenu buys.
function Clockwork.salesmenu:GetBuys()
	return self.buys;
end;

-- A function to get the salesmenu sels.
function Clockwork.salesmenu:GetSells()
	return self.sells;
end;

-- A function to get the salesmenu panel.
function Clockwork.salesmenu:GetPanel()
	return self.panel;
end;

-- A function to get the salesmenu name.
function Clockwork.salesmenu:GetName()
	return self.name;
end;