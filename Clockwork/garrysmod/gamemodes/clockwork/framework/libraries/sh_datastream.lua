--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

local Clockwork = Clockwork;
local net = net;
local ErrorNoHalt = ErrorNoHalt;
local pairs = pairs;
local pcall = pcall;
local type = type;
local util = util;

--[[ The datastream library is already defined! --]]
if (Clockwork.datastream) then return; end;

Clockwork.datastream = Clockwork.kernel:NewLibrary("Datastream");
Clockwork.datastream.stored = {};

--[[
	@codebase Shared
	@details A function to hook a data stream.
	@param String A unique identifier.
	@param Function The datastream callback.
	@returns Bool Whether or not the tables are equal.
--]]
function Clockwork.datastream:Hook(name, Callback)
	self.stored[name] = Callback;
end;

if (SERVER) then
	util.AddNetworkString("cwDataDS");

	-- A function to start a data stream.
	function Clockwork.datastream:Start(player, name, data)
		local recipients = {};
		local bShouldSend = false;
	
		if (type(player) != "table") then
			if (!player) then
				player = cwPlayer.GetAll();
			else
				player = {player};
			end;
		end;
		
		for k, v in pairs(player) do
			if (type(v) == "Player") then
				recipients[#recipients + 1] = v;
				
				bShouldSend = true;
			elseif (type(k) == "Player") then
				recipients[#recipients + 1] = k;
			
				bShouldSend = true;
			end;
		end;
		
		if (data == nil) then data = 0; end;
		
		local dataTable = {data = data};
		local vonData = Clockwork.kernel:Serialize(dataTable);
		local encodedData = util.Compress(vonData);
			
		if (encodedData and #encodedData > 0 and bShouldSend) then
			net.Start("cwDataDS");
				net.WriteString(name);
				net.WriteUInt(#encodedData, 32);
				net.WriteData(encodedData, #encodedData);
			net.Send(recipients);
		end;
	end;
	
	net.Receive("cwDataDS", function(length, player)
		local CW_DS_NAME = net.ReadString();
		local CW_DS_LENGTH = net.ReadUInt(32);
		local CW_DS_DATA = net.ReadData(CW_DS_LENGTH);
		
		if (CW_DS_NAME and CW_DS_DATA and CW_DS_LENGTH) then
			CW_DS_DATA = util.Decompress(CW_DS_DATA);
			
			if (!CW_DS_DATA) then
				ErrorNoHalt("[Clockwork] The datastream failed to decompress!\n");
				
				return;
			end;
			
			player.cwDataStreamName = CW_DS_NAME;
			player.cwDataStreamData = "";
			
			if (player.cwDataStreamName and player.cwDataStreamData) then
				player.cwDataStreamData = CW_DS_DATA;
				
				if (Clockwork.datastream.stored[player.cwDataStreamName]) then
					local bSuccess, value = pcall(Clockwork.kernel.Deserialize, Clockwork.kernel, player.cwDataStreamData);
					
					if (bSuccess) then
						Clockwork.datastream.stored[player.cwDataStreamName](player, value.data);
					elseif (value != nil) then
						ErrorNoHalt("[Clockwork] The '"..CW_DS_NAME.."' datastream has failed to run.\n"..value.."\n");
					end;
				end;
				
				player.cwDataStreamName = nil;
				player.cwDataStreamData = nil;
			end;
		end;
		
		CW_DS_NAME, CW_DS_DATA, CW_DS_LENGTH = nil, nil, nil;
	end);
else
	-- A function to start a data stream.
	function Clockwork.datastream:Start(name, data)
		if (data == nil) then data = 0; end;
		
		local dataTable = {data = data};
		local vonData = Clockwork.kernel:Serialize(dataTable);
		local encodedData = util.Compress(vonData);
		
		if (encodedData and #encodedData > 0) then
			net.Start("cwDataDS");
				net.WriteString(name);
				net.WriteUInt(#encodedData, 32);
				net.WriteData(encodedData, #encodedData);
			net.SendToServer();
		end;
	end;
	
	net.Receive("cwDataDS", function(length)
		CW_DS_NAME = net.ReadString();
		CW_DS_LENGTH = net.ReadUInt(32);
		CW_DS_DATA = net.ReadData(CW_DS_LENGTH);
		
		if (CW_DS_NAME and CW_DS_DATA and CW_DS_LENGTH) then
			CW_DS_DATA = util.Decompress(CW_DS_DATA);

			if (!CW_DS_DATA) then
				ErrorNoHalt("[Clockwork] The datastream failed to decompress!\n");
				
				return;
			end;
						
			if (Clockwork.datastream.stored[CW_DS_NAME]) then
				local bSuccess, value = pcall(Clockwork.kernel.Deserialize, Clockwork.kernel, CW_DS_DATA);
			
				if (bSuccess) then
					Clockwork.datastream.stored[CW_DS_NAME](value.data);
				elseif (value != nil) then
					ErrorNoHalt("[Clockwork] The '"..CW_DS_NAME.."' datastream has failed to run.\n"..value.."\n");
				end;
			end;
		end;
		
		CW_DS_NAME, CW_DS_DATA, CW_DS_LENGTH = nil, nil, nil;
	end);
end;
