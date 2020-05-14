--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

DEFINE_BASECLASS("base_gmodentity");

ENT.Type = "anim";
ENT.Author = "kurozael";
ENT.PrintName = "Gear";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.UsableInVehicle = true;

-- Called when the data tables are setup.
function ENT:SetupDataTables()
	self:DTVar("Int", 0, "Index");
end;

-- A function to get the entity's real position.
function ENT:GetRealPosition()
	local offsetVector = self:GetOffsetVector();
	local offsetAngle = self:GetOffsetAngle();
	local itemTable = self:GetItemTable();
	local player = self:GetPlayer();
	local bone = player:LookupBone(self:GetBone());
	
	if (offsetVector and offsetAngle and player and bone) then
		local position, angles = player:GetBonePosition(bone);
		local ragdollEntity = player:GetRagdollEntity();
		
		if (itemTable.AdjustAttachmentOffsetInfo) then
			local info = {
				offsetVector = offsetVector,
				offsetAngle = offsetAngle
			};
			
			itemTable:AdjustAttachmentOffsetInfo(player, self, info);
			offsetVector = info.offsetVector;
			offsetAngle = info.offsetAngle;
		end;
		
		if (ragdollEntity) then
			position, angles = ragdollEntity:GetBonePosition(bone);
		end;
		
		local x = angles:Up() * offsetVector.x;
		local y = angles:Right() * offsetVector.y;
		local z = angles:Forward() * offsetVector.z;
		
		angles:RotateAroundAxis(angles:Forward(), offsetAngle.p);
		angles:RotateAroundAxis(angles:Right(), offsetAngle.y);
		angles:RotateAroundAxis(angles:Up(), offsetAngle.r);
		
		return position + x + y + z, angles;
	end;
end;

-- A function to get the entity's bone.
function ENT:GetBone()
	local itemTable = self:GetItemTable();
	return itemTable("attachmentBone", "");
end;

-- A function to get the entity's item table.
function ENT:GetItemTable()
	if (CLIENT) then
		local itemTable = Clockwork.entity:FetchItemTable(self);
		
		if (!itemTable) then
			return Clockwork.item:FindByID(self:GetDTInt(0));
		else
			return itemTable;
		end;
	end;
	
	return self.cwItemTable;
end;

-- A function to get the entity's player.
function ENT:GetPlayer()
	local player = self:GetOwner();
	
	if (IsValid(player) and player:IsPlayer()) then
		return player;
	end;
end;

-- A function to get the entity's offset vector.
function ENT:GetOffsetVector()
	local itemTable = self:GetItemTable();
	return itemTable("attachmentOffsetVector", Vector(0, 0, 0));
end;

-- A function to get the entity's offset angle.
function ENT:GetOffsetAngle()
	local itemTable = self:GetItemTable();
	return itemTable("attachmentOffsetAngles", Angle(0, 0, 0));
end;