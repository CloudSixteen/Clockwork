--[[ 
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

Clockwork.icon = Clockwork.kernel:NewLibrary("Icon");
Clockwork.icon.stored = Clockwork.icon.stored or {};
	
--[[
	@codebase Client
	@details A function to add a chat icon.
	@param {Unknown} Missing description for uniqueID.
	@param {Unknown} Missing description for path.
	@param {Unknown} Missing description for callback.
	@param {Unknown} Missing description for isPlayer.
	@returns {Unknown}
--]]
function Clockwork.icon:Add(uniqueID, path, callback, isPlayer)
	if (uniqueID) then
		if (path) then
			if (callback) then
				self.stored[uniqueID] = {
					path = path,
					callback = callback,
					isPlayer = isPlayer
				};
			else
				MsgC(Color(255, 100, 0, 255), "[Clockwork:Icon] Error: Attempting to add icon without providing a callback.\n");
			end;
		else
			MsgC(Color(255, 100, 0, 255), "[Clockwork:Icon] Error: Attempting to add icon without providing a path..\n");
		end;
	else
		MsgC(Color(255, 100, 0, 255), "[Clockwork:Icon] Error: Attempting to add an icon without providing a uniqueID.\n");
	end;
end;

--[[
	@codebase Client
	@details A function to remove a chat icon.
	@param {Unknown} Missing description for uniqueID.
	@returns {Unknown}
--]]
function Clockwork.icon:Remove(uniqueID)
	if (uniqueID) then
		self.stored[uniqueID] = nil;
	else
		MsgC(Color(255, 100, 0, 255), "[Clockwork:Icon] Error: Attempting to remove an icon without providing a uniqueID.\n");
	end;
end;

--[[
	@codebase Client
	@details A function to set a player's icon.
	@param {Unknown} Missing description for steamID.
	@param {Unknown} Missing description for uniqueID.
	@param {Unknown} Missing description for path.
	@returns {Unknown}
--]]
function Clockwork.icon:PlayerSet(steamID, uniqueID, path)
	Clockwork.icon:Add(uniqueID, path, function(player)
		if (steamID == player:SteamID()) then
			return true;
		end;
	end, true);
end;

--[[
	@codebase Client
	@details A function to set a group's icon.
	@param {Unknown} Missing description for group.
	@param {Unknown} Missing description for uniqueID.
	@param {Unknown} Missing description for path.
	@returns {Unknown}
--]]
function Clockwork.icon:GroupSet(group, uniqueID, path)
	Clockwork.icon:Add(uniqueID, path, function(player)
		if (player:IsUserGroup(group)) then
			return true;
		end;
	end);
end;

--[[
	@codebase Client
	@details A function to return the stored icons.
	@returns {Unknown}
--]]
function Clockwork.icon:GetAll()
	return Clockwork.icon.stored;
end;

Clockwork.icon:GroupSet("superadmin", "SuperAdminShield", "icon16/shield.png");
Clockwork.icon:GroupSet("admin", "AdminStar", "icon16/star.png");
Clockwork.icon:GroupSet("operator", "OperatorSmile", "icon16/emoticon_smile.png");