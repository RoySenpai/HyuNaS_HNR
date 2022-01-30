/*
    HNR Addon: Infender Dance for HyuNaS HitAndRun v2.0
    Copyright (C) 2013-2021 HiyoriX aka Hyuna (Roy), Hasson
    Author URL (Roy): https://steamcommunity.com/id/KissMyAsscom
    Author URL (Hasson): https://steamcommunity.com/id/hassonipulus
    Author SteamID (Roy): STEAM_1:0:35424936
    Author SteamID (Hasson): STEAM_1:0:50833741

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
#include <fun>
#include <hitandrun>

#define HNR_DBG_NAME    "HNR Infender Dance"

new g_iHandsVModel;
new g_bIsDancing = false;

new g_pSprites[MAX_SPRITES];

public plugin_init() {
    register_plugin("[HNR Addon] Infender Dance",get_hnr_version(),"Hasson & HiyoriX");

    register_logevent("EventRoundStart",2,"1=Round_Start");

    RegisterHam(Ham_Touch,"weapon_hegrenade","fwdOnWeaponTouchPre",0);
    RegisterHam(Ham_Touch,"weaponbox","fwdOnWeaponTouchPre",0);
    RegisterHam(Ham_Touch,"armoury_entity","fwdOnWeaponTouchPre",0);
}

public fwdOnWeaponTouchPre(entid, client) {
    if (!isClientValid(client,true))
        return HAM_IGNORED;

    return (g_bIsDancing ? HAM_SUPERCEDE:HAM_IGNORED);
}

public plugin_precache() {
    hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug started");

    if (!file_exists(g_szDanceModel))
    {
        hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to find model ^"%s^" (Clap Hands Model); Plugin failed to load.",g_szDanceModel);
        set_fail_state("[HitAndRun] Error loading model!");
    }

    hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache player model file: ^"%s^"",g_szDanceModel);
    precache_model(g_szDanceModel);

    g_iHandsVModel = engfunc(EngFunc_AllocString,g_szDanceModel);

    for(new i; i < MAX_SPRITES; i++)
    {
        if (!file_exists(g_szSpriteList[i],true))
        {
            hnr_dbg_message(HNR_DBG_NAME,dbg_fatal,"Failed to find sprite ^"%s^" (Fireworks Sprite); Plugin failed to load.",g_szSpriteList[i]);
            set_fail_state("[HitAndRun] Error loading sprite!");
        }

        hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Precache sprite file: ^"%s^"",g_szSpriteList[i]);
        g_pSprites[i] = precache_model(g_szSpriteList[i]);
    }
}

public plugin_end() {
    hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug ended");
}

public EventRoundStart(){
    g_bIsDancing = false;
    remove_task(TASKID_FIREWORKS);
}

public OnHNRWinner(client){
    static szClient[1];

    hnr_dbg_message(HNR_DBG_NAME,dbg_info,"OnHNRWinner called;");

    szClient[0] = client;
    g_bIsDancing = true;

    strip_user_weapons(client);
    give_item(client,"weapon_knife");
    set_pev(client,pev_viewmodel,g_iHandsVModel);

    set_task(1.0,"taskFireWorks",TASKID_FIREWORKS,szClient,1,"b");
}

public taskFireWorks(iParams[], taskid) {
    static i, client;
    client = iParams[0];

    if (!is_user_alive(client))
    {
        g_bIsDancing = false;
        remove_task(TASKID_FIREWORKS);
        return;
    }

    for (i = 0; i < MAX_SPRITES; i++)
        MakeWinnerFireWorks(client,g_pSprites[i]);
}
