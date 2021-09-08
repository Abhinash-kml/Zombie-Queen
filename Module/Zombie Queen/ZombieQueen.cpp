// Default C++ includes
#include <stdio.h>
#include <string.h>
#include <ctype.h>

// AMXX includes
#include "amxxmodule.h"
#include "ZombieQueen.h"

#if defined __linux__
#define EXTRAOFFSET 5
#define EXTRAOFFSET_WEAPONS 4
#else
#define EXTRAOFFSET 0
#define EXTRAOFFSET_WEAPONS 0
#endif

#define OFFSET_TEAM 114 + EXTRAOFFSET
#define OFFSET_CSMONEY 115 + EXTRAOFFSET
#define OFFSET_ZOOMTYPE 363 + EXTRAOFFSET
#define OFFSET_CSDEATHS 444 + EXTRAOFFSET
#define OFFSET_PAINSHOCK 108 + EXTRAOFFSET 
#define OFFSET_CLIPAMMO EXTRAOFFSET_WEAPONS + 51

#define Mine_Flag (1<<12)
#define Spawn_Flag 0x13A

Vector g_EndPosition;

const int g_ConnectionSounds[] = { 12, 16, 17 };

enum GameMessages 
{
	DeathMsg = 1,
	HLTV
};

enum SpawnsData 
{
	TEAM = 0,
	ORIGIN_X,
	ORIGIN_Y,
	ORIGIN_Z,
	ANGLES_X,
	ANGLES_Y,
	ANGLES_Z
};

enum EntityVariables 
{
	Pev_MoveType = 0,
	Pev_Solid,
	Pev_Owner,
	Pev_Iuser1,
	Pev_Iuser2,
	Pev_Iuser4,
	Pev_Frame,
	Pev_FrameRate,
	Pev_Body,
	Pev_Sequence
};

class CPlayer 
{
public:
	bool modelled;
	float rocket;
	bool monster;
	bool jetpack;
	bool zombie;
	float fuel;
	bool frozen;
} CPlayers[33];

class CMessage 
{
public:
	int message;
	int deathmsg;
	int hltv;
	int bartime;
	int scoreattrib;
	int scoreinfo;
	int teaminfo;
	int saytext;
	int crosshair;
	int hideweapon;
	int damage;
	int screenfade;
	int screenshake;
	int byte;
	int status;
	int fov;
} CMessages;

class CString
{
public:
	int vegon;
	int pegon;
	int pgoldak;
	int vgoldak;
	int pgoldm4;
	int vgoldm4;
	int pgoldxm;
	int vgoldxm;
	int pgolddeagle;
	int vgolddeagle;
	int vknife;
	int pknife;
	int null;
	int jetpack;
	int rocket;
	int mine;
	int infotarget;
	int ctspawn;
	int tspawn;
} CStrings;

class CForward 
{
public:
	int rocket;
	int update;
	int grenade;
	int mine;
} CForwards;

class CSprite 
{
public:
	int flame;
	int fire;
	int trail;
	int smoke;
	int glass;
	int shockwave;
	int explode;
	int lightning;
} CSprites;

class CMisc 
{
public:
	bool prepared;
	bool spawns;
} CMiscs;

void SetJetpack(edict_t* ePlayer)
{
	ePlayer->v.viewmodel = CStrings.vegon;
	ePlayer->v.weaponmodel = CStrings.pegon;
}

void SetKnife(edict_t* ePlayer)
{
	ePlayer->v.viewmodel = CStrings.vknife;
	ePlayer->v.weaponmodel = CStrings.pknife;
}

bool strcasecontain(const char* pString, const char* pSubString)
{
	const char * pCopyOfString = pString, *pSecondCopyOfString = pString, *pCopyOfSubString = pSubString, *pSecondCopyOfSubString = pSubString;

	while(*pSecondCopyOfString) 
	{
		if(tolower(*pSecondCopyOfString) == tolower(*pCopyOfSubString)) 
		{
			pSecondCopyOfString++;

			if(!*++pCopyOfSubString)
				return true;
		}

		else 
		{
			pSecondCopyOfString = ++pCopyOfString;

			pCopyOfSubString = pSecondCopyOfSubString;
		}
	}

	return false;
}

void DropJetpack(int iPlayer, bool bForced)
{
	edict_t* player = INDEXENT(iPlayer);
	if(!FNullEnt(player))
	{
		Vector vecOrigin = player->v.origin;

		MAKE_VECTORS(player->v.v_angle);

		Vector vecForward = gpGlobals->v_forward * 75;

		vecOrigin.x += vecForward.x;
		vecOrigin.y += vecForward.y;

		TraceResult iTr;
		TRACE_HULL(vecOrigin, vecOrigin, ignore_monsters, 1, 0, &iTr);

		if(iTr.fStartSolid || iTr.fAllSolid || !iTr.fInOpen) 
		{
			if (bForced)
			{
				CPlayers[iPlayer].jetpack = false;

				if(MF_IsPlayerAlive(iPlayer))
				{
					CLIENT_COMMAND(player, "weapon_knife\n");

					SetKnife(player);
				}
			}
		}

		else 
		{
			edict_t *eEntity = CREATE_NAMED_ENTITY(CStrings.infotarget);

			if(!FNullEnt(eEntity))
			{
				SET_MODEL(eEntity, STRING(CStrings.pegon));
				SET_SIZE(eEntity, Vector(-16, -16, -16), Vector(16, 16, 16));

				eEntity->v.classname = CStrings.jetpack;
				eEntity->v.movetype = MOVETYPE_TOSS;
				eEntity->v.solid = SOLID_TRIGGER;

				SET_ORIGIN(eEntity, vecOrigin);

				CPlayers[iPlayer].jetpack = false;

				if (MF_IsPlayerAlive(iPlayer))
				{
					CLIENT_COMMAND(player, "weapon_knife\n");

					SetKnife(player);
				}
			}
		}
	}
}

void trim(char *cInput) 
{
	char *cOldInput = cInput, *cStart = cInput;

	while(*cStart == ' ' || *cStart == '\t' || *cStart == '\r' || *cStart == '\n')
		cStart++;

	if(cStart != cInput)
		while((*cInput++ = *cStart++ ) != '\0')
			/* do nothing */;

	cStart = cOldInput;
	cStart += strlen(cStart) - 1;

	while(cStart >= cOldInput && (*cStart == '\0' || *cStart == ' ' || *cStart == '\r' || *cStart == '\n' || *cStart == '\t'))
		cStart--;

	cStart++;
	*cStart = '\0';

	while(*cStart != '\0') 
	{
		if(*cStart == ';') 
		{
			*cStart = '\0';

			break;
		}

		cStart++;
	}
}

static cell AMX_NATIVE_CALL CreateBot(AMX* amx, cell* param)
{
	const char * pName = MF_GetAmxString(amx, param[1], 0, 0);

	edict_t * pEntity = CREATEFAKECLIENT(STRING(ALLOC_STRING(pName)));

	if(FNullEnt(pEntity) || FNullEnt(ENT(pEntity)) || pEntity == NULL || FNullEnt(ENT(ENTINDEX(pEntity))) || ENTINDEX(pEntity) <= 0)
		return 0;

	if(pEntity->pvPrivateData != NULL)
		FREE_PRIVATE(pEntity);

	pEntity->pvPrivateData = NULL;

	pEntity->v.frags = 0;

	CALL_GAME_ENTITY(PLID, "player", VARS(pEntity));

	pEntity->v.flags |= FL_FAKECLIENT;
	pEntity->v.model = CStrings.null;
	pEntity->v.viewmodel = CStrings.null;
	pEntity->v.modelindex = 0;
	pEntity->v.renderfx = kRenderFxNone;
	pEntity->v.rendermode = kRenderTransAlpha;
	pEntity->v.renderamt = 0;

	MESSAGE_BEGIN(MSG_BROADCAST, CMessages.teaminfo);
	WRITE_BYTE(ENTINDEX(pEntity));
	WRITE_STRING("UNASSIGNED");
	MESSAGE_END();

	CPlayers[ENTINDEX(pEntity)].frozen = false;
	CPlayers[ENTINDEX(pEntity)].fuel = 0;
	CPlayers[ENTINDEX(pEntity)].jetpack = false;
	CPlayers[ENTINDEX(pEntity)].modelled = false;
	CPlayers[ENTINDEX(pEntity)].monster = false;
	CPlayers[ENTINDEX(pEntity)].zombie = false;
	CPlayers[ENTINDEX(pEntity)].rocket = 0;

	return ENTINDEX(pEntity);
}

static cell AMX_NATIVE_CALL set_nextthink(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	player->v.nextthink = amx_ctof(param[2]);

	return 1;
}

static cell AMX_NATIVE_CALL kill(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MDLL_ClientKill(player);

	return 1;
}

static cell AMX_NATIVE_CALL get_user_model(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MF_SetAmxString(amx, param[2], INFOKEYVALUE(GETINFOKEYBUFFER(player), "model"), param[3]);

	return 1;
}

static cell AMX_NATIVE_CALL set_user_model(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	
	SETCLIENTKEYVALUE(index, GETINFOKEYBUFFER(player), "model", MF_GetAmxString(amx, param[2], 0, 0));

	CPlayers[index].modelled = true;
	
	return 1;
}

static cell AMX_NATIVE_CALL get_user_jetpack(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];

	return CPlayers[index].jetpack;
}

static cell AMX_NATIVE_CALL range(AMX* amx, cell*param)
{
	CHECK_PLAYER(param[1])
	CHECK_PLAYER(param[2])

	const auto index1 = param[1];
	const auto index2 = param[2];
	const auto player1 = INDEXENT(index1);
	const auto player2 = INDEXENT(index2);

	return (cell) (player1->v.origin - player2->v.origin).Length();
}

static cell AMX_NATIVE_CALL SendDeathMsg(AMX*, cell* param)
{
	const auto attacker = param[1];
	const auto victim = param[2];

	MESSAGE_BEGIN(MSG_BROADCAST, CMessages.deathmsg);
	WRITE_BYTE(attacker);
	WRITE_BYTE(victim);
	WRITE_BYTE(1);
	WRITE_STRING("infection");
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL SendScoreInfo(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	if(player->pvPrivateData != NULL) 
	{
		MESSAGE_BEGIN(MSG_BROADCAST, CMessages.scoreinfo);
		WRITE_BYTE(index);
		WRITE_SHORT((int)player->v.frags);
		WRITE_SHORT(*((int*)player->pvPrivateData + OFFSET_CSDEATHS));
		WRITE_SHORT(0);
		WRITE_SHORT(*((int*)player->pvPrivateData + OFFSET_TEAM));
		MESSAGE_END();
	}

	return 1;
}

static cell AMX_NATIVE_CALL set_team(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto team = param[2];

	if(player->pvPrivateData != NULL) 
	{
		*((int *) player->pvPrivateData + OFFSET_TEAM) = team;

		MESSAGE_BEGIN(MSG_BROADCAST, CMessages.teaminfo);
		WRITE_BYTE(index);
		WRITE_STRING(team == 1 ? "TERRORIST" : "CT");
		MESSAGE_END();

		for(int i = 1; i <= gpGlobals -> maxClients; i++) 
		{
			const auto loop_player = INDEXENT(i);
			if(!FNullEnt(loop_player) && loop_player->v.oldbuttons & IN_SCORE && loop_player->v.button & IN_SCORE)
				MF_ExecuteForward(CForwards.update, static_cast<cell>(i));
		}
	}

	return 1;
}

static cell AMX_NATIVE_CALL get_team(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	if (player->pvPrivateData == NULL)
	{
		return 0;
	}
	else
	{
		return *((int*)player->pvPrivateData + OFFSET_TEAM);
	}
}

static cell AMX_NATIVE_CALL set_frags(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto frags = param[2];

	player->v.frags = float(frags);

	return 1;
}

static cell AMX_NATIVE_CALL set_speed(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto Speed = amx_ctof(param[2]);

	SETCLIENTMAXSPEED(player, Speed);

	player->v.maxspeed = Speed;

	return 1;
}

static cell AMX_NATIVE_CALL set_gravity(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto gravity = param[2];

	player->v.gravity = amx_ctof(gravity);

	return 1;
}

static cell AMX_NATIVE_CALL get_origin(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	cell * pOrigin = MF_GetAmxAddr(amx, param[2]);

	Vector Origin = player->v.origin;

	pOrigin[0] = amx_ftoc(Origin.x);
	pOrigin[1] = amx_ftoc(Origin.y);
	pOrigin[2] = amx_ftoc(Origin.z);

	return 1;
}

static cell AMX_NATIVE_CALL set_origin(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	cell* pOrigin = MF_GetAmxAddr(amx, param[2]);

	player->v.origin = Vector(amx_ctof(pOrigin[0]), amx_ctof(pOrigin[1]), amx_ctof(pOrigin[2]));

	return 1;
}

static cell AMX_NATIVE_CALL set_velocity(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	cell* pVelocity = MF_GetAmxAddr(amx, param[2]);

	player->v.velocity = Vector(amx_ctof(pVelocity[0]), amx_ctof(pVelocity[1]), amx_ctof(pVelocity[2]));

	return 1;
}

static cell AMX_NATIVE_CALL SetLight(AMX* amx, cell* param)
{
	const auto light = param[1];
	LIGHT_STYLE(0, MF_GetAmxString(amx, light, 0, 0));

	return 1;
}

static cell AMX_NATIVE_CALL get_mins(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	cell* pMins = MF_GetAmxAddr(amx, param[2]);

	Vector Mins = player->v.mins;

	pMins[0] = amx_ftoc(Mins.x);
	pMins[1] = amx_ftoc(Mins.y);
	pMins[2] = amx_ftoc(Mins.z);
	

	return 1;
}

static cell AMX_NATIVE_CALL get_velocity(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	cell* pVelocity = MF_GetAmxAddr(amx, param[2]);

	Vector Velocity = player->v.velocity;

	pVelocity[0] = amx_ftoc(Velocity.x);
	pVelocity[1] = amx_ftoc(Velocity.y);
	pVelocity[2] = amx_ftoc(Velocity.z);

	return 1;
}

static cell AMX_NATIVE_CALL set_monster(AMX* amx, cell* param)
{
	if (param[1] > 0 && param[1] <= gpGlobals->maxClients)
		CPlayers[param[1]].monster = param[2] ? true : false;

	return 1;
}

static cell AMX_NATIVE_CALL reset_money(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	if(player->pvPrivateData != NULL)
		*((int *) player->pvPrivateData + OFFSET_CSMONEY) = 0;

	return 1;
}

static cell AMX_NATIVE_CALL create_mine(AMX* amx, cell*)
{
	edict_t * pEntity = CREATE_NAMED_ENTITY(CStrings.infotarget);

	if(FNullEnt(pEntity))
		return 0;

	SET_MODEL(pEntity, "models/zombie_plague/lasermine.mdl");
	SET_SIZE(pEntity, Vector(-4, -4, -4), Vector(4, 4, 4));

	pEntity->v.classname = CStrings.mine;

	return ENTINDEX(pEntity);
}

static cell AMX_NATIVE_CALL set_deaths(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	if(player->pvPrivateData != NULL)
		*((int *) player-> pvPrivateData + OFFSET_CSDEATHS) = param[2];

	return 1;
}

static cell AMX_NATIVE_CALL get_deaths(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	return (player->pvPrivateData == NULL) ? 0 : *((int *)player->pvPrivateData + OFFSET_CSDEATHS);
}

static cell AMX_NATIVE_CALL get_frags(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	return (cell) FNullEnt(player) ? 0 : player->v.frags;
}

static cell AMX_NATIVE_CALL FixScoreAttrib(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MESSAGE_BEGIN(MSG_BROADCAST, CMessages.scoreattrib);
	WRITE_BYTE(index);
	WRITE_BYTE(0);
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL set_user_jetpack(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	if(param[2])
	{
		CPlayers[index].jetpack = true;

		CLIENT_COMMAND(player, "weapon_knife\n");

		SetJetpack(player);
	}

	else
		CPlayers[index].jetpack = false;

	return 1;
}

static cell AMX_NATIVE_CALL set_user_fuel(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto fuel = param[2];

	CPlayers[index].fuel = amx_ctof(fuel);

	return 1;
}

static cell AMX_NATIVE_CALL set_user_rocket_time(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto id = param[1];
	const auto rocket = param[2];

	CPlayers[id].rocket = amx_ctof(rocket);

	return 1;
}

static cell AMX_NATIVE_CALL user_drop_jetpack(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	if(param[2])
		DropJetpack(index, true);

	else
		DropJetpack(index, false);

	return 1;
}

static cell AMX_NATIVE_CALL set_zombie(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	CPlayers[index].zombie = param[2] ? true : false;

	return 1;
}

static cell AMX_NATIVE_CALL give_weapon(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	edict_t* pEntity = CREATE_NAMED_ENTITY(ALLOC_STRING(MF_GetAmxString(amx, param[2], 0, 0)));

	if(FNullEnt(pEntity))
		return 0;

	pEntity->v.origin = player->v.origin;
	pEntity->v.spawnflags |= (1 << 30);

	MDLL_Spawn(pEntity);

	int Solid = pEntity->v.solid;

	MDLL_Touch(pEntity, ENT(player));

	if(Solid == pEntity->v.solid)
		REMOVE_ENTITY(pEntity);

	return 1;
}

static cell AMX_NATIVE_CALL get_armor(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	return (cell) FNullEnt(player) ? 0 : player->v.armorvalue;
}

static cell AMX_NATIVE_CALL reset_armor(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	player->v.armorvalue = 0;

	return 1;
}

static cell AMX_NATIVE_CALL set_weapon_ammo(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto ammo = param[2];

	if (player->pvPrivateData != NULL)
		*((int *) player->pvPrivateData + OFFSET_CLIPAMMO) = ammo;

	return 1;
}

static cell AMX_NATIVE_CALL SetFOV(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto amount = param[2];

	if(gpGlobals->time > 4)
	{
		MESSAGE_BEGIN(MSG_ONE, CMessages.fov, 0, ENT(player));
		WRITE_BYTE(amount);
		MESSAGE_END();
	}
	return 1;
}

static cell AMX_NATIVE_CALL set_health(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto amount = param[2];

	player->v.health = float(amount);

	return 1;
}

static cell AMX_NATIVE_CALL set_armor(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto amount = param[2];

	player->v.armorvalue = float(amount);

	return 1;
}

static cell AMX_NATIVE_CALL get_health(AMX* amx, cell* param) 
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	return (cell) FNullEnt(player) ? 0 : player->v.health;
}

static cell AMX_NATIVE_CALL SendNightVision(AMX* amx, cell* param) 
{
	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto red = param[2];
	const auto green = param[3];
	const auto blue = param[4];

	if(gpGlobals->time > 4) 
	{
		MESSAGE_BEGIN(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, 0, ENT(player));
		WRITE_BYTE(TE_DLIGHT);
		WRITE_COORD(player->v.origin.x);
		WRITE_COORD(player->v.origin.y);
		WRITE_COORD(player->v.origin.z);
		WRITE_BYTE(90);
		WRITE_BYTE(red);
		WRITE_BYTE(green);
		WRITE_BYTE(blue);
		WRITE_BYTE(2);
		WRITE_BYTE(0);
		MESSAGE_END();
	}

	return 1;
}

static cell AMX_NATIVE_CALL SendFlashlight(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	//const auto index = param[1];
	//const auto player = INDEXENT(index);

	cell* pOrigin = MF_GetAmxAddr(amx, param[5]);
	Vector Origin = Vector(amx_ctof(pOrigin[0]), amx_ctof(pOrigin[1]), amx_ctof(pOrigin[2]));

	const auto size = param[1];
	const auto red = param[2];
	const auto green = param[3];
	const auto blue = param[4];


	if (gpGlobals->time > 4)
	{
		g_engfuncs.pfnMessageBegin(MSG_PVS, SVC_TEMPENTITY, g_EndPosition, 0);
		WRITE_BYTE(TE_DLIGHT);
		WRITE_COORD(Origin.x);
		WRITE_COORD(Origin.y);
		WRITE_COORD(Origin.z);
		WRITE_BYTE(size);
		WRITE_BYTE(red);
		WRITE_BYTE(green);
		WRITE_BYTE(blue);
		WRITE_BYTE(3);
		WRITE_BYTE(0);
		MESSAGE_END();
	}

	return 1;
}

static cell AMX_NATIVE_CALL SendGrenadeLight(AMX* amx, cell* param)
{
	//CHECK_PLAYER(param[1])

	//const auto index = param[1];
	//const auto player = INDEXENT(index);

	const auto red = param[1];
	const auto green = param[2];
	const auto blue = param[3];
	const auto size = param[4];

	cell* pOrigin = MF_GetAmxAddr(amx, param[5]);
	Vector Origin = Vector(amx_ctof(pOrigin[0]), amx_ctof(pOrigin[1]), amx_ctof(pOrigin[2]));


	if (gpGlobals->time > 4)
	{
		g_engfuncs.pfnMessageBegin(MSG_BROADCAST, SVC_TEMPENTITY, 0, 0);
		WRITE_BYTE(TE_DLIGHT);
		WRITE_COORD(Origin.x);
		WRITE_COORD(Origin.y);
		WRITE_COORD(Origin.z);
		WRITE_BYTE(size);
		WRITE_BYTE(red);
		WRITE_BYTE(green);
		WRITE_BYTE(blue);
		WRITE_BYTE(8);
		WRITE_BYTE(60);
		MESSAGE_END();
	}

	return 1;
}

static cell AMX_NATIVE_CALL SendGrenadeBeamCylinder(AMX* amx, cell* param)
{
	//CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	const auto red = param[2];
	const auto green = param[3];
	const auto blue = param[4];
	const auto brightness = param[5];

	if (gpGlobals->time > 4)
	{
		MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
		WRITE_BYTE(TE_BEAMCYLINDER);
		WRITE_COORD(player->v.origin.x);
		WRITE_COORD(player->v.origin.y);
		WRITE_COORD(player->v.origin.z);
		WRITE_COORD(player->v.origin.x);
		WRITE_COORD(player->v.origin.y);
		WRITE_COORD(player->v.origin.z + (float) 475);
		WRITE_SHORT(CSprites.shockwave);
		WRITE_BYTE(0);
		WRITE_BYTE(0);
		WRITE_BYTE(4);
		WRITE_BYTE(60);
		WRITE_BYTE(0);
		WRITE_BYTE(red);
		WRITE_BYTE(green);
		WRITE_BYTE(blue);
		WRITE_BYTE(brightness);
		WRITE_BYTE(0);
		MESSAGE_END();
	}

	return 1;
}

static cell AMX_NATIVE_CALL strip_user_weapons(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	edict_t * pEntity = CREATE_NAMED_ENTITY(MAKE_STRING("player_weaponstrip"));

	if(FNullEnt(pEntity))
		return 0;

	MDLL_Spawn(pEntity);
	MDLL_Use(pEntity, ENT(player));

	REMOVE_ENTITY(pEntity);
	

	return 1;
}

static cell AMX_NATIVE_CALL get_ent_flags(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	return FNullEnt(player) ? 0 : player->v.flags;
}

static cell AMX_NATIVE_CALL set_ent_flags(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	player->v.flags = param[2];

	return 1;
}

static cell AMX_NATIVE_CALL set_glow(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	
	player->v.rendermode = kRenderNormal;
	player->v.renderfx = kRenderFxGlowShell;
	player->v.renderamt = float(param[5]);
	player->v.rendercolor = Vector(float(param[2]), float(param[3]), float(param[4]));

	return 1;
}

static cell AMX_NATIVE_CALL remove_glow(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])
	
	const auto index = param[1];
	const auto player = INDEXENT(index);

	player->v.rendermode = kRenderNormal;
	player->v.renderfx = kRenderFxNone;
	player->v.renderamt = 0;

	return 1;
}

static cell AMX_NATIVE_CALL set_viewmodel(AMX* amx, cell* param) 
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto model = param[2];

	player->v.viewmodel = model;

	return 1;
}

static cell AMX_NATIVE_CALL set_weaponmodel(AMX* amx, cell* param) 
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto model = param[2];

	player->v.weaponmodel = model;

	return 1;
}

static cell AMX_NATIVE_CALL set_weaponmodel_null(AMX* amx, cell* param) 
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	player->v.weaponmodel = CStrings.null;

	return 1;
}

static cell AMX_NATIVE_CALL is_hull_vacant(AMX* amx, cell* param) 
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	Vector Origin = player->v.origin;

	TraceResult Tr;
	TRACE_HULL(Origin, Origin, 0, player->v.flags & FL_DUCKING ? 3 : 1, player, &Tr);

	if(!Tr.fStartSolid || !Tr.fAllSolid)
		return 1;

	return 0;
}

static cell AMX_NATIVE_CALL is_origin_vacant(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[2])

	const auto index = param[2];
	const auto player = INDEXENT(index);

	cell * pOrigin = MF_GetAmxAddr(amx, param[1]);

	Vector Origin = Vector(amx_ctof(pOrigin[0]), amx_ctof(pOrigin[1]), amx_ctof(pOrigin[2]));

	TraceResult Tr;
	TRACE_HULL(Origin, Origin, 0, player->v.flags & FL_DUCKING ? 3 : 1, player, &Tr);

	if(!Tr.fStartSolid || !Tr.fAllSolid)
		return 1;

	return 0;
}

static cell AMX_NATIVE_CALL SendGrenadeBeamFollow(AMX* amx, cell* param)
{
	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto red = param[2];
	const auto green = param[3];
	const auto blue = param[4];

	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
	WRITE_BYTE(TE_BEAMFOLLOW);
	WRITE_SHORT(index);
	WRITE_SHORT(CSprites.trail);
	WRITE_BYTE(10);
	WRITE_BYTE(10);
	WRITE_BYTE(param[2]);
	WRITE_BYTE(param[3]);
	WRITE_BYTE(param[4]);
	WRITE_BYTE(255);
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL send_beam_cylinder(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
	WRITE_BYTE(TE_BEAMCYLINDER);
	WRITE_COORD(player->v.origin.x);
	WRITE_COORD(player->v.origin.y);
	WRITE_COORD(player->v.origin.z);
	WRITE_COORD(player->v.origin.x);
	WRITE_COORD(player->v.origin.y);
	WRITE_COORD(player->v.origin.z + (float) 475);
	WRITE_SHORT(CSprites.shockwave);
	WRITE_BYTE(0);
	WRITE_BYTE(0);
	WRITE_BYTE(4);
	WRITE_BYTE(60);
	WRITE_BYTE(0);
	WRITE_BYTE(param[2]);
	WRITE_BYTE(param[3]);
	WRITE_BYTE(param[4]);
	WRITE_BYTE(param[5]);
	WRITE_BYTE(0);
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL send_explosion(AMX* amx, cell* param) 
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
	WRITE_BYTE(TE_EXPLOSION);
	WRITE_COORD(player->v.origin.x + RANDOM_LONG(-4, 4));
	WRITE_COORD(player->v.origin.y + RANDOM_LONG(-4, 4));
	WRITE_COORD(player->v.origin.z + RANDOM_LONG(-4, 4));
	WRITE_SHORT(CSprites.explode);
	WRITE_BYTE(RANDOM_LONG(25, 30));
	WRITE_BYTE(18);
	WRITE_BYTE(0);
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL remove_entity(AMX* amx, cell* param)
{
	if(!FNullEnt(INDEXENT(param[1])))
		REMOVE_ENTITY(INDEXENT(param[1]));

	return 1;
}

static cell AMX_NATIVE_CALL sound(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	EMITSOUND(player, param[2], MF_GetAmxString(amx, param[3], 0, 0), VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return 1;
}

static cell AMX_NATIVE_CALL SendDamage(AMX* amx, cell* param)
{
	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto damage_type = param[2];

	MESSAGE_BEGIN(MSG_ONE_UNRELIABLE, CMessages.damage, 0, ENT(index));
	WRITE_BYTE(0);
	WRITE_BYTE(0);
	WRITE_LONG(damage_type);
	WRITE_COORD(0);
	WRITE_COORD(0);
	WRITE_COORD(0);
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL SendSmoke(AMX* amx, cell* param) 
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
	WRITE_BYTE(TE_SMOKE);
	WRITE_COORD(player->v.origin.x);
	WRITE_COORD(player->v.origin.y);
	WRITE_COORD(player->v.origin.z - 50);
	WRITE_SHORT(CSprites.smoke );
	WRITE_BYTE(RANDOM_LONG(15, 30));
	WRITE_BYTE(RANDOM_LONG(10, 30));
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL SendFlame(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
	WRITE_BYTE(TE_SPRITE);
	WRITE_COORD(player->v.origin.x + RANDOM_LONG(-5, 5));
	WRITE_COORD(player->v.origin.y + RANDOM_LONG(-5, 5));
	WRITE_COORD(player->v.origin.z + RANDOM_LONG(-10, 10));
	WRITE_SHORT(CSprites.flame);
	WRITE_BYTE(RANDOM_LONG(5, 12));
	WRITE_BYTE(RANDOM_LONG(150, 245));
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL SendImplosion(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
	WRITE_BYTE(TE_IMPLOSION );
	WRITE_COORD(player->v.origin.x);
	WRITE_COORD(player->v.origin.y);
	WRITE_COORD(player->v.origin.z);
	WRITE_BYTE(150);
	WRITE_BYTE(32);
	WRITE_BYTE(3);
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL SendParticleBurst(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
	WRITE_BYTE(TE_PARTICLEBURST);
	WRITE_COORD(player->v.origin.x);
	WRITE_COORD(player->v.origin.y);
	WRITE_COORD(player->v.origin.z);
	WRITE_SHORT(50);
	WRITE_BYTE(70);
	WRITE_BYTE(3);
	MESSAGE_END();

	return 1;
}


static cell AMX_NATIVE_CALL send_particle_burst(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
	WRITE_BYTE(TE_PARTICLEBURST);
	WRITE_COORD(player->v.origin.x);
	WRITE_COORD(player->v.origin.y);
	WRITE_COORD(player->v.origin.z);
	WRITE_SHORT(50);
	WRITE_BYTE(70);
	WRITE_BYTE(3);
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL SendLavaSplash(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
	WRITE_BYTE(TE_LAVASPLASH);
	WRITE_COORD(player->v.origin.x);
	WRITE_COORD(player->v.origin.y);
	WRITE_COORD(player->v.origin.z - 26);
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL SendInfectionLight(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
	WRITE_BYTE(TE_DLIGHT);
	WRITE_COORD(player->v.origin.x);
	WRITE_COORD(player->v.origin.y);
	WRITE_COORD(player->v.origin.z);
	WRITE_BYTE(20);
	WRITE_BYTE(240);
	WRITE_BYTE(0);
	WRITE_BYTE(0);
	WRITE_BYTE(2);
	WRITE_BYTE(0);
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL SendAura(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto red = param[2];
	const auto green = param[3];
	const auto blue = param[4];

	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
	WRITE_BYTE(TE_DLIGHT);
	WRITE_COORD(player->v.origin.x);
	WRITE_COORD(player->v.origin.y);
	WRITE_COORD(player->v.origin.z);
	WRITE_BYTE(20);
	WRITE_BYTE(red);
	WRITE_BYTE(green);
	WRITE_BYTE(blue);
	WRITE_BYTE(8);
	WRITE_BYTE(60);
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL SendTeleport(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
	WRITE_BYTE(TE_TELEPORT);
	WRITE_COORD(player->v.origin.x);
	WRITE_COORD(player->v.origin.y);
	WRITE_COORD(player->v.origin.z);
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL SendGlassBreak(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
	WRITE_BYTE(TE_BREAKMODEL);
	WRITE_COORD(player->v.origin.x);
	WRITE_COORD(player->v.origin.y);
	WRITE_COORD(player->v.origin.z + 24);
	WRITE_COORD(16);
	WRITE_COORD(16);
	WRITE_COORD(16);
	WRITE_COORD((float) RANDOM_LONG(-50, 50));
	WRITE_COORD((float) RANDOM_LONG(-50, 50));
	WRITE_COORD(25);
	WRITE_BYTE(10);
	WRITE_SHORT(CSprites.glass);
	WRITE_BYTE(10);
	WRITE_BYTE(25);
	WRITE_BYTE(1);
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL send_screen_fade(AMX* amx, cell* param) 
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);;

	if(gpGlobals->time > 4) 
	{
		MESSAGE_BEGIN(MSG_ONE_UNRELIABLE, CMessages.screenfade, 0, ENT(player));
        WRITE_SHORT(4096);
        WRITE_SHORT(2048);
        WRITE_SHORT(0);
        WRITE_BYTE(param[2]);
        WRITE_BYTE(param[3]);
        WRITE_BYTE(param[4]);
        WRITE_BYTE(param[5]);
		MESSAGE_END();
	}

	return 1;
}

static cell AMX_NATIVE_CALL SendScreenShake(AMX* amx, cell* param) 
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	if( gpGlobals->time > 4) 
	{
		MESSAGE_BEGIN(MSG_ONE_UNRELIABLE, CMessages.screenshake, 0, ENT(player));
		WRITE_SHORT(param[2]);
		WRITE_SHORT(param[3]);
		WRITE_SHORT(param[4]);
		MESSAGE_END();
	}

	return 1;
}

static cell AMX_NATIVE_CALL HideWeapon(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MESSAGE_BEGIN(MSG_ONE_UNRELIABLE, CMessages.hideweapon, 0, ENT(player));
	WRITE_BYTE(param[2]);
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL HideCrosshair(AMX* amx, cell* param) 
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	MESSAGE_BEGIN(MSG_ONE_UNRELIABLE, CMessages.crosshair, 0, ENT(player));
	WRITE_BYTE(0);
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL get_button(AMX* amx, cell* param)
{
	const auto index = param[1];
	const auto player = INDEXENT(index);

	return FNullEnt(player) ? 0 : player->v.button;
}

static cell AMX_NATIVE_CALL set_take_damage(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto damage = param[2];

	player->v.takedamage = float(damage);

	return 1;
}

static cell AMX_NATIVE_CALL set_frozen(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	CPlayers[index].frozen = param[2] ? true : false;

	return 1;
}

static cell AMX_NATIVE_CALL send_bar_time(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	if (gpGlobals->time > 4)
	{
		MESSAGE_BEGIN(MSG_ONE_UNRELIABLE, CMessages.bartime, 0, ENT(player));
		WRITE_BYTE(1);
		WRITE_BYTE(0);
		MESSAGE_END();
	};

	return 1;
}

static cell AMX_NATIVE_CALL get_target_and_attack(AMX* amx, cell* param)
{
	if(!CMiscs.prepared) return 0;
	edict_t * pClient = MF_GetPlayerEdict(param[1]);
	Vector Source = pClient -> v.origin + pClient -> v.view_ofs;
	Vector Forward;
	ANGLEVECTORS(pClient -> v.v_angle, Forward, 0, 0);
	Vector Destination = Source + Forward * 600;
	TraceResult Result;
	TRACE_LINE(Source, Destination, 0, pClient, &Result);
	if(!Result.pHit || FNullEnt(Result.pHit) || !MF_IsPlayerAlive(ENTINDEX(Result.pHit)) || CPlayers[ENTINDEX(Result.pHit)].zombie) return 0;
	MAKE_VECTORS(pClient->v.v_angle);
	pClient->v.velocity = gpGlobals->v_forward * 1400; return 1;
}

static cell AMX_NATIVE_CALL set_team_offset(AMX* amx, cell* param) 
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto offset = param[2];

	if(player->pvPrivateData != NULL)
		*((int *) player->pvPrivateData + OFFSET_TEAM) = offset;

	return 1;
}

static cell AMX_NATIVE_CALL get_oldbuttons(AMX* amx, cell* param) 
{
	const auto index = param[1];
	const auto player = INDEXENT(index);

	return FNullEnt(player) ? 0 : player->v.oldbuttons;
}

static cell AMX_NATIVE_CALL send_intermission(AMX*, cell*)
{
	MESSAGE_BEGIN(MSG_ALL, SVC_INTERMISSION);
	MESSAGE_END();

	return 1;
}

static cell AMX_NATIVE_CALL strip_name(AMX* amx, cell* param)
{
	char Line[33];
	snprintf(Line, 32, "%s", MF_GetAmxString(amx, param[1], 0, 0));

	for (size_t i = 0; i < strlen(Line); i++)
		if (Line[i] == '#' || Line[i] == '<' || Line[i] == '>' || Line[i] == '\'' || Line[i] == '"' || Line[i] == '&' || Line[i] == '$' || Line[i] == '`' || Line[i] == '~' || Line[i] == '/')
			Line[i] = '*';

	MF_SetAmxString(amx, param[1], Line, param[2]);

	return 1;
}

static cell AMX_NATIVE_CALL rem(AMX* amx, cell* param)
{
	edict_t * pEntity = NULL;

	while(!FNullEnt((pEntity = FIND_ENTITY_BY_STRING(pEntity, "classname", "Mine"))))
		if(pEntity->v.iuser2 == param[1])
			REMOVE_ENTITY(pEntity);

	return 1;
}

static cell AMX_NATIVE_CALL can(AMX* amx, cell* param)
{
	edict_t * pEntity = NULL;
	const auto index = param[1];
	const auto player = INDEXENT(index);

	while(!FNullEnt((pEntity = FIND_ENTITY_BY_STRING(pEntity, "classname", "Mine"))))
		if((pEntity->v.iuser2 == param[1]) && !FNullEnt(player) && ((player->v.origin - pEntity-> v.origin).Length() < 55))
			return 1;

	return 0;
}

static cell AMX_NATIVE_CALL ent(AMX * amx, cell * param)
{
	edict_t * pEntity = NULL;
	const auto index = param[1];
	const auto player = INDEXENT(index);

	int Count = 0;

	cell * pEntities = MF_GetAmxAddr(amx, param[2]);

	while(!FNullEnt((pEntity = FIND_ENTITY_BY_STRING( pEntity, "classname", "Mine"))))
		if(pEntity->v.iuser2 == param[1] && !FNullEnt(player) && (player-> v.origin - pEntity -> v.origin).Length() < 55)
			pEntities[Count++] = ENTINDEX(pEntity);

	return Count;
}

static cell AMX_NATIVE_CALL set_jetpack(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	SetJetpack(player);

	return 1;
}

static cell AMX_NATIVE_CALL set_goldenak47(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	player->v.viewmodel = CStrings.vgoldak;
	player->v.weaponmodel = CStrings.pgoldak;
	
	return 1;
}

static cell AMX_NATIVE_CALL set_goldenm4a1(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	player->v.viewmodel = CStrings.vgoldm4;
	player->v.weaponmodel = CStrings.pgoldm4;

	return 1;
}

static cell AMX_NATIVE_CALL set_goldenxm1014(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	player->v.viewmodel = CStrings.vgoldxm;
	player->v.weaponmodel = CStrings.pgoldxm;
	

	return 1;
}

static cell AMX_NATIVE_CALL set_goldendeagle(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	player->v.viewmodel = CStrings.vgolddeagle;
	player->v.weaponmodel = CStrings.pgolddeagle;

	return 1;
}

static cell AMX_NATIVE_CALL Beam(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])
	CHECK_PLAYER(param[2])

	const auto index = param[1];
	const auto index2 = param[2];
	const auto player = INDEXENT(index);
	const auto player2 = INDEXENT(index2);

	if(gpGlobals->time > 4)
	{
		MESSAGE_BEGIN(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, NULL, ENT(player));
		WRITE_BYTE(1);
		WRITE_SHORT(index);
		WRITE_COORD(player2->v.origin.x);
		WRITE_COORD(player2->v.origin.y);
		WRITE_COORD(player2->v.origin.z);
		WRITE_SHORT(CSprites.trail);
		WRITE_BYTE(1);
		WRITE_BYTE(1);
		WRITE_BYTE(2);
		WRITE_BYTE(8);
		WRITE_BYTE(0);
		WRITE_BYTE(param[3]);
		WRITE_BYTE(param[4]);
		WRITE_BYTE(param[5]);
		WRITE_BYTE(255);
		WRITE_BYTE(0);
		MESSAGE_END();
	}

	return 1;
}

static cell AMX_NATIVE_CALL SendSkillEffect(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	cell* pOrigin = MF_GetAmxAddr(amx, param[2]);
	Vector Origin = Vector(amx_ctof(pOrigin[0]), amx_ctof(pOrigin[1]), amx_ctof(pOrigin[2]));

	const auto index = param[1];
	const auto player = INDEXENT(index);
	const auto red = param[3];
	const auto green = param[4];
	const auto blue = param[5];

	if (gpGlobals->time > 4)
	{
		MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
		WRITE_BYTE(TE_BEAMPOINTS);
		WRITE_COORD(player->v.origin.x);
		WRITE_COORD(player->v.origin.y);
		WRITE_COORD(player->v.origin.z + 16);
		WRITE_COORD(Origin.x);
		WRITE_COORD(Origin.y);
		WRITE_COORD(Origin.z + 16);
		WRITE_SHORT(CSprites.lightning);
		WRITE_BYTE(0);
		WRITE_BYTE(30);
		WRITE_BYTE(10);
		WRITE_BYTE(50);
		WRITE_BYTE(20);
		WRITE_BYTE(red);
		WRITE_BYTE(green);
		WRITE_BYTE(blue);
		WRITE_BYTE(255);
		WRITE_BYTE(50);
		MESSAGE_END();
	}

	return 1;
}

static cell AMX_NATIVE_CALL SendLightningTracers(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	if (gpGlobals->time > 4)
	{
		MESSAGE_BEGIN(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, NULL, ENT(player));
		WRITE_BYTE(1);
		WRITE_SHORT(param[1] | 0x1000);
		WRITE_COORD(g_EndPosition.x);
		WRITE_COORD(g_EndPosition.y);
		WRITE_COORD(g_EndPosition.z);
		WRITE_SHORT(CSprites.lightning);
		WRITE_BYTE(0);
		WRITE_BYTE(0);
		WRITE_BYTE(1);
		WRITE_BYTE(5);
		WRITE_BYTE(0);
		WRITE_BYTE(255);
		WRITE_BYTE(160);
		WRITE_BYTE(100);
		WRITE_BYTE(128);
		WRITE_BYTE(0);
		MESSAGE_END();
	}

	return 1;
}

static cell AMX_NATIVE_CALL SendSniperTracers(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	if (gpGlobals->time > 4)
	{
		MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY, NULL, ENT(player));
		WRITE_BYTE(1);
		WRITE_SHORT(param[1] | 0x1000);
		WRITE_COORD(g_EndPosition.x);
		WRITE_COORD(g_EndPosition.y);
		WRITE_COORD(g_EndPosition.z);
		WRITE_SHORT(CSprites.lightning);
		WRITE_BYTE(0);
		WRITE_BYTE(0);
		WRITE_BYTE(2);
		WRITE_BYTE(10);
		WRITE_BYTE(0);
		WRITE_BYTE(255);
		WRITE_BYTE(255);
		WRITE_BYTE(0);
		WRITE_BYTE(200);
		WRITE_BYTE(0);
		MESSAGE_END();
	}

	return 1;
}

static cell AMX_NATIVE_CALL SendTracers(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	Vector Origin = player->v.origin;
	Vector Eyes_Origin = Origin + player->v.view_ofs;

	Vector Angles;
	ANGLEVECTORS(player->v.v_angle, Angles, NULL, NULL);

	Vector Destination = Eyes_Origin + Angles * 8192;

	TraceResult Result;
	TRACE_LINE(Eyes_Origin, Destination, 0, player, &Result);

	g_EndPosition = (Result.flFraction < 1.0) ? Result.vecEndPos : Vector(0, 0, 0);

	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
	WRITE_BYTE(TE_TRACER);
	WRITE_COORD(Origin.x);
	WRITE_COORD(Origin.y);
	WRITE_COORD(Origin.z);
	WRITE_COORD(g_EndPosition.x);
	WRITE_COORD(g_EndPosition.y);
	WRITE_COORD(g_EndPosition.z);
	MESSAGE_END();
	

	return 1;
}

static cell AMX_NATIVE_CALL set_painshock(AMX* amx, cell* param)
{
	CHECK_PLAYER(param[1])

	const auto index = param[1];
	const auto player = INDEXENT(index);

	if(player->pvPrivateData != NULL)
		*((int *) player->pvPrivateData + OFFSET_PAINSHOCK);

	return 1;
}

AMX_NATIVE_INFO ZombieFunctions[] = 
{
	{ "send_intermission"      ,	   send_intermission }, 
	{ "set_painshock"		   ,		   set_painshock }, 
	{ "rem"					   ,				     rem },
	{ "CreateBot"			   ,			   CreateBot }, 
	{ "can"					   ,					 can }, 
	{ "get_mins"			   ,		        get_mins }, 
	{ "set_nextthink"		   ,		   set_nextthink },  
	{ "kill"				   ,					kill }, 
	{ "set_team_offset"		   ,		 set_team_offset }, 
	{ "send_bar_time"		   ,		   send_bar_time }, 
	{ "get_target_and_attack"  ,   get_target_and_attack }, 
	{ "set_frozen"			   ,			  set_frozen },
	{ "SendTeleport"		   ,		    SendTeleport },
	{ "SendDamage"			   ,			  SendDamage }, 
	{ "SendSmoke"			   ,			   SendSmoke }, 
	{ "SendFlame"			   ,			   SendFlame }, 
	{ "sound"				   ,				   sound },
	{ "SendGlassBreak"	       ,		  SendGlassBreak }, 
	{ "send_screen_fade"	   ,		send_screen_fade },
	{ "remove_entity"		   ,		   remove_entity },
	{ "SendScreenShake"	       ,	     SendScreenShake }, 
	{ "SendImplosion"		   ,		   SendImplosion }, 
	{ "SendParticleBurst"	   ,	   SendParticleBurst }, 
	{ "send_particle_burst"    ,	 send_particle_burst }, 
	{ "SendInfectionLight"	   ,	  SendInfectionLight },
	{ "SendAura"               ,                SendAura },
	{ "set_weaponmodel_null"   ,	set_weaponmodel_null },
	{ "HideWeapon"	           ,		      HideWeapon }, 
	{ "HideCrosshair"		   ,		   HideCrosshair }, 
	{ "SendLavaSplash"	       ,		  SendLavaSplash }, 
	{ "get_oldbuttons"		   ,		  get_oldbuttons },
	{ "get_button"			   ,			  get_button }, 
	{ "set_take_damage"		   ,		 set_take_damage }, 
	{ "send_explosion"		   ,		  send_explosion }, 
	{ "SendGrenadeBeamFollow"  ,   SendGrenadeBeamFollow }, 
	{ "send_beam_cylinder"	   ,	  send_beam_cylinder }, 
	{ "is_origin_vacant"	   ,		is_origin_vacant }, 
	{ "is_hull_vacant"		   ,		  is_hull_vacant }, 
	{ "set_weaponmodel"		   ,		 set_weaponmodel }, 
	{ "set_viewmodel"		   ,		   set_viewmodel }, 
	{ "get_user_jetpack"	   ,		get_user_jetpack }, 
	{ "create_mine"			   ,			 create_mine }, 
	{ "set_gravity"			   ,			 set_gravity }, 
	{ "set_zombie"			   ,			  set_zombie }, 
	{ "set_user_jetpack"	   ,		set_user_jetpack }, 
	{ "SetFOV"			       ,				  SetFOV },
	{ "set_user_fuel"		   ,		   set_user_fuel }, 
	{ "set_user_rocket_time"   ,	set_user_rocket_time }, 
	{ "user_drop_jetpack"	   ,	   user_drop_jetpack }, 
	{ "give_weapon"			   ,			 give_weapon },
	{ "get_user_model"		   ,		  get_user_model }, 
	{ "set_user_model"		   ,		  set_user_model }, 
	{ "set_team"			   ,				set_team }, 
	{ "get_team"			   ,				get_team }, 
	{ "SetLight"			   ,				SetLight }, 
	{ "get_origin"			   ,			  get_origin }, 
	{ "get_frags"			   ,			   get_frags }, 
	{ "get_deaths"			   ,			  get_deaths }, 
	{ "set_frags"			   ,			   set_frags }, 
	{ "ent"					   ,					 ent }, 
	{ "set_deaths"			   ,			  set_deaths }, 
	{ "get_armor"			   ,			   get_armor }, 
	{ "reset_armor"			   ,			 reset_armor }, 
	{ "SendScoreInfo"		   ,		   SendScoreInfo }, 
	{ "strip_name"			   ,			  strip_name },
	{ "FixScoreAttrib"	       ,	      FixScoreAttrib }, 
	{ "get_health"			   ,			  get_health }, 
	{ "set_weapon_ammo"		   ,		 set_weapon_ammo }, 
	{ "set_monster"			   ,			 set_monster }, 
	{ "Beam"				   ,					Beam },
	{ "set_health"			   ,			  set_health }, 
	{ "SendNightVision"		   ,		 SendNightVision },
	{ "SendFlashLight"         ,          SendFlashlight },
	{ "SendGrenadeLight"       ,        SendGrenadeLight },
	{ "SendGrenadeBeamCylinder", SendGrenadeBeamCylinder },
	{ "SendDeathMsg"		   ,		    SendDeathMsg }, 
	{ "set_jetpack"			   ,			 set_jetpack },
	{ "set_goldenak47"		   ,		  set_goldenak47 },
	{ "set_goldenm4a1"		   ,		  set_goldenm4a1 },
	{ "set_goldenxm1014"	   ,		set_goldenxm1014 },
	{ "set_goldendeagle"	   ,		set_goldendeagle },
	{ "SendTracers"			   ,			 SendTracers },
	{ "SendLightningTracers"   ,	SendLightningTracers },
	{ "SendSniperTracers"      ,       SendSniperTracers },
	{ "SendSkillEffect"        ,         SendSkillEffect },
	{ "set_ent_flags"		   ,		   set_ent_flags }, 
	{ "strip_user_weapons"	   ,	  strip_user_weapons }, 
	{ "get_ent_flags"		   ,		   get_ent_flags }, 
	{ "set_glow"			   ,				set_glow }, 
	{ "remove_glow"			   ,			 remove_glow }, 
	{ "set_armor"			   ,			   set_armor }, 
	{ "set_origin"			   ,			  set_origin }, 
	{ "get_velocity"		   ,			get_velocity }, 
	{ "set_velocity"		   ,			set_velocity }, 
	{ "set_speed"			   ,			   set_speed },  
	{ "reset_money"			   ,			 reset_money }, 
	{ "range"				   ,				   range },
	{ 0						   ,					   0 }
};


void OnAmxxAttach(void) 
{
	MF_AddNatives(ZombieFunctions);
}

void OnPluginsLoaded(void) 
{
	CForwards.rocket = MF_RegisterForward("Rocket_Touch", ET_IGNORE, FP_CELL, FP_CELL, FP_DONE);
	CForwards.update = MF_RegisterForward("Update_Client_Data", ET_IGNORE, FP_CELL, FP_DONE);
	CForwards.grenade = MF_RegisterForward("Grenade_Thrown", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_DONE);
	CForwards.mine = MF_RegisterForward("Mine_Think", ET_IGNORE, FP_CELL, FP_CELL, FP_DONE);
}

void UpdateClientData(const edict_t* pEntity, int, clientdata_s*)
{
	if (gpGlobals->time > 4 && MF_IsPlayerIngame(ENTINDEX(pEntity)) && pEntity->v.oldbuttons & IN_SCORE && pEntity->v.button & IN_SCORE)
		MF_ExecuteForward(CForwards.update, static_cast <cell> (ENTINDEX(pEntity)));

	RETURN_META(MRES_IGNORED);
}

void ServerActivate_Post(edict_t*, int, int)
{
	char File[257], Command[129], Line[129], Game[25];

	//CVAR_SET_STRING("light", "d");
	//CVAR_SET_STRING( "sv_skyname", "space" );

	//CVAR_SET_FLOAT( "sv_skycolor_r", 0 );
	//CVAR_SET_FLOAT( "sv_skycolor_g", 0 );
	//CVAR_SET_FLOAT( "sv_skycolor_b", 0 );
	//CVAR_SET_FLOAT( "sv_allowdownload", 1 );
	//CVAR_SET_FLOAT( "mp_timelimit", 40 );

	GET_GAME_DIR(Game);

	snprintf(File, 256, "%s/addons/amxmodx/configs/maps/%s.cfg", Game, STRING(gpGlobals->mapname));

	FILE* pFile = fopen(File, "a+");

	if (pFile)
	{
		while (!feof(pFile))
		{
			Line[0] = '\0';

			fgets(Line, 128, pFile);

			trim(Line);

			if (strlen(Line) > 2)
			{
				snprintf(Command, 128, "%s\n", Line);

				SERVER_COMMAND(Command);
			}
		}

		fclose(pFile);
	}

	if (CMiscs.spawns)
	{
		edict_t* pEntity = NULL;

		while (!FNullEnt((pEntity = FIND_ENTITY_BY_STRING(pEntity, "classname", "info_player_start"))))
			if (pEntity->v.iuser4 != Spawn_Flag)
				REMOVE_ENTITY(pEntity);

		pEntity = NULL;

		while (!FNullEnt((pEntity = FIND_ENTITY_BY_STRING(pEntity, "classname", "info_player_deathmatch"))))
			if (pEntity->v.iuser4 != Spawn_Flag)
				REMOVE_ENTITY(pEntity);
	}

	RETURN_META(MRES_IGNORED);
}

int ClientConnect_Post(edict_t* pEntity, const char* pName, const char* pAddress, char*)
{
	CLIENT_COMMAND(pEntity, "rate 25000; fps_max 999; cl_cmdrate 101; cl_updaterate 35; cl_dynamiccrosshair 0\n");
	CLIENT_COMMAND(pEntity, "mp3volume 0.25; mp3 play media/Half-Life%d.mp3\n", g_ConnectionSounds[RANDOM_LONG(0, 2)]);

	RETURN_META_VALUE(MRES_IGNORED, 0);
}

int DispatchSpawn(edict_t* pSpawned)
{
	if (!FNullEnt(pSpawned))
	{
		const char* pClass = STRING(pSpawned->v.classname);

		if (strcasecontain(pClass, "Multi") || strcasecontain(pClass, "Manager") || strcasecontain(pClass, "Safety") || strcasecontain(pClass, "Tank") || strcasecontain(pClass, "Buy") || strcasecontain(pClass, "Env") || strcasecontain(pClass, "Sprite") || strcasecontain(pClass, "Glow") || strcasecontain(pClass, "Info_Target") || strcasecontain(pClass, "Ambient") || strcasecontain(pClass, "Camera") || strcasecontain(pClass, "Parameters") || strcasecontain(pClass, "Bomb") || strcasecontain(pClass, "Hostage") || strcasecontain(pClass, "Rescue") || strcasecontain(pClass, "Vip") || strcasecontain(pClass, "Equip") || strcasecontain(pClass, "Strip"))
			REMOVE_ENTITY(pSpawned);
	}

	if (!CMiscs.prepared)
	{
		char File[257], Line[129], Game[25], Team[3];

		CStrings.jetpack     = ALLOC_STRING("Jetpack");
		CStrings.rocket      = ALLOC_STRING("Rocket");
		CStrings.mine        = ALLOC_STRING("Mine");
		CStrings.pegon       = ALLOC_STRING("models/p_egon.mdl");
		CStrings.vegon       = ALLOC_STRING("models/v_egon.mdl");
		CStrings.pknife      = ALLOC_STRING("models/p_knife.mdl");
		CStrings.vknife      = ALLOC_STRING("models/v_knife.mdl");
		CStrings.vgoldak     = ALLOC_STRING("models/PerfectZM/v_goldenak47.mdl");
		CStrings.pgoldak     = ALLOC_STRING("models/PerfectZM/p_goldenak47.mdl");
		CStrings.vgoldm4     = ALLOC_STRING("models/PerfectZM/v_goldenm4a1.mdl");
		CStrings.pgoldm4     = ALLOC_STRING("models/PerfectZM/p_goldenm4a1.mdl");
		CStrings.vgoldxm     = ALLOC_STRING("models/PerfectZM/v_goldenxm1014.mdl");
		CStrings.pgoldxm     = ALLOC_STRING("models/PerfectZM/p_goldenxm1014.mdl");
		CStrings.vgolddeagle = ALLOC_STRING("models/PerfectZM/v_goldendeagle.mdl");
		CStrings.pgolddeagle = ALLOC_STRING("models/PerfectZM/p_goldendeagle.mdl");
		CStrings.infotarget  = ALLOC_STRING("info_target");
		CStrings.tspawn      = ALLOC_STRING("info_player_deathmatch");
		CStrings.ctspawn     = ALLOC_STRING("info_player_start");
		CStrings.null        = ALLOC_STRING("");

		edict_t* pEntity = CREATE_NAMED_ENTITY(ALLOC_STRING("hostage_entity"));

		if (!FNullEnt(pEntity))
		{
			SET_ORIGIN(pEntity, Vector(8192, 8192, 8192));

			MDLL_Spawn(pEntity);
		}

		//pEntity = CREATE_NAMED_ENTITY(ALLOC_STRING("env_fog"));

		/*if( !FNullEnt( pEntity ) ) {
			KeyValueData KVD;

			KVD.szClassName = "env_fog";
			KVD.szKeyName = "density";
			KVD.szValue = "0.00086";
			KVD.fHandled = 0;

			MDLL_KeyValue( pEntity, &KVD );

			KVD.szClassName = "env_fog";
			KVD.szKeyName = "rendercolor";
			KVD.szValue = "121 121 121";
			KVD.fHandled = 0;

			MDLL_KeyValue( pEntity, &KVD );
		}*/

		PRECACHE_MODEL("models/rpgrocket.mdl");
		PRECACHE_MODEL("models/p_egon.mdl");
		PRECACHE_MODEL("models/v_egon.mdl");
		PRECACHE_MODEL("models/PerfectZM/p_goldenak47.mdl");
		PRECACHE_MODEL("models/PerfectZM/v_goldenak47.mdl");
		PRECACHE_MODEL("models/PerfectZM/p_goldenm4a1.mdl");
		PRECACHE_MODEL("models/PerfectZM/v_goldenm4a1.mdl");
		PRECACHE_MODEL("models/PerfectZM/p_goldenxm1014.mdl");
		PRECACHE_MODEL("models/PerfectZM/v_goldenxm1014.mdl");
		PRECACHE_MODEL("models/PerfectZM/p_goldendeagle.mdl");
		PRECACHE_MODEL("models/PerfectZM/v_goldendeagle.mdl");

		CSprites.fire      = PRECACHE_MODEL("sprites/xfireball3.spr");
		CSprites.flame     = PRECACHE_MODEL("sprites/flame.spr");
		CSprites.smoke     = PRECACHE_MODEL("sprites/black_smoke3.spr");
		CSprites.trail     = PRECACHE_MODEL("sprites/laserbeam.spr");
		CSprites.glass     = PRECACHE_MODEL("models/glassgibs.mdl");
		CSprites.shockwave = PRECACHE_MODEL("sprites/shockwave.spr");
		CSprites.explode   = PRECACHE_MODEL("sprites/zerogxplode.spr");
		CSprites.lightning = PRECACHE_MODEL("sprites/lgtning.spr");

		PRECACHE_SOUND("fvox/flatline.wav");
		PRECACHE_SOUND("PerfectZM/armor_hit.wav");
		PRECACHE_SOUND("PerfectZM/jetpack_fly.wav");
		PRECACHE_SOUND("PerfectZM/jetpack_blow.wav");
		PRECACHE_SOUND("PerfectZM/rocket_fire.wav");
		PRECACHE_SOUND("PerfectZM/gun_pickup.wav");
		//PRECACHE_SOUND("PerfectZM/mine_activate.wav");
		//PRECACHE_SOUND("PerfectZM/mine_deploy.wav");
		//PRECACHE_SOUND("PerfectZM/mine_charge.wav");
		PRECACHE_SOUND("PerfectZM/armor_equip.wav");

		GET_GAME_DIR(Game);

		snprintf(File, 256, "%s/addons/amxmodx/configs/spawns/%s_spawns.cfg", Game, STRING(gpGlobals->mapname));

		FILE* pFile = fopen(File, "r");
		
		if (pFile)
		{
			float Origin[3], Angles[3];
			int State = 0;
			char* pPiece;

			while (!feof(pFile))
			{
				Line[0] = '\0';

				fgets(Line, 128, pFile);

				trim(Line);

				if (Line[0] != '/' && strlen(Line) > 5)
				{
					State = 0;
					pPiece = strtok(Line, " ");

					while (pPiece != NULL)
					{
						switch (State)
						{
						case TEAM:
							snprintf(Team, 2, "%s", pPiece);

							break;

						case ORIGIN_X:
							Origin[0] = atof(pPiece);

							break;

						case ORIGIN_Y:
							Origin[1] = atof(pPiece);

							break;

						case ORIGIN_Z:
							Origin[2] = atof(pPiece);

							break;

						case ANGLES_X:
							Angles[0] = atof(pPiece);

							break;

						case ANGLES_Y:
							Angles[1] = atof(pPiece);

							break;

						case ANGLES_Z:
							Angles[2] = atof(pPiece);

							break;
						}

						State++;

						pPiece = strtok(NULL, " ");
					}

					edict_t* pEntity = CREATE_NAMED_ENTITY(Team[0] == 'T' ? CStrings.tspawn : CStrings.ctspawn);
					
					if (!FNullEnt(pEntity))
					{
						(pEntity)->v.origin = Origin;
						(pEntity)->v.angles = Angles;
						(pEntity)->v.iuser4 = Spawn_Flag;
					}
				}
			}

			fclose(pFile);

			CMiscs.spawns = true;
		}

		CMiscs.prepared = true;
	}

	RETURN_META_VALUE(MRES_IGNORED, 0);
}

void DispatchThink(edict_t* pEntity)
{
	if (pEntity->v.iuser4 == Mine_Flag)
		MF_ExecuteForward(CForwards.mine, static_cast <cell> (ENTINDEX(pEntity)), static_cast <cell> ((int)pEntity->v.health));

	RETURN_META(MRES_IGNORED);
}

void DispatchTouch(edict_t* pTouched, edict_t* pToucher)
{
	const char* pTouchedClass = STRING(pTouched->v.classname);

	if (!strcmp(pTouchedClass, "Rocket"))
	{
		MF_ExecuteForward(CForwards.rocket, static_cast <cell> (ENTINDEX(pTouched->v.owner)), static_cast <cell> (ENTINDEX(pTouched)));
		if (!strcmp("func_breakable", STRING(pToucher->v.classname)))
			MDLL_Use(pToucher, pTouched);

		for (int i = 0; i < 4; i++)
		{
			MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
			WRITE_BYTE(TE_EXPLOSION);
			WRITE_COORD(pTouched->v.origin.x + RANDOM_LONG(-22, 22));
			WRITE_COORD(pTouched->v.origin.y + RANDOM_LONG(-22, 22));
			WRITE_COORD(pTouched->v.origin.z + RANDOM_LONG(-22, 22));
			WRITE_SHORT(CSprites.explode);
			WRITE_BYTE(RANDOM_LONG(15, 25));
			WRITE_BYTE(15);
			WRITE_BYTE(0);
			MESSAGE_END();
		}

		for (int i = 0; i < 4; i++)
		{
			MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
			WRITE_BYTE(TE_BEAMCYLINDER);
			WRITE_COORD(pTouched->v.origin.x);
			WRITE_COORD(pTouched->v.origin.y);
			WRITE_COORD(pTouched->v.origin.z);
			WRITE_COORD(pTouched->v.origin.x);
			WRITE_COORD(pTouched->v.origin.y);
			WRITE_COORD(pTouched->v.origin.z + (450 + (i * 100)));
			WRITE_SHORT(CSprites.shockwave);
			WRITE_BYTE(0);
			WRITE_BYTE(0);
			WRITE_BYTE(4);
			WRITE_BYTE(i * 40);
			WRITE_BYTE(0);
			WRITE_BYTE(121);
			WRITE_BYTE(121);
			WRITE_BYTE(121);
			WRITE_BYTE(RANDOM_LONG(150, 240));
			WRITE_BYTE(0);
			MESSAGE_END();
		}

		REMOVE_ENTITY(pTouched);
	}

	else if (!strcmp(pTouchedClass, "Jetpack"))
	{
		if (ENTINDEX(pToucher) > gpGlobals->maxClients || ENTINDEX(pToucher) < 1 || !MF_IsPlayerAlive(ENTINDEX(pToucher)) || CPlayers[ENTINDEX(pToucher)].jetpack || CPlayers[ENTINDEX(pToucher)].zombie)
			RETURN_META(MRES_SUPERCEDE);

		if (CPlayers[ENTINDEX(pToucher)].fuel < 2)
			CPlayers[ENTINDEX(pToucher)].fuel = 250;

		CPlayers[ENTINDEX(pToucher)].jetpack = true;

		CLIENT_COMMAND(pToucher, "weapon_knife\n");

		SetJetpack(pToucher);

		EMITSOUND(pToucher, CHAN_ITEM, "PerfectZM/gun_pickup.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

		REMOVE_ENTITY(pTouched);
	}

	RETURN_META(MRES_IGNORED);
}

void SetClientKeyValue(int Player, char*, char* pKey, char*)
{
	RETURN_META(CPlayers[Player].modelled && !strcmp(pKey, "model") ? MRES_SUPERCEDE : MRES_IGNORED);
}

void ClientDisconnect(edict_t* pEntity)
{
	if (CPlayers[ENTINDEX(pEntity)].jetpack)
		DropJetpack(ENTINDEX(pEntity), true);

	CPlayers[ENTINDEX(pEntity)].frozen = false;
	CPlayers[ENTINDEX(pEntity)].fuel = 0;
	CPlayers[ENTINDEX(pEntity)].rocket = 0;
	CPlayers[ENTINDEX(pEntity)].modelled = false;
	CPlayers[ENTINDEX(pEntity)].monster = false;
	CPlayers[ENTINDEX(pEntity)].zombie = false;
	

	RETURN_META(MRES_IGNORED);
}

void ServerDeactivate(void)
{
	CMiscs.prepared = false;
	CMiscs.spawns = false;

	for (int i = 1; i <= gpGlobals->maxClients; i++)
	{
		CPlayers[i].frozen = false;
		CPlayers[i].fuel = 0;
		CPlayers[i].rocket = 0;
		CPlayers[i].jetpack = false;
		CPlayers[i].modelled = false;
		CPlayers[i].monster = false;
		CPlayers[i].zombie = false;
	}

	RETURN_META(MRES_IGNORED);
}

void ClientPutInServer(edict_t* pEntity)
{
	CPlayers[ENTINDEX(pEntity)].fuel = 0;
	CPlayers[ENTINDEX(pEntity)].rocket = 0;
	CPlayers[ENTINDEX(pEntity)].jetpack = false;
	CPlayers[ENTINDEX(pEntity)].modelled = false;
	CPlayers[ENTINDEX(pEntity)].monster = false;
	CPlayers[ENTINDEX(pEntity)].zombie = false;

	RETURN_META(MRES_IGNORED);
}

void PlayerPreThink(edict_t* pPlayer)
{
	if(CPlayers[ENTINDEX(pPlayer)].frozen)
		pPlayer->v.velocity = Vector(0, 0, 0);

	else if(CPlayers[ENTINDEX(pPlayer)].jetpack) 
	{
		int Button = pPlayer->v.button;
		float Time = gpGlobals->time;

		if(Button & IN_ATTACK2 && CPlayers[ENTINDEX(pPlayer)].rocket < Time) 
		{
			edict_t * pEntity = CREATE_NAMED_ENTITY(CStrings.infotarget);

			if(!FNullEnt(pEntity)) 
			{
				SET_MODEL(pEntity, "models/rpgrocket.mdl");

				pEntity->v.classname = CStrings.rocket;
				pEntity->v.movetype = MOVETYPE_FLY;
				pEntity->v.solid = SOLID_BBOX;
				pEntity->v.effects = EF_LIGHT;

				MAKE_VECTORS(pPlayer->v.v_angle);

				Vector Forward = gpGlobals->v_forward * 64;
				Vector Velocity = gpGlobals->v_forward * 1750;
				Vector Origin = pPlayer->v.origin;

				Origin.x += Forward.x, Origin.y += Forward.y;

				SET_ORIGIN(pEntity, Origin);

				pEntity->v.velocity = Velocity;

				Vector Angles;
				VEC_TO_ANGLES(Velocity, Angles);

				pEntity->v.angles = Angles, pEntity->v.owner = pPlayer;

				MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
				WRITE_BYTE(TE_BEAMFOLLOW);
				WRITE_SHORT(ENTINDEX(pEntity));
				WRITE_SHORT(CSprites.trail);
				WRITE_BYTE(25);
				WRITE_BYTE(5);
				WRITE_BYTE(191);
				WRITE_BYTE(191);
				WRITE_BYTE(191);
				WRITE_BYTE(RANDOM_LONG(150, 240));
				MESSAGE_END();

				EMITSOUND(pPlayer, CHAN_WEAPON, "PerfectZM/rocket_fire.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

				CPlayers[ENTINDEX(pPlayer)].rocket = Time + 15;
			}

			else
				CPlayers[ENTINDEX(pPlayer)].rocket = Time + 1;
		}

		if(Button & IN_DUCK && Button & IN_JUMP && !(pPlayer -> v.flags & FL_ONGROUND) && CPlayers[ENTINDEX(pPlayer)].fuel > 0) 
		{
			Vector Velocity = pPlayer->v.velocity;
			Vector Angles = pPlayer->v.angles;

			Angles.z = 0;

			Vector Forward;
			ANGLEVECTORS(Angles, Forward, 0, 0);

			Angles = Forward;

			Angles.x *= 300, Angles.y *= 300;

			Velocity.x = Angles.x, Velocity.y = Angles.y;

			if(Velocity.z < 300)
				Velocity.z += 35;

			pPlayer -> v.velocity = Velocity;

			MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
			WRITE_BYTE(TE_SPRITE);
			WRITE_COORD(pPlayer->v.origin.x);
			WRITE_COORD(pPlayer->v.origin.y);
			WRITE_COORD(pPlayer->v.origin.z);
			WRITE_SHORT(CSprites.fire);
			WRITE_BYTE(8);
			WRITE_BYTE(25);
			MESSAGE_END();

			if(CPlayers[ENTINDEX(pPlayer)].fuel > 80)
				EMITSOUND(pPlayer, CHAN_ITEM, "PerfectZM/jetpack_fly.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			else
				EMITSOUND(pPlayer, CHAN_ITEM, "PerfectZM/jetpack_blow.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

			CPlayers[ENTINDEX(pPlayer)].fuel -= 1;
		}

		else if(!(Button & IN_DUCK) && !(Button & IN_JUMP) && CPlayers[ENTINDEX(pPlayer)].fuel < 250)
			CPlayers[ENTINDEX(pPlayer)].fuel += 0.5;
	}

	/*if(pPlayer -> v.button & IN_USE && pPlayer -> v.velocity.z < 0)
		pPlayer -> v.velocity.z = -100;*/

	RETURN_META(MRES_IGNORED);
}

void EmitSound(edict_t* pEntity, int Channel, const char* pSound, float Volume, float Attenuation, int Flags, int Pitch)
{
	if(ENTINDEX(pEntity) > 0 && ENTINDEX(pEntity) <= gpGlobals -> maxClients) 
	{
		if(CPlayers[ENTINDEX(pEntity)].jetpack && pSound[0] == 'w' && pSound[8] == 'k')
			RETURN_META(MRES_SUPERCEDE);
	}

	RETURN_META(MRES_IGNORED);
}

void MessageBegin_Post(int, int Type, const float*, edict_t*)
{
	if(Type == CMessages.deathmsg && gpGlobals -> time > 6) 
	{
		CMessages.message = DeathMsg;

		CMessages.byte = 0;
	}

	else if(Type == CMessages.hltv && gpGlobals -> time > 6) 
	{
		CMessages.message = HLTV;

		CMessages.byte = 0;
	}

	RETURN_META(MRES_IGNORED);
}

void MessageEnd_Post(void) 
{
	if(CMessages.message)
		CMessages.message = 0;

	RETURN_META(MRES_IGNORED);
}

void WriteByte_Post(int Byte) 
{
	if(CMessages.message) 
	{
		switch(CMessages.message) 
		{
		case DeathMsg:
			if(++CMessages.byte == 2 && CPlayers[Byte].jetpack)
				DropJetpack(Byte, true);

			break;

		case HLTV:
			switch(++CMessages.byte) 
			{
			case 1:
				CMessages.status = Byte;

				break;

			case 2:
				if(!CMessages.status && !Byte) 
				{
					edict_t * pEntity = NULL;

					while(!FNullEnt((pEntity = FIND_ENTITY_BY_STRING(pEntity, "classname", "Rocket"))))
						REMOVE_ENTITY(pEntity);

					pEntity = NULL;

					while(!FNullEnt((pEntity = FIND_ENTITY_BY_STRING(pEntity, "classname", "Jetpack"))))
						REMOVE_ENTITY(pEntity);

					pEntity = NULL;

					while(!FNullEnt((pEntity = FIND_ENTITY_BY_STRING(pEntity, "classname", "Mine"))))
						REMOVE_ENTITY(pEntity);
				}

				break;
			}

			break;
		}
	}

	RETURN_META(MRES_IGNORED);
}

int RegUserMsg_Post(const char* pName, int)
{
	if(!strcmp(pName, "DeathMsg"))
		CMessages.deathmsg = META_RESULT_ORIG_RET(int);

	else if(!strcmp(pName, "HLTV"))
		CMessages.hltv = META_RESULT_ORIG_RET(int);

	else if(!strcmp(pName, "ScoreAttrib"))
		CMessages.scoreattrib = META_RESULT_ORIG_RET(int);

	else if(!strcmp(pName, "ScoreInfo"))
		CMessages.scoreinfo = META_RESULT_ORIG_RET(int);

	else if(!strcmp(pName, "TeamInfo"))
		CMessages.teaminfo = META_RESULT_ORIG_RET(int);

	else if(!strcmp(pName, "SayText"))
		CMessages.saytext = META_RESULT_ORIG_RET(int);

	else if(!strcmp(pName, "ScreenFade"))
		CMessages.screenfade = META_RESULT_ORIG_RET(int);

	else if(!strcmp(pName, "ScreenShake"))
		CMessages.screenshake = META_RESULT_ORIG_RET(int);

	else if(!strcmp(pName, "Crosshair"))
		CMessages.crosshair = META_RESULT_ORIG_RET(int);

	else if(!strcmp(pName, "HideWeapon"))
		CMessages.hideweapon = META_RESULT_ORIG_RET(int);

	else if(!strcmp(pName, "Damage"))
		CMessages.damage = META_RESULT_ORIG_RET(int);

	else if(!strcmp(pName, "BarTime"))
		CMessages.bartime = META_RESULT_ORIG_RET(int);
	
	else if(!strcmp(pName, "SetFOV"))
		CMessages.fov = META_RESULT_ORIG_RET(int);	

	RETURN_META_VALUE(MRES_IGNORED, 0);
}

void ClientKill(edict_t*)
{
	RETURN_META(MRES_SUPERCEDE);
}