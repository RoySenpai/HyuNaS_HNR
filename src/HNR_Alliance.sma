/*
    HNR Addon: Alliance for HyuNaS HitAndRun v2.0
    Copyright (C) 2013-2021 HiyoriX aka Hyuna (Roy)
	Author URL: https://steamcommunity.com/id/KissMyAsscom
	Author SteamID: STEAM_1:0:35424936

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#include <amxmodx>
#include <hitandrun>

// Defines the HNR Debug message tag for this plugin.
#define HNR_DBG_NAME		"HNR Alliance"

new g_iAlliance[MAX_PLAYERS + 1];
new bool:g_bAllianced[MAX_PLAYERS + 1];

public plugin_init() {
	register_plugin("[HNR Addon] Alliance",get_hnr_version(),"HiyoriX");

	register_logevent("EventRoundStart",2,"1=Round_Start");

	register_clcmd("say /alliance","cmdAlliance");
	register_clcmd("say /brit","cmdAlliance");

	register_dictionary("hnr_alliance.txt");
}

public plugin_precache() {
	hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug started");
}

public plugin_end() {
	hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug ended");
}

public plugin_natives() {
	register_native("is_user_allianced","_is_user_allianced",0);
	register_native("get_user_alliance","_get_user_alliance",0);
	register_native("set_user_alliance","_set_user_alliance",0);
}

public bool:_is_user_allianced(pluginid, params) {
	static client;

	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"is_user_allianced^" call - data: %d; PluginID: %d",client,pluginid);

	if (!isClientValid(client,true))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"is_user_allianced^" error - player %d is invalid; PluginID: %d",client,pluginid);

		return false;
	}

	return g_bAllianced[client];
}

public _get_user_alliance(pluginid, params) {
	static client;

	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"get_user_alliance^" call - data: %d; PluginID: %d",client,pluginid);

	if (!isClientValid(client,true))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"get_user_alliance^" error - player %d is invalid; PluginID: %d",client,pluginid);

		return -1;
	}

	if (!g_bAllianced[client])
		return -1;

	return (isClientValid(g_iAlliance[client],true) ? g_iAlliance[client]:-1);
}

public _set_user_alliance(pluginid, params) {
	static client,idother;

	client = get_param(1);
	idother = get_param(2);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"set_user_alliance^" call - data: %d %d; PluginID: %d",client,idother,pluginid);

	if (!isClientValid(client,true))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"set_user_alliance^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return -1;
	}

	else if (!idother)
	{
		if (isClientValid(g_iAlliance[client],true))
		{
			g_iAlliance[g_iAlliance[client]] = 0;
			g_bAllianced[g_iAlliance[client]] = false;

			g_iAlliance[client] = 0;
			g_bAllianced[client] = false;

			return 1;
		}
	}

	else if (!isClientValid(idother,true))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",idother);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"set_user_alliance^" error - player %d is invalid; PluginID: %d",idother,pluginid);

		return -1;
	}

	else if (get_humans_count() < 3)
		return 0;

	g_bAllianced[client] = true;
	g_bAllianced[idother] = true;

	g_iAlliance[client] = idother;
	g_iAlliance[idother] = client;

	return 1;
}

public EventRoundStart() {
	if (isHNREnabled())
	{
		arrayset(g_iAlliance,0,(MAX_PLAYERS + 1));
		arrayset(g_bAllianced,false,(MAX_PLAYERS + 1));
	}
}

public cmdAlliance(client) {
	if (!isHNREnabled())
		return PLUGIN_CONTINUE;

	if (!is_user_alive(client))
	{
		client_print_color(client,client,"%s %L",TAG,client,"ERR_MUST_BE_ALIVE");
		return PLUGIN_HANDLED;
	}

	if (get_hnr_status() == GameEnding)
	{
		client_print_color(client,client,"%s %L",TAG,client,"ERR_GAME_END");
		return PLUGIN_HANDLED;
	}

	if (get_humans_count() < 3)
	{
		client_print_color(client,client,"%s %L",TAG,client,"ERR_NOT_ENOUGHT_PLR");
		return PLUGIN_HANDLED;
	}

	return ActionAllianceMenu(client);
}

public ActionAllianceMenu(client) {
	static some[8],players[32],szName[MAX_NAME_LENGTH],some2[128],pnum,plr,i,m;

	formatex(some2,charsmax(some2),"%L^n\r%L",client,"AL_MENU_TITLE",client,"AL_MENU_CHOOSE_PLR");

	m = menu_create(some2,"AllianceMenuHandler");

	get_players(players,pnum,"aceh","TERRORIST");

	for (i = 0; i < pnum; i++)
	{
		plr = players[i];

		if (plr == client)
			continue;

		get_user_name(plr,szName,charsmax(szName));

		num_to_str(plr,some,charsmax(some));

		menu_additem(m,szName,some);
	}

	menu_display(client,m);

	return PLUGIN_HANDLED;
}

public AllianceMenuHandler(client, menu, item) {
	static info[8],plr;

	if (item != MENU_BACK && item != MENU_MORE && item != MENU_EXIT)
	{
		if (!isHNREnabled())
		{
			client_print_color(client,client,"%s %L",TAG,client,"ERR_PLG_DISABLED");
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}

		if (get_hnr_status() == GameEnding || get_hnr_status() == GameDisabled)
		{
			client_print_color(client,client,"%s %L",TAG,client,"ERR_GAME_NOT_RUNNING");
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}

		if (get_humans_count() < 3)
		{
			client_print_color(client,client,"%s %L",TAG,client,"ERR_NOT_ENOUGHT_PLR");
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}

		menu_item_getinfo(menu,item,.info=info,.infolen=charsmax(info));

		plr = str_to_num(info);

		if (isClientValid(client,true) && isClientValid(plr,true))
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d send an alliance request to player %d.",client,plr);
			ActionAcceptAlliance(plr,client);
		}

		else
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_warning,"Player %d tried to send an alliance request to player %d, but falied.",client,plr);

			client_print_color(client,client,"%s %L",TAG,client,"ERR_MUST_BE_ALIVE_SEND");

			menu_destroy(menu);
			return ActionAllianceMenu(client);
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public ActionAcceptAlliance(target,inviter) {
	static some[128],some2[4],szName[MAX_NAME_LENGTH],m;

	get_user_name(inviter,szName,charsmax(szName));

	formatex(some,charsmax(some),"%L^n\r%L^n\y%L^n\w%L"
		,target,"AL_MENU_TITLE",target,"AL_MENU_PLR_REQ",szName,target,"AL_MENU_DOYOUWANT",target,"AL_MENU_CHOOSE_TIME",MAX_ALLIANCE_TIME);

	m = menu_create(some,"AcceptAllianceHandler");

	num_to_str(inviter,some2,charsmax(some2));

	formatex(some,charsmax(some),"%L",target,"AL_MENU_ITEM_YES");
	menu_additem(m,some,some2);

	formatex(some,charsmax(some),"%L",target,"AL_MENU_ITEM_NO");
	menu_additem(m,some,some2);

	menu_setprop(m,MPROP_EXIT,MEXIT_NEVER);

	menu_display(target,m,.time=MAX_ALLIANCE_TIME);
}

public AcceptAllianceHandler(client, menu, item) {
	static szName[MAX_NAME_LENGTH],info[4],inviter;

	menu_item_getinfo(menu,item,.info=info);

	inviter = str_to_num(info);

	if (item == MENU_TIMEOUT)
	{
		get_user_name(inviter,szName,charsmax(szName));
		client_print_color(client,client,"%s You have ^3falied^1 to accept an alliance with ^4%s^1.",TAG,client,"MSG_ALL_TIMEOUT_PLR",szName);

		get_user_name(client,szName,charsmax(szName));
		client_print_color(inviter,inviter,"%s Player ^4%s^1 had ^3falied^1 to accept an alliance with you.",TAG,inviter,"MSG_ALL_TIMEOUT_INVITER",szName);

		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d falied to accept player %d alliance request in time (TIMEOUT %d SECONDS).",client,inviter,MAX_ALLIANCE_TIME);

		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	if (!item)
	{
		if (!isHNREnabled())
		{
			client_print_color(client,client,"%s %L",TAG,client,"ERR_PLG_DISABLED");
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}

		if (get_hnr_status() == GameEnding || get_hnr_status() == GameDisabled)
		{
			client_print_color(client,client,"%s %L",TAG,client,"ERR_GAME_NOT_RUNNING");
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}

		if (get_humans_count() < 3)
		{
			client_print_color(client,client,"%s %L",TAG,client,"ERR_NOT_ENOUGHT_PLR");
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}

		if (isClientValid(client,true) && isClientValid(inviter,true))
		{
			g_bAllianced[client] = true;
			g_bAllianced[inviter] = true;

			g_iAlliance[client] = inviter;
			g_iAlliance[inviter] = client;

			get_user_name(inviter,szName,charsmax(szName));
			client_print_color(client,client,"%s %L",TAG,client,"MSG_ALL_SUCCESS",szName);

			get_user_name(client,szName,charsmax(szName));
			client_print_color(inviter,inviter,"%s %L",TAG,inviter,"MSG_ALL_SUCCESS",szName);

			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d accepted player %d alliance request.",client,inviter);
		}

		else
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_warning,"Player %d tried to accept an alliance request from player %d, but falied.",client,inviter);

			client_print_color(client,client,"%s %L",TAG,client,"ERR_MUST_BE_ALIVE_ACCEPT");
		}
	}

	else
	{
		if (isClientValid(inviter,false))
		{
			get_user_name(client,szName,charsmax(szName));
			client_print_color(inviter,inviter,"%s %L",TAG,inviter,"MSG_ALL_REFUSE_INVITER",szName);
		}

		get_user_name(inviter,szName,charsmax(szName));
		client_print_color(client,client,"%s %L",TAG,client,"MSG_ALL_REFUSE_SENDER",szName);

		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d refused to accept player %d alliance request.",client,inviter);
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public OnHNRInfection(client, infector) {
	if (isClientValid(client,true) && isClientValid(infector,true))
	{
		if (g_iAlliance[client] == infector && g_iAlliance[infector] == client)
			return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public OnHNRKilled(client, idkiller) {
	static tmp;

	if (isClientValid(g_iAlliance[client],true))
	{
		tmp = g_iAlliance[client];

		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d alliance with player %d ended due to player %d death from infection.",client,tmp,client);
		g_iAlliance[client] = 0;
		g_iAlliance[tmp] = 0

		g_bAllianced[client] = false;
		g_bAllianced[tmp] = false;
	}

	else if (get_humans_count() == 2) // Only 2 players left, reset the array anyway
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"All alliances have been removed, only 2 humans are alive.");
		arrayset(g_iAlliance,0,(MAX_PLAYERS + 1));
		arrayset(g_bAllianced,false,(MAX_PLAYERS + 1));

		client_print_color(0,client,"%s %L",TAG,LANG_PLAYER,"MSG_ALL_CLEANUP");
	}
}

public client_putinserver(client) {
	g_iAlliance[client] = 0;
	g_bAllianced[client] = false;
}

public client_disconnected(client, bool:drop, message[], maxlen) {
	g_iAlliance[client] = 0;
	g_bAllianced[client] = false;
}
