local cwThirdPerson = cwThirdPerson;

Clockwork.config:AddToSystem("Enable Third Person", "enable_third_person", "Whether or not players will be able to toggle third person.");

if (!cwThirdPerson.addedSettings) then
	Clockwork.setting:AddCheckBox("Third Person", "Enable Third Person View.", "cwThirdPerson", "Whether or not to enable third person view.");
	Clockwork.setting:AddNumberSlider("Third Person", "Back Position:", "cwChaseCamBack", -200, 200, 1, "How far back the third person camera is.");
	Clockwork.setting:AddNumberSlider("Third Person", "Right Position:", "cwChaseCamRight", -200, 200, 1, "How far to the right (or left) the third person camera is.");
	Clockwork.setting:AddNumberSlider("Third Person", "Up Position:", "cwChaseCamUp", -200, 200, 1, "How far up (or down) the third person camera is.");

	cwThirdPerson.addedSettings = true;
end;