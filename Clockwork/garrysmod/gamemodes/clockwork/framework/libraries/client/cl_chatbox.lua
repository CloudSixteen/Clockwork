--[[ 
	� 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local UnPredictedCurTime = UnPredictedCurTime;
local RunConsoleCommand = RunConsoleCommand;
local Material = Material;
local IsValid = IsValid;
local unpack = unpack;
local Color = Color;
local pairs = pairs;
local type = type;
local ScrH = ScrH;
local ScrW = ScrW;
local surface = surface;
local string = string;
local input = input;
local table = table;
local hook = hook;
local math = math;
local vgui = vgui;

--[[ We need the datastream library to add the hooks! --]]
if (!Clockwork.datastream) then
	include("clockwork/framework/libraries/sh_datastream.lua");
end;

Clockwork.chatBox = Clockwork.kernel:NewLibrary("ChatBox");
	Clockwork.chatBox.classes = {};
	Clockwork.chatBox.defaultClasses = {}
	Clockwork.chatBox.messages = {};
	Clockwork.chatBox.historyPos = 0;
	Clockwork.chatBox.historyMsgs = {};
	Clockwork.chatBox.spaceWidths = {};
chat.ClockworkAddText = chat.AddText;

-- A function to add text to the chat box.
function chat.AddText(...)
	local curColor = nil;
	local text = {};
	
	for k, v in pairs({...}) do
		if (type(v) == "Player") then
			text[#text + 1] = cwTeam.GetColor(v:Team());
			text[#text + 1] = v:Name();
		elseif (type(v) == "table") then
			curColor = v;
		elseif (curColor) then
			text[#text + 1] = curColor;
			text[#text + 1] = v;
		else
			text[#text + 1] = v;
		end;
	end;

	Clockwork.chatBox:Add(nil, nil, unpack(text));
end;

-- A function to register a chat box class.
function Clockwork.chatBox:RegisterClass(class, filter, Callback)
	self.classes[class] = {
		Callback = Callback,
		filter = filter
	};
end;

-- A function to register a default chat box class.
function Clockwork.chatBox:RegisterDefaultClass(class, filter, Callback)
	self.defaultClasses[class] = {
		Callback = Callback,
		filter = filter
	};
end;

-- A function to set the chat box's custom position.
function Clockwork.chatBox:SetCustomPosition(x, y)
	self.position = {
		x = x,
		y = y
	};
end;

-- A function to get the chat box's custom position.
function Clockwork.chatBox:GetCustomPosition()
	return self.position;
end;

-- A function to reset the chat box's custom position.
function Clockwork.chatBox:ResetCustomPosition()
	self.position = nil;
end;

-- A function to get the position of the chat area.
function Clockwork.chatBox:GetPosition(addX, addY)
	local customPosition = Clockwork.chatBox:GetCustomPosition();
	local x, y = 8, ScrH() * 0.75;
	
	if (customPosition) then
		x = customPosition.x;
		y = customPosition.y;
	end;
	
	return x + (addX or 0), y + (addY or 0);
end;

-- A function to get the chat box panel.
function Clockwork.chatBox:GetPanel()
	if (IsValid(self.panel)) then
		return self.panel;
	end;
end;

-- A function to get the x position of the chat area.
function Clockwork.chatBox:GetX()
	local x, y = Clockwork.chatBox:GetPosition();
	return x;
end;

-- A function to get the y position of the chat area.
function Clockwork.chatBox:GetY()
	local x, y = Clockwork.chatBox:GetPosition();
	return y;
end;

-- A function to get the current text.
function Clockwork.chatBox:GetCurrentText()
	local textEntry = self.textEntry;
	
	if (textEntry:IsVisible() and Clockwork.chatBox:IsOpen()) then
		return textEntry:GetValue();
	else
		return "";
	end;
end;

-- A function to get whether the player is typing a command.
function Clockwork.chatBox:IsTypingCommand()
	local currentText = Clockwork.chatBox:GetCurrentText();
	local prefix = Clockwork.config:Get("command_prefix"):Get();
	
	if (string.sub(currentText, 1, string.len(prefix)) == prefix) then
		return true;
	else
		return false;
	end;
end;

-- A function to get the spacing between messages.
function Clockwork.chatBox:GetSpacing(fontName)
	local chatBoxTextFont = fontName or Clockwork.option:GetFont("chat_box_text");
	local textWidth, textHeight = Clockwork.kernel:GetCachedTextSize(chatBoxTextFont, "U");
	
	if (textWidth and textHeight) then
		return textHeight + 4;
	end;
end;

-- A function to create all of the derma.
function Clockwork.chatBox:CreateDermaAll()
	Clockwork.chatBox:CreateDermaPanel();
	Clockwork.chatBox:CreateDermaTextEntry();

	self.panel:Hide();
end;

-- A function to create a derma text entry.
function Clockwork.chatBox:CreateDermaTextEntry()
	if (!self.textEntry) then
		self.textEntry = vgui.Create("DTextEntry", self.panel);
		self.textEntry:SetPos(34, 4);
		self.textEntry:SetTabPosition(1);
		self.textEntry:SetAllowNonAsciiCharacters(true);
		
		-- Called each frame.
		self.textEntry.Think = function(textEntry)
			local maxChatLength = Clockwork.config:Get("max_chat_length"):Get();
			local text = textEntry:GetValue();
			
			if (string.len(text) > maxChatLength) then
				textEntry:SetRealValue(string.sub(text, 0, maxChatLength));
				surface.PlaySound("common/talk.wav");
			elseif (self:IsOpen()) then
				if (text != textEntry.previousText) then
					Clockwork.plugin:Call("ChatBoxTextChanged", textEntry.previousText or "", text);
				end;
			end;
			
			textEntry.previousText = text;
		end;
		
		-- Called when enter has been pressed.
		self.textEntry.OnEnter = function(textEntry)
			local text = textEntry:GetValue();
			
			if (text and text != "") then
				self.historyPos = #self.historyMsgs;
				
				--local replaceText = Clockwork.kernel:Replace(text, "\"", "~");
				Clockwork.datastream:Start("PlayerSay", text);
				--RunConsoleCommand("say", replaceText);
				
				Clockwork.plugin:Call("ChatBoxTextTyped", text);
				textEntry:SetRealValue("");
			end;
			
			if (text and text != "") then
				self.panel:Hide(true);
			else
				self.panel:Hide();
			end;
		end;
		
		-- A function to set the text entry's real value.
		self.textEntry.SetRealValue = function(textEntry, text, limit)
			textEntry:SetText(text);
			
			if (limit) then
				if (textEntry:GetCaretPos() > string.len(text)) then
					textEntry:SetCaretPos(string.len(text));
				end;
			else
				textEntry:SetCaretPos(string.len(text));
			end;
		end;
		
		-- Called when a key code has been typed.
		self.textEntry.OnKeyCodeTyped = function(textEntry, code)
			if (code == KEY_ENTER and !textEntry:IsMultiline() and textEntry:GetEnterAllowed()) then
				textEntry:FocusNext();
				textEntry:OnEnter();
			elseif (code == KEY_TAB) then
				local text = textEntry:GetValue();
				local prefix = Clockwork.config:Get("command_prefix"):Get();
				
				if (string.sub(text, 1, string.len(prefix)) == prefix) then
					local exploded = string.Explode(" ", text);
					
					if (!exploded[2]) then
						local commands = Clockwork.kernel:GetSortedCommands();
						local bUseNext = false;
						local firstCmd = nil;
						local command = string.sub(exploded[1], string.len(prefix) + 1);
						
						command = string.lower(command);
						
						for k, v in pairs(commands) do
							v = string.lower(v);
							
							if (!firstCmd) then
								firstCmd = v;
							end;
							
							if ((string.len(command) < string.len(v)
							and string.find(v, command) == 1) or bUseNext) then
								textEntry:SetRealValue(prefix..v);
								return;
							elseif (v == string.lower(command)) then
								bUseNext = true;
							end
						end
						
						if (bUseNext and firstCmd) then
							textEntry:SetRealValue(prefix..firstCmd);
							return;
						end
					end;
				end;
				
				text = Clockwork.plugin:Call("OnChatTab", text);
				
				if (text and type(text) == "string") then
					textEntry:SetRealValue(text)
				end;
			else
				local text = hook.Call("ChatBoxKeyCodeTyped", Clockwork, code, textEntry:GetValue());
				
				if (text and type(text) == "string") then
					textEntry:SetRealValue(text)
				end;
			end;
		end;
	end;
end;

-- A function to create the derma panel.
function Clockwork.chatBox:CreateDermaPanel()
	if (!self.panel) then
		self.panel = vgui.Create("EditablePanel");
		
		-- A function to show the chat panel.
		self.panel.Show = function(editablePanel)
			editablePanel:SetKeyboardInputEnabled(true);
			editablePanel:SetMouseInputEnabled(true);
			editablePanel:SetVisible(true);
			editablePanel:MakePopup();
			
			self.textEntry:RequestFocus();
			self.scroll:SetVisible(true);
			self.historyPos = #self.historyMsgs;
			
			if (IsValid(Clockwork.Client)) then
				Clockwork.plugin:Call("ChatBoxOpened");
			end;
		end;
		
		-- A function to hide the chat panel.
		self.panel.Hide = function(editablePanel, textTyped)
			editablePanel:SetKeyboardInputEnabled(false);
			editablePanel:SetMouseInputEnabled(false);
			editablePanel:SetVisible(false);
			
			self.textEntry:SetText("");
			self.scroll:SetVisible(false);
			
			if (IsValid(Clockwork.Client)) then
				Clockwork.plugin:Call("ChatBoxClosed", textTyped);
			end;
		end;
		
		-- Called each time the panel should be painted.
		self.panel.Paint = function(editablePanel)
			Clockwork.kernel:DrawSimpleGradientBox(2, 0, 0, editablePanel:GetWide(), editablePanel:GetTall(), Clockwork.option:GetColor("background"));
		end;
		
		-- Called every frame.
		self.panel.Think = function(editablePanel)
			local panelWidth = ScrW() / 4;
			local x, y = self:GetPosition();
			
			editablePanel:SetPos(x, y + 6);
			editablePanel:SetSize(panelWidth + 8, 24);
			self.textEntry:SetPos(4, 4);
			self.textEntry:SetSize(panelWidth, 16);
			
			if (editablePanel:IsVisible() and input.IsKeyDown(KEY_ESCAPE)) then
				editablePanel:Hide();
			end;
		end;
		
		self.scroll = vgui.Create("Panel");
		self.scroll:SetPos(0, 0);
		self.scroll:SetSize(0, 0);
		self.scroll:SetMouseInputEnabled(true);
		
		-- Called when the panel is scrolled with the mouse wheel.
		self.scroll.OnMouseWheeled = function(panel, delta)
			local bIsOpen = self:IsOpen();
			local maximumLines = math.Clamp(CW_CONVAR_MAXCHATLINES:GetInt(), 1, 10);
			
			if (bIsOpen) then
				if (delta > 0) then
					delta = math.Clamp(delta, 1, maximumLines);
					
					if (self.historyMsgs[self.historyPos - maximumLines]) then
						self.historyPos = self.historyPos - delta;
					end;
				else
					if (!self.historyMsgs[self.historyPos - delta]) then
						delta = -1;
					end;
					
					if (self.historyMsgs[self.historyPos - delta]) then
						self.historyPos = self.historyPos - delta;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to get whether the chat box is open.
function Clockwork.chatBox:IsOpen()
	return self.panel and self.panel:IsVisible();
end;

-- A function to decode a message.
function Clockwork.chatBox:Decode(speaker, name, text, data, class, multiplier)
	local filtered = nil;
	local filter = nil;
	local icon = nil;
	
	if (!IsValid(Clockwork.Client)) then
		return;
	end;
	
	if (self.classes[class]) then
		filter = self.classes[class].filter;
	elseif (self.defaultClasses[class]) then
		filter = self.defaultClasses[class].filter;
	elseif (class == "pm" or class == "ooc"	or class == "roll"
		or class == "looc" or class == "priv") then
		filtered = (CW_CONVAR_SHOWOOC:GetInt() == 0);
		filter = "ooc";
	else
		filtered = (CW_CONVAR_SHOWIC:GetInt() == 0);
		filter = "ic";
	end;
	
	text = Clockwork.kernel:Replace(text, " ' ", "'");
	
	if (IsValid(speaker)) then
		if (!Clockwork.kernel:IsChoosingCharacter()) then
			if (speaker:Name() != "") then
				local unrecognised = false;
				local classIndex = speaker:Team();
				local classColor = cwTeam.GetColor(classIndex);
				local focusedOn = false;
				
				if (speaker:IsSuperAdmin()) then
					icon = "icon16/shield.png";
				elseif (speaker:IsAdmin()) then
					icon = "icon16/star.png";
				elseif (speaker:IsUserGroup("operator")) then
					icon = "icon16/emoticon_smile.png";
				else
					local faction = speaker:GetFaction();
					
					if (faction and Clockwork.faction.stored[faction]) then
						if (Clockwork.faction.stored[faction].whitelist) then
							icon = "icon16/add.png";
						end;
					end;
					
					if (!icon) then
						icon = "icon16/user.png";
					end;
				end;
				
				if (!Clockwork.player:DoesRecognise(speaker, RECOGNISE_TOTAL) and filter == "ic") then
					unrecognised = true;
				end;
				
				local trace = Clockwork.player:GetRealTrace(Clockwork.Client);
				
				if (trace and trace.Entity and IsValid(trace.Entity) and trace.Entity == speaker) then
					focusedOn = true;
				end;
				
				local info = {
					unrecognised = unrecognised,
					shouldHear = Clockwork.player:CanHearPlayer(Clockwork.Client, speaker),
					multiplier = multiplier,
					focusedOn = focusedOn,
					filtered = filtered,
					speaker = speaker,
					visible = true;
					filter = filter,
					class = class,
					icon = icon,
					name = name,
					text = text,
					data = data
				};
				
				Clockwork.plugin:Call("ChatBoxAdjustInfo", info);
				
				if (Clockwork.config:Get("chat_multiplier"):Get()) then
					Clockwork.chatBox:SetMultiplier(info.multiplier);
				end;
				
				if (info.visible) then
					if (info.filter == "ic") then
						if (!Clockwork.Client:Alive()) then
							return;
						end;
					end;
					
					if (info.unrecognised) then
						local unrecognisedName, usedPhysDesc = Clockwork.player:GetUnrecognisedName(info.speaker);
						
						if (usedPhysDesc and string.len(unrecognisedName) > 24) then
							unrecognisedName = string.sub(unrecognisedName, 1, 21).."...";
						end;
						
						info.name = "["..unrecognisedName.."]";
					end;
					
					if (self.classes[info.class]) then
						self.classes[info.class].Callback(info);
					elseif (self.defaultClasses[info.class]) then
						self.defaultClasses[info.class].Callback(info);
						
					elseif (info.class == "radio_eavesdrop") then
						if (info.shouldHear) then
							local color = Color(255, 255, 175, 255);
							
							if (info.focusedOn) then
								color = Color(175, 255, 175, 255);
							end;
							
							Clockwork.chatBox:Add(info.filtered, nil, color, info.name.." radios in \""..info.text.."\"");
						end;
					elseif (info.class == "whisper") then
						if (info.shouldHear) then
							local color = Color(255, 255, 175, 255);
							
							if (info.focusedOn) then
								color = Color(175, 255, 175, 255);
							end;
							
							Clockwork.chatBox:Add(info.filtered, nil, color, info.name.." whispers \""..info.text.."\"");
						end;
					elseif (info.class == "event") then
						Clockwork.chatBox:Add(info.filtered, nil, Color(200, 100, 50, 255), info.text);
					elseif (info.class == "localevent") then
						Clockwork.chatBox:Add(info.filtered, nil, Color(200, 100, 50, 255), "(LOCAL) "..info.text);
					elseif (info.class == "radio") then
						Clockwork.chatBox:Add(info.filtered, nil, Color(75, 150, 50, 255), info.name.." radios in \""..info.text.."\"");
					elseif (info.class == "yell") then
						local color = Color(255, 255, 175, 255);
						
						if (info.focusedOn) then
							color = Color(175, 255, 175, 255);
						end;
						Clockwork.chatBox:Add(info.filtered, nil, color, info.name.." yells \""..info.text.."\"");
					elseif (info.class == "chat") then
						Clockwork.chatBox:Add(info.filtered, nil, classColor, info.name, ": ", info.text, nil, info.filtered);
					elseif (info.class == "looc") then
						if (Clockwork.config:Get("enable_looc_icons"):Get()) then
							Clockwork.chatBox:Add(info.filtered, info.icon, Color(225, 50, 50, 255), "[LOOC] ", Color(255, 255, 150, 255), info.name..": "..info.text);
						else
							Clockwork.chatBox:Add(info.filtered, nil, Color(225, 50, 50, 255), "[LOOC] ", Color(255, 255, 150, 255), info.name..": "..info.text);
						end;
					elseif (info.class == "priv") then
						Clockwork.chatBox:Add(info.filtered, nil, Color(255, 200, 50, 255), "@"..info.data.userGroup.." ", classColor, info.name, ": ", info.text);
					elseif (info.class == "roll") then
						if (info.shouldHear) then
							Clockwork.chatBox:Add(info.filtered, nil, Color(150, 75, 75, 255), "** "..info.name.." "..info.text);
						end;
					elseif (info.class == "ooc") then
						Clockwork.chatBox:Add(info.filtered, info.icon, Color(225, 50, 50, 255), "[OOC] ", classColor, info.name, ": ", info.text);
					elseif (info.class == "pm") then
						Clockwork.chatBox:Add(info.filtered, nil, "[PM] ", Color(125, 150, 75, 255), info.name..": "..info.text);
						surface.PlaySound("hl1/fvox/bell.wav");
					elseif (info.class == "me") then
						local color = Color(255, 255, 175, 255);
						
						if (info.focusedOn) then
							color = Color(175, 255, 175, 255);
						end;
						
						if (string.sub(info.text, 1, 1) == "'") then
							Clockwork.chatBox:Add(info.filtered, nil, color, "*** "..info.name..info.text);
						else
							Clockwork.chatBox:Add(info.filtered, nil, color, "*** "..info.name.." "..info.text);
						end;
					elseif (info.class == "mec") then
						local color;
						if (!info.focusedOn) then
							color = Color(255, 255, 150, 255);
						else
							color = Color(175, 255, 175, 255);
						end;
						
						if (string.sub(info.text, 1, 1) == "'") then
							Clockwork.chatBox:Add(info.filtered, nil, color, "* "..info.name..info.text);
						else
							Clockwork.chatBox:Add(info.filtered, nil, color, "* "..info.name.." "..info.text);
						end;
					elseif (info.class == "mel") then
						local color;
						if (!info.focusedOn) then
							color = Color(255, 255, 150, 255);
						else
							color = Color(175, 255, 175, 255);
						end;
						
						if (string.sub(info.text, 1, 1) == "'") then
							Clockwork.chatBox:Add(info.filtered, nil, color, "***** "..info.name..info.text);
						else
							Clockwork.chatBox:Add(info.filtered, nil, color, "***** "..info.name.." "..info.text);
						end;

					elseif (info.class == "it") then
						local color = Color(255, 255, 175, 255);
						
						if (info.focusedOn) then
							color = Color(175, 255, 175, 255);
						end;
						
						Clockwork.chatBox:Add(info.filtered, nil, color, "***' "..info.text);
					elseif (info.class == "itc") then
						local color;
						if (!info.focusedOn) then
							color = Color(255, 255, 150, 255);
						else
							color = Color(175, 255, 175, 255);
						end;
						
						Clockwork.chatBox:Add(info.filtered, nil, color, "*' "..info.text);
					elseif (info.class == "itl") then
						local color;
						if (!info.focusedOn) then
							color = Color(255, 255, 150, 255);
						else
							color = Color(175, 255, 175, 255);
						end;
						
						Clockwork.chatBox:Add(info.filtered, nil, color, "*****' "..info.text);
					elseif (info.class == "ic") then
						if (info.shouldHear) then
							local color = Color(255, 255, 150, 255);
							
							if (info.focusedOn) then
								color = Color(175, 255, 150, 255);
							end;
							
							Clockwork.chatBox:Add(info.filtered, nil, color, info.name.." says \""..info.text.."\"");
						end;
					end;
				end;
			end;
		end;
	else
		if (name == "Console" and class == "chat") then
			icon = "icon16/shield.png";
		end;
		
		local info = {
			multiplier = multiplier,
			filtered = filtered,
			visible = true;
			filter = filter,
			class = class,
			icon = icon,
			name = name,
			text = text,
			data = data
		};
		
		Clockwork.plugin:Call("ChatBoxAdjustInfo", info);
		Clockwork.chatBox:SetMultiplier(info.multiplier);
		
		if (!info.visible) then return; end;
		
		if (self.classes[info.class]) then
			self.classes[info.class].Callback(info);
		elseif (self.defaultClasses[info.class]) then
			self.defaultClasses[info.class].Callback(info);

		elseif (info.class == "notify_all") then
			if (Clockwork.kernel:GetNoticePanel()) then
				Clockwork.kernel:AddCinematicText(info.text, Color(255, 255, 255, 255), 32, 6, Clockwork.option:GetFont("menu_text_tiny"), true);
			end;

			local filtered = (CW_CONVAR_SHOWAURA:GetInt() == 0) or info.filtered;
			local icon = info.data.icon or "comment";
			local color = Color(125, 150, 175, 255);

			if (string.sub(info.text, -1) == "!") then
				icon = info.data.icon or "error";
				color = Color(200, 175, 200, 255);
			end;

			Clockwork.chatBox:Add(filtered, "icon16/"..icon..".png", color, info.text);
		elseif (info.class == "disconnect") then
			local filtered = (CW_CONVAR_SHOWAURA:GetInt() == 0) or info.filtered;
			
			Clockwork.chatBox:Add(filtered, "icon16/user_delete.png", Color(200, 150, 200, 255), info.text);
		elseif (info.class == "notify") then
			if (Clockwork.kernel:GetNoticePanel()) then
				Clockwork.kernel:AddCinematicText(info.text, Color(255, 255, 255, 255), 32, 6, Clockwork.option:GetFont("menu_text_tiny"), true);
			end;
			
			local filtered = (CW_CONVAR_SHOWAURA:GetInt() == 0) or info.filtered;
			local icon = info.data.icon or "comment";
			local color = Color(175, 200, 255, 255);

			if (string.sub(info.text, -1) == "!") then
				icon = info.data.icon or "error";
				color = Color(200, 175, 200, 255);
			end;

			Clockwork.chatBox:Add(filtered, "icon16/"..icon..".png", color, info.text);
		elseif (info.class == "connect") then
			local filtered = (CW_CONVAR_SHOWAURA:GetInt() == 0) or info.filtered;
			Clockwork.chatBox:Add(filtered, "icon16/user_add.png", Color(150, 150, 200, 255), info.text);
		elseif (info.class == "chat") then
			Clockwork.chatBox:Add(info.filtered, info.icon, Color(225, 50, 50, 255), "[OOC] ", Color(150, 150, 150, 255), name, ": ", info.text);
		else
			local yellowColor = Color(255, 255, 150, 255);
			local blueColor = Color(125, 150, 175, 255);
			local redColor = Color(200, 25, 25, 255);
			local filtered = (CW_CONVAR_SHOWSERVER:GetInt() == 0) or info.filtered;
			local prefix;
			
			Clockwork.chatBox:Add(filtered, nil, yellowColor, info.text);
		end;
	end;
end;

-- A function to add and wrap text to a message.
function Clockwork.chatBox:WrappedText(newLine, message, color, text, OnHover)
	local chatBoxTextFont = Clockwork.option:GetFont("chat_box_text");
	local width, height = Clockwork.kernel:GetTextSize(chatBoxTextFont, text);
	local maximumWidth = ScrW() * 0.75;
	
	if (width > maximumWidth) then
		local currentWidth = 0;
		local firstText = nil;
		local secondText = nil;
		
		for i = 0, #text do
			local currentCharacter = string.sub(text, i, i);
			local currentSingleWidth = Clockwork.kernel:GetTextSize(chatBoxTextFont, currentCharacter);
			
			if ((currentWidth + currentSingleWidth) >= maximumWidth) then
				secondText = string.sub(text, i);
				firstText = string.sub(text, 0, (i - 1));
				
				break;
			else
				currentWidth = currentWidth + currentSingleWidth;
			end;
		end;
		
		if (firstText and firstText != "") then
			Clockwork.chatBox:WrappedText(true, message, color, firstText, OnHover);
		end;
		
		if (secondText and secondText != "") then
			Clockwork.chatBox:WrappedText(nil, message, color, secondText, OnHover);
		end;
	else
		message.text[#message.text + 1] = {
			newLine = newLine,
			OnHover = OnHover,
			height = height,
			width = width,
			color = color,
			text = text
		};
		
		if (newLine) then
			message.lines = message.lines + 1;
		end;
	end;
end;

-- A function to paint the chat box.
function Clockwork.chatBox:Paint()
	local chatBoxSyntaxFont = Clockwork.option:GetFont("chat_box_syntax");
	local chatBoxTextFont = Clockwork.option:GetFont("chat_box_text");
	local bIsOpen = Clockwork.chatBox:IsOpen();
	
	Clockwork.kernel:OverrideMainFont(chatBoxTextFont);
	
	if (!self.spaceWidths[chatBoxTextFont]) then
		self.spaceWidths[chatBoxTextFont] = Clockwork.kernel:GetTextSize(chatBoxTextFont, " ");
	end;
	
	local bIsTypingCommand = Clockwork.chatBox:IsTypingCommand();
	local chatBoxSpacing = Clockwork.chatBox:GetSpacing();
	local maximumLines = math.Clamp(CW_CONVAR_MAXCHATLINES:GetInt(), 1, 10);
	local origX, origY = Clockwork.chatBox:GetPosition(4);
	local onHoverData = nil;
	local spaceWidth = self.spaceWidths[chatBoxTextFont];
	local fontHeight = chatBoxSpacing - 4;
	local messages = self.messages;
	local x, y = origX, origY;
	local box = {width = 0, height = 0};

	if (!bIsOpen) then
		if (#self.historyMsgs > 100) then
			local amount = #self.historyMsgs - 100;
			
			for i = 1, amount do
				table.remove(self.historyMsgs, 1);
			end;
		end;
	else
		messages = {};
		
		for i = 0, (maximumLines - 1) do
			messages[#messages + 1] = self.historyMsgs[self.historyPos - i];
		end;
	end;
	
	for k, v in pairs(messages) do
		local fontName = Clockwork.fonts:GetMultiplied(chatBoxTextFont, v.multiplier or 1);
		Clockwork.kernel:OverrideMainFont(fontName);
		
		if (!self.spaceWidths[fontName]) then
			self.spaceWidths[fontName] = Clockwork.kernel:GetTextSize(fontName, " ");
		end;

		chatBoxSpacing = Clockwork.chatBox:GetSpacing(fontName);
		spaceWidth = self.spaceWidths[fontName];
		
		if (messages[k - 1]) then
			y = y - messages[k - 1].spacing;
		end;
		
		if (!bIsOpen and k == 1) then
			y = y - ((chatBoxSpacing + v.spacing) * (v.lines - 1)) + 14;
		else
			y = y - ((chatBoxSpacing + v.spacing) * v.lines);
			
			if (k == 1) then
				y = y + 2;
			end;
		end;
		
		local messageX = x;
		local messageY = y;
		local alpha = v.alpha;
		
		if (bIsTypingCommand) then
			alpha = 25;
		elseif (bIsOpen) then
			alpha = 255;
		end;
		
		if (v.icon) then
			local messageIcon = Clockwork.kernel:GetMaterial(v.icon);

			surface.SetMaterial(messageIcon);
			surface.SetDrawColor(255, 255, 255, alpha);
			surface.DrawTexturedRect(messageX, messageY + (fontHeight / 2) - 8, 16, 16);
			
			messageX = messageX + 16 + spaceWidth;
		end;
		
		local mouseX = gui.MouseX();
		local mouseY = gui.MouseY();
		
		for k2, v2 in pairs(v.text) do
			local textColor = Color(v2.color.r, v2.color.g, v2.color.b, alpha);
			local newLine = false;
			
			if (mouseX > messageX and mouseY > messageY
			and mouseX < messageX + v2.width
			and mouseY < messageY + v2.height) then
				if (v2.OnHover) then
					onHoverData = v2;
				end;
			end;
			
			Clockwork.kernel:DrawSimpleText(v2.text, messageX, messageY, textColor);
			messageX = messageX + v2.width;
			
			if (origY - y > box.height) then
				box.height = origY - y;
			end;
			
			if (messageX - 8 > box.width) then
				box.width = messageX - 8;
			end;
			
			if (v2.newLine) then
				messageY = messageY + chatBoxSpacing + v.spacing;
				messageX = origX;
			end;
		end;
	end;
	
	Clockwork.kernel:OverrideMainFont(false);
	
	if (bIsTypingCommand) then
		local colorInformation = Clockwork.option:GetColor("information");
		local currentText = Clockwork.chatBox:GetCurrentText();
		local colorWhite = Clockwork.option:GetColor("white");
		local splitTable = string.Explode(" ", string.sub(currentText, 2));
		local commands = {};
		local oX, oY = origX, origY;
		local command = splitTable[1];
		local prefix = Clockwork.config:Get("command_prefix"):Get();
		
		if (command) then
			for k, v in pairs(Clockwork.command.stored) do
				if (string.sub(k, 1, string.len(command)) == string.lower(command)
				and (!splitTable[2] or string.lower(command) == k)) then
					if (Clockwork.player:HasFlags(Clockwork.Client, v.access)) then
						commands[#commands + 1] = v;
					end;
				end;
				
				if (#commands == 8) then
					break;
				end;
			end;
			
			Clockwork.kernel:OverrideMainFont(chatBoxSyntaxFont);
			
			if (#commands > 0) then
				local bSingleCommand = (#commands == 1);
				
				for k, v in pairs(commands) do
					local totalText = prefix..v.name;
					
					if (bSingleCommand) then
						totalText = totalText.." "..v.text;
					end;
					
					local tWidth, tHeight = Clockwork.kernel:GetCachedTextSize(
						chatBoxSyntaxFont, totalText
					);
					
					if (k == 1) then
						oY = oY - tHeight;
					end;
					
					Clockwork.kernel:DrawSimpleText(prefix..v.name, oX, oY, colorInformation);
					
					if (bSingleCommand) then
						local pWidth = Clockwork.kernel:GetCachedTextSize(
							chatBoxSyntaxFont, prefix..v.name
						);
						
						if (v.tip and v.tip != "") then
							Clockwork.kernel:DrawSimpleText(v.tip, oX, oY - tHeight - 8, colorWhite);
						end;
						
						Clockwork.kernel:DrawSimpleText(" "..v.text, oX + pWidth, oY, colorWhite);
					end;
					
					if (k < #commands) then oY = oY - tHeight; end;
					if (oY < y) then y = oY; end;
					
					if (origY - oY > box.height) then
						box.height = origY - oY;
					end;
					
					if (origX + tWidth - 8 > box.width) then
						box.width = origX + tWidth - 8;
					end;
				end;
			end;
			
			Clockwork.kernel:OverrideMainFont(false);
		end;
	end;
	
	self.scroll:SetSize(box.width + 8, box.height + 8);
	self.scroll:SetPos(x - 4, y - 4);
	
	if (onHoverData) then
		onHoverData.OnHover(onHoverData);
	end;
end;

-- A function to set the size (multiplier) of the next message.
function Clockwork.chatBox:SetMultiplier(multiplier)
	self.multiplier = multiplier;
end;

-- A function to add a message to the chat box.
function Clockwork.chatBox:Add(filtered, icon, ...)
	if (ScrW() == 160 or ScrH() == 27) then
		return;
	end;
	
	if (!filtered) then
		local maximumLines = math.Clamp(CW_CONVAR_MAXCHATLINES:GetInt(), 1, 10);
		local colorWhite = Clockwork.option:GetColor("white");
		local curTime = UnPredictedCurTime();
		local message = {
			timeFinish = curTime + 11,
			timeStart = curTime,
			timeFade = curTime + 10,
			spacing = 0,
			alpha = 255,
			lines = 1,
			icon = icon
		};
		
		if (self.multiplier) then
			message.multiplier = self.multiplier;
			self.multiplier = nil;
		end;
		
		local curOnHover = nil;
		local curColor = nil;
		local text = {...};
		
		if (CW_CONVAR_SHOWTIMESTAMPS:GetInt() == 1) then
			local timeInfo = "("..os.date("%H:%M")..") ";
			local color = Color(150, 150, 150, 255);
			
			if (CW_CONVAR_TWELVEHOURCLOCK:GetInt() == 1) then
				timeInfo = "("..string.lower(os.date("%I:%M%p"))..") ";
			end;
			
			if (text) then
				table.insert(text, 1, color);
				table.insert(text, 2, timeInfo);
			else
				text = {timeInfo, color};
			end;
		end;
		
		if (text) then
			message.text = {};
			
			for k, v in pairs(text) do
				if (type(v) == "string" or type(v) == "number" or type(v) == "boolean") then
					Clockwork.chatBox:WrappedText(
						nil, message, curColor or colorWhite, tostring(v), curOnHover
					);
					curColor = nil;
					curOnHover = nil;
				elseif (type(v) == "function") then
					curOnHover = v;
				elseif (type(v) == "Player") then
					Clockwork.chatBox:WrappedText(
						nil, message, cwTeam.GetColor(v:Team()), v:Name(), curOnHover
					);
					curColor = nil;
					curOnHover = nil;
				elseif (type(v) == "table") then
					curColor = Color(v.r or 255, v.g or 255, v.b or 255);
				end;
			end;
		end;
		
		if (self.historyPos == #self.historyMsgs) then
			self.historyPos = #self.historyMsgs + 1;
		end;
		
		self.historyMsgs[#self.historyMsgs + 1] = message;
		
		if (#self.messages == maximumLines) then
			table.remove(self.messages, maximumLines);
		end;
		
		table.insert(self.messages, 1, message);
		
		surface.PlaySound("common/talk.wav");
		Clockwork.kernel:PrintColoredText(...);
	end;
end;

hook.Add("PlayerBindPress", "Clockwork.chatBox:PlayerBindPress", function(player, bind, bPress)
	if ((string.find(bind, "messagemode") or string.find(bind, "messagemode2")) and bPress) then
		if (Clockwork.Client:HasInitialized()) then
			Clockwork.chatBox.panel:Show();
		end;
		
		return true;
	end;
end);

hook.Add("Think", "Clockwork.chatBox:Think", function()
	local curTime = UnPredictedCurTime();
	
	for k, v in pairs(Clockwork.chatBox.messages) do
		if (curTime >= v.timeFade) then
			local fadeTime = v.timeFinish - v.timeFade;
			local timeLeft = v.timeFinish - curTime;
			local alpha = math.Clamp((255 / fadeTime) * timeLeft, 0, 255);
			
			if (alpha == 0) then
				table.remove(Clockwork.chatBox.messages, k);
			else
				v.alpha = alpha;
			end;
		end;
	end;
end);

Clockwork.datastream:Hook("ChatBoxDeathCode", function(data)
	local iDeathCode = data;
	
	if (Clockwork.chatBox:IsOpen()) then
		local text = Clockwork.chatBox.textEntry:GetValue();
		
		if (text != "" and string.sub(text, 1, 2) != "//" and string.sub(text, 1, 3) != ".//"
		and string.sub(text, 1, 2) != "[[") then
			RunConsoleCommand("cwDeathCode", iDeathCode);
				Clockwork.chatBox.textEntry:SetRealValue(string.sub(text, 0, string.len(text) - 1).."-");
			Clockwork.chatBox.textEntry:OnEnter();
		end;
	end;
end);

Clockwork.datastream:Hook("ChatBoxPlayerMessage", function(data)
	if (data.speaker:IsPlayer()) then
		Clockwork.chatBox:Decode(data.speaker, data.speaker:Name(), data.text, data.data, data.class, data.multiplier);
	end;
end);

Clockwork.datastream:Hook("ChatBoxColorMessage", function(data)
	chat.AddText(unpack(data));
end);

Clockwork.datastream:Hook("ChatBoxMessage", function(data)
	if (data and type(data) == "table") then
		Clockwork.chatBox:Decode(nil, nil, data.text, data.data, data.class, data.multiplier);
	end;
end);