--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local string = string;

Clockwork.attribute = Clockwork.kernel:NewLibrary("Attribute");
Clockwork.attribute.stored = Clockwork.attribute.stored or {};
Clockwork.attribute.buffer = Clockwork.attribute.buffer or {};

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {__index = CLASS_TABLE};

--[[
	@codebase Shared
	@details A function to register a new attribute.
	@returns {Unknown}
--]]
function CLASS_TABLE:Register()
	return Clockwork.attribute:Register(self);
end;

--[[
	@codebase Shared
	@details A function to get a new attribute.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
function Clockwork.attribute:New(name)
	local object = Clockwork.kernel:NewMetaTable(CLASS_TABLE);
		object.name = name or "Unknown";
	return object;
end;

--[[
	@codebase Shared
	@details A function to get the attribute buffer.
	@returns {Unknown}
--]]
function Clockwork.attribute:GetBuffer()
	return self.buffer;
end;

--[[
	@codebase Shared
	@details A function to get all attributes.
	@returns {Unknown}
--]]
function Clockwork.attribute:GetAll()
	return self.stored;
end;

--[[
	@codebase Shared
	@details A function to register a new attribute.
	@param {Unknown} Missing description for attribute.
	@returns {Unknown}
--]]
function Clockwork.attribute:Register(attribute)
	attribute.uniqueID = attribute.uniqueID or string.lower(string.gsub(attribute.name, "%s", "_"));
	attribute.index = Clockwork.kernel:GetShortCRC(attribute.name);
	attribute.image = attribute.image or "clockwork/attributes/default";
	attribute.cache = {};
	
	if (not attribute.category) then
		attribute.category = "Attributes";
	end;
	
	for i = -attribute.maximum, attribute.maximum do
		attribute.cache[i] = {};
	end;
	
	self.stored[attribute.uniqueID] = attribute;
	self.buffer[attribute.index] = attribute;
	
	if (SERVER) then
		Clockwork.kernel:AddFile("materials/"..attribute.image..".png");
	end;
	
	return attribute.uniqueID;
end;

--[[
	@codebase Shared
	@details A function to find an attribute by an identifier.
	@param {Unknown} Missing description for identifier.
	@returns {Unknown}
--]]
function Clockwork.attribute:FindByID(identifier)
	if (!identifier) then return; end;
	
	if (self.buffer[identifier]) then
		return self.buffer[identifier];
	elseif (self.stored[identifier]) then
		return self.stored[identifier];
	end;
	
	local attribute = nil;
	
	for k, v in pairs(self.stored) do
		if (string.find(string.lower(v.name), string.lower(identifier))) then
			if (attribute) then
				if (string.utf8len(v.name) < string.utf8len(attribute.name)) then
					attribute = v;
				end;
			else
				attribute = v;
			end;
		end;
	end;
	
	return attribute;
end;