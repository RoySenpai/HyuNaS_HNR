/*
    HNR Addon: Shop for HyuNaS HitAndRun v2.0
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
#include <cstrike>
#include <hamsandwich>
#include <fun>
#include <hitandrun>
#include <nvault>

// Defines the HNR Debug message tag for this plugin.
#define HNR_DBG_NAME		"HNR Shop"

#define TMPDATA_SIZE 7

enum _:PlayersData
{
	dLevel,
	dXP,
	dCash,
	dTotalRounds,
	dTotalWins
}

enum _:eCvars
{
	cWinXp,
	cWinCash,
	cLHXPBonus,
	cLHCashBonus
}

new const g_dCvars[eCvars][eCvarsData] = {
	{ "hnr_winxp", "10", "Amount of XP get for winning a round" },
	{ "hnr_wincash", "20", "Amount of Cash get for winning a round" },
	{ "hnr_bonusxp", "1", "Amount of XP get for being the last guy to pass the infection" },
	{ "hnr_bonuscash", "2", "Amount of Cash get for being the last guy to pass the infection" }
};

new g_iCvars[eCvars];

new g_PlayersData[MAX_PLAYERS + 1][PlayersData];
new g_iVault;

new g_szHelpMOTD[MAX_MOTD_LENGTH];

public plugin_init() {
	register_plugin("[HNR Addon] Shop",get_hnr_version(),"HiyoriX");

	for (new i = 0; i < eCvars; i++)
		g_iCvars[i] = create_cvar(g_dCvars[i][cName],g_dCvars[i][cDefValue],(FCVAR_SERVER | FCVAR_PRINTABLEONLY),g_dCvars[i][cDescription],true,1.0,false);

	register_clcmd("say","ActionSayHandler");
	register_clcmd("say_team","ActionSayHandler");

	register_clcmd("say /hnrhelp","cmdHNRHelpMOTD");

	register_clcmd("jointeam","ActionShop");
	register_clcmd("chooseteam","ActionShop");
	register_clcmd("radio1","ActionShop");
	register_clcmd("radio2","ActionShop");
	register_clcmd("radio3","ActionShop");

	register_concmd("amx_addcash","cmdAddCash",ADMIN_BAN,"<name> <amount> - Adds amount of cash to specific player.");
	register_concmd("amx_removecash","cmdRemoveCash",ADMIN_BAN,"<name> <amount> - Removes amount of cash from specific player.");
	register_concmd("amx_setlevel","cmdSetLevel",ADMIN_BAN,"<name> <level> - Sets player's level to <level>.");

	g_iVault = nvault_open(g_szShopVault);

	if (g_iVault == INVALID_HANDLE)
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to open vault ^"%s^"; Plugin failed to load.",g_szShopVault);
		set_fail_state("[HitAndRun] Error opening HNR shop vault; Plugin failed to load.");
	}

	register_dictionary("hnr_shop.txt");
}

public plugin_precache() {
	hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug started");
}

public plugin_cfg() {
	add(g_szHelpMOTD,charsmax(g_szHelpMOTD),"<html><body bgcolor=^"000000^"><font color=^"#FFFFFF^"><center>");
	format(g_szHelpMOTD,charsmax(g_szHelpMOTD),"%s <h1>HyuNaS HitAndRun %s By HiyoriX aka Hyuna (Roy)</h1><br /></center>",g_szHelpMOTD,get_hnr_version());
	add(g_szHelpMOTD,charsmax(g_szHelpMOTD),"<h3>Chat Commands:</h3>");
	add(g_szHelpMOTD,charsmax(g_szHelpMOTD),"<ul><li>/hnrhelp - Shows this help motd.</li><li>/stats or /xp or /level or /rounds or /wins - Shows the rounds that played, total rounds played, wins and total wins. Supporting to see other players stats.</li>");
	add(g_szHelpMOTD,charsmax(g_szHelpMOTD),"<li>/next - Shows how much xp do you need to collect to level up.</li><li>/send or /give or /transfer - Sends to client cash.</li><li>/gamble - Gambles the cash.</li><li>/event or /events - Shows infomation about Events (if it's running, how much rounds left until the event will start etc.)</li>");
	add(g_szHelpMOTD,charsmax(g_szHelpMOTD),"<li>/knife or /knives - Opens up the knives skins menu.</li><li>/scout or /scouts - Opens up the scouts skins menu.</li><li>/alliance or /brit - Opens up the alliance menu.</li></ul>");
	add(g_szHelpMOTD,charsmax(g_szHelpMOTD),"<br /><h3>Rules:</h3>");
	add(g_szHelpMOTD,charsmax(g_szHelpMOTD),"<ul><li>Don't Cheat! You'll be banned from the server!</li><li>Don't retry! An retry while the game is running will make you lose that round!</li><li>Don't flood with gamble!</li><li>Play fair!</li>");
	add(g_szHelpMOTD,charsmax(g_szHelpMOTD),"<li>And the most important: Enjoy!</li></ul>");
	add(g_szHelpMOTD,charsmax(g_szHelpMOTD),"</font></body></html>");
}

public plugin_end() {
   	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"nVault vault ^"%s^" (%d) closed",g_szShopVault,g_iVault);
	nvault_close(g_iVault);

	hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug ended");
}

public plugin_natives() {
	register_native("get_user_cash","_get_user_cash",0);
	register_native("get_user_rounds","_get_user_rounds",0);
	register_native("get_user_wins","_get_user_wins",0);
	register_native("get_user_xp","_get_user_xp",0);
	register_native("get_user_level","_get_user_level",0);

	register_native("set_user_cash","_set_user_cash",0);
	register_native("set_user_rounds","_set_user_rounds",0);
	register_native("set_user_wins","_set_user_wins",0);
	register_native("set_user_xp","_set_user_xp",0);
	register_native("set_user_level","_set_user_level",0);
}

public _get_user_cash(pluginid, params) {
	static client;
	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"get_user_cash^" call - data: %d; PluginID: %d",client,pluginid);

	if (!isClientValid(client,false))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"get_user_cash^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return 0;
	}

	return g_PlayersData[client][dCash];
}

public _get_user_rounds(pluginid, params) {
	static client;
	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"get_user_rounds^" call - data: %d; PluginID: %d",client,pluginid);

	if (!isClientValid(client,false))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"get_user_rounds^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return 0;
	}

	return g_PlayersData[client][dTotalRounds];
}

public _get_user_wins(pluginid, params) {
	static client;
	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"get_user_wins^" call - data: %d; PluginID: %d",client,pluginid);

	if (!isClientValid(client,false))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"get_user_wins^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return 0;
	}

	return g_PlayersData[client][dTotalWins];
}

public _get_user_xp(pluginid, params) {
	static client;
	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"get_user_xp^" call - data: %d; PluginID: %d",client,pluginid);

	if (!isClientValid(client,false))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"get_user_xp^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return 0;
	}

	return g_PlayersData[client][dXP];
}

public _get_user_level(pluginid, params) {
	static client;
	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"get_user_level^" call - data: %d; PluginID: %d",client,pluginid);

	if (!isClientValid(client,false))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"get_user_level^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return 0;
	}

	return g_PlayersData[client][dLevel];
}

public _set_user_cash(pluginid, params) {
	static client;
	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"set_user_cash^" call - data: %d %d; PluginID: %d",client,get_param(2),pluginid);

	if (!isClientValid(client,false))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"set_user_cash^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return 0;
	}

	g_PlayersData[client][dCash] = clamp(get_param(2),0,MAX_CASH);

	SaveData(client);

	return 1;
}

public _set_user_rounds(pluginid, params) {
	static client;
	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"set_user_rounds^" call - data: %d %d; PluginID: %d",client,get_param(2),pluginid);

	if (!isClientValid(client,false))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"set_user_rounds^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return 0;
	}

	g_PlayersData[client][dTotalRounds] = clamp(get_param(2),0,MAX_ROUNDS);

	SaveData(client);

	return 1;
}

public _set_user_wins(pluginid, params) {
	static client;
	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"set_user_wins^" call - data: %d %d; PluginID: %d",client,get_param(2),pluginid);

	if (!isClientValid(client,false))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"st_user_wins^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return 0;
	}

	g_PlayersData[client][dTotalWins] = clamp(get_param(2),0,MAX_ROUNDS);

	SaveData(client);

	return 1;
}

public _set_user_xp(pluginid, params) {
	static client;
	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"set_user_xp^" call - data: %d %d; PluginID: %d",client,get_param(2),pluginid);

	if (!isClientValid(client,false))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"set_user_xp^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return 0;
	}

	g_PlayersData[client][dXP] = clamp(get_param(2),0,MAX_CASH);

	CheckPlayerLevel(client);

	return 1;
}

public _set_user_level(pluginid, params) {
	static client;
	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"set_user_level^" call - data: %d %d; PluginID: %d",client,get_param(2),pluginid);

	if (!isClientValid(client,false))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"set_user_level^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return 0;
	}

	g_PlayersData[client][dLevel] = clamp(get_param(2),0,MAX_LEVELS);
	g_PlayersData[client][dXP] = (g_iXP[g_PlayersData[client][dLevel]] - 1);

	SaveData(client);

	return 1;
}

public client_putinserver(client) {
	LoadData(client);
}

public client_disconnected(client) {
	SaveData(client);
}

public OnHNRWinner(client) {
	static players[32],pnum,i,xp,cash;

	xp = get_pcvar_num(g_iCvars[cWinXp]);
	cash = get_pcvar_num(g_iCvars[cWinCash]);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d won and got %d xp and %d cash",client,xp,cash);
	client_print_color(client,print_team_red,"%s %L",TAG,client,"PRIZE_WINNER",xp,cash);

	g_PlayersData[client][dXP] += xp;
	g_PlayersData[client][dCash] += cash;

	g_PlayersData[client][dTotalWins]++;

	get_players(players,pnum,"ceh","TERRORIST");

	for (i = 0; i < pnum; i++)
		g_PlayersData[players[i]][dTotalRounds]++;

	CheckPlayerLevel(client);
}

public OnHNRKilled(client, idkiller) {
	static xp, cash;

	if (!isClientValid(idkiller,true))
		return;

	xp = get_pcvar_num(g_iCvars[cLHXPBonus]);
	cash = get_pcvar_num(g_iCvars[cLHCashBonus]);

	if (get_humans_count() > 1)
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d got %d xp and %d cash bonus for being the last guy pass infection to %d.",idkiller,xp,cash,client);
		client_print_color(idkiller,print_team_red,"%s %L",TAG,idkiller,"PRIZE_KILL",xp,cash);

		g_PlayersData[idkiller][dXP] += xp;
		g_PlayersData[idkiller][dCash] += cash;
	}
}

public cmdAddCash(client, level, cid) {
	static szName1[MAX_NAME_LENGTH],szName2[MAX_NAME_LENGTH],
	szAuthID1[MAX_NAME_LENGTH],szAuthID2[MAX_NAME_LENGTH],
	szArg1[MAX_NAME_LENGTH],szArg2[16],plr,iCash;

	if (get_hnr_status() == GameDisabled)
		return PLUGIN_CONTINUE;

	if (!cmd_access(client,level,cid,3,false))
		return PLUGIN_HANDLED;

	read_argv(1,szArg1,charsmax(szArg1));
	plr = cmd_target(client,szArg1,(CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS));

	if (!plr)
		return PLUGIN_HANDLED;

	read_argv(2,szArg2,charsmax(szArg2));

	if (!is_str_num(szArg2))
	{
		console_print(client,"%L",client,"ONLY_NUMBERS_CONSOLE");
		return PLUGIN_HANDLED;
	}

	iCash = str_to_num(szArg2);

	g_PlayersData[plr][dCash] = clamp((g_PlayersData[plr][dCash] + iCash),0,MAX_CASH);

	get_user_name(client,szName1,charsmax(szName1));
	get_user_authid(client,szAuthID1,charsmax(szAuthID1));

	get_user_name(plr,szName2,charsmax(szName2));
	get_user_authid(plr,szAuthID2,charsmax(szAuthID2));

	log_amx("Cmd: %s (%s) added %d cash to %s (%s)",szName1,szAuthID1,iCash,szName2,szAuthID2);

	show_activity_key("ACTIVITY_ADD_CASH_NO_NAME","ACTIVITY_ADD_CASH_NAME",szName1,iCash,szName2);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Admin %d added %d cash to player %d",client,iCash,plr);

	SaveData(plr);

	return PLUGIN_HANDLED;
}

public cmdRemoveCash(client, level, cid) {
	static szName1[MAX_NAME_LENGTH],szName2[MAX_NAME_LENGTH],
	szAuthID1[MAX_NAME_LENGTH],szAuthID2[MAX_NAME_LENGTH],
	szArg1[MAX_NAME_LENGTH],szArg2[16],plr,iCash;

	if (get_hnr_status() == GameDisabled)
		return PLUGIN_CONTINUE;

	if (!cmd_access(client,level,cid,3,false))
		return PLUGIN_HANDLED;

	read_argv(1,szArg1,charsmax(szArg1));
	plr = cmd_target(client,szArg1,(CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS));

	if (!plr)
		return PLUGIN_HANDLED;

	read_argv(2,szArg2,charsmax(szArg2));

	if (!is_str_num(szArg2))
	{
		console_print(client,"%L",client,"ONLY_NUMBERS_CONSOLE");
		return PLUGIN_HANDLED;
	}

	iCash = str_to_num(szArg2);

	g_PlayersData[plr][dCash] = clamp((g_PlayersData[plr][dCash] - iCash),0,MAX_CASH);

	get_user_name(client,szName1,charsmax(szName1));
	get_user_authid(client,szAuthID1,charsmax(szAuthID1));

	get_user_name(plr,szName2,charsmax(szName2));
	get_user_authid(plr,szAuthID2,charsmax(szAuthID2));

	log_amx("Cmd: %s (%s) removed %d cash from %s (%s)",szName1,szAuthID1,iCash,szName2,szAuthID2);

	show_activity_key("ACTIVITY_REMOVE_CASH_NO_NAME","ACTIVITY_REMOVE_CASH_NAME",szName1,iCash,szName2);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Admin %d removed %d cash from player %d",client,iCash,plr);

	SaveData(plr);

	return PLUGIN_HANDLED;
}

public cmdSetLevel(client, level, cid) {
	static szName1[MAX_NAME_LENGTH],szName2[MAX_NAME_LENGTH],
	szAuthID1[MAX_NAME_LENGTH],szAuthID2[MAX_NAME_LENGTH],
	szArg1[MAX_NAME_LENGTH],szArg2[16],plr,iLevel;

	if (get_hnr_status() == GameDisabled)
		return PLUGIN_CONTINUE;

	if (!cmd_access(client,level,cid,3,false))
		return PLUGIN_HANDLED;

	read_argv(1,szArg1,charsmax(szArg1));
	plr = cmd_target(client,szArg1,(CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS));

	if (!plr)
		return PLUGIN_HANDLED;

	read_argv(2,szArg2,charsmax(szArg2));

	if (!is_str_num(szArg2))
	{
		console_print(client,"%L",client,"ONLY_NUMBERS_CONSOLE");
		return PLUGIN_HANDLED;
	}

	iLevel = str_to_num(szArg2);

	g_PlayersData[plr][dLevel] = clamp(iLevel,0,MAX_LEVELS);
	g_PlayersData[plr][dXP] = g_iXP[g_PlayersData[plr][dLevel] - 1];

	get_user_name(client,szName1,charsmax(szName1));
	get_user_authid(client,szAuthID1,charsmax(szAuthID1));

	get_user_name(plr,szName2,charsmax(szName2));
	get_user_authid(plr,szAuthID2,charsmax(szAuthID2));

	log_amx("Cmd: %s (%s) set player's %s (%s) level to %d",szName1,szAuthID1,szName2,szAuthID2,iLevel);

	show_activity_key("ACTIVITY_SET_LEVEL_NO_NAME","ACTIVITY_SET_LEVEL_NAME",szName1,iLevel,szName2);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Admin %d set player's %d level to %d",client,plr,iLevel);

	SaveData(plr);

	return PLUGIN_HANDLED;
}

public ActionSayHandler(client) {
	static szMsg[32];

	if (get_hnr_status() == GameDisabled)
		return PLUGIN_CONTINUE;

	new szArg1[8],szArg2[8],szArg3[8];

	read_argv(1,szMsg,charsmax(szMsg));

	parse(szMsg,szArg1,charsmax(szArg1),szArg2,charsmax(szArg2),szArg3,charsmax(szArg3));

	if (equal(szArg1,"/stats") || equal(szArg1,"/xp") || equal(szArg1,"/level") || equal(szArg1,"/rounds") || equal(szArg1,"/wins"))
		return ActionShowPlayerStatics(client,szArg2);

	else if (equal(szArg1,"/transfer") || equal(szArg1,"/send") || equal(szArg1,"/give"))
		return ActionTransfer(client,szArg2,szArg3);

	else if (equal(szArg1,"/gamble"))
		return ActionGamble(client,szArg2);

	else if (equal(szArg1,"/next"))
		return ActionNextLevel(client);

	return PLUGIN_CONTINUE;
}

public ActionShowPlayerStatics(client, plrname[]) {
	static szName[MAX_NAME_LENGTH],plr;

	if (!plrname[0])
	{
		client_print_color(client,print_team_red,"%s %L",TAG,client,"MSG_STATS1_SELF");
		client_print_color(client,print_team_red,"^3 %L",client,"MSG_STATS2",g_PlayersData[client][dLevel],g_PlayersData[client][dXP],g_PlayersData[client][dCash]);
		client_print_color(client,print_team_red,"^3 %L",client,"MSG_STATS3",g_PlayersData[client][dTotalRounds],g_PlayersData[client][dTotalWins]);

		if (g_PlayersData[client][dTotalRounds] > 0)
			client_print_color(client,print_team_red,"^3 %L",client,"MSG_STATS4_WINS",((g_PlayersData[client][dTotalWins] * 100.0) / g_PlayersData[client][dTotalRounds]));

		else
			client_print_color(client,print_team_red,"^3 %L",client,"MSG_STATS4_NO_WINS");
	}

	else
	{
		plr = cmd_target(client,plrname,(CMDTARGET_NO_BOTS));

		if (!is_user_connected(plr))
			client_print_color(client,print_team_red,"%s %L",TAG,client,"PLAYER_NOT_FOUND_CHAT",plrname);

		else
		{
			get_user_name(plr,szName,charsmax(szName));

			client_print_color(client,print_team_red,"%s %L",TAG,client,"MSG_STATS1",szName);
			client_print_color(client,print_team_red,"^3 %L",client,"MSG_STATS2",g_PlayersData[plr][dLevel],g_PlayersData[plr][dXP],g_PlayersData[plr][dCash]);
			client_print_color(client,print_team_red,"^3 %L",client,"MSG_STATS3",g_PlayersData[plr][dTotalRounds],g_PlayersData[plr][dTotalWins]);

			if (g_PlayersData[plr][dTotalRounds] > 0)
				client_print_color(client,print_team_red,"^3 %L",client,"MSG_STATS4_WINS",((g_PlayersData[plr][dTotalWins] * 100) / g_PlayersData[plr][dTotalRounds]));

			else
				client_print_color(client,print_team_red,"^3 %L",client,"MSG_STATS4_NO_WINS");
		}
	}

	return PLUGIN_HANDLED;
}

public ActionTransfer(client, plrname[], cashamount[]) {
	static szName[MAX_NAME_LENGTH],plr,iCash;

	if (!plrname[0])
		client_print_color(client,print_team_red,"%s %L",TAG,client,"SEND_SYNTAX");

	else
	{
		plr = cmd_target(client,plrname,(CMDTARGET_NO_BOTS));

		if (!is_user_connected(plr))
		{
			client_print_color(client,print_team_red,"%s %L",TAG,client,"PLAYER_NOT_FOUND_CHAT",plrname);
			return PLUGIN_HANDLED;
		}

		if (client == plr)
		{
			client_print_color(client,print_team_red,"%s%L",TAG,client,"SEND_SELF_NOT_ALLOWED");
			return PLUGIN_HANDLED;
		}

		if (!is_str_num(cashamount))
		{
			client_print_color(client,print_team_red,"%s %L",TAG,client,"ONLY_NUMBERS_CHAT");
			return PLUGIN_HANDLED;
		}

		iCash = str_to_num(cashamount);

		if (iCash < 1)
			client_print_color(client,print_team_red,"%s %L",TAG,client,"SEND_MIN_CASH");

		else if (g_PlayersData[client][dCash] < iCash)
			client_print_color(client,print_team_red,"%s %L%L",TAG,client,"NOT_ENOUGHT_CASH");

		else
		{
			g_PlayersData[client][dCash]-=iCash;
			g_PlayersData[plr][dCash]+=iCash;

			get_user_name(client,szName,charsmax(szName));
			client_print_color(plr,print_team_red,"%s %L",TAG,plr,"SEND_RECEIVER_MSG",iCash,szName);

			get_user_name(plr,szName,charsmax(szName));
			client_print_color(client,print_team_red,"%s %L",TAG,client,"SEND_SENDER_MSG",iCash,szName);

			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d send %d cash to player %d",client,iCash,plr);

			SaveData(client);
			SaveData(plr);
		}
	}

	return PLUGIN_HANDLED;
}

public ActionGamble(client, cashamount[]) {
	static szName[MAX_NAME_LENGTH],iCash;

	if (!is_str_num(cashamount))
	{
		client_print_color(client,print_team_red,"%s %L",TAG,client,"ONLY_NUMBERS_CHAT");
		return PLUGIN_HANDLED;
	}

	iCash = str_to_num(cashamount);

	if (iCash < MIN_GAMBLE_CASH)
	{
		client_print_color(client,print_team_red,"%s %L",TAG,client,"GAMBLE_MIN_CASH",MIN_GAMBLE_CASH);
		return PLUGIN_HANDLED;
	}

	else if (g_PlayersData[client][dCash] < iCash)
	{
		client_print_color(client,print_team_red,"%s %L",TAG,client,"NOT_ENOUGHT_CASH");
		return PLUGIN_HANDLED;
	}

	get_user_name(client,szName,charsmax(szName));

	switch(random(10))
	{
		case 0..2:
		{
			g_PlayersData[client][dCash]+=iCash;
			client_print_color(client,print_team_red,"%s %L",TAG,client,"GAMBLE_WON",iCash);
			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d gambled %d cash and won.",client,iCash);
		}

		case 3..9:
		{
			g_PlayersData[client][dCash]-=iCash;
			client_print_color(client,print_team_red,"%s %L",TAG,client,"GAMBLE_LOST",iCash);
			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d gambled %d cash and lost.",client,iCash);
		}
	}

	SaveData(client);

	return PLUGIN_HANDLED;
}

public ActionNextLevel(client) {
	if (g_PlayersData[client][dLevel] == MAX_LEVELS)
		client_print_color(client,print_team_red,"%s %L",TAG,client,"MSG_LEVEL_MAXED");

	else
		client_print_color(client,print_team_red,"%s %L",TAG,client,"MSG_NEXTLEVEL",(g_iXP[g_PlayersData[client][dLevel]] - g_PlayersData[client][dXP]));

	return PLUGIN_HANDLED;
}

///////////////////
/// Actual Shop ///
///////////////////
public ActionShop(client) {
	static some[128],cb,cb2,iMenu;

	if (get_hnr_status() == GameDisabled)
		return PLUGIN_CONTINUE;

	formatex(some,charsmax(some),"\d[ \r%L \d]\y %L^n\w%L \y%d",client,"MENU_PREFIX",client,"MENU_WELCOME",client,"MENU_SHOWCASH",g_PlayersData[client][dCash]);
	iMenu = menu_create(some,"shopHandler");
	cb = menu_makecallback("shopCallback");

	formatex(some,charsmax(some),"%L",client,"MENU_PRIMEWEPS");
	menu_additem(iMenu,some,.callback=cb);

	formatex(some,charsmax(some),"%L",client,"MENU_SECWEPS");
	menu_additem(iMenu,some,.callback=cb);

	formatex(some,charsmax(some),"%L",client,"MENU_GRENADES");
	menu_additem(iMenu,some,.callback=cb);

	formatex(some,charsmax(some),"%L",client,"MENU_AP");
	menu_additem(iMenu,some,.callback=cb);

	menu_addblank(iMenu,0);

	formatex(some,charsmax(some),"%L",client,"MENU_VIEWSTATS");
	menu_additem(iMenu,some);

	menu_addblank(iMenu,0);

	formatex(some,charsmax(some),"%L",client,"MENU_SCOUTS_SKINS");
	menu_additem(iMenu,some);

	formatex(some,charsmax(some),"%L",client,"MENU_KNIVES_SKINS");
	menu_additem(iMenu,some);

	menu_addblank(iMenu,0);

	formatex(some,charsmax(some),"%L",client,"MENU_EVENTS");
	menu_additem(iMenu,some);

	menu_addblank(iMenu,0);

	formatex(some,charsmax(some),"%L",client,"MENU_HELP");
	menu_additem(iMenu,some);

	menu_setprop(iMenu,MPROP_PERPAGE,0);
	menu_setprop(iMenu,MPROP_EXIT,MEXIT_FORCE);

	menu_display(client,iMenu);

	return PLUGIN_HANDLED;
}

public shopCallback(client, menu, item) {
	return ((isClientValid(client,true) && (get_hnr_status() != GameEnding)) ? ITEM_ENABLED:ITEM_DISABLED);
}

public shopHandler(client, menu, item) {
	switch(item)
	{
		case cPrimeWeapons: 	ActionPrimeWeaponsMenu(client);
		case cSecWeapons: 	ActionSecWeapons(client);
		case cGrenades: 	ActionGrenadesMenu(client);
		case cAmmo: 		ActionAmmoPacksMenu(client);
		case cStats:		ActionViewStats(client);
		case cScoutsM:		amxclient_cmd(client,"say","/scout");
		case cKnivesM:		amxclient_cmd(client,"say","/knife");
		case cEvents:		amxclient_cmd(client,"say","/event");
		case cHelpM:
		{
			cmdHNRHelpMOTD(client);
			menu_destroy(menu);
			return ActionShop(client);
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public ActionPrimeWeaponsMenu(client) {
	static some[128],cb,iMenu,i;

	formatex(some,charsmax(some),"\d[ \r%L \d]\y %L^n\w%L \y%d",client,"MENU_PREFIX",client,"MENU_PRIMEWEPS",client,"MENU_SHOWCASH",g_PlayersData[client][dCash]);
	iMenu = menu_create(some,"PrimeShopHandler");
	cb = menu_makecallback("cbPrimeWeapons");

	for (i = 0; i < MAX_PRIMEWEAPONS; i++)
	{
		if (user_has_weapon(client,g_aPrimeWeaponList[i][WepCSW]))
			formatex(some,charsmax(some),"\y%s [ %L ]",g_aPrimeWeaponList[i][WepName],client,"MENU_ITEM_OWNED");

		else if (!g_aPrimeWeaponList[i][WepCost])
			formatex(some,charsmax(some),"\y%s [ %L ]",g_aPrimeWeaponList[i][WepName],client,"MENU_ITEM_FREE");

		else
			formatex(some,charsmax(some),"\y%s [ %L ]",g_aPrimeWeaponList[i][WepName],client,"MENU_ITEM_COST",g_aPrimeWeaponList[i][WepCost]);

		menu_additem(iMenu,some,.callback=cb);
	}

	menu_setprop(iMenu,MPROP_EXITNAME,"Back");
	menu_display(client,iMenu);

	return PLUGIN_HANDLED;
}

public cbPrimeWeapons(client, menu, item) {
	return ((g_aPrimeWeaponList[item][WepCost] > g_PlayersData[client][dCash]) ||
		(get_hnr_status() != GameRunning) ||
		user_has_weapon(client,g_aPrimeWeaponList[item][WepCSW] || !is_user_alive(client))
		? ITEM_DISABLED:ITEM_ENABLED);
}

public PrimeShopHandler(client, menu, item) {
	static tmp;

	if ((item != MENU_EXIT) && (item != MENU_BACK) && (item != MENU_MORE))
	{
		if (!user_has_weapon(client,g_aPrimeWeaponList[item][WepCSW]))
		{
			if (g_aPrimeWeaponList[item][WepCost] <= g_PlayersData[client][dCash])
			{
				g_PlayersData[client][dCash]-=g_aPrimeWeaponList[item][WepCost];

				tmp = give_item(client,g_aPrimeWeaponList[item][WepClass]);
				cs_set_weapon_ammo(tmp,g_aPrimeWeaponList[item][WepBullets]);
				cs_set_user_bpammo(client,g_aPrimeWeaponList[item][WepCSW],0);

				client_print_color(client,print_team_red,"%s %L",TAG,client,"SHOP_BUY_SUCCESS",g_aPrimeWeaponList[item][WepName],g_aPrimeWeaponList[item][WepCost]);

				SaveData(client);
			}

			else
				client_print_color(client,print_team_red,"%s %L",TAG,client,"SHOP_NOT_ENOUGHT_CASH");
		}

		else
			client_print_color(client,print_team_default,"%s %L",TAG,client,"SHOP_BUY_ALREADY_OWNED");
	}

	menu_destroy(menu);

	return (item == MENU_EXIT ? ActionShop(client):PLUGIN_HANDLED);
}

public ActionSecWeapons(client) {
	static some[128],cb,iMenu,i;

	formatex(some,charsmax(some),"\d[ \r%L \d]\y %L^n\w%L \y%d",client,"MENU_PREFIX",client,"MENU_SECWEPS",client,"MENU_SHOWCASH",g_PlayersData[client][dCash]);
	iMenu = menu_create(some,"SecShopHandler");
	cb = menu_makecallback("cbSecWeapons");

	for (i = 0; i < MAX_SECWEAPONS; i++)
	{
		if (user_has_weapon(client,g_aSecWeaponList[i][WepCSW]))
			formatex(some,charsmax(some),"\y%s [ %L ]",g_aSecWeaponList[i][WepName],client,"MENU_ITEM_OWNED");

		else if (!g_aSecWeaponList[i][WepCost])
			formatex(some,charsmax(some),"\y%s [ %L ]",g_aSecWeaponList[i][WepName],client,"MENU_ITEM_FREE");

		else
			formatex(some,charsmax(some),"\y%s [ %L ]",g_aSecWeaponList[i][WepName],client,"MENU_ITEM_COST",g_aSecWeaponList[i][WepCost]);

		menu_additem(iMenu,some,.callback=cb);
	}

	menu_setprop(iMenu,MPROP_EXITNAME,"Back");
	menu_display(client,iMenu);

	return PLUGIN_HANDLED;
}

public cbSecWeapons(client, menu, item) {
		return ((g_aSecWeaponList[item][WepCost] > g_PlayersData[client][dCash]) ||
		(get_hnr_status() != GameRunning) ||
		user_has_weapon(client,g_aSecWeaponList[item][WepCSW] || !is_user_alive(client))
		? ITEM_DISABLED:ITEM_ENABLED);
}

public SecShopHandler(client, menu, item) {
	static tmp;

	if ((item != MENU_EXIT) && (item != MENU_BACK) && (item != MENU_MORE))
	{
		if (!user_has_weapon(client,g_aSecWeaponList[item][WepCSW]))
		{
			if (g_aSecWeaponList[item][WepCost] <= g_PlayersData[client][dCash])
			{
				g_PlayersData[client][dCash]-=g_aSecWeaponList[item][WepCost];

				tmp = give_item(client,g_aSecWeaponList[item][WepClass]);
				cs_set_weapon_ammo(tmp,g_aSecWeaponList[item][WepBullets]);
				cs_set_user_bpammo(client,g_aSecWeaponList[item][WepCSW],0);

				client_print_color(client,print_team_red,"%s %L",TAG,client,"SHOP_BUY_SUCCESS",g_aSecWeaponList[item][WepName],g_aSecWeaponList[item][WepCost]);

				SaveData(client);
			}

			else
				client_print_color(client,print_team_red,"%s %L",TAG,client,"SHOP_NOT_ENOUGHT_CASH");
		}

		else
			client_print_color(client,print_team_default,"%s %L",TAG,client,"SHOP_BUY_ALREADY_OWNED");
	}

	menu_destroy(menu);

	return (item == MENU_EXIT ? ActionShop(client):PLUGIN_HANDLED);
}

public ActionGrenadesMenu(client) {
	static some[128],cb,iMenu,i;

	formatex(some,charsmax(some),"\d[ \r%L \d]\y %L^n\w%L \y%d",client,"MENU_PREFIX",client,"MENU_GRENADES",client,"MENU_SHOWCASH",g_PlayersData[client][dCash]);
	iMenu = menu_create(some,"GrenadesShopHandler");
	cb = menu_makecallback("cbGrenadesWeapons");

	for (i = 0; i < MAX_GRENADES; i++)
	{
		if (user_has_weapon(client,g_aGrenadesList[i][GreCSW]))
			formatex(some,charsmax(some),"\y%s [ %L ]",g_aGrenadesList[i][GreName],client,"MENU_ITEM_OWNED");

		else if (!g_aGrenadesList[i][WepCost])
			formatex(some,charsmax(some),"\y%s [ %L ]",g_aGrenadesList[i][GreName],client,"MENU_ITEM_FREE");

		else
			formatex(some,charsmax(some),"\y%s [ %L ]",g_aGrenadesList[i][GreName],client,"MENU_ITEM_COST",g_aGrenadesList[i][GreCost]);

		menu_additem(iMenu,some,.callback=cb);
	}

	menu_setprop(iMenu,MPROP_EXITNAME,"Back");
	menu_display(client,iMenu);

	return PLUGIN_HANDLED;
}

public cbGrenadesWeapons(client, menu, item) {
		return ((g_aGrenadesList[item][GreCost] > g_PlayersData[client][dCash]) ||
		(get_hnr_status() != GameRunning) ||
		user_has_weapon(client,g_aGrenadesList[item][GreCSW] || !is_user_alive(client))
		? ITEM_DISABLED:ITEM_ENABLED);
}

public GrenadesShopHandler(client, menu, item) {
	if ((item != MENU_EXIT) && (item != MENU_BACK) && (item != MENU_MORE))
	{
		if (!user_has_weapon(client,g_aGrenadesList[item][GreCSW]))
		{
			if (g_aGrenadesList[item][GreCost] <= g_PlayersData[client][dCash])
			{
				g_PlayersData[client][dCash]-=g_aGrenadesList[item][GreCost];

				give_item(client,g_aGrenadesList[item][GreClass]);

				client_print_color(client,print_team_red,"%s %L",TAG,client,"SHOP_BUY_SUCCESS",g_aGrenadesList[item][GreName],g_aGrenadesList[item][GreCost]);

				SaveData(client);
			}

			else
				client_print_color(client,print_team_red,"%s %L",TAG,client,"SHOP_NOT_ENOUGHT_CASH");
		}

		else
			client_print_color(client,print_team_default,"%s %L",TAG,client,"SHOP_BUY_ALREADY_OWNED");
	}

	menu_destroy(menu);

	return (item == MENU_EXIT ? ActionShop(client):PLUGIN_HANDLED);
}

public ActionAmmoPacksMenu(client) {
	static some[128],cb,iMenu,i;

	formatex(some,charsmax(some),"\d[ \r%L \d]\y %L^n\w%L \y%d",client,"MENU_PREFIX",client,"MENU_AP",client,"MENU_SHOWCASH",g_PlayersData[client][dCash]);
	iMenu = menu_create(some,"AmmoPacksShopHandler");
	cb = menu_makecallback("cbAmmoPacks");

	for (i = 0; i < MAX_AMMOPACKS; i++)
	{
		if (!user_has_weapon(client,CSW_SCOUT))
			formatex(some,charsmax(some),"\y%d %L [ %L ]",g_AmmoPacksList[i][AmmoAmount],client,"MENU_ITEM_BULLETS",client,"MENU_ITEM_NEED_SCOUT");

		else if (!g_aGrenadesList[i][WepCost])
			formatex(some,charsmax(some),"\y%d %L [ %L ]",g_AmmoPacksList[i][AmmoAmount],client,"MENU_ITEM_BULLETS",client,"MENU_ITEM_FREE");

		else
			formatex(some,charsmax(some),"\y%d %L [ %L ]",g_AmmoPacksList[i][AmmoAmount],client,"MENU_ITEM_BULLETS",client,"MENU_ITEM_COST",g_AmmoPacksList[i][AmmoCost]);

		menu_additem(iMenu,some,.callback=cb);
	}

	menu_setprop(iMenu,MPROP_EXITNAME,"Back");
	menu_display(client,iMenu);

	return PLUGIN_HANDLED;
}

public cbAmmoPacks(client, menu, item) {
		return ((g_AmmoPacksList[item][AmmoCost] > g_PlayersData[client][dCash]) ||
		(get_hnr_status() != GameRunning) ||
		(!user_has_weapon(client,CSW_SCOUT) || !is_user_alive(client))
		? ITEM_DISABLED:ITEM_ENABLED);
}

public AmmoPacksShopHandler(client, menu, item) {
	if ((item != MENU_EXIT) && (item != MENU_BACK) && (item != MENU_MORE))
	{
		if (user_has_weapon(client,CSW_SCOUT))
		{
			if (g_AmmoPacksList[item][AmmoCost] <= g_PlayersData[client][dCash])
			{
				g_PlayersData[client][dCash]-=g_AmmoPacksList[item][AmmoCost];

				cs_set_user_bpammo(client,CSW_SCOUT,(cs_get_user_bpammo(client,CSW_SCOUT) + g_AmmoPacksList[item][AmmoAmount]));

				client_print_color(client,print_team_blue,"%s %L",TAG,client,"SHOP_BUY_AP_SUCCESS",g_AmmoPacksList[item][AmmoAmount],g_AmmoPacksList[item][AmmoCost]);

				SaveData(client);
			}

			else
				client_print_color(client,print_team_red,"%s %L",TAG,client,"SHOP_NOT_ENOUGHT_CASH");
		}

		else
			client_print_color(client,print_team_red,"%s %L",TAG,client,"SHOP_NEED_SCOUT");
	}

	menu_destroy(menu);

	return (item == MENU_EXIT ? ActionShop(client):PLUGIN_HANDLED);
}

public ActionViewStats(client) {
	static some[256],szName[MAX_NAME_LENGTH],plr,players[MAX_PLAYERS],pnum,iMenu,i;

	formatex(some,charsmax(some),"\d[ \r%L \d]\y %L",client,"MENU_PREFIX",client,"MENU_VIEWSTATS");
	iMenu = menu_create(some,"ViewStatsHandler");

	get_players(players,pnum,"ch");

	for (i = 0; i < pnum; i++)
	{
		plr = players[i];

		get_user_name(plr,szName,charsmax(szName));
		formatex(some,charsmax(some),"\y%s \d[ \w%L: \y%d \r- \w%L: \y%d \r- \w%L: \y%d \d]",szName,client,"MENU_CASH",g_PlayersData[plr][dCash],client,"MENU_LEVEL",g_PlayersData[plr][dLevel],client,"MENU_XP",g_PlayersData[plr][dXP]);
		menu_additem(iMenu,some);
	}

	menu_setprop(iMenu,MPROP_EXITNAME,"Back");
	menu_display(client,iMenu);

	return PLUGIN_HANDLED;
}

public ViewStatsHandler(client, menu, item) {
	menu_destroy(menu);
	return (item == MENU_EXIT ? ActionShop(client):ActionViewStats(client));
}

public cmdHNRHelpMOTD(client) {
	show_motd(client,g_szHelpMOTD,"HyuNaS HitAndRun Help");
}

CheckPlayerLevel(client) {
	static szName[MAX_NAME_LENGTH];

	if (!isClientValid(client,false))
		return;

	if (g_PlayersData[client][dLevel] == MAX_LEVELS)
		return;

	while (g_PlayersData[client][dXP] >= g_iXP[g_PlayersData[client][dLevel]])
	{
		g_PlayersData[client][dLevel]++;

		get_user_name(client,szName,charsmax(szName));

		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d leveled up to level %d",client,g_PlayersData[client][dLevel]);
		client_print_color(client,print_team_blue,"%s %L",TAG,client,"LEVELUP_PERSON",g_PlayersData[client][dLevel]);
		client_print_color(0,print_team_red,"%s %L",TAG,LANG_PLAYER,"LEVELUP_ALL",szName,g_PlayersData[client][dLevel]);
	}

	SaveData(client);
}

LoadData(client) {
	static szAuthID[MAX_AUTHID_LENGTH],szData[128],i;
	static tmpLevel[TMPDATA_SIZE + 1],tmpXP[TMPDATA_SIZE + 1],tmpCash[TMPDATA_SIZE + 1],tmpTRounds[TMPDATA_SIZE + 1],tmpTWins[TMPDATA_SIZE + 1];

	if (!isClientValid(client,false))
		return;

	get_user_authid(client,szAuthID,charsmax(szAuthID));

	if (nvault_lookup(g_iVault,szAuthID,szData,charsmax(szData),nVaultDummy))
	{
		replace_all(szData,charsmax(szData),"#"," ");
		parse(szData,tmpLevel,TMPDATA_SIZE,tmpXP,TMPDATA_SIZE,tmpCash,TMPDATA_SIZE,tmpTRounds,TMPDATA_SIZE,tmpTWins,TMPDATA_SIZE);

		g_PlayersData[client][dLevel] = str_to_num(tmpLevel);
		g_PlayersData[client][dXP] = str_to_num(tmpXP);
		g_PlayersData[client][dCash] = str_to_num(tmpCash);
		g_PlayersData[client][dTotalRounds] = str_to_num(tmpTRounds);
		g_PlayersData[client][dTotalWins] = str_to_num(tmpTWins);

		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Data load for authid ^"%s^" - %s",szAuthID,szData);
	}

	else
	{
		for (i = 0; i < PlayersData; i++)
			g_PlayersData[client][i] = 0;

		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"No data found for authid ^"%s^"",szAuthID);
	}
}

SaveData(client) {
	static szAuthID[MAX_AUTHID_LENGTH],szData[128];

	if (!isClientValid(client,false))
		return;

	get_user_authid(client,szAuthID,charsmax(szAuthID));

	formatex(szData,charsmax(szData),"%d#%d#%d#%d#%d",
	g_PlayersData[client][dLevel],
	g_PlayersData[client][dXP],
	g_PlayersData[client][dCash],
	g_PlayersData[client][dTotalRounds],
	g_PlayersData[client][dTotalWins]);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Data save for authid ^"%s^": %s",szAuthID,szData);

	nvault_set(g_iVault,szAuthID,szData);
}
