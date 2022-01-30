/*
 * HyuNaS HitAndRun mod for Counter-Strike 1.6 STEAM
 * Copyright (C) 2013-2021 HiyoriX aka Hyuna (Roy)
 *
 * This software is licensed under the GNU General Public License, version 3 or higher.
 * Additional exceptions apply. For full license details, see LICENSE.txt.
 *
 *
 * HitAndRun API - Stocks include file
 *
 * Updated to v2.0 (2021 version)
 *
 * **** NOTE: This API ISN'T compatible with HyuNaS HitAndRun v1.0 (2013 version). ****
 *
 * Author URL: https://steamcommunity.com/id/KissMyAsscom
 * Author SteamID: STEAM_1:0:35424936
*/

#if defined _hitandrun_stocks_included
	#endinput
#endif
#define _hitandrun_stocks_included

#if !defined _amxmodx_included
	#include <amxmodx>
#endif

#if !defined _fakemeta_included
	#include <fakemeta>
#endif

/* Stocks */

/**
 * Quick stock for checking if given client is valid.
 *
 * @param client	Client id
 * @param bAlive 	Also checks if player is alive
 * @param bBots		Include bots
 *
 * @return		True if client is valid, false if not.
 */
stock bool:isClientValid(client, bool:bAlive = false, bool:bBots = false) {
	if (!is_user_connected(client))
		return false;

	if (is_user_hltv(client))
		return false;

	if (!bBots && is_user_bot(client))
		return false;

	if (bAlive)
		return bool:is_user_alive(client);

	return true;
}

/**
 * Quick stock for checking if HNR plugin is enabled via cvar.
 *
 * @noparams
 *
 * @return		True if enabled, False if not.
 */
stock bool:isHNREnabled() {
	static ePointer;

	if (!ePointer)
		ePointer = get_cvar_pointer("hnr_enabled");

	return get_pcvar_bool(ePointer);
}

/**
 * Quick stock for checking if sound file exists (for precache & debug).
 *
 * @param filename 		File full path
 * @param use_valve_fs	Same as use_valve_fs param in file_exists()
 *
 * @return				True if found; false if not.
 */
stock bool:isSoundFileExist(const filename[], bool:use_valve_fs = false) {
	new some[128];

	formatex(some,charsmax(some),"sound/%s",filename);

	return bool:file_exists(some,use_valve_fs);
}

/**
 * Removes all entities with given classname.
 *
 * @param classname		The classname of the entities you want to remove.
 *
 * @noreturn
 */
stock RemoveAllEntitiesByClass(const classname[]) {
	new ent = -1;

	while ((ent = engfunc(EngFunc_FindEntityByString,ent,"classname",classname)) > 0)
		engfunc(EngFunc_RemoveEntity,ent);
}

/**
 * Set environment's light style (fakemeta moudle).
 *
 * @param lights	Light style, from 'a' to 'z'.
 *
 * @noreturn
 */
stock fm_set_lights(const lights[]) {
	engfunc(EngFunc_LightStyle,0,lights);
}

/**
 * Makes sickness effect to given client.
 *
 * @param index		Client ID.
 *
 * @return			1 on success, 0 if client isn't valid/dead.
 */
stock make_sickness(index) {
	static Origin[3];

	if (!isClientValid(index,true))
		return 0;

	get_user_origin(index,Origin);

	message_begin(MSG_PVS,SVC_TEMPENTITY,Origin);
	write_byte(TE_IMPLOSION);	// Tracers moving toward a point
	write_coord(Origin[0]); // Position X
	write_coord(Origin[1]); // Position Y
	write_coord(Origin[2]); // Position Z
	write_byte(128);  // Radius
	write_byte(20); // Count
	write_byte(3); // Life in 0,1's
	message_end();

	return 1;
}

/**
 * Makes client's screen shake.
 *
 * @param index		Client ID. Put 0 for everyone.
 *
 * @noreturn
 */
stock make_user_screenshake(index){
	static msgScreenShake;

	if (!msgScreenShake)
		msgScreenShake = get_user_msgid("ScreenShake");

	message_begin((index ? MSG_ONE:MSG_ALL),msgScreenShake,.player=index);
	write_short(255<<14);	// Ammount
	write_short(10<<14);	// Lasts this long
	write_short(255<<14);	// Frequency
	message_end();
}

/**
 * Makes a screen fade effect to client.
 *
 * @param index		Client ID. Put 0 for everyone.
 * @param duration	Time. (1<<12) = 1 second.
 * @param holdtime	Holdtime. (1<<12) = 1 second.
 * @param flags		Flags. See FFADE_* const.
 * @param r			Red amount (from 0 to 255).
 * @param g			Green amount (from 0 to 255).
 * @param b			Blue amount (from 0 to 255).
 * @param a			Alpha amount (from 0 to 255).
 *
 * @noreturn
 */
stock make_user_screenfade(index,duration,holdtime,flags, r = 0, g = 0, b = 0, a = 255) {
	static msgScreenFade;

	if (!msgScreenFade)
		msgScreenFade = get_user_msgid("ScreenFade");

	message_begin((index ? MSG_ONE:MSG_ALL),msgScreenFade,.player = index);
	write_short(duration);	// Duration
	write_short(holdtime); // HoldTime
	write_short(flags); // Flags
	write_byte(r); // Red
	write_byte(g); // Green
	write_byte(b); // Blue
	write_byte(a); // Alpha
	message_end();
}

/**
 * Makes a bartime.
 *
 * @param index		Client ID. Put 0 for everyone.
 * @param duration	The time that take to the bar fill.
 *
 * @noreturn
 */
stock make_user_bartime(index,duration = 0) {
	static msgBarTime;

	if (!msgBarTime)
		msgBarTime = get_user_msgid("BarTime");

	message_begin((index ? MSG_ONE:MSG_ALL),msgBarTime,.player = index);
	write_short(duration); // Duration
	message_end();
}

/**
 * Makes some fireworks
 *
 * @param index		Client ID
 * @param iSprite	Sprite index (must be precached first!)
 *
 * @noreturn
 */
stock MakeWinnerFireWorks(index, iSprite) {
    static iOrigin[3];

    get_user_origin(index,iOrigin);

    message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
    write_byte(TE_SPRITETRAIL);
    write_coord(iOrigin[0]);        // Start Position (X)
    write_coord(iOrigin[1]);        // Start Position (Y)
    write_coord(iOrigin[2]);        // Start Position (Z)
    write_coord(iOrigin[0]);        // End Position (X)
    write_coord(iOrigin[1]);        // End Position (Y)
    write_coord(iOrigin[2] + 10);   // End Position (Z)
    write_short(iSprite);           // Sprite index
    write_byte(25);                 // Count
    write_byte(1);                  // Life in 0.1's
    write_byte(2);                  // Scale in 0.1's
    write_byte(25);                 // Velocity along vector in 10's
    write_byte(25);                 // Randomness of velocity in 10's
    message_end();
}

/**
 * Makes a status icon.
 *
 * @param index		Client ID. Put 0 for everyone.
 * @param spr		Sprite name.
 * @paarm status	See STATUSICON_* const for more information.
 * @param r			Red amount (from 0 to 255).
 * @param g			Green amount (from 0 to 255).
 * @param b			Blue amount (from 0 to 255).
 *
 * @noreturn
 */
stock make_user_statusicon(index, const spr[], status = STATUSICON_ON, r = 0, g = 255, b = 255) {
	static msgStatusIcon;

	if (!msgStatusIcon)
		msgStatusIcon = get_user_msgid("StatusIcon");

	message_begin((index ? MSG_ONE:MSG_ALL),msgStatusIcon,.player = index);
	write_byte(status); // Status (0=hide, 1=show, 2=flash)
	write_string(spr); // Sprite name
	write_byte(r); // Red
	write_byte(g); // Green
	write_byte(b); // Blue
	message_end();
}


/**
 * Makes a fog.
 *
 * @note 			Players must set cvar "cl_fog" to 1 to show fog!
 *
 * @param r			Red amount (from 0 to 255).
 * @param g			Green amount (from 0 to 255).
 * @param b			Blue amount (from 0 to 255).
 * @param density	How much does the fog effects (see FOG_* const).
 *
 * @noreturn
 */
stock make_fog(r = 0, g = 0, b = 0, density = FOG_OFF){
	static msgFog, dens;

	if (!msgFog)
		msgFog = get_user_msgid("Fog");

	dens = (4 * density);

	message_begin(MSG_BROADCAST,msgFog,{0,0,0},0);
	write_byte(r); // Red
	write_byte(g); // Green
	write_byte(b); // Blue
	write_byte(g_iFogDensity[dens]); // SD
	write_byte(g_iFogDensity[dens + 1]); // ED
	write_byte(g_iFogDensity[dens + 2]); // D1
	write_byte(g_iFogDensity[dens + 3]); // D2
	message_end();
}

/**
 * Changes scoreboard mark
 *
 * @note 			See SCOREATTRIB_* for more information about the flags
 *
 * @param client	Client ID
 * @param flags		Flags bitsum
 *
 * @return			1 on success, 0 if player is invalid
 */
stock msg_scoreattrib(client, flags) {
	static msgScoreAttrib;

	if (!msgScoreAttrib)
		msgScoreAttrib = get_user_msgid("ScoreAttrib");

	if (!is_user_connected(client))
		return 0;

	message_begin(MSG_ALL,msgScoreAttrib,{0,0,0},0);
	write_byte(client);
	write_byte(flags);
	message_end();

	return 1;
}

/**
 * Returns the offical HNR version in string format
 *
 * @noparams
 *
 * @return			HNR version in string, formatted as "vX.Y.ZZZ"
 */
stock get_hnr_version() {
	static szVersion[MAX_NAME_LENGTH];

	if (!szVersion[0])
		formatex(szVersion,charsmax(szVersion),"%s.%d",HNR_VERSION,HNR_VER_BUILD);

	return szVersion;
}

/**
 * Just logs a debug message.
 *
 * @note 				Output logged text will be: "L MM/DD/YYYY - HH:MM:SS: [PREFIX] DBG_LEVEL: DBG_MSG"
 *
 * @param dbg_prefix	Prefix to use in the debug message
 * @param dbg_lvl       Debug level (see hitandrun_const.inc)
 * @param dbg_msg		The debug message (Max 192 chars)
 * @param ...			Format text
 *
 * @return 				1 = Active debug; 0 - No debug (won't do anything at all).
 */
stock hnr_dbg_message(const dbg_prefix[], const DebugTypes:dbg_lvl, const dbg_msg[192], any: ...){
	if (dbg_mode)
	{
		if (!g_szLogfile[0])
		{
			get_time("%d-%m-%Y",g_szLogfile,charsmax(g_szLogfile));

			format(g_szLogfile,charsmax(g_szLogfile),"hnr_%s.log",g_szLogfile);
		}

		new szMsg[MAX_FMT_LENGTH],szMsg2[MAX_FMT_LENGTH];

		if ((dbg_mode & DEBUG_FATAL && dbg_lvl == dbg_fatal) ||
			(dbg_mode & DEBUG_ERROR && dbg_lvl == dbg_error) ||
			(dbg_mode & DEBUG_WARNING && dbg_lvl == dbg_warning) ||
			(dbg_mode & DEBUG_INFO && dbg_lvl == dbg_info) ||
			(dbg_mode > DEBUG_OFF && dbg_lvl == dbg_any))
		{

			format(szMsg2,charsmax(szMsg2),"[%s] %s: %s",dbg_prefix,g_szDbgPrefix[dbg_lvl],dbg_msg);
			vformat(szMsg,charsmax(szMsg),szMsg2,4);
			log_to_file(g_szLogfile,szMsg);

			return 1;
		}
	}

	return 0;
}
