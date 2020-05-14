--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

include("shared.lua");

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetHealth(50);
	self:SetSolid(SOLID_VPHYSICS);
	
	local physicsObject = self:GetPhysicsObject();
	
	if (IsValid(physicsObject)) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
end;

-- Called when the entity's transmit state should be updated.
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS;
end;

-- A function to set the data of the entity.
function ENT:SetData(inventory, cash)
	self:SetModel("models/weapons/w_suitcase_passenger.mdl");
	self.cwInventory = inventory;
	self.cwCash = cash;
end;

-- A function to explode the entity.
function ENT:Explode(scale)
	local effectData = EffectData();
		effectData:SetStart(self:GetPos());
		effectData:SetOrigin(self:GetPos());
		effectData:SetScale(8);
	util.Effect("GlassImpact", effectData, true, true);

	self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0));
	
	if (self:Health() <= 0) then
		self:Explode(); self:Remove();
	end;
end;

-- Called when the entity is removed.
function ENT:OnRemove()
	if (!Clockwork.kernel:IsShuttingDown()) then
		Clockwork.entity:DropItemsAndCash(self.cwInventory, self.cwCash, self:GetPos(), self);
		self.cwInventory = nil;
		self.cwCash = nil;
	end;
end;