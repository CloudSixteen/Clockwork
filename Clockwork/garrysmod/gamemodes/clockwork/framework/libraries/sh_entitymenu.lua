--[[
	© 2013 Slidefuse.net
	Half-Life Universe
--]]

Clockwork.entityMenu = Clockwork.kernel:NewLibrary("EntityMenu");

--Clockwork.entityMenu = {};

if (CLIENT) then

	surface.CreateFont("popup_title", {
		font = "Arial", 
		size = Clockwork.kernel:FontScreenScale(10), 
		weight = 700
	})
	surface.CreateFont("popup_option", {
		font = "Arial", 
		size = Clockwork.kernel:FontScreenScale(7), 
		weight = 700
	})

	Clockwork.entityMenu.stored = {}
	Clockwork.entityMenu.callbacks = {}
	Clockwork.entityMenu.activeEnts = {}

	-- Add a new popup menu.
	function Clockwork.entityMenu:New(data)
		self.stored[data.id] = data
	end

	-- Draw the popup menus..
	function Clockwork.entityMenu:RenderScreenspaceEffects()
		for k,v in pairs(self.stored) do
			Clockwork.entityMenu:UpdateSelection();

			if (IsValid(k) and k:IsValid()) then
				v.origin = k:GetPos();
			end;

			local pos = v.origin:ToScreen()
			local distance = LocalPlayer():GetPos():Distance(v.origin)
			local alpha = 255

			if (distance >= v.distance*0.75) then
				alpha = ((v.distance - distance)/(v.distance*0.75))*255*2.25
			end

			if (pos.visible) then
				local y = pos.y - 28
				local x = pos.x - v.width / 2
				
				local titleWidth = surface.GetTextSize(v.title)
				v.width = math.max(v.width, titleWidth + 4)
		
				Clockwork.kernel:OverrideMainFont("popup_title")
					y = Clockwork.kernel:DrawSimpleText(v.title, x, y, Color(255, 255, 255, alpha), 0, 0)
				Clockwork.kernel:OverrideMainFont(false)

				draw.RoundedBox(4, x, y, v.width + 4, v.height + 4, Color(20, 20, 30, alpha))
				y = y + 2
				for a,b in ipairs(v.options) do
					local textWidth = surface.GetTextSize(b.text)
					if (textWidth > v.width) then
						v.width = textWidth + 4
					end
					local colour = Color(40, 50, 70, alpha)
					if (self.selected and self.selected.id and self.selected.id == b.id) then
						colour = Color(120, 120, 140, alpha)
					end
					if (a == 1) then
						draw.RoundedBoxEx(4, x+2, y, v.width, 16, colour, true, true, false, false)
					elseif (a == #v.options) then
						draw.RoundedBoxEx(4, x+2, y, v.width, 16, colour, false, false, true, true)
					else
						draw.RoundedBoxEx(4, x+2, y, v.width, 16, colour, false, false, false, false)
					end

					Clockwork.kernel:OverrideMainFont("popup_option")
						Clockwork.kernel:DrawSimpleText(b.text, x + v.width / 2, y + 8, Color(240, 240, 240, alpha), 1, 1)
					Clockwork.kernel:OverrideMainFont(false)
					y = y + 16
					
					v.height = a * 16
				end
			else
				self.stored[k] = nil
			end
		end

		self:DrawCursor()
	end

	function Clockwork.entityMenu:UpdateSelection()
		for k,v in pairs(self.stored) do
			if (LocalPlayer():GetPos():Distance(v.origin) > v.distance) then
				self.stored[k] = nil
				self.activeEnts[v.entity] = nil
			end
			
	--		local mousePos = LocalPlayer():GetEyeTrace().HitPos:ToScreen()
			local mouseX, mouseY = input.GetCursorPos();
			local mousePos = {x = mouseX, y = mouseY};
			local originPos = v.origin:ToScreen()
			local y = originPos.y
			local x = originPos.x - v.width / 2
			
			if !(y < 0 or y > ScrH() or x < 0 or x > ScrW()) then
				//self.stored[k] = nil
	--		else
				if ((mousePos.x >= x and mousePos.x <= (x + v.width)) and (mousePos.y >= y and mousePos.y <= (y + v.height))) then
					for a,b in ipairs(v.options) do
						local newY = y + (a-1)*16;

						if (mousePos.y >= newY and mousePos.y <= (newY + 16)) then
							self.selected = {parent = v.id, id = b.id};
						end;
					end;
					
					break;
				else
					self.selected = nil;
				end;
			end;
		end;
	end;

	-- Draw the cursor when a popup is active.
	function Clockwork.entityMenu:DrawCursor()
		local origin = LocalPlayer():GetEyeTrace().HitPos:ToScreen()
		if (table.Count(self.stored) > 0) then
			surface.SetDrawColor(20, 20, 20, 255)
			surface.DrawRect(origin.x - 3, origin.y - 3, 6, 6)
			surface.SetDrawColor(240, 240, 240, 255)
			surface.DrawRect(origin.x - 2, origin.y - 2, 4, 4)
		end
	end

	function Clockwork.entityMenu:Create(entity, title, options, distance, pos)
		if (self.activeEnts[entity]) then return; end;
	--	self.activeEnts = {};
		self.stored = {}
		self.callbacks = {}
		self.activeEnts = {}

		self.activeEnts[entity] = true;

		if (!pos) then pos = LocalPlayer():GetEyeTrace().HitPos; end;
		if (!distance) then distance = 256; end;

		local id = id or #self.stored + 1;
		local sendOptions = {}
		
		for k,v in ipairs(options) do
			local id = util.CRC(tostring(v.callback)..tostring(SysTime()))
			self.callbacks[id] = v.callback
			
			table.insert(sendOptions, {id = id, text = v.text})
		end
		
		local create = {
			id = entity or id,
			title = title,
			origin = pos,
			distance = distance,
			options = sendOptions,
			width = 128,
			height = 0,
			entity = entity
		}

		for k,v in ipairs(create.options) do
			v.parent = id
		end
		
		Clockwork.entityMenu:New(create)
	end

	-- A function to add a menu from data.
	function Clockwork.entityMenu:AddMenuFromData(entity, data, name, Callback)
		local options = {}
		local menu = {}
		menu.options = {}
		
		for k, v in pairs(data) do
			options[#options + 1] = {k, v}
		end
		
		table.sort(options, function(a, b)
			return a[1] < b[1]
		end)
		
		for k, v in pairs(options) do
			if (type(v[2]) == "table" and !v[2].isArgTable) then
				if (table.Count(v[2]) > 0) then
				end
			elseif (type(v[2]) == "function") then
				table.insert(menu.options, {text = v[1], callback = v[2]})
			elseif (Callback) then
				Callback(menu, v[1], v[2])
			end
		end

		if (#options > 0) then
			Clockwork.entityMenu:Create(entity, name or "", menu.options)
		end

		return menu
	end

	Clockwork.datastream:Hook("newPopup", function(data)
		local create = {
			entity = data[1],
			title = data[2],
			origin = data[3],
			distance = data[4],
			options = data[5],
			width = 40,
			height = 0
		}
		
		for k,v in ipairs(create.options) do
			v.parent = data[1]
		end
		
		Clockwork.entityMenu:New(create)
	end)

	function Clockwork.entityMenu:KeyRelease(player, key)
		if (table.Count(self.stored) > 0) then
			if (key == IN_USE or key == IN_ATTACK) then
				if (self.selected) then
					local id = self.selected.id;
					local entity = self.selected.parent;

					self.activeEnts[entity] = nil;

					if (self.callbacks[id]) then
						self.callbacks[id](ply, entity);
						self.callbacks[id] = nil;
					end;

					self.stored[self.selected.parent] = nil;
					self.selected = nil;
					
					return true;
				else
					local e = Clockwork.Client:GetEyeTrace().Entity;

					self.stored[e] = nil;
					self.activeEnts[e] = nil;
				end;
			end;
		end;
	end;

	Clockwork.plugin:Add("ClockworkEntityMenu", Clockwork.entityMenu);
else

	Clockwork.entityMenu.callbacks = {}

	-- Create a new popup menu.
	function Clockwork.entityMenu:Create(ply, entity, title, options, distance, pos)
		if (!ply) then return false; end;
		if (!pos) then pos = ply:GetEyeTrace().HitPos; end;
		if (!distance) then distance = 256; end;
		
		local sendOptions = {};
		self.stored = {}
		self.callbacks = {}
		self.activeEnts = {}
		
		for k,v in ipairs(options) do
			local id = util.CRC(tostring(v.callback)..tostring(SysTime()));
			self.callbacks[id] = v.callback;
			
			table.insert(sendOptions, {id = id, text = v.text});
		end;

		Clockwork.datastream:Start(ply, "newPopup", {entity, title, pos, distance, sendOptions});
	end;

	Clockwork.datastream:Hook("pressOption", function(ply, data)
		local id = data[1];
		local entity = data[2];
		
		if (Clockwork.entityMenu.callbacks[id]) then
			Clockwork.entityMenu.callbacks[id](ply, entity);
			Clockwork.entityMenu.callbacks[id] = nil;
		end;
	end);
end;