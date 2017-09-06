--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local string = string;

Clockwork.trait = Clockwork.kernel:NewLibrary("Trait");
Clockwork.trait.stored = Clockwork.trait.stored or {};
Clockwork.trait.buffer = Clockwork.trait.buffer or {};

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {__index = CLASS_TABLE};

--[[
	@codebase Shared
	@details A function to register a new trait.
	@returns {Unknown}
--]]
function CLASS_TABLE:Register()
	return Clockwork.trait:Register(self);
end;

--[[
	@codebase Shared
	@details A function to get a new trait.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
function Clockwork.trait:New(name)
	local object = Clockwork.kernel:NewMetaTable(CLASS_TABLE);
		object.name = name or "Unknown";
	return object;
end;

--[[
	@codebase Shared
	@details A function to get all traits.
	@returns {Unknown}
--]]
function Clockwork.trait:GetAll()
	return self.stored;
end;

--[[
	@codebase Shared
	@details A function to register a new trait.
	@param {Unknown} Missing description for trait.
	@returns {Unknown}
--]]
function Clockwork.trait:Register(trait)
	trait.uniqueID = trait.uniqueID or string.lower(string.gsub(trait.name, "%s", "_"));
	trait.index = Clockwork.kernel:GetShortCRC(trait.name);
	trait.points = trait.points or 1;
	
	self.stored[trait.uniqueID] = trait;
	self.buffer[trait.index] = trait;
	
	if (SERVER and trait.image) then
		Clockwork.kernel:AddFile("materials/"..trait.image..".png");
	end;
	
	return trait.uniqueID;
end;

--[[
	@codebase Shared
	@details A function to find an trait by an identifier.
	@param {Unknown} Missing description for identifier.
	@returns {Unknown}
--]]
function Clockwork.trait:FindByID(identifier)
	if (!identifier) then return; end;
	
	if (self.buffer[identifier]) then
		return self.buffer[identifier];
	elseif (self.stored[identifier]) then
		return self.stored[identifier];
	end;
	
	local trait = nil;
	
	for k, v in pairs(self.stored) do
		if (string.find(string.lower(v.name), string.lower(identifier))) then
			if (trait) then
				if (string.utf8len(v.name) < string.utf8len(trait.name)) then
					trait = v;
				end;
			else
				trait = v;
			end;
		end;
	end;
	
	return trait;
end;