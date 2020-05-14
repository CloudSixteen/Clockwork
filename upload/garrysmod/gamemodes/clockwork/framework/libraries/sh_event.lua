--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local type = type;

Clockwork.event = Clockwork.kernel:NewLibrary("Event");
Clockwork.event.stored = Clockwork.event.stored or {};

--[[
	@codebase Shared
	@details A function to hook into an event.
	@param {Unknown} Missing description for eventClass.
	@param {Unknown} Missing description for eventName.
	@param {Unknown} Missing description for isAllowed.
	@returns {Unknown}
--]]
function Clockwork.event:Hook(eventClass, eventName, isAllowed)
	if (eventName) then
		self.stored[eventClass] = {};
		self.stored[eventClass][eventName] = isAllowed;
	else
		self.stored[eventClass] = isAllowed;
	end;
end;

--[[
	@codebase Shared
	@details A function to get whether an event can run.
	@param {Unknown} Missing description for eventClass.
	@param {Unknown} Missing description for eventName.
	@returns {Unknown}
--]]
function Clockwork.event:CanRun(eventClass, eventName)
	local eventTable = self.stored[eventClass];
	
	if (type(eventTable) == "boolean") then
		return eventTable;
	elseif (eventTable != nil and type(eventTable[eventName]) == "boolean") then
		return eventTable[eventName];
	end;
	
	return true;
end;