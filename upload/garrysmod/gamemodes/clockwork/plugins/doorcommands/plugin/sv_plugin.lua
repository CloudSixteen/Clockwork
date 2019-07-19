--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local tostring = tostring;
local IsValid = IsValid;
local pairs = pairs;
local game = game;

local cwEntity = Clockwork.entity;
local cwKernel = Clockwork.kernel;
local cwConfig = Clockwork.config;

local IsDoorLocked = cwEntity.IsDoorLocked;
local GetDoorState = cwEntity.GetDoorState;

cwConfig:Add("default_doors_hidden", true, nil, nil, nil, nil, true);
cwConfig:Add("doors_save_state", true, nil, nil, nil, nil, true);

-- A function to load the parent data.
function cwDoorCmds:LoadParentData()
	self.parentData = self.parentData or {};
	
	local parentData = cwKernel:RestoreSchemaData("plugins/parents/"..game.GetMap());
	local positions = {};
	
	for k, v in pairs(cwEntity:GetDoorEntities()) do
		if (IsValid(v)) then
			local position = v:GetPos();
			
			if (position) then
				positions[tostring(position)] = v;
			end;
		end;
	end;
	
	for k, v in pairs(parentData) do
		local parent = positions[tostring(v.parentPosition)];
		local entity = positions[tostring(v.position)];
		
		if (IsValid(entity) and IsValid(parent) and !self.parentData[entity]) then
			if (cwEntity:IsDoor(entity) and cwEntity:IsDoor(parent)) then
				cwEntity:SetDoorParent(entity, parent);
				
				self.parentData[entity] = parent;
			end;
		end;
	end;
end;

-- A function to load the door data.
function cwDoorCmds:LoadDoorData()
	self.doorData = self.doorData or {};
	
	local positions = {};
	local doorData = cwKernel:RestoreSchemaData("plugins/doors/"..game.GetMap());
	
	for k, v in pairs(cwEntity:GetDoorEntities()) do
		if (IsValid(v)) then
			local position = v:GetPos();
			
			if (position) then
				positions[tostring(position)] = v;
			end;
		end;
	end;
	
	for k, v in pairs(doorData) do
		local entity = positions[tostring(v.position)];
		
		if (IsValid(entity) and !self.doorData[entity]) then
			if (cwEntity:IsDoor(entity)) then
				local data = {
					customName = v.customName,
					position = v.position,
					entity = entity,
					name = v.name,
					text = v.text
				};
				
				if (!data.customName) then
					cwEntity:SetDoorUnownable(data.entity, true);
					cwEntity:SetDoorName(data.entity, data.name);
					cwEntity:SetDoorText(data.entity, data.text);
				else
					cwEntity:SetDoorName(data.entity, data.name);
				end;
				
				self.doorData[data.entity] = data;
			end;
		end;
	end;
	
	if (cwConfig:Get("default_doors_hidden"):Get()) then
		for k, v in pairs(positions) do
			if (!self.doorData[v]) then
				cwEntity:SetDoorHidden(v, true);
			end;
		end;
	end;
end;

-- A function to save the parent data.
function cwDoorCmds:SaveParentData()
	local parentData = {};
	
	for k, v in pairs(self.parentData) do
		if (IsValid(k) and IsValid(v)) then
			parentData[#parentData + 1] = {
				parentPosition = v:GetPos(),
				position = k:GetPos()
			};
		end;
	end;
	
	cwKernel:SaveSchemaData("plugins/parents/"..game.GetMap(), parentData);
end;

-- A function to save the door data.
function cwDoorCmds:SaveDoorData()
	local doorData = {};
	
	for k, v in pairs(self.doorData) do
		local data = {
			customName = v.customName,
			position = v.position,
			name = v.name,
			text = v.text
		};
		
		doorData[#doorData + 1] = data;
	end;
	
	cwKernel:SaveSchemaData("plugins/doors/"..game.GetMap(), doorData);
end;

function cwDoorCmds:SaveDoorStates()
	local doorTable = {};

	for k, v in pairs(cwEntity:GetDoorEntities()) do
		if (v:IsValid()) then
			doorTable[#doorTable + 1] = {
				position = v:GetPos(),
				bLocked = IsDoorLocked(cwEntity, v),
				state = GetDoorState(cwEntity, v)
			};
		end;
	end;

	cwKernel:SaveSchemaData("plugins/doorstates/"..game.GetMap(), doorTable);
end;

function cwDoorCmds:LoadDoorStates()
	local doorTable = cwKernel:RestoreSchemaData("plugins/doorstates/"..game.GetMap());
	local positions = {};

	for k, v in pairs(cwEntity:GetDoorEntities()) do
		if (IsValid(v)) then
			local position = v:GetPos();
			
			if (position) then
				positions[tostring(position)] = v;
			end;
		end;
	end;
	
	for k, v in pairs(doorTable) do
		local entity = positions[tostring(v.position)];

		if (IsValid(entity) and cwEntity:IsDoor(entity)) then

			if (v.state == 1 or v.state == 2) then
				cwEntity:OpenDoor(entity, 0);
			end;

			if (v.bLocked) then
				entity:Fire("Lock", "", 0);
			end;
		end;
	end;
end;