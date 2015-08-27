--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local IsValid = IsValid;
local pairs = pairs;
local pcall = pcall;
local string = string;
local table = table;
local game = game;

-- A function to retrieve the file directory from a string.
local function SplitDirectory(directory)
	local explodedDirectory = string.Explode("/", directory);
	local splitDirectory = nil;

	explodedDirectory[#explodedDirectory] = nil;
	splitDirectory = table.concat(explodedDirectory, "/");

	return splitDirectory;
end;

--[[
	Fix for file.IsDir not working in LUA for folders that aren't in lua/*.
		http://facepunch.com/showthread.php?t=1213957
--]]
local ClockworkFileIsDir = file.IsDir;
function file.IsDir(directory, path)
	if (ClockworkFileIsDir(directory, path) or !string.GetExtensionFromFilename(directory)) then
		return true;
	end;
end;

--[[
	Fix for file.Find returning both files and folders in the first return.
		http://facepunch.com/showthread.php?t=1213505
--]]
local ClockworkFileFind = file.Find;
function file.Find(directory, path, orderBy)
	if (!directory or !path) then return {}, {}; end;

	local files, folders = ClockworkFileFind(
		directory, path, orderBy
	);
	local filesTable = {};
	local foldersTable = {};

	if ((path == "LUA" or path == "lsv")
	and (orderBy == "namedesc" or !orderBy)) then
		local rawDirectory = SplitDirectory(directory);

		for k, v in pairs (files) do
			local filePath = rawDirectory.."/"..v;

			if (file.IsDir(filePath, path)) then
				if (!table.HasValue(foldersTable, v)) then
					foldersTable[#foldersTable + 1] = v;
				end;
			else
				if (!table.HasValue(filesTable, v)) then
					filesTable[#filesTable + 1] = v;
				end;
			end;
		end;

		for k, v in pairs (folders) do
			local filePath = rawDirectory.."/"..v;

			if (file.IsDir(filePath, path)) then
				if (!table.HasValue(foldersTable, v)) then
					foldersTable[#foldersTable + 1] = v;
				end;
			else
				if (!table.HasValue(filesTable, v)) then
					filesTable[#filesTable + 1] = v;
				end;
			end;
		end;
	else
		filesTable, foldersTable = files, folders;
	end;

	return filesTable, foldersTable;
end;

--[[
	Fix for file.Exists not working in LUA.
--]]
local ClockworkFileExists = file.Exists;
function file.Exists(filePath, searchPath)
	if (ClockworkFileExists(filePath, searchPath)) then
		return true;
	else
		local files, folders = file.Find(filePath, searchPath);

		if (files and #files > 0) then
			return true;
		end;
	end;

	return false;
end;

--[[
	Fix for IsValid issue.
--]]
local ClockworkIsValid = IsValid;
function IsValid(object)
	if (!object) then
		return false;
	end;

	local bSuccess, value = pcall(ClockworkIsValid, object);

	if (!bSuccess) then
		return false;
	end;

	return value;
end;
