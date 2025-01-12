/* Sublime AMXX Editor v4.2 */

#define MAX_HOSTNAME_LEN 5

#include <amxmodx>
#include <sqlx>
#include <cstrike>
#include <mix_system>
#include <reapi>

#define PLUGIN  "[MIX System] Player's Data + Match Data"
#define VERSION "1.8.1"
#define AUTHOR  "Shadows Adi"

new Handle:g_hSqlTuple
new Handle:g_iSqlConnection
new g_szSqlError[512]

#define PLAYERS_TABLE "points_sys_pstats"
#define MATCH_TABLE "points_sys_match"

new g_iGameID = 0

enum _:PlayerData
{
	sSteamID[32],
	sName[MAX_NAME_LENGTH],
	iKills,
	iDeaths,
	iHS,
	iWins,
	iMVP,
	szTeam[18],
	iUserPoints
}

new g_ePlayerData[MAX_PLAYERS + 1][PlayerData]

new g_szMap[48]

new g_iKills[MAX_PLAYERS + 1]

new Array:g_aPlayerDropped

new bool:g_bPlayerInTeam[MAX_PLAYERS + 1]

new g_szHostname[MAX_HOSTNAME_LEN]

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterHookChain(RG_RoundEnd, "RG_Round_End")
	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_RestartRound", 1)
	RegisterHookChain(RG_HandleMenu_ChooseTeam, "RG_ChooseTeam_Post", 1)

	get_mapname(g_szMap, charsmax(g_szMap))

	g_aPlayerDropped = ArrayCreate(32)

	if(!Mix_HasPointsSys())
	{
		new szPluginName[32]
		get_plugin(-1, szPluginName, charsmax(szPluginName))
		log_amx("[MIX System] Plugin ^"%s^" has been stopped because main plugin has no Points System active.", szPluginName)
		pause("a")
	}
}

public plugin_cfg()
{
	get_cvar_string("hostname", g_szHostname, charsmax(g_szHostname))
}

public plugin_end()
{
	ArrayDestroy(g_aPlayerDropped)
}

public mix_database_connected(Handle:hTuple, Handle:iSqlConn)
{
	g_hSqlTuple = hTuple
	g_iSqlConnection = iSqlConn

	if(g_iSqlConnection == Empty_Handle)
	{
		log_to_file("mix_system.log", "{%s} Failed to connect to database. Make sure databse settings are right!", PLUGIN)
		SQL_FreeHandle(g_iSqlConnection)
	}

	new szQueryData[612];
	formatex(szQueryData, charsmax(szQueryData), "CREATE TABLE IF NOT EXISTS `%s` \
	(`MatchID` int(11) NOT NULL,\
	  `SteamID` varchar(32) NOT NULL,\
	  `Name` varchar(32) DEFAULT NULL,\
	  `Wins` int(11) NOT NULL DEFAULT 0,\
	  `Kills` int(11) NOT NULL DEFAULT 0,\
	  `Deaths` int(11) NOT NULL DEFAULT 0,\
	  `HS` int(11) NOT NULL DEFAULT 0,\
	  `Duration` int(11) NOT NULL DEFAULT 0,\
	  `Team` varchar(18) DEFAULT '0',\
	  `Dropped` int(11) NOT NULL DEFAULT 0,\
	  `Points` int(11) NOT NULL DEFAULT 0,\
	  `MVPS` int(11) NOT NULL DEFAULT 0,\
	  `Winner` int(1) NOT NULL DEFAULT 0,\
		PRIMARY KEY(MatchID, SteamID));", PLAYERS_TABLE)

	SQL_ThreadQuery(g_hSqlTuple, "QueryHandler", szQueryData)

	formatex(szQueryData, charsmax(szQueryData), "CREATE TABLE IF NOT EXISTS `%s` \
	(`Server` varchar(5) NOT NULL,\
	`Duration` int(11) NOT NULL,\
	  `Map` varchar(48) DEFAULT NULL,\
	  `Winner` varchar(12) DEFAULT 'In Progress',\
	  `CTScore` int(11) NOT NULL,\
	  `TSCORE` int(11) NOT NULL,\
	  `Timestamp` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),\
	  `CT` VARCHAR(32) NOT NULL DEFAULT 'CT',\
	  `TE` VARCHAR(32) NOT NULL DEFAULT 'T',\
	  `Status` VARCHAR(32) NOT NULL DEFAULT 'In Progress',\
		PRIMARY KEY(MatchID));", MATCH_TABLE)

	SQL_ThreadQuery(g_hSqlTuple, "QueryHandler", szQueryData)
}

public client_authorized(id, const authid[])
{
	copy(g_ePlayerData[id][sSteamID], charsmax(g_ePlayerData[][sSteamID]), authid)
}

public mix_game_begin_pre()
{
	g_iGameID = 0

	DefineGame()
}

public mix_game_begin_post(id, bFinished, szAuthID[], szName[], iPoints)
{
	switch(get_member(id, m_iTeam))
	{
		case TEAM_CT:
		{
			formatex(g_ePlayerData[id][szTeam], charsmax(g_ePlayerData[][szTeam]), "COUNTER-TERRORIST")
		}
		case TEAM_TERRORIST:
		{
			formatex(g_ePlayerData[id][szTeam], charsmax(g_ePlayerData[][szTeam]), "TERRORIST")
		}
	}

	LoadPlayerData(id, szName, iPoints)
}

public LoadPlayerData(id, szName[], iPoints)
{
	copy(g_ePlayerData[id][sName], charsmax(g_ePlayerData[][sName]), szName)

	g_ePlayerData[id][iUserPoints] = iPoints

	LoadData(id)
}

public mix_player_killed(iVictim, iAttacker, bHeadshot, szName[], szAuthID[])
{
	g_ePlayerData[iAttacker][iKills] += 1
	g_ePlayerData[iAttacker][iHS] += bHeadshot

	g_iKills[iAttacker] += 1

	g_ePlayerData[iVictim][iDeaths] += 1
}

public mix_game_over(id, iDuration, iTeamWon, iPoints)
{
	new CsTeams:iTeam = cs_get_user_team(id)
	new szTemp[3]

	switch(iTeamWon)
	{
		case 'C':
		{
			formatex(szTemp, charsmax(szTemp), "CT")
			if(iTeam == CS_TEAM_CT)
			{
				g_ePlayerData[id][iWins] += 1
			}
		}
		case 'T':
		{
			formatex(szTemp, charsmax(szTemp), "T")

			if(iTeam == CS_TEAM_T)
			{
				g_ePlayerData[id][iWins] += 1
			}
		}
	}

	UpdateGame(iDuration, szTemp)
}

public mix_game_stopped(id, iDuration, iPoints)
{
	UpdateGame(iDuration, "Canceled")
}

public mix_match_winner(iPlayer)
{
	g_ePlayerData[iPlayer][iWins] += 1
}

SetDropped(id)
{
	if(Mix_IsStarted() && !Mix_IsWarm() && g_bPlayerInTeam[id])
	{
		new szQuery[128]
		formatex(szQuery, charsmax(szQuery), "UPDATE `%s` \
			SET `Dropped` = '1' \
			WHERE `SteamID`=^"%s^" AND `MatchID` = '%d';", PLAYERS_TABLE, g_ePlayerData[id][sSteamID], g_iGameID)

		ArrayPushString(g_aPlayerDropped, g_ePlayerData[id][sSteamID])

		SQL_ThreadQuery(g_hSqlTuple, "QueryHandler", szQuery, szQuery, sizeof(szQuery))
	}
}

public client_disconnected(id, bool:drop, message[], maxlen)
{
	if(Mix_IsStarted() && !Mix_IsWarm() && g_bPlayerInTeam[id])
		SetDropped(id)
}

public mix_game_new_round(iCTScore, iTeroScore, iDuration)
{
	new szQuery[120]

	formatex(szQuery, charsmax(szQuery), "UPDATE `%s` SET `CTScore`='%d', `TSCORE`='%d', `Duration`='%d' WHERE `MatchID` = '%d';", MATCH_TABLE, iCTScore, iTeroScore, iDuration, g_iGameID)

	SQL_ThreadQuery(g_hSqlTuple, "QueryHandler", szQuery)
}

public RG_Round_End(WinStatus:status, ScenarioEventEndRound:event, Float:fDelay)
{
	set_task(0.5, "CalculateTopKiller")

	return HC_CONTINUE
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

#define TASK_TEAM 2938

public RG_ChooseTeam_Post(id, MenuChooseTeam:slot)
{
	if(slot == MenuChoose_CT || slot == MenuChoose_T)
	{
		set_task(0.1, "task_check_team", id + TASK_TEAM)
	}

	if(slot == MenuChoose_Spec && g_bPlayerInTeam[id])
	{
		SetDropped(id)
	}
}

public task_check_team(id)
{
	id -= TASK_TEAM

	if(Mix_IsStarted() && is_user_connected(id))
	{
		new pID = ArrayFindString(g_aPlayerDropped, g_ePlayerData[id][sSteamID])

		if(pID != -1)
		{
			new szQuery[128]
			formatex(szQuery, charsmax(szQuery), "UPDATE `%s` \
				SET `Dropped` = '0' \
				WHERE `SteamID`=^"%s^" AND `MatchID` = '%d';", PLAYERS_TABLE, g_ePlayerData[id][sSteamID], g_iGameID)

			SQL_ThreadQuery(g_hSqlTuple, "QueryHandler", szQuery)

			ArrayDeleteItem(g_aPlayerDropped, pID)
		}

		new TeamName:iTeam = get_member(id, m_iTeam)

		if(iTeam != TEAM_UNASSIGNED && iTeam != TEAM_SPECTATOR)
		{
			new szName[MAX_NAME_LENGTH]
			Mix_GetUserName(id, szName, charsmax(szName))

			switch(iTeam)
			{
				case TEAM_CT:
				{
					formatex(g_ePlayerData[id][szTeam], charsmax(g_ePlayerData[][szTeam]), "COUNTER-TERRORIST")
				}
				case TEAM_TERRORIST:
				{
					formatex(g_ePlayerData[id][szTeam], charsmax(g_ePlayerData[][szTeam]), "TERRORIST")
				}
			}

			LoadPlayerData(id, szName, Mix_UserPoints(id))
		}
	}
}

public mix_user_save(iPlayer)
{
	if(!is_user_connected(iPlayer) || !Mix_IsStarted() || !g_bPlayerInTeam[iPlayer])
		return

	switch(get_member(iPlayer, m_iTeam))
	{
		case TEAM_CT:
		{
			formatex(g_ePlayerData[iPlayer][szTeam], charsmax(g_ePlayerData[][szTeam]), "COUNTER-TERRORIST")
		}
		case TEAM_TERRORIST:
		{
			formatex(g_ePlayerData[iPlayer][szTeam], charsmax(g_ePlayerData[][szTeam]), "TERRORIST")
		}
	}

	new szQuery[250]
	formatex(szQuery, charsmax(szQuery), "UPDATE `%s` \
		SET `Name`=^"%s^",\
		`Kills`='%d',\
		`HS`='%d', \
		`Deaths`='%d',\
		`MVPS`='%d', \
		`Team`='%s' \
		WHERE `SteamID`=^"%s^" AND `MatchID` = '%d';",
		PLAYERS_TABLE, g_ePlayerData[iPlayer][sName], g_ePlayerData[iPlayer][iKills], g_ePlayerData[iPlayer][iHS],
		g_ePlayerData[iPlayer][iDeaths], g_ePlayerData[iPlayer][iMVP], g_ePlayerData[iPlayer][szTeam], g_ePlayerData[iPlayer][sSteamID], g_iGameID)

	SQL_ThreadQuery(g_hSqlTuple, "QueryHandler", szQuery)
}

public CalculateTopKiller()
{
	new iPlayers[32], iNum, iPlayer

	switch(get_member_game(m_iRoundWinStatus))
	{
		case 1:
		{
			get_players(iPlayers, iNum, "ceh", "CT")
		}
		case 2:
		{
			get_players(iPlayers, iNum, "ceh", "TERRORIST")
		}
	}

	new iFrags, iTemp, iTempID
	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		iFrags = g_iKills[iPlayer]

		if(iFrags > iTemp)
		{
			iTemp = iFrags
			iTempID = iPlayer
		}
	}

	if(0 < iTempID)
	{
		g_ePlayerData[iTempID][iMVP] += 1
	}

	arrayset(g_iKills, 0, sizeof(g_iKills))			
}

public QueryHandlerLoad(iFailState, Handle:iQuery, szError[], iErrorCode, sTemp[])
{
	switch(iFailState)
	{
		case TQUERY_CONNECT_FAILED: 
		{
			log_to_file("mix_system.log", "[SQL Error] Connection failed (%i): %s", iErrorCode, szError);
			return 
		}
		case TQUERY_QUERY_FAILED:
		{
			log_to_file("mix_system.log", "[SQL Error] Query failed (%i): %s", iErrorCode, szError);
			return
		}
	}

	new id = sTemp[0]
	new szQuery[328]
	new szTemp[2]

	if(!SQL_NumResults( iQuery ))
	{
		formatex(szQuery, charsmax(szQuery), "INSERT INTO `%s` \
			(`MatchID`,\
			`SteamID`,\
			`Name`,\
			`Wins`,\
			`Kills`,\
			`Deaths`,\
			`HS`,\
			`Duration`,\
			`Team`,\
			`Dropped`, \
			`Points`,\
			`MVPS`,\
			`Winner`\
			) VALUES ('%d', ^"%s^", ^"%s^", '0', '0', '0', '0', '0', '%s', '0', '0', '0', '0');", PLAYERS_TABLE, g_iGameID, g_ePlayerData[id][sSteamID], g_ePlayerData[id][sName], g_ePlayerData[id][szTeam]);
	}
	else
	{
		formatex(szQuery, charsmax(szQuery), "SELECT \
			`Wins`,\
			`Kills`,\
			`Deaths`,\
			`HS`,\
			`MVPS`\
			FROM `%s` WHERE `SteamID` = '%s' AND `MatchID` = '%d';", PLAYERS_TABLE, g_ePlayerData[id][sSteamID], g_iGameID);

		szTemp[1] = 1
	}

	szTemp[0] = id

	SQL_ThreadQuery(g_hSqlTuple, "HandleLoad", szQuery, szTemp, sizeof(szTemp))
}

public HandleLoad(iFailState, Handle:iQuery, szError[], iErrorCode, sTemp[])
{
	switch(iFailState)
	{
		case TQUERY_CONNECT_FAILED: 
		{
			log_to_file("mix_system.log", "[SQL Error] Connection failed (%i): %s", iErrorCode, szError);
			return 
		}
		case TQUERY_QUERY_FAILED:
		{
			log_to_file("mix_system.log", "[SQL Error] Query failed (%i): %s", iErrorCode, szError);
			return 
		}
	}

	if(sTemp[1] == 0)
		return

	new id = sTemp[0]

	g_ePlayerData[id][iKills] = SQL_ReadResult(iQuery, SQL_FieldNameToNum(iQuery, "Kills"))

	g_ePlayerData[id][iDeaths] = SQL_ReadResult(iQuery, SQL_FieldNameToNum(iQuery, "Deaths"))

	g_ePlayerData[id][iHS] = SQL_ReadResult(iQuery, SQL_FieldNameToNum(iQuery, "HS"))

	g_ePlayerData[id][iWins] = SQL_ReadResult(iQuery, SQL_FieldNameToNum(iQuery, "Wins"))

	g_ePlayerData[id][iMVP] = SQL_ReadResult(iQuery, SQL_FieldNameToNum(iQuery, "MVPS"))
}

public QueryHandler(iFailState, Handle:iQuery, szError[], iErrorCode)
{
	switch(iFailState)
	{
		case TQUERY_CONNECT_FAILED: 
		{
			log_to_file("mix_system.log", "[SQL Error] Connection failed (%i): %s", iErrorCode, szError);		}
		case TQUERY_QUERY_FAILED:
		{
			log_to_file("mix_system.log", "[SQL Error] Query failed (%i): %s", iErrorCode, szError);
		}
	}
}

stock SQL_Exec(Handle:iQuery, szQueryData[])
{
	if(!SQL_Execute(iQuery))
	{
		SQL_QueryError(iQuery, g_szSqlError, charsmax(g_szSqlError))
		log_to_file("mix_system_stats.log", "[%s] %s Query %s", PLUGIN, g_szSqlError, szQueryData)

		SQL_FreeHandle(iQuery)

		return -1
	}

	return 1
}

DefineGame()
{
	new Handle:iQuery, szQuery[150]

	formatex(szQuery, charsmax(szQuery), "INSERT INTO `%s` (`Server`, `Duration`, `Map`, `CTScore`, `TSCORE`) VALUES('%s', '0', '%s', '0', '0');", MATCH_TABLE, g_szHostname, g_szMap)

	iQuery = SQL_PrepareQuery(g_iSqlConnection, szQuery);

	if(!SQL_Exec(iQuery, szQuery))
		return

	if(g_iGameID == 0)
	{
		g_iGameID = SQL_GetInsertId(iQuery)
	}

	if(iQuery != Empty_Handle)
		SQL_FreeHandle(iQuery)
}

UpdateGame(iDuration, sTeam[] = "In Progress")
{
	new szQuery[200]

	formatex(szQuery, charsmax(szQuery), "UPDATE `%s` SET `Duration`='%d', `Winner`=^"%s^", `Status` = ^"Finished^" WHERE `MatchID` = '%d';", MATCH_TABLE, iDuration, sTeam, g_iGameID)

	SQL_ThreadQuery(g_hSqlTuple, "QueryHandler", szQuery)
}

LoadData(id)
{
	new szQuery[128]
	formatex(szQuery, charsmax(szQuery), "SELECT * FROM `%s` WHERE `SteamID` = ^"%s^" AND `MatchID` = '%d';", PLAYERS_TABLE, g_ePlayerData[id][sSteamID], g_iGameID)
	
	new sTemp[2]
	sTemp[0] = id

	SQL_ThreadQuery(g_hSqlTuple, "QueryHandlerLoad", szQuery, sTemp, charsmax(sTemp))
}
