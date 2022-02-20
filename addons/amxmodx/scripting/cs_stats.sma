#include < amxmodx >
#include < csx >

enum {
	INT_STATS_KILLS = 0,
	INT_STATS_DEATHS,
	INT_STATS_HS,
	INT_STATS_TKS,
	INT_STATS_SHOTS,
	INT_STATS_HITS,
	INT_STATS_DAMAGE
};

enum {
	INT_STATS_BOMB_DEFUSIONS = 0,
	INT_STATS_BOMB_DEFUSED,
	INT_STATS_BOMB_PLANTS,
	INT_STATS_BOMB_EXPLOSIONS
};

enum {
	INT_STATS_HIT_GENERIC = 0,
	INT_STATS_HIT_HEAD,
	INT_STATS_HIT_CHEST,
	INT_STATS_HIT_STOMACH,
	INT_STATS_HIT_LEFTARM,
	INT_STATS_HIT_RIGHTARM,
	INT_STATS_HIT_LEFTLEG,
	INT_STATS_HIT_RIGHTLEG
};

new g_iMessageSayText;

public plugin_init( ) 
{
	register_plugin( "CS STATS", "2.0", "Abhinash" );
	
	register_clcmd( "say", "CLIENT_COMMAND_HOOK" );
	register_clcmd( "say_team", "CLIENT_COMMAND_HOOK" );
	g_iMessageSayText = get_user_msgid( "SayText" );
}

public CLIENT_COMMAND_HOOK( INT_PLAYER ) {
	static STRING_ARGUMENT[ 11 ];
	read_argv( 1, STRING_ARGUMENT, charsmax( STRING_ARGUMENT ) );
	
	// TOP
	if( equali( STRING_ARGUMENT, "top", 3 ) || equali( STRING_ARGUMENT, "/top", 4 ) ) {
		new HANDLE_MENU = menu_create( "Top", "FUNC_MENU_HANDLER" );
		new STRING_STATS[ 8 ], STRING_BODY[ 8 ], STRING_NAME[ 32 ], STRING_TEMP[ 128 ], STRING_TEMP_NUM[ 4 ], INT_VARIABLE, STATSNUM = get_statsnum( );
		
		if( STATSNUM < 360 )
			INT_VARIABLE = STATSNUM;
		
		else
			INT_VARIABLE = 360;
		
		for( new INT_VARIABLE2 = 0; INT_VARIABLE2 < INT_VARIABLE; INT_VARIABLE2++ ) {
			get_stats( INT_VARIABLE2, STRING_STATS, STRING_BODY, STRING_NAME, charsmax( STRING_NAME ) );
			
			num_to_str( INT_VARIABLE2 + 1, STRING_TEMP_NUM, charsmax( STRING_TEMP_NUM ) );
			
			static KillString[16], DeathString[16];
		
			AddCommas(STRING_STATS[ INT_STATS_KILLS ], KillString, 15);
			AddCommas(STRING_STATS[ INT_STATS_DEATHS ], DeathString, 15);
			
			format( STRING_TEMP, charsmax( STRING_TEMP ), "\y%s \wRank: \r%i \wKills: \r%s \wDeaths: \r%s", STRING_NAME, INT_VARIABLE2 + 1, \
			KillString, DeathString );
			
			menu_additem( HANDLE_MENU, STRING_TEMP, STRING_TEMP_NUM, 0 );
		}
		
		menu_setprop( HANDLE_MENU, MPROP_EXITNAME, "Exit" );
		menu_setprop( HANDLE_MENU, MPROP_NEXTNAME, "Next" );
		menu_setprop( HANDLE_MENU, MPROP_BACKNAME, "Back" );
		
		menu_display( INT_PLAYER, HANDLE_MENU, 0 );
		
		client_cmd( INT_PLAYER, "spk buttons/button9" );
	}
	
	// STATSME
	if( equali( STRING_ARGUMENT, "statsme" ) || equali( STRING_ARGUMENT, "/statsme" ) ) {
		new INT_RANK_POS, STRING_STATS[ 8 ], STRING_BODY[ 8 ], STRING_TEMP[ 128 ], STRING_STATS2[ 4 ];
		INT_RANK_POS = get_user_stats( INT_PLAYER, STRING_STATS, STRING_BODY );
		get_user_stats2( INT_PLAYER, STRING_STATS2 );
		
		new HANDLE_MENU = menu_create( "Rank", "FUNC_MENU_HANDLER" );
		
		static RankString[16];
		AddCommas(INT_RANK_POS, RankString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wRank: \r%s", RankString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "1", 0 );
		
		static KillString[16];
		AddCommas(STRING_STATS[ INT_STATS_KILLS ], KillString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wKills: \r%s", KillString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "2", 0 );
		
		static DeathString[16];
		AddCommas(STRING_STATS[ INT_STATS_DEATHS ], DeathString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wDeaths: \r%s", DeathString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "3", 0 );
		
		static HeadString[16];
		AddCommas(STRING_STATS[ INT_STATS_HS ], HeadString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wHeadshots: \r%s", HeadString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "4", 0 );
		
		static TeamKillString[16];
		AddCommas(STRING_STATS[ INT_STATS_TKS ], TeamKillString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wTeam kills: \r%s", TeamKillString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "5", 0 );
		
		static ShotString[16];
		AddCommas(STRING_STATS[ INT_STATS_SHOTS ], ShotString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wShots: \r%s", ShotString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "6", 0 );
		
		static HitString[16];
		AddCommas(STRING_STATS[ INT_STATS_HITS ], HitString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wHits: \r%s", HitString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "7", 0 );
		
		static DamageString[16];
		AddCommas(STRING_STATS[ INT_STATS_DAMAGE ], DamageString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wDamage: \r%s", DamageString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "8", 0 );
		
		static DefusionString[16];
		AddCommas(STRING_STATS2[ INT_STATS_BOMB_DEFUSIONS ], DefusionString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wTotal defusions: \r%s", DefusionString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "9", 0 );
		
		static BDString[16];
		AddCommas(STRING_STATS2[ INT_STATS_BOMB_DEFUSED ], BDString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wBomb defused: \r%s", BDString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "10", 0 );
		
		static BPString[16];
		AddCommas(STRING_STATS2[ INT_STATS_BOMB_PLANTS ], BPString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wBomb plants: \r%s", BPString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "11", 0 );
		
		static BEString[16];
		AddCommas(STRING_STATS2[ INT_STATS_BOMB_EXPLOSIONS ], BEString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wBomb explosions: \r%s", BEString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "12", 0 );
		
		static HDString[16];
		AddCommas(STRING_BODY[ INT_STATS_HIT_HEAD ], HDString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wHead hits: \r%s", HDString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "13", 0 );
		
		static CHString[16];
		AddCommas(STRING_BODY[ INT_STATS_HIT_CHEST ], CHString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wChest hits: \r%s", CHString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "14", 0 );
		
		static STString[16];
		AddCommas(STRING_BODY[ INT_STATS_HIT_STOMACH ], STString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wStomach hits: \r%s", STString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "15", 0 );
		
		static LFString[16];
		AddCommas(STRING_BODY[ INT_STATS_HIT_LEFTARM ], LFString, 15);

		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wLeftarm hits: \r%s", LFString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "16", 0 );
		
		static RHString[16];
		AddCommas(STRING_BODY[ INT_STATS_HIT_RIGHTARM ], RHString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wRightarm hits: \r%s", RHString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "17", 0 );
		
		static LHString[16];
		AddCommas(STRING_BODY[ INT_STATS_HIT_LEFTLEG ], LHString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wLeftleg hits: \r%s", LHString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "18", 0 );
		
		static RHDString[16];
		AddCommas(STRING_BODY[ INT_STATS_HIT_RIGHTLEG ], RHDString, 15);
		
		format( STRING_TEMP, charsmax( STRING_TEMP ), "\wRightleg hits: \r%s", RHDString );
		menu_additem( HANDLE_MENU, STRING_TEMP, "19", 0 );
		
		menu_setprop( HANDLE_MENU, MPROP_EXITNAME, "Exit" );
		menu_setprop( HANDLE_MENU, MPROP_NEXTNAME, "Next" );
		menu_setprop( HANDLE_MENU, MPROP_BACKNAME, "Back" );
		
		menu_display( INT_PLAYER, HANDLE_MENU, 0 );
		
		client_cmd( INT_PLAYER, "spk buttons/button9" );
	}
	
	// STATS
	if( equali( STRING_ARGUMENT, "stats" ) || equali( STRING_ARGUMENT, "/stats" ) ) {
		new STRING_NAME[ 32 ], STRING_TEMP_NUM[ 4 ];
		new HANDLE_MENU = menu_create( "Choose the player", "FUNC_MENU_STATS_HANDLER" );
		
		for( new id = 1; id <= 32; id++ ) {
			if( is_user_connected( id ) ) {
				get_user_name( id, STRING_NAME, charsmax( STRING_NAME ) );
				
				num_to_str( id, STRING_TEMP_NUM, charsmax( STRING_TEMP_NUM ) );
				
				menu_additem( HANDLE_MENU, STRING_NAME, STRING_TEMP_NUM, 0 );
			}
		}
		
		menu_setprop( HANDLE_MENU, MPROP_EXITNAME, "Exit" );
		menu_setprop( HANDLE_MENU, MPROP_NEXTNAME, "Next" );
		menu_setprop( HANDLE_MENU, MPROP_BACKNAME, "Back" );
		
		menu_display( INT_PLAYER, HANDLE_MENU, 0 );
		
		client_cmd( INT_PLAYER, "spk buttons/button9" );
	}
	
	// DAMAGE
	if( equali( STRING_ARGUMENT, "damage" ) || equali( STRING_ARGUMENT, "/damage" ) || equali( STRING_ARGUMENT, "/dmg" ) || equali( STRING_ARGUMENT, "dmg" ) ) {
		new HANDLE_MENU = menu_create( "Damage Top", "FUNC_MENU_HANDLER" );
		new STRING_STATS[ 8 ], STRING_BODY[ 8 ], STRING_NAME[ 32 ], STRING_TEMP[ 128 ], STRING_TEMP_NUM[ 4 ], INT_VARIABLE, STATSNUM = get_statsnum( );
		
		if( STATSNUM < 360 )
			INT_VARIABLE = STATSNUM;
		
		else
			INT_VARIABLE = 360;
		
		for( new INT_VARIABLE2 = 0; INT_VARIABLE2 < INT_VARIABLE; INT_VARIABLE2++ ) {
			get_stats( INT_VARIABLE2, STRING_STATS, STRING_BODY, STRING_NAME, charsmax( STRING_NAME ) );
			
			num_to_str( INT_VARIABLE2 + 1, STRING_TEMP_NUM, charsmax( STRING_TEMP_NUM ) );
			
			static DamageString[16];
			AddCommas(STRING_STATS[ INT_STATS_DAMAGE ], DamageString, 15);
			
			format( STRING_TEMP, charsmax( STRING_TEMP ), "\y%s \wRank: \r%i \wDamage: \r%s%", \
			STRING_NAME, INT_VARIABLE2 + 1, DamageString );
			
			menu_additem( HANDLE_MENU, STRING_TEMP, STRING_TEMP_NUM, 0 );
		}
		
		menu_setprop( HANDLE_MENU, MPROP_EXITNAME, "Exit" );
		menu_setprop( HANDLE_MENU, MPROP_NEXTNAME, "Next" );
		menu_setprop( HANDLE_MENU, MPROP_BACKNAME, "Back" );
		
		menu_display( INT_PLAYER, HANDLE_MENU, 0 );
		
		client_cmd( INT_PLAYER, "spk buttons/button9" );
	}
	
	// HEADSHOTS
	if( equali( STRING_ARGUMENT, "headshots" ) || equali( STRING_ARGUMENT, "/headshots" ) || equali( STRING_ARGUMENT, "/hs" ) ) {
		new HANDLE_MENU = menu_create( "Headshots Top", "FUNC_MENU_HANDLER" );
		new STRING_STATS[ 8 ], STRING_BODY[ 8 ], STRING_NAME[ 32 ], STRING_TEMP[ 128 ], STRING_TEMP_NUM[ 4 ], INT_VARIABLE, STATSNUM = get_statsnum( );
		
		if( STATSNUM < 360 )
			INT_VARIABLE = STATSNUM;
		
		else
			INT_VARIABLE = 360;
		
		for( new INT_VARIABLE2 = 0; INT_VARIABLE2 < INT_VARIABLE; INT_VARIABLE2++ ) {
			get_stats( INT_VARIABLE2, STRING_STATS, STRING_BODY, STRING_NAME, charsmax( STRING_NAME ) );
			
			num_to_str( INT_VARIABLE2 + 1, STRING_TEMP_NUM, charsmax( STRING_TEMP_NUM ) );
			
			static HeadString[16];
			AddCommas(STRING_STATS[ INT_STATS_HS ], HeadString, 15);
			
			format( STRING_TEMP, charsmax( STRING_TEMP ), "\y%s \wRank: \r%i \wHeadshots: \r%i", \
			STRING_NAME, INT_VARIABLE2 + 1, HeadString );
			
			menu_additem( HANDLE_MENU, STRING_TEMP, STRING_TEMP_NUM, 0 );
		}
		
		menu_setprop( HANDLE_MENU, MPROP_EXITNAME, "Exit" );
		menu_setprop( HANDLE_MENU, MPROP_NEXTNAME, "Next" );
		menu_setprop( HANDLE_MENU, MPROP_BACKNAME, "Back" );
		
		menu_display( INT_PLAYER, HANDLE_MENU, 0 );
		
		client_cmd( INT_PLAYER, "spk buttons/button9" );
	}
	
	// EFFECT
	if( equali( STRING_ARGUMENT, "effect" ) || equali( STRING_ARGUMENT, "/effect" ) ) {
		new HANDLE_MENU = menu_create( "Effects Top", "FUNC_MENU_HANDLER" );
		new STRING_STATS[ 8 ], STRING_BODY[ 8 ], STRING_NAME[ 32 ], STRING_TEMP[ 128 ], STRING_TEMP_NUM[ 4 ], INT_VARIABLE, STATSNUM = get_statsnum( );
		
		if( STATSNUM < 360 )
			INT_VARIABLE = STATSNUM;
		
		else
			INT_VARIABLE = 360;
		
		for( new INT_VARIABLE2 = 0; INT_VARIABLE2 < INT_VARIABLE; INT_VARIABLE2++ ) {
			get_stats( INT_VARIABLE2, STRING_STATS, STRING_BODY, STRING_NAME, charsmax( STRING_NAME ) );
			
			num_to_str( INT_VARIABLE2 + 1, STRING_TEMP_NUM, charsmax( STRING_TEMP_NUM ) );
			
			format( STRING_TEMP, charsmax( STRING_TEMP ), "\y%s \wRank: \r%i \wEffect: \r%2.f%", STRING_NAME, INT_VARIABLE2 + 1, \
			float( STRING_STATS[ INT_STATS_KILLS ] ) * 1.002 / float( STRING_STATS[ INT_STATS_DEATHS ] ) * 1.002 * 30.346647 );
			
			menu_additem( HANDLE_MENU, STRING_TEMP, STRING_TEMP_NUM, 0 );
		}
		
		menu_setprop( HANDLE_MENU, MPROP_EXITNAME, "Exit" );
		menu_setprop( HANDLE_MENU, MPROP_NEXTNAME, "Next" );
		menu_setprop( HANDLE_MENU, MPROP_BACKNAME, "Back" );
		
		menu_display( INT_PLAYER, HANDLE_MENU, 0 );
		
		client_cmd( INT_PLAYER, "spk buttons/button9" );
	}
}

public FUNC_MENU_HANDLER( INT_PLAYER, INT_MENU, INT_ITEM )
	return PLUGIN_HANDLED;

public FUNC_MENU_STATS_HANDLER( INT_PLAYER, INT_MENU, INT_ITEM ) {
	new STRING_COMMAND[ 6 ], STRING_NAME[ 64 ], INT_ACCESS, INT_CALLBACK, INT_VICTIM;
	menu_item_getinfo( INT_MENU, INT_ITEM, INT_ACCESS, STRING_COMMAND, charsmax( STRING_COMMAND ), STRING_NAME, charsmax( STRING_NAME ), INT_CALLBACK );
	INT_VICTIM = get_user_index( STRING_NAME );
	
	if( is_user_connected( INT_VICTIM ) )
		FUNC_STATS_ME( INT_PLAYER, INT_VICTIM );
	
	else {
		ColorChat( INT_PLAYER, "^x01The player you choosed is disconnected!" );
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_HANDLED;
}

public FUNC_STATS_ME( INT_PLAYER, VICTIM ) {
	new INT_RANK_POS, STRING_STATS[ 8 ], STRING_BODY[ 8 ], STRING_TEMP[ 128 ], STRING_STATS2[ 4 ], STRING_NAME[ 32 ];
	INT_RANK_POS = get_user_stats( VICTIM, STRING_STATS, STRING_BODY );
	get_user_stats2( VICTIM, STRING_STATS2 );
	get_user_name( VICTIM, STRING_NAME, charsmax( STRING_NAME ) );
	
	new HANDLE_MENU = menu_create( "Rank", "FUNC_MENU_HANDLER" );
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wUser: \r%s", STRING_NAME );
	menu_additem( HANDLE_MENU, STRING_TEMP, "1", 0 );
	
	static RankString[16];
	AddCommas(INT_RANK_POS, RankString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wRank: \r%i", RankString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "2", 0 );
	
	static KillString[16];
	AddCommas(STRING_STATS[ INT_STATS_KILLS ], KillString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wKills: \r%i", KillString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "3", 0 );
	
	static DeathString[16];
	AddCommas(STRING_STATS[ INT_STATS_DEATHS ], DeathString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wDeaths: \r%i", DeathString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "4", 0 );
	
	static HeadString[16];
	AddCommas(STRING_STATS[ INT_STATS_HS ], HeadString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wHeadshots: \r%i", HeadString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "5", 0 );
	
	static TeamKillString[16];
	AddCommas(STRING_STATS[ INT_STATS_TKS ], TeamKillString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wTeam kills: \r%i", TeamKillString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "6", 0 );
	
	static ShotString[16];
	AddCommas(STRING_STATS[ INT_STATS_SHOTS ], ShotString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wShots: \r%i", ShotString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "7", 0 );
	
	static HitString[16];
	AddCommas(STRING_STATS[ INT_STATS_HITS ], HitString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wHits: \r%i", HitString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "8", 0 );
	
	static DamageString[16];
	AddCommas(STRING_STATS[ INT_STATS_DAMAGE ], DamageString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wDamage: \r%i", DamageString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "9", 0 );
	
	static DefusionString[16];
	AddCommas(STRING_STATS2[ INT_STATS_BOMB_DEFUSIONS ], DefusionString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wTotal defusions: \r%i", DefusionString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "10", 0 );
	
	static BDString[16];
	AddCommas(STRING_STATS2[ INT_STATS_BOMB_DEFUSED ], BDString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wBomb defused: \r%i", BDString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "11", 0 );
	
	static BPString[16];
	AddCommas(STRING_STATS2[ INT_STATS_BOMB_PLANTS ], BPString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wBomb plants: \r%i", BPString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "12", 0 );
	
	static BEString[16];
	AddCommas(STRING_STATS2[ INT_STATS_BOMB_EXPLOSIONS ], BEString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wBomb explosions: \r%i", BEString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "13", 0 );
	
	static HDString[16];
	AddCommas(STRING_BODY[ INT_STATS_HIT_HEAD ], HDString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wHead hits: \r%i", HDString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "14", 0 );
	
	static CHString[16];
	AddCommas(STRING_BODY[ INT_STATS_HIT_CHEST ], CHString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wChest hits: \r%i", CHString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "15", 0 );
	
	static STString[16];
	AddCommas(STRING_BODY[ INT_STATS_HIT_STOMACH ], STString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wStomach hits: \r%i", STString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "16", 0 );
	
	static LFString[16];
	AddCommas(STRING_BODY[ INT_STATS_HIT_LEFTARM ], LFString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wLeftarm hits: \r%i", LFString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "17", 0 );
	
	static RHString[16];
	AddCommas(STRING_BODY[ INT_STATS_HIT_RIGHTARM ], RHString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wRightarm hits: \r%i", RHString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "18", 0 );
	
	static LHString[16];
	AddCommas(STRING_BODY[ INT_STATS_HIT_LEFTLEG ], LHString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wLeftleg hits: \r%i", LHString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "19", 0 );
	
	static RHDString[16];
	AddCommas(STRING_BODY[ INT_STATS_HIT_RIGHTLEG ], RHDString, 15);
	
	format( STRING_TEMP, charsmax( STRING_TEMP ), "\wRightleg hits: \r%i", RHDString );
	menu_additem( HANDLE_MENU, STRING_TEMP, "20", 0 );
	
	menu_setprop( HANDLE_MENU, MPROP_EXITNAME, "Exit" );
	menu_setprop( HANDLE_MENU, MPROP_NEXTNAME, "Next" );
	menu_setprop( HANDLE_MENU, MPROP_BACKNAME, "Back" );
	
	menu_display( INT_PLAYER, HANDLE_MENU, 0 );
	
	client_cmd( INT_PLAYER, "spk buttons/button9" );
}

ColorChat( iTarget, szMessage[ ], any: ... ) {
	static szBuffer[ 189 ];
	vformat( szBuffer, 188, szMessage, 3 );
	
	if( iTarget ) {
		message_begin( MSG_ONE_UNRELIABLE, g_iMessageSayText, _, iTarget );
		write_byte( iTarget );
		write_string( szBuffer );
		message_end( );
	} else {
		static iPlayers[ 32 ], iNum, i, iPlayer;
		get_players( iPlayers, iNum, "c" );
		
		for( i = 0; i < iNum; i++ ) {
			iPlayer = iPlayers[ i ];
			
			message_begin( MSG_ONE_UNRELIABLE, g_iMessageSayText, _, iPlayer );
			write_byte( iPlayer );
			write_string( szBuffer );
			message_end( );
		}
	}
}

stock AddCommas( iNum , szOutput[] , iLen )
{
	static szTmp[ 15 ] , iOutputPos , iNumPos , iNumLen;
	szTmp[0]='^0',iOutputPos=iNumPos=iNumLen=0;
	if ( iNum < 0 ){
		szOutput[ iOutputPos++ ] = '-';
		iNum = abs( iNum );}
	iNumLen = num_to_str( iNum , szTmp , charsmax( szTmp ) );
	if ( iNumLen <= 3 )iOutputPos += copy( szOutput[ iOutputPos ] , iLen , szTmp );
	else{
		while ( ( iNumPos < iNumLen ) && ( iOutputPos < iLen ) ){
			szOutput[ iOutputPos++ ] = szTmp[ iNumPos++ ];
			if( ( iNumLen - iNumPos ) && !( ( iNumLen - iNumPos ) % 3 ) )szOutput[ iOutputPos++ ] = ',';
		}
		szOutput[ iOutputPos ] = EOS;
	}return iOutputPos;}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
