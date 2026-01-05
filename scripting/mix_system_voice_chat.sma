/* Sublime AMXX-Editor v4.4 */

#include <amxmodx>
#include <mix_system>

#define PLUGIN  "[MIX System] Voice chat"
#define VERSION "1.0.0"
#define AUTHOR  "Shadows Adi"

new g_pAlltalk

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_pAlltalk = get_cvar_pointer("sv_alltalk")
}

public mix_game_new_round(iCTScore, iTeroScore, iDuration)
{
	if(Mix_IsHalf())
	{
		// https://github.com/rehlds/ReGameDLL_CS/wiki/sv_alltalk#sv_alltalk-1
		set_pcvar_num(g_pAlltalk, 1)
	}
	else
	{
		// https://github.com/rehlds/ReGameDLL_CS/wiki/sv_alltalk#sv_alltalk-3
		set_pcvar_num(g_pAlltalk, 3)
	}
}
