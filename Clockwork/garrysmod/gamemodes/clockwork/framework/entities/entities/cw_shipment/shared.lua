--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

DEFINE_BASECLASS("base_gmodentity");

ENT.Type = "anim";
ENT.Author = "kurozael";
ENT.PrintName = "Shipment";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.UsableInVehicle = true;

-- Called when the data tables are setup.
function ENT:SetupDataTables()
	self:DTVar("Int", 0, "Index");
end;

-- A function to get the entity's item table.
function ENT:GetItemTable()
	if (CLIENT) then
		local index = self:GetDTInt(0);
		
		if (index != 0) then
			return Clockwork.item:FindByID(index);
		end;
	end;
	
	return self.cwItemTable;
end;