/*
 * HyuNaS HitAndRun mod for Counter-Strike 1.6 STEAM
 * Copyright (C) 2013-2021 HiyoriX aka Hyuna (Roy)
 *
 * This software is licensed under the GNU General Public License, version 3 or higher.
 * Additional exceptions apply. For full license details, see LICENSE.txt.
 *
 *
 * HitAndRun API - Alliance include file
 *
 * Updated to v2.0 (2021 version)
 *
 * **** NOTE: This API ISN'T compatible with HyuNaS HitAndRun v1.0 (2013 version). ****
 *
 * Author URL: https://steamcommunity.com/id/KissMyAsscom
 * Author SteamID: STEAM_1:0:35424936
*/

#if defined _hitandrun_alliance_included
	#endinput
#endif
#define _hitandrun_alliance_included


/* Natives */

/**
 * Checks if the client have an alliance made with another player.
 *
 * @param client	Client ID
 *
 * @return			True if there is, false if not
 *
 * @error 			Invaild client.
 */
native bool:is_user_allianced(client);

/**
 * Get's client's alliance ID, if there is an alliance.
 *
 * @param client	Client ID
 *
 * @return			Client's alliance ID. If there is no alliance, it will return -1
 *
 * @error 			Invaild client.
 */
native get_user_alliance(client);

/**
 * Set's client's alliance with other player
 *
 * @param client	Client ID
 * @param idother	The ID of the other player we want to make an alliance. (0 to remove)
 *
 * @return			1 on success, 0 if client/other player is dead/there less then 3 humans alive (failed), -1 on error
 *
 * @error 			Invaild client/alliance
 */
native set_user_alliance(client, idother);
