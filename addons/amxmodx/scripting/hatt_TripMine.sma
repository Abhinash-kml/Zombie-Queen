#include < amxmodx >
#include amxmisc
#include cstrike
#include < fakemeta_util >
#include < fun >
#include < engine >
#include hamsandwich
#include nvault
#include < zombieplague >
#include chr_engine

#define FADE_IN      0x0000
#define FADE_OUT      0x0001
#define FADE_MODULATE   0x0002
#define FADE_STAYOUT   0x0004

#define MAX_ENTITIES		(global_get(glb_maxEntities))
#define MINE_ON			1
#define MINE_OFF			0
#define TASK_CREATE		847655612
#define TASK_REMOVE		867661231
#define MINE_COST			5
#define MINE_CLASSNAME		"zp_mine"
#define MINE_MODEL_EXPLODE	"sprites/zerogxplode.spr"
#define MINE_MODEL_VIEW		"models/zombie_plague/lasermine.mdl"
#define MINE_SOUND_ACTIVATE	"weapons/mine_activate.wav"
#define MINE_SOUND_CHARGE		"weapons/mine_charge.wav"
#define MINE_SOUND_DEPLOY		"weapons/mine_deploy.wav"
#define MINE_HEALTH		800.0
#define entity_get_owner(%0)		entity_get_int( %0, EV_INT_iuser2 )
#define entity_get_status(%0)		entity_get_int( %0, EV_INT_iuser1 )
#define entity_get_classname(%0,%1)	entity_get_string( %0, EV_SZ_classname, %1, charsmax( %1 ) )

new g_iTripMines[ 33 ];
new g_iPlantedMines[ 33 ];
new g_iPlanting[ 33 ];
new g_iRemoving[ 33 ];
new g_iMineIds[33][2];
new g_multijumps[33];
new g_hExplode;
new g_hud[3];
new g_itemid;
new g_armor100;
new g_armor200;
new g_armor300;
new g_multijump;
new g_zgravity;
new g_zmultijump;
new g_specialmultijump;
new g_health;
new g_gravity;
new g_moddeagle;
new g_modak;
new g_ak;
new g_deagle;
new g_buyassassin;
new g_buynemesis;
new g_jetpack;
new g_buysniper;
new g_buysurvivor;
new g_modjetpack;
new jumpnum[33] = 0
new bool:dojump[33] = false
new g_isingravity[33]
new g_goldenak[33]
new g_goldendeagle[33]
new g_clip
new g_jet[33]
new g_blink[33]
new g_iblink, g_imodblink
new g_enemy[33]
new Float:g_fuel[33], Float:g_rocket[33]
new g_shockwave
new g_trail
new g_flame
new g_rounds[512]
new g_tryder[33]
new g_tryderid
new g_modscount=0
new g_modgravity
new g_curround = 0
new g_inround = false

// CS Offsets
#if cellbits == 32
const OFFSET_CLIPAMMO = 51
#else
const OFFSET_CLIPAMMO = 65
#endif
const OFFSET_LINUX_WEAPONS = 4

// Max Clip for weapons
new const MAXCLIP[] = { -1, 13, -1, 10, 1, 7, -1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20,
			10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50 }

setJetpack( Player)
{
	set_pev(Player, pev_viewmodel2, "models/v_egon.mdl")
	set_pev(Player, pev_weaponmodel2, "models/p_egon.mdl")
}

setKnife( Player)
{
	set_pev(Player, pev_viewmodel2, "models/v_knife.mdl")
	set_pev(Player, pev_weaponmodel2, "models/p_knife.mdl")
}

dropJetpack( Player,  Forced = false)
{
	new Float:origin[3];
	pev(Player, pev_origin, origin);

	new Float:vangle[3];
	pev(Player, pev_v_angle, vangle);
	engfunc(EngFunc_MakeVectors, vangle);
	
	new Float:fwd[3];
	global_get(glb_v_forward, fwd);
	fwd[0] *= 75.0;
	fwd[1] *= 75.0;
	fwd[2] *= 75.0;
	
	origin[0] += fwd[0]
	origin[1]+=fwd[1]

	new Trace=0;
	engfunc(EngFunc_TraceHull, origin, origin, IGNORE_MONSTERS | IGNORE_GLASS, HULL_HUMAN, 0, Trace);
	if (get_tr2(Trace, TR_StartSolid) || get_tr2(Trace, TR_AllSolid) || !get_tr2(Trace, TR_InOpen))
	{
		if (Forced)
		{
			g_jet[Player]=false

			if (is_user_alive(Player))
			{
				client_cmd(Player, "weapon_knife");
				setKnife(Player);
			}
		}
	}

	else
	{
		new pJetpack = create_entity("info_target");
		if (pev_valid(pJetpack))
		{
			engfunc(EngFunc_SetModel, pJetpack, "models/p_egon.mdl");
			engfunc(EngFunc_SetSize,pJetpack, Float:{-16.0, -16.0, -16.0},Float:{16.0, 16.0, 16.0});

			set_pev(pJetpack, pev_classname, "Jetpack")
			set_pev(pJetpack, pev_movetype, MOVETYPE_TOSS);
			set_pev(pJetpack, pev_solid, SOLID_TRIGGER);
			set_pev(pJetpack, pev_origin, origin);

			g_jet[Player] = false;

			if (is_user_alive(Player))
			{
				client_cmd(Player, "weapon_knife");
				setKnife(Player);
			}
		}
	}
}

public Drop(id)
{
	if (!is_user_connected(id))
		return 0;

	if (get_user_weapon(id)==CSW_KNIFE)
	{
		if (g_jet[id])
			dropJetpack(id, false)

		return 1;
	}
	
	return 0;
}

public plugin_init( )
{
	register_plugin( "[ZP] Extra Items [Especially Trip Mines]", "1.0", "Hattrick" );

	register_cvar("zp_limit_buy_mod_hours", "12") // a player can buy mod in how many hours?
	register_cvar("zp_map_mods_limit", "2") // how many mods can be purchased in map?
	
	register_cvar("zp_enable_bazooka_knockback", "0") // when bazooka's projectile explodes, change players position on map?
	register_cvar("zp_enable_bazooka_k_humans", "0") // if enabled above,   also include humans??
	register_cvar("zp_enable_bazooka_redfade", "1") // if enabled,   zombies get red screenfade if damaged by bazooka projectile?
	register_cvar("zp_enable_bazooka_flatline", "1") // if enabled,   zombies get sound while damaged by bazooka projectile?

	register_cvar("zp_enable_lasermine_knockback", "0") // when lasermine explodes, change players position on map?
	register_cvar("zp_enable_lasermine_k_humans", "0") // if enabled above,   also include humans??
	register_cvar("zp_enable_lasermine_redfade", "1") // if enabled,   zombies get red screenfade if damaged by lasermine?
	register_cvar("zp_enable_lasermine_flatline", "1") // if enabled,   zombies get sound while damaged by lasermine?

	register_forward(FM_Touch, "DispatchTouch");
	register_forward(FM_ClientDisconnect, "ClientDisconnect");
	
	register_clcmd( "say /lm", "Command_Buy" );
	register_clcmd( "say lm", "Command_Buy" );
	register_message(get_user_msgid("CurWeapon"), "message_cur_weapon")
	register_clcmd( "say_team /lm", "Command_Buy" );
	register_clcmd( "say_team lm", "Command_Buy" );
	
	register_clcmd("drop", "Drop");

	register_clcmd( "Plant_Mine", "Command_Plant" );
	register_clcmd( "Take_Mine", "Command_Take" );

	register_logevent( "Event_RoundStart", 2, "1=Round_Start" );
	register_logevent( "Event_RoundEnd", 2, "1=Round_End" );
	register_think( MINE_CLASSNAME, "Forward_Think" );
	
	// Health
	g_health = zp_register_extra_item("Health (+1,000 H.P.)", 25, ZP_TEAM_HUMAN|ZP_TEAM_SURVIVOR|ZP_TEAM_SNIPER);
	
	// Armors
	g_armor100 = zp_register_extra_item("Armor (100 A.P.)", 5, ZP_TEAM_HUMAN);
	g_armor200 = zp_register_extra_item("Armor (200 A.P.)", 9, ZP_TEAM_HUMAN);
	g_armor300 = zp_register_extra_item("Armor (300 A.P.)", 12, ZP_TEAM_HUMAN);
	
	// Clip
	g_clip = zp_register_extra_item("Unlimited Clip", 12, ZP_TEAM_HUMAN);
	
	// Jetpack
	g_jetpack = zp_register_extra_item("Jetpack + Bazooka", 32, ZP_TEAM_HUMAN);
	g_modjetpack = zp_register_extra_item("*MOD* Jetpack + Bazooka", 45, ZP_TEAM_SNIPER | ZP_TEAM_SURVIVOR);

	// Tryder
	g_tryderid=zp_register_extra_item("Tryder", 36, ZP_TEAM_HUMAN);
	
	// Laser
	g_itemid = zp_register_extra_item("Trip Mine (/LM)", MINE_COST, ZP_TEAM_HUMAN|ZP_TEAM_SURVIVOR|ZP_TEAM_SNIPER)
	
	// Jump
	g_multijump = zp_register_extra_item("Multi Jump (+1)", 3, ZP_TEAM_HUMAN);
	g_zmultijump = zp_register_extra_item("ZM Multi Jump (+1)", 5, ZP_TEAM_ZOMBIE);
	g_specialmultijump = zp_register_extra_item("*MOD* Multi Jump (+1)", 10, ZP_TEAM_SURVIVOR | ZP_TEAM_SNIPER | ZP_TEAM_ASSASSIN | ZP_TEAM_NEMESIS);
	
	// Graviy
	g_gravity = zp_register_extra_item("Extra Gravity", 8, ZP_TEAM_HUMAN);
	g_zgravity = zp_register_extra_item("ZM Extra Gravity", 15, ZP_TEAM_ZOMBIE);
	g_modgravity = zp_register_extra_item("*MOD* Extra Gravity", 20, ZP_TEAM_SNIPER | ZP_TEAM_ASSASSIN | ZP_TEAM_NEMESIS | ZP_TEAM_SURVIVOR);
	
	// AK
	g_ak = zp_register_extra_item("Gold Ak47 (More Damage)", 18, ZP_TEAM_HUMAN);
	g_modak = zp_register_extra_item("*MOD* Gold Ak47 (More Damage)", 24, ZP_TEAM_SURVIVOR);
	
	// Deagle
	g_deagle = zp_register_extra_item("Gold Deagle (More Damage)", 10, ZP_TEAM_HUMAN);
	g_moddeagle = zp_register_extra_item("*MOD* Gold Deagle (More Damage)", 12, ZP_TEAM_SURVIVOR);
	
	// Mod
	g_buyassassin = zp_register_extra_item("Buy Assassin", 190, ZP_TEAM_HUMAN);
	g_buynemesis = zp_register_extra_item("Buy Nemesis", 190, ZP_TEAM_HUMAN);
	g_buysniper = zp_register_extra_item("Buy Sniper", 190, ZP_TEAM_HUMAN);
	g_buysurvivor = zp_register_extra_item("Buy Survivor", 190, ZP_TEAM_HUMAN);

	// Blink
	g_iblink = zp_register_extra_item("Knife Blink (1s)", 5, ZP_TEAM_ZOMBIE);
	g_imodblink = zp_register_extra_item("*MOD* Knife Blink (1s)", 8, ZP_TEAM_ASSASSIN | ZP_TEAM_NEMESIS);
	
	RegisterHam(Ham_Killed, "player", "onKilled");

	register_event("StatusValue", "event_show_status", "be", "1=2", "2!0")
	register_event("StatusValue", "event_hide_status", "be", "1=1", "2=0")
	
	g_hud[0] = CreateHudSyncObj();
	g_hud[1] = CreateHudSyncObj();
	g_hud[2] = CreateHudSyncObj();
}

public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	// Player doesn't have the unlimited clip upgrade
	if (!g_tryder[msg_entity])
		return;
	
	// Player not alive or not an active weapon
	if (!is_user_alive(msg_entity) || get_msg_arg_int(1) != 1)
		return;
	
	static weapon, clip
	weapon = get_msg_arg_int(2) // get weapon ID
	clip = get_msg_arg_int(3) // get weapon clip
	
	// Unlimited Clip Ammo
	if (MAXCLIP[weapon] > 2) // skip grenades
	{
		set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon]) // HUD should show full clip all the time
		
		if (clip < 2) // refill when clip is nearly empty
		{
			// Get the weapon entity
			static wname[32], weapon_ent
			get_weaponname(weapon, wname, sizeof wname - 1)
			weapon_ent = fm_find_ent_by_owner(-1, wname, msg_entity)
			
			// Set max clip on weapon
			if (pev_valid(weapon_ent)==2)
			fm_set_weapon_ammo(weapon_ent, MAXCLIP[weapon])
		}
	}
}

public zp_round_started(gamemode, id)
{
	g_rounds[g_curround++] = gamemode;
	g_inround=true
}

public zp_round_ended(winteam)
{
	g_inround=false
}

public event_show_status(id)
{
	if (is_user_alive(id) && g_blink[id])
	{
		new enemy = read_data(2)
		if (is_user_alive(enemy) && !zp_get_user_zombie(enemy))
			g_enemy[id] = enemy;
		else
			g_enemy[id] = 0
	}
}

public event_hide_status(id)
{
	if (is_user_alive(id) && g_blink[id])
	{
		g_enemy[id] = 0
	}
}

public Event_RoundEnd()
{
	for ( new i = 1; i <=get_maxplayers(); i++)
	{
		g_isingravity[i] = false
		g_multijumps[i] = 0
		jumpnum[i] = 0
		dojump[i] = false
		g_blink[i]= false

		if (is_user_alive(i)&&!zp_get_user_zombie(i))
		{
			if (g_tryder[i])
				cs_set_user_armor(i, 0,CS_ARMOR_NONE)
			if (get_user_health(i)>get_cvar_num("zp_human_health"))
				set_user_health(i, get_cvar_num("zp_human_health"))
		}
		g_tryder[i]=false
	}
}

public Event_RoundStart( )
{
	static iEntity, szClassName[ 32 ], iPlayer;
	for( iEntity = 0; iEntity < MAX_ENTITIES + 1; iEntity++ )
	{
		if( !is_valid_ent( iEntity ) )
			continue;
		
		szClassName[ 0 ] = '^0';
		entity_get_classname( iEntity, szClassName );
		
		if( equali( szClassName, MINE_CLASSNAME ) || equali(szClassName, "Jetpack") || equali(szClassName, "Rocket"))
			remove_entity( iEntity );
	}
	
	for( iPlayer = 1; iPlayer < 33; iPlayer++ )
	{
		g_iTripMines[ iPlayer ] = 0;
		g_iPlantedMines[ iPlayer ] = 0;
		g_iMineIds[iPlayer][0] = 0;
		g_iMineIds[iPlayer][1] = 0;
		g_fuel[iPlayer]=250.0;
		g_rocket[iPlayer]=get_gametime()+random_float(0.2, 2.0)
	}
}

public onKilled(victim, killer, gib)
{
	if (g_isingravity[victim])
	{
		if (get_user_gravity(victim) <= 0.5)
		{
			set_user_gravity(victim, 1.0)
		}
	}
	g_isingravity[victim] = false
	g_multijumps[victim] = 0
	jumpnum[victim] = 0
	dojump[victim] = false
	g_goldenak[victim]=false
	g_goldendeagle[victim]=false
	if (g_jet[victim])
		dropJetpack(victim,true)
	g_fuel[victim]=0.0
	g_rocket[victim]=0.0
	g_jet[victim]=false
	g_tryder[victim]=false
	g_blink[victim]= false
}

public zp_user_humanized_pre(id, survivor)
{
	g_isingravity[id]=false
	g_multijumps[id]=false
	g_blink[id]=false
	g_rocket[id]=0.0
	g_fuel[id]=0.0
}

public zp_user_infected_pre(id, infector, nemesis)
{
	g_goldenak[id]=false
	g_goldendeagle[id]=false
	if (g_jet[id])
		dropJetpack(id,true)
	g_isingravity[id]=false
	g_multijumps[id]=false
	g_rocket[id]=0.0
	g_fuel[id]=0.0
}

public client_disconnect( iPlayer )
{
	g_goldenak[iPlayer]=false
	g_goldendeagle[iPlayer]=false
	g_isingravity[iPlayer] = false
	g_multijumps[iPlayer] = 0
	jumpnum[iPlayer] = 0
	g_blink[iPlayer]= false
	dojump[iPlayer] = false
	g_rocket[iPlayer]=0.0
	g_tryder[iPlayer]=false
	g_fuel[iPlayer]=0.0
	
	if (g_iPlantedMines[ iPlayer ] > 0)
	{
		Func_RemoveMinesByOwner( iPlayer );
		g_iPlantedMines[ iPlayer ] = 0;
	}

	g_iTripMines[ iPlayer ] = 0;

	g_iPlanting[ iPlayer ] = false;
	g_iRemoving[ iPlayer ] = false;

	g_iMineIds[iPlayer][0] = 0;
	g_iMineIds[iPlayer][1] = 0;
	
	if (task_exists(iPlayer + TASK_REMOVE))
		remove_task( iPlayer + TASK_REMOVE );
	if (task_exists(iPlayer + TASK_CREATE))
		remove_task( iPlayer + TASK_CREATE );
}

public client_PreThink(id)
{
	if (is_user_alive(id))
	{
		if (g_isingravity[id])
		{
			if (zp_get_user_zombie(id))
			{
				if (!zp_frozen(id))
				{
					set_user_gravity(id, 0.25)
				}
			}

			else
			{
				set_user_gravity(id, 0.5)
			}
		}
		
		if (g_blink[id] && g_enemy[id] > 0 && (pev(id, pev_button) & IN_ATTACK || pev(id, pev_button) & IN_ATTACK2) && is_user_alive(g_enemy[id]) && !zp_get_user_zombie(g_enemy[id]))
		{
			new Float:origin[3];
			new Float:new_velocity[3];
			
			pev(g_enemy[id], pev_origin, origin);

			entity_set_aim(id, origin);
			get_speed_vector2(id, g_enemy[id], 1150.0, new_velocity)
			
			set_task(1.2, "disableBlink", id);
			set_pev(id, pev_velocity, new_velocity);
		}
		
		if (g_multijumps[id] > 0)
		{
			new nbut = get_user_button(id)
			new obut = get_user_oldbutton(id)
			if((nbut & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND) && !(obut & IN_JUMP))
			{
				if(jumpnum[id] < g_multijumps[id])
				{
					dojump[id] = true
					jumpnum[id]++
					return
				}
			}
			if((nbut & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
			{
				jumpnum[id] = 0
				return
			}
		}

		if (g_jet[id])
		{
			if (pev(id, pev_button) & IN_ATTACK2 && g_rocket[id] < get_gametime())
			{
				new pEntity = create_entity("info_target");
				if (pev_valid(pEntity))
				{
					engfunc(EngFunc_SetModel, pEntity, "models/rpgrocket.mdl");

					set_pev(pEntity, pev_classname, "Rocket");
					set_pev(pEntity, pev_movetype, MOVETYPE_FLY);
					set_pev(pEntity, pev_solid, SOLID_BBOX);
					set_pev(pEntity, pev_effects, EF_LIGHT | EF_BRIGHTLIGHT);
					set_pev(pEntity, pev_owner, id);

					new Float:VAngle[3];
					pev(id, pev_v_angle, VAngle);
					engfunc(EngFunc_MakeVectors, VAngle);

					new Float:Forward[3], Float:Velocity[3];
					global_get(glb_v_forward, Forward);
					Forward[0]*=64.0;
					Forward[1]*=64.0;
					Forward[2]*=64.0;
					
					global_get(glb_v_forward, Velocity);
					Velocity[0]*=1750.0;
					Velocity[1]*=1750.0;
					Velocity[2]*=1750.0;

					new Float:Origin[3];
					pev(id, pev_origin, Origin);
					Origin[0] += Forward[0];
					Origin[1] += Forward[1];

					set_pev(pEntity, pev_origin, Origin);
					set_pev(pEntity, pev_velocity, Velocity);

					new Float: Angles[3];
					engfunc(EngFunc_VecToAngles, Velocity, Angles);
					set_pev(pEntity, pev_angles, Angles);

					message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
					write_byte(TE_BEAMFOLLOW);
					write_short(pEntity);
					write_short(g_trail);
					write_byte(25);
					write_byte(5);
					write_byte(191);
					write_byte(191);
					write_byte(191);
					write_byte(random_num(150, 240));
					message_end();

					emit_sound(id, CHAN_WEAPON, "ZombieOutstanding/rocket_fire.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
					g_rocket[id] = get_gametime() + 15.0;
				}

				else
					g_rocket[id] = get_gametime() + 1.0;
			}

			if (pev(id, pev_button) & IN_DUCK && pev(id, pev_button) & IN_JUMP && !(pev(id, pev_flags) & FL_ONGROUND) && g_fuel[id] > 0.0)
			{
				new Float:Velocity[3], Float:Angles[3], Float:Forward[3], Float:dummy1[3], Float:dummy2[3];
				
				pev(id, pev_velocity, Velocity);
				pev(id, pev_angles, Angles);
				Angles[2] = 0.0;

				engfunc(EngFunc_AngleVectors, Angles, Forward,dummy1,dummy2);
				Angles[0] = Forward[0], Angles[1] = Forward[1], Angles[2] = Forward[2];
				Angles[0] *= 300.0;
				Angles[1] *= 300.0;

				Velocity[0] = Angles[0];
				Velocity[1] = Angles[1];

				if (Velocity[2] < 300.0)
					Velocity[2] += 35.0;

				set_pev(id, pev_velocity, Velocity)

				if (random_num(0, 3) == 0)
				{
					new Float:Origin[3];
					pev(id, pev_origin, Origin);

					message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
					write_byte(TE_SPRITE);
					engfunc(EngFunc_WriteCoord, Origin[0]);
					engfunc(EngFunc_WriteCoord, Origin[1]);
					engfunc(EngFunc_WriteCoord, Origin[2]);
					write_short(g_flame);
					write_byte(8);
					write_byte(200);
					message_end();
				}

				if (g_fuel[id] > 80.0)
					emit_sound(id, CHAN_ITEM, "ZombieOutstanding/jetpack_fly.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

				else
					emit_sound(id, CHAN_ITEM, "ZombieOutstanding/jetpack_blow.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

				g_fuel[id] -= 1.0;
			}

			else if (!(pev(id, pev_button) & IN_DUCK) && !(pev(id, pev_button) & IN_JUMP) && g_fuel[id] < 250.0)
				g_fuel[id] += 0.5;
		}
	}
}

public disableBlink(i)
{
	if (is_user_connected(i))
		g_blink[i] = false
}

public client_PostThink(id)
{
	if(!is_user_alive(id))
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

public plugin_natives()
{
	register_library("hatt_EI");
	register_native("zp_get_gold_ak", "zp_get_gold_ak", 1)
	register_native ("zp_get_gold_de", "zp_get_gold_de", 1)
	register_native("zp_get_jp", "zp_get_jp", 1)
}

public zp_get_jp(i)
{
	return g_jet[i];
}

public zp_get_gold_ak(i)
{
	return g_goldenak[i]
}

public zp_get_gold_de(i)
{
	return g_goldendeagle[i];
}

public zp_extra_item_selected(id, itemid)
{
	static CsArmorType:tmp;
	static name[64];

	get_user_name(id, name, 63);
	set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), -1.0, 0.55,0, 6.0, 2.25, 0.1, 0.2,-1);

	if (itemid == g_itemid)
	{
		g_iTripMines[ id ]++;
		
		client_print_color( id, id, "^x04[ZP]^x01 You bought a^x03 Trip Mine^x01. Press^x04 P^x01 to plant it or^x04 V^x01 to take it" );
		
		client_cmd( id, "bind p Plant_Mine" );
		client_cmd( id, "bind v Take_Mine" );
		
		DCF( id, "bind p Plant_Mine" );
		DCF( id, "bind v Take_Mine" );

		ShowSyncHudMsg(id, g_hud[2], "* YOU BOUGHT A TRiP MiNE *");
	}
	
	else if (itemid == g_iblink)
	{
		g_blink[id] = true
		ShowSyncHudMsg(id, g_hud[2], "* %s HAS NOW KNiFE BLiNK *", name);
		client_print_color(0, id, "^x04[ZP]^x03 %s^x01 bought^x04 Knife Blink", name);
	}

	else if (itemid == g_imodblink)
	{
		g_blink[id] = true
		ShowSyncHudMsg(id, g_hud[2], "* %s HAS NOW *MOD* KNiFE BLiNK *", name);
		client_print_color(0, id, "^x04[ZP]^x03 %s^x01 bought^x04 *MOD* Knife Blink", name);
	}

	else if (itemid == g_armor100)
	{
		if (get_user_armor(id) + 100 > 300)
		{
			client_print_color( id, id, "^x04[ZP]^x01 You already have some armor." );
			return ZP_PLUGIN_HANDLED;
		}
		
		cs_set_user_armor(id, cs_get_user_armor(id, tmp) + 100, CS_ARMOR_VESTHELM);
		client_cmd(id, "spk items/tr_kevlar")
		ShowSyncHudMsg(id, g_hud[2], "* YOU BOUGHT ARMOR (100 A.P.) *");
		client_print_color( id, id, "^x04[ZP]^x01 You bought^x03 Armor (100 A.P.)" );
	}
	
	else if (itemid == g_clip)
	{
		g_tryder[id]=true
		ShowSyncHudMsg(id, g_hud[2], "* YOU BOUGHT UNLiMiTED CLiP *");
		client_print_color( id, id, "^x04[ZP]^x01 You bought^x03 Unlimited Clip" );
	}
	
	else if (itemid == g_armor200)
	{
		if (get_user_armor(id) + 200 > 300)
		{
			client_print_color( id, id, "^x04[ZP]^x01 You already have some armor." );
			return ZP_PLUGIN_HANDLED;
		}
		
		cs_set_user_armor(id, cs_get_user_armor(id, tmp) + 200, CS_ARMOR_VESTHELM);
		client_cmd(id, "spk items/tr_kevlar")
		ShowSyncHudMsg(id, g_hud[2], "* YOU BOUGHT ARMOR (200 A.P.) *");
		client_print_color( id, id, "^x04[ZP]^x01 You bought^x03 Armor (200 A.P.)" );
	}
	else if ( itemid ==g_armor300)
	{
		if (get_user_armor(id) + 300 > 300)
		{
			client_print_color( id, id, "^x04[ZP]^x01 You already have some armor." );
			return ZP_PLUGIN_HANDLED;
		}
		
		cs_set_user_armor(id, cs_get_user_armor(id, tmp) + 300, CS_ARMOR_VESTHELM);
		client_cmd(id, "spk items/tr_kevlar")
		ShowSyncHudMsg(id, g_hud[2], "* YOU BOUGHT ARMOR (300 A.P.) *");
		client_print_color( id, id, "^x04[ZP]^x01 You bought^x03 Armor (300 A.P.)" );
	}
	else if (itemid==g_tryderid)
	{
		set_user_health(id, 720);
		cs_set_user_armor(id, 720, CS_ARMOR_VESTHELM)
		ShowSyncHudMsg(0, g_hud[2], "* %s BOUGHT TRYDER *", name);
		client_print_color(0, id, "^x04[ZP]^x03 %s^x01 bought^x04 TRYDER", name);
		g_tryder[id]=true
		if (!user_has_weapon(id, CSW_AK47))
		{
			give_item(id, "weapon_ak47");
			cs_set_user_bpammo(id, CSW_AK47, 90)
		}
		if (!user_has_weapon(id, CSW_M4A1))
		{
			give_item(id, "weapon_m4a1");
			cs_set_user_bpammo(id, CSW_M4A1, 90)
		}
		if (!user_has_weapon(id, CSW_G3SG1))
		{
			give_item(id, "weapon_g3sg1");
			cs_set_user_bpammo(id, CSW_G3SG1, 90)
		}
		if (!user_has_weapon(id, CSW_SG550))
		{
			give_item(id, "weapon_sg550");
			cs_set_user_bpammo(id, CSW_SG550, 90)
		}
		if (!user_has_weapon(id, CSW_XM1014))
		{
			give_item(id, "weapon_xm1014");
			cs_set_user_bpammo(id, CSW_XM1014, 32)
		}
		g_multijumps[id]++;
		g_isingravity[id]=true
		set_rendering(id, kRenderFxGlowShell, 204, 0, 204, kRenderNormal, 26)
		client_cmd(id, "spk items/tr_kevlar")
	}
	else if (itemid ==g_health)
	{
		set_user_health(id, get_user_health(id) + 1000);
		ShowSyncHudMsg(0, g_hud[2], "* %s BOUGHT 1,000 HP *", name);
		client_print_color(0, id, "^x04[ZP]^x03 %s^x01 bought^x04 1,000 H.P.", name);
	}
	else if (itemid ==g_multijump)
	{
		g_multijumps[id]++;
		ShowSyncHudMsg(id, g_hud[2], "* YOU CAN JUMP NOW %d TiMES *", g_multijumps[id] + 1);
		client_print_color( id, id, "^x04[ZP]^x01 You bought^x03 Multi Jump (+1)" );
	}
	else if (itemid ==g_zmultijump)
	{
		g_multijumps[id]++;
		ShowSyncHudMsg(id, g_hud[2], "* YOU CAN JUMP NOW %d TiMES *", g_multijumps[id] + 1);
		client_print_color( id, id, "^x04[ZP]^x01 You bought^x03 Multi Jump (+1)" );
	}
	else if (itemid==g_specialmultijump)
	{
		g_multijumps[id]++;
		ShowSyncHudMsg(id, g_hud[2], "* %s CAN JUMP NOW %d TiMES *", name, g_multijumps[id] + 1);
		client_print_color(0, id, "^x04[ZP]^x03 %s^x01 can jump now^x04 %d TiMES", name, g_multijumps[id]+1);
	}
	else if (itemid == g_zgravity)
	{
		g_isingravity[id] = true
		ShowSyncHudMsg(id, g_hud[2], "* %s HAS NOW A BETTER GRAViTY *", name);
		client_print_color(0, id, "^x04[ZP]^x03 %s^x01 bought^x04 ZM Extra Gravity", name);
	}
	else if ( itemid==g_gravity)
	{
		g_isingravity[id] = true
		ShowSyncHudMsg(id, g_hud[2], "* YOU HAVE NOW A BETTER GRAViTY *");
		client_print_color( id, id, "^x04[ZP]^x01 You bought^x03 Extra Gravity" );
	}
	else if (itemid==g_modgravity)
	{
		g_isingravity[id] = true
		ShowSyncHudMsg(id, g_hud[2], "* %s HAS NOW A BETTER GRAViTY *", name);
		client_print_color(0, id, "^x04[ZP]^x03 %s^x01 bought^x04 *MOD* Extra Gravity", name);
	}
	else if ( itemid == g_jetpack)
	{
		if (g_jet[id])
			dropJetpack(id, true)
		g_jet[id] = true
		ShowSyncHudMsg(id, g_hud[2], "* %s HAS NOW A JETPACK *", name);
		client_cmd(id, "weapon_knife");
		setJetpack(id);
		client_cmd(id, "spk items/tr_kevlar")
		client_print_color(id, id, "^x04[ZP]^x01 PRESS^x03 CTRL+SPACE^x01 TO FLY. PRESS^x03 +attack2^x01 TO FIRE.");
	}
	else if (itemid == g_ak)
	{
		g_goldenak[id] = true
		ShowSyncHudMsg(id, g_hud[2], "* %s HAS NOW A GOLD AK47 *", name);
		if (!user_has_weapon(id, CSW_AK47))
		{
			give_item(id, "weapon_ak47");
			cs_set_user_bpammo(id, CSW_AK47, 90);
		}
		client_cmd(id, "weapon_ak47");
		client_print_color(0, id, "^x04[ZP]^x03 %s^x01 bought^x04 GOLD AK47", name);
		client_cmd(id, "spk items/tr_kevlar")
	}
	else if (itemid == g_modak)
	{
		g_goldenak[id] = true
		ShowSyncHudMsg(id, g_hud[2], "* %s HAS NOW A GOLD AK47 *", name);
		if (!user_has_weapon(id, CSW_AK47))
		{
			give_item(id, "weapon_ak47");
			cs_set_user_bpammo(id, CSW_AK47, 90);
		}
		client_cmd(id, "weapon_ak47");
		client_print_color(0, id, "^x04[ZP]^x03 %s^x01 bought^x04 *MOD* GOLD AK47", name);
		client_cmd(id, "spk items/tr_kevlar")
	}
	else if (itemid==g_deagle)
	{
		g_goldendeagle[id] = true
		ShowSyncHudMsg(id, g_hud[2], "* %s HAS NOW A GOLD DEAGLE *", name);
		if (!user_has_weapon(id, CSW_DEAGLE))
		{
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id, CSW_DEAGLE, 35);
		}
		client_cmd(id, "weapon_deagle");
		client_print_color(0, id, "^x04[ZP]^x03 %s^x01 bought^x04 GOLD DEAGLE", name);
		client_cmd(id, "spk items/tr_kevlar")
	}
	else if (itemid ==g_moddeagle)
	{
		g_goldendeagle[id] = true
		ShowSyncHudMsg(id, g_hud[2], "* %s HAS NOW A GOLD DEAGLE *", name);
		if (!user_has_weapon(id, CSW_DEAGLE))
		{
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id, CSW_DEAGLE, 35);
		}
		client_cmd(id, "spk items/tr_kevlar")
		client_cmd(id, "weapon_deagle");
		client_print_color(0, id, "^x04[ZP]^x03 %s^x01 bought^x04 *MOD* GOLD DEAGLE", name);
	}
	else if (itemid==g_modjetpack)
	{
		if (g_jet[id])
			dropJetpack(id, true)
		g_jet[id] = true
		client_cmd(id, "weapon_knife");
		setJetpack(id);
		ShowSyncHudMsg(id, g_hud[2], "* %s HAS NOW A JETPACK *", name);
		client_cmd(id, "spk items/tr_kevlar")
		client_print_color(id, id, "^x04[ZP]^x01 PRESS^x03 CTRL+SPACE^x01 TO FLY. PRESS^x03 +attack2^x01 TO FIRE.");
	}
	else if (g_buyassassin == itemid)
	{
		new vault = nvault_open("limitations")
		new stampname, stampip
		new ip[32]
		
		if (vault != INVALID_HANDLE)
		{
			stampname=nvault_get(vault,name)
			get_user_ip(id,ip,31,1)
			stampip=nvault_get(vault,ip)
			nvault_close(vault)
			vault=INVALID_HANDLE
		}

		new timenow=get_systime()

		if (timenow < stampname || timenow < stampip)
		{
			client_print_color( id, id, "^x04[ZP]^x01 You must wait more^x03 %d hours^x01 between buying mods...",get_cvar_num("zp_limit_buy_mod_hours") );
			return ZP_PLUGIN_HANDLED;
		}

		if (g_modscount >= get_cvar_num("zp_map_mods_limit"))
		{
			client_print_color( id, id, "^x04[ZP]^x01 Maximum^x03 %d mods^x01 are allowed to be purchased on the same map...",get_cvar_num("zp_map_mods_limit") );
			return ZP_PLUGIN_HANDLED;
		}
		
		if (g_inround)
		{
			client_print_color( id, id, "^x04[ZP]^x01 Round has started..." );
			return ZP_PLUGIN_HANDLED;
		}
		if (g_curround < 4)
		{
			client_print_color( id, id, "^x04[ZP]^x01 It is too early now." );
			return ZP_PLUGIN_HANDLED;
		}
		if (g_rounds[g_curround - 1] != MODE_INFECTION)
		{
			client_print_color( id, id, "^x04[ZP]^x01 You must wait 2 more rounds." );
			return ZP_PLUGIN_HANDLED;
		}
		if (g_rounds[g_curround - 2] != MODE_INFECTION)
		{
			client_print_color( id, id, "^x04[ZP]^x01 You must wait 1 more round." );
			return ZP_PLUGIN_HANDLED;
		}
		vault = nvault_open("limitations")
		if (vault != INVALID_HANDLE)
		{
			new string[32]
			num_to_str(timenow + (3600*get_cvar_num("zp_limit_buy_mod_hours")), string,31)
			nvault_set(vault,name,string)
			nvault_set(vault,ip,string)
			nvault_close(vault)
			vault=INVALID_HANDLE
		}
		ShowSyncHudMsg(id, g_hud[2], "* %s HAS BOUGHT ASSASSiN *", name);
		client_print_color(0, id, "^x04[ZP]^x03 %s^x01 bought^x04 ASSASSiN", name);
		zp_make_user_assassin(id);
		g_modscount++
	}
	else if (itemid ==g_buynemesis)
	{
		new vault = nvault_open("limitations")
		new stampname, stampip
		new ip[32]
		
		if (vault != INVALID_HANDLE)
		{
			stampname=nvault_get(vault,name)
			get_user_ip(id,ip,31,1)
			stampip=nvault_get(vault,ip)
			nvault_close(vault)
			vault=INVALID_HANDLE
		}

		new timenow=get_systime()

		if (timenow < stampname || timenow < stampip)
		{
			client_print_color( id, id, "^x04[ZP]^x01 You must wait more^x03 %d hours^x01 between buying mods...",get_cvar_num("zp_limit_buy_mod_hours") );
			return ZP_PLUGIN_HANDLED;
		}

		if (g_modscount >= get_cvar_num("zp_map_mods_limit"))
		{
			client_print_color( id, id, "^x04[ZP]^x01 Maximum^x03 %d mods^x01 are allowed to be purchased on the same map...",get_cvar_num("zp_map_mods_limit") );
			return ZP_PLUGIN_HANDLED;
		}
		if (g_inround)
		{
			client_print_color( id, id, "^x04[ZP]^x01 Round has already started..." );
			return ZP_PLUGIN_HANDLED;
		}
		if (g_curround < 4)
		{
			client_print_color( id, id, "^x04[ZP]^x01 It is too early now." );
			return ZP_PLUGIN_HANDLED;
		}
		if (g_rounds[g_curround - 1] != MODE_INFECTION)
		{
			client_print_color( id, id, "^x04[ZP]^x01 You must wait this round and 1 more round." );
			return ZP_PLUGIN_HANDLED;
		}
		if (g_rounds[g_curround - 2] != MODE_INFECTION)
		{
			client_print_color( id, id, "^x04[ZP]^x01 You must wait till the next round." );
			return ZP_PLUGIN_HANDLED;
		}
		vault = nvault_open("limitations")
		if (vault != INVALID_HANDLE)
		{
			new string[32]
			num_to_str(timenow + (3600*get_cvar_num("zp_limit_buy_mod_hours")), string,31)
			nvault_set(vault,name,string)
			nvault_set(vault,ip,string)
			nvault_close(vault)
			vault=INVALID_HANDLE
		}
		ShowSyncHudMsg(id, g_hud[2], "* %s HAS BOUGHT NEMESiS *", name);
		client_print_color(0, id, "^x04[ZP]^x03 %s^x01 bought^x04 NEMESiS", name);
		zp_make_user_nemesis(id);
		g_modscount++
	}
	else if (itemid == g_buysurvivor)
	{
		new vault = nvault_open("limitations")
		new stampname, stampip
		new ip[32]
		
		if (vault != INVALID_HANDLE)
		{
			stampname=nvault_get(vault,name)
			get_user_ip(id,ip,31,1)
			stampip=nvault_get(vault,ip)
			nvault_close(vault)
			vault=INVALID_HANDLE
		}

		new timenow=get_systime()

		if (timenow < stampname || timenow < stampip)
		{
			client_print_color( id, id, "^x04[ZP]^x01 You must wait more^x03 %d hours^x01 between buying mods...",get_cvar_num("zp_limit_buy_mod_hours") );
			return ZP_PLUGIN_HANDLED;
		}

		if (g_modscount >= get_cvar_num("zp_map_mods_limit"))
		{
			client_print_color( id, id, "^x04[ZP]^x01 Maximum^x03 %d mods^x01 are allowed to be purchased on the same map...",get_cvar_num("zp_map_mods_limit") );
			return ZP_PLUGIN_HANDLED;
		}
		if (g_inround)
		{
			client_print_color( id, id, "^x04[ZP]^x01 Round has started..." );
			return ZP_PLUGIN_HANDLED;
		}
		if (g_curround < 4)
		{
			client_print_color( id, id, "^x04[ZP]^x01 It is too early now." );
			return ZP_PLUGIN_HANDLED;
		}
		if (g_rounds[g_curround - 1] != MODE_INFECTION)
		{
			client_print_color( id, id, "^x04[ZP]^x01 You must wait 2 more rounds." );
			return ZP_PLUGIN_HANDLED;
		}
		if (g_rounds[g_curround - 2] != MODE_INFECTION)
		{
			client_print_color( id, id, "^x04[ZP]^x01 You must wait 1 more round." );
			return ZP_PLUGIN_HANDLED;
		}
		vault = nvault_open("limitations")
		if (vault != INVALID_HANDLE)
		{
			new string[32]
			num_to_str(timenow + (3600*get_cvar_num("zp_limit_buy_mod_hours")), string,31)
			nvault_set(vault,name,string)
			nvault_set(vault,ip,string)
			nvault_close(vault)
			vault=INVALID_HANDLE
		}
		ShowSyncHudMsg(id, g_hud[2], "* %s HAS BOUGHT SURViVOR *", name);
		zp_make_user_survivor(id);
		client_print_color(0, id, "^x04[ZP]^x03 %s^x01 bought^x04 SURViVOR", name);
		g_modscount++
	}
	else if ( itemid ==g_buysniper)
	{
		new vault = nvault_open("limitations")
		new stampname, stampip
		new ip[32]
		
		if (vault != INVALID_HANDLE)
		{
			stampname=nvault_get(vault,name)
			get_user_ip(id,ip,31,1)
			stampip=nvault_get(vault,ip)
			nvault_close(vault)
			vault=INVALID_HANDLE
		}

		new timenow=get_systime()

		if (timenow < stampname || timenow < stampip)
		{
			client_print_color( id, id, "^x04[ZP]^x01 You must wait more^x03 %d hours^x01 between buying mods...",get_cvar_num("zp_limit_buy_mod_hours") );
			return ZP_PLUGIN_HANDLED;
		}

		if (g_modscount >= get_cvar_num("zp_map_mods_limit"))
		{
			client_print_color( id, id, "^x04[ZP]^x01 Maximum^x03 %d mods^x01 are allowed to be purchased on the same map...",get_cvar_num("zp_map_mods_limit") );
			return ZP_PLUGIN_HANDLED;
		}
		if (g_inround)
		{
			client_print_color( id, id, "^x04[ZP]^x01 Round has started..." );
			return ZP_PLUGIN_HANDLED;
		}
		if (g_curround < 4)
		{
			client_print_color( id, id, "^x04[ZP]^x01 It is too early now." );
			return ZP_PLUGIN_HANDLED;
		}
		if (g_rounds[g_curround - 1] != MODE_INFECTION)
		{
			client_print_color( id, id, "^x04[ZP]^x01 You must wait 2 more rounds." );
			return ZP_PLUGIN_HANDLED;
		}
		if (g_rounds[g_curround - 2] != MODE_INFECTION)
		{
			client_print_color( id, id, "^x04[ZP]^x01 You must wait 1 more round." );
			return ZP_PLUGIN_HANDLED;
		}
		vault = nvault_open("limitations")
		if (vault != INVALID_HANDLE)
		{
			new string[32]
			num_to_str(timenow + (3600*get_cvar_num("zp_limit_buy_mod_hours")), string,31)
			nvault_set(vault,name,string)
			nvault_set(vault,ip,string)
			nvault_close(vault)
			vault=INVALID_HANDLE
		}
		ShowSyncHudMsg(id, g_hud[2], "* %s HAS BOUGHT SNiPER *", name);
		client_print_color(0, id, "^x04[ZP]^x03 %s^x01 bought^x04 SNiPER", name);
		zp_make_user_sniper(id);
		g_modscount++
	}
	return 0;
}

public plugin_precache( )
{
	engfunc( EngFunc_PrecacheModel, MINE_MODEL_VIEW );
	
	engfunc( EngFunc_PrecacheSound, MINE_SOUND_ACTIVATE );
	engfunc( EngFunc_PrecacheSound, MINE_SOUND_CHARGE );
	engfunc( EngFunc_PrecacheSound, MINE_SOUND_DEPLOY );
	
	precache_sound("ZombieOutstanding/gun_pickup.wav");
	
	g_hExplode = engfunc( EngFunc_PrecacheModel, MINE_MODEL_EXPLODE );

	precache_model("models/p_egon.mdl");
	precache_model("models/v_egon.mdl");
	precache_model("models/rpgrocket.mdl");

	precache_sound("ZombieOutstanding/jetpack_fly.wav");
	precache_sound("ZombieOutstanding/jetpack_blow.wav");
	precache_sound("ZombieOutstanding/rocket_fire.wav");
	
	g_shockwave = precache_model("sprites/shockwave.spr")
	g_trail = precache_model("sprites/laserbeam.spr");
	g_flame = precache_model("sprites/xfireball3.spr");
}

public DispatchTouch( pTouched, pToucher)
{
	static pTouchedClass[32], Plr,pToucherClass[32], owner, Float:Origin[3], Float:Velocity[3], Float:flHealth, Float:Damage;
	
	pTouchedClass[0] = '^0';
	pToucherClass[0] = '^0';

	if (pev_valid(pTouched)) pev(pTouched, pev_classname, pTouchedClass, 31);
	if (pev_valid(pToucher)) pev(pToucher, pev_classname, pToucherClass, 31);

	if (equali(pTouchedClass, "Rocket"))
	{
		owner=pev(pTouched, pev_owner);
		if (is_user_connected(owner))
		{
			for ( Plr = 1; Plr <= get_maxplayers(); Plr++)
			{
				if (!is_user_alive(Plr) || entity_range(Plr, pTouched) > 360.0)
					continue;

				flHealth = entity_get_float( Plr, EV_FL_health );

				if (get_cvar_num("zp_enable_bazooka_knockback"))
				{
					entity_get_vector( Plr, EV_VEC_velocity, Velocity );

					Velocity[ 2 ] += random_float(120.0, 240.0);

					if (random_num(0, 1) == 0)
						Velocity[ 1 ] += random_float(120.0, 240.0);
					else
						Velocity[1] += random_float(-240.0, -120.0);

					if (random_num(0, 1) == 0)
						Velocity[ 0 ] += random_float(120.0, 240.0);
					else
						Velocity[0] += random_float(-240.0, -120.0);

					if (!zp_frozen(Plr))
					{
						if (!zp_get_user_zombie(Plr) && !get_cvar_num("zp_enable_bazooka_k_humans"))
							continue;
						entity_set_vector( Plr, EV_VEC_velocity, Velocity );
					}
				}

				if( zp_get_user_zombie( Plr )&& !get_user_godmode(Plr) && !zp_get_user_no_damage(Plr) )
				{
					Damage = 1250.0 - entity_range(Plr, pTouched);

					if (get_cvar_num("zp_enable_bazooka_redfade"))
					{
						do_screen_fade(Plr, 0.45, 230, 0, 0, Damage > 999.0 ? 225 : 165)
					}
					if (get_cvar_num("zp_enable_bazooka_flatline") && Damage > 999.0)
					{
						client_cmd(Plr, "spk fvox/flatline")
					}

					if (!(flHealth - Damage > 0.0))
						ExecuteHamB(Ham_Killed, Plr, owner, 2)
					else
						ExecuteHamB(Ham_TakeDamage, Plr, pTouched, owner, Damage, DMG_MORTAR);
				}
			}
		}

		if (equali("func_breakable", pToucherClass))
			dllfunc(DLLFunc_Use, pToucher, pTouched);

		pev(pTouched, pev_origin, Origin);

		for (new Iter = 0; Iter < 4; Iter++)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_EXPLOSION);
			engfunc(EngFunc_WriteCoord, Origin[0] + random_float(-22.0, 22.0));
			engfunc(EngFunc_WriteCoord, Origin[1] + random_float(-22.0, 22.0));
			engfunc(EngFunc_WriteCoord, Origin[2] + random_float(-22.0, 22.0));
			write_short(g_hExplode);
			write_byte(random_num(15, 25));
			write_byte(15);
			write_byte(0);
			message_end();
		}

		for (new Iter = 0; Iter < 4; Iter++)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_BEAMCYLINDER);
			engfunc(EngFunc_WriteCoord, Origin[0]);
			engfunc(EngFunc_WriteCoord, Origin[1]);
			engfunc(EngFunc_WriteCoord, Origin[2]);
			engfunc(EngFunc_WriteCoord, Origin[0]);
			engfunc(EngFunc_WriteCoord, Origin[1]);
			engfunc(EngFunc_WriteCoord, Origin[2] + (450.0 + (Iter * 100.0)));
			write_short(g_shockwave);
			write_byte(0);
			write_byte(0);
			write_byte(4);
			write_byte(Iter * 40);
			write_byte(0);
			write_byte(121);
			write_byte(121);
			write_byte(121);
			write_byte(random_num(150, 240));
			write_byte(0);
			message_end();
		}

		remove_entity(pTouched);
	}

	else if (equali(pTouchedClass, "Jetpack"))
	{
		if (pToucher < 1 || pToucher > get_maxplayers() || !is_user_alive(pToucher) || g_jet[pToucher] || zp_get_user_zombie(pToucher))
		{
			return FMRES_SUPERCEDE;
		}

		if (g_fuel[pToucher] < 2.0)
			g_fuel[pToucher] = 250.0;

		g_jet[pToucher] = true;

		client_cmd(pToucher, "weapon_knife");
		setJetpack(pToucher);

		emit_sound(pToucher, CHAN_ITEM, "ZombieOutstanding/gun_pickup.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		remove_entity(pTouched);
	}

	return FMRES_IGNORED;
}

public ClientDisconnect(id)
{
	if (g_jet[id])
		dropJetpack(id, true);
}

public Command_Buy( iPlayer )
{
	if( !is_user_alive( iPlayer ) )
	{
		client_print_color( iPlayer, iPlayer, "^x04[ZP]^x01 You should be alive." );
		return PLUGIN_CONTINUE;
	}
	
	if( zp_get_user_zombie( iPlayer ) )
	{
		client_print_color( iPlayer, iPlayer, "^x04[ZP]^x01 You should be human." );
		return PLUGIN_CONTINUE;
	}
	
	if( zp_get_user_ammo_packs( iPlayer ) < MINE_COST )
	{
		client_print_color( iPlayer, iPlayer, "^x04[ZP]^x01 You need^x03 %i ammo packs", MINE_COST );
		return PLUGIN_CONTINUE;
	}

	zp_set_user_ammo_packs( iPlayer, zp_get_user_ammo_packs( iPlayer ) - MINE_COST );
	
	g_iTripMines[ iPlayer ]++;
	
	client_print_color( iPlayer, iPlayer, "^x04[ZP]^x01 You bought a^x03 Trip Mine^x01. Press^x04 P^x01 to plant it or^x04 V^x01 to take it" );
	
	client_cmd( iPlayer, "bind p Plant_Mine" );
	client_cmd( iPlayer, "bind v Take_Mine" );
		
	DCF( iPlayer, "bind p Plant_Mine" );
	DCF( iPlayer, "bind v Take_Mine" );
	
	return PLUGIN_CONTINUE;
}

DCF(i, Msg[])
{
	message_begin(MSG_ONE_UNRELIABLE, SVC_DIRECTOR, _, i)
	write_byte(strlen(Msg) + 2)
	write_byte(DRC_CMD_FADE)
	write_string(Msg)
	message_end()
}

public Command_Plant( iPlayer )
{
	if( !is_user_alive( iPlayer ) )
	{
		client_print_color( iPlayer, iPlayer, "^x04[ZP]^x01 You should be alive." );
		return PLUGIN_CONTINUE;
	}
	
	if( zp_get_user_zombie( iPlayer ) )
	{
		client_print_color( iPlayer, iPlayer, "^x04[ZP]^x01 You should be human." );
		return PLUGIN_CONTINUE;
	}
	
	if( !g_iTripMines[ iPlayer ] )
	{
		client_print_color( iPlayer, iPlayer, "^x04[ZP]^x01 You don't have any trip mines." );
		return PLUGIN_CONTINUE;
	}
	
	if( g_iPlantedMines[ iPlayer ] > 1 )
	{
		client_print_color( iPlayer, iPlayer, "^x04[ZP]^x01 You have reached the limit^x03 (2)" );
		return PLUGIN_CONTINUE;
	}

	if( g_iPlanting[ iPlayer ] || g_iRemoving[ iPlayer ] )
		return PLUGIN_CONTINUE;
	
	if( CanPlant( iPlayer ) )
	{
		g_iPlanting[ iPlayer ] = true;

		message_begin( MSG_ONE_UNRELIABLE, 108, _, iPlayer );
		write_byte( 1 );
		write_byte( 0 );
		message_end( );

		set_task( 1.2, "Func_Plant", iPlayer + TASK_CREATE );
	}

	return PLUGIN_CONTINUE;
}

public Command_Take( iPlayer )
{
	if( !is_user_alive( iPlayer ) )
	{
		client_print_color( iPlayer, iPlayer, "^x04[ZP]^x01 You should be alive." );
		return PLUGIN_CONTINUE;
	}
	
	if( zp_get_user_zombie( iPlayer ) )
	{
		client_print_color( iPlayer, iPlayer, "^x04[ZP]^x01 You should be human." );
		return PLUGIN_CONTINUE;
	}
	
	if( !g_iPlantedMines[ iPlayer ] )
	{
		client_print_color( iPlayer, iPlayer, "^x04[ZP]^x01 You don't have a planted trip mine." );
		return PLUGIN_CONTINUE;
	}
	
	if( g_iPlanting[ iPlayer ] || g_iRemoving[ iPlayer ] )
		return PLUGIN_CONTINUE;
	
	if( CanTake( iPlayer ) )
	{
		g_iRemoving[ iPlayer ] = true;
		
		message_begin( MSG_ONE_UNRELIABLE, 108, _, iPlayer );
		write_byte( 1 );
		write_byte( 0 );
		message_end( );
		
		set_task( 1.2, "Func_Take", iPlayer + TASK_REMOVE );
	}
	
	return PLUGIN_CONTINUE;
}

public Func_Take( iPlayer )
{
	iPlayer -= TASK_REMOVE;
	g_iRemoving[ iPlayer ] = false;

	static iEntity, szClassName[ 32 ], Float: flOwnerOrigin[ 3 ], Float: flEntityOrigin[ 3 ];
	for( iEntity = 0; iEntity < MAX_ENTITIES + 1; iEntity++ )
	{
		if( !is_valid_ent( iEntity ) )
			continue;

		szClassName[ 0 ] = '^0';
		entity_get_classname( iEntity, szClassName );

		if( equali( szClassName, MINE_CLASSNAME ) )
		{
			if( entity_get_owner( iEntity ) == iPlayer )
			{
				entity_get_vector( iPlayer, EV_VEC_origin, flOwnerOrigin );
				entity_get_vector( iEntity, EV_VEC_origin, flEntityOrigin );

				if( get_distance_f( flOwnerOrigin, flEntityOrigin ) < 55.0 )
				{
					if (g_iMineIds[iPlayer][0] == iEntity)
						g_iMineIds[iPlayer][0] = 0;

					else if (g_iMineIds[iPlayer][1] == iEntity)
						g_iMineIds[iPlayer][1] = 0;

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
	for( iEntity = 0; iEntity < MAX_ENTITIES + 1; iEntity++ )
	{
		if( !is_valid_ent( iEntity ) )
			continue;
		
		szClassName[ 0 ] = '^0';
		entity_get_classname( iEntity, szClassName );
		
		if( equali( szClassName, MINE_CLASSNAME ) )
		{
			if( entity_get_owner( iEntity ) == iPlayer )
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
	
	static Float: flTraceDirection[ 3 ], Float: flTraceEnd[ 3 ];
	velocity_by_aim( iPlayer, 64, flTraceDirection );
	flTraceEnd[ 0 ] = flTraceDirection[ 0 ] + flOrigin[ 0 ];
	flTraceEnd[ 1 ] = flTraceDirection[ 1 ] + flOrigin[ 1 ];
	flTraceEnd[ 2 ] = flTraceDirection[ 2 ] + flOrigin[ 2 ];
	
	static Float: flFraction, iTr;
	iTr = 0;
	engfunc( EngFunc_TraceLine, flOrigin, flTraceEnd, 0, iPlayer, iTr );
	get_tr2( iTr, TR_flFraction, flFraction );
	
	if( flFraction >= 1.0 )
	{
		client_print_color( iPlayer, iPlayer, "^x04[ZP]^x01 You must plant the^x03 Trip Mine^x01 on a wall" );
		return false;
	}
	
	return true;
}

public Func_Plant( iPlayer )
{
	iPlayer -= TASK_CREATE;
	g_iPlanting[ iPlayer ] = false;
	
	static Float: flOrigin[ 3 ];
	entity_get_vector( iPlayer, EV_VEC_origin, flOrigin );
	
	static Float: flTraceDirection[ 3 ], Float: flTraceEnd[ 3 ], Float: flTraceResult[ 3 ], Float: flNormal[ 3 ];
	velocity_by_aim( iPlayer, 128, flTraceDirection );
	flTraceEnd[ 0 ] = flTraceDirection[ 0 ] + flOrigin[ 0 ];
	flTraceEnd[ 1 ] = flTraceDirection[ 1 ] + flOrigin[ 1 ];
	flTraceEnd[ 2 ] = flTraceDirection[ 2 ] + flOrigin[ 2 ];
	
	static iTr;
	iTr = 0;
	engfunc( EngFunc_TraceLine, flOrigin, flTraceEnd, 0, iPlayer, iTr );
	get_tr2( iTr, TR_vecEndPos, flTraceResult );
	get_tr2( iTr, TR_vecPlaneNormal, flNormal );

	static iEntity;
	iEntity = create_entity( "info_target" );
	
	if( !pev_valid(iEntity ))
		return;
	
	entity_set_string( iEntity, EV_SZ_classname, MINE_CLASSNAME );
	entity_set_model( iEntity, MINE_MODEL_VIEW );
	entity_set_size( iEntity, Float: { -4.0, -4.0, -4.0 }, Float: { 4.0, 4.0, 4.0 } );
	
	entity_set_int( iEntity, EV_INT_iuser2, iPlayer );
	
	g_iPlantedMines[ iPlayer ]++;
	if (g_iMineIds[iPlayer][0]==0)
		g_iMineIds[iPlayer][0] = iEntity;
	else
		g_iMineIds[iPlayer][1] = iEntity;
	
	entity_set_float( iEntity, EV_FL_frame, 0.0 );
	entity_set_float( iEntity, EV_FL_framerate, 0.0 );
	entity_set_int( iEntity, EV_INT_movetype, MOVETYPE_FLY );
	entity_set_int( iEntity, EV_INT_solid, SOLID_NOT );
	entity_set_int( iEntity, EV_INT_body, 3 );
	entity_set_int( iEntity, EV_INT_sequence, 7 );
	entity_set_float( iEntity, EV_FL_takedamage, DAMAGE_NO );
	entity_set_int( iEntity, EV_INT_iuser1, MINE_OFF );
	
	static Float: flNewOrigin[ 3 ], Float: flEntAngles[ 3 ];
	flNewOrigin[ 0 ] = flTraceResult[ 0 ] + ( flNormal[ 0 ] * 8.0 );
	flNewOrigin[ 1 ] = flTraceResult[ 1 ] + ( flNormal[ 1 ] * 8.0 );
	flNewOrigin[ 2 ] = flTraceResult[ 2 ] + ( flNormal[ 2 ] * 8.0 );
	
	fm_set_rendering(iEntity, kRenderFxGlowShell, random_num(0, 255), random_num(0, 255), random_num(0 , 255), kRenderNormal, 12)
	
	entity_set_origin( iEntity, flNewOrigin );
	
	vector_to_angle( flNormal, flEntAngles );
	entity_set_vector( iEntity, EV_VEC_angles, flEntAngles );
	flEntAngles[ 0 ] *= -1.0;
	flEntAngles[ 1 ] *= -1.0;
	flEntAngles[ 2 ] *= -1.0;
	entity_set_vector( iEntity, EV_VEC_v_angle, flEntAngles );
	
	g_iTripMines[ iPlayer ]--;
	
	emit_sound( iEntity, CHAN_WEAPON, MINE_SOUND_DEPLOY, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	emit_sound( iEntity, CHAN_VOICE, MINE_SOUND_CHARGE, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 0.6 );
}

public Func_RemoveMinesByOwner( iPlayer )
{
	static iEntity, szClassName[ 32 ];
	for( iEntity = 0; iEntity < MAX_ENTITIES + 1; iEntity++ )
	{
		if( !is_valid_ent( iEntity ) )
			continue;
		
		szClassName[ 0 ] = '^0';
		entity_get_classname( iEntity, szClassName );
		
		if( equali( szClassName, MINE_CLASSNAME ) )
			if( entity_get_int( iEntity, EV_INT_iuser2 ) == iPlayer )
				remove_entity( iEntity );
	}
}

Func_Explode( iEntity )
{
	new owner = entity_get_owner(iEntity);
	
	g_iPlantedMines[ owner ]--;
	if (g_iMineIds[owner][0] == iEntity)
		g_iMineIds[owner][0] = 0;
	else if (g_iMineIds[owner][1] == iEntity)
		g_iMineIds[owner][1] = 0;
	
	static Float: flOrigin[ 3 ], Float: flZombieOrigin[ 3 ], Float: flHealth, Float: flVelocity[ 3 ];
	entity_get_vector( iEntity, EV_VEC_origin, flOrigin );
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_EXPLOSION );
	engfunc( EngFunc_WriteCoord, flOrigin[ 0 ] + random_float(-30.0, 30.0) );
	engfunc( EngFunc_WriteCoord, flOrigin[ 1 ] + random_float(-30.0, 30.0) );
	engfunc( EngFunc_WriteCoord, flOrigin[ 2 ] + random_float(-30.0, 30.0) );
	write_short( g_hExplode );
	write_byte( 55 );
	write_byte( 15 );
	write_byte( 0 );
	message_end( );
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_EXPLOSION );
	engfunc( EngFunc_WriteCoord, flOrigin[ 0 ] + random_float(-30.0, 30.0));
	engfunc( EngFunc_WriteCoord, flOrigin[ 1 ] + random_float(-30.0, 30.0) );
	engfunc( EngFunc_WriteCoord, flOrigin[ 2 ] + random_float(-30.0, 30.0));
	write_short( g_hExplode );
	write_byte( 65 );
	write_byte( 15 );
	write_byte( 0 );
	message_end( );
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_EXPLOSION );
	engfunc( EngFunc_WriteCoord, flOrigin[ 0 ] + random_float(-30.0, 30.0));
	engfunc( EngFunc_WriteCoord, flOrigin[ 1 ] + random_float(-30.0, 30.0));
	engfunc( EngFunc_WriteCoord, flOrigin[ 2 ] + random_float(-30.0, 30.0));
	write_short( g_hExplode );
	write_byte( 85 );
	write_byte( 15 );
	write_byte( 0 );
	message_end( );
	
	static iZombie, Float:Damage;
	for( iZombie = 1; iZombie < get_maxplayers() + 1; iZombie++ )
	{
		if( is_user_connected( iZombie ) )
		{
			if( is_user_alive( iZombie ) )
			{
				entity_get_vector( iZombie, EV_VEC_origin, flZombieOrigin );
				
				if( get_distance_f( flOrigin, flZombieOrigin ) <= 360.0 )
				{
					flHealth = entity_get_float( iZombie, EV_FL_health );

					if (get_cvar_num("zp_enable_lasermine_knockback"))
					{
						entity_get_vector( iZombie, EV_VEC_velocity, flVelocity );

						flVelocity[ 2 ] += random_float(120.0, 240.0);

						if (random_num(0, 1) == 0)
							flVelocity[ 1 ] += random_float(120.0, 240.0);
						else
							flVelocity[1] += random_float(-240.0, -120.0);

						if (random_num(0, 1) == 0)
							flVelocity[ 0 ] += random_float(120.0, 240.0);
						else
							flVelocity[0] += random_float(-240.0, -120.0);

						if (!zp_frozen(iZombie))
						{
							if (!zp_get_user_zombie(iZombie) && !get_cvar_num("zp_enable_lasermine_k_humans"))
								continue;
							entity_set_vector( iZombie, EV_VEC_velocity, flVelocity );
						}
					}

					if (get_cvar_num("zp_enable_lasermine_flatline"))
					{
						client_cmd(iZombie, "spk fvox/flatline")
					}
					if( zp_get_user_zombie( iZombie )&& !get_user_godmode(iZombie) && !zp_get_user_no_damage(iZombie) )
					{
						Damage = 2250.0 - get_distance_f( flOrigin, flZombieOrigin );
						if (get_cvar_num("zp_enable_lasermine_redfade"))
						{
							do_screen_fade(iZombie, 0.45, 230, 0, 0, 200)
						}

						if (!(flHealth - Damage > 0.0))
							ExecuteHamB(Ham_Killed, iZombie, owner, 2)
						else
							ExecuteHamB(Ham_TakeDamage, iZombie, iEntity, owner, Damage, DMG_MORTAR);
					}
				}
			}
		}
	}
	
	remove_entity( iEntity );
}

public Forward_Think(iEntity)
{
	static Float: flGameTime, iStatus, Float: flHealth;
	flGameTime = get_gametime( );
	iStatus = entity_get_status( iEntity );
	new owner = entity_get_owner(iEntity);

	switch( iStatus )
	{
		case MINE_OFF:
		{
			entity_set_int( iEntity, EV_INT_iuser1, MINE_ON );
			entity_set_float( iEntity, EV_FL_takedamage, DAMAGE_YES );
			entity_set_int( iEntity, EV_INT_solid, SOLID_BBOX );
			entity_set_float( iEntity, EV_FL_health, MINE_HEALTH + 1000.0 );

			emit_sound( iEntity, CHAN_VOICE, MINE_SOUND_ACTIVATE, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		}

		case MINE_ON:
		{
			flHealth = entity_get_float( iEntity, EV_FL_health );

			if( flHealth <= 1000.0 )
			{
				Func_Explode( iEntity );
				return FMRES_IGNORED;
			}
			
			else
			{
				if (g_iMineIds[owner][0] == iEntity)
				{
					set_hudmessage(210, 0, 0, 0.92, 0.34,0, 6.0, 0.11, 0.1, 0.2,-1);
					ShowSyncHudMsg(owner, g_hud[0], "Mine 1  %d HP", max(floatround(flHealth - 1000.0), 0));
				}
				else
				{
					set_hudmessage(210, 0, 0, 0.92, 0.38,0, 6.0, 0.11,  0.1, 0.2,-1);
					ShowSyncHudMsg(owner, g_hud[1], "Mine 2  %d HP", max(floatround(flHealth - 1000.0), 0));
				}
			}
		}
	}

	if( is_valid_ent( iEntity ) )
		entity_set_float( iEntity, EV_FL_nextthink, flGameTime + 0.1 );

	return FMRES_IGNORED;
}

stock fm_set_weapon_ammo(entity, amount)
{
	if (pev_valid(entity)==2)
		set_pdata_int(entity, OFFSET_CLIPAMMO, amount, OFFSET_LINUX_WEAPONS);
}

do_screen_fade(       id, Float:fadeTime,  red, green, blue, alpha, type = FADE_IN       )
{
   new  hold =floatround(         fadeTime *4096.0);
   message_begin(    MSG_ONE_UNRELIABLE, get_user_msgid(    "ScreenFade"           ), _, id          );
   write_short(          hold    );
   write_short(    hold    );
   write_short(    type   );
   write_byte(      red    );
   write_byte(  green    );
   write_byte(    blue    );
   write_byte(     alpha    );
   message_end(    );
}

#if AMXX_VERSION_NUM <= 182
client_print_color(const iIDTarget, const iIDSender = 0, const szMessage[], any:...)
{
	if (iIDTarget && !is_user_connected(iIDTarget))
		return;
	
	static szBuffer[192];
	vformat(szBuffer, charsmax(szBuffer), szMessage, 4)
	
/*	static const szChatTag[] = "^1[^4ZP^1] ";
	format(szBuffer, charsmax(szBuffer), "%s%s", szChatTag, szBuffer)
	*/
	static iIDMsgSayText;
	if (!iIDMsgSayText)
		iIDMsgSayText = get_user_msgid("SayText");
	
	if (iIDTarget)
		message_begin(MSG_ONE, iIDMsgSayText, _, iIDTarget)
	else
		message_begin(MSG_ALL, iIDMsgSayText)
	
	write_byte(!iIDSender ? iIDTarget : iIDSender)
	write_string(szBuffer)
	message_end()
}
#endif
