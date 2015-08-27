--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local IsValid = IsValid;

Clockwork.door = Clockwork.kernel:NewLibrary("Door");

-- A function to get whether the door panel is open.
function Clockwork.door:IsDoorPanelOpen()
	local panel = self:GetPanel();
	
	if (IsValid(panel)) then
		return true;
	end;
end;

-- A function to get whether the door has shared text.
function Clockwork.door:HasSharedText()
	return self.cwDoorSharedTxt;
end;

-- A function to get whether the door has shared access.
function Clockwork.door:HasSharedAccess()
	return self.cwDoorSharedAxs;
end;

-- A function to get whether the door is a parent.
function Clockwork.door:IsParent()
	return self.isParent;
end;

-- A function to get whether the door is unsellable.
function Clockwork.door:IsUnsellable()
	return self.unsellable;
end;

-- A function to get the door's access list.
function Clockwork.door:GetAccessList()
	return self.accessList;
end;

-- A function to get the door's name.
function Clockwork.door:GetName()
	return self.name;
end;

-- A function to get the door panel.
function Clockwork.door:GetPanel()
	if (IsValid(self.panel)) then
		return self.panel;
	end;
end;

-- A function to get the door owner.
function Clockwork.door:GetOwner()
	if (IsValid(self.owner)) then
		return self.owner;
	end;
end;

-- A function to get the door entity.
function Clockwork.door:GetEntity()
	return self.entity;
end;