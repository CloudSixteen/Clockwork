--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called just after the translucent renderables have been drawn.
function cwDynamicAdverts:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if (bDrawingSkybox or bDrawingDepth) then return; end;
	
	local eyeAngles = EyeAngles();
	local curTime = UnPredictedCurTime();
	local eyePos = EyePos();
	
	cam.Start3D(eyePos, eyeAngles);
		for k, v in pairs(self.storedList) do
			if (!IsValid(v.panel)) then
				if (Clockwork.player:CanSeePosition(Clockwork.Client, v.position, nil, true)) then
					self:CreateHTMLPanel(v);
				end;
			else
				v.panel:SetPaintedManually(false);
					cam.Start3D2D(v.position, v.angles, v.scale or 0.25);
						render.PushFilterMin(TEXFILTER.ANISOTROPIC);
						render.PushFilterMag(TEXFILTER.ANISOTROPIC);
								v.panel:PaintManual();
						render.PopFilterMag();
						render.PopFilterMin();
					cam.End3D2D();
				v.panel:SetPaintedManually(true);
			end;
		end;
	cam.End3D();
end;