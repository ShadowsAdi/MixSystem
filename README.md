### Mix System 5v5 CS 1.6

---

This system includes the following functionalities:

- 100% customizable settings from an external file (from chat/console command names to player weapons during the warm-up round).
- Commands for:
  - Starting/stopping the mix.
  - Warm-up rounds.
  - Starting the knife round.
  - Opening / closing the chat.
  - Password-protecting the server.
  - Removing the server password.
  - Moving all players to spectator mode.
  - Assigning players to CT/T/SPECTATOR teams.
  - Starting/stopping a demo for a specific player.
  - Viewing the player leaderboard.
  - Pausing the round.

- Warm-up rounds can be of two types:
  1. Players only receive money at each spawn to buy their favorite weapons.
  2. Fixed weapons for each team (e.g., AK47 + Deagle for Terrorist players / M4A1 + Deagle for CT players) while restricting the purchase of other weapons.

- The mix can only be started if each team has 5 players, totaling 10 players.
- During the mix, only 5 players are allowed in each team (to prevent disruptions from additional players).
- Automatic demo recording when starting the mix with various options:
  1. Demo starts with the current map name.
  2. Demo starts with a custom name set in another setting.
  3. Demo starts with a name set by an admin using the demo start command.

- Configuration files (`.cfg`) for:
  - Starting the mix.
  - Stopping the mix.
  - Starting overtime.

- Ability to set:
  - The number of rounds required for a team to win the mix/overtime.
  - The score from which overtime rounds begin.
  - The number of rounds played in overtime on both sides.
  - Team player limits during the mix (a maximum of 5 players per team).

- **Fastcup Mode**:
  - Provides a similar experience as Fastcup platform.
  - When the admin starts the mix, the knife round begins automatically.
  - The winning team is announced in the chat and can choose the side to start the match.
  - Includes the rank letter of the player based on his points ( Shown only in his name during a match )

- Includes a dictionary ( lang file ) to modify any system-related messages.
- The scoring system and Fastcup mode are optional and can be activated / deactivated in the source code.

#### Scoring System Features:
- Ability to configure the points players gain/lose during specific events:  
  Legend: `+` = add points, `-` = deduct points
  - Normal kill: `+/-`
  - Headshot kill: `+/-`
  - Normal knife kill: `+/-`
  - Knife headshot kill: `+/-`
  - Kill using an HE grenade: `+/-`
  - Suicide: `-`
  - Bomb plant: `+`
  - Bomb explosion: `+`
  - Bomb defuse: `+`
  - Ace: `+`
  - Semi-ace: `+`
  - Winning team: `+`

---

Additionally, this system comes with some sub-addons that provides:

- If a player disconnects during the mix and doesn't reconnect within 5 minutes (default, adjustable), they receive a 30-minute ban (default, adjustable) and lose 20 points (default, adjustable).

- Player's stats and Match information insertion in a `Database` ( Wins, Loses, Basic stats, Match progress, etc )