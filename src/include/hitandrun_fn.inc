/*
 * HyuNaS HitAndRun mod for Counter-Strike 1.6 STEAM
 * Copyright (C) 2013-2021 HiyoriX aka Hyuna (Roy)
 *
 * This software is licensed under the GNU General Public License, version 3 or higher.
 * Additional exceptions apply. For full license details, see LICENSE.txt.
 *
 *
 * HitAndRun API - FrostNades include file
 *
 * Updated to v2.0 (2021 version)
 *
 * **** NOTE: This API ISN'T compatible with HyuNaS HitAndRun v1.0 (2013 version). ****
 *
 * Author URL: https://steamcommunity.com/id/KissMyAsscom
 * Author SteamID: STEAM_1:0:35424936
*/

#if defined _hitandrun_fn_included
	#endinput
#endif
#define _hitandrun_fn_included


/* Forwards */


/**
 * Called when a frost nade explodes - Pre method.
 *
 * @param ent	FrostNade entity
 *
 * @return	PLUGIN_CONTINUE to let the core plugin handle it.
 * 			PLUGIN_HANDLED to let the sub-plugin handle it.
 */
forward OnNadeExplotion(ent);

/**
 * Called when client gets frozen by a nade - Pre method.
 * The forward isn't triggered by set_user_freeze native.
 *
 * @param client	Client ID
 *
 * @return		PLUGIN_CONTINUE to let the core plugin handle it.
 * 				PLUGIN_HANDLED to let the sub-plugin handle it.
 */
forward OnClientFreeze(client);


/* Natives */

/**
 * Checks if selected client is freezed.
 *
 * @param client	Client ID
 *
 * @return		True if is freezed, else false.
 *
 * @error 		Invaild client.
 */
native bool:is_user_freezed(client);

/**
 * Freeze/Unfreeze selected client.
 *
 * @param client	Client ID
 * @param bFreezed	Freeze/Unfreeze client
 *
 * @return		1 on success, 0 on fail.
 *
 * @error 		Invaild client.
 */
native set_user_freeze(client,bool:bFreezed);
