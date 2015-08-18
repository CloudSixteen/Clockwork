--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
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
TOOL.ClientConVar[ "contname" ]			= "A Container";
TOOL.ClientConVar[ "contmessage" ]		= "A Message";
TOOL.ClientConVar[ "contpassword" ] 	= "password";


function TOOL:AddItems(entity)

	local Clockwork = Clockwork;
	local trace = entity;
	local scale = self:GetClientInfo( "contfillscale" );
	local category = self:GetClientInfo("fillcategory");
	local player = self:GetOwner();

	if (CLIENT) then return true end;

	if (scale) then
		scale = math.Clamp(math.Round(scale), 1, 5);
		
		if (IsValid(trace.Entity)) then
			if (Clockwork.entity:IsPhysicsEntity(trace.Entity)) then
				local model = string.lower(trace.Entity:GetModel());
				
				if (cwStorage.containerList[model]) then
					if (!trace.Entity.inventory) then
						cwStorage.storage[trace.Entity] = trace.Entity;
						
						trace.Entity.inventory = {};
					end;
					
					local containerWeight = cwStorage.containerList[model][1] / (6 - scale);
					local weight = Clockwork.inventory:CalculateWeight(trace.Entity.inventory);
					
					if (!category or cwStorage:CategoryExists(category)) then
						while (weight < containerWeight) do
							local randomItem = cwStorage:GetRandomItem(category);
							
							if (randomItem) then
								Clockwork.inventory:AddInstance(
									trace.Entity.inventory, Clockwork.item:CreateInstance(randomItem[1])
								);
								
								weight = weight + randomItem[2];
							end;
						end;
					
						Clockwork.player:Notify(player, "This container has been filled with random items.");
						return;
					else
						Clockwork.player:Notify(player, "That category doesn't exist!"); 
						return;
					end
				end;

				Clockwork.player:Notify(player, "This is not a valid container!");
			else
				Clockwork.player:Notify(player, "This is not a valid container!");
			end;
		else
			Clockwork.player:Notify(player, "This is not a valid container!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid scale!");
	end;
end

function TOOL:SetMessage(entity)
	local trace = entity;
	local player = self:GetOwner();

	if (CLIENT) then return true end;

	if (IsValid(trace.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(trace.Entity)) then
			trace.Entity.cwMessage = self:GetClientInfo("contmessage");
			
			Clockwork.player:Notify(player, "You have set this container's message.");
		else
			Clockwork.player:Notify(player, "This is not a valid container!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid container!");
	end;
end

function TOOL:SetName(entity)
	local trace = entity;
	local player = self:GetOwner();
	local name = self:GetClientInfo("contname");

	if (CLIENT) then return true end;

	if (IsValid(trace.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(trace.Entity)) then
			local model = string.lower(trace.Entity:GetModel());
			
			
			if (cwStorage.containerList[model]) then
				if (!trace.Entity.inventory) then
					cwStorage.storage[trace.Entity] = trace.Entity;
					
					trace.Entity.inventory = {};
				end;
				
				trace.Entity:SetNetworkedString("Name", name);
			else
				Clockwork.player:Notify(player, "This is not a valid container!");
			end;
		else
			Clockwork.player:Notify(player, "This is not a valid container!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid container!");
	end;
end

function TOOL:SetPassword(entity)
	local trace = entity;
	local player = self:GetOwner();
	local password = self:GetClientInfo("contpassword");

	if (CLIENT) then return true end;
	
	if (IsValid(trace.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(trace.Entity)) then
			local model = string.lower(trace.Entity:GetModel());
			
			if (cwStorage.containerList[model]) then
				if (!trace.Entity.inventory) then
					cwStorage.storage[trace.Entity] = trace.Entity;
					trace.Entity.inventory = {};
				end;
				
				trace.Entity.cwPassword = password
				
				Clockwork.player:Notify(player, "This container's password has been set to '"..trace.Entity.cwPassword.."'.");
			else
				Clockwork.player:Notify(player, "This is not a valid container!");
			end;
		else
			Clockwork.player:Notify(player, "This is not a valid container!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid container!");
	end;
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
			list:AddLine(" 1 **Container Filler**");
		else
			list:AddLine(" 1   Container Filler");
		end
		if ( mode == 2 ) then
			list:AddLine(" 2 **Container Set Message**");
		else
			list:AddLine(" 2   Container Set Message");
		end
		if ( mode == 3 ) then
			list:AddLine(" 3 **Container Set Name**");
		else
			list:AddLine(" 3   Container Set Name  ");
		end
		if ( mode == 4 ) then
			list:AddLine(" 4 **Container Set Password**");
		else
			list:AddLine(" 4   Container Set Password  ");
		end
		
		list:SortByColumn(1);

		Panel:AddItem(list);

		

		if ( mode == 1 ) then 
			Panel:AddControl( "Slider",  { 
					Label	= "Item Fill Scale",
					Type	= "Interger",
					Min		= 1,
					Max		= 5,
					Command = "containertool_contfillscale",
					Description = "Scale of Item fill"}	 );

			Panel:AddControl( "TextBox", { 
									 Label = "Category",
									 MaxLenth = "20",
									 Command = "containertool_fillcategory" } );
		end
		if ( mode == 2 ) then 
			Panel:AddControl( "TextBox", { 
									 Label = "Message",
									 MaxLenth = "20",
									 Command = "containertool_contmessage" } );
		end
		if ( mode == 3) then 
			Panel:AddControl( "TextBox", { 
						Label = "Name",
						MaxLenth = "20",
						Command = "containertool_contname" } );
		end
		if ( mode == 4) then 
			Panel:AddControl( "TextBox", { 
									 Label = "Password",
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
	
TOOL:Register();