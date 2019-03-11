Changelog
---------
The following changes have been made for each official Clockwork build.

0.99
------

* Updated CloudAuthX
* Added German language support
* Various language string updates
* Various localisation fixes
* Changed more systems to use localisation
* Fixed PostCommandUsed not being called
* Added an example schema
* Added blueprint.CanCraft
* Added value restoration for the PLUGIN global
* Added schema version rounding
* Added automatic gender selection for single gendered factions
* Reworked the voice command system
* Added the ShouldDeleteCharacter hook, to separate character deletion from character table adjustment
* Fixed crafting
* Fixed static entities being physgunnable physable by anyone after a restart
* Fixed decaying entities not rendering alpha changes
* Fixed clientside decaying entities not rendering alpha changes
* Changed player.CommunityID to alias player.SteamID64
* Updated directory formatting
* Fixed ammo loss
* Fixed legs not drawing
* Fixed player.GiveItems
* Fixed Clockwork.crafting.CheckTakeItems taking the same unique items multiple times
* Fixed an issue of whitelist losses
* Fixed Clockwork.kernel.IsShuttingDown
* Fixed CLASS_TABLE.__tostring
* Fixed rank demotion
* Fixed file reading issue relating to UTF8
* Fixed Clockwork.kernel.ValidateTableKeys
* Fixed the networking of player names upon name setting
* Updated the reference to the content pack
* Corrected stored chat text width, meaning text separation between timestamps and text will scale according to the chat size multiplier

0.98
-------

* Updated a lot of systems to support localisation
* Added French language support
* Added Korean language support
* Added Russian language support
* Added Spanish language support
* Added Swedish language support
* Added Clockwork.lang:ReplaceSubs(language, input, subs)
* Added Clockwork.kernel:SplitKeepDelim(input, delim)
* Added the ability to disable the quiz
* Added traits
* Added OnConsoleRun method for commands
* Added OnConsoleRun method to PlySetGroup (example)
* Added a character name limit
* Added exception handling for rankpromote and rankdemote
* Added Tools folder to repo with HookDoccer and ItemTranslator (for developers)
* Updated CloudAuthX
* Updated directory formatting
* Updated the system menu's functionality and styling, and added icons
* Updated character creation's attributes screen
* Updated Codebase
* Moved the stamina plugin to HL2RP
* Theme updates
* Fixed a faction error
* Fixed an error with the typing display
* Fixed various GUI issues
* Fixed PermaKill mode
* Fixed config setting
* Fixed an issue with progression past the character screen
* Fixed the itc command
* Fixed the plyrespawntp command
* Removed the cwc command
* Removed sh_fixes.lua
* Removed support for the anonymous speech character, "?"

0.97
------
* Fixed a cl_character bug with factions
* Removed inclusion of sh_fixes.lua
* Increased localisation support

0.96.6
-------

* Various localisation fixes
* Font updates
* Fixed file.Exists faction materials issue
* Crafting and blueprint fixes

0.96.3
-------

* Fixed items being removed too soon on creation.
* Fixed TOOL binds not working (such as camera key, etc.)
* Removed deploy animation from the hands weapon.
* Fixed odd credits in the keys weapon.
* Moved experimental Backsword and themetest plugins to development/ folder.
* Made ironsights library name more consistent with others.

0.96.2
-------

* Fixed doors not displaying 3D2D info properly.
* Removed theme library debug prints when switching a theme.
* Made the GetDoorEntities function serverside only.
* Gave the PreDrawWeaponList hook the ability to stop drawing the weapon list if it returns true.
* Fixed items removing on think (I.E. removing instantly when dropped).
* Fixed IsMapEntity using entIndex, changed to using the entity itself to check for.
* Fixed fists not playing the knocking noise when the secondary fire is used on a door.
	* *Contributed by NightAngel.*

0.96.1
-------

* Optimized cl_kernel, sv_kernel and sh_kernel with localizations and added library/class functions.
	* *Contributed by NightAngel.*
* Optimized the doorcommands plugin saving doors and door states, should no longer lag the server when saving.
	* *Contributed by NightAngel.*
* Added GetDoorEntities function in the entity library, which returns all doors stored on startup for optimization.
	* *Contributed by NightAngel.*
* Themes can now be changed in game by clients through the Clockwork settings menu.
	* *Contributed by NightAngel.*
* Added themes folder to plugin extras, so you can now have a '/themes/' folder in plugins to store added themes.
	* *Contributed by NightAngel.*
* Added default Clockwork theme, which all themes will inherit from.
	* *Contributed by NightAngel.*
* Added configs for stopping players from changing their themes, as well as changing the default theme that players start with.
	* *Contributed by NightAngel.*
* Added CanHandsPickupEntity hook that is called when a player attempts to pickup an entity with the hands secondary fire.
	* *Contributed by NightAngel.*
* Possible fix to gray/loading screen being stuck on joining.
	* *Contributed by NightAngel.*
* Item entities will now remove if they are out of the map, or if the item they represent isn't loaded on the server.
	* *Contributed by NightAngel.*
* Added config to disable/enable quick raising your weapon.
	* *Contributed by NightAngel.*
* Added Lerp wrapper library for easily adding and using lerp functions that are included with GMod for linear interpolation.
	* *Contributed by NightAngel.*
* Changed quick raising to be activated by pressing the B key, left and right mouse will no longer trigger it.
	* *Contributed by NightAngel.*
* Changed the CharSetDesc command to display the target's physdesc and let you edit it, similar to changing your own physdesc.
	* *Contributed by NightAngel.*
* Adjusted some fonts in multiple menus.
	* *Contributed by NightAngel.*
* Fixed command library FindByAlias not being caps insensitive.
	* *Contributed by NightAngel.*
* Fixed multiple BackSword 2 issues, including the holdtypes issue, and added several scope textures.
	* *Contributed by Zigalishous.*
* Added and changed multiple admin related commands including commands for managing teleports, chat, and respawns.
	* *Contributed by Tyler.*


0.95.3
-------

* Consolidated cl_player, sv_player and sh_player into sh_player and optimized it by localizing Clockwork libraries.
	* *Contributed by NightAngel.*
* Fixed some player model animations to look better and added 'heavy' animations for physgun, etc.
	* *Contributed by NightAngel.*
* Made ironsights file check for the player library and include sh_player if it isn't included when ironsights are included, also fixed a small typo with the movement slow using spread config instead of slow config.
	* *Contributed by NightAngel.*
* Localized Clockwork libraries in sv_kernel for micro optimizations and fixed some mistakes that would slow down PlayerThink hooks.
	* *Contributed by NightAngel.*

0.95.2
-------

* Added BackSword 2, a reworked SWEP base made for Clockwork that includes ironsights variables.
	* *Contributed by Zigalishous.*
* Added ironsights that can be used with any weapon that uses the ironsight variable format that M9K, BS2 and RealCS use.
Just press middle mouse while your weapon is raised to use the ironsights, it will slow movement and reduce spread.
	* *Contributed by NightAngel.*
* Added cwToggleIronSights concommand so that players can bind a key to this to toggle their ironsights instead of middle mouse.
	* *Contributed by NightAngel.*
* Fixed displaytyping text not drawing over translucent surfaces after recent changes.
	* *Contributed by NightAngel.*
* Small optimizations to some functions in cl_kernel.
	* *Contributed by NightAngel.*
* Added viewmodel hands info to Combine animations tables to make any added models use the Combine viewmodel hands.
	* *Contributed by NightAngel.*
* Added rudimentary zombie animation table for Half-Life 2 classic zombie animations.
	* *Contributed by NightAngel.*
* Added player model animations so that player models will now animate properly without tposing.
	* *Contributed by NightAngel.*
* Added multiple functions to register certain models to use certain viewmodel hand info (CSS, HL2, Combine, Citizen, etc).
	* *Contributed by NightAngel.*
* Made male_01/03 as well as female_03 use the black skin for citizen hands.
	* *Contributed by NightAngel.*
* Made group03/03m models use the refugee hands model with the gloves bodygroup on.
	* *Contributed by NightAngel.*
* Made HL2 zombie models use zombie skin for refugee arms model.
	* *Contributed by NightAngel.*
* Removed redundant male/female human model animation registering (They get set to these automatically anyways).
	* *Contributed by NightAngel.*
* Small edit to codebase to make it write its documentation findings to seperate files to avoid this huge text file containing all the documentation.
	* *Contributed by NightAngel.*
* Added 'CanDrawCrosshair' plugin hook that gets called to determine if a player's crosshair should be drawn, ironsights will force crosshair to draw if they are used in third person.
	* *Contributed by NightAngel.*
* Added two configs to modify how much ironsights will reduce the spread, as well as how much they will reduce walk speed of the player.
	* *Contributed by NightAngel.*

0.95.1
-------

* Added command aliases, which can be used to shorten longer commands while still keeping the original commands present.
	* *Contributed by Mr. Meow.*
* Fixed chatbox to display commands properly after one letter is typed.
	* *Contributed by NightAngel.*
* Added SpawnPointESP which includes info_player_start point entities, made minor optimization to staticESP.
	* *Contributed by NightAngel.*
* Fixed errors occuring with manage_plugins system menu.
	* *Contributed by NightAngel.*
* Fixed DisplayTyping plugin not drawing properly due to a minor mistake and optimized it further.
	* *Contributed by NightAngel.*

0.95
-------

* Optimized cl_kernel by localizing global tables.
	* *Contributed by NightAngel.*
* Added config to enable/disable smooth sprint.
	* *Contributed by NightAngel.*
* Fixed typo in crafting menu that caused tab menu to not open.
	* *Contributed by NightAngel.*
* Added check that stops some errors with the storage from occurring.
	* *Contributed by NightAngel.*
* Removed changelog from directory menu.
	* *Contributed by NightAngel.*
* Arranged default chatbox classes into an array, and added GetClasses(boolean Default) function to Clockwork.chatBox.
	* *Contributed by NightAngel.*
* Modified similar Clockwork.player:CanSee[X] functions to run off of CanSeeEntity, which in turn runs off of CanSeePosition.
	* *Contributed by NightAngel.*
* Localized hidden table for Clockwork.command, and added Clockwork.command:GetAll().
	* *Contributed by NightAngel.*
* Localized global plugin library arrays, and changed to no longer force lowercase directories for including plugins.
	* *Contributed by NightAngel.*
* Fixed typo with player models to bypass Clockwork animations (temp work around).
	* *Contributed by NightAngel.*
* Changed joining and leaving logs to include IP addresses as well as SteamIDs.
	* *Contributed by NightAngel.*
* Fixed look recognise and organized recognise options.
	* *Contributed by NightAngel.*
* Added a hook that is called after a player's usergroup is set 'OnPlayerUserGroupSet'.
	* *Contributed by NightAngel.*
* Fixed displaytyping to display proper type of talking the player is doing, also fixed the display not working on ragdolls or when a head bone isn't found.
	* *Contributed by NightAngel.*
* Fixed problem with editing salesmen that were made before the update to salesmen.
	* *Contributed by NightAngel.*
* Optimized StaticESP to sync only on spawn as admin, usergroup being set to admin, or when an entity is staticed and you're an admin.
	* *Contributed by NightAngel.*
* Changed StaticESP to get info from an entity clientside, instead of networking pre-gathered info serverside (now syncs entity IDs instead).
	* *Contributed by NightAngel.*
* Added SaveEntity() function to StaticEnts plugin and made all saving commands/functions use it, adds entity to staticEnt table to be saved.
	* *Contributed by NightAngel.*
* Added command 'StaticModeToggle', when used it will toggle StaticMode, this will automatically save all whitelisted entities/props/ragdolls when ANY player spawns them.
	* *Contributed by NightAngel.*
* Added 'StaticWhitelist[X]' commands for management of the static whitelist ingame (which entities can be staticed).
	* *Contributed by NightAngel.*
* Moved 'CanEntityStatic' to serverside, since it is only called serverside anyways and requires serverside functions now.
	* *Contributed by NightAngel.*
* Updated hands and keys SWEPs to new hands model and changed hands SWEP to play viewmodel animations.
	* *Contributed by Zigalishous.*

0.94.8
-------

* Clarified some documentation in the entity library.
	* *Contributed by RJ.*
* Alphabeticalized inventory library.
	* *Contributed by RJ.*
* Added methods to count the amount of a specified item in an inventory.
	* *Contributed by RJ.*
* Added work in progress crafting library.
	* *Contributed by RJ.*
* Optimized some functions in sv_kernel and removed pointless variables that were slowing things down.
	* *Contributed by NightAngel.*
* Added more comments to sv_kernel to better explain reasons for doing certain things.
	* *Contributed by NightAngel.*
* Added PlayerCanQuickRaise plugin hook that calls when a player attempts to raise their weapon by pressing left or right click.
	* *Contributed by NightAngel.*
* Hands SWEP is now impossible to quick raise, due to quick raising conflicting with certain functions of the SWEP.
	* *Contributed by NightAngel.*

0.94.75
-------

* Added the ability to raise your weapon by pressing left or right click if it is lowered.
	* *Contributed by NightAngel.*

0.94.74
-------

* Fixed a fatal error with schema prints erroring out clientside.
	* *Contributed by NightAngel.*

0.94.73
-------

* Changed the ESP system to be a little less confusing with its tables, uses string keys instead of numbered keys now.
	* *Contributed by NightAngel.*

0.94.72
-------

* Fixed issues with command hints not showing due to recent GMOD update.
	* *Contributed by NightAngel.*
* Added hints for voice commands that display command and phrase when typing IC.
	* *Contributed by NightAngel.*
* Changed voice library to use a local stored table instead of a global one, added three new functions to access the table easier.
	* *Contributed by NightAngel.*
* Added three new functions to access the voice groups table easier GetAll(), FindByID(id) and GetVoices(id).
	* *Contributed by NightAngel.*

0.94.69
-------

* Fixed schema version print to show properly (small bugs may occur where extra decimals are added).
	* *Contributed by NightAngel.*

0.94.68
-------

* Moved chatbox hooks that implement voice commands to the voice library file for better organization.
	* *Contributed by NightAngel.*
* Added plugin call 'PlayerShouldStaminaDrain' to determine whether a player's stamina should drain while sprinting.
	* *Contributed by NightAngel.*
* Added pitch and volume arguments to the Add function of Clockwork.voices.
	* *Contributed by NightAngel.*
* Using a voice command will no longer display a message from the player if the phrase of the voice command is nil or empty.
	* *Contributed by NightAngel.*

0.94.64
-------

* Added setting to disable/enable drawing of the vignette.
	* *Contributed by NightAngel.*
* Capitalized most setting/config entry names.
	* *Contributed by NightAngel.*
* Added category key to config entry array.
	* *Contributed by kurozael.*
* Changed decimal, maximum and minimum to be forced to numbers before being added to the config entry.
	* *Contributed by NightAngel.*
* Fixed issue with 'DoorSetChild' command where the active parent door could become its own child.
	* *Contributed by NightAngel.*
* Fixed minor issue with the door multitool not updating its cpanel properly.
	* *Contributed by NightAngel.*
* Cleaned up useless comment from 'SalesmanPlaySound' datastream hook.
	* *Contributed by NightAngel.*

0.94.6
-------

* Patched weakness that was being exploited to dupe items/currency, cooldown on entity use can now be edited with 'entity_handle_time' in the config.
	* *Contributed by NightAngel.*
* Added variables (tool.reloadCMD, tool.reloadFire, tool.leftClickFire, tool.rightClickFire) to the tool metatable. Fire variables are boolean for whether the beam will fire on each event.
	* *Contributed by NightAngel.*
* Shifted door tools and parent ESP from toolguns plugin to doorcommands plugin, optimized and cleaned up code for both tools. Also shifted alot of code from tools to the commands being called.
	* *Contributed by NightAngel.*
* Added notifications to 'DoorLock' and 'DoorUnlock' commands.
	* *Contributed by NightAngel.*
* Added 'DoorResetParent' command to clear a player's active parent door (this is what the reload function of parenting tool did).
	* *Contributed by NightAngel.*
* Added config to save whether doors are locked and/or opened (on by default).
	* *Contributed by NightAngel.*

0.94.51
-------

* Fixes problem with some menus overlapping next buttons for lower resolutions in char creation
	* *Contributed by NightAngel.*

0.94.5
-------

* Fixed animations not saving for salesmen
* Added sounds for phrases and whether or not a phrase will display the salesman's name
* Added phrase for when a player starts trading with a salesman
	* *Contributed by NightAngel.*

0.94.42
-------

* Fixed a small problem with voice library being overwritten by HL2 RP.
	* *Contributed by NightAngel.*

0.94.41
-------

* Fixed a small bug with voice commands that stopped them from working correctly.
	* *Contributed by NightAngel.*

0.94.4
-------

* Added 'PostCommandUsed' hook called after a command succeeds in running.
	* *Contributed by NightAngel.*
* Added 'StaticAreaAdd' and 'StaticAreaRemove' commands for adding static entities in a certain radius around you.
	* *Contributed by NightAngel.*
* Added two new functions in the player library, CanPromote and CanDemote (focussed on rank promotions/demotions).
	* *Contributed by Vortix.*
* Added two new commands, RankPromote and RankDemote.
	* *Contributed by Vortix.*
* GetLowestRank and GetHighestRank functions now return rank table as well as name.
	* *Contributed by Vortix.*
* SetFactionRank now checks if the rank is valid and, if it is, sets the player's rank to the provided rank and provides the new rank's model, class and weapons.
	* *Contributed by Vortix.*
* Fixed sorting for tab menu items that don't have icons.
	* *Contributed by kurozael.*
* Fixed issue with players being unable to make another character without having to rejoin.
	* *Contributed by NightAngel.*
* Added theme hooks 'PreCharacterFadeOutNavigation', 'PreCharacterFadeInNavigation', 'PreCharacterFadeOutTitle' and 'PreCharacterFadeInTitle'.
	* *Contributed by NightAngel.*
* Shifted PreCharacterMenuPaint to include everything inside the paint function.
	* *Contributed by NightAngel.*
* Fixed errors that occured from the display typing plugin with utf8 len function.
	* *Contributed by NightAngel.*
* Added whitelist/blacklist system for classes that can be staticed
	* *Contributed by NightAngel.*
* Added EditStaticWhitelist and EditStaticBlacklist hooks to modify what can and cannot be staticed
	* *Contributed by NightAngel.*
* Added 'target_id_delay' config to modify the delay for when a target ID appears on a player's screen.
	* *Contributed by kurozael.*
* Added config options for intro background and logo. ('intro_background_url', 'intro_logo_url')
	* *Contributed by kurozael.*
* Added work in progress translate command along with 'translate_api_key' config option.
	* *Contributed by Vortix.*

0.94.17
-------

* Added bitflag library.
    * *Contributed by duck.*
* Linked utf-8 library with GMod utf-8 module.
    * *Contributed by Kefta.*
* Added DoorSetAllUnownable/DoorSetAllOwnable commands.
    * *Contributed by Trurascalz.*
* Allow SQL host urls with/without http:// or https:// to be used.
    * *Contributed by RJ.*
* Added check for iniTable so that the framework doesn't crash if a plugin doesn't have an ini file.
    * *Contributed by NightAngel.*
* Added checks to chatbox that solve len bug from utf8 commit.
    * *Contributed by NightAngel.*

0.94.1
-------
* Added plugin call for drawing salesman targetID.
    * *Contributed by NightAngel.*
* Added custom ammo type saving and AdjustAmmoTypes hook.
    * *Contributed by NightAngel.*
* Shifted faction/rank derived stat setting from PostPlayerSpawn to PlayerSpawn.
    * *Contributed by NightAngel.*

0.94
-------

* Added entity relationships, to make NPCs hostile/friendly/fearful towards players of certain factions.
    * *Contributed by Vortix.*
* Added a rank system to Clockwork.
    * *Contributed by Vortix.*
* Added starting inventory and respawn inventory for factions.
    * *Contributed by Vortix.*
* Moved and improved voice library from HL2RP to Clockwork
    * *Contributed by Gr4Ss and Vortix.*
* Fixed GetPrintName bug relating to AdminESP.
	* *Contributed by NightAngel.*
* Created Clockwork workshop addon and linked it to the framework for clients to auto-download.
	* *Contributed by NightAngel.*
* Added function to toggle allow (or disallow) tab menu activation.
	* *Contributed by NightAngel.*
* Cleaned up and added ThirdPerson plugin native to Clockwork.
	* *Contributed by NightAngel and RJ.*
* Organized sh_kernel code into sv_ and cl_kernel.
	* *Contributed by NightAngel.*
* Organized Clockwork.entity:IsDoor function for clarity.
	* *Contributed by RJ.*
* Moved code that broadcasts voice commands from HL2RP to Clockwork.
	* *Contributed by Vortix.*
* Overhauled the Static Entities plugin, compatible with Static Props and backs up prop file from old static ents.
	* *Contributed by NightAngel.*
* Fixed 'Clockwork' typo in codebase and IncludeDirectory.
	* *Contributed by RJ.*
* Added Plugin Compatibility value to plugin.ini
    * *Contributed by Trurascalz.*
* Added GetDefaultRank function
    * *Contributed by Vortix.*
* Updated Faction Specific Commands for multiple access
    * *Contributed by Vortix.*
* Updated to allow multiple owners
    * *Contributed by Vortix.*
* Added disease library
	* *Contributed by Vortix.*
* Added WIP language selector
	* *Contributed by NightAngel.*
* Added scrollbar to quiz
	* *Contributed by NightAngel.*
* Added recognize option for the character the player is looking at
	* *Contributed by NightAngel.*
* Added extra checks to chatbubble to fix NULL error
	* *Contributed by NightAngel.*
* Fixed issues with chatbox custom position
	* *Contributed by NightAngel.*
* Added runSound, walkSound and pickupSound to item metaTable
	* *Contributed by NightAngel.*
* Changed ShowGradient to be off by default to make default tab menu tidier
	* *Contributed by NightAngel.*
* Added OnAttributeProgress hook
	* *Contributed by NightAngel.*
* Framework now prints schema name, author and version on boot.
	* *Contributed by NightAngel.*
* Added "Center Hints", like the hints in the top-right but appear in the center of the screen.
    * *Contributed by kurozael.*
* Updated the entire UI and derma panels for better customizable themes.
    * *Contributed by kurozael.*
* Fixed some issues with wages and implemented new Wage hooks.
    * *Contributed by kurozael.*
* Added shared post-hook for when items have initialized.
    * *Contributed by kurozael.*
* Added pre-hook for when players have taken damage.
    * *Contributed by kurozael.*
* Fixed Limb Damage not resetting properly.
    * *Contributed by kurozael.*
* Added Clockwork.kernel:DrawInfoScaled for drawing a scaled font.
    * *Contributed by kurozael.*
* The character creation screen will open automatically when no characters exist.
    * *Contributed by kurozael.*
* Added DrawGeneratorTargetID hook and ability to customize generator target ID.
    * *Contributed by kurozael.*
* Added hint to press 'Use' to resupply a generator, some people didn't realize.
    * *Contributed by kurozael.*
* General fixes for Player Property entities not networking properly.
    * *Contributed by kurozael.*
* Fixed Stamina not draining and regenerating properly using customized settings.
    * *Contributed by kurozael.*
* Added some new language strings to the general codebase.
    * *Contributed by kurozael.*
* Added option to scale the width of the top bars.
    * *Contributed by kurozael.*
* Added system to add icons to menu items in the TAB menu.
    * *Contributed by kurozael.*

0.93
-------


* Added Entity Library documentation.
    * *Contributed by RJ.*
* Fixed copyright logos.
    * *Contributed by NightAngel.*
* Added Developer Version option to disable auto updating via CAX.
* Added documentation to cl_kernel.lua
    * *Contributed by NightAngel.*
* Added amount argument to CharGiveItem.
	* *Contributed by duck.*
* Added player flags and related commands.
	* *Contributed by NightAngel.*
* Added a config option to disable and/or enable the chat size for yelling and whispers.
	* *Contributed by NightAngel.*
* Removed the allowedprops plugin.
* Added family sharing protection plugin.
	* *Contributed by duck.*
* Added quantity to Clockwork.inventory:AddInstance()
	* *Contributed by Vortix.*
* Fixed multiple issues to different core systems.
* Added config option to disable business menu.
* Fixed issue where chat bubble wouldn't stick with salesmen when moved.
* Replaced static prop plugin with static entity plugin.
	* *Contributed by NightAngel.*
* Rewritten ESP system with more information to display and plug in to, clientside option added for update rate.
	* *Contributed by NightAngel.*
* Added Vortigaunt model animations.
	* *Contributed by NightAngel.*
* Added functionality to share tables.
	* *Contributed by duck.*
* Banned clients will be immediately rejected instead of going through the connection process.
	* *Contributed by duck.*
* Raised the cap for stamina regen, and made stamina attribute affect regen as it affects drain.
	* *Contributed by NightAngel.*
* Added function to add extra options for data in the persuasion creation panel.
	* *Contributed by NightAngel.*
* Added function to add labels to character screen to show extra information.
	* *Contributed by NightAngel.*
* Added cwSay concommand.
	* *Contributed by duck.*
* Rewrote hooks to run faster.
	* *Contributed by Gr4Ss.*
* Added error message on attempting to clear cache for invalid hooks for easier debugging.
	* *Contributed by Vortix.*
* Added individual table sharing.
	* *Contributed by duck.*
* Rewrote config menu to sort options for easier navigation.
	* *Contributed by duck.*
* Added datastream requests.
	* *Contributed by duck.*
* Fixed broken cwLabelButton hovering.
	* *Contributed by duck.*
* Fixed CanSeeEntity/Player/NPC always returning true. (Fixes flashbangs being horribly broken.)
	* *Contributed by Gr4Ss.*
* Fixed CW initializing bug.
	* *Contributed by Alex Grist.*
* Added icon support for NotifyAll.
	* *Contributed by Vortix.*
* Added toolgun library.
	* *Contributed by NightAngel.*
* NotifyAdmins function for ease of use when notifying admins.
	* *Contributed by NightAngel.*
* Added toolguns plugin.
    * *Contributed by Trurascalz & NightAngel.*
* Fixed examine option for items.
	* *Contributed by NightAngel.*
* Added viewmodel hands fix for weapons.
	* *Contributed by NightAngel.*
* Added icon library for easy assignment of chat/ESP icons.
	* *Contributed by Vortix.*
* Added faction rank functions.
	* *Contributed by Vortix.*
* Added auto-refresh support.
  * *Contributed by Alex Grist.*

0.92
-------

* Added Clockwork.player:AddCharacterData and Clockwork.player:AddPlayerData for adding character and player data that is automatically networked to either all players, or the local player only. This comes with a client-side version of player:GetData(key, default) and player:GetCharacterData(key, default).
* Added Linux binaries. This is a big deal. You can now run Clockwork on your Linux server, please report bugs to the issue tracker as it isn't guaranteed to be flawless right now, but at least it will run.
* Added support for intro sound configuration and reduced line count.
  * *Contributed by ametrocavich.*
* Now using PON + made datastreams faster.
  * *Contributed by TheGarry.*
* Added a config option to disable black intro bars.
* Added two config options to use different types of server rates, that should prevent few nasty item dupe glitches and also kill lags.
* Added console versions of common admin commands (such as "setgroup", "demote" etc). Use "cwc COMMAND ARGUMENTS" in console.
* Fixed bug where weapons didn't raise correctly.
* Changed Clockwork intro music to old OpenAura one.
* Clockwork will try to use SQLLite if the default SQL file is not touched.
* Clockwork will try to use MySQLOO if it is installed and loaded.
* Added a built-in crafting / recipe system. Use ITEM:AddRecipe(uniqueId, amount, uniqueId, amount, uniqueId, amount, ...) to add recipes. Items can have multiple recipes. AddRecipe returns a table, which you can use .access, .factions, .classes to prohibit access to it.
* Fixed the config option for crosshairs.
* Changed log files so they are named in order of year-month-day so they sort correctly.
* Added MeC, MeL, ItC and ItL commands to account for distances when using the Me and It commands.
* Added a config option to the stamina plugin which allows you to change the stamina regeneration rate.
* Fixed the file.Exists function.
* Fixed the CharSetDesc command.
* Added the ending to the vocoder speech for MPF and Overwatch (::>)
* Added a config option to disable/enable alt jogging.
* Added CharSetFlags and CharCheckFlags commands, as well as a SetFlags function.
* Fixed issue preventing salesmen and storage from working.
* Added a way to allow icons to be set for notifications.

0.91
-------

* Added GiveCash from the player library to the player meta table.
  * *Contributed by SomeSortOfDuck.*
* Added \n to a few ErrorNoHalt calls that were missing it.
  * *Contributed by SomeSortOfDuck.*
* Extended item options capabilities.
  * *Contributed by Insomnia Array.*
* Headbob has been clamped from 0 to 1.
  * *Contributed by hungerjohnson.*
* Added material computation to DrawScreenBlurs().
  * *Contributed by Chessnut.*
* Changed schema hook override warning to be clearer.
  * *Contributed by SomeSortOfDuck.*
* Added cl_imagebutton.lua
  * *Contributed by RJ.*
  
0.9
-------
* Progress bars will now use ScissorRect for an improved graphical aesthetic.
  * *Contributed by Spencer Sharkey.*
* A new config option (observer_reset) was added to prevent a player's position being reset when exiting observer mode.
  * *Contributed by SomeSortOfDuck.*
* Added the Derma Request library which can be used to prompt a client.
  * *Contributed by Spencer Sharkey.*
* Stamina will no longer deplete if you are not on the ground.
  * *Contributed by Spencer Sharkey.*
* Optimized client-side vignette drawing. Only performing raycast once every second.
* Added two functions to give and take a table of item instances from a
player object.
  * *Contributed by Spencer Sharkey.*
* Fixed a bug where hook errors would not be reported correctly.
  * *Contributed by Alex Grist.*
* Fixed the PluginLoad/PluginUnload commands.
  * *Contributed by Alex Grist.*
* Added sh_charsetdesc.lua for operators to set a character's physical description.
  * *Contributed by RJ.*
* Change /Roll to allow the player to specify the range of values.
  * *Contributed by Insomnia Array.*
* Added itemTable:EntityHandleMenuOption for cw_item entities (allows more code to be moved into item files).
  * *Contributed by Insomnia Array.*
* Added a 'space' system similiar to the 'weight' system, miscellaneous fixes and changes.
  * *Contributed by Insomnia Array.*
* Added a check to inventory:AddInstance to prevent erroring.
* Loading and unloading of plugins is now fully functional.
* A player's targetname is now set to their faction (for use with mapping.)
* Added size multiplier options to the chatbox to allow different sized messages. Whispering and yelling uses this feature.
* Added the Clockwork.fonts library for ease in creation and grabbing of different sized fonts that use the same settings.
