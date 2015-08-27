--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local tonumber = tonumber;

Clockwork.time = Clockwork.kernel:NewLibrary("Time");
Clockwork.date = Clockwork.kernel:NewLibrary("Date");

-- A function to get the time minute.
function Clockwork.time:GetMinute()
	if (CLIENT) then
		return Clockwork.kernel:GetSharedVar("Minute");
	else
		return self.minute;
	end;
end;

-- A function to get the time hour.
function Clockwork.time:GetHour()
	if (CLIENT) then
		return Clockwork.kernel:GetSharedVar("Hour");
	else
		return self.hour;
	end;
end;

-- A function to get the time day.
function Clockwork.time:GetDay()
	if (CLIENT) then
		return Clockwork.kernel:GetSharedVar("Day");
	else
		return self.day;
	end;
end;

-- A function to get the day name.
function Clockwork.time:GetDayName()
	local defaultDays = Clockwork.option:GetKey("default_days");
	
	if (defaultDays) then
		return defaultDays[self:GetDay()] or "Unknown";
	end;
end;

if (SERVER) then
	function Clockwork.time:GetSaveData()
		return {
			minute = self:GetMinute(),
			hour = self:GetHour(),
			day = self:GetDay()
		};
	end;
	
	-- A function to get the date save data.
	function Clockwork.date:GetSaveData()
		return {
			month = self:GetMonth(),
			year = self:GetYear(),
			day = self:GetDay()
		};
	end;
	
	-- A function to get the date year.
	function Clockwork.date:GetYear()
		return self.year;
	end;

	-- A function to get the date month.
	function Clockwork.date:GetMonth()
		return self.month;
	end;

	-- A function to get the date day.
	function Clockwork.date:GetDay()
		return self.day;
	end;
else
	function Clockwork.date:GetString()
		return Clockwork.kernel:GetSharedVar("Date");
	end;
	
	-- A function to get the time as a string.
	function Clockwork.time:GetString()
		local minute = Clockwork.kernel:ZeroNumberToDigits(self:GetMinute(), 2);
		local hour = Clockwork.kernel:ZeroNumberToDigits(self:GetHour(), 2);
		
		if (CW_CONVAR_TWELVEHOURCLOCK:GetInt() == 1) then
			hour = tonumber(hour);
			
			if (hour >= 12) then
				if (hour > 12) then
					hour = hour - 12;
				end;
				
				return Clockwork.kernel:ZeroNumberToDigits(hour, 2)..":"..minute.."pm";
			else
				return Clockwork.kernel:ZeroNumberToDigits(hour, 2)..":"..minute.."am";
			end;
		else
			return hour..":"..minute;
		end;
	end;
end;