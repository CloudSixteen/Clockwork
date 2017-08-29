--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when an entity's target ID HUD should be painted.
function cwStorage:HUDPaintEntityTargetID(entity, info)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	
	if (Clockwork.entity:IsPhysicsEntity(entity)) then
		local model = string.lower(entity:GetModel());
		
		if (self.containerList[model]) then
			if (entity:GetNetworkedString("Name") != "") then
				info.y = Clockwork.kernel:DrawInfo(entity:GetNetworkedString("Name"), info.x, info.y, colorTargetID, info.alpha);
			else
				info.y = Clockwork.kernel:DrawInfo(self.containerList[model][2], info.x, info.y, colorTargetID, info.alpha);
			end;
			
			info.y = Clockwork.kernel:DrawInfo("You can put stuff inside it.", info.x, info.y, colorWhite, info.alpha);
		end;
	end;
end;

-- Called when an entity's menu options are needed.
function cwStorage:GetEntityMenuOptions(entity, options)
	if (Clockwork.entity:IsPhysicsEntity(entity)) then
		local model = string.lower(entity:GetModel());
		
		if (self.containerList[model]) then
			options["Open"] = "cwContainerOpen";
		end;
	end;
end;

-- Called when the local player's storage is rebuilt.
function cwStorage:PlayerStorageRebuilt(panel, categories)
	if (panel.storageType == "Container") then
		local entity = Clockwork.storage:GetEntity();
		
		if (IsValid(entity) and entity.cwMessage) then
			local messageForm = vgui.Create("DForm", panel);
			local helpText = messageForm:Help(entity.cwMessage);
				messageForm:SetPadding(5);
				messageForm:SetName("Message");
				helpText:SetFont("Default");
			panel:AddItem(messageForm);
		end;
	end;
end;