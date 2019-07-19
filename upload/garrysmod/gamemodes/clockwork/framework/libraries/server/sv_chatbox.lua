--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.chatBox = Clockwork.kernel:NewLibrary("ChatBox");

--[[
	@codebase Server
	@details A function to add a new chat message.
	@returns {Unknown}
--]]
function Clockwork.chatBox:Add(listeners, speaker, class, text, data) end;

--[[
	@codebase Server
	@details A function to add a new chat message in a target radius.
	@returns {Unknown}
--]]
function Clockwork.chatBox:AddInTargetRadius(speaker, class, text, position, radius, data) end;

--[[
	@codebase Server
	@details A function to add a new chat message in a radius.
	@returns {Unknown}
--]]
function Clockwork.chatBox:AddInRadius(speaker, class, text, position, radius, data) end;

--[[
	@codebase Server
	@details A function to send a colored message.
	@returns {Unknown}
--]]
function Clockwork.chatBox:SendColored(listeners, ...) end;

-- A function to set the size (multiplier) of the next chat message.
function Clockwork.chatBox:SetMultiplier(multiplier) end;