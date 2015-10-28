--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
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

-- A function to add some flags.
function Clockwork.bitFlags:Add(field, ...)
	local flags = {...};

	for k, v in ipairs(flags) do
		field = bit.bor(field, 2 ^ (v - 1));
	end;

	return field;
end;

-- A function to remove some flags.
function Clockwork.bitFlags:Remove(field, ...)
	local flags = {...};

	for k, v in ipairs(flags) do
		field = bit.band(field, bit.bnot(2 ^ (v - 1)));
	end;

	return field;
end;

-- A function to check if some flags are set.
function Clockwork.bitFlags:Has(field, ...)
	local flags = {...};

	for k, v in ipairs(flags) do
		if (bit.band(field, 2 ^ (v - 1)) == 0) then
			return false;
		end;
	end;

	return true;
end;

-- A function to check if any flags are set.
function Clockwork.bitFlags:HasAny(field, ...)
	local flags = {...};

	for k, v in ipairs(flags) do
		if (bit.band(field, 2 ^ (v - 1)) != 0) then
			return true;
		end;
	end;

	return false;
end;

-- A function to combine some flags.
function Clockwork.bitFlags:Combine(...)
	return self:Add(0, ...);
end;

-- A function to define some bit flags.
function Clockwork.bitFlags:Define(name, flagsTable)
	self.stored[name] = flagsTable;

	for k, v in pairs(flagsTable) do
		_G[k] = v;
	end;
end;
