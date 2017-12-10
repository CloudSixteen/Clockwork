--[[
	This project is created with the Clockwork framework by Cloud Sixteen.
	http://cloudsixteen.com
--]]

-- Called when Clockwork has loaded all of the entities.
function Schema:ClockworkInitPostEntity() end;

-- Called when data should be saved.
function Schema:SaveData() end;

-- Called just after data should be saved.
function Schema:PostSaveData() end;

-- Called when a player's default model is needed.
function Schema:GetPlayerDefaultModel(player) end;