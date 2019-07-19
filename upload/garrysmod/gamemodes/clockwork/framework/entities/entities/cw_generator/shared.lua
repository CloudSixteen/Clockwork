--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

DEFINE_BASECLASS("base_gmodentity");

ENT.Type = "anim";
ENT.Model = "models/props_combine/combine_mine01.mdl";
ENT.Author = "kurozael";
ENT.PrintName = "Generator";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.UsableInVehicle = true;

-- Called when the data tables are setup.
function ENT:SetupDataTables()
	self:DTVar("Int", 0, "Power");
end;

-- A function to get the entity's power.
function ENT:GetPower()
	return self:GetDTInt(0);
end;