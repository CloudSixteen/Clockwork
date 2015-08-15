local cwThirdPerson = cwThirdPerson;

Clockwork.setting:AddCheckBox("Third Person", "Enable Third Person View.", "cwThirdPerson", "Whether or not to enable third person view.");
Clockwork.setting:AddCheckBox("Third Person", "Enable Bob.", "cwChaseCamBob", "Whether or not to enable third person bobbing camera movements.");
Clockwork.setting:AddNumberSlider("Third Person", "Bob Amount:", "cwChaseCamBobScale", 0, 1, 2, "The amount to scale the bob movements by.");
Clockwork.setting:AddNumberSlider("Third Person", "Back Position:", "cwChaseCamBack", -200, 200, 1, "How far back the third person camera is.");
Clockwork.setting:AddNumberSlider("Third Person", "Right Position:", "cwChaseCamBack", -200, 200, 1, "How far to the right (or left) the third person camera is.");
Clockwork.setting:AddNumberSlider("Third Person", "Up Position:", "cwChaseCamUp", -200, 200, 1, "How far up (or down) the third person camera is.");
Clockwork.setting:AddCheckBox("Third Person", "Enable Smoothing.", "cwChaseCamSmooth", "Whether or not to enable smooth camera movements for third person.");
Clockwork.setting:AddNumberSlider("Third Person", "Smoothing Scale:", "cwChaseCamSmoothScale", 0, 1, 1, "How much to smooth camera movements by.");