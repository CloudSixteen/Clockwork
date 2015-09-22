--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local math = math;

--[[
	@codebase Server
	@details Provides an interface to the hints system.
	@field stored A table containing a list of stored hints.
--]]
Clockwork.hint = Clockwork.kernel:NewLibrary("Hint");
Clockwork.hint.stored = Clockwork.hint.stored or {};

--[[
	@codebase Server
	@details Add a new hint to the list.
	@param String A unique identifier.
	@param String The body of the hint.
	@param Function A callback with the player as an argument, return false to hide.
--]]
function Clockwork.hint:Add(name, text, Callback)
	self.stored[name] = {
		Callback = Callback,
		text = text
	};
end;

--[[
	@codebase Server
	@details Remove an existing hint from the list.
	@param String A unique identifier.
--]]
function Clockwork.hint:Remove(name)
	self.stored[name] = nil;
end;

--[[
	@codebase Server
	@details Find a hint by its identifier.
	@param String A unique identifier.
	@returns Table The hint table matching the identifier.
--]]
function Clockwork.hint:Find(name)
	return self.stored[name];
end;

--[[
	@codebase Server
	@details Distribute a hint to each player.
--]]
function Clockwork.hint:Distribute()
	local hintText, Callback = self:Get();
	local hintInterval = Clockwork.config:Get("hint_interval"):Get();
	
	if (!hintText) then return; end;
	
	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:HasInitialized() and v:GetInfoNum("cwShowHints", 1) == 1
		and !v:IsViewingStarterHints()) then
			if (!Callback or Callback(v) != false) then
				self:Send(v, hintText, 6, nil, true);
			end;
		end;
	end;
end;

--[[
	@codebase Server
	@details Send customized and centered hint text to a player.
	@param Player The recipient(s).
	@param String The hint text to send.
	@param Float The delay before it fades.
	@param Color The color of the hint text.
	@option Bool:String Specify a custom sound or false for no sound.
	@option Bool Specify wether to display duplicates of this hint.
--]]
function Clockwork.hint:SendCenter(player, text, delay, color, bNoSound, showDuplicated)
	Clockwork.datastream:Start(player, "Hint", {
		text = Clockwork.kernel:ParseData(text),
		delay = delay,
		color = color,
		center = true,
		noSound = bNoSound,
		showDuplicates = showDuplicated
	});
end;

--[[
	@codebase Server
	@details Send customized and centered hint text to all players.
	@param String The hint text to send.
	@param Float The delay before it fades.
	@param Color The color of the hint text.
--]]
function Clockwork.hint:SendCenterAll(text, delay, color)
	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:HasInitialized()) then
			self:SendCenter(v, text, delay, color);
		end;
	end;
end;

--[[
	@codebase Server
	@details Send customized hint text to a player.
	@param Player The recipient(s).
	@param String The hint text to send.
	@param Float The delay before it fades.
	@param Color The color of the hint text.
	@option Bool:String Specify a custom sound or false for no sound.
	@option Bool Specify wether to display duplicates of this hint.
--]]
function Clockwork.hint:Send(player, text, delay, color, bNoSound, showDuplicated)
	Clockwork.datastream:Start(player, "Hint", {
		text = Clockwork.kernel:ParseData(text), delay = delay, color = color, noSound = bNoSound, showDuplicates = showDuplicated
	});
end;

--[[
	@codebase Server
	@details Send customized hint text to all players.
	@param String The hint text to send.
	@param Float The delay before it fades.
	@param Color The color of the hint text.
--]]
function Clockwork.hint:SendAll(text, delay, color)
	for k, v in pairs(cwPlayer.GetAll()) do
		if (v:HasInitialized()) then
			self:Send(v, text, delay, color);
		end;
	end;
end;

--[[
	@codebase Server
	@details Pick a random hint from the list.
	@returns String The random hint text.
	@returns Function The random hint callback.
--]]
function Clockwork.hint:Get()
	local hints = {};
	
	for k, v in pairs(self.stored) do
		if (!v.Callback or v.Callback() != false) then
			hints[#hints + 1] = v;
		end;
	end;
	
	if (#hints > 0) then
		local hint = hints[math.random(1, #hints)];
		
		if (hint) then
			return hint.text, hint.Callback;
		end;
	end;
end;

Clockwork.hint:Add("OOC", "Type // before your message to talk out-of-character.");
Clockwork.hint:Add("LOOC", "Type .// or [[before your message to talk out-of-character locally.");
Clockwork.hint:Add("Ducking", "Toggle ducking by holding :+speed: and pressing :+walk: while standing still.");
Clockwork.hint:Add("Jogging", "Toggle jogging by pressing :+walk: while moving.");
Clockwork.hint:Add("Directory", "Hold down :+showscores: and click *name_directory* to get help.");
Clockwork.hint:Add("F1 Hotkey", "Hold :gm_showhelp: to view your character and roleplay information.");
Clockwork.hint:Add("F2 Hotkey", "Press :gm_showteam: while looking at a door to view the door menu.");
Clockwork.hint:Add("Tab Hotkey", "Press :+showscores: to view the main menu, or hold :+showscores: to temporarily view it.");

Clockwork.hint:Add("Context Menu", "Hold :+menu_context: and click on an entity to open its menu.", function(player)
	return !Clockwork.config:Get("use_opens_entity_menus"):Get();
end);
Clockwork.hint:Add("Entity Menu", "Press :+use: on an entity to open its menu.", function(player)
	return Clockwork.config:Get("use_opens_entity_menus"):Get();
end);
Clockwork.hint:Add("Phys Desc", "Change your character's physical description by typing $command_prefix$CharPhysDesc.", function(player)
	return Clockwork.command:FindByID("CharPhysDesc") != nil;
end);
Clockwork.hint:Add("Give Name", "Press :gm_showteam: to allow characters within a specific range to recognise you.", function(player)
	return Clockwork.config:Get("recognise_system"):Get();
end);
Clockwork.hint:Add("Raise Weapon", "Hold :+reload: to raise or lower your weapon.", function(player)
	return Clockwork.config:Get("raised_weapon_system"):Get();
end);
Clockwork.hint:Add("Target Recognises", "A character's name will flash white if they do not recognise you.", function(player)
	return Clockwork.config:Get("recognise_system"):Get();
end);