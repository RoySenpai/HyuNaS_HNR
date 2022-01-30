/*
 * HyuNaS HitAndRun mod for Counter-Strike 1.6 STEAM
 * Copyright (C) 2013-2021 HiyoriX aka Hyuna (Roy)
 *
 * This software is licensed under the GNU General Public License, version 3 or higher.
 * Additional exceptions apply. For full license details, see LICENSE.txt.
 *
 *
 * HitAndRun API - Settings include file
 *
 * Updated to v2.0 (2021 version)
 *
 * **** NOTE: This API ISN'T compatible with HyuNaS HitAndRun v1.0 (2013 version). ****
 *
 * Author URL: https://steamcommunity.com/id/KissMyAsscom
 * Author SteamID: STEAM_1:0:35424936
*/

#include <hitandrun_const>

#if defined _hitandrun_settings_included
	#endinput
#endif
#define _hitandrun_settings_included


/**************************
 * Settings (Core Plugin) *
 **************************/
/*
 * Plugin debug mod (Default: DEBUG_OFF)
 *
 * @NOTE: Very useful for diagnosing bugs and problems.
 *
 * Debug options:
 *
 * DEBUG_OFF 		(0) 	 - 	Turns off debug mod (Default option).
 * DEBUG_FATAL 		(1)		 - 	Shows critical/fatal error messages (ex. model load fail), so plugin can't operate at all when they occur.
 * DEBUG_ERROR 		(2)		 - 	Shows error messages (ex. native errors), that the plugin can still operate even when they occur.
 * DEBUG_WARNING 	(4)		 - 	Shows warning messages (ex. the winner of the game left the game), that don't effect game-play at much.
 * DEBUG_INFO 		(8) 	 - 	Shows messages about actions players take and general information about what the plugin is doing right now (Advanced users, not recommended).
 * DEBUG_ALL 		(15)	 - 	All above combined (Advanced users, not recommended).
 *
 *
 * NOTE: Even with debug turned off, whenever there is a fatal error - an amxx error will be showen and logged but with limited infomation.
 */
stock const dbg_mode =		(DEBUG_OFF);


// Hide HUD elements (See HIDE_* enum, Default: HIDE_FLASHLIGHT | HIDE_RADAR_HP_AP_PLUS | HIDE_TIMER_PLUS | HIDE_MONEY_PLUS)
#define HIDE_HUD_ELEMENTS 	(HIDE_FLASHLIGHT | HIDE_RADAR_HP_AP_PLUS | HIDE_TIMER_PLUS | HIDE_MONEY_PLUS)

// Ratio of infected players (Default: 3)
#define RATIO_INFECT 		3

// Tag that's used for chat - Colored (Default: ^4[ ^3HyuNaS HNR ^4]^1)
#define TAG 				"^4[ ^3HyuNaS HNR ^4]^1"

// Config file name (Default: HitAndRun.cfg)
#define CFG_FILE 			"HitAndRun.cfg"

// Sounds dir name (Default: HyuNaS_HNR)
#define PLUGIN_DIR 			"HyuNaS_HNR"

// Sounds effects dir (Default: winnersnd, infectsnd)
#define DIR_WINNER 			"winnersnd"
#define DIR_INFECTED 		"infectsnd"

// Max sounds (Default: 6, 3)
#define MAX_WINNER_SND 		6
#define MAX_INFECT_SND 		3

// Sounds names (Default: winsound, infected)
#define SND_WINNER 			"winsound"
#define SND_INFECT 			"infected"

// Retry time in seconds (float, Default: 10.0)
#define RETRY_TIME 			10.0

// Advertise message frequency in seconds (float, Default: 120.0)
#define HNR_ADV_TIME		120.0

// Sickness player model (Default: Adv-Sick)
// NOTE: Put only the model name, without path and without .mdl. The core plugin does this automatically.
stock const g_sSickModel[] = 		"Adv-Sick";

/* Sprites and sounds */
stock const g_LightningSnd[] = 		"ambience/thunder_clap.wav"; 	// Lightning sound file (Default: ambience/thunder_clap.wav)
stock const g_eLightning[] = 		"sprites/lgtning.spr";			// Lightning sprite file (Default: sprites/lgtning.spr)
stock const g_eSmoke[] = 			"sprites/steam1.spr";			// Smoke sprite file (Default: sprites/steam1.sprv)
stock const g_eWinnerBeamspr[] = 	"sprites/zbeam2.spr";			// Winner beam sprite file (Default: sprites/zbeam2.spr)
stock const g_szSIspr[] = 			"dmg_bio";						// Status Icon sprite name (Default: dmg_bio)

stock const g_sEffectsSounds[dEffectsSnd][] = {
	"loser.wav",				// Loser sound effect (Default: loser.wav)
	"alarm-thriller.mp3",		// Alarm sound effect (Default: alarm-thriller.mp3)
	"Clock.mp3"					// Clock sound effect (Default: Clock.mp3)
};


/****************************************
 * Specific settings for custom plugins *
 ****************************************/

/* Forstnades Plugin */
// Max radius (float) of FrostNade explosion (Default: 240.0)
#define MAX_RADIUS 			240.0

// Frostnade sounds
stock const g_szFrostSoundsPath[sFrostSounds][] = {
	"warcraft3/frostnova.wav",			// Frostnade explode sound effect (Default: warcraft3/frostnova.wav)
	"warcraft3/impalehit.wav",			// Frostnade hit sound effect (Default: warcraft3/impalehit.wav)
	"warcraft3/impalelaunch1.wav"		// Frostnade unfreeze sound effect (Default: warcraft3/impalelaunch1.wav)
};

// Frostnade shockwave sprite file (Default: sprites/shockwave.spr)
stock const g_szBeaconSprite[] = "sprites/shockwave.spr";

// Frostnade grenade model file (Default: models/HyuNaS_HNR/v_grenade_frost.mdl)
stock const g_szForstNadeModel[] = "models/HyuNaS_HNR/v_grenade_frost.mdl"



/************************
 * Shop plugin settings *
 ************************/
// Max levels (Default: 100)
#define MAX_LEVELS 			100

// Max cash (Default: 2147483647 ~ ((2^31) - 1)
#define MAX_CASH 			2147483647

// Max rounds (Default: 2147483647 ~ ((2^31) - 1)
#define MAX_ROUNDS 			2147483647

// Max primary Weapons (Default: 3)
#define MAX_PRIMEWEAPONS 	3

// Max secondary weapons (Default: 3)
#define MAX_SECWEAPONS 		3

// Max grenades (Default: 3)
#define MAX_GRENADES 		3

// Max ammo packs (Default: 3)
#define MAX_AMMOPACKS 		3

// Minimal amount of cash to gamble (Default: 5)
#define MIN_GAMBLE_CASH		5

// nVault vault name (Default: HNR-Shop)
stock const g_szShopVault[] = 	"HNR-Shop";

// Level XPs (Default: 50, 100, 150, ...)
stock const g_iXP[MAX_LEVELS] = { 50, 100, 150, ... };

/* Primary weapons list
 * Name | Class | Cost | CSW Code | Bullets */
stock const g_aPrimeWeaponList[MAX_PRIMEWEAPONS][WeaponsStructure] = {
	{ "M4A1", "weapon_m4a1", 15, CSW_M4A1, 2 },
	{ "MP5", "weapon_mp5navy", 30, CSW_MP5NAVY, 5 },
	{ "M3", "weapon_m3", 40, CSW_M3, 6 }
};

/* Secondary weapons list
 * Name | Class | Cost | CSW Code | Bullets */
stock const g_aSecWeaponList[MAX_SECWEAPONS][WeaponsStructure] = {
	{ "Glock 18", "weapon_glock18", 50, CSW_GLOCK18, 5 },
	{ "Desert Eagle", "weapon_deagle", 60, CSW_DEAGLE, 7 },
	{ "Five Seven", "weapon_fiveseven", 70, CSW_FIVESEVEN, 13 }
};

/* Grenades weapon list
 * Name | Class | Cost | CSW Code */
stock const g_aGrenadesList[MAX_GRENADES][GrenadesStructure] = {
	{ "HE Grenade", "weapon_hegrenade", 80, CSW_HEGRENADE },
	{ "Flashbang", "weapon_flashbang", 20, CSW_FLASHBANG },
	{ "Frostnade", "weapon_smokegrenade", 100, CSW_SMOKEGRENADE }
};

/* Ammo packs list
 * Amount | Cost */
stock const g_AmmoPacksList[MAX_AMMOPACKS][AmmoPacksStructure] = {
	{ 5, 10 },
	{ 15, 20 },
	{ 30, 35 }
};




/**************************
 * Scouts plugin settings *
 **************************/
// Max scouts  (Default: 6; counting the default scout)
#define MAX_SCOUTS 			6

/* Scouts list
 * Name | VModel | PModel | Min. Level | Cost | Access Level */
stock const g_aScoutsList[MAX_SCOUTS][ScoutsStructure] = {
	{ "Default Scout", 		g_szDefaultVScout, 							g_szDefaultPScout, 0, 0, ADMIN_ALL },
	{ "Begginer Scout", 	"models/HyuNaS_HNR/Scouts/v_scout1.mdl", 	"models/HyuNaS_HNR/Scouts/p_scout1.mdl", 1, 100, ADMIN_ALL },
	{ "Semi-Pro Scout", 	"models/HyuNaS_HNR/Scouts/v_scout2.mdl", 	"models/HyuNaS_HNR/Scouts/p_scout2.mdl", 5, 200, ADMIN_ALL },
	{ "Pro Scout", 			"models/HyuNaS_HNR/Scouts/v_scout3.mdl", 	"models/HyuNaS_HNR/Scouts/p_scout3.mdl", 10, 500, ADMIN_ALL },
	{ "God-like Scout", 	"models/HyuNaS_HNR/Scouts/v_scout4.mdl", 	"models/HyuNaS_HNR/Scouts/p_scout4.mdl", 20, 1000, ADMIN_ALL },
	{ "VIP Scout", 			"models/HyuNaS_HNR/Scouts/v_scout5.mdl", 	"models/HyuNaS_HNR/Scouts/p_scout5.mdl", 0, 0, ADMIN_CHAT }
};

// nVault vault name (Default: HNR-Scouts)
stock const g_szScoutsVault[] = "HNR-Scouts";



/**************************
 * Knives plugin settings *
 **************************/
// Max knives  (Default: 6; counting the default knife)
#define MAX_KNIVES 			6

/* Knives list
 * Name | VModel | PModel | Min. Level | Cost | Access Level */
stock const g_aKnivesList[MAX_KNIVES][KnivesStructure] = {
	{ "Default Knife", 		g_szDefaultVKnife, 							g_szDefaultPKnife, 0, 0, ADMIN_ALL },
	{ "Begginer Knife", 	"models/HyuNaS_HNR/Knives/v_knife1.mdl", 	"models/HyuNaS_HNR/Knives/p_knife1.mdl", 1, 100, ADMIN_ALL },
	{ "Semi-Pro Knife", 	"models/HyuNaS_HNR/Knives/v_knife2.mdl", 	"models/HyuNaS_HNR/Knives/p_knife2.mdl", 5, 200, ADMIN_ALL },
	{ "Pro Knife", 			"models/HyuNaS_HNR/Knives/v_knife3.mdl", 	"models/HyuNaS_HNR/Knives/p_knife3.mdl", 10, 500, ADMIN_ALL },
	{ "God-like Knife", 	"models/HyuNaS_HNR/Knives/v_knife4.mdl", 	"models/HyuNaS_HNR/Knives/p_knife4.mdl", 20, 1000, ADMIN_ALL },
	{ "VIP Knife", 			"models/HyuNaS_HNR/Knives/v_knife5.mdl", 	"models/HyuNaS_HNR/Knives/p_knife5.mdl", 0, 0, ADMIN_CHAT }
};


// nVault vault name (Default: HNR-Knives)
stock const g_szKnivesVault[] = "HNR-Knives";


/****************************
 * Alliance plugin settings *
 ****************************/
// Max alliance accept time in seconds (Default: 20)
#define MAX_ALLIANCE_TIME	20


/*******************************
 * Suprise-Box plugin settings *
 *******************************/
// Max Surprise Box entites - to prevent crashes and lags (Default: MAX_PLAYERS)
#define MAX_BOX_ENTITES 	MAX_PLAYERS

// Suprise box max size (Default: 5.0, 5.0, 5.0)
stock const Float:g_iSBEntMax[3] = { 5.0, 5.0, 5.0 };

// Suprise box mix size (Default: -2.0, -2.0, -2.0)
stock const Float:g_iSBEntMin[3] = { -2.0, -2.0, -2.0 };

// Suprise box model (Default: models/HyuNaS_HNR/w_surprisebox.mdl)
stock const g_szSBModel[] = "models/HyuNaS_HNR/w_surprisebox.mdl";

// Suprise box entity classname (Default: ent_surprisebox)
stock const g_szSurpriseBoxClassname[] = "ent_surprisebox";


/*******************************
 * Infender Dance plugin settings *
 *******************************/

// Max fireworks sprites that will be precached (Default: 8)
#define MAX_SPRITES         8

// Hands viewmodel location (Default: models/HyuNaS_HNR/v_claphands.mdl)
stock const g_szDanceModel[] = "models/HyuNaS_HNR/v_claphands.mdl";

// Fireworks sprites list
stock const g_szSpriteList[MAX_SPRITES][] = {
    "sprites/HyuNaS_HNR/FireWorks/fw_1.spr",
    "sprites/HyuNaS_HNR/FireWorks/fw_2.spr",
    "sprites/HyuNaS_HNR/FireWorks/fw_3.spr",
    "sprites/HyuNaS_HNR/FireWorks/fw_4.spr",
    "sprites/HyuNaS_HNR/FireWorks/fw_5.spr",
    "sprites/HyuNaS_HNR/FireWorks/fw_6.spr",
    "sprites/HyuNaS_HNR/FireWorks/fw_7.spr",
    "sprites/HyuNaS_HNR/FireWorks/fw_8.spr"
};


/**************************
 * Events plugin settings *
 **************************/

// Events enum
enum _:eEvent
{
    eNone,
    eBhop,
    ePistols,
    eGrenades,
    eKnives,
    eFog,
    eGravity,
    eDouble
};

// Events names
stock const g_szEvents[eEvent][] = {
    "",
    "Rabbit Easter",
    "Pistols Only",
    "Dodgeball Game",
    "Sticks and Stones",
    "Foggy Night",
    "Moonday",
    "All The Double"
};

// Defines the gravity multiplier for the gravity event (Default: 0.5)
#define EVN_GRAVITY_MUL 0.5

// Defines the density of the fog for the fog event (Default: FOG_HIGH)
#define FOG_DENSITY     FOG_HIGH

// Defines the fog color (Default: 127, 127, 127 - Gray)
stock const g_iFogColors[3] = { 127, 127, 127 };

// Defines the lights settings for the fog event (Default: c)
stock const g_iFogLight[] = "c";
