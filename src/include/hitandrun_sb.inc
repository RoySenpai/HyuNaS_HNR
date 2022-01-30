/*
 * HyuNaS HitAndRun mod for Counter-Strike 1.6 STEAM
 * Copyright (C) 2013-2021 HiyoriX aka Hyuna (Roy)
 *
 * This software is licensed under the GNU General Public License, version 3 or higher.
 * Additional exceptions apply. For full license details, see LICENSE.txt.
 *
 *
 * HitAndRun API - Surprise Box include file
 *
 * Updated to v2.0 (2021 version)
 *
 * **** NOTE: This API ISN'T compatible with HyuNaS HitAndRun v1.0 (2013 version). ****
 *
 * Author URL: https://steamcommunity.com/id/KissMyAsscom
 * Author SteamID: STEAM_1:0:35424936
*/

#if defined _hitandrun_sb_included
	#endinput
#endif
#define _hitandrun_sb_included

/* Forwards */

/**
 * Called when a player attemps to open a surprise box (In menu).
 *
 * @param client	Client ID
 *
 * @return			PLUGIN_CONTINUE to let the core plugin handle it.
 * 					PLUGIN_HANDLED to let the sub-plugin handle it.
 */
forward OnClientAttempOpenBox(client);

/**
 * Called when a player touches a surprise box.
 *
 * @param client	Client ID
 * @param iEnt		Surprise Box entity ID
 *
 * @return			PLUGIN_CONTINUE to let the core plugin handle it.
 * 					PLUGIN_HANDLED to let the sub-plugin handle it.
 */
forward OnClientTouchBox(client, iEnt);


/* Natives */

/**
 * Checks if selected client is in select menu.
 *
 * @param client	Client ID
 *
 * @return			True if is in menu or false if not or failed.
 *
 * @error 			Invaild client.
 */
native bool:is_client_onboxmenu(client);

/**
 * Forces showing surprise box menu to a selected client.
 *
 * @param client	Client ID
 *
 * @return			1 on success, 0 on fail, -1 if the client is HLTV or a bot.
 *
 * @error 			Invaild client.
 */
native client_forceboxmenu(client);

/**
 * Creates a surprise box with given origin.
 *
 * @param origin	A 3-sized array that contain the location of the box (aka origin).
 *
 * @return			Entity id on success, -1 if failed/got to max entites.
 */
native create_surprisebox(Float:origin[3]);

/**
 * Removes a specific surprise box entity.
 *
 * @param iEnt		The surprise box entity id.
 *
 * @return			Returns 1 on success, 0 if the ent isn't surprise box.
 *
 * @error			Invaild entity.
 */
native remove_surprisebox(iEnt);

/**
 * Purge all supply boxes entites.
 *
 * @noparams
 *
 * @return			1 on success, 0 if there aren't any supply box entites.
 */
native purge_surpriseboxes();

/**
 * Returns how much supply box entities are exist.
 *
 * @noparams
 *
 * @return			Supply boxes in the map.
 */
native get_surprisebox_count();
