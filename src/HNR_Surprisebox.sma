/*
    HNR Addon: Suprise Box for HyuNaS HitAndRun v2.0
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
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <hitandrun>

// Defines the HNR Debug message tag for this plugin.
#define HNR_DBG_NAME		"HNR SurpriseBox"

new g_iMenu;

new g_iEntCount;

new g_iForwardOnAttemp, g_iForwardOnTouch;

new bool:g_bIsInMenu[MAX_PLAYERS + 1];

public plugin_init() {
	register_plugin("[HNR Addon] Surprise Box",get_hnr_version(),"HiyoriX");

	register_concmd("amx_purgeboxes","cmdPurgeBoxes",ADMIN_KICK,"- Deletes all Surprise Boxes");

	RegisterHam(Ham_Touch,"info_target","fw_HamEntityTouchPost",1);
	RegisterHamPlayer(Ham_Spawn,"fw_HamPlayerSpawnPost",1);

	register_event("HLTV","fw_eventNewRound","a","1=0","2=0");

	g_iForwardOnAttemp = CreateMultiForward("OnClientAttempOpenBox",ET_STOP,FP_CELL);
	g_iForwardOnTouch = CreateMultiForward("OnClientTouchBox",ET_STOP,FP_CELL,FP_CELL);

	if (g_iForwardOnAttemp == INVALID_HANDLE || g_iForwardOnTouch == INVALID_HANDLE)
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed create forwards; Plugin failed to load.");
		set_fail_state("[HitAndRun] Error creating forwards.");
	}

	register_dictionary("hnr_sb.txt");
}

public plugin_precache() {
	hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug started");

	if (!file_exists(g_szSBModel))
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to find model ^"%s^"; Plugin failed to load.",g_szSBModel);
		set_fail_state("[HitAndRun] Failed to find Surprise Box model.");
	}

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache model file: ^"%s^"",g_szSBModel);

	precache_model(g_szSBModel);
}

public plugin_natives() {
	register_native("is_client_onboxmenu","native_is_client_onboxmenu",0);
	register_native("client_forceboxmenu","native_client_forceboxmenu",0);
	register_native("create_surprisebox","native_create_surprisebox",0);
	register_native("remove_surprisebox","native_remove_surprisebox",0);
	register_native("purge_surpriseboxes","native_purge_surpriseboxes",0);
	register_native("get_surprisebox_count","native_get_surprisebox_count",0);
}

public native_is_client_onboxmenu(pluginid, params) {
	static client;
	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"is_client_onboxmenu^" call - data: %d; PluginID: %d",client,pluginid);

	if (!is_user_connected(client))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Client %d is invalid.",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"is_client_onboxmenu^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return false;
	}

	return g_bIsInMenu[client];
}

public native_client_forceboxmenu(pluginid, params) {
	static client;
	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"client_forceboxmenu^" call - data: %d; PluginID: %d",client,pluginid);

	if (!is_user_connected(client))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Client %d is invalid.",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"client_forceboxmenu^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return 0;
	}

	if (is_user_bot(client) || is_user_hltv(client))
		return -1;

	menu_display(client,g_iMenu);

	return 1;
}

public native_create_surprisebox(pluginid, params) {
	static Float:fOrigin[3], ent;
	get_array_f(1,fOrigin,charsmax(fOrigin));

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"create_surprisebox^" call - data: %.1f %.1f %.1f; PluginID: %d",fOrigin[0],fOrigin[1],fOrigin[2],pluginid);

	if (g_iEntCount == MAX_BOX_ENTITES)
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_warning,"Native ^"remove_surprisebox^" warning - max box entities (%d) reached; PluginID: %d",MAX_BOX_ENTITES,pluginid);
		return INVALID_HANDLE;
	}

	ent = CreateSupplyBox(fOrigin,0,true);

	if (!pev_valid(ent))
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_warning,"Native ^"remove_surprisebox^" warning - failed to create suprise box; PluginID: %d",pluginid);
		return INVALID_HANDLE;
	}

	return ent;
}

public native_remove_surprisebox(pluginid, params) {
	static entid, szClassname[32];

	entid = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"remove_surprisebox^" call - data: %d; PluginID: %d",entid,pluginid);

	if (!pev_valid(entid))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Invalid entity ID %d",entid);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"remove_surprisebox^" error - entity %d is invalid; PluginID: %d",entid,pluginid);
		return 0;
	}

	pev(entid,pev_classname,szClassname,charsmax(szClassname));

	if (!equal(szClassname,g_szSurpriseBoxClassname))
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_warning,"Native ^"remove_surprisebox^" warning - entity %d isn't a surprise box; PluginID: %d",entid,pluginid);
		return 0;
	}

	engfunc(EngFunc_RemoveEntity,entid);
	g_iEntCount--;

	return 1;
}

public native_purge_surpriseboxes(pluginid, params) {
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"purge_surpriseboxes^" call - PluginID: %d",pluginid);

	if (!g_iEntCount)
		return 0;

	PurgeBoxEntities();

	return 1;
}

public native_get_surprisebox_count(pluginid, params) {
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"get_surprisebox_count^" call - PluginID: %d",pluginid);
	return g_iEntCount;
}

public plugin_cfg() {
	new some[128];

	formatex(some,charsmax(some),"\d[ \r%L \d] \y%L",LANG_PLAYER,"MENU_PREFIX",LANG_PLAYER,"MENU_TITLE");
	g_iMenu = menu_create(some,"mHandler");

	formatex(some,charsmax(some),"%L",LANG_PLAYER,"MENU_OPT_YES");
	menu_additem(g_iMenu,some);

	formatex(some,charsmax(some),"%L",LANG_PLAYER,"MENU_OPT_NO");
	menu_additem(g_iMenu,some);

	menu_setprop(g_iMenu,MPROP_EXIT,MEXIT_NEVER);
}

public plugin_end() {
	// Prevent AMXX memory leak
	DestroyForward(g_iForwardOnAttemp);
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward ^"OnClientAttempOpenBox^" Destroyed");
	DestroyForward(g_iForwardOnTouch);
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward ^"OnClientTouchBox^" Destroyed");

	hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug ended");
}

public client_disconnected(client, bool:drop, message[], maxlen) {
	static ent;

	if (!isHNREnabled())
		return;

	while ((ent = engfunc(EngFunc_FindEntityByString,ent,"classname",g_szSurpriseBoxClassname)) > 0)
	{
		if (pev_valid(ent) && (pev(ent,pev_owner) == client))
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d disconnected; Removing surprise box ent %d",client,ent);
			engfunc(EngFunc_RemoveEntity,ent);

			g_iEntCount--;

			break;
		}
	}
}

public cmdPurgeBoxes(client,level,cid) {
	static szName[32], szAuthid[32];

	if (!cmd_access(client,level,cid,1))
		return PLUGIN_HANDLED;

	if (!g_iEntCount)
	{
		if (client)
			client_print_color(client,print_team_red,"%s %L",TAG,client,"MSG_NO_BOXES");

		return PLUGIN_HANDLED;
	}

	PurgeBoxEntities();

	if (client)
	{
		get_user_name(client,szName,charsmax(szName));
		get_user_authid(client,szAuthid,charsmax(szAuthid));

		log_amx("Cmd: ^"%s<%d><%s><>^" purged all Surprise Box entites.",szName,get_user_userid(client),szAuthid);
		client_print_color(0,print_team_red,"%s %L",TAG,LANG_PLAYER,"MSG_ADMIN_PURGE",szName);

		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Admin %d purged all suprise box entites",client);
	}

	else
	{
		log_amx("Server Cmd: Purge all Surprise Box entites.");
		client_print_color(0,print_team_default,"%s %L",TAG,LANG_PLAYER,"MSG_SERVER_PURGE");

		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Server command: Purge all suprise box entites",client);
	}

	return PLUGIN_HANDLED;
}

public fw_eventNewRound() {
	if (isHNREnabled())
		PurgeBoxEntities();
}

public fw_HamPlayerSpawnPost(client) {
	if (!is_user_alive(client))
		return;

	if (!isHNREnabled())
		return;

	if (g_bIsInMenu[client])
	{
		menu_cancel(client);
		reset_menu(client);

		g_bIsInMenu[client] = false;
	}
}

public OnHNRKilled(client,idkiller) {
	static Float:fOrigin[3];

	if (!isHNREnabled())
		return;

	if (!isClientValid(client))
		return;

	pev(client,pev_origin,fOrigin);

	CreateSupplyBox(fOrigin,client,false);
}

public fw_HamEntityTouchPost(iEnt, idother) {
	static szClassname[32], ret;

	if (!isHNREnabled())
		return;

	if (!isClientValid(idother,true) || !pev_valid(iEnt))
		return;

	pev(iEnt,pev_classname,szClassname,charsmax(szClassname));

	if (!equal(szClassname,g_szSurpriseBoxClassname))
		return;

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward ^"OnClientTouchBox^" call");
	ExecuteForward(g_iForwardOnTouch,ret,idother,iEnt);

	if (ret == PLUGIN_HANDLED)
		return;

	if (g_bIsInMenu[idother])
		return;

	engfunc(EngFunc_RemoveEntity,iEnt);
	g_iEntCount--;

	menu_cancel(idother);
	reset_menu(idother);
	menu_display(idother,g_iMenu);

	g_bIsInMenu[idother] = true;
}

public mHandler(client, menu, item) {
	static szName[32], ret;

	if (item == 0)
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward ^"OnClientAttempOpenBox^" call");
		ExecuteForward(g_iForwardOnAttemp,ret,client);

		if (ret == PLUGIN_HANDLED)
		{
			g_bIsInMenu[client] = false;
			return PLUGIN_HANDLED;
		}

		if (is_user_alive(client))
		{
			get_user_name(client,szName,charsmax(szName));

			switch(random(100))
			{
				case 0..19:	// 20% chance
				{
					client_print_color(client,print_team_default,"%s %L",TAG,client,"MSG_OPT1");
					client_print_color(0,client,"%s %L",TAG,LANG_PLAYER,"MSG_OPT1_ALL",szName);
					set_user_cash(client,(get_user_cash(client) + 20));
				}

				case 20..39: // 20% chance
				{
					client_print_color(client,print_team_default,"%s %L",TAG,client,"MSG_OPT3");
					client_print_color(0,client,"%s %L",TAG,LANG_PLAYER,"MSG_OPT3_ALL",szName);
					set_user_xp(client,(get_user_xp(client) + 10));
				}

				case 40..59: // 20% chance
				{
					client_print_color(client,print_team_default,"%s %L",TAG,client,"MSG_OPT3");
					client_print_color(0,client,"%s %L",TAG,LANG_PLAYER,"MSG_OPT3_ALL",szName);
					set_user_cash(client,(get_user_cash(client) + 5));
				}

				case 60..99: // 40% chance
				{
					client_print_color(client,print_team_default,"%s %L",TAG,client,"MSG_OPT4");
					client_print_color(0,client,"%s %L",TAG,LANG_PLAYER,"MSG_OPT4_ALL",szName);
				}
			}
		}

		else
			client_print_color(client,print_team_default,"%s %L",TAG,client,"MSG_MUST_BE_ALIVE");
	}

	else
		client_print_color(client,print_team_red,"%s %L",TAG,client,"MSG_DONT_OPEN");

	g_bIsInMenu[client] = false;

	return PLUGIN_HANDLED;
}

CreateSupplyBox(Float:origin[3], const owner, bool:isnative) {
	if (!isnative)
	{
		if (g_iEntCount == MAX_BOX_ENTITES)
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_warning,"Max box entites reached (%d). Plugin won't create new box entites until it will purge.",MAX_BOX_ENTITES);
			log_amx("Warning: Max box entites reached (%d). Plugin won't create new box entites until it will purge.",MAX_BOX_ENTITES);
			log_amx("Use amx_purgeboxes command to purge all boxes.");
			client_print_color(0,print_team_red,"%s %L",TAG,LANG_PLAYER,"MSG_WARNING",MAX_BOX_ENTITES);

			return -1;
		}
	}

	new iEnt = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"));

	if (!pev_valid(iEnt))
	{
		if (!isnative)
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Falied to create surprise box entity");
			set_fail_state("[HitAndRun] Error creating surprise box entity");
		}

		return -1;
	}

	set_pev(iEnt,pev_classname,g_szSurpriseBoxClassname);

	engfunc(EngFunc_SetOrigin,iEnt,origin);
	engfunc(EngFunc_SetModel,iEnt,g_szSBModel);

	set_pev(iEnt,pev_solid,SOLID_BBOX);

	engfunc(EngFunc_SetSize,iEnt,g_iSBEntMin,g_iSBEntMax);
	engfunc(EngFunc_DropToFloor,iEnt);

	// So we can destory it if the player disconnect
	if (owner)
		set_pev(iEnt,pev_owner,owner);

	g_iEntCount++;

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Box entity %d (%d/%d) created",iEnt,g_iEntCount,MAX_BOX_ENTITES);

	return iEnt;
}

PurgeBoxEntities() {
	new ent = -1;

	while ((ent = engfunc(EngFunc_FindEntityByString,ent,"classname",g_szSurpriseBoxClassname)) > 0)
	{
		if (pev_valid(ent))
			engfunc(EngFunc_RemoveEntity,ent);
	}

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"All surprise entities have been purged");

	g_iEntCount = 0;
}
