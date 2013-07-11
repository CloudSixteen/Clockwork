--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.config:AddToSystem("Cross Server Chat Enabled", "cross_server_chat_enabled", "Whether or not cross server chat is enabled.");
Clockwork.config:AddToSystem("Cross Server Chat Name", "cross_server_chat_name", "A unique server name for cross server chat.");

Clockwork.datastream:Hook("CrossServerChat", function(data)
	Clockwork.chatBox:Add(nil, nil, Color(225, 50, 50, 255), "[OOC] ", Color(data.color.r, data.color.g, data.color.b, data.color.a), data.name, ": ", data.text);
end);