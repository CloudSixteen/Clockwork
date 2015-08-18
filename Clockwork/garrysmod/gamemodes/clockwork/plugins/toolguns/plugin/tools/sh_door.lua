--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local TOOL = Clockwork.tool:New();

TOOL.Name 			= "Door Tool";
TOOL.UniqueID 		= "doortool";
TOOL.Desc 			= "Do various things with doors.";
TOOL.HelpText		= "Primary: Do Action | Secondary: Do Action (If Applicable)";

TOOL.ClientConVar[ "mode" ]	 			= "1";
TOOL.ClientConVar[ "doorname" ]	= "A Door";
TOOL.ClientConVar[ "doordesc" ]		= "It seem's to have a handle.";



function TOOL:AddOwnable(entity)

	local Clockwork = Clockwork;
	local trace = entity;
	local doorname = self:GetClientInfo( "doorname" );
	local player = self:GetOwner();

	if (trace.Entity:GetClass() == "player") then return false end

	if (CLIENT) then return true end;

	local door = player:GetEyeTraceNoCursor().Entity;

	if not player:IsAdmin() then 
		return false;
	end

	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		local data = {
			customName = true,
			position = door:GetPos(),
			entity = door,
			name = doorname or self:GetClientInfo( "doorname" )
		};
		
		Clockwork.entity:SetDoorUnownable(data.entity, false);
		Clockwork.entity:SetDoorText(data.entity, false);
		Clockwork.entity:SetDoorName(data.entity, data.name);
		
		cwDoorCmds.doorData[data.entity] = data;
		cwDoorCmds:SaveDoorData();
		
		Clockwork.player:Notify(player, "You have set an ownable door.");
	else
		Clockwork.player:Notify(player, "This is not a valid door!");
	end;
end

function TOOL:AddUnownable(entity)
	local trace = entity;
	local player = self:GetOwner();

	if not player:IsAdmin() then 
		return false;
	end

	local doorname = self:GetClientInfo( "doorname" );

	local description = self:GetClientInfo( "doordesc" );

	if (trace.Entity:GetClass() == "player") then return false end

	if (CLIENT) then return true end

	local door = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		local data = {
			position = door:GetPos(),
			entity = door,
			text = description or self:GetClientInfo( "doordesc" ),
			name = doorname or self:GetClientInfo( "doorname" )
		};
		
		Clockwork.entity:SetDoorName(data.entity, data.name);
		Clockwork.entity:SetDoorText(data.entity, data.text);
		Clockwork.entity:SetDoorUnownable(data.entity, true);
		
		cwDoorCmds.doorData[data.entity] = data;
		cwDoorCmds:SaveDoorData();
		
		Clockwork.player:Notify(player, "You have set an unownable door.");
	else
		Clockwork.player:Notify(player, "This is not a valid door!");
	end;
end

function TOOL:LockDoor(entity)
	local trace = entity;
	local player = self:GetOwner();


	if not player:IsAdmin() then 
		return false;
	end
	
	if (trace.Entity:GetClass() == "player") then return false end
	if (CLIENT) then return true end

	local door = player:GetEyeTraceNoCursor().Entity;
		
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		door:EmitSound("doors/door_latch3.wav");
		door:Fire("Lock", "", 0);
		Clockwork.player:Notify(player, "You have locked the door!");
	else
		Clockwork.player:Notify(player, "This is not a valid door!");
	end;
end

function TOOL:UnlockDoor(entity)
	local trace = entity;
	local player = self:GetOwner();


	if not player:IsAdmin() then 
		return false;
	end
	
	if (trace.Entity:GetClass() == "player") then return false end
	if (CLIENT) then return true end

	local door = player:GetEyeTraceNoCursor().Entity;
		
	if (IsValid(door) and Clockwork.entity:IsDoor(door)) then
		door:EmitSound("doors/door_latch3.wav");
		door:Fire("Unlock", "", 0);
		Clockwork.player:Notify(player, "You have unlocked the door!");
	else
		Clockwork.player:Notify(player, "This is not a valid door!");
	end;
end

function TOOL:LeftClick(trace)
	if (CLIENT) then return true; end;
	
	local mode = self:GetClientNumber("mode");
	local player = self:GetOwner();
	local entity = player:GetEyeTraceNoCursor();

	if (!player:IsAdmin()) then
		Clockwork.player:Notify(player, "You are not an admin!");

		return false;
	end
	
	if (IsValid(entity.Entity)) then
		if(mode == 1) then
			self:LockDoor(entity);
		elseif(mode == 2) then
			self:AddOwnable(entity);
		elseif(mode == 3) then
			self:AddUnownable(entity);
		end
	end
end

function TOOL:RightClick(trace)
	if (CLIENT) then return true; end;
	
	local mode = self:GetClientNumber("mode");
	local player = self:GetOwner();
	local entity = player:GetEyeTraceNoCursor();

	if (!player:IsAdmin()) then
		Clockwork.player:Notify(player, "You are not an admin!");

		return false;
	end
	
	if (IsValid(entity.Entity)) then
		if(mode == 1) then
			self:UnlockDoor(entity);
		else
			return false;
		end
	end
end

if CLIENT then
	
	local function AddDefControls( Panel )

		Panel:ClearControls();
	

		local mode = LocalPlayer():GetInfoNum( "doortool_mode", 0 );
		
		local list = vgui.Create("DListView");


		local height = 90;
		
		

		list:SetSize(30,height);
		--list:SizeToContents()
		list:AddColumn("Tool Mode");
		list:SetMultiSelect(false);
		function list:OnRowSelected(LineID, line)
			if not (mode == LineID) then
				RunConsoleCommand("door_setmode", LineID);
			end
		end

		if (mode == 1) then
			list:AddLine(" 1 **Lock/Unlock Door**");
		else
			list:AddLine(" 1   Lock/Unlock Door");
		end
		if (mode == 2) then
			list:AddLine(" 2 **Door Set Ownable**");
		else
			list:AddLine(" 2   Door Set Ownable  ");
		end
		if (mode == 3) then
			list:AddLine(" 3 **Door Set Unownable**");
		else
			list:AddLine(" 3   Door Set Unownable  ");
		end
		
		list:SortByColumn(1);

		Panel:AddItem(list);

		

		if ( mode == 1 ) then 
			Panel:AddControl( "Header", { Text = "Lock/Unlook Door", Description	= "Lock and unlock doors!" }  );
		end
		if ( mode == 2) then 
			Panel:AddControl( "TextBox", { 
						Label = "Door Name",
						MaxLenth = "20",
						Command = "doortool_doorname" } );
		end
		if ( mode == 3) then 
			Panel:AddControl( "TextBox", { 
						Label = "Door name",
						MaxLenth = "20",
						Command = "doortool_doorname" } );
			Panel:AddControl( "TextBox", { 
						Label = "Door Description",
						MaxLenth = "20",
						Command = "doortool_doordesc" } );
		end
	end
	
	function door_setmode( player, tool, args )
		if LocalPlayer():GetInfoNum( "doortool_mode", 2 ) != args[1] then
			RunConsoleCommand("doortool_mode", args[1]);
			timer.Simple(0.05, function() door_updatepanel(); end );
		end
	end
	concommand.Add( "door_setmode", door_setmode );

	function door_updatepanel()
		local Panel = controlpanel.Get( "doortool" );
		if (!Panel) then return end
		AddDefControls( Panel );
	end
	concommand.Add( "door_updatepanel", door_updatepanel );

	function TOOL.BuildCPanel( Panel )
		AddDefControls( Panel );
	end
end
	
TOOL:Register();