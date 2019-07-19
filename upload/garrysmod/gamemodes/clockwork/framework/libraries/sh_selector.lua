--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local tostring = tostring;
local Color = Color;
local pairs = pairs;
local ScrW = ScrW;
local ScrH = ScrH;
local type = type;
local surface = surface;
local timer = timer;
local draw = draw;

Clockwork.selector = Clockwork.kernel:NewLibrary("Selector");
Clockwork.selector.COLOR_ORANGE = Color(215, 150, 50, 255);
Clockwork.selector.COLOR_CREAM = Color(225, 215, 175, 255);
Clockwork.selector.COLOR_GREEN = Color(150, 215, 50, 255);
Clockwork.selector.COLOR_RED = Color(215, 50, 50, 255);

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {__index = CLASS_TABLE};

--[[
	@codebase Shared
	@details A function to start creating a new selector.
	@returns {Unknown}
--]]
function Clockwork.selector:New()
	local selector = Clockwork.kernel:NewMetaTable(CLASS_TABLE);
	
	if (CLIENT) then
		selector.paginated = {};
		selector.isCreated = false;
		selector.pages = { {}};
		selector.page = 1;
		selector.key = 0;
	else
		selector.data = {};
	end;
	
	selector.paginateText = false;
	selector.canExit = true;
	
	return selector;
end;

--[[
	@codebase Shared
	@details A function to set whether text should be paginated.
	@param {Unknown} Missing description for bPaginateText.
	@returns {Unknown}
--]]
function CLASS_TABLE:SetPaginateText(bPaginateText)
	self.paginateText = bPaginateText;
end;

--[[
	@codebase Shared
	@details A function to set the selector callback.
	@param {Unknown} Missing description for Callback.
	@returns {Unknown}
--]]
function CLASS_TABLE:SetCallback(Callback)
	self.Callback = Callback;
end;

--[[
	@codebase Shared
	@details A function to set whether the selector can be exited.
	@param {Unknown} Missing description for bCanExit.
	@returns {Unknown}
--]]
function CLASS_TABLE:SetCanExit(bCanExit)
	self.canExit = bCanExit;
end;

--[[
	@codebase Shared
	@details A function to add text to the selector.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for color.
	@returns {Unknown}
--]]
function CLASS_TABLE:AddText(text, color)
	if (text) then text = tostring(text); end;
	
	if (CLIENT) then
		if (#self.pages[self.page] == 6 and self.paginateText) then
			self.page = self.page + 1; self.key = 1;
			self.pages[self.page] = {};
		end;
		
		self.pages[self.page][#self.pages[self.page] + 1] = {
			class = "text",
			text = text,
			color = color
		};
	else
		self.data[#self.data + 1] = {
			class = "text",
			text = text,
			color = color
		};
	end;
end;

--[[
	@codebase Shared
	@details A function to add an option to the selector.
	@param {Unknown} Missing description for text.
	@param {Unknown} Missing description for color.
	@returns {Unknown}
--]]
function CLASS_TABLE:AddOption(text, color)
	if (text) then text = tostring(text); end;
	
	if (CLIENT) then
		if (self.key == 6) then
			self.page = self.page + 1; self.key = 1;
			self.pages[self.page] = {};
		else
			self.key = self.key + 1;
		end;
		
		self.pages[self.page][#self.pages[self.page] + 1] = {
			class = "option",
			key = self.key,
			text = text,
			color = color
		};
	else
		self.data[#self.data + 1] = {
			class = "option",
			text = text,
			color = color
		};
	end;
end;

if (SERVER) then
	Clockwork.selector.active = {};
	
	--[[
		@codebase Shared
		@details A function to set the selector's player.
		@param {Unknown} Missing description for player.
		@returns {Unknown}
	--]]
	function CLASS_TABLE:SetPlayer(player)
		if (type(player) != "table") then
			self.player = {player};
		else
			self.player = player;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to create the selector.
		@returns {Unknown}
	--]]
	function CLASS_TABLE:Create()
		if (!self.player) then
			self.player = g_Player.GetAll();
		end;
		
		Clockwork.datastream:Start(self.player, "Selector", {
			paginateText = self.paginateText,
			canExit = self.canExit,
			data = self.data
		});
		
		for k, v in pairs(self.player) do
			Clockwork.selector.active[v] = self;
		end;
	end;
	
	Clockwork.datastream:Hook("Selector", function(player, data)
		local text = data[3];
		local page = data[1];
		local key = data[2];
		
		if (type(page) == "number" and type(key) == "number"
		and type(text) == "string" and Clockwork.selector.active[player]) then
			local Callback = Clockwork.selector.active[player].Callback;
			
			if (Callback) then
				if (key != 7 and key != 8 and key != 9) then
					Clockwork.selector.active[player] = nil;
				end;
				
				Callback(player, page, key, text);
			end;
		end;
	end);
else
	surface.CreateFont("cwSelector", 
	{
		font		= "Verdana",
		size		= 14,
		weight		= 700,
		antialiase	= true,
		additive 	= false
	});
	
	--[[
		@codebase Shared
		@details A function to select a selector's option by key.
		@param {Unknown} Missing description for key.
		@returns {Unknown}
	--]]
	function CLASS_TABLE:Select(key)
		local wasSuccess = false;
		local tOption = nil;
		
		for k, v in pairs(self.pages[self.page]) do
			if (v.class == "option" and v.key == key) then
				wasSuccess = true;
				tOption = v;
				break;
			end;
		end;
		
		if (tOption) then
			if (self.Callback) then
				self.Callback(
					self.page, tOption.key, tOption.text
				);
				
				if (tOption.key == 7) then
					self:PreviousPage();
					return false;
				elseif (tOption.key == 8) then
					self:NextPage();
					return false;
				end;
			end;
			
			surface.PlaySound("ui/buttonclickrelease.wav");
			
			if (tOption.key != 7
			and tOption.key != 8) then
				return true;
			end;
		end;
		
		if (!wasSuccess) then
			return true;
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to go to the selector's next page.
		@returns {Unknown}
	--]]
	function CLASS_TABLE:NextPage()
		if (self.pages[self.page + 1]) then
			self.page = self.page + 1; self:Create();
		end
	end;
	
	--[[
		@codebase Shared
		@details A function to go to the selector's previous page.
		@returns {Unknown}
	--]]
	function CLASS_TABLE:PreviousPage()
		if (self.pages[self.page - 1]) then
			self.page = self.page - 1; self:Create();
		end;
	end;
	
	--[[
		@codebase Shared
		@details A function to create the selector.
		@returns {Unknown}
	--]]
	function CLASS_TABLE:Create()
		if (!self.isCreated) then
			self.page = 1; self.isCreated = true;
		end;
		
		if (!self.paginated[self.page]) then
			if (self.pages[self.page - 1]) then
				self.pages[self.page][#self.pages[self.page] + 1] = {
					class = "option",
					key = 7,
					text = "Back"
				};
			end;
			
			if (self.pages[self.page + 1]) then
				self.pages[self.page][#self.pages[self.page] + 1] = {
					class = "option",
					key = 8,
					text = "Next"
				};
			end;
			
			if (self.canExit) then
				self.pages[self.page][#self.pages[self.page] + 1] = {
					class = "option",
					key = 9,
					text = "Exit"
				};
			end;
			
			self.paginated[self.page] = true;
		end;
		
		local height = (18 * #self.pages[self.page]) + 16;
		local width = 0;
		
		surface.SetFont("cwSelector");
		
		for k, v in pairs(self.pages[self.page]) do
			if (v.class == "text") then
				if (surface.GetTextSize(string.Replace(v.text, "&", "U")) > width) then
					width = surface.GetTextSize(string.Replace(v.text, "&", "U"));
				end;
			elseif (v.class == "option") then
				if (surface.GetTextSize(string.Replace(v.key..". "..v.text, "&", "U")) > width) then
					width = surface.GetTextSize(string.Replace(v.key..". "..v.text, "&", "U"));
				end;
			end;
		end;
		
		width = width + 16;
		
		Clockwork.Client:AddPlayerOption("cwSelector", -1, function(key)
			return self:Select(key);
		end, function()
			local x, y = ScrW() * 0.1, ScrH() * 0.2;
				draw.RoundedBox(4, x, y, width, height, Color(0, 0, 0, 150));
			x, y = x + 8, y + 10;
			
			for k, v in pairs(self.pages[self.page]) do
				local color = v.color;
				local text = v.text;
				
				if (v.class == "text") then
					color = color or Clockwork.selector.COLOR_CREAM;
				elseif (v.class == "option") then
					color = color or Clockwork.selector.COLOR_ORANGE;
					text = v.key..". "..text;
				end;
				
				draw.DrawText(text, "cwSelector", x, y, color);
				y = y + 18;
			end;
		end);
	end;
	
	Clockwork.datastream:Hook("Selector", function(data)
		local selector = Clockwork.selector:New();
		
		selector:SetPaginateText(data.paginateText);
		selector:SetCanExit(data.canExit);
		
		selector:SetCallback(function(page, key, text)
			Clockwork.datastream:Start("Selector", {page, key, text});
		end);
		
		for k, v in pairs(data.data) do
			if (v.class == "option") then
				selector:AddOption(v.text, v.color);
			elseif (v.class == "text") then
				selector:AddText(v.text, v.color);
			end;
		end;
		
		if (!Clockwork.Client or !Clockwork.Client:IsValid()) then
			timer.Create("cwSelectorCreate", 1, 1, function()
				selector:Create();
			end);
		else
			selector:Create();
		end;
	end);
end;