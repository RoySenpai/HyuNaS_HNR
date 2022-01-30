/*
    HNR Addon: Events for HyuNaS HitAndRun v2.0
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
#include <fakemeta>
#include <fun>
#include <hitandrun>

// Defines the HNR Debug message tag for this plugin.
#define HNR_DBG_NAME        "HNR Events"

enum _:eCvars
{
    cEnabled,
    cRounds
};

new const g_dCvars[eCvars][eCvarsData] = {
    { "hnr_events", "1", "Toggle events addon status" },
    { "hnr_events_rnd", "7", "Sets how many rounds an event will playout" }
};

new g_iCvars[eCvars];

new g_iJumpStyleCvar, JumpStyleTmp;

new g_iRounds;
new g_iCurrentEvent = eNone;

new g_iWinXpCvar, g_iWinCashCvar, g_iBonusXpCvar, g_iBonusCashCvar;

new g_fwdOnHNREventStart;

public plugin_init() {
    register_plugin("[HNR Addon] Events",get_hnr_version(),"HiyoriX");

    for (new i = 0; i < eCvars; i++)
        g_iCvars[i] = create_cvar(g_dCvars[i][cName],g_dCvars[i][cDefValue],(FCVAR_SERVER | FCVAR_PRINTABLEONLY),g_dCvars[i][cDescription],true,(i == cRounds ? 1.0:0.0),(i == cRounds ? false:true),1.0);

    register_clcmd("say /event","cmdShowEvent");
    register_clcmd("say /events","cmdShowEvent");

    register_logevent("EventRoundStart",2,"1=Round_Start");

    g_fwdOnHNREventStart = CreateMultiForward("OnHNREventStart",ET_STOP,FP_CELL);

    register_dictionary("hnr_events.txt");
}

public plugin_precache() {
    hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug started");
}

public plugin_cfg() {
    g_iJumpStyleCvar = get_cvar_pointer("hnr_jumpstyle");
    JumpStyleTmp = g_iJumpStyleCvar;

    g_iWinXpCvar = get_cvar_pointer("hnr_winxp");
    g_iWinCashCvar = get_cvar_pointer("hnr_wincash");
    g_iBonusXpCvar = get_cvar_pointer("hnr_bonusxp");
    g_iBonusCashCvar = get_cvar_pointer("hnr_bonuscash");
}

public plugin_end() {
    hnr_dbg_message(HNR_DBG_NAME,dbg_any,"Debug ended");
}

public plugin_natives() {
    register_native("get_round_event","_get_round_event");
}

public _get_round_event(pluginid, params) {
    hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Native ^"get_round_event^" call - PluginID: %d",pluginid);

    return g_iCurrentEvent;
}

public EventRoundStart() {
    static players[MAX_PLAYERS], pnum;

    if (!isHNREnabled())
        return;

    hnr_dbg_message(HNR_DBG_NAME,dbg_info,"New round started, removing fog, redrawing players and returning gravity to normal.");

    make_fog();
    g_iCurrentEvent = eNone;

    get_players(players,pnum,"ch");

    for (new i = 0; i < pnum; i++)
    {
        new p = players[i];
        set_pev(p,pev_effects,(pev(p,pev_effects) & ~EF_NODRAW));
        set_user_gravity(p,1.0);
    }
}

public cmdShowEvent(client) {
    if (!isHNREnabled())
        return PLUGIN_CONTINUE;

    if (!get_pcvar_num(g_iCvars[cEnabled]))
        return PLUGIN_CONTINUE;

    if (!g_iCurrentEvent)
    {
        new rnd = get_pcvar_num(g_iCvars[cRounds]) - g_iRounds;

        if (!rnd)
            client_print_color(client,print_team_red,"%s %L",TAG,client,"EVN_CHECK_THIS_RND");

        else if (rnd == 1)
            client_print_color(client,print_team_red,"%s %L",TAG,client,"EVN_CHECK_NEXT_RND");

        else
            client_print_color(client,print_team_red,"%s %L",TAG,client,"EVN_CHECK_X_RND",rnd);
    }

    else
        client_print_color(client,print_team_red,"%s ^3Current event^1 is: ^4%s^1.",TAG,client,"EVN_CHECK_CURRENT",g_szEvents[g_iCurrentEvent]);

    return PLUGIN_CONTINUE;
}

public OnHNRRoundStart() {
    static players[MAX_PLAYERS], pnum, ret;

    if (!get_pcvar_num(g_iCvars[cEnabled]))
        return PLUGIN_CONTINUE;

    if (get_humans_count() < 2)
    {
        hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Not enought players to start an event; Rollback to Core plugin");
        return PLUGIN_CONTINUE;
    }

    if (++g_iRounds > get_pcvar_num(g_iCvars[cRounds]))
    {
        get_players(players,pnum,"aceh","TERRORIST");
        g_iRounds = 0;

        g_iCurrentEvent = random_num(eBhop,eDouble);

        hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward call: OnHNREventStart");
        ExecuteForward(g_fwdOnHNREventStart,ret,g_iCurrentEvent);

        if (ret > 0)
        {
            hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Forward call ^"OnHNREventStart^" returned %d, blocking from event starting.",ret);
            return PLUGIN_CONTINUE;
        }

        hnr_dbg_message(HNR_DBG_NAME,dbg_info,"Random event started: %s",g_szEvents[g_iCurrentEvent]);

        set_dhudmessage(255,0,0,-1.0,0.30,0,6.0,12.0,0.25,0.25);
        show_dhudmessage(0,"%L %s",LANG_PLAYER,"EVN_MSG_STARTED",g_szEvents[g_iCurrentEvent]);

        client_print_color(0,print_team_red,"%s ^3%L ^4%s",TAG,LANG_PLAYER,"EVN_MSG_STARTED",g_szEvents[g_iCurrentEvent]);

        set_hnr_status(GameRunning);
        make_random_infection();

        switch(g_iCurrentEvent)
        {
            case eBhop:
            {
                JumpStyleTmp = get_pcvar_num(g_iJumpStyleCvar);
                set_pcvar_num(g_iJumpStyleCvar,2);

                for (new i = 0; i < pnum; i++)
                {
                    new p = players[i];

                    give_item(p,"weapon_knife");
                    give_item(p,"weapon_scout");

                    give_item(p,"weapon_hegrenade");
                    give_item(p,"weapon_flashbang");
                    give_item(p,"weapon_flashbang");
                    give_item(p,"weapon_smokegrenade");
                }
            }

            case ePistols:
            {
                for (new i = 0; i < pnum; i++)
                {
                    give_item(players[i],"weapon_usp");
                    cs_set_user_bpammo(players[i],CSW_USP,999);
                }
            }

            case eGrenades:
            {
                for (new i = 0; i < pnum; i++)
                {
                    new p = players[i];

                    give_item(p,"weapon_hegrenade");
                    give_item(p,"weapon_flashbang");
                    give_item(p,"weapon_flashbang");
                    give_item(p,"weapon_smokegrenade");

                    cs_set_user_bpammo(p,CSW_HEGRENADE,999);
                }
            }

            case eKnives:
            {
                for (new i = 0; i < pnum; i++)
                    give_item(players[i],"weapon_knife");
            }

            case eFog:
            {
                make_fog(g_iFogColors[0],g_iFogColors[1],g_iFogColors[2],FOG_DENSITY);
                fm_set_lights(g_iFogLight);
            }

            case eGravity:
            {
                for (new i = 0; i < pnum; i++)
                {
                    new p = players[i];

                    give_item(p,"weapon_knife");
                    give_item(p,"weapon_scout");

                    give_item(p,"weapon_hegrenade");
                    give_item(p,"weapon_flashbang");
                    give_item(p,"weapon_flashbang");
                    give_item(p,"weapon_smokegrenade");

                    set_user_gravity(p,EVN_GRAVITY_MUL);
                }
            }

            case eDouble:
            {
                for (new i = 0; i < pnum; i++)
                {
                    new p = players[i];

                    give_item(p,"weapon_knife");
                    give_item(p,"weapon_scout");

                    give_item(p,"weapon_hegrenade");
                    give_item(p,"weapon_flashbang");
                    give_item(p,"weapon_flashbang");
                    give_item(p,"weapon_smokegrenade");
                }
            }
        }

        return PLUGIN_HANDLED;
    }

    return PLUGIN_CONTINUE;
}

public OnHNRInfection(client, infector) {
    if (!get_pcvar_num(g_iCvars[cEnabled]))
        return PLUGIN_CONTINUE;

    switch(g_iCurrentEvent)
    {
        case eFog:
        {
            set_pev(client,pev_effects,(pev(client,pev_effects) | EF_NODRAW));

            if (isClientValid(infector,true,false))
                set_pev(infector,pev_effects,(pev(infector,pev_effects) & ~EF_NODRAW));
        }
    }

    return PLUGIN_CONTINUE;
}

public OnHNRKilled(client, idkiller) {
    if (!get_pcvar_num(g_iCvars[cEnabled]))
        return;

    switch(g_iCurrentEvent)
    {
        case eFog: set_pev(client,pev_effects,(pev(client,pev_effects) & ~EF_NODRAW));

        case eDouble:
        {
            if (isClientValid(idkiller,true,false))
            {
                set_user_cash(idkiller,(get_user_cash(idkiller) + get_pcvar_num(g_iBonusCashCvar)));
                set_user_xp(idkiller,(get_user_xp(idkiller) + get_pcvar_num(g_iBonusXpCvar)));

                client_print_color(idkiller,print_team_red,"%s %L",TAG,idkiller,"EVN_MSG_DOUBLE",g_szEvents[g_iCurrentEvent]);
            }
        }
    }
}

public OnHNRWinner(client) {
    if (!get_pcvar_num(g_iCvars[cEnabled]))
        return;

    switch(g_iCurrentEvent)
    {
        case eBhop: set_pcvar_num(g_iJumpStyleCvar,JumpStyleTmp);

        case eFog: set_pev(client,pev_effects,(pev(client,pev_effects) & ~EF_NODRAW));

        case eDouble:
        {
            set_user_cash(client,(get_user_cash(client) + get_pcvar_num(g_iWinCashCvar)));
            set_user_xp(client,(get_user_xp(client) + get_pcvar_num(g_iWinXpCvar)));

            client_print_color(client,print_team_red,"%s %L",TAG,client,"EVN_MSG_DOUBLE",g_szEvents[g_iCurrentEvent]);
        }
    }
}
