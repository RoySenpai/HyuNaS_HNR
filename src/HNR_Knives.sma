/*
    HNR Addon: Knives for HyuNaS HitAndRun v2.0
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
#define HNR_DBG_NAME		"HNR Knives"

new g_uKnives[MAX_PLAYERS + 1];
new g_uCurrentKnife[MAX_PLAYERS + 1];

new g_iASVModel[MAX_KNIVES];
new g_iASPModel[MAX_KNIVES];

new g_iVault;

public plugin_init() {
	register_plugin("[HNR Addon] Knives",get_hnr_version(),"HiyoriX");

	register_clcmd("say /knife","cmdShowKnivesMenu");
	register_clcmd("say /knives","cmdShowKnivesMenu");

	RegisterHam(Ham_Item_Deploy,"weapon_knife","fwd_HamItemDeployPost",1);

	g_iVault = nvault_open(g_szKnivesVault);

	if (g_iVault == INVALID_HANDLE)
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to open vault ^"%s^"; Plugin failed to load.",g_szKnivesVault);
		set_fail_state("[HitAndRun] Error opening HNR Knives vault; Plugin failed to load.");
	}

	register_dictionary("hnr_knives.txt");
}

public plugin_precache() {
	hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug started");

	for (new i; i < MAX_KNIVES; i++)
	{
		if (!file_exists(g_aKnivesList[i][KnifeVModel]))
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to find model ^"%s^"; Plugin failed to load.",g_aKnivesList[i][KnifeVModel]);
			set_fail_state("[HitAndRun] Error loading knife model!");
		}

		else if (!file_exists(g_aKnivesList[i][KnifePModel]))
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to find model ^"%s^"; Plugin failed to load.",g_aKnivesList[i][KnifePModel]);
			set_fail_state("[HitAndRun] Error loading knife model!");
		}

		else
		{
			precache_model(g_aKnivesList[i][KnifeVModel]);
			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache knife model file: ^"%s^"",g_aKnivesList[i][KnifeVModel]);

			precache_model(g_aKnivesList[i][KnifePModel]);
			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache knife model file: ^"%s^"",g_aKnivesList[i][KnifePModel]);

			g_iASVModel[i] = engfunc(EngFunc_AllocString,g_aKnivesList[i][KnifeVModel]);
			g_iASPModel[i] = engfunc(EngFunc_AllocString,g_aKnivesList[i][KnifePModel]);
		}
	}
}

public plugin_end() {
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"nVault vault ^"%s^" (%d) closed",g_szKnivesVault,g_iVault);
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

	cData = g_uCurrentKnife[client];

	set_pev(client,pev_viewmodel,g_iASVModel[cData]);
	set_pev(client,pev_weaponmodel,g_iASPModel[cData]);
}

public cmdShowKnivesMenu(client) {
	static some[512],m,cb,i,cData;

	if (!isHNREnabled())
		return;

	cData = g_uCurrentKnife[client];

	formatex(some,charsmax(some),"\d[ \r%L \d]\y %L^n\w%L \y%d^n%L %d"
		,client,"KNIVES_MENU_TITLE",client,"KNIVES_MENU_WELCOME",client,"KNIVES_MENU_URCASH",get_user_cash(client),client,"KNIVES_MENU_URLVL",get_user_level(client));
	m = menu_create(some,"mKnifeMenuHandler");
	cb = menu_makecallback("mKnifeMenuCallback");

	for (i = 0; i < MAX_KNIVES; i++)
	{
		formatex(some,charsmax(some),"%s",g_aKnivesList[i][KnifeName]);

		if (cData == i )
			format(some,charsmax(some),"%s - \y%L",some,client,"KNIVES_MENU_CURRENT");

		else if (g_uKnives[client] & (1<<i))
			format(some,charsmax(some),"%s - \y%L",some,client,"KNIVES_MENU_OWNED");

		else
		{
			if (g_aKnivesList[i][KnifeCost] > 0)
				format(some,charsmax(some),"%s \d[ \r%d \y%L \d]\w",some,g_aKnivesList[i][KnifeCost],client,"KNIVES_MENU_CASH");

			if (g_aKnivesList[i][KnifeMinLevel] > 0)
				format(some,charsmax(some),"%s \d[ \w%L \r%d \d]",some,client,"KNIVES_MENU_LEVEL",g_aKnivesList[i][KnifeMinLevel]);

			if (g_aKnivesList[i][KnifeAccessLevel] != ADMIN_ALL && g_aKnivesList[i][KnifeAccessLevel] != ADMIN_USER)
				format(some,charsmax(some),"%s \d[ \r%L \d]",some,client,"KNIVES_MENU_VIP");
		}

		menu_additem(m,some,.callback=cb);
	}

	menu_setprop(m,MPROP_PERPAGE,7);
	menu_setprop(m,MPROP_EXIT,MEXIT_FORCE);

	menu_display(client,m);
}

public mKnifeMenuCallback(client, menu, item) {
	if (!item && g_uCurrentKnife[client] != item)
		return ITEM_ENABLED;

	if (g_uCurrentKnife[client] == item)
		return ITEM_DISABLED;

	if (g_aKnivesList[item][KnifeCost] > get_user_cash(client))
		return ITEM_DISABLED;

	if (g_aKnivesList[item][KnifeMinLevel] > get_user_level(client))
		return ITEM_DISABLED;

	if (!(get_user_flags(client) & g_aKnivesList[item][KnifeAccessLevel]) && g_aKnivesList[item][KnifeAccessLevel] != ADMIN_ALL)
		return ITEM_DISABLED;

	return ITEM_ENABLED;
}

public mKnifeMenuHandler(client, menu, item) {
	if (item != MENU_EXIT && item != MENU_BACK && item != MENU_MORE)
	{
		g_uCurrentKnife[client] = item;

		if (!(g_uKnives[client] & (1<<item)) && item)
		{
			g_uKnives[client] |= (1<<item);

			if (g_aKnivesList[item][KnifeCost] > 0)
			{
				set_user_cash(client,(get_user_cash(client) - g_aKnivesList[item][KnifeCost]));
				client_print_color(client,print_team_red,"%s %L",TAG,client,"MSG_BUY_SUCCESS",g_aKnivesList[item][KnifeName],g_aKnivesList[item][KnifeCost]);
			}
		}


		if (!item)
			client_print_color(client,print_team_red,"%s %L",TAG,client,"MSG_DEF_KNIFE");

		else
			client_print_color(client,print_team_red,"%s %L",TAG,client,"MSG_CHOOSEN_KNIFE",g_aKnivesList[item][KnifeName]);

		if (get_user_weapon(client) == CSW_KNIFE)
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

		g_uCurrentKnife[client] = str_to_num(szSmallData1);
		g_uKnives[client] = str_to_num(szSmallData2);

		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Data load for authid ^"%s^" - %s",szAuthID,szData);
	}

	else
	{
		g_uCurrentKnife[client] = 0;
		g_uKnives[client] = (1<<0);

		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"No data found for authid ^"%s^"",szAuthID);
	}
}

SaveData(client) {
	static szAuthID[MAX_AUTHID_LENGTH],szData[64];

	if (!isClientValid(client,false))
		return;

	get_user_authid(client,szAuthID,charsmax(szAuthID));

	formatex(szData,charsmax(szData),"%d#%d",g_uCurrentKnife[client],g_uKnives[client]);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Data save for authid ^"%s^": %s",szAuthID,szData);

	nvault_set(g_iVault,szAuthID,szData);
}
