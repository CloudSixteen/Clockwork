--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

--[[ 
	Never edit this file! All config editing should be done
	either through the .cfg files provided or through the
	in-game config editing systems.
--]]

Clockwork.config:Add("mysql_bans_table", "bans", nil, nil, true, true, true);
Clockwork.config:Add("mysql_characters_table", "characters", nil, nil, true, true, true);
Clockwork.config:Add("mysql_players_table", "players", nil, nil, true, true, true);
Clockwork.config:Add("mysql_username", "", nil, nil, true, true, true);
Clockwork.config:Add("mysql_password", "", nil, nil, true, true, true);
Clockwork.config:Add("mysql_database", "", nil, nil, true, true, true);
Clockwork.config:Add("mysql_host", "", nil, nil, true, true, true);
Clockwork.config:Add("mysql_port", 3306, nil, nil, true, true, true);
Clockwork.config:Add("scale_attribute_progress", 1);
Clockwork.config:Add("messages_must_see_player", false, true);
Clockwork.config:Add("bash_in_door_enabled", false);
Clockwork.config:Add("default_attribute_points", 30, true);
Clockwork.config:Add("max_trait_points", 3, true);
Clockwork.config:Add("health_regeneration_enabled", true);
Clockwork.config:Add("enable_prop_protection", true);
Clockwork.config:Add("use_local_machine_date", false, nil, nil, nil, nil, true);
Clockwork.config:Add("use_local_machine_time", false, nil, nil, nil, nil, true);
Clockwork.config:Add("use_opens_entity_menus", true, true);
Clockwork.config:Add("shoot_after_raise_time", 1);
Clockwork.config:Add("save_recognised_names", true);
Clockwork.config:Add("save_attribute_boosts", false);
Clockwork.config:Add("ragdoll_immunity_time", 0.5);
Clockwork.config:Add("additional_characters", 2, true);
Clockwork.config:Add("change_class_interval", 180);
Clockwork.config:Add("raised_weapon_system", true, true);
Clockwork.config:Add("prop_kill_protection", true);
Clockwork.config:Add("clockwork_intro_enabled", true);
Clockwork.config:Add("use_smooth_rates", true, nil, nil, nil, nil, true);
Clockwork.config:Add("use_mid_performance_rates", false, nil, nil, nil, nil, true);
Clockwork.config:Add("use_lag_free_rates", false, nil, nil, nil, nil, true);
Clockwork.config:Add("sprint_lowers_weapon", true);
Clockwork.config:Add("use_own_group_system", false, true);
Clockwork.config:Add("generator_interval", 540);
Clockwork.config:Add("enable_gravgun_punt", true);
Clockwork.config:Add("default_inv_weight", 20, true);
Clockwork.config:Add("default_inv_space", 100, true);
Clockwork.config:Add("custom_weapon_color", true);
Clockwork.config:Add("save_data_interval", 180);
Clockwork.config:Add("damage_view_punch", true);
Clockwork.config:Add("enable_heartbeat", true, true);
Clockwork.config:Add("force_language", "", true);
Clockwork.config:Add("unrecognised_name", "Somebody you do not recognise.", true);
Clockwork.config:Add("scale_fall_damage", 1);
Clockwork.config:Add("limb_damage_system", true, true);
Clockwork.config:Add("enable_vignette", true, true);
Clockwork.config:Add("use_free_aiming", true, true, true);
Clockwork.config:Add("default_cash", 100, nil, nil, nil, nil, nil, true);
Clockwork.config:Add("armor_chest_only", false);
Clockwork.config:Add("minimum_physdesc", 32, true);
Clockwork.config:Add("wood_breaks_fall", true);
Clockwork.config:Add("enable_crosshair", false, true, true);
Clockwork.config:Add("recognise_system", true, true);
Clockwork.config:Add("max_chat_length", 256, true, true);
Clockwork.config:Add("cash_enabled", true, true, nil, nil, nil, true);
Clockwork.config:Add("default_physdesc", "", true);
Clockwork.config:Add("scale_chest_dmg", 1);
Clockwork.config:Add("body_decay_time", 600);
Clockwork.config:Add("banned_message", "You are still banned for !t more !f.");
Clockwork.config:Add("wages_interval", 360);
Clockwork.config:Add("scale_prop_cost", 1);
Clockwork.config:Add("fade_dead_npcs", true, true);
Clockwork.config:Add("cash_weight", 0.001, true);
Clockwork.config:Add("cash_space", 0.001, true);
Clockwork.config:Add("scale_head_dmg", 3);
Clockwork.config:Add("block_inv_binds", true, true);
Clockwork.config:Add("target_id_delay", 0.5, true);
Clockwork.config:Add("scale_limb_dmg", 0.5);
Clockwork.config:Add("enable_headbob", true, true);
Clockwork.config:Add("command_prefix", "/", true);
Clockwork.config:Add("crouched_speed", 25);
Clockwork.config:Add("default_flags", "", true);
Clockwork.config:Add("disable_sprays", true);
Clockwork.config:Add("owner_steamid", "STEAM_0:0:0000000", nil, nil, true, true, true);
Clockwork.config:Add("hint_interval", 30);
Clockwork.config:Add("ooc_interval", 120);
Clockwork.config:Add("minute_time", 60, true);
Clockwork.config:Add("voice_enabled", true);
Clockwork.config:Add("unlock_time", 3);
Clockwork.config:Add("local_voice", true, true);
Clockwork.config:Add("talk_radius", 384, true);
Clockwork.config:Add("wages_name", "Wages", true);
Clockwork.config:Add("give_hands", true);
Clockwork.config:Add("give_keys", true);
Clockwork.config:Add("jump_power", 160);
Clockwork.config:Add("spawn_time", 60);
Clockwork.config:Add("walk_speed", 100);
Clockwork.config:Add("run_speed", 225);
Clockwork.config:Add("door_cost", 10, true);
Clockwork.config:Add("lock_time", 2);
Clockwork.config:Add("max_doors", 5);
Clockwork.config:Add("enable_space_system", false, true);
Clockwork.config:Add("draw_intro_bars", true, true);
Clockwork.config:Add("enable_jogging", false, true, true);
Clockwork.config:Add("enable_looc_icons", true, true, true);
Clockwork.config:Add("show_business", true, true);
Clockwork.config:Add("chat_multiplier", true, true, true);
Clockwork.config:Add("steam_api_key", "");
Clockwork.config:Add("enable_map_props_physgrab", false);
Clockwork.config:Add("translate_api_key", "");
Clockwork.config:Add("entity_handle_time", 0.1);
Clockwork.config:Add("player_should_smooth_sprint", true);
Clockwork.config:Add("quick_raise_enabled", true);
Clockwork.config:Add("modify_themes", false, true);
Clockwork.config:Add("default_theme", "Schema", true);
Clockwork.config:Add("enable_disease", false);
Clockwork.config:Add("disease_interval", 60);

Clockwork.config:Add("enable_ironsights", true, true);
Clockwork.config:Add("ironsights_spread", 0.5, true);
Clockwork.config:Add("ironsights_slow", 0.5, true);

Clockwork.config:Add("max_char_name", 32, true);

Clockwork.config:Add("description_crafting", "Combine various items to make new items.", true);
Clockwork.config:Add("crafting_menu_enabled", false, true);
