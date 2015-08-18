--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]


local TOOL = Clockwork.tool:New();

TOOL.Name 			= "Text Add/Remove";
TOOL.UniqueID 		= "text";
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

	local traceLine = ply:GetEyeTraceNoCursor();
	local fScale = scale
	
	if (fScale) then
		fScale = fScale * 0.25;
	end;
	
	local data = {
		text = finishedtext,
		scale = fScale,
		angles = traceLine.HitNormal:Angle(),
		position = traceLine.HitPos + (traceLine.HitNormal * 1.25)
	};
	
	data.angles:RotateAroundAxis(data.angles:Forward(), 90);
	data.angles:RotateAroundAxis(data.angles:Right(), 270);
	
	Clockwork.datastream:Start(nil, "SurfaceTextAdd", data);
	
	cwSurfaceTexts.storedList[#cwSurfaceTexts.storedList + 1] = data;
	cwSurfaceTexts:SaveSurfaceTexts();
	
	Clockwork.player:Notify(ply, "You have added some surface text.");
end


function TOOL:RightClick( tr )
	if (CLIENT) then return true; end;

	local Clockwork = Clockwork;
	local ply = self:GetOwner();

	if (!ply:IsAdmin()) then 
		return false;
	end;

	local position = ply:GetEyeTraceNoCursor().HitPos;
	local iRemoved = 0;
	
	for k, v in pairs(cwSurfaceTexts.storedList) do
		if (v.position:Distance(position) <= 256) then
			Clockwork.datastream:Start(nil, "SurfaceTextRemove", v.position);
				cwSurfaceTexts.storedList[k] = nil;
			iRemoved = iRemoved + 1;
		end;
	end;
	
	if (iRemoved > 0) then
		if (iRemoved == 1) then
			Clockwork.player:Notify(ply, "You have removed "..iRemoved.." surface text.");
		else
			Clockwork.player:Notify(ply, "You have removed "..iRemoved.." surface texts.");
		end;
	else
		Clockwork.player:Notify(ply, "There were no surface texts near this position.");
	end;
	
	cwSurfaceTexts:SaveSurfaceTexts();
end;



function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl( "Header", { 
		Text = "Text Tool", 
		Description	= "Add a string of text to the map. It can be colored and scaled." 
	});

	local CVars = {"text_text"};
	local CVars = {"text_scale"};
	local CVars = {"text_r"};
	local CVars = {"text_g"};
	local CVars = {"text_b"};
	local CVars = {"text_a"};

	CPanel:AddControl( "TextBox", { 
		Label = "Text Add/Remove",
		MaxLenth = "50",
		Command = "text_text" 
	});

	CPanel:AddControl( "Slider",  {
		Label	= "Scale",
		Type	= "Float",
		Min		= 1.0,
		Max		= 20,
		Command = "text_scale",
		Description = "Size of the text"
	});

	CPanel:AddControl("Color", {
		Label = "Text Color",
		Red = "text_r",
		Green = "text_g",
		Blue = "text_b",
		Alpha = "text_a",
		ShowHSV = 1,
		ShowRGB = 1,
		Multiplier = 255
	});
end;

TOOL:Register();