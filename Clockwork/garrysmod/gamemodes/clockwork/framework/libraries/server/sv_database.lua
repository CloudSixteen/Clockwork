--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.database = Clockwork.kernel:NewLibrary("Database");

-- A function to begin a database update.
function Clockwork.database:Update(tableName) end;

-- A function to begin a database insert.
function Clockwork.database:Insert(tableName) end;

-- A function to begin a database select.
function Clockwork.database:Select(tableName) end;

-- A function to begin a database delete.
function Clockwork.database:Delete(tableName) end;

-- Called when a MySQL error occurs.
function Clockwork.database:Error(errText) end;

-- A function to query the database.
function Clockwork.database:Query(query, Callback, flag, bRawQuery) end;

-- A function to get whether a result is valid.
function Clockwork.database:IsResult(result) end;

-- A function to make a string safe for SQL.
function Clockwork.database:Escape(text) end;

-- Called when the database is connected.
function Clockwork.database:OnConnected() end;

-- Called when the database connection fails.
function Clockwork.database:OnConnectionFailed(errText) end;

-- A function to connect to the database.
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