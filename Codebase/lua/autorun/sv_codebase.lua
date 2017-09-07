--[[
	© 2017 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

Codebase = {};
Codebase.fileManifest = nil;
Codebase.outputTable = nil;

function Codebase.AddFilesToManifest(directory)
	local files, folders = file.Find(directory.."/*", "GAME");
	
	for k, v in pairs(files) do
		if (v != ".." and v != ".") then
			Codebase.fileManifest[#Codebase.fileManifest + 1] = directory.."/"..v
		end;
	end;
	
	for k, v in pairs(folders) do
		if (v != ".." and v != ".") then
			Codebase.AddFilesToManifest(directory.."/"..v);
		end;
	end;
end;

function Codebase.ProcessFile(fileName)
	local fileData = file.Read(fileName, "GAME");
	local fileLines = string.Explode("\n", fileData);
	local isInComment = false;
	local codebase = nil;
	local counter = {classes = 0, libraries = 0, functions = 0, hooks = 0};

	Codebase.outputTable[fileName] = {functions = {}, classes = {}, libraries = {}, hooks = {}};
	
	for k, v in ipairs(fileLines) do
		if (string.find(v, "%-%-%[%[")) then
			isInComment = true;
		end;
		
		if (isInComment and !codebase) then
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
			local paramType, paramNote = string.match(v, "@param%s([%{%}a-zA-Z0-9]+)%s*(.*)");
			local returnType, returnNote = string.match(v, "@returns%s([%{%}a-zA-Z0-9]+)%s*(.*)");
			local optionType, optionNote = string.match(v, "@option%s([a-zA-Z0-9]+)%s*(.*)");
			local isValidField = false;
			
			if (details) then
				codebase.details = details;
				isValidField = true;
			end;
			
			if (fieldName and fieldNote) then
				if (!codebase.fields) then codebase.fields = {}; end;
				
				codebase.fields[#codebase.fields + 1] = {
					name = fieldName,
					note = fieldNote
				};
				
				isValidField = true;
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
				
				isValidField = true;
			end;
			
			if (paramType) then
				if (!codebase.params) then codebase.params = {}; end;
				
				paramType = string.gsub(paramType, "{", "");
				paramType = string.gsub(paramType, "}", "");
				
				if (string.find(paramType, ":")) then
					paramType = string.Explode(paramType, ":");
				end;
				
				codebase.params[#codebase.params + 1] = {
					varType = paramType,
					note = paramNote or ""
				};
				
				isValidField = true;
			end;
			
			if (returnType) then
				if (!codebase.returns) then codebase.returns = {}; end;
				
				returnType = string.gsub(returnType, "{", "");
				returnType = string.gsub(returnType, "}", "");
				
				if (string.find(returnType, ":")) then
					returnType = string.Explode(returnType, ":");
				end;
				
				codebase.returns[#codebase.returns + 1] = {
					varType = returnType,
					note = returnNote or ""
				};
				
				isValidField = true;
			end;
			
			if (!isInComment) then
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
							if (!GAMEMODE.BaseClass.BaseClass[niceName]) then
								Codebase.outputTable[fileName]["hooks"][niceName] = codebase;
								counter.hooks = counter.hooks + 1;
							end;
						else
							Codebase.outputTable[fileName]["functions"][libName] = Codebase.outputTable[fileName]["functions"][libName] or {};
							Codebase.outputTable[fileName]["functions"][libName][niceName] = codebase;
							counter.functions = counter.functions + 1;
						end;
					end;
					
					isValidField = true;
				elseif (libName and niceName) then
					codebase.niceName = niceName;
					codebase.libName = libName;
					codebase.objType = "library";
					Codebase.outputTable[fileName]["libraries"][libName] = codebase;
					counter.libraries = counter.libraries + 1;
					
					isValidField = true;
				elseif (className) then
					codebase.niceName = name or string.Trim(className);
					codebase.objType = "class";
					Codebase.outputTable[fileName]["classes"][codebase.niceName] = codebase;
					counter.classes = counter.classes + 1;
					
					isValidField = true;
				end;
				
				codebase = nil;
			end;
			
			if (string.find(v, "%-%-%]%]")) then
				isInComment = false;
			elseif (!isValidField and codebase) then
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
		MsgC(Color(150, 225, 150), "@codebase "..(string.gsub(fileName, "gamemodes/clockwork/framework/", "")).."\n");
		MsgC(Color(150, 150, 150), "\t"..countString.."\n");
	else
		Codebase.outputTable[fileName] = nil;
		table.insert(Codebase.outputTable["empty_files.lua"], fileName);
		MsgC(Color(255, 128, 128), "@codebase "..(string.gsub(fileName, "gamemodes/clockwork/framework/", "")).."\n");
	end;
end;

concommand.Add("codebase", function(player, command, arguments)
	Codebase.fileManifest = {};
	Codebase.outputTable = {};
	Codebase.outputTable["empty_files.lua"] = {};
	
	Codebase.AddFilesToManifest("gamemodes/clockwork/framework");

	local delay = 0;
	for k, v in ipairs(Codebase.fileManifest) do
		if (delay > 0) then
			timer.Simple(delay, function()
				Codebase.ProcessFile(v);
			end);
		else
			Codebase.ProcessFile(v);
		end;

		delay = delay + 0.005;
	end;
	
	if (delay > 0) then
		timer.Simple(delay, function()
			--[[
			for k, v in pairs(Codebase.outputTable) do
				local saveName = string.gsub(k, "gamemodes/clockwork/", "");
				
				saveName = "codebase/"..string.gsub(saveName, ".lua", ".txt");
				
				local dirString = "";
				local explodeTable = string.Explode("/", saveName);

				for k, v in ipairs(explodeTable) do
					if (k != #explodeTable) then
						dirString = dirString..v.."/";
						
						Clockwork.file:MakeDirectory(dirString);
					end;	
				end;
				
				Clockwork.file:Write(saveName, Clockwork.json:Encode(v));
				
				MsgC(Color(255, 200, 0), "@codebase has saved the generated JSON to data/"..saveName.."\n");
			end;
			--]]
			
			local mergedOutput = {};
			
			for k, v in pairs(Codebase.outputTable) do
				table.Merge(mergedOutput, v);
			end;
			
			Clockwork.file:Write("codebase/generated.json", Clockwork.json:Encode(mergedOutput));
			MsgC(Color(255, 200, 0), "@codebase has saved the generated JSON to codebase/generated.json\n");
		end);
	end;
end);