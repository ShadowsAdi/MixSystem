/* Sublime AMXX Editor v4.2 */
#include <amxmodx>
#include <reapi>
#include <mix_system>

#define PLUGIN  "[MIX System] Player Drop"
#define VERSION "1.0"
#define AUTHOR  "Shadows Adi"

#define TASK_CHECK_TIME random_num(3721, 19210)

enum _:PlayerData
{
	szSteamID[MAX_NAME_LENGTH],
	szName[MAX_NAME_LENGTH]
}

new Array:g_aDroppedPlayers
new bool:g_bPlayerInTeam[MAX_PLAYERS + 1]
new g_ePlayerData[MAX_PLAYERS + 1][PlayerData]
new g_szPrefix[48]
new g_iTime
new g_iBanTime
new g_iSubstractPoints

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	bind_pcvar_num(create_cvar("mix_player_drop_time", "300", .description = "Time in seconds for player to reconnect"), g_iTime)
	bind_pcvar_num(create_cvar("mix_player_drop_ban", "120", .description = "Ban time for dropped player in seconds"), g_iBanTime)
	bind_pcvar_num(create_cvar("mix_player_drop_points", "25", .description = "Points to substract from player balance"), g_iSubstractPoints)

	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_RestartRound", 1)
}

public plugin_natives()
{
	g_aDroppedPlayers = ArrayCreate(PlayerData)
}

public OnConfigsExecuted()
{
	Mix_GetPrefix(g_szPrefix, charsmax(g_szPrefix))
}

public plugin_end()
{
	ArrayDestroy(g_aDroppedPlayers)
}

public client_authorized(id, const authid[])
{
	copy(g_ePlayerData[id][szSteamID], charsmax(g_ePlayerData[][szSteamID]), authid)
	get_user_name(id, g_ePlayerData[id][szName], charsmax(g_ePlayerData[][szName]))

	g_bPlayerInTeam[id] = false

	new iID = ArrayFindString(g_aDroppedPlayers, g_ePlayerData[id][szSteamID])
	if(iID != -1 && Mix_IsStarted() && !Mix_IsWarm())
	{
		ArrayDeleteItem(g_aDroppedPlayers, iID)
	}
}

public client_disconnected(id, bool:drop, message[], maxlen)
{
	if(Mix_IsStarted() && !Mix_IsWarm() && g_bPlayerInTeam[id])
	{
		static iData[PlayerData]
		copy(iData[szSteamID], charsmax(iData[szSteamID]), g_ePlayerData[id][szSteamID])
		copy(iData[szName], charsmax(iData[szName]), g_ePlayerData[id][szName])

		ArrayPushArray(g_aDroppedPlayers, iData)

		static iPlayer, iPlayers[MAX_PLAYERS], iNum
		get_players(iPlayers, iNum, "ch")

		for(new i; i < iNum; i++)
		{
			iPlayer = iPlayers[i]

			client_print_color(iPlayer, print_chat, "^4%s ^1%L", g_szPrefix, LANG_SERVER, "MIX_PLAYER_DROPPED", g_ePlayerData[id][szName], g_iTime / 60)
		}

		set_task(float(g_iTime), "task_check_time", TASK_CHECK_TIME)
	}
}

public task_check_time(id)
{
	if(!ArraySize(g_aDroppedPlayers))
	{
		return
	}

	if(!Mix_IsStarted())
	{ 
		return
	}

	new iData[PlayerData]

	for(new i; i < ArraySize(g_aDroppedPlayers); i++)
	{
		ArrayGetArray(g_aDroppedPlayers, i, iData)

		if(find_player_ex(FindPlayer_MatchAuthId, iData[szSteamID]))
		{
			ArrayDeleteItem(g_aDroppedPlayers, i)
		}
		else
		{
			new szTemp[100]
			formatex(szTemp, charsmax(szTemp), "amx_addban ^"%s^" ^"%s^" %d ^"%L^"", iData[szName], iData[szSteamID], g_iBanTime, LANG_SERVER, "MIX_PLAYER_DROPPED_REASON")
			
			Mix_SearchForUser(iData[szSteamID], g_iSubstractPoints, false)

			client_print_color(0, print_chat, "^4%s ^1%L", g_szPrefix, LANG_SERVER, "MIX_PLAYER_DROPPED_PUNISH", iData[szName], g_iBanTime / 60, g_iSubstractPoints)
			server_cmd(szTemp)
			server_exec()
			ArrayDeleteItem(g_aDroppedPlayers, i)
		}
	}
}

public RG_RestartRound()
{
	static iPlayers[MAX_PLAYERS], iPlayer, iNum, TeamName:iTeam
	get_players(iPlayers, iNum)

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		iTeam = get_member(iPlayer, m_iTeam)

		if(is_user_alive(iPlayer) && Mix_IsStarted() && iTeam != TEAM_SPECTATOR && iTeam != TEAM_UNASSIGNED)
		{
			g_bPlayerInTeam[iPlayer] = true
		}
		else 
		{
			g_bPlayerInTeam[iPlayer] = false
		}
	}
}
