#pragma once
#include "amxxmodule.h"

#define CREATEFAKECLIENT			(*g_engfuncs.pfnCreateFakeClient)
#define INFOKEYVALUE				(*g_engfuncs.pfnInfoKeyValue)
#define GETINFOKEYBUFFER			(*g_engfuncs.pfnGetInfoKeyBuffer)
#define SETCLIENTKEYVALUE			(*g_engfuncs.pfnSetClientKeyValue)
#define SETCLIENTMAXSPEED			(*g_engfuncs.pfnSetClientMaxspeed)
#define EMITSOUND					(*g_engfuncs.pfnEmitSound)
#define ANGLEVECTORS				(*g_engfuncs.pfnAngleVectors)


#define CHECK_PLAYER(x) \
	if ((x) < 1 || (x) > gpGlobals->maxClients) \
	{ \
		MF_LogError(amx, AMX_ERR_NATIVE, "Player out of range (%d)", x); \
			return 0; \
	} \
	else \
	{ \
		if (!MF_IsPlayerIngame(x) || FNullEnt(INDEXENT(x))) \
			{\
				MF_LogError(amx, AMX_ERR_NATIVE, "Invalid player %d", x); \
				return 0; \
			}\
	}

#define PLAYER_AVAILAIBLE(x) \
	if ((x) > 0 && (x) <= gpGlobals->maxClients) \
	{ \
		return 0; \
	} \
	else \
	{ \
		MF_LogError(amx, AMX_ERR_NATIVE, "Player out of range (%d) or not available", x); \
		return 0; \
	}

#define PLAYER_FOUND(x)				(*((x) > 0 && (x) <= gpGlobals->maxClients))
