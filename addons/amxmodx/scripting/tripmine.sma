#include < amxmodx >
#include < fakemeta >
#include < fakemeta_util >
#include < fun >
#include < engine >
#include < hamsandwich >
#include < xs >

native IsZombie(id)
native GetPacks(id)
native SetPacks(id, iPacks)
native IsNemesis(i)
native IsAssasin(i)
native IsApocalypseRound()
native IsDevilRound()
native IsNightmareRound()
native IsArmageddonRound()
native IsSynapsisRound()
native IsSurvivorVsAssasinRound()
native IsBombardierVsGrenadierRound()

new q

#define MAX_ENTITIES		600
#define MAX_PLAYERS		32
#define MINE_ON			1
#define MINE_OFF			0
#define TASK_CREATE		84765
#define TASK_REMOVE		86766
#define MINE_COST			6
#define MINE_CLASSNAME		"zp_trip_mine"
#define MINE_MODEL_EXPLODE	"sprites/zerogxplode.spr"
#define MINE_MODEL_VIEW		"models/PerfectZM/lasermine.mdl"
#define MINE_MODEL_SPRITE	"sprites/shockwave.spr"
#define MINE_SOUND_ACTIVATE	"weapons/mine_activate.wav"
#define MINE_SOUND_CHARGE		"weapons/mine_charge.wav"
#define MINE_SOUND_DEPLOY		"weapons/mine_deploy.wav"
#define MINE_SOUND_EXPLODE		"fvox/flatline.wav"
#define MINE_HEALTH		800.0
#define entity_get_owner(%0)		entity_get_int( %0, EV_INT_iuser2 )
#define entity_get_status(%0)		entity_get_int( %0, EV_INT_iuser1 )
#define entity_get_classname(%0,%1)	entity_get_string( %0, EV_SZ_classname, %1, charsmax( %1 ) )

const FFADE_IN = 0x0000

new g_iTripMines[33]
new g_iPlantedMines[33]
new g_iPlanting[33]
new g_iRemoving[33]
new g_hExplode
new g_exploSpr
new tripmine_glow
new gmsgScreenShake
new g_MsgSync
new g_MsgSync2

public plugin_init()
{
	register_plugin("[ZP] Trip Mines", "2.0", "EYE | NeO")
	
	register_clcmd("say /lm", "Command_Buy")
	register_clcmd("say lm", "Command_Buy")
	q = get_user_msgid("SayText")
	register_clcmd("CreateLaser", "Command_Plant")
	register_clcmd("TakeLaser", "Command_Take")
	register_clcmd("plant_mine", "Command_Plant")
	register_clcmd("take_mine", "Command_Take")
	register_clcmd("CreateMine", "Command_Plant")
	register_clcmd("TakeMine", "Command_Take")
	register_clcmd("+makelaser", "Command_Plant")
	register_clcmd("+delllaser", "Command_Take")
	
	register_logevent("Event_RoundStart", 2, "1=Round_Start")
	
	register_think(MINE_CLASSNAME, "Forward_Think")
	
	tripmine_glow =	register_cvar("zp_tripmine_glow", "1")
	
	gmsgScreenShake = get_user_msgid("ScreenShake")

	g_MsgSync = CreateHudSyncObj()
	g_MsgSync2 = CreateHudSyncObj()
	
}

public plugin_precache( )
{
	engfunc(EngFunc_PrecacheModel, MINE_MODEL_VIEW)
	
	engfunc(EngFunc_PrecacheSound, MINE_SOUND_ACTIVATE)
	engfunc(EngFunc_PrecacheSound, MINE_SOUND_CHARGE)
	engfunc(EngFunc_PrecacheSound, MINE_SOUND_DEPLOY)
	engfunc(EngFunc_PrecacheSound, MINE_SOUND_EXPLODE)
	
	g_hExplode = engfunc(EngFunc_PrecacheModel, MINE_MODEL_EXPLODE)
	g_exploSpr = engfunc(EngFunc_PrecacheModel, MINE_MODEL_SPRITE)
}

public client_disconnected(id )
{
	g_iTripMines[id] = 0
	g_iPlanting[id] = false
	g_iRemoving[id] = false
	
	if (g_iPlantedMines[id])
	{
		Func_RemoveMinesByOwner(id)
		
		g_iPlantedMines[id] = 0
	}
	
	remove_task(id + TASK_REMOVE)
	remove_task(id + TASK_CREATE)
}

public Command_Buy(id)
{
	if (!is_user_alive(id))
	{
		Message(id, "^x04[ZP]^x01 You should be Alive")
		
		return PLUGIN_CONTINUE
	}
	
	if (IsZombie(id))
	{
		Message(id, "^x04[ZP]^x01 You should be Human")
		
		return PLUGIN_CONTINUE
	}
	
	if (GetPacks(id) < MINE_COST)
	{
		Message(id, "^x04[ZP]^x01 You need %i ammo packs", MINE_COST)
		
		return PLUGIN_CONTINUE
	}

	if (IsApocalypseRound() || IsDevilRound() ||  IsNightmareRound() || IsArmageddonRound() || IsSynapsisRound() || IsSurvivorVsAssasinRound() || IsBombardierVsGrenadierRound())
	{
		Message(id, "^x04[ZP]^x01 You can't buy a tripmine in a special round")
		
		return PLUGIN_CONTINUE
	}
	
	SetPacks(id, GetPacks(id) - MINE_COST)
	
	g_iTripMines[id]++
	
	Message(id, "^x04[ZP]^x01 You bought a trip mine. Press^x03 P^x01 to plant it or^x03 V^x01 to take it")
	
	client_cmd(id, "bind p CreateLaser")
	client_cmd(id, "bind v TakeLaser")
	client_cmd(id, "bind p CreateMine")
	client_cmd(id, "bind v TakeMine")
	client_cmd(id, "bind p plant_mine")
	client_cmd(id, "bind v take_mine")
	
	return PLUGIN_CONTINUE
}

public Command_Plant(id)
{
	if (!is_user_alive(id))
	{
		Message(id, "^x04[ZP]^x01 You should be Alive")
		
		return PLUGIN_CONTINUE
	}
	
	if (IsZombie(id))
	{
		Message(id, "^x04[ZP]^x01 You should be Human")
		
		return PLUGIN_CONTINUE
	}
	
	if (!g_iTripMines[id])
	{
		Message(id, "^x04[ZP]^x01 You don't have a trip mine to plant")
		
		return PLUGIN_CONTINUE
	}
	
	if (g_iPlantedMines[ id ] > 1)
	{
		Message(id, "^x04[ZP]^x01 You can plant only 2 mines")
		
		return PLUGIN_CONTINUE
	}
	
	if (IsApocalypseRound() || IsDevilRound() ||  IsNightmareRound() || IsArmageddonRound() || IsSynapsisRound() || IsSurvivorVsAssasinRound() || IsBombardierVsGrenadierRound())
	{
		Message(id, "^x04[ZP]^x01 You can't buy a tripmine in a special round")
		
		return PLUGIN_CONTINUE
	}
	
	if (g_iPlanting[id] || g_iRemoving[id]) return PLUGIN_CONTINUE
	
	if (CanPlant(id)) 
	{
		g_iPlanting[id] = true
		
		message_begin(MSG_ONE_UNRELIABLE, 108, _, id)
		write_byte(1)
		write_byte(0)
		message_end()
		
		set_task(1.2, "Func_Plant", id + TASK_CREATE)
	}
	
	return PLUGIN_CONTINUE
}

public Command_Take(id)
{
	if (!is_user_alive(id))
	{
		Message(id, "^x04[ZP]^x01 You should be Alive")
		
		return PLUGIN_CONTINUE
	}
	
	if (IsZombie(id))
	{
		Message(id, "^x04[ZP]^x01 You should be Human")
		
		return PLUGIN_CONTINUE
	}
	
	if (!g_iPlantedMines[id])
	{
		Message(id, "^x04[ZP]^x01 You don't have a planted mine")
		
		return PLUGIN_CONTINUE
	}
	
	if (g_iPlanting[id] || g_iRemoving[id]) return PLUGIN_CONTINUE
	
	if (CanTake(id)) 
	{
		g_iRemoving[id] = true
		
		message_begin(MSG_ONE_UNRELIABLE, 108, _, id)
		write_byte(1)
		write_byte(0)
		message_end()
		
		set_task(1.2, "Func_Take", id + TASK_REMOVE)
	}
	
	return PLUGIN_CONTINUE
}

public Event_RoundStart() 
{
	static iEntity, szClassName[32], id
	for (iEntity = 0; iEntity < MAX_ENTITIES + 1; iEntity++) 
	{
		if (!is_valid_ent(iEntity)) continue
		
		szClassName[0] = '^0'
		entity_get_classname(iEntity, szClassName)
		
		if (equal(szClassName, MINE_CLASSNAME)) remove_entity(iEntity)
	}
	
	for (id = 1; id < 33; id++) 
	{
		g_iTripMines[id] = 0
		g_iPlantedMines[id] = 0
	}
}

public Func_Take(id) 
{
	id -= TASK_REMOVE
	
	g_iRemoving[id] = false
	
	static iEntity, szClassName[32], Float:flOwnerOrigin[3], Float:flEntityOrigin[3]
	for (iEntity = 0; iEntity < MAX_ENTITIES + 1; iEntity++) 
	{
		if (!is_valid_ent(iEntity)) continue
		
		szClassName[0] = '^0'
		entity_get_classname(iEntity, szClassName)
		
		if (equal(szClassName, MINE_CLASSNAME)) 
		{
			if (entity_get_owner(iEntity) == id) 
			{
				entity_get_vector(id, EV_VEC_origin, flOwnerOrigin)
				entity_get_vector(iEntity, EV_VEC_origin, flEntityOrigin)
				
				if (get_distance_f(flOwnerOrigin, flEntityOrigin) < 55.0) 
				{
					g_iPlantedMines[id]--
					g_iTripMines[id]++
					
					remove_entity(iEntity)
					
					break
				}
			}
		}
	}
}

public bool:CanTake(id) 
{
	static iEntity, szClassName[32], Float:flOwnerOrigin[3], Float:flEntityOrigin[3]
	for (iEntity = 0; iEntity < MAX_ENTITIES + 1; iEntity++) 
	{
		if (!is_valid_ent(iEntity)) continue
		
		szClassName[0] = '^0'
		entity_get_classname(iEntity, szClassName)
		
		if (equal(szClassName, MINE_CLASSNAME)) 
		{
			if (entity_get_owner(iEntity) == id) 
			{
				entity_get_vector(id, EV_VEC_origin, flOwnerOrigin)
				entity_get_vector(iEntity, EV_VEC_origin, flEntityOrigin)
				
				if (get_distance_f(flOwnerOrigin, flEntityOrigin) < 55.0) return true
			}
		}
	}
	
	return false
}

public bool:CanPlant(id) 
{
	static Float:flOrigin[3]
	entity_get_vector(id, EV_VEC_origin, flOrigin)
	
	static Float:flTraceDirection[3], Float:flTraceEnd[3], Float:flTraceResult[3], Float:flNormal[3]
	velocity_by_aim(id, 64, flTraceDirection)
	flTraceEnd[0] = flTraceDirection[0] + flOrigin[0]
	flTraceEnd[1] = flTraceDirection[1] + flOrigin[1]
	flTraceEnd[2] = flTraceDirection[2] + flOrigin[2]
	
	static Float: flFraction, iTr
	iTr = 0
	engfunc(EngFunc_TraceLine, flOrigin, flTraceEnd, 0, id, iTr)
	get_tr2(iTr, TR_vecEndPos, flTraceResult)
	get_tr2(iTr, TR_vecPlaneNormal, flNormal)
	get_tr2(iTr, TR_flFraction, flFraction)
	
	if (flFraction >= 1.0) 
	{
		Message(id, "^x04[ZP]^x01 You must plant the tripmine on a wall")
		
		return false
	}
	
	return true
}

public Func_Plant(id) 
{
	id -= TASK_CREATE
	
	g_iPlanting[id] = false
	
	static Float:flOrigin[3]
	entity_get_vector(id, EV_VEC_origin, flOrigin)
	
	static Float:flTraceDirection[3], Float:flTraceEnd[3], Float:flTraceResult[3], Float:flNormal[3]
	velocity_by_aim(id, 128, flTraceDirection)
	flTraceEnd[0] = flTraceDirection[0] + flOrigin[0]
	flTraceEnd[1] = flTraceDirection[1] + flOrigin[1]
	flTraceEnd[2] = flTraceDirection[2] + flOrigin[2]
	
	static Float:flFraction, iTr
	iTr = 0
	engfunc(EngFunc_TraceLine, flOrigin, flTraceEnd, 0, id, iTr)
	get_tr2(iTr, TR_vecEndPos, flTraceResult)
	get_tr2(iTr, TR_vecPlaneNormal, flNormal)
	get_tr2(iTr, TR_flFraction, flFraction)
	
	static iEntity
	iEntity = create_entity("info_target")
	
	if (!iEntity) return
	
	entity_set_string(iEntity, EV_SZ_classname, MINE_CLASSNAME)
	entity_set_model(iEntity, MINE_MODEL_VIEW)
	entity_set_size(iEntity, Float:{-4.0, -4.0, -4.0}, Float:{4.0, 4.0, 4.0})
	
	if (get_pcvar_num(tripmine_glow)) fm_set_rendering(iEntity, kRenderFxGlowShell, random(256), random(256), random(256), kRenderNormal, 13)
	
	entity_set_int(iEntity, EV_INT_iuser2, id)
	
	g_iPlantedMines[id]++

	set_pev(iEntity, pev_iuser3, g_iPlantedMines[id])
	
	entity_set_float(iEntity, EV_FL_frame, 0.0)
	entity_set_float(iEntity, EV_FL_framerate, 0.0)
	entity_set_int(iEntity, EV_INT_movetype, MOVETYPE_FLY)
	entity_set_int(iEntity, EV_INT_solid, SOLID_NOT)
	entity_set_int(iEntity, EV_INT_body, 3)
	entity_set_int(iEntity, EV_INT_sequence, 7)
	entity_set_float(iEntity, EV_FL_takedamage, DAMAGE_NO)
	entity_set_int(iEntity, EV_INT_iuser1, MINE_OFF)
	
	static Float:flNewOrigin[3], Float:flEntAngles[3]
	flNewOrigin[0] = flTraceResult[0] + (flNormal[0] * 8.0)
	flNewOrigin[1] = flTraceResult[1] + (flNormal[1] * 8.0)
	flNewOrigin[2] = flTraceResult[2] + (flNormal[2] * 8.0)
	
	entity_set_origin(iEntity, flNewOrigin)
	
	vector_to_angle(flNormal, flEntAngles)
	entity_set_vector( iEntity, EV_VEC_angles, flEntAngles)
	flEntAngles[0] *= -1.0
	flEntAngles[1] *= -1.0
	flEntAngles[2] *= -1.0
	entity_set_vector(iEntity, EV_VEC_v_angle, flEntAngles)
	
	g_iTripMines[id]--
	
	emit_sound(iEntity, CHAN_WEAPON, MINE_SOUND_DEPLOY, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(iEntity, CHAN_VOICE, MINE_SOUND_CHARGE, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	entity_set_float(iEntity, EV_FL_nextthink, get_gametime() + 0.6)
}

public Func_RemoveMinesByOwner(id) 
{
	static iEntity, szClassName[32]
	for (iEntity = 0; iEntity < MAX_ENTITIES + 1; iEntity++) 
	{
		if (!is_valid_ent(iEntity)) continue
		
		szClassName[0] = '^0'
		entity_get_classname(iEntity, szClassName)
		
		if (equal(szClassName, MINE_CLASSNAME))
			if (entity_get_int(iEntity, EV_INT_iuser2) == id)
				remove_entity(iEntity)
	}
}

Func_Explode(iEntity) 
{
	g_iPlantedMines[entity_get_owner(iEntity)]--
	
	static Float:flOrigin[3], Float:flZombieOrigin[3], Float:flVelocity[3]
	entity_get_vector(iEntity, EV_VEC_origin, flOrigin)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, flOrigin[0])
	engfunc(EngFunc_WriteCoord, flOrigin[1])
	engfunc(EngFunc_WriteCoord, flOrigin[2])
	write_short(g_hExplode)
	emit_sound(iEntity, CHAN_WEAPON, MINE_SOUND_EXPLODE, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	write_byte(85)
	write_byte(15)
	write_byte(0)
	message_end()
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, flOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, flOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, flOrigin[2]) // z
	engfunc(EngFunc_WriteCoord, flOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, flOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, flOrigin[2] + 900.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(160) // width
	write_byte(0) // noise
	write_byte(121) // red
	write_byte(121) // green
	write_byte(121) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	static iZombie
	for (iZombie = 1; iZombie < MAX_PLAYERS + 1; iZombie++) 
	{
		if (is_user_connected(iZombie)) 
		{
			if (is_user_alive(iZombie)) 
			{
				entity_get_vector(iZombie, EV_VEC_origin, flZombieOrigin)
				
				if (get_distance_f(flOrigin, flZombieOrigin) < 340.0) 
				{
					entity_get_vector(iZombie, EV_VEC_velocity, flVelocity)
					
					flVelocity[2] += 240.0
					flVelocity[1] += 200.0
					flVelocity[0] += 160.0
					
					entity_set_vector(iZombie, EV_VEC_velocity, flVelocity)
				}
			}
		}
	}
	
	for (new i = 1; i < 33; i++)
	{
		if (!is_user_connected(i) || !is_user_alive(i)) continue
		if (IsZombie(i))
		{
			static Float:fDistance, Float:fDamage

			fDistance = entity_range(i, iEntity)

			if (fDistance < 340)
			{
				fDamage = 2850.0 - fDistance

				static Float:fVelocity[3]
				pev(i, pev_velocity, fVelocity)

				xs_vec_mul_scalar(fVelocity, 1.75, fVelocity)

				set_pev(i, pev_velocity, fVelocity)

				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, i)
				write_short(4096)
				write_short(4096)
				write_short(FFADE_IN)
				write_byte(220)
				write_byte(0)
				write_byte(0)
				write_byte(fDistance < 220 ? 220 : 205)
				message_end()
				
				message_begin(MSG_ONE_UNRELIABLE, gmsgScreenShake, _, i)
				write_short(4096 * 100 ) // amplitude
				write_short(4096 * 500 ) // duration
				write_short(4096 * 200 ) // frequency
				message_end()

				if (float(get_user_health(i)) - fDamage > 0) ExecuteHamB(Ham_TakeDamage, i, iEntity, entity_get_owner(iEntity), fDamage, DMG_BLAST)
				else ExecuteHamB(Ham_Killed, i, entity_get_owner(iEntity), 2)
				
				if (!IsNemesis(i) && !IsAssasin(i)) fDamage *= 0.75

				static cName[32]; get_user_name(i, cName, 31)
				Message(entity_get_owner(iEntity), "^x04[ZP]^x01 Damage to^x04 %s^x01 ::^x04 %0.0f^x01 damage", cName, fDamage)
			}
		}
	}

	for (new i = 1; i < 33; i++)
	{
		if (!is_user_connected(i) || !is_user_alive(i)) continue
		if (!IsZombie(i))
		{
			message_begin(MSG_ONE_UNRELIABLE, gmsgScreenShake, _, i)
			write_short(4096 * 3)
			write_short(4096 * 2)
			write_short(4096 * 4)
			message_end()
			
			if (entity_range(i, iEntity) < 340)
			{
				static Float:fVelocity[3]
				pev(i, pev_velocity, fVelocity)

				xs_vec_mul_scalar(fVelocity, 1.5, fVelocity)

				set_pev(i, pev_velocity, fVelocity)
			}
		}
	}

	remove_entity(iEntity)
}

public Forward_Think(iEntity) 
{
	static Float:flGameTime, iStatus
	flGameTime = get_gametime()
	iStatus = entity_get_status(iEntity)
	
	switch (iStatus) 
	{
		case MINE_OFF: 
		{
			entity_set_int(iEntity, EV_INT_iuser1, MINE_ON)
			entity_set_float(iEntity, EV_FL_takedamage, DAMAGE_YES)
			entity_set_int(iEntity, EV_INT_solid, SOLID_BBOX)
			entity_set_float(iEntity, EV_FL_health, MINE_HEALTH + 1000.0)
			
			emit_sound(iEntity, CHAN_VOICE, MINE_SOUND_ACTIVATE, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
		
		case MINE_ON: 
		{
			static Float:flHealth
			flHealth = entity_get_float(iEntity, EV_FL_health)

			if (is_user_alive(entity_get_owner(iEntity)))
			{
				if (entity_get_owner(iEntity))
				{
					if (pev(iEntity, pev_iuser3) == 1)
					{
						set_hudmessage(10, 255, 20, 0.10, 0.33, 0, 0.10, 0.10, 0.10, 0.10, 18)
						ShowSyncHudMsg(entity_get_owner(iEntity), g_MsgSync, "First mine's health: %0.0f", flHealth - 1000.0)
					}
					else
					{
						set_hudmessage(10, 255, 20, 0.10, 0.37, 0, 0.10, 0.10, 0.10, 0.10, 18)
						ShowSyncHudMsg(entity_get_owner(iEntity), g_MsgSync2, "Second mine's health: %0.0f", flHealth - 1000.0)
					}
				}
				
				if (flHealth <= 1000.0) 
				{
					Func_Explode(iEntity)
				
					return FMRES_IGNORED
				}
			}
		}
	}
	
	if (is_valid_ent(iEntity)) entity_set_float(iEntity, EV_FL_nextthink, flGameTime + 0.1)
	
	return FMRES_IGNORED
}

Message(v, c[], any: ...)
{
	static cBuffer[192]
	vformat(cBuffer, 191, c, 3)

	if (v)
	{
		message_begin(MSG_ONE_UNRELIABLE, q, _, v)
		write_byte(v)
		write_string(cBuffer)
		message_end()
	}

	else
	{
		static i[32], j, k
		get_players(i, j, "ch")
		for (k = 0; k < j; k++)
		{
			message_begin(MSG_ONE_UNRELIABLE, q, _, i[k])
			write_byte(i[k])
			write_string(cBuffer)
			message_end()
		}
	}
}