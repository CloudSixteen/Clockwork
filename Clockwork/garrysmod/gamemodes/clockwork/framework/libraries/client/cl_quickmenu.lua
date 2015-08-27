--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

Clockwork.quickmenu = Clockwork.kernel:NewLibrary("QuickMenu");
Clockwork.quickmenu.stored = Clockwork.quickmenu.stored or {};
Clockwork.quickmenu.categories = Clockwork.quickmenu.categories or {};

-- A function to add a quick menu callback.
function Clockwork.quickmenu:AddCallback(name, category, GetInfo, OnCreateMenu)
	if (category) then
		if (!self.categories[category]) then
			self.categories[category] = {};
		end;
		
		self.categories[category][name] = {
			OnCreateMenu = OnCreateMenu,
			GetInfo = GetInfo,
			name = name
		};
	else
		self.stored[name] = {
			OnCreateMenu = OnCreateMenu,
			GetInfo = GetInfo,
			name = name
		};
	end;
	
	return name;
end;

-- A function to add a command quick menu callback.
function Clockwork.quickmenu:AddCommand(name, category, command, options)
	return self:AddCallback(name, category, function()
		local commandTable = Clockwork.command:FindByID(command);
		
		if (commandTable) then
			return {
				toolTip = commandTable.tip,
				Callback = function(option)
					Clockwork.kernel:RunCommand(command, option);
				end,
				options = options
			};
		else
			return false;
		end;
	end);
end;

Clockwork.quickmenu:AddCallback("Fall Over", nil, function()
	local commandTable = Clockwork.command:FindByID("CharFallOver");
	
	if (commandTable) then
		return {
			toolTip = commandTable.tip,
			Callback = function(option)
				Clockwork.kernel:RunCommand("CharFallOver");
			end
		};
	else
		return false;
	end;
end);

Clockwork.quickmenu:AddCallback("Description", nil, function()
	local commandTable = Clockwork.command:FindByID("CharPhysDesc");
	
	if (commandTable) then
		return {
			toolTip = commandTable.tip,
			Callback = function(option)
				Clockwork.kernel:RunCommand("CharPhysDesc");
			end
		};
	else
		return false;
	end;
end);