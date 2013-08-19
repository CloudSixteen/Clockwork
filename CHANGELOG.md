Changelog
---------
The following changes have been made for each official Clockwork build.


0.89
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
