#if defined _dhudmessage_included
	#endinput
#endif

#define _dhudmessage_included

#include <amxmodx>

stock __dhud_color;
stock __dhud_x;
stock __dhud_y;
stock __dhud_effect;
stock __dhud_fxtime;
stock __dhud_holdtime;
stock __dhud_fadeintime;
stock __dhud_fadeouttime;
stock __dhud_reliable;

stock set_dhudmessage( red = 0, green = 160, blue = 0, Float:x = -1.0, Float:y = 0.65, effects = 2, Float:fxtime = 6.0, Float:holdtime = 3.0, Float:fadeintime = 0.1, Float:fadeouttime = 1.5, bool:reliable = true )
{
	#define clamp_byte(%1)	   ( clamp( %1, 0, 255 ) )
	#define pack_color(%1,%2,%3) ( %3 + ( %2 << 8 ) + ( %1 << 16 ) )

	__dhud_color	   = pack_color( clamp_byte( red ), clamp_byte( green ), clamp_byte( blue ) );
	__dhud_x		   = _:x;
	__dhud_y		   = _:y;
	__dhud_effect	  = effects;
	__dhud_fxtime	  = _:fxtime;
	__dhud_holdtime	= _:holdtime;
	__dhud_fadeintime  = _:fadeintime;
	__dhud_fadeouttime = _:fadeouttime;
	__dhud_reliable	= _:reliable;

	return 1;
}

stock show_dhudmessage( index, const message[], any:... )
{
	static buffer[ 512 ], numArguments;
	numArguments = numargs();

	if( numArguments == 2 )
	{
		send_dhudMessage( index, message );
	}
	else if( index || numArguments == 3 )
	{
		vformat( buffer, charsmax( buffer ), message, 3 );
		send_dhudMessage( index, buffer );
	}
	else
	{
		static playersList[ 32 ], numPlayers;
		get_players( playersList, numPlayers, "ch" );

		if( !numPlayers )
		{
			return 0;
		}

		static Array:handleArrayML, i, j;
		handleArrayML = ArrayCreate();

		for( i = 2; i < numArguments; i++ )
		{
			if( getarg( i ) == LANG_PLAYER )
			{
				while( ( buffer[ j ] = getarg( i + 1, j++ ) ) ) {}
				j = 0;

				if( GetLangTransKey( buffer ) != TransKey_Bad )
				{
					ArrayPushCell( handleArrayML, i++ );
				}
			}
		}

		static size;
		size = ArraySize( handleArrayML );

		if( !size )
		{
			vformat( buffer, charsmax( buffer ), message, 3 );
			send_dhudMessage( index, buffer );
		}
		else
		{
			static j;
			
			for( i = 0; i < numPlayers; i++ )
			{
				index = playersList[ i ];

				for( j = 0; j < size; j++ )
				{
					setarg( ArrayGetCell( handleArrayML, j ), 0, index );
				}

				vformat( buffer, charsmax( buffer ), message, 3 );
				send_dhudMessage( index, buffer );
			}
		}

		ArrayDestroy( handleArrayML );
	}

	return 1;
}

stock send_dhudMessage( const index, const message[] )
{
	message_begin( __dhud_reliable ? ( index ? MSG_ONE : MSG_ALL ) : ( index ? MSG_ONE_UNRELIABLE : MSG_BROADCAST ), SVC_DIRECTOR, _, index );
	{
		write_byte( strlen( message ) + 31 );
		write_byte( DRC_CMD_MESSAGE );
		write_byte( __dhud_effect );
		write_long( __dhud_color );
		write_long( __dhud_x );
		write_long( __dhud_y );
		write_long( __dhud_fadeintime );
		write_long( __dhud_fadeouttime );
		write_long( __dhud_holdtime );
		write_long( __dhud_fxtime );
		write_string( message );
	}
	message_end();
}
