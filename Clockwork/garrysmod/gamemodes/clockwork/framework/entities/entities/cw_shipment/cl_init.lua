--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

include("shared.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	local itemTable = self:GetItemTable();
	
	if (itemTable) then
		y = Clockwork.kernel:DrawInfo(L("Shipment"), x, y, colorTargetID, alpha);
		y = Clockwork.kernel:DrawInfo(L(itemTable("name")), x, y, colorWhite, alpha);
	end;
end;

-- Called when the entity should draw.
function ENT:Draw()
	if (Clockwork.plugin:Call("ShipmentEntityDraw", self) != false) then
		self:DrawModel();
	end;
end;