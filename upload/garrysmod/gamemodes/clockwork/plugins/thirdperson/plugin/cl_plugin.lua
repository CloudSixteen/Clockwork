local cwThirdPerson = cwThirdPerson;

Clockwork.config:AddToSystem("EnableThirdPerson", "enable_third_person", "EnableThirdPersonDesc");

if (!cwThirdPerson.addedSettings) then
	Clockwork.setting:AddCheckBox("ThirdPerson", "EnableThirdPersonView", "cwThirdPerson", "EnableThirdPersonViewDesc");
	Clockwork.setting:AddNumberSlider("ThirdPerson", "BackPosition", "cwChaseCamBack", -200, 200, 1, "BackPositionDesc");
	Clockwork.setting:AddNumberSlider("ThirdPerson", "RightPosition", "cwChaseCamRight", -200, 200, 1, "RightPositionDesc");
	Clockwork.setting:AddNumberSlider("ThirdPerson", "UpPosition", "cwChaseCamUp", -200, 200, 1, "UpPositionDesc");

	cwThirdPerson.addedSettings = true;
end;