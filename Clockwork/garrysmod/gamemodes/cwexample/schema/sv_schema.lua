--[[
	This project is created with the Clockwork framework by Cloud Sixteen.
	http://cloudsixteen.com
--]]

-- This is where you might add any functions for your schema.
function Schema:MakeAnnouncement(text)
	Clockwork.player:NotifyAll(text);
end;