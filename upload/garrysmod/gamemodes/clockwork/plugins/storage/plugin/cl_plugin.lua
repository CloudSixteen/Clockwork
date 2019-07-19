--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.datastream:Hook("StorageMessage", function(data)
	local entity = data.entity;
	local message = data.message;
	
	if (IsValid(entity)) then
		entity.cwMessage = message;
	end;
end);

Clockwork.datastream:Hook("ContainerPassword", function(data)
	local entity = data;
	
	Derma_StringRequest("Password", "What is the password for this container?", nil, function(text)
		Clockwork.datastream:Start("ContainerPassword", {text, entity});
	end);
end);