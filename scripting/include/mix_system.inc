/* Sublime AMXX Editor v4.2 */

#if defined _mix_system_included
    #endinput
#endif
#define _mix_system_included

#pragma reqlib mix_system
#if !defined AMXMODX_NOAUTOLOAD
    #pragma loadlib LIBRARY_NAME
#endif

/**
 * Returns if is half round.
 *
 * @noparam
 * @type            Boolean
 * @return          True if it is, false otherwise.
 */
native Mix_IsHalf()

/**
 * Returns if is last round.
 *
 * @noparam
 * @type            Boolean
 * @return          True if it is, false otherwise.
 */
native Mix_IsLastRound()

/**
 * Returns if is pre last round.
 *
 * @noparam
 * @type            Boolean
 * @return          True if it is, false otherwise.
 */
native Mix_IsPreLastRound()

/**
 * Returns if mix can be overtimed.
 *
 * @noparam
 * @type            Boolean
 * @return          True if it is, false otherwise.
 */
native Mix_CanOvertime()

/**
 * Returns if mix is started.
 *
 * @noparam
 * @type            Boolean
 * @return          True if it is, false otherwise.
 */
native Mix_IsStarted()

/**
 * Returns if warm is started.
 *
 * @noparam
 * @type            Boolean
 * @return          True if it is, false otherwise.
 */
native Mix_IsWarm()

/**
 * Returns a player's points.
 *
 * @param id        Player index

 * @return          Amount of points.
 */
native Mix_UserPoints(id)

/**
 * Returns player's name.
 *
 * @param id        Player index
 * @param name      Buffer to store player's name
 * @param len       Name length
 * 
 * @return          1 if succes, -1 otherwise.
 */
native Mix_GetUserName(id, name[], len)

/**
 * Copy Chat prefix.
 *
 * @param szPrefix  Array to copy the string
 * @param iLen      Array lenght
 * 
 * @type            String
 * @noreturn        
 */
native Mix_GetPrefix(szPrefix[], iLen)

/**
 * Search for player in database using his SteamID.
 *
 * @param szSteamID     Player's steamid
 * @param iPoints       Amount of points to deal with
 * @param bAdd          If true, points will be added to player's balance, otherwise, decreased
 * 
 * @return              1 on succes, -1 if player doesn't exists in database       
 */
native Mix_SearchForUser(szSteamID[], iPoints, bool:bAdd = true)

/**
 * Multiplies player's points before adding into account.
 * 
 * @param id        Player's index.
 * @param iFactor   Multiply factor.
 * 
 * @return          1 on succes, -1 on error.
 * @error           Returns -1 if the player is not connected.
 */
native Mix_MultiplyFactor(id, iFactor)

/**
 * Called when a player is killed during a game.
 *
 * @param id                    Killer index.
 * @param iVictim               Victim index.
 * @param bHeadshot             If the kill was a headshot index.
 * @param szName                Killer's Name.
 * @param szAuthID              Killer's AuthID
 * 
 * @noreturn
 */
forward mix_player_killed(id, iVictim, bHeadshot, szName[], szAuthID[])

/**
 * Called when a game is over.
 *
 * @param id                    Player index.
 * @param iDuration             Game duration.
 * @param iPoints               Player's points.
 * @param iTeamWon              First char for the winner team ( 'C' for CT ; 'T' for Terrorists ).
 * 
 * @noreturn
 */
forward mix_game_over(id, iDuration, iTeamWon, iPoints)

/**
 * Called when a game is starting.
 *
 * @param id                    Player index.
 * @param bFinished             Returns 1 if the loop through players finished.
 * @param szAuthID              Player's AuthID.
 * @param szName                Player's Name.
 * @param iPoints               Player's Points.
 * 
 * @noreturn
 */
forward mix_game_begin_post(id, bFinished, szAuthID[], szName[], iPoints)

/**
 * Called right before a game starts.
 *
 * @noparam
 * 
 * @noreturn
 */
forward mix_game_begin_pre()

/**
 * Called when a game is stopped.
 *
 * @param id                    Player index.
 * @param iDuration             Game duration.
 * @param iPoints               Player's points.
 * 
 * @noreturn
 */
forward mix_game_stopped(id, iDuration, iPoints)

/**
 * Called when a player dropped and never reconnected during a game.
 *
 * @param szAuthID              Player's AuthID.
 * 
 * @noreturn
 */
forward mix_sys_leaver(szAuthID[])

/**
 * Called when the teams' score is shown.
 *
 * @param iCTScore              Team Counter-Terrorist Score.
 * @param iTeroScore            Team Terrorist Score.
 * @param iDuration             Match current duration in seconds
 * 
 * @noreturn
 */
forward mix_game_new_round(iCTScore, iTeroScore, iDuration)

/**
 * Called when system connected to database.
 *
 * @param hTuple              Database Tuple handle.
 * @param iSqlConn            Database Connection handle.
 * 
 * @noreturn
 */
forward mix_database_connected(Handle:hTuple, Handle:iSqlConn)

/**
 * Called when winners get their rewards.
 *
 * @param iPlayer              Winner client index.
 * 
 * @noreturn
 */
forward mix_match_winner(iPlayer)

/**
 * Called when saving player's data.
 *
 * @param iPlayer               Client index.
 * 
 * @noreturn
 */
forward mix_user_save(iPlayer)
