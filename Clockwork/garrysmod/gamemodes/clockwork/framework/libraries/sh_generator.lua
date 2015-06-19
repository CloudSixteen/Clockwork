--[[
	� 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local string = string;

Clockwork.generator = Clockwork.kernel:NewLibrary("Generator");
Clockwork.generator.stored = Clockwork.generator.stored or {};

-- A function to register a new generator.
function Clockwork.generator:Register(name, power, health, maximum, cash, uniqueID, powerName, powerPlural)
	self.stored[uniqueID] = {
		powerPlural = powerPlural or powerName or "Power",
		powerName = powerName or "Power",
		uniqueID = uniqueID,
		maximum = maximum or 5,
		health = health or 100,
		power = power or 2,
		cash = cash or 100,
		name = name
	};
end;

-- A function to get all generators.
function Clockwork.generator:GetAll()
	return self.stored;
end;

-- A function to find a generator by an identifier.
function Clockwork.generator:FindByID(identifier)
	if (!self.stored[identifier]) then
		local tGeneratorTab = nil;
		
		for k, v in pairs(self.stored) do
			if (string.find(string.lower(v.name), string.lower(identifier))) then
				if (!tGeneratorTab or string.utf8len(v.name) < string.utf8len(tGeneratorTab.name)) then
					tGeneratorTab = v;
				end;
			end;
		end;
		
		return tGeneratorTab;
	else
		return self.stored[identifier];
	end;
end;