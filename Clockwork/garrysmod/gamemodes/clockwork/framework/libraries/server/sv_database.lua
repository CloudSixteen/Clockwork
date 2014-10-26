--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
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

	:IsResult only works for :Select, and someone must join
	the server once in order for the queries to work. After
	someone joins, queries may be executed freely. You may 
	use a bot to trigger the ability to use queries.

	You should always use callbacks, as the query is not 
	instantaneous, and your script will continue to run
	even though the query has not yet been executed.

	EXAMPLE:

	local queryObj = Clockwork.database:Select(Clockwork.config:Get("mysql_characters_table"):Get());
		queryObj:AddWhere("_Name = ?", "Jim Bob");
		queryObj:SetCallback(function(result, status, error)
			if (Clockwork.database:IsResult(result)) then
				print("Jim Bob is there!");
			end;
		end);
	queryObj:Pull();
--]]
