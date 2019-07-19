--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local surface = surface;
local Clockwork = Clockwork;

CreateFont = CreateFont or surface.CreateFont;

function surface.CreateFont(...)
	Clockwork.fonts:Add(...);
end;

Clockwork.fonts = Clockwork.kernel:NewLibrary("Fonts");
Clockwork.fonts.stored = Clockwork.fonts.stored or {};
Clockwork.fonts.sizes = Clockwork.fonts.sizes or {};

--[[
	@codebase Client
	@details A function to add a new font to the system.
	@param {Unknown} Missing description for name.
	@param {Unknown} Missing description for fontTable.
	@returns {Unknown}
--]]
function Clockwork.fonts:Add(name, fontTable)
	fontTable.extended = true;
	
	self.stored[name] = fontTable;
	
	CreateFont(name, self.stored[name]);
end;

--[[
	@codebase Client
	@details A function to find a font by name.
	@param {Unknown} Missing description for name.
	@returns {Unknown}
--]]
function Clockwork.fonts:FindByName(name)
	return self.stored[name];
end;

--[[
	@codebase Client
	@details A function to grab a font by size (creating what doesn't exist.)
	@param {Unknown} Missing description for creating what doesn't exist..
	@returns {Unknown}
--]]
function Clockwork.fonts:GetSize(name, size)
	local fontKey = name..size;
	
	if (self.sizes[fontKey]) then
		return fontKey;
	end;
	
	if (not self.stored[name]) then
		return name;
	end;
	
	self.sizes[fontKey] = table.Copy(self.stored[name]);
	self.sizes[fontKey].size = size;
	
	CreateFont(fontKey, self.sizes[fontKey]);
	return fontKey;
end;

--[[
	@codebase Client
	@details A function to grab a font by multiplier.
	@param {Unknown} Missing description for name.
	@param {Unknown} Missing description for multiplier.
	@returns {Unknown}
--]]
function Clockwork.fonts:GetMultiplied(name, multiplier)
	local fontTable = self:FindByName(name);
	if (fontTable == nil) then return name; end;
	
	return self:GetSize(name, fontTable.size * multiplier);
end;

Clockwork.fonts:Add("cwMainText", 
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(7),
	weight		= 700
});
Clockwork.fonts:Add("cwESPText", 
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(5.5),
	weight		= 700
});
Clockwork.fonts:Add("cwTooltip", 
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(5),
	weight		= 700
});
Clockwork.fonts:Add("cwMenuTextBig",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(18),
	weight		= 700
});
Clockwork.fonts:Add("cwMenuTextTiny",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(7),
	weight		= 700
});
Clockwork.fonts:Add("cwInfoTextFont",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(6),
	weight		= 700
});
Clockwork.fonts:Add("cwMenuTextHuge",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(30),
	weight		= 700
});
Clockwork.fonts:Add("cwMenuTextSmall",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(10),
	weight		= 700
});
Clockwork.fonts:Add("cwIntroTextBig",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(18),
	weight		= 700
});
Clockwork.fonts:Add("cwIntroTextTiny",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(9),
	weight		= 700
});
Clockwork.fonts:Add("cwIntroTextSmall",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(7),
	weight		= 700
});
Clockwork.fonts:Add("cwLarge3D2D",
{
	font		= "Arial",
	size		= Clockwork.kernel:GetFontSize3D(),
	weight		= 700
});
Clockwork.fonts:Add("cwScoreboardName",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(7),
	weight		= 600
});
Clockwork.fonts:Add("cwScoreboardDesc",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(5),
	weight		= 600
});
Clockwork.fonts:Add("cwCinematicText",
{
	font		= "Trebuchet",
	size		= Clockwork.kernel:FontScreenScale(8),
	weight		= 700
});
Clockwork.fonts:Add("cwChatSyntax",
{
	font		= "Courier New",
	size		= Clockwork.kernel:FontScreenScale(7),
	weight		= 600
});
