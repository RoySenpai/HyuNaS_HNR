/*
    HyuNaS HitAndRun mod for Counter-Strike 1.6 STEAM
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
#include <fakemeta>
#include <fun>
#include <hitandrun>
#include <cstrike_pdatas>

// Defines the HNR Debug message tag for this plugin.
#define HNR_DBG_NAME		"HNR Core"

enum _:eCvars
{
	cEnabled,
	cJumpStyle,
	cNoZoom,
	cScoutDrop,
	cBlockKill,
	cBlockRadio,
	cVoice
};

new const g_dCvars[eCvars][eCvarsData] = {
	{ "hnr_enabled", "1", "Toggle plugin status" },
	{ "hnr_jumpstyle", "1", "Change jumping style" },
	{ "hnr_nozoom", "0", "Toggle scout zooming" },
	{ "hnr_scoutdrop", "1", "Toggle scout drop" },
	{ "hnr_blockkill", "1", "Toggle suicide" },
	{ "hnr_blockradio", "1", "Blocks ^"Fire in the hole^" text and sound" },
	{ "hnr_voice", "0", "Sets the voice of the countdown announcement" }
};

new g_iCvars[eCvars];
new cvarhook:g_chCvars[eCvars];

new bool:g_bNoZoom = false;

new g_fwdEventRoundStart;
new g_fwdClientKill,g_fwdGetGameDescription;
new HamHook:g_fwdHamSpawn,HamHook:g_fwdHamTakeDamage,HamHook:g_fwdHamPlayerJump;
new HamHook:g_fwdHamWeaponSecondaryAttack,HamHook:g_fwdHamCSItemCanDrop;
new g_fwdmsgStatusIcon,g_fwdmsgHideWeapon,g_fwdmsgTextMsg,g_fwdmsgSendAudio;

new GameStatus:g_gStatus = GameWaiting;

new g_iInfected[RATIO_INFECT + 1], g_cInfected;
new g_iLastHit[RATIO_INFECT + 1];
new bool:g_bInfected[MAX_PLAYERS + 1];
new g_iWinner;

new Float:g_iTimer;
new g_iCD;

new g_iMsgStatusIcon,g_iMsgHideWeapon,g_iMsgTextMsg,g_iMsgSendAudio;
new g_iLight,g_iSmoke,g_iWinnerBeamspr;

new g_fwdOnRoundStart, g_fwdOnWinner, g_fwdOnInfection, g_fwdOnHNRKilled;

public plugin_init() {
	register_plugin("HyuNaS HitAndRun",get_hnr_version(),"HiyoriX");

	create_cvar("hnr_version",get_hnr_version(),(FCVAR_SERVER | FCVAR_SPONLY | FCVAR_PRINTABLEONLY),"Shows plugin version");

	for (new i = 0; i < eCvars; i++)
	{
		g_iCvars[i] = create_cvar(g_dCvars[i][cName],g_dCvars[i][cDefValue],(FCVAR_SERVER | FCVAR_PRINTABLEONLY),g_dCvars[i][cDescription],true,0.0,true,(i == cJumpStyle ? 2.0:1.0));
		g_chCvars[i] = hook_cvar_change(g_iCvars[i],"fwdOnCvarChange");
	}

	g_fwdEventRoundStart = register_logevent("EventRoundStart",2,"1=Round_Start");

	register_clcmd("jointeam","ActionBlock");
	register_clcmd("chooseteam","ActionBlock");
	register_clcmd("radio1","ActionBlock");
	register_clcmd("radio2","ActionBlock");
	register_clcmd("radio3","ActionBlock");

	g_fwdClientKill = register_forward(FM_ClientKill,"fwdClientKillPre",0);
	g_fwdGetGameDescription = register_forward(FM_GetGameDescription,"fwdGetGameDescriptionPre",0);

	g_fwdHamSpawn = RegisterHamPlayer(Ham_Spawn,"fwdHamSpawnPost",1);
	g_fwdHamTakeDamage = RegisterHamPlayer(Ham_TakeDamage,"fwdHamTakeDamagePre",0);
	g_fwdHamPlayerJump = RegisterHamPlayer(Ham_Player_Jump,"fwdHamPlayerJumpPost",1);

	g_fwdHamWeaponSecondaryAttack = RegisterHam(Ham_Weapon_SecondaryAttack,"weapon_scout","fw_ScoutOnZoomOnPre",0);
	g_fwdHamCSItemCanDrop = RegisterHam(Ham_CS_Item_CanDrop,"weapon_scout","fw_ScoutCanDropPre",0);

	g_iMsgStatusIcon = get_user_msgid("StatusIcon");
	g_iMsgHideWeapon = get_user_msgid("HideWeapon");
	g_iMsgTextMsg = get_user_msgid("TextMsg");
	g_iMsgSendAudio = get_user_msgid("SendAudio");

	g_fwdmsgStatusIcon = register_message(g_iMsgStatusIcon,"msgStatusIcon");
	g_fwdmsgHideWeapon = register_message(g_iMsgHideWeapon,"msgHideWeapon");
	g_fwdmsgTextMsg = register_message(g_iMsgTextMsg,"msgTextMsg");
	g_fwdmsgSendAudio = register_message(g_iMsgSendAudio,"msgSendAudio");

	g_fwdOnRoundStart = CreateMultiForward("OnHNRRoundStart",ET_STOP);
	g_fwdOnWinner = CreateMultiForward("OnHNRWinner",ET_IGNORE,FP_CELL);
	g_fwdOnInfection = CreateMultiForward("OnHNRInfection",ET_STOP,FP_CELL,FP_CELL);
	g_fwdOnHNRKilled = CreateMultiForward("OnHNRKilled",ET_IGNORE,FP_CELL,FP_CELL);

	if (g_fwdOnWinner == INVALID_HANDLE || g_fwdOnInfection == INVALID_HANDLE || g_fwdOnHNRKilled == INVALID_HANDLE || g_fwdOnRoundStart == INVALID_HANDLE)
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to create forwards; Plugin failed to load.");
		hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"g_fwdOnWinner = %d; g_fwdOnInfection = %d; g_fwdOnHNRKilled = %d; g_fwdOnRoundStart = %d",g_fwdOnWinner,g_fwdOnInfection,g_fwdOnHNRKilled,g_fwdOnRoundStart);
		set_fail_state("[HitAndRun] Error creating forwards.");
	}

	register_dictionary("hnr_core.txt");

	set_task(HNR_ADV_TIME,"taskAdvMsg",TASKID_ADVMSG,.flags="b");
}

public plugin_precache() {
	new szMap[64];

	hnr_dbg_message(HNR_DBG_NAME,dbg_any,"------------------------------------");
	hnr_dbg_message(HNR_DBG_NAME,dbg_any,"HyuNaS HitAndRun %s build %d; By Hyuna (aka HiyoriX)",HNR_VERSION,HNR_VER_BUILD);
	hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug started; Have a nice day!");

	if (!cstrike_running())
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"This plugin supports only Counter-Strike game mode; Plugin failed to load.");
		set_fail_state("[HitAndRun] Mod isn't supported!");
	}

	get_mapname(szMap,charsmax(szMap));

	if ((containi(szMap,"hnr_") == -1) && (containi(szMap,"bg_") == -1))
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"This map isn't an hitandrun/bombgame map!");
		set_fail_state("[HitAndRun] This map isn't an hitandrun/bombgame map!");
	}

	new some[256], i;
	formatex(some,charsmax(some),"models/player/%s/%s.mdl",g_sSickModel,g_sSickModel);

	if (!file_exists(some))
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to find model ^"%s^" (Sickness Model); Plugin failed to load.",some);
		set_fail_state("[HitAndRun] Error loading model!");
	}

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache player model file: ^"%s^"",some);
	precache_model(some);

	if (!file_exists(g_eLightning,true))
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to find sprite ^"%s^" (Lightning Sprite); Plugin failed to load.",g_eLightning);
		set_fail_state("[HitAndRun] Error loading sprite!");
	}

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache sprite file: ^"%s^"",g_eLightning);
	g_iLight = precache_model(g_eLightning);

	if (!file_exists(g_eSmoke,true))
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to find sprite ^"%s^" (SMoke Sprite); Plugin failed to load.",g_eSmoke);
		set_fail_state("[HitAndRun] Error loading sprite!");
	}

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache sprite file: ^"%s^"",g_eSmoke);
	g_iSmoke = precache_model(g_eSmoke);

	if (!file_exists(g_eWinnerBeamspr,true))
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to find sprite ^"%s^" (Winner-Beam Sprite); Plugin failed to load.",g_eWinnerBeamspr);
		set_fail_state("[HitAndRun] Error loading sprite!");
	}

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache sprite file: ^"%s^"",g_eWinnerBeamspr);
	g_iWinnerBeamspr = precache_model(g_eWinnerBeamspr);

	for (i = 0; i < MAX_WINNER_SND; i++)
	{
		formatex(some,charsmax(some),"%s/%s/%s%d.mp3",PLUGIN_DIR,DIR_WINNER,SND_WINNER,(i+1));

		if (!isSoundFileExist(some,false))
			hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Failed to find sound: ^"%s^" (Winner Sound).",some);

		else
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache sound file: ^"%s^"",some);
			precache_sound(some);
		}
	}

	for (i = 0; i < MAX_INFECT_SND; i++)
	{
		formatex(some,charsmax(some),"%s/%s/%s%d.wav",PLUGIN_DIR,DIR_INFECTED,SND_INFECT,(i+1));

		if (!isSoundFileExist(some,false))
			hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Failed to find sound: ^"%s^" (Infected Sound).",some);

		else
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache sound file: ^"%s^"",some);
			precache_sound(some);
		}
	}

	for (i = 0; i < dEffectsSnd; i++)
	{
		formatex(some,charsmax(some),"%s/%s",PLUGIN_DIR,g_sEffectsSounds[i]);

		if (!isSoundFileExist(some,true))
			hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Failed to find sound: ^"%s^" (Effects Sound).",some);

		else
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache sound file: ^"%s^"",some);
			precache_sound(some);
		}
	}

	if (!isSoundFileExist(g_LightningSnd,true))
			hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Failed to find sound: ^"%s^" (Lightling Sound).",g_LightningSnd);

	else
	{
			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache sound file: ^"%s^"",g_LightningSnd);
			precache_sound(some);
	}

	precache_sound(g_LightningSnd);
}

public plugin_cfg() {
	new some[256];
	get_configsdir(some,charsmax(some));
	format(some,charsmax(some),"%s/%s",some,CFG_FILE);

	LoadConfigFile(some);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Removing entity ^"func_bomb_target^"");
	RemoveAllEntitiesByClass("func_bomb_target");

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Removing entity ^"info_bomb_target^"");
	RemoveAllEntitiesByClass("info_bomb_target");

	set_task(5.0,"taskRestartGame");
}

public plugin_end() {
	// Prevent AMXX memory leak

	DestroyForward(g_fwdOnWinner);
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward ^"OnHNRWinner^" Destroyed");

	DestroyForward(g_fwdOnInfection);
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward ^"OnHNRInfection^" Destroyed");

	DestroyForward(g_fwdOnHNRKilled);
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward ^"OnHNRKilled^" Destroyed");

	hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug ended");
}

public plugin_natives() {
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Registering library ^"hitandrun^"");
	register_library("hitandrun");

	register_native("is_user_infected","_is_user_infected");
	register_native("get_infected_player","_get_infected_player");
	register_native("get_infected_players","_get_infected_players");
	register_native("get_infected_count","_get_infected_count");
	register_native("get_humans_count","_get_humans_count");
	register_native("get_hnr_status","_get_hnr_status");
	register_native("set_hnr_status","_set_hnr_status");
	register_native("make_random_infection","_make_random_infection");
}

public _is_user_infected(pluginid, params) {
	static client;
	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"is_user_infected^" call - data: %d; PluginID: %d",client,pluginid);

	if (!isClientValid(client,true))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"is_user_infected^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return -1;
	}

	return g_bInfected[client];
}

public _get_infected_player(pluginid, params) {
	static client;
	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"get_infected_player^" call - data: %d; PluginID: %d",client,pluginid);

	if (!isClientValid(client,true))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"get_infected_player^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return -1;
	}

	return get_infected_id(client);
}

public _get_infected_players(pluginid, params) {
	set_array(1,g_iInfected,RATIO_INFECT);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"get_infected_player^" call - PluginID: %d",pluginid);
}

public _get_infected_count(pluginid, params) {
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"get_infected_count^" call - PluginID: %d",pluginid);
	return g_cInfected;
}

public _get_humans_count(pluginid, params) {
	static players[32],pnum,count,i,p;

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"get_humans_count^" call - PluginID: %d",pluginid);

	count = 0;

	get_players(players,pnum,"aceh","TERRORIST");

	for (i = 0; i < pnum; i++)
	{
		p = players[i];

		if (!g_bInfected[p])
			count++;
	}

	return count;
}

public GameStatus:_get_hnr_status(pluginid, params) {
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"get_hnr_status^" call - PluginID: %d",pluginid);

	return g_gStatus;
}

public _set_hnr_status(pluginid,params) {
	g_gStatus = GameStatus:clamp(get_param(1),_:GameDisabled,_:GameEnding);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"set_hnr_status^" call - data: %d; PluginID: %d",get_param(1),pluginid);
}

public _make_random_infection(pluginid,params) {
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"make_random_infection^" call - PluginID: %d",pluginid);
	return MakeRandomInfection();
}

public client_disconnected(client) {
	if (g_gStatus == GameDisabled)
		return;

	if (client == g_iWinner)
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_warning,"Winner left the game, restarting game");
		set_task(1.0,"taskRestartGame");
	}

	if (g_bInfected[client])
	{
		if ((--g_cInfected < 1) && !isClientValid(get_random_infected(),true))
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_warning,"Last player left the game, restarting game");
			set_task(1.0,"taskRestartGame");
		}
	}
}

public msgStatusIcon(msgid, msgdest, client) {
	static szIcon[8];

	if (get_msg_arg_int(1))
	{
		get_msg_arg_string(2,szIcon,charsmax(szIcon));

		if(equal(szIcon,"buyzone"))
		{
			set_pdata_int(client,m_fClientMapZone,(get_pdata_int(client,m_fClientMapZone,XO_CBASEPLAYER) & ~CS_MAPZONE_BUY),XO_CBASEPLAYER);
			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_CONTINUE;
}

public msgHideWeapon(msgid, msgdest, client) {
	if (g_gStatus > GameDisabled)
	{
		set_msg_arg_int(1,ARG_BYTE,HIDE_HUD_ELEMENTS);
		set_pdata_int(client,m_iHideHUD,HIDE_HUD_ELEMENTS,XO_CBASEPLAYER);
		set_pdata_int(client,m_iClientHideHUD,HIDE_HUD_ELEMENTS,XO_CBASEPLAYER);
	}

	else
	{
		set_msg_arg_int(1,ARG_BYTE,0);
		set_pdata_int(client,m_iHideHUD,0,XO_CBASEPLAYER);
		set_pdata_int(client,m_iClientHideHUD,0,XO_CBASEPLAYER);
	}
}

public msgTextMsg(msgid, msgdest, client) {
	static arg[24];

	if (!get_pcvar_bool(g_iCvars[cBlockRadio]))
		return PLUGIN_CONTINUE;

	if (get_msg_args() != 5)
		return PLUGIN_CONTINUE;

	get_msg_arg_string(3,arg,charsmax(arg));

	if(!equal(arg,"#Game_radio"))
		return PLUGIN_CONTINUE;

	get_msg_arg_string(5,arg,charsmax(arg));

	if(equal(arg,"#Fire_in_the_hole"))
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}

public msgSendAudio(msgid, msgdest, client) {
	static arg[24];

	if (!get_pcvar_bool(g_iCvars[cBlockRadio]))
		return PLUGIN_CONTINUE;

	get_msg_arg_string(2,arg,charsmax(arg));

	if(equal(arg,"%!MRAD_FIREINHOLE"))
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}

public taskRestartGame() {
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Restarting game");

	if (g_gStatus == GameEnding)
		set_game_status(GameWaiting);

	server_cmd("sv_restart 1");
}

public EventRoundStart() {
	static players[32],pnum,i,p;

	if (g_gStatus == GameDisabled)
		return;

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"New round started; Removing tasks and cleaning arrays");

	set_game_status(GameWaiting);

	cs_set_no_knives(1);

	remove_task(TASKID_GAMESTART);
	remove_task(TASKID_COUNTDOWN);
	remove_task(TASKID_TIMER);
	remove_task(TASKID_SOUNDS);
	remove_task(g_iWinner);

	fm_set_lights("m");

	g_iWinner = 0
	g_cInfected = 0;
	arrayset(g_bInfected,false,MAX_PLAYERS + 1);
	arrayset(g_iInfected,0,RATIO_INFECT);
	arrayset(g_iLastHit,0,RATIO_INFECT);

	get_players(players,pnum,"ch");

	for (i = 0; i < pnum; i++)
	{
		p = players[i];

		if (cs_get_user_team(p) != CS_TEAM_T)
			cs_set_user_team(p,CS_TEAM_T);

		ExecuteHamB(Ham_CS_RoundRespawn,p);
	}

	client_cmd(0,"mp3 stop");

	g_iCD = 10;
	g_iTimer = 20.0;

	set_task(1.0,"taskCountDown",TASKID_COUNTDOWN,"",0,"b",0);
	client_print_color(0,print_team_red,"%s %L",TAG,LANG_PLAYER,"GAME_WILL_START_CHAT");
}

public taskCountDown(taskid){
	static szWord[32], iCvar;

	if (g_gStatus == GameDisabled)
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_warning,"Plugin disabled, restarting game");
		remove_task(taskid);
		set_task(1.0,"taskRestartGame");
		return;
	}

	if (g_iCD < 1)
	{
		remove_task(taskid);
		ActionStartGame(0);
		return;
	}

	iCvar = get_pcvar_num(g_iCvars[cVoice]);

	num_to_word(g_iCD,szWord,31);

	client_cmd(0,"spk ^"\%svox/%s",(iCvar ? "f":""),szWord);

	set_dhudmessage(0,255,0,-1.0,0.13,0,6.0,0.5,0.25,0.25);
	show_dhudmessage(0,"%L",LANG_PLAYER,"GAME_WILL_START_DHUD",g_iCD);

	g_iCD--;
}

public ActionStartGame(stats) {
	static players[32],pnum,ret;

	if (g_gStatus == GameDisabled)
		return;

	if (!stats)
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward call: OnHNRRoundStart");
		ExecuteForward(g_fwdOnRoundStart,ret);

		if (ret > 0)
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward call ^"OnHNRRoundStart^" returned %d, blocking from infection.",ret);
			return;
		}
	}

	if (!MakeRandomInfection())
		return;

	if (g_gStatus == GameWaiting)
	{
		get_players(players,pnum,"aceh","TERRORIST");

		for (new i = 0; i < pnum; i++)
		{
			give_item(players[i],"weapon_knife");
			give_item(players[i],"weapon_scout");

			give_item(players[i],"weapon_hegrenade");
			give_item(players[i],"weapon_flashbang");
			give_item(players[i],"weapon_flashbang");
			give_item(players[i],"weapon_smokegrenade");
		}
	}

	set_game_status(GameRunning);
}

public TikTok() client_cmd(0,"mp3 play sound/%s/%s",PLUGIN_DIR,g_sEffectsSounds[eAlarm]);

public Trrrrr() client_cmd(0,"mp3 play sound/%s/%s",PLUGIN_DIR,g_sEffectsSounds[eClock]);

public ActionShowTimer(taskid) {
	static plr,lh,ret;

	if(g_gStatus != GameRunning)
	{
		remove_task(taskid);

		hnr_dbg_message(HNR_DBG_NAME,dbg_warning,"Plugin disabled, restarting game");
		set_task(1.0,"taskRestartGame");
		return;
	}

	if (g_iTimer < 0.1)
	{
		for (new i = 0; i < g_cInfected; i++)
		{
			plr = g_iInfected[i];
			if (!isClientValid(plr,true))
				continue;

			lh = g_iLastHit[i];

			ActionRemoveInfection(plr);

			if (is_user_freezed(plr))
				set_user_freeze(plr,false);

			if (isClientValid(lh,true))
			{
				make_deathmsg(lh,plr,0,"");
				user_silentkill(plr);

				g_iLastHit[i] = 0;
			}

			else
				user_kill(g_iInfected[i],1);

			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward call: OnHNRKilled");
			ExecuteForward(g_fwdOnHNRKilled,ret,plr,lh);

			client_cmd(plr,"spk %s",PLUGIN_DIR,g_sEffectsSounds[eLooser]);

			make_user_screenfade(plr,(1<<15),(1<<10),(1<<12));
		}

		ActionCheckWinner();

		remove_task(taskid);
		return;
	}

	set_dhudmessage(255,0,0,-1.0,0.71,1,0.0,0.12,0.0,0.0);
	show_dhudmessage(0,"%L^n%s",LANG_PLAYER,"TIMER_TLEFT",g_iTimer,show_infected_msg());

	g_iTimer-=0.1;
}

public ActionInfectPlayer(client,infector) {
	static szName[32],ret;

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward call: OnHNRInfection");

	ExecuteForward(g_fwdOnInfection,ret,client,infector);

	if (ret > 0)
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward call ^"OnHNRInfection^" returned %d, blocking from infection.",ret);
		return;
	}

	if (isClientValid(infector,true))
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d passed the sickness to %d in %1.f seconds",infector,client,g_iTimer);

		g_iLastHit[get_infected_id(infector)] = infector;
		g_bInfected[client] = true;
		g_iInfected[get_infected_id(infector)] = client;

		ActionRemoveInfection(infector);

		get_user_name(client,szName,charsmax(szName));

		client_print_color(0,print_team_red,"%s ^3%s^1 %L [^4%.1f^1]",TAG,szName,LANG_PLAYER,"SICKNESS_PASS",g_iTimer);
	}

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Infecting player %d",client);

	g_bInfected[client] = true;
	make_user_statusicon(client,g_szSIspr,STATUSICON_FLASH);
	set_user_rendering(client,kRenderFxGlowShell,random(256),random(256),random(256),kRenderTransAlpha,120);
	cs_set_user_model(client,g_sSickModel);

	make_sickness(client);
	make_user_screenshake(client);

	make_user_bartime(client,floatround(g_iTimer));

	msg_scoreattrib(client,SCOREATTRIB_BOMB);

	client_cmd(client,"spk %s/%s/%s%d.wav",PLUGIN_DIR,DIR_INFECTED,SND_INFECT,random_num(1,MAX_INFECT_SND));
}

public ActionRemoveInfection(client) {
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Removing infection from player %d",client);
	g_bInfected[client] = false;
	make_user_statusicon(client,g_szSIspr,STATUSICON_OFF);
	set_user_rendering(client,kRenderFxNone,255,255,255,kRenderNormal,16);
	cs_reset_user_model(client);

	make_user_bartime(client,0);

	msg_scoreattrib(client,SCOREATTRIB_NONE);
}

public ActionBlock(client) {
		return (g_gStatus > GameDisabled ? PLUGIN_HANDLED_MAIN:PLUGIN_CONTINUE);
}

public PreparePlayer(client) {
	strip_user_weapons(client);
	set_pdata_int(client,m_fHasPrimary,0,XO_CBASEPLAYER);
	set_user_health(client,100);

	set_user_rendering(client,kRenderFxNone,255,255,255,kRenderNormal,16);

	if (pev(client,pev_weapons) & (1<<CSW_C4))
		engclient_cmd(client,"drop","weapon_c4");

	cs_reset_user_model(client);
}

public fwdOnCvarChange(pcvar, const old_value[], const new_value[]) {
	static t;

	if (equal(old_value,new_value))
		return;

	if (pcvar == g_iCvars[cEnabled])
	{
		t = 0;

		switch(new_value[0])
		{
			case '0':
			{
				set_game_status(GameDisabled);
				disable_logevent(g_fwdEventRoundStart);

				cs_set_no_knives(0);

				unregister_forward(FM_GetGameDescription,g_fwdGetGameDescription,0);
				unregister_forward(FM_ClientKill,g_fwdClientKill,0);

				unregister_message(g_iMsgStatusIcon,g_fwdmsgStatusIcon);
				unregister_message(g_iMsgHideWeapon,g_fwdmsgHideWeapon);
				unregister_message(g_iMsgTextMsg,g_fwdmsgTextMsg);
				unregister_message(g_iMsgSendAudio,g_fwdmsgSendAudio);

				DisableHamForward(g_fwdHamPlayerJump);
				DisableHamForward(g_fwdHamWeaponSecondaryAttack);
				DisableHamForward(g_fwdHamCSItemCanDrop);
				DisableHamForward(g_fwdHamSpawn);
				DisableHamForward(g_fwdHamTakeDamage);

				hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Plugin disabled; Restarting game");
				set_task(1.0,"taskRestartGame");
			}

			case '1':
			{
				set_game_status(GameWaiting);
				enable_logevent(g_fwdEventRoundStart);

				cs_set_no_knives(1);

				g_fwdGetGameDescription = register_forward(FM_GetGameDescription,"fwdGetGameDescriptionPre",0);

				if (get_pcvar_bool(g_iCvars[cBlockKill]))
					g_fwdClientKill = register_forward(FM_ClientKill,"fwdClientKillPre",0);

				g_fwdmsgStatusIcon = register_message(g_iMsgStatusIcon,"msgStatusIcon");
				g_fwdmsgHideWeapon = register_message(g_iMsgHideWeapon,"msgHideWeapon");

				if (get_pcvar_bool(g_iCvars[cBlockRadio]))
				{
					g_fwdmsgTextMsg = register_message(g_iMsgTextMsg,"msgTextMsg");
					g_fwdmsgSendAudio = register_message(g_iMsgSendAudio,"msgSendAudio");
				}

				if (get_pcvar_num(g_iCvars[cJumpStyle]))
					EnableHamForward(g_fwdHamPlayerJump)

				if (get_pcvar_bool(g_iCvars[cNoZoom]))
					EnableHamForward(g_fwdHamWeaponSecondaryAttack);

				if (get_pcvar_bool(g_iCvars[cScoutDrop]))
					EnableHamForward(g_fwdHamCSItemCanDrop);

				EnableHamForward(g_fwdHamSpawn);
				EnableHamForward(g_fwdHamTakeDamage);

				hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Plugin enabled; Restarting game");
				set_task(1.0,"taskRestartGame");
			}
		}
	}

	else if (pcvar == g_iCvars[cJumpStyle])
	{
		t = 1;

		switch(new_value[0])
		{
			case '0': DisableHamForward(g_fwdHamPlayerJump);
			case '1', '2': EnableHamForward(g_fwdHamPlayerJump);
		}
	}

	else if (pcvar == g_iCvars[cNoZoom])
	{
		t = 2;

		switch(new_value[0])
		{
			case '0':
			{
				DisableHamForward(g_fwdHamWeaponSecondaryAttack);
				g_bNoZoom = false;
			}

			case '1':
			{
				EnableHamForward(g_fwdHamWeaponSecondaryAttack);
				g_bNoZoom = true;
			}
		}
	}

	else if (pcvar == g_iCvars[cScoutDrop])
	{
		t = 3;

		switch(new_value[0])
		{
			case '0': DisableHamForward(g_fwdHamCSItemCanDrop);
			case '1': EnableHamForward(g_fwdHamCSItemCanDrop);
		}
	}

	else if (pcvar == g_iCvars[cBlockKill])
	{
		t = 4;

		switch(new_value[0])
		{
			case '0': unregister_forward(FM_ClientKill,g_fwdClientKill,0);
			case '1': g_fwdClientKill = register_forward(FM_ClientKill,"fwdClientKillPre",0);
		}
	}

	else if (pcvar == g_iCvars[cBlockRadio])
	{
		t = 5;

		switch(new_value[0])
		{
			case '0':
			{
				unregister_message(g_iMsgTextMsg,g_fwdmsgTextMsg);
				unregister_message(g_iMsgSendAudio,g_fwdmsgSendAudio);
			}

			case '1':
			{
				g_fwdmsgTextMsg = register_message(g_iMsgTextMsg,"msgTextMsg");
				g_fwdmsgSendAudio = register_message(g_iMsgSendAudio,"msgSendAudio");
			}
		}
	}

	else
	{
		log_error(AMX_ERR_BOUNDS,"[HitAndRun] Error: Hooked cvar not found.");
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Cvar %d out of bound.",pcvar);
		return;
	}

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Cvar ^"%s^" (%d) set to ^"%s^"",g_dCvars[t][cName],pcvar,new_value);
}

public fwdClientKillPre(client) {
	client_print_color(client,print_team_red,"%s %L",TAG,client,"BLOCKKILL_CHAT");
	console_print(client,"%L",client,"BLOCKKILL_CONSOLE");

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d tried to kill himself; Action blocked",client);

	return FMRES_SUPERCEDE;
}

public fwdGetGameDescriptionPre(){
	new some[32];
	formatex(some,31,"HitAndRun %s",HNR_VERSION);
	forward_return(FMV_STRING,some);
	return FMRES_SUPERCEDE;
}

public fwdHamSpawnPost(client) {
	if (!isClientValid(client,true))
		return;

	if (g_gStatus > GameWaiting)
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d joined the game too late, killing him",client);
		user_silentkill(client,1);
		make_user_screenfade(client,(1<<15),(1<<10),(1<<12));

		client_print_color(client,print_team_red,"%s %L",TAG,client,"SPAWN_TOO_LATE");
	}

	else
		PreparePlayer(client);
}

public fwdHamTakeDamagePre(client, idinflictor, idattacker, Float:damage, damagebits) {
	if (isClientValid(client,true) && isClientValid(idattacker,true) && (client != idattacker))
	{
		if (g_bInfected[idattacker] && !g_bInfected[client])
			ActionInfectPlayer(client,idattacker);
	}

	return HAM_SUPERCEDE;
}

public fwdHamPlayerJumpPost(client) {
	static Float:vel[3],flags;

	set_pev(client,pev_fuser2,0.0);

	if(get_pcvar_num(g_iCvars[cJumpStyle]) == 2)
	{
		flags = pev(client,pev_flags);

		if (!(flags & FL_ONGROUND) || (flags & FL_WATERJUMP) || (pev(client,pev_waterlevel) >= 2))
			return;

		pev(client,pev_velocity,vel);
		vel[2] += 260.0;
		set_pev(client,pev_velocity,vel);

		set_pev(client,pev_gaitsequence,6);
	}
}

public fw_ScoutOnZoomOnPre(ent) {
	return (g_bNoZoom ? HAM_SUPERCEDE:HAM_IGNORED);
}

public fw_ScoutCanDropPre(ent) {
	return HAM_SUPERCEDE;
}

public ActionCheckWinner() {
	static players[32],szName[32],pnum,ret;

	if (g_gStatus != GameRunning)
		return;

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Checking winner");

	get_players(players,pnum,"aceh","TERRORIST");

	if (pnum == 1)
	{
		remove_task(TASKID_TIMER);
		remove_task(TASKID_SOUNDS);

		g_iWinner = players[0];

		if(!isClientValid(g_iWinner,true))
		{
			inCaseofError();
			return;
		}

		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Success - Player %d won the game",g_iWinner);

		get_user_name(g_iWinner,szName,charsmax(szName));

		client_print_color(0,print_team_red,"%s %L",TAG,LANG_PLAYER,"WINNER_CHAT",szName);

		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward call: ^"OnHNRWinner^"");
		ExecuteForward(g_fwdOnWinner,ret,g_iWinner);

		client_cmd(0,"mp3 play ^"sound/%s/%s/%s%d.mp3^"",PLUGIN_DIR,DIR_WINNER,SND_WINNER,random_num(1,MAX_WINNER_SND));

		fm_set_lights("b");

		set_task(0.5,"WinnerBeam",g_iWinner,.flags="b");
		set_task(20.0,"taskRestartGame");

		set_game_status(GameEnding);
	}

	else if (pnum > 1)
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"No winner found; Continuing the game");
		set_game_status(GameRunning);
		set_task(4.0,"ActionStartGame",1);
	}

	else
		inCaseofError();
}

public WinnerBeam(client){
	static Origin[3];

	if(!isClientValid(client,true) || g_gStatus != GameEnding)
		remove_task(client);

	get_user_origin(client,Origin);

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMTORUS); // Screen aligned beam ring, expands to max radius over lifetime
	write_coord(Origin[0]);	// Position X
	write_coord(Origin[1]);	// Position Y
	write_coord(Origin[2]);	// Position Z
	write_coord(Origin[0]);	// Axis X
	write_coord(Origin[1]);	// Axis Y
	write_coord(Origin[2] + 400);	// Axis Z
	write_short(g_iWinnerBeamspr);	// Sprite index
	write_byte(0);	// Starting frame
	write_byte(1);	// Frame rate in 0.1's
	write_byte(7);	// Life in 0.1's
	write_byte(80);	// Line width in 0.1's
	write_byte(1);	// Noise amplitude in 0.01's
	write_byte(random(256));	// Red
	write_byte(random(256));	// Green
	write_byte(random(256));	// Blue
	write_byte(200);	// Brightness
	write_byte(0);	// Scroll speed in 0.1's
	message_end();
}

public taskAdvMsg(taskid) {
	client_print_color(0,print_team_red,"%s %L ^4HiyoriX^1.",TAG,LANG_PLAYER,"ADV_CREDITS",get_hnr_version());
	client_print_color(0,print_team_red,"%s ^3Visit our website: ^4gamers-israel.co.il",TAG);
	client_print_color(0,print_team_red,"%s ^3Teamspeak: ^4ts.gamers-israel.co.il",TAG);
}

MakeRandomInfection() {
	static players[32],pnum;

	get_players(players,pnum,"aceh","TERRORIST");

	g_iTimer = 20.0;
	g_cInfected = 0;

	do
	{
		g_iInfected[g_cInfected] = get_random_infected();

		if (!isClientValid(g_iInfected[g_cInfected],true))
		{
			if (g_iInfected[g_cInfected] == -2)
			{
				client_print_color(0,print_team_red,"%s %L",TAG,LANG_PLAYER,"NOT_ENOUGHT_PLAYERS",floatround(RETRY_TIME));
				hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Not enough players to start the game, retry in %.1f seconds",RETRY_TIME);
			}

			set_task(RETRY_TIME,"EventRoundStart",TASKID_GAMESTART);
			return 0;
		}

		ActionInfectPlayer(g_iInfected[g_cInfected],0);
		make_lightning(g_iInfected[g_cInfected]);

		g_cInfected++
	}

	while (((pnum/RATIO_INFECT) > g_cInfected) && (g_cInfected <= RATIO_INFECT))

	set_task(0.1,"ActionShowTimer",TASKID_TIMER,.flags="b");

	set_task(3.0,"TikTok",TASKID_SOUNDS);
	set_task(13.0,"Trrrrr",TASKID_SOUNDS);

	return 1;
}

stock inCaseofError() {
	hnr_dbg_message(HNR_DBG_NAME,dbg_warning,"Something went wrong, restarting game in 5 seconds");

	client_print_color(0,print_team_red,"%s %L",TAG,LANG_PLAYER,"FATAL_ERROR");

	set_task(5.0,"taskRestartGame");
}

stock LoadConfigFile(const szFile[]) {
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Loading config file ^"%s^"",szFile);

	if (!file_exists(szFile))
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_warning,"Can't find config file; Creating");

		new f = fopen(szFile,"w");

		if (!f)
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to open config file ^"%s^"",szFile);
			set_fail_state("[HitAndRun] Failed to open config file!");
		}

		fprintf(f,"// HyunaS HitAndRun %s Config File\n\n",HNR_VERSION);

		for (new i = 0; i < eCvars; i++)
			fprintf(f,"// %s\n %s %s\n\n",g_dCvars[i][cDescription],g_dCvars[i][cName],g_dCvars[i][cDefValue]);

		fclose(f);

		return;
	}

	server_cmd("exec %s",szFile);
	server_exec();
}

stock make_lightning(index){
	static origin[3], srco[3];
	get_user_origin(index,origin);

	origin[2] -= 26;
	srco[0] = origin[0] + 150;
	srco[1] = origin[1] + 150;
	srco[2] = origin[2] + 400;

	// Lightning
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMPOINTS);	// Beam effect between two points
	write_coord(srco[0]);	// Start position X
	write_coord(srco[1]);	// Start position Y
	write_coord(srco[2]);	// Start position Z
	write_coord(origin[0]);	// End position X
	write_coord(origin[1]);	// End position Y
	write_coord(origin[2]);	// End position Z
	write_short(g_iLight);	// Sprite Index
	write_byte(1);	// Starting frame
	write_byte(5);	// Frame rate in 0.1's
	write_byte(2);	// Life in 0.1's
	write_byte(20);	// Line width in 0.1's
	write_byte(30);	// Noise amplitude in 0.01's
	write_byte(200);	// Red
	write_byte(200);	// Green
	write_byte(200);	// Blue
	write_byte(200);	// brightness
	write_byte(200);	// Scroll speed in 0.1's
	message_end();

	// Sparks
	message_begin(MSG_PVS,SVC_TEMPENTITY,origin);
	write_byte(TE_SPARKS);	// 8 random tracers with gravity, ricochet sprite
	write_coord(origin[0]);	// Position X
	write_coord(origin[1]);	// Position Y
	write_coord(origin[2]);	// Position Z
	message_end();

	// Smoke
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY,origin);
	write_byte(TE_SMOKE);	// Alphablend sprite, move vertically 30pps
	write_coord(origin[0]);	// Position X
	write_coord(origin[1]);	// Position Y
	write_coord(origin[2]);	// Position Z
	write_short(g_iSmoke);	// Sprite Index
	write_byte(10);	// Scale in 0.1's
	write_byte(10);	// Framerate
	message_end();

	emit_sound(index,CHAN_AUTO,g_LightningSnd,VOL_NORM,ATTN_NORM,0,PITCH_NORM);
}

stock get_random_infected() {
	static players[32],pnum,rnd,i;
	get_players(players,pnum,"aceh","TERRORIST");

	if (pnum < 1)
		return -1;

	if (pnum < 2)
		return -2;

	i = 0;

	do
	{
		rnd = random(pnum);
		i++;	// Safe fail
	}

	while (g_bInfected[players[rnd]] && i < 10)

	if (g_bInfected[players[rnd]])
	{
		inCaseofError();
		return -1;
	}

	return players[rnd];
}

stock get_infected_id(client) {
	static i;
	for (i = 0; i < g_cInfected; i++)
	{
		if (g_iInfected[i] == client)
			return i;
	}

	return -1; // Out of bound, which means something was fucked up.
}

stock show_infected_msg() {
	static some[128],szName[32];
	static i;

	formatex(some,charsmax(some),"%L^n",LANG_PLAYER,"INFECTED_PLAYERS");

	for (i = 0; i < g_cInfected; i++)
	{
		if (!isClientValid(g_iInfected[i],true))
			continue;

		get_user_name(g_iInfected[i],szName,charsmax(szName));
		add(some,charsmax(some),szName);
		add(some,charsmax(some),"^n");
	}

	return some;
}

stock bool:isPluginEnabled() {
	return get_pcvar_bool(g_iCvars[cEnabled]);
}

stock set_game_status(GameStatus:status) {
	g_gStatus = status;
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Game status set: %s",g_szGSNames[_:status]);
}
