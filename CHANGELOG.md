# HyuNaS HitAndRun changelog
## Current version

- Build: **v2.0 BUILD 140**
- Release date: **10/12/2021**

#### Changes/Additions
- SHOP: Added more functions to the menu.
- SHOP: Added help motd.
- EVENTS: Added Events addon.
- DEV: New include: hitandrun_events.inc
- DEV: Minimal AMXX version increased to v1.9.0.
- ALL: A lot of bug fixes.
- ALL: Added missing ML keys.

#### New CVARS
- EVENTS: hnr_events; Toggle events addon status; Default: 1.
- EVENTS: hnr_events_rnd; Sets how many rounds an event will playout; Default: 7.

## Past versions

- Build: **v2.0 BUILD 132**
- Release date: **30/04/2020**

#### Changes/Additions
- SCOUTS: Fixed a glitch with the models.
- KNIVES: Fixed a glitch with the models.
- DANCE: Added Winner Dance addon (xd).


----
- Build: **v2.0 BUILD 131**
- Release date: **11/04/2020**

#### Changes/Additions
- CORE: Moved changing some cvar to the config file.
- CORE: Fixed bunnyhop not working.
- SHOP: Now you won't be able to buy stuff if you are dead!
- SHOP: Added viewing players stats.
- SHOP: Changed some default values.
- SHOP: Added amx_setlevel command.
- SHOP: Fixed the amx_addcash &  amx_removecash commands.
- SCOUTS: Fixed some bug with the menu.
- KNIVES: Fixed some bug with the menu.
- KNIVES: Fixed ML key typo.
- ALL: Added missing ML keys.

----
- Build: **v2.0 BUILD 130**
- Release date: **09/04/2020**

#### Changes/Additions
- CORE: Removed gib player feature (Seems like there are some bugs with it).
- CORE: Changed hnr_noslowdown cvar to hnr_jumpstyle and changed it purpose.
- KNIVES: Fixed ML error.
- DEV: Moved define versions to hitandrun_const.inc.

----
- Build: **v2.0 BUILD 121**
- Release date: **28/06/2019**

#### Changes/Additions
- ALL: Final optimization for final public release.

----
- Build: **v2.0 BUILD 120**
- Release date: **28/06/2019**

#### Changes/Additions
- CORE: Added map check - plugin will be disabled on non-hnr(/bombgame) maps.
- DEVELOPERS: Removed hnr_dbg_init() stock (The hnr_dbg_message() stock now handles it).
- SHOP: Fixed a bug in the ML system.
- ALLIANCE: Added multilangauge system. See hnr_alliance.txt.
- SCOUTS: Added multilangauge system. See hnr_scouts.txt.
- KNIVES: Added multilangauge system. See hnr_knives.txt.


----
- Build: **v2.0 BUILD 119**
- Release date: **01/06/2019**

#### Changes/Additions
- SHOP: Added multilangauge system. See hnr_shop.txt.
- SUPRISEBOX: Added multilangauge system. See hnr_sb.txt.


#### Bug Fixes
- SHOP: Fixed menu not showing properly.


----
- Build: **v2.0 BUILD 118**
- Release date: **31/05/2019**

#### Changes/Additions
- CORE: Added multilangauge system. See hnr_core.txt.

----
- Build: **v2.0 BUILD 117**
- Release date: **30/05/2019**

#### Changes/Additions
- ALL: Some optimizations and preperations for future updates.

----
- Build: **v2.0 BUILD 116**
- Release date: **24/05/2019**

#### Changes/Additions
- CORE: Plugin optimized.


#### Bug Fixes
- KNIVES: Fixed some bugs.

----
- Build: **v2.0 BUILD 115**
- Release date: **23/05/2019**

#### Bug Fixes
- SHOP: Fixed some bugs with amx_addcash and amx_removecash commands.
- SCOUTS: Fixed some bugs.

----
- Build: **v2.0 BUILD 114**
- Release date: **19/05/2019**

#### Changes/Additions
- CORE: Changed some default settings.
- SCOUTS: Plugin optimized.
- KNIVES: Added Knives Skins System plugin.


#### Bug Fixes
- ALLIANCE: Fixed some bugs.

----
- Build: **v2.0 BUILD 113**
- Release date: **09/05/2019**

#### Changes/Additions
- CORE: Changed some default settings.
- DEVELOPERS: Sepereted const include file from the settings (new include - hitandrun_settings).
- SCOUTS: Added Scouts Skins System plugin.

----
- Build: **v2.0 BUILD 112**
- Release date: **05/05/2019**

#### Changes/Additions
- CORE: Added get_humans_count native.
- SHOP: Added gamble system (30% chance win).
- SHOP: Added "/next" command to see how much xp needed for next level.
- ALLIANCE: Added Alliance plugin.
- ALLIANCE: New natives: is_user_allianced, get_user_alliance, set_user_alliance


#### Bug Fixes
- SHOP: Fixed set_user_xp native not working propaply.

----
- Build: **v2.0 BUILD 111**
- Release date: **04/05/2019**

#### Changes/Additions
- CORE: Adding mark for infected player in scoreboard.
- SHOP: Changed some cvar defualts.


#### New CVARS
- SHOP: hnr_bonusxp
Amount of XP get for being the last guy to pass the infection
Default: 1

- SHOP: hnr_bonuscash
Amount of Cash get for being the last guy to pass the infection
Default: 2


#### Bug Fixes
- CORE: Fixed when enable the plugin, all functions enabled even when some cvars turned off.
- CORE: Fixed hnr_nozoom cvar not working propaply.
- CORE: Fixed infection ratio not working as expected.
- SHOP: Fixed XP-Level system.

----
- Build: **v2.0 BUILD 110**
- Release date: **03/05/2019**

#### Changes/Additions
- CORE: Changing OnHNRInfection forward from Post-Method to Pre-Method (useful for alliance plugin).
- CORE: Adding Killer ID parameter to OnHNRKilled forward.
- SUPRISE BOX: Changed max surprise boxes from 20 to MAX_PLAYERS (32).


#### Bug Fixes
- CORE: Fixed when new round kicks-in and all players suddenly die and re-spawn with scout.
- CORE: Fixed plugin not working after refresh start/map change.
- SHOP: Fixed the bug that won't allow you to buy anything from the shop even if you got the money.

----
- Build: **v2.0 BUILDS 101 - 109**
- Release date: **Mid-2018 – Late-2018**

#### Changes/Additions
- A lot of stuff I can't really remember and haven't documented it.
- A lot of plugin optimization.
- ADDED: Debug system for developers.
- ADDED: Shop system, Frost-nades system, Surprise-Box System.
- ADDED: Shittone of includes (hitandrun.inc, hitandrun_const.inc, hitandrun_fn.inc, hitandrun_shop.inc, hitandrun_sb.inc, hitandrun_stocks.inc).


#### New CVARS
- CORE: hnr_blockradio
Blocks "Fire in the hole" text and sound.
Default: 1

- CORE: hnr_gibplayer
Gibs a player when he dies from infection.
Default: 1

- FROSTNADE: hnr_fn_enabled
Toggle Frost-Nade plugin.
Default: 1

- FROSTNADE: hnr_fn_selfreeze
Toggle self freeze.
Default: 1

- FROSTNADE: hnr_fn_passinfection
Toggle if the Frost-Nade can pass infection.
Default: 1

- SHOP: hnr_winxp
Amount of XP get for winning a round.
Default: 1

- SHOP: hnr_wincash
Amount of Cash get for winning a round.
Default: 5


#### Bug Fixes
- Shittone of bug fixes.

----
- Build: **v2.0 BUILD 100**
- Release date: **15/06/2018**

#### Changes/Additions
- Plugin total rewrite from scratch.
- Renamed CVARS: amx_hnr_enabled -> hnr_enabled; amx_hnr_noslowdown -> hnr_noslowdown; amx_hnr_nozoom -> hnr_nozoom; amx_hnr_noscoutdrop -> hnr_scoutdrop; amx_hnr_blockkill-> hnr_blockkill
- REMOVED: Cash system, Round system, Send system, Gamble system, Level system.
- REMOVED: All systems CVARS.

----
- Build: **v1.0**
- Release date: **29/04/2013**

#### Changes/Additions
- First Public Release.


#### New CVARS
- amx_hnr_enabled
Enable/Disable the plugin.
Default: 1

- amx_hnr_noslowdown
Enable/Disable No-Slowdown effect after jump.
Default: 1

- amx_hnr_nozoom
Enable/Disable No-Zoom mod at scout.
Default: 0

- amx_hnr_noscoutdrop
Enable/Disable blocking scout from dropping.
Default: 1

- amx_hnr_blockkill
Enable/Disable blocking from client killing himself.
Default: 1

- amx_hnr_cashsys
Enable/Disable Cash System.
Default: 1

- amx_hnr_roundsys
Enable/Disable Round & Wins Count System.
Default: 1

- amx_hnr_sendsys
Enable/Disable Send System.
Default: 1

- amx_hnr_gamblesys
Enable/Disable Gamble System.
Default: 1

- amx_hnr_levelsys
Enable/Disable Level System.
Default: 1
