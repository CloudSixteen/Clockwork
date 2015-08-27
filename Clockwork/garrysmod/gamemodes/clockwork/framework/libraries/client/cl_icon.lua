--[[ 
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

Clockwork.icon = Clockwork.kernel:NewLibrary("Icon");
Clockwork.icon.stored = Clockwork.icon.stored or {};
	
-- A function to add a chat icon.
function Clockwork.icon:Add(uniqueID, path, callback, bIsPlayer)
	if (uniqueID) then
		if (path) then
			if (callback) then
				self.stored[uniqueID] = {
					path = path,
					callback = callback,
					isPlayer = bIsPlayer
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

-- A function to remove a chat icon.
function Clockwork.icon:Remove(uniqueID)
	if (uniqueID) then
		self.stored[uniqueID] = nil;
	else
		MsgC(Color(255, 100, 0, 255), "[Clockwork:Icon] Error: Attempting to remove an icon without providing a uniqueID.\n");
	end;
end;

-- A function to set a player's icon.
function Clockwork.icon:PlayerSet(steamID, uniqueID, path)
	Clockwork.icon:Add(uniqueID, path, function(player)
		if (steamID == player:SteamID()) then
			return true;
		end;
	end, true);
end;

-- A function to set a group's icon.
function Clockwork.icon:GroupSet(group, uniqueID, path)
	Clockwork.icon:Add(uniqueID, path, function(player)
		if (player:IsUserGroup(group)) then
			return true;
		end;
	end);
end;

-- A function to return the stored icons.
function Clockwork.icon:GetAll()
	return Clockwork.icon.stored;
end;

Clockwork.icon:GroupSet("superadmin", "SuperAdminShield", "icon16/shield.png");
Clockwork.icon:GroupSet("admin", "AdminStar", "icon16/star.png");
Clockwork.icon:GroupSet("operator", "OperatorSmile", "icon16/emoticon_smile.png");