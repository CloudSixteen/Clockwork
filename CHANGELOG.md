Changelog
---------
The following changes have been made for each official Clockwork build.

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
* Added easy loading for toolgun tools.
	* *Contributed by NightAngel.*
	
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
