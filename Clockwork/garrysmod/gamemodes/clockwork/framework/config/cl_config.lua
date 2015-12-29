--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;

Clockwork.config:AddToSystem("Attribute Progression Scale", "scale_attribute_progress", "The amount to scale attribute progress by.");
Clockwork.config:AddToSystem("Messages Must See Player", "messages_must_see_player", "Whether or not you must see a player to hear some in-character messages.");
Clockwork.config:AddToSystem("Starting Attribute Points", "default_attribute_points", "The default amount of attribute points that a player has.");
Clockwork.config:AddToSystem("Clockwork Introduction Enabled", "clockwork_intro_enabled", "Enable the Clockwork introduction for new players.");
Clockwork.config:AddToSystem("Health Regeneration Enabled", "health_regeneration_enabled", "Whether or not health regeneration is enabled.");
Clockwork.config:AddToSystem("Prop Protection Enabled", "enable_prop_protection", "Whether or not to enable prop protection.");
Clockwork.config:AddToSystem("Use Local Machine Date", "use_local_machine_date", "Whether or not to use the local machine's date when the map is loaded.");
Clockwork.config:AddToSystem("Use Local Machine Time", "use_local_machine_time", "Whether or not to use the local machine's time when the map is loaded.");
Clockwork.config:AddToSystem("Use Key Opens Entity Menus", "use_opens_entity_menus", "Whether or not 'use' opens the context menus.");
Clockwork.config:AddToSystem("Shoot After Raise Delay", "shoot_after_raise_time", "The time that it takes for players to be able to shoot after raising their weapon (seconds).\nSet to 0 for no time.");
Clockwork.config:AddToSystem("Use Clockwork's Admin System", "use_own_group_system", "Whether or not you use a different group or admin system to Clockwork.");
Clockwork.config:AddToSystem("Saved Recognised Names", "save_recognised_names", "Whether or not recognised names should be saved.");
Clockwork.config:AddToSystem("Save Attribute Boosts", "save_attribute_boosts", "Whether or not attribute boosts are saved.");
Clockwork.config:AddToSystem("Ragdoll Damage Immunity Time", "ragdoll_immunity_time", "The time that a player's ragdoll is immune from damage (seconds).");
Clockwork.config:AddToSystem("Additional Character Count", "additional_characters", "The additional amount of characters that each player can have.");
Clockwork.config:AddToSystem("Class Changing Interval", "change_class_interval", "The time that a player has to wait to change class again (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Sprinting Lowers Weapon", "sprint_lowers_weapon", "Whether or not sprinting lowers a player's weapon.");
Clockwork.config:AddToSystem("Weapon Raising System Enabled", "raised_weapon_system", "Whether or not the raised weapon system is enabled.");
Clockwork.config:AddToSystem("Prop Kill Protection Enabled", "prop_kill_protection", "Whether or not prop kill protection is enabled.");
Clockwork.config:AddToSystem("Use Smooth Server Rates", "use_smooth_rates", "Whether or not to use Clockwork smooth rates.");
Clockwork.config:AddToSystem("Use Medium Performance Server Rates", "use_optimised_rates", "Whether or not to use Clockwork mid performance rates (bars will be less smooth).");
Clockwork.config:AddToSystem("Use Lag Free Server Rates", "use_lag_free_rates", "Whether or not to use Clockwork max performance rates (kills all lags, screws up bars).");
Clockwork.config:AddToSystem("Generator Interval", "generator_interval", "The time that it takes for generator cash to be distrubuted (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Gravity Gun Punt Enabled", "enable_gravgun_punt", "Whether or not to enable entities to be punted with the gravity gun.");
Clockwork.config:AddToSystem("Default Inventory Weight", "default_inv_weight", "The default inventory weight (kilograms).");
Clockwork.config:AddToSystem("Default Inventory Space", "default_inv_space", "The default inventory space (litres).");
Clockwork.config:AddToSystem("Data Save Interval", "save_data_interval", "The time that it takes for data to be saved (seconds).", 0, 7200);
Clockwork.config:AddToSystem("View Punch On Damage", "damage_view_punch", "Whether or not a player's view gets punched when they take damage.");
Clockwork.config:AddToSystem("Unrecognised Name", "unrecognised_name", "The name that is given to unrecognised players.");
Clockwork.config:AddToSystem("Limb Damage System Enabled", "limb_damage_system", "Whether or not limb damage is enabled.");
Clockwork.config:AddToSystem("Fall Damage Scale", "scale_fall_damage", "The amount to scale fall damage by.");
Clockwork.config:AddToSystem("Starting Currency", "default_cash", "The default amount of cash that each player starts with.", 0, 10000);
Clockwork.config:AddToSystem("Armor Affects Chest Only", "armor_chest_only", "Whether or not armor only affects the chest.");
Clockwork.config:AddToSystem("Minimum Physical Description Length", "minimum_physdesc", "The minimum amount of characters a player must have in their physical description.", 0, 128);
Clockwork.config:AddToSystem("Wood Breaks Fall", "wood_breaks_fall", "Whether or not wooden physics entities break a player's fall.");
Clockwork.config:AddToSystem("Vignette Enabled", "enable_vignette", "Whether or not the vignette is enabled.");
Clockwork.config:AddToSystem("Heartbeat Sounds Enabled", "enable_heartbeat", "Whether or not the heartbeat is enabled.");
Clockwork.config:AddToSystem("Crosshair Enabled", "enable_crosshair", "Whether or not the crosshair is enabled.");
Clockwork.config:AddToSystem("Free Aiming Enabled", "use_free_aiming", "Whether or not free aiming is enabled.");
Clockwork.config:AddToSystem("Recognise System Enabled", "recognise_system", "Whether or not the recognise system is enabled.");
Clockwork.config:AddToSystem("Currency Enabled", "cash_enabled", "Whether or not cash is enabled.");
Clockwork.config:AddToSystem("Default Physical Description", "default_physdesc", "The physical description that each player begins with.");
Clockwork.config:AddToSystem("Chest Damage Scale", "scale_chest_dmg", "The amount to scale chest damage by.");
Clockwork.config:AddToSystem("Corpse Decay Time", "body_decay_time", "The time that it takes for a player's ragdoll to decay (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Banned Disconnect Message", "banned_message", "The message that a player receives when trying to join while banned.\n!t for the time left, !f for the time format.");
Clockwork.config:AddToSystem("Wages Interval", "wages_interval", "The time that it takes for wages cash to be distrubuted (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Prop Cost Scale", "scale_prop_cost", "How to much to scale prop cost by.\nSet to 0 to to make props free.");
Clockwork.config:AddToSystem("Fade NPC Corpses", "fade_dead_npcs", "Whether or not to fade dead NPCs.");
Clockwork.config:AddToSystem("Cash Weight", "cash_weight", "The weight of cash (kilograms).", 0, 100, 3);
Clockwork.config:AddToSystem("Cash Space", "cash_space", "The amount of space cash takes (litres).", 0, 100, 3);
Clockwork.config:AddToSystem("Head Damage Scale", "scale_head_dmg", "The amount to scale head damage by.");
Clockwork.config:AddToSystem("Block Inventory Binds", "block_inv_binds", "Whether or not inventory binds should be blocked for players.");
Clockwork.config:AddToSystem("Limb Damage Scale", "scale_limb_dmg", "The amount to scale limb damage by.");
Clockwork.config:AddToSystem("Target ID Delay", "target_id_delay", "The delay before the Target ID is displayed when looking at an entity.");
Clockwork.config:AddToSystem("Headbob Enabled", "enable_headbob", "Whether or not to enable headbob.");
Clockwork.config:AddToSystem("Chat Command Prefix", "command_prefix", "The prefix that is used for chat commands.");
Clockwork.config:AddToSystem("Crouch Walk Speed", "crouched_speed", "The speed that characters walk at when crouched.", 0, 1024);
Clockwork.config:AddToSystem("Maximum Chat Length", "max_chat_length", "The maximum amount of characters that can be typed in chat.", 0, 1024);
Clockwork.config:AddToSystem("Starting Flags", "default_flags", "The flags that each player begins with.");
Clockwork.config:AddToSystem("Player Spray Enabled", "disable_sprays", "Whether players can spray their tags.");
Clockwork.config:AddToSystem("Hint Interval", "hint_interval", "The time that a hint is displayed to each player (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Out-Of-Character Chat Interval", "ooc_interval", "The time that a player has to wait to speak out-of-character again (seconds).\nSet to 0 for never.", 0, 7200);
Clockwork.config:AddToSystem("Minute Time", "minute_time", "The time that it takes for a minute to pass (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Door Unlock Interval", "unlock_time", "The time that a player has to wait to unlock a door (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Voice Chat Enabled.", "voice_enabled", "Whether or not voice chat is enabled.");
Clockwork.config:AddToSystem("Local Voice Chat", "local_voice", "Whether or not to enable local voice.");
Clockwork.config:AddToSystem("Talk Radius", "talk_radius", "The radius of each player that other characters have to be in to hear them talk (units).", 0, 4096);
Clockwork.config:AddToSystem("Give Hands", "give_hands", "Whether or not to give hands to each player.");
Clockwork.config:AddToSystem("Custom Weapon Color", "custom_weapon_color", "Whether or not to enable custom weapon colors.");
Clockwork.config:AddToSystem("Give Keys", "give_keys", "Whether or not to give keys to each player.");
Clockwork.config:AddToSystem("Wages Name", "wages_name", "The name that is given to wages.");
Clockwork.config:AddToSystem("Jump Power", "jump_power", "The power that characters jump at.", 0, 1024);
Clockwork.config:AddToSystem("Respawn Delay", "spawn_time", "The time that a player has to wait before they can spawn again (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Maximum Walk Speed", "walk_speed", "The speed that characters walk at.", 0, 1024);
Clockwork.config:AddToSystem("Maximum Run Speed", "run_speed", "The speed that characters run at.", 0, 1024);
Clockwork.config:AddToSystem("Door Price", "door_cost", "The amount of cash that each door costs.");
Clockwork.config:AddToSystem("Door Lock Interval", "lock_time", "The time that a player has to wait to lock a door (seconds).", 0, 7200);
Clockwork.config:AddToSystem("Maximum Ownable Doors", "max_doors", "The maximum amount of doors a player can own.");
Clockwork.config:AddToSystem("Enable Space System", "enable_space_system", "Whether or not to use the space system that affects inventories.");
Clockwork.config:AddToSystem("Draw Intro Bars", "draw_intro_bars", "Whether or not to draw cinematic intro black bars on top and bottom of the screen.");
Clockwork.config:AddToSystem("Enable Jogging", "enable_jogging", "Whether or not to enable jogging.");
Clockwork.config:AddToSystem("Enable LOOC Icons", "enable_looc_icons", "Whether or not to enable LOOC chat icons.");
Clockwork.config:AddToSystem("Show Business Menu", "show_business", "Whether or not to show the business menu.");
Clockwork.config:AddToSystem("Enable Chat Multiplier", "chat_multiplier", "Whether or not to change text size based on types of chat.");
Clockwork.config:AddToSystem("Steam API Key", "steam_api_key", "Some non-essential features may require the usage of the Steam API.\nhttp://steamcommunity.com/dev/apikey");
Clockwork.config:AddToSystem("Enable Map Props Physgrab", "enable_map_props_physgrab", "Whether or not players will be able to grab map props and doors with physguns.");
<<<<<<< HEAD
Clockwork.config:AddToSystem("Entity Use Cooldown", "entity_handle_time", "The amount of time between entity uses a player has to wait.", 0, 1, 3);

Clockwork.config:AddToSystem("Crafting Description", "crafting_description", "The amount of time between entity uses a player has to wait.");
Clockwork.config:AddToSystem("Crafting Enabled", "crafting_menu_enabled", "Whether or not the crafting menu is enabled.");
Clockwork.config:AddToSystem("Crafting Name", "crafting_name", "The amount of time between entity uses a player has to wait.");
=======
Clockwork.config:AddToSystem("Entity Use Cooldown", "entity_handle_time", "The amount of time between entity uses a player has to wait.", 0, 1, 3);
>>>>>>> origin/master
