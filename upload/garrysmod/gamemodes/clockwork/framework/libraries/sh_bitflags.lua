--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.bitFlags = Clockwork.kernel:NewLibrary("BitFlags");
Clockwork.bitFlags.stored = {};

--[[
	These are non-standard bit flags that operate
	consecutively, starting from 1.
--]]

--[[
	@codebase Shared
	@details A function to add some flags.
	@param {Unknown} Missing description for field.
	@param {Unknown} Missing description for ....
	@returns {Unknown}
--]]
function Clockwork.bitFlags:Add(field, ...)
	local flags = {...};

	for k, v in ipairs(flags) do
		field = bit.bor(field, 2 ^ (v - 1));
	end;

	return field;
end;

--[[
	@codebase Shared
	@details A function to remove some flags.
	@param {Unknown} Missing description for field.
	@param {Unknown} Missing description for ....
	@returns {Unknown}
--]]
function Clockwork.bitFlags:Remove(field, ...)
	local flags = {...};

	for k, v in ipairs(flags) do
		field = bit.band(field, bit.bnot(2 ^ (v - 1)));
	end;

	return field;
end;

--[[
	@codebase Shared
	@details A function to check if some flags are set.
	@param {Unknown} Missing description for field.
	@param {Unknown} Missing description for ....
	@returns {Unknown}
--]]
function Clockwork.bitFlags:Has(field, ...)
	local flags = {...};

	for k, v in ipairs(flags) do
		if (bit.band(field, 2 ^ (v - 1)) == 0) then
			return false;
		end;
	end;

	return true;
end;

--[[
	@codebase Shared
	@details A function to check if any flags are set.
	@param {Unknown} Missing description for field.
	@param {Unknown} Missing description for ....
	@returns {Unknown}
--]]
function Clockwork.bitFlags:HasAny(field, ...)
	local flags = {...};

	for k, v in ipairs(flags) do
		if (bit.band(field, 2 ^ (v - 1)) != 0) then
			return true;
		end;
	end;

	return false;
end;

--[[
	@codebase Shared
	@details A function to combine some flags.
	@param {Unknown} Missing description for ....
	@returns {Unknown}
--]]
function Clockwork.bitFlags:Combine(...)
	return self:Add(0, ...);
end;

--[[
	@codebase Shared
	@details A function to define some bit flags.
	@param {Unknown} Missing description for name.
	@param {Unknown} Missing description for flagsTable.
	@returns {Unknown}
--]]
function Clockwork.bitFlags:Define(name, flagsTable)
	self.stored[name] = flagsTable;

	for k, v in pairs(flagsTable) do
		_G[k] = v;
	end;
end;
