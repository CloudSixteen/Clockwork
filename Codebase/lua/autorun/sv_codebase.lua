--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

local FILE_MANIFEST = nil;
local OUTPUT_TABLE = nil;

local function AddFilesToManifest(directory)
	local files, folders = file.Find(directory.."/*", "GAME");
	
	for k, v in pairs(files) do
		if (v != ".." and v != ".") then
			FILE_MANIFEST[#FILE_MANIFEST + 1] = directory.."/"..v
		end;
	end;
	
	for k, v in pairs(folders) do
		if (v != ".." and v != ".") then
			AddFilesToManifest(directory.."/"..v);
		end;
	end;
end;

local function ProcessFile(fileName)
	local fileData = file.Read(fileName, "GAME");
	local fileLines = string.Explode("\n", fileData);
	local bInComment = false;
	local codebase = nil;
	local counter = {classes = 0, libraries = 0, functions = 0, hooks = 0};
	
	for k, v in ipairs(fileLines) do
		if (string.find(v, "%-%-%[%[")) then
			bInComment = true;
		end;
		
		if (bInComment and !codebase) then
			local scriptState = string.match(v, "@codebase%s([a-zA-Z0-9]+)");
			
			if (scriptState) then
				codebase = {
					scriptState = scriptState,
					details = ""
				};
			end;
		end;
		
		if (codebase) then
			local name = string.match(v, "@name%s(.+)");
			local class = string.match(v, "@class%s(.+)");
			local details = string.match(v, "@details%s(.+)");
			local fieldName, fieldNote = string.match(v, "@field%s([a-zA-Z0-9]+)%s(.+)");
			local paramType, paramNote = string.match(v, "@param%s([a-zA-Z0-9]+)%s(.+)");
			local returnType, returnNote = string.match(v, "@returns%s([a-zA-Z0-9]+)%s(.+)");
			local optionType, optionNote = string.match(v, "@option%s([a-zA-Z0-9]+)%s(.+)");
			local bIsValidField = false;
			
			if (details) then
				codebase.details = details;
				bIsValidField = true;
			end;
			
			if (fieldName and fieldNote) then
				if (!codebase.fields) then codebase.fields = {}; end;
				
				codebase.fields[#codebase.fields + 1] = {
					name = fieldName,
					note = fieldNote
				};
				
				bIsValidField = true;
			end;
			
			if (optionType and optionNote) then
				if (!codebase.params) then codebase.params = {}; end;
				if (string.find(optionType, ":")) then
					optionType = string.Explode(optionType, ":");
				end;
				
				codebase.params[#codebase.params + 1] = {
					varType = optionType,
					note = optionNote
				};
				
				bIsValidField = true;
			end;
			
			if (paramType and paramNote) then
				if (!codebase.params) then codebase.params = {}; end;
				if (string.find(optionType, ":")) then
					paramType = string.Explode(paramType, ":");
				end;
				
				codebase.params[#codebase.params + 1] = {
					varType = paramType,
					note = paramNote
				};
				
				bIsValidField = true;
			end;
			
			if (returnType and returnNote) then
				if (!codebase.returns) then codebase.returns = {}; end;
				
				codebase.returns[#codebase.returns + 1] = {
					varType = returnType,
					note = returnNote
				};
				
				bIsValidField = true;
			end;
			
			if (!bInComment) then
				local funcName, paramString = string.match(v, "function%s(.+)%((.+)%)");
				local className = string.match(v, "(.-)%s?=%s?{");
				local libName, niceName = string.match(v, "(.+)%s=%sClockwork.kernel:NewLibrary%(\"(.+)\"%)");
				
				if (funcName and paramString) then
					local startPoint = string.find(funcName, ":");
					local syntax = ":";
					
					if (!startPoint) then
						startPoint = string.find(funcName, "%.");
						syntax = ".";
						
						while (true) do
							local nextPoint = string.find(funcName, "%.", startPoint);
							if (nextPoint) then
								startPoint = nextPoint;
							else
								break;
							end;
						end;
					end;
					
					if (startPoint) then
						local niceName = string.sub(funcName, startPoint + 1);
						local libName = string.sub(funcName, 1, startPoint - 1);
						
						codebase.niceName = niceName;
						codebase.funcName = funcName;
						codebase.libName = libName;
						codebase.objType = "function";
						codebase.syntax = syntax;
						codebase.params = codebase.params or {};
						codebase.class = class;
						
						if (codebase.class) then
							codebase.funcName = codebase.class..codebase.syntax..codebase.niceName;
						end;
						
						for k2, v2 in ipairs(string.Explode(",", paramString)) do
							local paramName = string.Trim(v2);
							
							if (codebase.params[k2]) then
								codebase.params[k2].name = paramName;
							elseif (v2 == "...") then
								codebase.params[k2] = {
									varType = "Optional",
									name = "...",
									note = "Various other optional parameters."
								};
							end;
						end
						
						if (codebase.libName == "Clockwork" and syntax == ":") then
							OUTPUT_TABLE["hooks"][niceName] = codebase;
							counter.hooks = counter.hooks + 1;
						else
							OUTPUT_TABLE["functions"][libName] = OUTPUT_TABLE["functions"][libName] or {};
							OUTPUT_TABLE["functions"][libName][niceName] = codebase;
							counter.functions = counter.functions + 1;
						end;
					end;
					
					bIsValidField = true;
				elseif (libName and niceName) then
					codebase.niceName = niceName;
					codebase.libName = libName;
					codebase.objType = "library";
					OUTPUT_TABLE["libraries"][libName] = codebase;
					counter.libraries = counter.libraries + 1;
					
					bIsValidField = true;
				elseif (className) then
					codebase.niceName = name or string.Trim(className);
					codebase.objType = "class";
					OUTPUT_TABLE["classes"][codebase.niceName] = codebase;
					counter.classes = counter.classes + 1;
					
					bIsValidField = true;
				end;
				
				codebase = nil;
			end;
			
			if (string.find(v, "%-%-%]%]")) then
				bInComment = false;
			elseif (!bIsValidField) then
				if (!codebase.details) then
					codebase.details = "";
				end;
				
				codebase.details = codebase.details.."\n"..string.Trim(v)
			end;
		end;
	end;
	
	local countTab = {};
	
	if (counter.classes > 0) then
		table.insert(countTab, counter.classes.." class(es)");
	end;
	
	if (counter.functions > 0) then
		table.insert(countTab, counter.functions.." function(s)");
	end;
	
	if (counter.libraries > 0) then
		table.insert(countTab, counter.libraries.." lib(s)");
	end;
	
	if (counter.hooks > 0) then
		table.insert(countTab, counter.hooks.." hook(s)");
	end;
	
	local countString = table.concat(countTab, ", ");
	
	if (countString != "") then
		MsgC(Color(150, 225, 150), "@codebase "..(string.gsub(fileName, "gamemodes/Clockwork/framework/", "")).."\n");
		MsgC(Color(150, 150, 150), "\t"..countString.."\n");
	end;
end;

concommand.Add("codebase", function(player, command, arguments)
	FILE_MANIFEST = {};
	OUTPUT_TABLE = {functions = {}, classes = {}, libraries = {}, hooks = {}};

	AddFilesToManifest("gamemodes/Clockwork/framework");

	local delay = 0;
	for k, v in ipairs(FILE_MANIFEST) do
		timer.Simple(delay, ProcessFile, v);
		delay = delay + 0.005;
	end;

	if (delay > 0) then
		timer.Simple(delay, function()
			file.Write("codebase.txt", Clockwork.json:Encode(OUTPUT_TABLE));
			MsgC(Color(255, 128, 128), "@codebase has saved the generated JSON to data/codebase.txt\n");
		end);
	end;
end);