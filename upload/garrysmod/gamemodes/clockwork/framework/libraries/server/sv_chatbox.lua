--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.chatBox = Clockwork.kernel:NewLibrary("ChatBox");

Clockwork.chatBox.multiplier = nil;

--[[
	@codebase Server
	@details A function to add a new chat message.
	@returns {Unknown}
--]]
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
		multiplier = self.multiplier,
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
				multiplier = info.multiplier,
				speaker = info.speaker,
				class = info.class,
				text = info.text,
				data = info.data
			});
		else
			Clockwork.datastream:Start(info.listeners, "ChatBoxMessage", {
				multiplier = info.multiplier,
				class = info.class,
				text = info.text,
				data = info.data
			});
		end;
	end;
	
	self.multiplier = nil;
	return info;
end;

--[[
	@codebase Server
	@details A function to add a new chat message in a target radius.
	@returns {Unknown}
--]]
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

--[[
	@codebase Server
	@details A function to add a new chat message in a radius.
	@returns {Unknown}
--]]
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

--[[
	@codebase Server
	@details A function to send a colored message.
	@returns {Unknown}
--]]
function Clockwork.chatBox:SendColored(listeners, ...)
	Clockwork.datastream:Start(listeners, "ChatBoxColorMessage", {...});
end;

-- A function to set the size (multiplier) of the next chat message.
function Clockwork.chatBox:SetMultiplier(multiplier)
	self.multiplier = multiplier;
end;
