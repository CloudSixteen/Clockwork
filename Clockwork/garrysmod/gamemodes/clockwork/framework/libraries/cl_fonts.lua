--[[ 
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

local Clockwork = Clockwork;
local surface = surface;

surface.CreateFont("cwMainText", 
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(7),
	weight		= 700,
	antialiase	= true,
	additive 	= false
});
surface.CreateFont("cwMenuTextBig",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(18),
	weight		= 700,
	antialiase	= true,
	additive 	= false
});
surface.CreateFont("cwMenuTextTiny",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(7),
	weight		= 700,
	antialiase	= true,
	additive 	= false
});
surface.CreateFont("cwMenuTextHuge",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(30),
	weight		= 700,
	antialiase	= true,
	additive 	= false
});
surface.CreateFont("cwMenuTextSmall",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(10),
	weight		= 700,
	antialiase	= true,
	additive 	= false
});
surface.CreateFont("cwIntroTextBig",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(18),
	weight		= 700,
	antialiase	= true,
	additive 	= false
});
surface.CreateFont("cwIntroTextTiny",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(9),
	weight		= 700,
	antialiase	= true,
	additive 	= false
});
surface.CreateFont("cwIntroTextSmall",
{
	font		= "Arial",
	size		= Clockwork.kernel:FontScreenScale(7),
	weight		= 700,
	antialiase	= true,
	additive 	= false
});
surface.CreateFont("cwLarge3D2D",
{
	font		= "Arial",
	size		= Clockwork.kernel:GetFontSize3D(),
	weight		= 700,
	antialiase	= true,
	additive 	= false
});
surface.CreateFont("cwCinematicText",
{
	font		= "Trebuchet",
	size		= Clockwork.kernel:FontScreenScale(8),
	weight		= 700,
	antialiase	= true,
	additive 	= false
});
surface.CreateFont("cwChatSyntax",
{
	font		= "Courier New",
	size		= Clockwork.kernel:FontScreenScale(7),
	weight		= 600,
	antialiase	= true,
	additive 	= false
});