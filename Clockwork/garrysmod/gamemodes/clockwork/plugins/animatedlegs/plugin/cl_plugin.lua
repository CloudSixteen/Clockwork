--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

cwAnimatedLegs.BoneHoldTypes = {
	["none"] = {
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
	},
	["fist"] = {
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
	},
	["chair"] = {
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
		"ValveBiped.Bip01_R_Upperarm",
		"ValveBiped.Bip01_L_Upperarm",
		"ValveBiped.Bip01_R_Clavicle",
		"ValveBiped.Bip01_L_Clavicle"
	},
	["default"] = {
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_L_Hand",
		"ValveBiped.Bip01_L_Forearm",
		"ValveBiped.Bip01_L_Upperarm",
		"ValveBiped.Bip01_L_Clavicle",
		"ValveBiped.Bip01_R_Hand",
		"ValveBiped.Bip01_R_Forearm",
		"ValveBiped.Bip01_R_Upperarm",
		"ValveBiped.Bip01_R_Clavicle",
		"ValveBiped.Bip01_L_Finger4",
		"ValveBiped.Bip01_L_Finger41",
		"ValveBiped.Bip01_L_Finger42",
		"ValveBiped.Bip01_L_Finger3",
		"ValveBiped.Bip01_L_Finger31",
		"ValveBiped.Bip01_L_Finger32",
		"ValveBiped.Bip01_L_Finger2",
		"ValveBiped.Bip01_L_Finger21",
		"ValveBiped.Bip01_L_Finger22",
		"ValveBiped.Bip01_L_Finger1",
		"ValveBiped.Bip01_L_Finger11",
		"ValveBiped.Bip01_L_Finger12",
		"ValveBiped.Bip01_L_Finger0",
		"ValveBiped.Bip01_L_Finger01",
		"ValveBiped.Bip01_L_Finger02",
		"ValveBiped.Bip01_R_Finger4",
		"ValveBiped.Bip01_R_Finger41",
		"ValveBiped.Bip01_R_Finger42",
		"ValveBiped.Bip01_R_Finger3",
		"ValveBiped.Bip01_R_Finger31",
		"ValveBiped.Bip01_R_Finger32",
		"ValveBiped.Bip01_R_Finger2",
		"ValveBiped.Bip01_R_Finger21",
		"ValveBiped.Bip01_R_Finger22",
		"ValveBiped.Bip01_R_Finger1",
		"ValveBiped.Bip01_R_Finger11",
		"ValveBiped.Bip01_R_Finger12",
		"ValveBiped.Bip01_R_Finger0",
		"ValveBiped.Bip01_R_Finger01",
		"ValveBiped.Bip01_R_Finger02"
	},
	["vehicle"] = {
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
	}
};

cwAnimatedLegs.PlaybackRate = 1;
cwAnimatedLegs.OldWeapon = nil;
cwAnimatedLegs.Sequence = nil;
cwAnimatedLegs.Velocity = 0;
cwAnimatedLegs.HoldType = nil;
cwAnimatedLegs.ForwardOffset = -24;
cwAnimatedLegs.BonesToRemove = {};
cwAnimatedLegs.RenderAngle = nil;
cwAnimatedLegs.RenderColor = {};
cwAnimatedLegs.BreathScale = 0.5;
cwAnimatedLegs.BoneMatrix = nil;
cwAnimatedLegs.NextBreath = 0;
cwAnimatedLegs.BiaisAngle = nil;
cwAnimatedLegs.ClipVector = vector_up * -1;
cwAnimatedLegs.RenderPos = nil;
cwAnimatedLegs.RadAngle = nil;

-- A function to get whether the legs should be drawn.
function cwAnimatedLegs:ShouldDrawLegs()
	return IsValid(self.LegsEntity) and Clockwork.Client:Alive()
	and self:CheckDrawVehicle() and GetViewEntity() == Clockwork.Client
	and !Clockwork.Client:ShouldDrawLocalPlayer() and !IsValid(Clockwork.Client:GetObserverTarget());
end;

-- A function to check if a vehicle should be drawn.
function cwAnimatedLegs:CheckDrawVehicle()
	return Clockwork.Client:InVehicle()
	and (Clockwork.Client:GetVehicle() and Clockwork.Client:GetVehicle():GetThirdPersonMode())
	or !Clockwork.Client:InVehicle();
end;

-- A function to create the legs.
function cwAnimatedLegs:CreateLegs()
	self.LegsEntity = ClientsideModel(Clockwork.Client:GetModel(), RENDER_GROUP_OPAQUE_ENTITY);
	self.LegsEntity:SetNoDraw(true);
	self.LegsEntity:SetSkin(Clockwork.Client:GetSkin());
	self.LegsEntity:SetMaterial(Clockwork.Client:GetMaterial());
	self.LegsEntity.LastTick = 0;
end;

-- A function to get when a weapon is changed.
function cwAnimatedLegs:WeaponChanged(weapon)
	if (IsValid(self.LegsEntity)) then
		if (IsValid(weapon)) then
			self.HoldType = weapon.HoldType;
		else
			self.HoldType = "none";
		end;
		
		for i = 0, self.LegsEntity:GetBoneCount() do
			self.LegsEntity:ManipulateBoneScale(i, Vector(1, 1, 1));
			self.LegsEntity:ManipulateBonePosition(i, vector_origin);
		end;
		
		self.BonesToRemove = {"ValveBiped.Bip01_Head1"};
			
		if (!Clockwork.Client:InVehicle()) then
			if ((self.HoldType != "fist" or !Clockwork.player:GetWeaponRaised(Clockwork.Client))
			and self.BoneHoldTypes[self.HoldType]) then
				self.BonesToRemove = self.BoneHoldTypes[self.HoldType];
			else
				self.BonesToRemove = self.BoneHoldTypes["default"];
			end;
		elseif (!Clockwork.entity:IsChairEntity(Clockwork.Client:GetVehicle())) then
			self.BonesToRemove = self.BoneHoldTypes["vehicle"];
		else
			self.BonesToRemove = self.BoneHoldTypes["chair"];
		end;
		
		for k, v in pairs(self.BonesToRemove) do
			local bone = self.LegsEntity:LookupBone(v);
			
			if (bone) then
				self.LegsEntity:ManipulateBoneScale(bone, vector_origin);
				self.LegsEntity:ManipulateBonePosition(bone, Vector(-10,-10,0));
			end;
		end;
	end;
end;

-- Called every frame for the legs.
function cwAnimatedLegs:LegsThink(maxSeqGroundSpeed)
	local curTime = CurTime();
	
	if (IsValid(self.LegsEntity)) then
		if (Clockwork.Client:GetActiveWeapon() != self.OldWeapon) then
			self.OldWeapon = Clockwork.Client:GetActiveWeapon();
			self:WeaponChanged(self.OldWeapon);
		end;
		
		if (self.LegsEntity:GetModel() != Clockwork.Client:GetModel()) then
			self.LegsEntity:SetModel(Clockwork.Client:GetModel());
		end
		
		self.LegsEntity:SetMaterial(Clockwork.Client:GetMaterial());
		self.LegsEntity:SetSkin(Clockwork.Client:GetSkin());
		self.Velocity = Clockwork.Client:GetVelocity():Length2D();
		self.PlaybackRate = 1;

		if (self.Velocity > 0.5) then
			if (maxSeqGroundSpeed < 0.001) then
				self.PlaybackRate = 0.01;
			else
				self.PlaybackRate = self.Velocity / maxSeqGroundSpeed;
				self.PlaybackRate = math.Clamp(self.PlaybackRate, 0.01, 10);
			end
		end
		
		self.LegsEntity:SetPlaybackRate(self.PlaybackRate);
		self.Sequence = Clockwork.Client:GetSequence();
		
		if (self.LegsEntity.Anim != self.Sequence) then
			self.LegsEntity.Anim = self.Sequence;
			self.LegsEntity:ResetSequence(self.Sequence);
		end;
		
		self.LegsEntity:FrameAdvance(curTime - self.LegsEntity.LastTick);
		self.LegsEntity.LastTick = curTime;
		
		if (self.NextBreath <= curTime) then
			self.NextBreath = curTime + 1.95 / self.BreathScale;
			self.LegsEntity:SetPoseParameter("breathing", self.BreathScale);
		end
		
		self.LegsEntity:SetPoseParameter("move_yaw", (Clockwork.Client:GetPoseParameter("move_yaw") * 360) - 180);
		self.LegsEntity:SetPoseParameter("body_yaw", (Clockwork.Client:GetPoseParameter("body_yaw") * 180) - 90);
		self.LegsEntity:SetPoseParameter("spine_yaw", (Clockwork.Client:GetPoseParameter("spine_yaw") * 180) - 90);
		
		if (Clockwork.Client:InVehicle()) then
			self.LegsEntity:SetColor(color_transparent);
			self.LegsEntity:SetPoseParameter("vehicle_steer", (Clockwork.Client:GetVehicle():GetPoseParameter("vehicle_steer") * 2) - 1);
		end;
	end;
end;
