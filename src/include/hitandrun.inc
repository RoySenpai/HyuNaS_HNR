/*
 * HyuNaS HitAndRun mod for Counter-Strike 1.6 STEAM
 * Copyright (C) 2013-2021 HiyoriX aka Hyuna (Roy)
 *
 * This software is licensed under the GNU General Public License, version 3 or higher.
 * Additional exceptions apply. For full license details, see LICENSE.txt.
 *
 *
 * HitAndRun API - Main include file
 *
 * Updated to v2.0 (2021 version)
 *
 * **** NOTE: This API ISN'T compatible with HyuNaS HitAndRun v1.0 (2013 version). ****
 *
 * Author URL: https://steamcommunity.com/id/KissMyAsscom
 * Author SteamID: STEAM_1:0:35424936
*/

// Must be always first!
#include <hitandrun_settings>

#include <hitandrun_fn>
#include <hitandrun_shop>
#include <hitandrun_sb>
#include <hitandrun_alliance>
#include <hitandrun_events>
#include <hitandrun_stocks>

#if defined _hitandrun_included
	#endinput
#endif
#define _hitandrun_included

#pragma reqlib hitandrun

#if !defined AMXMODX_NOAUTOLOAD
	#pragma loadlib hitandrun
#endif


/* Forwards */

/**
 * Called when an HNR round is about to start - Pre method.
 *
 * @noparams
 *
 * @return          1 to block round start (get_hnr_status() will remain GameWaiting), 0 for normal operetion
 */
 forward OnHNRRoundStart();

/**
 * Called when a player wins the game - Post method.
 *
 * @param client	Client ID
 *
 * @noreturn
 */
forward OnHNRWinner(client);

/**
 * Called when a player gets infected - Pre method.
 *
 * @param client	Client ID
 * @param infector	ID of last hit (0 if randon infection)
 *
 * @return			1 to block the infection, 0 for normal operetion
 */
forward OnHNRInfection(client,infector);

/**
 * Called when a player killed from an infection - Post method.
 *
 * @param client	Client ID
 * @param idkiller 	Killer ID (aka Last hitter). If there is no last hit, ID=0
 *
 * @noreturn
 */
forward OnHNRKilled(client,idkiller);



/* Natives */

/**
 * Checks if selected client is infected.
 *
 * @param client	Client ID
 *
 * @return		True if is infected, alse false.
 *
 * @error 		Invaild client.
 */
native bool:is_user_infected(client);

/**
 * Returns the index position of client in the infected list.
 *
 * @param client	Client ID
 *
 * @return		Index position on success, -1 if falied/client isn't infected.
 *
 * @error 		Invaild client.
 */
native get_infected_player(client);

/**
 * Returns the array that contines the index of clients that are infected
 *
 * @param aInfectedPlayers	The Array
 *
 * @noreturn
 */
native get_infected_players(aInfectedPlayers[RATIO_INFECT]);

/**
 * Returns the amount of current infected clients.
 *
 * @noparams
 *
 * @return		Amount of infected clients.
 */
native get_infected_count();

/**
 * Returns the amount of current humans alive.
 *
 * @noparams
 *
 * @return		Amount of humans-alive clients.
 */
native get_humans_count();

/**
 * Retures the current gamestatus
 *
 * @noparams
 *
 * @return		Current game status
 */
native GameStatus:get_hnr_status();

/**
 * Sets new gamestatus
 *
 * @param status	Game status (see GameStatus enum)
 *
 * @noreturn
 */
native set_hnr_status(GameStatus:status);

/**
 * Makes a random infection based on RATIO_INFECT
 *
 * @noparams
 *
 * @return      >0 Number of infected players, 0 if nobody got infected
 */
native make_random_infection();
