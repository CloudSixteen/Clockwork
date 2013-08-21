--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

local Clockwork = Clockwork;
local tostring = tostring;
local pairs = pairs;
local string = string;

Clockwork.lang = Clockwork.kernel:NewLibrary("Lang");
Clockwork.lang.stored = {};
Clockwork.lang.default = {};

--[[
	A list of language names below:
		english.xml
		french.xml
		german.xml
		korean.xml
		russian.xml
	
	You can create your own language files and
	e-mail them to kurozael@gmail.com or post them
	on the Cloud Sixteen forums.
--]]

--[[
	A function to find a language string.
	You can also use CL(identifier, ...)
--]]
function Clockwork.lang:Find(identifier, ...)
	local langString = self.stored[identifier] or self.default[identifier];
	local arguments = {...};
	
	for k, v in pairs(arguments) do
		langString = string.gsub(langString, "#"..k, tostring(v), 1);
	end;
	
	return langString;
end;

function CL(identifier, ...)
	return Clockwork.lang:Find(identifier, ...);
end;

--[[ Server-side only code beyond this point. --]]
if (not SERVER) then return; end;

--[[
	A function to add a language file to the collection.
	This will load an XML file and add it to the language table.
--]]
function Clockwork.lang:Add(language, fileName) end;

-- A function to set the active language.
function Clockwork.lang:Set(language) end;