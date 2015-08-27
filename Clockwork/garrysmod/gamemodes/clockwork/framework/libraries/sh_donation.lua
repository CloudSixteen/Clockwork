--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local table = table;
local os = os;

Clockwork.donation = Clockwork.kernel:NewLibrary("Donation");
Clockwork.donation.stored = Clockwork.donation.stored or {};

-- A function to register a new donation subscription.
function Clockwork.donation:Register(uniqueID, friendlyName, description, imageName)
	self.stored[uniqueID] = {
		friendlyName = friendlyName,
		description = description,
		imageName = imageName
	};
	
	if (imageName and SERVER) then
		Clockwork.kernel:AddFile("materials/"..imageName..".png");
	end;
end;

-- A function to get a donation subscription table.
function Clockwork.donation:Get(uniqueID)
	return self.stored[uniqueID];
end;

if (SERVER) then
	function Clockwork.donation:IsSubscribed(player, uniqueID)
		local expireTime = player.cwDonations[uniqueID];
		
		if (expireTime and (expireTime == 0 or os.clock() < expireTime)) then
			return expireTime;
		end;
		
		return false;
	end;
else
	Clockwork.donation.active = Clockwork.donation.active or {};
	Clockwork.donation.hasDonated = false;
	
	-- A function to get whether the local player is subscribed to a donation.
	function Clockwork.donation:IsSubscribed(uniqueID)
		return self.active[uniqueID] or false;
	end;
	
	-- A function to get whether the local player has donated at all.
	function Clockwork.donation:HasDonated()
		return self.hasDonated;
	end;
	
	Clockwork.datastream:Hook("Donations", function(data)
		Clockwork.donation.active = data;
		
		if (table.Count(data) > 0) then
			Clockwork.donation.hasDonated = true;
		end;
	end);
end;