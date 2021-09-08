#if !defined __NEWSTATS_INC__

#define __NEWSTATS_INC__

#pragma library NewStats

#include amxmodx

/**
* Retrieves the name of the best 15 players.
*
* Returns 0 if it fails. Returns how many players have been selected otherwise.
* If there are not 15 ranked players yet, it might return values like 1, 2, 3 and so on.
* Example of use:
*
*	new totalPlayers = NewStats_GetTop15(...);
*
* And then you can get the rank statistics for each.
*/
native NewStats_GetTop15(_n1[], _n2[], _n3[], _n4[], _n5[], _n6[], _n7[], _n8[], \
	_n9[], _n10[], _n11[], _n12[], _n13[], _n14[], _n15[]);

/**
* Retrieves information of a player by name.
*
* Returns 0 if it fails. If the name of the player does not exists and so on.
* Returns 1 otherwise.
* These values are all strings. You can then convert them to numbers and so on.
* Example of use:
*
*	new Name[64] = "Hattrick";
*	Steam[64], Ip[64], Score[16], Rank[16];
*	new Success = NewStats_GetStats(Name, Steam, Ip, Score, ...);
*
*	if (Success)
*	{
*		server_print("Player %s's score is %s. Or numeric, %d.", Name, Score, str_to_num(Score));
*	}
*/
native NewStats_GetStats(Name[], Steam[], Ip[], Score[], Kills[], \
	Deaths[], headShots[], Time[], timeString[], Seen[], seenString[], \
	kpdRatio[], kmdValue[], Rank[], totalPositions[]);

#endif
