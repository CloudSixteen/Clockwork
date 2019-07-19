--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

cwAreaDisplays.activeDisplays = {};
cwAreaDisplays.expiredList = Clockwork.kernel:RestoreSchemaData("plugins/displays/"..game.GetMap());

Clockwork.setting:AddCheckBox("Framework", "EnableAreaDisplay", "cwShowAreas", "EnableAreaDisplayDesc");

Clockwork.datastream:Hook("AreaDisplays", function(data)
	for k, v in pairs(data) do
		if (cwAreaDisplays:HasExpired(v)) then
			data[k] = nil;
		end;
	end;
	
	cwAreaDisplays.storedList = data;
end);

Clockwork.datastream:Hook("AreaAdd", function(data)
	if (!cwAreaDisplays:HasExpired(data)) then
		cwAreaDisplays.storedList[#cwAreaDisplays.storedList + 1] = data;
		cwAreaDisplays:AddAreaDisplayDisplay(data);
	end;
end);

Clockwork.datastream:Hook("AreaRemove", function(data)
	for k, v in pairs(cwAreaDisplays.storedList) do
		if (v.name == data.name and v.minimum == data.minimum
		and v.maximum == data.maximum) then
			cwAreaDisplays.storedList[k] = nil;
		end;
	end;
end);

-- A function to add an area name display.
function cwAreaDisplays:AddAreaDisplayDisplay(areaTable)
	areaTable.name = string.Replace(
		areaTable.name, "%t", Clockwork.time:GetString()
	);
	
	if (!areaTable.class) then
		areaTable.class = "Scrolling";
	end;
	
	if (areaTable.class == "Cinematic") then
		Clockwork.kernel:AddCinematicText(areaTable.name);
		return;
	end;
	
	local uniqueID = tostring(areaTable.position);
	local curTime = UnPredictedCurTime();
	
	if (!self.activeDisplays[uniqueID]) then
		self.activeDisplays[uniqueID] = {
			targetAlpha = 255,
			areaTable = areaTable,
			fadeTime = curTime + 4,
			class = areaTable.class,
			alpha = 0,
		};
	end;
end;

-- A function to calculate the alpha of a display.
function cwAreaDisplays:CalculateDisplayAlpha(displayInfo, index)
	if (displayInfo.targetAlpha == 255) then
		displayInfo.alpha = math.Clamp(1 - ((displayInfo.fadeTime - CurTime()) / 4), 0, 1) * 255;
		
		if (displayInfo.alpha == 255) then
			displayInfo.targetAlpha = 0;
			displayInfo.goBackTime = CurTime() + 6;
			displayInfo.fadeTime = nil;
		end;
	elseif (CurTime() >= displayInfo.goBackTime) then
		if (!displayInfo.fadeTime) then
			displayInfo.fadeTime = CurTime() + 2;
		end;
		
		displayInfo.alpha = 255 - (math.Clamp(1 - ((displayInfo.fadeTime - CurTime()) / 2), 0, 1) * 255);
		
		if (displayInfo.alpha == 0) then
			self.activeDisplays[index] = nil;
		end;
	end;
end;

-- A function to handle an area table.
function cwAreaDisplays:HandleAreaTable(areaTable, index)
	local bCalledHooks = false;
	
	if (!areaTable.doesExpire) then
		self.currentAreaDisplay = areaTable.name;
		
		Clockwork.plugin:Call(
			"PlayerEnteredArea", areaTable.name, areaTable.minimum, areaTable.maximum
		);
		
		bCalledHooks = true;
	end;
	
	if (CW_CONVAR_SHOWAREAS:GetInt() == 1 or areaTable.doesExpire) then
		self:AddAreaDisplayDisplay(areaTable);
	end;
	
	self:SetExpired(index);
	
	if (bCalledHooks) then
		return true;
	end;
end;

-- A function to draw a 3D display.
function cwAreaDisplays:DrawDisplay3D(displayInfo)
	local large3D2DFont = Clockwork.option:GetFont("large_3d_2d");
	local colorWhite = Clockwork.option:GetColor("white");
	local eyeAngles = EyeAngles();
	local eyePos = EyePos();
	
	--[[ We want the font to be the 3D one... --]]
	Clockwork.kernel:OverrideMainFont(large3D2DFont);
	
	cam.Start3D(eyePos, eyeAngles);
		local areaTable = displayInfo.areaTable;
		
		cam.Start3D2D(areaTable.position, areaTable.angles, (areaTable.scale or 1) * 0.2);
			Clockwork.kernel:DrawInfo(areaTable.name, 0, 0, colorWhite, displayInfo.alpha, nil,
				function(x, y, width, height)
					return x, y - (height / 2);
				end, 3
			);
		cam.End3D2D();
	cam.End3D();
	
	Clockwork.kernel:OverrideMainFont(false);
end;

-- A function to draw a scrolling display.
function cwAreaDisplays:DrawDisplayScrolling(displayInfo, info)
	local introTinyTextFont = Clockwork.option:GetFont("intro_text_tiny")
	Clockwork.kernel:OverrideMainFont(introTinyTextFont);
	
	local informationColor = Clockwork.option:GetColor("information");
	local bIsGoingBack = (displayInfo.goBackTime and CurTime() >= displayInfo.goBackTime);
	local colorWhite = Clockwork.option:GetColor("white");
	local areaTable = displayInfo.areaTable;

	if (!displayInfo.scrollInfo) then
		displayInfo.scrollInfo = {
			index = 0,
			text = "",
		};
	end;
	
	if (bIsGoingBack and !displayInfo.scrollInfo.isGoingBack) then
		displayInfo.scrollInfo.isGoingBack = true;
		displayInfo.scrollInfo.index = 0;
	end;
	
	if (!displayInfo.scrollInfo.nextType or CurTime() >= displayInfo.scrollInfo.nextType) then
		displayInfo.scrollInfo.nextType = CurTime() + 0.1;
		displayInfo.scrollInfo.index = displayInfo.scrollInfo.index + 1;
		
		if (displayInfo.scrollInfo.isGoingBack) then
			displayInfo.scrollInfo.text = string.utf8sub(
				areaTable.name, displayInfo.scrollInfo.index + 1
			);
		else
			displayInfo.scrollInfo.text = string.utf8sub(
				areaTable.name, 0, displayInfo.scrollInfo.index
			);
		end;
		
		if (displayInfo.scrollInfo.index < #areaTable.name) then
			surface.PlaySound("common/talk.wav");
		end;
	end;
	
	local defaultWidth, defaultHeight = Clockwork.kernel:GetCachedTextSize(
		introTinyTextFont, string.upper(areaTable.name)
	);
	local scrollWidth, scrollHeight = Clockwork.kernel:GetCachedTextSize(
		introTinyTextFont, string.upper(displayInfo.scrollInfo.text)
	);
	local sNextCharacter = "";
	local newX = info.x;
	
	if (displayInfo.scrollInfo.isGoingBack) then
		sNextCharacter = string.utf8sub(
			areaTable.name, displayInfo.scrollInfo.index, displayInfo.scrollInfo.index
		);
		
		local _, textWidth = Clockwork.kernel:DrawInfo(
			string.upper(sNextCharacter), info.x, info.y, informationColor,
			math.max(displayInfo.alpha - 25, 0), true, function(x, y, width, height)
				return x + (defaultWidth - scrollWidth) - width, y;
			end
		);
		
		newX = newX + (defaultWidth - scrollWidth);
	else
		sNextCharacter = string.utf8sub(
			areaTable.name, displayInfo.scrollInfo.index + 1, displayInfo.scrollInfo.index + 1
		);
	end;
	
	local newY, textWidth = Clockwork.kernel:DrawInfo(
		string.upper(displayInfo.scrollInfo.text), newX, info.y, colorWhite, displayInfo.alpha, true
	);
	
	if (!displayInfo.scrollInfo.isGoingBack and sNextCharacter != "") then
		Clockwork.kernel:DrawInfo(
			string.upper(sNextCharacter), newX + textWidth, info.y, informationColor, math.max(displayInfo.alpha - 25, 0), true
		);
	end;
	
	Clockwork.kernel:OverrideMainFont(false);
	info.y = newY;
end;

-- A function to get whether an area display has expired.
function cwAreaDisplays:HasExpired(areaDisplay)
	if (areaDisplay and areaDisplay.doesExpire) then
		local position = tostring(areaDisplay.position);

		if (self.expiredList[position] == areaDisplay.name) then
			return true;
		end;
	end;
	
	return false;
end;

-- A function to set an area display as expired.
function cwAreaDisplays:SetExpired(index)
	local areaDisplay = self.storedList[index];
	
	if (areaDisplay and areaDisplay.doesExpire) then
		local position = tostring(areaDisplay.position);
		local name = areaDisplay.name;
		
		self.storedList[index] = nil;
		self.expiredList[position] = name;
		
		Clockwork.kernel:SaveSchemaData("plugins/displays/"..game.GetMap(), self.expiredList);
	end;
end;