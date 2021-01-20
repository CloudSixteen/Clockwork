--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

function cwLogo:PostDrawBackgroundBlurs()
	if (INTRO_HTML) then
		Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255));
	end;
	
	if (self.NewIntroFadeOut) then
		local duration = self.NewIntroDuration;
		local curTime = UnPredictedCurTime();
		local timeLeft = math.Clamp(self.NewIntroFadeOut - curTime, 0, duration);
		local material = self.NewIntroOverrideImage;
		local sineWave = math.sin(curTime);
		local height = 256;
		local width = 512;
		local alpha = 384;
		local scrW = ScrW();
		local scrH = ScrH();
		
		if (timeLeft <= 3) then
			alpha = (255 / 3) * timeLeft;
		end;
		
		if (timeLeft > 0) then
			if (sineWave > 0) then
				width = width - (sineWave * 16);
				height = height - (sineWave * 4);
			end;
			
			local x, y = (scrW / 2) - (width / 2), (scrH * 0.3) - (height / 2);
			
			Clockwork.kernel:DrawSimpleGradientBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, alpha));
			Clockwork.kernel:DrawGradient(
				GRADIENT_CENTER, 0, y - 8, scrW, height + 16, Color(100, 100, 100, math.min(alpha, 150))
			);
			
			material:SetFloat("$alpha", alpha / 255);
			
			surface.SetDrawColor(255, 255, 255, alpha);
				surface.SetMaterial(material);
			surface.DrawTexturedRect(x, y, width, height);
		else
			self.NewIntroFadeOut = nil;
			self.NewIntroOverrideImage = nil;
			
			if (INTRO_CALLBACK) then
				INTRO_CALLBACK();
			end;	
		end;
	end;
end;

function cwLogo:ShouldCharacterMenuBeCreated()
	if (self.introActive) then
		return false;
	end;
end;