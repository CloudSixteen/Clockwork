--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

Clockwork.config:AddToSystem("Attribute progression scale", "scale_attribute_progress", "The amount to scale attribute progress by.");
Clockwork.config:AddToSystem("Messages must see player", "messages_must_see_player", "Whether or not you must see a player to hear some in-character messages.");
Clockwork.config:AddToSystem("Starting attribute points", "default_attribute_points", "The default amount of attribute points that a player has.");
Clockwork.config:AddToSystem("Clockwork introduction enabled", "clockwork_intro_enabled", "Enable the Clockwork introduction for new players.");
Clockwork.config:AddToSystem("Health regeneration enabled", "health_regeneration_enabled", "Whether or not health regeneration is enabled.");
Clockwork.config:AddToSystem("Prop protection enabled", "enable_prop_protection", "Whether or not to enable prop protection.");
Clockwork.config:AddToSystem("Use local machine date", "use_local_machine_date", "Whether or not to use the local machine's date when the map is loaded.");
Clockwork.config:AddToSystem("Use local machine time", "use_local_machine_time", "Whether or not to use the local machine's time when the map is loaded.");
Clockwork.config:AddToSystem("Use key opens entity menus", "use_opens_entity_menus", "Whether or not 'use' opens the context menus.");
Clockwork.config:AddToSystem("Shoot after raise delay", "shoot_after_raise_time", "The time that it takes for players to be able to shoot after raising their weapon (seconds).\nSet to 0 for no time.");
Clockwork.config:AddToSystem("Use Clockwork's admin system", "use_own_group_system", "Whether or not you use a different group or admin system to Clockwork.");
Clockwork.config:AddToSystem("Saved recognised names", "save_recognised_names", "Whether or not recognised names should be saved.");
Clockwork.config:AddToSystem("Save attribute boosts", "save_attribute_boosts", "Whether or not attribute boosts are saved.");
Clockwork.config:AddToSystem("Ragdoll damage immunity time", "ragdoll_immunity_time", "The time that a player's ragdoll is immune from damage (seconds).");
Clockwork.config:AddToSystem("Additional character count", "additional_characters", "The additional amount of characters that each player can have.");
Clockwork.config:AddToSystem("Class changing interval", "change_class_interval", "The time that a player has to wait to change class again (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Sprinting lowers weapon", "sprint_lowers_weapon", "Whether or not sprinting lowers a player's weapon.");
Clockwork.config:AddToSystem("Weapon raising system enabled", "raised_weapon_system", "Whether or not the raised weapon system is enabled.");
Clockwork.config:AddToSystem("Prop kill protection enabled", "prop_kill_protection", "Whether or not prop kill protection is enabled.");
Clockwork.config:AddToSystem("Use smooth server rates", "use_smooth_rates", "Whether or not to use Clockwork smooth rates.");
Clockwork.config:AddToSystem("Use medium performance server rates", "use_optimised_rates", "Whether or not to use Clockwork mid performance rates (bars will be less smooth).");
Clockwork.config:AddToSystem("Use lag free server rates", "use_lag_free_rates", "Whether or not to use Clockwork max performance rates (kills all lags, screws up bars).");
Clockwork.config:AddToSystem("Generator interval", "generator_interval", "The time that it takes for generator cash to be distrubuted (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Gravity gun punt enabled", "enable_gravgun_punt", "Whether or not to enable entities to be punted with the gravity gun.");
Clockwork.config:AddToSystem("Default inventory weight", "default_inv_weight", "The default inventory weight (kilograms).");
Clockwork.config:AddToSystem("Default inventory space", "default_inv_space", "The default inventory space (litres).");
Clockwork.config:AddToSystem("Data save interval", "save_data_interval", "The time that it takes for data to be saved (seconds).", 0, 7200);
Clockwork.config:AddToSystem("View punch on damage", "damage_view_punch", "Whether or not a player's view gets punched when they take damage.");
Clockwork.config:AddToSystem("Unrecognised name", "unrecognised_name", "The name that is given to unrecognised players.");
Clockwork.config:AddToSystem("Limb damage system enabled", "limb_damage_system", "Whether or not limb damage is enabled.");
Clockwork.config:AddToSystem("Fall damage scale", "scale_fall_damage", "The amount to scale fall damage by.");
Clockwork.config:AddToSystem("Starting currency", "default_cash", "The default amount of cash that each player starts with.", 0, 10000);
Clockwork.config:AddToSystem("Armor affects chest only", "armor_chest_only", "Whether or not armor only affects the chest.");
Clockwork.config:AddToSystem("Minimum physical description length", "minimum_physdesc", "The minimum amount of characters a player must have in their physical description.", 0, 128);
Clockwork.config:AddToSystem("Wood breaks fall", "wood_breaks_fall", "Whether or not wooden physics entities break a player's fall.");
Clockwork.config:AddToSystem("Vignette enabled", "enable_vignette", "Whether or not the vignette is enabled.");
Clockwork.config:AddToSystem("Heartbeat sounds enabled", "enable_heartbeat", "Whether or not the heartbeat is enabled.");
Clockwork.config:AddToSystem("Crosshair enabled", "enable_crosshair", "Whether or not the crosshair is enabled.");
Clockwork.config:AddToSystem("Free aiming enabled", "use_free_aiming", "Whether or not free aiming is enabled.");
Clockwork.config:AddToSystem("Recognise system enabled", "recognise_system", "Whether or not the recognise system is enabled.");
Clockwork.config:AddToSystem("Currency enabled", "cash_enabled", "Whether or not cash is enabled.");
Clockwork.config:AddToSystem("Default physical description", "default_physdesc", "The physical description that each player begins with.");
Clockwork.config:AddToSystem("Chest damage scale", "scale_chest_dmg", "The amount to scale chest damage by.");
Clockwork.config:AddToSystem("Corpse decay time", "body_decay_time", "The time that it takes for a player's ragdoll to decay (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Banned disconnect message", "banned_message", "The message that a player receives when trying to join while banned.\n!t for the time left, !f for the time format.");
Clockwork.config:AddToSystem("Wages interval", "wages_interval", "The time that it takes for wages cash to be distrubuted (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Prop cost scale", "scale_prop_cost", "How to much to scale prop cost by.\nSet to 0 to to make props free.");
Clockwork.config:AddToSystem("Fade NPC corpses", "fade_dead_npcs", "Whether or not to fade dead NPCs.");
Clockwork.config:AddToSystem("Cash weight", "cash_weight", "The weight of cash (kilograms).", 0, 100, 3);
Clockwork.config:AddToSystem("Cash space", "cash_space", "The amount of space cash takes (litres).", 0, 100, 3);
Clockwork.config:AddToSystem("Head damage scale", "scale_head_dmg", "The amount to scale head damage by.");
Clockwork.config:AddToSystem("Block inventory binds", "block_inv_binds", "Whether or not inventory binds should be blocked for players.");
Clockwork.config:AddToSystem("Limb damage scale", "scale_limb_dmg", "The amount to scale limb damage by.");
Clockwork.config:AddToSystem("Headbob enabled", "enable_headbob", "Whether or not to enable headbob.");
Clockwork.config:AddToSystem("Chat command prefix", "command_prefix", "The prefix that is used for chat commands.");
Clockwork.config:AddToSystem("Crouch walk speed", "crouched_speed", "The speed that characters walk at when crouched.", 0, 1024);
Clockwork.config:AddToSystem("Maximum chat length", "max_chat_length", "The maximum amount of characters that can be typed in chat.", 0, 1024);
Clockwork.config:AddToSystem("Starting flags", "default_flags", "The flags that each player begins with.");
Clockwork.config:AddToSystem("Player spray enabled", "disable_sprays", "Whether players can spray their tags.");
Clockwork.config:AddToSystem("Hint interval", "hint_interval", "The time that a hint is displayed to each player (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Out-of-character chat interval", "ooc_interval", "The time that a player has to wait to speak out-of-character again (seconds).\nSet to 0 for never.", 0, 7200);
Clockwork.config:AddToSystem("Minute time", "minute_time", "The time that it takes for a minute to pass (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Door unlock interval", "unlock_time", "The time that a player has to wait to unlock a door (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Voice chat enabled.", "voice_enabled", "Whether or not voice chat is enabled.");
Clockwork.config:AddToSystem("Local voice chat", "local_voice", "Whether or not to enable local voice.");
Clockwork.config:AddToSystem("Talk radius", "talk_radius", "The radius of each player that other characters have to be in to hear them talk (units).", 0, 4096);
Clockwork.config:AddToSystem("Give hands", "give_hands", "Whether or not to give hands to each player.");
Clockwork.config:AddToSystem("Custom weapon color", "custom_weapon_color", "Whether or not to enable custom weapon colors.");
Clockwork.config:AddToSystem("Give keys", "give_keys", "Whether or not to give keys to each player.");
Clockwork.config:AddToSystem("Wages name", "wages_name", "The name that is given to wages.");
Clockwork.config:AddToSystem("Jump power", "jump_power", "The power that characters jump at.", 0, 1024);
Clockwork.config:AddToSystem("Respawn delay", "spawn_time", "The time that a player has to wait before they can spawn again (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Maximum walk speed", "walk_speed", "The speed that characters walk at.", 0, 1024);
Clockwork.config:AddToSystem("Maximum run speed", "run_speed", "The speed that characters run at.", 0, 1024);
Clockwork.config:AddToSystem("Door price", "door_cost", "The amount of cash that each door costs.");
Clockwork.config:AddToSystem("Door lock interval", "lock_time", "The time that a player has to wait to lock a door (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Maximum ownable doors", "max_doors", "The maximum amount of doors a player can own.");
Clockwork.config:AddToSystem("Enable space system", "enable_space_system", "Whether or not to use the space system that affects inventories.");
Clockwork.config:AddToSystem("Draw intro bars", "draw_intro_bars", "Whether or not to draw cinematic intro black bars on top and bottom of the screen.");