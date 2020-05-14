--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called just after the translucent renderables have been drawn.
function cwSurfaceTexts:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if (bDrawingSkybox or bDrawingDepth) then return; end;
	
	local large3D2DFont = Clockwork.option:GetFont("large_3d_2d");
	local colorWhite = Clockwork.option:GetColor("white");
	local eyeAngles = EyeAngles();
	local eyePos = EyePos();
	
	cam.Start3D(eyePos, eyeAngles);
		for k, v in pairs(self.storedList) do
			local alpha = math.Clamp(
				Clockwork.kernel:CalculateAlphaFromDistance(512, eyePos, v.position) * 1.5, 0, 255
			);
			
			if (alpha > 0) then
				if (!v.markupObject) then
					v.markupObject = markup.Parse(
						"<font="..large3D2DFont..">"..string.gsub(v.text, "\\n", "\n").."</font>"
					);
					Clockwork.kernel:OverrideMarkupDraw(v.markupObject);
				end;
				
				cam.Start3D2D(v.position, v.angles, (v.scale or 0.25) * 0.2);
					render.PushFilterMin(TEXFILTER.ANISOTROPIC);
					render.PushFilterMag(TEXFILTER.ANISOTROPIC);
							v.markupObject:Draw(0, 0, 1, nil, alpha);
					render.PopFilterMag();
					render.PopFilterMin();
				cam.End3D2D();
			end;
		end;
	cam.End3D();
end;