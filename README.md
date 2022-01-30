# HyuNaS HitAndRun for ***Counter-Strike 1.6***
## v2.0 Release Documentation


**By HiyoriX aka Hyuna (Roy), SteamID: [STEAM_1:0:35424936](https://steamcommunity.com/id/KissMyAsscom).**

## Information
This plugin is a new gameplay mode for Counter-Strike. All players go to the Terrorists team, 10 seconds after the game starts and 1 or more players get randomly an 'infection' from a mysterious virus. The main goal is to pass the infection to other players before the time runs out and the virus kill the player. The winner is the player that survived the infection.

Plugin supports both ***Counter-Strike 1.6*** and ***Counter-Strike: Condition Zero***.

## Requirements
* **STEAM server only with an updated build 6153+ Aug 2013 (Recommanded: build 8177+ Mar 2019)**
* **Metamod v1.2.1-am/Metamod-P 1.21p38**
* **AMX Mod X v1.9+ (Recommanded: v1.10)**

:no_entry_sign: **_NOTE_: No support for _AMX Mod_! Don't ask me about it!**

## Installation guide
1. Change any setting you want (via hitandrun_settings.inc) and compile it ***locally*** via an amxx complier.
2. Upload all the resources (mod_resources) to your cstrike server folder.
3. Upload your config files to addons/amxmodx/configs server folder.
4. Upload the language files to addons/amxmodx/data/lang server folder.
5. Upload the binary amxx files to addons/amxmodx/plugins server folder.
6. Change the server's map to an Hit And Run/Bomb Game map (hnr_ or bg_ prefix).
7. Enjoy!

## Bug reports
### If you found an issue with the plugin or the addons, please follow this steps:
1. Enable debug with all options enabled (via hitandrun_settings.inc).
2. Run the server until the problem occures.
3. Analayze the debug information, if any of it is useful.
4. Post the log files (including amxx error logs if there are), with full information about your server (metamod version & running dlls, amxx version & running plugins & modules, server version and server status command) and what you did to repeat the problem.
5. If you had changed some stuff from the vanilla version - also post the code that have been changed.
6. Posting a video/screenshot will also help identify the problem.

**_NOTE:_ Most of the time you can see yourself what error occures as debug with all options will log EVERYTHING the plugin does, helping you identifing and fixing the problem by yourself.**

## To do list
- [ ] Add admin menu
- [ ] Add SQL Support.
