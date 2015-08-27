--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local IsValid = IsValid;

Clockwork.system = Clockwork.kernel:NewLibrary("System");
Clockwork.system.stored = Clockwork.system.stored or {};

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {__index = CLASS_TABLE};

-- A function to register a new system.
function CLASS_TABLE:Register()
	return Clockwork.system:Register(self);
end;

-- A function to get all systems.
function Clockwork.system:GetAll()
	return self.stored;
end;

-- A function to get a new system.
function Clockwork.system:New(name)
	local object = Clockwork.kernel:NewMetaTable(CLASS_TABLE);
		object.name = name or "Unknown";
	return object;
end;

-- A function to get a system by an identifier.
function Clockwork.system:FindByID(identifier)
	return self.stored[identifier];
end;

-- A function to get the system panel.
function Clockwork.system:GetPanel()
	if (IsValid(self.panel)) then
		return self.panel;
	end;
end;

-- A function to rebuild an system.
function Clockwork.system:Rebuild(name)
	local panel = self:GetPanel();
	
	if (panel and self:GetActive() == name) then
		panel:Rebuild();
	end;
end;

-- A function to get the active system.
function Clockwork.system:GetActive()
	local panel = self:GetPanel();
	
	if (panel) then
		return panel.system;
	end;
end;

-- A function to set the active system.
function Clockwork.system:SetActive(name)
	local panel = self:GetPanel();
	
	if (panel) then
		panel.system = name;
		panel:Rebuild();
	end;
end;

-- A function to register a new system.
function Clockwork.system:Register(system)
	self.stored[system.name] = system;
	
	if (!system.HasAccess) then
		system.HasAccess = function(systemTable)
			return Clockwork.player:HasFlags(Clockwork.Client, systemTable.access);
		end;
	end;
	
	-- A function to get whether the system is active.
	system.IsActive = function(systemTable)
		local activeAdmin = self:GetActive();
		
		if (activeAdmin == systemTable.name) then
			return true;
		else
			return false;
		end;
	end;
	
	-- A function to rebuild the system.
	system.Rebuild = function(systemTable)
		self:Rebuild(systemTable.name);
	end;
end;