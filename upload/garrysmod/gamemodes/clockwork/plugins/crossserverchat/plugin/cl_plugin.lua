--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.config:AddToSystem("CrossServerChatEnabled", "cross_server_chat_enabled", "CrossServerChatEnabledDesc");
Clockwork.config:AddToSystem("CrossServerChatName", "cross_server_chat_name", "CrossServerChatNameDesc");

Clockwork.datastream:Hook("CrossServerChat", function(data)
	Clockwork.chatBox:Add(nil, nil, Color(225, 50, 50, 255), "[OOC] ", Color(data.color.r, data.color.g, data.color.b, data.color.a), data.name, ": ", data.text);
end);