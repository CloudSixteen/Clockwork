--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.salesman = Clockwork.kernel:NewLibrary("Salesman");

-- A function to get whether the salesman is open.
function Clockwork.salesman:IsSalesmanOpen()
	local panel = self:GetPanel();
	
	if (IsValid(panel) and panel:IsVisible()) then
		return true;
	end;
end;

-- A function to get whether the items are bought shipments.
function Clockwork.salesman:BuyInShipments()
	return self.buyInShipments;
end;

-- A function to get the salesman price scale.
function Clockwork.salesman:GetPriceScale()
	return self.priceScale or 1;
end;

-- A function to get whether the salesman's chat bubble is shown.
function Clockwork.salesman:GetShowChatBubble()
	return self.showChatBubble;
end;

-- A function to get the salesman stock.
function Clockwork.salesman:GetStock()
	return self.stock;
end;

-- A function to get the salesman cash.
function Clockwork.salesman:GetCash()
	return self.cash;
end;

-- A function to get the salesman buy rate.
function Clockwork.salesman:GetBuyRate()
	return self.buyRate;
end;

-- A function to get the salesman classes.
function Clockwork.salesman:GetClasses()
	return self.classes;
end;

-- A function to get the salesman factions.
function Clockwork.salesman:GetFactions()
	return self.factions;
end;

-- A function to get the salesman text.
function Clockwork.salesman:GetText()
	return self.text;
end;

-- A function to get what the salesman sells.
function Clockwork.salesman:GetSells()
	return self.sells;
end;

-- A function to get what the salesman buys.
function Clockwork.salesman:GetBuys()
	return self.buys;
end;

-- A function to get the salesman items.
function Clockwork.salesman:GetItems()
	return self.items;
end;

-- A function to get the salesman panel.
function Clockwork.salesman:GetPanel()
	return self.panel;
end;

-- A function to get the salesman model.
function Clockwork.salesman:GetModel()
	return self.model;
end;

-- A function to get the salesman name.
function Clockwork.salesman:GetName()
	return self.name;
end;