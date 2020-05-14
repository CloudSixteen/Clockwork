--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local IsValid = IsValid;

Clockwork.door = Clockwork.kernel:NewLibrary("Door");

--[[
	@codebase Client
	@details A function to get whether the door panel is open.
	@returns {Unknown}
--]]
function Clockwork.door:IsDoorPanelOpen()
	local panel = self:GetPanel();
	
	if (IsValid(panel)) then
		return true;
	end;
end;

--[[
	@codebase Client
	@details A function to get whether the door has shared text.
	@returns {Unknown}
--]]
function Clockwork.door:HasSharedText()
	return self.cwDoorSharedTxt;
end;

--[[
	@codebase Client
	@details A function to get whether the door has shared access.
	@returns {Unknown}
--]]
function Clockwork.door:HasSharedAccess()
	return self.cwDoorSharedAxs;
end;

--[[
	@codebase Client
	@details A function to get whether the door is a parent.
	@returns {Unknown}
--]]
function Clockwork.door:IsParent()
	return self.isParent;
end;

--[[
	@codebase Client
	@details A function to get whether the door is unsellable.
	@returns {Unknown}
--]]
function Clockwork.door:IsUnsellable()
	return self.unsellable;
end;

--[[
	@codebase Client
	@details A function to get the door's access list.
	@returns {Unknown}
--]]
function Clockwork.door:GetAccessList()
	return self.accessList;
end;

--[[
	@codebase Client
	@details A function to get the door's name.
	@returns {Unknown}
--]]
function Clockwork.door:GetName()
	return self.name;
end;

--[[
	@codebase Client
	@details A function to get the door panel.
	@returns {Unknown}
--]]
function Clockwork.door:GetPanel()
	if (IsValid(self.panel)) then
		return self.panel;
	end;
end;

--[[
	@codebase Client
	@details A function to get the door owner.
	@returns {Unknown}
--]]
function Clockwork.door:GetOwner()
	if (IsValid(self.owner)) then
		return self.owner;
	end;
end;

--[[
	@codebase Client
	@details A function to get the door entity.
	@returns {Unknown}
--]]
function Clockwork.door:GetEntity()
	return self.entity;
end;