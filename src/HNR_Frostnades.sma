/*
    HNR Addon: Frostnades for HyuNaS HitAndRun v2.0
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
#include <fun>
#include <cstrike_pdatas>

// Defines the HNR Debug message tag for this plugin.
#define HNR_DBG_NAME		"HNR Frostnades"


enum _:eCvars
{
	cEnabled,
	cSelfreeze,
	cPassInfection
}

new const g_dCvars[eCvars][eCvarsData] = {
	{ "hnr_fn_enabled", "1", "Toggle frostnade plugin" },
	{ "hnr_fn_selfreeze", "1", "Toggle if player can freeze themself" },
	{ "hnr_fn_passinfection", "1", "Toggle if the frostnade can pass infection" }
};

new g_iCvars[eCvars];

new g_iBeaconSprite;

new bool:g_bFreezed[MAX_PLAYERS + 1];

new g_fwdOnNadeExplotion,g_fwdOnClientFreeze;

new g_iASFrostModel;

public plugin_init() {
	register_plugin("[HNR Addon] Frostnades",get_hnr_version(),"HiyoriX");

	for (new i = 0; i < eCvars; i++)
		g_iCvars[i] = create_cvar(g_dCvars[i][cName],g_dCvars[i][cDefValue],(FCVAR_SERVER | FCVAR_PRINTABLEONLY),g_dCvars[i][cDescription],true,0.0,true,1.0);

	register_forward(FM_SetModel,"fw_FMSetModelPost",1);

	RegisterHam(Ham_Item_Deploy,"weapon_smokegrenade","fw_HamItemDeployPost",1);

	g_fwdOnNadeExplotion = CreateMultiForward("OnNadeExplotion",ET_STOP,FP_CELL);
	g_fwdOnClientFreeze = CreateMultiForward("OnClientFreeze",ET_STOP,FP_CELL);

	if (g_fwdOnNadeExplotion == INVALID_HANDLE || g_fwdOnClientFreeze == INVALID_HANDLE)
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to create forwards; Plugin failed to load.");
		set_fail_state("[HitAndRun] Error creating forwards.");
	}
}

public plugin_precache() {
	hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug started");

	for(new i = 0; i < sFrostSounds; i ++ )
	{
		if (!isSoundFileExist(g_szFrostSoundsPath[i],false))
			hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Failed to find sound file: ^"%s^"",g_szFrostSoundsPath[i]);

		else
		{
			hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache sound file: ^"%s^"",g_szFrostSoundsPath[i]);
			precache_sound(g_szFrostSoundsPath[i]);
		}
	}

	if (!file_exists(g_szBeaconSprite,true))
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to find sprite ^"%s^"; Plugin failed to load.",g_szBeaconSprite);
		set_fail_state("[HitAndRun] Error loading beacon sprite!");
	}

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache sprite file: ^"%s^"",g_szBeaconSprite);

	g_iBeaconSprite = precache_model(g_szBeaconSprite);

	if (!file_exists(g_szForstNadeModel,false))
	{
		hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to find model ^"%s^"; Plugin failed to load.",g_szForstNadeModel);
		set_fail_state("[HitAndRun] Error loading frostnade model!");
	}

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache model file: ^"%s^"",g_szForstNadeModel);
	precache_model(g_szForstNadeModel);

	g_iASFrostModel = engfunc(EngFunc_AllocString,g_szForstNadeModel);
}

public plugin_end() {
	// Prevent AMXX memory leak
	DestroyForward(g_fwdOnNadeExplotion);
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward ^"OnNadeExplotion^" Destroyed");
	DestroyForward(g_fwdOnClientFreeze);
	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward ^"OnClientFreeze^" Destroyed");

	hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug ended");
}

public plugin_natives() {
	register_native("is_user_freezed","_is_user_freezed",0);
	register_native("set_user_freeze","_set_user_freeze",0);
}

public bool:_is_user_freezed(pluginid, params) {
	static client;
	client = get_param(1);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"is_user_freezed^" call - data: %d; PluginID: %d",client,pluginid);

	if (!isClientValid(client,true))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"is_user_freezed^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return false;
	}

	return g_bFreezed[client];
}

public _set_user_freeze(pluginid, params) {
	static client, bool:bFreeze;

	client = get_param(1);
	bFreeze = bool:get_param(2);

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"set_user_freeze^" call - data: %d %d; PluginID: %d",client,bFreeze,pluginid);

	if (!isClientValid(client,true))
	{
		log_error(AMX_ERR_NATIVE,"[HitAndRun] Error: Player %d is invalid!",client);
		hnr_dbg_message(HNR_DBG_NAME,dbg_error,"Native ^"set_user_freeze ^" error - player %d is invalid; PluginID: %d",client,pluginid);
		return 0;
	}

	if (bFreeze && !g_bFreezed[client])
	{
		FreezePlayer(client);
		return 1;
	}

	else if (!bFreeze && g_bFreezed[client])
	{
		UnFreezePlayer(client);
		return 1;
	}

	else
		return 0;
}

public client_putinserver(client) {
	g_bFreezed[client] = false;
}

public fw_FMSetModelPost(ent, const szModel[]) {
	if (!pev_valid(ent))
		return;

	if (!equal(szModel,"models/w_smokegrenade.mdl"))
		return;

	if (!get_pcvar_bool(g_iCvars[cEnabled]) || !isHNREnabled())
		return;

	if (!is_user_connected(pev(ent,pev_owner)))
		return;

	set_pev(ent,pev_nextthink,(get_gametime() + 5.0));

	set_task(1.5,"taskExplodeNade",(TASKID_EXPLODE + ent));
}

public fw_HamItemDeployPost(ent) {
	static client;

	if (pev_valid(ent) != 2)
		return;

	if (!isHNREnabled())
		return;

	client = get_pdata_cbase(ent,m_pPlayer,XO_CBASEPLAYERITEM);

	if (!isClientValid(client,true))
		return;

	set_pev(client,pev_viewmodel,g_iASFrostModel);
}

public taskExplodeNade(taskid) {
	static players[32], Float:fOrigin[3], Float:fPOrigin[3];
	static i,ent,iOwner,pnum,plr,fwd_return;

	ent = taskid - TASKID_EXPLODE;

	if (!pev_valid(ent))
		return;

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward ^"OnNadeExplotion^" call");
	ExecuteForward(g_fwdOnNadeExplotion,fwd_return,ent);

	if (fwd_return == PLUGIN_HANDLED)
		return;

	iOwner = pev(ent,pev_owner);

	pev(ent,pev_origin,fOrigin);

	MakeExplodeBeacon(fOrigin);

	engfunc(EngFunc_EmitSound,ent,CHAN_WEAPON,g_szFrostSoundsPath[sExplode],1.0,ATTN_NORM,0,PITCH_NORM);

	get_players(players,pnum,"aceh","TERRORIST");

	for (i = 0; i < pnum; i++)
	{
		plr = players[i];

		if ((plr == iOwner && !get_pcvar_bool(g_iCvars[cSelfreeze])) || g_bFreezed[plr])
			continue;

		pev(plr,pev_origin,fPOrigin);

		if(get_distance_f(fPOrigin,fOrigin) > MAX_RADIUS)
			continue;

		hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward ^"OnClientFreeze^" call");
		ExecuteForward(g_fwdOnClientFreeze,fwd_return,plr);

		if (fwd_return == PLUGIN_HANDLED)
			continue;

		FreezePlayer(plr);

		if (get_pcvar_bool(g_iCvars[cPassInfection]))
			ExecuteHamB(Ham_TakeDamage,plr,iOwner,iOwner,0.0,DMG_GENERIC);

		set_task(3.5,"taskUnFreeze",(plr + TASKID_FREEZE));
	}

	engfunc(EngFunc_RemoveEntity,ent);
}

public taskUnFreeze(taskid) {
	static client;
	client = taskid - TASKID_FREEZE;

	if (!is_user_alive(client))
		return;

	UnFreezePlayer(client);
}

FreezePlayer(client) {
	g_bFreezed[client] = true;

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d frozed",client);

	set_user_rendering(client,kRenderFxGlowShell,0,80,200,kRenderNormal,80);

	set_pev(client,pev_flags,(pev(client,pev_flags) | FL_FROZEN));

	engfunc(EngFunc_EmitSound,client,CHAN_WEAPON,g_szFrostSoundsPath[sHit],1.0,ATTN_NORM,0,PITCH_NORM);

	make_user_screenfade(client,(1<<31),(1<<31),FFADE_STAYOUT,100,200,255,100);
}

UnFreezePlayer(client) {
	g_bFreezed[client] = false;

	hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Player %d unfrozed",client);

	if (is_user_infected(client))
		set_user_rendering(client,kRenderFxGlowShell,random(256),random(256),random(256),kRenderTransAlpha,120);

	else
		set_user_rendering(client,kRenderFxNone,255,255,255,kRenderNormal,16);

	make_user_screenfade(client,0,0,0,0);

	set_pev(client,pev_flags,(pev(client,pev_flags) & ~FL_FROZEN));

	engfunc(EngFunc_EmitSound,client,CHAN_WEAPON,g_szFrostSoundsPath[sUnfreeze],1.0,ATTN_NORM,0,PITCH_NORM);
}

stock MakeExplodeBeacon(Float:Origin[3]) {
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	engfunc(EngFunc_WriteCoord,Origin[0]);
	engfunc(EngFunc_WriteCoord,Origin[1]);
	engfunc(EngFunc_WriteCoord,Origin[2]);
	engfunc(EngFunc_WriteCoord,Origin[0]);
	engfunc(EngFunc_WriteCoord,Origin[1]);
	engfunc(EngFunc_WriteCoord,Origin[2] + 240);
	write_short(g_iBeaconSprite);
	write_byte(0);
	write_byte(0);
	write_byte(8);
	write_byte(60);
	write_byte(0);
	write_byte(40);
	write_byte(100);
	write_byte(200);
	write_byte(200);
	write_byte(3);
	message_end();
}
