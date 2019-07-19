--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when the client initializes.
function cwAreaDisplays:Initialize()
	CW_CONVAR_SHOWAREAS = Clockwork.kernel:CreateClientConVar("cwShowAreas", 1, true, true);
end;

-- Called when the local player has entered an area.
function cwAreaDisplays:PlayerEnteredArea(name, minimum, maximum)
	Clockwork.datastream:Start("EnteredArea", {name, minimum, maximum});
end;

-- Called when the local player has exited an area.
function cwAreaDisplays:PlayerExitedArea(name, minimum, maximum)
	self.currentAreaDisplay = nil;
end;

-- Called just after the translucent renderables have been drawn.
function cwAreaDisplays:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if (bDrawingSkybox or bDrawingDepth) then return; end;
	
	for k, v in pairs(self.activeDisplays) do
		if (v.class == "3D") then
			self:DrawDisplay3D(v);
			self:CalculateDisplayAlpha(v, k);
		end;
	end;
end;

-- Called when the foreground HUD should be painted.
function cwAreaDisplays:HUDPaintForeground()
	local info = {x = ScrW() * 0.1, y = ScrH() * 0.6};
	
	for k, v in pairs(self.activeDisplays) do
		if (v.class == "Scrolling") then
			self:DrawDisplayScrolling(v, info);
			self:CalculateDisplayAlpha(v, k);
		end;
	end;
end;

-- Called each tick.
function cwAreaDisplays:Tick()
	local lastAreaDisplay = self.currentAreaDisplay;
	local bDidLeave = false;
	local curTime = UnPredictedCurTime();
	
	if (!IsValid(Clockwork.Client) or !Clockwork.Client:HasInitialized()) then
		return;
	end;
	
	if (self.nextCheckAreaDisplays and curTime < self.nextCheckAreaDisplays) then
		return;
	end;
	
	self.nextCheckAreaDisplays = curTime + 1;
	
	for k, v in pairs(self.storedList) do
		if (Clockwork.entity:IsInBox(Clockwork.Client, v.minimum, v.maximum)) then
			
			if (self.currentAreaDisplay != v.name) then
				local bCalledHooks = self:HandleAreaTable(v, k);
				
				if (!bCalledHooks) then
					Clockwork.plugin:Call(
						"PlayerExitedArea", lastAreaDisplay, v.name
					);
				end;
				
				return;
			end;
		elseif (lastAreaDisplay == v.name) then
			bDidLeave = v.name;
		end;
	end;
	
	if (bDidLeave) then
		Clockwork.plugin:Call("PlayerExitedArea", bDidLeave);
	end;
end;