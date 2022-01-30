/*
 * HyuNaS HitAndRun mod for Counter-Strike 1.6 STEAM
 * Copyright (C) 2013-2021 HiyoriX aka Hyuna (Roy)
 *
 * This software is licensed under the GNU General Public License, version 3 or higher.
 * Additional exceptions apply. For full license details, see LICENSE.txt.
 *
 *
 * HitAndRun API - Const include file
 *
 * Updated to v2.0 (2021 version)
 *
 * **** NOTE: This API ISN'T compatible with HyuNaS HitAndRun v1.0 (2013 version). ****
 *
 * Author URL: https://steamcommunity.com/id/KissMyAsscom
 * Author SteamID: STEAM_1:0:35424936
*/

#if defined _hitandrun_const_included
	#endinput
#endif
#define _hitandrun_const_included

/*
*
* 	Defines the minimal AMX Mod X version that's required to run the plugins. (Defualt: 1.9)
*	Note: Don't change this value!!!
* 	Note: Most of the functions require this version, so don't be a chicken, this IS a stable version :-)
*
*/
#if AMXX_VERSION_NUM < 190
	#assert Amx Mod X Version 1.90 and above is needed to run this plugin!   \
			Download the last version via this link: www.amxmodx.org/downloads-new.php
#endif

// Plugin official version (Don't change <: - I use build number to increase the version)
#define HNR_VERSION 		"v2.0"

// Defines plugin build (Sub-version)
#define HNR_VER_BUILD		140


// Core enums
enum (<<= 1)
{
	HIDE_CROSS_AMMO_WEPLST = 1,		// (1<<0) = 1; 		Crosshair, Ammo, Weapons List
	HIDE_FLASHLIGHT,				// (1<<1) = 2; 		Flashlight, +
	HIDE_ALL,						// (1<<2) = 4; 		Everything
	HIDE_RADAR_HP_AP_PLUS,			// (1<<3) = 8; 		Radar, Health, Armor, +
	HIDE_TIMER_PLUS,				// (1<<4) = 16; 	Timer, +
	HIDE_MONEY_PLUS,				// (1<<5) = 32; 	Money, +
	HIDE_CROSS,						// (1<<6) = 64; 	Crosshair
	HIDE_PLUS						// (1<<7) = 128;  	+
}
// Symbol + mean that an additional crosshair will be drawn. That crosshair looks exactly like the one from Crosshair message.

enum GameStatus
{
	GameDisabled = 0,			// Game disabled
	GameWaiting,				// Game waiting to start
	GameRunning,				// Game running
	GameEnding					// Winner (Game end)
}

enum _:ShopCategories
{
	cPrimeWeapons = 0,
	cSecWeapons,
	cGrenades,
	cAmmo,
	cStats,
	cScoutsM,
	cKnivesM,
    cEvents,
	cHelpM
}

enum (+=1)
{
	STATUSICON_OFF = 0,			// Disabled
	STATUSICON_ON,				// Show sprite
	STATUSICON_FLASH			// Flash sprite
}

enum (+=1)
{
	FOG_OFF = 0,
	FOG_LOW_XX,
	FOG_LOW_X,
	FOG_LOW,
	FOG_LOW_NORMAL,
	FOG_NORMAL,
	FOG_NORMAL_HIGH,
	FOG_HIGH,
	FOG_HIGH_X,
	FOG_MAX
}

enum _:dEffectsSnd
{
	eLooser,
	eAlarm,
	eClock
}

enum _:eCvarsData
{
	cName[32],
	cDefValue[4],
	cDescription[64]
}


// Task ID's
enum _:TaskIDs
{
	TASKID_GAMESTART = 999,
	TASKID_COUNTDOWN,
	TASKID_TIMER,
	TASKID_SOUNDS,
	TASKID_ADVMSG,
	TASKID_EXPLODE,
	TASKID_FREEZE,
	TASKID_FIREWORKS
}

// Frostnade enums
enum _:sFrostSounds
{
	sExplode,
	sHit,
	sUnfreeze
}

// Shop enums
enum _:WeaponsStructure
{
	WepName[32],
	WepClass[32],
	WepCost,
	WepCSW,
	WepBullets
}

enum _:GrenadesStructure
{
	GreName[32],
	GreClass[32],
	GreCost,
	GreCSW
}

enum _:AmmoPacksStructure
{
	AmmoAmount,
	AmmoCost
}

// Scouts enums
enum _:ScoutsStructure
{
	ScoutName[32],
	ScoutVModel[64],
	ScoutPModel[64],
	ScoutMinLevel,
	ScoutCost,
	ScoutAccessLevel
}

// Knives enums
enum _:KnivesStructure
{
	KnifeName[32],
	KnifeVModel[64],
	KnifePModel[64],
	KnifeMinLevel,
	KnifeCost,
	KnifeAccessLevel
}

// Default scouts models, DON'T CHANGE.
#define g_szDefaultVScout 		"models/v_scout.mdl"
#define g_szDefaultPScout 		"models/p_scout.mdl"

// Default knives models, DON'T CHANGE.
#define g_szDefaultVKnife 		"models/v_knife.mdl"
#define g_szDefaultPKnife 		"models/p_knife.mdl"


// ScoreAttrib Message defines
#define SCOREATTRIB_NONE	0		// No mark
#define SCOREATTRIB_DEAD	(1<<0)	// Marked dead
#define SCOREATTRIB_BOMB	(1<<1)	// Marked has a bomb (T's only)
#define SCOREATTRIB_VIP		(1<<2)	// Marked is VIP (CT's only)

// Debug stuff
enum (<<=1)
{
	DEBUG_OFF = 0,		// Turns off debug
	DEBUG_FATAL = 1,	// Shows debug on fatal errors (plugin can't operate anymore).
	DEBUG_ERROR,		// Shows debug on errors (plugin can continue to operate).
	DEBUG_WARNING,		// Shows debug on warnings.
	DEBUG_INFO			// Shows debug on info messages (testing only!).
}

#define DEBUG_ALL 		(DEBUG_FATAL | DEBUG_ERROR | DEBUG_WARNING | DEBUG_INFO)	// Debug all messages (testing only!).

enum DebugTypes (+=1)
{
	dbg_fatal = 0,
	dbg_error,
	dbg_warning,
	dbg_info,
	dbg_any
}

stock const g_szDbgPrefix[DebugTypes][] = {
	"FATAL",
	"ERROR",
	"WARNING",
	"INFO",
	"DEBUGGER"
};

stock const g_szGSNames[4][16] = {
	"Game Disabled",
	"Game Waiting",
	"Game Running",
	"Game Ending"
};

stock g_szLogfile[128];

/* Flags for screenfade */
#define FFADE_IN         	0x0000 		// Just here so we don't pass 0 into the function
#define FFADE_OUT        	0x0001 		// Fade out (not in)
#define FFADE_MODULATE   	0x0002 		// Modulate (don't blend)
#define FFADE_STAYOUT    	0x0004 		// ignores the duration, stays faded out until new ScreenFade message received

// Fog density offsets [Credit to DA]
stock const g_iFogDensity[] = {
	0, 0, 0, 0,					// 0 = FOG_OFF
	111, 18, 3, 58,				// 1 = FOG_LOW_XX
	111, 18, 125, 58,			// 2 = FOG_LOW_X
	66, 96, 27, 59,				// 3 = FOG_LOW
	90, 101, 60, 59,			// 4 = FOG_NORMAL_LOW
	90, 101, 68, 59,			// 5 = FOG_NORMAL
	10, 41, 95, 59,				// 6 = FOG_NORMAL_HIGH
	111, 18, 125, 59,			// 7 = FOG_HIGH
	111, 18, 3, 60,				// 8 = FOG_HIGH_X
	68, 116, 19, 60				// 9 = FOG_MAX
};


// nVault timestamp dummy var
stock nVaultDummy = 0;

// END
