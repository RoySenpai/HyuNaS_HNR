/*
 * HyuNaS HitAndRun mod for Counter-Strike 1.6 STEAM
 * Copyright (C) 2013-2021 HiyoriX aka Hyuna (Roy)
 *
 * This software is licensed under the GNU General Public License, version 3 or higher.
 * Additional exceptions apply. For full license details, see LICENSE.txt.
 *
 *
 * HitAndRun API - Events include file
 *
 * Updated to v2.0 (2021 version)
 *
 * **** NOTE: This API ISN'T compatible with HyuNaS HitAndRun v1.0 (2013 version). ****
 *
 * Author URL: https://steamcommunity.com/id/KissMyAsscom
 * Author SteamID: STEAM_1:0:35424936
*/

#if defined _hitandrun_events_included
	#endinput
#endif
#define _hitandrun_events_included


/* Forwards */


/**
 * Called when an event is going to start - Pre method.
 *
 * @param eventid   Event ID (see enum eEvent)
 *
 * @return  PLUGIN_CONTINUE to let the core plugin handle it.
 *          PLUGIN_HANDLED to let the sub-plugin handle it.
 */
forward OnHNREventStart(eventid);


/* Natives */

/**
 * Returns the current event running.
 *
 * @noparams
 *
 * @return      ID of the current event, 0 if no event is running.
 */
native get_round_event();
