--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;
local type = type;
local string = string;
local math = math;

Clockwork.animation = Clockwork.kernel:NewLibrary("Animation");
Clockwork.animation.sequences = {};
Clockwork.animation.override = {};
Clockwork.animation.models = {};
Clockwork.animation.stored = {};
Clockwork.animation.convert = {
	[ACT_HL2MP_IDLE_CROSSBOW] = "smg",
	[ACT_HL2MP_IDLE_GRENADE] = "grenade",
	[ACT_HL2MP_IDLE_SHOTGUN] = "smg",
	[ACT_HL2MP_IDLE_PHYSGUN] = "heavy",
	[ACT_HL2MP_IDLE_PISTOL] = "pistol",
	[ACT_HL2MP_IDLE_MELEE2] = "blunt",
	[ACT_HL2MP_IDLE_MELEE] = "blunt",
	[ACT_HL2MP_IDLE_KNIFE] = "blunt",
	[ACT_HL2MP_IDLE_FIST] = "fist",
	[ACT_HL2MP_IDLE_SLAM] = "slam",
	[ACT_HL2MP_IDLE_SMG1] = "smg",
	[ACT_HL2MP_IDLE_AR2] = "smg",
	[ACT_HL2MP_IDLE_RPG] = "heavy",
	[ACT_HL2MP_IDLE] = "fist",
	["gravitygun"] = "pistol",
	["crossbow"] = "heavy",
	["physgun"] = "heavy",
	["grenade"] = "grenade",
	["shotgun"] = "smg",
	["pistol"] = "pistol",
	["normal"] = "fist",
	["melee"] = "blunt",
	["slam"] = "slam",
	["smg"] = "smg",
	["ar2"] = "smg",
	["357"] = "pistol",
	["rpg"] = "heavy"
};

Clockwork.animation.holdTypes = {
	["gmod_tool"] = "pistol",
	["weapon_357"] = "pistol",
	["weapon_ar2"] = "smg",
	["weapon_smg1"] = "smg",
	["weapon_frag"] = "grenade",
	["weapon_slam"] = "slam",
	["weapon_pistol"] = "pistol",
	["weapon_crowbar"] = "blunt",
	["weapon_physgun"] = "heavy",
	["weapon_shotgun"] = "smg",
	["weapon_crossbow"] = "smg",
	["weapon_stunstick"] = "blunt",
	["weapon_physcannon"] = "heavy"
};

Clockwork.animation.stored.combineOverwatch = {
	["crouch_grenade_aim_idle"] = ACT_COVER_LOW,
	["crouch_pistol_aim_idle"] = ACT_CROUCHIDLE,
	["crouch_pistol_aim_walk"] = ACT_WALK_CROUCH_RIFLE,
	["stand_grenade_aim_idle"] = ACT_IDLE,
	["stand_pistol_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["stand_grenade_aim_run"] = ACT_RUN_AIM_SHOTGUN,
	["crouch_heavy_aim_walk"] = ACT_WALK_CROUCH_RIFLE,
	["crouch_blunt_aim_idle"] = ACT_RANGE_AIM_AR2_LOW,
	["stand_pistol_aim_idle"] = ACT_IDLE_ANGRY_SMG1,
	["crouch_heavy_aim_idle"] = ACT_CROUCHIDLE,
	["crouch_blunt_aim_walk"] = ACT_WALK_CROUCH_RIFLE,
	["stand_pistol_aim_run"] = ACT_RUN_AIM_RIFLE,
	["crouch_slam_aim_walk"] = ACT_WALK_CROUCH_RIFLE,
	["crouch_fist_aim_walk"] = ACT_WALK_CROUCH_RIFLE,
	["crouch_slam_aim_idle"] = ACT_RANGE_AIM_AR2_LOW,
	["stand_blunt_aim_idle"] = ACT_IDLE_MANNEDGUN,
	["crouch_fist_aim_idle"] = ACT_CROUCHIDLE,
	["stand_blunt_aim_walk"] = ACT_WALK_AIM_SHOTGUN,
	["stand_heavy_aim_idle"] = ACT_IDLE_ANGRY_SMG1,
	["stand_heavy_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["crouch_smg_aim_idle"] = ACT_CROUCHIDLE,
	["crouch_grenade_idle"] = ACT_COVER_LOW,
	["crouch_smg_aim_walk"] = ACT_WALK_CROUCH_RIFLE,
	["crouch_grenade_walk"] = ACT_WALK_CROUCH_RIFLE,
	["stand_fist_aim_idle"] = ACT_IDLE_ANGRY_SMG1,
	["stand_heavy_aim_run"] = ACT_RUN_AIM_RIFLE,
	["stand_blunt_aim_run"] = ACT_RUN_AIM_SHOTGUN,
	["stand_slam_aim_idle"] = ACT_IDLE_MANNEDGUN,
	["stand_fist_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["stand_grenade_idle"] = "Idle_Unarmed",
	["crouch_pistol_walk"] = ACT_WALK_CROUCH_RIFLE,
	["stand_smg_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["crouch_pistol_idle"] = ACT_CROUCHIDLE,
	["stand_grenade_walk"] = "WalkUnarmed_all",
	["stand_fist_aim_run"] = ACT_RUN_AIM_RIFLE,
	["stand_slam_aim_run"] = ACT_RUN_RIFLE,
	["stand_smg_aim_idle"] = ACT_IDLE_ANGRY_SMG1,
	["stand_smg_aim_run"] = ACT_RUN_AIM_RIFLE,
	["crouch_blunt_idle"] = ACT_COVER_LOW,
	["crouch_blunt_walk"] = ACT_WALK_CROUCH,
	["crouch_heavy_idle"] = ACT_CROUCHIDLE,
	["stand_pistol_idle"] = "Idle_Unarmed",
	["stand_pistol_walk"] = "WalkUnarmed_all",
	["stand_grenade_run"] = ACT_RUN_RIFLE,
	["crouch_heavy_walk"] = ACT_WALK_CROUCH_RIFLE,
	["crouch_slam_walk"] = ACT_WALK_CROUCH_RIFLE,
	["stand_blunt_walk"] = "WalkUnarmed_all",
	["stand_pistol_run"] = ACT_RUN_RIFLE,
	["stand_heavy_walk"] = ACT_WALK_RIFLE,
	["stand_heavy_idle"] = ACT_IDLE,
	["crouch_fist_walk"] = ACT_WALK_CROUCH_RIFLE,
	["crouch_slam_idle"] = ACT_COVER_LOW,
	["crouch_fist_idle"] = ACT_CROUCHIDLE,
	["stand_blunt_idle"] = "Idle_Unarmed",
	["stand_heavy_run"] = ACT_RUN_RIFLE,
	["stand_fist_idle"] = "Idle_Unarmed",
	["crouch_smg_idle"] = ACT_CROUCHIDLE,
	["stand_fist_walk"] = ACT_WALK_RIFLE,
	["stand_slam_idle"] = "Idle_Unarmed",
	["stand_blunt_run"] = ACT_RUN_RIFLE,
	["crouch_smg_walk"] = ACT_WALK_CROUCH_RIFLE,
	["stand_smg_walk"] = ACT_WALK_RIFLE,
	["stand_slam_run"] = ACT_RUN_RIFLE,
	["stand_smg_idle"] = ACT_IDLE,
	["stand_fist_run"] = ACT_RUN_RIFLE,
	["grenade_attack"] = ACT_RANGE_ATTACK_THROW,
	["stand_smg_run"] = ACT_RUN_RIFLE,
	["pistol_attack"] = ACT_GESTURE_RANGE_ATTACK_SMG1,
	["pistol_reload"] = ACT_GESTURE_RELOAD,
	["blunt_attack"] = ACT_MELEE_ATTACK1,
	["heavy_attack"] = ACT_GESTURE_RANGE_ATTACK_SMG1,
	["heavy_reload"] = ACT_GESTURE_RELOAD,
	["crouch_walk"] = ACT_WALK_CROUCH_RIFLE,
	["slam_attack"] = ACT_SPECIAL_ATTACK2,
	["crouch_idle"] = ACT_CROUCHIDLE,
	["stand_walk"] = "WalkUnarmed_all",
	["stand_idle"] = "Idle_Unarmed",
	["smg_attack"] = ACT_GESTURE_RANGE_ATTACK_SMG1,
	["smg_reload"] = ACT_GESTURE_RELOAD,
	["stand_run"] = ACT_RUN_RIFLE,
	["jump"] = ACT_GLIDE,
	["sit"] = ACT_COVER_LOW
};

Clockwork.animation.stored.civilProtection = {
	["crouch_grenade_aim_idle"] = ACT_COVER_PISTOL_LOW,
	["crouch_grenade_aim_walk"] = ACT_WALK,
	["stand_grenade_aim_idle"] = ACT_IDLE,
	["crouch_pistol_aim_idle"] = ACT_COVER_SMG1_LOW,
	["stand_grenade_aim_walk"] = ACT_WALK_ANGRY,
	["crouch_pistol_aim_walk"] = ACT_WALK_CROUCH,
	["crouch_heavy_aim_idle"] = ACT_COVER_SMG1_LOW,
	["crouch_blunt_aim_idle"] = ACT_COVER_SMG1_LOW,
	["stand_grenade_aim_run"] = ACT_RUN,
	["crouch_blunt_aim_walk"] = ACT_WALK_CROUCH,
	["crouch_heavy_aim_walk"] = ACT_WALK_CROUCH,
	["stand_pistol_aim_walk"] = ACT_WALK_AIM_PISTOL,
	["stand_pistol_aim_idle"] = ACT_RANGE_ATTACK_PISTOL,
	["crouch_fist_aim_walk"] = ACT_WALK_CROUCH,
	["crouch_slam_aim_walk"] = ACT_WALK_CROUCH,
	["stand_pistol_aim_run"] = ACT_RUN_AIM_PISTOL,
	["crouch_fist_aim_idle"] = ACT_COVER_SMG1_LOW,
	["stand_heavy_aim_idle"] = ACT_IDLE_ANGRY_SMG1,
	["stand_blunt_aim_idle"] = ACT_IDLE_ANGRY_MELEE,
	["crouch_slam_aim_idle"] = ACT_RANGE_AIM_PISTOL_LOW,
	["stand_blunt_aim_walk"] = ACT_WALK_ANGRY,
	["stand_heavy_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["stand_fist_aim_idle"] = ACT_RANGE_ATTACK_SMG1,
	["crouch_smg_aim_walk"] = ACT_WALK_CROUCH,
	["crouch_smg_aim_idle"] = ACT_COVER_SMG1_LOW,
	["stand_fist_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["stand_blunt_aim_run"] = ACT_RUN,
	["stand_heavy_aim_run"] = ACT_RUN_AIM_RIFLE,
	["crouch_grenade_walk"] = ACT_WALK_CROUCH,
	["crouch_grenade_idle"] = ACT_COVER_PISTOL_LOW,
	["stand_slam_aim_idle"] = ACT_IDLE_MANNEDGUN,
	["stand_slam_aim_walk"] = ACT_WALK_RIFLE,
	["stand_slam_aim_run"] = ACT_RUN_RIFLE,
	["stand_smg_aim_idle"] = ACT_IDLE_ANGRY_SMG1,
	["stand_smg_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["stand_fist_aim_run"] = ACT_RUN_RIFLE,
	["crouch_pistol_idle"] = ACT_COVER_PISTOL_LOW,
	["stand_grenade_walk"] = ACT_WALK,
	["crouch_pistol_walk"] = ACT_WALK_CROUCH,
	["stand_grenade_idle"] = ACT_IDLE,
	["stand_grenade_run"] = ACT_RUN,
	["crouch_blunt_idle"] = ACT_COVER_PISTOL_LOW,
	["stand_pistol_walk"] = ACT_WALK,
	["crouch_blunt_walk"] = ACT_WALK_CROUCH,
	["crouch_heavy_walk"] = ACT_WALK_CROUCH,
	["stand_pistol_idle"] = ACT_IDLE,
	["crouch_heavy_idle"] = ACT_COVER_SMG1_LOW,
	["stand_smg_aim_run"] = ACT_RUN_AIM_RIFLE,
	["stand_heavy_walk"] = ACT_WALK_RIFLE,
	["stand_blunt_walk"] = ACT_WALK,
	["stand_blunt_idle"] = ACT_IDLE,
	["crouch_fist_idle"] = ACT_COVER_PISTOL_LOW,
	["crouch_fist_walk"] = ACT_WALK_CROUCH,
	["crouch_slam_idle"] = ACT_COVER_PISTOL_LOW,
	["stand_pistol_run"] = ACT_RUN,
	["stand_heavy_idle"] = ACT_IDLE_SMG1,
	["crouch_slam_walk"] = ACT_WALK_CROUCH,
	["stand_heavy_run"] = ACT_RUN_RIFLE,
	["stand_slam_idle"] = ACT_IDLE,
	["stand_fist_walk"] = ACT_WALK,
	["stand_slam_walk"] = ACT_WALK,
	["stand_blunt_run"] = ACT_RUN,
	["crouch_smg_walk"] = ACT_WALK_CROUCH,
	["crouch_smg_idle"] = ACT_COVER_SMG1_LOW,
	["stand_fist_idle"] = ACT_IDLE,
	["stand_slam_run"] = ACT_RUN,
	["grenade_attack"] = ACT_RANGE_ATTACK_THROW,
	["stand_smg_idle"] = ACT_IDLE_SMG1,
	["stand_fist_run"] = ACT_RUN,
	["stand_smg_walk"] = ACT_WALK_RIFLE,
	["pistol_attack"] = ACT_GESTURE_RANGE_ATTACK_PISTOL,
	["stand_smg_run"] = ACT_RUN_RIFLE,
	["pistol_reload"] = ACT_GESTURE_RELOAD_PISTOL,
	["heavy_reload"] = ACT_GESTURE_RELOAD_SMG1,
	["heavy_attack"] = ACT_GESTURE_RANGE_ATTACK_SMG1,
	["blunt_attack"] = ACT_MELEE_ATTACK_SWING,
	["crouch_idle"] = ACT_COVER_PISTOL_LOW,
	["crouch_walk"] = ACT_WALK_CROUCH,
	["slam_attack"] = ACT_PICKUP_GROUND,
	["stand_idle"] = ACT_IDLE,
	["stand_walk"] = ACT_WALK,
	["smg_attack"] = ACT_GESTURE_RANGE_ATTACK_SMG1,
	["smg_reload"] = ACT_GESTURE_RELOAD_SMG1,
	["stand_run"] = ACT_RUN,
	["jump"] = ACT_GLIDE,
	["sit"] = ACT_COVER_PISTOL_LOW
};

Clockwork.animation.stored.femaleHuman = {
	["crouch_grenade_aim_idle"] = ACT_COVER_LOW,
	["crouch_grenade_aim_walk"] = ACT_WALK_CROUCH,
	["stand_grenade_aim_idle"] = ACT_IDLE,
	["crouch_pistol_aim_idle"] = ACT_RANGE_AIM_SMG1_LOW,
	["stand_grenade_aim_walk"] = ACT_WALK,
	["crouch_pistol_aim_walk"] = ACT_WALK_CROUCH_AIM_RIFLE,
	["crouch_heavy_aim_idle"] = ACT_RANGE_AIM_SMG1_LOW,
	["crouch_blunt_aim_idle"] = ACT_COWER,
	["stand_grenade_aim_run"] = ACT_RUN,
	["crouch_blunt_aim_walk"] = ACT_WALK_CROUCH_RIFLE,
	["crouch_heavy_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["stand_pistol_aim_walk"] = ACT_WALK_AIM_PISTOL,
	["stand_pistol_aim_idle"] = ACT_IDLE_ANGRY_PISTOL,
	["crouch_fist_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["crouch_slam_aim_walk"] = ACT_WALK_CROUCH_RPG,
	["stand_pistol_aim_run"] = ACT_RUN_AIM_PISTOL,
	["crouch_fist_aim_idle"] = ACT_RANGE_AIM_SMG1_LOW,
	["stand_heavy_aim_idle"] = ACT_IDLE_ANGRY_RPG,
	["stand_blunt_aim_idle"] = ACT_IDLE_MANNEDGUN,
	["crouch_slam_aim_idle"] = ACT_COVER_LOW_RPG,
	["stand_blunt_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["stand_heavy_aim_walk"] = ACT_WALK_AIM_RIFLE_STIMULATED,
	["stand_fist_aim_idle"] = ACT_RANGE_ATTACK_SMG1,
	["crouch_smg_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["crouch_smg_aim_idle"] = ACT_RANGE_AIM_SMG1_LOW,
	["stand_fist_aim_walk"] = ACT_WALK_AIM_RIFLE_STIMULATED,
	["stand_blunt_aim_run"] = ACT_RUN,
	["stand_heavy_aim_run"] = ACT_RUN_AIM_RIFLE_STIMULATED,
	["crouch_grenade_walk"] = ACT_WALK_CROUCH,
	["crouch_grenade_idle"] = ACT_COVER_LOW,
	["stand_slam_aim_idle"] = ACT_IDLE_PACKAGE,
	["stand_slam_aim_walk"] = ACT_WALK_PACKAGE,
	["stand_slam_aim_run"] = ACT_RUN_RPG,
	["stand_smg_aim_idle"] = ACT_RANGE_ATTACK_SMG1,
	["stand_smg_aim_walk"] = ACT_WALK_AIM_RIFLE_STIMULATED,
	["stand_fist_aim_run"] = ACT_RUN_AIM_RIFLE_STIMULATED,
	["crouch_pistol_idle"] = ACT_COVER_LOW,
	["stand_grenade_walk"] = ACT_WALK,
	["crouch_pistol_walk"] = ACT_WALK_CROUCH,
	["stand_grenade_idle"] = ACT_IDLE,
	["stand_grenade_run"] = ACT_RUN,
	["crouch_blunt_idle"] = ACT_COVER_LOW,
	["stand_pistol_walk"] = ACT_WALK,
	["crouch_blunt_walk"] = ACT_WALK_CROUCH,
	["crouch_heavy_walk"] = ACT_WALK_CROUCH_RPG,
	["stand_pistol_idle"] = ACT_IDLE_PISTOL,
	["crouch_heavy_idle"] = ACT_COVER_LOW_RPG,
	["stand_smg_aim_run"] = ACT_RUN_AIM_RIFLE_STIMULATED,
	["stand_heavy_walk"] = ACT_WALK_RPG_RELAXED,
	["stand_blunt_walk"] = ACT_WALK,
	["stand_blunt_idle"] = ACT_IDLE,
	["crouch_fist_idle"] = ACT_COVER_LOW,
	["crouch_fist_walk"] = ACT_WALK_CROUCH,
	["crouch_slam_idle"] = ACT_COVER,
	["stand_pistol_run"] = ACT_RUN,
	["stand_heavy_idle"] = ACT_IDLE_SHOTGUN_AGITATED,
	["crouch_slam_walk"] = ACT_WALK_CROUCH_RPG,
	["stand_heavy_run"] = ACT_RUN_RPG_RELAXED,
	["stand_slam_idle"] = ACT_IDLE_SUITCASE,
	["stand_fist_walk"] = ACT_WALK,
	["stand_slam_walk"] = ACT_WALK_SUITCASE,
	["stand_blunt_run"] = ACT_RUN,
	["crouch_smg_walk"] = ACT_WALK_CROUCH_RPG,
	["crouch_smg_idle"] = ACT_COVER_LOW_RPG,
	["stand_fist_idle"] = ACT_IDLE,
	["stand_slam_run"] = ACT_RUN,
	["grenade_attack"] = ACT_RANGE_ATTACK_THROW,
	["stand_smg_idle"] = ACT_IDLE_SMG1_RELAXED,
	["stand_fist_run"] = ACT_RUN,
	["stand_smg_walk"] = ACT_WALK_RIFLE_RELAXED,
	["pistol_attack"] = ACT_GESTURE_RANGE_ATTACK_SMG1,
	["stand_smg_run"] = ACT_RUN_RIFLE_STIMULATED,
	["pistol_reload"] = ACT_GESTURE_RELOAD_SMG1,
	["heavy_reload"] = ACT_GESTURE_RELOAD_SMG1,
	["heavy_attack"] = ACT_GESTURE_RANGE_ATTACK_SMG1,
	["blunt_attack"] = ACT_MELEE_ATTACK_SWING,
	["crouch_idle"] = ACT_COVER_LOW,
	["crouch_walk"] = ACT_WALK_CROUCH,
	["slam_attack"] = ACT_PICKUP_GROUND,
	["stand_idle"] = ACT_IDLE,
	["stand_walk"] = ACT_WALK,
	["smg_attack"] = ACT_GESTURE_RANGE_ATTACK_SMG1,
	["smg_reload"] = ACT_GESTURE_RELOAD_SMG1,
	["stand_run"] = ACT_RUN,
	["jump"] = ACT_GLIDE,
	["sit"] = ACT_BUSY_SIT_CHAIR
};

Clockwork.animation.stored.maleHuman = {
	["crouch_grenade_aim_idle"] = ACT_COVER_LOW,
	["crouch_grenade_aim_walk"] = ACT_WALK_CROUCH,
	["stand_grenade_aim_idle"] = ACT_IDLE,
	["crouch_pistol_aim_idle"] = ACT_RANGE_ATTACK_PISTOL_LOW,
	["stand_grenade_aim_walk"] = ACT_WALK,
	["crouch_pistol_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["crouch_heavy_aim_idle"] = ACT_RANGE_AIM_SMG1_LOW,
	["crouch_blunt_aim_idle"] = ACT_COWER,
	["stand_grenade_aim_run"] = ACT_RUN,
	["crouch_blunt_aim_walk"] = ACT_WALK_CROUCH_RIFLE,
	["crouch_heavy_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["stand_pistol_aim_walk"] = ACT_WALK_AIM_RIFLE_STIMULATED,
	["stand_pistol_aim_idle"] = ACT_RANGE_ATTACK_PISTOL,
	["crouch_fist_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["crouch_slam_aim_walk"] = ACT_WALK_CROUCH_RPG,
	["stand_pistol_aim_run"] = ACT_RUN_AIM_RIFLE_STIMULATED,
	["crouch_fist_aim_idle"] = ACT_RANGE_AIM_SMG1_LOW,
	["stand_heavy_aim_idle"] = ACT_IDLE_ANGRY_RPG,
	["stand_blunt_aim_idle"] = ACT_IDLE_MANNEDGUN,
	["crouch_slam_aim_idle"] = ACT_COVER_LOW_RPG,
	["stand_blunt_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["stand_heavy_aim_walk"] = ACT_WALK_AIM_RIFLE_STIMULATED,
	["stand_fist_aim_idle"] = ACT_RANGE_ATTACK_SMG1,
	["crouch_smg_aim_walk"] = ACT_WALK_AIM_RIFLE,
	["crouch_smg_aim_idle"] = ACT_RANGE_AIM_SMG1_LOW,
	["stand_fist_aim_walk"] = ACT_WALK_AIM_RIFLE_STIMULATED,
	["stand_blunt_aim_run"] = ACT_RUN,
	["stand_heavy_aim_run"] = ACT_RUN_AIM_RIFLE_STIMULATED,
	["crouch_grenade_walk"] = ACT_WALK_CROUCH,
	["crouch_grenade_idle"] = ACT_COVER_LOW,
	["stand_slam_aim_idle"] = ACT_IDLE_PACKAGE,
	["stand_slam_aim_walk"] = ACT_WALK_PACKAGE,
	["stand_slam_aim_run"] = ACT_RUN_RPG,
	["stand_smg_aim_idle"] = ACT_RANGE_ATTACK_SMG1,
	["stand_smg_aim_walk"] = ACT_WALK_AIM_RIFLE_STIMULATED,
	["stand_fist_aim_run"] = ACT_RUN_AIM_RIFLE_STIMULATED,
	["crouch_pistol_idle"] = ACT_COVER_LOW,
	["stand_grenade_walk"] = ACT_WALK,
	["crouch_pistol_walk"] = ACT_WALK_CROUCH,
	["stand_grenade_idle"] = ACT_IDLE,
	["stand_grenade_run"] = ACT_RUN,
	["crouch_blunt_idle"] = ACT_COVER_LOW,
	["stand_pistol_walk"] = ACT_WALK,
	["crouch_blunt_walk"] = ACT_WALK_CROUCH,
	["crouch_heavy_walk"] = ACT_WALK_CROUCH_RPG,
	["stand_pistol_idle"] = ACT_IDLE,
	["crouch_heavy_idle"] = ACT_COVER_LOW_RPG,
	["stand_smg_aim_run"] = ACT_RUN_AIM_RIFLE_STIMULATED,
	["stand_heavy_walk"] = ACT_WALK_RPG_RELAXED,
	["stand_blunt_walk"] = ACT_WALK,
	["stand_blunt_idle"] = ACT_IDLE,
	["crouch_fist_idle"] = ACT_COVER_LOW,
	["crouch_fist_walk"] = ACT_WALK_CROUCH,
	["crouch_slam_idle"] = ACT_COVER,
	["stand_pistol_run"] = ACT_RUN,
	["stand_heavy_idle"] = ACT_IDLE_SHOTGUN_AGITATED,
	["crouch_slam_walk"] = ACT_WALK_CROUCH_RPG,
	["stand_heavy_run"] = ACT_RUN_RPG_RELAXED,
	["stand_slam_idle"] = ACT_IDLE_SUITCASE,
	["stand_fist_walk"] = ACT_WALK,
	["stand_slam_walk"] = ACT_WALK_SUITCASE,
	["stand_blunt_run"] = ACT_RUN,
	["crouch_smg_walk"] = ACT_WALK_CROUCH_RPG,
	["crouch_smg_idle"] = ACT_COVER_LOW_RPG,
	["stand_fist_idle"] = ACT_IDLE,
	["stand_slam_run"] = ACT_RUN,
	["grenade_attack"] = ACT_RANGE_ATTACK_THROW,
	["stand_smg_idle"] = ACT_IDLE_RPG,
	["stand_fist_run"] = ACT_RUN,
	["stand_smg_walk"] = ACT_WALK_RPG_RELAXED,
	["pistol_attack"] = ACT_GESTURE_RANGE_ATTACK_SMG1,
	["stand_smg_run"] = ACT_RUN_RPG_RELAXED,
	["pistol_reload"] = ACT_GESTURE_RELOAD_SMG1,
	["heavy_reload"] = ACT_GESTURE_RELOAD_SMG1,
	["heavy_attack"] = ACT_GESTURE_RANGE_ATTACK_AR2,
	["blunt_attack"] = ACT_MELEE_ATTACK_SWING,
	["crouch_idle"] = ACT_COVER_LOW,
	["crouch_walk"] = ACT_WALK_CROUCH,
	["slam_attack"] = ACT_PICKUP_GROUND,
	["stand_idle"] = ACT_IDLE,
	["stand_walk"] = ACT_WALK,
	["smg_attack"] = ACT_GESTURE_RANGE_ATTACK_SMG1,
	["smg_reload"] = ACT_GESTURE_RELOAD_SMG1,
	["stand_run"] = ACT_RUN,
	["jump"] = ACT_GLIDE,
	["sit"] = ACT_BUSY_SIT_CHAIR
};

-- A function to set a model's menu sequence.
function Clockwork.animation:SetMenuSequence(model, sequence)
	self.sequences[string.lower(model)] = sequence;
end;

-- A function to get a model's menu sequence.
function Clockwork.animation:GetMenuSequence(model, bRandom)
	local lowerModel = string.lower(model);
	local sequence = self.sequences[lowerModel];
	
	if (sequence) then
		if (type(sequence) == "table") then
			if (bRandom) then
				return sequence[math.random(1, #sequence)];
			else
				return sequence;
			end;
		else
			return sequence;
		end;
	end;
end;

-- A function to add a model.
function Clockwork.animation:AddModel(class, model)
	local lowerModel = string.lower(model);
		self.models[lowerModel] = class;
	return lowerModel;
end;

-- A function to add an override.
function Clockwork.animation:AddOverride(model, key, value)
	local lowerModel = string.lower(model);
	
	if (!self.override[lowerModel]) then
		self.override[lowerModel] = {};
	end;
	
	self.override[lowerModel][key] = value;
end;

-- A function to get an animation for a model.
function Clockwork.animation:GetForModel(model, key)
	if (!model) then
		debug.Trace();
		
		return false;
	end;

	local lowerModel = string.lower(model);
	local animTable = self:GetTable(lowerModel);
	local overrideTable = self.override[lowerModel];
	local finalAnimation = animTable[key];
	
	if (overrideTable and overrideTable[key]) then
		finalAnimation = overrideTable[key];
	end;
	
	return finalAnimation;
end;

-- A function to get a model's class.
function Clockwork.animation:GetModelClass(model, alwaysReal)
	local modelClass = self.models[string.lower(model)];
	
	if (!modelClass) then
		if (!alwaysReal) then
			return "maleHuman";
		end;
	else
		return modelClass;
	end;
end;

-- A function to add a Combine Overwatch model.
function Clockwork.animation:AddCombineOverwatchModel(model)
	return self:AddModel("combineOverwatch", model);
end;

-- A function to add a Civil Protection model.
function Clockwork.animation:AddCivilProtectionModel(model)
	return self:AddModel("civilProtection", model);
end;

-- A function to add a female human model.
function Clockwork.animation:AddFemaleHumanModel(model)
	return self:AddModel("femaleHuman", model);
end;

-- A function to add a male human model.
function Clockwork.animation:AddMaleHumanModel(model)
	return self:AddModel("maleHuman", model);
end;

-- A function to get a weapon's hold type.
function Clockwork.animation:GetWeaponHoldType(player, weapon)
	local class = string.lower(weapon:GetClass());
	local weaponTable = weapons.GetStored(class);
	local holdType = "fist";
	
	if (self.holdTypes[class]) then
		holdType = self.holdTypes[class];
	elseif (weaponTable and weaponTable.HoldType) then
		if (self.convert[weaponTable.HoldType]) then
			holdType = self.convert[weaponTable.HoldType];
		else
			holdType = weaponTable.HoldType;
		end;
	else
		local act = player:Weapon_TranslateActivity(ACT_HL2MP_IDLE) or -1;
		
		if (act != -1 and self.convert[act]) then
			holdType = self.convert[act];
		end;
	end;
	
	return string.lower(holdType);
end;

-- A function to get an animation table.
function Clockwork.animation:GetTable(model)
	local lowerModel = string.lower(model);
	local class = self.models[lowerModel];
	
	if (class and self.stored[class]) then
		return self.stored[class];
	elseif (string.find(lowerModel, "female")) then
		return self.stored.femaleHuman;
	else
		return self.stored.maleHuman;
	end;
end;

Clockwork.animation:AddCombineOverwatchModel("models/combine_soldier_prisonguard.mdl");
Clockwork.animation:AddCombineOverwatchModel("models/combine_super_soldier.mdl");
Clockwork.animation:AddCombineOverwatchModel("models/combine_soldier.mdl");

Clockwork.animation:AddCivilProtectionModel("models/police.mdl");

Clockwork.animation:AddFemaleHumanModel("models/humans/group01/female_01.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group01/female_02.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group01/female_03.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group01/female_04.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group01/female_06.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group01/female_07.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group02/female_01.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group02/female_02.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group02/female_03.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group02/female_04.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group02/female_06.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group02/female_07.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group03/female_01.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group03/female_02.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group03/female_03.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group03/female_04.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group03/female_06.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group03/female_07.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group03m/female_01.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group03m/female_02.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group03m/female_03.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group03m/female_04.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group03m/female_06.mdl");
Clockwork.animation:AddFemaleHumanModel("models/humans/group03m/female_07.mdl");
  
Clockwork.animation:AddMaleHumanModel("models/humans/group01/male_01.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group01/male_02.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group01/male_03.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group01/male_04.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group01/male_05.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group01/male_06.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group01/male_07.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group01/male_08.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group01/male_09.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group02/male_01.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group02/male_02.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group02/male_03.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group02/male_04.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group02/male_05.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group02/male_06.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group02/male_07.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group02/male_08.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group02/male_09.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03/male_01.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03/male_02.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03/male_03.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03/male_04.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03/male_05.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03/male_06.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03/male_07.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03/male_08.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03/male_09.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03m/male_01.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03m/male_02.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03m/male_03.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03m/male_04.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03m/male_05.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03m/male_06.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03m/male_07.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03m/male_08.mdl");
Clockwork.animation:AddMaleHumanModel("models/humans/group03m/male_09.mdl");