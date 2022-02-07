#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>
#include <cstrike>

forward OnRoundStart(gamemode, id)
native IsTerminator(id)

#define ENG_NULLENT			-1
#define EV_INT_WEAPONKEY		EV_INT_impulse
#define ethereal_WEAPONKEY 		666
#define MAX_PLAYERS  			32
#define IsValidUser(%1) 		(1 <= %1 <= g_MaxPlayers)
#define m_flNextSecondaryAttack 	47

const USE_STOPPED = 0
const OFFSET_ACTIVE_ITEM = 373
const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX = 5
const OFFSET_LINUX_WEAPONS = 4

#define write_coord_f(%1)		engfunc(EngFunc_WriteCoord,%1)
#define WEAP_LINUX_XTRA_OFF		4
#define m_fKnown			44
#define m_flNextPrimaryAttack 		46
#define m_flTimeWeaponIdle		48
#define m_iClip				51
#define m_fInReload			54
#define PLAYER_LINUX_XTRA_OFF		5
#define m_flNextAttack			83

#define ethereal_RELOAD_TIME 	3.0
#define ethereal_RELOAD		1
#define ethereal_DRAW		2
#define ethereal_SHOOT1		3
#define ethereal_SHOOT2		4

#define deathMSG		//Death Message
#define Icon			//Left Icon
#define ZombiePlague
#if defined Icon
	new g_Msg_StatusIcon
#endif

/*Laser Ethereal Mode: Color Settings */
//Laser Ethereal Icon Colors
#define l_ethereal_i_r		0	//R
#define l_ethereal_i_g		0	//G
#define l_ethereal_i_b		200	//B
//Laser Ethereal Line Colors
#define l_ethereal_l_r		0	//R
#define l_ethereal_l_g		0	//G
#define l_ethereal_l_b		200	//B



/* Ethereal Electro Mode Settings */
//Electro Ethereal Icon Colors
#define e_ethereal_i_r		0	//R
#define e_ethereal_i_g		200	//G
#define e_ethereal_i_b		200	//B

//Electro Ethereal Line Colors
#define e_ethereal_l_r		0	//R
#define e_ethereal_l_g		200	//G
#define e_ethereal_l_b		200	//B

//Electro Ethereal Line Size
#define e_ethereal_ls_min	0	//Min size
#define e_ethereal_ls_max	30	//Max size

//	On\Off
//#define electro_fire_hole	//Electro Hole Effect
//#define electro_fire_smoke	//Electro Smode Effect


#define get_bit(%1,%2)		(%1 & (1 << (%2 & 31)))
#define set_bit(%1,%2)		%1 |= (1 << (%2 & 31))
#define reset_bit(%1,%2)	%1 &= ~(1 << (%2 & 31))

new g_bitsMuzzleFlash;

new g_iEntity;

new const Laser_Sounds[] = { "weapons/ethereal_shoot1.wav" }	//Laser mode fire sound
new const Electro_Sounds[]= { "weapons/ethereal_shoot1.wav" }	//Electro mode fire sound

new ethereal_V_MODEL[64] = "models/v_ethereal_shus.mdl"		//v_model
new ethereal_P_MODEL[64] = "models/p_ethereal.mdl"	//p_model
new ethereal_W_MODEL[64] = "models/w_ethereal.mdl"	//w_model


new cvar_dmg_ethereal_laser, cvar_spd_ethereal_laser,cvar_recoil_ethereal_laser
new cvar_dmg_ethereal_electro, cvar_spd_ethereal_electro,cvar_recoil_ethereal_electro

new g_itemid_ethereal, cvar_clip_ethereal, cvar_ethereal_ammo
new g_MaxPlayers, g_orig_event_ethereal, g_IsInPrimaryAttack
new Float:cl_pushangle[MAX_PLAYERS + 1][3], m_iBlood[2]
new g_has_ethereal[33], g_clip_ammo[33], g_ethereal_TmpClip[33], oldweap[33]
new gmsgWeaponList
new g_SmokePuff_SprId
static wSprite
const UNIT_SECOND = (1 << 12)
new eth_mode[33]
new ethereal_changemode[33]
new ethereal_reloaded[33]
const PRIMARY_WEAPONS_BIT_SUM = 
(1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<
CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
			"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
			"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
			"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
			"weapon_ak47", "weapon_knife", "weapon_p90" }

public plugin_init()
{
	register_plugin("[WPN] Ethereal", "1.0", "Chrescoe1")
	/*
	 *Crock / =) (Poprogun4ik) / LARS-DAY[BR]EAKER - Authors Original Code "Scar Basic Edition"
	 *Dias - Thank's for Smoke and bullet hole from Balrog 3
	 *Alexander.3 - Thank's for LineTraceAttack from zl_Ethereal
	 *WPMG Team - Thank's for Muzzle
	 *Extra : Ethereal (by Shurik)  - Weapon model and resource
	 *Chrescoe1 - Changed "Scar Basic Edition" and use all code to create "Ethereal dual-mode"
	*/
	#if defined Icon
		g_Msg_StatusIcon = get_user_msgid("StatusIcon")
	#endif
	#if defined deathMSG
		register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
	#endif
	
	register_event("CurWeapon","CurrentWeapon","be","1=1")
	
	RegisterHam(Ham_Item_AddToPlayer, "weapon_aug", "fw_ethereal_AddToPlayer")
	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary_Post", 1)
	
	for (new i = 1; i < sizeof WEAPONENTNAMES; i++)
	
	if (WEAPONENTNAMES[i][0]) 
		RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "fw_Item_Deploy_Post", 1)
	
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_aug", "fw_ethereal_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_aug", "fw_ethereal_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Item_PostFrame, "weapon_aug", "ethereal_ItemPostFrame")
	RegisterHam(Ham_Weapon_Reload, "weapon_aug", "ethereal_Reload")
	RegisterHam(Ham_Weapon_Reload, "weapon_aug", "ethereal_Reload_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
	
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_wall", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_door", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_plat", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_rotating", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack", 1)
	
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_AddToFullPack, "CPlayer__AddToFullPack_post", 1);	
	register_forward(FM_CheckVisibility, "CEntity__CheckVisibility");
	register_forward(FM_PrecacheEvent, "fwPrecacheEvent_Post", 1)
	
	//Laser Mode Config
	cvar_dmg_ethereal_laser = register_cvar("eth_laser_dmg", "1.24")			//Damage - 1.64 - 164% from original weapon
	cvar_spd_ethereal_laser = register_cvar("eth_laser_attack_spd", "1.24")		//Attack Speed - 1.24 - 124% from original weapon
	cvar_recoil_ethereal_laser = register_cvar("eth_laser_recoil", "0.03")		//Recoil - 0.03 - 3% from original weapon
	
	//Electro Mode Config
	cvar_dmg_ethereal_electro = register_cvar("eth_electro_dmg", "0.87")		//Damage - 0,87 - 87% from original weapon
	cvar_spd_ethereal_electro = register_cvar("eth_electro_attack_spd", "0.25")	//Attack Speed - 0.25 - 25% from original weapon
	cvar_recoil_ethereal_electro = register_cvar("eth_laser_recoil", "0.17")		//Recoil - 0.17 - 17% from original weapon

	cvar_clip_ethereal= register_cvar("ethereal_clip", "50")				//Max Clip
	cvar_ethereal_ammo = register_cvar("ethereal_ammo", "250")			//Max Ammo
	
	register_clcmd("say /ethereal","zp_extra_item_selected")
	//g_itemid_ethereal = zp_register_extra_item("\rEthereal", 15, ZP_TEAM_HUMAN)
	
	g_MaxPlayers = get_maxplayers()
	gmsgWeaponList = get_user_msgid("WeaponList")
}

public plugin_precache()
{
	precache_model(ethereal_V_MODEL)
	precache_model(ethereal_P_MODEL)
	precache_model(ethereal_W_MODEL)
	
	precache_sound(Laser_Sounds)	
	precache_sound(Electro_Sounds)
	precache_sound("weapons/ethereal_reload.wav")
	precache_sound("weapons/ethereal_draw.wav")
	
	m_iBlood[0] = precache_model("sprites/blood.spr")
	m_iBlood[1] = precache_model("sprites/bloodspray.spr")
	
	precache_generic("sprites/weapon_ethereal_sh.txt")
	precache_generic("sprites/sh/640hud74.spr")
	precache_generic("sprites/sh/640hud7x.spr")
	precache_model("sprites/muzzleflash7.spr")
	
	g_SmokePuff_SprId = engfunc(EngFunc_PrecacheModel, "sprites/wall_puff1.spr")
	wSprite = precache_model("sprites/laserbeam.spr")	//Laser Sprite
	
	g_iEntity = create_entity("info_target")
	entity_set_model(g_iEntity, "sprites/muzzleflash7.spr")
	entity_set_float(g_iEntity, EV_FL_scale, 0.2)
	
	entity_set_int(g_iEntity, EV_INT_rendermode, kRenderTransTexture)
	entity_set_float(g_iEntity, EV_FL_renderamt, 0.0)
	
	register_clcmd("wpn_ethereal3", "weapon_hook")	
}

public OnRoundStart()
{
    for (new id = 1; id <= get_maxplayers(); id++)
    {
        if (IsTerminator(id))
        set_task(1.0, "task_give", id+45634)
    }
}

public task_give(id)
{
    id -= 45634
    if (IsTerminator(id) && is_user_alive(id))
    {
		give_ethereal(id)
		ethereal_changemode[id]=0
		ethereal_reloaded[id]=0
		client_print(id, print_center, "*** You got an Ethereal, enjoy killing the zombies ***")
    }
}  

public fw_PlayerKilled(victim)
{
	g_has_ethereal[victim] = false
}

public client_disconnect(id)
{
	g_has_ethereal[id] = false
}

public event_round_start()
{
	new id
	for (id = 1; id <= get_maxplayers(); id++)
	{
		g_has_ethereal[id] = false
	}
}

public weapon_hook(id)
{
    	engclient_cmd(id, "weapon_aug")
    	return PLUGIN_HANDLED
}
public fw_TraceAttack(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType, Float:fVec1[3], Float:fVec2[3])
{
	if(!is_user_alive(iAttacker))
		return

	new g_currentweapon = get_user_weapon(iAttacker)

	if(g_currentweapon != CSW_AUG) 
		return
	
	if(!g_has_ethereal[iAttacker]) 
		return

	static Float:flEnd[3]
	get_tr2(ptr, TR_vecEndPos, flEnd)
	
	if(!is_user_alive(iEnt))
	{
		if(eth_mode[iAttacker]==1)
		{
			Make_BulletHole(iAttacker, flEnd,flDamage)
			Make_BulletSmoke(iAttacker, ptr)
			emit_sound(iAttacker, CHAN_WEAPON, Laser_Sounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			LaserBeam(iAttacker, flEnd,1, 2,l_ethereal_l_r,l_ethereal_l_g,l_ethereal_l_b,1,1)
		}
		else
		{
			#if defined electro_fire_hole
				Make_BulletHole(iAttacker, flEnd,flDamage)
			#endif
			
			#if defined electro_fire_smoke
				Make_BulletSmoke(iAttacker, ptr)
			#endif
			LaserBeam(iAttacker,flEnd, 1, 2,e_ethereal_l_r,e_ethereal_l_g,e_ethereal_l_b,e_ethereal_ls_min,e_ethereal_ls_max)
			emit_sound(iAttacker, CHAN_WEAPON, Electro_Sounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
	}
}
public  LaserBeam(id, Float: Origin[3],Time, Size,red,green,blue,randmin,randmax) 
{
	if(get_user_weapon(id) == CSW_AUG && g_has_ethereal[id])
	{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte (TE_BEAMENTPOINT)
	write_short(id | 0x1000)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_short(wSprite)
	write_byte(1)
	write_byte(5)
	write_byte(Time)
	write_byte(Size)
	write_byte(random_num(randmin,randmax))
	write_byte(red)
	write_byte(green)
	write_byte(blue)
	write_byte(200)
	write_byte(200)
	message_end()
	}
}
public Make_BulletSmoke(id, TrResult)
{
	
	static Float:vecSrc[3], Float:vecEnd[3], TE_FLAG
	get_weapon_attachment(id, vecSrc)
	global_get(glb_v_forward, vecEnd)
    
	xs_vec_mul_scalar(vecEnd, 8192.0, vecEnd)
	xs_vec_add(vecSrc, vecEnd, vecEnd)

	get_tr2(TrResult, TR_vecEndPos, vecSrc)
	get_tr2(TrResult, TR_vecPlaneNormal, vecEnd)
    
	xs_vec_mul_scalar(vecEnd, 2.5, vecEnd)
	xs_vec_add(vecSrc, vecEnd, vecEnd)
    
	TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
	TE_FLAG |= TE_EXPLFLAG_NOSOUND
	TE_FLAG |= TE_EXPLFLAG_NOPARTICLES
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecEnd, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, vecEnd[0])
	engfunc(EngFunc_WriteCoord, vecEnd[1])
	engfunc(EngFunc_WriteCoord, vecEnd[2] - 10.0)
	write_short(g_SmokePuff_SprId)
	write_byte(2)
	write_byte(50)
	write_byte(TE_FLAG)
	message_end()
}

stock Make_BulletHole(id, Float:Origin[3], Float:Damage)
{
	// Find target
	static Decal; Decal = random_num(41, 45)
	static LoopTime; 
	
	if(Damage > 100.0) LoopTime = 2
	else LoopTime = 1
	
	for(new i = 0; i < LoopTime; i++)
	{
		// Put decal on "world" (a wall)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		engfunc(EngFunc_WriteCoord, Origin[0])
		engfunc(EngFunc_WriteCoord, Origin[1])
		engfunc(EngFunc_WriteCoord, Origin[2])
		write_byte(Decal)
		message_end()
		
		// Show sparcles
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)
		engfunc(EngFunc_WriteCoord, Origin[0])
		engfunc(EngFunc_WriteCoord, Origin[1])
		engfunc(EngFunc_WriteCoord, Origin[2])
		write_short(id)
		write_byte(Decal)
		message_end()
	}
}
stock get_weapon_attachment(id, Float:output[3], Float:fDis = 40.0)
{ 
	new Float:vfEnd[3], viEnd[3] 
	get_user_origin(id, viEnd, 3)  
	IVecFVec(viEnd, vfEnd) 
	
	new Float:fOrigin[3], Float:fAngle[3]
	
	pev(id, pev_origin, fOrigin) 
	pev(id, pev_view_ofs, fAngle)
	
	xs_vec_add(fOrigin, fAngle, fOrigin) 
	
	new Float:fAttack[3]
	
	xs_vec_sub(vfEnd, fOrigin, fAttack)
	xs_vec_sub(vfEnd, fOrigin, fAttack) 
	
	new Float:fRate
	
	fRate = fDis / vector_length(fAttack)
	xs_vec_mul_scalar(fAttack, fRate, fAttack)
	
	xs_vec_add(fOrigin, fAttack, output)
}
public plugin_natives ()
{
	register_native("give_ethereal_wpn", "native_give_weapon_add", 1)
}
public native_give_weapon_add(id)
{
	give_ethereal(id)
}

public fwPrecacheEvent_Post(type, const name[])
{
	if (equal("events/aug.sc", name))
	{
		g_orig_event_ethereal = get_orig_retval()
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}

public client_connect(id)
{
	g_has_ethereal[id] = false
}

public fw_SetModel(entity, model[])
{
	if(!is_valid_ent(entity))
		return FMRES_IGNORED
	
	static szClassName[33]
	entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName))
		
	if(!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED
	
	static iOwner
	
	iOwner = entity_get_edict(entity, EV_ENT_owner)
	
	if(equal(model, "models/w_aug.mdl"))
	{
		static iStoredAugID
		
		iStoredAugID = find_ent_by_owner(ENG_NULLENT, "weapon_aug", entity)
	
		if(!is_valid_ent(iStoredAugID))
			return FMRES_IGNORED
	
		if(g_has_ethereal[iOwner])
		{
			entity_set_int(iStoredAugID, EV_INT_WEAPONKEY, ethereal_WEAPONKEY)
			
			g_has_ethereal[iOwner] = false
			
			entity_set_model(entity, ethereal_W_MODEL)
			
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

public give_ethereal(id)
{
	drop_weapons(id, 1)
	new iWep2 = give_item(id,"weapon_aug")
	if( iWep2 > 0 )
	{
		cs_set_weapon_ammo(iWep2, get_pcvar_num(cvar_clip_ethereal))
		cs_set_user_bpammo (id, CSW_AUG, get_pcvar_num(cvar_ethereal_ammo))	
		UTIL_PlayWeaponAnimation(id, ethereal_DRAW)
		set_pdata_float(id, m_flNextAttack, 1.0, PLAYER_LINUX_XTRA_OFF)
		
		message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
		write_string("weapon_ethereal_sh")
		write_byte(4)
		write_byte(90)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(17)
		write_byte(CSW_AUG)
		message_end()
	}
	g_has_ethereal[id] = true
	
	eth_mode[id]=1
	set_task(0.1,"clockdown",id)
}
public zp_extra_item_selected(id, itemid)
{
	if(itemid != g_itemid_ethereal)
		return
	give_ethereal(id)
	ethereal_changemode[id]=0
	ethereal_reloaded[id]=0
}

public fw_ethereal_AddToPlayer(ethereal, id)
{
	if(!is_valid_ent(ethereal) || !is_user_connected(id))
		return HAM_IGNORED
	
	if(entity_get_int(ethereal, EV_INT_WEAPONKEY) == ethereal_WEAPONKEY)
	{
		g_has_ethereal[id] = true
		
		entity_set_int(ethereal, EV_INT_WEAPONKEY, 0)

		message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
		write_string("weapon_ethereal_sh")
		write_byte(4)
		write_byte(90)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(17)
		write_byte(CSW_AUG)
		message_end()
		
		return HAM_HANDLED
	}
	else
	{
		message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
		write_string("weapon_aug")
		write_byte(4)
		write_byte(90)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(17)
		write_byte(CSW_AUG)
		message_end()
	}
	return HAM_IGNORED
}

public fw_UseStationary_Post(entity, caller, activator, use_type)
{
	if (use_type == USE_STOPPED && is_user_connected(caller))
		replace_weapon_models(caller, get_user_weapon(caller))
}

public fw_Item_Deploy_Post(weapon_ent)
{
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	static weaponid
	weaponid = cs_get_weapon_id(weapon_ent)
	
	replace_weapon_models(owner, weaponid)
}

public CurrentWeapon(id)
{
	replace_weapon_models(id, read_data(2))
	
	if(read_data(2) != CSW_AUG || !g_has_ethereal[id])
	{
		#if defined Icon
		ethereal_debugicon(id)
		#endif
		return
	}
	static Float:iSpeed
	
	if(g_has_ethereal[id])
		if(eth_mode[id]==1)
			iSpeed = get_pcvar_float(cvar_spd_ethereal_laser)
		else
			iSpeed = get_pcvar_float(cvar_spd_ethereal_electro)
			
	static weapon[32],Ent
	get_weaponname(read_data(2),weapon,31)
	Ent = find_ent_by_owner(-1,weapon,id)
	
	if(Ent)
	{
		static Float:Delay
		Delay = get_pdata_float( Ent, 46, 4) * iSpeed
		
		if (Delay > 0.0)
			set_pdata_float(Ent, 46, Delay, 4)
	}
	#if defined Icon
	ethereal_debugicon(id)
	#endif
}

replace_weapon_models(id, weaponid)
{
	switch (weaponid)
	{
		case CSW_AUG:
		{
			
			if(g_has_ethereal[id])
			{
				set_pev(id, pev_viewmodel2, ethereal_V_MODEL)
				set_pev(id, pev_weaponmodel2, ethereal_P_MODEL)
				if(oldweap[id] != CSW_AUG) 
				{
					UTIL_PlayWeaponAnimation(id, ethereal_DRAW)
					set_pdata_float(id, m_flNextAttack, 1.0, PLAYER_LINUX_XTRA_OFF)
					#if defined Icon
						ethereal_debugicon(id)
					#endif
					message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
					write_string("weapon_ethereal_sh")
					write_byte(4)
					write_byte(90)
					write_byte(-1)
					write_byte(-1)
					write_byte(0)
					write_byte(17)
					write_byte(CSW_AUG)
					message_end()
				}
			}
		}
	}
	oldweap[id] = weaponid
}

public fw_UpdateClientData_Post(Player, SendWeapons, CD_Handle)
{
	if(!is_user_alive(Player) || (get_user_weapon(Player) != CSW_AUG || !g_has_ethereal[Player]))
		return FMRES_IGNORED
	
	set_cd(CD_Handle, CD_flNextAttack, halflife_time () + 0.001)
	return FMRES_HANDLED
}

public fw_ethereal_PrimaryAttack(Weapon)
{
	new Player = get_pdata_cbase(Weapon, 41, 4)
	
	if (!g_has_ethereal[Player])
		return
	
	g_IsInPrimaryAttack = 1
	pev(Player,pev_punchangle,cl_pushangle[Player])
	
	g_clip_ammo[Player] = cs_get_weapon_ammo(Weapon)
}

public fwPlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if ((eventid != g_orig_event_ethereal) || !g_IsInPrimaryAttack)
		return FMRES_IGNORED
	if (!(1 <= invoker <= g_MaxPlayers))
		return FMRES_IGNORED
	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	return FMRES_SUPERCEDE
}

public fw_ethereal_PrimaryAttack_Post(Weapon)
{
	new iPlayerID = get_pdata_cbase(Weapon, 41, 4);
	
	
	g_IsInPrimaryAttack = 0
	new Player = get_pdata_cbase(Weapon, 41, 4)
	
	new szClip, szAmmo
	get_user_weapon(Player, szClip, szAmmo)
	
	if(!is_user_alive(Player))
		return

	if(g_has_ethereal[Player])
	{
		if (!g_clip_ammo[Player])
			return

		new Float:push[3]
		pev(Player,pev_punchangle,push)
		xs_vec_sub(push,cl_pushangle[Player],push)
		if(eth_mode[Player]==1)
			xs_vec_mul_scalar(push,get_pcvar_float(cvar_recoil_ethereal_laser),push)
		else
			xs_vec_mul_scalar(push,get_pcvar_float(cvar_recoil_ethereal_electro),push)
		
		xs_vec_add(push,cl_pushangle[Player],push)
		set_pev(Player,pev_punchangle,push)
		
		UTIL_PlayWeaponAnimation(Player, random_num(ethereal_SHOOT1, ethereal_SHOOT2))
			
		set_bit(g_bitsMuzzleFlash, iPlayerID);
	}
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if (victim != attacker && is_user_connected(attacker))
	{
		if(get_user_weapon(attacker) == CSW_AUG)
		{
			if(g_has_ethereal[attacker])
				if(eth_mode[attacker]==1)
					SetHamParamFloat(4, damage * get_pcvar_float(cvar_dmg_ethereal_laser))
				else
					SetHamParamFloat(4, damage * get_pcvar_float(cvar_dmg_ethereal_electro))
		}
	}
}
#if defined  deathMSG
public message_DeathMsg(msg_id, msg_dest, id)
{
	static szTruncatedWeapon[33], iAttacker, iVictim
	
	get_msg_arg_string(4, szTruncatedWeapon, charsmax(szTruncatedWeapon))
	
	iAttacker = get_msg_arg_int(1)
	iVictim = get_msg_arg_int(2)
	
	if(!is_user_connected(iAttacker) || iAttacker == iVictim)
		return PLUGIN_CONTINUE
	
	if(equal(szTruncatedWeapon, "aug") && get_user_weapon(iAttacker) == CSW_AUG)
		if(g_has_ethereal[iAttacker])
			if(eth_mode[iAttacker]==0)
				set_msg_arg_string(4, "Ethereal Electric")
			else
			if(eth_mode[iAttacker]==1)
				set_msg_arg_string(4, "Ethereal Laser")
			
	return PLUGIN_CONTINUE
}
#endif
stock fm_cs_get_current_weapon_ent(id)
{
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX)
}

stock fm_cs_get_weapon_ent_owner(ent)
{
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player)
	write_byte(Sequence)
	write_byte(pev(Player, pev_body))
	message_end()
}

public ethereal_ItemPostFrame(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)

	if (!is_user_connected(id)||!g_has_ethereal[id])
		return HAM_IGNORED
	
	static iClipExtra
	iClipExtra = get_pcvar_num(cvar_clip_ethereal)
	
	new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)
	new iBpAmmo = cs_get_user_bpammo(id, CSW_AUG)
	new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)
	new fInReload = get_pdata_int(weapon_entity, m_fInReload, WEAP_LINUX_XTRA_OFF) 
	
	if( fInReload && flNextAttack <= 0.0 )
	{
		new j = min(iClipExtra - iClip, iBpAmmo)
		
		set_pdata_int(weapon_entity, m_iClip, iClip + j, WEAP_LINUX_XTRA_OFF)
		cs_set_user_bpammo(id, CSW_AUG, iBpAmmo-j)
			
		set_pdata_int(weapon_entity, m_fInReload, 0, WEAP_LINUX_XTRA_OFF)
		fInReload = 0
	}
	return HAM_IGNORED
}

public ethereal_Reload(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)

	if (!is_user_connected(id)||!g_has_ethereal[id])
		return HAM_IGNORED
	
	static iClipExtra
	if(g_has_ethereal[id])
		iClipExtra = get_pcvar_num(cvar_clip_ethereal)
	
	g_ethereal_TmpClip[id] = -1
	
	new iBpAmmo = cs_get_user_bpammo(id, CSW_AUG)
	new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)
	
	if (iBpAmmo <= 0||iClip >= iClipExtra)
		return HAM_SUPERCEDE
		
	g_ethereal_TmpClip[id] = iClip
	ethereal_reloaded[id]=1
	set_task(ethereal_RELOAD_TIME,"reload_end",id)
	return HAM_IGNORED
}
public reload_end(id)
	ethereal_reloaded[id]=0
public ethereal_Reload_Post(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)
	if (!g_has_ethereal[id]||g_ethereal_TmpClip[id] == -1||!is_user_connected(id))
		return HAM_IGNORED

	set_pdata_int(weapon_entity, m_iClip, g_ethereal_TmpClip[id], WEAP_LINUX_XTRA_OFF)
	set_pdata_float(weapon_entity, m_flTimeWeaponIdle, ethereal_RELOAD_TIME, WEAP_LINUX_XTRA_OFF)
	set_pdata_float(id, m_flNextAttack, ethereal_RELOAD_TIME, PLAYER_LINUX_XTRA_OFF)
	set_pdata_int(weapon_entity, m_fInReload, 1, WEAP_LINUX_XTRA_OFF)
	
	UTIL_PlayWeaponAnimation(id, ethereal_RELOAD)

	return HAM_IGNORED
}

stock drop_weapons(id, dropwhat)
{
	static weapons[32], num, i, weaponid
	num = 0
	get_user_weapons(id, weapons, num)
	
	for (i = 0; i < num; i++)
	{
		weaponid = weapons[i]
		
		if (dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
		{
			static wname[32]
			get_weaponname(weaponid, wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}
public fw_CmdStart(id, uc_handle, seed)
{
	if(!is_user_alive(id)||ethereal_changemode[id]==1||!g_has_ethereal[id]||ethereal_reloaded[id]==1)
		return

	if((get_uc(uc_handle, UC_Buttons) & IN_USE) && !(pev(id, pev_oldbuttons) & IN_USE))
	{
		new szClip, szAmmo
		new szWeapID = get_user_weapon(id, szClip, szAmmo)
		if(szWeapID == CSW_AUG && g_has_ethereal[id])
		{
			if(eth_mode[id]==1)
			{
				eth_mode[id]=0
				ethereal_changemode[id]=1
				client_print(id,print_center,"Electric mode selected")
				set_pdata_float(id, m_flNextAttack, ethereal_RELOAD_TIME, PLAYER_LINUX_XTRA_OFF)
				UTIL_PlayWeaponAnimation(id, ethereal_RELOAD)
				set_task(3.0,"clockdown",id)
				#if defined Icon
					Status_Icon(id,l_ethereal_i_r,l_ethereal_i_g,l_ethereal_i_b,2)
				#endif
			}
			else
			{
				eth_mode[id]=1
				ethereal_changemode[id]=1
				client_print(id,print_center,"Laser mode selected")
				set_pdata_float(id, m_flNextAttack, ethereal_RELOAD_TIME, PLAYER_LINUX_XTRA_OFF)
				UTIL_PlayWeaponAnimation(id, ethereal_RELOAD)
				set_task(3.0,"clockdown",id)
				#if defined Icon
					Status_Icon(id,e_ethereal_i_r,e_ethereal_i_g,e_ethereal_i_b,2)
				#endif
			}
			cs_set_user_zoom(id,0,0)
		}
	}
}
public clockdown(id)
{
	ethereal_changemode[id]=0
	#if defined Icon
		ethereal_debugicon(id)
	#endif
}
public CPlayer__AddToFullPack_post(esState, iE, iEnt, iHost, iHostFlags, iPlayer, pSet)
{
	if (iEnt != g_iEntity)
		return;
	if (get_bit(g_bitsMuzzleFlash, iHost))
	{
		set_es(esState, ES_Frame, float(random_num(0, 2)));
			
		set_es(esState, ES_RenderMode, kRenderTransAdd);
		set_es(esState, ES_RenderAmt, 255.0);
		
		reset_bit(g_bitsMuzzleFlash, iHost);
	}
		
	set_es(esState, ES_Skin, iHost);
	set_es(esState, ES_Body, 1);
	set_es(esState, ES_AimEnt, iHost);
	set_es(esState, ES_MoveType, MOVETYPE_FOLLOW);
}
public CEntity__CheckVisibility(iEntity, pSet)
{
	if (iEntity != g_iEntity)
		return FMRES_IGNORED;
	
	forward_return(FMV_CELL, 1);
	
	return FMRES_SUPERCEDE;
}
#if defined Icon
Status_Icon(id,r,g,b,p)
{			
	{
		message_begin(MSG_ONE_UNRELIABLE, g_Msg_StatusIcon, {0,0,0}, id)
		write_byte(p)
		write_string("dmg_shock")
		write_byte(r)			// red
		write_byte(g)			// green
		write_byte(b)			// blue
		message_end()
	}
}
public ethereal_debugicon(id)
{
	if(get_user_weapon(id)==CSW_AUG&&g_has_ethereal[id]&&is_user_alive(id))
		if(eth_mode[id]==1)
			Status_Icon(id,l_ethereal_i_r,l_ethereal_i_g,l_ethereal_i_b,1)
		else
			Status_Icon(id,e_ethereal_i_r,e_ethereal_i_g,e_ethereal_i_b,1)
	else
		Status_Icon(id,0,0,0,0)
}
#endif
