--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local tonumber = tonumber;
local IsValid = IsValid;
local pairs = pairs;
local type = type;
local string = string;
local util = util;
local os = os;

Clockwork.tool = Clockwork.kernel:NewLibrary("Tool");
Clockwork.tool.stored = Clockwork.tool.stored or {};

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {__index = CLASS_TABLE};

function CLASS_TABLE:CreateConVars()
	local mode = self:GetMode()

	if (CLIENT) then	
		for cvar, default in pairs(self.ClientConVar) do		
			CreateClientConVar(mode.."_"..cvar, default, true, true);			
		end;
	else
		self.AllowedCVar = CreateConVar("toolmode_allow_"..mode, 1, FCVAR_NOTIFY);
	end;
end;

function CLASS_TABLE:GetServerInfo(property)
	local mode = self:GetMode();
	
	return GetConVarString(mode.."_"..property);	
end;

function CLASS_TABLE:BuildConVarList()
	local mode = self:GetMode();
	local convars = {};

	for k, v in pairs(self.ClientConVar) do
		convars[mode .. "_" .. k] = v;
	end;

	return convars;
end;

function CLASS_TABLE:GetClientInfo(property)
	local mode = self:GetMode();
	
	return self:GetOwner():GetInfo(mode.."_"..property);
end;

function CLASS_TABLE:GetClientNumber(property, default)
	default = default or 0;
	
	local mode = self:GetMode();
	
	return self:GetOwner():GetInfoNum(mode.."_"..property, default);
end;

function CLASS_TABLE:Allowed()
	if (CLIENT) then
		return true;
	end;
	
	return self.AllowedCVar:GetBool();
end;

function CLASS_TABLE:Init()
end;

function CLASS_TABLE:GetMode()
	return self.Mode;
end;

function CLASS_TABLE:GetSWEP()
	return self.SWEP;
end;

function CLASS_TABLE:GetOwner()
	return self:GetSWEP().Owner or self.Owner;
end;

function CLASS_TABLE:GetWeapon()
	return self:GetSWEP().Weapon or self.Weapon;
end;

function CLASS_TABLE:LeftClick()
	return false;
end;

function CLASS_TABLE:RightClick()
	return false;
end;

function CLASS_TABLE:Reload()
	self:ClearObjects();
end;

function CLASS_TABLE:Deploy()
	self:ReleaseGhostEntity();
end;

function CLASS_TABLE:Holster()
	self:ReleaseGhostEntity();
end;

function CLASS_TABLE:Think()
	self:ReleaseGhostEntity();
end;

function CLASS_TABLE:CheckObjects()
	for k, v in pairs(self.Objects) do			
		if (!v.Ent:IsWorld() && !v.Ent:IsValid()) then
			self:ClearObjects();
		end;				
	end;
end;

function CLASS_TABLE:UpdateData()	
	self:SetStage(self:NumObjects());
end;

function CLASS_TABLE:SetStage(i)
	if (SERVER) then
		self:GetWeapon():SetNWInt("Stage", i, true);
	end;
end;

function CLASS_TABLE:GetStage()
	return self:GetWeapon():GetNWInt("Stage", 0);
end;

function CLASS_TABLE:GetOperation()
	return self:GetWeapon():GetNWInt("Op", 0);
end;

function CLASS_TABLE:SetOperation(i)
	if (SERVER) then
		self:GetWeapon():SetNWInt("Op", i, true);
	end;
end;

function CLASS_TABLE:ClearObjects()
	self:ReleaseGhostEntity();
	self.Objects = {};
	self:SetStage(0);
	self:SetOperation(0);
end

function CLASS_TABLE:GetEnt(i)
	if (!self.Objects[i]) then
		return NULL;
	end;
	
	return self.Objects[i].Ent;
end;

function CLASS_TABLE:GetPos(i)
	if (self.Objects[i].Ent:EntIndex() == 0) then
		return self.Objects[i].Pos;
	elseif (self.Objects[i].Phys ~= nil && self.Objects[i].Phys:IsValid()) then
		return self.Objects[i].Phys:LocalToWorld(self.Objects[i].Pos);
	else
		return self.Objects[i].Ent:LocalToWorld(self.Objects[i].Pos);
	end;
end;

function CLASS_TABLE:GetLocalPos(i)
	return self.Objects[i].Pos;
end;

function CLASS_TABLE:GetBone(i)
	return self.Objects[i].Bone;
end;

function CLASS_TABLE:GetNormal(i)
	if (self.Objects[i].Ent:EntIndex() == 0) then
		return self.Objects[i].Normal;
	else
		local norm;
		
		if (self.Objects[i].Phys ~= nil && self.Objects[i].Phys:IsValid()) then
			norm = self.Objects[i].Phys:LocalToWorld(self.Objects[i].Normal);
		else
			norm = self.Objects[i].Ent:LocalToWorld(self.Objects[i].Normal);
		end;
		
		return norm - self:GetPos(i);
	end;
end;

function CLASS_TABLE:GetPhys(i)
	if (self.Objects[i].Phys == nil) then
		return self:GetEnt(i):GetPhysicsObject();
	end;

	return self.Objects[i].Phys;
end;

function CLASS_TABLE:SetObject(i, ent, pos, phys, bone, norm)
	self.Objects[i] = {};
	self.Objects[i].Ent = ent;
	self.Objects[i].Phys = phys;
	self.Objects[i].Bone = bone;
	self.Objects[i].Normal = norm;

	if (ent:EntIndex() == 0) then
		self.Objects[i].Phys = nil;
		self.Objects[i].Pos = pos;
	else
		norm = norm + pos;

		if (IsValid(phys)) then
			self.Objects[i].Normal = self.Objects[i].Phys:WorldToLocal(norm);
			self.Objects[i].Pos = self.Objects[i].Phys:WorldToLocal(pos);
		else
			self.Objects[i].Normal = self.Objects[i].Ent:WorldToLocal(norm);
			self.Objects[i].Pos = self.Objects[i].Ent:WorldToLocal(pos);
		end;
	end;
end;

function CLASS_TABLE:NumObjects()
	if (CLIENT) then
		return self:GetStage();
	end;

	return #self.Objects;
end;

function CLASS_TABLE:GetHelpText()
	return self.HelpText or "#tool." .. GetConVarString("gmod_toolmode") .. "." .. self:GetStage();
end

function CLASS_TABLE:MakeGhostEntity(model, pos, angle)
	util.PrecacheModel(model);

	if (SERVER && !game.SinglePlayer()) then
		return;
	end;
	
	if (CLIENT && game.SinglePlayer()) then
		return;
	end;
	
	self:ReleaseGhostEntity();
		
	if (!util.IsValidProp(model)) then
		return;
	end;
	
	if (CLIENT) then
		self.GhostEntity = ents.CreateClientProp(model);
	else
		self.GhostEntity = ents.Create("prop_physics");
	end;

	if (!self.GhostEntity:IsValid()) then
		self.GhostEntity = nil;
		return;
	end;
	
	self.GhostEntity:SetModel(model);
	self.GhostEntity:SetPos(pos);
	self.GhostEntity:SetAngles(angle);
	self.GhostEntity:Spawn()	;
	self.GhostEntity:SetSolid(SOLID_VPHYSICS);
	self.GhostEntity:SetMoveType(MOVETYPE_NONE);
	self.GhostEntity:SetNotSolid(true);
	self.GhostEntity:SetRenderMode(RENDERMODE_TRANSALPHA);
	self.GhostEntity:SetColor(Color(255, 255, 255, 150));
end

function CLASS_TABLE:StartGhostEntity(ent)
	local class = ent:GetClass();

	if (SERVER && !game.SinglePlayer()) then
		return;
	end;
	
	if (CLIENT && game.SinglePlayer()) then
		return;
	end;
	
	self:MakeGhostEntity(ent:GetModel(), ent:GetPos(), ent:GetAngles());
end;

function CLASS_TABLE:ReleaseGhostEntity()
	if (self.GhostEntity) then
		if (!self.GhostEntity:IsValid()) then
			self.GhostEntity = nil;
			return;
		end;
		
		self.GhostEntity:Remove();
		self.GhostEntity = nil;
	end
		
	if (self.GhostEntities) then
		for k,v in pairs(self.GhostEntities) do
			if (v:IsValid()) then
				v:Remove();
			end;
			
			self.GhostEntities[k] = nil;
		end
			
		self.GhostEntities = nil
	end;
	
	if (self.GhostOffset) then	
		for k,v in pairs(self.GhostOffset) do
			self.GhostOffset[k] = nil;
		end;
	end;
end;

function CLASS_TABLE:UpdateGhostEntity()
	if (self.GhostEntity == nil) then
		return;
	end;
	
	if (!self.GhostEntity:IsValid()) then
		self.GhostEntity = nil;
		return;
	end;
		
	local tr = util.GetPlayerTrace(self:GetOwner());
	local trace = util.TraceLine(tr);
	
	if (!trace.Hit) then
		return;
	end;
	
	local ang1, ang2 = self:GetNormal(1):Angle(), (trace.HitNormal * -1):Angle();
	local targetAngle = self:GetEnt(1):AlignAngles(ang1, ang2);
	
	self.GhostEntity:SetPos(self:GetEnt(1):GetPos());
	self.GhostEntity:SetAngles(targetAngle);
	
	local translatedPos = self.GhostEntity:LocalToWorld(self:GetLocalPos(1));
	local targetPos = trace.HitPos + (self:GetEnt(1):GetPos() - translatedPos) + (trace.HitNormal);
	
	self.GhostEntity:SetPos(targetPos);
end;


if (CLIENT) then
	function CLASS_TABLE:FreezeMovement()
		return false;
	end;

	function CLASS_TABLE:DrawHUD()
	end;
end;

function CLASS_TABLE:Register()
	return Clockwork.tool:Register(self);
end;

function CLASS_TABLE:Create()
	local tool = Clockwork.kernel:NewMetaTable(CLASS_TABLE);

	tool.Mode = nil;
	tool.SWEP = nil;
	tool.Owner = nil;
	tool.Category = "Clockwork";
	tool.ClientConVar = {};
	tool.ServerConVar = {};
	tool.Objects = {};
	tool.Stage = 0;
	tool.Message = "start";
	tool.LastMessage = 0;
	tool.AllowedCVar = 0;
	
	return tool;		
end;

function Clockwork.tool:New()
	return CLASS_TABLE:Create();
end;

function Clockwork.tool:GetAll()
	return self.stored;
end;

function Clockwork.tool:Register(tool)
	if (tool.UniqueID) then
		tool.Mode = tool.UniqueID;
		tool:CreateConVars();

		if (tool.leftClickCMD) then
			if (tool.leftClickFire == nil) then
				tool.leftClickFire = true;
			end;

			function tool:LeftClick(tr)
				if (CLIENT) then
					return tool.leftClickFire;
				end;

				self:GetOwner():RunClockworkCmd(tool.leftClickCMD);
			end;
		end;

		if (tool.rightClickCMD) then
			if (tool.rightClickFire == nil) then
				tool.rightClickFire = true;
			end;

			function tool:RightClick(tr)
				if (CLIENT) then
					return tool.rightClickFire;
				end;

				self:GetOwner():RunClockworkCmd(tool.rightClickCMD);
			end;
		end;

		if (tool.reloadCMD) then
			if (tool.reloadFire == nil) then
				tool.reloadFire = true;
			end;

			function tool:Reload(tr)
				if (CLIENT) then
					return tool.reloadFire;
				end;

				self:GetOwner():RunClockworkCmd(tool.reloadCMD);
			end;
		end;

		self.stored[tool.UniqueID] = tool;
	else
		MsgC(Color(255, 100, 0, 255), "[Clockwork:Tool] The "..tool.Name.." tool does not have a UniqueID, and will not function without one!\n");
	end;
end;