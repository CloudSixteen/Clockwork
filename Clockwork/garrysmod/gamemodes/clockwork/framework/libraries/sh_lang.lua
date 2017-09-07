--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

--[[
	@codebase Shared
	@details Provides an interface for the language system.
	@field stored A table containing a list of stored languages.
--]]
Clockwork.lang = Clockwork.kernel:NewLibrary("Lang");
Clockwork.lang.stored = Clockwork.lang.stored or {};
Clockwork.lang.default = "English";

CW_LANGUAGE_CLASS = {__index = CW_LANGUAGE_CLASS};

--[[
	@codebase Shared
	@details Get the language table for the given language (or create if it doesn't exist.)
	@param {String} The language to get the table for.
	@returns {String} The language table for the given language.
--]]
function Clockwork.lang:GetTable(name)
	if (!Clockwork.lang.stored[name]) then
		Clockwork.lang.stored[name] = Clockwork.kernel:NewMetaTable(CW_LANGUAGE_CLASS);
	end;
	
	return Clockwork.lang.stored[name];
end;

--[[
	@codebase Shared
	@details Get the table of all the languages.
	@returns {String} The table containing all the languages.
--]]
function Clockwork.lang:GetAll()
	return self.stored;
end;

--[[
	@codebase Shared
	@details Get the language string for the given identifier.
	@param {String} The language which table to search.
	@param {String} The identifier to search for.
	@param {Mixed} A list of subs to replace in the string.
	@returns {String} The final string for the given identifier.
--]]
function Clockwork.lang:GetString(language, identifier, ...)
	local subs = {...};
	local output = nil;
	
	if (!language) then
		language = self.default;
	end;
	
	if (self.stored[language]) then
		output = self.stored[language][identifier];
	end;
	
	if (!output) then
		output = self.stored[self.default][identifier] or identifier;
	end;
	
	if (type(subs[1]) == "function") then
		local process = subs[1];
		
		output = process(output);
		
		table.remove(subs, 1);
	end;
	
	if (type(output) == "table") then
		for k, v in ipairs(output) do
			if (type(v) == "string") then
				output[k] = self:ReplaceSubs(language, v, subs);
			end;
		end;
		
		return output;
	else
		return self:ReplaceSubs(language, output, subs);
	end;
end;

function Clockwork.lang:ReplaceSubs(language, input, subs)
	for child in string.gmatch(input, "%{(.-)%}") do
		input = string.gsub(input, "{"..child.."}", self:GetString(language, child));
	end;
	
	for child in string.gmatch(input, "%~(.-)%~") do
		input = string.gsub(input, "~"..child.."~", string.lower(self:GetString(language, child)));
	end;
	
	for k, v in ipairs(subs) do
		if (istable(v)) then
			input = string.gsub(input, "#"..k, T(v), 1);
		else
			input = string.gsub(input, "#"..k, tostring(v), 1);
		end;
	end;
	
	return input;
end;

if (CLIENT) then
	function L(identifier, ...)
		if (type(identifier) == "table") then
			return L(unpack(data));
		end;
		
		local language = CW_CONVAR_LANG:GetString();
		
		return Clockwork.lang:GetString(language, identifier, ...);
	end;
	
	function T(data)
		if (type(data) == "table") then
			return L(unpack(data));
		else
			return L(data);
		end;
	end;
else
	function L(player, identifier, ...)
		if (player != nil) then
			local language = player:GetInfo("cwLang");
			
			return Clockwork.lang:GetString(language, identifier, ...);
		else
			return Clockwork.lang:GetString(nil, identifier, ...);
		end;
	end;
	
	function T(player, data)
		if (type(player) == "table") then
			return L(nil, unpack(player));
		elseif (type(player) == "string") then
			return L(nil, player);
		elseif (type(data) == "table") then
			return L(player, unpack(data));
		else
			return L(data);
		end;
	end;
end;