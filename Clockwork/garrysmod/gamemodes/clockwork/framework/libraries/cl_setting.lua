--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local table = table;

Clockwork.setting = Clockwork.kernel:NewLibrary("Setting");
Clockwork.setting.stored = {};

-- A function to add a number slider setting.
function Clockwork.setting:AddNumberSlider(category, text, conVar, minimum, maximum, decimals, toolTip, Condition)
	local index = #self.stored + 1;
	
	self.stored[index] = {
		Condition = Condition,
		category = category,
		decimals = decimals,
		toolTip = toolTip,
		maximum = maximum,
		minimum = minimum,
		conVar = conVar,
		class = "numberSlider",
		text = text
	};
	
	return index;
end;

-- A function to add a multi-choice setting.
function Clockwork.setting:AddMultiChoice(category, text, conVar, options, toolTip, Condition)
	local index = #self.stored + 1;
	
	if (options) then
		table.sort(options, function(a, b) return a < b; end);
	else
		options = {};
	end;
	
	self.stored[index] = {
		Condition = Condition,
		category = category,
		toolTip = toolTip,
		options = options,
		conVar = conVar,
		class = "multiChoice",
		text = text
	};
	
	return index;
end;

-- A function to add a number wang setting.
function Clockwork.setting:AddNumberWang(category, text, conVar, minimum, maximum, decimals, toolTip, Condition)
	local index = #self.stored + 1;
	
	self.stored[index] = {
		Condition = Condition,
		category = category,
		decimals = decimals,
		toolTip = toolTip,
		maximum = maximum,
		minimum = minimum,
		conVar = conVar,
		class = "numberWang",
		text = text
	};
	
	return index;
end;

-- A function to add a text entry setting.
function Clockwork.setting:AddTextEntry(category, text, conVar, toolTip, Condition)
	local index = #self.stored + 1;
	
	self.stored[index] = {
		Condition = Condition,
		category = category,
		toolTip = toolTip,
		conVar = conVar,
		class = "textEntry",
		text = text
	};
	
	return index;
end;

-- A function to add a check box setting.
function Clockwork.setting:AddCheckBox(category, text, conVar, toolTip, Condition)
	local index = #self.stored + 1;
	
	self.stored[index] = {
		Condition = Condition,
		category = category,
		toolTip = toolTip,
		conVar = conVar,
		class = "checkBox",
		text = text
	};
	
	return index;
end;

-- A function to remove a setting by its index.
function Clockwork.setting:RemoveByIndex(index)
	self.stored[index] = nil;
end;

-- A function to remove a setting by its convar.
function Clockwork.setting:RemoveByConVar(conVar)
	for k, v in pairs(self.stored) do
		if (v.conVar == conVar) then
			self.stored[k] = nil;
		end;
	end;
end;

-- A function to remove a setting.
function Clockwork.setting:Remove(category, text, class, conVar)
	for k, v in pairs(self.stored) do
		if ((!category or v.category == category)
		and (!conVar or v.conVar == conVar)
		and (!class or v.class == class)
		and (!text or v.text == text)) then
			self.stored[k] = nil;
		end;
	end;
end;

Clockwork.setting:AddNumberSlider("Framework", "Headbob Amount:", "cwHeadbobScale", 0, 1, 1, "The amount to scale the headbob by.");
Clockwork.setting:AddNumberSlider("Chat Box", "Chat Lines:", "cwMaxChatLines", 1, 10, 0, "The amount of chat lines shown at once.");

Clockwork.setting:AddCheckBox("Framework", "Enable the admin console log.", "cwShowLog", "Whether or not to show the admin console log.", function()
	return Clockwork.player:IsAdmin(Clockwork.Client);
end);

Clockwork.setting:AddCheckBox("Framework", "Enable the twelve hour clock.", "cwTwelveHourClock", "Whether or not to show a twelve hour clock.");
Clockwork.setting:AddCheckBox("Framework", "Show bars at the top of the screen.", "cwTopBars", "Whether or not to show bars at the top of the screen.");
Clockwork.setting:AddCheckBox("Framework", "Enable the hints system.", "cwShowHints", "Whether or not to show you any hints.");
Clockwork.setting:AddCheckBox("Chat Box", "Show timestamps on messages.", "cwShowTimeStamps", "Whether or not to show you timestamps on messages.");
Clockwork.setting:AddCheckBox("Chat Box", "Show messages related to Clockwork.", "cwShowClockwork", "Whether or not to show you any Clockwork messages.");
Clockwork.setting:AddCheckBox("Chat Box", "Show messages from the server.", "cwShowServer", "Whether or not to show you any server messages.");
Clockwork.setting:AddCheckBox("Chat Box", "Show out-of-character messages.", "cwShowOOC", "Whether or not to show you any out-of-character messages.");
Clockwork.setting:AddCheckBox("Chat Box", "Show in-character messages.", "cwShowIC", "Whether or not to show you any in-character messages.");

Clockwork.setting:AddCheckBox("Framework", "Enable the admin ESP.", "cwAdminESP", "Whether or not to show the admin ESP.", function()
	return Clockwork.player:IsAdmin(Clockwork.Client);
end);