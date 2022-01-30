/*
    HNR Addon: Scouts for HyuNaS HitAndRun v2.0
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
#include <hamsandwich>
#include <fakemeta>
#include <hitandrun>
#include <cstrike_pdatas>
#include <nvault>

// Defines the HNR Debug message tag for this plugin.
#define HNR_DBG_NAME		"HNR Scouts"

new g_uScouts[MAX_PLAYERS + 1];
new g_uCurrentScout[MAX_LEVELS + 1];

new g_iASVModel[MAX_SCOUTS];
new g_iASPModel[MAX_SCOUTS];

new g_iVault;

public plugin_init() {
	register_plugin("[HNR Addon] Scouts",get_hnr_version(),"HiyoriX");

	register_clcmd("say /scout","cmdShowScoutsMenu");
	register_clcmd("say /scouts","cmdShowScoutsMenu");

	RegisterHam(Ham_Item_Deploy,"weapon_scout","fwd_HamItemDeployPost",1);

	g_iVault = nvault_open(g_szScoutsVault);

	if (g_iVault == INVALID_HANDLE)
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to open vault ^"%s^"; Plugin failed to load.",g_szScoutsVault);
		set_fail_state("[HitAndRun] Error opening HNR Scouts vault; Plugin failed to load.");
	}

	register_dictionary("hnr_scouts.txt");
}

public plugin_precache() {
	hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug started");

	for (new i; i < MAX_SCOUTS; i++)
	{
		if (!file_exists(g_aScoutsList[i][ScoutVModel]))
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to find model ^"%s^"; Plugin failed to load.",g_aScoutsList[i][ScoutVModel]);
			set_fail_state("[HitAndRun] Error loading scout model!");
		}

		else if (!file_exists(g_aScoutsList[i][ScoutPModel]))
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to find model ^"%s^"; Plugin failed to load.",g_aScoutsList[i][ScoutPModel]);
			set_fail_state("[HitAndRun] Error loading scout model!");
		}

		else
		{
			precache_model(g_aScoutsList[i][ScoutVModel]);
			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache scout model file: ^"%s^"",g_aScoutsList[i][ScoutVModel]);

			precache_model(g_aScoutsList[i][ScoutPModel]);
			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache scout model file: ^"%s^"",g_aScoutsList[i][ScoutPModel]);

			g_iASVModel[i] = engfunc(EngFunc_AllocString,g_aScoutsList[i][ScoutVModel]);
			g_iASPModel[i] = engfunc(EngFunc_AllocString,g_aScoutsList[i][ScoutPModel]);
		}
	}
}

public plugin_end() {
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"nVault vault ^"%s^" (%d) closed",g_szScoutsVault,g_iVault);
	nvault_close(g_iVault);

	hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug ended");
}

public client_putinserver(client) {
	LoadData(client);
}

public client_disconnected(client, bool:drop, message[], maxlen) {
	SaveData(client);
}

public fwd_HamItemDeployPost(ent) {
	static client,cData;

	if (!isHNREnabled())
		return;

	if (pev_valid(ent) != 2)
		return;

	client = get_pdata_cbase(ent,m_pPlayer,XO_CBASEPLAYERITEM);

	if (!isClientValid(client,true))
		return;

	cData = g_uCurrentScout[client];

	set_pev(client,pev_viewmodel,g_iASVModel[cData]);
	set_pev(client,pev_weaponmodel,g_iASPModel[cData]);
}

public cmdShowScoutsMenu(client) {
	static some[512],m,cb,i,cData;

	if (!isHNREnabled())
		return;

	cData = g_uCurrentScout[client];

	formatex(some,charsmax(some),"\d[ \r%L \d]\y %L^n\w%L \y%d^n%L %d"
		,client,"SCOUTS_MENU_TITLE",client,"SCOUTS_MENU_WELCOME",client,"SCOUTS_MENU_URCASH",get_user_cash(client),client,"SCOUTS_MENU_URLVL",get_user_level(client));
	m = menu_create(some,"mScoutMenuHandler");
	cb = menu_makecallback("mScoutMenuCallback");

	for (i = 0; i < MAX_SCOUTS; i++)
	{
		formatex(some,charsmax(some),"%s",g_aScoutsList[i][ScoutName]);

		if (cData == i)
			format(some,charsmax(some),"%s - \y%L",some,client,"SCOUTS_MENU_CURRENT");

		else if (g_uScouts[client] & (1<<i))
			format(some,charsmax(some),"%s - \y%L",some,client,"SCOUTS_MENU_OWNED");

		else
		{
			if (g_aScoutsList[i][ScoutCost] > 0)
				format(some,charsmax(some),"%s \d[ \r%d \y%L \d]\w",some,g_aScoutsList[i][ScoutCost],client,"SCOUTS_MENU_CASH");

			if (g_aScoutsList[i][ScoutMinLevel] > 0)
				format(some,charsmax(some),"%s \d[ \w%L \r%d \d]",some,client,"SCOUTS_MENU_LEVEL",g_aScoutsList[i][ScoutMinLevel]);

			if (g_aScoutsList[i][ScoutAccessLevel] != ADMIN_ALL && g_aScoutsList[i][ScoutAccessLevel] != ADMIN_USER)
				format(some,charsmax(some),"%s \d[ \r%L \d]",some,client,"SCOUTS_MENU_VIP");
		}

		menu_additem(m,some,.callback=cb);
	}

	menu_display(client,m);
}

public mScoutMenuCallback(client, menu, item) {
	if (!item && g_uCurrentScout[client] != item)
		return ITEM_ENABLED;

	if (g_uCurrentScout[client] == item)
		return ITEM_DISABLED;

	if (g_aScoutsList[item][ScoutCost] > get_user_cash(client))
		return ITEM_DISABLED;

	if (g_aScoutsList[item][ScoutMinLevel] > get_user_level(client))
		return ITEM_DISABLED;

	if (!(get_user_flags(client) & g_aScoutsList[item][ScoutAccessLevel]) && g_aScoutsList[item][ScoutAccessLevel] != ADMIN_ALL)
		return ITEM_DISABLED;

	return ITEM_ENABLED;
}

public mScoutMenuHandler(client, menu, item) {
	if (item != MENU_EXIT && item != MENU_BACK && item != MENU_MORE)
	{
		g_uCurrentScout[client] = item;

		if (!(g_uScouts[client] & (1<<item)) && item)
		{
			g_uScouts[client] |= (1<<item);

			if (g_aScoutsList[item][ScoutCost] > 0 && get_user_cash(client) >= g_aScoutsList[item][ScoutCost])
			{
				set_user_cash(client,(get_user_cash(client) - g_aScoutsList[item][ScoutCost]));
				client_print_color(client,print_team_red,"%s %L",TAG,client,"MSG_BUY_SUCCESS",g_aScoutsList[item][ScoutName],g_aScoutsList[item][ScoutCost]);
			}
		}


		if (!item)
			client_print_color(client,print_team_red,"%s %L",TAG,client,"MSG_DEF_SCOUT");

		else
			client_print_color(client,print_team_red,"%s %L",TAG,client,"MSG_CHOOSEN_SCOUT",g_aScoutsList[item][ScoutName]);

		if (get_user_weapon(client) == CSW_SCOUT)
		{
			set_pev(client,pev_viewmodel,g_iASVModel[item]);
			set_pev(client,pev_weaponmodel,g_iASPModel[item]);
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

LoadData(client) {
	static szAuthID[MAX_AUTHID_LENGTH],szData[64],szSmallData1[8],szSmallData2[56];

	if (!isClientValid(client,false))
		return;

	get_user_authid(client,szAuthID,charsmax(szAuthID));

	if (nvault_lookup(g_iVault,szAuthID,szData,charsmax(szData),nVaultDummy))
	{
		replace(szData,charsmax(szData),"#"," ");
		parse(szData,szSmallData1,charsmax(szSmallData1),szSmallData2,charsmax(szSmallData2));

		g_uCurrentScout[client] = str_to_num(szSmallData1);
		g_uScouts[client] = str_to_num(szSmallData2);

		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Data load for authid ^"%s^" - %s",szAuthID,szData);
	}

	else
	{
		g_uCurrentScout[client] = 0;
		g_uScouts[client] = (1<<0);

		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"No data found for authid ^"%s^"",szAuthID);
	}
}

SaveData(client) {
	static szAuthID[MAX_AUTHID_LENGTH],szData[64];

	if (!isClientValid(client,false))
		return;

	get_user_authid(client,szAuthID,charsmax(szAuthID));

	formatex(szData,charsmax(szData),"%d#%d",g_uCurrentScout[client],g_uScouts[client]);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Data save for authid ^"%s^": %s",szAuthID,szData);

	nvault_set(g_iVault,szAuthID,szData);
}
