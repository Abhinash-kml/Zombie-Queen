#include <amxmodx>
#include <engine>
#include <fakemeta>

new const g_szStarts[][] = { "info_player_start", "info_player_deathmatch" }
new const Float:g_fOffsets[] = { 3500.0, 3500.0, 1500.0 }

new Array:g_vOrigins;
new Array:g_vSpawns;

new g_roundCount

public plugin_init()
{
	g_vOrigins = ArrayCreate(3,1);
	g_vSpawns = ArrayCreate(3,1);
	
	ScanMap();
	
	register_logevent("EventRoundStart", 2, "1=Round_Start");
}
public plugin_precache()
{
	precache_model("models/p_egon.mdl");
}
public plugin_end()
{
	ArrayDestroy(g_vOrigins);
	ArrayDestroy(g_vSpawns);
}
public EventRoundStart()
{
	g_roundCount++
	if (g_roundCount >= 3) TaskSpawnJetpacks()	
}
public TaskSpawnJetpacks()
{
	new Float:fOrigin[3];
	if(GetOrigin(fOrigin)) 
	{
		new iEnt = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"));
		if(pev_valid(iEnt))
		{
			entity_set_model(iEnt, "models/p_egon.mdl");
			engfunc(EngFunc_SetSize,iEnt,Float:{-16.0,-16.0,-16.0},Float:{16.0,16.0,16.0});
			entity_set_string(iEnt,EV_SZ_classname,"Jetpack");
			entity_set_int(iEnt,EV_INT_movetype,MOVETYPE_TOSS);
			entity_set_int(iEnt,EV_INT_solid,SOLID_TRIGGER);
			entity_set_origin(iEnt,fOrigin);

			set_dhudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), 0.03, 0.5, 2, 6.0, 10.0)
			show_dhudmessage(0, "A jetpack has spawned in a random place!")

			return 1;
		}
	}
	return 0;
}
stock GetOrigin(Float:origin[3])
{
    ArrayGetArray(g_vOrigins, random_num(0, ArraySize(g_vOrigins) - 1), origin);
    return 1;
}
IsOriginValid(Float:fStart[3], Float:fEnd[3])
{
	SetFloor(fEnd);
	
	fEnd[2] += 36.0;
	
	new iPoint = engfunc(EngFunc_PointContents,fEnd);
	if(iPoint == CONTENTS_EMPTY)
	{
		if(CheckPoints(fEnd) && CheckDistance(fEnd) && CheckVisibility(fStart,fEnd))
		{
			if(!trace_hull(fEnd,HULL_LARGE,-1)) { return true; }
		}
	}
	return false;
}
ScanMap()
{
	new Float:fOrigin[3];
	new iStart;
	
	for(iStart = 0;iStart < sizeof(g_szStarts); iStart++)
	{
		new iEnt;
		if((iEnt = engfunc(EngFunc_FindEntityByString,iEnt,"classname",g_szStarts[iStart])))
		{
			new iCounter;
			entity_get_vector(iEnt,EV_VEC_origin,fOrigin);
			ArrayPushArray(g_vSpawns,fOrigin);
			
			while(iCounter < 100000) { iCounter = GetLocation(fOrigin,iCounter); }
		}
	}
}
GetLocation(Float:fStart[3], &iCounter)
{
	new Float:fEnd[3];
	for(new i=0;i<3;i++) { fEnd[i] += random_float(0.0 - g_fOffsets[i],g_fOffsets[i]); }
	
	if(IsOriginValid(fStart,fEnd))
	{
		fStart[0] = fEnd[0];
		fStart[1] = fEnd[1];
		fStart[2] = fEnd[2];
		ArrayPushArray(g_vOrigins,fEnd);
	}
	iCounter++;
	return iCounter;
}
SetFloor(Float:fStart[3])
{
	new Float:fEnd[3];
	new iTrace;
	
	fEnd[0] = fStart[0];
	fEnd[1] = fStart[1];
	fEnd[2] = -99999.9;
	
	engfunc(EngFunc_TraceLine,fStart,fEnd,DONT_IGNORE_MONSTERS,-1,iTrace);
	get_tr2(iTrace,TR_vecEndPos,fStart);
}
CheckPoints(Float:origin[3])
{
	new Float:data[3], tr, point
	data[0] = origin[0]
	data[1] = origin[1]
	data[2] = 99999.9
	engfunc(EngFunc_TraceLine, origin, data, DONT_IGNORE_MONSTERS, -1, tr)
	get_tr2(tr, TR_vecEndPos, data)
	point = engfunc(EngFunc_PointContents, data)
	if(point == CONTENTS_SKY && get_distance_f(origin, data) < 250.0)
	{
		return false
	}
	data[2] = -99999.9
	engfunc(EngFunc_TraceLine, origin, data, DONT_IGNORE_MONSTERS, -1, tr)
	get_tr2(tr, TR_vecEndPos, data)
	point = engfunc(EngFunc_PointContents, data)
	if(point < CONTENTS_SOLID)
		return false
	
	return true
}

CheckDistance(Float:origin[3])
{
	new Float:dist, Float:data[3]
	new count = ArraySize(g_vSpawns)
	for(new i = 0; i < count; i++)
	{
		ArrayGetArray(g_vSpawns, i, data)
		dist = get_distance_f(origin, data)
		if(dist < 500.0)
			return false
	}

	count = ArraySize(g_vOrigins)
	for(new i = 0; i < count; i++)
	{
		ArrayGetArray(g_vOrigins, i, data)
		dist = get_distance_f(origin, data)
		if(dist < 500.0)
			return false
	}

	return true
}
CheckVisibility(Float:start[3], Float:end[3])
{
	new tr
	engfunc(EngFunc_TraceLine, start, end, IGNORE_GLASS, -1, tr)
	return (get_tr2(tr, TR_pHit) < 0)
}
