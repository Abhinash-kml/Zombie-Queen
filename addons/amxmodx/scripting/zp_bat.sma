/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "ZP: Bat"
#define VERSION "1.0"
#define AUTHOR "Sn!ff3r"

native RegisterPointsShopWeapon(const szName[ ], const iCost)
forward OnPointsShopWeaponSelected(iPlayer, iItemIndex)
native IsZombie(id)
forward OnInfectedPost(victim, infector, class)

#define fm_precache_model(%1) 		engfunc(EngFunc_PrecacheModel,%1)
#define fm_precache_sound(%1) 		engfunc(EngFunc_PrecacheSound,%1)
#define fm_remove_entity(%1) 		engfunc(EngFunc_RemoveEntity, %1)
#define fm_drop_to_floor(%1) 		engfunc(EngFunc_DropToFloor,%1)
#define fm_find_ent_by_class(%1,%2) 	engfunc(EngFunc_FindEntityByString, %1, "classname", %2)
#define fm_set_user_gravity(%1,%2) 	set_pev(%1,pev_gravity,%2)

#define PET_FLAG 			pev_flTimeStepSound
#define PET_KILLED 			389

static const pet_model[] = "models/stukabat.mdl"
static const pet_sounds[][] = { "bullchicken/bc_die1.wav", "bullchicken/bc_die2.wav", "bullchicken/bc_die3.wav", "bullchicken/bc_idle1.wav", "bullchicken/bc_pain3.wav" }
static const pet_idle = 13
static const pet_run = 13
static const pet_die = 5
static const pet_cost = 15
static const Float:pet_idle_speed = 0.5
static const Float:pet_run_speed = 13.0
static const Float:player_gravity = 0.5

new item_id
new item_pet[33]
new item_have[33]
new item_at_spawn[33]
new Float:item_leaptime[33]

new maxplayers

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("DeathMsg","DeathMsg","a")
	register_event("HLTV","HLTV", "a","1=0", "2=0")
	
	register_forward(FM_Think,"FM_Think_hook")
	register_forward(FM_PlayerPreThink, "FM_PlayerPreThink_hook")
	
	RegisterHam(Ham_Spawn, "player", "player_spawn", 1)	
	RegisterHam(Ham_Touch, "info_target", "player_touch")	
	
	register_dictionary("zombieaddons.txt")
	
	item_id = RegisterPointsShopWeapon("Bat", pet_cost)
	
	maxplayers = get_maxplayers()
}

public plugin_precache()
{
	new i = 0
	
	for(i = 0; i < sizeof pet_sounds; i++)
		fm_precache_sound(pet_sounds[i])
	
	fm_precache_model(pet_model)	
}

public HLTV()
{
	new entid = -1
	while((entid = fm_find_ent_by_class(entid, "zp_bat")))
	{
		if(pev(entid,PET_FLAG) == PET_KILLED)
		{
			fm_remove_entity(entid)
		}		
	}	
}

public DeathMsg() 
{
	new id = read_data(2)
	
	if(item_have[id])
	{
		kill_pet(id)	
	}
}

public OnInfectedPost(id, infector, class)
{
	if(item_have[id])
	{
		kill_pet(id)	
	}
}

public kill_pet(id)
{
	if(pev_valid(item_pet[id]))
	{
		set_pev(item_pet[id],pev_sequence,pet_die)
		set_pev(item_pet[id],pev_gaitsequence,pet_die)
		set_pev(item_pet[id],pev_framerate,1.0)
		
		set_pev(item_pet[id],PET_FLAG,PET_KILLED)
		
		fm_drop_to_floor(item_pet[id])
		
		item_have[id] = 0
	}	
	item_pet[id] = 0
}

public OnPointsShopWeaponSelected(player, itemid)
{	
	if ( itemid == item_id)
	{
		create_pet(player)		
	}
}

public player_spawn(player)
{
	if(is_user_alive(player))
	{
		if(item_have[player])
		{
			set_task(1.0,"new_round_gravity",player)
		}
		
		else if(item_at_spawn[player])
		{
			create_pet(player)
			item_at_spawn[player] = 0
		}
	}	
}

public player_touch(this,idother)
{	
	if(!this || !idother)
		return HAM_IGNORED
	
	new classname[32]
	pev(this,pev_classname,classname,31)
	if(equal(classname,"zp_bat") && is_a_player(idother) && !item_have[idother] && !IsZombie(idother))
	{
		if(pev(this,PET_FLAG) == PET_KILLED)
		{
			remove_pet(this)
			create_pet(idother)				
		}
	}	
	return HAM_IGNORED
}

public new_round_gravity(id)
{
	fm_set_user_gravity(id,player_gravity)	
}

public create_pet(id)
{
	if (item_have[id])
	{
		client_print_color(id, print_team_grey, "You already have a bat...")
		return PLUGIN_HANDLED
	}
	else if(!is_user_alive(id))
	{
		client_print_color(id, print_team_grey, "Because you are not alive, you will get your bat in next spawn...")
		item_at_spawn[id] = 1
		return PLUGIN_HANDLED
	}	
	else
	{
		item_pet[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString,"info_target"))
		set_pev(item_pet[id],pev_classname,"zp_bat")
		
		engfunc(EngFunc_SetModel,item_pet[id],pet_model)
		
		new Float:origin[3]
		pev(id,pev_origin,origin)			
		
		set_pev(item_pet[id],pev_origin,origin)
		set_pev(item_pet[id],pev_solid,SOLID_TRIGGER)
		set_pev(item_pet[id],pev_movetype,MOVETYPE_FLY)
		set_pev(item_pet[id],pev_owner,33)
		set_pev(item_pet[id],pev_nextthink,1.0)
		set_pev(item_pet[id],pev_sequence,0)
		set_pev(item_pet[id],pev_gaitsequence,0)
		set_pev(item_pet[id],pev_framerate,1.0)

		static r, g, b;
		r = random_num(75, 255)
		g = random_num(75, 255)
		b = random_num(75, 255)
		set_rendering(item_pet[id], kRenderFxGlowShell, r, g, b, kRenderTransAlpha, 1)
		
		
		fm_set_user_gravity(id,player_gravity)		
		
		engfunc(EngFunc_EmitSound,item_pet[id],CHAN_AUTO,pet_sounds[random_num(0,sizeof pet_sounds - 1)],1.0, 1.2, 0, PITCH_NORM)	
		
		client_print_color(id, print_team_grey, "You have a bat now [ Benefits: Long jump and Low Gravity ]")
	
		item_have[id] = 1
	}
	return PLUGIN_HANDLED
}

public FM_Think_hook(ent)
{
	for(new i = 0; i <= maxplayers; i++)
	{
		if(ent == item_pet[i])
		{
			static Float:origin[3]
			static Float:origin2[3]
			static Float:velocity[3]
			pev(ent,pev_origin,origin2)
			get_offset_origin_body(i,Float:{50.0,0.0,0.0},origin)
			
			if(get_distance_f(origin,origin2) > 300.0)
			{
				set_pev(ent,pev_origin,origin)
			}
			
			else if(get_distance_f(origin,origin2) > 80.0)
			{
				get_speed_vector(origin2,origin,250.0,velocity)
				set_pev(ent,pev_velocity,velocity)
				if(pev(ent,pev_sequence) != pet_run || pev(ent,pev_framerate) != pet_run_speed)
				{
					set_pev(ent,pev_sequence,pet_run)
					set_pev(ent,pev_gaitsequence,pet_run)
					set_pev(ent,pev_framerate,pet_run_speed)
				}
			}
			
			else if(get_distance_f(origin,origin2) < 75.0)
			{
				if(pev(ent,pev_sequence) != pet_idle || pev(ent,pev_framerate) != pet_idle_speed)
				{
					set_pev(ent,pev_sequence,pet_idle)
					set_pev(ent,pev_gaitsequence,pet_idle)
					set_pev(ent,pev_framerate,pet_idle_speed)
				}
				set_pev(ent,pev_velocity,Float:{0.0,0.0,0.0})
			}
			pev(i,pev_origin,origin)
			origin[2] = origin2[2]
			entity_set_aim(ent,origin)			
			set_pev(ent,pev_nextthink,1.0)
			break
		}
	}
}

public FM_PlayerPreThink_hook(id)
{
	if (!is_user_alive(id))
		return
	
	if(allowed_leap(id))
	{
		static Float:velocity[3]
		velocity_by_aim(id, get_cvar_num("zp_leap_nemesis_force"), velocity)
		
		velocity[2] = get_cvar_float("zp_leap_nemesis_height")
		
		set_pev(id, pev_velocity, velocity)
		
		item_leaptime[id] = get_gametime()
	}
}

public allowed_leap(id)
{	
	if(IsZombie(id))
		return false
	
	if(!item_have[id])
		return false
	
	if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 80)
		return false
	
	static buttons
	buttons = pev(id, pev_button)
	
	if (!is_user_bot(id) && (!(buttons & IN_JUMP) || !(buttons & IN_DUCK)))
		return false
	
	if (get_gametime() - item_leaptime[id] < 7)
		return false
	
	return true
}

public is_a_player(ent)
{
	if(ent > 0 && ent < 33)
		return true
	
	return false
}

public remove_pet(ent) 
{
	if(pev_valid(ent)) 
	{
		fm_remove_entity(ent)
	}
}

// Get entity's speed (from fakemeta_util)
stock fm_get_speed(entity)
{
	static Float:velocity[3]
	pev(entity, pev_velocity, velocity)
	
	return floatround(vector_length(velocity));
}
stock get_offset_origin_body(ent,const Float:offset[3],Float:origin[3])
{
	if(!pev_valid(ent))
		return 0;
	
	new Float:angle[3]
	pev(ent,pev_angles,angle)
	
	pev(ent,pev_origin,origin)
	
	origin[0] += floatcos(angle[1],degrees) * offset[0]
	origin[1] += floatsin(angle[1],degrees) * offset[0]
	
	origin[1] += floatcos(angle[1],degrees) * offset[1]
	origin[0] += floatsin(angle[1],degrees) * offset[1]
	
	return 1;
}

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}

stock entity_set_aim(ent,const Float:origin2[3],bone=0)
{
	if(!pev_valid(ent))
		return 0;
	
	static Float:origin[3]
	origin[0] = origin2[0]
	origin[1] = origin2[1]
	origin[2] = origin2[2]
	
	static Float:ent_origin[3], Float:angles[3]
	
	if(bone)
		engfunc(EngFunc_GetBonePosition,ent,bone,ent_origin,angles)
	else
		pev(ent,pev_origin,ent_origin)
	
	origin[0] -= ent_origin[0]
	origin[1] -= ent_origin[1]
	origin[2] -= ent_origin[2]
	
	static Float:v_length
	v_length = vector_length(origin)
	
	static Float:aim_vector[3]
	aim_vector[0] = origin[0] / v_length
	aim_vector[1] = origin[1] / v_length
	aim_vector[2] = origin[2] / v_length
	
	static Float:new_angles[3]
	vector_to_angle(aim_vector,new_angles)
	
	new_angles[0] *= -1
	
	if(new_angles[1]>180.0) new_angles[1] -= 360
	if(new_angles[1]<-180.0) new_angles[1] += 360
	if(new_angles[1]==180.0 || new_angles[1]==-180.0) new_angles[1]=-179.999999
	
	set_pev(ent,pev_angles,new_angles)
	set_pev(ent,pev_fixangle,1)
	
	return 1;
}

stock set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) {
	static Float:RenderColor[3];
	RenderColor[0] = float(r);
	RenderColor[1] = float(g);
	RenderColor[2] = float(b);

	set_pev(entity, pev_renderfx, fx);
	set_pev(entity, pev_rendercolor, RenderColor);
	set_pev(entity, pev_rendermode, render);
	set_pev(entity, pev_renderamt, float(amount));

	return 1;
}
