--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

function cwLogo:LoadSchemaIntro(callback)
	local customBackground = Clockwork.option:GetKey("intro_background_url");
	local customLogo = Clockwork.option:GetKey("intro_logo_url");
	local schemaFolder = string.lower(Clockwork.kernel:GetSchemaFolder());
	local duration = 5;
	
	if (customBackground and customBackground != "") then
		if (customLogo and customLogo != "") then
			local genericURL = "http://authx.cloudsixteen.com/data/loading/generic.php";
			
			genericURL = genericURL.."?bg="..util.Base64Encode(customBackground);
			genericURL = genericURL.."&logo="..util.Base64Encode(customLogo);
			
			self:OpenIntroHTML(genericURL, duration, function()
				callback();
			end);
			
			return true;
		end;
	end;
	
	if (schemaFolder == "clockwork_hl2rp") then
		self:OpenIntroHTML("http://authx.cloudsixteen.com/data/loading/hl2rp.php", duration, function()
			callback();
		end);
		
		return true;
	end;
	
	local introImage = Clockwork.option:GetKey("intro_image");
	
	if (introImage == "") then
		callback();
		return;
	end;
	
	local curTime = UnPredictedCurTime();
	
	self.NewIntroFadeOut = curTime + duration;
	self.NewIntroDuration = duration;
	self.NewIntroOverrideImage = Material(introImage..".png");
	
	surface.PlaySound("buttons/combine_button5.wav");
	
	INTRO_CALLBACK = callback;
end;

function cwLogo:SetIntroFinished()
	self.introActive = false;
end;

function cwLogo:SetIntroActive()
	self.introActive = true;
end;

function cwLogo:StartIntro()
	local introSound = Clockwork.option:GetKey("intro_sound");
	local soundObject = nil;
	
	if (introSound ~= "") then
		soundObject = CreateSound(Clockwork.Client, introSound);
	end;
	
	local duration = 6;
	
	if (soundObject) then
		soundObject:PlayEx(0.3, 100);
	end;
	
	surface.PlaySound("buttons/button1.wav");

	self:SetIntroActive();
	
	self:OpenIntroHTML("http://authx.cloudsixteen.com/data/loading/clockwork.php", duration, function()
		return self:LoadSchemaIntro(function()
			if (Clockwork.Client:IsAdmin() and vgui.GetControlTable("cwAdminNews")) then
				local newsPanel = vgui.Create("cwAdminNews");
				
				newsPanel:SetCallback(function()
					self:SetIntroFinished();
					
					if (soundObject) then
						soundObject:FadeOut(4);
					end;
				end);
			else
				self:SetIntroFinished();
				
				if (soundObject) then
					soundObject:FadeOut(4);
				end;
			end;
		end);
	end);
end;

function cwLogo:OpenIntroHTML(website, duration, callback)
	INTRO_CALLBACK = callback;
	
	if (!INTRO_HTML) then
		INTRO_PANEL = vgui.Create("DPanel");
		INTRO_PANEL:SetSize(ScrW(), ScrH());
		INTRO_PANEL:SetPos(0, 0);
		
		INTRO_HTML = vgui.Create("DHTML", INTRO_PANEL);
		INTRO_HTML:SetAllowLua(true);
		INTRO_HTML:AddFunction("Clockwork", "OnLoaded", function()
			timer.Destroy("cw.IntroTimer");
			
			timer.Simple(duration, function()
				if (!INTRO_CALLBACK or !INTRO_CALLBACK()) then
					if (INTRO_HTML) then
						INTRO_HTML:Remove();
						INTRO_HTML = nil;
					end;
					
					if (INTRO_PANEL) then
						INTRO_PANEL:Remove();
						INTRO_PANEL = nil;
					end;
				end;
			end);
		end);
		INTRO_HTML:SetSize(ScrW(), ScrH());
		INTRO_HTML:SetPos(0, 0);
	end;
	
	INTRO_HTML:OpenURL(website);
	
	timer.Create("cw.IntroTimer", 5, 1, function()
		if (!INTRO_CALLBACK or !INTRO_CALLBACK()) then
			if (INTRO_HTML) then
				INTRO_HTML:Remove();
				INTRO_HTML = nil;
			end;
			
			if (INTRO_PANEL) then
				INTRO_PANEL:Remove();
				INTRO_PANEL = nil;
			end;
		end;
	end);
end;

Clockwork.datastream:Hook("WebIntroduction", function(data)
	cwLogo:StartIntro();
end);