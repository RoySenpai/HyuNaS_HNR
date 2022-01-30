/*
 * HyuNaS HitAndRun mod for Counter-Strike 1.6 STEAM
 * Copyright (C) 2013-2021 HiyoriX aka Hyuna (Roy)
 *
 * This software is licensed under the GNU General Public License, version 3 or higher.
 * Additional exceptions apply. For full license details, see LICENSE.txt.
 *
 *
 * HitAndRun API - Shop include file
 *
 * Updated to v2.0 (2021 version)
 *
 * **** NOTE: This API ISN'T compatible with HyuNaS HitAndRun v1.0 (2013 version). ****
 *
 * Author URL: https://steamcommunity.com/id/KissMyAsscom
 * Author SteamID: STEAM_1:0:35424936
*/

#if defined _hitandrun_shop_included
	#endinput
#endif
#define _hitandrun_shop_included


/* Natives */

/**
 * Gets client's cash.
 *
 * @param client	Client ID
 *
 * @return		Client cash.
 *
 * @error 		Invaild client.
 */
native get_user_cash(client);

/**
 * Gets client's total rounds.
 *
 * @param client	Client ID
 *
 * @return		Client total rounds
 *.
 * @error 		Invaild client.
 */
native get_user_rounds(client);

/**
 * Gets client's total wins.
 *
 * @param client	Client ID
 *
 * @return		Client total wins.
 *
 * @error 		Invaild client.
 */
native get_user_wins(client);

/**
 * Gets client's XP.
 *
 * @param client	Client ID
 *
 * @return		Client XP.
 *
 * @error 		Invaild client.
 */
native get_user_xp(client);

/**
 * Gets client's level.
 *
 * @param client	Client ID
 *
 * @return		Client level.
 *
 * @error 		Invaild client.
 */
native get_user_level(client);

/**
 * Sets client's cash.
 *
 * @param client	Client ID
 * @param cash		The cash
 *
 * @return		1 on success, 0 if failed.
 *
 * @error 		Invaild client.
 */
native set_user_cash(client,cash);

/**
 * Sets client's total rounds.
 *
 * @param client	Client ID
 * @param rounds	Total rounds
 *
 * @return		1 on success, 0 if failed.
 *
 * @error 		Invaild client.
 */
native set_user_rounds(client,rounds);

/**
 * Sets client's total wins.
 *
 * @param client	Client ID
 * @param wins		Total wins
 *
 * @return		1 on success, 0 if failed.
 *
 * @error 		Invaild client.
 */
native set_user_wins(client,wins);

/**
 * Sets client's XP.
 *
 * @param client	Client ID
 * @param xp		XP
 *
 * @return		1 on success, 0 if failed.
 *
 * @error 		Invaild client.
 */
native set_user_xp(client,xp);

/**
 * Sets client's level.
 *
 * @param client	Client ID
 * @param level		Level
 *
 * @return		1 on success, 0 if failed.
 *
 * @error 		Invaild client.
 */
native set_user_level(client,level);
