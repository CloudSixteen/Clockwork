--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local fileio = fileio;

--[[
	@codebase Server
	@details Provides an interface to the file library. 
--]]
Clockwork.file = Clockwork.kernel:NewLibrary("File");

--[[
	@codebase Server
	@details A function to read files.
	@param {String} The file path.
	@returns {String} The contents of the file.
--]]
function Clockwork.file:Read(filePath)
	return fileio.Read(filePath);
end;

--[[
	@codebase Server
	@details A function to write data to a file.
	@param {String} The file path.
	@param {String} The data to write to the file.
--]]
function Clockwork.file:Write(filePath, fileData)
	return fileio.Write(filePath, fileData);
end;

--[[
	@codebase Server
	@details A function to delete a file.
	@param {String} The file path.
--]]
function Clockwork.file:Delete(filePath)
	return fileio.Delete(filePath);
end;

--[[
	@codebase Server
	@details A function to make a directory.
	@param {String} The directory to make.
--]]
function Clockwork.file:MakeDirectory(directory)
	return fileio.MakeDirectory(directory);
end;

--[[
	@codebase Server
	@details A function to append data to a file.
	@param {String} The file path.
	@param {String} The data to write to the file.
--]]
function Clockwork.file:Append(filePath, fileData)
	return fileio.Append(filePath, fileData);
end;

--[[
	@codebase Server
	@details A function to get whether a file exists.
	@param {String} The file path.
--]]
function Clockwork.file:Exists(filePath)
	return file.Exists(filePath, "GAME");
end;