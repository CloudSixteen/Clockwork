--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;
local tostring = tostring;
local pairs = pairs;
local string = string;

Clockwork.lang = Clockwork.kernel:NewLibrary("Lang");
Clockwork.lang.stored = {};
Clockwork.lang.default = {};

-- A function to find a language string.
function Clockwork.lang:Find(identifier, ...)
	--[[ First we'll try the loaded language, then we'll try the default. --]]
	local langString = self.stored[identifier] or self.default[identifier];
	local arguments = {...};
	
	for k, v in pairs(arguments) do
		langString = string.gsub(langString, "#"..k, tostring(v), 1);
	end;
	
	return langString;
end;

-- A function to set the active language.
function Clockwork.lang:Set(language)
	--[[ TODO. LOAD LANGUAGES. --]]
end;