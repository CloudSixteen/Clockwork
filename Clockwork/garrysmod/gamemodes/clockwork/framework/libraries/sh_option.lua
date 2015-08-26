--[[
	� 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local Color = Color;
local type = type;
local surface = surface;
local string = string;

Clockwork.option = Clockwork.kernel:NewLibrary("Option");
Clockwork.option.keys = Clockwork.option.keys or {};
Clockwork.option.sounds = Clockwork.option.sounds or {};

-- A function to set a schema key.
function Clockwork.option:SetKey(key, value)
	self.keys[key] = value;
end;

-- A function to get a schema key.
function Clockwork.option:GetKey(key, lowerValue)
	local value = self.keys[key];
	
	if (lowerValue and type(value) == "string") then
		return string.lower(value);
	else
		return value;
	end;
end;

-- A function to set a schema sound.
function Clockwork.option:SetSound(name, sound)
	self.sounds[name] = sound;
end;

-- A function to get a schema sound.
function Clockwork.option:GetSound(name)
	return self.sounds[name];
end;

-- A function to play a schema sound.
function Clockwork.option:PlaySound(name)
	local sound = self:GetSound(name);
	
	if (sound) then
		if (CLIENT) then
			surface.PlaySound(sound);
		else
			Clockwork.player:PlaySound(nil, sound);
		end;
	end;
end;

Clockwork.option:SetKey("default_date", {month = 1, year = 2010, day = 1});
Clockwork.option:SetKey("default_time", {minute = 0, hour = 0, day = 1});
Clockwork.option:SetKey("default_days", {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"});
Clockwork.option:SetKey("description_business", "Order items for your business.");
Clockwork.option:SetKey("description_inventory", "Manage the items in your inventory.");
Clockwork.option:SetKey("description_directory", "A directory of various topics and information.");
Clockwork.option:SetKey("description_system", "Access a variety of server-side options.");
Clockwork.option:SetKey("description_scoreboard", "See which players are on the server.");
Clockwork.option:SetKey("description_attributes", "Check the status of your attributes.");
Clockwork.option:SetKey("model_shipment", "models/items/item_item_crate.mdl");
Clockwork.option:SetKey("model_cash", "models/props_c17/briefcase001a.mdl");
Clockwork.option:SetKey("format_singular_cash", "$%a");
Clockwork.option:SetKey("format_cash", "$%a");
Clockwork.option:SetKey("name_attributes", "Attributes");
Clockwork.option:SetKey("name_attribute", "Attribute");
Clockwork.option:SetKey("name_system", "System");
Clockwork.option:SetKey("name_scoreboard", "Scoreboard");
Clockwork.option:SetKey("name_directory", "Directory");
Clockwork.option:SetKey("name_inventory", "Inventory");
Clockwork.option:SetKey("name_business", "Business");
Clockwork.option:SetKey("name_destroy", "Destroy");
Clockwork.option:SetKey("schema_logo", "");
Clockwork.option:SetKey("intro_image", "");
Clockwork.option:SetKey("intro_sound", "music/HL2_song25_Teleporter.mp3");
Clockwork.option:SetKey("menu_music", "music/hl2_song32.mp3");
Clockwork.option:SetKey("name_cash", "Cash");
Clockwork.option:SetKey("name_drop", "Drop");
Clockwork.option:SetKey("top_bars", false);
Clockwork.option:SetKey("name_use", "Use");
Clockwork.option:SetKey("gradient", "gui/gradient_up");

Clockwork.option:SetSound("click_release", "ui/buttonclickrelease.wav");
Clockwork.option:SetSound("rollover", "ui/buttonrollover.wav");
Clockwork.option:SetSound("click", "ui/buttonclick.wav");

if (CLIENT) then
	Clockwork.option.fonts = Clockwork.option.fonts or {};
	Clockwork.option.colors = Clockwork.option.colors or {};

	-- A function to set a schema color.
	function Clockwork.option:SetColor(name, color)
		self.colors[name] = color;
	end;

	-- A function to get a schema color.
	function Clockwork.option:GetColor(name)
		return self.colors[name];
	end;

	-- A function to set a schema font.
	function Clockwork.option:SetFont(name, font)
		self.fonts[name] = font;
	end;

	-- A function to get a schema font.
	function Clockwork.option:GetFont(name)
		return self.fonts[name];
	end;

	Clockwork.option:SetColor("columnsheet_shadow_normal", Color(0, 0, 0, 255));
	Clockwork.option:SetColor("columnsheet_text_normal", Color(255, 255, 255, 255));
	Clockwork.option:SetColor("columnsheet_shadow_active", Color(255, 255, 255, 255));
	Clockwork.option:SetColor("columnsheet_text_active", Color(50, 50, 50, 255));
	Clockwork.option:SetColor("basic_form_color", Color(255, 255, 255, 255));
	
	Clockwork.option:SetKey("info_text_icon_size", 24);
	Clockwork.option:SetKey("info_text_red_icon", "icon16/exclamation.png");
	Clockwork.option:SetKey("info_text_green_icon", "icon16/tick.png");
	Clockwork.option:SetKey("info_text_orange_icon", "icon16/error.png");
	Clockwork.option:SetKey("info_text_blue_icon", "icon16/information.png");
	
	Clockwork.option:SetColor("positive_hint", Color(100, 175, 100, 255));
	Clockwork.option:SetColor("negative_hint", Color(175, 100, 100, 255));
	Clockwork.option:SetColor("background", Color(0, 0, 0, 125));
	Clockwork.option:SetColor("foreground", Color(50, 50, 50, 125));
	Clockwork.option:SetColor("target_id", Color(50, 75, 100, 255));
	Clockwork.option:SetColor("white", Color(255, 255, 255, 255));

	Clockwork.option:SetFont("schema_description", "cwMainText");
	Clockwork.option:SetFont("player_info_text", "cwMainText");
	Clockwork.option:SetFont("intro_text_small", "cwIntroTextSmall");
	Clockwork.option:SetFont("intro_text_tiny", "cwIntroTextTiny");
	Clockwork.option:SetFont("menu_text_small", "cwMenuTextSmall");
	Clockwork.option:SetFont("chat_box_syntax", "cwChatSyntax");
	Clockwork.option:SetFont("menu_text_huge", "cwMenuTextHuge");
	Clockwork.option:SetFont("intro_text_big", "cwIntroTextBig");
	Clockwork.option:SetFont("menu_text_tiny", "cwMenuTextTiny");
	Clockwork.option:SetFont("date_time_text", "cwMenuTextSmall");
	Clockwork.option:SetFont("cinematic_text", "cwCinematicText");
	Clockwork.option:SetFont("target_id_text", "cwMainText");
	Clockwork.option:SetFont("auto_bar_text", "cwMainText");
	Clockwork.option:SetFont("menu_text_big", "cwMenuTextBig");
	Clockwork.option:SetFont("chat_box_text", "cwMainText");
	Clockwork.option:SetFont("large_3d_2d", "cwLarge3D2D");
	Clockwork.option:SetFont("hints_text", "cwIntroTextTiny");
	Clockwork.option:SetFont("main_text", "cwMainText");
	Clockwork.option:SetFont("bar_text", "cwMainText");
	Clockwork.option:SetFont("esp_text", "cwESPText");
end;