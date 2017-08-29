--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

	

local TOOL = Clockwork.tool:New();

TOOL.Name 			= "Text Add/Remove";
TOOL.UniqueID 		= "text";
TOOL.Category			= "Clockwork";
TOOL.Desc 			= "Add colored text!";
TOOL.HelpText		= "Primary: Add Secondary: Remove";

TOOL.ClientConVar[ "text" ]	= ""
TOOL.ClientConVar[ "scale" ] = ""
TOOL.ClientConVar[ "r" ] = 255
TOOL.ClientConVar[ "g" ] = 0
TOOL.ClientConVar[ "b" ] = 255
TOOL.ClientConVar[ "a" ] = 255

function TOOL:LeftClick(tr)
	if (CLIENT) then return true; end;

	local Clockwork = Clockwork;
	local ply = self:GetOwner();

	if (!ply:IsAdmin()) then 
		return false;
	end;
	
	-- Process text
	local r =  self:GetClientInfo( "r" )
	local g =  self:GetClientInfo( "g" )
	local b =  self:GetClientInfo( "b" )
	local a =  self:GetClientInfo( "a" )
	local usertext = self:GetClientInfo( "text" )

	local finishedtext = "<color="..r..","..g..","..b..","..a..">"..usertext

	local scale = self:GetClientInfo( "scale" )
	
	ply:RunClockworkCmd("TextAdd", finishedtext, scale);
end


function TOOL:RightClick( tr )
	if (CLIENT) then return true; end;

	local Clockwork = Clockwork;
	local ply = self:GetOwner();

	if (!ply:IsAdmin()) then 
		return false;
	end;
	
	ply:RunClockworkCmd("TextRemove");
end;



function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl( "Header", { 
		Text = "Text Tool", 
		Description	= L("SurfaceTextToolDesc") 
	});

	local CVars = {"text_text"};
	local CVars = {"text_scale"};
	local CVars = {"text_r"};
	local CVars = {"text_g"};
	local CVars = {"text_b"};
	local CVars = {"text_a"};

	CPanel:AddControl( "TextBox", { 
		Label = L("SurfaceTextToolAddText"),
		MaxLenth = "50",
		Command = "text_text" 
	});

	CPanel:AddControl( "Slider",  {
		Label	= "Scale",
		Type	= "Float",
		Min		= 1.0,
		Max		= 20,
		Command = "text_scale",
		Description = L("SurfaceTextToolSizeText")
	});

	CPanel:AddControl("Color", {
		Label = L("SurfaceTextToolColorText"),
		Red = "text_r",
		Green = "text_g",
		Blue = "text_b",
		Alpha = "text_a",
		ShowHSV = 1,
		ShowRGB = 1,
		Multiplier = 255
	});
end;

local plugin = Clockwork.plugin:FindByID("Surface Texts");
	
if (plugin) then
	if (Clockwork.plugin:IsDisabled(plugin.name) or Clockwork.plugin:IsUnloaded(plugin.name)) then
		
	else
		TOOL:Register();
	end	
end