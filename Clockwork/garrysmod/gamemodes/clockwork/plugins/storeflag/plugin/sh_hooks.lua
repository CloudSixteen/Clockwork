--[[
© CloudSixteen.com do not share, re-distribute or modify
without permission of its author (kurozael@gmail.com).

Clockwork was created by Conna Wiles (also known as kurozael.)
https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode
--]]

function cwStoreFlag:ClockworkItemInitialized(itemTable)
	if (itemTable.access and not string.find(itemTable.access, 'N')) then
		itemTable.access = itemTable.access.."N";
	end;
end;