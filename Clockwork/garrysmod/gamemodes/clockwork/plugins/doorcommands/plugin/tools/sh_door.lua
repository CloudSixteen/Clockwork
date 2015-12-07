--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local TOOL = Clockwork.tool:New();

TOOL.Name 		= "Door Tool";
TOOL.UniqueID 	= "doortool";
TOOL.Desc 		= "Do various things with doors.";
TOOL.HelpText 	= "Primary: Do Action | Secondary: Do Action (If Applicable)";

-- Create the convars for the client.
TOOL.ClientConVar[ "mode" ] 	= "1";
TOOL.ClientConVar[ "doorname" ]	= "A Door";
TOOL.ClientConVar[ "doordesc" ]	= "It seem's to have a handle.";

-- Called when the player clicks the left mouse button while the tool is equipped.
function TOOL:LeftClick(trace)
	if (CLIENT) then return true; end;
	
	local mode = self:GetClientNumber("mode");
	local player = self:GetOwner();

	if (mode == 1) then
		player:RunClockworkCmd("DoorLock");
	elseif(mode == 2) then
		player:RunClockworkCmd("DoorSetOwnable", self:GetClientInfo("doorname"));
	elseif(mode == 3) then
		player:RunClockworkCmd("DoorSetUnownable", self:GetClientInfo("doorname"), self:GetClientInfo("doordesc"));
	end;
end;

-- Called when the player clicks the right mouse button while the tool is equipped.
function TOOL:RightClick(trace)
	if (CLIENT) then return true; end;
	
	local mode = self:GetClientNumber("mode");
	local player = self:GetOwner();

	if (mode == 1) then
		player:RunClockworkCmd("DoorUnlock");
	end;
end;

if (CLIENT) then
	-- A function to add the controls for the tool in the tool menu.
	local function AddDefControls(panel)
		panel:ClearControls();
	
		local mode = Clockwork.Client:GetInfoNum("doortool_mode", 0);
		local list = vgui.Create("DListView");
		local height = 90;
	
		list:SetSize(30, height);
		list:AddColumn("Tool Mode");
		list:SetMultiSelect(false);

		function list:OnRowSelected(LineID, line)
			if (mode != LineID) then
				RunConsoleCommand("door_setmode", LineID);
			end;
		end;

		if (mode == 1) then
			list:AddLine(" 1 **Lock/Unlock Door**");
		else
			list:AddLine(" 1   Lock/Unlock Door");
		end;

		if (mode == 2) then
			list:AddLine(" 2 **Door Set Ownable**");
		else
			list:AddLine(" 2   Door Set Ownable  ");
		end;

		if (mode == 3) then
			list:AddLine(" 3 **Door Set Unownable**");
		else
			list:AddLine(" 3   Door Set Unownable  ");
		end;
		
		list:SortByColumn(1);

		panel:AddItem(list);

		if (mode == 1) then 
			panel:AddControl("Header", {Text = "Lock/Unlook Door", Description = "Lock and unlock doors!" });
		elseif (mode == 2) then 
			panel:AddControl( "TextBox", { 
				Label = "Door Name",
				MaxLenth = "20",
				Command = "doortool_doorname"
			});
		elseif (mode == 3) then 
			panel:AddControl( "TextBox", { 
				Label = "Door name",
				MaxLenth = "20",
				Command = "doortool_doorname"
			});

			panel:AddControl( "TextBox", { 
				Label = "Door Description",
				MaxLenth = "20",
				Command = "doortool_doordesc"
			});
		end;
	end;

	-- Called to build the controls in the tool menu.
	function TOOL.BuildCPanel(panel)
		AddDefControls(panel);
	end;

	-- A concommand that is called to set the mode of the tool, called from the controls in the tool menu.
	concommand.Add("door_setmode", function(player, tool, args)
		if (Clockwork.Client:GetInfoNum("doortool_mode", 2) != args[1]) then
			RunConsoleCommand("doortool_mode", args[1]);

			timer.Simple(0.05, function() 
				door_updatepanel(); 
			end);
		end;
	end);

	-- A concommand that is called to rebuild the control panel for the tool, to show any new changes or selections.
	concommand.Add("door_updatepanel", function()
		local panel = controlpanel.Get("doortool");

		if (!panel) then return; end;

		AddDefControls(panel);
	end);
end;

TOOL:Register();