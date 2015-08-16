local cwThirdPerson = cwThirdPerson;

Clockwork.config:AddToSystem("Enable Third Person", "enable_third_person", "Whether or not players will be able to toggle third person.");

Clockwork.setting:AddCheckBox("Third Person", "Enable Third Person View.", "cwThirdPerson", "Whether or not to enable third person view.", function()
	return Clockwork.config:Get("enable_third_person"):GetBoolean(); 
end);
Clockwork.setting:AddCheckBox("Third Person", "Enable Bob.", "cwChaseCamBob", "Whether or not to enable third person bobbing camera movements.", function()
	return Clockwork.config:Get("enable_third_person"):GetBoolean(); 
end);
Clockwork.setting:AddNumberSlider("Third Person", "Bob Amount:", "cwChaseCamBobScale", 0, 1, 2, "The amount to scale the bob movements by.", function()
	return Clockwork.config:Get("enable_third_person"):GetBoolean(); 
end);
Clockwork.setting:AddNumberSlider("Third Person", "Back Position:", "cwChaseCamBack", -200, 200, 1, "How far back the third person camera is.", function()
	return Clockwork.config:Get("enable_third_person"):GetBoolean(); 
end);
Clockwork.setting:AddNumberSlider("Third Person", "Right Position:", "cwChaseCamBack", -200, 200, 1, "How far to the right (or left) the third person camera is.", function()
	return Clockwork.config:Get("enable_third_person"):GetBoolean(); 
end);
Clockwork.setting:AddNumberSlider("Third Person", "Up Position:", "cwChaseCamUp", -200, 200, 1, "How far up (or down) the third person camera is.", function()
	return Clockwork.config:Get("enable_third_person"):GetBoolean(); 
end);
Clockwork.setting:AddCheckBox("Third Person", "Enable Smoothing.", "cwChaseCamSmooth", "Whether or not to enable smooth camera movements for third person.", function()
	return Clockwork.config:Get("enable_third_person"):GetBoolean(); 
end);
Clockwork.setting:AddNumberSlider("Third Person", "Smoothing Scale:", "cwChaseCamSmoothScale", 0, 1, 1, "How much to smooth camera movements by.", function()
	return Clockwork.config:Get("enable_third_person"):GetBoolean(); 
end);