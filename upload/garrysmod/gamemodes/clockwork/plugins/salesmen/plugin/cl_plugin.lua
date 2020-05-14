--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when the salesman's target ID is painted.
function cwSalesmen:SalesmanTargetID(entity, x, y, alpha) end;

Clockwork.datastream:Hook("Salesmenu", function(data)
	Clockwork.salesmenu.buyInShipments = data.buyInShipments;
	Clockwork.salesmenu.priceScale = data.priceScale;
	Clockwork.salesmenu.factions = data.factions;
	Clockwork.salesmenu.buyRate = data.buyRate;
	Clockwork.salesmenu.classes = data.classes;
	Clockwork.salesmenu.entity = data.entity;
	Clockwork.salesmenu.sells = data.sells;
	Clockwork.salesmenu.stock = data.stock;
	Clockwork.salesmenu.cash = data.cash;
	Clockwork.salesmenu.text = data.text;
	Clockwork.salesmenu.buys = data.buys;
	Clockwork.salesmenu.name = data.name;
	
	Clockwork.salesmenu.panel = vgui.Create("cwSalesmenu");
	Clockwork.salesmenu.panel:Rebuild();
	Clockwork.salesmenu.panel:MakePopup();
end);

Clockwork.datastream:Hook("SalesmenuRebuild", function(data)
	local cash = data;
	
	if (Clockwork.salesmenu:IsSalesmenuOpen()) then
		Clockwork.salesmenu.cash = cash;
		Clockwork.salesmenu.panel:Rebuild();
	end;
end);

Clockwork.datastream:Hook("SalesmanPlaySound", function(data)
	if (data[2] and data[2]:IsValid()) then
		data[2]:EmitSound(data[1]);
	end;
end);

Clockwork.datastream:Hook("SalesmanAdd", function(data)
	if (Clockwork.salesman:IsSalesmanOpen()) then
		CloseDermaMenus();
		
		Clockwork.salesman.panel:Close();
		Clockwork.salesman.panel:Remove();
	end;
	
	Derma_StringRequest("Name", "What do you want the salesman's name to be?", "", function(text)
		Clockwork.salesman.name = text;
		
		gui.EnableScreenClicker(true);
		
		Clockwork.salesman.showChatBubble = true;
		Clockwork.salesman.buyInShipments = true;
		Clockwork.salesman.priceScale = 1;
		Clockwork.salesman.physDesc = "";
		Clockwork.salesman.factions = {};
		Clockwork.salesman.buyRate = 100;
		Clockwork.salesman.classes = {};
		Clockwork.salesman.stock = -1;
		Clockwork.salesman.sells = {};
		Clockwork.salesman.model = "models/humans/group01/male_0"..math.random(1, 9)..".mdl";
		Clockwork.salesman.items = {};
		Clockwork.salesman.cash = -1;
		Clockwork.salesman.text = {
			doneBusiness = {},
			cannotAfford = {},
			needMore = {},
			noStock = {},
			noSale = {},
			start = {}
		};
		Clockwork.salesman.buys = {};
		Clockwork.salesman.name = Clockwork.salesman.name;
		
		for k, v in pairs(Clockwork.item:GetAll()) do
			if (!v("isBaseItem")) then
				Clockwork.salesman.items[k] = v;
			end;
		end;
		
		Clockwork.salesman.panel = vgui.Create("cwSalesman");
		Clockwork.salesman.panel:Rebuild();
		Clockwork.salesman.panel:MakePopup();
	end);
end);

Clockwork.datastream:Hook("SalesmanEdit", function(data)
	if (Clockwork.salesman:IsSalesmanOpen()) then
		CloseDermaMenus();
		
		Clockwork.salesman.panel:Close();
		Clockwork.salesman.panel:Remove();
	end;
	
	Derma_StringRequest("Name", "What do you want to change the salesman's name to?", data.name, function(text)
		Clockwork.salesman.showChatBubble = data.showChatBubble;
		Clockwork.salesman.buyInShipments = data.buyInShipments;
		Clockwork.salesman.priceScale = data.priceScale;
		Clockwork.salesman.factions = data.factions;
		Clockwork.salesman.physDesc = data.physDesc;
		Clockwork.salesman.buyRate = data.buyRate;
		Clockwork.salesman.classes = data.classes;
		Clockwork.salesman.stock = -1;
		Clockwork.salesman.sells = data.sellTab;
		Clockwork.salesman.model = data.model;
		Clockwork.salesman.items = {};
		Clockwork.salesman.cash = data.cash;
		Clockwork.salesman.text = data.textTab;
		Clockwork.salesman.buys = data.buyTab;
		Clockwork.salesman.name = text;
		
		for k, v in pairs(Clockwork.item:GetAll()) do
			if (!v("isBaseItem")) then
				Clockwork.salesman.items[k] = v;
			end;
		end;
		
		gui.EnableScreenClicker(true);
		
		local scrW = ScrW();
		local scrH = ScrH();
		
		Clockwork.salesman.panel = vgui.Create("cwSalesman");
		Clockwork.salesman.panel:SetSize(scrW * 0.5, scrH * 0.75);
		Clockwork.salesman.panel:SetPos(
			(scrW / 2) - (Clockwork.salesman.panel:GetWide() / 2),
			(scrH / 2) - (Clockwork.salesman.panel:GetTall() / 2)
		);
		Clockwork.salesman.panel:Rebuild();
		Clockwork.salesman.panel:MakePopup();
	end);
end);