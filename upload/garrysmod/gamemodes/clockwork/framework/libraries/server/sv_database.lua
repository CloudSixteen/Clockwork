--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.database = Clockwork.kernel:NewLibrary("Database");

Clockwork.database.updateTable = nil;
Clockwork.database.runQueue = {};
Clockwork.database.liteSql = false;

MYSQL_UPDATE_CLASS = {__index = MYSQL_UPDATE_CLASS};

function MYSQL_UPDATE_CLASS:SetTable(tableName)
	self.tableName = tableName;
	return self;
end;

function MYSQL_UPDATE_CLASS:SetValue(key, value)
	if (Clockwork.NoMySQL) then return self; end;
		self.updateVars[key] = "\""..Clockwork.database:Escape(tostring(value)).."\"";
	return self;
end;

function MYSQL_UPDATE_CLASS:Replace(key, search, replace)
	if (Clockwork.NoMySQL) then return self; end;
	
	search = "\""..Clockwork.database:Escape(tostring(search)).."\"";
	replace = "\""..Clockwork.database:Escape(tostring(replace)).."\"";
	self.updateVars[key] = "REPLACE("..key..", "..search..", "..replace..")";
	
	return self;
end;

function MYSQL_UPDATE_CLASS:AddWhere(key, value)
	if (Clockwork.NoMySQL) then return self; end;
	
	value = Clockwork.database:Escape(tostring(value));
		self.updateWhere[#self.updateWhere + 1] = string.gsub(key, '?', "\""..value.."\"");
	return self;
end;

function MYSQL_UPDATE_CLASS:SetCallback(Callback)
	self.Callback = Callback;
	return self;
end;

function MYSQL_UPDATE_CLASS:SetFlag(value)
	self.Flag = value;
	return self;
end;

function MYSQL_UPDATE_CLASS:Push()
	if (Clockwork.NoMySQL) then return; end;
	if (!self.tableName) then return; end;
	
	local updateQuery = "";
	
	for k, v in pairs(self.updateVars) do
		if (updateQuery == "") then
			updateQuery = "UPDATE "..self.tableName.." SET "..k.." = "..v;
		else
			updateQuery = updateQuery..", "..k.." = "..v;
		end;
	end;
	
	if (updateQuery == "") then return; end;
	
	local whereTable = {};
	
	for k, v in pairs(self.updateWhere) do
		whereTable[#whereTable + 1] = v;
	end;
	
	local whereString = table.concat(whereTable, " AND ");
	
	if (whereString != "") then
		Clockwork.database:Query(updateQuery.." WHERE "..whereString, self.Callback, self.Flag);
	else
		Clockwork.database:Query(updateQuery, self.Callback, self.Flag);
	end;
end;

MYSQL_INSERT_CLASS = {__index = MYSQL_INSERT_CLASS};

function MYSQL_INSERT_CLASS:SetTable(tableName)
	self.tableName = tableName;
	return self;
end;

function MYSQL_INSERT_CLASS:SetValue(key, value)
	self.insertVars[key] = value;
	return self;
end;

function MYSQL_INSERT_CLASS:SetCallback(Callback)
	self.Callback = Callback;
	return self;
end;

function MYSQL_INSERT_CLASS:SetFlag(value)
	self.Flag = value;
	return self;
end;

function MYSQL_INSERT_CLASS:Push()
	if (Clockwork.NoMySQL) then return; end;
	if (!self.tableName) then return; end;
	
	local keyList = {};
	local valueList = {};
	
	for k, v in pairs(self.insertVars) do
		keyList[#keyList + 1] = k;
		valueList[#valueList + 1] = "\""..Clockwork.database:Escape(tostring(v)).."\"";
	end;
	
	if (#keyList == 0) then return; end;
	
	local insertQuery = "INSERT INTO "..self.tableName.." ("..table.concat(keyList, ", ")..")";
		insertQuery = insertQuery.." VALUES("..table.concat(valueList, ", ")..")";
	Clockwork.database:Query(insertQuery, self.Callback, self.Flag);
end;

MYSQL_SELECT_CLASS = {__index = MYSQL_SELECT_CLASS};

function MYSQL_SELECT_CLASS:SetTable(tableName)
	self.tableName = tableName;
	return self;
end;

function MYSQL_SELECT_CLASS:AddColumn(key)
	self.selectColumns[#self.selectColumns + 1] = key;
	return self;
end;

function MYSQL_SELECT_CLASS:AddWhere(key, value)
	if (Clockwork.NoMySQL) then return self; end;
	
	value = Clockwork.database:Escape(tostring(value));
		self.selectWhere[#self.selectWhere + 1] = string.gsub(key, '?', "\""..value.."\"");
	return self;
end;

function MYSQL_SELECT_CLASS:SetCallback(Callback)
	self.Callback = Callback;
	return self;
end;

function MYSQL_SELECT_CLASS:SetFlag(value)
	self.Flag = value;
	return self;
end;

function MYSQL_SELECT_CLASS:SetOrder(key, value)
	self.Order = key.." "..value;
	return self;
end;

function MYSQL_SELECT_CLASS:Pull()
	if (Clockwork.NoMySQL) then return; end;
	if (!self.tableName) then return; end;
	
	if (#self.selectColumns == 0) then
		self.selectColumns[#self.selectColumns + 1] = "*";
	end;
	
	local selectQuery = "SELECT "..table.concat(self.selectColumns, ", ").." FROM "..self.tableName;
	local whereTable = {};
	
	for k, v in pairs(self.selectWhere) do
		whereTable[#whereTable + 1] = v;
	end;
	
	local whereString = table.concat(whereTable, " AND ");
	
	if (whereString != "") then
		selectQuery = selectQuery.." WHERE "..whereString;
	end;
	
	if (self.selectOrder != "") then
		selectQuery = selectQuery.." ORDER BY "..self.selectOrder;
	end;
	
	Clockwork.database:Query(selectQuery, self.Callback, self.Flag);
end;

MYSQL_DELETE_CLASS = {__index = MYSQL_DELETE_CLASS};

function MYSQL_DELETE_CLASS:SetTable(tableName)
	self.tableName = tableName;
	return self;
end;

function MYSQL_DELETE_CLASS:AddWhere(key, value)
	if (Clockwork.NoMySQL) then return self; end;
	
	value = Clockwork.database:Escape(tostring(value));
		self.deleteWhere[#self.deleteWhere + 1] = string.gsub(key, '?', "\""..value.."\"");
	return self;
end;

function MYSQL_DELETE_CLASS:SetCallback(Callback)
	self.Callback = Callback;
	return self;
end;

function MYSQL_DELETE_CLASS:SetFlag(value)
	self.Flag = value;
	return self;
end;

function MYSQL_DELETE_CLASS:Push()
	if (Clockwork.NoMySQL) then return; end;
	if (!self.tableName) then return; end;
	
	local deleteQuery = "DELETE FROM "..self.tableName;
	local whereTable = {};
	
	for k, v in pairs(self.deleteWhere) do
		whereTable[#whereTable + 1] = v;
	end;
	
	local whereString = table.concat(whereTable, " AND ");
	
	if (whereString != "") then
		Clockwork.database:Query(deleteQuery.." WHERE "..whereString, self.Callback, self.Flag);
	else
		Clockwork.database:Query(deleteQuery, self.Callback, self.Flag);
	end;
end;

function Clockwork.database:Update(tableName)
	local object = Clockwork.kernel:NewMetaTable(MYSQL_UPDATE_CLASS);
		object.updateVars = {};
		object.updateWhere = {};
		object.tableName = tableName;
	return object;
end;

function Clockwork.database:Insert(tableName)
	local object = Clockwork.kernel:NewMetaTable(MYSQL_INSERT_CLASS);
		object.insertVars = {};
		object.tableName = tableName;
	return object;
end;

function Clockwork.database:Select(tableName)
	local object = Clockwork.kernel:NewMetaTable(MYSQL_SELECT_CLASS);
		object.selectColumns = {};
		object.selectWhere = {};
		object.selectOrder = "";
		object.tableName = tableName;
	return object;
end;

function Clockwork.database:Delete(tableName)
	local object = Clockwork.kernel:NewMetaTable(MYSQL_DELETE_CLASS);
		object.deleteWhere = {};
		object.tableName = tableName;
	return object;
end;

function Clockwork.database:Error(text) end;

function Clockwork.database:Query(query, Callback, flag, bRawQuery)
	if (Clockwork.NoMySQL) then
		MsgN("[Clockwork] Cannot run a database query with no connection!");
		return;
	end;
	
	if (self.MDB) then
		local sqlObject = self.MDB:query(query);
		
		sqlObject:setOption(mysqloo.OPTION_NAMED_FIELDS);
 
		function sqlObject.onSuccess(sqlObject, data)
			if (Callback and !bRawQuery) then
				Callback(data, sqlObject:lastInsert());
			end;
		end;
		
		function sqlObject.onError(sqlObject, errorText)
			local databaseStatus = self.MDB:status();

			if (databaseStatus == mysqloo.DATABASE_NOT_CONNECTED) then
				table.insert(self.runQueue, {query, Callback, bRawQuery});
				self.MDB:connect();
			end;
			
			if (errorText) then
				MsgN(errorText);
			end;
		end;
	 
		sqlObject:start();
		
		return;
	end;
	
	if (!bRawQuery) then
		if (self.liteSql) then
			local data = sql.Query(query);
			local lastError = sql.LastError();
			
			if (lastError) then
				MsgN(query);
				MsgN(lastError);
			end;
			
			if (data == false) then
				Clockwork.database:Error(lastError);
				return;
			end;
			
			if (Callback) then
				Callback(data, lastError, tonumber(sql.QueryValue("SELECT last_insert_rowid()")))
			end
		else
			tmysql.query(query, function(result, status, text, other)
				--MsgN("[Clockwork] Result: "..tostring(result).." Status: "..tostring(status).." Text: "..tostring(text).." Other: "..tostring(other));
				
				if (Callback) then
					Callback(result, status, text);
				end;
			end, (flag or 1));
		end;
	elseif (self.liteSql) then
		local data = sql.Query(query);
		
		if (data == false) then
			MsgN(query);
			MsgN(sql.LastError());
		end;
	else
		tmysql.query(query, function(result, status, text, other)
			--MsgN("[Clockwork] Result: "..tostring(result).." Status: "..tostring(status).." Text: "..tostring(text).." Other: "..tostring(other));
		end);
	end;
end;

function Clockwork.database:IsResult(result)
	return (result and type(result) == "table" and #result > 0);
end;

function Clockwork.database:Escape(text)
	if (self.MDB) then
		return self.MDB:escape(text);
	elseif (self.liteSql) then
	    local escapedText = string.Replace(text, '"', '""');
		local nullPosition = string.find(escapedText, "\0");
		local result;

		if (nullPosition) then
			result = string.sub(escapedText, 1, nullPosition - 1);
		else
			result = escapedText;
		end;

		return result;
	else
		return tmysql.escape(text);
	end;
end;

function Clockwork.database:OnConnected()
	local BANS_TABLE_QUERY = [[
	CREATE TABLE IF NOT EXISTS `]]..Clockwork.config:Get("mysql_bans_table"):Get()..[[` (
		`_Key` int(11) NOT NULL AUTO_INCREMENT,
		`_Identifier` text NOT NULL,
		`_UnbanTime` int(11) NOT NULL,
		`_SteamName` varchar(150) NOT NULL,
		`_Duration` int(11) NOT NULL,
		`_Reason` text NOT NULL,
		`_Schema` text NOT NULL,
		PRIMARY KEY (`_Key`));
	]];
	
	local LITE_BANS_TABLE_QUERY = [[
	CREATE TABLE IF NOT EXISTS `]]..Clockwork.config:Get("mysql_bans_table"):Get()..[[` (
		`_Key` INTEGER PRIMARY KEY AUTOINCREMENT,
		`_Identifier` TEXT,
		`_UnbanTime` INTEGER,
		`_SteamName` TEXT,
		`_Duration` INTEGER,
		`_Reason` TEXT,
		`_Schema` TEXT);
	]];
	
	local CHARACTERS_TABLE_QUERY = [[
	CREATE TABLE IF NOT EXISTS `]]..Clockwork.config:Get("mysql_characters_table"):Get()..[[` (
		`_Key` smallint(11) NOT NULL AUTO_INCREMENT,
		`_Data` text NOT NULL,
		`_Name` varchar(150) NOT NULL,
		`_Ammo` text NOT NULL,
		`_Cash` varchar(150) NOT NULL,
		`_Model` varchar(250) NOT NULL,
		`_Flags` text NOT NULL,
		`_Schema` text NOT NULL,
		`_Gender` varchar(50) NOT NULL,
		`_Faction` varchar(50) NOT NULL,
		`_SteamID` varchar(60) NOT NULL,
		`_SteamName` varchar(150) NOT NULL,
		`_Inventory` text NOT NULL,
		`_OnNextLoad` text NOT NULL,
		`_Attributes` text NOT NULL,
		`_LastPlayed` varchar(50) NOT NULL,
		`_TimeCreated` varchar(50) NOT NULL,
		`_CharacterID` varchar(50) NOT NULL,
		`_RecognisedNames` text NOT NULL,
		PRIMARY KEY (`_Key`));
	]];
	
	local LITE_CHARACTERS_TABLE_QUERY = [[
	CREATE TABLE IF NOT EXISTS `]]..Clockwork.config:Get("mysql_characters_table"):Get()..[[` (
		`_Key` INTEGER PRIMARY KEY AUTOINCREMENT,
		`_Data` TEXT,
		`_Name` TEXT,
		`_Ammo` TEXT,
		`_Cash` INTEGER,
		`_Model` TEXT,
		`_Flags` TEXT,
		`_Schema` TEXT,
		`_Gender` TEXT,
		`_Faction` TEXT,
		`_SteamID` TEXT,
		`_SteamName` TEXT,
		`_Inventory` TEXT,
		`_OnNextLoad` TEXT,
		`_Attributes` TEXT,
		`_LastPlayed` INTEGER,
		`_TimeCreated` INTEGER,
		`_CharacterID` INTEGER,
		`_RecognisedNames` TEXT);
	]];

	local PLAYERS_TABLE_QUERY = [[
	CREATE TABLE IF NOT EXISTS `]]..Clockwork.config:Get("mysql_players_table"):Get()..[[` (
		`_Key` smallint(11) NOT NULL AUTO_INCREMENT,
		`_Data` text NOT NULL,
		`_Schema` text NOT NULL,
		`_SteamID` varchar(60) NOT NULL,
		`_Donations` text NOT NULL,
		`_UserGroup` text NOT NULL,
		`_IPAddress` varchar(50) NOT NULL,
		`_SteamName` varchar(150) NOT NULL,
		`_OnNextPlay` text NOT NULL,
		`_LastPlayed` varchar(50) NOT NULL,
		`_TimeJoined` varchar(50) NOT NULL,
		PRIMARY KEY (`_Key`));
	]];
	
	local LITE_PLAYERS_TABLE_QUERY = [[
	CREATE TABLE IF NOT EXISTS `]]..Clockwork.config:Get("mysql_players_table"):Get()..[[` (
		`_Key` INTEGER PRIMARY KEY AUTOINCREMENT,
		`_Data` TEXT,
		`_Schema` TEXT,
		`_SteamID` TEXT,
		`_Donations` TEXT,
		`_UserGroup` TEXT,
		`_IPAddress` TEXT,
		`_SteamName` TEXT,
		`_OnNextPlay` TEXT,
		`_LastPlayed` INTEGER,
		`_TimeJoined` INTEGER);
	]];

	if (self.liteSql) then
		self:Query(string.gsub(LITE_BANS_TABLE_QUERY, "%s", " "), nil, nil, true);
		self:Query(string.gsub(LITE_CHARACTERS_TABLE_QUERY, "%s", " "), nil, nil, true);
		self:Query(string.gsub(LITE_PLAYERS_TABLE_QUERY, "%s", " "), nil, nil, true);
	else
		self:Query(string.gsub(BANS_TABLE_QUERY, "%s", " "), nil, nil, true);
		self:Query(string.gsub(CHARACTERS_TABLE_QUERY, "%s", " "), nil, nil, true);
		self:Query(string.gsub(PLAYERS_TABLE_QUERY, "%s", " "), nil, nil, true);
	end;
	
	Clockwork.NoMySQL = false;
	Clockwork.plugin:Call("ClockworkDatabaseConnected");
	
	if (self.MDB) then
		for k, v in pairs(self.runQueue) do
			self:Query(v[1], v[2], nil, v[3]);
		end;

		self.runQueue = {};
	end;
end;

function Clockwork.database:OnConnectionFailed(errText)
	ErrorNoHalt("Clockwork::Database - "..errText.."\n");

	Clockwork.NoMySQL = errText;
	Clockwork.plugin:Call("ClockworkDatabaseConnectionFailed", errText);
end;

function Clockwork.database:Connect(host, username, password, database, port)
	if (host == "example.com") then
		ErrorNoHalt("[Clockwork] No MySQL details found. Connecting to database using SQLite...\n");
		
		self.liteSql = true;
		self:OnConnected();
		return;
	end;
	
	if (host == "localhost") then
		host = "127.0.0.1";
	end;
	
	if (system.IsLinux() and mysqloo) then
		self.MDB = mysqloo.connect(host, username, password, database, port);
		
		ErrorNoHalt("[Clockwork] Connecting to database using MySQLOO...\n");
		
		function self.MDB.onConnected(db)
			Clockwork.database:OnConnected();
		end;

		function self.MDB.onConnectionFailed(db, errText)
			Clockwork.database:OnConnectionFailed(errText);
		end;
		
		self.MDB:connect();
		
		return;
	end;
	
	local success, databaseConnection, errText = pcall(
		tmysql.initialize,
		host,
		username,
		password,
		database,
		port
	);
	
	ErrorNoHalt("[Clockwork] Connecting to database using tmysql4...\n");

	if (databaseConnection) then
		self:OnConnected();
	else
		self:OnConnectionFailed(errText);
	end;
end;

--[[
	EXAMPLE:
	
	local myInsert = Clockwork.database:Insert();
		myInsert:SetTable("players");
		myInsert:SetValue("_Name", "Joe");
		myInsert:SetValue("_SteamID", "STEAM_0:1:9483843344");
		myInsert:AddCallback(MyCallback);
	myInsert:Push();
--]]