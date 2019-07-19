--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local table = table;

Clockwork.setting = Clockwork.kernel:NewLibrary("Setting");
Clockwork.setting.stored = Clockwork.setting.stored or {};

--[[
	@codebase Client
	@details A function to add a number slider setting.
	@param {Unknown} Missing description for category.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for conVar.
	@param {Unknown} Missing description for minimum.
	@param {Unknown} Missing description for maximum.
	@param {Unknown} Missing description for decimals.
	@param {Unknown} Missing description for toolTip.
	@param {Unknown} Missing description for Condition.
	@returns {Unknown}
--]]
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

--[[
	@codebase Client
	@details A function to add a multi-choice setting.
	@param {Unknown} Missing description for category.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for conVar.
	@param {Unknown} Missing description for options.
	@param {Unknown} Missing description for toolTip.
	@param {Unknown} Missing description for Condition.
	@returns {Unknown}
--]]
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

--[[
	@codebase Client
	@details A function to add a number wang setting.
	@param {Unknown} Missing description for category.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for conVar.
	@param {Unknown} Missing description for minimum.
	@param {Unknown} Missing description for maximum.
	@param {Unknown} Missing description for decimals.
	@param {Unknown} Missing description for toolTip.
	@param {Unknown} Missing description for Condition.
	@returns {Unknown}
--]]
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

--[[
	@codebase Client
	@details A function to add a text entry setting.
	@param {Unknown} Missing description for category.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for conVar.
	@param {Unknown} Missing description for toolTip.
	@param {Unknown} Missing description for Condition.
	@returns {Unknown}
--]]
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

--[[
	@codebase Client
	@details A function to add a check box setting.
	@param {Unknown} Missing description for category.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for conVar.
	@param {Unknown} Missing description for toolTip.
	@param {Unknown} Missing description for Condition.
	@returns {Unknown}
--]]
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

--[[
	@codebase Client
	@details A function to add a color mixer setting.
	@param {Unknown} Missing description for category.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for conVar.
	@param {Unknown} Missing description for toolTip.
	@param {Unknown} Missing description for Condition.
	@returns {Unknown}
--]]
function Clockwork.setting:AddColorMixer(category, text, conVar, toolTip, Condition)
	local index = #self.stored + 1;

	self.stored[index] = {
		Condition = Condition,
		category = category,
		toolTip = toolTip,
		conVar = conVar,
		class = "colorMixer",
		text = text
	};

	return index;
end;

--[[
	@codebase Client
	@details A function to remove a setting by its index.
	@param {Unknown} Missing description for index.
	@returns {Unknown}
--]]
function Clockwork.setting:RemoveByIndex(index)
	self.stored[index] = nil;
end;

--[[
	@codebase Client
	@details A function to remove a setting by its convar.
	@param {Unknown} Missing description for conVar.
	@returns {Unknown}
--]]
function Clockwork.setting:RemoveByConVar(conVar)
	for k, v in pairs(self.stored) do
		if (v.conVar == conVar) then
			self.stored[k] = nil;
		end;
	end;
end;

--[[
	@codebase Client
	@details A function to remove a setting.
	@param {Unknown} Missing description for category.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for class.
	@param {Unknown} Missing description for conVar.
	@returns {Unknown}
--]]
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

function Clockwork.setting:AddSettings()
	if (!Clockwork.setting.wereSettingsAdded) then
		local langTable = {};

		for k, v in pairs(Clockwork.lang:GetAll()) do
			table.insert(langTable, k);
		end;

		local themeTable = {};

		for k, v in pairs(Clockwork.theme:GetAll()) do
			table.insert(themeTable, k);
		end;

		local categoryFramework = "Framework";
		local categoryAdminESP = "AdminESP";
		local categoryChatBox = "ChatBox";
		local categoryTheme = "Theme";

		Clockwork.setting:AddNumberSlider(categoryFramework, "HeadbobAmount", "cwHeadbobScale", 0, 1, 1, "HeadbobAmountDesc");
		Clockwork.setting:AddNumberSlider(categoryChatBox, "ChatLines", "cwMaxChatLines", 1, 10, 0, "ChatLinesDesc");

		Clockwork.setting:AddCheckBox(categoryFramework, "EnableAdminConsoleLog", "cwShowLog", "EnableAdminConsoleLogDesc", function()
			return Clockwork.player:IsAdmin(Clockwork.Client);
		end);

		Clockwork.setting:AddCheckBox(categoryFramework, "EnableTwelveHourClock", "cwTwelveHourClock", "EnableTwelveHourClockDesc");
		Clockwork.setting:AddCheckBox(categoryFramework, "ShowTopBars", "cwTopBars", "ShowTopBarsDesc");
		Clockwork.setting:AddCheckBox(categoryFramework, "EnableHintsSystem", "cwShowHints", "EnableHintsSystemDesc");
		Clockwork.setting:AddMultiChoice(categoryFramework, "Language", "cwLang", langTable, "LangDesc");
		Clockwork.setting:AddCheckBox(categoryFramework, "EnableVignette", "cwShowVignette", "EnableVignetteDesc");
		
		Clockwork.setting:AddCheckBox(categoryChatBox, "ShowMessageTimeStamps", "cwShowTimeStamps", "ShowMessageTimeStampsDesc");
		Clockwork.setting:AddCheckBox(categoryChatBox, "ShowClockworkMessages", "cwShowClockwork", "ShowClockworkMessagesDesc");
		Clockwork.setting:AddCheckBox(categoryChatBox, "ShowServerMessages", "cwShowServer", "ShowServerMessagesDesc");
		Clockwork.setting:AddCheckBox(categoryChatBox, "ShowOOCMessages", "cwShowOOC", "ShowClockworkMessagesDesc");
		Clockwork.setting:AddCheckBox(categoryChatBox, "ShowICMessages", "cwShowIC", "ShowICMessagesDesc");

		Clockwork.setting:AddMultiChoice(categoryTheme, categoryTheme, "cwActiveTheme", themeTable, "ThemeDesc", function ()
			return (Clockwork.config:Get("modify_themes"):GetBoolean());
		end);
		
		--[[
		Clockwork.setting:AddColorMixer(categoryTheme, "Text Color:", "cwTextColor", "The Text Color", function()
			return (!Clockwork.theme:IsFixed());
		end);
		
		Clockwork.setting:AddColorMixer(categoryTheme, "Background Color:", "cwBackColor", "The Background Color");
		Clockwork.setting:AddNumberSlider(categoryTheme, "TabMenu X-Axis:", "cwTabPosX", 0, ScrW(), 0, "The position of the tab menu on the X axis.");
		Clockwork.setting:AddNumberSlider(categoryTheme, "TabMenu Y-Axis:", "cwTabPosY", 0, ScrH(), 0, "The position of the tab menu on the Y axis.");
		Clockwork.setting:AddNumberSlider(categoryTheme, "BackMenu X-Axis:", "cwBackX", 0, ScrW(), 0, "The position of the background on the X axis.");
		Clockwork.setting:AddNumberSlider(categoryTheme, "BackMenu Y-Axis:", "cwBackY", 0, ScrH(), 0, "The position of the background on the Y axis.");
		Clockwork.setting:AddNumberSlider(categoryTheme, "BackMenu Width:", "cwBackW", 0, ScrW(), 0, "The width of the background.");
		Clockwork.setting:AddNumberSlider(categoryTheme, "BackMenu Height:", "cwBackH", 0, ScrH(), 0, "The height of the background.");
		Clockwork.setting:AddCheckBox(categoryTheme, "Fade Panels:", "cwFadePanels", "Whether or not to fade in and out menu panels.");
		Clockwork.setting:AddCheckBox(categoryTheme, "Show Material:", "cwShowMaterial", "Whether or not to show a material background.");
		Clockwork.setting:AddCheckBox(categoryTheme, "Show Gradient:", "cwShowGradient", "Whether or not to show a gradient background.");
		Clockwork.setting:AddTextEntry(categoryTheme, "Material:", "cwMaterial", "The material to be used for the tab menu.");
		--]]
		
		Clockwork.setting:AddCheckBox(categoryAdminESP, "EnableAdminESP", "cwAdminESP", "EnableAdminESPDesc", function()
			return Clockwork.player:IsAdmin(Clockwork.Client);
		end);

		Clockwork.setting:AddCheckBox(categoryAdminESP, "DrawESPBars", "cwESPBars", "DrawESPBarsDesc", function()
			return Clockwork.player:IsAdmin(Clockwork.Client);
		end);

		Clockwork.setting:AddCheckBox(categoryAdminESP, "ShowItemEntities", "cwItemESP", "ShowItemEntitiesDesc", function()
			return Clockwork.player:IsAdmin(Clockwork.Client);
		end);

		Clockwork.setting:AddCheckBox(categoryAdminESP, "ShowSalesmenEntities", "cwSaleESP", "ShowSalesmenEntitiesDesc", function()
			return Clockwork.player:IsAdmin(Clockwork.Client);
		end);

		Clockwork.setting:AddNumberSlider(categoryAdminESP, "ESPInterval", "cwESPTime", 0, 2, 0, "ESPIntervalDesc", function()
			return Clockwork.player:IsAdmin(Clockwork.Client);
		end);

		Clockwork.setting.wereSettingsAdded = true;
	end;
end;
