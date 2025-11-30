/* Sublime AMXX Editor v4.2 */

/* 	Activare sistem de puncte 
	Activate Points system 
*/
#define POINTS_SYS

/* 	Mod Fastcup ( /start, runda de cutite automata, alegere a echipei de catre echipa castigatoare ) 
	Fastcup Mode ( /start, automatic knife round, choose start side by winning team )
*/
#define FASTCUP_MODE

/* 	Modificarea indicilor kickback ale armelor care suporta acest lucru 
	Modifying supported weapons kickback angles
*/
//#define PUNCH_ANGLE

/* 	Optiuni pentru debugging, nu recomand a se porni daca nu se testeaza 
	Debugging messages, uncomment only if you're testing
*/
//#define DEBUG

/* 	Overtime-ul este doar de o runda, setarile din overtime.cfg se aplica 
   	Only one round of overtime, settings from overtime.cfg applies
*/
//#define OVERTIME_ONE_ROUND

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <reapi>
#if defined POINTS_SYS
#include <sqlx>
#endif
#include <regex>
#include <mix_system>

#define PLUGIN  "Mix System"
#if defined FASTCUP_MODE
#undef PLUGIN
#define PLUGIN  "Mix System ~ Fastcup Mode"
#endif

#define VERSION "2.19.5"
#define AUTHOR  "Shadows Adi"

#define IsPlayer(%1)				((1 <= %1 <= MAX_PLAYERS) && is_user_connected(%1))
#define NATIVE_ERROR				-1

enum (+=1200)
{
	TASK_WARM = 8200,
	TASK_SET_MONEY,
	TASK_GIVE_WEAPON,
	TASK_SWAP,
	TASK_REVIVE,
	TASK_CHANGE_BOOL,
	#if defined FASTCUP_MODE
	TASK_ASK,
	TASK_CHECKVOTES,
	#endif
	TASK_SPECALL,
	TASK_LOAD,
	TASK_COUNT_DURATION
}

enum MatchState
{
	MATCHSTATE_WARM = 0,
	MATCHSTATE_IN_MATCH,
	MATCHSTATE_KNIFE_ROUND,
	MATCHSTATE_OVERTIME
}

new const CHAT_PREFIX[]			=		"CHAT_PREFIX"
new const OVERTIME_ROUNDS[]		=		"OVERTIME_ROUNDS"
new const OVERTIME_SCORE[]		=		"OVERTIME_SCORE"
new const MIX_END_ROUND[]		=		"MIX_END_ROUND"
new const ADMIN_CHAT_FLAGS[]	=		"ADMIN_CHAT_FLAGS"
new const ADMIN_ACCESS[]		=		"ADMIN_LEVEL_ACCESS"
new const FREEZETIME_SWAP[]		=		"FREEZE_TIME_SWAP"
new const AUTO_OVERTIME[]		=		"AUTOMATIC_OVERTIME"
new const START_CFG[]			=		"START_CONFIG"
new const STOP_CFG[]			=		"STOP_CONFIG"
new const OVERTIME_CFG[]		=		"OVERTIME_CONFIG"
new const FREEZETIME[]			=		"FREEZETIME"
new const PAUSE_TIME[]			=		"PAUSE_DURATION"
new const TEN_REQUIRED[]		=		"START_TEN_REQUIRED"
new const KNIFE_ROUND_DELAY[]	=		"KNIFE_ROUND_START_DELAY"
new const DEFAULT_POINTS[]		=		"DEFAULT_START_POINTS"
new const FORCE_WARMUP[]		=		"FORCE_WARMUP"
new const SHOW_COMMANDS[]		=		"SHOW_COMMANDS"
new const START_COMMANDS[]		=		"START_MIX_COMMANDS"
new const STOP_COMMANDS[]		=		"STOP_MIX_COMMANDS"
new const WARM_COMMANDS[]		=		"WARM_COMMANDS"
new const KNIFE_COMMANDS[]		=		"KNIFE_COMMANDS"
new const CHAT_ON_COMMANDS[]	=		"CHAT_ON_COMMANDS"
new const CHAT_OFF_COMMANDS[]	=		"CHAT_OFF_COMMANDS"
new const OVERTIME_COMMANDS[]	=		"OVERTIME_COMMANDS"
new const PASSON_COMMANDS[]		=		"PASSWORD_ON_COMMANDS"
new const PASSOFF_COMMANDS[]	=		"PASSWORD_OFF_COMMANDS"
new const SPECALL_COMMANDS[]	=		"SPECALL_COMMANDS"
new const RESTART_COMMANDS[]	=		"RESTART_COMMANDS"
new const SCORE_COMMANDS[]		=		"SCORE_COMMANDS"
new const CT_COMMANDS[]			=		"MOVE_CT_COMMANDS"
new const T_COMMANDS[]			=		"MOVE_TERO_COMMANDS"
new const SPEC_COMMANDS[]		=		"MOVE_SPEC_COMMANDS"
new const STARTDEMO_COMMANDS[]	=		"START_DEMO_COMMANDS"
new const STOPDEMO_COMMANDS[]	=		"STOPDEMO_COMMANDS"
new const PAUSE_COMMANDS[]		=		"PAUSE_COMMANDS"
new const WARM_TYPE[]			=		"WARMUP_TYPE"
new const WARM_SPAWN_MONEY[]	=		"WARMUP_SPAWN_MONEY"
new const WARM_WEAPON_CT[]		=		"WARMUP_WEAPON_CT"
new const WARM_WEAPON_TERO[]	=		"WARMUP_WEAPON_TERO"
new const WARM_PISTOL[]			=		"WARMUP_PISTOL"
new const WARM_BP_AMMO[]		=		"WARMUP_BP_AMMO"
new const HUD_COLORS[]			=		"HUD_COLOR"
new const HUD_POSITION[]		=		"HUD_POSITION"
new const DEMO_AUTO[]			=		"AUTO_DEMO"
new const DEMO_TYPE[]			= 		"DEMO_TYPE"
new const DEMO_NAME[]			=		"DEMO_NAME"
#if defined POINTS_SYS
new const RESET_COMMANDS[]		=		"RESET_COMMANDS"
new const TOP_COMMANDS[]		=		"RANK_COMMANDS"
new const DBASE_HOST[]			=		"DATABASE_HOST"
new const DBASE_USER[]			=		"DATABASE_USERNAME"
new const DBASE_PASS[]			=		"DATABASE_PASSWORD"
new const DBASE_NAME[]			=		"DATABASE_NAME"
new const DBASE_TABLE[]			=		"DATABASE_TABLE"
new const POINTS_ADD[]			=		"POINTS_ADD"
new const POINTS_ADD_HS[]		=		"POINTS_ADD_HS"
new const POINTS_ADD_KNIFE[]	=		"POINTS_ADD_KNIFE"
new const POINTS_ADD_KNIFE_HS[]	=		"POINTS_ADD_KNIFE_HS"
new const POINTS_ADD_GRENADE[]	=		"POINTS_ADD_HE_GRENADE"
new const POINTS_SUB[]			=		"POINTS_SUB"
new const POINTS_SUB_HS[]		=		"POINTS_SUB_HS"
new const POINTS_SUB_KNIFE[]	=		"POINTS_SUB_KNIFE"
new const POINTS_SUB_KNIFE_HS[]	=		"POINTS_SUB_KNIFE_HS"
new const POINTS_SUB_GRENADE[]	=		"POINTS_SUB_HE_GRENADE"
new const POINTS_SUB_SUICIDE[]	=		"POINTS_SUB_SUICIDE"
new const POINTS_SUB_TK[]		=		"POINTS_SUB_TK"
new const POINTS_EXPLODED[]		=		"POINTS_EXPLODED"
new const POINTS_DEFUSED[]		=		"POINTS_DEFUSED"
new const POINTS_PLANTED[]		=		"POINTS_PLANTED"
new const POINTS_ACE[]			=		"POINTS_ACE"
new const POINTS_SEMIACE[]		=		"POINTS_SEMIACE"
new const POINTS_TWIN[]			=		"POINTS_TEAM_WIN"
new const POINTS_SHOW_NAME[]	=		"POINTS_SHOW_NAME"
#endif

#if defined POINTS_SYS
new const name[] = "name"
#endif

enum
{
	SETTINGS_SECTION = 1,
	COMMANDS_SECTION,
	WARM_SETTINGS,
	HUD_SETTINGS,
	DEMO_SETTINGS,
	POINTS_SYSTEM,
	RANK_SYSTEM
}

enum _:Settings
{
	szPrefix[64],
	iRoundOvertime,
	iMixEndRound,
	iOvertimeScore[5],
	szAdminFlags[22],
	szAdminAccess[4],
	iFreezetimeSwap,
	iAutoOvertime,
	szStartCfg[32],
	szOvertimeCfg[32],
	iPauseTime,
	bool:bRequireTen,
	iKnifeStartDelay,
	iStartPoints,
	bool:bForceWarmup,
	#if defined POINTS_SYS
	szStopCfg[32],
	szHostname[48],
	szUsername[48],
	szPassword[48],
	szDatabaseName[32],
	szTable[32],
	#else
	szStopCfg[32]
	#endif
}

enum _:WarmSettings
{
	bool:bWarmType,
	iWarmMoney[6],
	szWeaponCT[16],
	szWeaponT[16],
	szPistol[16],
	iBpAmmo
}

enum _:DemoSettings
{
	iDemoAuto,
	iDemoType,
	szDemoName[32],
}

enum
{
	DEMO_MAPNAME,
	DEMO_CUSTOM_NAME,
	DEMO_CIN_NAME
}

enum _:Score
{
	CT_SCORE,
	TERO_SCORE,
	CT_OVER_SCORE,
	TERO_OVER_SCORE,
	DRAW // Unusable, only for equal case in OverTime
}

enum
{
	CT_LAST = 1,
	T_LAST
}

enum _:Infos
{
	MIX_STARTER[MAX_NAME_LENGTH],
	MIX_STOPER[MAX_NAME_LENGTH],
	CHAT[MAX_NAME_LENGTH],
	WARM_CALLER[MAX_NAME_LENGTH],
	KNIFE_STRATER[MAX_NAME_LENGTH],
	OVERTIME_STARTER[MAX_NAME_LENGTH],
	PASSON_CALLER[MAX_NAME_LENGTH],
	PASSOFF_CALLER[MAX_NAME_LENGTH],
	SPECALL_CALLER[MAX_NAME_LENGTH],
	ACE[MAX_NAME_LENGTH],
	SEMI_ACE[MAX_NAME_LENGTH]
}

enum _:Bools
{
	#if defined FASTCUP_MODE
	bool:bWasKnife,
	#endif
	bool:bCanChat[MAX_PLAYERS + 1],
	bool:bIsMixOn,
	bool:bIsKnife,
	bool:bIsWarm,
	bool:bTeamSwap,
	bool:bOvertime,
	bool:bIsStoppingMix,
	bool:bCanShowStats
}

enum _:HudSettings
{
	Float:fHudPosX,
	Float:fHudPosY,
	iHudColorR,
	iHudColorG,
	iHudColorB
}

enum _:OVERTIME
{
	bool:FirstOvertime,
	bool:SecondOvertime
}

enum 
{
	SPEC,
	CT,
	TERO
}

enum _:Pdata
{
	STEAMID[32],
	KILLS,
	DEATHS,
	MONEY
}

#if defined FASTCUP_MODE
new g_iPlayers

enum _:TeamAnswers
{
	SWITCH = 0,
	STAY
}
#endif

enum _:PlayerScore
{
	iKILLS,
	iDEATHS
}

enum _:Teams
{
	CT_PAUSE,
	TERO_PAUSE
}

enum _:PlayerStats
{
	DamageGiven,
	HitsGiven,
	PlayerHealth
}

enum _:Forwards
{
	Kill,
	GameOver,
	GameBeginPre,
	GameBeginPost,
	GameStopped,
	NewRound,
	DatabaseConnected,
	Winners,
	Save,
	MaxFwds
}

#if defined POINTS_SYS
enum _:PointsSystem 
{
	PointsAdd,
	PointsAddHS,
	PointsAddKnife,
	PointsAddKnifeHS,
	PointsAddGrenade,
	PointsSub,
	PointsSubHS,
	PointsSubKnife,
	PointsSubKnifeHS,
	PointsSubGrenade,
	PointsSubSuicide,
	PointsSubTK,
	PointsExploded,
	PointsDefused,
	PointsPlanted,
	PointsAce,
	PointsSemiAce,
	PointsTeamWin,
	PointsShowName
}

enum
{
	UPDATE_ROUND = 0,
	UPDATE_TEAMCHANGE
}

enum _:Ranking
{
	szRank[6],
	iRankPoints
}

new Array:g_aRanks

new g_ePointSystem[PointsSystem]
new g_iPoints[MAX_PLAYERS + 1]
new g_iKills[MAX_PLAYERS + 1]
new g_iDeaths[MAX_PLAYERS + 1]
new g_iWins[MAX_PLAYERS + 1]
new g_iLose[MAX_PLAYERS + 1]
new Handle:g_hSqlTuple
new g_szSqlError[512]
new Handle:g_iSqlConnection
new g_iBombPlanter
new bool:g_bConnected
new g_iTry
new g_iIndex
new g_szBuffer[2500]
new bool:g_bLoadedPlayer[MAX_PLAYERS + 1]
#endif
new Array:g_aStartCmds
new Array:g_aStopCmds
new Array:g_aWarmCmds
new Array:g_aKnifeCmds
new Array:g_aChatOnCmds
new Array:g_aChatOffCmds
new Array:g_aOvertimeCmds
new Array:g_aPassOnCmds
new Array:g_aPassOffCmds
new Array:g_aSpecAllCmds
new Array:g_aCTCmds
new Array:g_aTCmds
new Array:g_aSpecCmds
new Array:g_aStartDemoCmds
new Array:g_aStopDemoCmds

new g_ePluginSettings[Settings]
new g_eHudSettings[HudSettings]
new g_eWarmSettings[WarmSettings]
new g_eInformations[Infos]
new g_eDemoSettings[DemoSettings]

new g_eOvertime[OVERTIME]
new g_iOvertimeScore[Score]

new g_iScore[Score]
new g_iRoundNum
new g_iKnifes
new g_iStart

new g_szName[MAX_PLAYERS + 1][MAX_NAME_LENGTH]
new g_szAuthID[MAX_PLAYERS][32]
new Array:g_aPlayerData

new g_eBooleans[Bools]

new g_cFreezeTime
new g_iFreezeTime

new g_iPlayerKills[MAX_PLAYERS + 1]
new g_szWeapon[MAX_PLAYERS + 1][32]

new g_ePlayerScore[MAX_PLAYERS + 1][PlayerScore]

new g_eTeamPause[Teams]
new bool:g_bPaused
new g_iTimer

#if defined FASTCUP_MODE
new bool:g_bVoted
new g_iVote
new g_iAnswer[TeamAnswers]
#endif

new g_ePlayerStats[MAX_PLAYERS + 1][MAX_PLAYERS + 1][PlayerStats]

new g_eForwards[Forwards]
new g_iDuration

new g_iRet

new Regex:g_rePattern

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_cvar("mix_sys", VERSION, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)

	register_dictionary("mix_system.txt")

	register_clcmd("say", "hook_say")

	register_clcmd("fullupdate", "clcmd_fullupdate")

	RegisterHookChain(RG_RoundEnd, "RG_EndRound")
	RegisterHookChain(RG_CSGameRules_PlayerKilled, "RG_Player_Killed_Post", 1)
	RegisterHookChain(RG_CWeaponBox_SetModel, "RG_Weapon_Remove")
	RegisterHookChain(RG_HandleMenu_ChooseTeam, "RG_ChooseTeam_Pre")
	RegisterHookChain(RG_HandleMenu_ChooseTeam, "RG_ChooseTeam_Post", 1)
	RegisterHookChain(RG_CSGameRules_CanHavePlayerItem, "RG_CSGameRules_CanHavePlayerItem_Pre")

	#if defined POINTS_SYS
	RegisterHookChain(RG_PlantBomb, "RG_BombPlanted")
	RegisterHookChain(RG_CGrenade_ExplodeBomb, "RG_BombExploded")
	RegisterHookChain(RG_CGrenade_DefuseBombEnd, "RG_BombDefused")
	RegisterHookChain(RG_CBasePlayer_Spawn, "RG_Player_Spawn_Post", 1)
	register_event("DeathMsg", "ev_DeathMsg", "ae", "1>0")
	#endif
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "RG_PlayerTakeDamage_Pre")
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "RG_PlayerTakeDamage_Post", 1)
	#if defined PUNCH_ANGLE
	RegisterHookChain(RG_CBasePlayerWeapon_KickBack, "RG_KickBack_Pre")
	#endif

	register_message(get_user_msgid("SayText"), "HookSay")
	register_event("HLTV", "ev_NewRound", "a", "1=0", "2=0");
	register_event("TextMsg", "ev_GameRestart", "a", "2=#Game_will_restart_in")
	g_cFreezeTime = get_cvar_pointer("mp_freezetime")

	#if defined DEBUG
	register_clcmd("say /test_over", "clcmd_say_test_over")
	register_clcmd("say /test_score", "clcmd_say_test_score")
	register_clcmd("say /test", "clcmd_say_test")
	#endif 

	g_eForwards[Kill] = CreateMultiForward("mix_player_killed", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_STRING, FP_STRING)
	g_eForwards[GameBeginPre] = CreateMultiForward("mix_game_begin_pre", ET_IGNORE)
	#if defined POINTS_SYS
	g_eForwards[GameOver] = CreateMultiForward("mix_game_over", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	g_eForwards[GameBeginPost] = CreateMultiForward("mix_game_begin_post", ET_IGNORE, FP_CELL, FP_CELL, FP_STRING, FP_STRING, FP_CELL)
	g_eForwards[GameStopped] = CreateMultiForward("mix_game_stopped", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_eForwards[DatabaseConnected] = CreateMultiForward("mix_database_connected", ET_IGNORE, FP_CELL, FP_CELL)
	g_eForwards[Winners] = CreateMultiForward("mix_match_winner", ET_IGNORE, FP_CELL)
	g_eForwards[Save] = CreateMultiForward("mix_user_save", ET_IGNORE, FP_CELL)
	#else
	g_eForwards[GameOver] = CreateMultiForward("mix_game_over", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_eForwards[GameBeginPost] = CreateMultiForward("mix_game_begin_post", ET_IGNORE, FP_CELL, FP_CELL, FP_STRING, FP_STRING)
	g_eForwards[GameStopped] = CreateMultiForward("mix_game_stopped", ET_IGNORE, FP_CELL, FP_CELL)
	#endif
	g_eForwards[NewRound] = CreateMultiForward("mix_game_new_round", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	
	new pcvar = get_cvar_pointer("amx_mode")
	if(pcvar != 0)
	{
		hook_cvar_change(pcvar, "OnCvarChange")
	}

	g_rePattern = regex_compile_ex("<.*?>",PCRE_CASELESS|PCRE_DOTALL|PCRE_EXTENDED|PCRE_UTF8)

	set_task(0.1, "task_read_config")
}

public task_read_config()
{
	ReadConfig()
}

public plugin_natives()
{
	g_aStartCmds = ArrayCreate(32)
	g_aStopCmds = ArrayCreate(32)
	g_aWarmCmds = ArrayCreate(32)
	g_aKnifeCmds = ArrayCreate(32)
	g_aChatOnCmds = ArrayCreate(32)
	g_aChatOffCmds = ArrayCreate(32)
	g_aOvertimeCmds = ArrayCreate(32)
	g_aPassOnCmds = ArrayCreate(32)
	g_aPassOffCmds = ArrayCreate(32)
	g_aSpecAllCmds = ArrayCreate(32)
	g_aCTCmds = ArrayCreate(32)
	g_aTCmds = ArrayCreate(32)
	g_aSpecCmds = ArrayCreate(32)
	g_aStartDemoCmds = ArrayCreate(32)
	g_aStopDemoCmds = ArrayCreate(32)
	g_aPlayerData = ArrayCreate(Pdata)

	#if defined POINTS_SYS
	g_aRanks = ArrayCreate(Ranking)
	#endif

	register_library("mix_system")

	register_native("Mix_IsHalf", "native_is_half")
	register_native("Mix_IsLastRound", "native_is_last_round")
	register_native("Mix_IsPreLastRound", "native_is_prelast_round")
	register_native("Mix_CanOvertime", "native_can_overtime")
	register_native("Mix_IsStarted", "native_is_started")
	register_native("Mix_IsWarm", "native_is_warm")
	register_native("Mix_GetPrefix", "native_get_prefix")
	register_native("Mix_GetUserName", "native_get_username")
	#if defined POINTS_SYS
	register_native("Mix_SearchForUser", "native_search_for_user")
	register_native("Mix_UserPoints", "native_user_points")
	register_native("Mix_GetPointsTable", "native_get_points_table")
	#endif
	register_native("Mix_HasPointsSys", "native_has_points_sys")
}

public plugin_end()
{
	ArrayDestroy(g_aStartCmds)
	ArrayDestroy(g_aStopCmds)
	ArrayDestroy(g_aWarmCmds)
	ArrayDestroy(g_aKnifeCmds)
	ArrayDestroy(g_aChatOnCmds)
	ArrayDestroy(g_aChatOffCmds)
	ArrayDestroy(g_aOvertimeCmds)
	ArrayDestroy(g_aPassOnCmds)
	ArrayDestroy(g_aPassOffCmds)
	ArrayDestroy(g_aSpecAllCmds)
	ArrayDestroy(g_aCTCmds)
	ArrayDestroy(g_aTCmds)
	ArrayDestroy(g_aSpecCmds)
	ArrayDestroy(g_aStartDemoCmds)
	ArrayDestroy(g_aStopDemoCmds)
	ArrayDestroy(g_aPlayerData)

	for(new i; i < MaxFwds; i++)
	{
		DestroyForward(g_eForwards[i])
	}

	#if defined POINTS_SYS
	ArrayDestroy(g_aRanks)

	if(g_bConnected)
	{
		SQL_FreeHandle(g_hSqlTuple)
		SQL_FreeHandle(g_iSqlConnection)
	}
	
	#endif
}

public OnCvarChange(pcvar, const old_value[], const new_value[])
{
	if(get_pcvar_num(pcvar) != 1)
	{
		set_pcvar_num(pcvar, 1)
	}

	server_cmd("amx_reloadadmins")
	server_exec()
}

#if defined DEBUG
public clcmd_say_test_score(id)
{
	g_iScore[CT_SCORE] += 1
	g_iScore[TERO_SCORE] += 12

	g_iRoundNum += 13
}

public clcmd_say_test_over(id)
{
	g_iScore[CT_SCORE] += 0
	g_iScore[TERO_SCORE] += 14
	g_iRoundNum += 14
}

public clcmd_say_test(id)
{
	console_print(id, "Can chat: %s", g_eBooleans[bCanChat] ? "YES" : "NO")
	console_print(id, "Mix started: %s", g_eBooleans[bIsMixOn] ? "YES" : "NO")
	console_print(id, "Knife started: %s", g_eBooleans[bIsKnife] ? "YES" : "NO")
	console_print(id, "Warm started: %s", g_eBooleans[bIsWarm] ? "YES" : "NO")
	console_print(id, "Team swap: %s", g_eBooleans[bTeamSwap] ? "YES" : "NO")
	console_print(id, "Overtime: %s", g_eBooleans[bOvertime] ? "YES" : "NO")
	console_print(id, "First Overtime: %s", g_eOvertime[FirstOvertime] ? "YES" : "NO")
	console_print(id, "Second Overtime: %s", g_eOvertime[SecondOvertime] ? "YES" : "NO")
	console_print(id, "Admin Flags: %s", g_ePluginSettings[szAdminAccess])
	console_print(id, "Score T: %i", g_iScore[TERO_SCORE])
	console_print(id, "Score CT: %i", g_iScore[CT_SCORE])
	console_print(id, "Score Over T: %i", g_iOvertimeScore[TERO_OVER_SCORE])
	console_print(id, "Score Over CT: %i", g_iOvertimeScore[CT_OVER_SCORE])
	console_print(id, "Warmup Type: %s", g_eWarmSettings[bWarmType] ? "True" : "False")
	console_print(id, "Weapon Tero: %s", g_eWarmSettings[szWeaponT])
	console_print(id, "Weapon CT: %s", g_eWarmSettings[szWeaponCT])
	#if defined POINTS_SYS
	console_print(id, "Database host: %s", g_ePluginSettings[szHostname])
	console_print(id, "Database username: %s", g_ePluginSettings[szUsername])
	console_print(id, "Database password: %s", g_ePluginSettings[szPassword])
	console_print(id, "Database name: %s", g_ePluginSettings[szDatabaseName])
	console_print(id, "Database table: %s", g_ePluginSettings[szTable])
	#endif
}
#endif

ReadConfig()
{
	new szConfigsDir[128], szFileDir[64]
	get_configsdir(szConfigsDir, charsmax(szConfigsDir))

	formatex(szFileDir, charsmax(szFileDir), "%s/MixSettings.ini", szConfigsDir)

	new iFile = fopen(szFileDir, "rt")

	if(iFile)
	{
		new szData[128], iSection, szString[64], szValue[64]

		#if defined POINTS_SYS
		new aRank[Ranking]
		#endif

		while(!feof(iFile))
		{
			fgets(iFile, szData, charsmax(szData))
			trim(szData)

			if(szData[0] == '#' || szData[0] == EOS || szData[0] == ';')
				continue

			if(szData[0] == '[')
			{
				iSection += 1
			}
			switch(iSection)
			{
				case SETTINGS_SECTION:
				{
					if(szData[0] != '[')
					{
						strtok2(szData, szString, charsmax(szString), szValue, charsmax(szValue), '=', TRIM_INNER)

						if(szValue[0] == EOS || !szValue[0])
							continue

						if(equal(szString, CHAT_PREFIX))
						{
							copy(g_ePluginSettings[szPrefix], charsmax(g_ePluginSettings[szPrefix]), szValue)
						}
						else if(equal(szString, OVERTIME_ROUNDS))
						{
							g_ePluginSettings[iRoundOvertime] = str_to_num(szValue)
						}
						else if(equal(szString, OVERTIME_SCORE))
						{
							g_ePluginSettings[iOvertimeScore] = str_to_num(szValue)
						}
						else if(equal(szString, MIX_END_ROUND))
						{
							g_ePluginSettings[iMixEndRound] = str_to_num(szValue)
						}
						else if(equal(szString, ADMIN_CHAT_FLAGS))
						{
							copy(g_ePluginSettings[szAdminFlags], charsmax(g_ePluginSettings[szAdminFlags]), szValue)
						}
						else if(equal(szString, ADMIN_ACCESS))
						{
							copy(g_ePluginSettings[szAdminAccess], charsmax(g_ePluginSettings[szAdminAccess]), szValue)
						}
						else if(equal(szString, FREEZETIME_SWAP))
						{
							g_ePluginSettings[iFreezetimeSwap] = str_to_num(szValue)
						}
						else if(equal(szString, AUTO_OVERTIME))
						{
							g_ePluginSettings[iAutoOvertime] = str_to_num(szValue)
						}
						else if(equal(szString, START_CFG))
						{
							copy(g_ePluginSettings[szStartCfg], charsmax(g_ePluginSettings[szStartCfg]), szValue)
						}
						else if(equal(szString, STOP_CFG))
						{
							copy(g_ePluginSettings[szStopCfg], charsmax(g_ePluginSettings[szStopCfg]), szValue)
						}
						else if(equal(szString, OVERTIME_CFG))
						{
							copy(g_ePluginSettings[szOvertimeCfg], charsmax(g_ePluginSettings[szOvertimeCfg]), szValue)
						}
						else if(equal(szString, FREEZETIME))
						{
							g_iFreezeTime = str_to_num(szValue)
						}
						else if(equal(szString, PAUSE_TIME))
						{
							g_ePluginSettings[iPauseTime] = str_to_num(szValue)
						}
						else if (equal(szString, TEN_REQUIRED))
						{
							g_ePluginSettings[bRequireTen] = bool:clamp(str_to_num(szValue), 0, 1) 
						}
						else if (equal(szString, KNIFE_ROUND_DELAY))
						{
							g_ePluginSettings[iKnifeStartDelay] = str_to_num(szValue)
						}
						else if (equal(szString, DEFAULT_POINTS))
						{
							g_ePluginSettings[iStartPoints] = str_to_num(szValue)
						}
						else if (equal(szString, FORCE_WARMUP))
						{
							g_ePluginSettings[bForceWarmup] = bool:clamp(str_to_num(szValue), 0, 1) 
						}
					}
				}
				case COMMANDS_SECTION:
				{
					if(szData[0] != '[')
					{
						strtok2(szData, szString, charsmax(szString), szValue, charsmax(szValue), '=', TRIM_INNER)

						if(szValue[0] == EOS || !szValue[0])
							continue

						if(equal(szString, SHOW_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_showcmds")
							}
						}
						else if(equal(szString, START_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_startmix")
								ArrayPushString(g_aStartCmds, szString)
							}
						}
						else if(equal(szString, STOP_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_stopmix")
								ArrayPushString(g_aStopCmds, szString)
							}
						}
						else if(equal(szString, WARM_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_warm")
								ArrayPushString(g_aWarmCmds, szString)
							}
						}
						else if(equal(szString, KNIFE_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_knife")
								ArrayPushString(g_aKnifeCmds, szString)
							}
						}
						else if(equal(szString, CHAT_ON_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_chat_on")
								ArrayPushString(g_aChatOnCmds, szString)
							}
						}
						else if(equal(szString, CHAT_OFF_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_chat_off")
								ArrayPushString(g_aChatOffCmds, szString)
							}
						}
						else if(equal(szString, OVERTIME_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_overtime")
								ArrayPushString(g_aOvertimeCmds, szString)
							}
						}
						else if(equal(szString, PASSON_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_passon")
								ArrayPushString(g_aPassOnCmds, szString)
							}
						}
						else if(equal(szString, PASSOFF_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_passoff")
								ArrayPushString(g_aPassOffCmds, szString)
							}
						}
						else if(equal(szString, SPECALL_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_specall")
								ArrayPushString(g_aSpecAllCmds, szString)
							}
						}
						else if(equal(szString, RESTART_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_restart")
							}
						}
						else if(equal(szString, SCORE_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_score")
							}
						}
						else if(equal(szString, CT_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_ct")
								ArrayPushString(g_aCTCmds, szString)
							}
						}
						else if(equal(szString, T_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_t")
								ArrayPushString(g_aTCmds, szString)
							}
						}
						else if(equal(szString, SPEC_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_spec")
								ArrayPushString(g_aSpecCmds, szString)
							}
						}
						else if(equal(szString, STARTDEMO_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_start_demo")
								ArrayPushString(g_aStartDemoCmds, szString)
							}
						}
						else if(equal(szString, STOPDEMO_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_stop_demo")
								ArrayPushString(g_aStopDemoCmds, szString)
							}
						}
						#if defined POINTS_SYS
						else if(equal(szString, TOP_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_say_rank")
								ArrayPushString(g_aStopDemoCmds, szString)
							}
						}
						else if(equal(szString, RESET_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "concmd_reset_db")
							}
						}
						#endif
						else if(equal(szString, PAUSE_COMMANDS))
						{
							while(szValue[0] != EOS && strtok2(szValue, szString, charsmax(szString), szValue, charsmax(szValue), ',', TRIM_INNER))
							{
								register_clcmd(szString, "clcmd_say_pause")
							}
						}
					}
				}
				case WARM_SETTINGS:
				{
					if(szData[0] == '[')
						continue

					strtok2(szData, szString, charsmax(szString), szValue, charsmax(szValue), '=', TRIM_INNER)

					if(equal(szString, WARM_TYPE))
					{
						g_eWarmSettings[bWarmType] = (str_to_num(szValue) == 1 ? true : false)
					}
					else if(equal(szString, WARM_SPAWN_MONEY))
					{
						g_eWarmSettings[iWarmMoney] = str_to_num(szValue)
					}
					else if(equal(szString, WARM_WEAPON_CT))
					{
						copy(g_eWarmSettings[szWeaponCT], charsmax(g_eWarmSettings[szWeaponCT]), szValue)
					}
					else if(equal(szString, WARM_WEAPON_TERO))
					{
						copy(g_eWarmSettings[szWeaponT], charsmax(g_eWarmSettings[szWeaponT]), szValue)
					}
					else if(equal(szString, WARM_PISTOL))
					{
						copy(g_eWarmSettings[szPistol], charsmax(g_eWarmSettings[szPistol]), szValue)
					}
					else if(equal(szString, WARM_BP_AMMO))
					{
						g_eWarmSettings[iBpAmmo] = str_to_num(szValue)
					}
				}
				case HUD_SETTINGS:
				{
					if(szData[0] == '[')
						continue

					strtok2(szData, szString, charsmax(szString), szValue, charsmax(szValue), '=', TRIM_INNER)

					if(equal(szString, HUD_COLORS))
					{
						new szHudColorR[4], szHudColorG[4], szHudColorB[4]

						parse(szValue, szHudColorR, charsmax(szHudColorR), szHudColorG, charsmax(szHudColorG), szHudColorB, charsmax(szHudColorB))

						g_eHudSettings[iHudColorR] = str_to_num(szHudColorR)
						g_eHudSettings[iHudColorG] = str_to_num(szHudColorG)
						g_eHudSettings[iHudColorB] = str_to_num(szHudColorB)
					}
					else if(equal(szString, HUD_POSITION))
					{
						new szHudPosX[5], szHudPosY[5]
						parse(szValue, szHudPosX, charsmax(szHudPosX), szHudPosY, charsmax(szHudPosY))

						g_eHudSettings[fHudPosX] = str_to_float(szHudPosX)
						g_eHudSettings[fHudPosY] = str_to_float(szHudPosY)

						#if defined DEBUG
						server_print("HudPostX : %f", g_eHudSettings[fHudPosX])
						server_print("HudPostY : %f", g_eHudSettings[fHudPosY])
						server_print("szHudX: %s", szHudPosX)
						server_print("szHudY: %s", szHudPosY)
						server_print("szValue: %s", szValue)
						#endif
					}
				}
				case DEMO_SETTINGS:
				{
					if(szData[0] == '[')
						continue

					strtok2(szData, szString, charsmax(szString), szValue, charsmax(szValue), '=', TRIM_INNER)

					if(equal(szString, DEMO_AUTO))
					{
						g_eDemoSettings[iDemoAuto] = str_to_num(szValue)
					}
					else if(equal(szString, DEMO_TYPE))
					{
						g_eDemoSettings[iDemoType] = str_to_num(szValue)
					}
					else if(equal(szString, DEMO_NAME))
					{
						copy(g_eDemoSettings[szDemoName], charsmax(g_eDemoSettings[szDemoName]), szValue)
					}
				}
				#if defined POINTS_SYS
				case POINTS_SYSTEM:
				{
					if(szData[0] == '[')
						continue

					strtok2(szData, szString, charsmax(szString), szValue, charsmax(szValue), '=', TRIM_INNER)
					if(equal(szString, DBASE_HOST))
					{
						copy(g_ePluginSettings[szHostname], charsmax(g_ePluginSettings[szHostname]), szValue)
					}
					else if(equal(szString, DBASE_USER))
					{
						copy(g_ePluginSettings[szUsername], charsmax(g_ePluginSettings[szUsername]), szValue)
					}
					else if(equal(szString, DBASE_PASS))
					{
						copy(g_ePluginSettings[szPassword], charsmax(g_ePluginSettings[szPassword]), szValue)
					}
					else if(equal(szString, DBASE_NAME))
					{
						copy(g_ePluginSettings[szDatabaseName], charsmax(g_ePluginSettings[szDatabaseName]), szValue)
					}
					else if(equal(szString, DBASE_TABLE))
					{
						copy(g_ePluginSettings[szTable], charsmax(g_ePluginSettings[szTable]), szValue)
					}
					else if(equal(szString, POINTS_ADD))
					{
						g_ePointSystem[PointsAdd] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_ADD_HS))
					{
						g_ePointSystem[PointsAddHS] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_ADD_KNIFE))
					{
						g_ePointSystem[PointsAddKnife] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_ADD_KNIFE_HS))
					{
						g_ePointSystem[PointsAddKnifeHS] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_ADD_GRENADE))
					{
						g_ePointSystem[PointsAddGrenade] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_SUB))
					{
						g_ePointSystem[PointsSub] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_SUB_HS))
					{
						g_ePointSystem[PointsSubHS] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_SUB_KNIFE))
					{
						g_ePointSystem[PointsSubKnife] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_SUB_KNIFE_HS))
					{
						g_ePointSystem[PointsSubKnifeHS] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_SUB_GRENADE))
					{
						g_ePointSystem[PointsSubGrenade] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_SUB_SUICIDE))
					{
						g_ePointSystem[PointsSubSuicide] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_SUB_TK))
					{
						g_ePointSystem[PointsSubTK] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_EXPLODED))
					{
						g_ePointSystem[PointsExploded] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_DEFUSED))
					{
						g_ePointSystem[PointsDefused] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_PLANTED))
					{
						g_ePointSystem[PointsPlanted] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_ACE))
					{
						g_ePointSystem[PointsAce] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_SEMIACE))
					{
						g_ePointSystem[PointsSemiAce] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_TWIN))
					{
						g_ePointSystem[PointsTeamWin] = str_to_num(szValue)
					}
					else if(equal(szString, POINTS_SHOW_NAME))
					{
						g_ePointSystem[PointsShowName] = str_to_num(szValue)
					}
				}
				case RANK_SYSTEM:
				{
					if(szData[0] == '[')
						continue
						
					strtok2(szData, szString, charsmax(szString), szValue, charsmax(szValue), '=', TRIM_INNER)
					copy(aRank[szRank], charsmax(aRank[szRank]), szString)
					aRank[iRankPoints] = str_to_num(szValue)

					ArrayPushArray(g_aRanks, aRank)
				}
				#endif
			}
		}
	}

	#if defined POINTS_SYS
	DatabaseConnect()
	#endif

	g_iTimer = g_ePluginSettings[iPauseTime] - 1
}

#if defined POINTS_SYS
public DatabaseConnect()
{
	SQL_SetAffinity("mysql")
	g_hSqlTuple = SQL_MakeDbTuple(g_ePluginSettings[szHostname], g_ePluginSettings[szUsername], g_ePluginSettings[szPassword], g_ePluginSettings[szDatabaseName], 10)

	new iError
	g_iSqlConnection = SQL_Connect(g_hSqlTuple, iError, g_szSqlError, charsmax(g_szSqlError))

	if(g_iSqlConnection == Empty_Handle)
	{
		log_to_file("mix_system.log", "%s Failed to connect to database. Make sure databse settings are right!", g_ePluginSettings[szPrefix])
		return 
	}

	g_bConnected = true

	ExecuteForward(g_eForwards[DatabaseConnected], g_iRet, g_hSqlTuple, g_iSqlConnection)

	new szQueryData[450];
	formatex(szQueryData, charsmax(szQueryData), "CREATE TABLE IF NOT EXISTS `%s` \
		(`ID` INT NOT NULL AUTO_INCREMENT,\
		`SteamID` VARCHAR(32),\
		`Name` VARCHAR(32),\
		`Points` INT NOT NULL,\
		`Kills` INT NOT NULL,\
		`Deaths` INT NOT NULL,\
		`Wins` INT NOT NULL, \
		`Lose` INT NOT NULL, \
		`Online` TINYINT(1) NOT NULL DEFAULT ^"0^", \
		`updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(), \
		PRIMARY KEY(ID, SteamID));", g_ePluginSettings[szTable])

	SQL_ThreadQuery(g_hSqlTuple, "QueryHandlerTable", szQueryData, szQueryData, charsmax(szQueryData))
}

public QueryHandlerTable(iFailState, Handle:iQuery, szError[], iErrorCode, szQuery[])
{
	switch(iFailState)
	{
		case TQUERY_CONNECT_FAILED: 
		{
			log_amx("[SQL Error Table] Connection failed (%i): %s", iErrorCode, szError);
		}
		case TQUERY_QUERY_FAILED:
		{
			log_amx("[SQL Error Table] Query failed (%i): %s", iErrorCode, szError);
			log_amx("Query: %s", szQuery)
		}
	}
}
#endif

public client_putinserver(id)
{
	get_user_authid(id, g_szAuthID[id], charsmax(g_szAuthID[]))
	get_user_name(id, g_szName[id], charsmax(g_szName[]))

	#if defined POINTS_SYS
	g_bLoadedPlayer[id] = false
	g_iPoints[id] = g_ePluginSettings[iStartPoints]
	g_iKills[id] = 0
	g_iDeaths[id] = 0
	g_iWins[id] = 0
	g_iLose[id] = 0

	if(!is_bot(id) && g_bConnected)
	{
		set_task(0.2, "task_load", id + TASK_LOAD)
	}
	#endif
	g_iPlayerKills[id] = 0

	g_eBooleans[bCanChat][id] = true

	if(g_eBooleans[bIsMixOn])
	{
		if(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminFlags]))
		{
			g_eBooleans[bCanChat][id] = true
		}
		else 
		{
			g_eBooleans[bCanChat][id] = false
		}
	}
}

public client_disconnected(id)
{
	if(is_bot(id))
		return

	if(g_eBooleans[bIsMixOn] && !is_nullent(id))
	{
		new iData[Pdata]
		iData[STEAMID] = g_szAuthID[id]
		iData[DEATHS] = get_user_deaths(id)
		iData[KILLS] = get_user_frags(id)
		iData[MONEY] = get_member(id, m_iAccount)
		ArrayPushArray(g_aPlayerData, iData)

		g_ePlayerScore[id][iKILLS] = 0
		g_ePlayerScore[id][iDEATHS] = 0
	}

	#if defined POINTS_SYS
	if(g_bConnected)
	{
		SaveData(id, true)
	}

	set_user_info(id, name, g_szName[id])
	#endif
}

#if defined PUNCH_ANGLE
public RG_KickBack_Pre(const index, Float:up_base, Float:lateral_base, Float:up_modifier, Float:lateral_modifier, Float:up_max, Float:lateral_max, direction_change)
{
	/* De modificat doar daca stiti ce se intampla aici*/
	SetHookChainArg(4, ATYPE_FLOAT, up_modifier * 0.90)
	SetHookChainArg(5, ATYPE_FLOAT, lateral_modifier * 0.90)
}
#endif

public RG_Weapon_Remove(iEnt, const szModelName[])
{
	if(g_eBooleans[bIsWarm] || g_eBooleans[bIsKnife])
	{
		static szClass[32]
		get_entvar(iEnt, var_classname, szClass, charsmax(szClass))

		if(!equal(szClass, "weaponbox"))
			return HC_CONTINUE

		set_entvar(iEnt, var_nextthink, get_gametime() + 1)
	}

	return HC_CONTINUE
}

public RG_CSGameRules_CanHavePlayerItem_Pre(id, item)
{
	if(g_eBooleans[bIsKnife])
	{
		if(get_member(item, m_iId) == WEAPON_KNIFE)
			return

		SetHookChainReturn(ATYPE_INTEGER, 0)
	}
}

public RG_ChooseTeam_Pre(id, MenuChooseTeam:slot)
{
	if(g_eBooleans[bIsMixOn])
	{
		new iCT = get_playersnum_ex(GetPlayers_MatchTeam, "CT")
		new iTero = get_playersnum_ex(GetPlayers_MatchTeam, "TERRORIST")

		if(slot == MenuChoose_T && iTero == 5)
		{
			SetHookChainReturn(ATYPE_INTEGER, 0)
			return HC_SUPERCEDE
		}
		else if(slot == MenuChoose_CT && iCT == 5)
		{
			SetHookChainReturn(ATYPE_INTEGER, 0)
			return HC_SUPERCEDE
		}
		else if(slot == MenuChoose_AutoSelect)
		{
			SetHookChainReturn(ATYPE_INTEGER, 0)
			return HC_SUPERCEDE
		}
	}
	return HC_CONTINUE
}

public RG_ChooseTeam_Post(id, MenuChooseTeam:slot)
{
	if(g_eBooleans[bIsWarm])
	{
		set_task(1.0, "task_revive", id + TASK_REVIVE)
	}

	if(g_eBooleans[bIsMixOn])
	{
		new iData[Pdata]
		new pID = ArrayFindString(g_aPlayerData, g_szAuthID[id])

		if(pID != -1)
		{
			ArrayGetArray(g_aPlayerData, pID, iData)
			set_user_frags(id, iData[KILLS])
			cs_set_user_deaths(id, iData[DEATHS], true)
			set_member(id, m_iAccount, iData[MONEY])

			ArrayDeleteItem(g_aPlayerData, pID)
		}
	}
}

public clcmd_fullupdate(id)
{
	return PLUGIN_HANDLED_MAIN
}

public StartCount()
{
	g_iDuration += 1
}

public ev_DeathMsg()
{
	new killer = read_data(1)
	if(!is_user_connected(killer))
	{
		return PLUGIN_HANDLED
	}
	read_data(4, g_szWeapon[killer], charsmax(g_szWeapon[]))

	return PLUGIN_HANDLED
}

public RG_PlayerTakeDamage_Pre(iVictim, pevInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if(!g_eBooleans[bIsMixOn])
		return

	g_ePlayerStats[iAttacker][iVictim][PlayerHealth] = get_user_health(iVictim)
}

public RG_PlayerTakeDamage_Post(iVictim, pevInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if(!g_eBooleans[bIsMixOn])
		return

	new iAfter = g_ePlayerStats[iAttacker][iVictim][PlayerHealth] - get_user_health( iVictim )

	new iCalculation = (iAfter) < 0 ? g_ePlayerStats[iAttacker][iVictim][PlayerHealth] : iAfter

	g_ePlayerStats[iAttacker][iVictim][DamageGiven] += iCalculation;
	g_ePlayerStats[iAttacker][iVictim][HitsGiven] += 1
}

public RG_Player_Killed_Post(iVictim, iKiller, iInflictor)
{
	if(IsPlayer(iVictim) && g_eBooleans[bIsWarm])
	{
		set_task(1.0, "task_revive", iVictim + TASK_REVIVE)
	}

	if(g_eBooleans[bIsMixOn] && !g_eBooleans[bIsWarm])
	{
		if(!IsPlayer(iKiller) || !IsPlayer(iVictim))
		{
			return HC_CONTINUE
		}

		if(iKiller == iVictim)
		{
			#if defined POINTS_SYS
			g_iPoints[iKiller] -= g_ePointSystem[PointsSubSuicide]
			client_print_color(iVictim, iVictim, "^4%s ^1%L", g_ePluginSettings[szPrefix], LANG_PLAYER, "KILLER_KILLED_SUICIDE", g_ePointSystem[ PointsSubSuicide ])
			#endif
			goto _return
		}

		new bool:bHeadshot = get_member(iVictim, m_bHeadshotKilled)

		#if defined POINTS_SYS
		if(containi(g_szWeapon[iKiller], "grenade") != -1)
		{
			format(g_szWeapon[iKiller], charsmax(g_szWeapon[]), "weapon_he%s", g_szWeapon[iKiller])
		}
		else
		{
			format(g_szWeapon[iKiller], charsmax(g_szWeapon[]), "weapon_%s", g_szWeapon[iKiller])
		}
		
		new WeaponIdType:wid = rg_get_weapon_info(g_szWeapon[iKiller], WI_ID)
		
		if(get_user_team(iKiller) == get_user_team(iVictim))
		{
			g_iPoints[ iKiller ] -= g_ePointSystem[PointsSubTK]
			client_print_color(iKiller, iKiller, "^4%s ^1%L", g_ePluginSettings[szPrefix], LANG_PLAYER, bHeadshot ? ((wid == WEAPON_KNIFE) ? "VICTIM_KILLED_SUB_TK_KNIFE_HS" : "VICTIM_KILLED_SUB_TK_HS") : ((wid == WEAPON_KNIFE) ? "VICTIM_KILLED_SUB_TK_KNIFE" : "VICTIM_KILLED_SUB_TK"), g_ePointSystem[PointsSubTK], g_szName[iVictim])
			goto _return
		}

		if(wid == WEAPON_HEGRENADE)
		{
			g_iPoints[iKiller] += g_ePointSystem[PointsAddGrenade]
			client_print_color(iKiller, iKiller, "^4%s ^1%L", g_ePluginSettings[szPrefix], LANG_PLAYER, "KILLER_KILLED_ADD_GRENADE", g_ePointSystem[PointsAddGrenade], g_szName[iVictim])
			
			g_iPoints[iVictim] -= g_ePointSystem[PointsSubGrenade]
			client_print_color(iVictim, iVictim, "^4%s ^1%L", g_ePluginSettings[szPrefix], LANG_PLAYER, "KILLER_KILLED_SUB_GRENADE", g_ePointSystem[PointsAddGrenade], g_szName[iKiller])
		}
		else if(wid == WEAPON_KNIFE)
		{
			g_iPoints[iKiller] += bHeadshot ? g_ePointSystem[PointsAddKnifeHS] : g_ePointSystem[PointsAddKnife]
			client_print_color(iKiller, iKiller, "^4%s ^1%L", g_ePluginSettings[szPrefix], LANG_PLAYER, bHeadshot ? "KILLER_KILLED_ADD_KNIFE_HS" : "KILLER_KILLED_ADD_KNIFE", bHeadshot ? g_ePointSystem[PointsAddKnifeHS] : g_ePointSystem[PointsAddKnife], g_szName[iVictim])

			g_iPoints[iVictim] -= bHeadshot ? g_ePointSystem[PointsSubKnifeHS] : g_ePointSystem[PointsSubKnife]
			client_print_color(iVictim, iVictim, "^4%s ^1%L", g_ePluginSettings[szPrefix], LANG_PLAYER, bHeadshot ? "VICTIM_KILLED_SUB_KNIFE_HS" : "VICTIM_KILLED_SUB_KNIFE", bHeadshot ? g_ePointSystem[PointsSubKnifeHS] : g_ePointSystem[PointsSubKnife], g_szName[iKiller])
		}
		else
		{
			g_iPoints[iKiller] += bHeadshot ? g_ePointSystem[PointsAddHS] : g_ePointSystem[PointsAdd]
			client_print_color(iKiller, iKiller, "^4%s ^1%L", g_ePluginSettings[szPrefix], LANG_PLAYER, bHeadshot ? "KILLER_KILLED_ADD_HS" : "KILLER_KILLED_ADD", bHeadshot ? g_ePointSystem[PointsAddHS] : g_ePointSystem[PointsAdd], g_szName[iVictim])
			
			g_iPoints[iVictim] -= bHeadshot ? g_ePointSystem[PointsSubHS] : g_ePointSystem[PointsSub]
			client_print_color(iVictim, iVictim, "^4%s ^1%L", g_ePluginSettings[szPrefix], LANG_PLAYER, bHeadshot ? "VICTIM_KILLED_SUB_HS" : "VICTIM_KILLED_SUB", bHeadshot ? g_ePointSystem[PointsSubHS] : g_ePointSystem[PointsSub], g_szName[iKiller])
		}
		g_iKills[iKiller] += 1
		g_iDeaths[iVictim] += 1
		#endif
		g_iPlayerKills[iKiller] += 1

		ExecuteForward(g_eForwards[Kill], g_iRet, iVictim, iKiller, bHeadshot ? 1 : 0, g_szName[iKiller], g_szAuthID[iKiller])
	}
	_return:
	return HC_CONTINUE
}

public task_revive(iPlayer)
{
	iPlayer -= TASK_REVIVE

	if(IsPlayer(iPlayer))
	{
		new CsTeams:iTeam = cs_get_user_team(iPlayer)
		if(iTeam == CS_TEAM_SPECTATOR || iTeam == CS_TEAM_UNASSIGNED)
		{
			return HC_CONTINUE
		}

		set_entvar(iPlayer, var_health, 100)

		rg_round_respawn(iPlayer)
		rg_set_user_armor(iPlayer, 100, ARMOR_VESTHELM)

		switch(g_eWarmSettings[bWarmType])
		{
			case false:
			{
				set_task(1.0, "task_set_money", iPlayer + TASK_SET_MONEY)
			}
			case true:
			{
				set_task(1.0, "task_give_weapon", iPlayer + TASK_GIVE_WEAPON)
			}
		}
	}

	return PLUGIN_HANDLED
}

#if defined POINTS_SYS
public RG_BombPlanted(id)
{
	if(g_eBooleans[bIsMixOn])
	{
		g_iBombPlanter = id
		g_iPoints[ id ] += g_ePointSystem[ PointsPlanted ]
		client_print_color( id, id, "^4%s ^1%L", g_ePluginSettings[szPrefix], LANG_PLAYER, "POINTS_FOR_PLANT_BOMB", g_ePointSystem[ PointsPlanted ] )
	}
}

public RG_BombExploded()
{
	if(g_eBooleans[bIsMixOn])
	{
		g_iPoints[ g_iBombPlanter ] += g_ePointSystem[ PointsExploded ]
		client_print_color(g_iBombPlanter, g_iBombPlanter, "^4%s^1 %L", g_ePluginSettings[szPrefix], LANG_SERVER, "BOMB_EXPLODED_BY_YOU", g_ePointSystem[PointsExploded])
	}
}

public RG_BombDefused(id2, id, bool:bDefused)
{
	if(g_eBooleans[bIsMixOn])
	{
		if(bDefused)
		{
			g_iPoints[id] += g_ePointSystem[ PointsDefused ]
			client_print_color(id, id, "^4%s^1 %L", g_ePluginSettings[szPrefix], LANG_SERVER, "BOMB_DEFUSED_BY_YOU", g_ePointSystem[PointsDefused])
		}
	}
}

public RG_Player_Spawn_Post(id)
{
	if(is_user_alive(id) && g_eBooleans[bIsMixOn])
	{
		if(g_iPoints[id] < 0)
		{
			g_iPoints[id] = 0
		}

		new aRank[Ranking]

		for(new i; i < ArraySize(g_aRanks); i++)
		{
			ArrayGetArray(g_aRanks, i, aRank)

			if(g_iPoints[id] <= aRank[iRankPoints])
			{
				if(i > 1)
				{
					ArrayGetArray(g_aRanks, i-1, aRank)
				}
				break
			}
		}
		
		new iError
		regex_replace(g_rePattern, g_szName[id], charsmax(g_szName[]), "", .errcode=iError)

		if(iError != 0)
		{
			log_to_file("mix_system.log", "Regex Error. Code %d", iError)
		}

		new tmpName[32]
		formatex(tmpName, charsmax(tmpName), "%s", g_szName[id])

		if(g_ePointSystem[PointsShowName])
		{
			format(tmpName, charsmax(tmpName), "%s <%d>", tmpName, g_iPoints[id])
		}
		else
		{
			format(tmpName, charsmax(tmpName), "%s <%s>", tmpName, aRank[szRank])
		}
		set_user_info(id, name, tmpName)
	}
}
#endif

public clcmd_showcmds(id)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	for(new i; i < sizeof(g_aStartCmds); i++)
	{
		console_print(id, "=-=-==-=-=---=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")

		GetArrayCmd(id, g_aStartCmds, i, "MIX_START_COMMANDS_ARE")

		GetArrayCmd(id, g_aStopCmds, i, "MIX_STOP_COMMANDS_ARE")

		GetArrayCmd(id, g_aWarmCmds, i, "MIX_WARM_COMMANDS_ARE")

		GetArrayCmd(id, g_aChatOnCmds, i, "MIX_CHAT_ON_COMMANDS_ARE")

		GetArrayCmd(id, g_aChatOffCmds, i, "MIX_CHAT_OFF_COMMANDS_ARE")

		GetArrayCmd(id, g_aOvertimeCmds, i, "MIX_OVERTIME_COMMANDS_ARE")

		GetArrayCmd(id, g_aPassOnCmds, i, "MIX_PASSON_COMMANDS_ARE")

		GetArrayCmd(id, g_aPassOffCmds, i, "MIX_PASSOFF_COMMANDS_ARE")

		GetArrayCmd(id, g_aSpecAllCmds, i, "MIX_SPEC_ALL_COMMANDS_ARE")

		GetArrayCmd(id, g_aCTCmds, i, "MIX_CT_MOVE_COMMANDS_ARE")

		GetArrayCmd(id, g_aTCmds, i, "MIX_T_MOVE_COMMANDS_ARE")

		GetArrayCmd(id, g_aSpecCmds, i, "MIX_SPEC_MOVE_COMMANDS_ARE")

		GetArrayCmd(id, g_aStartDemoCmds, i, "MIX_START_DEMO_COMMANDS_ARE")

		GetArrayCmd(id, g_aStopDemoCmds, i, "MIX_STOP_DEMO_COMMANDS_ARE")

		console_print(id, "=-=-==-=-=---=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
	}

	client_print_color(id, id, "^4%s ^1%L", g_ePluginSettings[szPrefix], LANG_SERVER, "OPEN_CONSOLE_FOR_CMDS")
	client_cmd(id, "toggleconsole")

	return PLUGIN_HANDLED
}

stock GetArrayCmd(id, Array:array, item, ML[])
{
	static temp[32]
	static szTemp[64]
	temp[0] = 0
	szTemp[0] = 0
	
	ArrayGetString(array, item, temp, charsmax(temp))
	formatex(szTemp, charsmax(szTemp), "%L: %s", LANG_SERVER, ML, temp)
	console_print(id, szTemp)
}

public clcmd_startmix(id, bool:bKnife)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	if(g_eBooleans[bIsMixOn] || g_eBooleans[bIsKnife])
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_ALREADY_STARTED")
		return PLUGIN_HANDLED
	}

	if(g_ePluginSettings[bRequireTen])
	{
		new iTemp[7]
		rg_initialize_player_counts(iTemp[0], iTemp[1], iTemp[2], iTemp[3])
		iTemp[4] = iTemp[0] + iTemp[2]
		iTemp[5] = iTemp[1] + iTemp[3]
		iTemp[6] = iTemp[5] + iTemp[4]

		if(iTemp[6] < 10)
		{
			client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_NEEDS_TEN_PLAYERS")
			return PLUGIN_HANDLED
		}
	}

	#if defined FASTCUP_MODE
	if(g_eBooleans[bWasKnife])
	#endif
	{
		ExecuteForward(g_eForwards[GameBeginPre], g_iRet)
	}

	new szMapName[32], iDate[3]
	enum { iYear = 0, iMonth, iDay }
	get_mapname(szMapName, charsmax(szMapName))
	date(iDate[iYear], iDate[iMonth], iDate[iDay])

	static iPlayer, iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")

	g_eInformations[MIX_STARTER] = id

	new CsTeams:iTeam, bool:bFinished

	for(new i; i < iNum ; i++)
	{
		iPlayer = iPlayers[i]

		g_eBooleans[bCanChat][iPlayer] = true

		#if defined FASTCUP_MODE
		if(g_eBooleans[bWasKnife] && bKnife)
		{
		#endif
			if(g_eInformations[MIX_STARTER] == iPlayer)
			{
				client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_PLAYER, "MIX_STARTED_BY_YOU")
			}
			else
			{
				client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_STARTED_BY_X", g_szName[g_eInformations[MIX_STARTER]])
			}

			if(g_eDemoSettings[iDemoAuto])
			{
				switch(g_eDemoSettings[iDemoType])
				{
					case DEMO_MAPNAME:
					{
						client_cmd(iPlayer, "record ^"%s_%i_%i_%i^"", szMapName, iDate[iYear], iDate[iMonth], iDate[iDay])
					}
					case DEMO_CUSTOM_NAME:
					{
						client_cmd(iPlayer, "record ^"%s_%s^"", g_eDemoSettings[szDemoName], szMapName)
					}
				}
				client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_PLAYER, "DEMO_STARTED_ON_YOU")
			}
			
			iTeam = cs_get_user_team(iPlayer)

			if(iTeam == CS_TEAM_CT || iTeam == CS_TEAM_T)
			{
				if(i == iNum - 1)
				{
					bFinished = true
				}

				#if defined POINTS_SYS
				ExecuteForward(g_eForwards[GameBeginPost], g_iRet, iPlayer, bFinished ? 1 : 0, g_szAuthID[iPlayer], g_szName[iPlayer], g_iPoints[iPlayer])
				#else
				ExecuteForward(g_eForwards[GameBeginPost], g_iRet, iPlayer, bFinished ? 1 : 0, g_szAuthID[iPlayer], g_szName[iPlayer])
				#endif
			}
		#if defined FASTCUP_MODE
		}
		#endif
	}

	g_eBooleans[bCanChat][id] = false

	g_iStart = 0

	ResetScore()

	#if defined FASTCUP_MODE
	if(!g_eBooleans[bWasKnife])
	{
		g_eBooleans[bWasKnife] = true
		clcmd_knife(id)
		StartConfig()
		return PLUGIN_HANDLED
	}

	if(!bKnife)
	{
		return PLUGIN_HANDLED
	}
	#endif

	g_eBooleans[bIsMixOn] = true
	g_eBooleans[bOvertime] = false
	g_eBooleans[bIsStoppingMix] = false
	g_eInformations[ACE] = -1
	g_eInformations[SEMI_ACE] = -1
	g_eTeamPause[CT_PAUSE] = 0
	g_eTeamPause[TERO_PAUSE] = 0

	StartConfig()

	server_cmd("sv_restart 1")

	set_task(1.0, "StartCount", TASK_COUNT_DURATION, .flags = "b")

	return PLUGIN_CONTINUE
}

public clcmd_stopmix(id)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	#if defined DEBUG
	client_print_color(0, 0, "clcmd_stopmix() called")
	#endif

	if(!g_eBooleans[bIsKnife] && !g_eBooleans[bIsMixOn])
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_NOT_STARTED_YET")
		return PLUGIN_HANDLED
	}

	g_eBooleans[bIsStoppingMix] = true

	static iPlayer, iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")

	new CsTeams:iTeam

	g_eInformations[MIX_STOPER] = id

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(g_eInformations[MIX_STOPER] == iPlayer)
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_PLAYER, "MIX_STOPPED_BY_YOU")
		}
		else
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_STOPPED_BY_X", g_szName[g_eInformations[MIX_STOPER]])
		}

		iTeam = cs_get_user_team(iPlayer)

		if(iTeam == CS_TEAM_CT || iTeam == CS_TEAM_T)
		{
			#if defined POINTS_SYS
			ExecuteForward(g_eForwards[GameStopped], g_iRet, iPlayer, g_iDuration, g_iPoints[iPlayer])
			#else
			ExecuteForward(g_eForwards[GameStopped], g_iRet, iPlayer, g_iDuration)
			#endif
		}

		client_cmd(iPlayer, "stop")

		#if defined POINTS_SYS
		set_user_info(iPlayer, name, g_szName[iPlayer])
		#endif
	}

	#if defined FASTCUP_MODE
	g_eBooleans[bWasKnife] = false
	#endif

	ResetScore()
	StopConfig()

	server_cmd("sv_restart 1")

	return PLUGIN_CONTINUE
}

public clcmd_warm(id)
{
	if(is_user_connected(id))
	{
		if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
		{
			client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
			return PLUGIN_HANDLED
		}
	}

	if(g_eBooleans[bIsMixOn] || g_eBooleans[bIsKnife] || task_exists(TASK_CHECKVOTES))
	{
		if(is_user_connected(id))
		{
			client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_NEED_STOPPED")
		}
		return PLUGIN_HANDLED
	}
	

	static iPlayer, iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")

	g_eInformations[WARM_CALLER] = id

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(g_eInformations[WARM_CALLER] == iPlayer)
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_PLAYER, "WARM_STARTED_BY_YOU")
		}
		else
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "WARM_STARTED_BY_X", strlen(g_szName[g_eInformations[WARM_CALLER]]) ? 
			                   g_szName[g_eInformations[WARM_CALLER]] : "Server")
		}

		set_task(2.0, "Task_Warmup", iPlayer + TASK_WARM)
	}

	g_eBooleans[bIsWarm] = true
	g_eBooleans[bOvertime] = false
	#if defined FASTCUP_MODE
	g_eBooleans[bWasKnife] = false
	#endif

	StopConfig()

	server_cmd("mp_buytime 99999")

	server_cmd("sv_restart 1")

	SetGameDesc(MATCHSTATE_WARM)

	return PLUGIN_CONTINUE
}

public Task_Warmup(iPlayer)
{
	iPlayer -= TASK_WARM

	if(g_eBooleans[bIsWarm] && is_user_connected(iPlayer))
	{
		rg_set_user_armor(iPlayer, 100, ARMOR_VESTHELM)

		switch(g_eWarmSettings[bWarmType])
		{
			case false:
			{
				set_task(1.0, "task_set_money", iPlayer + TASK_SET_MONEY)
			}
			case true:
			{
				set_task(1.0, "task_give_weapon", iPlayer + TASK_GIVE_WEAPON)
			}
		}
	}
	return PLUGIN_CONTINUE
}

public task_set_money(id)
{
	id -= TASK_SET_MONEY

	if(!IsPlayer(id) || !g_eBooleans[bIsWarm])
	{
		return PLUGIN_HANDLED
	}

	rg_add_account(id, g_eWarmSettings[iWarmMoney], AS_ADD, true)

	#if defined DEBUG
	client_print_color(id, id, "task_set_money() called")
	#endif

	return PLUGIN_CONTINUE
}

public task_give_weapon(id)
{
	id -= TASK_GIVE_WEAPON

	if(!IsPlayer(id) || !g_eBooleans[bIsWarm] || !is_user_connected(id))
	{
		return PLUGIN_HANDLED
	}

	new TeamName:iTeam = get_member(id, m_iTeam)
	new iWeaponID[3]

	iWeaponID[0] = rg_get_weapon_info(g_eWarmSettings[szWeaponT], WI_ID)
	iWeaponID[1] = rg_get_weapon_info(g_eWarmSettings[szWeaponCT], WI_ID)
	iWeaponID[2] = rg_get_weapon_info(g_eWarmSettings[szPistol], WI_ID)

	switch(iTeam)
	{
		case TEAM_TERRORIST:
		{
			rg_give_item(id, g_eWarmSettings[szWeaponT], GT_REPLACE)
			rg_give_item(id, g_eWarmSettings[szPistol], GT_REPLACE)
			rg_set_user_bpammo(id, WeaponIdType:iWeaponID[0], g_eWarmSettings[iBpAmmo])
			rg_set_user_bpammo(id, WeaponIdType:iWeaponID[2], g_eWarmSettings[iBpAmmo])
		}
		case TEAM_CT:
		{
			rg_give_item(id, g_eWarmSettings[szWeaponCT], GT_REPLACE)
			rg_give_item(id, g_eWarmSettings[szPistol], GT_REPLACE)
			rg_set_user_bpammo(id, WeaponIdType:iWeaponID[1], g_eWarmSettings[iBpAmmo])
			rg_set_user_bpammo(id, WeaponIdType:iWeaponID[2], g_eWarmSettings[iBpAmmo])
		}
	}
	
	#if defined DEBUG
	client_print_color(id, id, "task_give_weapon() called")
	#endif

	return PLUGIN_HANDLED
}

public clcmd_knife(id)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	if(g_eBooleans[bIsMixOn])
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_NEED_STOPPED")
		return PLUGIN_HANDLED
	}

	static iPlayer, iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")

	g_eInformations[KNIFE_STRATER] = id

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		#if !defined FASTCUP_MODE
		if(g_eInformations[KNIFE_STRATER] == iPlayer)
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "KNIFE_STARTED_BY_YOU")
		}
		else
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "KNIFE_STARTED_BY_X", g_szName[g_eInformations[KNIFE_STRATER]])
		}
		#else
		client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "KNIFE_STARTED")
		#endif
	}

	g_iKnifes = 0

	ResetScore()

	g_eBooleans[bIsKnife] = true

	g_iKnifes += 1

	StopConfig()

	server_cmd("sv_restart 1")

	SetGameDesc(MATCHSTATE_KNIFE_ROUND)

	return PLUGIN_CONTINUE
}

public RG_EndRound(WinStatus:status, ScenarioEventEndRound:event, Float:tmDelay)
{
	if(get_playersnum() < 1)
	{
		return
	}

	set_task(1.0, "task_end_round", any:status)
}

public task_end_round(index)
{
	new WinStatus:status = WinStatus:index

	new szTeamWon[12]
	#if defined FASTCUP_MODE
	new TeamName:iWTeam
	#endif

	switch(status)
	{
		case WINSTATUS_CTS:
		{
			formatex(szTeamWon, charsmax(szTeamWon), "%L", LANG_SERVER, "CT_TEAM")
			#if defined FASTCUP_MODE
			iWTeam = TEAM_CT
			#endif

			if(g_eBooleans[bIsMixOn])
			{
				if(!g_eBooleans[bOvertime])
				{
					g_iScore[CT_SCORE] += 1
					g_iRoundNum += 1
				}
				else
				{
					g_iOvertimeScore[CT_OVER_SCORE] += 1
				}
			}
		}
		case WINSTATUS_TERRORISTS:
		{
			formatex(szTeamWon, charsmax(szTeamWon), "%L", LANG_SERVER, "TERO_TEAM")
			#if defined FASTCUP_MODE
			iWTeam = TEAM_TERRORIST
			#endif

			if(g_eBooleans[bIsMixOn])
			{
				if(!g_eBooleans[bOvertime])
				{
					g_iScore[TERO_SCORE] += 1
					g_iRoundNum += 1
				}
				else
				{
					g_iOvertimeScore[TERO_OVER_SCORE] += 1
				}
			}
		}
	}

	if(g_eBooleans[bIsMixOn])
		SetGameDesc(g_eBooleans[bOvertime] ? MATCHSTATE_OVERTIME : MATCHSTATE_IN_MATCH)
	else if(g_ePluginSettings[bForceWarmup] && !g_eBooleans[bIsWarm])
	{
		clcmd_warm(0)
	}

	if(g_iKnifes == 2)
	{
		if(g_eBooleans[bIsKnife] && !g_eBooleans[bIsStoppingMix])
		{
			static iPlayer, iPlayers[MAX_PLAYERS], iNum
			get_players(iPlayers, iNum, "ch")

			for(new i; i < iNum; i++)
			{
				iPlayer = iPlayers[i]

				client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "KNIFE_ROUND_WON_BY_X_TEAM", szTeamWon)
				client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "KNIFE_ROUND_MATCH_START_IN", g_ePluginSettings[iKnifeStartDelay])
				
				#if defined FASTCUP_MODE
				if(get_member(iPlayer, m_iTeam) == iWTeam)
				{
					g_iPlayers += 1
					set_task(0.2, "task_ask_player", iPlayer + TASK_ASK)
				}
				#endif
			}

#if defined FASTCUP_MODE
			if(!task_exists(TASK_CHECKVOTES))
			{
				set_task(float(g_ePluginSettings[iKnifeStartDelay]), "task_do_change", TASK_CHECKVOTES)
			}
#endif
			g_eBooleans[bIsKnife] = false
			g_iKnifes = 3

			ResetScore()
		}
	}

	if(CanOvertime() && g_ePluginSettings[iAutoOvertime] && !g_eBooleans[bOvertime])
	{
		g_eBooleans[bOvertime] = true
		g_eOvertime[FirstOvertime] = true

		new iPlayer, iPlayers[MAX_PLAYERS], iNum
		get_players(iPlayers, iNum, "ch")

		for(new i; i < iNum; i++)
		{
			iPlayer = iPlayers[i]

			if(!IsPlayer(iPlayer))
			{
				continue
			}

			#if defined OVERTIME_ONE_ROUND
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "OVERTIME_AUTOMATIC_WILL_START_ONER")
			#else
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "OVERTIME_AUTOMATIC_WILL_START")
			#endif
		}

		g_eBooleans[bTeamSwap] = false

		OvertimeConfig()

		set_task(1.0, "task_delayed_swap")
	}

	if(g_eBooleans[bOvertime])
	{
		CheckOvertimePhase()
	}

 	if(g_eBooleans[bIsKnife])
 	{
		g_iKnifes += 1
 	}

 	if(g_eBooleans[bIsMixOn])
 	{
 		g_bPaused = false
 		g_iTimer = g_ePluginSettings[iPauseTime] - 1

	 	static iPlayer, iPlayers[MAX_PLAYERS], iNum
		get_players(iPlayers, iNum, "ch")

		new iDamageGiven, iDamageTaken, iHitsGiven, iHitsTaken, iVictim, CsTeams:iTeam

		for(new i; i < iNum; i++)
		{
			iPlayer = iPlayers[i]

			if(g_eBooleans[bCanShowStats])
			{
				for(new j; j < iNum; j++)
				{
					iVictim = iPlayers[j]

					iTeam = cs_get_user_team(iVictim)

					if(iTeam == CS_TEAM_CT || iTeam == CS_TEAM_T)
					{
						iDamageGiven = g_ePlayerStats[iPlayer][iVictim][DamageGiven]
						iDamageTaken = g_ePlayerStats[iVictim][iPlayer][DamageGiven]

						if(iDamageGiven > 100)
						{
							iDamageGiven = 100
						}

						if(iDamageTaken > 100)
						{
							iDamageTaken = 100
						}

						if(i != j && iTeam != cs_get_user_team(iPlayer))
						{
							if(!(iDamageGiven || iDamageTaken))
								continue

							iHitsGiven = g_ePlayerStats[iPlayer][iVictim][HitsGiven]
							iHitsTaken = g_ePlayerStats[iVictim][iPlayer][HitsGiven]

							client_print_color(iPlayer, iPlayer, "^4%s ^1%s (^4%d ^1%L^4 %d^1) %L, (^4%d^1 %L^4 %d^1) %L.", 
							                   g_ePluginSettings[szPrefix], g_szName[iVictim], iDamageGiven, LANG_PLAYER, "IN",
							                    iHitsGiven, LANG_PLAYER, "DAMAGE", iDamageTaken, LANG_PLAYER, "IN", iHitsTaken, LANG_PLAYER, "RECEIVED")
						}
					}
				}
			}

			if(g_iPlayerKills[iPlayer] == 5)
			{
				g_eInformations[ACE] = iPlayer
			}

			if(g_iPlayerKills[iPlayer] == 4)
			{
				g_eInformations[SEMI_ACE] = iPlayer
			}
		}

		for(new i; i < iNum; i++)
		{
			iPlayer = iPlayers[i]

			if(g_eInformations[ACE] != -1)
			{
				if(g_eInformations[ACE] == iPlayer)
				{
					#if defined POINTS_SYS
					client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_SCORED_ACE_POINTS", g_ePointSystem[PointsAce])
					g_iPoints[iPlayer] += g_ePointSystem[PointsAce]
					#else
					client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_SCORED_ACE")
					#endif
				}
				else
				{
					client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "X_SCORED_ACE", g_szName[g_eInformations[ACE]])
				}

				client_cmd(iPlayer, "spk vox/buzwarn")
			}

			if(g_eInformations[SEMI_ACE] != -1)
			{
				if(g_eInformations[SEMI_ACE] == iPlayer)
				{
					#if defined POINTS_SYS
					client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_SCORED_SEMIACE_POINTS", g_ePointSystem[PointsAce])
					g_iPoints[iPlayer] += g_ePointSystem[PointsSemiAce]
					#else
					client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_SCORED_SEMIACE")
					#endif
				}
				else
				{
					client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "X_SCORED_SEMIACE", g_szName[g_eInformations[SEMI_ACE]])
				}
				client_cmd(iPlayer, "spk vox/buzwarn")
			}

			#if defined POINTS_SYS
			SaveData(iPlayer, false)
			#endif
		}

		for(new i = 1; i <= MAX_PLAYERS; i++)
		{
			for(new j = 1; j <= MAX_PLAYERS; j++)
			{
				g_ePlayerStats[i][j][DamageGiven] = 0
				g_ePlayerStats[i][j][HitsGiven] = 0
				g_ePlayerStats[i][j][PlayerHealth] = 0
			}
		}

		if(g_eTeamPause[TERO_PAUSE] == 1)
		{
			set_pcvar_num(g_cFreezeTime, g_ePluginSettings[iPauseTime])
			server_cmd("mp_buytime 0.80")
			g_eTeamPause[TERO_PAUSE] += 1
			g_bPaused = true
		}
		else if(g_eTeamPause[CT_PAUSE] == 1)
		{
			set_pcvar_num(g_cFreezeTime, g_ePluginSettings[iPauseTime])
			server_cmd("mp_buytime 0.80")
			g_eTeamPause[CT_PAUSE] += 1
			g_bPaused = true
		}

		if(!g_bPaused)
		{
			set_pcvar_num(g_cFreezeTime, g_iFreezeTime)
		}
	}

	return HC_CONTINUE
}

#if defined FASTCUP_MODE
public task_ask_player(id)
{
	id -= TASK_ASK

	new szTemp[64]

	formatex(szTemp, charsmax(szTemp), "\r%s \w%L", g_ePluginSettings[szPrefix], LANG_SERVER, "MENU_ASK_PLAYER")
	new menu = menu_create(szTemp, "handle_ask_menu")

	formatex(szTemp, charsmax(szTemp), "\y%L", LANG_SERVER, "ASK_MENU_SWITCH")
	menu_additem(menu, szTemp)

	formatex(szTemp, charsmax(szTemp), "\y%L", LANG_SERVER, "ASK_MENU_STAY")
	menu_additem(menu, szTemp)

	_MenuDisplay(id, menu)
}

public handle_ask_menu(id, menu, item)
{
	if(item == MENU_EXIT || !IsPlayer(id) || g_bVoted || g_eBooleans[bIsMixOn])
	{
		return _MenuExit(menu)
	}

	switch(item)
	{
		case 0:
		{
			g_iAnswer[SWITCH] += 1
		}
		case 1:
		{
			g_iAnswer[STAY] += 1
		}
	}

	CheckVotes(g_iAnswer)

	return _MenuExit(menu)
}

public CheckVotes(any:iAnswer[])
{
	if(iAnswer[SWITCH] > iAnswer[STAY])
	{
		g_iVote = 1
	}
	else if(iAnswer[SWITCH] < iAnswer[STAY])
	{
		g_iVote = 0
	}
	else if(iAnswer[SWITCH] == iAnswer[STAY])
	{
		g_iVote = 0
	}
	else 
	{
		g_iVote = 0
	}
}

public task_do_change(iTaskID)
{
	g_bVoted = true

	new szTemp[128]

	switch(g_iVote)
	{
		case 0:
		{
			formatex(szTemp, charsmax(szTemp), "%L", LANG_SERVER, "STAY")
		}
		case 1:
		{
			formatex(szTemp, charsmax(szTemp), "%L", LANG_SERVER, "SWITCH")
		}
	}

	client_print_color(0, 0, "^4%s %L %s", g_ePluginSettings[szPrefix], LANG_SERVER, "TEAM_VOTED", szTemp)

	if(g_iVote) 
	{
		rg_swap_all_players()
	}

	g_eBooleans[bCanShowStats] = false

	clcmd_startmix(g_eInformations[MIX_STARTER], true)

	return PLUGIN_HANDLED
}
#endif

public ev_NewRound()
{
	#if defined FASTCUP_MODE
	if(g_eBooleans[bIsMixOn] && g_iKnifes == 3)
	#else
	if(g_eBooleans[bIsMixOn])
	#endif
	{
		set_task(1.0, "task_show_score")
		if(IsHalf() && !g_eBooleans[bOvertime] && !g_eBooleans[bTeamSwap])
		{
			set_pcvar_num(g_cFreezeTime, g_ePluginSettings[iFreezetimeSwap])
		}

		g_eBooleans[bCanShowStats] = true

		if(g_bPaused)
		{
			set_task(0.01, "task_show_dhud")
		}
	}
}

public ev_GameRestart()
{
	set_task(1.0, "task_change_bool", TASK_CHANGE_BOOL)
}

public task_change_bool(taskid)
{
	g_eBooleans[bIsStoppingMix] = false

	remove_task(TASK_CHANGE_BOOL)
}

public CS_OnBuyAttempt(id, item)
{
	if(g_eBooleans[bIsWarm] && g_eWarmSettings[bWarmType] || g_eBooleans[bIsKnife])
	{
		return PLUGIN_HANDLED
	}
	
	if(item == CSI_SHIELDGUN || item == CSI_NVGS || item == CSI_SG550 || item == CSI_G3SG1 || item == CSI_SHIELD)
	{
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public clcmd_chat_on(id)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	#if defined DEBUG
	client_print_color(0, 0, "clcmd_chat() called")
	#endif

	if(!g_eBooleans[bIsMixOn])
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_NOT_STARTED_YET")
		return PLUGIN_HANDLED
	}

	static iPlayer, iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")

	g_eInformations[CHAT] = id

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(g_eInformations[CHAT] == iPlayer)
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "CHAT_OPENED_BY_YOU")
		}
		else
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "CHAT_OPENED_BY_X", g_szName[g_eInformations[CHAT]])
		}

		g_eBooleans[bCanChat][iPlayer] = true
	}

	return PLUGIN_HANDLED
}

public clcmd_chat_off(id)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	#if defined DEBUG
	client_print_color(0, 0, "clcmd_chat() called")
	#endif

	if(!g_eBooleans[bIsMixOn])
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_NOT_STARTED_YET")
		return PLUGIN_HANDLED
	}

	static iPlayer, iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")

	g_eInformations[CHAT] = id

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(g_eInformations[CHAT] == iPlayer)
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "CHAT_CLOSED_BY_YOU")
		}
		else
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "CHAT_CLOSED_BY_X", g_szName[g_eInformations[CHAT]])
		}
		
		if(!(get_user_flags(iPlayer) & read_flags(g_ePluginSettings[szAdminFlags])))
		{
			g_eBooleans[bCanChat][iPlayer] = false
		}
	}

	return PLUGIN_HANDLED
}

public hook_say(id)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE

	if(!g_eBooleans[bCanChat][id] && g_eBooleans[bIsMixOn])
	{
		if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminFlags])))
		{
			return PLUGIN_HANDLED
		}
		else if(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminFlags]))
		{
			return PLUGIN_CONTINUE
		}
	}

	new sArg[MAX_NAME_LENGTH], szMessage[180]
	read_argv(1, sArg, charsmax(sArg))
	read_args(szMessage, charsmax(szMessage))
	remove_quotes(szMessage)

	if(strlen(szMessage) != 0)
	{
		if(szMessage[0] == '/')
		{
			switch(szMessage[1])
			{
				case 's':
				{
					if(szMessage[2] == 'p' && szMessage[5] != 'a')
					{
						clcmd_move_spec(id, szMessage, charsmax(szMessage), 1)
						return PLUGIN_HANDLED
					}
				}
				case 't':
				{
					if(szMessage[2] == ' ')
					{
						clcmd_move_t(id, szMessage, charsmax(szMessage), 1)
						return PLUGIN_HANDLED
					}
				}
				case 'c':
				{
					if(szMessage[2] == 't')
					{
						clcmd_move_ct(id, szMessage, charsmax(szMessage), 1)
						return PLUGIN_HANDLED
					}
				}
				case 'p':
				{
					if(szMessage[2] == 'a' && szMessage[5] == ' ')
					{
						clcmd_passon(id, szMessage, 1)
						return PLUGIN_HANDLED
					}
				}
			}
		}

		new iPlayer, iPlayers[MAX_PLAYERS], iNum
		get_players(iPlayers, iNum, "c")

		if(is_user_alive(id))
		{
			format(szMessage, charsmax(szMessage), "^3%n^1: %s", id, szMessage)
		}
		else
		{
			format(szMessage, charsmax(szMessage), "^1*[DEAD] ^3%n^1: %s", id, szMessage)
		}

		for(new i; i < iNum; i++)
		{
			iPlayer = iPlayers[i]

			client_print_color(iPlayer, id, szMessage)
		}
	}

	return PLUGIN_CONTINUE
}

public HookSay(iMsgID, Msg, iDest)
{
	new szBuffer[64]
	get_msg_arg_string(2, szBuffer, charsmax(szBuffer))

	if(g_eBooleans[bIsMixOn] || g_eBooleans[bIsStoppingMix])
	{
		if(equal(szBuffer, "#Cstrike_Name_Change"))
		{
	        return PLUGIN_HANDLED
		}
	}

	if(equal(szBuffer, "#Cstrike_Chat_CT") || equal(szBuffer, "#Cstrike_Chat_T") || equal(szBuffer, "#Cstrike_Chat_CT_Dead") || equal(szBuffer, "#Cstrike_Chat_T_Dead"))
	{
		return PLUGIN_CONTINUE
	}

	return PLUGIN_HANDLED
}

public clcmd_overtime(id)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	#if defined DEBUG
	client_print_color(0, 0, "clcmd_overtime() called")
	#endif

	if(!g_eBooleans[bIsMixOn])
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_NOT_STARTED_YET")
		return PLUGIN_HANDLED
	}

	if(!CanOvertime())
	{
		client_print_color(id, id, "^4%s ^1%L", g_ePluginSettings[szPrefix], LANG_SERVER, "CANT_START_OVERTIME_YET")
		return PLUGIN_HANDLED
	}

	if(g_eBooleans[bOvertime])
	{
		client_print_color(id, id, "^4%s ^1%L", g_ePluginSettings[szPrefix], LANG_SERVER, "OVERTIME_ALREADY_STARTED")
		return PLUGIN_HANDLED
	}

	static iPlayer, iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")

	g_eInformations[OVERTIME_STARTER] = id

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(g_eInformations[OVERTIME_STARTER] == iPlayer)
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "OVERTIME_STARTED_BY_YOU")
		}
		else
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "OVERTIME_STARTED_BY_X", g_szName[g_eInformations[OVERTIME_STARTER]])
		}
	}

	OvertimeConfig()

	set_task(1.0, "task_delayed_swap")

	g_eBooleans[bOvertime] = true

	g_eBooleans[bTeamSwap] = false

	g_eOvertime[FirstOvertime] = true

	return PLUGIN_HANDLED
}

public clcmd_passon(id, szMessage[180], IsSay)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	#if defined DEBUG
	client_print_color(0, 0, "clcmd_passon() called")
	#endif

	if(!g_eBooleans[bIsMixOn])
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_NOT_STARTED_YET")
		return PLUGIN_HANDLED
	}

	if(IsSay)
	{
		read_argv(1, szMessage, charsmax(szMessage))
		replace_all(szMessage, charsmax(szMessage), "/pass", "")
	}

	server_cmd("sv_password %s", szMessage)

	static iPlayer, iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")

	g_eInformations[PASSON_CALLER] = id

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(g_eInformations[PASSON_CALLER] == iPlayer)
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PASSWORD_SETTED_BY_YOU", szMessage)
		}
		else if((get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PASSWORD_SETTED_BY_X_ADMIN", g_szName[g_eInformations[PASSON_CALLER]], szMessage)
		}
		else
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PASSWORD_SETTED_BY_X", g_szName[g_eInformations[PASSON_CALLER]])
		}
	}

	return PLUGIN_HANDLED
}

public clcmd_passoff(id)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	#if defined DEBUG
	client_print_color(0, 0, "clcmd_passoff() called")
	#endif

	if(!g_eBooleans[bIsMixOn])
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_NOT_STARTED_YET")
		return PLUGIN_HANDLED
	}

	server_cmd("sv_password ^"^"")

	static iPlayer, iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")

	g_eInformations[PASSOFF_CALLER] = id

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(g_eInformations[PASSOFF_CALLER] == iPlayer)
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PASSWORD_REMOVED_BY_YOU")
		}
		else
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PASSWORD_REMOVED_BY_X", g_szName[g_eInformations[PASSOFF_CALLER]])
		}
	}

	return PLUGIN_HANDLED
}

public task_show_score()
{
	new iPlayer, iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(!IsHalf() && !IsLastRound() && !g_eBooleans[bOvertime] && !IsPreLastRound())
		{
			if(!g_iStart)
			{
				client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_SCORE_IS", LANG_SERVER, "CT_TEAM", g_iScore[CT_SCORE], LANG_SERVER, "TERO_TEAM", g_iScore[TERO_SCORE])
			}
			else
			{
				client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_SCORE_IS_WITH_END", LANG_SERVER, "CT_TEAM", g_iScore[CT_SCORE], LANG_SERVER, "TERO_TEAM", g_iScore[TERO_SCORE])
			}
		}
		
		if(IsHalf() && !g_eBooleans[bOvertime] && !g_eBooleans[bTeamSwap])
		{
			set_pcvar_num(g_cFreezeTime, g_ePluginSettings[iFreezetimeSwap])
			if(!IsPreLastRound())
			{
				client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_HALF_SCORE", LANG_SERVER, "CT_TEAM", g_iScore[CT_SCORE], LANG_SERVER, "TERO_TEAM", g_iScore[TERO_SCORE])
			}

			#if defined DEBUG
			client_print_color(0, 0, "IsHalf() called")
			#endif
		}

		if(IsPreLastRound() && !g_eBooleans[bOvertime])
		{
			new szTemp[16]
			LastRoundUntilWin(szTemp, charsmax(szTemp))

			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_LAST_ROUND_FOR_X_TEAM", szTemp)
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_SCORE_IS_WITH_END", LANG_SERVER, "CT_TEAM", g_iScore[CT_SCORE], LANG_SERVER, "TERO_TEAM", g_iScore[TERO_SCORE])
		}

		if(IsLastRound())
		{
			new szTemp[16]
			WinnerTeam(szTemp, charsmax(szTemp))

			#if defined POINTS_SYS
			new CsTeams:iTeam = cs_get_user_team(iPlayer)
			if(iTeam == CS_TEAM_CT && szTemp[0] == 'C' || iTeam == CS_TEAM_T && szTemp[0] == 'T')
			{
				GiveTeamReward(iPlayer, g_ePointSystem[PointsTeamWin])
				g_iWins[iPlayer] += 1

				ExecuteForward(g_eForwards[Winners], g_iRet, iPlayer)
			}
			else if(iTeam == CS_TEAM_CT && szTemp[0] == 'T' || iTeam == CS_TEAM_T && szTemp[0] == 'C')
			{
				g_iLose[iPlayer] += 1
			}

			ExecuteForward(g_eForwards[GameOver], g_iRet, iPlayer, g_iDuration, szTemp[0], g_iPoints[iPlayer])
			#else 
			ExecuteForward(g_eForwards[GameOver], g_iRet, iPlayer, g_iDuration, szTemp[0])
			#endif

			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_WON_BY_X_TEAM", szTemp)
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_PLAYER, "MIX_END_SCORE", LANG_SERVER, "CT_TEAM", g_iScore[CT_SCORE], LANG_SERVER, "TERO_TEAM", g_iScore[TERO_SCORE])
		
			client_cmd(iPlayer, "stop")
		}

		if(g_eOvertime[FirstOvertime] && !IsHalf() && !OvertimeFinished())
		{
			#if !defined OVERTIME_ONE_ROUND
			if(!g_eOvertime[SecondOvertime] && !g_eBooleans[bTeamSwap])
			{
				client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "FIRST_OVERTIME_SCORE_IS", LANG_SERVER, "CT_TEAM", g_iOvertimeScore[CT_OVER_SCORE], LANG_SERVER, "TERO_TEAM", g_iOvertimeScore[TERO_OVER_SCORE])
			}
			
			if(g_eOvertime[SecondOvertime] && g_eBooleans[bTeamSwap])
			{
				client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "SECOND_OVERTIME_SCORE_IS", LANG_SERVER, "CT_TEAM", g_iOvertimeScore[CT_OVER_SCORE], LANG_SERVER, "TERO_TEAM", g_iOvertimeScore[TERO_OVER_SCORE])
			}
			#else
			if(!g_eOvertime[SecondOvertime] && !g_eBooleans[bTeamSwap])
			{
				client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "ONE_ROUND_FOR_WIN", LANG_SERVER)
			}
			#endif
		}

		if(OvertimeFinished())
		{
			new szTemp[16]
			WinnerTeam(szTemp, charsmax(szTemp))

			#if defined POINTS_SYS
			if(cs_get_user_team(iPlayer) == CS_TEAM_CT && szTemp[0] == 'C' || cs_get_user_team(iPlayer) == CS_TEAM_T && szTemp[0] == 'T')
			{
				GiveTeamReward(iPlayer, g_ePointSystem[PointsTeamWin])
			}

			ExecuteForward(g_eForwards[GameOver], g_iRet, iPlayer, g_iDuration, szTemp[0], g_iPoints[iPlayer])
			#else 
			ExecuteForward(g_eForwards[GameOver], g_iRet, iPlayer, g_iDuration, szTemp[0])
			#endif

			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_WON_BY_X_TEAM_IN_OVERTIME", szTemp)
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_PLAYER, "MIX_OVERTIME_END_SCORE", LANG_SERVER, "CT_TEAM", g_iOvertimeScore[CT_OVER_SCORE], LANG_SERVER, "TERO_TEAM", g_iOvertimeScore[TERO_OVER_SCORE])
		
			client_cmd(iPlayer, "stop")
		}

		g_iPlayerKills[iPlayer] = 0
	}

	ExecuteForward(g_eForwards[NewRound], g_iRet, g_iScore[CT_SCORE], g_iScore[TERO_SCORE], g_iDuration)

	if(IsHalf() && !g_eBooleans[bOvertime] && !g_eBooleans[bTeamSwap])
	{
		set_task(1.0, "task_swap_score")
		set_task(1.1, "task_delayed_swap")
	}

	if(IsLastRound() || OvertimeFinished())
	{
		set_task(5.0, "task_stop_mix")
	}

	g_eBooleans[bIsStoppingMix] = false
	g_eInformations[ACE] = -1
	g_eInformations[SEMI_ACE] = -1

	g_iStart = 1
}

public task_show_dhud()
{
	if(g_iTimer > 0)
	{
		static szMsg[64]
		formatex(szMsg, charsmax(szMsg), "%s %L [%d]", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_TIMEOUTED", g_iTimer)
		set_dhudmessage(255, 255, 255, -1.0, 0.2, 0, 0.0, 1.00)
		show_dhudmessage(0, szMsg)

		g_iTimer--

		if(g_bPaused)
		{
			set_task(1.0, "task_show_dhud")
		}
	}
}

public task_delayed_swap()
{
	new iPlayer, iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")

	rg_swap_all_players()

	new szDefaultWeap[48]

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		new TeamName:iTeam = get_member(iPlayer, m_iTeam)

		if(iTeam == TEAM_UNASSIGNED || iTeam == TEAM_SPECTATOR)
			continue 

		g_ePlayerScore[iPlayer][iKILLS] = get_user_frags(iPlayer)
		g_ePlayerScore[iPlayer][iDEATHS] = get_user_deaths(iPlayer)
		set_member_game(m_bCTCantBuy, true)
		set_member_game(m_bTCantBuy, true)
		set_member_game(m_bCompleteReset, true)
		rg_add_account(iPlayer, get_cvar_num("mp_startmoney"), AS_SET)
		rg_remove_all_items(iPlayer, true)
		rg_set_user_armor(iPlayer, 0, ARMOR_NONE)
		rg_give_item(iPlayer, "weapon_knife")

		switch(iTeam)
		{
			case TEAM_TERRORIST:
			{
				get_cvar_string("mp_t_default_weapons_secondary", szDefaultWeap, charsmax(szDefaultWeap))
			}
			case TEAM_CT:
			{
				get_cvar_string("mp_ct_default_weapons_secondary", szDefaultWeap, charsmax(szDefaultWeap))
			}
		}

		format(szDefaultWeap, charsmax(szDefaultWeap), "weapon_%s", szDefaultWeap)
		rg_give_item(iPlayer, szDefaultWeap)
		new WeaponIdType:wid = rg_get_weapon_info(szDefaultWeap, WI_ID)

		if(!wid)
			continue

		rg_set_user_bpammo(iPlayer, wid, rg_get_global_iteminfo(wid, ItemInfo_iMaxClip) * 2)
	}

	rg_round_end(1.0, WINSTATUS_NONE, ROUND_GAME_OVER)

	set_task(1.2, "task_delayed_members")
}

public task_delayed_members()
{
	set_member_game(m_bCTCantBuy, false)
	set_member_game(m_bTCantBuy, false)
	set_member_game(m_bCompleteReset, false)
}

public task_swap_score()
{
	g_eBooleans[bTeamSwap] = true

	#if defined DEBUG
	client_print_color(0, 0, "task_swap_score() called")
	#endif
	
	new temp[6]
	if(g_eBooleans[bOvertime])
	{
			temp[2] = g_iOvertimeScore[CT_OVER_SCORE]
			temp[3] = g_iOvertimeScore[TERO_OVER_SCORE]
			g_iOvertimeScore[TERO_OVER_SCORE] = temp[2]
			g_iOvertimeScore[CT_OVER_SCORE] = temp[3]

			#if defined DEBUG
			client_print_color(0, 0, "if() called")
			#endif
	}
	else
	{
		temp[0] = g_iScore[CT_SCORE]
		temp[1] = g_iScore[TERO_SCORE]
		g_iScore[TERO_SCORE] = temp[0]
		g_iScore[CT_SCORE] = temp[1]

		#if defined DEBUG
		client_print_color(0, 0, "else() called")
		client_print_color(0, 0, "temp[0] = %i", temp[0])
		client_print_color(0, 0, "temp[1] = %i", temp[1])
		#endif
	}
	
	temp[4] = g_eTeamPause[CT_PAUSE]
	temp[5] = g_eTeamPause[TERO_PAUSE]
	g_eTeamPause[TERO_PAUSE] = temp[4]
	g_eTeamPause[CT_PAUSE] = temp[5]

	set_pcvar_num(g_cFreezeTime, g_iFreezeTime)

	for(new i; i < ArraySize(g_aPlayerData); i++)
	{
		ArrayDeleteItem(g_aPlayerData, i)
	}

	set_task(2.0, "task_change_score")
}

public task_change_score()
{
	rg_update_teamscores(g_iScore[CT_SCORE], g_iScore[TERO_SCORE], false)
}

public clcmd_specall(id)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	if(g_eBooleans[bIsMixOn])
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_NEED_STOPPED")
		return PLUGIN_HANDLED
	}

	static iPlayer, iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")

	g_eInformations[SPECALL_CALLER] = id

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(g_eInformations[SPECALL_CALLER] == iPlayer)
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PLAYERS_MOVED_SPEC_BY_YOU")
		}
		else
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PLAYERS_MOVED_SPEC_BY_X", g_szName[g_eInformations[SPECALL_CALLER]])
		}

		rg_join_team(iPlayer, TEAM_SPECTATOR)
		rg_round_end(1.0, WINSTATUS_DRAW, ROUND_END_DRAW, "ROUND DRAW", "ROUND DRAW", true)
	}

	return PLUGIN_HANDLED
}

public task_specall(id)
{
	id -= TASK_SPECALL

	if(!is_user_connected(id))
	{
		return
	}

	rg_join_team(id, TEAM_SPECTATOR)
}

public clcmd_restart(id)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}
	if(!g_eBooleans[bIsMixOn])
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_NOT_STARTED_YET")
		return PLUGIN_HANDLED
	}
	
	if(g_iRoundNum != 0)
	{
		rg_round_end(1.0, WINSTATUS_DRAW, ROUND_END_DRAW, "ROUND DRAW", "ROUND DRAW", true)
		set_task(2.0, "task_set_score")
	}
	else
	{ 
		server_cmd("sv_restart 1")
	}

	g_eBooleans[bCanShowStats] = false

	return PLUGIN_HANDLED
}

public task_set_score()
{
	rg_update_teamscores(g_iScore[CT_SCORE], g_iScore[TERO_SCORE], false)
}

public clcmd_score(id)
{
	if(!g_eBooleans[bIsMixOn])
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_NOT_STARTED_YET")
		return PLUGIN_HANDLED
	}

	if(!IsHalf() && !IsLastRound() && !g_eBooleans[bOvertime] && !IsPreLastRound())
	{
		if(!g_iStart)
		{
			client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_SCORE_IS", LANG_SERVER, "CT_TEAM", g_iScore[CT_SCORE], LANG_SERVER, "TERO_TEAM", g_iScore[TERO_SCORE])
		}
		else
		{
			client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_SCORE_IS_WITH_END", LANG_SERVER, "CT_TEAM", g_iScore[CT_SCORE], LANG_SERVER, "TERO_TEAM", g_iScore[TERO_SCORE])
		}
	}

	if(g_eOvertime[FirstOvertime] && !IsHalf() && !OvertimeFinished())
	{
		if(!g_eOvertime[SecondOvertime] && !g_eBooleans[bTeamSwap])
		{
			client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "FIRST_OVERTIME_SCORE_IS", LANG_SERVER, "CT_TEAM", g_iOvertimeScore[CT_OVER_SCORE], LANG_SERVER, "TERO_TEAM", g_iOvertimeScore[TERO_OVER_SCORE])
		}
	}

	if(IsPreLastRound() && !g_eBooleans[bOvertime])
	{
		new szTemp[16]
		LastRoundUntilWin(szTemp, charsmax(szTemp))

		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_LAST_ROUND_FOR_X_TEAM", szTemp)
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_SCORE_IS_WITH_END", LANG_SERVER, "CT_TEAM", g_iScore[CT_SCORE], LANG_SERVER, "TERO_TEAM", g_iScore[TERO_SCORE])
	}

	return PLUGIN_CONTINUE
}

public clcmd_ct(id)
{
	new arg1[MAX_NAME_LENGTH]
	read_argv(1, arg1, charsmax(arg1))

	clcmd_move_ct(id, arg1, charsmax(arg1))

	return PLUGIN_HANDLED
}

stock clcmd_move_ct(id, szMessage[], iLen, IsSay = -1)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	new target

	if(IsSay)
	{
		replace_all(szMessage, iLen, "/ct ", "")
		replace_all(szMessage, iLen, "^"", "")
	}

	target = cmd_target(id, szMessage, CMDTARGET_ALLOW_SELF)

	if(!target)
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PLAYER_NOT_FOUND")
		return PLUGIN_HANDLED
	}

	static iPlayer, iPlayers[MAX_PLAYERS], iNum, szTeam[22]
	get_players(iPlayers, iNum, "ch")

	GetTeam(CT, szTeam, charsmax(szTeam))

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(id == iPlayer)
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PLAYER_X_MOVED_X_BY_YOU", g_szName[target], szTeam)
		}
		else if(target == iPlayer)
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_WERE_MOVED_X_BY_X", szTeam, g_szName[id])
		}
		else
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PLAYER_X_MOVED_X_BY_X", g_szName[target], szTeam, g_szName[id])
		}
	}

	rg_join_team(target, TEAM_CT)

	return PLUGIN_HANDLED
}

public clcmd_t(id)
{
	new arg1[MAX_NAME_LENGTH]
	read_argv(1, arg1, charsmax(arg1))

	clcmd_move_t(id, arg1, charsmax(arg1))

	return PLUGIN_HANDLED
}

stock clcmd_move_t(id, szMessage[], iLen, IsSay = -1)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	new target
	
	if(IsSay)
	{
		replace_all(szMessage, iLen, "/t ", "")
		replace_all(szMessage, iLen, "^"", "")
	}

	target = cmd_target(id, szMessage, CMDTARGET_ALLOW_SELF)

	if(!target)
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PLAYER_NOT_FOUND")
		return PLUGIN_HANDLED
	}

	static iPlayer, iPlayers[MAX_PLAYERS], iNum, szTeam[22]
	get_players(iPlayers, iNum, "ch")

	GetTeam(TERO, szTeam, charsmax(szTeam))

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(id == iPlayer)
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PLAYER_X_MOVED_X_BY_YOU", g_szName[target], szTeam)
		}
		else if(target == iPlayer)
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_WERE_MOVED_X_BY_X", szTeam, g_szName[id])
		}
		else
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PLAYER_X_MOVED_X_BY_X", g_szName[target], szTeam, g_szName[id])
		}
	}

	rg_join_team(target, TEAM_TERRORIST)

	return PLUGIN_HANDLED
}

public clcmd_spec(id)
{
	new arg1[MAX_NAME_LENGTH]
	read_argv(1, arg1, charsmax(arg1))

	clcmd_move_spec(id, arg1, charsmax(arg1))

	return PLUGIN_HANDLED
}

stock clcmd_move_spec(id, szMessage[], iLen, IsSay = -1)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	new target

	if(IsSay)
	{
		replace_all(szMessage, iLen, "/spec ", "")
		replace_all(szMessage, iLen, "^"", "")
	}

	target = cmd_target(id, szMessage, CMDTARGET_ALLOW_SELF)

	if(!target)
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PLAYER_NOT_FOUND")
		return PLUGIN_HANDLED
	}

	static iPlayer, iPlayers[MAX_PLAYERS], iNum, szTeam[22]
	get_players(iPlayers, iNum, "ch")

	GetTeam(SPEC, szTeam, charsmax(szTeam))

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(id == iPlayer)
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PLAYER_X_MOVED_X_BY_YOU", g_szName[target], szTeam)
		}
		else if(target == iPlayer)
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_WERE_MOVED_X_BY_X", szTeam, g_szName[id])
		}
		else
		{
			client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PLAYER_X_MOVED_X_BY_X", g_szName[target], szTeam, g_szName[id])
		}
	}

	rg_join_team(target, TEAM_SPECTATOR)
	

	return PLUGIN_HANDLED
}

public clcmd_start_demo(id)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	#if defined DEBUG
	client_print_color(0, 0, "clcmd_start_Demo() called")
	#endif

	if(!g_eBooleans[bIsMixOn])
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_NOT_STARTED_YET")
		return PLUGIN_HANDLED
	}

	new arg1[MAX_NAME_LENGTH], arg2[32], target
	read_argv(1, arg1, charsmax(arg1))

	if(g_eDemoSettings[iDemoType] == DEMO_CIN_NAME)
	{
		read_argv(2, arg2, charsmax(arg2))
	}

	#if defined DEBUG
	target = cmd_target(id, arg1, CMDTARGET_ALLOW_SELF)
	#else
	target = cmd_target(id, arg1)
	#endif

	if(!target)
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PLAYER_NOT_FOUND")
		return PLUGIN_HANDLED
	}

	new len = strlen(arg2)
	if(g_eDemoSettings[iDemoType] == DEMO_CIN_NAME)
	{
		if(len < 2)
		{
			client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "DEMO_NAME_REQUIRED")
			return PLUGIN_HANDLED
		}
	}

	static iPlayer, iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(get_user_flags(iPlayer) & read_flags(g_ePluginSettings[szAdminFlags]))
		{
			if(iPlayer == id)
			{
				client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "DEMO_STARTED_BY_YOU_FOR_X", g_szName[target])
			}
			else
			{
				client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "DEMO_STARTED_BY_X_FOR_X", g_szName[id], g_szName[target])
			}
		}
	}

	switch(g_eDemoSettings[iDemoType])
	{
		case DEMO_MAPNAME:
		{
			new szMapName[32]
			get_mapname(szMapName, charsmax(szMapName))

			client_cmd(target, "record ^"%s^"", szMapName)
		}
		case DEMO_CUSTOM_NAME:
		{
			client_cmd(target, "record ^"%s^"", g_eDemoSettings[szDemoName])
		}
		case DEMO_CIN_NAME:
		{
			client_cmd(target, "record ^"%s^"", arg2)
		}
	}

	return PLUGIN_HANDLED
}

public clcmd_stop_demo(id)
{
	if(!(get_user_flags(id) & read_flags(g_ePluginSettings[szAdminAccess])))
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	#if defined DEBUG
	client_print_color(0, 0, "clcmd_stop_Demo() called")
	#endif

	if(!g_eBooleans[bIsMixOn])
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_NOT_STARTED_YET")
		return PLUGIN_HANDLED
	}

	new arg1[MAX_NAME_LENGTH], target
	read_argv(1, arg1, charsmax(arg1))

	#if defined DEBUG
	target = cmd_target(id, arg1, CMDTARGET_ALLOW_SELF)
	#else
	target = cmd_target(id, arg1)
	#endif

	if(!target)
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PLAYER_NOT_FOUND")
		return PLUGIN_HANDLED
	}

	static iPlayer, iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "ch")

	for(new i; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(get_user_flags(iPlayer) & read_flags(g_ePluginSettings[szAdminFlags]))
		{
			if(iPlayer == id)
			{
				client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "DEMO_STOPPED_BY_YOU_FOR_X", g_szName[target])
			}
			else
			{
				client_print_color(iPlayer, iPlayer, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "DEMO_STOPPED_BY_X_FOR_X", g_szName[id], g_szName[target])
			}
		}
	}

	client_cmd(target, "stop")

	return PLUGIN_HANDLED
}

#if defined POINTS_SYS
public clcmd_say_rank(id)
{
	if(!is_user_connected(id) || !g_bConnected)
		return PLUGIN_HANDLED

	new szTemp[512]
	formatex(szTemp, charsmax(szTemp), "SELECT * FROM `%s` ORDER BY `%s`.`Points` DESC LIMIT 0,15", g_ePluginSettings[szTable], g_ePluginSettings[szTable])
	g_iIndex = id
	SQL_ThreadQuery(g_hSqlTuple, "format_top15", szTemp)

	return PLUGIN_HANDLED
}

public format_top15(iFailState, Handle:szQuery, Error[], Errcode, Data[], DataSize)
{
	switch(iFailState)
	{
		case TQUERY_CONNECT_FAILED: 
		{
			log_amx("[SQL Error] Connection failed (%i): %s", Errcode, Error);
		}
		case TQUERY_QUERY_FAILED:
		{
			log_amx("[SQL Error] Query failed (%i): %s", Errcode, Error);
		}
	}

	enum _:PlayerData
	{
		szSteamID[32],
		szName[32],
		iPoints
	}

	new iRows = SQL_NumResults(szQuery)
	new iInfos[15][PlayerData]

	if( SQL_MoreResults(szQuery) ) 
	{
		for(new i = 0 ; i < iRows ; i++)
		{
			SQL_ReadResult(szQuery, SQL_FieldNameToNum(szQuery, "SteamID"), iInfos[i][szSteamID], charsmax(iInfos[][szSteamID]))
			SQL_ReadResult(szQuery, SQL_FieldNameToNum(szQuery, "Name"), iInfos[i][szName], charsmax(iInfos[][szName]))
			iInfos[i][iPoints]	= SQL_ReadResult(szQuery, SQL_FieldNameToNum(szQuery, "Points"))
            
			SQL_NextRow(szQuery)
		}
	}

	if(iRows > 0) 
    {
		new iLen = 0;
		iLen = formatex( g_szBuffer[iLen], charsmax(g_szBuffer), "<meta charset=UTF-8><style>body{background:#000}tr{text-align:left} table{font-size:25px;color:#fff;padding:15px; min-width:600px} h2{color:#FFF;font-family:Arial} td{border:2px solid #27bcfe} th{border:2px solid #27bcfe; color: #27bcfe;}</style><body>")
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "<body bgcolor=#000000><table align=center><tr><th class=p>#<td class=p><th>Name<th>SteamID<th>Points^n" )     
        
		for(new i = 0 ; i < iRows ; i++) 
		{
			iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "<tr><td class=p>%d<td class=p><td>%s<td>%s<td>%i", i + 1, iInfos[i][szName], iInfos[i][szSteamID], iInfos[i][iPoints])
		}
	}
	show_motd(g_iIndex, g_szBuffer, "Top15 Points")

	return PLUGIN_HANDLED
}

public concmd_reset_db(id)
{
	if(!(get_user_flags(id) & ADMIN_IMMUNITY))
	{
		console_print(id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOU_DONT_HAVE_ACCESS")
		return PLUGIN_HANDLED
	}

	new szQuery[56]
	formatex(szQuery, charsmax(szQuery), "TRUNCATE TABLE `%s`", g_ePluginSettings[szTable])
	SQL_ThreadQuery(g_hSqlTuple, "QueryHandler", szQuery)
	console_print(id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "DATABASE_WIPED")

	return PLUGIN_HANDLED
}
#endif

public clcmd_say_pause(id)
{
	if(!g_eBooleans[bIsMixOn])
	{
		client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_NOT_STARTED_YET")
		return PLUGIN_HANDLED
	}

	new CsTeams:iTeam = cs_get_user_team(id)

	switch(iTeam)
	{
		case CS_TEAM_T:
		{
			if(!g_eTeamPause[TERO_PAUSE])
			{
				g_eTeamPause[TERO_PAUSE] = 1
				client_print_color(0, 0, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PLAYER_X_REQUESTED_TIMEOUT", g_szName[id])
			}
			else
			{
				client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOUR_TEAM_ALREADY_TIMEOUT")
			}
		}
		case CS_TEAM_CT:
		{
			if(!g_eTeamPause[CT_PAUSE])
			{
				g_eTeamPause[CT_PAUSE] = 1
				client_print_color(0, 0, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "PLAYER_X_REQUESTED_TIMEOUT", g_szName[id])
			}
			else
			{
				client_print_color(id, id, "^4%s %L", g_ePluginSettings[szPrefix], LANG_SERVER, "YOUR_TEAM_ALREADY_TIMEOUT")
			}
		}
	}

	return PLUGIN_CONTINUE
}

#if defined POINTS_SYS
public task_load(id)
{
	id -= TASK_LOAD

	LoadData(id)
}

public LoadData(id)
{
	new szQuery[100];
	formatex(szQuery, charsmax(szQuery), "SELECT * FROM `%s` WHERE `SteamID` = ^"%s^";", g_ePluginSettings[szTable], g_szAuthID[id])

	new index[2]
	index[0] = id
	SQL_ThreadQuery(g_hSqlTuple, "QueryLoadData", szQuery, index, charsmax(index));
}

public QueryLoadData(iFailState, Handle:iQuery, szError[], iErrorCode, szData[])
{
	new id = szData[0]

	switch(iFailState)
	{
		case TQUERY_CONNECT_FAILED, TQUERY_QUERY_FAILED:
		{
			log_amx("[SQL Error Load] Query failed (%i): %s", iErrorCode, szError) < 3
			if(g_iTry < 3)
			{
				LoadData(id)
				g_iTry++
			}
			return 
		}
	}

	g_iTry = 0

	if(SQL_NumResults(iQuery) > 0)
	{
		g_iPoints[id] = SQL_ReadResult(iQuery, SQL_FieldNameToNum(iQuery, "Points"));
		g_iDeaths[id] = SQL_ReadResult(iQuery, SQL_FieldNameToNum(iQuery, "Deaths"));
		g_iKills[id] = SQL_ReadResult(iQuery, SQL_FieldNameToNum(iQuery, "Kills"));
		g_iWins[id] = SQL_ReadResult(iQuery, SQL_FieldNameToNum(iQuery, "Wins"));
		g_iLose[id] = SQL_ReadResult(iQuery, SQL_FieldNameToNum(iQuery, "Lose"));
		g_bLoadedPlayer[id] = true

		goto _markOnline
	}

	new szQuery[256]

	formatex(szQuery, charsmax(szQuery), "INSERT INTO `%s`\
		(`SteamID`,\
		`Name`,\
		`Points`,\
		`Kills`,\
		`Deaths`,\
		`Wins`,\
		`Lose`, \
		`Online` \
		) VALUES ('%s', ^"%s^", '%d', '0', '0', '0', '0', '1');", g_ePluginSettings[szTable], g_szAuthID[id], g_szName[id], g_ePluginSettings[iStartPoints]);

	SQL_ThreadQuery(g_hSqlTuple, "LoadPData", szQuery, szData, strlen(szData));

	_markOnline:
	formatex(szQuery, charsmax(szQuery), "UPDATE `%s` SET `Online`='1' WHERE `SteamID`=^"%s^";", g_ePluginSettings[szTable], g_szAuthID[id]);

	SQL_ThreadQuery(g_hSqlTuple, "QueryHandler", szQuery, szQuery, charsmax(szQuery));
}

public LoadPData(iFailState, Handle:iQuery, szError[], iErrorCode, szData[])
{
	new id = szData[0]

	switch(iFailState)
	{
		case TQUERY_CONNECT_FAILED, TQUERY_QUERY_FAILED:
		{
			log_amx("[SQL Error Load] Query failed (%i): %s", iErrorCode, szError)
			if(g_iTry < 3)
			{
				LoadData(id)
				g_iTry++
			}
			return 
		}
	}
	g_bLoadedPlayer[id] = true
}

public SaveData(id, bool:bDisconnect)
{
	if(!g_bLoadedPlayer[id])
		return

	ExecuteForward(g_eForwards[Save], g_iRet, id)

	new szQuery[300]
	formatex(szQuery, charsmax(szQuery), "UPDATE `%s` \
		SET `Points`='%d', \
		`Name`=^"%s^", \
		`Kills`='%d', \
		`Deaths`='%d', \
		`Wins`='%d', \
		`Lose`='%d', \
		`Online`='%d' \
		WHERE `SteamID`=^"%s^";", g_ePluginSettings[szTable], g_iPoints[id], g_szName[id], g_iKills[id], g_iDeaths[id], g_iWins[id], g_iLose[id], bDisconnect ? 0 : 1, g_szAuthID[id])

	SQL_ThreadQuery(g_hSqlTuple, "QueryHandler", szQuery, szQuery, charsmax(szQuery));
}

public QueryHandler(iFailState, Handle:iQuery, szError[], iErrorCode, szQuery[])
{
	switch(iFailState)
	{
		case TQUERY_CONNECT_FAILED: 
		{
			log_amx("[SQL Error Save] Connection failed (%i): %s", iErrorCode, szError);
		}
		case TQUERY_QUERY_FAILED:
		{
			log_amx("[SQL Error Save] Query failed (%i): %s", iErrorCode, szError);
			log_amx("Query: %s", szQuery)
		}
	}
}
#endif

ResetScore()
{
	g_iScore[TERO_SCORE] = 0
	g_iScore[CT_SCORE] = 0
	g_iOvertimeScore[CT_OVER_SCORE] = 0
	g_iOvertimeScore[TERO_OVER_SCORE] = 0
	g_eTeamPause[CT_PAUSE] = 0
	g_eTeamPause[TERO_PAUSE] = 0
	g_iRoundNum = 0
	for(new i; i < MAX_PLAYERS; i++ )
	{
		g_eBooleans[bCanChat][i] = true
	}
	g_eBooleans[bIsMixOn] = false
	g_eBooleans[bOvertime] = false
	g_eBooleans[bTeamSwap] = false
	g_eBooleans[bOvertime] = false
	g_eBooleans[bIsWarm] = false
	g_eOvertime[FirstOvertime] = false
	g_eOvertime[SecondOvertime] = false
	g_eBooleans[bIsKnife] = false

	#if defined FASTCUP_MODE
	g_bVoted = false
	arrayset(g_iAnswer, 0, sizeof(g_iAnswer))
	#endif
	server_cmd("sv_restart 1")
}

stock StartConfig()
{
	static szConfigsDir[48]
	get_configsdir(szConfigsDir, charsmax(szConfigsDir))
	server_cmd("exec %s/%s", szConfigsDir, g_ePluginSettings[szStartCfg])
}

stock StopConfig()
{
	new szConfigsDir[48]
	get_configsdir(szConfigsDir, charsmax(szConfigsDir))

	server_cmd("exec %s/%s", szConfigsDir, g_ePluginSettings[szStopCfg])
}

stock OvertimeConfig()
{
	new szConfigsDir[48]
	get_configsdir(szConfigsDir, charsmax(szConfigsDir))

	server_cmd("exec %s/overtime.cfg", szConfigsDir)
}

stock bool:is_bot(id)
{
	if(is_user_bot(id) || is_user_hltv(id))
	{
		return true
	}
	return false
}

public task_stop_mix()
{
	g_iDuration = 0

	remove_task(TASK_COUNT_DURATION)

	ResetScore()
}

stock bool:IsHalf()
{
	if(!g_eBooleans[bTeamSwap] && g_iRoundNum == 15 && !g_eBooleans[bOvertime])
	{
		return true
	}
	return false
}

stock bool:IsLastRound()
{
	if(g_eBooleans[bTeamSwap] && g_iScore[CT_SCORE] == g_ePluginSettings[iMixEndRound] && !g_eBooleans[bOvertime] || g_eBooleans[bTeamSwap] && g_iScore[TERO_SCORE] == g_ePluginSettings[iMixEndRound] && !g_eBooleans[bOvertime])
	{
		return true
	}
	return false
}

stock bool:IsPreLastRound()
{
	if(g_eBooleans[bTeamSwap] && g_iScore[CT_SCORE] == g_ePluginSettings[iOvertimeScore] && !g_eBooleans[bOvertime] || g_eBooleans[bTeamSwap] && g_iScore[TERO_SCORE] == g_ePluginSettings[iOvertimeScore] && !g_eBooleans[bOvertime])
	{
		return true
	}
	return false
}

stock bool:CanOvertime()
{
	if(IsPreLastRound() && g_iScore[CT_SCORE] == g_iScore[TERO_SCORE])
	{
		return true
	}
	return false
}

stock bool:OvertimeFinished()
{
	#if !defined OVERTIME_ONE_ROUND
	if(g_eBooleans[bOvertime] && g_eOvertime[SecondOvertime])
	{
		if(CheckOverScore() == g_ePluginSettings[iRoundOvertime] * 2)
		{
			return true
		}
		return false
	}
	#else
	if(g_eBooleans[bOvertime])
	{
		if(CheckOverScore())
		{
			return true
		}
		return false
	}
	#endif
	return false
}

stock CheckOvertimePhase()
{
	if((CheckOverScore() == g_ePluginSettings[iRoundOvertime]) && g_eOvertime[FirstOvertime])
	{
		if(g_eBooleans[bOvertime] && !OvertimeFinished() && !g_eBooleans[bTeamSwap] && !g_eOvertime[SecondOvertime])
		{
			g_eOvertime[FirstOvertime] = true
			g_eOvertime[SecondOvertime] = true

			set_task(1.0, "task_delayed_swap")
			set_task(2.0, "task_swap_score")
		}
	}

	#if defined DEBUG
	client_print_color(0, 0, "CheckOvertimePhase() called")
	#endif
}

stock CheckOverScore()
{
	new iResult
	iResult = g_iOvertimeScore[CT_OVER_SCORE] + g_iOvertimeScore[TERO_OVER_SCORE]

	return iResult
}

stock LastRoundUntilWin(output[], len)
{
	if(IsPreLastRound())
	{
		switch(CheckScore())
		{
			case CT_LAST:
			{
				formatex(output, len, "CTs")
			}
			case T_LAST:
			{
				formatex(output, len, "TERORISTs")
			}
		}
	}
}

stock CheckWinner()
{
	new iResult

	if(!g_eBooleans[bOvertime])
	{
		if(g_iScore[CT_SCORE] == g_ePluginSettings[iMixEndRound])
		{
			iResult = CT_SCORE

			#if defined DEBUG
			server_print("iResult case CT_SCORE")
			#endif
		}
		else if(g_iScore[TERO_SCORE] == g_ePluginSettings[iMixEndRound])
		{
			iResult = TERO_SCORE

			#if defined DEBUG
			server_print("iResult case TERO_SCORE")
			#endif
		}
	}
	else 
	{
		if(CheckOverScore() == (g_ePluginSettings[iRoundOvertime] * 2))
		{
			if(g_iOvertimeScore[CT_OVER_SCORE] > g_iOvertimeScore[TERO_OVER_SCORE])
			{
				iResult = CT_OVER_SCORE

				#if defined DEBUG
				server_print("iResult case CT_OVER_SCORE")
				#endif
			}
			else if(g_iOvertimeScore[TERO_OVER_SCORE] > g_iOvertimeScore[CT_OVER_SCORE])
			{
				iResult = TERO_OVER_SCORE

				#if defined DEBUG
				server_print("iResult case TERO_OVER_sCORE")
				#endif
			}
			else if(g_iOvertimeScore[TERO_OVER_SCORE] == g_iOvertimeScore[CT_OVER_SCORE])
			{
				iResult = DRAW

				#if defined DEBUG
				server_print("iResult case DRAW")
				#endif
			}
		}
	}

	#if defined DEBUG
	server_print("iResult: %i", iResult)
	#endif

	return iResult
}

stock WinnerTeam(output[], len)
{
	if(IsLastRound() || OvertimeFinished())
	{
		switch(CheckWinner())
		{
			case CT_SCORE, CT_OVER_SCORE:
			{
				formatex(output, len, "%L", LANG_SERVER, "CT_TEAM")
			}
			case TERO_SCORE, TERO_OVER_SCORE:
			{
				formatex(output, len, "%L", LANG_SERVER, "TERO_TEAM")
			}
			case DRAW:
			{
				formatex(output, len, "%L", LANG_SERVER, "DRAW")
			}
		}
	}
}

stock GiveTeamReward(iPlayer, iPoints)
{
	if(IsLastRound() || OvertimeFinished())
	{
		client_print_color(iPlayer, iPlayer, "^4%s ^1%L", g_ePluginSettings[szPrefix], LANG_SERVER, "MIX_YOUR_TEAM_WON", g_ePointSystem[PointsTeamWin])
	
		g_iPoints[iPlayer] += iPoints
	}
}

stock CheckScore()
{
	new iResult
	if(!g_eBooleans[bOvertime])
	{
		if(g_iScore[CT_SCORE] == (g_ePluginSettings[iMixEndRound] - 1 ))
		{
			iResult = CT_LAST
		}
		
		if(g_iScore[TERO_SCORE] == (g_ePluginSettings[iMixEndRound] - 1))
		{
			iResult = T_LAST
		}
	}

	return iResult
}

stock GetTeam(iNum, output[], len)
{
	switch(iNum)
	{
		case SPEC:
		{
			formatex(output, len, "%L", LANG_SERVER, "SPEC_TEAM")
		}
		case TERO:
		{
			formatex(output, len, "%L", LANG_SERVER, "TERO_TEAM")
		}
		case CT:
		{
			formatex(output, len, "%L", LANG_SERVER, "CT_TEAM")
		}
	}
}

stock _MenuExit(menu)
{
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

stock _MenuDisplay(id, menu)
{
	menu_display(id, menu)
	set_member(id, m_iMenu, Menu_OFF)
	return PLUGIN_HANDLED
}

stock mysql_escape_string(const source[], dest[], length)
{
	SQL_QuoteString(Empty_Handle, dest, length, source)
}

stock SetGameDesc(MatchState:matchState)
{
	new szTemp[30]
	switch(matchState)
	{
		case MATCHSTATE_WARM:
		{
			formatex(szTemp, charsmax(szTemp), "%L", LANG_SERVER, "MATCHSTATE_WARM")
		}
		case MATCHSTATE_IN_MATCH:
		{
			formatex(szTemp, charsmax(szTemp), "%L", LANG_SERVER, "MATCHSTATE_IN_MATCH", g_iScore[CT_SCORE], g_iScore[TERO_SCORE])
		}
		case MATCHSTATE_KNIFE_ROUND:
		{
			formatex(szTemp, charsmax(szTemp), "%L", LANG_SERVER, "MATCHSTATE_KNIFE_ROUND")
		}
		case MATCHSTATE_OVERTIME:
		{
			formatex(szTemp, charsmax(szTemp), "%L", LANG_SERVER, "MATCHSTATE_OVERTIME", g_iOvertimeScore[CT_OVER_SCORE], g_iOvertimeScore[TERO_OVER_SCORE])
		}
	}

	set_member_game(m_GameDesc, szTemp)
}

public native_is_half(iPluginID, iParamNum)
{
	return IsHalf()
}

public native_is_last_round(iPluginID, iParamNum)
{
	return IsLastRound()
}

public native_is_prelast_round(iPluginID, iParamNum)
{
	return IsPreLastRound()
}

public native_can_overtime(iPluginID, iParamNum)
{
	return CanOvertime()
}

public native_is_started(iPluginID, iParamNum)
{
	return g_eBooleans[bIsMixOn]
}

public native_is_warm(iPluginID, iParamNum)
{
	return g_eBooleans[bIsWarm]
}	

public native_get_prefix(iPluginID, iParamNum)
{
	set_string(1, g_ePluginSettings[szPrefix], get_param(2))
}

public native_get_username(iPluginID, iParamNum)
{
	if (iParamNum != 3)
	{
		log_error(AMX_ERR_NATIVE, "%s Invalid param num ! Valid: (PlayerID, Name[], Len)", g_ePluginSettings[szPrefix])
		return NATIVE_ERROR
	}
	new id = get_param(1)

	if(!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "%s Player is not connected (%d)", g_ePluginSettings[szPrefix], id)
		return NATIVE_ERROR
	}

	set_string(2, g_szName[id], get_param(3))

	return 1
}

#if defined POINTS_SYS
public native_search_for_user(iPluginID, iParamNum)
{
	if(!g_bConnected)
	{
		log_error(AMX_ERR_NATIVE, "%s Database connection was not established", g_ePluginSettings[szPrefix])
		return NATIVE_ERROR;
	}

	static szSteamID[MAX_NAME_LENGTH]
	get_string(1, szSteamID, charsmax(szSteamID))

	new Handle:iQuery = SQL_PrepareQuery(g_iSqlConnection, "SELECT * FROM `%s` WHERE `SteamID` = ^"%s^";", g_ePluginSettings[szTable], szSteamID)
			
	if(!SQL_Execute(iQuery))
	{
		SQL_QueryError(iQuery, g_szSqlError, charsmax(g_szSqlError))
		log_to_file("mix_system.log", g_szSqlError)
		SQL_FreeHandle(iQuery)
	}

	new bool:bFoundData = SQL_NumResults( iQuery ) > 0 ? true : false

	if(!bFoundData)
	{
		return NATIVE_ERROR;
	}

	new szQuery[128], iUserPoints, iPoints = get_param(2), bool:bAdd = bool:get_param(3)

	formatex(szQuery, charsmax(szQuery), "SELECT `Points` FROM `%s` WHERE `SteamID` = '%s';", g_ePluginSettings[szTable], szSteamID)

	iQuery = SQL_PrepareQuery(g_iSqlConnection, szQuery);

	if(!SQL_Execute(iQuery))
	{
		SQL_QueryError(iQuery, g_szSqlError, charsmax(g_szSqlError))
		log_to_file("mix_system.log", g_szSqlError);
	}

	if(SQL_NumResults(iQuery) > 0)
	{
		iUserPoints = SQL_ReadResult(iQuery, SQL_FieldNameToNum(iQuery, "Points"))
	}

	if(bAdd)
	{
		iUserPoints += iPoints
	}
	else
	{
		iUserPoints -= iPoints
	}

	formatex(szQuery, charsmax(szQuery), "UPDATE `%s` SET `Points`='%d' WHERE `SteamID`=^"%s^";", g_ePluginSettings[szTable], iUserPoints, szSteamID)

	iQuery = SQL_PrepareQuery(g_iSqlConnection, szQuery)

	if(!SQL_Execute(iQuery))
	{
		SQL_QueryError(iQuery, g_szSqlError, charsmax(g_szSqlError))
		log_to_file("mix_system.log", g_szSqlError)
	}

	SQL_FreeHandle(iQuery)

	return 1
}

public native_user_points(iPluginID, iParamNum)
{
	if(!g_bConnected)
	{
		log_error(AMX_ERR_NATIVE, "%s Database connection was not established", g_ePluginSettings[szPrefix])
		return NATIVE_ERROR;
	}

	if (iParamNum != 1)
	{
		log_error(AMX_ERR_NATIVE, "%s Invalid param num ! Valid: (PlayerID)", g_ePluginSettings[szPrefix])
		return NATIVE_ERROR
	}
	new id = get_param(1)

	if(!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "%s Player is not connected (%d)", g_ePluginSettings[szPrefix], id)
		return NATIVE_ERROR
	}

	return g_iPoints[id]
}

public native_get_points_table(iPluginID, iParamNum)
{
	if(!g_bConnected)
	{
		log_error(AMX_ERR_NATIVE, "%s Database connection was not established", g_ePluginSettings[szPrefix])
		return NATIVE_ERROR
	}

	set_string(1, g_ePluginSettings[szTable], get_param(2))

	return 1
}

#endif

public native_has_points_sys(iPluginID, iParamNum)
{
	#if defined POINTS_SYS
	return true
	#else
	return false
	#endif
}