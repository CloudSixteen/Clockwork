--[[
The MIT License (MIT)

Copyright (c) 2013 Alex Grist-Hucker

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local Clockwork = Clockwork;
local net = net;
local ErrorNoHalt = ErrorNoHalt;
local pairs = pairs;
local pcall = pcall;
local type = type;
local util = util;

Clockwork.datastream = Clockwork.kernel:NewLibrary("Datastream");
Clockwork.datastream.stored = Clockwork.datastream.stored or {};

--[[
	@codebase Shared
	@details A function to hook a data stream.
	@param {String} A unique identifier.
	@param {Function} The datastream callback.
--]]
function Clockwork.datastream:Hook(name, Callback)
	self.stored[name] = Callback;
end;

if (SERVER) then
	util.AddNetworkString("cwDataDS");

	--[[
		@codebase Shared
		@details A function to start a data stream.
		@param {Unknown} Missing description for player.
		@param {Unknown} Missing description for name.
		@param {Unknown} Missing description for data.
		@returns {Unknown}
	--]]
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
		local encodedData = Clockwork.kernel:Serialize(dataTable);
			
		if (encodedData and #encodedData > 0 and bShouldSend) then
			net.Start("cwDataDS");
				net.WriteString(name);
				net.WriteUInt(#encodedData, 32);
				net.WriteData(encodedData, #encodedData);
			net.Send(recipients);
		end;
	end;

	--[[
		@codebase Shared
		@details A function to listen for a request.
		@param {Unknown} Missing description for name.
		@param {Unknown} Missing description for Callback.
		@returns {Unknown}
	--]]
	function Clockwork.datastream:Listen(name, Callback)
		self:Hook(name, function(player, data)
			local bShouldReply, reply = Callback(player, data);
			
			if (bShouldReply) then
				self:Start(player, name, reply);
			end;
		end);
	end;
	
	net.Receive("cwDataDS", function(length, player)
		local CW_DS_NAME = net.ReadString();
		local CW_DS_LENGTH = net.ReadUInt(32);
		local CW_DS_DATA = net.ReadData(CW_DS_LENGTH);
		
		if (CW_DS_NAME and CW_DS_DATA and CW_DS_LENGTH) then
			player.cwDataStreamName = CW_DS_NAME;
			player.cwDataStreamData = "";
			
			if (player.cwDataStreamName and player.cwDataStreamData) then
				player.cwDataStreamData = CW_DS_DATA;
				
				if (Clockwork.datastream.stored[player.cwDataStreamName]) then
					local wasSuccess, value = pcall(Clockwork.kernel.Deserialize, Clockwork.kernel, player.cwDataStreamData);
					
					if (wasSuccess) then
						Clockwork.datastream.stored[player.cwDataStreamName](player, value.data);
					elseif (value != nil) then
						MsgC(Color(255, 100, 0, 255), "[Clockwork:Datastream] The '"..CW_DS_NAME.."' datastream has failed to run.\n"..value.."\nData: "..tostring(player.cwDataStreamData).."\n");
					end;
				end;
				
				player.cwDataStreamName = nil;
				player.cwDataStreamData = nil;
			end;
		end;
		
		CW_DS_NAME, CW_DS_DATA, CW_DS_LENGTH = nil, nil, nil;
	end);
else
	--[[
		@codebase Shared
		@details A function to start a data stream.
		@param {Unknown} Missing description for name.
		@param {Unknown} Missing description for data.
		@returns {Unknown}
	--]]
	function Clockwork.datastream:Start(name, data)
		if (data == nil) then data = 0; end;
		
		local dataTable = {data = data};
		local encodedData = Clockwork.kernel:Serialize(dataTable);
		
		if (encodedData and #encodedData > 0) then
			net.Start("cwDataDS");
				net.WriteString(name);
				net.WriteUInt(#encodedData, 32);
				net.WriteData(encodedData, #encodedData);
			net.SendToServer();
		end;
	end;

	--[[
		@codebase Shared
		@details A function to send a request.
		@param {Unknown} Missing description for name.
		@param {Unknown} Missing description for data.
		@param {Unknown} Missing description for Callback.
		@returns {Unknown}
	--]]
	function Clockwork.datastream:Request(name, data, Callback)
		self:Hook(name, Callback);		
		self:Start(name, data);
	end;

	net.Receive("cwDataDS", function(length)
		local CW_DS_NAME = net.ReadString();
		local CW_DS_LENGTH = net.ReadUInt(32);
		local CW_DS_DATA = net.ReadData(CW_DS_LENGTH);

		if (CW_DS_NAME and CW_DS_DATA and CW_DS_LENGTH) then			
			if (Clockwork.datastream.stored[CW_DS_NAME]) then
				local wasSuccess, value = pcall(Clockwork.kernel.Deserialize, Clockwork.kernel, CW_DS_DATA);
			
				if (wasSuccess) then
					Clockwork.datastream.stored[CW_DS_NAME](value.data);
				elseif (value != nil) then
					MsgC(Color(255, 100, 0, 255), "[Clockwork:Datastream] The '"..CW_DS_NAME.."' datastream has failed to run.\n"..value.."\nData: "..tostring(CW_DS_DATA).."\n");
				end;
			end;
		end;
		
		CW_DS_NAME, CW_DS_DATA, CW_DS_LENGTH = nil, nil, nil;
	end);
end;
