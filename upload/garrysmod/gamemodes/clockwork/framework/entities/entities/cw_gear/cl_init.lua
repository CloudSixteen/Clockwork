--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

include("shared.lua")

-- Called each frame.
function ENT:Think()
	if (!Clockwork.entity:HasFetchedItemData(self)) then
		Clockwork.entity:FetchItemData(self);
		return;
	end;
	
	local playerEyePos = Clockwork.Client:EyePos();
	local player = self:GetPlayer();
	local eyePos = EyePos();
	
	if (IsValid(player)) then
		local isPlayer = player:IsPlayer();
		
		if ((eyePos:Distance(playerEyePos) > 32 or GetViewEntity() != Clockwork.Client
		or Clockwork.Client != player or !isPlayer) and (!isPlayer or player:Alive())) then
			self:SetNoDraw(false);
		else
			self:SetNoDraw(true);
		end;
	end;
end;

-- Called when the entity should draw.
function ENT:Draw()
	if (!Clockwork.entity:HasFetchedItemData(self)) then
		return;
	end;

	local playerEyePos = Clockwork.Client:EyePos();
	local colorTable = self:GetColor();
	local itemTable = Clockwork.entity:FetchItemTable(self);
	local modelScale = itemTable("attachmentModelScale", Vector(1, 1, 1));
	local bDrawModel = false;
	local eyePos = EyePos();
	local player = self:GetPlayer();
	
	if (IsValid(player) and (player:GetMoveType() == MOVETYPE_WALK
	or player:IsRagdolled() or player:InVehicle())) then
		local position, angles = self:GetRealPosition();
		local isPlayer = player:IsPlayer();
		
		if (position and angles) then
			self:SetPos(position); self:SetAngles(angles);
		end;
		
		if (itemTable.GetAttachmentModelScale) then
			modelScale = itemTable:GetAttachmentModelScale(player, self) or modelScale;
		end;
		
		if ((eyePos:Distance(playerEyePos) > 32 or GetViewEntity() != Clockwork.Client
		or Clockwork.Client != player or !isPlayer) and (!isPlayer or player:Alive()) and colorTable.a > 0) then
			bDrawModel = true;
		end;
	end;

	if (modelScale) then
		local entityMatrix = Matrix();
			entityMatrix:Scale(modelScale);
		self:EnableMatrix("RenderMultiply", entityMatrix);
	end;
	
	if (bDrawModel and Clockwork.plugin:Call("GearEntityDraw", self) != false) then
		self:DrawModel();
	end;
end;