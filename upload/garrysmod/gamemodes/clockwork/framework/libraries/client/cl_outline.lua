--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local Color = Color;
local render = render;
local math = math;

--[[ We need the plugin library to add this as a module! --]]
if (!Clockwork.plugin) then
	include("clockwork/framework/libraries/sh_plugin.lua");
end;

Clockwork.outline = Clockwork.kernel:NewLibrary("Outline");

--[[
	@codebase Client
	@details A function to add an entity outline.
	@param {Unknown} Missing description for entity.
	@param {Unknown} Missing description for glowColor.
	@param {Unknown} Missing description for glowSize.
	@param {Unknown} Missing description for bIgnoreZ.
	@returns {Unknown}
--]]
function Clockwork.outline:Add(entity, glowColor, glowSize, bIgnoreZ)
	if (not glowSize) then glowSize = 2; end;
	
	if (type(entity) ~= "table") then
		entity = {entity};
	end;
	
	halo.Add(
		entity, glowColor, glowSize, glowSize, 1, true, bIgnoreZ
	);
end;

--[[
	@codebase Client
	@details A function to add a fading entity outline.
	@param {Unknown} Missing description for entity.
	@param {Unknown} Missing description for glowColor.
	@param {Unknown} Missing description for iDrawDist.
	@param {Unknown} Missing description for bShowAnyway.
	@param {Unknown} Missing description for tIgnoreEnts.
	@param {Unknown} Missing description for glowSize.
	@param {Unknown} Missing description for bIgnoreZ.
	@returns {Unknown}
--]]
function Clockwork.outline:Fader(entity, glowColor, iDrawDist, bShowAnyway, tIgnoreEnts, glowSize, bIgnoreZ)
	local fOutlineAlpha = glowColor.a;
	
	if (iDrawDist) then
		local distance = Clockwork.Client:GetPos():Distance(entity:GetPos());
		fOutlineAlpha = fOutlineAlpha - ((fOutlineAlpha / iDrawDist) * math.min(distance, iDrawDist));
	end;
	
	if (!Clockwork.player:CanSeeEntity(Clockwork.Client, entity, 0.9, tIgnoreEnts)
	and !bShowAnyway) then
		fOutlineAlpha = 0;
	end;
	
	if (!entity.cwLastOutlineAlpha) then
		entity.cwLastOutlineAlpha = 0;
	end;
	
	entity.cwLastOutlineAlpha = math.Approach(
		entity.cwLastOutlineAlpha, fOutlineAlpha, FrameTime() * 64
	);
	
	if (entity.cwLastOutlineAlpha > 0) then
		self:Add(
			entity, Color(glowColor.r, glowColor.g, glowColor.b, entity.cwLastOutlineAlpha),
			glowSize, bIgnoreZ
		);
	end
end;

--[[
	@codebase Client
	@details Called when GMod halos should be added.
	@returns {Unknown}
--]]
function Clockwork.outline:PreDrawHalos()
	Clockwork.plugin:Call("AddEntityOutlines", self);
end;

--[[
	Register the library as a module. We're doing this because
	we want the PreDrawHalos function to be called
	before anything else.
--]]

Clockwork.plugin:Add("Outline", Clockwork.outline);