--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local TOOL = Clockwork.tool:New();

TOOL.Name 			= "Container Tool";
TOOL.UniqueID 		= "containertool";
TOOL.Desc 			= "Do various things with containers.";
TOOL.HelpText		= "Primary: Do Action";

TOOL.ClientConVar[ "mode" ]	 			= "1";
TOOL.ClientConVar[ "contfillscale" ]	= "1";
TOOL.ClientConVar[ "fillcategory" ]		= "Consumables";
TOOL.ClientConVar[ "contname" ]			= "Example Name";
TOOL.ClientConVar[ "contmessage" ]		= "Example Message";
TOOL.ClientConVar[ "contpassword" ] 	= "examplepassword";


function TOOL:AddItems(entity)

	local Clockwork = Clockwork;
	local trace = entity;
	local scale = self:GetClientInfo( "contfillscale" );
	local category = self:GetClientInfo("fillcategory");
	local player = self:GetOwner();

	if (CLIENT) then return true end;
	
	player:RunClockworkCmd("ContFill", scale, category);
end

function TOOL:SetMessage(entity)
	local trace = entity;
	local player = self:GetOwner();

	if (CLIENT) then return true end;
	
	player:RunClockworkCmd("ContSetMessage", self:GetClientInfo("contmessage"));
end

function TOOL:SetName(entity)
	local trace = entity;
	local player = self:GetOwner();
	local name = self:GetClientInfo("contname");

	if (CLIENT) then return true end;
	
	player:RunClockworkCmd("ContSetName", name);
end

function TOOL:SetPassword(entity)
	local trace = entity;
	local player = self:GetOwner();
	local password = self:GetClientInfo("contpassword");

	if (CLIENT) then return true end;
	
	player:RunClockworkCmd("ContSetPassword", password);
end

function TOOL:LeftClick( trace )
	
	local mode = self:GetClientNumber( "mode" );
	local player = self:GetOwner();
	local container = player:GetEyeTraceNoCursor();

	if (!player:IsAdmin()) then 
		return false;
	end
	
	if (IsValid(container.Entity)) then
		if(mode == 1) then
			self:AddItems(container);
		end
		if(mode == 2) then
			self:SetMessage(container);
		end
		if(mode == 3) then
			self:SetName(container);
		end
		if(mode == 4) then
			self:SetPassword(container);
		end
	end
end


if CLIENT then
	
	local function AddDefControls( Panel )

		Panel:ClearControls();
	

		local mode = LocalPlayer():GetInfoNum( "containertool_mode", 0 );
		
		local list = vgui.Create("DListView");


		local height = 90;
		
		

		list:SetSize(30,height);
		--list:SizeToContents()
		list:AddColumn("Tool Mode");
		list:SetMultiSelect(false);
		function list:OnRowSelected(LineID, line)
			if not (mode == LineID) then
				RunConsoleCommand("cont_setmode", LineID);
			end
		end

		if ( mode == 1 ) then
			list:AddLine(L("ContainerToolSelectedMode1"));
		else
			list:AddLine(L("ContainerToolMode1"));
		end
		if ( mode == 2 ) then
			list:AddLine(L("ContainerToolSelectedMode2"));
		else
			list:AddLine(L("ContainerToolMode2"));
		end
		if ( mode == 3 ) then
			list:AddLine(L("ContainerToolSelectedMode3"));
		else
			list:AddLine(L("ContainerToolMode3"));
		end
		if ( mode == 4 ) then
			list:AddLine(L("ContainerToolSelectedMode4"));
		else
			list:AddLine(L("ContainerToolMode4"));
		end
		
		list:SortByColumn(1);

		Panel:AddItem(list);

		

		if ( mode == 1 ) then 
			Panel:AddControl( "Slider",  { 
					Label	= L("ContainerToolScaleOfFillName"),
					Type	= "Interger",
					Min		= 1,
					Max		= 5,
					Command = "containertool_contfillscale",
					Description = L("ContainerToolScaleOfFillDesc")}	 );

			Panel:AddControl( "TextBox", { 
									 Label = L("ContainerToolCategoryName"),
									 MaxLenth = "20",
									 Command = "containertool_fillcategory" } );
		end
		if ( mode == 2 ) then 
			Panel:AddControl( "TextBox", { 
									 Label = L("ContainerToolMessage"),
									 MaxLenth = "20",
									 Command = "containertool_contmessage" } );
		end
		if ( mode == 3) then 
			Panel:AddControl( "TextBox", { 
						Label = L("ContainerToolName"),
						MaxLenth = "20",
						Command = "containertool_contname" } );
		end
		if ( mode == 4) then 
			Panel:AddControl( "TextBox", { 
									 Label = L("ContainerToolPassword"),
									 MaxLenth = "20",
									 Command = "containertool_contpassword" } );
		end
	end
	
	function cont_setmode( player, tool, args )
		if LocalPlayer():GetInfoNum( "containertool_mode", 3 ) != args[1] then
			RunConsoleCommand("containertool_mode", args[1]);
			timer.Simple(0.05, function() cont_updatepanel(); end );
		end
	end
	concommand.Add( "cont_setmode", cont_setmode );

	function cont_updatepanel()
		local Panel = controlpanel.Get( "containertool" );
		if (!Panel) then return end
		AddDefControls( Panel );
	end
	concommand.Add( "cont_updatepanel", cont_updatepanel );

	function TOOL.BuildCPanel( Panel )
		AddDefControls( Panel );
	end
end
	
local plugin = Clockwork.plugin:FindByID("Storage");
	
if (plugin) then
	if (Clockwork.plugin:IsDisabled(plugin.name) or Clockwork.plugin:IsUnloaded(plugin.name)) then
		
	else
		TOOL:Register();
	end	
end