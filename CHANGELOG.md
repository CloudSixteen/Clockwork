Changelog
---------
The following changes have been made for each official Clockwork build.

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
* Changed Clockwork intro music to old OpenAura one.

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
