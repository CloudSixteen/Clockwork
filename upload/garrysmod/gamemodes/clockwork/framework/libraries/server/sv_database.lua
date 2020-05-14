--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.database = Clockwork.kernel:NewLibrary("Database");

--[[
	@codebase Server
	@details A function to begin a database update.
	@returns {Unknown}
--]]
function Clockwork.database:Update(tableName) end;

--[[
	@codebase Server
	@details A function to begin a database insert.
	@returns {Unknown}
--]]
function Clockwork.database:Insert(tableName) end;

--[[
	@codebase Server
	@details A function to begin a database select.
	@returns {Unknown}
--]]
function Clockwork.database:Select(tableName) end;

--[[
	@codebase Server
	@details A function to begin a database delete.
	@returns {Unknown}
--]]
function Clockwork.database:Delete(tableName) end;

--[[
	@codebase Server
	@details Called when a MySQL error occurs.
	@returns {Unknown}
--]]
function Clockwork.database:Error(errText) end;

--[[
	@codebase Server
	@details A function to query the database.
	@returns {Unknown}
--]]
function Clockwork.database:Query(query, Callback, flag, bRawQuery) end;

--[[
	@codebase Server
	@details A function to get whether a result is valid.
	@returns {Unknown}
--]]
function Clockwork.database:IsResult(result) end;

--[[
	@codebase Server
	@details A function to make a string safe for SQL.
	@returns {Unknown}
--]]
function Clockwork.database:Escape(text) end;

--[[
	@codebase Server
	@details Called when the database is connected.
	@returns {Unknown}
--]]
function Clockwork.database:OnConnected() end;

--[[
	@codebase Server
	@details Called when the database connection fails.
	@returns {Unknown}
--]]
function Clockwork.database:OnConnectionFailed(errText) end;

--[[
	@codebase Server
	@details A function to connect to the database.
	@returns {Unknown}
--]]
function Clockwork.database:Connect(host, username, password, database, port) end;

--[[
	EXAMPLE:
	
	local myInsert = Clockwork.database:Insert();
		myInsert:SetTable("players");
		myInsert:SetValue("_Name", "Joe");
		myInsert:SetValue("_SteamID", "STEAM_0:1:9483843344");
		myInsert:AddCallback(MyCallback);
	myInsert:Push();
--]]