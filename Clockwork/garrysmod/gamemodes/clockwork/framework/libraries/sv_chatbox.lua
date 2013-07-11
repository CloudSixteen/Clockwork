--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;
local IsValid = IsValid;
local pairs = pairs;
local type = type;

--[[ We need the datastream library to add the hooks! --]]
if (!Clockwork.datastream) then include("sh_datastream.lua"); end;

Clockwork.chatBox = Clockwork.kernel:NewLibrary("ChatBox");

-- A function to add a new chat message.
function Clockwork.chatBox:Add(listeners, speaker, class, text, data)
	if (type(listeners) != "table") then
		if (!listeners) then
			listeners = cwPlayer.GetAll();
		else
			listeners = {listeners};
		end;
	end;
	
	local info = {
		bShouldSend = true,
		listeners = listeners,
		speaker = speaker,
		class = class,
		text = text,
		data = data
	};
	
	if (type(info.data) != "table") then
		info.data = {info.data};
	end;
		
	Clockwork.plugin:Call("ChatBoxAdjustInfo", info);
	Clockwork.plugin:Call("ChatBoxMessageAdded", info);
	
	if (info.bShouldSend) then
		if (IsValid(info.speaker)) then
			Clockwork.datastream:Start(info.listeners, "ChatBoxPlayerMessage", {
				speaker = info.speaker,
				class = info.class,
				text = info.text,
				data = info.data
			});
		else
			Clockwork.datastream:Start(info.listeners, "ChatBoxMessage", {
				class = info.class,
				text = info.text,
				data = info.data
			});
		end;
	end;
	
	return info;
end;

-- A function to add a new chat message in a target radius.
function Clockwork.chatBox:AddInTargetRadius(speaker, class, text, position, radius, data)
	local listeners = {};
	
	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:HasInitialized()) then
			if (Clockwork.player:GetRealTrace(v).HitPos:Distance(position) <= (radius / 2)
			or position:Distance(v:GetPos()) <= radius) then
				listeners[#listeners + 1] = v;
			end;
		end;
	end;

	self:Add(listeners, speaker, class, text, data);
end;

-- A function to add a new chat message in a radius.
function Clockwork.chatBox:AddInRadius(speaker, class, text, position, radius, data)
	local listeners = {};
	
	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:HasInitialized()) then
			if (position:Distance(v:GetPos()) <= radius) then
				listeners[#listeners + 1] = v;
			end;
		end;
	end;

	self:Add(listeners, speaker, class, text, data);
end;

-- A function to send a colored message.
function Clockwork.chatBox:SendColored(listeners, ...)
	Clockwork.datastream:Start(listeners, "ChatBoxColorMessage", {...});
end;