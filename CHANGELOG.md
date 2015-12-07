Changelog
---------
The following changes have been made for each official Clockwork build.

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