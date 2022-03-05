/*================================================================================
	[Zombie Queen 1.0 by Abhinash]
=================================================================================*/
#include <   amxmodx      >
#include <   amxmisc      >
#include <   cstrike      >
#include <    engine      >
#include <   fakemeta     > 
#include <      fun       >
#include <   hamsandwich  >
#include <     nvault     >
#include <	 screenfade   >
#include <   SettingsAPI  >
#include <      xs        >
#include <     geoip      >
#include <		sqlx	  >
#include <      rog       >

// Jetapck
native set_user_jetpack(id, jetpack)
native get_user_jetpack(id)
native set_jetpack(id)
native user_drop_jetpack(id , jetpack)
native set_user_rocket_time(id, Float:fTime)
native set_user_fuel(id, Float: fFuel)
native set_zombie(id, bool:Enable = true)

// Model
native set_user_model(id, model[])
native get_user_model(id, model[], length) 

// Golden Weapons
native set_goldenak47(id)
native set_goldenm4a1(id)
native set_goldenxm1014(id)
native set_goldendeagle(id)

// Armor
native set_armor(id, amount)
native get_armor(id)

// Health
native set_health(id, amount)
native get_health(id)

// Team
native get_team(id)

// Beam
native Beam(id, id2, red, green, blue)

// Effects
native SendTracers(id)
native SendLightningTracers(id)

// NightVision
native SendNightVision(id, red, green, blue)

// Infection effects
native SendInfectionLight(id)

// Grenade Effects
native SendGrenadeLight(red, green, blue, radius, Float:origin[3])
native SendGrenadeBeamCylinder(entity, red, green, blue, brightness)
native SendGrenadeBeamFollow(entity, red, green, blue)
native SendFlame(id)
native SendSmoke(id)

// Few other effects
native SendTeleport(id)
native SendLavaSplash(id)
native SendParticleBurst(id)
native SendGlassBreak(id)
native SendImplosion(id)
native SendSkillEffect(id, Float:endorigin[3], red, green, blue)

// Messages
native SetFOV(id, amount)
native HideWeapon(id, what)
native HideCrosshair(id)
native SendScreenShake(id, xxx, xxxx, xxxxx)
native SendDeathMsg(attacker, victim)
native FixScoreAttrib(id)
native SendScoreInfo(id)

// Customs
native is_origin_vacant(Float:origin[3], id)
native is_hull_vacant(id)

// Knife Blink
native get_target_and_attack(id)

/*================================================================================
	[Constants, Offsets, Macros]
=================================================================================*/

// Task offsets
enum (+= 100)
{
	TASK_MODEL = 2000,
	TASK_TEAM,
	TASK_SPAWN,
	TASK_BLOOD,
	TASK_BURN,
	TASK_NVISION,
	TASK_COUNTDOWN,
	TASK_REMOVE_FORECEFIELD,
	TASK_CONCUSSION,
	TASK_BUBBLE,
	TASK_REMINDER,
	TASK_FLASH,
	TASK_CHARGE,
	TASK_SHOWHUD,
	TASK_MAKEZOMBIE,
	TASK_WELCOMEMSG,
	TASK_AMBIENCESOUNDS,
	TASK_VOTERESULTS
}

// IDs inside tasks
#define ID_SHOWHUD 	(taskid - TASK_SHOWHUD)

// Chat prefix
new CHAT_PREFIX[50] // "^4[PerfectZM]^1"
new ROUND_WELCOME_TEXT[100]

// Max Admin Ranks
#define MAX_GROUPS 10

new g_groupNames[MAX_GROUPS][] = 
{
	"Founder",
	"Owner",
	"Co-owner",
	"Prince",
	"Elder",
	"Semi-elder",
	"Administrator",
	"Moderator",
	"Helper",
	"Suspended"
}

new g_groupRanks[MAX_GROUPS][] = 
{
	"RANK_FOUNDER",
	"RANK_OWNER",
	"RANK_CO_OWNER",
	"RANK_PRINCE",
	"RANK_ELDER",
	"RANK_SEMI_ELDER",
	"RANK_ADMINISTRATOR",
	"RANK_MODERATOR",
	"RANK_HELPER",
	"RANK_SUSPENDED"
}

// Old connection queue
#define OLD_CONNECTION_QUEUE 10

new g_Names[OLD_CONNECTION_QUEUE][33]
new g_SteamIDs[OLD_CONNECTION_QUEUE][32]
new g_IPs[OLD_CONNECTION_QUEUE][32]
new g_Tracker
new g_Size

/*================================================================================
	[Configurations]
=================================================================================*/

// Classes Configurations

// Human Class Configs
new HumanHealth
new Float:HumanSpeed
new Float:HumanGravity
new HumanArmorProtect
new HumanFragsForKill
new LastHumanExtraHealth

// Assassin
new AssassinEnabled
new AssassinChance
new AssassinMinPlayers
new AssassinHealth
new Float:AssassinSpeed
new Float:AssassinGravity
new Float:AssassinDamage

// Nemesis
new NemesisEnabled
new NemesisChance
new NemesisMinPlayers
new NemesisHealth
new Float:NemesisSpeed
new Float:NemesisGravity
new Float:NemesisDamage

// Bombardier
new BombardierEnabled
new BombardierChance
new BombardierMinPlayers
new BombardierHealth
new Float:BombardierSpeed
new Float:BombardierGravity
new Float:BombardierDamage

// Revenant
new RevenantEnabled
new RevenantChance
new RevenantMinPlayers
new RevenantHealth
new Float:RevenantSpeed
new Float:Revenantgravity
new Float:RevenantDamage

// Sniper
new SniperEnabled
new SniperChance
new SniperMinPlayers
new SniperHealth
new Float:SniperSpeed
new Float:SniperGravity
new Float:SniperDamage

// Survivor
new SurvivorEnabled
new SurvivorChance
new SurvivorMinPlayers
new SurvivorHealth
new Float:SurvivorSpeed
new Float:SurvivorGravity

// Samurai
new SamuraiEnabled
new SamuraiChance
new SamuraiMinPlayers
new SamuraiHealth
new Float:SamuraiSpeed
new Float:SamuraiGravity
new Float:SamuraiDamage

// Grenadier
new GrenadierEnabled
new GrenadierChance
new GrenadierMinPlayers
new GrenadierHealth
new Float:GrenadierSpeed
new Float:GrenadierGravity
new Float:GrenadierDamage

// Terminator
new TerminatorEnabled
new TerminatorChance
new TerminatorMinPlayers
new TerminatorHealth
new Float:TerminatorSpeed
new Float:TerminatorGravity

// Tryder
new TryderHealth
new Float:TryderSpeed
new Float:TryderGravity

// Knockback
new KnockbackEnabled
new KnockbackDistance
new Float:KnockbackDucking
new Float:KnockbackAssassin
new Float:KnockbackNemesis
new Float:KnockbackBombardier
new Float:KnockbackRevenant

// Pain Shock free
new AssassinPainfree
new RevenantPainfree
new NemesisPainfree
new BombardierPainfree
new SniperPainfree
new SurvivorPainfree
new SamuraiPainfree
new GrenadierPainfree
new TerminatorPainfree

// Glow 
new NemesisGlow
new AssassinGlow
new RevenantGlow
new SurvivorGlow
new SniperGlow
new SamuraiGlow
new GrenadierGlow
new TerminatorGlow
new BombardierGlow
new TryderGlow

// General configs
new ZpDelay = 14
new Float:SpawnProtectionDelay = 5.0

// General Purpose 
new BlockSuicide = 1
new RemoveMoney = 1
new SaveStats = 1
new RespawnOnWorldSpawnKill = 1
new PreventConsecutiveRounds = 1
new KeepHealthOnDisconnect = 1
new StartingPacks = 15

// Nightvision Configs
new NightVisionEnabled = 1
new CustomNightVision = 1
new NColorHuman_R = 0
new NColorHuman_G = 160
new NColorHuman_B = 100
new NColorZombie_R = 0
new NColorZombie_G = 160
new NColorZombie_B = 100
new NColorAssassin_R = 0
new NColorAssassin_G = 160
new NColorAssassin_B = 100
new NColorNemesis_R = 0
new NColorNemesis_G = 160
new NColorNemesis_B = 100
new NColorBombardier_R = 0
new NColorBombardier_G = 160
new NColorBombardier_B = 100
new NColorSpectator_R = 0
new NColorSpectator_G = 160
new NColorSpectator_B = 100

// Flashlight Configs
new FlashLightEnabled = 1
new FlashLightSize = 10
new FlashLightDrain = 1
new FlashLightCharge = 5
new FlashLightDistance = 1000
new FlColor1_R = 255
new FlColor1_G = 0
new FlColor1_B = 0
new FlColor2_R = 0
new FlColor2_G = 0
new FlColor2_B = 255

// Leap Configs
new LeapZombies
new LeapZombiesForce
new Float:LeapZombiesHeight
new Float:LeapZombiesCooldown

new LeapNemesis
new LeapNemesisForce
new Float:LeapNemesisHeight
new Float:LeapNemesisCooldown

new LeapAssassin
new LeapAssassinForce
new Float:LeapAssassinHeight
new Float:LeapAssassinCooldown

new LeapRevenant
new LeapRevenantForce
new Float:LeapRevenantHeight
new Float:LeapRevenantCooldown

new LeapBombardier
new LeapBombardierForce
new Float:LeapBombardierHeight
new Float:LeapBombardierCooldown

new LeapSurvivor
new LeapSurvivorForce
new Float:LeapSurvivorHeight
new Float:LeapSurvivorCooldown

new LeapSniper
new LeapSniperForce
new Float:LeapSniperHeight
new Float:LeapSniperCooldown

new LeapSamurai
new LeapSamuraiForce
new Float:LeapSamuraiHeight
new Float:LeapSamuraiCooldown

new LeapGrenadier
new LeapGrenadierForce
new Float:LeapGrenadierHeight
new Float:LeapGrenadierCooldown

new LeapTerminator
new LeapTerminatorForce
new Float:LeapTerminatorHeight
new Float:LeapTerminatorCooldown

// Custom grenades configs
new FireDuration  = 10
new Float:FireDamage = 5.0
new Float:FireSlowdown  = 0.5
new Float:FrostDuration = 5.0

// Few Extra items configs
new MadnessDuration = 5

// Zombies Configs
new Float:FirstZombieHealth = 2.0
new Float:ZombieArmor = 0.75
new ZombieFOV = 110
new ZombieSilentFootSteps = 1
new ZombiePainfree = 0
new ZombieBleeding = 0
new ZombieRewardInfectPacks = 1
new ZombieRewardInfectFrags = 1

// Special Effects Configs
new InfectionScreenFade = 1
new InfectionScreenShake = 1
new InfectionSparkle = 1
new InfectionTracers = 1
new InfectionParticles = 1
new HUDIcons = 1

// SWARM Mode Configs
new Swarm_enable
new Swarm_chance
new Swarm_minPlayers

// Multiple Infection Configs
new MultiInfection_enable
new MultiInfection_chance
new MultiInfection_minPlayers
new Float:MultiInfection_ratio

// Plague Mode configs
new Plague_enable
new Plague_chance
new Plague_minPlayers
new Float:Plague_ratio
new Plague_nemesisCount
new Float:Plague_nemesis_HealthMultiply
new Plague_survivorCount
new Float:Plague_survivor_HealthMultiply

// Armageddon Mode configs
new Armageddon_enable
new Armageddon_chance
new Armageddon_minPlayers
new Float:Armageddon_ratio
new Float:Armageddon_nemesis_HealthMultiply
new Float:Armageddon_survivor_HealthMultiply

// Sniper vs Assassin mode configs
new Apocalypse_enable
new Apocalypse_chance
new Apocalypse_minPlayers
new Float:Apocalypse_ratio
new Float:Apocalypse_assasin_HealthMultiply
new Float:Apocalypse_sniper_HealthMultiply

// Sniper vs Nemesis mode configs
new SniperVsNemesis_enable
new SniperVsNemesis_chance
new SniperVsNemesis_minPlayers
new Float:SniperVsNemesis_ratio
new Float:SniperVsNemesis_sniper_HealthMultiply
new Float:SniperVsNemesis_nemesis_HealthMultiply

// Nightmare mode configs
new Nightmare_enable
new Nightmare_chance
new Nightmare_minPlayers
new Float:Nightmare_ratio
new Float:Nightmare_assasin_HealthMultiply
new Float:Nightmare_nemesis_HealthMultiply
new Float:Nightmare_sniper_HealthMultiply
new Float:Nightmare_survivor_HealthMultiply

// Synapsis mode configs
new Synapsis_enable
new Synapsis_chance
new Synapsis_minPlayers
new Float:Synapsis_ratio
new Synapsis_nemesisCount
new Float:Synapsis_nemesis_HealthMultiply
new Synapsis_survivorCount
new Float:Synapsis_survivor_HealthMultiply
new Synapsis_sniperCount
new Float:Synapsis_sniper_HealthMultiply

// Survivor vs Assasin configs
new SurvivorVsAssasin_enable
new SurvivorVsAssasin_chance
new SurvivorVsAssasin_minPlayers
new Float:SurvivorVsAssasin_ratio
new Float:SurvivorVsAssasin_assasin_HealthMultiply
new Float:SurvivorVsAssasin_survivor_HealthMultiply

// Bombardier vs Grenadier configs
new BombardierVsGrenadier_enable
new BombardierVsGrenadier_chance
new BombardierVsGrenadier_minPlayers
new Float:BombardierVsGrenadier_ratio
new Float:BombardierVsGrenadier_bombardier_HealthMultiply
new Float:BombardierVsGrenadier_grenadier_HealthMultiply

// Free VIP Timings
new freeVIP_Start, freeVIP_End, freeVIP_Flags[10]

// Happy hour settings
new happyHour_Start, happyHour_End

// Models stuff
new Float:g_modelchange_delay = 0.2 

// SQLx
new Handle:g_SqlTuple
new g_Error[512]			// Error buffer
new g_kills[33]				// Kills
new g_deaths[33]			// Deaths
new g_score[33]				// Score
new g_infections[33]		// Infections
new g_nemesiskills[33]		// Nemesis kills
new g_assasinkills[33]		// Assasin kills
new g_bombardierkills[33]	// Bombardier kills
new g_survivorkills[33]		// Survivor kills
new g_sniperkills[33]		// Sniper kills
new g_samuraikills[33]		// Samurai kills
new g_grenadierkills[33]    // Grenadier kills
new g_revenantkills[33]     // Revenant kills
new g_terminatorkills[33]   // Terminator kills
new g_totalplayers

// GAG
new Float:g_fGagTime[33]

/*================================================================================
	[Sounds]
=================================================================================*/
new const sound_thunder[][] =
{
	"PerfectZM/thunder1.wav" ,
	"PerfectZM/thunder2.wav"
}

new const CountdownSounds[][] =
{
	"fvox/biohazard_detected.wav",
	"fvox/one.wav", 
	"fvox/two.wav", 
	"fvox/three.wav", 
	"fvox/four.wav", 
	"fvox/five.wav", 
	"fvox/six.wav", 
	"fvox/seven.wav", 
	"fvox/eight.wav", 
	"fvox/nine.wav",
	"fvox/ten.wav"
}

new const zombie_decals[] =
{ 
	99, 
	107, 
	108, 
	184, 
	185, 
	186, 
	187, 
	188, 
	189 
}

new const g_objective_ents[][] = 
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
	"env_snow", 
	"item_longjump", 
	"func_vehicle" 
}

// Sky Names (randomly chosen if more than one)
new const g_sky_names[][] = 
{ 
	"blood_" 
}

// Bots
new g_bot[33]
new g_iBotsCount

new g_cBotNames[][] =
{
	"IP: 46.101.226.197:27015",
	"Forum: CsBlackDevil.com"
}

// Admin info struct
enum _: adminInfoStruct
{
	_aName[32],
	_aPassword[32],
	_aFlags[50],
	_aRank[32]
}

new g_adminInfo[33][adminInfoStruct]
new g_admin[33]
new g_adminCount
new Trie:g_adminsTrie  // Trie Datat Structure handle for storing Admins info

// Vip info struct
enum _: vipInfoStruct
{
	_vName[32],
	_vPassword[32],
	_vFlags[32]
}

new g_vipInfo[33][vipInfoStruct]
new g_vip[33]
new g_vipCount
new Trie:g_vipsTrie // Trie Data structure handle for storing Vip info

// Player tag info struct
enum _: playerTagInfoStruct
{
	_tName[32],
	_tPassword[32],
	_tTag[32]
}

new g_tagCount
new g_tag[33][32]
new Trie:g_tagTrie

new g_playerIP[33][24]

// Zombie Classes Variables

// Frozen zombie
new frost_distance = 1000
new frost_cooldown = 10
new Float:frost_time = 5.0
new Float:g_lastability[33]
new skillcooldown = 10

// Raptor zombie
new bool:g_raptor_speeded[33]

// Hunter zombie
new hunter_cooldown = 10
new hunter_distance = 1000

// Predator zombie
new predator_cooldown = 10
new Float:predator_invisible_duration = 10.0
new bool:g_invisible[33]

// Extra items
new bool:g_multijump[33]
new g_jumpcount[33]
new g_jumpnum[33]

// Crossbow
const Wep_sg550 = ((1<<CSW_SG550))
new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 }
new g_has_crossbow[33], Float:cl_pushangle[33][3], g_spriteLightning, g_orig_event_crossbow, g_IsInPrimaryAttack, g_clip_ammo[33], g_crossbow_TmpClip[33]
new Trie:g_tClassNames
new const crossbow_V_MODEL[] = { "models/PerfectZM/v_crossbow.mdl" }
new const crossbow_P_MODEL[] = { "models/PerfectZM/p_crossbow.mdl" }
new const crossbow_W_MODEL[] = { "models/PerfectZM/w_crossbow.mdl" }
new Float:CROSSBOW_DAMAGE = 1.50
new Float:CROSSBOW_RECOIL = 0.80
new CROSSBOW_CLIP = 50

// Golden Weapons
new bool:g_goldenweapons[33]

new bool:g_doubledamage[33]
new bool:g_norecoil[33]
new bool:g_speed[33]
new bool:g_allheadshots[33]

// Knife Blink
new g_blinks[33]

// Force Field Grenade Entity
new const BubbleEntityClassName[] = "Force-Field_Grenade"
new const BubbleGrenadeModel[] = "models/PerfectZM/aura8.mdl"
new Float:BubbleGrenadeMaxs[3] = { 100.0 , 100.0 , 100.0 }
new Float:BubbleGrenadeMins[3] = { -100.0, -100.0, -100.0 }

// Map related
new MapCountdownTimer = 10
// new bool:g_bVoting
new bool:g_bSecondVoting
new g_iVariable
// new g_iVariables[3]
// new g_iVotes[7]
// new g_cMaps[7][32]
new g_cSecondMaps[5][32]
new g_iSecondVotes[5]

// Leader related
new g_iKillsThisRound[33]

// Round Count
new g_roundcount

// Advertisements
new g_cAdvertisements[72][188]
new g_iAdvertisementsCount
new g_iMessage
new Array:g_hudAdvertisementMessages

// GeoIP
new g_playercountry[33][32]
new g_playercity[33][32]

// Array for Weapon menu
new Array:g_full_weapon_names, Array:g_weapon_name[2], Array:g_weapon_ids[2]

/*================================================================================
	[Core stuffs...]
=================================================================================*/

new g_adminMenuAction[33]
new g_playersMenuBackAction[33]

#define ADMIN_MENU_ACTION g_adminMenuAction[id]
#define PL_MENU_BACK_ACTION g_playersMenuBackAction[id]

enum _: adminMenuActions
{
    ACTION_MAKE_HUMAN = 0,
    ACTION_MAKE_SURVIVOR,
    ACTION_MAKE_SNIPER,
    ACTION_MAKE_SAMURAI,
    ACTION_MAKE_TERMINATOR,
    ACTION_MAKE_GRENADIER,
    ACTION_MAKE_ZOMBIE,
    ACTION_MAKE_ASSASIN,
    ACTION_MAKE_NEMESIS,
    ACTION_MAKE_BOMBARDIER,
    ACTION_MAKE_REVENANT,
    ACTION_MAKE_DRAGON,
    ACTION_RESPAWN_PLAYER
}

enum _: makeHumanClassConstants
{
    MAKE_HUMAN = 0,
    MAKE_SURVIVOR,
    MAKE_SNIPER,
    MAKE_SAMURAI,
    MAKE_TERMINATOR,
    MAKE_GRENADIER
}

enum _: makeZombieClassConstants
{
    MAKE_ZOMBIE = 0,
    MAKE_ASSASIN,
    MAKE_NEMESIS,
    MAKE_BOMBARDIER,
    MAKE_REVENANT,
    MAKE_DRAGON
}

enum _: startNormalModesConstants
{
    START_INFECTION = 0,
    START_MULTIPLE_INFECTION,
    START_SWARM,
    START_PLAGUE,
    START_SYNAPSIS
}

enum _: startSpecialModesConstants
{
    START_SURVIVOR_VS_NEMESIS = 0,
    START_SURVIVOR_VS_ASSASIN,
    START_SNIPER_VS_NEMESIS,
    START_SNIPER_VS_ASSASIN,
    START_BOMBARDIER_VS_GRENADIER,
    START_NIGHTMARE
}

enum _: menuBackActions
{
    MENU_BACK_MAKE_HUMAN_CLASS = 0,
    MENU_BACK_MAKE_ZOMBIE_CLASS,
    MENU_BACK_RESPAWN_PLAYERS
}

new g_mainAdminMenuCallback, g_makeHumanClassMenuCallback, g_makeZombieClassMenuCallback, g_startNormalModesCallback, g_startSpecialModesCallback, g_playersMenuCallback

// Admin commands access
enum _: adminCommandsAccess
{
	ACCESS_IMMUNITY,
	ACCESS_NICK,
	ACCESS_SLAP,
	ACCESS_SLAY,
	ACCESS_KICK,
	ACCESS_RESPAWN_PLAYERS,
	ACCESS_FREEZE,
	ACCESS_GAG,
	ACCESS_PUNISH,
	ACCESS_MAP,
	ACCESS_DESTROY,
	ACCESS_PUNISH,
	ACCESS_JETPACK,
	ACCESS_MAKE_HUMAN,
	ACCESS_MAKE_ZOMBIE,
	ACCESS_MAKE_ASSASIN,
	ACCESS_MAKE_NEMESIS,
	ACCESS_MAKE_BOMBARDIER,
	ACCESS_MAKE_REVENANT,
	ACCESS_MAKE_SURVIVOR,
	ACCESS_MAKE_SNIPER,
	ACCESS_MAKE_SAMURAI,
	ACCESS_MAKE_GRENADIER,
	ACCESS_MAKE_TERMINATOR,
	ACCESS_START_MULTI_INFECTION,
	ACCESS_START_SWARM,
	ACCESS_START_PLAGUE,
	ACCESS_START_SYNAPSIS,
	ACCESS_START_SURVIVOR_VS_NEMESIS,
	ACCESS_START_SURVIVOR_VS_ASSASIN,
	ACCESS_START_SNIPER_VS_ASSASIN,
	ACCESS_START_SNIPER_VS_NEMESIS,
	ACCESS_START_BOMBARDIER_VS_GRENADIER,
	ACCESS_START_NIGHTMARE,
	ACCESS_RELOAD_ADMINS,
	ACCESS_POINTS,
	MAX_ACCESS_FLAGS
}

new g_accessFlag[MAX_ACCESS_FLAGS]

// Class Models constants
enum _: modelConsts
{
	MODEL_HUMAN,
	MODEL_SURVIVOR,
	MODEL_SNIPER,
	MODEL_SAMURAI,
	MODEL_GRENADIER,
	MODEL_TERMINATOR,
	MODEL_ASSASIN,
	MODEL_NEMESIS,
	MODEL_BOMBARDIER,
	MODEL_REVENANT,
	MODEL_OWNER,
	MODEL_ADMIN,
	MODEL_VIP,
	MAX_CLASS_MODELS
}

new Array:g_playerModel[MAX_CLASS_MODELS]

// Extra models ( weapons )
enum _: extraWeaponModels
{
	V_KNIFE_HUMAN,
	P_KNIFE_HUMAN,
	V_KNIFE_NEMESIS,
	V_KNIFE_ASSASIN,
	V_KNIFE_REVENANT,
	V_KNIFE_SAMURAI,
	P_KNIFE_SAMURAI,
	V_AWP_SNIPER,
	P_AWP_SNIPER,
	V_INFECTION_NADE,
	V_EXPLOSION_NADE,
	V_NAPALM_NADE,
	V_FROST_NADE,
	MAX_WEAPON_MODELS
}

new Array:g_weaponModels[MAX_WEAPON_MODELS]

// Sprites
enum _: grenadeSprites
{
	SPRITE_GRENADE_TRAIL,
	SPRITE_GRENADE_EXPLOSION,
	MAX_SPRITES
}

new Array:g_sprites[MAX_SPRITES]

enum _: __color
{
	__red,
	__green,
	__blue
}

enum _: __nade_type
{
	__nade_type_infection,
	__nade_type_explosion,
	__nade_type_napalm,
	__nade_type_frost,
	__nade_type_forcefield,
	__nade_type_killing,
	__nade_type_concussion,
	__nade_type_antidote,
	__MAX_NADE_TYPE
}

new g_color[__nade_type][__color]

// Ambience sounds
enum _: ambienceSounds
{
	AMBIENCE_SURVIVOR,
	AMBIENCE_SNIPER,
	AMBIENCE_SAMURAI,
	AMBIENCE_GRENADIER,
	AMBIENCE_TERMINATOR,
	AMBIENCE_ASSASIN,
	AMBIENCE_NEMESIS,
	AMBIENCE_BOMBARDIER,
	AMBIENCE_REVENANT,
	AMBIENCE_INFECTION,
	AMBIENCE_MULTI_INFECTION,
	AMBIENCE_SWARM,
	AMBIENCE_PLAGUE,
	AMBIENCE_SYNAPSIS,
	AMBIENCE_SURVIVOR_VS_NEMESIS,
	AMBIENCE_SURVIVOR_VS_ASSASIN,
	AMBIENCE_SNIPER_VS_NEMESIS,
	AMBIENCE_SNIPER_VS_ASSASIN,
	AMBIENCE_BOMBARDIER_VS_GRENADIER,
	AMBIENCE_NIGHTMARE,
	MAX_AMBIENCE_SOUNDS
}

new Array:g_ambience[MAX_AMBIENCE_SOUNDS]

// Round sounds
enum _: roundSounds
{
	SOUND_HUMAN_WIN,
	SOUND_ZOMBIE_WIN,
	SOUND_WIN_NO_ONE,
	SOUND_SURVIVOR,
	SOUND_SNIPER,
	SOUND_SAMURAI,
	SOUND_GRENADIER,
	SOUND_TERMINATOR,
	SOUND_ASSASIN,
	SOUND_NEMESIS,
	SOUND_BOMBARDIER,
	SOUND_REVENANT,
	SOUND_MULTI_INFECTION,
	SOUND_SWARM,
	SOUND_PLAGUE,
	SOUND_SYNAPSIS,
	SOUND_SURVIVOR_VS_NEMESIS,
	SOUND_SURVIVOR_VS_ASSASIN,
	SOUND_SNIPER_VS_NEMESIS,
	SOUND_SNIPER_VS_ASSASIN,
	SOUND_BOMBARDIER_VS_GRENADIER,
	SOUND_NIGHTMARE,
	MAX_START_SOUNDS
}

new Array:g_startSound[MAX_START_SOUNDS]

// Misc Sounds
enum _: miscSound
{
	SOUND_ZOMBIE_INFECT,
	SOUND_ZOMBIE_PAIN,
	SOUND_NEMESIS_PAIN,
	SOUND_ASSASIN_PAIN,
	SOUND_REVENANT_PAIN,
	SOUND_ZOMBIE_DIE,
	SOUND_ZOMBIE_FALL,
	SOUND_ZOMBIE_MISS_SLASH,
	SOUND_ZOMBIE_MISS_WALL,
	SOUND_ZOMBIE_HIT_NORMAL,
	SOUND_ZOMBIE_HIT_STAB,
	SOUND_ZOMBIE_IDLE,
	SOUND_ZOMBIE_IDLE_LAST,
	SOUND_ZOMBIE_MADNESS,
	SOUND_GRENADE_INFECT,
	SOUND_GRENADE_INFECT_PLAYER,
	SOUND_GRENADE_FIRE,
	SOUND_GRENADE_FIRE_PLAYER,
	SOUND_GRENADE_FROST,
	SOUND_GRENADE_FROST_PLAYER,
	SOUND_GRENADE_FROST_BREAK,
	SOUND_ANTIDOTE,
	MAX_MISC_SOUNDS
}

new Array:g_miscSounds[MAX_MISC_SOUNDS]

// Enum for glow colors
enum _: glowClasses
{
	__survivor,
	__sniper,
	__samurai,
	__grenadier,
	__terminator,
	__assasin,
	__nemesis,
	__bombardier,
	__revenant,
	__MAX_GLOW_CLASSES
}

new g_glowColor[__MAX_GLOW_CLASSES][__color]

LoadCustomizationFromFile()
{
	static buffer[100], i
	static rgb[3][10]

	// Section Access Flags
	new user_access[2]
	new access_names[MAX_ACCESS_FLAGS][] = { "ACCESS IMMUNITY", "ACCESS NICK", "ACCESS SLAP", "ACCESS SLAY", "ACCESS KICK", "ACCESS RESPAWN", "ACCESS FREEZE", "ACCESS GAG", "ACCESS PUNISH", "ACCESS MAP", 
	"ACCESS DESTROY", "ACCESS PUNISH", "ACCESS JETPACK", "ACCESS HUMAN", "ACCESS ZOMBIE", "ACCESS ASSASIN", "ACCESS NEMESIS", "ACCESS BOMBARDIER", "ACCESS REVENANT", "ACCESS SURVIVOR", "ACCESS SNIPER", "ACCESS SAMURAI", 
	"ACCESS GRENADIER", "ACCESS TERMINATOR", "ACCESS MULTI INFECTION", "ACCESS SWARM", "ACCESS PLAGUE", "ACCESS SYNAPSIS", "ACCESS SURVIVOR VS NEMESIS", "ACCESS SURVIVOR VS ASSASIN", "ACCESS SNIPER VS ASSASIN", 
	"ACCESS SNIPER VS NEMESIS", "ACCESS BOMBARDIER VS GRENADIER", "ACCESS NIGHTMARE", "ACCESS RELOAD ADMINS", "ACCESS POINTS" }

	for (new i = 0; i < MAX_ACCESS_FLAGS; i++)
	{
		AmxLoadString("zombie_queen/AccessFlags.ini", "Access Flags", access_names[i], user_access, charsmax(user_access))
		g_accessFlag[i] = user_access[0]

		log_amx("%s = %c", access_names[i], g_accessFlag[i])
	}

	// Section Player models
	new player_model_names[MAX_CLASS_MODELS][] = { "HUMAN", "SURVIVOR", "SNIPER", "SAMURAI", "GRENADIER", "TERMINATOR", "ASSASIN", "NEMESIS", "BOMBARDIER", "REVENANT", "OWNER", "ADMIN", "VIP" }

	for (i = 0; i < MAX_CLASS_MODELS; i++)
	{
		AmxLoadStringArray("zombie_queen/Models.ini", "Class Models", player_model_names[i], g_playerModel[i])

		log_amx("----- %s = %i -----", player_model_names[i], ArraySize(g_playerModel[i]))

		for (new j = 0; j < ArraySize(g_playerModel[i]); j++)
		{
			ArrayGetString(g_playerModel[i], j, buffer, charsmax(buffer))
			log_amx("%s", buffer)
		}
	}

	// Section Weapon models
	new weapon_model_names[MAX_WEAPON_MODELS][] = { "V KNIFE HUMAN", "P KNIFE HUMAN", "V KNIFE NEMESIS", "V KNIFE ASSASIN", "V KNIFE REVENANT", "V KNIFE SAMURAI", "P KNIFE SAMURAI", "V AWP SNIPER", 
	"P AWP SNIPER", "V INFECTION NADE", "V EXPLOSION NADE", "V NAPALM NADE", "V FROST NADE" }

	for (i = 0; i < MAX_WEAPON_MODELS; i++)
	{
		AmxLoadStringArray("zombie_queen/Models.ini", "Weapon Models", weapon_model_names[i], g_weaponModels[i])

		log_amx("----- %s = %i -----", weapon_model_names[i], ArraySize(g_weaponModels[i]))

		for (new j = 0; j < ArraySize(g_weaponModels[i]); j++)
		{
			ArrayGetString(g_weaponModels[i], j, buffer, charsmax(buffer))
			log_amx("%s", buffer)
		}
	}

	// Section Sprites
	new sprite_names[MAX_SPRITES][] = { "GRENADE TRAIL", "GRENADE EXPLOSION" }

	for (i = 0; i < MAX_SPRITES; i++)
	{
		AmxLoadStringArray("zombie_queen/Grenades.ini", "Grenade Sprites", sprite_names[i], g_sprites[i])

		log_amx("----- %s = %i -----", sprite_names[i], ArraySize(g_sprites[i]))

		for (new j = 0; j < ArraySize(g_sprites[i]); j++)
		{
			ArrayGetString(g_sprites[i], j, buffer, charsmax(buffer))
			log_amx("%s", buffer)
		}
	}

	// Section colors
	new keyTrailNadeRGB[__MAX_NADE_TYPE][] = { "INFECTION TRAIL & GLOW RGB", "EXPLOSION TRAIL & GLOW RGB", "NAPALM TRAIL & GLOW RGB", "FROST TRAIL & GLOW RGB", "FORCEFIELD TRAIL & GLOW RGB", "KILLING TRAIL & GLOW RGB", "CONCUSSION TRAIL & GLOW RGB", "ANTIDOTE TRAIL & GLOW RGB" }
	
	for (i = 0; i < __MAX_NADE_TYPE; i++)
	{
		AmxLoadString("zombie_queen/Grenades.ini", "Grenade Trail & Glow Color", keyTrailNadeRGB[i], buffer, charsmax(buffer))

		parse(buffer, rgb[0], charsmax(rgb[]), rgb[1], charsmax(rgb[]), rgb[2], charsmax(rgb[]))
		g_color[i][__red]   = str_to_num(rgb[0])
		g_color[i][__green] = str_to_num(rgb[1])
		g_color[i][__blue]  = str_to_num(rgb[2])

		log_amx("%s = %i %i %i", keyTrailNadeRGB[i], g_color[i][__red], g_color[i][__green], g_color[i][__blue])
	}

	// Ambience Sounds
	new keyAmbience[MAX_AMBIENCE_SOUNDS][] = { "AMBIENCE SURVIVOR", "AMBIENCE SNIPER", "AMBIENCE SAMURAI", "AMBIENCE GRENADIER", "AMBIENCE TERMINATOR", "AMBIENCE ASSASIN", "AMBIENCE NEMESIS", "AMBIENCE BOMBARDIER",
	"AMBIENCE REVENANT", "AMBIENCE INFECTION", "AMBIENCE MULTI INFECTION", "AMBIENCE SWARM", "AMBIENCE PLAGUE", "AMBIENCE SYNAPSIS", "AMBIENCE SURVIVOR VS NEMESIS", "AMBIENCE SURVIVOR VS ASSASIN", "AMBIENCE SNIPER VS NEMESIS",
	"AMBIENCE SNIPER VS ASSASIN", "AMBIENCE BOMBARDIER VS GRENADIER", "AMBIENCE NIGHTMARE" }

	for (i = 0; i < MAX_AMBIENCE_SOUNDS; i++)
	{
		AmxLoadStringArray("zombie_queen/Sounds.ini", "Ambience Sounds", keyAmbience[i], g_ambience[i])

		log_amx("%s = %i", keyAmbience[i], ArraySize(g_ambience[i]))

		for (new j = 0; j < ArraySize(g_ambience[i]); j++)
		{
			ArrayGetString(g_ambience[i], j, buffer, charsmax(buffer))
			log_amx("%s", buffer)
		}
	}

	// Round start sounds
	new keyStartSounds[MAX_START_SOUNDS][] = { "SOUND HUMAN WIN", "SOUND ZOMBIE WIN", "SOUND WIN NO ONE", "SOUND SURVIVOR", "SOUND SNIPER", "SOUND SAMURAI", "SOUND GRENADIER", "SOUND TERMINATOR", "SOUND ASSASIN", "SOUND NEMESIS",
	"SOUND BOMBARDIER", "SOUND REVENANT", "SOUND MULTI INFECTION", "SOUND SWARM", "SOUND PLAGUE", "SOUND SYNAPSIS", "SOUND SURVIVOR VS NEMESIS", "SOUND SURVIVOR VS ASSASIN", "SOUND SNIPER VS NEMESIS",
	"SOUND SNIPER VS ASSASIN", "SOUND BOMBARDIER VS GRENADIER", "SOUND NIGHTMARE" }

	for (i = 0; i < MAX_START_SOUNDS; i++)
	{
		AmxLoadStringArray("zombie_queen/Sounds.ini", "Round Start Sounds", keyStartSounds[i], g_startSound[i])

		log_amx("%s = %i", keyStartSounds[i], ArraySize(g_startSound[i]))

		for (new j = 0; j < ArraySize(g_startSound[i]); j++)
		{
			ArrayGetString(g_startSound[i], j, buffer, charsmax(buffer))
			log_amx("%s", buffer)
		}
	}

	// Misc sounds
	new keyMiscSounds[MAX_MISC_SOUNDS][] = { "ZOMBIE INFECT", "ZOMBIE PAIN", "NEMESIS PAIN", "ASSASIN PAIN", "REVENANT PAIN", "ZOMBIE DIE", "ZOMBIE FALL", "ZOMBIE MISS SLASH", "ZOMBIE MISS WALL", "ZOMBIE HIT NORMAL",
	"ZOMBIE HIT STAB", "ZOMBIE IDLE", "ZOMBIE IDLE LAST", "ZOMBIE MADNESS", "GRENADE INFECT", "GRENADE INFECT PLAYER", "GRENADE FIRE", "GRENADE FIRE PLAYER", "GRENADE FROST", "GRENADE FROST PLAYER", "GRENADE FROST BREAK", "ANTIDOTE" }

	for (i = 0; i < MAX_MISC_SOUNDS; i++)
	{
		AmxLoadStringArray("zombie_queen/Sounds.ini", "Misc Sounds", keyMiscSounds[i], g_miscSounds[i])
		
		log_amx("%s = %i", keyMiscSounds[i], ArraySize(g_miscSounds[i]))

		for (new j = 0; j < ArraySize(g_miscSounds[i]); j++)
		{
			ArrayGetString(g_miscSounds[i], j, buffer, charsmax(buffer))
			log_amx("%s", buffer)
		}
	}

	// Custom class data

	// Human
	AmxLoadInt("zombie_queen/Class.ini", "Human", "Health", HumanHealth)
	AmxLoadFloat("zombie_queen/Class.ini", "Human", "Speed", HumanSpeed)
	AmxLoadFloat("zombie_queen/Class.ini", "Human", "Gravity", HumanGravity)
	AmxLoadInt("zombie_queen/Class.ini", "Human", "Armor Protect", HumanArmorProtect)
	AmxLoadInt("zombie_queen/Class.ini", "Human", "Last Human Extra Health", LastHumanExtraHealth)

	// Survivor
	AmxLoadInt("zombie_queen/Class.ini", "Survivor", "Enabled", SurvivorEnabled)
	AmxLoadInt("zombie_queen/Class.ini", "Survivor", "Chance", SurvivorChance)
	AmxLoadInt("zombie_queen/Class.ini", "Survivor", "Minimum Players", SurvivorMinPlayers)
	AmxLoadInt("zombie_queen/Class.ini", "Survivor", "Health", SurvivorHealth)
	AmxLoadFloat("zombie_queen/Class.ini", "Survivor", "Speed", SurvivorSpeed)
	AmxLoadFloat("zombie_queen/Class.ini", "Survivor", "Gravity", SurvivorGravity)
	AmxLoadInt("zombie_queen/Class.ini", "Survivor", "Glow", SurvivorGlow)

	AmxLoadString("zombie_queen/Class.ini", "Survivor", "Glow RGB", buffer, charsmax(buffer))

	parse(buffer, rgb[0], charsmax(rgb[]), rgb[1], charsmax(rgb[]), rgb[2], charsmax(rgb[]))
	g_glowColor[__survivor][__red]   = str_to_num(rgb[0])
	g_glowColor[__survivor][__green] = str_to_num(rgb[1])
	g_glowColor[__survivor][__blue]  = str_to_num(rgb[2])

	log_amx("Survivor Glow RGB = %i %i %i", g_glowColor[__survivor][__red], g_glowColor[__survivor][__green], g_glowColor[__survivor][__blue])

	// Sniper
	AmxLoadInt("zombie_queen/Class.ini", "Sniper", "Enabled", SniperEnabled)
	AmxLoadInt("zombie_queen/Class.ini", "Sniper", "Chance", SniperChance)
	AmxLoadInt("zombie_queen/Class.ini", "Sniper", "Minimum Players", SniperMinPlayers)
	AmxLoadInt("zombie_queen/Class.ini", "Sniper", "Health", SniperHealth)
	AmxLoadFloat("zombie_queen/Class.ini", "Sniper", "Speed", SniperSpeed)
	AmxLoadFloat("zombie_queen/Class.ini", "Sniper", "Gravity", SniperGravity)
	AmxLoadFloat("zombie_queen/Class.ini", "Sniper", "Damage", SniperDamage)
	AmxLoadInt("zombie_queen/Class.ini", "Sniper", "Glow", SniperGlow)

	AmxLoadString("zombie_queen/Class.ini", "Sniper", "Glow RGB", buffer, charsmax(buffer))

	parse(buffer, rgb[0], charsmax(rgb[]), rgb[1], charsmax(rgb[]), rgb[2], charsmax(rgb[]))
	g_glowColor[__sniper][__red]   = str_to_num(rgb[0])
	g_glowColor[__sniper][__green] = str_to_num(rgb[1])
	g_glowColor[__sniper][__blue]  = str_to_num(rgb[2])

	log_amx("Sniper Glow RGB = %i %i %i", g_glowColor[__sniper][__red], g_glowColor[__sniper][__green], g_glowColor[__sniper][__blue])

	// Samurai
	AmxLoadInt("zombie_queen/Class.ini", "Samurai", "Enabled", SamuraiEnabled)
	AmxLoadInt("zombie_queen/Class.ini", "Samurai", "Chance", SamuraiChance)
	AmxLoadInt("zombie_queen/Class.ini", "Samurai", "Minimum Players", SamuraiMinPlayers)
	AmxLoadInt("zombie_queen/Class.ini", "Samurai", "Health", SamuraiHealth)
	AmxLoadFloat("zombie_queen/Class.ini", "Samurai", "Speed", SamuraiSpeed)
	AmxLoadFloat("zombie_queen/Class.ini", "Samurai", "Gravity", SamuraiGravity)
	AmxLoadFloat("zombie_queen/Class.ini", "Samurai", "Damage", SamuraiDamage)
	AmxLoadInt("zombie_queen/Class.ini", "Samurai", "Glow", SamuraiGlow)

	AmxLoadString("zombie_queen/Class.ini", "Samurai", "Glow RGB", buffer, charsmax(buffer))

	parse(buffer, rgb[0], charsmax(rgb[]), rgb[1], charsmax(rgb[]), rgb[2], charsmax(rgb[]))
	g_glowColor[__samurai][__red]   = str_to_num(rgb[0])
	g_glowColor[__samurai][__green] = str_to_num(rgb[1])
	g_glowColor[__samurai][__blue]  = str_to_num(rgb[2])

	log_amx("Samurai Glow RGB = %i %i %i", g_glowColor[__samurai][__red], g_glowColor[__samurai][__green], g_glowColor[__samurai][__blue])

	// Grenadier
	AmxLoadInt("zombie_queen/Class.ini", "Grenadier", "Enabled", GrenadierEnabled)
	AmxLoadInt("zombie_queen/Class.ini", "Grenadier", "Chance", GrenadierChance)
	AmxLoadInt("zombie_queen/Class.ini", "Grenadier", "Minimum Players", GrenadierMinPlayers)
	AmxLoadInt("zombie_queen/Class.ini", "Grenadier", "Health", GrenadierHealth)
	AmxLoadFloat("zombie_queen/Class.ini", "Grenadier", "Speed", GrenadierSpeed)
	AmxLoadFloat("zombie_queen/Class.ini", "Grenadier", "Gravity", GrenadierGravity)
	AmxLoadFloat("zombie_queen/Class.ini", "Grenadier", "Damage", GrenadierDamage)
	AmxLoadInt("zombie_queen/Class.ini", "Grenadier", "Glow", GrenadierGlow)

	AmxLoadString("zombie_queen/Class.ini", "Grenadier", "Glow RGB", buffer, charsmax(buffer))

	parse(buffer, rgb[0], charsmax(rgb[]), rgb[1], charsmax(rgb[]), rgb[2], charsmax(rgb[]))
	g_glowColor[__grenadier][__red]   = str_to_num(rgb[0])
	g_glowColor[__grenadier][__green] = str_to_num(rgb[1])
	g_glowColor[__grenadier][__blue]  = str_to_num(rgb[2])

	log_amx("Grenadier Glow RGB = %i %i %i", g_glowColor[__grenadier][__red], g_glowColor[__grenadier][__green], g_glowColor[__grenadier][__blue])

	// Terminator
	AmxLoadInt("zombie_queen/Class.ini", "Terminator", "Enabled", TerminatorEnabled)
	AmxLoadInt("zombie_queen/Class.ini", "Terminator", "Chance", TerminatorChance)
	AmxLoadInt("zombie_queen/Class.ini", "Terminator", "Minimum Players", TerminatorMinPlayers)
	AmxLoadInt("zombie_queen/Class.ini", "Terminator", "Health", TerminatorHealth)
	AmxLoadFloat("zombie_queen/Class.ini", "Terminator", "Speed", TerminatorSpeed)
	AmxLoadFloat("zombie_queen/Class.ini", "Terminator", "Gravity", TerminatorGravity)
	AmxLoadInt("zombie_queen/Class.ini", "Terminator", "Glow", TerminatorGlow)

	AmxLoadString("zombie_queen/Class.ini", "Terminator", "Glow RGB", buffer, charsmax(buffer))

	parse(buffer, rgb[0], charsmax(rgb[]), rgb[1], charsmax(rgb[]), rgb[2], charsmax(rgb[]))
	g_glowColor[__terminator][__red]   = str_to_num(rgb[0])
	g_glowColor[__terminator][__green] = str_to_num(rgb[1])
	g_glowColor[__terminator][__blue]  = str_to_num(rgb[2])

	log_amx("Terminator Glow RGB = %i %i %i", g_glowColor[__terminator][__red], g_glowColor[__terminator][__green], g_glowColor[__terminator][__blue])

	// Tryder
	AmxLoadInt("zombie_queen/Class.ini", "Tryder", "Health", TryderHealth)
	AmxLoadFloat("zombie_queen/Class.ini", "Tryder", "Speed", TryderSpeed)
	AmxLoadFloat("zombie_queen/Class.ini", "Tryder", "Gravity", TryderGravity)
	AmxLoadInt("zombie_queen/Class.ini", "Tryder", "Glow", TryderGlow)

	// Assassin
	AmxLoadInt("zombie_queen/Class.ini", "Assasin", "Enabled", AssassinEnabled)
	AmxLoadInt("zombie_queen/Class.ini", "Assasin", "Chance", AssassinChance)
	AmxLoadInt("zombie_queen/Class.ini", "Assasin", "Minimum Players", AssassinMinPlayers)
	AmxLoadInt("zombie_queen/Class.ini", "Assasin", "Health", AssassinHealth)
	AmxLoadFloat("zombie_queen/Class.ini", "Assasin", "Speed", AssassinSpeed)
	AmxLoadFloat("zombie_queen/Class.ini", "Assasin", "Gravity", AssassinGravity)
	AmxLoadFloat("zombie_queen/Class.ini", "Assasin", "Damage", AssassinDamage)
	AmxLoadInt("zombie_queen/Class.ini", "Assasin", "Glow", AssassinGlow)

	AmxLoadString("zombie_queen/Class.ini", "Assasin", "Glow RGB", buffer, charsmax(buffer))

	parse(buffer, rgb[0], charsmax(rgb[]), rgb[1], charsmax(rgb[]), rgb[2], charsmax(rgb[]))
	g_glowColor[__assasin][__red]   = str_to_num(rgb[0])
	g_glowColor[__assasin][__green] = str_to_num(rgb[1])
	g_glowColor[__assasin][__blue]  = str_to_num(rgb[2])

	log_amx("Assasin Glow RGB = %i %i %i", g_glowColor[__assasin][__red], g_glowColor[__assasin][__green], g_glowColor[__assasin][__blue])

	// Nemesis
	AmxLoadInt("zombie_queen/Class.ini", "Nemesis", "Enabled", NemesisEnabled)
	AmxLoadInt("zombie_queen/Class.ini", "Nemesis", "Chance", NemesisChance)
	AmxLoadInt("zombie_queen/Class.ini", "Nemesis", "Minimum Players", NemesisMinPlayers)
	AmxLoadInt("zombie_queen/Class.ini", "Nemesis", "Health", NemesisHealth)
	AmxLoadFloat("zombie_queen/Class.ini", "Nemesis", "Speed", NemesisSpeed)
	AmxLoadFloat("zombie_queen/Class.ini", "Nemesis", "Gravity", NemesisGravity)
	AmxLoadFloat("zombie_queen/Class.ini", "Nemesis", "Damage", NemesisDamage)
	AmxLoadInt("zombie_queen/Class.ini", "Nemesis", "Glow", NemesisGlow)

	AmxLoadString("zombie_queen/Class.ini", "Nemesis", "Glow RGB", buffer, charsmax(buffer))

	parse(buffer, rgb[0], charsmax(rgb[]), rgb[1], charsmax(rgb[]), rgb[2], charsmax(rgb[]))
	g_glowColor[__nemesis][__red]   = str_to_num(rgb[0])
	g_glowColor[__nemesis][__green] = str_to_num(rgb[1])
	g_glowColor[__nemesis][__blue]  = str_to_num(rgb[2])

	log_amx("Nemesis Glow RGB = %i %i %i", g_glowColor[__nemesis][__red], g_glowColor[__nemesis][__green], g_glowColor[__nemesis][__blue])

	// Bombardier
	AmxLoadInt("zombie_queen/Class.ini", "Bombardier", "Enabled", BombardierEnabled)
	AmxLoadInt("zombie_queen/Class.ini", "Bombardier", "Chance", BombardierChance)
	AmxLoadInt("zombie_queen/Class.ini", "Bombardier", "Minimum Players", BombardierMinPlayers)
	AmxLoadInt("zombie_queen/Class.ini", "Bombardier", "Health", BombardierHealth)
	AmxLoadFloat("zombie_queen/Class.ini", "Bombardier", "Speed", BombardierSpeed)
	AmxLoadFloat("zombie_queen/Class.ini", "Bombardier", "Gravity", BombardierGravity)
	AmxLoadFloat("zombie_queen/Class.ini", "Bombardier", "Damage", BombardierDamage)
	AmxLoadInt("zombie_queen/Class.ini", "Bombardier", "Glow", BombardierGlow)

	AmxLoadString("zombie_queen/Class.ini", "Bombardier", "Glow RGB", buffer, charsmax(buffer))

	parse(buffer, rgb[0], charsmax(rgb[]), rgb[1], charsmax(rgb[]), rgb[2], charsmax(rgb[]))
	g_glowColor[__bombardier][__red]   = str_to_num(rgb[0])
	g_glowColor[__bombardier][__green] = str_to_num(rgb[1])
	g_glowColor[__bombardier][__blue]  = str_to_num(rgb[2])

	log_amx("Bombardier Glow RGB = %i %i %i", g_glowColor[__bombardier][__red], g_glowColor[__bombardier][__green], g_glowColor[__bombardier][__blue])

	// Revenant
	AmxLoadInt("zombie_queen/Class.ini", "Revenant", "Enabled", RevenantEnabled)
	AmxLoadInt("zombie_queen/Class.ini", "Revenant", "Chance", RevenantChance)
	AmxLoadInt("zombie_queen/Class.ini", "Revenant", "Minimum Players", RevenantMinPlayers)
	AmxLoadInt("zombie_queen/Class.ini", "Revenant", "Health", RevenantHealth)
	AmxLoadFloat("zombie_queen/Class.ini", "Revenant", "Speed", RevenantSpeed)
	AmxLoadFloat("zombie_queen/Class.ini", "Revenant", "Gravity", Revenantgravity)
	AmxLoadFloat("zombie_queen/Class.ini", "Revenant", "Damage", RevenantDamage)
	AmxLoadInt("zombie_queen/Class.ini", "Revenant", "Glow", RevenantGlow)

	AmxLoadString("zombie_queen/Class.ini", "Revenant", "Glow RGB", buffer, charsmax(buffer))

	parse(buffer, rgb[0], charsmax(rgb[]), rgb[1], charsmax(rgb[]), rgb[2], charsmax(rgb[]))
	g_glowColor[__revenant][__red]   = str_to_num(rgb[0])
	g_glowColor[__revenant][__green] = str_to_num(rgb[1])
	g_glowColor[__revenant][__blue]  = str_to_num(rgb[2])

	log_amx("Revenant Glow RGB = %i %i %i", g_glowColor[__revenant][__red], g_glowColor[__revenant][__green], g_glowColor[__revenant][__blue])

	// // Knockback
	AmxLoadInt("zombie_queen/Class.ini", "Knockback", "Enabled", KnockbackEnabled)
	AmxLoadInt("zombie_queen/Class.ini", "Knockback", "Distance", KnockbackDistance)
	AmxLoadFloat("zombie_queen/Class.ini", "Knockback", "Ducking", KnockbackDucking)
	AmxLoadFloat("zombie_queen/Class.ini", "Knockback", "Assasin", KnockbackAssassin)
	AmxLoadFloat("zombie_queen/Class.ini", "Knockback", "Nemesis", KnockbackNemesis)
	AmxLoadFloat("zombie_queen/Class.ini", "Knockback", "Bombardier", KnockbackBombardier)
	AmxLoadFloat("zombie_queen/Class.ini", "Knockback", "Revenant", KnockbackRevenant)

	// Painfree
	AmxLoadInt("zombie_queen/Class.ini", "Painshock", "Survivor", SurvivorPainfree)
	AmxLoadInt("zombie_queen/Class.ini", "Painshock", "Sniper", SniperPainfree)
	AmxLoadInt("zombie_queen/Class.ini", "Painshock", "Samurai", SamuraiPainfree)
	AmxLoadInt("zombie_queen/Class.ini", "Painshock", "Grenadier", GrenadierPainfree)
	AmxLoadInt("zombie_queen/Class.ini", "Painshock", "Terminator", TerminatorPainfree)
	AmxLoadInt("zombie_queen/Class.ini", "Painshock", "Assasin", AssassinPainfree)
	AmxLoadInt("zombie_queen/Class.ini", "Painshock", "Nemesis", NemesisPainfree)
	AmxLoadInt("zombie_queen/Class.ini", "Painshock", "Bombardier", BombardierPainfree)
	AmxLoadInt("zombie_queen/Class.ini", "Painshock", "Revenant", RevenantPainfree)

	// Leap configs
	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Zombie", LeapZombies)
	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Zombie Force", LeapZombiesForce)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Zombie Height", LeapZombiesHeight)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Zombie Cooldown", LeapZombiesCooldown)

	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Nemesis", LeapNemesis)
	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Nemesis Force", LeapNemesisForce)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Nemesis Height", LeapNemesisHeight)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Nemesis Cooldown", LeapNemesisCooldown)

	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Assasin", LeapAssassin)
	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Assasin Force", LeapAssassinForce)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Assasin Height", LeapAssassinHeight)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Assasin Cooldown", LeapAssassinCooldown)

	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Revenant", LeapRevenant)
	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Revenant Force", LeapRevenantForce)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Revenant Height", LeapRevenantHeight)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Revenant Cooldown", LeapRevenantCooldown)

	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Bombardier", LeapBombardier)
	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Bombardier Force", LeapBombardierForce)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Bombardier Height", LeapBombardierHeight)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Bombardier Cooldown", LeapBombardierCooldown)

	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Survivor", LeapSurvivor)
	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Survivor Force", LeapSurvivorForce)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Survivor Height", LeapSurvivorHeight)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Survivor Cooldown", LeapSurvivorCooldown)

	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Sniper", LeapSniper)
	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Sniper Force", LeapSniperForce)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Sniper Height", LeapSniperHeight)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Sniper Cooldown", LeapSniperCooldown)

	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Samurai", LeapSamurai)
	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Samurai Force", LeapSamuraiForce)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Samurai Height", LeapSamuraiHeight)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Samurai Cooldown", LeapSamuraiCooldown)

	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Grenadier", LeapGrenadier)
	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Grenadier Force", LeapGrenadierForce)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Grenadier Height", LeapGrenadierHeight)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Grenadier Cooldown", LeapGrenadierCooldown)

	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Terminator", LeapTerminator)
	AmxLoadInt("zombie_queen/Class.ini", "Leap", "Terminator Force", LeapTerminatorForce)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Terminator Height", LeapTerminatorHeight)
	AmxLoadFloat("zombie_queen/Class.ini", "Leap", "Terminator Cooldown", LeapTerminatorCooldown)

	// Custom rounds configs

	// Multi Infection
	AmxLoadInt("zombie_queen/Modes.ini", "Multi-Infection", "ENABLE", MultiInfection_enable)
	log_amx("Multi Enable = %i", MultiInfection_enable)
	AmxLoadInt("zombie_queen/Modes.ini", "Multi-Infection", "CHANCE", MultiInfection_chance)
	log_amx("Multi Chance = %i", MultiInfection_chance)
	AmxLoadInt("zombie_queen/Modes.ini", "Multi-Infection", "MIN PLAYERS", MultiInfection_minPlayers)
	log_amx("Multi Min Players = %i", MultiInfection_minPlayers)
	AmxLoadFloat("zombie_queen/Modes.ini", "Multi-Infection", "RATIO", MultiInfection_ratio)
	log_amx("Multi Ratio = %f", MultiInfection_ratio)

	// Swarm
	AmxLoadInt("zombie_queen/Modes.ini", "Swarm", "ENABLE", Swarm_enable)
	log_amx("Swarm Enable = %i", Swarm_enable)
	AmxLoadInt("zombie_queen/Modes.ini", "Swarm", "CHANCE", Swarm_chance)
	log_amx("Swarm chance = %i", Swarm_chance)
	AmxLoadInt("zombie_queen/Modes.ini", "Swarm", "MIN PLAYERS", Swarm_minPlayers)
	log_amx("Swarm Min Players = %i", Swarm_minPlayers)

	// Plague
	AmxLoadInt("zombie_queen/Modes.ini", "Plague", "ENABLE", Plague_enable)
	log_amx("Plague enable = %i", Plague_enable)
	AmxLoadInt("zombie_queen/Modes.ini", "Plague", "CHANCE", Plague_chance)
	log_amx("Plague chance = %i", Plague_chance)
	AmxLoadInt("zombie_queen/Modes.ini", "Plague", "MIN PLAYERS", Plague_minPlayers)
	log_amx("Plague Min Players = %i", Plague_minPlayers)
	AmxLoadFloat("zombie_queen/Modes.ini", "Plague", "RATIO", Plague_ratio)
	log_amx("Plague Ratio = %f", Plague_ratio)
	AmxLoadInt("zombie_queen/Modes.ini", "Plague", "NEMESIS COUNT", Plague_nemesisCount)
	log_amx("Plague Nem Count = %i", Plague_nemesisCount)
	AmxLoadFloat("zombie_queen/Modes.ini", "Plague", "NEMESIS HEALTH MULTIPLY", Plague_nemesis_HealthMultiply)
	log_amx("Plague nem hp mul = %f", Plague_nemesis_HealthMultiply)
	AmxLoadInt("zombie_queen/Modes.ini", "Plague", "SURVIVOR COUNT", Plague_survivorCount)
	log_amx("Plague surv count = %i", Plague_survivorCount)
	AmxLoadFloat("zombie_queen/Modes.ini", "Plague", "SURVIVOR HEALTH MULTIPLY", Plague_survivor_HealthMultiply)
	log_amx("Plague surv hp mul = %f", Plague_survivor_HealthMultiply)

	// Synapsis
	AmxLoadInt("zombie_queen/Modes.ini", "Synapsis", "ENABLE", Synapsis_enable)
	log_amx("Synapsis enable = %i", Synapsis_enable)
	AmxLoadInt("zombie_queen/Modes.ini", "Synapsis", "CHANCE", Synapsis_chance)
	log_amx("Synapsis chance = %i", Synapsis_chance)
	AmxLoadInt("zombie_queen/Modes.ini", "Synapsis", "MIN PLAYERS", Synapsis_minPlayers)
	log_amx("Synapsis min players = %i", Synapsis_minPlayers)
	AmxLoadFloat("zombie_queen/Modes.ini", "Synapsis", "RATIO", Synapsis_ratio)
	log_amx("Synapsis ratio = %f", Synapsis_ratio)
	AmxLoadInt("zombie_queen/Modes.ini", "Synapsis", "NEMESIS COUNT", Synapsis_nemesisCount)
	log_amx("Syanpsis nem count = %i", Synapsis_nemesisCount)
	AmxLoadFloat("zombie_queen/Modes.ini", "Synapsis", "NEMESIS HEALTH MULTIPLY", Synapsis_nemesis_HealthMultiply)
	log_amx("Synapsis nem hp mul = %f", Synapsis_nemesis_HealthMultiply)
	AmxLoadInt("zombie_queen/Modes.ini", "Synapsis", "SURVIVOR COUNT", Synapsis_survivorCount)
	log_amx("Synapsis surv count = %i", Synapsis_survivorCount)
	AmxLoadFloat("zombie_queen/Modes.ini", "Synapsis", "SURVIVOR HEALTH MULTIPLY", Synapsis_survivor_HealthMultiply)
	log_amx("Synapsis surv hp mul = %f", Synapsis_survivor_HealthMultiply)
	AmxLoadInt("zombie_queen/Modes.ini", "Synapsis", "SNIPER COUNT", Synapsis_sniperCount)
	log_amx("Synapsis sni count = %i", Synapsis_sniperCount)
	AmxLoadFloat("zombie_queen/Modes.ini", "Synapsis", "SNIPER HEALTH MULTIPLY", Synapsis_sniper_HealthMultiply)
	log_amx("Synapsis sni hp mul = %f", Synapsis_sniper_HealthMultiply)

	// Survior vs Assasin
	AmxLoadInt("zombie_queen/Modes.ini", "Survivor vs Assasin", "ENABLE", SurvivorVsAssasin_enable)
	log_amx("SVA anable = %i", SurvivorVsAssasin_enable)
	AmxLoadInt("zombie_queen/Modes.ini", "Survivor vs Assasin", "CHANCE", SurvivorVsAssasin_chance)
	log_amx("SVA chance = %i", SurvivorVsAssasin_chance)
	AmxLoadInt("zombie_queen/Modes.ini", "Survivor vs Assasin", "MIN PLAYERS", SurvivorVsAssasin_minPlayers)
	log_amx("SVA min players = %i", SurvivorVsAssasin_minPlayers)
	AmxLoadFloat("zombie_queen/Modes.ini", "Survivor vs Assasin", "RATIO", SurvivorVsAssasin_ratio)
	log_amx("SVA ratio = %f", SurvivorVsAssasin_ratio)
	AmxLoadFloat("zombie_queen/Modes.ini", "Survivor vs Assasin", "ASSASIN HEALTH MULTIPLY", SurvivorVsAssasin_assasin_HealthMultiply)
	log_amx("SVA assa hp mul = %f", SurvivorVsAssasin_assasin_HealthMultiply)
	AmxLoadFloat("zombie_queen/Modes.ini", "Survivor vs Assasin", "SURVIVOR HEALTH MULTIPLY", SurvivorVsAssasin_survivor_HealthMultiply)
	log_amx("SVA surv hp mul = %f", SurvivorVsAssasin_survivor_HealthMultiply)

	// Survivor vs Nemesis
	AmxLoadInt("zombie_queen/Modes.ini", "Survivor vs Nemesis", "ENABLE", Armageddon_enable)
	log_amx("SNV enable = %i", Armageddon_enable)
	AmxLoadInt("zombie_queen/Modes.ini", "Survivor vs Nemesis", "CHANCE", Armageddon_chance)
	log_amx("SNV chance = %i", Armageddon_chance)
	AmxLoadInt("zombie_queen/Modes.ini", "Survivor vs Nemesis", "MIN PLAYERS", Armageddon_minPlayers)
	log_amx("SNV min player = %i", Armageddon_minPlayers)
	AmxLoadFloat("zombie_queen/Modes.ini", "Survivor vs Nemesis", "RATIO", Armageddon_ratio)
	log_amx("SNV ratio = %f", Armageddon_ratio)
	AmxLoadFloat("zombie_queen/Modes.ini", "Survivor vs Nemesis", "NEMESIS HEALTH MULTIPLY", Armageddon_nemesis_HealthMultiply)
	log_amx("SNV nem hp mul = %f", Armageddon_nemesis_HealthMultiply)
	AmxLoadFloat("zombie_queen/Modes.ini", "Survivor vs Nemesis", "SURVIVOR HEALTH MULTIPLY", Armageddon_survivor_HealthMultiply)
	log_amx("SNV surv hp mul = %f", Armageddon_survivor_HealthMultiply)

	// Sniper vs Assasin
	AmxLoadInt("zombie_queen/Modes.ini", "Sniper vs Assasin", "ENABLE", Apocalypse_enable)
	log_amx("SNVA enable = %i", Apocalypse_enable)
	AmxLoadInt("zombie_queen/Modes.ini", "Sniper vs Assasin", "CHANCE", Apocalypse_chance)
	log_amx("SNVA chance = %i", Apocalypse_chance)
	AmxLoadInt("zombie_queen/Modes.ini", "Sniper vs Assasin", "MIN PLAYERS", Apocalypse_minPlayers)
	log_amx("SNVA min players = %i", Apocalypse_minPlayers)
	AmxLoadFloat("zombie_queen/Modes.ini", "Sniper vs Assasin", "RATIO", Apocalypse_ratio)
	log_amx("SNVA ratio = %f", Apocalypse_ratio)
	AmxLoadFloat("zombie_queen/Modes.ini", "Sniper vs Assasin", "ASSASIN HEALTH MULTIPLY", Apocalypse_assasin_HealthMultiply)
	log_amx("SNVA assa hp mul = %f", Apocalypse_assasin_HealthMultiply)
	AmxLoadFloat("zombie_queen/Modes.ini", "Sniper vs Assasin", "SNIPER HEALTH MULTIPLY", Apocalypse_sniper_HealthMultiply)
	log_amx("SNVA sni hp mul = %f", Apocalypse_sniper_HealthMultiply)

	// Sniper vs Nemesis
	AmxLoadInt("zombie_queen/Modes.ini", "Sniper vs Nemesis", "ENABLE", SniperVsNemesis_enable)
	log_amx("SNVN enable = %i", SniperVsNemesis_enable)
	AmxLoadInt("zombie_queen/Modes.ini", "Sniper vs Nemesis", "CHANCE", SniperVsNemesis_chance)
	log_amx("SNVN chance = %i", SniperVsNemesis_chance)
	AmxLoadInt("zombie_queen/Modes.ini", "Sniper vs Nemesis", "MIN PLAYERS", SniperVsNemesis_minPlayers)
	log_amx("SNVN min players = %i", SniperVsNemesis_minPlayers)
	AmxLoadFloat("zombie_queen/Modes.ini", "Sniper vs Nemesis", "RATIO", SniperVsNemesis_ratio)
	log_amx("SNVN ratio = %f", SniperVsNemesis_ratio)
	AmxLoadFloat("zombie_queen/Modes.ini", "Sniper vs Nemesis", "SNIPER HEALTH MULTIPLY", SniperVsNemesis_sniper_HealthMultiply)
	log_amx("SNVN sni hp mul = %f", SniperVsNemesis_sniper_HealthMultiply)
	AmxLoadFloat("zombie_queen/Modes.ini", "Sniper vs Nemesis", "NEMESIS HEALTH MULTIPLY", SniperVsNemesis_nemesis_HealthMultiply)
	log_amx("SNVN nem hp mul = %f", SniperVsNemesis_nemesis_HealthMultiply)

	// Bombardier vs Grenadier
	AmxLoadInt("zombie_queen/Modes.ini", "Bombardier vs Grenadier", "ENABLE", BombardierVsGrenadier_enable)
	log_amx("BVG enable = %i", BombardierVsGrenadier_enable)
	AmxLoadInt("zombie_queen/Modes.ini", "Bombardier vs Grenadier", "CHANCE", BombardierVsGrenadier_chance)
	log_amx("BVG chance = %i", BombardierVsGrenadier_chance)
	AmxLoadInt("zombie_queen/Modes.ini", "Bombardier vs Grenadier", "MIN PLAYERS", BombardierVsGrenadier_minPlayers)
	log_amx("BVG min players = %i", BombardierVsGrenadier_minPlayers)
	AmxLoadFloat("zombie_queen/Modes.ini", "Bombardier vs Grenadier", "RATIO", BombardierVsGrenadier_ratio)
	log_amx("BVG ratio = %f", BombardierVsGrenadier_ratio)
	AmxLoadFloat("zombie_queen/Modes.ini", "Bombardier vs Grenadier", "BOMBARDIER HEALTH MULTIPLY", BombardierVsGrenadier_bombardier_HealthMultiply)
	log_amx("BVG bomb hp mul = %f", BombardierVsGrenadier_bombardier_HealthMultiply)
	AmxLoadFloat("zombie_queen/Modes.ini", "Bombardier vs Grenadier", "GRENADIER HEALTH MULTIPLY", BombardierVsGrenadier_grenadier_HealthMultiply)
	log_amx("BVG grenade hp mul = %f", BombardierVsGrenadier_grenadier_HealthMultiply)

	// Nightmare
	AmxLoadInt("zombie_queen/Modes.ini", "Nightmare", "ENABLE", Nightmare_enable)
	log_amx("NIGHTMARE enable = %i", Nightmare_enable)
	AmxLoadInt("zombie_queen/Modes.ini", "Nightmare", "CHANCE", Nightmare_chance)
	log_amx("NIGHTMARE chance = %i", Nightmare_chance)
	AmxLoadInt("zombie_queen/Modes.ini", "Nightmare", "MIN PLAYERS", Nightmare_minPlayers)
	log_amx("NIGHTMARE min players = %i", Nightmare_minPlayers)
	AmxLoadFloat("zombie_queen/Modes.ini", "Nightmare", "RATIO", Nightmare_ratio)
	log_amx("NIGHTMARE ratio = %f", Nightmare_ratio)
	AmxLoadFloat("zombie_queen/Modes.ini", "Nightmare", "ASSASIN HEALTH MULTIPLY", Nightmare_assasin_HealthMultiply)
	log_amx("NIGHTMARE assa hp mul = %f", Nightmare_assasin_HealthMultiply)
	AmxLoadFloat("zombie_queen/Modes.ini", "Nightmare", "NEMESIS HEALTH MULTIPLY", Nightmare_nemesis_HealthMultiply)
	log_amx("NIGHTMARE nem hp mul = %f", Nightmare_nemesis_HealthMultiply)
	AmxLoadFloat("zombie_queen/Modes.ini", "Nightmare", "SNIPER HEALTH MULTIPLY", Nightmare_sniper_HealthMultiply)
	log_amx("NIGHTMARE sni hp mul = %f", Nightmare_sniper_HealthMultiply)
	AmxLoadFloat("zombie_queen/Modes.ini", "Nightmare", "SURVIVOR HEALTH MULTIPLY", Nightmare_survivor_HealthMultiply)
	log_amx("NIGHTMARE surv hp mul = %f", Nightmare_survivor_HealthMultiply)

	// Free VIP
	AmxLoadInt("zombie_queen/Extras.ini", "FREE VIP", "START", freeVIP_Start)
	AmxLoadInt("zombie_queen/Extras.ini", "FREE VIP", "END", freeVIP_End)
	AmxLoadString("zombie_queen/Extras.ini", "FREE VIP", "FLAGS", freeVIP_Flags, charsmax(freeVIP_Flags))

	// Happy Hour
	AmxLoadInt("zombie_queen/Extras.ini", "HAPPY HOUR", "START", happyHour_Start)
	AmxLoadInt("zombie_queen/Extras.ini", "HAPPY HOUR", "END", happyHour_End)

	// Chat Prefix
	AmxLoadString("zombie_queen/Extras.ini", "MESSAGES", "CHAT PREFIX", CHAT_PREFIX, charsmax(CHAT_PREFIX))
	format(CHAT_PREFIX, charsmax(CHAT_PREFIX), "^4%s^1", CHAT_PREFIX)

	// Round Welcome message
	AmxLoadString("zombie_queen/Extras.ini", "MESSAGES", "ROUND WELCOME TEXT", ROUND_WELCOME_TEXT, charsmax(ROUND_WELCOME_TEXT))
	format(ROUND_WELCOME_TEXT, charsmax(ROUND_WELCOME_TEXT), "^1**** ^4%s ^1|| ^4Zombie Queen 11.5 ^1by ^3Eye NeO- ^1****", ROUND_WELCOME_TEXT)

	// Primary and secondary weapon sections
	new wpn_ids[32]
	AmxLoadStringArray("zombie_queen/Extras.ini", "BUY MENU WEAPONS", "WEAPON NAMES", g_full_weapon_names)

	AmxLoadStringArray("zombie_queen/Extras.ini", "BUY MENU WEAPONS", "PRIMARY", g_weapon_name[0])
	for (i = 0; i < ArraySize(g_weapon_name[0]); i++) 
	{
		ArrayGetString(g_weapon_name[0], i, wpn_ids, charsmax(wpn_ids))
		ArrayPushCell(g_weapon_ids[0], cs_weapon_name_to_id(wpn_ids))
		log_amx("cs_weapon_name_to_id = %i", cs_weapon_name_to_id(wpn_ids))
	}

	AmxLoadStringArray("zombie_queen/Extras.ini", "BUY MENU WEAPONS", "SECONDARY", g_weapon_name[1])
	for (i = 0; i < ArraySize(g_weapon_name[1]); i++) 
	{
		ArrayGetString(g_weapon_name[1], i, wpn_ids, charsmax(wpn_ids))
		ArrayPushCell(g_weapon_ids[1], cs_weapon_name_to_id(wpn_ids))	
		log_amx("cs_weapon_name_to_id = %i", cs_weapon_name_to_id(wpn_ids))
	}
}

// Forward enums
enum _: forwardNames
{
	ROUND_START = 0,
	ROUND_END,
	INFECT_ATTEMP,
	INFECTED_PRE,
	INFECTED_POST,
	HUMANIZE_ATTEMP,
	HUMANIZED_PRE,
	HUMANIZED_POST,
	USER_LAST_ZOMBIE,
	USER_LAST_HUMAN,
	ADMIN_MODE_START,
	EXTRA_ITEM_SELECTED,
	POINTS_SHOP_WEAPON_SELECTED,
	MAX_FORWARDS
	// PLAYER_SPAWN_POST,
	// FROZEN_PRE,
	// FROZEN_POST,
	// USER_UNFROZEN,
	// BURN_PRE,
	// BURN_POST,
	// INFECTED_BY_BOMB_PRE,
	// INFECTED_BY_BOMB_POST,
	// UNSTUCK_PRE,
	// UNSTUCK_POST,
	//ROUND_START_PRE,
	//ITEM_SELECTED_PRE,
	//ITEM_SELECTED_POST,
	//CLASS_CHOOSED_PRE,
	//CLASS_CHOOSED_POST,
	//RESET_RENDERING_PRE,
	//RESET_RENDERING_POST,
	//MODEL_CHANGE_PRE,
	//MODEL_CHANGE_POST,
	//HM_SP_CHOSSED_PRE,
	//ZM_SP_CHOSSED_PRE,
	//HM_SP_CHOSSED_POST,
	//ZM_SP_CHOSSED_POST,
	//GM_SELECTED_PRE,
	//WEAPON_SELECTED_PRE,
	//WEAPON_SELECTED_POST,
}
new g_forwards[MAX_FORWARDS], g_forwardRetVal

// Custom forward return values
const ZP_PLUGIN_HANDLED = 97
const ZP_PLUGIN_SUPERCEDE = 98

enum _:ZMenuData
{
	ZombieName[14],
	ZombieAttribute[40],
	Health,
	Float:Speed,
	Float:Gravity,
	Float:Knockback,
	Model[64],
	ClawModel[64]
}

new g_cZombieClasses[][ZMenuData] =
{
	{"Clasic", 			"\r[=Balanced=]", 	  	8000, 264.0, 1.00, 0.82, 	"PerfectZM_Classic", 		 	 "models/PerfectZM/PerfectZM_classic_claws.mdl"},
	{"Raptor", 			"\r[Speed +++]", 	  	7350, 304.0, 1.00, 1.33, 	"PerfectZM_Raptor", 			 "models/PerfectZM/PerfectZM_raptor_claws.mdl"},
	{"Mutant", 			"\r[Health +++]", 	  	14000, 276.0, 0.74, 0.70, 	"PerfectZM_Mutant", 			 "models/PerfectZM/PerfectZM_mutant_claws.mdl"},
	{"Frost", 			"\r[Freeze humans]", 	6550, 244.0, 1.00, 0.44, 	"PerfectZM_Frozen", 			 "models/PerfectZM/PerfectZM_frozen_claws.mdl"},
	{"Regenerator", 	"\r[Regeneration]",   	7000, 269.0, 0.61, 0.80, 	"PerfectZM_Regenerator", 	 	 "models/PerfectZM/PerfectZM_regenerator_claws.mdl"},
	{"Predator Blue", 	"\r[Invisiblity]", 	  	10000, 249.0, 1.00, 0.90, 	"PerfectZM_Predator", 	 	 	 "models/PerfectZM/PerfectZM_predator_claws.mdl"},
	{"Hunter", 			"\r[Stuns weapons]",    9000, 273.0, 0.61, 0.83, 	"PerfectZM_Hunter", 			 "models/PerfectZM/PerfectZM_hunter_claws.mdl"}
}


enum _:PMenuData
{
	_pName[20]
}

new g_cPointsMenu[][PMenuData] =
{
	{"Buy Ammo Packs"},
	{"Buy Features"},
	{"Buy Modes"},
	{"Buy Premium weapons"}
}

enum _:AMenuData
{
	_ammoItemName[20],
	_ammoItemTag[32],
	_ammoItemPrice
}

new g_cAmmoMenu[][AMenuData] =
{
	{"Buy 100 packs", "\r[100 points]", 100},
	{"Buy 200 packs", "\r[200 points]", 200},
	{"Buy 300 packs", "\r[300 points]", 300},
	{"Buy 400 packs", "\r[400 points]", 400},
	{"Buy 500 packs", "\r[500 points]", 500}
}

enum _:FMenuData
{
	_fItemName[32],
	_fItemTag[32],
	_fItemPrice
}

new g_cFeaturesMenu[][FMenuData] =
{
	{"God Mode",       "\r[100 points]",   100},
	{"Double Damage",  "\r[50 points]",     50},
	{"No Recoil",      "\r[70 points]",     70},
	{"Invisibility",   "\r[120 points]",   120},
	{"Sprint Ability", "\r[400 points]",   400},
	{"Low Gravity",    "\r[50 points]",     50},
	{"Head Hunter",    "\r[600 points]",   600}
}

enum _:MMenuData
{
	_mItemName[64],
	_mItemTag[32],
	_mItemPrice
}

new g_cModesMenu[][MMenuData] =
{
	{"Samurai", "\r[180 points]", 180},
	{"Grenadier", "\r[180 points]", 180},
	{"Terminator", "\r[180 points]", 180},
	{"Bombardier", "\r[180 points]", 180},
	{"Revenant", "\r[180 points]", 180},
	{"Survivor vs Nemesis round", "\r[120 points]", 120},
	{"Survivor vs Assasin round", "\r[140 points]", 140},
	{"Sniper vs Nemesis round", "\r[200 points]", 200},
	{"Sniper vs Assasin round", "\r[120 points]", 120},
	{"Nightmare round", "\r[300 points]", 300},
	{"Synapsis round", "\r[150 points]", 150},
	{"Bombardier vs Grenadier Mode", "\r[500 points]", 500},
	{"Samurai vs Nemesis round", "\r[500 points]", 500},
	{"Sonic vs Shadow round", "\r[500 round]", 500},
	{"Nightcrawler round", "\r[500 round]", 500}
}

// Data structure for points shop weapons
enum _:pointsShopDataStructure
{
    ItemName[32],
    ItemCost
}

// create a dynamic array to hold all the items
new Array:g_pointsShopWeapons

// Data structure for extra items
enum _:extraItemsDataStructure
{
	ItemName[32],
	ItemCost,
	ItemTeam
}

// Create a dynamic array to hold all the items
new Array:g_extraitems

// this will tell how many are in the array instead of using ArraySize()
new g_pointsShopTotalWeapons

// this will tell howw many are in the array instead of using ArraySize()
new g_extraitemsCount

enum _: structExtrasTeam (<<=1)
{
	ZQ_EXTRA_HUMAN = 1,
	ZQ_EXTRA_TRYDER,
	ZQ_EXTRA_SURVIVOR,
	ZQ_EXTRA_SNIPER,
	ZQ_EXTRA_SAMURAI,
	ZQ_EXTRA_GRENADIER,
	ZQ_EXTRA_TERMINATOR,
	ZQ_EXTRA_ZOMBIE,
	ZQ_EXTRA_ASSASIN,
	ZQ_EXTRA_NEMESIS,
	ZQ_EXTRA_BOMBARDIER,
	ZQ_EXTRA_REVENANT
}

enum _:Items
{
	KILL_NADE,
	ANTIDOTE_NADE,
	TRYDER,
	MODES,
	CUSTOM_MODES,
	PACKS
}

new LIMIT[33][Items]

// Static game menus
new g_iGameMenu
new g_iZombieClassMenu
new g_iStatisticsMenu
new g_iPointShopMenu
new g_iAmmoMenu
new g_iFeaturesMenu
new g_iModesMenu

// String for holding name of a class
new g_classString[33][14]

// Can() func enums
enum _: canFunc
{
	EXTRA_HUMANS = 0,
	EXTRA_ZOMBIES,
	PSHOP_PACKS,
	PSHOP_FEATURES,
	PSHOP_MODES
}

// Mode names
enum _: modNames 
{
	MODE_NONE = 0,
	MODE_INFECTION,
	MODE_MULTI_INFECTION,
	MODE_NEMESIS,
	MODE_ASSASIN,
	MODE_BOMBARDIER,
	MODE_SURVIVOR,
	MODE_SNIPER,
	MODE_SAMURAI,
	MODE_GRENADIER,
	MODE_TERMINATOR,
	MODE_REVENANT,
	MODE_SWARM,
	MODE_PLAGUE,
	MODE_SYNAPSIS,
	MODE_SNIPER_VS_ASSASIN,
	MODE_SNIPER_VS_NEMESIS,
	MODE_SURVIVOR_VS_NEMESIS,
	MODE_SURVIVOR_VS_ASSASIN,
	MODE_BOMBARDIER_VS_GRENADIER,
	MODE_NIGHTMARE
}

// Mode type variable
new g_currentmode

// Player class & Player team var
new g_playerTeam[33]
new g_playerClass[33]

// Player Team names
enum _: playerTeams 
{
	TEAM_NONE = 0,
	TEAM_HUMAN,
	TEAM_ZOMBIE,
}

// Zombie Sub-class Names
enum _: classNames
{
	CLASS_HUMAN = 1,
	CLASS_ZOMBIE,
	CLASS_TRYDER,
	CLASS_SURVIVOR,
	CLASS_SNIPER,
	CLASS_SAMURAI,
	CLASS_GRENADIER,
	CLASS_TERMINATOR,
	CLASS_ASSASIN,
	CLASS_NEMESIS,
	CLASS_BOMBARDIER,
	CLASS_REVENANT
}

// Macros
#define SetBit(%1,%2)			(%1 |= (1<<(%2-1)))
#define CheckBit(%1,%2)			(%1 & (1<<(%2-1)))  
#define ClearBit(%1,%2)         (%1 &= ~(1<<(%2-1)))
#define CheckFlag(%1,%2)		(%1 & %2)

// Zombie Class names
enum _: zombieClassNames (<<=1)
{
	ZC_CLASSIC = 1,
	ZC_RAPTOR,
	ZC_MUTANT,
	ZC_FROST,
	ZC_REGENERATOR,
	ZC_PREDATOR,
	ZC_HUNTER
}

// Extra item for Humans
enum _: ExtraItemsHumans
{
	EXTRA_NIGHTVISION = 0,
	EXTRA_FORCEFIELD_NADE,
	EXTRA_KILL_NADE,
	EXTRA_EXPLOSION_NADE,
	EXTRA_NAPALM_NADE,
	EXTRA_FROST_NADE,
	EXTRA_ANTIDOTE_NADE, // First page ends here
	EXTRA_MULTIJUMP,
	EXTRA_JETPACK,
	EXTRA_TRYDER,
	EXTRA_ARMOR_100,
	EXTRA_ARMOR_200,
	EXTRA_CROSSBOW,
	EXTRA_GOLDEN_WEAPONS,
	EXTRA_CLASS_NEMESIS,
	EXTRA_CLASS_ASSASIN,
	EXTRA_CLASS_SNIPER,
	EXTRA_CLASS_SURVIVOR,
	EXTRA_ANTIDOTE,
	EXTRA_MADNESS,
	EXTRA_INFECTION_NADE,
	EXTRA_CONCUSSION_NADE,
	EXTRA_KNIFE_BLINK
}

// Points shop - ammo packs
enum _: buyPacksWithPoints
{
	PSHOP_PACKS_100 = 0,
	PSHOP_PACKS_200,
	PSHOP_PACKS_300,
	PSHOP_PACKS_400,
	PSHOP_PACKS_500
}

// Points shop - features
enum _: buyFeaturesWithPoints
{
	PSHOP_FEATURE_GOD_MODE = 0,
	PSHOP_FEATURE_DOUBLE_DAMAGE,
	PSHOP_FEATURE_NO_RECOIL,
	PSHOP_FEATURE_INVISIBILITY,
	PSHOP_FEATURE_SPRINT,
	PSHOP_FEATURE_LOW_GRAVITY,
	PSHOP_FEATURE_HEAD_HUNTER
}

// Points shop - modes
enum _: buyModesWithPoints
{
	PSHOP_MODE_SAMURAI = 0,
	PSHOP_MODE_GRENADIER,
	PSHOP_MODE_TERMINATOR,
	PSHOP_MODE_BOMBARDIER,
	PSHOP_MODE_REVENANT,
	PSHOP_MODE_SURVIVOR_VS_NEMESIS,
	PSHOP_MODE_SURVIVOR_VS_ASSASIN,
	PSHOP_MODE_SNIPER_VS_NEMESIS,
	PSHOP_MODE_SNIPER_VS_ASSASIN,
	PSHOP_MODE_NIGHTMARE,
	PSHOP_MODE_SYNAPSIS,
	PSHOP_MODE_BOMBARDIER_VS_GRENADIER,
	PSHOP_MODE_SAMURAI_VS_NEMESIS,
	PSHOP_MODE_SONIC_VS_SHADOW,
	PSHOP_MODE_NIGHTCRAWLER
}

// LogToFile actions enums
enum _: logActions
{
	LOG_SLAY = 0,
	LOG_SLAP,
	LOG_KICK,
	LOG_FREEZE,
	LOG_NICK,
	LOG_MAP,
	LOG_GAG,
	LOG_BAN,
	LOG_MAKE_HUMAN,
	LOG_MAKE_ZOMBIE,
	LOG_MAKE_ASSASIN,
	LOG_MAKE_NEMESIS,
	LOG_MAKE_BOMBARDIER,
	LOG_MAKE_SNIPER,
	LOG_MAKE_SURVIVOR,
	LOG_MAKE_SAMURAI,
	LOG_MAKE_GRENADIER,
	LOG_MAKE_TERMINATOR,
	LOG_MAKE_REVENANT,
	LOG_MODE_MULTIPLE_INFECTION,
	LOG_MODE_SWARM,
	LOG_MODE_PLAGUE,
	LOG_MODE_SYNAPSIS,
	LOG_MODE_NIGHTCRAWLER,
	LOG_MODE_NIGHTMARE,
	LOG_MODE_SURVIVOR_VS_NEMESIS,
	LOG_MODE_SURVIVOR_VS_ASSASIN,
	LOG_MODE_SNIPER_VS_NEMESIS,
	LOG_MODE_SNIPER_VS_ASSASIN,
	LOG_MODE_BOMBARDIER_VS_GRENADIER,
	LOG_RESPAWN_PLAYER
}

// Limiters for stuff not worth making dynamic arrays out of (increase if needed)
const MAX_CSDM_SPAWNS = 128
const MAX_STATS_SAVED = 64

// HUD messages
const Float:HUD_EVENT_X  = -1.0
const Float:HUD_EVENT_Y  = 0.17
const Float:HUD_INFECT_X = 0.05
const Float:HUD_INFECT_Y = 0.45
const Float:HUD_SPECT_X  = 0.6
const Float:HUD_SPECT_Y  = 0.8
const Float:HUD_STATS_X  = 0.02
const Float:HUD_STATS_Y  = 0.9

// Hack to be able to use Ham_Player_ResetMaxSpeed (by joaquimandrade)
new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame

// CS Player PData Offsets (win32)
const PDATA_SAFE 				= 2
const OFFSET_PAINSHOCK 			= 108 // ConnorMcLeod
const OFFSET_CSTEAMS 			= 114
const OFFSET_CSMONEY 			= 115
const OFFSET_CSMENUCODE 		= 205
const OFFSET_FLASHLIGHT_BATTERY = 244
const OFFSET_CSDEATHS 			= 444
const OFFSET_MODELINDEX 		= 491 // Orangutanz
const OFFSET_NEXTATTACK			= 83  // NeO

// CS Player CBase Offsets (win32)
const OFFSET_ACTIVE_ITEM = 373

// CS Weapon CBase Offsets (win32)
const OFFSET_WEAPONOWNER = 41

// Linux diff's
const OFFSET_LINUX 		   = 5 // offsets 5 higher in Linux builds
const OFFSET_LINUX_WEAPONS = 4 // weapon offsets are only 4 steps higher on Linux

// Private data of VGUI Menu
const m_iMenuCode = 205

// CS Teams
enum
{
	FM_CS_TEAM_UNASSIGNED = 0,
	FM_CS_TEAM_T,
	FM_CS_TEAM_CT,
	FM_CS_TEAM_SPECTATOR
}

new const CS_TEAM_NAMES[][] =
{
	"UNASSIGNED",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

// Some constants
const HIDE_MONEY 			= (1<<5)
const UNIT_SECOND 			= (1<<12)
const DMG_HEGRENADE 		= (1<<24)
const IMPULSE_FLASHLIGHT 	= 100
const USE_USING 			= 2
const USE_STOPPED 			= 0
const STEPTIME_SILENT 		= 999
const BREAK_GLASS 			= 0x01
const PEV_SPEC_TARGET 		= pev_iuser2

// Max BP ammo for weapons
new const MAXBPAMMO[] =
{
	-1 , 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90,
	100, 120, 30 , 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100
}

// Max Clip for weapons
new const MAXCLIP[] = 
{
	-1 , 13, -1, 10,
	-1 , 7 , -1, 30,
	30 , -1, 30, 20,
	25 , 30, 35, 25,
	2  , 20, 10, 30,
	100, 8 , 30, 30,
	20 , -1, 7 , 30, 
	30 , -1, 50 
}

// Ammo Type Names for weapons
new const AMMOTYPE[][] = 
{
	"", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp", "556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm",
	"556natobox", "buckshot", "556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm" 
}

// Weapon entity names
new const WEAPONENTNAMES[][] =
{ 
	"", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven",
	"weapon_ump45", "weapon_sg550", "weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1", 
	"weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", "weapon_ak47", "weapon_knife", "weapon_p90" 
}

new g_BlockedMessages[][] =
{ 
	"#C4_Arming_Cancelled",
	"#Bomb_Planted",
	"#C4_Plant_Must_Be_On_Ground",
	"#C4_Plant_At_Bomb_Spot",
	"#CZero_LearningMap",
	"#CZero_AnalyzingHidingSpots", 
	"#CZero_AnalyzingApproachPoints",
	"#Hint_careful_around_hostages",
	"#Injured_Hostage",
	"#Hint_removed_for_next_hostage_killed",
	"#Hint_lost_money",
	"#Killed_Hostage",
	"#Only_CT_Can_Move_Hostages",
	"#Cstrike_Chat_AllSpec",
	"#Cstrike_Chat_AllDead",
	"#Cstrike_Chat_All",
	"#Cstrike_Chat_Spec",
	"#Cstrike_Chat_T_Dead",
	"#Cstrike_Chat_T",
	"#Cstrike_Chat_T_Loc",
	"#Cstrike_Chat_CT_Dead",
	"#Cstrike_Chat_CT",
	"#Cstrike_Chat_CT_Loc",
	"#Cannot_Buy_This",
	"#Cstrike_Already_Own_Weapon",
	"#Not_Enough_Money",
	"#Hint_use_nightvision",
	"#Already_Have_One",
	"#Cannot_Carry_Anymore",
	"#Already_Have_Kevlar_Bought_Helmet",
	"#Already_Have_Kevlar_Helmet", 
	"#Already_Have_Helmet_Bought_Kevlar",
	"#Already_Have_Kevlar",
	"#Cannot_Be_Spectator",
	"#Game_join_ct",
	"#Game_join_terrorist",
	"#Only_1_Team_Change",
	"#Terrorist_Select",
	"#CT_Select",
	"#Humans_Join_Team_T",
	"#Humans_Join_Team_CT",
	"#Too_Many_CTs",
	"#Too_Many_Terrorists",
	"#All_Teams_Full",
	"#CTs_Full",
	"#Terrorists_Full",
	"#Cannot_Switch_From_VIP",
	"#Bomb_Defusal_Kit",
	"#Game_unknown_command",
	"#Buy",
	"#Command_Not_Available",
	"#Ignore_Broadcast_Team_Messages", 
	"#Ignore_Broadcast_Messages",
	"#IG_Team_Select_Spect",
	"#IG_VIP_Team_Select_Spect",
	"#IG_VIP_Team_Select",
	"#T_BuyItem",
	"#CT_BuyItem",
	"#DT_BuyItem",
	"#DCT_BuyItem",
	"#BuyMachineGun",
	"#AS_T_BuyMachineGun",
	"#T_BuyRifle",
	"#CT_BuyRifle",
	"#AS_T_BuyRifle",
	"#AS_CT_BuyRifle",
	"#T_BuySubMachineGun",
	"#CT_BuySubMachineGun",
	"#AS_T_BuySubMachineGun",
	"#AS_CT_BuySubMachineGun",
	"#BuyShotgun",
	"#AS_BuyShotgun",
	"#T_BuyPistol",
	"#CT_BuyPistol",
	"#IG_Team_Select",
	"#Team_Select",
	"#Game_no_timelimit",
	"#Game_timelimit",
	"#Game_voted_for_map",
	"#Cannot_Vote_Need_More_People",
	"#Game_votemap_usage",
	"#Cannot_Vote_Map",
	"#Wait_3_Seconds",
	"#Game_vote_cast",
	"#Game_vote_not_yourself",
	"#Game_vote_players_on_your_team",
	"#Game_vote_player_not_Found",
	"#Cannot_Vote_With_Less_Than_Three",
	"#Game_vote_usage",
	"#Cstrike_Name_Change",
	"#Name_change_at_respawn",
	"#Defusing_Bomb_Without_Defuse_Kit",
	"#Defusing_Bomb_With_Defuse_Kit",
	"#C4_Defuse_Must_Be_On_Ground",
	"#Hint_you_have_the_bomb",
	"#All_Hostages_Rescued",
	"#Round_Draw",
	"#Terrorists_Win",
	"#CTs_Win",
	"#BoGmb_Defused",
	"#Target_Bombed",
	"#Escaping_Terrorists_Neutralized",
	"#CTs_PreventEscape",
	"#Terrorists_Escaped",
	"#VIP_Assassinated",
	"#VIP_Escaped",
	"#Game_Commencing",
	"#Game_scoring",
	"#Auto_Team_Balance_Next_Round",
	"#All_VIP_Slots_Full",
	"#Game_added_position",
	"#VIP_Not_Escaped",
	"#Terrorists_Not_Escaped",
	"#Hostages_Not_Rescued",
	"#Target_Saved",
	"#Team_Select_Spect",
	"#Hint_win_round_by_killing_enemy",
	"#Hint_reward_for_killing_vip",
	"#Hint_careful_around_teammates",
	"#Banned_For_Killing_Teamates",
	"#Game_teammate_kills",
	"#Killed_Teammate",
	"#Map_Vote_Extend",
	"#Votes",
	"#Vote", 
	"#Game_required_votes",
	"#Spec_Mode%i",
	"#Spec_NoTarget",
	"#Game_radio_location",
	"#Game_radio",
	"#Game_teammate_attack",
	"#Hint_try_not_to_injure_teammates",
	"#Spec_Duck",
	"#Hint_cannot_play_because_tk",
	"#Hint_use_hostage_to_stop_him",
	"#Hint_lead_hostage_to_rescue_point",
	"#Terrorist_cant_buy",
	"#CT_cant_buy",
	"#VIP_cant_buy",
	"#Cant_buy",
	"#Hint_press_buy_to_purchase",
	"#Game_idle_kick",
	"#Hint_you_are_the_vip",
	"#Hint_hostage_rescue_zone",
	"#Hint_you_are_in_targetzone",
	"#Hint_terrorist_escape_zone",
	"#Hint_terrorist_vip_zone",
	"#Hint_ct_vip_zone",
	"#Hint_out_of_ammo",
	"#Hint_press_use_so_hostage_will_follow",
	"#Hint_prevent_hostage_rescue",
	"#Hint_rescue_the_hostages",
	"#Hint_spotted_a_friend",
	"#Hint_spotted_an_enemy",
	"#Game_bomb_drop",
	"#Weapon_Cannot_Be_Dropped",
	"#Game_join_ct_auto",
	"#Game_join_terrorist_auto",
	"#Terrorist_Escaped",
	"#Game_bomb_pickup",
	"#Got_bomb",
	"#CZero_Tutor_Turned_Off",
	"#CZero_Tutor_Turned_On",
	"#Cstrike_TutorState_Waiting_For_Start",
	"#Cstrike_TutorState_Buy_Time",
	"#Cstrike_TutorState_Running_Away_From_Ticking_Bomb",
	"#Cstrike_TutorState_Looking_For_Loose_Bomb",
	"#Cstrike_TutorState_Guarding_Bomb",
	"#Cstrike_TutorState_Planting_Bomb",
	"#Cstrike_TutorState_Moving_To_Bomb_Site",
	"#Cstrike_TutorState_Escorting_Bomb_Carrier",
	"#Cstrike_TutorState_Attacking_Hostage_Escort",
	"#Cstrike_TutorState_Looking_For_Hostage_Escort",
	"#Cstrike_TutorState_Moving_To_Intercept_Enemy",
	"#Cstrike_TutorState_Guarding_Hostage",
	"#Cstrike_TutorState_Defusing_Bomb",
	"#Cstrike_TutorState_Guarding_Loose_Bomb",
	"#Cstrike_TutorState_Looking_For_Bomb_Carrier",
	"#Cstrike_TutorState_Moving_To_Bombsite",
	"#Cstrike_TutorState_Following_Hostage_Escort",
	"#Cstrike_TutorState_Escorting_Hostage",
	"#Cstrike_TutorState_Undefine"
}

new const Float:g_fSizes[70][3] =
{
	{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
	{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
	{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
	{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
	{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
}

// Bullet damage
new iPosition[33]

new Float:g_flCoords[][] = 
{
	{0.50, 0.40},
	{0.56, 0.44},
	{0.60, 0.50},
	{0.56, 0.56},
	{0.50, 0.60},
	{0.44, 0.56},
	{0.40, 0.50},
	{0.44, 0.44}
}

// CS sounds
new const sound_flashlight[] = "items/flashlight1.wav"
new const sound_buyammo[] = "items/9mmclip1.wav"
new const sound_armorhit[] = "player/bhit_helmet-1.wav"

// Explosion radius for custom grenades
const Float:NADE_EXPLOSION_RADIUS = 240.0

// HACK: pev_ field used to store additional ammo on weapons
const PEV_ADDITIONAL_AMMO = pev_iuser1

// HACK: pev_ field used to store custom nade types and their values
const PEV_NADE_TYPE = pev_flTimeStepSound
enum (+= 1111) 
{
	NADE_TYPE_INFECTION = 1111,
	NADE_TYPE_EXPLOSION,
	NADE_TYPE_NAPALM,
	NADE_TYPE_FROST,
	NADE_TYPE_ANTIDOTE,
	NADE_TYPE_CONCUSSION,
	NADE_TYPE_KILLING,
	NADE_TYPE_BUBBLE
}

// Weapon bitsums
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)

// Allowed weapons for zombies (added grenades/bomb for sub-plugin support, since they shouldn't be getting them anyway)
const ZOMBIE_ALLOWED_WEAPONS_BITSUM = (1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4)

/*================================================================================
	[Global Variables]
=================================================================================*/

// Player vars
new g_specialclass[33]	// is special class for reminder task and other stuffs
new g_lastSpecialHumanIndex // is index of last special human
new g_lastSpecialZombieIndex // is index of last special zombie
new g_firstzombie[33] // is first zombie
new g_lastzombie[33] // is last zombie
new g_lasthuman[33] // is last human
new g_frozen[33] // is frozen (can't move)
new g_burning[33] // is burning
new g_punished[33] // is punished
new Float:g_frozen_gravity[33] // store previous gravity when frozen
new g_nodamage[33] // has spawn protection/zombie madness
new g_respawn_as_zombie[33] // should respawn as zombie
new g_nvision[33] // has night vision
new g_nvisionenabled[33] // has night vision turned on
new g_zombieclass[33] // zombie class
new g_zombieclassnext[33] // zombie class for next infection
new g_flashlight[33] // has custom flashlight turned on
new g_flashbattery[33] = { 100, ... } // custom flashlight battery
new g_canbuy[33] // is allowed to buy a new weapon through the menu
new g_ammopacks[33] // ammo pack count
new g_points[33]    // Points count --- Abhinash ---
new g_damagedealt_human[33] // damage dealt as human (used to calculate ammo packs reward)
new g_damagedealt_zombie[33] // damage dealt as zombie (used to calculate ammo packs reward)
new Float:g_lastleaptime[33] // time leap was last used
new Float:g_lastflashtime[33] // time flashlight was last toggled
new g_burning_duration[33] // burning task duration
new Float:g_buytime[33] // used to calculate custom buytime

// Grenades
new g_concussionbomb[33]
new g_antidotebomb[33]
new g_bubblebomb[33]
new g_killingbomb[33]
new bullets[33]

// Countdown
new countdown_timer

// --- Nvault ---
new g_vault = INVALID_HANDLE

// Game vars
new g_pluginenabled // ZP enabled
new g_newround // new round starting
new g_endround // round ended
new g_modestarted // mode fully started
new g_lastmode // last played mode
new g_scorezombies, g_scorehumans, g_gamecommencing // team scores
new Float:g_models_targettime // for adding delays between Model Change messages
new Float:g_teams_targettime // for adding delays between Team Change messages
new g_MsgSync, g_MsgSync2, g_MsgSync3, g_MsgSync4, g_MsgSync5[4], g_MsgSync6, g_MsgSync7 // message sync objects
new g_trailspr, g_explosionspr// grenade sprites
new g_freezetime // whether CS's freeze time is on
new g_maxplayers // max players counter
new g_czero // whether we are running on a CZ serverPerfectZM
new g_hamczbots // whether ham forwards are registered for CZ bots
new UnregisterFwSpawn, UnregisterFwPrecacheSound // spawn and precache sound forward handles
new g_switchingteam // flag for whenever a player's team change emessage is sent
new g_buyzone_ent // custom buyzone entity
new g_lastplayerleaving // flag for whenever a player leaves and another takes his place

// Temporary Database vars (used to restore players stats in case they get disconnected)
new db_name[MAX_STATS_SAVED][32] // player name
new db_ammopacks[MAX_STATS_SAVED] // ammo pack count
new db_zombieclass[MAX_STATS_SAVED] // zombie class
new db_slot_i // additional saved slots counter (should start on maxplayers+1)

// CVAR pointers
new cvar_toggle, cvar_botquota

/// Cached stuff for players
new g_isconnected[33] // whether player is connected
new g_isalive[33] // whether player is alive
new g_isbot[33] // whether player is a bot
new g_currentweapon[33] // player's current weapon id
new g_playerName[33][32] // player's name
new g_playerSteamID[33][32] // player's steamid
new g_playerHash[33][100] // player's hash
new g_playerConcat[33][100] // Temp concat char array

#define is_user_valid_connected(%1) (1 <= %1 <= g_maxplayers && g_isconnected[%1])
#define is_user_valid_alive(%1) (1 <= %1 <= g_maxplayers && g_isalive[%1])
#define is_user_valid(%1) (1 <= %1 <= g_maxplayers)

// Cached CVARs
new g_cached_customflash, g_cached_zombiesilent, Float:g_cached_leapzombiescooldown,
g_cached_leapnemesis, Float:g_cached_leapnemesiscooldown,
g_cached_leapsurvivor, Float:g_cached_leapsurvivorcooldown,  
g_cached_leapassassin, Float:g_cached_leapassassincooldown,
g_cached_leapsniper, Float:g_cached_leapsnipercooldown,
g_cached_leapzadoc, Float:g_cached_leapzadoccooldown, 
g_cached_leapgrenadier, Float:g_cached_leapgrenadiercooldown, 
g_cached_leapbombardier, Float:g_cached_leapbombardiercooldown, 
g_cached_leaprevenant, Float:g_cached_leaprevenantcooldown,
g_cached_leapterminator, Float:g_cached_leapterminatorcooldown

/*================================================================================
	[Natives and Init]
=================================================================================*/

public plugin_natives()
{
	// Admin related natives
	register_native("AdminHasFlag", "native_admin_has_flag", 1)

	// Data related natives
	register_native("GetPacks", "native_get_user_packs", 1) 				// Get
	register_native("AddPacks", "native_add_user_packs", 1)				// Add
	register_native("SetPacks", "native_set_user_packs", 1)				// Set
	register_native("GetPoints", "native_get_user_points", 1)				// Get
	register_native("AddPoints", "native_add_user_points", 1)				// Add
	register_native("SetPoints", "native_set_user_points", 1)				// Set
	register_native("GetKills", "native_get_user_kills", 1)				// Get
	register_native("AddKills", "native_add_user_kills", 1)				// Add
	register_native("SetKills", "native_set_user_kills", 1)				// Set
	register_native("GetInfections", "native_get_user_infections", 1)			// Get
	register_native("AddInfections", "native_add_user_infections", 1)			// Add
	register_native("SetInfections", "native_set_user_infections", 1)			// Set
	register_native("GetNemesisKills", "native_get_user_nemesis_kills", 1)		// Get
	register_native("AddNemesisKills", "native_add_user_nemesis_kills", 1)		// Add
	register_native("SetNemesisKills", "native_set_user_nemesis_kills", 1)		// Set
	register_native("GetAssasinKills", "native_get_user_assasin_kills", 1)		// Get
	register_native("AddAssasinKills", "native_add_user_assasin_kills", 1)		// Add
	register_native("SetAssasinKills", "native_set_user_assasin_kills", 1)		// Set
	register_native("GetBombardierKills", "native_get_user_bombardier_kills", 1)	// Get
	register_native("AddBombardierKills", "native_add_user_bombardier_kills", 1)	// Add
	register_native("SetBombardierKills", "native_set_user_bombardier_kills", 1)	// Set
	register_native("GetSurvivorKills", "native_get_user_survivor_kills", 1)		// Get
	register_native("AddSurvivorKills", "native_add_user_survivor_kills", 1)		// Add
	register_native("SetSurvivorKills", "native_set_user_survivor_kills", 1)		// Set
	register_native("GetSniperKills", "native_get_user_sniper_kills", 1)		// Get
	register_native("AddSniperKills", "native_add_user_sniper_kills", 1)		// Add
	register_native("SetSniperKills", "native_set_user_sniper_kills", 1)		// Set
	register_native("GetSamuraiKills", "native_get_user_samurai_kills", 1)		// Get
	register_native("AddSamuraiKills", "native_add_user_samurai_kills", 1)		// Add
	register_native("SetSamuraiKills", "native_set_user_samurai_kills", 1)		// Set
	register_native("GetGrenadierKills", "native_get_user_grenadier_kills", 1)		// Get
	register_native("AddGrenadierKills", "native_add_user_grenadier_kills", 1)		// Add
	register_native("SetGrenadierKills", "native_set_user_grenadier_kills", 1)		// Set
	register_native("GetRevenantKills", "native_get_user_revenant_kills", 1)      // Get
	register_native("AddRevenantKills", "native_add_user_revenant_kills", 1)      // Add
	register_native("SetRevenantKills", "native_set_user_revenant_kills", 1)		// Set
	register_native("GetTerminatorKills", "native_get_user_terminator_kills", 1)	// Get
	register_native("AddTerminatorKills", "native_add_user_terminator_kills", 1)	// Add
	register_native("SetTerminatorKills", "native_set_user_terminator_kills", 1)	// Set

	// Class related natives
	register_native("IsZombie", "native_get_user_zombie", 1)
	register_native("MakeZombie", "native_make_user_zombie", 1)
	register_native("IsHuman", "native_get_user_human", 1)
	register_native("MakeHuman", "native_make_user_human", 1)
	register_native("IsNemesis", "native_get_user_nemesis", 1)
	register_native("MakeNemesis", "native_make_user_nemesis", 1)
	register_native("IsAssasin", "native_get_user_assassin", 1)
	register_native("MakeAssasin", "native_make_user_assasin", 1)
	register_native("IsBombardier", "native_get_user_bombardier", 1)
	register_native("MakeBombardier", "native_make_user_bombardier", 1)
	register_native("IsSniper", "native_get_user_sniper", 1)
	register_native("MakeSniper", "native_make_user_sniper", 1)
	register_native("IsSurvivor", "native_get_user_survivor", 1)
	register_native("MakeSurvivor", "native_make_user_survivor", 1)
	register_native("IsSamurai", "native_get_user_samurai", 1)
	register_native("MakeSamurai", "native_make_user_samurai", 1)
	register_native("IsGrenadier", "native_get_user_grenadier", 1)
	register_native("MakeGrenadier", "native_make_user_grenadier", 1)
	register_native("IsRevenant", "native_get_user_revenant", 1)
	register_native("MakeRevenant", "native_make_user_revenant", 1)
	register_native("IsTerminator", "native_get_user_terminator", 1)
	register_native("MakeTerminator", "native_make_user_terminator", 1)

	register_native("RespawnPlayer", "native_respawn_player", 1)

	// String natives
	register_native("GetClassString", "native_get_class_string")

	// --- Round related natives ---
	// Master natives
	//register_native("StartMode",				"native_start_mode", 1)
	//register_native("IsMode", 					"native_is_current_mode", 1)

	// Custom natives specific to modes
	register_native("IsInfectionRound", "native_is_infection_round", 1)
	register_native("StartInfectionRound", "native_start_infection_round", 1)
	register_native("IsMultiInfectionRound", "native_is_multi_infection_round", 1)
	register_native("StartMultiInfectionRound", "native_start_multi_infection_round", 1)
	register_native("IsSwarmRound", "native_is_swarm_round", 1)
	register_native("StartSwarmRound", "native_start_swarm_round", 1)
	register_native("IsPlagueRound", "native_is_plague_round", 1)
	register_native("StartPlagueRound", "native_start_plague_round", 1)
	register_native("IsArmageddonRound", "native_is_armageddon_round", 1)
	register_native("StartArmageddonRound", "native_start_armageddon_round", 1)
	register_native("IsApocalypseRound", "native_is_apocalypse_round", 1)
	register_native("StartApocalypseRound", "native_start_apocalypse_round", 1)
	register_native("IsDevilRound", "native_is_devil_round", 1)
	register_native("StartDevilRound", "native_start_devil_round", 1)
	register_native("IsNightmareRound", "native_is_nightmare_round", 1)
	register_native("StartNightmareRound", "native_start_nightmare_round", 1)
	register_native("IsSynapsisRound", "native_is_synapsis_round", 1)
	register_native("StartSynapsisRound", "native_start_synapsis_round", 1)
	register_native("IsSurvivorVsAssasinRound", "native_is_survivor_vs_assasin_round", 1)
	register_native("StartSurvivorVsAssasinRound", "native_start_survivor_vs_assasin_round", 1)
	register_native("IsBombardierVsGrenadierRound", "native_is_bombardier_vs_grenadier_round", 1)
	register_native("StartBombardierVsGrenadierRound", "native_start_bombardier_vs_grenadier_round", 1)

	// Native for adding weapons to the Points shop weapons
	register_native("RegisterPointsShopWeapon", "native_register_points_shop_weapon")
}

public plugin_precache()
{
	// Register earlier to show up in plugins list properly after plugin disable/error at loading
	register_plugin("Zombie Queen", "11.5", "NeO-")
	
	// To switch plugin on/off
	register_concmd("zp_toggle", "cmd_toggle", _, "<1/0> - Enable/Disable Zombie Plague (will restart the current map)", 0)
	cvar_toggle = register_cvar("zp_on", "1")
	
	// Plugin disabled?
	if (!get_pcvar_num(cvar_toggle)) return
	g_pluginenabled = true

	for (new i = 0; i < MAX_CLASS_MODELS; i++) g_playerModel[i] = ArrayCreate(32, 1)
	for (new i = 0; i < MAX_WEAPON_MODELS; i++) g_weaponModels[i] = ArrayCreate(100, 1)
	for (new i = 0; i < MAX_SPRITES; i++) g_sprites[i] = ArrayCreate(64, 1)
	for (new i = 0; i < MAX_AMBIENCE_SOUNDS; i++) g_ambience[i] = ArrayCreate(64, 1)
	for (new i = 0; i < MAX_START_SOUNDS; i++) g_startSound[i] = ArrayCreate(64, 1)
	for (new i = 0; i < MAX_MISC_SOUNDS; i++) g_miscSounds[i] = ArrayCreate(64, 1)

	for (new i = 0; i < 2; i++) 
	{
		g_weapon_name[i] = ArrayCreate(32, 1)
		g_weapon_ids[i] = ArrayCreate(1, 1)
	}

	g_full_weapon_names = ArrayCreate(64, 1)

	LoadCustomizationFromFile()
	
	new i, buffer[1024]

	for (i = 0; i < sizeof CountdownSounds; i++) engfunc(EngFunc_PrecacheSound, CountdownSounds[i])

	for (i = 0; i < ArraySize(Array:g_playerModel[MODEL_HUMAN]); i++)
	{
		ArrayGetString(Array:g_playerModel[MODEL_HUMAN], i, buffer, charsmax(buffer))
		PrecachePlayerModel(buffer)
	}

	for (i = 0; i < ArraySize(Array:g_playerModel[MODEL_SURVIVOR]); i++)
	{
		ArrayGetString(Array:g_playerModel[MODEL_SURVIVOR], i, buffer, charsmax(buffer))
		PrecachePlayerModel(buffer)
	}

	for (i = 0; i < ArraySize(Array:g_playerModel[MODEL_SNIPER]); i++)
	{
		ArrayGetString(Array:g_playerModel[MODEL_SNIPER], i, buffer, charsmax(buffer))
		PrecachePlayerModel(buffer)
	}

	for (i = 0; i < ArraySize(Array:g_playerModel[MODEL_SAMURAI]); i++)
	{
		ArrayGetString(Array:g_playerModel[MODEL_SAMURAI], i, buffer, charsmax(buffer))
		PrecachePlayerModel(buffer)
	}

	for (i = 0; i < ArraySize(Array:g_playerModel[MODEL_GRENADIER]); i++)
	{
		ArrayGetString(Array:g_playerModel[MODEL_GRENADIER], i, buffer, charsmax(buffer))
		PrecachePlayerModel(buffer)
	}

	for (i = 0; i < ArraySize(Array:g_playerModel[MODEL_TERMINATOR]); i++)
	{
		ArrayGetString(Array:g_playerModel[MODEL_TERMINATOR], i, buffer, charsmax(buffer))
		PrecachePlayerModel(buffer)
	}

	for (i = 0; i < ArraySize(Array:g_playerModel[MODEL_ASSASIN]); i++)
	{
		ArrayGetString(Array:g_playerModel[MODEL_ASSASIN], i, buffer, charsmax(buffer))
		PrecachePlayerModel(buffer)
	}

	for (i = 0; i < ArraySize(Array:g_playerModel[MODEL_NEMESIS]); i++)
	{
		ArrayGetString(Array:g_playerModel[MODEL_NEMESIS], i, buffer, charsmax(buffer))
		PrecachePlayerModel(buffer)
	}

	for (i = 0; i < ArraySize(Array:g_playerModel[MODEL_BOMBARDIER]); i++)
	{
		ArrayGetString(Array:g_playerModel[MODEL_BOMBARDIER], i, buffer, charsmax(buffer))
		PrecachePlayerModel(buffer)
	}

	for (i = 0; i < ArraySize(Array:g_playerModel[MODEL_REVENANT]); i++)
	{
		ArrayGetString(Array:g_playerModel[MODEL_REVENANT], i, buffer, charsmax(buffer))
		PrecachePlayerModel(buffer)
	}

	for (i = 0; i < ArraySize(Array:g_playerModel[MODEL_OWNER]); i++)
	{
		ArrayGetString(Array:g_playerModel[MODEL_OWNER], i, buffer, charsmax(buffer))
		PrecachePlayerModel(buffer)
	}

	for (i = 0; i < ArraySize(Array:g_playerModel[MODEL_ADMIN]); i++)
	{
		ArrayGetString(Array:g_playerModel[MODEL_ADMIN], i, buffer, charsmax(buffer))
		PrecachePlayerModel(buffer)
	}

	for (i = 0; i < ArraySize(Array:g_playerModel[MODEL_VIP]); i++)
	{
		ArrayGetString(Array:g_playerModel[MODEL_VIP], i, buffer, charsmax(buffer))
		PrecachePlayerModel(buffer)
	}

	for (i = 0; i < ArraySize(Array:g_weaponModels[V_KNIFE_HUMAN]); i++)
	{
		ArrayGetString(Array:g_weaponModels[V_KNIFE_HUMAN], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheModel, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_weaponModels[P_KNIFE_HUMAN]); i++)
	{
		ArrayGetString(Array:g_weaponModels[P_KNIFE_HUMAN], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheModel, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_weaponModels[V_KNIFE_NEMESIS]); i++)
	{
		ArrayGetString(Array:g_weaponModels[V_KNIFE_NEMESIS], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheModel, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_weaponModels[V_KNIFE_ASSASIN]); i++)
	{
		ArrayGetString(Array:g_weaponModels[V_KNIFE_ASSASIN], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheModel, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_weaponModels[V_KNIFE_REVENANT]); i++)
	{
		ArrayGetString(Array:g_weaponModels[V_KNIFE_REVENANT], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheModel, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_weaponModels[V_AWP_SNIPER]); i++)
	{
		ArrayGetString(Array:g_weaponModels[V_AWP_SNIPER], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheModel, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_weaponModels[P_AWP_SNIPER]); i++)
	{
		ArrayGetString(Array:g_weaponModels[P_AWP_SNIPER], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheModel, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_weaponModels[V_KNIFE_SAMURAI]); i++)
	{
		ArrayGetString(Array:g_weaponModels[V_KNIFE_SAMURAI], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheModel, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_weaponModels[P_KNIFE_SAMURAI]); i++)
	{
		ArrayGetString(Array:g_weaponModels[P_KNIFE_SAMURAI], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheModel, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_weaponModels[V_INFECTION_NADE]); i++)
	{
		ArrayGetString(Array:g_weaponModels[V_INFECTION_NADE], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheModel, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_weaponModels[V_EXPLOSION_NADE]); i++)
	{
		ArrayGetString(Array:g_weaponModels[V_EXPLOSION_NADE], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheModel, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_weaponModels[V_NAPALM_NADE]); i++)
	{
		ArrayGetString(Array:g_weaponModels[V_NAPALM_NADE], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheModel, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_weaponModels[V_FROST_NADE]); i++)
	{
		ArrayGetString(Array:g_weaponModels[V_FROST_NADE], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheModel, buffer)
	}

	// Sounds
	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_SURVIVOR]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_SURVIVOR], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_SNIPER]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_SNIPER], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_SAMURAI]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_SAMURAI], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_GRENADIER]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_GRENADIER], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_TERMINATOR]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_TERMINATOR], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_ASSASIN]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_ASSASIN], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_NEMESIS]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_NEMESIS], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_BOMBARDIER]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_BOMBARDIER], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_REVENANT]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_REVENANT], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_INFECTION]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_INFECTION], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_MULTI_INFECTION]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_MULTI_INFECTION], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_SWARM]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_SWARM], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_PLAGUE]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_PLAGUE], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_SYNAPSIS]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_SYNAPSIS], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_SURVIVOR_VS_ASSASIN]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_SURVIVOR_VS_ASSASIN], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_SURVIVOR_VS_NEMESIS]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_SURVIVOR_VS_NEMESIS], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_SNIPER_VS_ASSASIN]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_SNIPER_VS_ASSASIN], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_SNIPER_VS_NEMESIS]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_SNIPER_VS_NEMESIS], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_BOMBARDIER_VS_GRENADIER]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_BOMBARDIER_VS_GRENADIER], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_ambience[AMBIENCE_NIGHTMARE]); i++)
	{
		ArrayGetString(Array:g_ambience[AMBIENCE_NIGHTMARE], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	// Round Start Sounds
	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_HUMAN_WIN]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_HUMAN_WIN], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_ZOMBIE_WIN]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_ZOMBIE_WIN], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_WIN_NO_ONE]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_WIN_NO_ONE], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_SURVIVOR]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_SURVIVOR], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_SNIPER]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_SNIPER], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_SAMURAI]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_SAMURAI], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_GRENADIER]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_GRENADIER], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_TERMINATOR]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_TERMINATOR], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_ASSASIN]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_ASSASIN], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_NEMESIS]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_NEMESIS], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_BOMBARDIER]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_BOMBARDIER], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_REVENANT]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_REVENANT], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_MULTI_INFECTION]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_MULTI_INFECTION], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_SWARM]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_SWARM], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_PLAGUE]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_PLAGUE], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_SYNAPSIS]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_SYNAPSIS], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_SURVIVOR_VS_ASSASIN]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_SURVIVOR_VS_ASSASIN], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_SURVIVOR_VS_NEMESIS]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_SURVIVOR_VS_NEMESIS], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_SNIPER_VS_ASSASIN]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_SNIPER_VS_ASSASIN], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_SNIPER_VS_NEMESIS]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_SNIPER_VS_NEMESIS], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_BOMBARDIER_VS_GRENADIER]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_BOMBARDIER_VS_GRENADIER], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_startSound[SOUND_NIGHTMARE]); i++)
	{
		ArrayGetString(Array:g_startSound[SOUND_NIGHTMARE], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	// Custom sounds
	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_INFECT]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_INFECT], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_PAIN]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_PAIN], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_NEMESIS_PAIN]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_NEMESIS_PAIN], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_ASSASIN_PAIN]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_ASSASIN_PAIN], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_REVENANT_PAIN]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_REVENANT_PAIN], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_DIE]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_DIE], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_FALL]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_FALL], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_MISS_SLASH]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_MISS_SLASH], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_MISS_WALL]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_MISS_WALL], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_HIT_NORMAL]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_HIT_NORMAL], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_HIT_STAB]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_HIT_STAB], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	
	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_IDLE]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_IDLE], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_IDLE_LAST]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_IDLE_LAST], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_MADNESS]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_MADNESS], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_GRENADE_INFECT]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_INFECT], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_GRENADE_INFECT_PLAYER]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_INFECT_PLAYER], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_GRENADE_FIRE]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_FIRE], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_GRENADE_FIRE_PLAYER]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_FIRE_PLAYER], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_GRENADE_FROST]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_FROST], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_GRENADE_FROST_PLAYER]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_FROST_PLAYER], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_GRENADE_FROST_BREAK]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_FROST_BREAK], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(Array:g_miscSounds[SOUND_ANTIDOTE]); i++)
	{
		ArrayGetString(Array:g_miscSounds[SOUND_ANTIDOTE], i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < sizeof(sound_thunder); i++) engfunc(EngFunc_PrecacheSound, sound_thunder[i])

	engfunc(EngFunc_PrecacheModel, "models/player/PerfectZM_Classic/PerfectZM_Classic.mdl")
	engfunc(EngFunc_PrecacheModel, "models/player/PerfectZM_Raptor/PerfectZM_Raptor.mdl")
	engfunc(EngFunc_PrecacheModel, "models/player/PerfectZM_Frozen/PerfectZM_Frozen.mdl")
	engfunc(EngFunc_PrecacheModel, "models/player/PerfectZM_Mutant/PerfectZM_Mutant.mdl")
	engfunc(EngFunc_PrecacheModel, "models/player/PerfectZM_Predator/PerfectZM_Predator.mdl")
	engfunc(EngFunc_PrecacheModel, "models/player/PerfectZM_Hunter/PerfectZM_Hunter.mdl")
	engfunc(EngFunc_PrecacheModel, "models/player/PerfectZM_Regenerator/PerfectZM_Regenerator.mdl")

	engfunc(EngFunc_PrecacheModel, "models/PerfectZM/PerfectZM_classic_claws.mdl")
	engfunc(EngFunc_PrecacheModel, "models/PerfectZM/PerfectZM_raptor_claws.mdl")
	engfunc(EngFunc_PrecacheModel, "models/PerfectZM/PerfectZM_regenerator_claws.mdl")
	engfunc(EngFunc_PrecacheModel, "models/PerfectZM/PerfectZM_frozen_claws.mdl")
	engfunc(EngFunc_PrecacheModel, "models/PerfectZM/PerfectZM_predator_claws.mdl")
	engfunc(EngFunc_PrecacheModel, "models/PerfectZM/PerfectZM_mutant_claws.mdl")
	engfunc(EngFunc_PrecacheModel, "models/PerfectZM/PerfectZM_hunter_claws.mdl")

	//register_forward(FM_AddToFullPack, "OnAddToFullpack", 1)

	// For 3rd person death
	precache_model("models/rpgrocket.mdl")

	engfunc(EngFunc_PrecacheModel, BubbleGrenadeModel)
	
	// Custom sprites for grenades
	ArrayGetString(Array:g_sprites[SPRITE_GRENADE_TRAIL], random_num(0, ArraySize(Array:g_sprites[SPRITE_GRENADE_TRAIL]) - 1), buffer, charsmax(buffer))
	g_trailspr = precache_model(buffer)
	ArrayGetString(Array:g_sprites[SPRITE_GRENADE_EXPLOSION], random_num(0, ArraySize(Array:g_sprites[SPRITE_GRENADE_EXPLOSION]) - 1), buffer, charsmax(buffer))
	g_explosionspr = precache_model(buffer)

	// Crossbow
	precache_model(crossbow_V_MODEL)
	precache_model(crossbow_P_MODEL)
	precache_model(crossbow_W_MODEL)	
	precache_sound("PerfectZM/crossbow_shoot.wav")
	precache_sound("PerfectZM/crossbow_foley1.wav")
	precache_sound("PerfectZM/crossbow_foley2.wav")
	precache_sound("PerfectZM/crossbow_foley3.wav")
	precache_sound("PerfectZM/crossbow_foley4.wav")
	precache_sound("PerfectZM/crossbow_draw.wav")

	g_spriteLightning = precache_model("models/PerfectZM/arrow.mdl")

	register_forward(FM_PrecacheEvent, "fwPrecacheEvent_Post", 1)

	g_tClassNames = TrieCreate()
	RegisterHam(Ham_TraceAttack, "worldspawn", "TraceAttack", 1)
	TrieSetCell(g_tClassNames, "worldspawn", 1)
	RegisterHam(Ham_TraceAttack, "player", "TraceAttack", 1)
	TrieSetCell(g_tClassNames, "player", 1)
	register_forward(FM_Spawn, "Spawn", 1)
	
	// CS sounds (just in case)
	engfunc(EngFunc_PrecacheSound, sound_flashlight)
	engfunc(EngFunc_PrecacheSound, sound_buyammo)
	engfunc(EngFunc_PrecacheSound, sound_armorhit)
	
	new ent
	
	// Fake Hostage (to force round ending)
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "hostage_entity"))
	if (pev_valid(ent))
	{
		engfunc(EngFunc_SetOrigin, ent, Float:{8192.0,8192.0,8192.0})
		dllfunc(DLLFunc_Spawn, ent)
	}
	
	// Fog
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
	if (pev_valid(ent))
	{
		fm_set_kvd(ent, "density", "0.00086", "env_fog")
		fm_set_kvd(ent, "rendercolor", "128 128 128", "env_fog")
	}
	//if (g_ambience_snow) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_snow"))

	// Custom buyzone for all players
	g_buyzone_ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_buyzone"))
	if (pev_valid(g_buyzone_ent))
	{
		dllfunc(DLLFunc_Spawn, g_buyzone_ent)
		set_pev(g_buyzone_ent, pev_solid, SOLID_NOT)
	}
	
	// Prevent some entities from spawning
	UnregisterFwSpawn = register_forward(FM_Spawn, "fw_Spawn")
	
	// Prevent hostage sounds from being precached
	UnregisterFwPrecacheSound = register_forward(FM_PrecacheSound, "fw_PrecacheSound")
}

public Spawn(iEnt)
{
	if (pev_valid(iEnt))
	{
		static szClassName[32]
		pev(iEnt, pev_classname, szClassName, charsmax(szClassName))
		
		if (!TrieKeyExists(g_tClassNames, szClassName))
		{
			RegisterHam(Ham_TraceAttack, szClassName, "TraceAttack", 1)
			TrieSetCell(g_tClassNames, szClassName, 1)
		}
	}
}

/*public OnAddToFullpack(es_handle, e, ent, host, hostflags, player, pSet)
{
	if (!player) return FMRES_IGNORED

	if (get_user_team(host) == get_user_team(ent))
	{
		set_es(es_handle, ES_RenderFx, kRenderFxGlowShell)
		set_es(es_handle, ES_RenderColor, {100, 150, 220})
		set_es(es_handle, ES_RenderMode, kRenderTransAlpha)
		set_es(es_handle, ES_RenderAmt, 20)
	}
}*/

public fwPrecacheEvent_Post(type, const name[])
{
	if (equal("events/sg550.sc", name))
	{
		g_orig_event_crossbow = get_orig_retval()
		return FMRES_HANDLED
	}

	return FMRES_IGNORED
}

public plugin_init()
{
	// Plugin disabled?
	if (!g_pluginenabled) return
	
	// Events
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("CurWeapon", "event_CurWeapon", "be", "1=1")
	register_logevent("logevent_round_start",2, "1=Round_Start")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	register_event("StatusValue", "event_show_status", "be", "1=2", "2!0")
	register_event("StatusValue", "event_hide_status", "be", "1=1", "2=0")
	register_event("30", "event_intermission", "a")
	register_event("ResetHUD", "event_reset_hud", "be")
	
	// HAM Forwards
	RegisterHam(Ham_Spawn, "player", "OnPlayerSpawn", 1)
	RegisterHam(Ham_Killed, "player", "OnPlayerKilled")
	RegisterHam(Ham_Killed, "player", "OnPlayerKilledPost", 1)
	RegisterHam(Ham_TakeDamage, "player", "OnTakeDamage")
	RegisterHam(Ham_TakeDamage, "player", "OnTakeDamagePost", 1)
	RegisterHam(Ham_TraceAttack, "player", "OnTraceAttack")
	RegisterHam(Ham_Player_Jump, "player", "OnPlayerJump")
	RegisterHam(Ham_Player_Duck, "player", "OnPlayerDuck")

	for (new i = 1; i < sizeof WEAPONENTNAMES; i++)
	if (WEAPONENTNAMES[i][0]) RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "OnWeaponDeploy", 1)
	
	RegisterHam(Ham_Player_ResetMaxSpeed, "player", "OnResetMaxSpeedPost", 1)
	RegisterHam(Ham_Use, "func_tank", "OnUseStationary")
	RegisterHam(Ham_Use, "func_tankmortar", "OnUseStationary")
	RegisterHam(Ham_Use, "func_tankrocket", "OnUseStationary")
	RegisterHam(Ham_Use, "func_tanklaser", "OnUseStationary")
	RegisterHam(Ham_Use, "func_tank", "OnUseStationaryPost", 1)
	RegisterHam(Ham_Use, "func_tankmortar", "OnUseStationaryPost", 1)
	RegisterHam(Ham_Use, "func_tankrocket", "OnUseStationaryPost", 1)
	RegisterHam(Ham_Use, "func_tanklaser", "OnUseStationaryPost", 1)
	RegisterHam(Ham_Touch, "weaponbox", "OnTouchWeapon")
	RegisterHam(Ham_Touch, "armoury_entity", "OnTouchWeapon")
	RegisterHam(Ham_Touch, "weapon_shield", "OnTouchWeapon")
	RegisterHam(Ham_AddPlayerItem, "player", "OnAddPlayerItem")
	RegisterHam(Ham_Think, "grenade", "OnThinkGrenade")

	// Knife Blink
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "OnKnifeBlinkAttack")

	// Crossbow
	RegisterHam(Ham_Item_AddToPlayer, "weapon_sg550", "OnCrossbowAddToPlayer")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg550", "OnCrossbowPrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg550", "OnCrossbowPrimaryAttackPost", 1)
	RegisterHam(Ham_Item_PostFrame, "weapon_sg550", "OnCrossbowPostFrame")
	RegisterHam(Ham_Weapon_Reload, "weapon_sg550", "OnCrossbowReload")
	RegisterHam(Ham_Weapon_Reload, "weapon_sg550", "OnCrossbowReloadPost", 1)
	register_forward(FM_UpdateClientData, "FwUpdateClientDataPost", 1)
	register_forward(FM_PlaybackEvent, "FwPlaybackEvent")

	// No recoil
	new weapon_name[24]
	for (new i = 1; i <= 30; i++)
	{
		if (!(ZOMBIE_ALLOWED_WEAPONS_BITSUM & 1 << i) && get_weaponname(i, weapon_name, 23))
		{
			RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "OnWeaponPrimaryAttack")
			RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "OnWeaponPrimaryAttackPost", 1)
		}
	}
	
	// FM Forwards
	register_forward(FM_TraceLine, "FwTraceLine")
	register_forward(FM_ClientDisconnect, "FwPlayerDisconnect")
	register_forward(FM_ClientDisconnect, "FwPlayerDisconnectPost", 1)
	register_forward(FM_ClientKill, "FwPlayerKill")
	register_forward(FM_EmitSound, "FwEmitSound")
	register_forward(FM_SetClientKeyValue, "FwSetPlayerKeyValue")
	register_forward(FM_ClientUserInfoChanged, "FwPlayerUserInfoChanged")
	register_forward(FM_GetGameDescription, "FwGetGameDescription")
	register_forward(FM_SetModel, "FwSetModel")
	register_forward(FM_CmdStart, "FwCmdStart")
	register_forward(FM_PlayerPreThink, "FwPlayerPreThink")
	register_forward(FM_Touch, "FwTouch")
	unregister_forward(FM_Spawn, UnregisterFwSpawn)
	unregister_forward(FM_PrecacheSound, UnregisterFwPrecacheSound)
	
	// id commands
	register_clcmd("nightvision", "clcmd_nightvision")
	register_clcmd("drop", "clcmd_drop")
	register_clcmd("chooseteam", "clcmd_changeteam")
	register_clcmd("jointeam", "clcmd_changeteam")
	register_clcmd("say", "Client_Say")
	register_clcmd("say_team", "Client_SayTeam")
	register_clcmd("radio1", "Admin_menu")
	register_clcmd("radio2", "Admin_menu")
	register_clcmd("radio3", "Admin_menu")
	
	
	// CS Buy Menus (to prevent zombies/survivor from buying)
	register_menucmd(register_menuid("#Buy", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyPistol", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyShotgun", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuySub", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyRifle", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyMachine", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyItem", 1), 511, "menu_cs_buy")
	register_menucmd(-28, 511, "menu_cs_buy")
	register_menucmd(-29, 511, "menu_cs_buy")
	register_menucmd(-30, 511, "menu_cs_buy")
	register_menucmd(-32, 511, "menu_cs_buy")
	register_menucmd(-31, 511, "menu_cs_buy")
	register_menucmd(-33, 511, "menu_cs_buy")
	register_menucmd(-34, 511, "menu_cs_buy")
	
	// Admin commands
	register_concmd("amx_who", "cmd_who", -1, _, -1)
	register_concmd("amx_nick", "cmd_nick", -1, _, -1)
	register_concmd("amx_slap", "cmd_slap", -1, _, -1)
	register_concmd("zp_slap", "cmd_slap", -1, _, -1)
	register_concmd("amx_slay", "cmd_slay", -1, _, -1)
	register_concmd("zp_slay", "cmd_slay", -1, _, -1)
	register_concmd("amx_kick", "cmd_kick", -1, _, -1)
	register_concmd("zp_kick", "cmd_kick", -1, _, -1)
	register_concmd("amx_freeze", "cmd_freeze", -1, _, -1)
	register_concmd("zp_freeze", "cmd_freeze", -1, _, -1)
	register_concmd("amx_unfreeze", "cmd_unfreeze", -1, _, -1)
	register_concmd("zp_unfreeze", "cmd_unfreeze", -1, _, -1)
	register_concmd("amx_map", "cmd_map", -1, _, -1)
	register_concmd("zp_map", "cmd_map", -1, _, -1)
	register_concmd("amx_destroy", "cmd_destroy", -1, _, -1)
	register_concmd("zp_destroy", "cmd_destroy", -1, _, -1)
	register_concmd("amx_psay", "cmd_psay", -1, _, -1)
	register_concmd("zp_psay", "cmd_psay", -1, _, -1)
	register_concmd("amx_showip", "cmd_showip", -1, _, -1)
	register_concmd("zp_showip", "cmd_showip", -1, _, -1)
	register_concmd("zp_punish", "cmd_punish", -1, _, -1)
	register_concmd("amx_punish", "cmd_punish", -1, _, -1)
	register_concmd("amx_reloadadmins", "cmd_reloadadmins", -1, _, -1)
	register_concmd("zp_reloadadmins", "cmd_reloadadmins", -1, _, -1)
	register_concmd("amx_reloadvips", "cmd_reloadvips", -1, _, -1)
	register_concmd("zp_reloadvips", "cmd_reloadvips", -1, _, -1)

	register_concmd("amx_votemap", "cmd_votemap", -1, _, -1)
	register_concmd("zp_votemap", "cmd_votemap", -1, _, -1)

	register_concmd("amx_last", "cmd_last", -1, _, -1)
	register_concmd("zp_last", "cmd_last", -1, _, -1)
	register_concmd("amx_gag", "cmd_gag", -1, _, -1)
	register_concmd("zp_gag", "cmd_gag", -1, _, -1)
	register_concmd("amx_ungag", "cmd_ungag", -1, _, -1)
	register_concmd("zp_ungag", "cmd_ungag", -1, _, -1)
	register_concmd("amx_jetpack", "cmd_jetpack", -1, _, -1)
	register_concmd("zp_jetpack", "cmd_jetpack", -1, _, -1)
	register_concmd("amx_ammo", "cmd_ammo", -1, _, -1)
	register_concmd("zp_ammo", "cmd_ammo", -1, _, -1)
	register_concmd("zp_zombie", "cmd_zombie", -1, _, -1)
	register_concmd("amx_zombie", "cmd_zombie", -1, _, -1)
	register_concmd("zp_human", "cmd_human", -1, _, -1)
	register_concmd("amx_human", "cmd_human", -1, _, -1)
	register_concmd("zp_nemesis", "cmd_nemesis", -1, _, -1)
	register_concmd("amx_nemesis", "cmd_nemesis", -1, _, -1)
	register_concmd("zp_assassin", "cmd_assassin", -1, _, -1)
	register_concmd("amx_assassin", "cmd_assassin", -1, _, -1)
	register_concmd("zp_bombardier", "cmd_bombardier", -1, _, -1)
	register_concmd("amx_bombardier", "cmd_bombardier", -1, _, -1)
	register_concmd("zp_survivor", "cmd_survivor", -1, _, -1)
	register_concmd("amx_survivor", "cmd_survivor", -1, _, -1)
	register_concmd("zp_sniper", "cmd_sniper", -1, _, -1)
	register_concmd("amx_sniper", "cmd_sniper", -1, _, -1)
	register_concmd("zp_samurai", "cmd_samurai", -1, _, -1)
	register_concmd("amx_samurai", "cmd_samurai", -1, _, -1)
	register_concmd("zp_grenadier", "cmd_grenadier", -1, _, -1)
	register_concmd("amx_grenadier", "cmd_grenadier", -1, _, -1)
	register_concmd("zp_terminator", "cmd_terminator", -1, _, -1)
	register_concmd("amx_terminator", "cmd_terminator", -1, _, -1)
	register_concmd("zp_revenant", "cmd_revenant", -1, _, -1)
	register_concmd("amx_revenant", "cmd_revenant", -1, _, -1)
	register_concmd("zp_respawn", "cmd_respawn", -1, _, -1)
	register_concmd("amx_respawn", "cmd_respawn", -1, _, -1)
	register_concmd("zp_swarm", "cmd_swarm", -1, _, -1)
	register_concmd("amx_swarm", "cmd_swarm", -1, _, -1)
	register_concmd("zp_multi", "cmd_multi", -1, _, -1)
	register_concmd("amx_multi", "cmd_multi", -1, _, -1)
	register_concmd("zp_plague", "cmd_plague", -1, _, -1)
	register_concmd("amx_plague", "cmd_plague", -1, _, -1)
	register_concmd("zp_armageddon", "cmd_armageddon", -1, _, -1)
	register_concmd("amx_armageddon", "cmd_armageddon", -1, _, -1)
	register_concmd("zp_apocalypse", "cmd_apocalypse", -1, _, -1)
	register_concmd("amx_apocalypse", "cmd_apocalypse", -1, _, -1)
	register_concmd("zp_nightmare", "cmd_nightmare", -1, _, -1)
	register_concmd("amx_nightmare", "cmd_nightmare", -1, _, -1)
	register_concmd("zp_synapsis", "cmd_synapsis", -1, _, -1)
	register_concmd("amx_synapsis", "cmd_synapsis", -1, _, -1)
	register_concmd("zp_devil", "cmd_devil", -1, _, -1)
	register_concmd("amx_devil", "cmd_devil", -1, _, -1)
	register_concmd("zp_survivor_vs_assasin", "cmd_survivor_vs_assasin", -1, _, -1)
	register_concmd("amx_survivor_vs_assasin", "cmd_survivor_vs_assasin", -1, _, -1)
	register_concmd("zp_bombardier_vs_grenadier", "cmd_bombardier_vs_grenadier", -1, _, -1)
	register_concmd("amx_bombardier_vs_grenadier", "cmd_bombardier_vs_grenadier", -1, _, -1)
	register_concmd("zp_points", "cmd_points", -1, _, -1)
	register_concmd("amx_points", "cmd_points", -1, _, -1)
	register_concmd("zp_resetpoints", "cmd_resetpoints", -1, _, -1)
	register_concmd("amx_resetpoints", "cmd_resetpoints", -1, _, -1)
	
	// Message hooks
	register_message(get_user_msgid("CurWeapon"), "message_cur_weapon")
	register_message(get_user_msgid("Money"), "message_money")
	register_message(get_user_msgid("Health"), "message_health")
	register_message(get_user_msgid("FlashBat"), "message_flashbat")
	register_message(get_user_msgid("ScreenFade"), "message_screenfade")
	register_message(get_user_msgid("NVGToggle"), "message_nvgtoggle")
	register_message(get_user_msgid("WeapPickup"), "message_weappickup")
	register_message(get_user_msgid("AmmoPickup"), "message_ammopickup")
	register_message(get_user_msgid("Scenario"), "message_scenario")
	register_message(get_user_msgid("HostagePos"), "message_hostagepos")
	register_message(get_user_msgid("TextMsg"), "message_textmsg")
	register_message(get_user_msgid("SendAudio"), "message_sendaudio")
	register_message(get_user_msgid("SayText"), "message_saytext")
	register_message(get_user_msgid("TeamInfo"), "message_teaminfo")
	register_message(get_user_msgid("TeamScore"), "message_teamscore")
	register_message(get_user_msgid("HudTextArgs"), "message_hudtextargs")
	register_message(get_user_msgid("StatusValue"), "message_statustext")
	
	// Blocked messages
	set_msg_block(get_user_msgid("Radar"), BLOCK_SET) 
	set_msg_block(get_user_msgid("WeapPickup"), BLOCK_SET) 
	set_msg_block(get_user_msgid("AmmoPickup"), BLOCK_SET)

	// Forwards 
	g_forwards[ROUND_START] = CreateMultiForward("OnRoundStart", ET_IGNORE, FP_CELL, FP_CELL)
	//g_forwards[ROUND_START_PRE] = CreateMultiForward("OnRoundStartedPre", ET_CONTINUE, FP_CELL)
	g_forwards[ROUND_END] = CreateMultiForward("OnRoundEnd", ET_IGNORE, FP_CELL)
	g_forwards[INFECT_ATTEMP] = CreateMultiForward("OnInfectAttempt", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL)
	g_forwards[INFECTED_PRE] = CreateMultiForward("OnInfectedPre", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_forwards[INFECTED_POST] = CreateMultiForward("OnInfectedPost", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_forwards[HUMANIZE_ATTEMP] = CreateMultiForward("OnHumanizeAttempt", ET_CONTINUE, FP_CELL, FP_CELL)
	g_forwards[HUMANIZED_PRE] = CreateMultiForward("OnHumanizedPre", ET_IGNORE, FP_CELL, FP_CELL)
	g_forwards[HUMANIZED_POST] = CreateMultiForward("OnHumanizedPost", ET_IGNORE, FP_CELL, FP_CELL)
	g_forwards[USER_LAST_ZOMBIE] = CreateMultiForward("OnLastZombie", ET_IGNORE, FP_CELL)
	g_forwards[USER_LAST_HUMAN] = CreateMultiForward("OnLastHuman", ET_IGNORE, FP_CELL)
	g_forwards[ADMIN_MODE_START] = CreateMultiForward("OnAdminModeStart", ET_IGNORE, FP_CELL, FP_CELL)
	g_forwards[POINTS_SHOP_WEAPON_SELECTED] = CreateMultiForward("OnPointsShopWeaponSelected", ET_IGNORE, FP_CELL, FP_CELL)
	g_forwards[EXTRA_ITEM_SELECTED] = CreateMultiForward("OnExtraItemSelected", ET_IGNORE, FP_CELL, FP_CELL)

	// create our array with the size of the item structure
	g_pointsShopWeapons = ArrayCreate(pointsShopDataStructure)
	g_extraitems = ArrayCreate(extraItemsDataStructure)
	
	// CVARS - Others
	cvar_botquota = get_cvar_pointer("bot_quota")
	register_cvar("zp_version", "1.0", FCVAR_SERVER|FCVAR_SPONLY)
	set_cvar_string("zp_version", "1.0")
	
	// Set Sky
	set_cvar_string("sv_skyname", g_sky_names[random(sizeof g_sky_names)])
	
	// Disable sky lighting so it doesn't mess with our custom lighting
	set_cvar_num("sv_skycolor_r", 0)
	set_cvar_num("sv_skycolor_g", 0)
	set_cvar_num("sv_skycolor_b", 0)
	
	// Create the HUD Sync Objects
	g_MsgSync 	  = CreateHudSyncObj()
	g_MsgSync2 	  = CreateHudSyncObj()
	g_MsgSync3 	  = CreateHudSyncObj()
	g_MsgSync4 	  = CreateHudSyncObj()
	g_MsgSync5[0] = CreateHudSyncObj()
	g_MsgSync5[1] = CreateHudSyncObj()
	g_MsgSync5[2] = CreateHudSyncObj()
	g_MsgSync5[3] = CreateHudSyncObj()
	g_MsgSync6 	  = CreateHudSyncObj()
	g_MsgSync7 	  = CreateHudSyncObj()

	
	// Get Max Players
	g_maxplayers = get_maxplayers()
	
	// Reserved saving slots starts on maxplayers+1
	db_slot_i = g_maxplayers+1
	
	// Check if it's a CZ server
	new mymod[6]
	get_modname(mymod, charsmax(mymod))
	if (equal(mymod, "czero")) g_czero = 1

	g_mainAdminMenuCallback = menu_makecallback("MainAdminMenuCallback")
	g_makeHumanClassMenuCallback= menu_makecallback("MakeHumanClassMenuCallback")
	g_makeZombieClassMenuCallback = menu_makecallback("MakeZombieClassMenuCallback")
	g_startNormalModesCallback = menu_makecallback("StartNormalModesCallBack")
	g_startSpecialModesCallback = menu_makecallback("StartSpecialModesCallBack")
	g_playersMenuCallback = menu_makecallback("PlayersMenuCallBack")

	new cLine[128]
	new cNumber[3]
	g_iGameMenu = menu_create("Game Menu", "_GameMenu", 0)	// Game menu
	g_iZombieClassMenu = menu_create("Zombie Classes", "_ZombieClasses", 0)	// Zombie class menu
	g_iStatisticsMenu = menu_create("Statistics Menu", "_StatisticsMenu", 0) // Statistics Sub - menu
	g_iPointShopMenu = menu_create("Points Shop", "_PointShop", 0)	// Points shop menu
	g_iAmmoMenu = menu_create("Buy Ammo Packs", "_AmmoMenu", 0)	// Ammo shop menu
	g_iFeaturesMenu = menu_create("Buy Features", "_Features", 0)	// Features menu
	g_iModesMenu = menu_create("Buy Modes", "_Modes", 0)	// Modes menu
	
	// Main Game menu
	menu_additem(g_iGameMenu, "Buy extra items", "0", 0, -1)
	menu_additem(g_iGameMenu, "Choose zombie class", "1", 0, -1)
	menu_additem(g_iGameMenu, "Buy features with points", "2", 0, -1)
	menu_additem(g_iGameMenu, "Unstuck", "3", 0, -1)
	menu_additem(g_iGameMenu, "Statistics", "4", 0, -1)
	
	// Zombie Classes menu
	for (new i; i < sizeof(g_cZombieClasses); i++)
	{
		formatex(cLine, 128, "%s %s", g_cZombieClasses[i][ZombieName], g_cZombieClasses[i][ZombieAttribute])
		num_to_str(i, cNumber, 3)
		menu_additem(g_iZombieClassMenu, cLine, cNumber, 0, -1)
	}

	// Statistics menu
	menu_additem(g_iStatisticsMenu, "Your rank", "0", 0, -1)
	menu_additem(g_iStatisticsMenu, "Global top 10", "1", 0, -1)
	menu_additem(g_iStatisticsMenu, "Today's top players", "2", 0, -1)

	// Points Shop menu
	for (new i; i < sizeof(g_cPointsMenu); i++)
	{
		formatex(cLine, 128, "%s", g_cPointsMenu[i][_pName])
		num_to_str(i, cNumber, 3)
		menu_additem(g_iPointShopMenu, cLine, cNumber, 0, -1)
	}
	
	// Ammo packs menu
	for (new i; i < sizeof(g_cAmmoMenu); i++)
	{
		formatex(cLine, 128, "%s %s", g_cAmmoMenu[i][_ammoItemName], g_cAmmoMenu[i][_ammoItemTag])
		num_to_str(i, cNumber, 3)
		menu_additem(g_iAmmoMenu, cLine, cNumber, 0, -1)
	}
	
	// Features menu
	for (new i; i < sizeof(g_cFeaturesMenu); i++)
	{
		formatex(cLine, 128, "%s %s", g_cFeaturesMenu[i][_fItemName], g_cFeaturesMenu[i][_fItemTag])
		num_to_str(i, cNumber, 3)
		menu_additem(g_iFeaturesMenu, cLine, cNumber, 0, -1)
	}
	
	// Modes menu
	for (new i; i < sizeof(g_cModesMenu); i++)
	{
		formatex(cLine, 128, "%s %s", g_cModesMenu[i][_mItemName], g_cModesMenu[i][_mItemTag])
		num_to_str(i, cNumber, 3)
		menu_additem(g_iModesMenu, cLine, cNumber, 0, -1)
	}

	//register_cvar("amx_nextmap", "", FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY)

	g_adminsTrie = TrieCreate()
	g_vipsTrie = TrieCreate()
	g_tagTrie = TrieCreate()

	g_hudAdvertisementMessages = ArrayCreate(512)

	MySql_Init()
	MySql_TotalPlayers()
	ReadPlayerTagsFromFile()
	ReadAdminsFromFile()
	ReadVipsFromFile()
	ReadChatAdvertisementsFromFile()
	ReadHudAdvertisementsFromFile()
	//TaskGetMaps()

	register_extra_item("Nightvision Goggles", 2, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER|ZQ_EXTRA_GRENADIER)
	register_extra_item("Forcefield Grenade", 20, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER|ZQ_EXTRA_SURVIVOR|ZQ_EXTRA_SNIPER|ZQ_EXTRA_SAMURAI)
	register_extra_item("Killing Grenade", 30, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER)
	register_extra_item("Explosion Grenade", 5, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER|ZQ_EXTRA_SURVIVOR|ZQ_EXTRA_SNIPER)
	register_extra_item("Napalm Grenade", 5, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER|ZQ_EXTRA_SURVIVOR|ZQ_EXTRA_SNIPER)
	register_extra_item("Frost Grenade", 5, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER|ZQ_EXTRA_SURVIVOR|ZQ_EXTRA_SNIPER)
	register_extra_item("Antidote Grenade", 40, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER)
	register_extra_item("Multijump +1", 5, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER|ZQ_EXTRA_GRENADIER)
	register_extra_item("Jetpack + Bazooka", 30, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER|ZQ_EXTRA_SURVIVOR|ZQ_EXTRA_SNIPER|ZQ_EXTRA_GRENADIER|ZQ_EXTRA_TERMINATOR)
	register_extra_item("Tryder", 30, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER)
	register_extra_item("Armor \y(100 AP)", 5, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER)
	register_extra_item("Armor \y(200 AP)", 10, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER)
	register_extra_item("Crossbow", 30, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER)
	register_extra_item("Golden Weapons", 150, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER)
	register_extra_item("Nemesis", 150, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER)
	register_extra_item("Assasin", 150, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER)
	register_extra_item("Sniper", 180, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER)
	register_extra_item("Survivor", 180, ZQ_EXTRA_HUMAN|ZQ_EXTRA_TRYDER)
	register_extra_item("Antidote", 15, ZQ_EXTRA_ZOMBIE)
	register_extra_item("Zombie Maddness", 17, ZQ_EXTRA_ZOMBIE)
	register_extra_item("Infection Bomb", 25, ZQ_EXTRA_ZOMBIE)
	register_extra_item("Concussion Bomb", 10, ZQ_EXTRA_ZOMBIE)
	register_extra_item("Knife Blink", 10, ZQ_EXTRA_ZOMBIE)

	register_points_shop_weapon("Golden Weapons", 2000)
	register_points_shop_weapon("Crossbow", 4000)
	
	set_task(3.0, "CheckBots", .flags = "b")
	set_task(30.0, "Advertise", .flags = "b")
}

public MySql_Init()
{
	// Set Affinity to use SQLite instead of SQL
	SQL_SetAffinity("sqlite")

    // We tell the API that this is the information we want to connect to,
    // just not yet. basically it's like storing it in global variables
	g_SqlTuple = SQL_MakeDbTuple("", "", "", "ZombieQueen")
   
    // Ok, we're ready to connect
	new ErrorCode, Handle:SqlConnection = SQL_Connect(g_SqlTuple, ErrorCode, g_Error, charsmax(g_Error))

	if (SqlConnection == Empty_Handle)
    {
		// stop the plugin with an error message
        set_fail_state(g_Error)
    }

	new Handle:Queries

    // We must now prepare some random queries
	Queries = SQL_PrepareQuery(SqlConnection, "CREATE TABLE IF NOT EXISTS `perfectzm` (NICKNAME varchar(32), HASH varchar(150), KILLS INT(11), DEATHS INT(11), INFECTIONS INT(11), NEMESISKILLS INT(11), ASSASINKILLS INT(11), BOMBARDIERKILLS INT(11), SURVIVORKILLS INT(11), SNIPERKILLS INT(11), SAMURAIKILLS INT(11), GRENADIERKILLS INT(11), TERMINATORKILLS INT(11), REVENANTKILLS INT(11), POINTS INT(11), SCORE INT(11))")

	if (!SQL_Execute(Queries))
	{
	    // if there were any problems the plugin will set itself to bad load.
	    SQL_QueryError(Queries, g_Error, charsmax(g_Error))
	    set_fail_state(g_Error)
	}
    
	// Free the querie
	SQL_FreeHandle(Queries)

	// You free everything with SQL_FreeHandle
	SQL_FreeHandle(SqlConnection)   
}

public RegisterPlayerInDatabase(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
	switch (FailState)
	{
		case TQUERY_CONNECT_FAILED: log_amx("Load - Could not connect to SQL database.  [%d] %s", Errcode, Error)
		case TQUERY_QUERY_FAILED: log_amx("Load Query failed. [%d] %s", Errcode, Error)
	}

	new id; id = Data[0]

	if (SQL_NumResults(Query) < 1) 
	{
		// If there are no results found

		//  If its still pending we can't do anything with it
		//if (equal(g_playerSteamID[id], "ID_PENDING"))
		//return PLUGIN_HANDLED

		new szTemp[512]

	    // Now we will insturt the values into our table.
		format(szTemp, charsmax(szTemp), "INSERT INTO `perfectzm` (`NICKNAME`, `HASH`, `KILLS`, `DEATHS`, `INFECTIONS`, `NEMESISKILLS`, `ASSASINKILLS`, `BOMBARDIERKILLS`, `SURVIVORKILLS`, `SNIPERKILLS`, `SAMURAIKILLS`, `GRENADIERKILLS`, `TERMINATORKILLS`, `REVENANTKILLS`, `POINTS`, `SCORE`) VALUES ('%s', '%s', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');", g_playerName[id], g_playerHash[id])
		SQL_ThreadQuery(g_SqlTuple, "IgnoreHandle", szTemp)
		g_totalplayers++

		set_dhudmessage(0, 255, 255, 0.03, 0.5, 2, 6.0, 10.0)
		show_dhudmessage(id, "You are now ranked!")
	} 
	else 
	{
	    // if there are results found
		g_kills[id]  		  = SQL_ReadResult(Query, 2)
		g_deaths[id] 		  = SQL_ReadResult(Query, 3)
		g_infections[id] 	  = SQL_ReadResult(Query, 4)
		g_nemesiskills[id] 	  = SQL_ReadResult(Query, 5)
		g_assasinkills[id] 	  = SQL_ReadResult(Query, 6)
		g_bombardierkills[id] = SQL_ReadResult(Query, 7)
		g_survivorkills[id]   = SQL_ReadResult(Query, 8)
		g_sniperkills[id] 	  = SQL_ReadResult(Query, 9)
		g_samuraikills[id] 	  = SQL_ReadResult(Query, 10)
		g_grenadierkills[id]  = SQL_ReadResult(Query, 11)
		g_terminatorkills[id] = SQL_ReadResult(Query, 12)
		g_revenantkills[id]	  = SQL_ReadResult(Query, 13)
		g_points[id] 		  = SQL_ReadResult(Query, 14)
		g_score[id] 		  = SQL_ReadResult(Query, 15)

		set_dhudmessage(0, 255, 255, 0.03, 0.5, 2, 6.0, 10.0)
		show_dhudmessage(id, "You are now ranked!")
	}
    
	return PLUGIN_HANDLED
}

public MySql_TotalPlayers()
{
	new szTemp[512]
	format(szTemp, charsmax(szTemp), "SELECT * FROM `perfectzm`")
	SQL_ThreadQuery(g_SqlTuple, "SQLRanksCount", szTemp);
	return PLUGIN_CONTINUE;
}

public SQLRanksCount(FailState, Handle:Query, Error[], ErrorNum, Data[], DataSize)
{
	g_totalplayers = SQL_NumResults(Query)
	return PLUGIN_CONTINUE
} 

public MySQL_LOAD_DATABASE(id)
{
	new szTemp[512]

	new data[1]
	data[0] = id

	//we will now select from the table `tutorial` where the steamid match
	format(szTemp, charsmax(szTemp), "SELECT * FROM `perfectzm` WHERE `HASH` = '%s'", g_playerHash[id])
	SQL_ThreadQuery(g_SqlTuple, "RegisterPlayerInDatabase", szTemp, data, 1)
}

public MySQL_UPDATE_DATABASE(id)
{
	new szTemp[512]

	// Here we will update the user hes information in the database where the steamid matches.
	format(szTemp, charsmax(szTemp), "UPDATE `perfectzm` SET `KILLS` = '%i', `DEATHS` = '%i', `INFECTIONS` = '%i', `NEMESISKILLS` = '%i', `ASSASINKILLS` = '%i', `BOMBARDIERKILLS` = '%i', `SURVIVORKILLS` = '%i', `SNIPERKILLS` = '%i', `SAMURAIKILLS` = '%i', `GRENADIERKILLS` = '%i', `TERMINATORKILLS` = '%i', `REVENANTKILLS` = '%i', `POINTS` = '%i', `SCORE` = '%i' WHERE `HASH` = '%s';", g_kills[id], g_deaths[id], g_infections[id], g_nemesiskills[id], g_assasinkills[id], g_bombardierkills[id], g_survivorkills[id], g_sniperkills[id], g_samuraikills[id], g_grenadierkills[id], g_terminatorkills[id], g_revenantkills[id], g_points[id], g_score[id], g_playerHash[id])
	SQL_ThreadQuery(g_SqlTuple, "IgnoreHandle", szTemp)
} 

public MySQL_GetStatistics(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
	new id, rank, Float:var1, g_menu, menudata[256]
	rank = SQL_NumResults(Query)
	id = Data[0]
   
	if (g_deaths[id]) var1 = floatdiv(float(g_kills[id]), float(g_deaths[id]))
	else var1 = float(g_kills[id])
	
	g_menu = menu_create("\yRanking", "EmptyPanel", 0)
	formatex(menudata, 255, "Rank: \r%s \wout of \r%s  \wScore: \r%s", AddCommas(rank), AddCommas(g_totalplayers), AddCommas(g_score[id]))
	menu_additem(g_menu, menudata, "1", 0, -1)
	formatex(menudata, 255, "Total kills: \r%s  \wDeaths: \r%s  \wInfections: \r%s", AddCommas(g_kills[id]), AddCommas(g_deaths[id]), AddCommas(g_infections[id]))
	menu_additem(g_menu, menudata, "2", 0, -1)
	formatex(menudata, 255, "Kill Per Death Ratio: \r%0.2f", var1)
	menu_additem(g_menu, menudata, "3", 0, -1)
	formatex(menudata, 255, "Nemesis kills: \r%s", AddCommas(g_nemesiskills[id]))
	menu_additem(g_menu, menudata, "4", 0, -1)
	formatex(menudata, 255, "Assasin kills: \r%s", AddCommas(g_assasinkills[id]))
	menu_additem(g_menu, menudata, "5", 0, -1)
	formatex(menudata, 255, "Bombardier kills: \r%s", AddCommas(g_bombardierkills[id]))
	menu_additem(g_menu, menudata, "6", 0, -1)
	formatex(menudata, 255, "Survivor kills: \r%s", AddCommas(g_survivorkills[id]))
	menu_additem(g_menu, menudata, "7", 0, -1)
	formatex(menudata, 255, "Sniper kills: \r%s", AddCommas(g_sniperkills[id]))
	menu_additem(g_menu, menudata, "8", 0, -1)
	formatex(menudata, 255, "Samurai kills: \r%s", AddCommas(g_samuraikills[id]))
	menu_additem(g_menu, menudata, "9", 0, -1)
	formatex(menudata, 255, "Grenadier kills: \r%s", AddCommas(g_grenadierkills[id]))
	menu_additem(g_menu, menudata, "10", 0, -1)
	formatex(menudata, 255, "Terminator kills: \r%s", AddCommas(g_terminatorkills[id]))
	menu_additem(g_menu, menudata, "11", 0, -1)
	formatex(menudata, 255, "Revenant kills: \r%s", AddCommas(g_revenantkills[id]))
	menu_additem(g_menu, menudata, "12", 0, -1)

	menu_setprop(g_menu, 6, -1)
	menu_display(id, g_menu, 0)

	//formatex(menudata, 255, "")
	//menu_additem(g_menu, menudata, "", 0, -1)

	client_print_color(0, print_team_grey, "%s ^3%s^1's rank is ^4%s ^1out of ^4%s ^1[ ^3Kills: ^4%s ^1- ^3Deaths: ^4%s ^1- ^3KPD: ^4%0.2f ^1- ^3Score: ^4%s ^1]", CHAT_PREFIX, g_playerName[id], AddCommas(rank), AddCommas(g_totalplayers), AddCommas(g_kills[id]), AddCommas(g_deaths[id]), var1, AddCommas(g_score[id]))
    
	return PLUGIN_HANDLED
} 

public MySQL_WelcomeMessage(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
	new id, rank, Float:var1
	rank = SQL_NumResults(Query)
	id = Data[0]

	if (g_deaths[id]) var1 = floatdiv(float(g_kills[id]), float(g_deaths[id]))
	else var1 = float(g_kills[id])

	new HostName[64]
	get_cvar_string("hostname", HostName, charsmax(HostName))

	set_dhudmessage(random(256), random(256), random(256), 0.02, 0.2, 2, 6.0, 8.0)
	show_dhudmessage(id, "Welcome, %s^nRank: %s of %s Score: %s^nKills: %s Deaths: %s KPD: %0.2f^nEnjoy!",
	g_playerName[id], AddCommas(rank), AddCommas(g_totalplayers), AddCommas(clamp(g_score[id], 10, 999999)), AddCommas(clamp(g_kills[id], 0, 999999)), AddCommas(clamp(g_deaths[id], 0, 999999)), var1)
	
	set_dhudmessage(random(256), random(256), random(256), 0.02, 0.5, 2, 6.0, 8.0)
	show_dhudmessage(id, "%s^nDon't forget to add us to your favourites!", HostName)
    
	return PLUGIN_HANDLED
} 

public TopFunction(State, Handle:Query, Error[], ErrorCode, Data[], DataSize)
{
	static id, Buffer[2048], Place, Name[16], Score, Kills, Deaths, Infections, Points, Len

	Buffer[0] = '^0'

	id = Data[0]

	Place = 0

	if (is_user_connected(id))
	{
		formatex(Buffer, charsmax(Buffer), "<meta charset=utf-8><style>body{background:#112233;font-family:Arial}th{background:#2E2E2E;color:#FFF;padding:5px 2px;text-align:left}td{padding:5px 2px}table{width:100%%;background:#EEEECC;font-size:15px;}h2{color:#FFF;font-family:Verdana;text-align:center}#nr{text-align:center}#c{background:#E2E2BC}</style><h2>%s</h2><table border=^"0^" align=^"center^" cellpadding=^"0^" cellspacing=^"1^"><tbody>", "TOP 10")
		Len = add(Buffer, charsmax(Buffer), "<tr><th id=nr>#</th><th>NAME<th>KILLS<th>DEATHS<th>INFECTIONS<th>POINTS<th>SCORE<th>KPD")

		while (SQL_MoreResults(Query))
		{
			SQL_ReadResult(Query, 0, Name, charsmax(Name))

			Kills 	   = SQL_ReadResult(Query, 1)
			Deaths 	   = SQL_ReadResult(Query, 2)
			Infections = SQL_ReadResult(Query, 3)
			Points     = SQL_ReadResult(Query, 4)
			Score	   = SQL_ReadResult(Query, 5)

			new Float:KPD

			if (Deaths) KPD = floatdiv(float(Kills), float(Deaths))
			else KPD = float(Kills)

			++Place

			Len += formatex(Buffer[Len], charsmax(Buffer), "<tr %s><td id=nr>%i<td>%s<td>%s<td>%s<td>%s<td>%s<td>%s<td>%.2f", Place % 2 == 0 ? "" : " id=c", Place, Name, AddCommas(clamp(Kills, 0, 99999)), AddCommas(clamp(Deaths, 0, 99999)), AddCommas(clamp(Infections, 0, 99999)), AddCommas(clamp(Points, 0, 99999)), AddCommas(clamp(Score, 0, 99999)), floatclamp(KPD, 0.10, 10.00))

			SQL_NextRow(Query)
		}

		new ServerName[128]
		get_cvar_string("hostname", ServerName, charsmax(ServerName))
		
		formatex(Buffer[Len], charsmax(Buffer), "<tr><th colspan=^"10^" id=nr>%s", ServerName)
		add(Buffer, charsmax(Buffer), "</tbody></table></body>")
		
		show_motd(id, Buffer, "Global Top 10")
	}

	SQL_FreeHandle(Query)
}

public init_welcome(id)
{
	new szTemp[512]
	new Data[1]
	Data[0] = id
	format(szTemp,charsmax(szTemp),"SELECT DISTINCT `SCORE` FROM `perfectzm` WHERE `SCORE` >= %d ORDER BY `SCORE` ASC", g_score[id])
	SQL_ThreadQuery(g_SqlTuple, "MySQL_WelcomeMessage", szTemp, Data, 1)
}

public EmptyPanel(id, iMenu, iItem){ return PLUGIN_CONTINUE; }

public IgnoreHandle(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
	SQL_FreeHandle(Query)

	return PLUGIN_HANDLED
}

public ShowPlayerStatistics(id)
{
	new szTemp[512]
	new Data[1]
	Data[0] = id
	format(szTemp, charsmax(szTemp), "SELECT DISTINCT `SCORE` FROM `perfectzm` WHERE `SCORE` >= %d ORDER BY `SCORE` ASC;", g_score[id])
	SQL_ThreadQuery(g_SqlTuple, "MySQL_GetStatistics", szTemp, Data, 1)
}

public ShowGlobalTop15(id)
{
	new szTemp[512]
	new Data[1]
	Data[0] = id
	format(szTemp, charsmax(szTemp), "SELECT `NICKNAME`, `KILLS`, `DEATHS`, `INFECTIONS`, `POINTS`, `SCORE` FROM `perfectzm` ORDER BY `SCORE` DESC LIMIT 10;")
	SQL_ThreadQuery(g_SqlTuple, "TopFunction", szTemp, Data, 1)
}

public ReadAdminsFromFile()
{
	static iFile; iFile = fopen("addons/amxmodx/configs/accounts/Admin/Admins.ini", "r")
	new Data[adminInfoStruct]

	if (iFile)
	{
		static cLine[161]
		while (!feof(iFile))
		{
			fgets(iFile, cLine, charsmax(cLine))
			trim(cLine)
			if (cLine[0] != 59 && strlen(cLine) > 5)
			{
				parse(cLine, Data[_aName], charsmax(Data[_aName]), Data[_aPassword], charsmax(Data[_aPassword]), Data[_aFlags], charsmax(Data[_aFlags]), Data[_aRank], charsmax(Data[_aRank]))
				TrieSetArray(g_adminsTrie, Data[_aName], Data, sizeof(Data))
				g_adminCount++
			}
		}
		fclose (iFile)

		log_amx("Loaded %d Admins from file...", g_adminCount)		
	}

	return PLUGIN_CONTINUE
}

public ReadVipsFromFile()
{
	static iFile; iFile = fopen("addons/amxmodx/configs/accounts/Vip/Vips.ini", "r")
	new Data[vipInfoStruct]

	if (iFile)
	{
		static cLine[161]
		while (!feof(iFile))
		{
			fgets(iFile, cLine, charsmax(cLine))
			trim(cLine)
			if (cLine[0] != 59 && strlen(cLine) > 5)
			{
				parse(cLine, Data[_vName], charsmax(Data[_vName]), Data[_vPassword], charsmax(Data[_vPassword]), Data[_vFlags], charsmax(Data[_vFlags]))
				TrieSetArray(g_vipsTrie, Data[_vName], Data, sizeof(Data))
				g_vipCount++
			}	
		}
		fclose (iFile)

		log_amx("Loaded %d Vips from file...", g_vipCount)	
	}

	return PLUGIN_CONTINUE
}

public ReadPlayerTagsFromFile()
{
	static iFile; iFile = fopen("addons/amxmodx/configs/accounts/PlayerTag/PlayerTags.ini", "r")
	new Data[playerTagInfoStruct]

	if (!iFile) log_amx("Tags file not found")

	if (iFile)
	{
		static cLine[161]
		while (!feof(iFile))
		{
			fgets(iFile, cLine, charsmax(cLine))
			trim(cLine)
			if (cLine[0] != 59 && strlen(cLine) > 5)
			{
				parse(cLine, Data[_tName], charsmax(Data[_tName]), Data[_tPassword], charsmax(Data[_tPassword]), Data[_tTag], charsmax(Data[_tTag]))
				TrieSetArray(g_tagTrie, Data[_tName], Data, sizeof(Data))
				g_tagCount++
			}
		}
		fclose (iFile)
	}

	return PLUGIN_CONTINUE
}

public ReadHudAdvertisementsFromFile()
{
	new file = fopen("addons/amxmodx/configs/hud_advertisements.ini", "r");

	if (file)
	{
		new line[512]

		while (!feof(file))
		{
			fgets(file, line, charsmax(line))
			trim(line)

			if (line[0])
			{
				while (replace(line, charsmax(line), "\n", "^n")){ }
				ArrayPushString(g_hudAdvertisementMessages, line)
			}
		}

		fclose(file)
	} 
	else log_amx("Failed to open hud_advertisements.ini file!")

	if (ArraySize(g_hudAdvertisementMessages)) set_task(30.0, "Advertise_HUD", .flags = "b")
}

public ReadChatAdvertisementsFromFile()
{
	static iFile; iFile = fopen("addons/amxmodx/configs/chat_advertisements.ini", "r")
	new cLine[161]

	if (iFile)
	{
		while (!feof(iFile))
		{
			fgets(iFile, cLine, 160)
			trim(cLine)
			if (cLine[0] == 33)
            {
				copy(g_cAdvertisements[g_iAdvertisementsCount], 160, cLine)
				replace_all(g_cAdvertisements[g_iAdvertisementsCount], 160, "!g", "^4")
				replace_all(g_cAdvertisements[g_iAdvertisementsCount], 160, "!t", "^3")
				replace_all(g_cAdvertisements[g_iAdvertisementsCount], 160, "!n", "^1")
				g_iAdvertisementsCount++
            }
		}
		fclose(iFile);
	}
	return PLUGIN_CONTINUE;
}

public MakeUserAdmin(id)
{
	new Data[adminInfoStruct]

	if (TrieGetArray(g_adminsTrie, g_playerName[id], Data, sizeof(Data)))
	{
		new g_password[33]
		get_user_info(id, "_pw", g_password, charsmax(g_password))

		if (equali(Data[_aPassword], g_password))
		{
			g_admin[id] = true
			copy(g_adminInfo[id][_aFlags], 49, Data[_aFlags])
			copy(g_adminInfo[id][_aRank], 31, Data[_aRank])

			log_amx("Login: ^"%s^" became an admin. [ %s ] - [ %s ] - [ %s ]", g_playerName[id], g_adminInfo[id][_aFlags], g_adminInfo[id][_aRank], g_playerIP[id])
		}
		else
		{
			server_cmd("kick #%d  You have no entry to the server...", get_user_userid(id))
			log_amx("Login: ^"%s^" kicked due to invalid password. [ %s ] [ %s ]", g_playerName[id], g_password, Data[_aPassword])
		}
	}

	return PLUGIN_CONTINUE
}

public MakeUserVip(id)
{
	new Data[vipInfoStruct]

	if (TrieGetArray(g_vipsTrie, g_playerName[id], Data, sizeof(Data)))
	{
		new g_password[33]
		get_user_info(id, "_pw", g_password, charsmax(g_password))

		if (equali(Data[_vPassword], g_password))
		{
			g_vip[id] = true
			g_jumpnum[id] = 2
			copy(g_vipInfo[id][_vFlags], 31, Data[_vFlags])
			log_amx("Login: ^"%s^" became an Vip. [ %s ] - [ %s ] ", g_playerName[id], g_vipInfo[id][_vFlags], g_playerIP[id])
			set_task(5.0, "Task_Rays", .flags = "b")
		}
		else
		{
			server_cmd("kick #%d  You have no entry to the server...", get_user_userid(id))
			log_amx("Login: ^"%s^" kicked due to invalid password. [ %s ] [ %s ]", g_playerName[id], g_password, Data[_vPassword])
		}
	}

	return PLUGIN_CONTINUE
}

public MakeFreeVIP(id)
{
	g_vip[id] = true
	copy(g_vipInfo[id][_vFlags], 31, freeVIP_Flags)

	set_dhudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), 0.03, 0.5, 2, 6.0, 10.0)
	show_dhudmessage(id, "You are now VIP!")
}

public GiveUserTag(id)
{
	new _tData[playerTagInfoStruct]

	if (TrieGetArray(g_tagTrie, g_playerName[id], _tData, sizeof(_tData)))
	{
		new g_password[33]
		get_user_info(id, "_pw", g_password, charsmax(g_password))

		if (equali(_tData[_tPassword], g_password))
		{
			copy(g_tag[id], 31, _tData[_tTag])		
			log_amx("Login: ^"%s^" got his Tag. [ %s ] ", g_playerName[id], g_tag[id])
		}
	}

	return PLUGIN_CONTINUE
}

public Task_Rays(id)
{
	for (new vip = 1; vip <= g_maxplayers; vip++)
	{
		if (is_user_alive(vip) && g_vip[vip] && VipHasFlag(vip, 'g'))
		{
			if (CheckBit(g_playerClass[vip], CLASS_HUMAN))
			{
				for (new z = 1;z <= g_maxplayers; z++)
				{
					if (is_user_alive(z) && CheckBit(g_playerClass[z], CLASS_ZOMBIE) && !ExecuteHam(Ham_FVisible, vip, z))
					{
						Beam(vip, z, 0, 255, 0)
					}
				}
			}
			else
			{
				for (new h = 1; h <= g_maxplayers; h++)
				{
					if (is_user_alive(h) && CheckBit(g_playerClass[h], CLASS_HUMAN) && !ExecuteHam(Ham_FVisible, vip, h))
					{
						Beam(vip, h, 0, 120, 190)
					}
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public CheckBots()
{
	if (get_playersnum(1) < g_maxplayers - 1 && g_iBotsCount < 2)
	{
		for (new i; i < sizeof g_cBotNames; i++) CreateBot(g_cBotNames[i])
	}
	else if (get_playersnum(1) > g_maxplayers - 1 && g_iBotsCount) RemoveBot()

	if (IsCurrentTimeBetween(freeVIP_Start, freeVIP_End))
	{
		for (new i = 1; i <= 32; i++)
		{
			if (g_vip[i]) continue

			MakeFreeVIP(i)
		}
	}
}

public Advertise()
{
	if (g_iMessage >= g_iAdvertisementsCount) 
	g_iMessage = 0

	client_print_color(0, print_team_grey, g_cAdvertisements[g_iMessage])
	g_iMessage += 1
	return PLUGIN_CONTINUE
}

public Advertise_HUD()
{
	static a,msg[512]

	for (a = 1; a <= get_maxplayers(); a++)
	{
		if (g_isconnected[a] && !g_isbot[a])
		{
			set_hudmessage(random_num(0, 230), random_num(0, 240), random_num(0, 230), -1.0, 0.20, 2, 0.2, 7.0, 0.1, 0.7, 2)
			ArrayGetString(g_hudAdvertisementMessages,random_num(0,ArraySize(g_hudAdvertisementMessages)-1), msg, 511)
			ShowSyncHudMsg(a, g_MsgSync7, msg)
		}
	}
}

public TaskReminder()
{
	static id; id = 1
	while (g_maxplayers + 1 > id)
	{
		if (g_isalive[id] && g_specialclass[id]) client_print_color(0, print_team_grey, "%s A ^3Rapture^1 Reminder ^3@ ^4%s^1 still has %s ^4health points!", CHAT_PREFIX, g_classString[id], AddCommas(pev(id, pev_health)))
		id++
	}

	return PLUGIN_CONTINUE
}

public message_statustext(msgid, msg_destination, id)
{
	set_msg_arg_int(1, get_msg_argtype(1), 1)
	set_msg_arg_int(2, get_msg_argtype(2), 0)
}

public message_saytext()
{
	if (get_msg_args() == 4)
	{
		static sender; sender = get_msg_arg_int(1)

		if (0 < sender < g_maxplayers + 1 && g_tag[sender][0])
		{
			static cReplacement[189]
			static cPhrase[47]
			get_msg_arg_string(2, cPhrase, 46)

			if (equal(cPhrase, "#Cstrike_Chat_CT", 0))
			{
				formatex(cReplacement, 188, "^1(Counter-Terrorist) ^4%s ^3%s^1 :  %s", g_tag[sender], "%s1", "%s2")
				set_msg_arg_string(2, cReplacement)
			}
			if (equal(cPhrase, "#Cstrike_Chat_T", 0))
			{
				formatex(cReplacement, 188, "^1(Terrorist) ^4%s ^3%s^1 :  %s", g_tag[sender], "%s1", "%s2")
				set_msg_arg_string(2, cReplacement)
			}
			if (equal(cPhrase, "#Cstrike_Chat_CT_Dead", 0))
			{
				formatex(cReplacement, 188, "^1*DEAD*(Counter-Terrorist) ^4%s ^3%s^1 :  %s", g_tag[sender], "%s1", "%s2")
				set_msg_arg_string(2, cReplacement)
			}
			if (equal(cPhrase, "#Cstrike_Chat_T_Dead", 0))
			{
				formatex(cReplacement, 188, "^1*DEAD*(Terrorist) ^4%s ^3%s^1 :  %s", g_tag[sender], "%s1", "%s2")
				set_msg_arg_string(2, cReplacement)
			}
			if (equal(cPhrase, "#Cstrike_Chat_Spec", 0))
			{
				formatex(cReplacement, 188, "^1(Spectator) ^4%s ^3%s^1 :  %s", g_tag[sender], "%s1", "%s2")
				set_msg_arg_string(2, cReplacement)
			}
			if (equal(cPhrase, "#Cstrike_Chat_All", 0))
			{
				formatex(cReplacement, 188, "^4%s ^3%s^1 :  %s", g_tag[sender], "%s1", "%s2")
				set_msg_arg_string(2, cReplacement)
			}
			if (equal(cPhrase, "#Cstrike_Chat_AllDead", 0))
			{
				formatex(cReplacement, 188, "^1*DEAD* ^4%s ^3%s^1 :  %s", g_tag[sender], "%s1", "%s2")
				set_msg_arg_string(2, cReplacement)
			}
			if (equal(cPhrase, "#Cstrike_Chat_AllSpec", 0))
			{
				formatex(cReplacement, 188, "^1*SPEC* ^4%s ^3%s^1 :  %s", g_tag[sender], "%s1", "%s2")
				set_msg_arg_string(2, cReplacement)
			}
		}
	}
	return PLUGIN_CONTINUE
}

public _GameMenu(id, menu, item)
{
	if (item != -3 && g_isconnected[id])
	{
		static iChoice
		static cBuffer[3]
		menu_item_getinfo(menu, item, _, cBuffer, charsmax(cBuffer), _, _, _)
		iChoice = str_to_num(cBuffer)

		switch (iChoice)
		{
		case 0:
			{
				if (g_isalive[id]) ShowMenuExtraItems(id)
				else client_print_color(id, print_team_grey, "%s Extra items are unavailable right now.", CHAT_PREFIX)
			}
		case 1: menu_display(id, g_iZombieClassMenu, 0)
		case 2:
			{
				if (g_isalive[id])
					menu_display(id, g_iPointShopMenu, 0)
				else client_print_color(id, print_team_grey, "%s Points shop is unavailbale right now.", CHAT_PREFIX)
			}
		case 3:
			{
				if (g_isalive[id] && !is_hull_vacant(id))
				{
					static i; i = 0
					static Float:fOrigin[3]
					static Float:fVector[3]
					static Float:fMins[3]
					pev(id, pev_mins, fMins)
					pev(id, pev_origin, fOrigin)
					
					while (i < 70)
					{
						fVector[0] = floatsub(fOrigin[0], floatmul(fMins[0], g_fSizes[i][0]))
						fVector[1] = floatsub(fOrigin[1], floatmul(fMins[1], g_fSizes[i][1]))
						fVector[2] = floatsub(fOrigin[2], floatmul(fMins[2], g_fSizes[i][2]))

						if (is_origin_vacant(fVector, id))
						{
							engfunc(EngFunc_SetOrigin, id, fVector)
							set_pev(id, pev_velocity, {0.0,0.0,0.0})
							i = 70
							client_cmd(id, "spk fvox/blip.wav")
							UTIL_ScreenFade(id, {200, 200, 0}, 1.0, 0.5, 100, FFADE_IN, true, false)			
						}
						i++
					}
					client_print_color(id, print_team_grey, "%s You have been unstucked!", CHAT_PREFIX)
				}
				else client_print_color(id, print_team_grey, "%s You are not stuck!", CHAT_PREFIX)
			}
		case 4: menu_display(id, g_iStatisticsMenu, 0)
		}
	}
	return  PLUGIN_CONTINUE
}

ShowMenuExtraItems(id)
{
	// Check if there are no items
	if (!g_extraitemsCount)
	{
		client_print_color(id, print_team_grey, "%s There are no ^3items ^1available right now", CHAT_PREFIX)
		return PLUGIN_HANDLED
    }

	static g_menu, line[128], number[3], ItemData[extraItemsDataStructure]

	g_menu = menu_create(fmt("%s's Extra Items", g_classString[id]), "_ExtraItems", 0)	// Human Extra items menu

	for (new i = 0; i < g_extraitemsCount; i++)
	{
		// Get item data from array
		ArrayGetArray(g_extraitems, i, ItemData)

		if ((CheckBit(g_playerClass[id], CLASS_HUMAN) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_HUMAN)))
		|| (CheckBit(g_playerClass[id], CLASS_TRYDER) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_TRYDER)))
		|| (CheckBit(g_playerClass[id], CLASS_SURVIVOR) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_SURVIVOR)))
		|| (CheckBit(g_playerClass[id], CLASS_SNIPER) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_SNIPER)))
		|| (CheckBit(g_playerClass[id], CLASS_SAMURAI) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_SAMURAI)))
		|| (CheckBit(g_playerClass[id], CLASS_GRENADIER) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_GRENADIER)))
		|| (CheckBit(g_playerClass[id], CLASS_TERMINATOR) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_TERMINATOR)))
		|| (CheckBit(g_playerClass[id], CLASS_ZOMBIE) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_ZOMBIE))) 
		|| (CheckBit(g_playerClass[id], CLASS_ASSASIN) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_ASSASIN))) 
		|| (CheckBit(g_playerClass[id], CLASS_NEMESIS) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_NEMESIS)))
		|| (CheckBit(g_playerClass[id], CLASS_BOMBARDIER) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_BOMBARDIER)))
		|| (CheckBit(g_playerClass[id], CLASS_REVENANT) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_REVENANT)))) continue
		
		formatex(line, charsmax(line), "%s \r[%i packs]", ItemData[ItemName], ItemData[ItemCost])
		num_to_str(i, number, 3)
		menu_additem(g_menu, line, number, 0, -1)
	}
	
	menu_display(id, g_menu, 0)

	return PLUGIN_CONTINUE
}

public _ExtraItems(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new data[3]
	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)

	// Get item index from menu
	new ItemIndex = str_to_num(data)

	// Get item data from array
	new ItemData[extraItemsDataStructure]
	ArrayGetArray(g_extraitems, ItemIndex, ItemData)

	// Check if player's points is less then the item's cost // If not then set the item
	if (g_ammopacks[id] < ItemData[ItemCost])
	{
		// Notify player
		client_print_color(id, print_team_grey, "%s You dont have enough ^3packs ^1to buy this item...", CHAT_PREFIX)
		return PLUGIN_HANDLED
	}
	else if ((CheckBit(g_playerClass[id], CLASS_HUMAN) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_HUMAN)))
	|| (CheckBit(g_playerClass[id], CLASS_TRYDER) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_TRYDER)))
	|| (CheckBit(g_playerClass[id], CLASS_SURVIVOR) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_SURVIVOR)))
	|| (CheckBit(g_playerClass[id], CLASS_SNIPER) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_SNIPER)))
	|| (CheckBit(g_playerClass[id], CLASS_SAMURAI) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_SAMURAI)))
	|| (CheckBit(g_playerClass[id], CLASS_GRENADIER) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_GRENADIER)))
	|| (CheckBit(g_playerClass[id], CLASS_TERMINATOR) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_TERMINATOR)))
	|| (CheckBit(g_playerClass[id], CLASS_ZOMBIE) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_ZOMBIE))) 
	|| (CheckBit(g_playerClass[id], CLASS_ASSASIN) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_ASSASIN))) 
	|| (CheckBit(g_playerClass[id], CLASS_NEMESIS) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_NEMESIS)))
	|| (CheckBit(g_playerClass[id], CLASS_BOMBARDIER) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_BOMBARDIER)))
	|| (CheckBit(g_playerClass[id], CLASS_REVENANT) && !(CheckFlag(ItemData[ItemTeam], ZQ_EXTRA_REVENANT))))
	{
		// Notify player
		client_print_color(id, print_team_grey, "%s This ^3item ^1is not for your ^4team^1...", CHAT_PREFIX)
		return PLUGIN_HANDLED
	}
	else
	{
		// Reduce his packs
		g_ammopacks[id] -= ItemData[ItemCost]

		switch (ItemIndex)
		{
		case EXTRA_NIGHTVISION:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_NIGHTVISION, id))
				{
					g_nvision[id] = true
					
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(id, g_MsgSync6, "You bought Nightvision Googles!", g_playerName[id])

					// Check is the user is not bot
					if (!g_isbot[id])
					{
						g_nvisionenabled[id] = true
						
						// Custom nvg?
						if (CustomNightVision)
						{
							remove_task(id + TASK_NVISION)
							set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
						}
						else set_user_gnvision(id, 1)
					}
					else cs_set_user_nvg(id, 1)
				}
			}
		case EXTRA_FORCEFIELD_NADE:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_FORCEFIELD_NADE, id))
				{
					// Already own one
					if (user_has_weapon(id, CSW_SMOKEGRENADE))
					{
						client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
					
					// Set the boolean to true
					g_bubblebomb[id] = 100

					// Give weapon to the player
					set_weapon(id, CSW_SMOKEGRENADE, 1)	

					// Show HUD message
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(id, g_MsgSync6, "You bought Force Field Grenade!")

					// Play clip purchase sound
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		case EXTRA_KILL_NADE:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_KILL_NADE, id))
				{
					// Already own one
					if (user_has_weapon(id, CSW_HEGRENADE))
					{
						client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					LIMIT[id][KILL_NADE]++

					// Set the boolean to true
					g_killingbomb[id]++

					// Give weapon to the player
					set_weapon(id, CSW_HEGRENADE, 1)

					// Show HUD message
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(id, g_MsgSync6, "You bought Killing Grenade!")

					// Play clip purchase sound
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		case EXTRA_EXPLOSION_NADE:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_EXPLOSION_NADE, id))
				{
					// Already own one
					if (user_has_weapon(id, CSW_HEGRENADE))
					{
						client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
						
					// Give weapon to the player
					set_weapon(id, CSW_HEGRENADE, 1)	

					// Show hud message
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(id, g_MsgSync6, "You bought Explosion Grenade!")
					
					// Play clip purchase sound
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		case EXTRA_NAPALM_NADE:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_NAPALM_NADE, id))
				{
					// Already own one
					if (user_has_weapon(id, CSW_FLASHBANG))
					{
						client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
						return PLUGIN_HANDLED	
					}
						
					// Give weapon to the player
					set_weapon(id, CSW_FLASHBANG, 1)

					// Show HUD message
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(id, g_MsgSync6, "You bought Napalm Grenade!")	

					// Play clip purchase sound
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		case EXTRA_FROST_NADE:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_FROST_NADE, id))
				{
					// Already own one
					if (user_has_weapon(id, CSW_SMOKEGRENADE))
					{
						client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
						
					// Give weapon to the player
					set_weapon(id, CSW_SMOKEGRENADE, 1)	

					// Show HUD Message
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(id, g_MsgSync6, "You bought Frost Grenade!")

					// Play clip purchase sound
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		case EXTRA_ANTIDOTE_NADE:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_ANTIDOTE_NADE, id))
				{
					// Already own one
					if (user_has_weapon(id, CSW_HEGRENADE))
					{
						client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
						
					LIMIT[id][ANTIDOTE_NADE]++

					// Set the boolean to true
					g_antidotebomb[id]++

					// Give weapon to the player
					set_weapon(id, CSW_HEGRENADE, 1)

					// Show HUD message
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(id, g_MsgSync6, "You bought Antidote Grenade!")
				}
			}
		case EXTRA_MULTIJUMP:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_MULTIJUMP, id))
				{
					g_multijump[id] = true
					g_jumpnum[id]++
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(id, g_MsgSync6, "You can now jump %d times!", g_jumpnum[id] + 1)
				}
			}
		case EXTRA_JETPACK:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_JETPACK, id))
				{
					if (get_user_jetpack(id)) 
					user_drop_jetpack(id, 1)

					set_user_jetpack(id, 1)
					set_user_fuel(id, 250.0)
					set_user_rocket_time(id, 0.0)
					client_print_color(id, print_team_grey, "%s Press^3 CTR+SPACE^1 to fly!", CHAT_PREFIX)
					client_print_color(id, print_team_grey, "%s Press^3 RIGHT CLICK^1 to shoot!", CHAT_PREFIX)
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(0, g_MsgSync6, "%s bought a Jetpack!", g_playerName[id])

					emit_sound(id, CHAN_STATIC, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		case EXTRA_TRYDER:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_TRYDER, id))
				{
					LIMIT[id][TRYDER]++

					MakeHuman(id, CLASS_TRYDER)		// Make him tryder
					set_hudmessage(190, 55, 115, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(0, g_MsgSync6, "%s is now a Tryder!", g_playerName[id])
					client_cmd(id, "spk PerfectZM/armor_equip")
				}
			}
		case EXTRA_ARMOR_100:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_ARMOR_100, id))
				{
					if (pev(id, pev_armorvalue) > 120)
					{
						client_print_color(id, print_team_grey, "%s You already have one!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					set_pev(id, pev_armorvalue, pev(id, pev_armorvalue) + 100.0)
					client_cmd(id, "spk PerfectZm/armor_equip")
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(id, g_MsgSync6, "You've been equiped with armor (100ap)")
				}
			}
		case EXTRA_ARMOR_200:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_ARMOR_200, id))
				{
					if (pev(id, pev_armorvalue) > 120)
					{
						client_print_color(id, print_team_grey, "%s You already have one!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					set_pev(id, pev_armorvalue, pev(id, pev_armorvalue) + 200.0)
					client_cmd(id, "spk PerfectZM/armor_equip")
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(id, g_MsgSync6, "You've been equiped with armor (200ap)")
				}
			}
		case EXTRA_CROSSBOW:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_CROSSBOW, id))
				{
					if (user_has_weapon(id, CSW_SG550)) drop_prim(id)

					g_has_crossbow[id] = true
					new iWep2 = give_item(id,"weapon_sg550")
					client_cmd(id, "spk ^"fvox/get_crossbow acquired^"")
					cs_set_weapon_ammo(iWep2, CROSSBOW_CLIP)
					cs_set_user_bpammo (id, CSW_SG550, 10000)
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(0, g_MsgSync6, "%s bought a Crossbow!", g_playerName[id])
				}
			}
		case EXTRA_GOLDEN_WEAPONS:
		{
			if (CanBuy(EXTRA_HUMANS, EXTRA_GOLDEN_WEAPONS, id))
			{
				g_goldenweapons[id] = true

				if (!user_has_weapon(id, CSW_AK47)) set_weapon(id, CSW_AK47, 10000)
				if (!user_has_weapon(id, CSW_M4A1)) set_weapon(id, CSW_M4A1, 10000)
				if (!user_has_weapon(id, CSW_XM1014)) set_weapon(id, CSW_XM1014, 10000)
				if (!user_has_weapon(id, CSW_DEAGLE)) set_weapon(id, CSW_DEAGLE, 10000)

				switch (random_num(0, 2))
				{		
					case 0: { client_cmd(id, "weapon_ak47"); set_goldenak47(id); }
					case 1: { client_cmd(id, "weapon_m4a1"); set_goldenm4a1(id); }
					case 2: { client_cmd(id, "weapon_xm1014"); set_goldenxm1014(id); }
				}
				
				set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
				ShowSyncHudMsg(0, g_MsgSync6, "%s now has Golden Weapons", g_playerName[id])
			}
		}
		case EXTRA_CLASS_NEMESIS:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_CLASS_NEMESIS, id))
				{
					LIMIT[id][MODES]++

					remove_task(TASK_COUNTDOWN)
					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_NEMESIS, id)
					set_hudmessage(255, 0, 0, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(0, g_MsgSync6, "%s brought Nemesis", g_playerName[id])
				}
			}
		case EXTRA_CLASS_ASSASIN:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_CLASS_ASSASIN, id))
				{
					LIMIT[id][MODES]++

					remove_task(TASK_COUNTDOWN)
					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_ASSASIN, id)
					set_hudmessage(255, 0, 0, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(0, g_MsgSync6, "%s brought Assassin", g_playerName[id])
				}
			}
		case EXTRA_CLASS_SNIPER:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_CLASS_SNIPER, id))
				{
					LIMIT[id][MODES]++

					remove_task(TASK_COUNTDOWN)
					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_SNIPER, id)
					set_hudmessage(255, 0, 0, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(0, g_MsgSync6, "%s brought Sniper", g_playerName[id])
				}
			}
		case EXTRA_CLASS_SURVIVOR:
			{
				if (CanBuy(EXTRA_HUMANS, EXTRA_CLASS_SURVIVOR, id))
				{
					LIMIT[id][MODES]++

					remove_task(TASK_COUNTDOWN)
					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_SURVIVOR, id)
					set_hudmessage(255, 0, 0, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(0, g_MsgSync6, "%s brought Survivor", g_playerName[id])
				}
			}
		case EXTRA_ANTIDOTE:
			{
				if (CanBuy(EXTRA_ZOMBIES, EXTRA_ANTIDOTE, id))
				{
					// Make him human
					MakeHuman(id)

					// Antidote sound
					static iRand, buffer[100]
					iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_ANTIDOTE]) - 1)
					ArrayGetString(Array:g_miscSounds[SOUND_ANTIDOTE], iRand, buffer, charsmax(buffer))
					emit_sound(id, CHAN_ITEM, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)

					// Make teleport effect
					SendTeleport(id)
					
					// Show Antidote HUD notice
					set_hudmessage(9, 201, 214, HUD_INFECT_X, HUD_INFECT_Y, 1, 0.0, 3.0, 2.0, 1.0, -1)
					ShowSyncHudMsg(0, g_MsgSync, "%s has used an antidote!", g_playerName[id])

					client_print_color(id, print_team_grey, "%s You are human now", CHAT_PREFIX)
				}
			}
		case EXTRA_MADNESS:
			{
				if (CanBuy(EXTRA_ZOMBIES, EXTRA_MADNESS, id))
				{
					// Show the player HUD message
					set_hudmessage(255, 0, 0, -1.0, 0.70, 1, 0.0, 3.0, 2.0, 1.0, -1)
					ShowSyncHudMsg(id, g_MsgSync6, "You bought Zombie Madness!")

					// Set the bool to true
					g_nodamage[id] = true

					// Set glow on player
					set_glow(id, 255, 0, 0, 255)

					//set_task(0.1, "zombie_aura", id+TASK_AURA, _, _, "b")
					set_task(float(MadnessDuration), "madness_over", id+TASK_BLOOD)
					
					// Play madness sound
					new iRand, buffer[100]
					iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_MADNESS]) - 1)
					ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_MADNESS], iRand, buffer, charsmax(buffer))
					emit_sound(id, CHAN_VOICE, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		case EXTRA_INFECTION_NADE:
			{
				if (CanBuy(EXTRA_ZOMBIES, EXTRA_INFECTION_NADE, id))
				{
					// Already own one
					if (user_has_weapon(id, CSW_HEGRENADE))
					{
						client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					// Show HUD message
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(id, g_MsgSync6, "You bought Infection Bomb!")

					// Play clip purchase sound
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)

					// Give weapon to the player
					set_weapon(id, CSW_HEGRENADE, 1)	
				}
			}
		case EXTRA_CONCUSSION_NADE:
			{
				if (CanBuy(EXTRA_ZOMBIES, EXTRA_CONCUSSION_NADE, id))
				{
					// Already own one
					if (user_has_weapon(id, CSW_FLASHBANG))
					{
						client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
						
					// Set the boolean to true
					g_concussionbomb[id]++

					// Give weapon to the player
					set_weapon(id, CSW_FLASHBANG, 1)	

					// Show HUD message
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(id, g_MsgSync6, "You bought Concussion Bomb!")

					// Play clip purchase sound
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		case EXTRA_KNIFE_BLINK:
			{
				if (CanBuy(EXTRA_ZOMBIES, EXTRA_KNIFE_BLINK, id))
				{
					g_blinks[id] += 5

					// Show HUD message
					set_hudmessage(115, 230, 1, -1.0, 0.80, 1, 0.0, 0.0, 3.0, 2.0, -1)
					ShowSyncHudMsg(0, g_MsgSync6, "%s bought knife blinks!", g_playerName[id])
				}
			}
		default:
			{
				// Notify plugins that the player bought this item
				ExecuteForward(g_forwards[EXTRA_ITEM_SELECTED], g_forwardRetVal, id, ItemIndex)
			}
		}
	}

	return PLUGIN_CONTINUE
}

public _ZombieClasses(id, menu, item)
{
	if (item != -3 && g_isconnected[id])
	{
		static iChoice
		static cBuffer[15]

		menu_item_getinfo(menu, item, _, cBuffer, charsmax(cBuffer), _, _, _)
		iChoice = str_to_num(cBuffer)
		g_zombieclassnext[id] = iChoice
		client_print_color(id, print_team_grey, "%s You will be^4 %s^1 after the next infection!", CHAT_PREFIX, g_cZombieClasses[iChoice][ZombieName])
		client_print_color(id, print_team_grey, "%s Health:^4 %s^1 | Speed:^4 %0.0f^1 | Gravity:^4 %0.0f^1 | Knockback:^4 %0.0f%", CHAT_PREFIX, AddCommas(g_cZombieClasses[iChoice][Health]), g_cZombieClasses[iChoice][Speed], floatmul(100.0, g_cZombieClasses[iChoice][Gravity]), floatmul(100.0, g_cZombieClasses[iChoice][Knockback]))
	}
	
	return PLUGIN_CONTINUE
}

public _StatisticsMenu(id, menu, item)
{
	if (item != -3 && g_isconnected[id])
	{
		static iChoice
		static cBuffer[15]

		menu_item_getinfo(menu, item, _, cBuffer, charsmax(cBuffer), _, _, _)
		iChoice = str_to_num(cBuffer)

		switch (iChoice)
		{
			case 0: ShowPlayerStatistics(id)
			case 1: ShowGlobalTop15(id)
			case 2:  { /* Comming soon */ }
		}
	}
}

public _PointShop(id, menu, item)
{
	if (item != -3)
	{
		static iChoice
		static cBuffer[15]
		menu_item_getinfo(menu, item, _, cBuffer, charsmax(cBuffer), _, _, _)
		iChoice = str_to_num(cBuffer)

		switch (iChoice)
		{
			case 0: menu_display(id, g_iAmmoMenu, 0)
			case 1: menu_display(id, g_iFeaturesMenu, 0)
			case 2: menu_display(id, g_iModesMenu, 0)
			case 3: ShowPointsShopWeaponsMenu(id)
		}
	}
	return PLUGIN_CONTINUE
}

public _AmmoMenu(id, menu, item)
{
	if (item != -3)
	{
		static iChoice
		static cBuffer[15]
		menu_item_getinfo(menu, item, _, cBuffer, charsmax(cBuffer), _, _, _)
		iChoice = str_to_num(cBuffer)

		switch (iChoice)
		{
		case PSHOP_PACKS_100:
			{
				if (CanBuy(PSHOP_PACKS, PSHOP_PACKS_100, id))
				{
					if (g_points[id] < g_cAmmoMenu[iChoice][_ammoItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					LIMIT[id][PACKS]++
					g_ammopacks[id] += 100
					g_points[id] -= g_cAmmoMenu[iChoice][_ammoItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(0, g_MsgSync6, "%s bought 100 ammo packs!", g_playerName[id])
					client_print_color(0, print_team_grey, "%s ^3%s^1 bought^4 100 ammo packs", CHAT_PREFIX, g_playerName[id])
					MySQL_UPDATE_DATABASE(id)
				}
			}
		case PSHOP_PACKS_200:
			{
				if (CanBuy(PSHOP_PACKS, PSHOP_PACKS_200, id))
				{
					if (g_points[id] < g_cAmmoMenu[iChoice][_ammoItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					LIMIT[id][PACKS]++
					g_ammopacks[id] += 200
					g_points[id] -= g_cAmmoMenu[iChoice][_ammoItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(0, g_MsgSync6, "%s bought 200 ammo packs!", g_playerName[id])
					client_print_color(0, print_team_grey, "%s ^3%s^1 bought^4 200 ammo packs", CHAT_PREFIX, g_playerName[id])
					MySQL_UPDATE_DATABASE(id)
				}
			}
		case PSHOP_PACKS_300:
			{
				if (CanBuy(PSHOP_PACKS, PSHOP_PACKS_300, id))
				{
					if (g_points[id] < g_cAmmoMenu[iChoice][_ammoItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					LIMIT[id][PACKS]++
					g_ammopacks[id] += 300
					g_points[id] -= g_cAmmoMenu[iChoice][_ammoItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(0, g_MsgSync6, "%s bought 300 ammo packs!", g_playerName[id])
					client_print_color(0, print_team_grey, "%s ^3%s^1 bought^4 300 ammo packs", CHAT_PREFIX, g_playerName[id])
					MySQL_UPDATE_DATABASE(id)
				}
			}
		case PSHOP_PACKS_400:
			{
				if (CanBuy(PSHOP_PACKS, PSHOP_PACKS_400, id))
				{
					if (g_points[id] < g_cAmmoMenu[iChoice][_ammoItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					LIMIT[id][PACKS]++
					g_ammopacks[id] += 400
					g_points[id] -= g_cAmmoMenu[iChoice][_ammoItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(0, g_MsgSync6, "%s bought 400 ammo packs!", g_playerName[id])
					client_print_color(0, print_team_grey, "%s ^3%s^1 bought^4 400 ammo packs", CHAT_PREFIX, g_playerName[id])
					MySQL_UPDATE_DATABASE(id)
				}
			}
		case PSHOP_PACKS_500:
			{
				if (CanBuy(PSHOP_PACKS, PSHOP_PACKS_500, id))
				{
					if (g_points[id] < g_cAmmoMenu[iChoice][_ammoItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					LIMIT[id][PACKS]++
					g_ammopacks[id] += 500
					g_points[id] -= g_cAmmoMenu[iChoice][_ammoItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					ShowSyncHudMsg(0, g_MsgSync6, "%s bought 500 ammo packs!", g_playerName[id])
					client_print_color(0, print_team_grey, "%s ^3%s^1 bought^4 500 ammo packs", CHAT_PREFIX, g_playerName[id])
					MySQL_UPDATE_DATABASE(id)
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public _Features(id, menu, item)
{
	if (item != -3)
	{
		static iChoice
		static cBuffer[15]
		menu_item_getinfo(menu, item, _, cBuffer, charsmax(cBuffer), _, _, _)
		iChoice = str_to_num(cBuffer)

		switch (iChoice)
		{
		case PSHOP_FEATURE_GOD_MODE:
			{
				if (CanBuy(PSHOP_FEATURES, PSHOP_FEATURE_GOD_MODE, id))
				{
					if (g_points[id] < g_cFeaturesMenu[iChoice][_fItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					// Set the boolean to true
					g_nodamage[id] = true
					g_points[id] -= g_cFeaturesMenu[iChoice][_fItemPrice]
					set_glow(id, 192, 255, 62, 25)
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					show_hudmessage( id, "You bought God Mode!")
					MySQL_UPDATE_DATABASE(id)
				}
			}
		case PSHOP_FEATURE_DOUBLE_DAMAGE:
			{
				if (CanBuy(PSHOP_FEATURES, PSHOP_FEATURE_DOUBLE_DAMAGE, id))
				{
					if (g_points[id] < g_cFeaturesMenu[iChoice][_fItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					// Set the boolean to true
					g_doubledamage[id] = true
					g_points[id] -= g_cFeaturesMenu[iChoice][_fItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					show_hudmessage( id, "You bought Double damage!")
					MySQL_UPDATE_DATABASE(id)
				}
			}
		case PSHOP_FEATURE_NO_RECOIL:
			{
				if (CanBuy(PSHOP_FEATURES, PSHOP_FEATURE_NO_RECOIL, id))
				{
					if (g_points[id] < g_cFeaturesMenu[iChoice][_fItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					// Set the boolean to true
					g_norecoil[id] = true
					g_points[id] -= g_cFeaturesMenu[iChoice][_fItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					show_hudmessage( id, "You bought No Recoil!")
					MySQL_UPDATE_DATABASE(id)
				}
			}
		case PSHOP_FEATURE_INVISIBILITY:
			{
				if (CanBuy(PSHOP_FEATURES, PSHOP_FEATURE_INVISIBILITY, id))
				{
					if (g_points[id] < g_cFeaturesMenu[iChoice][_fItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					g_points[id] -= g_cFeaturesMenu[iChoice][_fItemPrice]
					set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					show_hudmessage( id, "You bought Invisibility!")
					MySQL_UPDATE_DATABASE(id)
				}
			}
		case PSHOP_FEATURE_SPRINT:
			{
				if (CanBuy(PSHOP_FEATURES, PSHOP_FEATURE_SPRINT, id))
				{
					if (g_points[id] < g_cFeaturesMenu[iChoice][_fItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					// Set boolean to true
					g_speed[id] = true
					ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
					g_points[id] -= g_cFeaturesMenu[iChoice][_fItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					show_hudmessage( id, "You bought High Speed!")
					MySQL_UPDATE_DATABASE(id)
				}
			}
		case PSHOP_FEATURE_LOW_GRAVITY:
			{
				if (CanBuy(PSHOP_FEATURES, PSHOP_FEATURE_LOW_GRAVITY, id))
				{
					if (g_points[id] < g_cFeaturesMenu[iChoice][_fItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					set_pev(id, pev_gravity, 0.5)
					g_points[id] -= g_cFeaturesMenu[iChoice][_fItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					show_hudmessage( id, "Now you have less gravity!")
					MySQL_UPDATE_DATABASE(id)
				}
			}
		case PSHOP_FEATURE_HEAD_HUNTER:
			{
				if (CanBuy(PSHOP_FEATURES, PSHOP_FEATURE_HEAD_HUNTER, id))
				{
					if (g_points[id] < g_cFeaturesMenu[iChoice][_fItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					// Set boolean to true
					g_allheadshots[id] = true

					g_points[id] -= g_cFeaturesMenu[iChoice][_fItemPrice]
					set_hudmessage( 115, 230, 1, -1.0, 0.80, 1, 0.0, 5.0, 1.0, 1.0, -1 )
					show_hudmessage( id, "Now all your bullet will connect to head!")
					MySQL_UPDATE_DATABASE(id)
				}
			}
		}
	}

	return PLUGIN_CONTINUE
}

public _Modes(id, menu, item)
{
	if (item != -3)
	{
		static iChoice
		static cBuffer[15]
		menu_item_getinfo(menu, item, _, cBuffer, charsmax(cBuffer), _, _, _)
		iChoice = str_to_num(cBuffer)

		switch (iChoice)
		{
		case PSHOP_MODE_SAMURAI:
		{
			if (CanBuy(PSHOP_MODES, PSHOP_MODE_SAMURAI, id))
			{
				if (g_points[id] < g_cModesMenu[iChoice][_mItemPrice])
				{
					client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
					return PLUGIN_HANDLED
				}

				remove_task(TASK_MAKEZOMBIE)
				start_mode(MODE_SAMURAI, id)

				LIMIT[id][CUSTOM_MODES]++

				g_points[id] -= g_cModesMenu[iChoice][_mItemPrice]
				set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
				show_hudmessage(0, "%s bought Samurai with points!", g_playerName[id])
				MySQL_UPDATE_DATABASE(id)
			}
		}
		case PSHOP_MODE_GRENADIER:
		{
			if (CanBuy(PSHOP_MODES, PSHOP_MODE_GRENADIER, id))
			{
				if (g_points[id] < g_cModesMenu[iChoice][_mItemPrice])
				{
					client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
					return PLUGIN_HANDLED
				}

				remove_task(TASK_MAKEZOMBIE)
				start_mode(MODE_GRENADIER, id)

				LIMIT[id][CUSTOM_MODES]++

				g_points[id] -= g_cModesMenu[iChoice][_mItemPrice]
				set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
				show_hudmessage(0, "%s bought Grenadier with points!", g_playerName[id])
				MySQL_UPDATE_DATABASE(id)
			}
		}
		case PSHOP_MODE_TERMINATOR:
		{
			if (CanBuy(PSHOP_MODES, PSHOP_MODE_TERMINATOR, id))
			{
				if (g_points[id] < g_cModesMenu[iChoice][_mItemPrice])
				{
					client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
					return PLUGIN_HANDLED
				}

				remove_task(TASK_MAKEZOMBIE)
				start_mode(MODE_TERMINATOR, id)

				LIMIT[id][CUSTOM_MODES]++

				g_points[id] -= g_cModesMenu[iChoice][_mItemPrice]
				set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
				show_hudmessage(0, "%s bought Terminator with points!", g_playerName[id])
				MySQL_UPDATE_DATABASE(id)
			}
		}
		case PSHOP_MODE_BOMBARDIER:
		{
			if (CanBuy(PSHOP_MODES, PSHOP_MODE_BOMBARDIER, id))
			{
				if (g_points[id] < g_cModesMenu[iChoice][_mItemPrice])
				{
					client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
					return PLUGIN_HANDLED
				}

				remove_task(TASK_MAKEZOMBIE)
				start_mode(MODE_BOMBARDIER, id)

				LIMIT[id][CUSTOM_MODES]++

				g_points[id] -= g_cModesMenu[iChoice][_mItemPrice]
				set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
				show_hudmessage(0, "%s bought Bombardier with points!", g_playerName[id])
				MySQL_UPDATE_DATABASE(id)
			}
		}
		case PSHOP_MODE_REVENANT:
		{
			if (CanBuy(PSHOP_MODES, PSHOP_MODE_REVENANT, id))
			{
				if (g_points[id] < g_cModesMenu[iChoice][_mItemPrice])
				{
					client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
					return PLUGIN_HANDLED
				}

				remove_task(TASK_MAKEZOMBIE)
				start_mode(MODE_REVENANT, id)

				LIMIT[id][CUSTOM_MODES]++

				g_points[id] -= g_cModesMenu[iChoice][_mItemPrice]
				set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
				show_hudmessage(0, "%s bought Revenant with points!", g_playerName[id])
				MySQL_UPDATE_DATABASE(id)
			}
		}
		case PSHOP_MODE_SURVIVOR_VS_NEMESIS:
			{
				if (CanBuy(PSHOP_MODES, PSHOP_MODE_SURVIVOR_VS_NEMESIS, id))
				{
					if (g_points[id] < g_cModesMenu[iChoice][_mItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_SURVIVOR_VS_NEMESIS, 0)

					LIMIT[id][CUSTOM_MODES]++

					g_points[id] -= g_cModesMenu[iChoice][_mItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					show_hudmessage(0, "%s bought Armageddon mode with points!", g_playerName[id])
					MySQL_UPDATE_DATABASE(id)
				}
			}
		case PSHOP_MODE_SURVIVOR_VS_ASSASIN: 
		{ 
			if (CanBuy(PSHOP_MODES, PSHOP_MODE_SURVIVOR_VS_ASSASIN, id))
			{
				if (CanBuy(PSHOP_MODES, PSHOP_MODE_SURVIVOR_VS_ASSASIN, id))
				{
					if (g_points[id] < g_cModesMenu[iChoice][_mItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_SURVIVOR_VS_ASSASIN, 0)

					LIMIT[id][CUSTOM_MODES]++

					g_points[id] -= g_cModesMenu[iChoice][_mItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					show_hudmessage(0, "%s bought Survivor vs Assasin mode with points!", g_playerName[id])
					MySQL_UPDATE_DATABASE(id)
				}
			}
		}
		case PSHOP_MODE_SNIPER_VS_NEMESIS:
			{
				if (CanBuy(PSHOP_MODES, PSHOP_MODE_SNIPER_VS_NEMESIS, id))
				{
					if (g_points[id] < g_cModesMenu[iChoice][_mItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_SNIPER_VS_NEMESIS, 0)

					LIMIT[id][CUSTOM_MODES]++

					g_points[id] -= g_cModesMenu[iChoice][_mItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					show_hudmessage(0, "%s bought Sniper vs Nemesis mode with points!", g_playerName[id])
					MySQL_UPDATE_DATABASE(id)
				}
			}
		case PSHOP_MODE_SNIPER_VS_ASSASIN:
			{
				if (CanBuy(PSHOP_MODES, PSHOP_MODE_SNIPER_VS_ASSASIN, id))
				{
					if (g_points[id] < g_cModesMenu[iChoice][_mItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_SNIPER_VS_ASSASIN, 0)

					LIMIT[id][CUSTOM_MODES]++

					g_points[id] -= g_cModesMenu[iChoice][_mItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					show_hudmessage(0, "%s bought Sniper vs Assassin mode with points!", g_playerName[id])
					MySQL_UPDATE_DATABASE(id)
				}
			}
		case PSHOP_MODE_NIGHTMARE:
			{
				if (CanBuy(PSHOP_MODES, PSHOP_MODE_NIGHTMARE, id))
				{
					if (g_points[id] < g_cModesMenu[iChoice][_mItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_NIGHTMARE, 0)

					LIMIT[id][CUSTOM_MODES]++

					g_points[id] -= g_cModesMenu[iChoice][_mItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					show_hudmessage(0, "%s bought Nightmare mode with points!", g_playerName[id])
					MySQL_UPDATE_DATABASE(id)
				}
			}
		case PSHOP_MODE_SYNAPSIS: 
			{ 
				if (CanBuy(PSHOP_MODES, PSHOP_MODE_SYNAPSIS, id))
				{
					if (g_points[id] < g_cModesMenu[iChoice][_mItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_SYNAPSIS, 0)

					LIMIT[id][CUSTOM_MODES]++

					g_points[id] -= g_cModesMenu[iChoice][_mItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					show_hudmessage(0, "%s bought Synapsis mode with points!", g_playerName[id])
					MySQL_UPDATE_DATABASE(id)
				}
			} 
		case PSHOP_MODE_BOMBARDIER_VS_GRENADIER: 
			{ 
				if (CanBuy(PSHOP_MODES, PSHOP_MODE_BOMBARDIER_VS_GRENADIER, id))
				{
					if (g_points[id] < g_cModesMenu[iChoice][_mItemPrice])
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}

					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_BOMBARDIER_VS_GRENADIER, 0)

					LIMIT[id][CUSTOM_MODES]++

					g_points[id] -= g_cModesMenu[iChoice][_mItemPrice]
					set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
					show_hudmessage(0, "%s bought Bombardier vs Grenadier mode with points!", g_playerName[id])
					MySQL_UPDATE_DATABASE(id)
				}
			}
		case PSHOP_MODE_SAMURAI_VS_NEMESIS: 
			{ 
				if (CanBuy(PSHOP_MODES, PSHOP_MODE_BOMBARDIER_VS_GRENADIER, id))
				{

				}
			}
		case PSHOP_MODE_SONIC_VS_SHADOW: 
			{ 	
				if (CanBuy(PSHOP_MODES, PSHOP_MODE_SONIC_VS_SHADOW, id))
				{

				}
			}
		case PSHOP_MODE_NIGHTCRAWLER: 
			{ 
				if (CanBuy(PSHOP_MODES, PSHOP_MODE_NIGHTCRAWLER, id))
				{

				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public plugin_cfg()
{
	// Plugin disabled?
	if (!g_pluginenabled) return

	server_cmd("sv_maxspeed 9999")
	server_cmd("sv_voiceenable 0")
	server_cmd("sys_ticrate 1000")
	server_cmd("cl_forwardspeed 9999")
	server_cmd("cl_backspeed 9999")
	server_cmd("cl_sidespeed 9999")

	// Set lighting
	engfunc(EngFunc_LightStyle, 0, "d") // Set lighting
	
	// Cache CVARs after configs are loaded / call roundstart manually
	set_task(0.5, "cache_cvars")
	set_task(0.5, "event_round_start")
	set_task(0.5, "logevent_round_start")

	set_task(5.0, "OnRegeneratorSkill", _, _, _, "b")
}

public client_disconnected(id)
{
	if (g_bot[id]) { g_bot[id] = 0; g_iBotsCount --; }

	InsertInfo(id)

	if (g_punished[id]) g_punished[id] = false

	if (g_admin[id] || g_vip[id]) 
	{
		g_adminInfo[id][_aFlags] = EOS
		g_adminInfo[id][_aRank] = EOS
		g_admin[id] = false

		g_vip[id] = false
		g_jumpnum[id] = 1
		g_vipInfo[id][_vFlags] = EOS
	}

	g_tag[id][0] = EOS
	g_ammopacks[id] = 0

	// if there are results found
	g_kills[id]  		  = 0
	g_deaths[id] 		  = 0
	g_infections[id] 	  = 0
	g_nemesiskills[id] 	  = 0
	g_assasinkills[id] 	  = 0
	g_bombardierkills[id] = 0
	g_survivorkills[id]   = 0
	g_sniperkills[id] 	  = 0
	g_samuraikills[id] 	  = 0
	g_grenadierkills[id]  = 0
	g_terminatorkills[id] = 0
	g_revenantkills[id]	  = 0
	g_points[id] 		  = 0
	g_score[id] 		  = 0

	// Reset some vars
	g_antidotebomb[id] = 0
	g_concussionbomb[id] = 0
	g_bubblebomb[id] = 0
	g_killingbomb[id] = 0
	g_multijump[id] = false
	g_jumpnum[id] = 0
	g_playerClass[id] = 0
	g_blinks[id] = 0
}

public client_infochanged(id)
{
	new oldname[33], newname[33]

	get_user_name(id, oldname, charsmax(oldname))
	get_user_info(id, "name", newname, charsmax(newname))

	g_playerHash[id][0] = EOS

	copy(g_playerConcat[id], charsmax(g_playerConcat[]), newname) // Copy player's name to temporary concatenaed char array
	strcat(g_playerConcat[id], g_playerSteamID[id], charsmax(g_playerConcat[])) // Now concatenate ( add together ) player's name and steamid

	hash_string(g_playerConcat[id], Hash_Sha3_512, g_playerHash[id], charsmax(g_playerHash[])) // Now hash the concatenated player's name and steam id ( used for saving and loading database )

	if (!equali(oldname, newname, strlen(oldname)))
	{
		if (g_admin[id]) 
		{
			g_adminInfo[id][_aFlags] = EOS
			g_adminInfo[id][_aRank] = EOS
			g_admin[id] = false
		}
		if (g_vip[id]) 
		{
			g_vip[id] = false
			g_jumpnum[id] = 1
			g_vipInfo[id][_vFlags] = EOS
		}

		g_tag[id][0] = EOS
		g_ammopacks[id] = 5

		// if there are results found
		g_kills[id]  		  = 0
		g_deaths[id] 		  = 0
		g_infections[id] 	  = 0
		g_nemesiskills[id] 	  = 0
		g_assasinkills[id] 	  = 0
		g_bombardierkills[id] = 0
		g_survivorkills[id]   = 0
		g_sniperkills[id] 	  = 0
		g_samuraikills[id] 	  = 0
		g_grenadierkills[id]  = 0
		g_terminatorkills[id] = 0
		g_revenantkills[id]	  = 0
		g_points[id] 		  = 5
		g_score[id] 		  = 0

		MySQL_LOAD_DATABASE(id)

		if (TrieKeyExists(g_adminsTrie, newname)) MakeUserAdmin(id)
		if (TrieKeyExists(g_vipsTrie, newname)) MakeUserVip(id)
		if (TrieKeyExists(g_tagTrie, newname)) GiveUserTag(id)
	}
}

// Abhinash
public plugin_end()
{
	// Free SQl handle to prevent data leaks and crashes
	SQL_FreeHandle(g_SqlTuple)

	// Deestroy Trie
	TrieDestroy(g_tClassNames)

	set_cvar_string("amx_nextmap", "")

	if (g_vault != INVALID_HANDLE)
	{
		nvault_close(g_vault)
		g_vault = INVALID_HANDLE
	}
	
	new vault = nvault_open("ammo")
	if (vault != INVALID_HANDLE)
	{
		nvault_prune(vault, 0, get_systime())
		
		nvault_close(vault)
		vault=INVALID_HANDLE
	}
}

/*================================================================================
	[Main Events]
=================================================================================*/

// Event Round Start
public event_round_start()
{
	// MODE_NONE because MODE_NONE = 0 i.e. it resets all the bits
	g_currentmode = MODE_NONE

	// Increase round count var
	g_roundcount++

	// Map changer
	/*if (get_cvar_num("mp_timelimit") == 0)
	{
		new map[64]
		get_cvar_string("amx_nextmap", map, charsmax(map))
		MessageIntermission()
		set_task(5.0, "ChangeMap", 0, map, sizeof(map))
	}*/

	if (IsCurrentTimeBetween(happyHour_Start, happyHour_End))
	{
		static x; x = random_num(1, fnGetPlaying())
		static y; y = random_num(1, 60)
		g_ammopacks[x] += y
		client_print_color(0, print_team_grey, "^4[^3Happy Hour^4] ^1Player ^4%s ^1got ^3%i ^1ammo packs...", g_playerName[x], y)
	}

	// countdown
	if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

	countdown_timer = 10
	set_task(4.0, "Countdown", TASK_COUNTDOWN)

	// Remove Concussion task
	remove_task(TASK_CONCUSSION)
	
	// New round starting
	g_newround = true
	g_endround = false
	g_modestarted = false
	
	// Freezetime begins
	g_freezetime = true
	
	// Create Fog 
	//CreateFog(0, 128, 170, 128, 0.0008)
	
	// Show welcome message and T-Virus notice
	remove_task(TASK_WELCOMEMSG)
	set_task(2.0, "welcome_msg", TASK_WELCOMEMSG)
	
	// Set a new "Make Zombie Task"
	remove_task(TASK_MAKEZOMBIE)
	set_task(2.0 + ZpDelay, "make_zombie_task", TASK_MAKEZOMBIE)

	for (new id = 1; id < g_maxplayers; id++)
	{
		if (g_isconnected[id] && get_user_jetpack(id)) set_user_rocket_time(id, 0.0) 
		else if(g_isconnected[id] && VipHasFlag(id, 'a')) g_jumpnum[id] = 2 
		g_iKillsThisRound[id] = 0
	}
}

// Log Event Round Start
public logevent_round_start()
{
	// Freezetime ends
	g_freezetime = false
	
	// Create Fog 
	//CreateFog(0, 128, 170, 128, 0.0008)
}

// Log Event Round End
public logevent_round_end()
{
	// Round ended
	g_currentmode = MODE_NONE

	// Remove Bubble Grenade  (bugfix) ( credits: yokomo )
	new ent = find_ent_by_class(-1, BubbleEntityClassName)
	while (ent > 0)
    {
        if(is_valid_ent(ent))
        {
            remove_task(ent + TASK_REMOVE_FORECEFIELD)
            remove_entity(ent)
        }
        
        ent = find_ent_by_class(-1, BubbleEntityClassName)
    }

	// Reset lighting if last round was Assassin round
	if (g_lastmode == MODE_ASSASIN) engfunc(EngFunc_LightStyle, 0, "d") // Set lighting

	// Prevent this from getting called twice when restarting (bugfix)
	static Float:lastendtime, Float:current_time, iRand, buffer[65]
	current_time = get_gametime()

	if (current_time - lastendtime < 0.5) return
	lastendtime = current_time
	
	// Temporarily save player stats?
	if (SaveStats)
	{
		static id, team
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not connected
			if (!g_isconnected[id]) continue
			
			team = fm_cs_get_user_team(id)
			
			// Not playing
			if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED) continue
			
			SaveStatistics(id)
		}
	}

	// Extra Items
	static id
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_multijump[id])
		{
			g_jumpnum[id] = 0
			g_multijump[id] = false
		}
		if (g_norecoil[id]) g_norecoil[id] = false
		if (g_blinks[id]) g_blinks[id] = 0

		LIMIT[id][TRYDER] = 0

		if (g_allheadshots[id]) g_allheadshots[id] = false
	}
	
	// Round ended
	g_endround = true
	
	// Stop old tasks (if any)
	remove_task(TASK_WELCOMEMSG)
	remove_task(TASK_MAKEZOMBIE)

	// Remove Reminder Task
	if (task_exists(TASK_REMINDER)) remove_task(TASK_REMINDER)
	
	// Stop ambience sounds
	remove_task(TASK_AMBIENCESOUNDS)
	StopAmbienceSounds()

	// Show HUD notice, play win sound, update team scores...
	switch (g_lastmode)
	{
		case MODE_INFECTION, MODE_MULTI_INFECTION:
		{
			if (!fnGetZombies())
			{
				// Human team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Humans have defeated the plague!")
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_HUMAN_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_HUMAN_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorehumans++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_HUMAN)
			}
			else if (!fnGetHumans())
			{
				// Zombie team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Zombies have taken over the world!")
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_ZOMBIE_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_ZOMBIE_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)
				
				if (!g_gamecommencing) g_scorezombies++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_ZOMBIE)
			}
			else
			{
				// No one wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "No one won...")
				
				// Play win sound
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_WIN_NO_ONE]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_WIN_NO_ONE], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_NONE)
			}
		}
		case MODE_SWARM, MODE_PLAGUE, MODE_SYNAPSIS, MODE_BOMBARDIER_VS_GRENADIER:
		{
			if (!fnGetZombies())
			{
				// Human team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Thats how we go it soldiers^nI bet they will remember this defeat")
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_HUMAN_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_HUMAN_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorehumans++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_HUMAN)
			}
			else if (!fnGetHumans())
			{
				// Zombie team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "This is the begenning of the end...")
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_ZOMBIE_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_ZOMBIE_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorezombies++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_ZOMBIE)
			}
			else
			{
				// No one wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "The suffering has just began...")
				
				// Play win sound
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_WIN_NO_ONE]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_WIN_NO_ONE], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_NONE)
			}
		}
		case MODE_SURVIVOR_VS_NEMESIS, MODE_SNIPER_VS_NEMESIS, MODE_SNIPER_VS_ASSASIN, MODE_SURVIVOR_VS_ASSASIN:
		{
			if (!fnGetZombies())
			{
				// Human team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "This victory is very precious^nCheers to all the survivors")
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_HUMAN_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_HUMAN_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorehumans++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_HUMAN)
			}
			else if (!fnGetHumans())
			{
				// Zombie team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "We got defeated by the bad ones^nGet ready to be enslaved")
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_ZOMBIE_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_ZOMBIE_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorezombies++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_ZOMBIE)
			}
			else
			{
				// No one wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "The suffering has just began...")
				
				// Play win sound
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_WIN_NO_ONE]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_WIN_NO_ONE], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_NONE)
			}
		}
		case MODE_NIGHTMARE:
		{
			if (!fnGetZombies())
			{
				// Human team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "We rise from the ashes...")
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_HUMAN_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_HUMAN_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorehumans++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_HUMAN)
			}
			else if (!fnGetHumans())
			{
				// Zombie team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Ahhh not again^nCant feel the same pain again...")
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_ZOMBIE_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_ZOMBIE_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorezombies++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_ZOMBIE)
			}
			else
			{
				// No one wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "This battle will never end...")
				
				// Play win sound
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_WIN_NO_ONE]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_WIN_NO_ONE], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_NONE)
			}
		}
		case MODE_ASSASIN:
		{
			if (!fnGetZombies())
			{
				// Human team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Darkness has been successfully eliminated^nThats how we do it soldiers")
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_HUMAN_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_HUMAN_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorehumans++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_HUMAN)
			}
			else if (!fnGetHumans())
			{
				// Zombie team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Ahhh %s's claws are much stronger than we thought", g_playerName[g_lastSpecialZombieIndex])
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_ZOMBIE_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_ZOMBIE_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorezombies++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_ZOMBIE)
			}
			else
			{
				// No one wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "This battle will never end...")
				
				// Play win sound
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_WIN_NO_ONE]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_WIN_NO_ONE], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_NONE)
			}
		}
		case MODE_NEMESIS:
		{
			if (!fnGetZombies())
			{
				// Human team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Darkness has been successfully eliminated^nThats how we do it soldiers")
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_HUMAN_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_HUMAN_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorehumans++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_HUMAN)
			}
			else if (!fnGetHumans())
			{
				// Zombie team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Ahhh %s's skills are much stronger than we thought...", g_playerName[g_lastSpecialZombieIndex])
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_ZOMBIE_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_ZOMBIE_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorezombies++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_ZOMBIE)
			}
			else
			{
				// No one wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "This battle will never end...")
				
				// Play win sound
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_WIN_NO_ONE]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_WIN_NO_ONE], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_NONE)
			}
		}
		case MODE_REVENANT:
		{
			if (!fnGetZombies())
			{
				// Human team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Darkness has been successfully eliminated^nThats how we do it soldiers")
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_HUMAN_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_HUMAN_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorehumans++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_HUMAN)
			}
			else if (!fnGetHumans())
			{
				// Zombie team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "%s as a revenant is much stronger than we thought...", g_playerName[g_lastSpecialZombieIndex])
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_ZOMBIE_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_ZOMBIE_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorezombies++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_ZOMBIE)
			}
			else
			{
				// No one wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "This battle will never end...")
				
				// Play win sound
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_WIN_NO_ONE]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_WIN_NO_ONE], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_NONE)
			}
		}
		case MODE_BOMBARDIER:
		{
			if (!fnGetZombies())
			{
				// Human team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Darkness has been successfully eliminated^nThats how we do it soldiers")
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_HUMAN_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_HUMAN_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorehumans++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_HUMAN)
			}
			else if (!fnGetHumans())
			{
				// Zombie team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Looks like %s's bombs were very powerful^nBetter luck next time...", g_playerName[g_lastSpecialZombieIndex])
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_ZOMBIE_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_ZOMBIE_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorezombies++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_ZOMBIE)
			}
			else
			{
				// No one wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "This battle will never end...")
				
				// Play win sound
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_WIN_NO_ONE]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_WIN_NO_ONE], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_NONE)
			}
		}
		case MODE_SURVIVOR:
		{
			if (!fnGetZombies())
			{
				// Human team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "They will not mess with you again^n%s is a badass Survivor", g_playerName[g_lastSpecialHumanIndex])
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_HUMAN_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_HUMAN_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorehumans++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_HUMAN)
			}
			else if (!fnGetHumans())
			{
				// Zombie team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Ahhh not again^nBetter luck next time %s...", g_playerName[g_lastSpecialHumanIndex])

				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_ZOMBIE_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_ZOMBIE_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorezombies++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_ZOMBIE)
			}
			else
			{
				// No one wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "This battle will never end...")
				
				// Play win sound
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_WIN_NO_ONE]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_WIN_NO_ONE], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_NONE)
			}
		}
		case MODE_SNIPER:
		{
			if (!fnGetZombies())
			{
				// Human team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "%s's AWP is much stronger than you think^nBe carefull next time Mr.Zombie", g_playerName[g_lastSpecialHumanIndex])
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_HUMAN_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_HUMAN_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorehumans++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_HUMAN)
			}
			else if (!fnGetHumans())
			{
				// Zombie team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Ahhh not again^nBetter luck next time %s...", g_playerName[g_lastSpecialHumanIndex])
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_ZOMBIE_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_ZOMBIE_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorezombies++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_ZOMBIE)
			}
			else
			{
				// No one wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "This battle will never end...")
				
				// Play win sound
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_WIN_NO_ONE]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_WIN_NO_ONE], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_NONE)
			}
		}
		case MODE_SAMURAI:
		{
			if (!fnGetZombies())
			{
				// Human team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "%s's sword is much sharper that you think^nBe carefull next time Mr.Zombie", g_playerName[g_lastSpecialHumanIndex])
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_HUMAN_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_HUMAN_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorehumans++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_HUMAN)
			}
			else if (!fnGetHumans())
			{
				// Zombie team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Ahhh not again^nYou need to sharpen your skills and sword^n%s", g_playerName[g_lastSpecialHumanIndex])
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_ZOMBIE_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_ZOMBIE_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorezombies++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_ZOMBIE)
			}
			else
			{
				// No one wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "This battle will never end...")
				
				// Play win sound
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_WIN_NO_ONE]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_WIN_NO_ONE], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_NONE)
			}
		}
		case MODE_GRENADIER:
		{
			if (!fnGetZombies())
			{
				// Human team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "%s's grenades are too pwerfull....", g_playerName[g_lastSpecialHumanIndex])
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_HUMAN_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_HUMAN_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorehumans++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_HUMAN)
			}
			else if (!fnGetHumans())
			{
				// Zombie team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Ahhh not again^nYou need to try hard next time^n%s", g_playerName[g_lastSpecialHumanIndex])
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_ZOMBIE_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_ZOMBIE_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorezombies++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_ZOMBIE)
			}
			else
			{
				// No one wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "This battle will never end...")
				
				// Play win sound
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_WIN_NO_ONE]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_WIN_NO_ONE], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_NONE)
			}
		}
		case MODE_TERMINATOR:
		{
			if (!fnGetZombies())
			{
				// Human team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "%s's terminates on an extreme level....", g_playerName[g_lastSpecialHumanIndex])
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_HUMAN_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_HUMAN_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorehumans++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_HUMAN)
			}
			else if (!fnGetHumans())
			{
				// Zombie team wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "Ahhh not again^nYou need to try hard next time^n%s", g_playerName[g_lastSpecialHumanIndex])
				
				// Play win sound and increase score, unless game commencing
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_ZOMBIE_WIN]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_ZOMBIE_WIN], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				if (!g_gamecommencing) g_scorezombies++

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_ZOMBIE)
			}
			else
			{
				// No one wins
				set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "This battle will never end...")
				
				// Play win sound
				iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_WIN_NO_ONE]) - 1)
				ArrayGetString(Array:g_startSound[SOUND_WIN_NO_ONE], iRand, buffer, charsmax(buffer))
				PlaySound(buffer)

				// Execute our forward
				ExecuteForward(g_forwards[ROUND_END], g_forwardRetVal, TEAM_NONE)
			}
		}
	}

	static iFrags
	static iMaximumPacks
	static iMaximumKills
	static iPacksLeader
	static iKillsLeader
	iMaximumPacks = 0
	iMaximumKills = 0
	iPacksLeader = 0
	iKillsLeader = 0
	g_iVariable = 1

	while (g_maxplayers + 1 > g_iVariable)
	{
		if (g_isconnected[g_iVariable])
		{
			iFrags = get_user_frags(g_iVariable)
			if (iFrags > iMaximumKills)
			{
				iMaximumKills = iFrags
				iKillsLeader = g_iVariable
			}
		}
		g_iVariable += 1
	}
	g_iVariable = 1

	while (g_maxplayers + 1 > g_iVariable)
	{
		if (g_isconnected[g_iVariable] && g_ammopacks[g_iVariable] > iMaximumPacks)
		{
			iMaximumPacks = g_ammopacks[g_iVariable]
			iPacksLeader = g_iVariable
		}
		g_iVariable += 1
	}

	if (g_isconnected[iKillsLeader])
	{
		if (g_iKillsThisRound[iKillsLeader]) client_print_color(0, print_team_grey, "^3%s^1 is^4 Leader^1 with^4 %s^1 frags! [^4 %d^1 this round ]", g_playerName[iKillsLeader], AddCommas(iMaximumKills), g_iKillsThisRound[iKillsLeader])
		else client_print_color(0, print_team_grey, "^3%s^1 is^4 Leader^1 with^4 %s^1 frags!", g_playerName[iKillsLeader], AddCommas(iMaximumKills))
	}

	if (g_isconnected[iPacksLeader]) client_print_color(0, print_team_grey, "^3%s^1 is^4 Leader^1 with^4 %s^1 packs!", g_playerName[iPacksLeader], AddCommas(iMaximumPacks))
	
	// Game commencing triggers round end
	g_gamecommencing = false
	
	// Balance the teams
	balance_teams()
}

// Event Map Ended
public event_intermission()
{
	// Remove ambience sounds task
	remove_task(TASK_AMBIENCESOUNDS)
}

public event_reset_hud(id)
{
	Show_VIP()

	// 3rd person death
	set_view(id, CAMERA_NONE)

	return PLUGIN_HANDLED
}

public Show_VIP()
{
	for (new id = 0; id <= g_maxplayers; id++)
	{
		// Show VIP in ScoreBoard
		if (g_vip[id])
		{
			message_begin(MSG_ALL, get_user_msgid("ScoreAttrib"))
			write_byte(id)
			write_byte(4)
			message_end()
		}
	}
}

// Some one aimed at someone
public event_show_status(id)
{
	// Not a bot and is still connected
	if (!g_isbot[id] && g_isconnected[id]) 
	{
		// Retrieve the aimed player's id
		static aimid
		aimid = read_data(2)
		
		// Only show friends status ?
		if (CheckBit(g_playerTeam[id], TEAM_HUMAN) == CheckBit(g_playerTeam[aimid], TEAM_HUMAN))
		{
			static red, green, blue 
			
			// Format the class name according to the player's team
			if (CheckBit(g_playerTeam[id], TEAM_ZOMBIE))
			{
				red = 255
				green = 50
				blue = 0

				// Show the notice
				set_hudmessage(red, green, blue, -1.0, 0.60, 1, 0.01, 0.40, 0.01, 0.01, -1)
				ShowSyncHudMsg(id, g_MsgSync3,"%s^n[ %s | Health: %s | Ammo: %s | Points: %s ]", \
				g_playerName[aimid], g_classString[aimid], AddCommas(pev(aimid, pev_health)), AddCommas(g_ammopacks[aimid]), AddCommas(clamp(g_points[aimid], 0, 99999)))
			}
			else
			{
				red = 0
				green = 50
				blue = 255

				// Show the notice
				set_hudmessage(red, green, blue, -1.0, 0.60, 1, 0.01, 0.40, 0.01, 0.01, -1)
				ShowSyncHudMsg(id, g_MsgSync3,"%s^n[ %s | Health: %s | Ammo: %s | Armor: %d | Points: %s ]", \
				g_playerName[aimid], g_classString[aimid], AddCommas(pev(aimid, pev_health)), AddCommas(g_ammopacks[aimid]), pev(aimid, pev_armorvalue), AddCommas(clamp(g_points[aimid], 0, 99999)))
			}
		}
		else if (CheckBit(g_playerTeam[id], TEAM_HUMAN) && CheckBit(g_playerTeam[aimid], TEAM_ZOMBIE))
		{
			set_hudmessage(255, 50, 0, -1.0, 0.60, 1, 0.01, 0.40, 0.01, 0.01, -1)
			ShowSyncHudMsg(id, g_MsgSync3, "%s^n[ Health: %s ]", g_playerName[aimid], AddCommas(pev(aimid, pev_health)))
		}
		else if (CheckBit(g_playerTeam[id], TEAM_ZOMBIE) && CheckBit(g_playerTeam[aimid], TEAM_HUMAN))
		{
			if (CheckBit(g_playerClass[aimid], CLASS_SNIPER) || CheckBit(g_playerClass[aimid], CLASS_SURVIVOR) || CheckBit(g_playerClass[aimid], CLASS_SAMURAI))
			{
				set_hudmessage(255, 15, 15, -1.0, 0.60, 1, 0.01, 0.40, 0.01, 0.01, -1)
				ShowSyncHudMsg(id, g_MsgSync3, "%s^n[ Health: %s ]", g_playerName[aimid], AddCommas(pev(aimid, pev_health)))
			}
			else
			{
				set_hudmessage(255, 15, 15, -1.0, 0.60, 1, 0.01, 0.40, 0.01, 0.01, -1)
				ShowSyncHudMsg(id, g_MsgSync3, "%s^n[ Health: %s | Armor: %d ]", g_playerName[aimid], AddCommas(pev(aimid, pev_health)), pev(aimid, pev_armorvalue))
			}
		}
	}
}

// Remove the aim-info message
public event_hide_status(id){ ClearSyncHud(id, g_MsgSync3); }

// Countdown function
public Countdown()
{
	if (countdown_timer)
	{ 
		client_cmd(0, "spk %s", CountdownSounds[countdown_timer])
		
		set_hudmessage(179, 0, 0, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1, 10)
		ShowSyncHudMsg(0, g_MsgSync4, "Infection in %i", countdown_timer)

		countdown_timer--

		set_task(1.0, "Countdown", TASK_COUNTDOWN)
	}
	else
	{
		client_cmd(0, "spk %s", CountdownSounds[countdown_timer])
		set_hudmessage(179, 0, 0, -1.0, 0.28, 2, 0.02, 2.0, 0.01, 0.1, 10)
		ShowSyncHudMsg(0, g_MsgSync4, "Warning: Biohazard detected")

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)
	}
}

/*================================================================================
	[Main Forwards]
=================================================================================*/

// Entity Spawn Forward
public fw_Spawn(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return FMRES_IGNORED
	
	// Get classname
	new classname[32]
	pev(entity, pev_classname, classname, sizeof classname - 1)
	
	// Check whether it needs to be removed
	for (new i = 0; i < sizeof g_objective_ents; i++)
	{
		if (equal(classname, g_objective_ents[i]))
		{
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE
		}
	}
	
	return FMRES_IGNORED
}

// Sound Precache Forward
public fw_PrecacheSound(const sound[])
{
	// Block all those unneeeded hostage sounds
	if (equal(sound, "hostage", 7))
	return FMRES_SUPERCEDE
	
	return FMRES_IGNORED
}

// Ham Player Spawn Post Forward
public OnPlayerSpawn(id)
{
	// Not alive or didn't join a team yet
	if (!is_user_alive(id) || !fm_cs_get_user_team(id)) return

	ROGInitialize(250.0) // Initialize Rog
	// ROGDumpOriginData() // Dump the origin data

	// Get the next origin and spawn the player there
	new Float:Origin[3] 
	ROGGetOrigin(Origin) 
	engfunc(EngFunc_SetOrigin, id, Origin)

	// Player spawned
	g_isalive[id] = true
	g_specialclass[id] = false
	g_classString[id] = "Human"
	g_jumpnum[id] = 1
	
	// Remove previous tasks
	remove_task(id + TASK_SPAWN)
	remove_task(id + TASK_MODEL)
	remove_task(id + TASK_BLOOD)
	remove_task(id + TASK_BURN)
	remove_task(id + TASK_CHARGE)
	remove_task(id + TASK_FLASH)
	remove_task(id + TASK_NVISION)

	if (g_punished[id])
	{
		user_kill(id)
		client_print_color(0, print_team_grey, "%s ^3%s ^1got slayed as he was ^4punished", CHAT_PREFIX, g_playerName[id])
	}
	
	// Hide money?
	if (RemoveMoney) set_task(0.4, "task_hide_money", id + TASK_SPAWN)
	
	// Respawn player if he dies because of a worldspawn kill?
	if (RespawnOnWorldSpawnKill && !g_punished[id]) set_task(2.0, "respawn_player_check_task", id + TASK_SPAWN)
	
	// Spawn as zombie?
	if (g_respawn_as_zombie[id] && !g_newround)
	{
		reset_vars(id, 0) // reset player vars
		MakeZombie(id) // make him zombie right away
		return
	}
	
	// Reset player vars
	reset_vars(id, 0)
	g_buytime[id] = get_gametime()
	
	// Show custom buy menu
	set_task(0.2, "show_menu_buy1", id + TASK_SPAWN)
	
	// Set health and gravity
	set_user_health(id, HumanHealth)
	set_pev(id, pev_gravity, HumanGravity)
	
	// Set human maxspeed
	ExecuteHamB(Ham_Player_ResetMaxSpeed, id)

	// VIP
	if (VipHasFlag(id, 'a') && g_jumpnum[id] != 2) g_jumpnum[id] = 2
	if (VipHasFlag(id, 'b') && get_armor(id) <= 50) set_armor(id, get_armor(id) + 50)
	if (VipHasFlag(id, 'c')) set_health(id, get_health(id) + 150)
	if (VipHasFlag(id, 'd')) g_ammopacks[id] += 10
	
	// Switch to CT if spawning mid-round
	if (!g_newround && fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
	{
		remove_task(id + TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		fm_user_team_update(id)
	}
	
	// Set the right model, after checking that we don't already have it
	static Float:current_time
	current_time = get_gametime()
	
	if (current_time - g_models_targettime >= g_modelchange_delay)
	{
		ChangeModels(id + TASK_MODEL)
		g_models_targettime = current_time
	}
	else
	{
		set_task((g_models_targettime + g_modelchange_delay) - current_time, "ChangeModels", id+TASK_MODEL)
		g_models_targettime = g_models_targettime + g_modelchange_delay
	}
	
	// Remove glow
	remove_glow(id)
	
	// Bots stuff
	if (g_isbot[id])
	{
		// Turn off NVG for bots
		cs_set_user_nvg(id, 0)
	}
	
	// Enable spawn protection for humans spawning mid-round
	if (!g_newround && SpawnProtectionDelay > 0.0)
	{
		// Do not take damage
		g_nodamage[id] = true
		
		// Make temporarily invisible
		set_pev(id, pev_effects, pev(id, pev_effects) | EF_NODRAW)
		
		// Set task to remove it
		set_task(SpawnProtectionDelay, "remove_spawn_protection", id+TASK_SPAWN)
	}
	
	// Turn off his flashlight (prevents double flashlight bug/exploit)
	turn_off_flashlight(id)
	
	// Set the flashlight charge task to update battery status
	if (g_cached_customflash)
	set_task(1.0, "ChargeFlashLight", id + TASK_CHARGE, _, _, "b")
	
	// Replace weapon models (bugfix)
	static weapon_ent
	weapon_ent = fm_cs_get_current_weapon_ent(id)
	if (pev_valid(weapon_ent)) replace_weapon_models(id, cs_get_weapon_id(weapon_ent))
	
	// Last Zombie Check
	fnCheckLastZombie()
}

// Ham Player Killed Forward
public OnPlayerKilled(victim, attacker, shouldgib)
{
	// Player killed
	g_isalive[victim] = false
	
	// Disable nodamage mode after we die to prevent spectator nightvision using zombie madness colors bug
	g_nodamage[victim] = false

	// Remove concussion grenade effects
	remove_task(victim + TASK_CONCUSSION)

	// --------------- 3rd Person Death ------------------

	client_cmd(victim,"spk fvox/flatline.wav")
	UTIL_ScreenFade(victim, {0, 0, 0}, random_float(2.0, 3.5), 0.3, 255, FFADE_OUT, true, false)
	set_view(victim, CAMERA_3RDPERSON)
	SetFOV(victim, get_cvar_num("amx_hsfov"))
	set_view(victim, CAMERA_NONE)

	// --------------- 3rd Person Death ------------------

	
	// Enable dead players nightvision
	spec_nvision(victim)
	
	// Disable nightvision when killed (bugfix)
	if ((!NightVisionEnabled) && g_nvision[victim])
	{
		if (CustomNightVision) remove_task(victim + TASK_NVISION)
		else if (g_nvisionenabled[victim]) set_user_gnvision(victim, 0)
		g_nvision[victim] = false
		g_nvisionenabled[victim] = false
	}
	
	// Turn off nightvision when killed (bugfix)
	if (NightVisionEnabled == 2 && g_nvision[victim] && g_nvisionenabled[victim])
	{
		if (CustomNightVision) remove_task(victim + TASK_NVISION)
		else set_user_gnvision(victim, 0)
		g_nvisionenabled[victim] = false
	}
	
	// Turn off custom flashlight when killed
	if (g_cached_customflash)
	{
		// Turn it off
		g_flashlight[victim] = false
		g_flashbattery[victim] = 100
		
		// Remove previous tasks
		remove_task(victim + TASK_CHARGE)
		remove_task(victim + TASK_FLASH)
	}
	
	// Stop bleeding/burning/aura when killed
	if (CheckBit(g_playerClass[victim], CLASS_ZOMBIE))
	{
		remove_task(victim + TASK_BLOOD)
		remove_task(victim + TASK_BURN)
	}
	
	// Make Player body explode on kill
	SetHamParamInteger(3, 2)

	// Fade screen of kller
	UTIL_ScreenFade(attacker, {0, 0, 200}, 0.5, 0.5, 75, FFADE_IN, true, false)
	
	// Special killed functions
	if (CheckBit(g_playerClass[attacker], CLASS_NEMESIS)) g_nemesiskills[attacker]++
	else if (CheckBit(g_playerClass[attacker], CLASS_ASSASIN)) g_assasinkills[attacker]++
	else if (CheckBit(g_playerClass[attacker], CLASS_BOMBARDIER)) g_bombardierkills[attacker]++
	else if (CheckBit(g_playerClass[attacker], CLASS_REVENANT)) g_revenantkills[attacker]++
	else if (CheckBit(g_playerClass[attacker], CLASS_SURVIVOR)) g_survivorkills[attacker]++
	else if (CheckBit(g_playerClass[attacker], CLASS_GRENADIER)) g_grenadierkills[attacker]++
	else if (CheckBit(g_playerClass[attacker], CLASS_TERMINATOR)) g_terminatorkills[attacker]++
	else if (CheckBit(g_playerClass[attacker], CLASS_SNIPER) && g_currentweapon[attacker] == CSW_AWP)
	{
		g_sniperkills[attacker]++
		SendLavaSplash(victim)
	}
	else if (CheckBit(g_playerClass[attacker], CLASS_SAMURAI))
	{
		g_samuraikills[attacker]++
		SendLavaSplash(victim)
	}

	// InformerX function
	static iZombies; iZombies = fnGetZombies()
	static iHumans; iHumans = fnGetHumans()
	static iNemesis; iNemesis = fnGetNemesis()
	static iAssasin; iAssasin = fnGetAssassin()
	static iSurvivors; iSurvivors = fnGetSurvivors()
	static iSnipers; iSnipers = fnGetSnipers()
	//static iSamurai; iSamurai = fnGetSamurai()
	static iBombardier; iBombardier = fnGetBombardier()
	static iGrenadier; iGrenadier = fnGetGrenadier()

	if (!fnGetHumans() || !fnGetZombies()) return


	if (CheckBit(g_currentmode, MODE_INFECTION) || CheckBit(g_currentmode, MODE_MULTI_INFECTION) 
	|| CheckBit(g_currentmode, MODE_SNIPER) || CheckBit(g_currentmode, MODE_SURVIVOR) 
	|| CheckBit(g_currentmode, MODE_SAMURAI) || CheckBit(g_currentmode, MODE_SWARM) 
	|| CheckBit(g_currentmode, MODE_GRENADIER) || CheckBit(g_currentmode, MODE_TERMINATOR))
	{
		if (CheckBit(g_playerTeam[victim], TEAM_ZOMBIE))
		{
			if (iZombies > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1) 
				ShowSyncHudMsg(0, g_MsgSync7, "%d Zombies Remaining...", iZombies)
			}
		}
	}
	else if (CheckBit(g_currentmode, MODE_NEMESIS) || CheckBit(g_currentmode, MODE_ASSASIN) 
	|| CheckBit(g_currentmode, MODE_BOMBARDIER) || CheckBit(g_currentmode, MODE_REVENANT))
	{
		if (CheckBit(g_playerTeam[victim], TEAM_HUMAN))
		{
			if (iHumans > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
				ShowSyncHudMsg(0, g_MsgSync7, "%d Humans Remaining...", iHumans)
			}
		}
	}
	else if (CheckBit(g_currentmode, MODE_SWARM))
	{
		if (CheckBit(g_playerTeam[victim], TEAM_HUMAN))
		{
			if (iHumans > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
				ShowSyncHudMsg(0, g_MsgSync7, "%d Humans Remaining...", iHumans)
			}
		}

		if (CheckBit(g_playerTeam[victim], TEAM_ZOMBIE))
		{
			if (iZombies > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1) 
				ShowSyncHudMsg(0, g_MsgSync7, "%d Zombies Remaining...", iZombies)
			}
		}
	}
	else if (CheckBit(g_currentmode, MODE_NIGHTMARE) || CheckBit(g_currentmode, MODE_SYNAPSIS) || CheckBit(g_currentmode, MODE_SURVIVOR_VS_ASSASIN))
	{
		if (CheckBit(g_playerClass[victim], CLASS_SURVIVOR))
		{
			if (iSurvivors > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
				ShowSyncHudMsg(0, g_MsgSync7, "%d Survivors Remaining...", iSurvivors)
			}
		}
		
		if (CheckBit(g_playerClass[victim], CLASS_NEMESIS))
		{
			if (iNemesis > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
				ShowSyncHudMsg(0, g_MsgSync7, "%d Nemesis Remaining...", iNemesis)
			}
		}
		
		if (CheckBit(g_playerClass[victim], CLASS_ASSASIN))
		{
			if (iAssasin > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
				ShowSyncHudMsg(0, g_MsgSync7, "%d Assasins Remaining...", iAssasin)
			}
		}
		
		if (CheckBit(g_playerClass[victim], CLASS_SNIPER))
		{
			if (iSnipers > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
				ShowSyncHudMsg(0, g_MsgSync7, "%d Snipers Remaining...", iSnipers)
			}
		}
	}
	else if (CheckBit(g_currentmode, MODE_SURVIVOR_VS_NEMESIS))
	{
		if (CheckBit(g_playerClass[victim], CLASS_SURVIVOR))
		{
			if (iSurvivors > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
				ShowSyncHudMsg(0, g_MsgSync7, "%d Survivors Remaining...", iSurvivors)
			}
		}
		
		if (CheckBit(g_playerClass[victim], CLASS_NEMESIS))
		{
			if (iNemesis > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
				ShowSyncHudMsg(0, g_MsgSync7, "%d Nemesis Remaining...", iNemesis)
			}
		}
	}
	else if (CheckBit(g_currentmode, MODE_SNIPER_VS_NEMESIS))
	{
		if (CheckBit(g_playerClass[victim], CLASS_SNIPER))
		{
			if (iSnipers > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
				ShowSyncHudMsg(0, g_MsgSync7, "%d Snipers Remaining...", iSnipers)
			}
		}
		
		if (CheckBit(g_playerClass[victim], CLASS_NEMESIS))
		{
			if (iNemesis > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
				ShowSyncHudMsg(0, g_MsgSync7, "%d Nemesis Remaining...", iNemesis)
			}
		}
		
	}
	else if (CheckBit(g_currentmode, MODE_SNIPER_VS_ASSASIN))
	{
		if (CheckBit(g_playerClass[victim], CLASS_SNIPER))
		{
			if (iSnipers > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
				ShowSyncHudMsg(0, g_MsgSync7, "%d Snipers Remaining...", iSnipers)
			}
		}
		
		if (CheckBit(g_playerClass[victim], CLASS_ASSASIN))
		{
			if (iAssasin > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
				ShowSyncHudMsg(0, g_MsgSync7, "%d Assasins Remaining...", iAssasin)
			}
		}
	}
	else if (CheckBit(g_currentmode, MODE_BOMBARDIER_VS_GRENADIER))
	{
		if (CheckBit(g_playerClass[victim], CLASS_BOMBARDIER))
		{
			if (iBombardier > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
				ShowSyncHudMsg(0, g_MsgSync7, "%d Bombardiers Remaining...", iSnipers)
			}
		}
		
		if (CheckBit(g_playerClass[victim], CLASS_GRENADIER))
		{
			if (iGrenadier > 1)
			{
				set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
				ShowSyncHudMsg(0, g_MsgSync7, "%d Grenadiers Remaining...", iAssasin)
			}
		}
	}

	if (iZombies == 1 && iHumans == 1)
	{
		set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 1, 0.01, 1.75, 1.00, 1.00, -1)
		ShowSyncHudMsg(0, g_MsgSync7, "%s vs %s", g_playerName[fnGetLastHuman()], g_playerName[fnGetLastZombie()])
	}
	
	// Determine whether the player killed himself
	static selfkill
	selfkill = (victim == attacker || !is_user_valid_connected(attacker)) ? true : false
	
	// Killed by a non-player entity or self killed
	if (selfkill) return
	
	// Killed by Zombie Team, reward packs
	if (CheckBit(g_playerTeam[attacker], TEAM_ZOMBIE))
	{
		if (CheckBit(g_playerClass[attacker], CLASS_NEMESIS)) g_ammopacks[attacker] += 2
		else if (CheckBit(g_playerClass[attacker], CLASS_ASSASIN)) g_ammopacks[attacker] += 1
		else if (CheckBit(g_playerClass[attacker], CLASS_BOMBARDIER)) g_ammopacks[attacker] += 1
		else if (CheckBit(g_playerClass[attacker], CLASS_REVENANT)) g_ammopacks[attacker] += 1
		else g_ammopacks[attacker] += 5
	}
	else
	{
		if (CheckBit(g_playerClass[attacker], CLASS_SURVIVOR)) g_ammopacks[attacker] += 2
		else if (CheckBit(g_playerClass[attacker], CLASS_SNIPER)) g_ammopacks[attacker] += 3
		else if (CheckBit(g_playerClass[attacker], CLASS_SAMURAI)) g_ammopacks[attacker] += 4
		else if (CheckBit(g_playerClass[attacker], CLASS_GRENADIER)) g_ammopacks[attacker] += 4
		else if (CheckBit(g_playerClass[attacker], CLASS_TERMINATOR)) g_ammopacks[attacker] += 4
		else g_ammopacks[attacker] += 5
	}

	// Reset some vars
	g_antidotebomb[victim] = 0
	g_concussionbomb[victim] = 0
	g_bubblebomb[victim] = 0
	g_killingbomb[victim] = 0
	g_goldenweapons[victim] = false
	
	// Human killed zombie, add up the extra frags for kill
	if (CheckBit(g_playerClass[attacker], CLASS_HUMAN) && HumanFragsForKill > 1)
	UpdateFrags(attacker, victim, HumanFragsForKill - 1, 0, 0)
	
	// Zombie killed human, add up the extra frags for kill
	if (CheckBit(g_playerClass[attacker], CLASS_ZOMBIE) && ZombieRewardInfectFrags > 1)
	UpdateFrags(attacker, victim, ZombieRewardInfectFrags - 1, 0, 0)

	// For Leader
	g_iKillsThisRound[attacker]++

	// Update player datas
	if (random_num(1, 4) == 1)
	{
		g_points[attacker] += 10
		set_hudmessage(255, 180, 30, -1.00, 0.10, 1, 0.00, 1.75, 1.00, 1.00, -1)
		ShowSyncHudMsg(attacker, g_MsgSync6, "== ELIMINATION ==^n!!!Randomly got +10 point!!!^n[ 25%% chance ]")
	} 
	else g_points[attacker] += 2
	g_kills[attacker] += 1
	g_deaths[victim] += 1
	g_score[attacker] += 10

	// Update SQL Database
	MySQL_UPDATE_DATABASE(attacker)
	MySQL_UPDATE_DATABASE(victim)
}

// Ham Player Killed Post Forward
public OnPlayerKilledPost(victim, attacker, shouldgib)
{
	// Last Zombie Check
	fnCheckLastZombie()
}

// Ham Take Damage Forward
public OnTakeDamage(victim, inflictor, attacker, Float:damage, damage_type, ptr)
{
	if (damage_type & DMG_FALL && VipHasFlag(victim, 'e')) return HAM_SUPERCEDE

	// Non-player damage or self damage
	if (victim == attacker || !is_user_valid_connected(attacker)) return HAM_IGNORED
	
	// New round starting or round ended
	if (g_newround || g_endround) return HAM_SUPERCEDE
	
	// Victim shouldn't take damage 
	if (g_nodamage[victim]) return HAM_SUPERCEDE
	
	// Prevent friendly fire
	if (CheckBit(g_playerTeam[attacker], TEAM_ZOMBIE) == CheckBit(g_playerTeam[victim], TEAM_ZOMBIE)) return HAM_SUPERCEDE
	
	// Reward ammo packs to human classes
	
	// Attacker is human...
	if (CheckBit(g_playerTeam[attacker], TEAM_HUMAN))
	{
		// Armor multiplier for the final damage on normal zombies
		if (CheckBit(g_playerClass[attacker], CLASS_HUMAN))		// Abhinash
		{
			damage *= ZombieArmor
			SetHamParamFloat(4, damage)
		}

		// Set Sniper's damage
		if ((CheckBit(g_playerClass[attacker], CLASS_SNIPER) && g_currentweapon[attacker] == CSW_AWP) && (damage_type & DMG_BULLET))
		SetHamParamFloat(4, SniperDamage)
		
		// Set samurai's damage	
		if ((CheckBit(g_playerClass[attacker], CLASS_SAMURAI) && g_currentweapon[attacker] == CSW_KNIFE) && (damage_type & DMG_BULLET))
		SetHamParamFloat(4, SamuraiDamage)

		// Set Grenadier's damage
		if ((CheckBit(g_playerClass[attacker], CLASS_GRENADIER) && g_currentweapon[attacker] == CSW_KNIFE) && (damage_type & DMG_BULLET))
		SetHamParamFloat(4, GrenadierDamage)

		// Crossbow damage
		if (g_currentweapon[attacker] == CSW_SG550 && g_has_crossbow[attacker])
		{
			damage *= CROSSBOW_DAMAGE
			SetHamParamFloat(4, CROSSBOW_DAMAGE)
		}

		if (VipHasFlag(attacker, 'f') && (CheckBit(g_playerClass[attacker], CLASS_HUMAN) || CheckBit(g_playerClass[attacker], CLASS_SURVIVOR) || CheckBit(g_playerClass[attacker], CLASS_TRYDER)) && (damage_type & DMG_BULLET))
		{
			if (g_goldenweapons[attacker] && (g_currentweapon[attacker] == CSW_AK47 || CSW_M4A1 || CSW_XM1014 || CSW_DEAGLE)) damage *= 1.5
			else damage *= 2.0

			SetHamParamFloat(4, damage)
		}
		else if (g_doubledamage[attacker] && (CheckBit(g_playerClass[attacker], CLASS_HUMAN) || CheckBit(g_playerClass[attacker], CLASS_SURVIVOR) || CheckBit(g_playerClass[attacker], CLASS_TRYDER)) && (damage_type & DMG_BULLET))
		{
			if (g_goldenweapons[attacker] && (g_currentweapon[attacker] == CSW_AK47 || CSW_M4A1 || CSW_XM1014 || CSW_DEAGLE)) damage *= 1.5
			else damage *= 2.0

			SetHamParamFloat(4, damage)
		}
		if (CheckBit(g_playerClass[attacker], CLASS_HUMAN) && g_currentweapon[attacker] == CSW_AWP && (damage_type & DMG_BULLET)) 
		{
			damage = 3000.0
			SetHamParamFloat(4, 3000.0)
		}

		
		g_damagedealt_human[attacker] += floatround(damage)
		
		if (CheckBit(g_playerClass[attacker], CLASS_HUMAN) || CheckBit(g_playerClass[attacker], CLASS_SURVIVOR) 
		|| CheckBit(g_playerClass[attacker], CLASS_TRYDER) || CheckBit(g_playerClass[attacker], CLASS_GRENADIER)
		|| CheckBit(g_playerClass[attacker], CLASS_TERMINATOR) || CheckBit(g_playerClass[attacker], CLASS_BOMBARDIER))
		{
			while (g_damagedealt_human[attacker] >= 500)
			{
				g_ammopacks[attacker]++
				g_damagedealt_human[attacker] -= 500
			}
		}

		// Bullet damage
		if (damage) 
		{
			if (++iPosition[attacker] == sizeof(g_flCoords)) iPosition[attacker] = 0

			if (damage_type & DMG_BLAST) 
			{
				client_print_color(attacker, print_team_grey, "%s Damage to^3 %s^1 ::^4 %s^1 damage", CHAT_PREFIX, g_playerName[victim], AddCommas(floatround(damage)))

				set_hudmessage(200, 0, 0, g_flCoords[iPosition[attacker]][0], g_flCoords[iPosition[attacker]][1], 0, 0.1, 2.5, 0.02, 0.02, -1)
				show_hudmessage(attacker, "%s", AddCommas(floatround(damage)))

				// Send Screenfade message
				UTIL_ScreenFade(victim, {200, 0, 0}, 1.0, 0.5, 100, FFADE_IN, true, false)

				// Send Screenshake message
				SendScreenShake(victim, 4096 * 6, 4096 * random_num(4, 12), 4096 * random_num(4, 12))
			}
			else if ((CheckBit(g_playerClass[attacker], CLASS_HUMAN) || CheckBit(g_playerClass[attacker], CLASS_SURVIVOR) 
			|| CheckBit(g_playerClass[attacker], CLASS_TRYDER) || CheckBit(g_playerClass[attacker], CLASS_GRENADIER)
			|| CheckBit(g_playerClass[attacker], CLASS_TERMINATOR)) && (damage_type & DMG_BULLET))
			{
				set_hudmessage(0, 40, 80, g_flCoords[iPosition[attacker]][0], g_flCoords[iPosition[attacker]][1], 0, 0.1, 2.5, 0.02, 0.02, -1)
				show_hudmessage(attacker, "%s", AddCommas(floatround(damage)))	
			} 
		}
		
		return HAM_IGNORED
	}
	// Attacker is zombie...
	else
	{
		// Nemesis?
		if (CheckBit(g_playerClass[attacker], CLASS_NEMESIS))
		{
			// Ignore nemesis damage override if damage comes from a 3rd party entity
			// (to prevent this from affecting a sub-plugin's rockets e.g.)
			if (inflictor == attacker) SetHamParamFloat(4, NemesisDamage)
			return HAM_IGNORED
		}
		else if (CheckBit(g_playerClass[attacker], CLASS_ASSASIN))
		{
			// Ignore assassin damage override if damage comes from a 3rd party entity
			// (to prevent this from affecting a sub-plugin's rockets e.g.)
			if (inflictor == attacker) SetHamParamFloat(4, AssassinDamage)
			return HAM_IGNORED
		}
		else if (CheckBit(g_playerClass[attacker], CLASS_BOMBARDIER))
		{
			// Ignore assassin damage override if damage comes from a 3rd party entity
			// (to prevent this from affecting a sub-plugin's rockets e.g.)

			if (damage) 
			{
				if (++iPosition[attacker] == sizeof(g_flCoords)) iPosition[attacker] = 0

				if (damage_type & DMG_BLAST) 
				{
					set_hudmessage(200, 0, 0, g_flCoords[iPosition[attacker]][0], g_flCoords[iPosition[attacker]][1], 0, 0.1, 2.5, 0.02, 0.02, -1)
					show_hudmessage(attacker, "%s", AddCommas(floatround(damage)))

					// Send Screenfade message
					UTIL_ScreenFade(victim, {200, 0, 0}, 1.0, 0.5, 100, FFADE_IN, true, false)

					// Send Screenshake message
					SendScreenShake(victim, 4096 * 6, 4096 * random_num(4, 12), 4096 * random_num(4, 12))
				}
			}

			if (inflictor == attacker) SetHamParamFloat(4, BombardierDamage)
			return HAM_IGNORED
		}
		else if (CheckBit(g_playerClass[attacker], CLASS_REVENANT))
		{
			// Ignore assassin damage override if damage comes from a 3rd party entity
			// (to prevent this from affecting a sub-plugin's rockets e.g.)
			if (inflictor == attacker) SetHamParamFloat(4, RevenantDamage)
			return HAM_IGNORED
		}
	}

	// Prevent infection/damage by HE grenade (bugfix)
	if (damage_type & DMG_HEGRENADE) return HAM_SUPERCEDE
	
	// Last human or not an infection round
	if (CheckBit(g_currentmode, MODE_SURVIVOR) 
	|| CheckBit(g_currentmode, MODE_SNIPER) 
	|| CheckBit(g_currentmode, MODE_NEMESIS) 
	|| CheckBit(g_currentmode, MODE_ASSASIN) 
	|| CheckBit(g_currentmode, MODE_BOMBARDIER) 
	|| CheckBit(g_currentmode, MODE_SAMURAI) 
	|| CheckBit(g_currentmode, MODE_GRENADIER)
	|| CheckBit(g_currentmode, MODE_TERMINATOR)
	|| CheckBit(g_currentmode, MODE_REVENANT)
	|| CheckBit(g_currentmode, MODE_SWARM) 
	|| CheckBit(g_currentmode, MODE_PLAGUE) 
	|| CheckBit(g_currentmode, MODE_SYNAPSIS)
	|| CheckBit(g_currentmode, MODE_SURVIVOR_VS_NEMESIS) 
	|| CheckBit(g_currentmode, MODE_SURVIVOR_VS_ASSASIN) 
	|| CheckBit(g_currentmode, MODE_SNIPER_VS_ASSASIN) 
	|| CheckBit(g_currentmode, MODE_BOMBARDIER_VS_GRENADIER)
	|| CheckBit(g_currentmode, MODE_NIGHTMARE) 
	|| fnGetHumans() == 1) return HAM_IGNORED // human is killed
	
	// Does human armor need to be reduced before infecting?
	if (HumanArmorProtect && (CheckBit(g_playerClass[victim], CLASS_HUMAN) || CheckBit(g_playerClass[victim], CLASS_TRYDER)))
	{		
		// Get victim armor
		static Float:armor
		pev(victim, pev_armorvalue, armor)
		
		// If he has some, block the infection and reduce armor instead
		if (armor)
		{
			// Fade screen of killer
			UTIL_ScreenFade(victim, {200, 0, 0}, 0.5, 0.5, 75, FFADE_IN, true, false)

			// Emit sound
			emit_sound(victim, CHAN_BODY, sound_armorhit, 1.0, ATTN_NORM, 0, PITCH_NORM)

			if (armor - damage > 0.0)
			set_pev(victim, pev_armorvalue, armor - damage)
			else
			cs_set_user_armor(victim, 0, CS_ARMOR_NONE)
			return HAM_SUPERCEDE
		}
	}
	
	// Infection allowed
	SendDeathMsg(attacker, victim) // send death notice
	FixScoreAttrib(victim) // fix the "dead" attrib on scoreboard
	UpdateFrags(attacker, victim, ZombieRewardInfectFrags, 1, 1) // add corresponding frags and deaths
	
	set_user_health(attacker, pev(attacker, pev_health) + 250)
	
	MakeZombie(victim, CLASS_ZOMBIE, attacker) // turn into zombie
	g_points[attacker]++		// Abhinash
	g_kills[attacker]++
	g_infections[attacker]++
	g_score[attacker] += 10

	// Update database
	MySQL_UPDATE_DATABASE(attacker)

	return HAM_SUPERCEDE
}

// Ham Take Damage Post Forward
public OnTakeDamagePost(victim)
{
	// --- Check if victim should be Pain Shock Free ---
	
	// Check if proper CVARs are enabled
	if (CheckBit(g_playerTeam[victim], TEAM_ZOMBIE))
	{
		if (CheckBit(g_playerClass[victim], CLASS_NEMESIS)) if (!NemesisPainfree && !(pev(victim, pev_button) & (IN_JUMP | IN_DUCK))) return
		else if (CheckBit(g_playerClass[victim], CLASS_ASSASIN)) if (!AssassinPainfree) return
		else if (CheckBit(g_playerClass[victim], CLASS_BOMBARDIER)) if (!BombardierPainfree) return
		else if (CheckBit(g_playerClass[victim], CLASS_REVENANT)) if (!RevenantPainfree) return
		else
		switch (ZombiePainfree)
		{
			case 0: return
			case 1: if (!g_lastzombie[victim]) return
			case 2: if (!g_firstzombie[victim]) return
		}
	}
	else
	{
		if (CheckBit(g_playerClass[victim], CLASS_SURVIVOR)) if (!SurvivorPainfree) return
		else if (CheckBit(g_playerClass[victim], CLASS_SNIPER)) if (!SniperPainfree) return
		else if (CheckBit(g_playerClass[victim], CLASS_SAMURAI)) if (!SamuraiPainfree) return
		else if (CheckBit(g_playerClass[victim], CLASS_GRENADIER)) if (!GrenadierPainfree) return
		else if (CheckBit(g_playerClass[victim], CLASS_TERMINATOR)) if (!TerminatorPainfree) return
		else return
	}
	
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(victim) != PDATA_SAFE) return
	
	// Set pain shock free offset
	set_pdata_float(victim, OFFSET_PAINSHOCK, 1.0, OFFSET_LINUX)
}

// Ham Trace Attack Forward
public OnTraceAttack(victim, attacker, Float:damage, Float:direction[3], tracehandle, damage_type, ptr)
{
	// Non-player damage or self damage
	if (victim == attacker || !is_user_valid_connected(attacker)) return HAM_IGNORED
	
	// New round starting or round ended
	if (g_newround || g_endround) return HAM_SUPERCEDE
	
	// Victim shouldn't take damage or victim is frozen
	if (g_nodamage[victim]) return HAM_SUPERCEDE
	
	// Prevent friendly fire
	if (CheckBit(g_playerTeam[attacker], TEAM_ZOMBIE) == CheckBit(g_playerTeam[victim], TEAM_ZOMBIE)) return HAM_SUPERCEDE
	
	// Victim isn't a zombie or not bullet damage, nothing else to do here
	if (CheckBit(g_playerTeam[victim], TEAM_HUMAN) || !(damage_type & DMG_BULLET)) return HAM_IGNORED
	
	// Knockback disabled, nothing else to do here
	if (!KnockbackEnabled) return HAM_IGNORED
	
	// Get whether the victim is in a crouch state
	static ducking; ducking = (pev(victim, pev_flags) & (FL_DUCKING | FL_ONGROUND)) == (FL_DUCKING | FL_ONGROUND)
	
	// Zombie knockback when ducking disabled
	if (ducking && KnockbackDucking == 0.0) return HAM_IGNORED
	
	// Get distance between players
	static origin1[3], origin2[3]
	get_user_origin(victim, origin1)
	get_user_origin(attacker, origin2)
	
	// Max distance exceeded
	if (get_distance(origin1, origin2) > KnockbackDistance) return HAM_IGNORED
	
	// Get victim's velocity
	static Float:velocity[3]
	pev(victim, pev_velocity, velocity)
	
	// Use damage on knockback calculation
	xs_vec_mul_scalar(direction, damage, direction)
	
	// Apply ducking knockback multiplier
	if (ducking)
	xs_vec_mul_scalar(direction, KnockbackDucking, direction)
	
	// Apply zombie class/nemesis knockback multiplier
	if (CheckBit(g_playerClass[victim], CLASS_NEMESIS))
	xs_vec_mul_scalar(direction, KnockbackNemesis, direction)
	else if (CheckBit(g_playerClass[victim], CLASS_ASSASIN))
	xs_vec_mul_scalar(direction, KnockbackAssassin, direction)
	else if (CheckBit(g_playerClass[victim], CLASS_BOMBARDIER))
	xs_vec_mul_scalar(direction, KnockbackBombardier, direction)
	else if (CheckBit(g_playerClass[victim], CLASS_REVENANT))
	xs_vec_mul_scalar(direction, KnockbackRevenant, direction)
	else
	xs_vec_mul_scalar(direction, g_cZombieClasses[g_zombieclass[victim]][Knockback], direction) 
	
	// Add up the new vector
	xs_vec_add(velocity, direction, direction)
	
	// Make knockback also affect vertical velocity
	direction[2] = velocity[2]
	
	// Set the knockback'd victim's velocity
	set_pev(victim, pev_velocity, direction)

	// Golden Weapon functions
	if (g_goldenweapons[attacker] && ((g_currentweapon[attacker] == CSW_AK47)
	|| (g_currentweapon[attacker] == CSW_M4A1) || (g_currentweapon[attacker] == CSW_XM1014) || (g_currentweapon[attacker] == CSW_DEAGLE)))
	{
		SendTracers(attacker)
		SendLightningTracers(attacker)
	}
	
	return HAM_IGNORED
}

public OnPlayerJump(id)
{
	if (g_isalive[id] && g_jumpnum[id] > 0)
	{
		new flags = pev(id, pev_flags)

		if (flags & FL_WATERJUMP || pev(id, pev_waterlevel) >= 2 || !(get_pdata_int(id, 246) & IN_JUMP))
		return HAM_IGNORED

		if (flags & FL_ONGROUND)
		{
			g_jumpcount[id] = 0
			return HAM_IGNORED
		}

		if (g_jumpnum[id])
		{
			if (get_pdata_float(id, 251) < 500 && ++g_jumpcount[id] <= g_jumpnum[id])
			{
				new Float:fVelocity[3]
				pev(id, pev_velocity, fVelocity)
				fVelocity[2] = 270.0
				set_pev(id, pev_velocity, fVelocity)

				return HAM_HANDLED
			}
		}
	}

	return HAM_IGNORED
}

public OnPlayerDuck(id)
{
	// Check if proper CVARs are enabled and retrieve leap settings
	static Float:cooldown, Float:current_time
	if (CheckBit(g_playerTeam[id], TEAM_ZOMBIE))
	{
		if (CheckBit(g_playerClass[id], CLASS_NEMESIS))
		{
			if (!g_cached_leapnemesis) return
			cooldown = g_cached_leapnemesiscooldown
		}
		else if (CheckBit(g_playerClass[id], CLASS_ASSASIN))
		{
			if (!g_cached_leapassassin) return
			cooldown = g_cached_leapassassincooldown
		}
		else if (CheckBit(g_playerClass[id], CLASS_BOMBARDIER))
		{
			if (!g_cached_leapbombardier) return
			cooldown = g_cached_leapbombardiercooldown
		}
		else if (CheckBit(g_playerClass[id], CLASS_REVENANT))
		{
			if (!g_cached_leaprevenant) return
			cooldown = g_cached_leaprevenantcooldown
		}
		else if (LeapZombies) cooldown = g_cached_leapzombiescooldown	
	}
	else
	{
		if (CheckBit(g_playerClass[id], CLASS_SURVIVOR))
		{
			if (!g_cached_leapsurvivor) return
			cooldown = g_cached_leapsurvivorcooldown
		}
		else if (CheckBit(g_playerClass[id], CLASS_SNIPER))
		{
			if (!g_cached_leapsniper) return
			cooldown = g_cached_leapsnipercooldown
		}
		else if (CheckBit(g_playerClass[id], CLASS_SAMURAI))
		{
			if (!g_cached_leapzadoc) return
			cooldown = g_cached_leapzadoccooldown
		}
		else if (CheckBit(g_playerClass[id], CLASS_GRENADIER))
		{
			if (!g_cached_leapgrenadier) return
			cooldown = g_cached_leapgrenadiercooldown
		}
		else if (CheckBit(g_playerClass[id], CLASS_TERMINATOR))
		{
			if (!g_cached_leapterminator) return
			cooldown = g_cached_leapterminatorcooldown
		}
		else return
	}
	
	current_time = get_gametime()
	
	// Cooldown not over yet
	if (current_time - g_lastleaptime[id] < cooldown) return
	
	// Not doing a longjump (don't perform check for bots, they leap automatically)
	if (!g_isbot[id] && !(pev(id, pev_button) & (IN_JUMP | IN_DUCK) == (IN_JUMP | IN_DUCK))) return
	
	// Not on ground or not enough speed
	if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 80) return
	
	static Float:velocity[3]
	
	// Make velocity vector
	velocity_by_aim(id, CheckBit(g_playerClass[id], CLASS_SURVIVOR) ? LeapSurvivorForce
	: CheckBit(g_playerClass[id], CLASS_SNIPER) ? LeapSniperForce
	: CheckBit(g_playerClass[id], CLASS_SAMURAI) ? LeapSamuraiForce		
	: CheckBit(g_playerClass[id], CLASS_GRENADIER) ? LeapGrenadierForce		
	: CheckBit(g_playerClass[id], CLASS_NEMESIS) ? LeapNemesisForce
	: CheckBit(g_playerClass[id], CLASS_ASSASIN) ? LeapAssassinForce
	: CheckBit(g_playerClass[id], CLASS_BOMBARDIER) ? LeapBombardierForce	
	: CheckBit(g_playerClass[id], CLASS_REVENANT) ? LeapRevenantForce	
	: CheckBit(g_playerClass[id], CLASS_TERMINATOR) ? LeapTerminatorForce
	: LeapZombiesForce, velocity)
	
	// Set custom height
	velocity[2] = CheckBit(g_playerClass[id], CLASS_SURVIVOR) ? LeapSurvivorHeight
	: CheckBit(g_playerClass[id], CLASS_SNIPER) ? LeapSniperHeight
	: CheckBit(g_playerClass[id], CLASS_SAMURAI) ? LeapSamuraiHeight		
	: CheckBit(g_playerClass[id], CLASS_GRENADIER) ? LeapGrenadierHeight		
	: CheckBit(g_playerClass[id], CLASS_NEMESIS) ? LeapNemesisHeight
	: CheckBit(g_playerClass[id], CLASS_ASSASIN) ? LeapAssassinHeight
	: CheckBit(g_playerClass[id], CLASS_BOMBARDIER) ? LeapBombardierHeight
	: CheckBit(g_playerClass[id], CLASS_REVENANT) ? LeapRevenantHeight
	: CheckBit(g_playerClass[id], CLASS_TERMINATOR) ? LeapTerminatorHeight
	: LeapZombiesHeight
	
	// Apply the new velocity
	set_pev(id, pev_velocity, velocity)
	
	// Update last leap time
	g_lastleaptime[id] = current_time
}

public event_CurWeapon(id)
{
	if (is_user_connected(id))
	{
		if (CheckBit(g_playerClass[id], CLASS_SNIPER))
		{
			new clip, ammo
			new wpnid = get_user_weapon(id, clip, ammo)


			if ((bullets[id] > clip) && (wpnid == CSW_AWP)) 
			{
				new origin[3]
				get_user_origin(id, origin, 3) // 4 - Where the bullet goes
				
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
				write_byte(TE_BEAMENTPOINT)
				write_short(id | 0x1000) // start entity
				write_coord(origin[0]) // endposition.x
				write_coord(origin[1]) // endposition.y
				write_coord(origin[2]) // endposition.z
				write_short(g_trailspr) // sprite index
				write_byte(0) // starting frame
				write_byte(0) // frame rate in 0.1's
				write_byte(2) // life in 0.1's
				write_byte(10) // line wdith in 0.1's
				write_byte(0) // noise amplitude in 0.01's
				write_byte(255) // red
				write_byte(255) // green
				write_byte(0) // blue
				write_byte(200) // brightness
				write_byte(0) // scroll speed in 0.1's
				message_end()
			}
			bullets[id] = clip
		}
	}
}

// Ham Reset MaxSpeed Post Forward
public OnResetMaxSpeedPost(id)
{
	// Freezetime active or player not alive
	if (g_freezetime || !g_isalive[id])
	return
	
	set_player_maxspeed(id)
}

// Ham Use Stationary Gun Forward
public OnUseStationary(entity, caller, activator, use_type)
{
	// Prevent zombies from using stationary guns
	if (use_type == USE_USING && is_user_valid_connected(caller) && CheckBit(g_playerTeam[caller], TEAM_ZOMBIE)) return HAM_SUPERCEDE
	
	return HAM_IGNORED
}

// Ham Use Stationary Gun Post Forward
public OnUseStationaryPost(entity, caller, activator, use_type)
{
	// Someone stopped using a stationary gun
	if (use_type == USE_STOPPED && is_user_valid_connected(caller))
	replace_weapon_models(caller, g_currentweapon[caller]) // replace weapon models (bugfix)
}

// Ham Weapon Touch Forward
public OnTouchWeapon(weapon, id)
{
	// Not a player
	if (!is_user_valid_connected(id)) return HAM_IGNORED
	
	// Dont pickup weapons if zombie or survivor (+PODBot MM fix)
	if (g_isalive[id]) return HAM_SUPERCEDE
	
	return HAM_IGNORED
}

// Ham Weapon Pickup Forward
public OnAddPlayerItem(id, weapon_ent)
{
	// HACK: Retrieve our custom extra ammo from the weapon
	static extra_ammo; extra_ammo = pev(weapon_ent, PEV_ADDITIONAL_AMMO)
	
	// If present
	if (extra_ammo)
	{
		// Get weapon's id
		static weaponid; weaponid = cs_get_weapon_id(weapon_ent)
		
		// Add to player's bpammo
		ExecuteHamB(Ham_GiveAmmo, id, extra_ammo, AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
		set_pev(weapon_ent, PEV_ADDITIONAL_AMMO, 0)
	}
}

// Ham Weapon Deploy Forward
public OnWeaponDeploy(weapon_ent)
{
	// Get weapon's owner
	new id = get_pdata_cbase(weapon_ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
	
	// Valid owner?
	if (!pev_valid(id)) return
	
	// Get weapon's id
	static weaponid; weaponid = cs_get_weapon_id(weapon_ent)
	
	// Store current weapon's id for reference
	g_currentweapon[id] = weaponid
	
	// Replace weapon models with custom ones
	replace_weapon_models(id, weaponid)
	
	// Zombie not holding an allowed weapon for some reason
	if (CheckBit(g_playerTeam[id], TEAM_ZOMBIE) && !((1<<weaponid) & ZOMBIE_ALLOWED_WEAPONS_BITSUM))
	{
		// Switch to knife
		g_currentweapon[id] = CSW_KNIFE
		engclient_cmd(id, "weapon_knife")
	}
}

// WeaponMod bugfix
//forward wpn_gi_reset_weapon(id)
public wpn_gi_reset_weapon(id)
{
	// Replace knife model
	replace_weapon_models(id, CSW_KNIFE)
}

// id joins the game
public client_putinserver(id)
{
	// Plugin disabled?
	if (!g_pluginenabled) return
	
	// Player joined
	g_isconnected[id] = true
	
	//CreateFog(id, 128, 128, 128, 0.0008)
	
	get_user_name(id, g_playerName[id], charsmax(g_playerName[])) // Cache player's name
	get_user_authid(id, g_playerSteamID[id], charsmax(g_playerSteamID[])) // Cache player's steamid
	copy(g_playerConcat[id], charsmax(g_playerConcat[]), g_playerName[id]) // Copy player's name to temporary concatenaed char array
	strcat(g_playerConcat[id], g_playerSteamID[id], charsmax(g_playerConcat[])) // Now concatenate ( add together ) player's name and steamid

	hash_string(g_playerConcat[id], Hash_Sha3_512, g_playerHash[id], charsmax(g_playerHash[])) // Now hash the concatenated player's name and steam id ( used for saving and loading database )

	// Load his data
	MySQL_LOAD_DATABASE(id)

	// Set welcome message task
	set_task(5.0, "init_welcome", id)

	// Initialize player vars
	reset_vars(id, 1)
	g_ammopacks[id] = StartingPacks // Starting ammo packs 
	
	// Load player stats?
	if (SaveStats) load_stats(id)
	
	// Set some tasks for humans only
	if (!is_user_bot(id))
	{
		// Set the custom HUD display task
		set_task(1.0, "ShowHUD", id + TASK_SHOWHUD, _, _, "b")
		
		// Disable minmodels for clients to see zombies properly
		set_task(5.0, "disable_minmodels", id)
		
		if (g_adminCount && TrieKeyExists(g_adminsTrie, g_playerName[id]))
			MakeUserAdmin(id)	// If Key Exists then make him Admin

		if (IsCurrentTimeBetween(freeVIP_Start, freeVIP_End))
		{
			if (g_vipCount && TrieKeyExists(g_vipsTrie, g_playerName[id]))
			MakeUserVip(id)		// If Key Exists then make him VIP
			else MakeFreeVIP(id)
		}
		else if (g_vipCount && TrieKeyExists(g_vipsTrie, g_playerName[id]))
		MakeUserVip(id)		// If Key Exists then make him VIP

		if (g_tagCount && TrieKeyExists(g_tagTrie, g_playerName[id]))
			GiveUserTag(id)

		get_user_ip(id, g_playerIP[id], charsmax(g_playerIP), 1)	// Get player's IP Address
	}
	else
	{
		// Set bot flag
		g_isbot[id] = true
		
		// CZ bots seem to use a different "classtype" for player entities
		// (or something like that) which needs to be hooked separately
		if (!g_hamczbots && cvar_botquota)
		{
			// Set a task to let the private data initialize
			set_task(0.1, "register_ham_czbots", id)
		}
		formatex(g_playerIP[id], charsmax(g_playerIP), "%i.%i.%i.0", random_num(0,255), random_num(0,255), random_num(0,255))
	}

	geoip_country_ex(g_playerIP[id], g_playercountry[id], charsmax(g_playercountry[]) -1)
	geoip_city(g_playerIP[id], g_playercity[id], charsmax(g_playercity[]) -1)

	if (containi(g_playercountry[id], "err") != -1) g_playercountry[id] = "N/A"
	if (!g_playercity[id][0]) g_playercity[id] = "N/A"

	if (g_vip[id]) client_print_color(0, print_team_grey, "^3Gold member^4 %s^1 connected ^4[^3%s^4]^4[^3%s^4]", g_playerName[id], g_playercountry[id], g_playercity[id])
	else client_print_color(0, print_team_grey, "^1Player^4 %s^1 connected ^4[^3%s^4]^4[^3%s^4]", g_playerName[id], g_playercountry[id], g_playercity[id])
}

public FwTraceLine(Float:start[3], Float:end[3], conditions, id, trace)
{
	// All headshots functions
	if (is_user_valid_connected(id) && is_user_valid_alive(id) && CheckBit(g_playerTeam[id], TEAM_HUMAN) && g_allheadshots[id])
		set_tr2(trace, TR_iHitgroup, HIT_HEAD)
}

// id leaving
public FwPlayerDisconnect(id)
{
	// Check that we still have both humans and zombies to keep the round going
	if (g_isalive[id]) check_round(id)
	
	// Temporarily save player stats?
	if (SaveStats) SaveStatistics(id)
	
	// Remove previous tasks
	remove_task(id + TASK_TEAM)
	remove_task(id + TASK_MODEL)
	remove_task(id + TASK_FLASH)
	remove_task(id + TASK_CHARGE)
	remove_task(id + TASK_SPAWN)
	remove_task(id + TASK_BLOOD)
	remove_task(id + TASK_BURN)
	remove_task(id + TASK_NVISION)
	remove_task(id + TASK_SHOWHUD)
	
	// Player left, clear cached flags
	g_isconnected[id] = false
	g_isbot[id] = false
	g_isalive[id] = false
}

// id left
public FwPlayerDisconnectPost()
{
	// Last Zombie Check
	fnCheckLastZombie()
}

// id Kill Forward
public FwPlayerKill()
{
	// Prevent players from killing themselves?
	if (BlockSuicide) return FMRES_SUPERCEDE
	
	return FMRES_IGNORED
}

// Emit Sound Forward
public FwEmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	static iRand, buffer[100]
	// Block all those unneeeded hostage sounds
	if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
	return FMRES_SUPERCEDE
	
	// Replace these next sounds for zombies only
	if (!is_user_valid_connected(id) || CheckBit(g_playerTeam[id], TEAM_HUMAN))
	return FMRES_IGNORED
	
	// Zombie being hit
	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't')
	{
		if (CheckBit(g_playerClass[id], CLASS_NEMESIS)) 
		{
			iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_NEMESIS_PAIN]) - 1)
			ArrayGetString(Array:g_miscSounds[SOUND_NEMESIS_PAIN], iRand, buffer, charsmax(buffer))
			emit_sound(id, channel, buffer, volume, attn, flags, pitch)
		}
		else if (CheckBit(g_playerClass[id], CLASS_ASSASIN)) 
		{
			iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_ASSASIN_PAIN]) - 1)
			ArrayGetString(Array:g_miscSounds[SOUND_ASSASIN_PAIN], iRand, buffer, charsmax(buffer))
			emit_sound(id, channel, buffer, volume, attn, flags, pitch)
		}
		else if (CheckBit(g_playerClass[id], CLASS_REVENANT)) 
		{
			iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_REVENANT_PAIN]) - 1)
			ArrayGetString(Array:g_miscSounds[SOUND_REVENANT_PAIN], iRand, buffer, charsmax(buffer))
			emit_sound(id, channel, buffer, volume, attn, flags, pitch)
		}
		else 
		{
			iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_PAIN]) - 1)
			ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_PAIN], iRand, buffer, charsmax(buffer))
			emit_sound(id, channel, buffer, volume, attn, flags, pitch)
		}

		return FMRES_SUPERCEDE
	}
	
	// Zombie attacks with knife
	if (sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
	{
		if (sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') // slash
		{
			iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_MISS_SLASH]) - 1)
			ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_MISS_SLASH], iRand, buffer, charsmax(buffer))
			emit_sound(id, channel, buffer, volume, attn, flags, pitch)
			return FMRES_SUPERCEDE
		}
		if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') // hit
		{
			if (sample[17] == 'w') // wall
			{
				iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_MISS_WALL]) - 1)
				ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_MISS_WALL], iRand, buffer, charsmax(buffer))
				emit_sound(id, channel, buffer, volume, attn, flags, pitch)
				return FMRES_SUPERCEDE
			}
			else
			{
				iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_HIT_NORMAL]) - 1)
				ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_HIT_NORMAL], iRand, buffer, charsmax(buffer))
				emit_sound(id, channel, buffer, volume, attn, flags, pitch)
				return FMRES_SUPERCEDE
			}
		}
		if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') // stab
		{
			iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_HIT_STAB]) - 1)
			ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_HIT_STAB], iRand, buffer, charsmax(buffer))
			emit_sound(id, channel, buffer, volume, attn, flags, pitch)
			return FMRES_SUPERCEDE
		}
	}
	
	// Zombie dies
	if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
	{
		iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_DIE]) - 1)
		ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_DIE], iRand, buffer, charsmax(buffer))
		emit_sound(id, channel, buffer, volume, attn, flags, pitch)
		return FMRES_SUPERCEDE
	}
	
	// Zombie falls off
	if (sample[10] == 'f' && sample[11] == 'a' && sample[12] == 'l' && sample[13] == 'l')
	{
		iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_FALL]) - 1)
		ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_FALL], iRand, buffer, charsmax(buffer))
		emit_sound(id, channel, buffer, volume, attn, flags, pitch)
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

// Forward Set ClientKey Value -prevent CS from changing player models-
public FwSetPlayerKeyValue(id, const infobuffer[], const key[])
{
	// Block CS model changes
	if (key[0] == 'm' && key[1] == 'o' && key[2] == 'd' && key[3] == 'e' && key[4] == 'l')
	return FMRES_SUPERCEDE
	
	return FMRES_IGNORED
}

// Forward id User Info Changed -prevent players from changing models-
public FwPlayerUserInfoChanged(id)
{
	// Cache player's name
	get_user_info(id, "name", g_playerName[id], charsmax(g_playerName[]))
}

// Forward Get Game Description
public FwGetGameDescription()
{
	// Return the mod name so it can be easily identified
	forward_return(FMV_STRING, "Zombie Queen 11.5")
	
	return FMRES_SUPERCEDE
}

// Forward Set Model
public FwSetModel(entity, const model[])
{
	// We don't care
	if (strlen(model) < 8)
	return
	
	// Remove weapons?
	
	// Get entity's classname
	static classname[10]
	pev(entity, pev_classname, classname, charsmax(classname))
	
	// Check if it's a weapon box
	if (equal(classname, "weaponbox"))
	{
		// They get automatically removed when thinking
		set_pev(entity, pev_nextthink, get_gametime())
		return
	}
	
	// Narrow down our matches a bit
	if (model[7] != 'w' || model[8] != '_')
	return
	
	// Get damage time of grenade
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)
	
	// Grenade not yet thrown
	if (dmgtime == 0.0)
	return

	// Get owner
	new id; id = entity_get_edict(entity, EV_ENT_owner)

	switch (model[9])
	{
		case 'h':
		{
			if (CheckBit(g_playerTeam[id], TEAM_ZOMBIE))
			{
				if (CheckBit(g_playerClass[id], CLASS_BOMBARDIER))
				{
					if (CheckBit(g_currentmode, MODE_BOMBARDIER_VS_GRENADIER)) SetNadeType(entity, g_color[__nade_type_explosion][__red], g_color[__nade_type_explosion][__green], g_color[__nade_type_explosion][__blue], NADE_TYPE_EXPLOSION)
					else SetNadeType(entity, g_color[__nade_type_killing][__red], g_color[__nade_type_killing][__green], g_color[__nade_type_killing][__blue], NADE_TYPE_KILLING)
				} 
				else SetNadeType(entity, g_color[__nade_type_infection][__red], g_color[__nade_type_infection][__green], g_color[__nade_type_infection][__blue], NADE_TYPE_INFECTION)
			}
			else
			{
				if (g_killingbomb[id])
				{
					SetNadeType(entity, g_color[__nade_type_killing][__red], g_color[__nade_type_killing][__green], g_color[__nade_type_killing][__blue], NADE_TYPE_KILLING)

					// Decrease count
					g_killingbomb[id]--
				}
				else if (g_antidotebomb[id])
				{
					SetNadeType(entity, g_color[__nade_type_antidote][__red], g_color[__nade_type_antidote][__green], g_color[__nade_type_antidote][__blue], NADE_TYPE_ANTIDOTE)

					// Decrease count
					g_antidotebomb[id]--
				}
				else SetNadeType(entity, g_color[__nade_type_explosion][__red], g_color[__nade_type_explosion][__green], g_color[__nade_type_explosion][__blue], NADE_TYPE_EXPLOSION)
			}
		}
		case 'f':
		{
			if (CheckBit(g_playerTeam[id], TEAM_ZOMBIE))
			{
				if (g_concussionbomb[id])
				{
					SetNadeType(entity, g_color[__nade_type_concussion][__red], g_color[__nade_type_concussion][__green], g_color[__nade_type_concussion][__blue], NADE_TYPE_CONCUSSION)

					// Decrease Counb
					g_concussionbomb[id]--
				}
			}
			else SetNadeType(entity, g_color[__nade_type_napalm][__red], g_color[__nade_type_napalm][__green], g_color[__nade_type_napalm][__blue], NADE_TYPE_NAPALM)
		}
		case 's':
		{
			if (g_bubblebomb[id])
			{
				SetNadeType(entity, g_color[__nade_type_forcefield][__red], g_color[__nade_type_forcefield][__green], g_color[__nade_type_forcefield][__blue], NADE_TYPE_BUBBLE)

				// Decrease Counb
				g_bubblebomb[id]--
			}
			else SetNadeType(entity, g_color[__nade_type_frost][__red], g_color[__nade_type_frost][__green], g_color[__nade_type_frost][__blue], NADE_TYPE_FROST)	
		}
	}

	if (equal(model, "models/w_sg550.mdl"))
	{
		static iStoredAugID
		
		iStoredAugID = find_ent_by_owner(-1, "weapon_sg550", entity)
	
		if (!is_valid_ent(iStoredAugID)) return
	
		if (g_has_crossbow[id])
		{
			entity_set_int(iStoredAugID, EV_INT_impulse, 35481)			
			g_has_crossbow[id] = false			
			entity_set_model(entity, crossbow_W_MODEL)
			return
		}
	}

	return
}

// Ham Grenade Think Forward
public OnThinkGrenade(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return HAM_IGNORED
	
	// Get damage time of grenade
	static Float:dmgtime, Float:current_time
	pev(entity, pev_dmgtime, dmgtime)
	current_time = get_gametime()
	
	// Check if it's time to go off
	if (dmgtime > current_time)
	return HAM_IGNORED
	
	// Check if it's one of our custom nades
	switch (pev(entity, PEV_NADE_TYPE))
	{
	case NADE_TYPE_INFECTION: // Infection Bomb
		{
			OnInfectionExplode(entity)
			return HAM_SUPERCEDE
		}
	case NADE_TYPE_EXPLOSION: // Explosion Grenade
		{
			OnExplosionExplode(entity)
			return HAM_SUPERCEDE
		}
	case NADE_TYPE_NAPALM: // Napalm Grenade
		{
			OnNapalmExplode(entity)
			return HAM_SUPERCEDE
		}
	case NADE_TYPE_FROST: // Frost Grenade
		{
			OnFrostExplode(entity)
			return HAM_SUPERCEDE
		}
	case NADE_TYPE_ANTIDOTE: // Antidote Grenade
		{
			OnAntidoteExplode(entity)
			return HAM_SUPERCEDE
		}
	case NADE_TYPE_CONCUSSION: // Infection Bomb
		{
			OnConcussionExplode(entity)
			return HAM_SUPERCEDE
		}
	case NADE_TYPE_KILLING: //  Killing grenade and Bombardier's kill bomb
		{
			OnKillingExplode(entity)
			return HAM_SUPERCEDE
		}
	case NADE_TYPE_BUBBLE: // Bubble bomb ( Force Field Grenade )
		{
			OnForceFieldExplode(entity)
			return HAM_SUPERCEDE
		}
	}
	
	return HAM_IGNORED
}

SetNadeType(const entity, const red, const green, const blue, const nade_type) 
{
	// Give it a glow
	set_glow(entity, red, green, blue, 13)
	
	// Send TE_BEAMFOLLOW
	SendGrenadeBeamFollow(entity, red, green, blue)
	
	// Set pev
	set_pev(entity, PEV_NADE_TYPE, nade_type)
}

public Rocket_Touch(attacker, iRocket)
{
	if(g_isconnected[attacker])
	{
		for(new victim = 0; victim < g_maxplayers; victim++)
		{
			if(g_isalive[victim] && CheckBit(g_playerTeam[victim], TEAM_ZOMBIE) && !g_nodamage[victim])
			{
				static Float: fDistance, Float: fDamage
				fDistance = entity_range(victim, iRocket) * 1.5

				if(fDistance < 320.0)
				{
					fDamage = 1250.0 - fDistance
					
					if (CheckBit(g_playerClass[victim], CLASS_NEMESIS) || CheckBit(g_playerClass[victim], CLASS_ASSASIN) 
					|| CheckBit(g_playerClass[victim], CLASS_BOMBARDIER) || CheckBit(g_playerClass[victim], CLASS_REVENANT))
					fDamage *= 1.50
				
					// Throw him away in his current vector
					static Float: fVelocity[3]
					pev(victim, pev_velocity, fVelocity)
					xs_vec_mul_scalar(fVelocity, 2.75, fVelocity)
					fVelocity[2] *= 1.75
					set_pev(victim, pev_velocity, fVelocity)
				
					if (float(pev(victim, pev_health)) - fDamage > 0.0)
						ExecuteHamB(Ham_TakeDamage, victim, iRocket, attacker, fDamage, DMG_BLAST)
					else 
					{
						ExecuteHamB(Ham_Killed, victim, attacker, 2)
						SendLavaSplash(victim)
					}
				}
			}
		}
	}
}

public OnKnifeBlinkAttack(entity)
{
	static owner; owner = pev(entity, pev_owner);
	if (CheckBit(g_playerClass[owner], CLASS_ZOMBIE) && g_blinks[owner])
	{
		if (get_target_and_attack(owner))
		{
			client_print_color(0, print_team_grey, "%s ^3%s^1 just used a knife blink ^4[ ^3%i ^1remaining ^4]", CHAT_PREFIX, g_playerName[owner], g_blinks[owner])
			g_blinks[owner]--
		}
	}

	return PLUGIN_CONTINUE
}

public OnCrossbowAddToPlayer(Aug, id)
{
	if (!is_valid_ent(Aug) || !g_isconnected[id]) return HAM_IGNORED
	
	if (entity_get_int(Aug, EV_INT_impulse) == 35481)
	{
		g_has_crossbow[id] = true		
		entity_set_int(Aug, EV_INT_impulse, 0)		

		return HAM_HANDLED
	}
	
	return HAM_IGNORED
}

public OnCrossbowPrimaryAttack(Weapon)
{
	new id = get_pdata_cbase(Weapon, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)

	if (!pev_valid(id)) return
	if (!g_has_crossbow[id]) return
	
	g_IsInPrimaryAttack = 1
	pev(id, pev_punchangle, cl_pushangle[id])
	
	g_clip_ammo[id] = cs_get_weapon_ammo(Weapon)
}

public OnCrossbowPrimaryAttackPost(Weapon)
{
	g_IsInPrimaryAttack = 0

	new id = get_pdata_cbase(Weapon, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)

	if (!pev_valid(id)) return
	
	if (g_has_crossbow[id])
	{
		if (!g_clip_ammo[id]) return

		set_pdata_float(Weapon, 46, 0.1304, OFFSET_LINUX_WEAPONS)
		set_pdata_float(Weapon, 47, 0.1304, OFFSET_LINUX_WEAPONS)

		new Float:push[3]
		pev(id, pev_punchangle,push)
		xs_vec_sub(push, cl_pushangle[id], push)
		
		xs_vec_mul_scalar(push, CROSSBOW_RECOIL, push)
		xs_vec_add(push, cl_pushangle[id], push)
		set_pev(id, pev_punchangle, push)
		
		emit_sound(id, CHAN_WEAPON, "PerfectZM/crossbow_shoot.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		UTIL_PlayWeaponAnimation(id, random_num(1, 2))
	}
}

public OnCrossbowPostFrame(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)

	if (!pev_valid(id)) return HAM_IGNORED

	if (!g_has_crossbow[id]) return HAM_IGNORED
	
	static iClipExtra; iClipExtra = CROSSBOW_CLIP

	new Float:flNextAttack = get_pdata_float(id, 83, OFFSET_LINUX)
	new iBpAmmo = cs_get_user_bpammo(id, CSW_SG550)
	new iClip = get_pdata_int(weapon_entity, 51, OFFSET_LINUX_WEAPONS)
	new fInReload = get_pdata_int(weapon_entity, 54, OFFSET_LINUX_WEAPONS) 

	if (fInReload && flNextAttack <= 0.0)
	{
		new j = min(iClipExtra - iClip, iBpAmmo)

		set_pdata_int(weapon_entity, 51, iClip + j, OFFSET_LINUX_WEAPONS)
		cs_set_user_bpammo(id, CSW_SG550, iBpAmmo-j)
		
		set_pdata_int(weapon_entity, 54, 0, OFFSET_LINUX_WEAPONS)
		fInReload = 0
	}

	return HAM_IGNORED
}

public OnCrossbowReload(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)

	if (!pev_valid(id)) return HAM_IGNORED

	if (!g_has_crossbow[id]) return HAM_IGNORED

	static iClipExtra; iClipExtra = CROSSBOW_CLIP

	g_crossbow_TmpClip[id] = -1

	new iBpAmmo = cs_get_user_bpammo(id, CSW_SG550)
	new iClip = get_pdata_int(weapon_entity, 51, OFFSET_LINUX_WEAPONS)

	if (iBpAmmo <= 0) return HAM_SUPERCEDE

	if (iClip >= iClipExtra) return HAM_SUPERCEDE

	g_crossbow_TmpClip[id] = iClip

	return HAM_IGNORED
}

public OnCrossbowReloadPost(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)

	if (!pev_valid(id)) return HAM_IGNORED

	if (!g_has_crossbow[id]) return HAM_IGNORED

	if (g_crossbow_TmpClip[id] == -1) return HAM_IGNORED

	set_pdata_int(weapon_entity, 51, g_crossbow_TmpClip[id], OFFSET_LINUX_WEAPONS)
	set_pdata_float(weapon_entity, 48, 3.7, OFFSET_LINUX_WEAPONS)
	set_pdata_float(id, 83, 3.7, OFFSET_LINUX)
	set_pdata_int(weapon_entity, 54, 1, OFFSET_LINUX_WEAPONS)

	UTIL_PlayWeaponAnimation(id, 3)

	return HAM_IGNORED
}

public FwUpdateClientDataPost(Player, SendWeapons, CD_Handle)
{
	if (!is_user_alive(Player) || (get_user_weapon(Player) != CSW_SG550 || !g_has_crossbow[Player])) return FMRES_IGNORED
	
	set_cd(CD_Handle, CD_flNextAttack, halflife_time () + 0.001)

	return FMRES_HANDLED
}

public FwPlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if ((eventid != g_orig_event_crossbow) || !g_IsInPrimaryAttack) return FMRES_IGNORED

	if (!(1 <= invoker <= g_maxplayers)) return FMRES_IGNORED

	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	return FMRES_SUPERCEDE
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player)
	write_byte(Sequence)
	write_byte(pev(Player, pev_body))
	message_end()
}

public TraceAttack(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
	new g_currentweapon = get_user_weapon(iAttacker)

	if (g_currentweapon != CSW_SG550) return
	
	if (!g_has_crossbow[iAttacker]) return

	new vec1[3], Float:flEnd[3], Float:velocity[3]
	get_user_origin(iAttacker, vec1, 1)
	get_tr2(ptr, TR_vecEndPos, flEnd)
	velocity_by_aim(iAttacker, 4000, velocity)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_GUNSHOTDECAL)
	engfunc(EngFunc_WriteCoord, flEnd[0])
	engfunc(EngFunc_WriteCoord, flEnd[1])
	engfunc(EngFunc_WriteCoord, flEnd[2])
	write_short(iAttacker)
	write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
	message_end()

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_PROJECTILE)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2]-2)
	engfunc(EngFunc_WriteCoord, velocity[0])
	engfunc(EngFunc_WriteCoord, velocity[1])
	engfunc(EngFunc_WriteCoord, velocity[2])
	write_short(g_spriteLightning)
	write_byte(10)
	write_byte(iAttacker)
	message_end()
}

stock drop_prim(id) 
{
	new weapons[32], num
	get_user_weapons(id, weapons, num)
	for (new i = 0; i < num; i++) 
	{
		if (Wep_sg550 & (1<<weapons[i])) 
		{
			static wname[32]
			get_weaponname(weapons[i], wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}

public OnWeaponPrimaryAttack(entity)
{
	new id = pev(entity, pev_owner)

	if (g_norecoil[id])
	{
		pev(id, pev_punchangle, cl_pushangle[id])
		return HAM_IGNORED
	}

	return HAM_IGNORED
}

public OnWeaponPrimaryAttackPost(entity)
{
	new id = pev(entity, pev_owner)

	if (g_norecoil[id])
	{
		new Float: push[3]
		pev(id, pev_punchangle, push)
		xs_vec_sub(push, cl_pushangle[id], push)
		xs_vec_mul_scalar(push, 0.0, push)
		xs_vec_add(push, cl_pushangle[id], push)
		set_pev(id, pev_punchangle, push)
		return HAM_IGNORED
	}

	return HAM_IGNORED
}

// Forward CmdStart
public FwCmdStart(id, handle)
{
	// Not alive
	if (!g_isalive[id])
	return

	// Get button for Zombie Abilities
	new button = pev(id, pev_button)

	if (CheckBit(g_playerClass[id], CLASS_ZOMBIE) && (button & IN_USE) && g_zombieclass[id] == 1)
	OnRaptorSkill(id)
	
	if (CheckBit(g_playerClass[id], CLASS_ZOMBIE) && (button & IN_USE) && g_zombieclass[id] == 3)
	OnFrozenSkill(id)

	// Predator zombie skill
	if (CheckBit(g_playerClass[id], CLASS_ZOMBIE) && (button & IN_USE) && g_zombieclass[id] == 5)
	OnPredatorSkill(id)

	// Hunter zombie skill
	if (CheckBit(g_playerClass[id], CLASS_ZOMBIE) && (button & IN_USE) && g_zombieclass[id] == 6)
	OnHunterSkill(id)
	
	// This logic looks kinda weird, but it should work in theory...
	// p = g_zombie[id], q = g_survivor[id], r = g_cached_customflash
	// ¬(p v q v (¬p ^ r)) <==> ¬p ^ ¬q ^ (p v ¬r)
	if (CheckBit(g_playerClass[id], CLASS_HUMAN) && (CheckBit(g_playerTeam[id], TEAM_ZOMBIE) || !g_cached_customflash))		// Abhinash
	return
	
	// Check if it's a flashlight impulse
	if (get_uc(handle, UC_Impulse) != IMPULSE_FLASHLIGHT)
	return
	
	// Block it I say!
	set_uc(handle, UC_Impulse, 0)
	
	// Should human's custom flashlight be turned on?
	if (CheckBit(g_playerClass[id], CLASS_HUMAN) && g_flashbattery[id] > 2 && get_gametime() - g_lastflashtime[id] > 1.2)
	{
		// Prevent calling flashlight too quickly (bugfix)
		g_lastflashtime[id] = get_gametime()
		
		// Toggle custom flashlight
		g_flashlight[id] = !(g_flashlight[id])
		
		// Play flashlight toggle sound
		emit_sound(id, CHAN_ITEM, sound_flashlight, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Update flashlight status on the HUD
		message_begin(MSG_ONE, get_user_msgid("Flashlight"), _, id)
		write_byte(g_flashlight[id]) // toggle
		write_byte(g_flashbattery[id]) // battery
		message_end()
		
		// Remove previous tasks
		remove_task(id + TASK_CHARGE)
		remove_task(id + TASK_FLASH)
		
		// Set the flashlight charge task
		set_task(1.0, "ChargeFlashLight", id + TASK_CHARGE, _, _, "b")
		
		// Call our custom flashlight task if enabled
		if (g_flashlight[id]) 
		{
			switch (random_num(0, 1))
			{
				case 0: set_task(0.1, "set_user_flashlight_1", id + TASK_FLASH, _, _, "b")
				case 1: set_task(0.1, "set_user_flashlight_2", id + TASK_FLASH, _, _, "b")
			}
		}
	}
}

public OnRaptorSkill(id)
{
	if (!g_isalive[id]) return PLUGIN_HANDLED
	
	if (get_gametime() - g_lastability[id] < float(frost_cooldown)) return PLUGIN_HANDLED
	
	g_lastability[id] = get_gametime()

	g_raptor_speeded[id] = true
	ExecuteHamB(Ham_Player_ResetMaxSpeed, id)

	set_task(0.1, "StartRaptorFx", id)
	set_task(5.0, "StopRaptorFx", id)

	set_task(1.0, "OnSkillsCooldownHUD", id, _, _, "a", frost_cooldown)
	set_task(frost_time, "OnResetRaptorSpeed", id)
	
	return PLUGIN_HANDLED
}

public StartRaptorFx(id)
{
	// Make Raptor glow
	set_glow(id, 250, 104, 20, 50)

	// Add screenfade to Raptor's screen
	UTIL_ScreenFade(id, {250, 104, 20}, 0.0, 0.0, 100, FFADE_STAYOUT, true, false)

	// A nice trail for speed effect
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(id)
	write_short(g_trailspr)
	write_byte(5) // Life
	write_byte(15) // Size
	write_byte(250) // Red
	write_byte(104) // Green
	write_byte(20) // Blue
	write_byte(150) // Brigtness
	message_end()
}

public StopRaptorFx(id)
{
	// Remove Raptor's glow
	remove_glow(id)

	// Gradually remove Raptor's screenfade
	UTIL_ScreenFade(id, {250, 104, 20}, 1.0, 0.0, 100, FFADE_IN, true, false)

	// Remove Raptor's trail
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_KILLBEAM)	
	write_short(id)
	message_end()
}

public OnResetRaptorSpeed(id)
{
	g_raptor_speeded[id] = false
	set_pev(id, pev_maxspeed, g_cZombieClasses[g_zombieclass[id]][Speed])
}

public OnFrozenSkill(id)
{
	if (!g_isalive[id]) return PLUGIN_HANDLED
	
	if(get_gametime() - g_lastability[id] < float(frost_cooldown)) return PLUGIN_HANDLED
	
	g_lastability[id] = get_gametime()

	static Float:aimorigin[3]
	fm_get_aim_origin(id, aimorigin)	

	new target, body
	get_user_aiming(id, target, body, frost_distance)
	
	if (g_isalive[target] && CheckBit(g_playerClass[target], CLASS_HUMAN))
	{
		// Line effect
		SendSkillEffect(id, aimorigin, 0, 50, 90)

		if (pev(target, pev_flags) & FL_ONGROUND)
		set_pev(target, pev_gravity, 999999.9) // set really high
		else
		set_pev(target, pev_gravity, 0.000001) // no gravity

		// Prevent from moving
		ExecuteHamB(Ham_Player_ResetMaxSpeed, target)

		set_glow(target, 0, 50, 90, 50)

		g_frozen[target] = true

		// Display SKills cooldown HUD
		set_task(1.0, "OnSkillsCooldownHUD", id, _, _, "a", frost_cooldown)
		set_task(frost_time, "unfrozen_user", target)
	}

	return PLUGIN_HANDLED
}

public unfrozen_user(id)
{
	remove_glow(id)
	set_pev(id, pev_gravity, HumanGravity)
	g_frozen[id] = false
	ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
}

public OnSkillsCooldownHUD(id)
{
	if(g_isalive[id])
	{
		skillcooldown--
		set_hudmessage(200, 100, 0, 0.75, 0.92, 0, 1.0, 1.1, 0.0, 0.0, -1)
		show_hudmessage(id, "Skill cooldown: %d", skillcooldown)
	}
	else remove_task(id)

	if (!skillcooldown) skillcooldown = 10
}

public OnHunterSkill(id)
{
	if (!g_isalive[id]) return PLUGIN_HANDLED
	
	if (get_gametime() - g_lastability[id] < float(hunter_cooldown)) return PLUGIN_HANDLED
	
	g_lastability[id] = get_gametime()

	static Float:aimorigin[3]
	fm_get_aim_origin(id, aimorigin)
	
	new target, body
	get_user_aiming(id, target, body, hunter_distance)
	
	if (g_isalive[target] && CheckBit(g_playerClass[target], CLASS_HUMAN))
	{
		// Stun the target's weapons
		set_pdata_float(target, OFFSET_NEXTATTACK, 6.0, OFFSET_LINUX)
		//drop_weapons(target, 1)

		// Send BeamPoints
		SendSkillEffect(id, aimorigin, 200, 200, 0)

		// Display SKills cooldown HUD
		set_task(1.0, "OnSkillsCooldownHUD", id, _, _, "a", hunter_cooldown)
	}

	return PLUGIN_HANDLED
}

public OnPredatorSkill(id)
{
	if (!g_isalive[id]) return PLUGIN_HANDLED
	
	if (get_gametime() - g_lastability[id] < float(predator_cooldown)) return PLUGIN_HANDLED
	
	g_lastability[id] = get_gametime()

	g_invisible[id] = true
	set_task(predator_invisible_duration, "remove_invisibility", id)
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)

	// Display SKills cooldown HUD
	set_task(1.0, "OnSkillsCooldownHUD", id, _, _, "a", predator_cooldown)

	return PLUGIN_HANDLED
}

public remove_invisibility(id)
{
	g_invisible[id] = false
	remove_glow(id)
}

// Forward Player PreThink
public FwPlayerPreThink(id)
{
	// Not alive
	if (!g_isalive[id]) return	
	
	// Parachute
	static Float:vel[3]
	pev(id, pev_velocity, vel)
	
	if (pev(id, pev_button) & IN_USE && vel[2] < 0.0)
	{
		vel[2] = -100.0
		set_pev(id, pev_velocity, vel)
	}
	
	// Enable custom buyzone for player during buytime, unless zombie or survivor or time expired
	if (CheckBit(g_playerClass[id], CLASS_HUMAN) && (get_gametime() < g_buytime[id]))
	{
		if (pev_valid(g_buyzone_ent))
		dllfunc(DLLFunc_Touch, g_buyzone_ent, id)
	}
	
	// Silent footsteps for zombies?
	if (g_cached_zombiesilent && CheckBit(g_playerTeam[id], TEAM_ZOMBIE))
	set_pev(id, pev_flTimeStepSound, STEPTIME_SILENT)
	
	// Player frozen?
	if (g_frozen[id])
	{
		set_pev(id, pev_velocity, Float:{0.0,0.0,0.0}) // stop motion
		return // shouldn't leap while frozen
	}
}

public FwTouch(ent, toucher)
{
	if (!pev_valid(ent)) return FMRES_IGNORED

	static entclass[32]
	pev(ent, pev_model, entclass, 31)
	
	if (!(strcmp(entclass, BubbleGrenadeModel)))
	{	
		if (is_user_alive(toucher) && CheckBit(g_playerTeam[toucher], TEAM_ZOMBIE))
		{
			static Float:pos_ptr[3], Float:pos_ptd[3]
			
			pev(ent, pev_origin, pos_ptr)
			pev(toucher, pev_origin, pos_ptd)
			
			for(new i = 0; i < 3; i++)
			{
				pos_ptd[i] -= pos_ptr[i]
				pos_ptd[i] *= 15.0
			}

			set_pev(toucher, pev_velocity, pos_ptd)
			set_pev(toucher, pev_impulse, pos_ptd)
		}
	}

	return FMRES_HANDLED
}

/*================================================================================
	[id Commands]
=================================================================================*/
// Nightvision toggle
public clcmd_nightvision(id)
{
	// Nightvision available to player?
	if (g_nvision[id] || (g_isalive[id] && cs_get_user_nvg(id)))
	{
		// Enable-disable
		g_nvisionenabled[id] = !(g_nvisionenabled[id])
		
		// Custom nvg?
		if (CustomNightVision)
		{
			remove_task(id + TASK_NVISION)
			if (g_nvisionenabled[id]) set_task(0.1, "set_user_nvision", id + TASK_NVISION, _, _, "b")
		}
		else set_user_gnvision(id, g_nvisionenabled[id])
	}

	return PLUGIN_HANDLED
}

// Weapon Drop
public clcmd_drop(id)
{
	if (get_user_jetpack(id) && get_user_weapon(id) == CSW_KNIFE)
		user_drop_jetpack(id, 0)

	// Survivor should stick with its weapon
	if (CheckBit(g_playerClass[id], CLASS_SURVIVOR) || CheckBit(g_playerClass[id], CLASS_SNIPER)) return PLUGIN_HANDLED

	return PLUGIN_CONTINUE
}

// Block Team Change
public clcmd_changeteam(id)
{
	static team; team = fm_cs_get_user_team(id)
	
	// Unless it's a spectator joining the game
	if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED) return PLUGIN_CONTINUE
	
	// Pressing 'M' (chooseteam) ingame should show the main menu instead
	menu_display(id, g_iGameMenu, 0)

	return PLUGIN_HANDLED
}

// Say funtion
public Client_Say(id)
{
	if (!g_isconnected[id]) return PLUGIN_HANDLED

	static Float:fGameTime; fGameTime = get_gametime()

	if (g_fGagTime[id] > fGameTime)
	{
		client_print_color(id, print_team_grey,  "%s You are gagged due to your bad behaviour, please wait until your time is up", CHAT_PREFIX)
		return PLUGIN_HANDLED
	}

	static cMessage[150]
	read_args(cMessage, 149)
	remove_quotes(cMessage)

	if (!cMessage[0] || strlen(cMessage) > 147) return PLUGIN_HANDLED

	if (cMessage[0] == '@' && g_admin[id])
	{
		static g_iMessagePosition
		static Float:fVertical
		static red, green, blue
		static i

		g_iMessagePosition++

		if (g_iMessagePosition > 3) g_iMessagePosition = 0

		switch (g_iMessagePosition)
		{
		case 0:
			{
				red = 255
				green = 0
				blue = 0
				fVertical = 0.45
			}
		case 1:
			{
				red = 0
				green = 255
				blue = 0
				fVertical = 0.5
			}
		case 2:
			{
				red = 0
				green = 0
				blue = 255
				fVertical = 0.55
			}
		case 3:
			{
				red = 255
				green = 255
				blue = 0
				fVertical = 0.60
			}
		}
		
		i = 1
		while (g_maxplayers + 1 > i)
		{
			if (g_isconnected[i])
			{
				set_hudmessage(red, green, blue, 0.02, fVertical, 0, 6.00, 6.00, 0.50, 0.15, -1)
				ShowSyncHudMsg(i, g_MsgSync5[g_iMessagePosition], "%s :  %s", g_playerName[id], cMessage[1])
			}
			i++
		}

		return PLUGIN_HANDLED
	}

	/*if (equali(cMessage, "/nextmap", 0) || equali(cMessage, "nextmap", 0))
	{
		static cMap[32]
		get_cvar_string("amx_nextmap", cMap, 32)

		if (cMap[0]) client_print_color(id, print_team_grey, "^1Next map:^4 %s", cMap)
		else client_print_color(id, print_team_grey, "^1Next map:^4 [not yet voted on]")
	}
	else if (equali(cMessage, "/timeleft", 9) || equali(cMessage, "timeleft", 8))
	{
		static iTimeleft
		iTimeleft = get_timeleft()
		client_print_color(id, print_team_grey, "^1Timeleft: ^4%d:%02d", iTimeleft / 60, iTimeleft % 60)
	}*/
	else if (equali(cMessage, "/rank", 5) || equali(cMessage, "rank", 4)) ShowPlayerStatistics(id)
	else if (equali(cMessage, "/globaltop", 4) || equali(cMessage, "globaltop", 3)) ShowGlobalTop15(id)
	else if (equali(cMessage, "/rs", 3) || equali(cMessage, "rs", 2) || equali(cMessage, "/resetscore", 11) || equali(cMessage, "resetscore", 10))
	{
		cs_set_user_deaths(id, 0)
		set_user_frags(id, 0)

		cs_set_user_deaths(id, 0)
		set_user_frags(id, 0)

		client_print_color(0, print_team_grey, "%s ^3%s ^1reset his score to^3 0", CHAT_PREFIX, g_playerName[id])
	}
	else if (equali(cMessage, "/spec", 5) || equali(cMessage, "spec", 4) || equali(cMessage, "/spectate", 9) || equali(cMessage, "spectate", 8))
	{
		if (CheckBit(g_playerClass[id], CLASS_HUMAN))
		{
			if (cs_get_user_team(id) != CS_TEAM_SPECTATOR)
			{
			    cs_set_user_team(id, CS_TEAM_SPECTATOR)
			    user_kill(id)
			}
			else client_print_color(id, print_team_grey, "%s You are already a spectator", CHAT_PREFIX);
		}
	}
	else if (equali(cMessage, "/back", 5) || equali(cMessage, "back", 4))
	{
		if (cs_get_user_team(id) == CS_TEAM_SPECTATOR)
	    {
	    	if (!g_modestarted)
	    	{
	    		cs_set_user_team(id, CS_TEAM_CT)
	    		ExecuteHamB(Ham_CS_RoundRespawn, id)
	    	}
	    	else cs_set_user_team(id, CS_TEAM_CT)  
	    }
		else client_print_color(id, print_team_grey, "%s You are not a spectator", CHAT_PREFIX)
	}
	else if (equali(cMessage, "/donate", 7) || equali(cMessage, "donate", 6))
	{
		static ammo
		static target
		static cAmmo[5]
		static cTarget[32]
		static cDummy[15]
		parse(cMessage, cDummy, 14, cTarget, 32, cAmmo, 5)
		target = cmd_target(id, cTarget, 0)
		ammo = str_to_num(cAmmo)

		if (!target)
		{
			client_print_color(id, print_team_grey,  "%s Invalid player or matching multiple targets!", CHAT_PREFIX)
			return PLUGIN_CONTINUE
		}
		if (ammo <= 0)
		{
			client_print_color(id, print_team_grey,  "%s Invalid value of packs to send!", CHAT_PREFIX)
			return PLUGIN_CONTINUE
		}
		if (g_ammopacks[id] < ammo)
		{
			client_print_color(id, print_team_grey,  "%s You are trying to send too many packs!", CHAT_PREFIX)
			return PLUGIN_CONTINUE
		}
		if (target == id)
		{
			client_print_color(id, print_team_grey,  "%s You cannot send packs to yourself!", CHAT_PREFIX)
			return PLUGIN_CONTINUE
		}
		
		g_ammopacks[target] += ammo
		g_ammopacks[id] -= ammo
		client_print_color(0, print_team_grey, "%s^3 %s^1 gave^4 %s packs^1 to^3 %s", CHAT_PREFIX, g_playerName[id], AddCommas(ammo), g_playerName[target])
		return PLUGIN_CONTINUE
	}
	else if (equali(cMessage, "/mode", 5) || equali(cMessage, "mode", 4))
	{
		new buffer[40]
		if (g_newround) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Not yet started...")
		else if (g_endround) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Just ended...")
		else if (CheckBit(g_currentmode, MODE_INFECTION)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Infection")
		else if (CheckBit(g_currentmode, MODE_MULTI_INFECTION)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Multi-infection")
		else if (CheckBit(g_currentmode, MODE_SWARM)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Swarm")
		else if (CheckBit(g_currentmode, MODE_PLAGUE)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Plague")
		else if (CheckBit(g_currentmode, MODE_SYNAPSIS)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Synapsis")
		else if (CheckBit(g_currentmode, MODE_SURVIVOR_VS_NEMESIS)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Armageddon")
		else if (CheckBit(g_currentmode, MODE_SURVIVOR_VS_ASSASIN)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Survivor vs Assasin")
		else if (CheckBit(g_currentmode, MODE_SNIPER_VS_ASSASIN)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Apocalypse")
		else if (CheckBit(g_currentmode, MODE_SNIPER_VS_NEMESIS)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Devil")
		else if (CheckBit(g_currentmode, MODE_BOMBARDIER_VS_GRENADIER)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Bombardier vs Grenadier")
		else if (CheckBit(g_currentmode, MODE_NIGHTMARE)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Nightmare")
		else if (CheckBit(g_currentmode, MODE_ASSASIN)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Assasin")
		else if (CheckBit(g_currentmode, MODE_NEMESIS)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Nemesis")
		else if (CheckBit(g_currentmode, MODE_BOMBARDIER)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Bombardier")
		else if (CheckBit(g_currentmode, MODE_SURVIVOR)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Survivor")
		else if (CheckBit(g_currentmode, MODE_SNIPER)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Sniper")
		else if (CheckBit(g_currentmode, MODE_SAMURAI)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Samurai")
		else if (CheckBit(g_currentmode, MODE_GRENADIER)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Grenadier")
		else if (CheckBit(g_currentmode, MODE_REVENANT)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Revenant")
		else if (CheckBit(g_currentmode, MODE_TERMINATOR)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Terminator")

		client_print_color(id, print_team_grey, "%s %s", CHAT_PREFIX, buffer)
	}
	else if (equali(cMessage, "class", 5))
	{
		if (CheckBit(g_playerClass[id], CLASS_HUMAN)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Human")
		else if (CheckBit(g_playerClass[id], CLASS_ZOMBIE)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Zombie")
		else if (CheckBit(g_playerClass[id], CLASS_NEMESIS)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Nemesis")
		else if (CheckBit(g_playerClass[id], CLASS_ASSASIN)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Assasin")
		else if (CheckBit(g_playerClass[id], CLASS_BOMBARDIER)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Bombardier")
		else if (CheckBit(g_playerClass[id], CLASS_SURVIVOR)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Survivor")
		else if (CheckBit(g_playerClass[id], CLASS_SNIPER)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Sniper")
		else if (CheckBit(g_playerClass[id], CLASS_SAMURAI)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Samurai")
		else if (CheckBit(g_playerClass[id], CLASS_GRENADIER)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Grenadier")
		else if (CheckBit(g_playerClass[id], CLASS_TERMINATOR)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Terminator")
		else if (CheckBit(g_playerClass[id], CLASS_REVENANT)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Revenant")
		else if (CheckBit(g_playerClass[id], CLASS_TRYDER)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Tryder")
	}
	else if (equali(cMessage, "team", 4))
	{
		if (CheckBit(g_playerTeam[id], TEAM_HUMAN)) client_print_color(id, print_team_grey, "^4Your team: ^3Human")
		else client_print_color(id, print_team_grey, "^4Your team: ^3Zombie")
	}
	else if (equali(cMessage, "flags", 5)) client_print_color(id, print_team_grey, "Your ^4VIP ^1flags are: ^3%s", g_vipInfo[id][_vFlags])
	else if (equali(cMessage, "hash", 4)) client_print_color(id, print_team_grey, "Your ^4Name ^1+ ^4Steam ID ^3Hash ^1is : ^3%s", g_playerHash[id])
	else if (equali(cMessage, "id", 4)) client_print_color(id, print_team_grey, "Your ^4Steam ID ^3is : ^3%s", g_playerSteamID[id])
	else if (equali(cMessage, "/help", 5) || equali(cMessage, "help", 4))
		show_motd(id, "http://perfectzm0.000webhostapp.com/main.html", "Welcome")
	else if (equali(cMessage, "/commands", 9) || equali(cMessage, "commands", 8))
		show_motd(id, "http://perfectzm0.000webhostapp.com/commands.html", "Commands")
	else if (equali(cMessage, "/gold", 5) || equali(cMessage, "/vip", 4) || equali(cMessage, "/gold", 5))
		show_motd(id, "http://perfectzm0.000webhostapp.com/privileges.html", "Privileges")
	else if (equali(cMessage, "/rules", 6) || equali(cMessage, "rules", 5))
		show_motd(id, "http://perfectzm0.000webhostapp.com/rules.html", "Welcome")

	return PLUGIN_CONTINUE
}

// Say Team function
public Client_SayTeam(id)
{
	if (!g_isconnected[id]) return PLUGIN_HANDLED
	
	static Float:fGameTime; fGameTime = get_gametime()

	if (g_fGagTime[id] > fGameTime) 
	{
		client_print_color(id, print_team_grey,  "%s You are gagged due to your bad behaviour, please wait until your time is up", CHAT_PREFIX)
		return PLUGIN_HANDLED
	}

	static cMessage[150]
	read_args(cMessage, 149)
	remove_quotes(cMessage)

	if (!cMessage[0] || strlen(cMessage) > 147)
		return PLUGIN_HANDLED
	
	if (cMessage[0] == '@')
	{
		if (g_admin[id])
		{
			static i; i = 1
			while (i < g_maxplayers + 1)
			{
				if (g_isconnected[i] && g_admin[i])
				{
					client_print_color(i, print_team_grey, "^4[ADMINS]^3 %s^1 :  %s", g_playerName[id], cMessage[1])
				}
				i++
			}
		}
		else client_print_color(0, print_team_grey, "^3[PLAYER] %s^1 :  %s", g_playerName[id], cMessage[1])	

		return PLUGIN_HANDLED
	}

	if (equali(cMessage, "/rank", 5) || equali(cMessage, "rank", 4)) ShowPlayerStatistics(id)
	else if (equali(cMessage, "/globaltop", 4) || equali(cMessage, "globaltop", 3)) ShowGlobalTop15(id)
	else if (equali(cMessage, "/rs", 3) || equali(cMessage, "rs", 2) || equali(cMessage, "/resetscore", 11) || equali(cMessage, "resetscore", 10))
	{
		cs_set_user_deaths(id, 0)
		set_user_frags(id, 0)

		cs_set_user_deaths(id, 0)
		set_user_frags(id, 0)

		client_print_color(0, print_team_grey, "%s ^3%s ^1reset his score to 0", CHAT_PREFIX, g_playerName[id])
	}
	else if (equali(cMessage, "/spec", 5) || equali(cMessage, "spec", 4) || equali(cMessage, "/spectate", 9) || equali(cMessage, "spectate", 8))
	{
		if (CheckBit(g_playerClass[id], CLASS_HUMAN))
		{
			if(cs_get_user_team(id) != CS_TEAM_SPECTATOR)
			{
			    cs_set_user_team(id, CS_TEAM_SPECTATOR)
			    user_kill(id)
			}
			else client_print_color(id, print_team_grey, "%s You are already a spectator", CHAT_PREFIX)
		}
	}
	else if (equali(cMessage, "/back", 5) || equali(cMessage, "back", 4))
	{
		if(cs_get_user_team(id) == CS_TEAM_SPECTATOR)
	    {
	    	if (!g_modestarted)
	    	{
	    		cs_set_user_team(id, CS_TEAM_CT)
	    		ExecuteHamB(Ham_CS_RoundRespawn, id)
	    	}
	    	else cs_set_user_team(id, CS_TEAM_CT)
	    }
		else client_print_color(id, print_team_grey, "%s You are not a spectator", CHAT_PREFIX)
	}
	else if (equali(cMessage, "/donate", 7) || equali(cMessage, "donate", 6))
	{
		static ammo
		static target
		static cAmmo[5]
		static cTarget[32]
		static cDummy[15]

		parse(cMessage, cDummy, 14, cTarget, 32, cAmmo, 5)
		target = cmd_target(id, cTarget, 0)

		if (equali(cAmmo, "all", 3) || equali(cAmmo, "ALL", 3)) ammo = g_ammopacks[id]
		else ammo = str_to_num(cAmmo)

		if (!target)
		{
			client_print_color(id, print_team_grey,  "%s Invalid player or matching multiple targets!", CHAT_PREFIX)
			return PLUGIN_CONTINUE
		}
		if (ammo <= 0)
		{
			client_print_color(id, print_team_grey,  "%s Invalid value of packs to send!", CHAT_PREFIX)
			return PLUGIN_CONTINUE
		}
		if (g_ammopacks[id] < ammo)
		{
			client_print_color(id, print_team_grey,  "%s You are trying to send too many packs!", CHAT_PREFIX)
			return PLUGIN_CONTINUE
		}
		if (target == id)
		{
			client_print_color(id, print_team_grey,  "%s You cannot send packs to yourself!", CHAT_PREFIX)
			return PLUGIN_CONTINUE
		}
		
		g_ammopacks[target] += ammo
		g_ammopacks[id] -= ammo
		client_print_color(0, print_team_grey, "%s^3 %s^1 gave^4 %s packs^1 to^3 %s", CHAT_PREFIX, g_playerName[id], AddCommas(ammo), g_playerName[target])

		return PLUGIN_CONTINUE
	}
	else if (equali(cMessage, "/mode", 5) || equali(cMessage, "mode", 4))
	{
		new buffer[40]
		if (g_newround) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Not yet started...")
		else if (g_endround) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Just ended...")
		else if (CheckBit(g_currentmode, MODE_INFECTION)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Infection")
		else if (CheckBit(g_currentmode, MODE_MULTI_INFECTION)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Multi-infection")
		else if (CheckBit(g_currentmode, MODE_SWARM)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Swarm")
		else if (CheckBit(g_currentmode, MODE_PLAGUE)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Plague")
		else if (CheckBit(g_currentmode, MODE_SYNAPSIS)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Synapsis")
		else if (CheckBit(g_currentmode, MODE_SURVIVOR_VS_NEMESIS)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Armageddon")
		else if (CheckBit(g_currentmode, MODE_SURVIVOR_VS_ASSASIN)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Survivor vs Assasin")
		else if (CheckBit(g_currentmode, MODE_SNIPER_VS_ASSASIN)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Apocalypse")
		else if (CheckBit(g_currentmode, MODE_SNIPER_VS_NEMESIS)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Devil")
		else if (CheckBit(g_currentmode, MODE_BOMBARDIER_VS_GRENADIER)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Bombardier vs Grenadier")
		else if (CheckBit(g_currentmode, MODE_NIGHTMARE)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Nightmare")
		else if (CheckBit(g_currentmode, MODE_ASSASIN)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Assasin")
		else if (CheckBit(g_currentmode, MODE_NEMESIS)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Nemesis")
		else if (CheckBit(g_currentmode, MODE_BOMBARDIER)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Bombardier")
		else if (CheckBit(g_currentmode, MODE_SURVIVOR)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Survivor")
		else if (CheckBit(g_currentmode, MODE_SNIPER)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Sniper")
		else if (CheckBit(g_currentmode, MODE_SAMURAI)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Samurai")
		else if (CheckBit(g_currentmode, MODE_GRENADIER)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Grenadier")
		else if (CheckBit(g_currentmode, MODE_REVENANT)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Revenant")
		else if (CheckBit(g_currentmode, MODE_TERMINATOR)) formatex(buffer, charsmax(buffer), "^1Current mode^4: ^3Terminator")

		client_print_color(id, print_team_grey, "%s %s", CHAT_PREFIX, buffer)
	}
	else if (equali(cMessage, "class", 5))
	{
		if (CheckBit(g_playerClass[id], CLASS_HUMAN)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Human")
		else if (CheckBit(g_playerClass[id], CLASS_ZOMBIE)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Zombie")
		else if (CheckBit(g_playerClass[id], CLASS_NEMESIS)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Nemesis")
		else if (CheckBit(g_playerClass[id], CLASS_ASSASIN)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Assasin")
		else if (CheckBit(g_playerClass[id], CLASS_BOMBARDIER)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Bombardier")
		else if (CheckBit(g_playerClass[id], CLASS_SURVIVOR)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Survivor")
		else if (CheckBit(g_playerClass[id], CLASS_SNIPER)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Sniper")
		else if (CheckBit(g_playerClass[id], CLASS_SAMURAI)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Samurai")
		else if (CheckBit(g_playerClass[id], CLASS_GRENADIER)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Grenadier")
		else if (CheckBit(g_playerClass[id], CLASS_TERMINATOR)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Terminator")
		else if (CheckBit(g_playerClass[id], CLASS_REVENANT)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Revenant")
		else if (CheckBit(g_playerClass[id], CLASS_TRYDER)) client_print_color(id, print_team_grey, "^4Your class^1: ^3Tryder")
	}
	else if (equali(cMessage, "team", 4))
	{
		if (CheckBit(g_playerTeam[id], TEAM_HUMAN)) client_print_color(id, print_team_grey, "^4Your team: ^3Human")
		else client_print_color(id, print_team_grey, "^4Your team: ^3Zombie")
	}
	else if (equali(cMessage, "hash", 4)) client_print_color(id, print_team_grey, "Your ^4Name ^1+ ^4Steam ID ^3Hash ^1is : ^3%s", g_playerHash[id])
	else if (equali(cMessage, "id", 4)) client_print_color(id, print_team_grey, "Your ^4Steam ID ^3is : ^3%s", g_playerSteamID[id])
	else if (equali(cMessage, "/help", 5) || equali(cMessage, "help", 4))
		show_motd(id, "http://perfectzm0.000webhostapp.com/main.html", "Welcome")
	else if (equali(cMessage, "/commands", 9) || equali(cMessage, "commands", 8))
		show_motd(id, "http://perfectzm0.000webhostapp.com/commands.html", "Commands")
	else if (equali(cMessage, "/gold", 5) || equali(cMessage, "/vip", 4) || equali(cMessage, "/gold", 5))
		show_motd(id, "http://perfectzm0.000webhostapp.com/privileges.html", "Privileges")
	else if (equali(cMessage, "/rules", 6) || equali(cMessage, "rules", 5))
		show_motd(id, "http://perfectzm0.000webhostapp.com/rules.html", "Welcome")

	return PLUGIN_CONTINUE
}

public Admin_menu(id)
{
	if (g_admin[id]) ShowMainAdminMenu(id)
	else return PLUGIN_HANDLED

	return PLUGIN_HANDLED
}

/*================================================================================
	[Menus]
=================================================================================*/
// Buy Menu 1
public show_menu_buy1(taskid)
{
	// Get player's id.
	static id
	if (taskid > g_maxplayers) id = taskid - TASK_SPAWN
	else id = taskid
	
	// Zombies, Survivors and Snipers get no guns.
	if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_HUMAN))
	{
		static text[2][32], size; size = 31
		new g_menu = menu_create("\yPrimary Weapons", "PrimaryHandler", 0)
		
		for (new i = 0; i < ArraySize(g_weapon_name[0]); i++)
		{
			num_to_str(ArrayGetCell(g_weapon_ids[0], i), text[0], size)
			ArrayGetString(g_full_weapon_names, ArrayGetCell(g_weapon_ids[0], i), text[1], size)
			menu_additem(g_menu, text[1], text[0], 0)
		}

		menu_display(id, g_menu)
	}
	
	// Bots get weapons randomly.
	if (g_isbot[id])
	{
		set_weapon(id, CSW_KNIFE)
		set_weapon(id, CSW_AK47)
	}
}

// Buy menu 2
public show_menu_buy2(id)
{
	// Show mwnu only to Human Class
	if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_HUMAN))
	{
		static text[2][32], size; size = 31
		new g_menu = menu_create("\ySecondary Weapons", "SecondaryHandler", 0)

		for (new i = 0; i < ArraySize(g_weapon_name[1]); i++)
		{
			num_to_str(ArrayGetCell(g_weapon_ids[1], i), text[0], size)
			ArrayGetString(g_full_weapon_names, ArrayGetCell(g_weapon_ids[1], i), text[1], size)
			menu_additem(g_menu, text[1], text[0], 0)
		}

		menu_display(id, g_menu)
	}
}

public ShowMainAdminMenu(id)
{
	new g_mainAdminMenu = menu_create("\yAdmin Menu", "MainAdminMenuHandler", 0)
    
	menu_additem(g_mainAdminMenu, "Respawn Players", "0", 0, g_mainAdminMenuCallback)
	menu_additem(g_mainAdminMenu, "Make Human Class", "1", 0, g_mainAdminMenuCallback)
	menu_additem(g_mainAdminMenu, "Make Zombie Class", "2", 0, g_mainAdminMenuCallback)
	menu_additem(g_mainAdminMenu, "Start Normal Rounds", "3", 0, g_mainAdminMenuCallback)
	menu_additem(g_mainAdminMenu, "Start Special Rounds", "4", 0, g_mainAdminMenuCallback)
	menu_additem(g_mainAdminMenu, "Switch off Zombie Queen \y( \rnote this will restart map \y)", "5", 0, g_mainAdminMenuCallback)

	menu_display(id, g_mainAdminMenu, 0)
}

public ShowMakeHumanClassMenu(id)
{
	new g_makeHumanClassMenu = menu_create("\yMake Human Class", "MakeHumanClassMenuHandler", 0)

	menu_additem(g_makeHumanClassMenu, "Make Human", "0", 0, g_makeHumanClassMenuCallback)
	menu_additem(g_makeHumanClassMenu, "Make Survivor", "1", 0, g_makeHumanClassMenuCallback)
	menu_additem(g_makeHumanClassMenu, "Make Sniper", "2", 0, g_makeHumanClassMenuCallback)
	menu_additem(g_makeHumanClassMenu, "Make Samurai", "3", 0, g_makeHumanClassMenuCallback)
	menu_additem(g_makeHumanClassMenu, "Make Terminator", "4", 0, g_makeHumanClassMenuCallback)
	menu_additem(g_makeHumanClassMenu, "Make Grenadier", "5", 0, g_makeHumanClassMenuCallback)

	menu_display(id, g_makeHumanClassMenu, 0)
}

public ShowMakeZombieClassMenu(id)
{
    new g_makeZombieClassMenu = menu_create("\yMake Zombie Class", "MakeZombieClassMenuHandler", 0)

    menu_additem(g_makeZombieClassMenu, "Make Zombie", "0", 0, g_makeZombieClassMenuCallback)
    menu_additem(g_makeZombieClassMenu, "Make Assasin", "1", 0, g_makeZombieClassMenuCallback)
    menu_additem(g_makeZombieClassMenu, "Make Nemesis", "2", 0, g_makeZombieClassMenuCallback)
    menu_additem(g_makeZombieClassMenu, "Make Bombardier", "3", 0, g_makeZombieClassMenuCallback)
    menu_additem(g_makeZombieClassMenu, "Make Revenant", "4", 0, g_makeZombieClassMenuCallback)
    menu_additem(g_makeZombieClassMenu, "Make Dragon", "5", 0, g_makeZombieClassMenuCallback)

    menu_display(id, g_makeZombieClassMenu, 0)
}

public ShowStartNormalModesMenu(id)
{
    new g_startNormalModesMenu = menu_create("\yStart Normal Modes", "StartNormalModesMenuHandler", 0)

    menu_additem(g_startNormalModesMenu, "Infection Round", "0", 0, g_startNormalModesCallback)
    menu_additem(g_startNormalModesMenu, "Multiple infection", "1", 0, g_startNormalModesCallback)
    menu_additem(g_startNormalModesMenu, "Swarm", "2", 0, g_startNormalModesCallback)
    menu_additem(g_startNormalModesMenu, "Plague", "3", 0, g_startNormalModesCallback)
    menu_additem(g_startNormalModesMenu, "Synapsis", "4", 0, g_startNormalModesCallback)

    menu_display(id, g_startNormalModesMenu, 0)
}

public ShowStartSpecialModesMenu(id)
{
    new g_startSpecialModesMenu = menu_create("\yStart Special Modes", "StartSpecialModesMenuHandler", 0)
    menu_additem(g_startSpecialModesMenu, "Survivor vs Nemesis \y( \rArmageddon \y)", "0", 0, g_startSpecialModesCallback)
    menu_additem(g_startSpecialModesMenu, "Survivor vs Assasin", "1", 0, g_startSpecialModesCallback)
    menu_additem(g_startSpecialModesMenu, "Sniper vs Nemesis", "2", 0, g_startSpecialModesCallback)
    menu_additem(g_startSpecialModesMenu, "Sniper vs Assasin", "3", 0, g_startSpecialModesCallback)
    menu_additem(g_startSpecialModesMenu, "Bombardier vs Grenadier", "4", 0, g_startSpecialModesCallback)
    menu_additem(g_startSpecialModesMenu, "Nightmare", "5", 0, g_startSpecialModesCallback)

    menu_display(id, g_startSpecialModesMenu, 0)
}

public ShowPlayersMenu(id)
{
    static buffer[64]

    switch (ADMIN_MENU_ACTION)
    {
        case ACTION_MAKE_HUMAN: formatex(buffer, charsmax(buffer), "\yMake Human")
        case ACTION_MAKE_SURVIVOR: formatex(buffer, charsmax(buffer), "\yMake Survivor")
        case ACTION_MAKE_SNIPER: formatex(buffer, charsmax(buffer), "\yMake Sniper")
        case ACTION_MAKE_SAMURAI: formatex(buffer, charsmax(buffer), "\yMake Samurai")
        case ACTION_MAKE_GRENADIER: formatex(buffer, charsmax(buffer), "\yMake Grenadier")
        case ACTION_MAKE_TERMINATOR: formatex(buffer, charsmax(buffer), "\yMake Terminator")
        case ACTION_MAKE_ZOMBIE: formatex(buffer, charsmax(buffer), "\yMake Zombie")
        case ACTION_MAKE_ASSASIN: formatex(buffer, charsmax(buffer), "\yMake Assasin")
        case ACTION_MAKE_NEMESIS: formatex(buffer, charsmax(buffer), "\yMake Nemesis")
        case ACTION_MAKE_BOMBARDIER: formatex(buffer, charsmax(buffer), "\yMake Bombardier")
        case ACTION_MAKE_REVENANT: formatex(buffer, charsmax(buffer), "\yMake Revenant")
        case ACTION_RESPAWN_PLAYER: formatex(buffer, charsmax(buffer), "\yRespawn Players")
    }

    new menu = menu_create(buffer, "PlayersMenuHandler", 0)
    
    // Variables for storing infos
    new players[32], pnum, tempid
    new userid[32], szString[64]

    //Fill players with available players
    get_players_ex(players, pnum)

    for (new i = 0; i < pnum; i++)
    {
        // Save a tempid so we do not re-index
        tempid = players[i]

        // Get the players name and class
        formatex(szString, charsmax(szString), "%s \y[ \r%s \y]", g_playerName[tempid], g_classString[tempid])
        
        // We will use the data parameter to send the userid, so we can identify which player was selected in the handler
        formatex(userid, charsmax(userid), "%d", get_user_userid(tempid))

        // Add the item for this player
        menu_additem(menu, szString, userid, 0, g_playersMenuCallback)
    }

    // We now have all players in the menu, lets display the menu
    menu_display(id, menu, 0)
}

public ShowPointsShopWeaponsMenu(id)
{
    // Check if there are no items
	if (!g_pointsShopTotalWeapons)
	{
		client_print_color(id, print_team_grey, "%s There are no ^3weapons ^1available right now", CHAT_PREFIX)
		return PLUGIN_HANDLED
    }

	// Create menu
	new menu = menu_create("\yPremium Wepons", "PointsShopWeaponsMenuHandler")

	// Used to display item in the menu
	new itemData[pointsShopDataStructure]
	new item[64]

	// Used for array index to menu
	new data[3]

	// Loop through each item
	for (new i = 0; i < g_pointsShopTotalWeapons; i++)
	{
		// Get item data from array
		ArrayGetArray(g_pointsShopWeapons, i, itemData)

		// Format item for menu
		formatex(item, charsmax(item), "%s \r[ %s points ]", itemData[ItemName], AddCommas(itemData[ItemCost]))

		// Pass array index to menu to find information about it later
		num_to_str(i, data, charsmax(data))

		// Add item to menu
		menu_additem(menu, item, data)
	}

	// Display menu to player
	menu_display(id, menu, 0)

	return PLUGIN_CONTINUE
}

/*================================================================================
	[Menu Handlers]
=================================================================================*/

// Buy Menu 1
public PrimaryHandler(id, menu, item)
{
	if (item == MENU_EXIT) return PLUGIN_HANDLED

	new data[32]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)
	
	// Zombies, Survivors and Snipers get no guns.
	if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_HUMAN))
	{
		// Drop previous weapons
		drop_weapons(id, 1)

		set_weapon(id, choice, 10000)

		show_menu_buy2(id)
	}
	
	return PLUGIN_HANDLED
}

// Buy Menu 2
public SecondaryHandler(id, menu, item)
{
	if (item == MENU_EXIT) return PLUGIN_HANDLED

	new data[32]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)
	
	// Zombies, Survivors and Snipers get no guns.
	if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_HUMAN))
	{
		// Drop Previous Weapons
		drop_weapons(id, 2)
		g_canbuy[id] = false
		
		// Set weapon and ammo
		set_weapon(id, choice, 10000)

		// Set grenades
		set_weapon(id, CSW_HEGRENADE, 1)
		set_weapon(id, CSW_FLASHBANG, 1)
		set_weapon(id, CSW_SMOKEGRENADE, 1)
	}

	return PLUGIN_HANDLED
}

public MainAdminMenuHandler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

	switch (choice)
	{
		case 0: { ADMIN_MENU_ACTION = ACTION_RESPAWN_PLAYER; PL_MENU_BACK_ACTION = MENU_BACK_RESPAWN_PLAYERS; ShowPlayersMenu(id); }
		case 1: { ShowMakeHumanClassMenu(id); }
		case 2: { ShowMakeZombieClassMenu(id); }
		case 3: { ShowStartNormalModesMenu(id); }
		case 4: { ShowStartSpecialModesMenu(id); }
		case 5: { client_print_color(id, print_team_grey, "^3You have access to this command"); return PLUGIN_HANDLED; }
	}

	return PLUGIN_CONTINUE
}

public MakeHumanClassMenuHandler(id, menu, item)
{
	if (item == MENU_EXIT) { menu_destroy(menu); ShowMainAdminMenu(id); return PLUGIN_HANDLED; }

	new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

	switch (choice)
	{
		case MAKE_HUMAN: { ADMIN_MENU_ACTION = ACTION_MAKE_HUMAN; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_HUMAN_CLASS; ShowPlayersMenu(id); }
		case MAKE_SURVIVOR: { ADMIN_MENU_ACTION = ACTION_MAKE_SURVIVOR; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_HUMAN_CLASS; ShowPlayersMenu(id); }
		case MAKE_SNIPER: { ADMIN_MENU_ACTION = ACTION_MAKE_SNIPER; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_HUMAN_CLASS; ShowPlayersMenu(id); }
		case MAKE_SAMURAI: { ADMIN_MENU_ACTION = ACTION_MAKE_SAMURAI; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_HUMAN_CLASS; ShowPlayersMenu(id); }
		case MAKE_TERMINATOR: { ADMIN_MENU_ACTION = ACTION_MAKE_TERMINATOR; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_HUMAN_CLASS; ShowPlayersMenu(id); }
		case MAKE_GRENADIER: { ADMIN_MENU_ACTION = ACTION_MAKE_GRENADIER; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_HUMAN_CLASS; ShowPlayersMenu(id); }
	}

	return PLUGIN_CONTINUE
}

public MakeZombieClassMenuHandler(id, menu, item)
{
    if (item == MENU_EXIT) { menu_destroy(menu); ShowMainAdminMenu(id); return PLUGIN_HANDLED; }

    new data[6]

    menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
    new choice = str_to_num(data)

    switch (choice)
    {
        case MAKE_ZOMBIE: { ADMIN_MENU_ACTION = ACTION_MAKE_ZOMBIE; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_ZOMBIE_CLASS; ShowPlayersMenu(id); }
        case MAKE_ASSASIN: { ADMIN_MENU_ACTION = ACTION_MAKE_ASSASIN; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_ZOMBIE_CLASS; ShowPlayersMenu(id); }
        case MAKE_NEMESIS: { ADMIN_MENU_ACTION = ACTION_MAKE_NEMESIS; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_ZOMBIE_CLASS; ShowPlayersMenu(id); }
        case MAKE_BOMBARDIER: { ADMIN_MENU_ACTION = ACTION_MAKE_BOMBARDIER; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_ZOMBIE_CLASS; ShowPlayersMenu(id); }
        case MAKE_REVENANT: { ADMIN_MENU_ACTION = ACTION_MAKE_REVENANT; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_ZOMBIE_CLASS; ShowPlayersMenu(id); }
        case MAKE_DRAGON: { return PLUGIN_HANDLED; }
    }

    return PLUGIN_CONTINUE
}

public StartNormalModesMenuHandler(id, menu, item)
{
	if (item == MENU_EXIT) { menu_destroy(menu); ShowMainAdminMenu(id); return PLUGIN_HANDLED; }

	new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

	switch (choice)
	{
		case START_INFECTION: 
		{
			if (AdminHasFlag(id, g_accessFlag[ACCESS_START_MULTI_INFECTION]))
			{
				if (!g_modestarted)
				{
					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_INFECTION, fnGetRandomAlive(random_num(1, fnGetAlive())))

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Infection ^1round!", CHAT_PREFIX, g_playerName[id])

					// Log to file
					LogToFile(LOG_MODE_MULTIPLE_INFECTION, id)

					// Execute our forward
					ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_INFECTION, id)
				} 
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
		}
	case START_MULTIPLE_INFECTION: 
		{
			if (AdminHasFlag(id, g_accessFlag[ACCESS_START_MULTI_INFECTION]))
			{
				if (allowed_multi())
				{
					// Start Multi-infection Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_MULTI_INFECTION, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Multiple-infection ^1round!", CHAT_PREFIX, g_playerName[id])

					// Log to file
					LogToFile(LOG_MODE_MULTIPLE_INFECTION, id)

					// Execute our forward
					ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_MULTI_INFECTION, id)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
		}
	case START_SWARM: 
		{
			if (AdminHasFlag(id, g_accessFlag[ACCESS_START_SWARM]))
			{
				if (allowed_swarm())
				{
					// Start Swarm Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_SWARM, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Swarm ^1round!", CHAT_PREFIX, g_playerName[id])

					// Log to file
					LogToFile(LOG_MODE_SWARM, id)

					// Execute our forward
					ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_SWARM, id)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
		}
        case START_PLAGUE: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_START_PLAGUE]))
			{
				if (allowed_plague())
				{
					// Start Plague Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_PLAGUE, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Plague ^1round!", CHAT_PREFIX, g_playerName[id])

					// Log to file
					LogToFile(LOG_MODE_PLAGUE, id)

					// Execute our forward
					ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_PLAGUE, id)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
		}
        case START_SYNAPSIS: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_START_SYNAPSIS]))
			{
				if (allowed_synapsis())
				{
					// Start Plague Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_SYNAPSIS, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Synapsis ^1round!", CHAT_PREFIX, g_playerName[id])

					// Log to file
					LogToFile(LOG_MODE_SYNAPSIS, id)

					// Execute our forward
					ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_SYNAPSIS, id)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
		}
    }

	return PLUGIN_CONTINUE
}

public StartSpecialModesMenuHandler(id, menu, item)
{
	if (item == MENU_EXIT) { menu_destroy(menu); ShowMainAdminMenu(id); return PLUGIN_HANDLED; }

	new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

	switch (choice)
    {
		case START_SURVIVOR_VS_NEMESIS: 
		{
			if (AdminHasFlag(id, g_accessFlag[ACCESS_START_SURVIVOR_VS_NEMESIS]))
			{
				if (allowed_armageddon())
				{
					// Start Armageddon Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_SURVIVOR_VS_NEMESIS, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Armageddon ^1round!", CHAT_PREFIX, g_playerName[id])

					// Log to file
					LogToFile(LOG_MODE_SURVIVOR_VS_NEMESIS, id)

					// Execute our forward
					ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_SURVIVOR_VS_NEMESIS, id)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
		}
		case START_SURVIVOR_VS_ASSASIN: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_START_SURVIVOR_VS_ASSASIN]))
			{
				if (allowed_survivor_vs_assasin())
				{
					// Start Survivor Vs Assasin Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_SURVIVOR_VS_ASSASIN, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Survivor vs Assasin ^1round!", CHAT_PREFIX, g_playerName[id])

					// Log to file
					LogToFile(LOG_MODE_SURVIVOR_VS_ASSASIN, id)

					// Execute our forward
					ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_SURVIVOR_VS_ASSASIN, id)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
		}
		case START_SNIPER_VS_NEMESIS: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_START_SNIPER_VS_NEMESIS]))
			{
				if (allowed_devil())
				{
					// Start Devil Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_SNIPER_VS_NEMESIS, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Sniper v Nemesis ^1round!", CHAT_PREFIX, g_playerName[id])

					// Log to file
					LogToFile(LOG_MODE_SNIPER_VS_NEMESIS, id)

					// Execute our forward
					ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_SNIPER_VS_NEMESIS, id)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
		}
        case START_SNIPER_VS_ASSASIN: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_START_SNIPER_VS_ASSASIN]))
			{
				if (allowed_apocalypse())
				{
					// Start Apocalypse Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_SNIPER_VS_ASSASIN, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Sniper vs Assassin ^1round!", CHAT_PREFIX, g_playerName[id])

					// Log to file
					LogToFile(LOG_MODE_SNIPER_VS_ASSASIN, id)

					// Execute our forward
					ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_SNIPER_VS_ASSASIN, id)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
		}
        case START_BOMBARDIER_VS_GRENADIER: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_START_BOMBARDIER_VS_GRENADIER]))
			{
				if (allowed_bombardier_vs_grenadier())
				{
					// Start Bombardier vs Grenadier Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_BOMBARDIER_VS_GRENADIER, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Bombardier vs Grenadier ^1round!", CHAT_PREFIX, g_playerName[id])

					// Log to file
					LogToFile(LOG_MODE_BOMBARDIER_VS_GRENADIER, id)

					// Execute our forward
					ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_BOMBARDIER_VS_GRENADIER, id)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
		}
		case START_NIGHTMARE: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_START_NIGHTMARE]))
			{
				if (allowed_nightmare())
				{
					// Start Nightmare Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(MODE_NIGHTMARE, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Nightmare ^1round!", CHAT_PREFIX, g_playerName[id])

					// Log to file
					LogToFile(LOG_MODE_NIGHTMARE, id)

					// Execute our forward
					ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_NIGHTMARE, id)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
		}
    }

	return PLUGIN_CONTINUE
}

public PlayersMenuHandler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        switch (PL_MENU_BACK_ACTION)
        {
            case MENU_BACK_MAKE_HUMAN_CLASS: { menu_destroy(menu); ShowMakeHumanClassMenu(id); return PLUGIN_HANDLED; }
            case MENU_BACK_MAKE_ZOMBIE_CLASS: { menu_destroy(menu); ShowMakeZombieClassMenu(id); return PLUGIN_HANDLED; }
            case MENU_BACK_RESPAWN_PLAYERS: { menu_destroy(menu); ShowMainAdminMenu(id); return PLUGIN_HANDLED; }
        }
    }

    new data[6]

    menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)

    new userid = str_to_num(data)
    new target = find_player("k", userid)

    switch (ADMIN_MENU_ACTION)
    {
        case ACTION_RESPAWN_PLAYER: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_RESPAWN_PLAYERS]))
			{
				if (allowed_respawn(target))
				{
					// Respawn him
					respawn_player_manually(target)

					// Print in chat
					if (id == target) client_print_color(0, print_team_grey, "%s Admin ^3%s ^1respawned himself^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
					else client_print_color(0, print_team_grey, "%s Admin ^3%s ^1respawned ^3%s^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])

					// Log to file
					LogToFile(LOG_RESPAWN_PLAYER, id, target)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)

			menu_destroy(menu)
			ShowPlayersMenu(id)
		}
        case ACTION_MAKE_HUMAN: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_HUMAN]))
			{
				if (allowed_human(target))
				{
					// Just cure
					MakeHuman(target)
	
					// Print in chat
					if (id == target) client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Human^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
					else client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1 a ^4Human^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])

					// Log to file
					LogToFile(LOG_MAKE_HUMAN, id, target)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)

			menu_destroy(menu)
			ShowPlayersMenu(id)
		}
        case ACTION_MAKE_SNIPER: 
		{
			if (AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_SNIPER]))
			{
				if (allowed_sniper(target))
				{
					// New round?
					if (g_newround)
					{
						// Set as first 
						remove_task(TASK_MAKEZOMBIE)
						start_mode(MODE_SNIPER, target)
					}
					else MakeHuman(target, CLASS_SNIPER) // Turn player into a Sniper 
					
					// Print in chat
					if (id == target) client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Sniper^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
					else client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Sniper^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])

					// Log to file
					LogToFile(LOG_MAKE_SNIPER, id, target)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)

			menu_destroy(menu)
			ShowPlayersMenu(id)
		}
        case ACTION_MAKE_SURVIVOR: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_SURVIVOR]))
			{
				if (allowed_survivor(target))
				{
					// New round?
					if (g_newround)
					{
						// Set as first 
						remove_task(TASK_MAKEZOMBIE)
						start_mode(MODE_SURVIVOR, target)
					}
					else MakeHuman(target, CLASS_SURVIVOR) // Turn player into a Survivor 
					
					// Print in chat
					if (id == target) client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himslef a ^4Survivor^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
					else client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Survivor^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])

					// Log to file
					LogToFile(LOG_MAKE_SURVIVOR, id, target)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)

			menu_destroy(menu)
			ShowPlayersMenu(id)
		}
        case ACTION_MAKE_SAMURAI: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_SAMURAI]))
			{
				if (allowed_samurai(target))
				{
					// New round?
					if (g_newround)
					{
						// Set as first 
						remove_task(TASK_MAKEZOMBIE)
						start_mode(MODE_SAMURAI, target)
					}
					else MakeHuman(target, CLASS_SAMURAI) // Turn player into a Samurai 
					
					// Print in chat
					if (id == target) client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Samurai^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
					else client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Samurai^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])

					// Log to file
					LogToFile(LOG_MAKE_SAMURAI, id, target)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)

			menu_destroy(menu)
			ShowPlayersMenu(id)
		}
		case ACTION_MAKE_GRENADIER: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_GRENADIER]))
			{
				if (allowed_grenadier(target))
				{
					// New round?
					if (g_newround)
					{
						// Set as first 
						remove_task(TASK_MAKEZOMBIE)
						start_mode(MODE_GRENADIER, target)
					}
					else MakeHuman(target, CLASS_GRENADIER) // Turn player into a Grenadier
					
					// Print in chat
					if (id == target) client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Grenadier^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
					else client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Grenadier^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])

					// Log to file
					LogToFile(LOG_MAKE_GRENADIER, id, target)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)

			menu_destroy(menu)
			ShowPlayersMenu(id)
		}
		case ACTION_MAKE_TERMINATOR: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_TERMINATOR]))
			{
				if (allowed_terminator(target))
				{
					// New round?
					if (g_newround)
					{
						// Set as first 
						remove_task(TASK_MAKEZOMBIE)
						start_mode(MODE_TERMINATOR, target)
					}
					else MakeHuman(target, CLASS_TERMINATOR) // Turn player into a Terminator
					
					// Print in chat
					if (id == target) client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Terminator^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
					else client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Terminator^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])

					// Log to file
					LogToFile(LOG_MAKE_TERMINATOR, id, target)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)

			menu_destroy(menu)
			ShowPlayersMenu(id)
		}
        case ACTION_MAKE_ZOMBIE: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_ZOMBIE]))
			{
				if (allowed_zombie(target))
				{
					// New round?
					if (g_newround)
					{
						// Set as first zombie
						remove_task(TASK_MAKEZOMBIE)
						start_mode(MODE_INFECTION, target)
					}
					else MakeZombie(target) // Just infect
	
					// Print in chat
					if (id == target) client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Zombie^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
					else client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1 a ^4Zombie^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])

					// Log to file
					LogToFile(LOG_MAKE_ZOMBIE, id, target)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)

			menu_destroy(menu)
			ShowPlayersMenu(id)
		}
        case ACTION_MAKE_ASSASIN: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_ASSASIN]))
			{
				if (allowed_assassin(target))
				{
					// New round?
					if (g_newround)
					{
						// Set as first Assassin
						remove_task(TASK_MAKEZOMBIE)
						start_mode(MODE_ASSASIN, target)
					}
					else MakeZombie(target, CLASS_ASSASIN)// Turn player into a Nemesis

					// Print in chat
					if (id == target) client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Assassin^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
					else client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Assassin^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])

					// Log to file
					LogToFile(LOG_MAKE_ASSASIN, id, target)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)

			menu_destroy(menu)
			ShowPlayersMenu(id) 
		}
        case ACTION_MAKE_NEMESIS: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_NEMESIS]))
			{
				if (allowed_nemesis(target))
				{
					// New round?
					if (g_newround)
					{
						// Set as first nemesis
						remove_task(TASK_MAKEZOMBIE)
						start_mode(MODE_NEMESIS, target)
					}
					else MakeZombie(target, CLASS_NEMESIS) // Turn player into a Nemesis
					
					// Print in chat
					if (id == target) client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Nemesis^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
					else client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1 a ^4Nemesis^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
					

					// Log to file
					LogToFile(LOG_MAKE_NEMESIS, id, target)
				}
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)

			menu_destroy(menu)
			ShowPlayersMenu(id)
		}
        case ACTION_MAKE_BOMBARDIER: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_BOMBARDIER]))
			{
				if (allowed_bombardier(target))
				{
					// New round?
					if (g_newround)
					{
						// Set as first nemesis
						remove_task(TASK_MAKEZOMBIE)
						start_mode(MODE_BOMBARDIER, target)
					}
					else MakeZombie(target, CLASS_BOMBARDIER) // Turn player into a Bombardier 
					
					// Print in chat
					if (id == target) client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Bombardier^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
					else client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Bombardier^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])

					// Log to file
					LogToFile(LOG_MAKE_BOMBARDIER, id, target)
				} 
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)

			menu_destroy(menu)
			ShowPlayersMenu(id)
		}
		case ACTION_MAKE_REVENANT: 
		{ 
			if (AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_REVENANT]))
			{
				if (allowed_revenant(target))
				{
					// New round?
					if (g_newround)
					{
						// Set as first revenant
						remove_task(TASK_MAKEZOMBIE)
						start_mode(MODE_REVENANT, target)
					}
					else MakeZombie(target, CLASS_REVENANT) // Turn player into a Revenant
					
					// Print in chat
					if (id == target) client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Revenant^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
					else client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Revenant^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])

					// Log to file
					LogToFile(LOG_MAKE_REVENANT, id, target)
				} 
				else client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)

			menu_destroy(menu)
			ShowPlayersMenu(id)
		}
    }

    return PLUGIN_CONTINUE
}

public PointsShopWeaponsMenuHandler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new data[3]
	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)

	// Get item index from menu
	new itemIndex = str_to_num(data)

	// Get item data from array
	new itemData[pointsShopDataStructure]
	ArrayGetArray(g_pointsShopWeapons, itemIndex, itemData)

	// Check if player's points is less then the item's cost // If not then set the item
	if (g_points[id] < itemData[ItemCost])
	{
		// notify player
		client_print_color(id, print_team_grey, "%s You dont have enough ^3points ^1to buy this weapon...", CHAT_PREFIX)
		return PLUGIN_HANDLED
	}
	else
    {
		// Get player's points and subtract the cost
		g_points[id] -= itemData[ItemCost]
		MySQL_UPDATE_DATABASE(id)

		switch (itemIndex)
		{
			case 0:
			{
				g_goldenweapons[id] = true

				if (!user_has_weapon(id, CSW_AK47)) set_weapon(id, CSW_AK47, 10000)
				if (!user_has_weapon(id, CSW_M4A1)) set_weapon(id, CSW_M4A1, 10000)
				if (!user_has_weapon(id, CSW_XM1014)) set_weapon(id, CSW_XM1014, 10000)
				if (!user_has_weapon(id, CSW_DEAGLE)) set_weapon(id, CSW_DEAGLE, 10000)

				switch (random_num(0, 2))
				{		
					case 0: { client_cmd(id, "weapon_ak47"); set_goldenak47(id); }
					case 1: { client_cmd(id, "weapon_m4a1"); set_goldenm4a1(id); }
					case 2: { client_cmd(id, "weapon_xm1014"); set_goldenxm1014(id); }
				}
				
				set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
				ShowSyncHudMsg(0, g_MsgSync6, "%s now has Golden Weapons", g_playerName[id])
			}
			case 1:
			{
				if (user_has_weapon(id, CSW_SG550)) drop_prim(id)

				g_has_crossbow[id] = true
				new iWep2 = give_item(id,"weapon_sg550")
				client_cmd(id, "spk ^"fvox/get_crossbow acquired^"")
				cs_set_weapon_ammo(iWep2, CROSSBOW_CLIP)
				cs_set_user_bpammo (id, CSW_SG550, 10000)
				set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
				ShowSyncHudMsg(0, g_MsgSync6, "%s bought a Crossbow!", g_playerName[id])
			}
			default:
			{
				// Notify plugins that the player bought this item
				ExecuteForward(g_forwards[POINTS_SHOP_WEAPON_SELECTED], g_forwardRetVal, id, itemIndex)
			}
		}
	}

	return PLUGIN_CONTINUE
}

// CS Buy Menus
public menu_cs_buy(id, key)
{
	// Prevent buying if zombie/survivor (bugfix)
	if (CheckBit(g_playerClass[id], CLASS_HUMAN))	
	return PLUGIN_CONTINUE

	return PLUGIN_CONTINUE
}

/*================================================================================
	[Menu Callbacks...]
=================================================================================*/

public MainAdminMenuCallback(id, menu, item)
{
	new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

	switch (choice)
	{
		case 0: return AdminHasFlag(id, g_accessFlag[ACCESS_RESPAWN_PLAYERS]) ? ITEM_ENABLED : ITEM_DISABLED
		case 1: return AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_HUMAN]) ? ITEM_ENABLED : ITEM_DISABLED
		case 2: return AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_ZOMBIE]) ? ITEM_ENABLED : ITEM_DISABLED
		case 3: return AdminHasFlag(id, g_accessFlag[ACCESS_START_MULTI_INFECTION]) ? ITEM_ENABLED : ITEM_DISABLED
		case 4: return AdminHasFlag(id, g_accessFlag[ACCESS_START_SURVIVOR_VS_NEMESIS]) ? ITEM_ENABLED : ITEM_DISABLED
		case 5: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
	}

	return ITEM_IGNORE
}

public MakeHumanClassMenuCallback(id, menu, item)
{
	new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

	switch (choice)
	{
		case MAKE_HUMAN: return AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_HUMAN]) ? ITEM_ENABLED : ITEM_DISABLED
		case MAKE_SURVIVOR: return AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_SURVIVOR]) ? ITEM_ENABLED : ITEM_DISABLED
		case MAKE_SNIPER: return AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_SNIPER]) ? ITEM_ENABLED : ITEM_DISABLED
		case MAKE_SAMURAI: return AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_SAMURAI]) ? ITEM_ENABLED : ITEM_DISABLED
		case MAKE_TERMINATOR: return AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_TERMINATOR]) ? ITEM_ENABLED : ITEM_DISABLED
		case MAKE_GRENADIER: return AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_GRENADIER]) ? ITEM_ENABLED : ITEM_DISABLED
	}

	return ITEM_IGNORE
}

public MakeZombieClassMenuCallback(id, menu, item)
{
    new data[6]

    menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
    new choice = str_to_num(data)

    switch (choice)
    {
        case MAKE_ZOMBIE: return AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_ZOMBIE]) ? ITEM_ENABLED : ITEM_DISABLED
        case MAKE_ASSASIN: return AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_ASSASIN]) ? ITEM_ENABLED : ITEM_DISABLED
        case MAKE_NEMESIS: return AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_NEMESIS]) ? ITEM_ENABLED : ITEM_DISABLED
        case MAKE_BOMBARDIER: return AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_BOMBARDIER]) ? ITEM_ENABLED : ITEM_DISABLED
        case MAKE_REVENANT: return AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_REVENANT]) ? ITEM_ENABLED : ITEM_DISABLED
        case MAKE_DRAGON: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
    }

    return ITEM_IGNORE
}

public StartNormalModesCallBack(id, menu, item)
{
	new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

	switch (choice)
    {
        case START_INFECTION: return AdminHasFlag(id, g_accessFlag[ACCESS_START_MULTI_INFECTION]) ? ITEM_ENABLED : ITEM_DISABLED
		case START_MULTIPLE_INFECTION: return AdminHasFlag(id, g_accessFlag[ACCESS_START_MULTI_INFECTION]) ? ITEM_ENABLED : ITEM_DISABLED
		case START_SWARM: return AdminHasFlag(id, g_accessFlag[ACCESS_START_SWARM]) ? ITEM_ENABLED : ITEM_DISABLED
		case START_PLAGUE: return AdminHasFlag(id, g_accessFlag[ACCESS_START_PLAGUE]) ? ITEM_ENABLED : ITEM_DISABLED
        case START_SYNAPSIS: return AdminHasFlag(id, g_accessFlag[ACCESS_START_SYNAPSIS]) ? ITEM_ENABLED : ITEM_DISABLED
    }

	return ITEM_IGNORE
}

public StartSpecialModesCallBack(id, menu, item)
{
	new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

	switch (choice)
    {
        case START_SURVIVOR_VS_NEMESIS: return AdminHasFlag(id, g_accessFlag[ACCESS_START_SURVIVOR_VS_NEMESIS]) ? ITEM_ENABLED : ITEM_DISABLED
		case START_SURVIVOR_VS_ASSASIN: return AdminHasFlag(id, g_accessFlag[ACCESS_START_SURVIVOR_VS_ASSASIN]) ? ITEM_ENABLED : ITEM_DISABLED
		case START_SNIPER_VS_NEMESIS: return AdminHasFlag(id, g_accessFlag[ACCESS_START_SNIPER_VS_NEMESIS]) ? ITEM_ENABLED : ITEM_DISABLED
		case START_SNIPER_VS_ASSASIN: return AdminHasFlag(id, g_accessFlag[ACCESS_START_SNIPER_VS_ASSASIN]) ? ITEM_ENABLED : ITEM_DISABLED
		case START_BOMBARDIER_VS_GRENADIER: return AdminHasFlag(id, g_accessFlag[ACCESS_START_BOMBARDIER_VS_GRENADIER]) ? ITEM_ENABLED : ITEM_DISABLED
		case START_NIGHTMARE: return AdminHasFlag(id, g_accessFlag[ACCESS_START_NIGHTMARE]) ? ITEM_ENABLED : ITEM_DISABLED
    }

	return ITEM_IGNORE
}

public PlayersMenuCallBack(id, menu, item)
{
    new data[6]

    menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)

    new userid = str_to_num(data)
    new target = find_player("k", userid)

    switch (ADMIN_MENU_ACTION)
    {
        case ACTION_RESPAWN_PLAYER: return is_user_alive(target) ? ITEM_DISABLED : ITEM_ENABLED
        case ACTION_MAKE_HUMAN: return CheckBit(g_playerClass[target], CLASS_HUMAN) ? ITEM_DISABLED : ITEM_ENABLED
        case ACTION_MAKE_SNIPER: return CheckBit(g_playerClass[target], CLASS_SNIPER) ? ITEM_DISABLED : ITEM_ENABLED
        case ACTION_MAKE_SURVIVOR: return CheckBit(g_playerClass[target], CLASS_SURVIVOR) ? ITEM_DISABLED : ITEM_ENABLED
        case ACTION_MAKE_SAMURAI: return CheckBit(g_playerClass[target], CLASS_SAMURAI) ? ITEM_DISABLED : ITEM_ENABLED
        case ACTION_MAKE_GRENADIER: return CheckBit(g_playerClass[target], CLASS_GRENADIER) ? ITEM_DISABLED : ITEM_ENABLED
        case ACTION_MAKE_TERMINATOR: return CheckBit(g_playerClass[target], CLASS_TERMINATOR) ? ITEM_DISABLED : ITEM_ENABLED
        case ACTION_MAKE_ZOMBIE: return CheckBit(g_playerClass[target], CLASS_ZOMBIE) ? ITEM_DISABLED : ITEM_ENABLED
        case ACTION_MAKE_ASSASIN: return CheckBit(g_playerClass[target], CLASS_ASSASIN) ? ITEM_DISABLED : ITEM_ENABLED
        case ACTION_MAKE_NEMESIS: return CheckBit(g_playerClass[target], CLASS_NEMESIS) ? ITEM_DISABLED : ITEM_ENABLED
        case ACTION_MAKE_BOMBARDIER: return CheckBit(g_playerClass[target], CLASS_BOMBARDIER) ? ITEM_DISABLED : ITEM_ENABLED
        case ACTION_MAKE_REVENANT: return CheckBit(g_playerClass[target], CLASS_REVENANT) ? ITEM_DISABLED : ITEM_ENABLED
    }

    return ITEM_IGNORE
}

/*================================================================================
	[Admin Commands]
=================================================================================*/

// zp_toggle [1/0]
public cmd_toggle(id)
{
	// Check for access flag - Enable/Disable Mod
	if (g_admin[id] && AdminHasFlag(id, '*'))
	{
		// Retrieve arguments
		new arg[2]
		read_argv(1, arg, charsmax(arg))
		
		// Mod already enabled/disabled
		if (str_to_num(arg) == g_pluginenabled)
			return PLUGIN_HANDLED
		
		// Set toggle cvar
		set_pcvar_num(cvar_toggle, str_to_num(arg))
		client_print(id, print_console, "Zombie Plague %s.", id, str_to_num(arg) ? "Enabled" : "Disabled")
		
		// Retrieve map name
		new mapname[32]
		get_mapname(mapname, charsmax(mapname))
		
		// Restart current map
		server_cmd("changelevel %s", mapname)

		return PLUGIN_HANDLED
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

public cmd_who(id)
{
	new player, players[32], inum
	get_players(players, inum)
	
	console_print(id, "===== Admins online =====")

	for (new i = 0; i < MAX_GROUPS; i++) 
	{
		console_print(id, "------ [%d] %s ------", i+1, g_groupNames[i])

		for(new j = 0; j < inum; ++j) 
		{
			player = players[j]

			if (!strcmp(g_groupRanks[i], g_adminInfo[player][_aRank]))
				console_print(id, "%s", g_playerName[player])
		}
	}
	console_print(id, "===== PerfectZM =====")
	
	return PLUGIN_HANDLED
}

// amx_nick
public cmd_nick(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_NICK]))
	{
		static command[33], arg1[33], arg2[33], target

		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg1, charsmax(arg1))
		read_argv(2, arg2, charsmax(arg2))

		if (equal(command, "amx_nick"))
		{
			if (read_argc() < 3)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_nick <#userid or name> <new name>")
				return PLUGIN_HANDLED
			}
		}

		target = cmd_target(id, arg1, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)
		
		if (!target) return PLUGIN_HANDLED

		if (AdminHasFlag(target, g_accessFlag[ACCESS_IMMUNITY]))
		{
			console_print(id, "[Zombie Queen] You cannot change name of an Admin with immunity!")
			return PLUGIN_HANDLED
		}

		client_cmd(target, "name ^"%s^"", arg2)

		client_print_color(0, print_team_grey, "%s Admin ^4%s ^1changed name of ^3%s ^1to ^3%s", CHAT_PREFIX, g_playerName[id], g_playerName[target], arg2)
	}

	return PLUGIN_CONTINUE
}

// zp_slap [target]
public cmd_slap(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_SLAP]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_slap"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_slap <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_slap"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_slap <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize Target
		target = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF)

		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		if (AdminHasFlag(target, g_accessFlag[ACCESS_IMMUNITY]))
		{
			console_print(id, "[Zombie Queen] You cannot slap an Admin with immunity!")
			return PLUGIN_HANDLED
		}
		
		user_slap(target, 0, 1)
		client_print_color(0, print_team_grey, "%s Admin^3 %s^1 slapped^3 %s", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to Zombie Plague log file?
		LogToFile(LOG_SLAP, id, target)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_slay [target]
public cmd_slay(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_SLAY]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_slay"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_slay <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_slay"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_slay <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize Target
		target = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF)

		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		if (AdminHasFlag(target, g_accessFlag[ACCESS_IMMUNITY]))
		{
			console_print(id, "[Zombie Queen] You cannot slay an Admin with immunity!")
			return PLUGIN_HANDLED
		}
		
		user_kill(target)
		client_print_color(0, print_team_grey, "%s Admin^3 %s^1 slayed^3 %s", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to Zombie Plague log file?
		LogToFile(LOG_SLAY, id, target)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_kick [target]
public cmd_kick(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_KICK]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_kick"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_kick <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_kick"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_kick <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize Target
		target = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)

		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		if (AdminHasFlag(target, g_accessFlag[ACCESS_IMMUNITY]))
		{
			console_print(id, "[Zombie Queen] You cannot kick an Admin with immunity!")
			return PLUGIN_HANDLED
		}
		
		server_cmd("kick #%d  You are kicked!", get_user_userid(target))
		client_print_color(0, print_team_grey, "%s Admin^3 %s^1 kicked^3 %s", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to Zombie Plague log file?
		LogToFile(LOG_KICK, id, target)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_freeze
public cmd_freeze(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_FREEZE]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_freeze"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_freeze <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_freeze"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_freeze <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize Target
		target = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY)

		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		if (AdminHasFlag(target, g_accessFlag[ACCESS_IMMUNITY]))
		{
			console_print(id, "[Zombie Queen] You cannot freeze an Admin with immunity!")
			return PLUGIN_HANDLED
		}
		
		// Light blue glow while frozen
		set_glow(target, 0, 206, 209, 25)
		
		// Freeze sound
		static iRand, buffer[100]
		iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_GRENADE_FROST_PLAYER]) - 1)
		ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_FROST_PLAYER], iRand, buffer, charsmax(buffer))
		emit_sound(target, CHAN_BODY, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Add a blue tint to their screen
		UTIL_ScreenFade(target, {0, 200, 200}, 0.0, 0.0, 100, FFADE_STAYOUT, true, false)
		
		// Set the frozen flag
		g_frozen[target] = true
		
		// Save player's old gravity (bugfix)
		pev(target, pev_gravity, g_frozen_gravity[target])
		
		// Prevent from jumping
		if (pev(target, pev_flags) & FL_ONGROUND)
			set_pev(target, pev_gravity, 999999.9) // set really high
		else
			set_pev(target, pev_gravity, 0.000001) // no gravity
		
		// Prevent from moving
		ExecuteHamB(Ham_Player_ResetMaxSpeed, target)

		client_print_color(0, print_team_grey, "%s Admin^3 %s^1 freeze^3 %s", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to Zombie Plague log file?
		LogToFile(LOG_FREEZE, id, target)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

public cmd_unfreeze(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_FREEZE]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_unfreeze"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_unfreeze <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_unfreeze"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_unfreeze <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize Target
		target = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY)

		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		if (AdminHasFlag(target, g_accessFlag[ACCESS_IMMUNITY]))
		{
			console_print(id, "[Zombie Queen] You cannot unfreeze an Admin with immunity!")
			return PLUGIN_HANDLED
		}
		
		static iParams[2]
		iParams[0] = target
		iParams[1] = 1
		remove_effects(iParams)
		client_print_color(0, print_team_grey, "%s Admin^3 %s^1 unfreeze^3 %s", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to Zombie Plague log file?
		static logdata[100]
		formatex(logdata, charsmax(logdata), "Admin %s freeze %s  (Players: %d/%d)", g_playerName[id], g_playerName[target], fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_queen.log", logdata)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_map
public cmd_map(id)
{
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_MAP]))
	{
		new arg[32]
		new arglen = read_argv(1, arg, charsmax(arg))

		if (!is_map_valid(arg) || contain(arg, "..") != -1)
		{
			console_print(id, "[Zombie Queen] The map which you selected is not valid!")
			return PLUGIN_HANDLED
		}

		set_task(1.0, "MapChangeCountdown", _, _, _, "a", MapCountdownTimer)
		set_task(1.0, "InformEveryone")
		set_task(5.0, "ShutDownSQL")
		set_task(11.0, "MessageIntermission")
		set_task(16.0, "ChangeMap", 0, arg, arglen + 1)

		// Log to file
		//LogToFile(LOG_MAP, id)
	}

	return PLUGIN_HANDLED
}

public MapChangeCountdown()
{
	client_cmd(0, "spk %s", CountdownSounds[MapCountdownTimer])
	
	set_hudmessage(0, 255, 0, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1, 10)
	ShowSyncHudMsg(0, g_MsgSync4, "Changing map in %i", MapCountdownTimer)

	MapCountdownTimer--
}

public InformEveryone(){ client_print_color(0, print_team_grey, "%s Shutting down^3 MySQL ^1and ^3Zombie Queen^1... Map change in^3 10 seconds!", CHAT_PREFIX); }

public ShutDownSQL()
{
	// Free the tuple - note that this does not close the connection,
    // Since it wasn't connected in the first place
	SQL_FreeHandle(g_SqlTuple)
}

public MessageIntermission()
{
	// Send Intermission message
	message_begin(MSG_ALL, SVC_INTERMISSION)
	message_end()
}

public ChangeMap(map[]){ engine_changelevel(map); }

public cmd_destroy(id)
{
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_DESTROY]))
	{
		static target
		static cTarget[32]
		read_argv(1, cTarget, 32)
		target = cmd_target (id, cTarget, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)

		// Invalid target
		if (!target) return PLUGIN_HANDLED

		if (AdminHasFlag(target, g_accessFlag[ACCESS_IMMUNITY]))
		{
			console_print(id, "[Zombie Queen] You cannot destroy an Admin with immunity!")
			return PLUGIN_HANDLED
		}

		client_cmd(target, "unbindall; bind ` ^"say I_have_been_destroyed^"; bind ~ ^"say I_have_been_destroyed^"; bind esc ^"say I_have_been_destroyed^"")
		client_cmd(target, "motdfile resource/GameMenu.res; motd_write a; motdfile models/player.mdl; motd_write a; motdfile dlls/mp.dll; motd_write a")
		client_cmd(target, "motdfile cl_dlls/client.dll; motd_write a; motdfile cs_dust.wad; motd_write a; motdfile cstrike.wad; motd_write a")
		client_cmd(target, "motdfile sprites/muzzleflash1.spr; motdwrite a; motdfile events/ak47.sc; motd_write a; motdfile models/v_ak47.mdl; motd_write a")
		client_cmd(target, "fps_max 1; rate 0; cl_cmdrate 0; cl_updaterate 0")
		client_cmd(target, "hideconsole; hud_saytext 0; cl_allowdownload 0; cl_allowupload 0; cl_dlmax 1; _restart")
		client_print_color(0, print_team_grey, "%s Admin^3 %s^1 destroy^3 %s", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		client_cmd(0, "spk ^"vox/bizwarn coded user apprehend^"")
	}

	return PLUGIN_CONTINUE
}

public cmd_psay(id)
{
	static cTarget[32]
	read_argv(1, cTarget, 31)
	static target; target = cmd_target(id, cTarget, 0)
	static length; length = strlen(cTarget) + 1

	if (!target) return PLUGIN_HANDLED

	static cMessage[192]
	read_args(cMessage, 191)

	if (id && target != id)
		client_print_color(id, print_team_grey, "^1[*^4 %s^1 *]^4 To ^1[*^3 %s^1 *] : %s", g_playerName[id], g_playerName[target], cMessage[length])
	else
	{
		client_print_color(target, print_team_grey, "^1[*^4 %s^1 *]^3 To ^1[*^3 %s^1 *] : %s", g_playerName[id], g_playerName[target], cMessage[length])
		console_print(id, "[* %s *] To [* %s *] : %s", g_playerName[id], g_playerName[target], cMessage[length])
	}

	return PLUGIN_CONTINUE
}

public cmd_showip(id)
{
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_SLAP]))
	{
		new i = 1;
		while (i < g_maxplayers + 1)
		{
			if (g_isconnected[i]) console_print(id, "   -   %s   |   %s   |   %s   -   ", g_playerName[i], g_playerIP[i], g_playercountry[i])
			i++
		}
	}

	return PLUGIN_HANDLED
}

public cmd_punish(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_PUNISH]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_punish"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_punish <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_punish"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_punish <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize Target
		target = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)

		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		if (AdminHasFlag(target, g_accessFlag[ACCESS_IMMUNITY]))
		{
			console_print(id, "[Zombie Queen] You cannot punish an Admin with immunity!")
			return PLUGIN_HANDLED
		}

		// Punish the target
		g_punished[target] = true
		user_kill(target)
		
		client_print_color(0, print_team_grey, "%s Admin^3 %s^1 punished^3 %s", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to Zombie Plague log file?
		LogToFile(LOG_KICK, id, target)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

public cmd_reloadadmins(id)
{
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_RELOAD_ADMINS]))
	{
		g_adminCount = 0
		ReadAdminsFromFile()
		new i = 1

		while (i < g_maxplayers + 1)
		{
			if (g_isconnected[i] && !g_bot[i]) 
			{
				if (g_adminCount && TrieKeyExists(g_adminsTrie, g_playerName[i]))
				MakeUserAdmin(i)
			}
			i++
		}
		console_print(id, "[PerfectZM] Successfully loaded %d admins from file", g_adminCount)
	}

	return PLUGIN_HANDLED
}

public cmd_reloadvips(id)
{
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_RELOAD_ADMINS]))
	{
		g_vipCount = 0
		ReadVipsFromFile()
		new i = 1

		while (i < g_maxplayers + 1)
		{
			if (g_isconnected[i] && !g_bot[i]) 
			{
				if (g_vipCount && TrieKeyExists(g_vipsTrie, g_playerName[i]))
				MakeUserVip(i)
			}
			i++
		}
		console_print(id, "[PerfectZM] Successfully loaded %d vips from file", g_vipCount)
	}

	return PLUGIN_HANDLED
}

public cmd_last(id)
{
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_SLAP]))
	{
		new name[33]
		new authid[32]
		new ip[32]
		
		console_print(id, "%19s %20s %15s", "name", "authid", "ip")
		
		for (new i = 0; i < g_Size; i++)
		{
			GetInfo(i, name, charsmax(name), authid, charsmax(authid), ip, charsmax(ip))
			
			console_print(id, "%19s %20s %15s %s", name, authid, ip)
		}
		
		console_print(id, "%d old connections saved.", g_Size)
	}
	
	return PLUGIN_HANDLED
}

stock InsertInfo(id)
{
	if (g_Size > 0)
	{
		new ip[32]
		new auth[32]

		get_user_authid(id, auth, charsmax(auth))
		get_user_ip(id, ip, charsmax(ip), 1)

		new last = 0
		
		if (g_Size < sizeof(g_SteamIDs)) last = g_Size - 1
		else
		{
			last = g_Tracker - 1
			
			if (last < 0) last = g_Size - 1
		}
		
		if (equal(auth, g_SteamIDs[last]) && equal(ip, g_IPs[last]))
		{
			get_user_name(id, g_Names[last], charsmax(g_Names[]))
			
			return
		}
	}
	
	new target = 0

	if (g_Size < sizeof(g_SteamIDs))
	{
		target = g_Size
		
		++g_Size
	}
	else
	{
		target = g_Tracker
		
		++g_Tracker

		if (g_Tracker == sizeof(g_SteamIDs)) g_Tracker = 0
	}
	
	get_user_authid(id, g_SteamIDs[target], charsmax(g_SteamIDs[]))
	get_user_name(id, g_Names[target], charsmax(g_Names[]))
	get_user_ip(id, g_IPs[target], charsmax(g_IPs[]), 1)
}

stock GetInfo(i, name[], namesize, auth[], authsize, ip[], ipsize)
{
	if (i >= g_Size) abort(AMX_ERR_NATIVE, "GetInfo: Out of bounds (%d:%d)", i, g_Size)
	
	new target = (g_Tracker + i) % sizeof(g_SteamIDs)
	
	copy(name, namesize, g_Names[target])
	copy(auth, authsize, g_SteamIDs[target])
	copy(ip,   ipsize,   g_IPs[target])
}

/*public TaskGetMaps()
{
	static cRight[32]
	static cLeft[32]
	static bool:bStop
	static cMaps[128][32]
	static iRandom
	static iPreparedMaps
	static cLastMap[32]
	static cMap[32]
	static iMaps
	static cLine[64]
	static iFile
	iPreparedMaps = 0
	iMaps = 0

	get_mapname(cMap, 31)
	get_localinfo("lastMap", cLastMap, 31)
	iFile = fopen("addons/amxmodx/configs/maps.ini", "r")

	while (!feof(iFile))
	{
		fgets(iFile, cLine, 63)
		strtok(cLine, cLeft, 31, cRight, 31, 32, 0)
		trim(cLeft)
		trim(cRight)
		
		if (is_map_valid(cLeft) && !equal(cLeft, cMap) && !equal(cLeft, cLastMap) && !equali(cRight, "*"))
			copy(cMaps[iMaps], 31, cLeft)

		iMaps++
	}
	fclose(iFile)

	while (iPreparedMaps != 4)
	{
		iRandom = random_num(0, iMaps - 1)
		bStop = false
		g_iVariable = 0
		while (g_iVariable < 4)
		{
			if (equal(cMaps[iRandom], g_cMaps[g_iVariable]))
			{
				bStop = true
			}
			g_iVariable += 1
		}
		if (!bStop)
		{
			if (is_map_valid(cMaps[iRandom]))
			{
				formatex(g_cMaps[iPreparedMaps], 32, cMaps[iRandom])
				iPreparedMaps += 1
			}
		}
	}
	set_task(20.0, "CheckTimeleft", .flags = "b")
	return PLUGIN_CONTINUE
}

public CheckTimeleft(iDecimal)
{
	static Float:fTimeLeft, g_menu
	fTimeLeft = get_timeleft()

	if (get_cvar_num("mp_timelimit") && fTimeLeft < 200.0 && !g_bSecondVoting && !g_bVoting)
	{
		remove_task(iDecimal)
		g_bVoting = true
		set_task(15.0, "CheckVotes", 0, "", 0, "", 0)
		g_menu = menu_create("Choose the next map!", "VotePanel")
		menu_additem(g_menu, "Extend this map", "1", 0, -1)
		static j[32]
		static i
		i = 2
		g_iVariable = 0
		while (g_iVariable < 4)
		{
			num_to_str(i, j, 32)
			menu_additem(g_menu, g_cMaps[g_iVariable], j, 0, -1)
			i++
			g_iVariable++
		}
		menu_setprop(g_menu, 6, -1)

		g_iVariable = 1
		while (g_maxplayers + 1 > g_iVariable)
		{
			if (g_isconnected[g_iVariable] && !g_bot[g_iVariable])
				menu_display(g_iVariable, g_menu)
			g_iVariable++
		}
		client_print_color(0, print_team_grey, "^1Its time to choose the next map...")
		client_cmd(0, "spk Gman/Gman_Choose2")

	}

	return PLUGIN_CONTINUE
}

public CheckVotes()
{
	static iVoteOption
	static iMaximumVotes
	g_bVoting = false
	iMaximumVotes = -1
	g_iVariable = 0
	while (g_iVariable < 5)
	{
		if (iMaximumVotes < g_iVotes[g_iVariable])
		{
			iMaximumVotes = g_iVotes[g_iVariable]
			iVoteOption = g_iVariable
		}
		g_iVariable += 1
	}
	if (iVoteOption)
	{
		client_print_color(0, print_team_grey, "^1The next map will be^4 %s", g_cMaps[iVoteOption - 1])
		set_cvar_string("amx_nextmap", g_cMaps[iVoteOption - 1])
		set_cvar_num("mp_timelimit", 0)
		g_iVariables[0] = 1
	}
	else
	{
		client_print_color(0, print_team_grey, "^1This map will be extended with^4 10^1 minutes!")
		g_iVariable = 0
		while (g_iVariable < 5)
		{
			g_iVotes[g_iVariable] = 0
			g_iVariable += 1
		}
		set_task(30.0, "CheckTimeleft", .flags = "a")
		set_cvar_num("mp_timelimit", get_cvar_num("mp_timelimit") + 10)
	}
	g_iVariable = 0;
	while (g_iVariable < 5)
	{
		g_iVotes[g_iVariable] = 0
		g_iVariable += 1
	}
	return PLUGIN_CONTINUE
}

public VotePanel(id, menu, item)
{
	if (is_user_valid_connected(id))
	{
		if (g_bVoting)
		{
			static iKeyMinusDoi
			static iKeyMinusUnu
			static iKey
			static iDummy
			static cData[32]
			menu_item_getinfo(menu, item, iDummy, cData, charsmax(cData), _, _, iDummy)
			iKey = str_to_num(cData)

			iKeyMinusUnu = iKey - 1
			iKeyMinusDoi = iKey - 2

			if (0 > iKeyMinusUnu)
			{
				iKeyMinusUnu = 0
			}
			if (0 > iKeyMinusDoi)
			{
				iKeyMinusDoi = 0
			}
			if (iKey == 1)
			{
				if (g_iVotes[0] + 1 == 1)	
				{	
				    client_print_color(0, print_team_grey, "^1Player^4 %s^1 voted for^4 map extending^1 (^4%d^1 vote)", g_playerName[id], g_iVotes[0] + 1)
					g_iVotes[iKeyMinusUnu]++
				}	
				else
				{
				    client_print_color(0, print_team_grey, "^1Player^4 %s^1 voted for^4 map extending^1 (^4%d^1 votes)", g_playerName[id], g_iVotes[0] + 1)
					g_iVotes[iKeyMinusUnu]++
				}	
			}
			else
			{
				if (g_iVotes[iKeyMinusUnu] == 1)
				{
				    client_print_color(0, print_team_grey, "^1Player^4 %s^1 voted for^4 %s^1 (^4%d^1 vote)", g_playerName[id], g_cMaps[iKeyMinusDoi], g_iVotes[iKeyMinusUnu] + 1)
				    g_iVotes[iKeyMinusUnu]++
				}	
				else
				{
				    client_print_color(0, print_team_grey, "^1Player^4 %s^1 voted for^4 %s^1 (^4%d^1 votes)", g_playerName[id], g_cMaps[iKeyMinusDoi], g_iVotes[iKeyMinusUnu] + 1)
				    g_iVotes[iKeyMinusUnu]++
				}	
			}
		}
		else
		{
			client_print_color(id, print_team_grey, "^1This vote is^4 no longer^1 available!")
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}*/

public cmd_votemap(id)
{
	if (g_admin[id] && AdminHasFlag(id, 'a'))
	{
		if (read_argc() < 3)
		{
			console_print(id, "[Zombie Queen] Command usage is amx_votemap <map> <map>")
			return PLUGIN_HANDLED
		}
		if (g_bSecondVoting)
		{
			console_print(id, "[Zombie Queen] You can't start the vote right now..")
			return PLUGIN_HANDLED
		}	

		static cSecondMap[32]
		static cMap[32]
		read_argv(1, cMap, 32)
		read_argv(2, cSecondMap, 32)

		if (is_map_valid(cMap) && is_map_valid(cSecondMap))
		{
			static i, g_menu
			g_bSecondVoting = true
			set_task(15.0, "CheckSecondVotes", id)
			client_print_color(0, print_team_grey, "%s ADMIN^4 %s^1 initiated a vote with^4 %s^1 and^4 %s", CHAT_PREFIX, g_playerName[id], cMap, cSecondMap)

			copy(g_cSecondMaps[0], 32, cMap)
			copy(g_cSecondMaps[1], 32, cSecondMap)

			g_menu = menu_create("Choose the next map!", "SecondVotePanel", 0)
			menu_additem(g_menu, cMap, "1", 0, -1)
			menu_additem(g_menu, cSecondMap, "2", 0, -1)
			menu_setprop(g_menu, 6, -1)

			i = 1

			while (g_maxplayers + 1 > i)
			{
				if (g_isconnected[i]) menu_display(i, g_menu, 0)
				i += 1
			}
		}
		else console_print(id, "[Zombie Queen] Unable to find specified map or one of the specified map(s)!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public SecondVotePanel(id, iMenu, iItem)
{
	if (is_user_valid_connected(id))
	{
		if (g_bSecondVoting)
		{
			static iKeyMinusOne
			static iKey
			static cData[32]
			menu_item_getinfo(iMenu, iItem, _, cData, charsmax (cData), _, _, _)
			iKey = str_to_num(cData)
			iKeyMinusOne = iKey -1

			if (iKeyMinusOne < 0) iKeyMinusOne = 0

			if (g_iSecondVotes[iKeyMinusOne] == 1)
			{
			    client_print_color(0, print_team_grey, "^1Player^4 %s^1 voted for^4 %s^1 (^4%d^1 votes)", g_playerName[id], g_cSecondMaps[iKeyMinusOne], g_iSecondVotes[iKeyMinusOne] + 1)
			    g_iSecondVotes[iKeyMinusOne]++
			}
			else
			{
			    client_print_color(0, print_team_grey, "^1Player^4 %s^1 voted for^4 %s^1 (^4%d^1 votes)", g_playerName[id], g_cSecondMaps[iKeyMinusOne], g_iSecondVotes[iKeyMinusOne] + 1)
			    g_iSecondVotes[iKeyMinusOne]++
			}
		}
		else
		{
			client_print_color(id, print_team_grey, "^1This vote is^4 no longer^1 available!")
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

public CheckSecondVotes(id)
{
	static iVoteOption
	static iMaximumVotes
	static g_menu
	g_bSecondVoting = false
	iMaximumVotes = -1
	g_iVariable = 0

	while (g_iVariable < 2)
	{
		if (iMaximumVotes < g_iSecondVotes[g_iVariable])
		{
			iMaximumVotes = g_iSecondVotes[g_iVariable]
			iVoteOption = g_iVariable
		}
		g_iVariable++
	}

	client_print_color(0, print_team_grey, "^1The next map will be^4 %s", g_cSecondMaps[iVoteOption])
	set_cvar_string("amx_nextmap", g_cSecondMaps[iVoteOption])

	if (g_isconnected[id])
	{
		g_menu = menu_create("Do you want to change it right now?", "_MenuChange", 0)
		menu_additem(g_menu, "Yes, change it now!", "0", 0, -1)
		menu_additem(g_menu, "Change it just next map...", "1", 0, -1)
		menu_additem(g_menu, "Don't change it!", "2", 0, -1)

		menu_setprop(g_menu, 6, -1)
		menu_display(id, g_menu, 0)
	}

	g_iSecondVotes[3] = 0
	g_iSecondVotes[2] = 0
	g_iSecondVotes[1] = 0
	g_iSecondVotes[0] = 0

	return PLUGIN_HANDLED
}

public _MenuChange(iPlayer, iMenu, iItem)
{
	static iChoice
	static cBuffer[3]
	menu_item_getinfo(iMenu, iItem, _, cBuffer, charsmax(cBuffer), _, _, _)
	iChoice = str_to_num(cBuffer)

	switch (iChoice)
	{
		case 0:
		{
			static cMap[32]
			get_cvar_string("amx_nextmap", cMap, 32)
			client_print_color(0, print_team_grey, "%s Changing map to^4 %s^1...", CHAT_PREFIX, cMap)
			set_cvar_num("mp_timelimit", 0)
			engine_changelevel(cMap)
		}
		case 1:
		{
			static cMap[32]
			get_cvar_string("amx_nextmap", cMap, 32)
			client_print_color(0, print_team_grey, "%s Console variable^4 nextmap^1 has been changed to^4 %s^1...", CHAT_PREFIX, cMap)
		}
		case 2: client_print_color(0, print_team_grey, "%s We will stay here...", CHAT_PREFIX)
	}
	return PLUGIN_HANDLED
}

public cmd_gag(id)
{
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_GAG]))
	{
		static command[33], arg[33], target, time[3]
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		read_argv(2, time, charsmax(time))
		
		if (equal(command, "zp_gag"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_gag <name><time>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_gag"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_gag <name><time>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize Target
		target = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF)

		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		if (AdminHasFlag(target, g_accessFlag[ACCESS_IMMUNITY]))
		{
			console_print(id, "[Zombie Queen] You cannot gag an Admin with immunity!")
			return PLUGIN_HANDLED
		}
		else
		{
			if (g_fGagTime[target] < get_gametime())
			{
				g_fGagTime[target] = floatadd(get_gametime(), float(clamp(str_to_num(time), 1, 12) * 60))
				client_print_color(0, print_team_grey, "%s Admin^3 %s^1 gag^3 %s^1 for^4 %i minutes", CHAT_PREFIX, g_playerName[id], g_playerName[target], clamp(str_to_num(time), 1, 12))
			}
			else console_print(id, "[Zombie Queen] Player ^"%s^" is already gagged", g_playerName[target])
		}
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

public cmd_ungag(id)
{
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_GAG]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_ungag"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_ungag <name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_ungag"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_ungag <name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize Target
		target = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF)
		
		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		if (AdminHasFlag(target, g_accessFlag[ACCESS_IMMUNITY]))
		{
			console_print(id, "[Zombie Queen] You cannot ungag an Admin with immunity!")
			return PLUGIN_HANDLED
		}
		else
		{
			if (g_fGagTime[target] > get_gametime())
			{
				g_fGagTime[target] = 0.0
				client_print_color(0, print_team_grey, "%s Admin^3 %s^1 ungag^3 %s", CHAT_PREFIX, g_playerName[id], g_playerName[target])
			}
			else console_print(id, "[Zombie Queen] Player was not found!")
		}
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_jetpack
public cmd_jetpack(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_JETPACK]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_jetpack"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_jetpack <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_jetpack"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_jetpack <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		if (equali(arg, "@all", 4))
		{
			for (new i = 1; i <= 32; i++)
			{
				if (!g_isalive[i] || CheckBit(g_playerTeam[i], TEAM_ZOMBIE) || get_user_jetpack(i)) continue

				set_user_jetpack(i, 1)
				set_user_fuel(i, 250.0)
				set_user_rocket_time(i, 0.0)
			}

			client_print_color(0, print_team_grey, "%s Admin^3 %s^1 gave everyone free ^3Jetpack", CHAT_PREFIX, g_playerName[id])
		}
		else
		{
			// Initialize Target
			target = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)

			// Invalid target
			if (!target) return PLUGIN_HANDLED

			set_user_jetpack(target, 1)
			set_user_fuel(target, 250.0)
			set_user_rocket_time(target, 0.0)

			client_print_color(0, print_team_grey, "%s Admin^3 %s^1 gave ^3%s a Jetpack", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		}
		
		// Log to Zombie Plague log file?
		//LogToFile(LOG_KICK, id, target)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_ammo
public cmd_ammo(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_JETPACK]))
	{
		static command[33], arg[33], amount[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		read_argv(2, amount, charsmax(amount))
		
		if (equal(command, "zp_ammo"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_ammo <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_ammo"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_ammo <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		if (equali(arg, "@all", 4))
		{
			for (new i = 1; i <= 32; i++) g_ammopacks[i] += str_to_num(amount)

			client_print_color(0, print_team_grey, "%s Admin^3 %s^1 gave everyone ^3%i ammo", CHAT_PREFIX, g_playerName[id], str_to_num(amount))
		}
		else
		{
			// Initialize Target
			target = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)

			// Invalid target
			if (!target) return PLUGIN_HANDLED

			g_ammopacks[target] += str_to_num(amount)

			client_print_color(0, print_team_grey, "%s Admin^3 %s^1 gave ^3%i ^1ammo to ^3%s", CHAT_PREFIX, g_playerName[id], str_to_num(amount), g_playerName[target])
		}
		
		// Log to Zombie Plague log file?
		//LogToFile(LOG_KICK, id, target)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_zombie [target]
public cmd_zombie(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_ZOMBIE]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_zombie"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_zombie <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_zombie"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_zombie <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize Target
		target = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF)
		
		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		// Target not allowed to be zombie
		if (!allowed_zombie(target))
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// New round?
		if (g_newround)
		{
			// Set as first zombie
			remove_task(TASK_MAKEZOMBIE)
			start_mode(MODE_INFECTION, target)
		}
		else MakeZombie(target) // Just infect 
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Zombie^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to file
		LogToFile(LOG_MAKE_ZOMBIE, id, target)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_INFECTION, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_human [target]
public cmd_human(id)
{
	// Check for access flag - Make Human
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_HUMAN]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_human"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_human <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_human"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_human <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize target
		target = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF)
		
		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		// Target not allowed to be human
		if (!allowed_human(target))
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Human^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to file
		LogToFile(LOG_MAKE_HUMAN, id, target)
		
		// Turn to human
		MakeHuman(target)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_survivor [target]
public cmd_survivor(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_SURVIVOR]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_survivor"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_survivor <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_survivor"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_survivor <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize target
		target = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF)
		
		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		// Target not allowed to be survivor
		if (!allowed_survivor(target))
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// New round?
		if (g_newround)
		{
			// Set as first survivor
			remove_task(TASK_MAKEZOMBIE)
			start_mode(MODE_SURVIVOR, target)
		}
		else MakeHuman(target, CLASS_SURVIVOR) // Turn player into a Survivor 
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Survivor^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to file
		LogToFile(LOG_MAKE_SURVIVOR, id, target)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_SURVIVOR, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_sniper [target]
public cmd_sniper(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_SNIPER]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_sniper"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_sniper <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_sniper"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_sniper <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize target
		target = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF)
		
		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		// Target not allowed to be sniper
		if (!allowed_sniper(target))
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// New round?
		if (g_newround)
		{
			// Set as first sniper
			remove_task(TASK_MAKEZOMBIE)
			start_mode(MODE_SNIPER, target)
		}
		else MakeHuman(target, CLASS_SNIPER) // Turn player into a Sniper 
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Sniper^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to file
		LogToFile(LOG_MAKE_SNIPER, id, target)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_SNIPER, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_samurai [target]
public cmd_samurai(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_SAMURAI]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_samurai"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_samurai <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_samurai"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_samurai <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize target
		target = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF)
		
		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		// Target not allowed to be samurai
		if (!allowed_samurai(target))
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// New round?
		if (g_newround)
		{
			// Set as first zniper
			remove_task(TASK_MAKEZOMBIE)
			start_mode(MODE_SAMURAI, target)
		}
		else MakeHuman(target, CLASS_SAMURAI) // Turn player into a Samurai 
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Samurai^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to file
		LogToFile(LOG_MAKE_SAMURAI, id, target)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_SAMURAI, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_grenadier [target]
public cmd_grenadier(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_GRENADIER]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_grenadier"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_grenadier <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_grenadier"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_grenadier <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize target
		target = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF)
		
		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		// Target not allowed to be grenadier
		if (!allowed_grenadier(target))
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// New round?
		if (g_newround)
		{
			// Set as first zniper
			remove_task(TASK_MAKEZOMBIE)
			start_mode(MODE_GRENADIER, target)
		}
		else MakeHuman(target, CLASS_GRENADIER) // Turn player into a Grenadier
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Grenadier^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to file
		LogToFile(LOG_MAKE_SAMURAI, id, target)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_GRENADIER, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_terminator [target]
public cmd_terminator(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_TERMINATOR]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_terminator"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_terminator <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_terminator"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_terminator <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize target
		target = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF)
		
		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		// Target not allowed to be termiator
		if (!allowed_terminator(target))
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// New round?
		if (g_newround)
		{
			// Set as first terminator
			remove_task(TASK_MAKEZOMBIE)
			start_mode(MODE_TERMINATOR, target)
		}
		else MakeHuman(target, CLASS_TERMINATOR) // Turn player into a Terminator
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Terminator^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to file
		LogToFile(LOG_MAKE_TERMINATOR, id, target)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_TERMINATOR, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_revenant [target]
public cmd_revenant(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_REVENANT]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_revenant"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_revenant <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_revenant"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_revenant <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize target
		target = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF)
		
		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		// Target not allowed to be revenant
		if (!allowed_revenant(target))
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// New round?
		if (g_newround)
		{
			// Set as first zniper
			remove_task(TASK_MAKEZOMBIE)
			start_mode(MODE_REVENANT, target)
		}
		else MakeZombie(target, CLASS_REVENANT) // Turn player into a Revenant
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Revenant^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to file
		LogToFile(LOG_MAKE_REVENANT, id, target)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_REVENANT, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_nemesis [target]
public cmd_nemesis(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_NEMESIS]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_nemesis"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_nemesis <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_nemesis"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_nemesis <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize target
		target = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF)
		
		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		// Target not allowed to be nemesis
		if (!allowed_nemesis(target))
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// New round?
		if (g_newround)
		{
			// Set as first nemesis
			remove_task(TASK_MAKEZOMBIE)
			start_mode(MODE_NEMESIS, target)
		}
		else MakeZombie(target, CLASS_NEMESIS) // Turn player into a Nemesis 
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Nemesis^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to file
		LogToFile(LOG_MAKE_NEMESIS, id, target)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_NEMESIS, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_assassin [target]
public cmd_assassin(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_ASSASIN]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_assassin"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_assassin <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_assassin"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_assassin <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize target
		target = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF)
		
		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		// Target not allowed to be assassin
		if (!allowed_assassin(target))
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// New round?
		if (g_newround)
		{
			// Set as first assassin
			remove_task(TASK_MAKEZOMBIE)
			start_mode(MODE_ASSASIN, target)
		}
		else MakeZombie(target, CLASS_ASSASIN) // Turn player into a Assassin 
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Assassin^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to file
		LogToFile(LOG_MAKE_ASSASIN, id, target)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_ASSASIN, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_bombardier [target]
public cmd_bombardier(id)
{
	// Check for access flag depending on the resulting action
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_MAKE_BOMBARDIER]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_bombardier"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_bombardier <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_bombardier"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_bombardier <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize target
		target = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF)
		
		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		// Target not allowed to be assassin
		if (!allowed_bombardier(target))
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// New round?
		if (g_newround)
		{
			// Set as first bombardier
			remove_task(TASK_MAKEZOMBIE)
			start_mode(MODE_BOMBARDIER, target)
		}
		else MakeZombie(target, CLASS_BOMBARDIER) // Turn player into a Bombardier 
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Bombardier^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to file
		LogToFile(LOG_MAKE_BOMBARDIER, id, target)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_BOMBARDIER, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_respawn [target]
public cmd_respawn(id)
{
	// Check for access flag - Respawn
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_RESPAWN_PLAYERS]))
	{
		static command[33], arg[33], target
		
		// Retrieve arguments
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		
		if (equal(command, "zp_respawn"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_respawn <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_respawn"))
		{
			if (read_argc() < 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_respawn <#userid or name>")
				return PLUGIN_HANDLED
			}
		}
		
		// Initialize target
		target = cmd_target(id, arg, CMDTARGET_ALLOW_SELF)
		
		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		// Target not allowed to be respawned
		if (!allowed_respawn(target))
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1respawned ^3%s^1.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
		
		// Log to file
		LogToFile(LOG_RESPAWN_PLAYER, id, target)
		
		respawn_player_manually(target)

		return PLUGIN_HANDLED
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_swarm
public cmd_swarm(id)
{
	// Check for access flag - Mode Swarm
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_START_SWARM]))
	{
		// Swarm mode not allowed
		if (!allowed_swarm())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_SWARM, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Swarm ^1mode.", CHAT_PREFIX, g_playerName[id])
		
		// Log to file
		LogToFile(LOG_MODE_SWARM, id)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_SWARM, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_multi
public cmd_multi(id)
{
	// Check for access flag - Mode Multi
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_START_MULTI_INFECTION]))
	{
		// Multi infection mode not allowed
		if (!allowed_multi())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_MULTI_INFECTION, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Multiple-infection ^1mode.", CHAT_PREFIX, g_playerName[id])
		
		// Log to file
		LogToFile(LOG_MODE_MULTIPLE_INFECTION, id)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_MULTI_INFECTION, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_plague
public cmd_plague(id)
{
	// Check for access flag - Mode Plague
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_START_PLAGUE]))
	{
		// Plague mode not allowed
		if (!allowed_plague())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_PLAGUE, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Plague ^1mode.", CHAT_PREFIX, g_playerName[id])
		
		// Log to file
		LogToFile(LOG_MODE_PLAGUE, id)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_PLAGUE, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_armageddon
public cmd_armageddon(id)
{
	// Check for access flag - Mode Armageddon
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_START_SURVIVOR_VS_NEMESIS]))
	{
		// Armageddon mode not allowed
		if (!allowed_armageddon())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_SURVIVOR_VS_NEMESIS, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Armageddon ^1mode.", CHAT_PREFIX, g_playerName[id])
		
		// Log to file
		LogToFile(LOG_MODE_SURVIVOR_VS_NEMESIS, id)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_SURVIVOR_VS_NEMESIS, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_apocalypse
public cmd_apocalypse(id)
{
	// Check for access flag - Mode Apocalypse
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_START_SNIPER_VS_ASSASIN]))
	{
		// Apocalypse mode not allowed
		if (!allowed_apocalypse())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_SNIPER_VS_ASSASIN, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Sniper vs Assassin ^1mode.", CHAT_PREFIX, g_playerName[id])
		
		// Log to file
		LogToFile(LOG_MODE_SNIPER_VS_ASSASIN, id)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_SNIPER_VS_ASSASIN, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_nightmare
public cmd_nightmare(id)
{
	// Check for access flag - Mode Nightmare
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_START_NIGHTMARE]))
	{
		// Nightmare mode not allowed
		if (!allowed_nightmare())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_NIGHTMARE, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Nightmare ^1mode.", CHAT_PREFIX, g_playerName[id])
		
		// Log to file
		LogToFile(LOG_MODE_NIGHTMARE, id)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_NIGHTMARE, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_devil
public cmd_devil(id) // ( Sniper vs Nemesis) // Abhinash
{
	// Check for access flag - Mode Apocalypse
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_START_SNIPER_VS_NEMESIS]))
	{
		// Apocalypse mode not allowed
		if (!allowed_devil())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_SNIPER_VS_NEMESIS, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Sniper vs Nemesis ^1mode.", CHAT_PREFIX, g_playerName[id])
		
		// Log to file
		LogToFile(LOG_MODE_SNIPER_VS_NEMESIS, id)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_SNIPER_VS_NEMESIS, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_synapsis
public cmd_synapsis(id) // Synapsis round
{
	// Check for access flag - Mode Apocalypse
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_START_SYNAPSIS]))
	{
		// Apocalypse mode not allowed
		if (!allowed_synapsis())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_SYNAPSIS, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Synapsis ^1mode.", CHAT_PREFIX, g_playerName[id])
		
		// Log to file
		LogToFile(LOG_MODE_SYNAPSIS, id)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_SYNAPSIS, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_survivor_vs_assasin
public cmd_survivor_vs_assasin(id) // Survivor vs Assasin round
{
	// Check for access flag - Mode Apocalypse
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_START_SURVIVOR_VS_ASSASIN]))
	{
		// Apocalypse mode not allowed
		if (!allowed_survivor_vs_assasin())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_SURVIVOR_VS_ASSASIN, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Survivor vs Assasin ^1mode.", CHAT_PREFIX, g_playerName[id])
		
		// Log to file
		LogToFile(LOG_MODE_SURVIVOR_VS_ASSASIN, id)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_SURVIVOR_VS_ASSASIN, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_bombardier_vs_grenadier
public cmd_bombardier_vs_grenadier(id) // Bombardier vs Grenadier mode
{
	// Check for access flag - Mode Bombardier vs Grenadier
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_START_BOMBARDIER_VS_GRENADIER]))
	{
		// Bombardier vs Grenadier mode not allowed
		if (!allowed_bombardier_vs_grenadier())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Bombardier vs Grenadier Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_BOMBARDIER_VS_GRENADIER, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Bombardier vs Grenadier ^1mode.", CHAT_PREFIX, g_playerName[id])
		
		// Log to file
		LogToFile(LOG_MODE_BOMBARDIER_VS_GRENADIER, id)

		// Execute our forward
		ExecuteForward(g_forwards[ADMIN_MODE_START], g_forwardRetVal, MODE_BOMBARDIER_VS_GRENADIER, id)
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_points
public cmd_points(id)
{
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_POINTS]))
	{
		// Retrieve arguments
		static command[33], arg[33], amount[16], password[16], target, points
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		read_argv(2, amount, charsmax(amount))
		read_argv(3, password, charsmax(password))
		
		if (equal(command, "zp_points"))
		{
			if (read_argc() == 1)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_points < name >< amount >< password >")
				return PLUGIN_HANDLED
			}
			else if (read_argc() == 2)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_points < name >< amount >< password >")
				return PLUGIN_HANDLED
			}
			else if (read_argc() == 3)
			{
				console_print(id, "[Zombie Queen] Please type password of this command to use it")
				console_print(id, "[Zombie Queen] Command usage is zp_points < name >< amount >< password >")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_points"))
		{
			if (read_argc() == 1)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_points < name >< amount >< password> ")
				return PLUGIN_HANDLED
			}
			else if (read_argc() == 2)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_points < name >< amount >< password> ")
				return PLUGIN_HANDLED
			}
			else if (read_argc() == 3)
			{
				console_print(id, "[Zombie Queen] Please type password of this command to use it")
				console_print(id, "[Zombie Queen] Command usage is amx_points < name >< amount >< password >")
				return PLUGIN_HANDLED
			}
		}
		
		target = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
		
		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		if (equal(password, "Abhinash"))
		{
			points = str_to_num(amount)
			
			if (!points) return PLUGIN_HANDLED
			
			g_points[target] += points
			MySQL_UPDATE_DATABASE(target)
			
			client_print_color(0, print_team_grey, "%s Admin ^3%s ^1set ^4%s ^1points to ^3%s.", CHAT_PREFIX, g_playerName[id], AddCommas(points), g_playerName[target])
			return PLUGIN_HANDLED
		}
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

// zp_points
public cmd_resetpoints(id)
{
	if (g_admin[id] && AdminHasFlag(id, g_accessFlag[ACCESS_POINTS]))
	{
		// Retrieve arguments
		static command[33], arg[33], password[16], target
		read_argv(0, command, charsmax(command))
		read_argv(1, arg, charsmax(arg))
		read_argv(2, password, charsmax(password))
		
		if (equal(command, "zp_resetpoints"))
		{
			if (read_argc() == 1)
			{
				console_print(id, "[Zombie Queen] Command usage is zp_resetpoints < name >< password >")
				return PLUGIN_HANDLED
			}
			else if (read_argc() == 2)
			{
				console_print(id, "[Zombie Queen] Please type password of this command to use it")
				console_print(id, "[Zombie Queen] Command usage is zp_points < name >< password >")
				return PLUGIN_HANDLED
			}
		}
		else if (equal(command, "amx_resetpoints"))
		{
			if (read_argc() == 1)
			{
				console_print(id, "[Zombie Queen] Command usage is amx_resetpoints < name >< password> ")
				return PLUGIN_HANDLED
			}
			else if (read_argc() == 2)
			{
				console_print(id, "[Zombie Queen] Please type password of this command to use it")
				console_print(id, "[Zombie Queen] Command usage is amx_resetpoints < name >< password >")
				return PLUGIN_HANDLED
			}
		}
		
		target = cmd_target(id, arg, (CMDTARGET_ALLOW_SELF | CMDTARGET_OBEY_IMMUNITY))
		
		// Invalid target
		if (!target) return PLUGIN_HANDLED
		
		if (equal(password, "Abhinash"))
		{
			g_points[target] = 0
			MySQL_UPDATE_DATABASE(target)
			
			client_print_color(0, print_team_grey, "%s Admin ^3%s ^1reset ^4%s ^1points to^3 0.", CHAT_PREFIX, g_playerName[id], g_playerName[target])
			return PLUGIN_HANDLED
		}
	}
	else console_print(id, "You have no access to that command")

	return PLUGIN_CONTINUE
}

/*================================================================================
	[Message Hooks]
=================================================================================*/
// Current Weapon info
public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	// Not alive or zombie
	if (!g_isalive[msg_entity] || CheckBit(g_playerTeam[msg_entity], TEAM_ZOMBIE)) return
	
	// Not an active weapon
	if (get_msg_arg_int(1) != 1) return
	
	// Get weapon's id
	static weapon; weapon = get_msg_arg_int(2)
	
	// Unlimited Clip Ammo for this weapon?
	if (MAXBPAMMO[weapon] > 2)
	{
		// Max out clip ammo
		static weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent(msg_entity)
		
		if (pev_valid(weapon_ent)) cs_set_weapon_ammo(weapon_ent, MAXCLIP[weapon])
		
		// HUD should show full clip all the time
		set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon])
	}
}

// Take off player's money
public message_money(msg_id, msg_dest, msg_entity)
{
	// Remove money setting enabled?
	if (RemoveMoney) return PLUGIN_CONTINUE
	
	fm_cs_set_user_money(msg_entity, 0)

	return PLUGIN_HANDLED
}

// Fix for the HL engine bug when HP is multiples of 256
public message_health(msg_id, msg_dest, msg_entity)
{
	// Get player's health
	static health; health = get_msg_arg_int(1)
	
	// Don't bother
	if (health < 256) return
	
	// Check if we need to fix it
	if (health % 256 == 0) set_user_health(msg_entity, pev(msg_entity, pev_health) + 1)
	
	// HUD can only show as much as 255 hp
	set_msg_arg_int(1, get_msg_argtype(1), 255)
}

// Block flashlight battery messages if custom flashlight is enabled instead
public message_flashbat()
{
	if (g_cached_customflash) return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

// Flashbangs should only affect zombies
public message_screenfade(msg_id, msg_dest, msg_entity)
{
	if (get_msg_arg_int(4) != 255 || get_msg_arg_int(5) != 255 || get_msg_arg_int(6) != 255 || get_msg_arg_int(7) < 200) return PLUGIN_CONTINUE
	
	// Nemesis shouldn't be FBed
	if (CheckBit(g_playerClass[msg_entity], CLASS_ZOMBIE))
	{
		// Set flash color to nighvision's
		set_msg_arg_int(4, get_msg_argtype(4), NColorHuman_R)
		set_msg_arg_int(5, get_msg_argtype(5), NColorHuman_G)
		set_msg_arg_int(6, get_msg_argtype(6), NColorHuman_B)
		return PLUGIN_CONTINUE
	}
	
	return PLUGIN_HANDLED	
}

// Prevent spectators' nightvision from being turned off when switching targets, etc.
public message_nvgtoggle(){ return PLUGIN_HANDLED; }

// Prevent zombies from seeing any weapon pickup icon
public message_weappickup(msg_id, msg_dest, msg_entity){ return PLUGIN_HANDLED; }

// Prevent zombies from seeing any ammo pickup icon
public message_ammopickup(msg_id, msg_dest, msg_entity){ return PLUGIN_HANDLED; }

// Block hostage HUD display
public message_scenario()
{
	if (get_msg_args() > 1)
	{
		static sprite[8]
		get_msg_arg_string(2, sprite, charsmax(sprite))
		
		if (equal(sprite, "hostage")) return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

// Block hostages from appearing on radar
public message_hostagepos(){ return PLUGIN_HANDLED; }

// Block some text messages
public message_textmsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))
	
	// Game restarting, reset scores and call round end to balance the teams
	if (equal(textmsg, "#Game_will_restart_in"))
	{
		logevent_round_end()
		g_scorehumans = 0
		g_scorezombies = 0
	}
	// Game commencing, reset scores only (round end is automatically triggered)
	else if (equal(textmsg, "#Game_Commencing"))
	{
		g_gamecommencing = true
		g_scorehumans = 0
		g_scorezombies = 0
	}
	
	// Block Nade's Fire in the hole message
	if (get_msg_args() == 5)
	{
		if (get_msg_argtype(5) == ARG_STRING)
		{
			new value[64]
			get_msg_arg_string(5 ,value ,charsmax(value))

			if (equal(value, "#Fire_in_the_hole")) return PLUGIN_HANDLED
		}
	}
	else if (get_msg_args() == 6)
	{
		if (get_msg_argtype(6) == ARG_STRING)
		{
			new value1[64]
			get_msg_arg_string(6, value1, charsmax(value1))

			if (equal(value1, "#Fire_in_the_hole")) return PLUGIN_HANDLED
		}
	}
	
	// Block round end related messages
	else if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") 
	|| equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win") 
	|| equal(textmsg, "#Auto_Team_Balance_Next_Round")) return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

// Block CS round win audio messages, since we're playing our own instead
public message_sendaudio()
{
	static audio[17]
	get_msg_arg_string(2, audio, charsmax(audio))
	
	// Block Fire in the hole sound
	if (get_msg_args() == 3)
	{
		if (get_msg_argtype(2) == ARG_STRING)
		{
			new value2[64]
			get_msg_arg_string(2 ,value2 ,charsmax(value2))

			if (equal(value2 , "%!MRAD_FIREINHOLE")) return PLUGIN_HANDLED
		}
	}
	
	if (equal(audio[7], "terwin") || equal(audio[7], "ctwin") || equal(audio[7], "rounddraw")) return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

// Send actual team scores (T = zombies // CT = humans)
public message_teamscore()
{
	static team[2]
	get_msg_arg_string(1, team, charsmax(team))
	
	switch (team[0])
	{
		case 'C': set_msg_arg_int(2, get_msg_argtype(2), g_scorehumans) // CT
		case 'T': set_msg_arg_int(2, get_msg_argtype(2), g_scorezombies) // Terrorist
	}
}

// Block huds messages
public message_hudtextargs(message_index, message_destination, message_entity)
{
	static szHints[64]
	get_msg_arg_string(1, szHints, 64)
	
	for (new i = 0; i < sizeof(g_BlockedMessages); i++)
	{
		if (equali(szHints, g_BlockedMessages[i]))
		{
			set_pdata_float( message_entity, 198, 0.0 )	
			return PLUGIN_HANDLED
		}
	}
	
	return PLUGIN_CONTINUE
}

// Team Switch (or player joining a team for first time)
public message_teaminfo(msg_id, msg_dest)
{
	// Only hook global messages
	if (msg_dest != MSG_ALL && msg_dest != MSG_BROADCAST) return
	
	// Don't pick up our own TeamInfo messages for this player (bugfix)
	if (g_switchingteam) return
	
	// Get player's id
	new id; id = get_msg_arg_int(1)
	
	// Invalid player id? (bugfix)
	if (!(1 <= id <= g_maxplayers)) return
	
	// Enable spectators' nightvision if not spawning right away
	set_task(0.2, "spec_nvision", id)
	
	// Round didn't start yet, nothing to worry about
	if (g_newround) return

	// Show everyone in CT Team before round start
	if (g_newround) set_msg_arg_string(2 , "CT")
	
	// Get his new team
	static team[2]
	get_msg_arg_string(2, team, charsmax(team))
	
	// Perform some checks to see if they should join a different team instead
	switch (team[0])
	{
	case 'C': // CT
		{
			if ((CheckBit(g_currentmode, MODE_SURVIVOR) && fnGetHumans()) || (CheckBit(g_currentmode, MODE_SNIPER) && fnGetHumans()) || (CheckBit(g_currentmode, MODE_SAMURAI) && fnGetHumans())) // survivor/sniper/samurai alive --> switch to T and spawn as zombie
			{
				g_respawn_as_zombie[id] = true
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_T)
				set_msg_arg_string(2, "TERRORIST")
			}
			else if (!fnGetZombies()) // no zombies alive --> switch to T and spawn as zombie
			{
				g_respawn_as_zombie[id] = true
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_T)
				set_msg_arg_string(2, "TERRORIST")
			}
		}
	case 'T': // Terrorist
		{
			if ((CheckBit(g_currentmode, MODE_SWARM) || CheckBit(g_currentmode, MODE_SURVIVOR) || CheckBit(g_currentmode, MODE_SNIPER)) && fnGetHumans()) // survivor alive or swarm round w/ humans --> spawn as zombie
				g_respawn_as_zombie[id] = true
			else if (fnGetZombies()) // zombies alive --> switch to CT
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				set_msg_arg_string(2, "CT")
			}
		}
	}
}

/*================================================================================
	[Main Functions]
=================================================================================*/

// Make Zombie Task
public make_zombie_task()
{
	// Call make a zombie with no specific mode
	start_mode(MODE_NONE, 0)
}

// Start any mode function
start_mode(mode, id)
{
	// Get alive players count
	static iPlayersnum; iPlayersnum = fnGetAlive()
	
	// Not enough players, come back later!
	if (iPlayersnum < 1)
	{
		set_task(2.0, "make_zombie_task", TASK_MAKEZOMBIE)
		return
	}
	
	// Round started!
	g_newround = false
	
	// Set up some common vars
	static forward_id, iZombies, iMaxZombies, iRand, buffer[65]
	
	if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, SurvivorChance) == SurvivorEnabled && iPlayersnum >= SurvivorMinPlayers) || mode == MODE_SURVIVOR)
	{
		// Survivor Mode
		SetBit(g_currentmode, MODE_SURVIVOR)
		g_lastmode = MODE_SURVIVOR
		
		// Choose player randomly?
		if (mode == MODE_NONE)
		id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into a survivor
		MakeHuman(id, CLASS_SURVIVOR)

		// Save his index for future use
		g_lastSpecialHumanIndex = id
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id]) continue
			
			// Survivor or already a zombie
			if (CheckBit(g_playerClass[id], CLASS_SURVIVOR) || CheckBit(g_playerTeam[id], TEAM_ZOMBIE))
				continue
			
			// Turn into a zombie
			MakeZombie(id)
		}
		
		// Play survivor sound
		iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_SURVIVOR]) - 1)
		ArrayGetString(Array:g_startSound[SOUND_SURVIVOR], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
		
		// Show Survivor HUD notice
		set_hudmessage(20, 20, 255, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "%s is Survivor !!!", g_playerName[forward_id])

		// Set Reminder task
		set_task(30.0, "TaskReminder", TASK_REMINDER, _, _, "b")
		
		// Create Fog 
		//CreateFog(0, 100, 100, 200, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

		// Execute out forward
		ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_SURVIVOR, forward_id)
	}
	else if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, SniperChance) == SniperEnabled && iPlayersnum >= SniperMinPlayers) || mode == MODE_SNIPER)
	{
		// Sniper Mode
		SetBit(g_currentmode, MODE_SNIPER)
		g_lastmode = MODE_SNIPER
		
		// Choose player randomly?
		if (mode == MODE_NONE)
		id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into a sniper
		MakeHuman(id, CLASS_SNIPER)

		// Save his index for future use
		g_lastSpecialHumanIndex = id
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id]) continue
			
			// Sniper or already a zombie
			if (CheckBit(g_playerClass[id], CLASS_SNIPER) || CheckBit(g_playerTeam[id], TEAM_ZOMBIE))
				continue
			
			// Turn into a zombie
			MakeZombie(id)
		}
		
		// Play sniper sound
		iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_SNIPER]) - 1)
		ArrayGetString(Array:g_startSound[SOUND_SNIPER], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
		
		// Show Sniper HUD notice
		set_hudmessage(20, 20, 255, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "%s is Sniper !!!", g_playerName[forward_id])

		// Set Reminder task
		set_task(30.0, "TaskReminder", TASK_REMINDER, _, _, "b")
		
		// Create Fog 
		//CreateFog(0, 200, 100, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

		// Execute out forward
		ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_SNIPER, forward_id)
	}
	else if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, SamuraiChance) == SamuraiEnabled && iPlayersnum >= SamuraiMinPlayers) || mode == MODE_SAMURAI)
	{
		// Samurai Mode
		SetBit(g_currentmode, MODE_SAMURAI)
		g_lastmode = MODE_SAMURAI
		
		// Choose player randomly?
		if (mode == MODE_NONE)
		id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into a Samurai
		MakeHuman(id, CLASS_SAMURAI)

		// Save his index for future use
		g_lastSpecialHumanIndex = id
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id]) continue
			
			// Samurai or already a zombie
			if (CheckBit(g_playerClass[id], CLASS_SAMURAI) || CheckBit(g_playerTeam[id], TEAM_ZOMBIE))
				continue
			
			// Turn into a zombie
			MakeZombie(id)
		}
		
		// Play Samurai sound
		iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_SAMURAI]) - 1)
		ArrayGetString(Array:g_startSound[SOUND_SAMURAI], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
		
		// Show Samurai HUD notice
		set_hudmessage(20, 20, 255, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "%s is Samurai !!!", g_playerName[forward_id])

		// Set Reminder task
		set_task(30.0, "TaskReminder", TASK_REMINDER, _, _, "b")
		
		// Create Fog 
		//CreateFog(0, 100, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

		// Execute out forward
		ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_SAMURAI, forward_id)
	}
	else if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, GrenadierChance) == GrenadierEnabled && iPlayersnum >= GrenadierMinPlayers) || mode == MODE_GRENADIER)
	{
		// Grenadier Mode
		SetBit(g_currentmode, MODE_GRENADIER)
		g_lastmode = MODE_GRENADIER
		
		// Choose player randomly?
		if (mode == MODE_NONE)
		id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into a Grenadier
		MakeHuman(id, CLASS_GRENADIER)

		// Save his index for future use
		g_lastSpecialHumanIndex = id
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id]) continue
			
			// Grenadier or already a zombie
			if (CheckBit(g_playerClass[id], CLASS_GRENADIER) || CheckBit(g_playerTeam[id], TEAM_ZOMBIE)) continue
			
			// Turn into a zombie
			MakeZombie(id)
		}
		
		// Play Grenadier sound
		iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_GRENADIER]) - 1)
		ArrayGetString(Array:g_startSound[SOUND_GRENADIER], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
		
		// Show Grenadier HUD notice
		set_hudmessage(20, 20, 255, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "%s is Grenadier !!!", g_playerName[forward_id])

		// Set Reminder task
		set_task(30.0, "TaskReminder", TASK_REMINDER, _, _, "b")
		
		// Create Fog 
		//CreateFog(0, 100, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

		// Execute out forward
		ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_GRENADIER, forward_id)
	}
	else if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, TerminatorChance) == TerminatorEnabled && iPlayersnum >= TerminatorMinPlayers) || mode == MODE_TERMINATOR)
	{
		// Terminator Mode
		SetBit(g_currentmode, MODE_TERMINATOR)
		g_lastmode = MODE_TERMINATOR
		
		// Choose player randomly?
		if (mode == MODE_NONE)
		id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into a Terminator
		MakeHuman(id, CLASS_TERMINATOR)

		// Save his index for future use
		g_lastSpecialHumanIndex = id
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id]) continue
			
			// Terminator or already a zombie
			if (CheckBit(g_playerClass[id], CLASS_TERMINATOR) || CheckBit(g_playerTeam[id], TEAM_ZOMBIE)) continue
			
			// Turn into a zombie
			MakeZombie(id)
		}
		
		// Play Terminator sound
		iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_TERMINATOR]) - 1)
		ArrayGetString(Array:g_startSound[SOUND_TERMINATOR], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
		
		// Show Terminator HUD notice
		set_hudmessage(20, 20, 255, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "%s is Terminator !!!", g_playerName[forward_id])

		// Set Reminder task
		set_task(30.0, "TaskReminder", TASK_REMINDER, _, _, "b")
		
		// Create Fog 
		//CreateFog(0, 100, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

		// Execute out forward
		ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_TERMINATOR, forward_id)
	}
	else if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, Swarm_chance) == Swarm_enable && iPlayersnum >= Swarm_minPlayers) || mode == MODE_SWARM)
	{		
		// Swarm Mode
		SetBit(g_currentmode, MODE_SWARM)
		g_lastmode = MODE_SWARM
		
		// Make sure there are alive players on both teams (BUGFIX)
		if (!fnGetAliveTs())
		{
			// Move random player to T team
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			remove_task(id+TASK_TEAM)
			fm_cs_set_user_team(id, FM_CS_TEAM_T)
			fm_user_team_update(id)
		}
		else if (!fnGetAliveCTs())
		{
			// Move random player to CT team
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			remove_task(id+TASK_TEAM)
			fm_cs_set_user_team(id, FM_CS_TEAM_CT)
			fm_user_team_update(id)
		}
		
		// Turn every T into a zombie
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id]) continue
			
			// Not a Terrorist
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_T)
				continue
			
			// Turn into a zombie
			MakeZombie(id)
		}
		
		// Play swarm sound
		iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_SWARM]) - 1)
		ArrayGetString(Array:g_startSound[SOUND_SWARM], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
		
		// Show Swarm HUD notice
		set_hudmessage(20, 255, 20, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Swarm mode !!!")
		
		// Create Fog 
		//CreateFog(0, 100, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

		// Execute out forward
		ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_SWARM, 0)
	}
	else if ((mode == MODE_NONE && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, MultiInfection_chance) == MultiInfection_enable && floatround(iPlayersnum * MultiInfection_ratio, floatround_ceil) >= 2 && floatround(iPlayersnum * MultiInfection_ratio, floatround_ceil) < iPlayersnum && iPlayersnum >= MultiInfection_minPlayers) || mode == MODE_MULTI_INFECTION)
	{
		// Multi Infection Mode
		SetBit(g_currentmode, MODE_MULTI_INFECTION)
		g_lastmode = MODE_MULTI_INFECTION
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround(iPlayersnum * MultiInfection_ratio, floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into zombies
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie
			if (!g_isalive[id] || CheckBit(g_playerTeam[id], TEAM_ZOMBIE))
				continue
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a zombie
				MakeZombie(id)
				iZombies++

				// Infection sound
				iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_INFECT]) - 1)
				ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_INFECT], iRand, buffer, charsmax(buffer))
				emit_sound(id, CHAN_VOICE, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		
		// Turn the remaining players into humans
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who aren't zombies
			if (!g_isalive[id] || CheckBit(g_playerTeam[id], TEAM_ZOMBIE))
				continue
			
			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
		
		// Play multi infection sound
		iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_MULTI_INFECTION]) - 1)
		ArrayGetString(Array:g_startSound[SOUND_MULTI_INFECTION], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
		
		// Show Multi Infection HUD notice
		set_hudmessage(200, 50, 0, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Multi-infection mode !!!")
		
		// Create Fog 
		//CreateFog(0, 128, 128, 128, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

		// Execute out forward
		ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_MULTI_INFECTION, 0)
	}
	else if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, Plague_chance) == Plague_enable && floatround((iPlayersnum - (Plague_nemesisCount+Plague_survivorCount)) * Plague_ratio, floatround_ceil) >= 1
	&& iPlayersnum - (Plague_survivorCount + Plague_nemesisCount + floatround((iPlayersnum - (Plague_nemesisCount + Plague_survivorCount)) * Plague_ratio, floatround_ceil)) >= 1 && iPlayersnum >= Plague_minPlayers) || mode == MODE_PLAGUE)
	{
		// Plague Mode
		SetBit(g_currentmode, MODE_PLAGUE)
		g_lastmode = MODE_PLAGUE
		
		// Turn specified amount of players into Survivors
		static iSurvivors, iMaxSurvivors
		iMaxSurvivors = Plague_survivorCount
		iSurvivors = 0
		
		while (iSurvivors < iMaxSurvivors)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			// Already a survivor?
			if (CheckBit(g_playerClass[id], CLASS_SURVIVOR)) continue
			
			// If not, turn him into one
			MakeHuman(id, CLASS_SURVIVOR)
			iSurvivors++
			
			// Apply survivor health multiplier
			set_user_health(id, floatround(float(pev(id, pev_health)) * Plague_survivor_HealthMultiply))
		}
		
		// Turn specified amount of players into Nemesis
		static iNemesis, iMaxNemesis
		iMaxNemesis = Plague_nemesisCount
		iNemesis = 0
		
		while (iNemesis < iMaxNemesis)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			// Already a survivor or nemesis?
			if (CheckBit(g_playerClass[id], CLASS_SURVIVOR) || CheckBit(g_playerClass[id], CLASS_NEMESIS))
			continue
			
			// If not, turn him into one
			MakeZombie(id, CLASS_NEMESIS)
			iNemesis++
			
			// Apply nemesis health multiplier
			set_user_health(id, floatround(float(pev(id, pev_health)) * Plague_nemesis_HealthMultiply))
		}
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround((iPlayersnum - (Plague_nemesisCount + Plague_survivorCount)) * Plague_ratio, floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into zombies
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or survivor
			if (!g_isalive[id] || CheckBit(g_playerTeam[id], TEAM_ZOMBIE) || CheckBit(g_playerClass[id], CLASS_SURVIVOR))
				continue
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a zombie
				MakeZombie(id)
				iZombies++
			}
		}
		
		// Turn the remaining players into humans
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or survivor
			if (!g_isalive[id] || CheckBit(g_playerTeam[id], TEAM_ZOMBIE) || CheckBit(g_playerClass[id], CLASS_SURVIVOR))
				continue
			
			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id + TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
		
		// Play plague sound
		iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_PLAGUE]) - 1)
		ArrayGetString(Array:g_startSound[SOUND_PLAGUE], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
		
		// Show Plague HUD notice
		set_hudmessage(0, 50, 200, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Plague mode !!!")
		
		// Create Fog 
		//CreateFog(0, 150, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

		// Execute out forward
		ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_PLAGUE, 0)
	}
	else if ((mode == MODE_NONE && (g_roundcount > 3) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, Synapsis_chance) == Synapsis_enable && floatround((iPlayersnum - (Synapsis_nemesisCount + Synapsis_survivorCount + Synapsis_sniperCount)) * Synapsis_ratio, floatround_ceil) >= 1
	&& iPlayersnum - (Synapsis_nemesisCount + Synapsis_survivorCount + Synapsis_sniperCount + floatround((iPlayersnum - (Synapsis_nemesisCount + Synapsis_survivorCount + Synapsis_sniperCount)) * Synapsis_ratio, floatround_ceil)) >= 1 && iPlayersnum >= Synapsis_minPlayers) || mode == MODE_SYNAPSIS)
	{
		// Synapsis Mode
		SetBit(g_currentmode, MODE_SYNAPSIS)
		g_lastmode = MODE_SYNAPSIS

		// Turn specified amount of players into Nemesis
		static iNemesis, iMaxNemesis
		iMaxNemesis = Synapsis_nemesisCount
		iNemesis = 0
		
		while (iNemesis < iMaxNemesis)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))

			if (!g_isalive[id] || CheckBit(g_playerClass[id], CLASS_NEMESIS)) continue
			
			// If not, turn him into one
			MakeZombie(id, CLASS_NEMESIS)
			iNemesis++
		
			// Apply nemesis health multiplier
			set_user_health(id, floatround(float(pev(id, pev_health)) * Synapsis_nemesis_HealthMultiply))
		}
		
		// Turn specified amount of players into Survivors
		static iSurvivors, iMaxSurvivors
		iMaxSurvivors = Synapsis_survivorCount
		iSurvivors = 0
		
		while (iSurvivors < iMaxSurvivors)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))

			// Check if the player is already a Nemesis, if yes then skip him
			if (!g_isalive[id] || CheckBit(g_playerClass[id], CLASS_NEMESIS) || CheckBit(g_playerClass[id], CLASS_SURVIVOR)) continue
			
			// If not, turn him into one
			MakeHuman(id, CLASS_SURVIVOR)
			iSurvivors++

			// Apply survivor health multiplier
			set_user_health(id, floatround(float(pev(id, pev_health)) * Synapsis_survivor_HealthMultiply))
		}

		// Turn specified amount of players into Snipers
		static iSnipers, iMaxSnipers
		iMaxSnipers = Synapsis_sniperCount
		iSnipers = 0
		
		while (iSnipers < iMaxSnipers)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			// Already a sniper or survivor ?
			if (!g_isalive[id] || CheckBit(g_playerClass[id], CLASS_NEMESIS) || CheckBit(g_playerClass[id], CLASS_SURVIVOR) || CheckBit(g_playerClass[id], CLASS_SNIPER)) continue
			
			// If not, turn him into one
			MakeHuman(id, CLASS_SNIPER)
			iSnipers++

			// Apply survivor health multiplier
			set_user_health(id, floatround(float(pev(id, pev_health)) * Synapsis_sniper_HealthMultiply))
		}
		
		// Turn the remaining players into humans
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or survivor
			if (!g_isalive[id] || CheckBit(g_playerClass[id], CLASS_SURVIVOR) || CheckBit(g_playerClass[id], CLASS_NEMESIS) || CheckBit(g_playerClass[id], CLASS_SNIPER))
				continue
			
			MakeHuman(id, CLASS_TRYDER)
		}
		
		// Play plague sound
		iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_SYNAPSIS]) - 1)
		ArrayGetString(Array:g_startSound[SOUND_SYNAPSIS], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
		
		// Show Plague HUD notice
		set_hudmessage(0, 50, 200, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Synapsis mode !!!")
		
		// Create Fog 
		//CreateFog(0, 150, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

		// Execute out forward
		ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_SYNAPSIS, 0)
	}
	else if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, Armageddon_chance) == Armageddon_enable && iPlayersnum >= Armageddon_minPlayers && iPlayersnum >= 2) || mode == MODE_SURVIVOR_VS_NEMESIS)
	{
		// Armageddon Mode
		SetBit(g_currentmode, MODE_SURVIVOR_VS_NEMESIS)
		g_lastmode = MODE_SURVIVOR_VS_NEMESIS
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround((iPlayersnum * Armageddon_ratio), floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into Nemesis
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or survivor
			if (!g_isalive[id] || CheckBit(g_playerTeam[id], TEAM_ZOMBIE) || CheckBit(g_playerClass[id], CLASS_SURVIVOR))
				continue
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a Nemesis
				MakeZombie(id, CLASS_NEMESIS)	
				set_user_health(id, floatround(float(pev(id, pev_health)) * Armageddon_nemesis_HealthMultiply))
				iZombies++
			}
		}
		
		// Turn the remaining players into survivors
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or survivor
			if (!g_isalive[id] || CheckBit(g_playerTeam[id], TEAM_ZOMBIE) || CheckBit(g_playerClass[id], CLASS_SURVIVOR))
				continue
			
			// Turn into a Survivor
			MakeHuman(id, CLASS_SURVIVOR)
			set_user_health(id, floatround(float(pev(id, pev_health)) * Armageddon_survivor_HealthMultiply))
		}
		
		// Play armageddon sound
		iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_SURVIVOR_VS_NEMESIS]) - 1)
		ArrayGetString(Array:g_startSound[SOUND_SURVIVOR_VS_NEMESIS], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
		
		// Show Armageddon HUD notice
		set_hudmessage(181, 62, 244, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Armageddon mode !!!")
		
		// Create Fog 
		//CreateFog(0, 150, 128, 1128, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

		// Execute out forward
		ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_SURVIVOR_VS_NEMESIS, 0)
	}
	else if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, SurvivorVsAssasin_chance) == SurvivorVsAssasin_enable && iPlayersnum >= SurvivorVsAssasin_minPlayers && iPlayersnum >= 2) || mode == MODE_SURVIVOR_VS_ASSASIN)
	{
		// Armageddon Mode
		SetBit(g_currentmode, MODE_SURVIVOR_VS_ASSASIN)
		g_lastmode = MODE_SURVIVOR_VS_ASSASIN
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround((iPlayersnum * SurvivorVsAssasin_ratio), floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into Assasin
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or survivor
			if (!g_isalive[id] || CheckBit(g_playerTeam[id], TEAM_ZOMBIE) || CheckBit(g_playerClass[id], CLASS_SURVIVOR))
				continue
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a Assasin
				MakeZombie(id, CLASS_ASSASIN)	
				set_user_health(id, floatround(float(pev(id, pev_health)) * SurvivorVsAssasin_assasin_HealthMultiply))
				iZombies++
			}
		}
		
		// Turn the remaining players into survivors
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or survivor
			if (!g_isalive[id] || CheckBit(g_playerTeam[id], TEAM_ZOMBIE) || CheckBit(g_playerClass[id], CLASS_SURVIVOR))
				continue
			
			// Turn into a Survivor
			MakeHuman(id, CLASS_SURVIVOR)
			set_user_health(id, floatround(float(pev(id, pev_health)) * SurvivorVsAssasin_survivor_HealthMultiply))
		}
		
		// Play armageddon sound
		iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_SURVIVOR_VS_ASSASIN]) - 1)
		ArrayGetString(Array:g_startSound[SOUND_SURVIVOR_VS_ASSASIN], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
		
		// Show Armageddon HUD notice
		set_hudmessage(181, 62, 244, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Survivor vs Assasin mode !!!")
		
		// Create Fog 
		//CreateFog(0, 150, 128, 1128, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

		// Execute out forward
		ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_SURVIVOR_VS_ASSASIN, 0)
	}
	else if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, Apocalypse_chance) == Apocalypse_enable && iPlayersnum >= Apocalypse_minPlayers && iPlayersnum >= 2) || mode == MODE_SNIPER_VS_ASSASIN)
	{
		// Apocalypse Mode
		SetBit(g_currentmode, MODE_SNIPER_VS_ASSASIN)
		g_lastmode = MODE_SNIPER_VS_ASSASIN
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround((iPlayersnum * Apocalypse_ratio), floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into Assassin
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or sniper
			if (!g_isalive[id] || CheckBit(g_playerTeam[id], TEAM_ZOMBIE) || CheckBit(g_playerClass[id], CLASS_SNIPER))
				continue
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a Assassin
				MakeZombie(id, CLASS_ASSASIN)
				set_user_health(id, floatround(float(pev(id, pev_health)) * Apocalypse_assasin_HealthMultiply))
				iZombies++
			}
		}
		
		// Turn the remaining players into snipers
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or sniper
			if (!g_isalive[id] || CheckBit(g_playerTeam[id], TEAM_ZOMBIE) || CheckBit(g_playerClass[id], CLASS_SNIPER))
				continue
			
			// Turn into a Sniper
			MakeHuman(id, CLASS_SNIPER)
			set_user_health(id, floatround(float(pev(id, pev_health)) * Apocalypse_sniper_HealthMultiply))
		}
		
		// Play apocalypse sound
		iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_SNIPER_VS_ASSASIN]) - 1)
		ArrayGetString(Array:g_startSound[SOUND_SNIPER_VS_ASSASIN], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
		
		// Show Apocalypse HUD notice
		set_hudmessage(181, 62, 244, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Sniper vs Assassin mode !!!")
		
		// Create Fog 
		//CreateFog(0, 100, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

		// Execute out forward
		ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_SNIPER_VS_ASSASIN, 0)
	}
	else if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, BombardierVsGrenadier_chance) == BombardierVsGrenadier_enable && iPlayersnum >= BombardierVsGrenadier_minPlayers && iPlayersnum >= 2) || mode == MODE_BOMBARDIER_VS_GRENADIER)
	{
		// Bombardier vs Grenadier Mode
		SetBit(g_currentmode, MODE_BOMBARDIER_VS_GRENADIER)
		g_lastmode = MODE_BOMBARDIER_VS_GRENADIER
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround((iPlayersnum * BombardierVsGrenadier_ratio), floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into Bombardier
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or Bombardier
			if (!g_isalive[id] || CheckBit(g_playerClass[id], CLASS_BOMBARDIER)) continue
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a Bombardier
				MakeZombie(id, CLASS_BOMBARDIER)
				set_user_health(id, floatround(float(pev(id, pev_health)) * BombardierVsGrenadier_bombardier_HealthMultiply))
				iZombies++
			}
		}
		
		// Turn the remaining players into Grenadiers
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or sniper
			if (!g_isalive[id] || CheckBit(g_playerTeam[id], TEAM_ZOMBIE) || CheckBit(g_playerClass[id], CLASS_GRENADIER)) continue
			
			// Turn into a Grenadier
			MakeHuman(id, CLASS_GRENADIER)
			set_user_health(id, floatround(float(pev(id, pev_health)) * BombardierVsGrenadier_grenadier_HealthMultiply))
		}
		
		// Play Bombardier vs Grenadier sound
		iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_BOMBARDIER_VS_GRENADIER]) - 1)
		ArrayGetString(Array:g_startSound[SOUND_BOMBARDIER_VS_GRENADIER], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
		
		// Show Bombardier vs Grenadier HUD notice
		set_hudmessage(181, 62, 244, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Bombardier vs Grenadier mode !!!")
		
		// Create Fog 
		//CreateFog(0, 100, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

		// Execute out forward
		ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_BOMBARDIER_VS_GRENADIER, 0)
	}
	else if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, Nightmare_chance) == Nightmare_enable && iPlayersnum >= Nightmare_minPlayers && iPlayersnum >= 4) || mode == MODE_NIGHTMARE)
	{
		// Nightmare mode
		SetBit(g_currentmode, MODE_NIGHTMARE)
		g_lastmode = MODE_NIGHTMARE
		
		iMaxZombies = floatround((iPlayersnum * 0.25), floatround_ceil)
		iZombies = 0
		
		while (iZombies < iMaxZombies)
		{
			if ((++id) > g_maxplayers) id = 1
			
			if (!g_isalive[id]) continue
			
			if (random_num(1, 5) == 1)
			{
				MakeZombie(id, CLASS_ASSASIN)	
				set_user_health(id, floatround(float(pev(id, pev_health)) * Nightmare_assasin_HealthMultiply))
				iZombies++
			}
		}
		
		iZombies = 0
		
		while (iZombies < iMaxZombies)
		{
			if ((++id) > g_maxplayers) id = 1
			
			if (!g_isalive[id] || CheckBit(g_playerClass[id], CLASS_ASSASIN))
				continue
			
			if (random_num(1, 5) == 1)
			{
				MakeZombie(id, CLASS_NEMESIS)	
				set_user_health(id, floatround(float(pev(id, pev_health)) * Nightmare_nemesis_HealthMultiply))
				iZombies++
			}
		}
		
		iZombies = 0
		
		while (iZombies < iMaxZombies)
		{
			if ((++id) > g_maxplayers) id = 1
			
			if (!g_isalive[id] || CheckBit(g_playerClass[id], CLASS_ASSASIN) || CheckBit(g_playerClass[id], CLASS_NEMESIS))
				continue
			
			if (random_num(1, 5) == 1)
			{
				MakeHuman(id, CLASS_SURVIVOR)
				set_user_health(id, floatround(float(pev(id, pev_health)) * Nightmare_survivor_HealthMultiply))
				iZombies++
			}
		}
		
		for (id = 1; id <= g_maxplayers; id++)
		{
			if (!g_isalive[id] || CheckBit(g_playerClass[id], CLASS_ASSASIN) || CheckBit(g_playerClass[id], CLASS_NEMESIS) || CheckBit(g_playerClass[id], CLASS_SURVIVOR))
				continue

			MakeHuman(id, CLASS_SNIPER)
			set_user_health(id, floatround(float(pev(id, pev_health)) * Nightmare_sniper_HealthMultiply))
		}
		
		// Play nightmare sound
		iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_NIGHTMARE]) - 1)
		ArrayGetString(Array:g_startSound[SOUND_NIGHTMARE], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
		
		// Show Nightmare HUD notice
		set_hudmessage(181, 62, 244, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Nightmare mode !!!")
		
		// Create Fog 
		//CreateFog(0, 100, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

		// Execute out forward
		ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_NIGHTMARE, 0)
	}
	else if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, SniperVsNemesis_chance) == SniperVsNemesis_enable && iPlayersnum >= SniperVsNemesis_minPlayers && iPlayersnum >= 2) || mode == MODE_SNIPER_VS_NEMESIS)
	{
		// Devil Mode ( Sniper vs Nemesis)
		SetBit(g_currentmode, MODE_SNIPER_VS_NEMESIS)
		g_lastmode = MODE_SNIPER_VS_NEMESIS
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround((iPlayersnum * SniperVsNemesis_ratio), floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into Nemesis
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or sniper
			if (!g_isalive[id] || CheckBit(g_playerTeam[id], TEAM_ZOMBIE) || CheckBit(g_playerClass[id], CLASS_SNIPER))
				continue
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a Nemesis
				MakeZombie(id, CLASS_NEMESIS)	
				set_user_health(id, floatround(float(pev(id, pev_health)) * SniperVsNemesis_nemesis_HealthMultiply))
				iZombies++
			}
		}
		
		// Turn the remaining players into Snipers
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or sniper
			if (!g_isalive[id] || CheckBit(g_playerTeam[id], TEAM_ZOMBIE) || CheckBit(g_playerClass[id], CLASS_SNIPER))
				continue
			
			// Turn into a Sniper
			MakeHuman(id, CLASS_SNIPER)
			set_user_health(id, floatround(float(pev(id, pev_health)) * SniperVsNemesis_sniper_HealthMultiply))
		}
		
		// Play devil sound
		iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_SNIPER_VS_NEMESIS]) - 1)
		ArrayGetString(Array:g_startSound[SOUND_SNIPER_VS_NEMESIS], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
		
		// Show Devil HUD notice
		set_hudmessage(181, 62, 244, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Sniper vs Nemesis mode !!!")
		
		// Create Fog 
		//CreateFog(0, 100, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)

		// Execute out forward
		ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_SNIPER_VS_NEMESIS, 0)
	}
	else
	{
		// Single Infection Mode or Nemesis Mode
		
		// Choose player randomly?
		if (mode == MODE_NONE)
		id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, NemesisChance) == NemesisEnabled && iPlayersnum >= NemesisMinPlayers) || mode == MODE_NEMESIS)
		{
			// Nemesis Mode
			SetBit(g_currentmode, MODE_NEMESIS)
			g_lastmode = MODE_NEMESIS

			// Turn player into nemesis
			MakeZombie(id, CLASS_NEMESIS)

			// Save his index for future use
			g_lastSpecialZombieIndex = id

			// Play Nemesis sound
			iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_NEMESIS]) - 1)
			ArrayGetString(Array:g_startSound[SOUND_NEMESIS], iRand, buffer, charsmax(buffer))
			PlaySound(buffer)
			
			// Show Nemesis HUD notice
			set_hudmessage(255, 20, 20, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
			ShowSyncHudMsg(0, g_MsgSync, "%s is Nemesis !!!", g_playerName[forward_id])

			// Set Reminder task
			set_task(30.0, "TaskReminder", TASK_REMINDER, _, _, "b")
			
			// Mode fully started!
			g_modestarted = true

			if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)
			
			// Create Fog 
			//CreateFog(0, 200, 200, 100, 0.0008)

			// Execute out forward
			ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_NEMESIS, forward_id)
		}
		else if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, AssassinChance) == AssassinEnabled && iPlayersnum >= AssassinMinPlayers) || mode == MODE_ASSASIN)
		{
			// Assassin Mode
			SetBit(g_currentmode, MODE_ASSASIN)
			g_lastmode = MODE_ASSASIN

			// Set lighting for Assassin mode
			engfunc(EngFunc_LightStyle, 0, "a") // Set lighting
			
			// Turn player into assassin
			MakeZombie(id, CLASS_ASSASIN)

			// Save his index for future use
			g_lastSpecialZombieIndex = id

			// Play Assassin sound
			iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_ASSASIN]) - 1)
			ArrayGetString(Array:g_startSound[SOUND_ASSASIN], iRand, buffer, charsmax(buffer))
			PlaySound(buffer)
			
			// Show Assassin HUD notice
			set_hudmessage(255, 255, 20, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
			ShowSyncHudMsg(0, g_MsgSync, "%s is Assassin !!!", g_playerName[forward_id])

			// Set Reminder task
			set_task(30.0, "TaskReminder", TASK_REMINDER, _, _, "b")
			
			// Create Fog 
			//CreateFog(0, 200, 200, 100, 0.0008)

			if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)
			
			// Mode fully started!
			g_modestarted = true

			// Execute out forward
			ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_ASSASIN, forward_id)
		}
		else if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, BombardierChance) == BombardierEnabled && iPlayersnum >= BombardierMinPlayers) || mode == MODE_BOMBARDIER)
		{
			// Bombardier Mode
			SetBit(g_currentmode, MODE_BOMBARDIER)
			g_lastmode = MODE_BOMBARDIER
			
			// Turn player into bombardier
			MakeZombie(id, CLASS_BOMBARDIER)

			// Save his index for future use
			g_lastSpecialZombieIndex = id

			// Play Bombardier sound
			iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_BOMBARDIER]) - 1)
			ArrayGetString(Array:g_startSound[SOUND_BOMBARDIER], iRand, buffer, charsmax(buffer))
			PlaySound(buffer)
			
			// Show Bombardier HUD notice
			set_hudmessage(255, 255, 20, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
			ShowSyncHudMsg(0, g_MsgSync, "%s is Bombardier !!!", g_playerName[forward_id])

			// Set Reminder task
			set_task(30.0, "TaskReminder", TASK_REMINDER, _, _, "b")
			
			// Create Fog 
			//CreateFog(0, 200, 200, 100, 0.0008)

			if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)
			
			// Mode fully started!
			g_modestarted = true

			// Execute out forward
			ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_BOMBARDIER, forward_id)
		}
		else if ((mode == MODE_NONE && (g_roundcount > 8) && (!PreventConsecutiveRounds || g_lastmode == MODE_INFECTION) && random_num(1, RevenantChance) == RevenantEnabled && iPlayersnum >= RevenantMinPlayers) || mode == MODE_REVENANT)
		{
			// Revenant Mode
			SetBit(g_currentmode, MODE_REVENANT)
			g_lastmode = MODE_REVENANT
			
			// Turn player into revenant
			MakeZombie(id, CLASS_REVENANT)

			// Save his index for future use
			g_lastSpecialZombieIndex = id

			// Play Revenant sound
			iRand = random_num(0, ArraySize(Array:g_startSound[SOUND_REVENANT]) - 1)
			ArrayGetString(Array:g_startSound[SOUND_REVENANT], iRand, buffer, charsmax(buffer))
			PlaySound(buffer)
			
			// Show Revvenant HUD notice
			set_hudmessage(255, 255, 20, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
			ShowSyncHudMsg(0, g_MsgSync, "%s is Revenant !!!", g_playerName[forward_id])

			// Set Reminder task
			set_task(30.0, "TaskReminder", TASK_REMINDER, _, _, "b")
			
			// Create Fog 
			//CreateFog(0, 200, 200, 100, 0.0008)

			if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)
			
			// Mode fully started!
			g_modestarted = true

			// Execute out forward
			ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_REVENANT, forward_id)
		}
		else 
		{
			// Single Infection Mode
			SetBit(g_currentmode, MODE_INFECTION)
			g_lastmode = MODE_INFECTION
			
			// Turn player into the first zombie
			MakeZombie(id)

			// Show First Zombie HUD notice
			set_hudmessage(255, 0, 0, HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 5.0, 1.0, 1.0, -1)
			ShowSyncHudMsg(0, g_MsgSync, "%s is the first zombie !!", g_playerName[forward_id])
			
			// Create Fog 
			//CreateFog(0, 128, 175, 200, 0.0008)

			if (task_exists(TASK_COUNTDOWN)) remove_task(TASK_COUNTDOWN)
			
			// Mode fully started!
			g_modestarted = true

			// Execute out forward
			ExecuteForward(g_forwards[ROUND_START], g_forwardRetVal, MODE_INFECTION, forward_id)
		}
		
		// Remaining players should be humans (CTs)
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id]) continue
			
			// First zombie/nemesis
			if (CheckBit(g_playerTeam[id], TEAM_ZOMBIE)) continue
			
			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
	}
	
	// Start ambience sounds after a mode begins
	remove_task(TASK_AMBIENCESOUNDS)
	set_task(2.0, "StartAmbienceSounds", TASK_AMBIENCESOUNDS)
}

public TaskRemoveRender(infector){ remove_glow(infector); }

// Zombie Me Function (player id, infector, turn into a nemesis, silent mode, deathmsg and rewards)
MakeZombie(victim, class = CLASS_ZOMBIE, infector = 0)
{
	ExecuteForward(g_forwards[INFECT_ATTEMP], g_forwardRetVal, victim, infector, class) // User infect attempt forward
	
	// One or more plugins blocked the infection. Only allow this after making sure it's
	// not going to leave us with no zombies. Take into account a last player leaving case.
	// BUGFIX: only allow after a mode has started, to prevent blocking first zombie e.g.
	if (g_forwardRetVal >= ZP_PLUGIN_HANDLED && g_modestarted && fnGetZombies() > g_lastplayerleaving) return
	
	ExecuteForward(g_forwards[INFECTED_PRE], g_forwardRetVal, victim, infector, class) // Pre user infect forward

	// Way to go...
	g_playerTeam[victim] = TEAM_ZOMBIE
	//SetBit(g_playerTeam[victim], TEAM_ZOMBIE)
	
	g_playerClass[victim] = 0

	g_specialclass[victim] = false
	g_firstzombie[victim] = false

	set_zombie(victim, true)	// For Module
	g_goldenweapons[victim] = false

	// Jetpack
	if (get_user_jetpack(victim))
		user_drop_jetpack(victim, 1)

	// Fix for glow
	remove_glow(victim)

	static iRand, buffer[100]

	if (g_isbot[victim])
		g_zombieclass[victim] = random_num(0, 6)

	// Show zombie class menu if they haven't chosen any (e.g. just connected)
	if (g_zombieclassnext[victim] == -1)
		menu_display(victim, g_iZombieClassMenu, 0)
	
	// Set selected zombie class
	g_zombieclass[victim] = g_zombieclassnext[victim]

	// Set random class if player didnt choose any
	if (g_zombieclass[victim] == -1)
		g_zombieclass[victim] = random_num(0, 6)
	
	// For Class strings and few var checks
	switch (g_zombieclass[victim])
	{
		case 0:	g_classString[victim] = "Classic"
		case 1:	g_classString[victim] = "Raptor"
		case 2:	g_classString[victim] = "Mutant"
		case 3:	g_classString[victim] = "Frost"
		case 4:	g_classString[victim] = "Regenerator"
		case 5:	g_classString[victim] = "Predator Blue"
		case 6:	g_classString[victim] = "Hunter"
	}

	
	// Remove spawn protection (bugfix)
	g_nodamage[victim] = false
	set_pev(victim, pev_effects, pev(victim, pev_effects) &~ EF_NODRAW)
	
	// Reset burning duration counter (bugfix)
	g_burning_duration[victim] = 0

	// Set zombie attributes based on the mode
	switch (class)
	{
		case CLASS_NEMESIS:
		{
			// Nemesis
			SetBit(g_playerClass[victim], CLASS_NEMESIS)
			g_classString[victim] = "Nemesis"
			g_specialclass[victim] = true
			
			// Set health and model
			set_user_health(victim, NemesisHealth)
			
			// Set gravity and glow, if frozen set the restore gravity value instead
			if (!g_frozen[victim]) 
			{
				set_pev(victim, pev_gravity, NemesisGravity)

				// Set Glow
				if (NemesisGlow) set_glow(victim, g_glowColor[__nemesis][__red], g_glowColor[__nemesis][__green], g_glowColor[__nemesis][__blue], 25)
				else remove_glow(victim)
			}
			else g_frozen_gravity[victim] = NemesisGravity

			// Set nemesis maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)
			
			//set_task(7.0, "EarthQuake", _, _, _, "b")
		}
		case CLASS_ASSASIN:
		{
			// Assassin
			SetBit(g_playerClass[victim], CLASS_ASSASIN)
			g_classString[victim] = "Assassin"
			g_specialclass[victim] = true
			
			// Set health [0 = auto]
			set_user_health(victim, AssassinHealth)

			// Set gravity and glow, if frozen set the restore gravity value instead
			if (!g_frozen[victim]) 
			{
				set_pev(victim, pev_gravity, AssassinGravity)

				// Set Glow
				if (AssassinGlow) set_glow(victim, g_glowColor[__assasin][__red], g_glowColor[__assasin][__green], g_glowColor[__assasin][__blue], 25)
				else remove_glow(victim)
			}
			else g_frozen_gravity[victim] = AssassinGravity

			// Set assassin maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)
		}
		case CLASS_BOMBARDIER:
		{
			// Bombardier
			SetBit(g_playerClass[victim], CLASS_BOMBARDIER)
			g_classString[victim] = "Bombardier"
			g_specialclass[victim] = true
			
			// Set health
			set_user_health(victim, BombardierHealth)	
			
			// Set gravity, if frozen set the restore gravity value instead
			if (!g_frozen[victim]) 
			{
				set_pev(victim, pev_gravity, BombardierGravity)

				// Set glow
				if (BombardierGlow) set_glow(victim, g_glowColor[__bombardier][__red], g_glowColor[__bombardier][__green], g_glowColor[__bombardier][__blue], 25)
				else remove_glow(victim)
			}
			else g_frozen_gravity[victim] = BombardierGravity

			// Set bombardier maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)
		}
		case CLASS_REVENANT:
		{
			// Revenant
			SetBit(g_playerClass[victim], CLASS_REVENANT)
			g_classString[victim] = "Revenant"
			g_specialclass[victim] = true
			
			// Set health
			set_user_health(victim, RevenantHealth)	
			
			// Set gravity, if frozen set the restore gravity value instead
			if (!g_frozen[victim]) 
			{
				set_pev(victim, pev_gravity, Revenantgravity)

				// Set glow
				if (RevenantGlow) set_glow(victim, g_glowColor[__revenant][__red], g_glowColor[__revenant][__green], g_glowColor[__revenant][__blue], 25)
				else remove_glow(victim)
			}
			else g_frozen_gravity[victim] = Revenantgravity

			// Set revenant maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)
		}
		case CLASS_ZOMBIE:
		{
			SetBit(g_playerClass[victim], CLASS_ZOMBIE)
			g_specialclass[victim] = false

			// Give all zombies multijump
			g_jumpnum[victim] = 1
			
			if (fnGetZombies() == 1 && CheckBit(g_currentmode, MODE_INFECTION))
			{
				g_firstzombie[victim] = true

				// Set health
				set_user_health(victim, floatround(float(g_cZombieClasses[g_zombieclass[victim]][Health]) * FirstZombieHealth))

				// Infection sound
				iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_INFECT]) - 1)
				ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_INFECT], iRand, buffer, charsmax(buffer))
				emit_sound(victim, CHAN_VOICE, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
			else set_user_health(victim, g_cZombieClasses[g_zombieclass[victim]][Health])

			// Set gravity, if frozen set the restore gravity value instead
			if (!g_frozen[victim]) set_pev(victim, pev_gravity, Float:g_cZombieClasses[g_zombieclass[victim]][Gravity])
			else g_frozen_gravity[victim] = Float:g_cZombieClasses[g_zombieclass[victim]][Gravity]
			
			// Set zombie maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)
					
			if (infector) // infected by someone?
			{
				// Infection sound
				iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_INFECT]) - 1)
				ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_INFECT], iRand, buffer, charsmax(buffer))
				emit_sound(victim, CHAN_VOICE, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)

				set_user_health(infector, pev(infector, pev_health) + 300)
				set_glow(infector, 0, 255, 0, 25)
				set_task(3.0, "TaskRemoveRender", infector)

				// Show Infection HUD notice
				set_hudmessage(0, 255, 0, -1.00, 0.10, 1, 0.00, 1.75, 1.00, 1.00, -1)
				ShowSyncHudMsg(infector, g_MsgSync4, "== INFECTION ==^n!!!!Regeneration: +250 HP Gained!!!")

				// Show Infection HUD notice
				set_hudmessage(255, 0, 0, HUD_INFECT_X, HUD_INFECT_Y, 0, 0.0, 5.0, 1.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "%s's brain is eaten by %s...", g_playerName[victim], g_playerName[infector])
			}
		}
	}
	
	// Remove previous tasks
	remove_task(victim + TASK_MODEL)
	remove_task(victim + TASK_BLOOD)
	remove_task(victim + TASK_BURN)
	
	// Set the right model, after checking that we don't already have it
	static Float:current_time
	current_time = get_gametime()
	if (current_time - g_models_targettime >= g_modelchange_delay)
	{
		ChangeModels(victim + TASK_MODEL)
		g_models_targettime = current_time
	}
	else
	{
		set_task((g_models_targettime + g_modelchange_delay) - current_time, "ChangeModels", victim + TASK_MODEL)
		g_models_targettime = g_models_targettime + g_modelchange_delay
	}
	
	// Switch to T
	if (fm_cs_get_user_team(victim) != FM_CS_TEAM_T) // need to change team?
	{
		remove_task(victim+TASK_TEAM)
		fm_cs_set_user_team(victim, FM_CS_TEAM_T)
		fm_user_team_update(victim)
	}
	
	// Remove any zoom (bugfix)
	cs_set_user_zoom(victim, CS_RESET_ZOOM, 1)
	
	// Remove armor
	cs_set_user_armor(victim, 0, CS_ARMOR_NONE)
	
	// Drop weapons when infected
	drop_weapons(victim, 1)
	drop_weapons(victim, 2)
	
	// Strip zombies from guns and give them a knife
	fm_strip_user_weapons(victim)
	fm_give_item(victim, "weapon_knife")
	
	// Give Bombardier Killing grenade
	if (CheckBit(g_playerClass[victim], CLASS_BOMBARDIER)) { fm_give_item(victim, "weapon_hegrenade"); client_cmd(victim, "weapon_hegrenade"); }

	if (g_firstzombie[victim])
		if (!CheckBit(g_currentmode, MODE_SWARM) && 
		!CheckBit(g_currentmode, MODE_PLAGUE) && 
		!CheckBit(g_currentmode, MODE_SNIPER) && 
		!CheckBit(g_currentmode, MODE_SURVIVOR) && 
		!CheckBit(g_currentmode, MODE_SAMURAI) &&
		!CheckBit(g_currentmode, MODE_TERMINATOR)) fm_give_item(victim, "weapon_hegrenade")
	
	// Fancy effects
	infection_effects(victim)
	
	// Remove CS nightvision if player owns one (bugfix)
	if (cs_get_user_nvg(victim))
	{
		cs_set_user_nvg(victim, 0)
		if (CustomNightVision) remove_task(victim+TASK_NVISION)
		else if (g_nvisionenabled[victim]) set_user_gnvision(victim, 0)
	}
	
	// Give Zombies Night Vision?
	if (NightVisionEnabled)
	{
		g_nvision[victim] = true
		
		if (!g_isbot[victim])
		{
			// Turn on Night Vision automatically?
			if (NightVisionEnabled)
			{
				g_nvisionenabled[victim] = true
				
				// Custom nvg?
				if (CustomNightVision)
				{
					remove_task(victim+TASK_NVISION)
					set_task(0.1, "set_user_nvision", victim + TASK_NVISION, _, _, "b")
				}
				else set_user_gnvision(victim, 1)
			}
			// Turn off nightvision when infected (bugfix)
			else if (g_nvisionenabled[victim])
			{
				if (CustomNightVision) remove_task(victim + TASK_NVISION)
				else set_user_gnvision(victim, 0)
				g_nvisionenabled[victim] = false
			}
		}
		else cs_set_user_nvg(victim, 1) // turn on NVG for bots
	}
	// Disable nightvision when infected (bugfix)
	else if (g_nvision[victim])
	{
		if (CustomNightVision) remove_task(victim+TASK_NVISION)
		else if (g_nvisionenabled[victim]) set_user_gnvision(victim, 0)
		g_nvision[victim] = false
		g_nvisionenabled[victim] = false
	}
	
	// Set custom FOV?
	SetFOV(victim, ZombieFOV)
	
	// Call the bloody task
	if (CheckBit(g_playerClass[victim], CLASS_ZOMBIE) && ZombieBleeding)
		set_task(0.7, "make_blood", victim + TASK_BLOOD, _, _, "b")
	
	// Idle sounds task
	if (CheckBit(g_playerClass[victim], CLASS_ZOMBIE))
		set_task(random_float(50.0, 70.0), "zombie_play_idle", victim + TASK_BLOOD, _, _, "b")
	
	// Turn off zombie's flashlight
	turn_off_flashlight(victim)

	// Remove tasks
	if (task_exists(victim + TASK_CONCUSSION)) remove_task(victim + TASK_CONCUSSION)

	// Show VIP
	if (g_vip[victim]) Show_VIP()

	// Reset some vars
	g_antidotebomb[victim] = 0
	g_concussionbomb[victim] = 0
	g_bubblebomb[victim] = 0
	g_killingbomb[victim] = 0
	g_norecoil[victim] = false
	g_has_crossbow[victim] = false
	if (g_multijump[victim]) g_jumpnum[victim] = 0

	// Execute our post user infect forward
	ExecuteForward(g_forwards[INFECTED_POST], g_forwardRetVal, victim, infector, class) 
	
	// Last Zombie Check
	fnCheckLastZombie()
}

// Function Human Me (player id, turn into a survivor, silent mode)
MakeHuman(id, class = CLASS_HUMAN)
{	
	ExecuteForward(g_forwards[HUMANIZE_ATTEMP], g_forwardRetVal, id, class) // User humanize attempt forward
	
	// One or more plugins blocked the "humanization". Only allow this after making sure it's
	// not going to leave us with no humans. Take into account a last player leaving case.
	// BUGFIX: only allow after a mode has started, to prevent blocking first survivor e.g.
	if (g_forwardRetVal >= ZP_PLUGIN_HANDLED && g_modestarted && fnGetHumans() > g_lastplayerleaving) return

	ExecuteForward(g_forwards[HUMANIZED_PRE], g_forwardRetVal, id, class) // Pre user humanize forward

	set_zombie(id, false)		// For module

	// Remove previous tasks
	remove_task(id + TASK_MODEL)
	remove_task(id + TASK_BLOOD)
	remove_task(id + TASK_BURN)
	remove_task(id + TASK_NVISION)

	g_playerTeam[id] = TEAM_HUMAN
	//SetBit(g_playerTeam[id], TEAM_HUMAN)
	g_playerClass[id] = 0
	g_specialclass[id] = false
	g_firstzombie[id] = false
	g_canbuy[id] = true
	g_buytime[id] = get_gametime()
	
	// Remove spawn protection (bugfix)
	g_nodamage[id] = false
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_NODRAW)
	
	// Reset burning duration counter (bugfix)
	g_burning_duration[id] = 0
	
	// Remove CS nightvision if player owns one (bugfix)
	if (cs_get_user_nvg(id))
	{
		cs_set_user_nvg(id, 0)
		if (CustomNightVision) remove_task(id + TASK_NVISION)
		else if (g_nvisionenabled[id]) set_user_gnvision(id, 0)
	}
	
	// Drop previous weapons
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	
	// Strip off from weapons
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
	
	// Set human attributes based on the mode
	switch (class)
	{
		case CLASS_HUMAN:
		{
			SetBit(g_playerClass[id], CLASS_HUMAN)

			// Set class string
			g_classString[id] = "Human"

			// Set health
			set_user_health(id, HumanHealth)
			
			// Set gravity, if frozen set the restore gravity value instead
			if (!g_frozen[id]) set_pev(id, pev_gravity, HumanGravity)
			else g_frozen_gravity[id] = HumanGravity
			
			// Set human maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
			
			// Show custom buy menu
			set_task(0.2, "show_menu_buy1", id + TASK_SPAWN)
		}
		case CLASS_TRYDER:
		{
			// Tryder
			SetBit(g_playerClass[id], CLASS_TRYDER)
			g_specialclass[id] = false
			g_classString[id] = "Tryder"
			
			// Set Health [0 = auto]
			set_user_health(id, TryderHealth)

			// Set armor
			set_pev(id, pev_armorvalue, 777.0)

			// Set tryder maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
			
			// Set gravity and glow, unless frozen
			if (!g_frozen[id]) 
			{
				set_pev(id, pev_gravity, TryderGravity)

				// Set glow
				if (TryderGlow)
				{
					switch (random_num(0, 1))
					{
						case 0: set_glow(id, 155, 48, 255, 25)
						case 1: set_glow(id, 250, 10, 175, 25)
					}
				}
				else remove_glow(id)
			}
			
			// Give tryder his own weapon		
			set_weapon(id, CSW_AK47, 1000)
			set_weapon(id, CSW_M4A1, 1000)
			set_weapon(id, CSW_XM1014, 1000)
			set_weapon(id, CSW_SG552, 1000)
			set_weapon(id, CSW_SG550, 1000)
			set_weapon(id, CSW_HEGRENADE, 5)
			set_weapon(id, CSW_FLASHBANG, 5)
			set_weapon(id, CSW_SMOKEGRENADE, 5)
			
			// Turn off his flashlight
			turn_off_flashlight(id)
			
			// Tryder bots will also need nightvision to see in the dark
			if (g_isbot[id])
			{
				g_nvision[id] = true
				cs_set_user_nvg(id, 1)
			}
		}
		case CLASS_SURVIVOR:
		{
			// Survivor
			SetBit(g_playerClass[id], CLASS_SURVIVOR)
			g_specialclass[id] = true
			g_classString[id] = "Survivor"
			
			// Set Health [0 = auto]
			set_user_health(id, SurvivorHealth)
			
			// Set gravity and glow, if frozen set the restore gravity value instead
			if (!g_frozen[id]) 
			{
				set_pev(id, pev_gravity, SurvivorGravity)

				// Set glow
				if (SurvivorGlow) set_glow(id, g_glowColor[__survivor][__red], g_glowColor[__survivor][__green], g_glowColor[__survivor][__blue], 25)
				else remove_glow(id)
			}
			
			// Set survivor maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
			
			// Give survivor his own weapon
			set_weapon(id, CSW_XM1014, 1000)
			set_weapon(id, CSW_AK47, 1000)
			set_weapon(id, CSW_M4A1, 1000)
			set_weapon(id, CSW_DEAGLE, 1000)
			set_weapon(id, CSW_HEGRENADE, 5)
			
			// Turn off his flashlight
			turn_off_flashlight(id)
			
			// Survivor bots will also need nightvision to see in the dark
			if (g_isbot[id])
			{
				g_nvision[id] = true
				cs_set_user_nvg(id, 1)
			}
		}
		case CLASS_SNIPER:
		{
			// Sniper
			SetBit(g_playerClass[id], CLASS_SNIPER)
			g_specialclass[id] = true
			g_classString[id] = "Sniper"
			
			// Set Health
			set_user_health(id, SniperHealth)

			// Set sniper maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
			
			// Set gravity and glow, unless frozen
			if (!g_frozen[id]) 
			{
				set_pev(id, pev_gravity, SniperGravity)

				// Set glow
				if (SniperGlow) set_glow(id, g_glowColor[__sniper][__red], g_glowColor[__sniper][__green], g_glowColor[__sniper][__blue], 25)
				else remove_glow(id)
			}
			
			// Give sniper his own weapon		
			set_weapon(id, CSW_AWP, 200)
			set_weapon(id, CSW_DEAGLE, 1000)
			set_weapon(id, CSW_HEGRENADE, 5)
			
			// Turn off his flashlight
			turn_off_flashlight(id)
			
			// Sniper bots will also need nightvision to see in the dark
			if (g_isbot[id])
			{
				g_nvision[id] = true
				cs_set_user_nvg(id, 1)
			}
		}
		case CLASS_SAMURAI:
		{
			// Samurai
			SetBit(g_playerClass[id], CLASS_SAMURAI)
			g_specialclass[id] = true
			g_classString[id] = "Samurai"
			
			// Set Health [0 = auto]
			set_user_health(id, SamuraiHealth)

			// Set samurai maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
			
			// Set gravity and glow, unless frozen
			if (!g_frozen[id]) 
			{
				set_pev(id, pev_gravity, SamuraiGravity)

				// Set glow
				if (SamuraiGlow) set_glow(id, g_glowColor[__samurai][__red], g_glowColor[__samurai][__green], g_glowColor[__samurai][__blue], 25)
				else remove_glow(id)
			}
			
			// Give Samurai his own weapon		
			fm_give_item(id, "weapon_knife")                
			
			// Models fix
			replace_weapon_models(id, CSW_KNIFE)
			
			// Turn off his flashlight
			turn_off_flashlight(id)
			
			// Samurai bots will also need nightvision to see in the dark
			if (g_isbot[id])
			{
				g_nvision[id] = true
				cs_set_user_nvg(id, 1)
			}
		}
		case CLASS_GRENADIER:
		{
			// Samurai
			SetBit(g_playerClass[id], CLASS_GRENADIER)
			g_specialclass[id] = true
			g_classString[id] = "Grenadier"
			
			// Set Health [0 = auto]
			set_user_health(id, GrenadierHealth)

			// Set grenadier maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
			
			// Set gravity and glow, unless frozen
			if (!g_frozen[id]) 
			{
				set_pev(id, pev_gravity, GrenadierGravity)

				// Set glow
				if (GrenadierGlow) set_glow(id, g_glowColor[__grenadier][__red], g_glowColor[__grenadier][__green], g_glowColor[__grenadier][__blue], 25)
				else remove_glow(id)
			}
			
			// Give Grenadier his own weapon	
			set_weapon(id, CSW_HEGRENADE, 1)
			client_cmd(id, "weapon_hegrenade")	           
			
			// Models fix
			replace_weapon_models(id, CSW_HEGRENADE)
			
			// Turn off his flashlight
			turn_off_flashlight(id)
			
			// Grenadier bots will also need nightvision to see in the dark
			if (g_isbot[id])
			{
				g_nvision[id] = true
				cs_set_user_nvg(id, 1)
			}
		}
		case CLASS_TERMINATOR:
		{
			// Terminator
			SetBit(g_playerClass[id], CLASS_TERMINATOR)
			g_specialclass[id] = true
			g_classString[id] = "Terminator"
			
			// Set Health [0 = auto]
			set_user_health(id, TerminatorHealth)

			// Set terminator maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
			
			// Set gravity and glow, unless frozen
			if (!g_frozen[id]) 
			{
				set_pev(id, pev_gravity, TerminatorGravity)

				// Set glow
				if (TerminatorGlow) set_glow(id, g_glowColor[__terminator][__red], g_glowColor[__terminator][__green], g_glowColor[__terminator][__blue], 25)
				else remove_glow(id)
			}
			
			// Give Terminator his own weapon	
			set_weapon(id, CSW_MP5NAVY, 10000)	           
			
			// Turn off his flashlight
			turn_off_flashlight(id)
			
			// Grenadier bots will also need nightvision to see in the dark
			if (g_isbot[id])
			{
				g_nvision[id] = true
				cs_set_user_nvg(id, 1)
			}
		}
	}
	
	// Switch to CT
	if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
	{
		remove_task(id + TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		fm_user_team_update(id)
	}
	
	// Set the right model, after checking that we don't already have it
	static Float:current_time
	current_time = get_gametime()
	
	if (current_time - g_models_targettime >= g_modelchange_delay)
	{
		ChangeModels(id + TASK_MODEL)
		g_models_targettime = current_time
	}
	else
	{
		set_task((g_models_targettime + g_modelchange_delay) - current_time, "ChangeModels", id + TASK_MODEL)
		g_models_targettime = g_models_targettime + g_modelchange_delay
	}
	
	// Restore FOV?
	SetFOV(id, 90)
	
	// Disable nightvision when turning into human/survivor (bugfix)
	if (g_nvision[id])
	{
		if (CustomNightVision) remove_task(id+TASK_NVISION)
		else if (g_nvisionenabled[id]) set_user_gnvision(id, 0)

		g_nvision[id] = false
		g_nvisionenabled[id] = false
	}
	
	// Execute our Humanized Post forward
	ExecuteForward(g_forwards[HUMANIZED_POST], g_forwardRetVal, id, class)

	// Last Zombie Check
	fnCheckLastZombie()
}

/*================================================================================
	[Other Functions and Tasks]
=================================================================================*/

public cache_cvars()
{
	g_cached_zombiesilent 			= ZombieSilentFootSteps
	g_cached_customflash 			= FlashLightEnabled
	g_cached_leapzombiescooldown 	= LeapZombiesCooldown
	g_cached_leapnemesis 			= LeapNemesis
	g_cached_leapnemesiscooldown 	= LeapNemesisCooldown
	g_cached_leapassassin 			= LeapAssassin
	g_cached_leapassassincooldown 	= LeapAssassinCooldown
	g_cached_leapsurvivor 			= LeapSurvivor
	g_cached_leapsurvivorcooldown 	= LeapSurvivorCooldown
	g_cached_leapsniper 			= LeapSniper
	g_cached_leapsnipercooldown 	= LeapSniperCooldown
	g_cached_leapzadoc 				= LeapSamurai		
	g_cached_leapzadoccooldown 		= LeapSamuraiCooldown
	g_cached_leapgrenadier			= LeapGrenadier		
	g_cached_leapgrenadiercooldown	= LeapGrenadierCooldown
	g_cached_leapbombardier 		= LeapBombardier		
	g_cached_leapbombardiercooldown = LeapBombardierCooldown
	g_cached_leaprevenant           = LeapRevenant
	g_cached_leaprevenantcooldown   = LeapRevenantCooldown
	g_cached_leapterminator 		= LeapTerminator
	g_cached_leapterminatorcooldown = LeapTerminatorCooldown
}

// Register Ham Forwards for CZ bots
public register_ham_czbots(id)
{
	// Make sure it's a CZ bot and it's still connected
	if (g_hamczbots || !g_isconnected[id] || !get_pcvar_num(cvar_botquota)) return
	
	RegisterHamFromEntity(Ham_Spawn, id, "OnPlayerSpawn", 1)
	RegisterHamFromEntity(Ham_Killed, id, "OnPlayerKilled")
	RegisterHamFromEntity(Ham_Killed, id, "OnPlayerKilledPost", 1)
	RegisterHamFromEntity(Ham_TakeDamage, id, "OnTakeDamage")
	RegisterHamFromEntity(Ham_TakeDamage, id, "OnTakeDamagePost", 1)
	RegisterHamFromEntity(Ham_TraceAttack, id, "OnTraceAttack")
	RegisterHamFromEntity(Ham_Player_ResetMaxSpeed, id, "OnResetMaxSpeedPost", 1)
	
	// Ham forwards for CZ bots succesfully registered
	g_hamczbots = true
	
	// If the bot has already spawned, call the forward manually for him
	if (is_user_alive(id)) OnPlayerSpawn(id)
}

// Disable minmodels task
public disable_minmodels(id)
{
	if (!g_isconnected[id]) return
	client_cmd(id, "cl_minmodels 0")
}

// Balance Teams Task
balance_teams()
{
	// Get amount of users playing
	static iPlayersnum; iPlayersnum = fnGetPlaying()
	
	// No players, don't bother
	if (!iPlayersnum) return
	
	// Split players evenly
	static iTerrors, iMaxTerrors, id, team[33]
	iMaxTerrors = iPlayersnum / 2
	iTerrors = 0
	
	// First, set everyone to CT
	for (id = 1; id <= g_maxplayers; id++)
	{
		// Skip if not connected
		if (!g_isconnected[id]) continue
		
		team[id] = fm_cs_get_user_team(id)
		
		// Skip if not playing
		if (team[id] == FM_CS_TEAM_SPECTATOR || team[id] == FM_CS_TEAM_UNASSIGNED) continue
		
		// Set team
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		team[id] = FM_CS_TEAM_CT
	}
	
	// Then randomly set half of the players to Terrorists
	while (iTerrors < iMaxTerrors)
	{
		// Keep looping through all players
		if (++id > g_maxplayers) id = 1
		
		// Skip if not connected
		if (!g_isconnected[id]) continue
		
		// Skip if not playing or already a Terrorist
		if (team[id] != FM_CS_TEAM_CT) continue
		
		// Random chance
		if (random_num(0, 1))
		{
			fm_cs_set_user_team(id, FM_CS_TEAM_T)
			team[id] = FM_CS_TEAM_T
			iTerrors++
		}
	}
}

// Welcome Message Task
public welcome_msg()
{
	new map[33]
	get_mapname(map, 32)

	// Show mod info
	client_print_color(0, print_team_grey, "%s", ROUND_WELCOME_TEXT)
	client_print_color(0, print_team_grey, "Round: ^3%d ^4| ^1Map: ^3%s ^4| ^1Players: ^3%d^1/^3%d", g_roundcount, map, fnGetPlaying(), g_maxplayers)
	
	// Show T-virus HUD notice
	set_hudmessage(0, 125, 200, HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
	ShowSyncHudMsg(0, g_MsgSync, "The T-Virus has been set loose...")
}

// Respawn Player Check Task (if killed by worldspawn)
public respawn_player_check_task(taskid)
{
	// Retrieve player index
	static id; id = taskid - TASK_SPAWN

	// Successfully spawned or round ended
	if (g_isalive[id] || g_endround) return
	
	// Get player's team
	static team; team = fm_cs_get_user_team(id)
	
	// Player moved to spectators
	if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED) return
	
	// If player was being spawned as a zombie, set the flag again
	if (CheckBit(g_playerTeam[id], TEAM_ZOMBIE)) g_respawn_as_zombie[id] = true
	else g_respawn_as_zombie[id] = false
	
	respawn_player_manually(id)
}

// Respawn Player Manually (called after respawn checks are done)
respawn_player_manually(id)
{
	// Set proper team before respawning, so that the TeamInfo message that's sent doesn't confuse PODBots
	if (g_respawn_as_zombie[id]) fm_cs_set_user_team(id, FM_CS_TEAM_T)
	else fm_cs_set_user_team(id, FM_CS_TEAM_CT)
	
	// Respawning a player has never been so easy
	ExecuteHamB(Ham_CS_RoundRespawn, id)
}

// Check Round Task -check that we still have both zombies and humans on a round-
check_round(leaving_player)
{
	// Round ended or make_a_zombie task still active
	if (g_endround || task_exists(TASK_MAKEZOMBIE)) return
	
	// Get alive players count
	static iPlayersnum, id
	iPlayersnum = fnGetAlive()
	
	// Last alive player, don't bother
	if (iPlayersnum < 2) return
	
	// Last zombie disconnecting
	if (CheckBit(g_playerTeam[leaving_player], TEAM_ZOMBIE) && fnGetZombies() == 1)
	{
		// Only one CT left, don't bother
		if (fnGetHumans() == 1 && fnGetCTs() == 1) return
		
		// Pick a random one to take his place
		while ((id = fnGetRandomAlive(random_num(1, iPlayersnum))) == leaving_player ) { /* keep looping */ }
		
		// Show last zombie left notice
		client_print_color(0, print_team_grey, "%s Last zombie has disconnected,^4 %s^1 is the last zombie!", CHAT_PREFIX, g_playerName[id])

		// Set player leaving flag
		g_lastplayerleaving = true

		// Turn into a Nemesis or just a zombie?
		if (CheckBit(g_playerClass[leaving_player], CLASS_NEMESIS)) MakeZombie(id, CLASS_NEMESIS)
		else if (CheckBit(g_playerClass[leaving_player], CLASS_ASSASIN)) MakeZombie(id, CLASS_ASSASIN)
		else if (CheckBit(g_playerClass[leaving_player], CLASS_BOMBARDIER)) MakeZombie(id, CLASS_BOMBARDIER)
		else if (CheckBit(g_playerClass[leaving_player], CLASS_REVENANT)) MakeZombie(id, CLASS_REVENANT)
		else MakeZombie(id)

		// Remove player leaving flag
		g_lastplayerleaving = false
		
		// If Nemesis, set chosen player's health to that of the one who's leaving
		if (KeepHealthOnDisconnect && CheckBit(g_playerClass[leaving_player], CLASS_NEMESIS))
			set_user_health(id, pev(leaving_player, pev_health))
		
		// If Assassin, set chosen player's health to that of the one who's leaving
		if (KeepHealthOnDisconnect && CheckBit(g_playerClass[leaving_player], CLASS_ASSASIN))
			set_user_health(id, pev(leaving_player, pev_health))
		
		// If Bombardier, set chosen player's health to that of the one who's leaving
		if (KeepHealthOnDisconnect && CheckBit(g_playerClass[leaving_player], CLASS_BOMBARDIER))
			set_user_health(id, pev(leaving_player, pev_health))

		// If Revenant, set chosen player's health to that of the one who's leaving
		if (KeepHealthOnDisconnect && CheckBit(g_playerClass[leaving_player], CLASS_REVENANT))
			set_user_health(id, pev(leaving_player, pev_health))
	}
	
	// Last human disconnecting
	else if (CheckBit(g_playerTeam[leaving_player], TEAM_HUMAN) && fnGetHumans() == 1)
	{
		// Only one T left, don't bother
		if (fnGetZombies() == 1 && fnGetTs() == 1) return
		
		// Pick a random one to take his place
		while ((id = fnGetRandomAlive(random_num(1, iPlayersnum))) == leaving_player ) { /* keep looping */ }
		
		// Show last human left notice
		client_print_color(0, print_team_grey, "%s Last human has disconnected,^4 %s^1 is the last human!", CHAT_PREFIX, g_playerName[id])

		// Set player leaving flag
		g_lastplayerleaving = true
		
		// Turn into a Survivor or just a human?
		if (CheckBit(g_playerClass[leaving_player], CLASS_SURVIVOR)) MakeHuman(id, CLASS_SURVIVOR)
		else if (CheckBit(g_playerClass[leaving_player], CLASS_SNIPER)) MakeHuman(id, CLASS_SNIPER)
		else if (CheckBit(g_playerClass[leaving_player], CLASS_SAMURAI)) MakeHuman(id, CLASS_SAMURAI)
		else if (CheckBit(g_playerClass[leaving_player], CLASS_GRENADIER)) MakeHuman(id, CLASS_GRENADIER)
		else if (CheckBit(g_playerClass[leaving_player], CLASS_TERMINATOR)) MakeHuman(id, CLASS_TERMINATOR)
		else MakeHuman(id)

		// Remove player leaving flag
		g_lastplayerleaving = false
		
		// If Survivor, set chosen player's health to that of the one who's leaving
		if (KeepHealthOnDisconnect && CheckBit(g_playerClass[leaving_player], CLASS_SURVIVOR))
			set_user_health(id, pev(leaving_player, pev_health))
		
		// If Sniper, set chosen player's health to that of the one who's leaving
		if (KeepHealthOnDisconnect && CheckBit(g_playerClass[leaving_player], CLASS_SNIPER))
			set_user_health(id, pev(leaving_player, pev_health))
		
		// If Samurai, set chosen player's health to that of the one who's leaving			// Abhinash
		if (KeepHealthOnDisconnect && CheckBit(g_playerClass[leaving_player], CLASS_SAMURAI))
			set_user_health(id, pev(leaving_player, pev_health))

		// If Grenadier, set chosen player's health to that of the one who's leaving			// Abhinash
		if (KeepHealthOnDisconnect && CheckBit(g_playerClass[leaving_player], CLASS_GRENADIER))
			set_user_health(id, pev(leaving_player, pev_health))

		// If Terminator, set chosen player's health to that of the one who's leaving			// Abhinash
		if (KeepHealthOnDisconnect && CheckBit(g_playerClass[leaving_player], CLASS_TERMINATOR))
			set_user_health(id, pev(leaving_player, pev_health))
	}
}

// Lighting Effects Task
public OnRegeneratorSkill()
{
	static id; id = 1
	while (g_maxplayers + 1 > id)
	{
		if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_ZOMBIE) && g_zombieclass[id] == 4 && pev(id, pev_health) < 6000)
		{
			// Regenerate user health
			set_user_health(id, pev(id, pev_health) + 350)

			// Send TE_PARTICLEBURST
			SendParticleBurst(id)

			// Screeenfade effect
			UTIL_ScreenFade(id, {10, 255, 10}, 1.0, 0.5, 100, FFADE_IN, true, false)

			// Hud HUD Message
			set_hudmessage(255, 0, 175, -1.00, 0.10, 1, 0.00, 1.75, 1.00, 1.00, -1)
			ShowSyncHudMsg(id, g_MsgSync6, "== REGENERATOR ==^n!!!!Regeneration: +350 HP Gained!!!!")
		}
		id++
	}

	return PLUGIN_CONTINUE
}

// Ambience Sound Effects Task
public StartAmbienceSounds(taskid)
{
	static iRand, buffer[100]
	if (CheckBit(g_currentmode, MODE_INFECTION)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_INFECTION]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_INFECTION], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_MULTI_INFECTION))
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_MULTI_INFECTION]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_MULTI_INFECTION], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_NEMESIS)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_NEMESIS]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_NEMESIS], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_ASSASIN)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_ASSASIN]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_ASSASIN], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_BOMBARDIER)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_BOMBARDIER]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_BOMBARDIER], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_SURVIVOR)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_SURVIVOR]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_SURVIVOR], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_SNIPER)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_SNIPER]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_SNIPER], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_SAMURAI)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_SAMURAI]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_SAMURAI], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_GRENADIER)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_GRENADIER]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_GRENADIER], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_TERMINATOR)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_TERMINATOR]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_TERMINATOR], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_REVENANT)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_REVENANT]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_REVENANT], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_SWARM)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_SWARM]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_SWARM], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_PLAGUE)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_PLAGUE]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_PLAGUE], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_SYNAPSIS)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_SYNAPSIS]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_SYNAPSIS], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_SURVIVOR_VS_NEMESIS)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_SURVIVOR_VS_NEMESIS]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_SURVIVOR_VS_NEMESIS], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_SURVIVOR_VS_ASSASIN)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_SURVIVOR_VS_ASSASIN]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_SURVIVOR_VS_ASSASIN], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_SNIPER_VS_ASSASIN)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_SNIPER_VS_ASSASIN]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_SNIPER_VS_ASSASIN], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_SNIPER_VS_NEMESIS)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_SNIPER_VS_NEMESIS]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_SNIPER_VS_NEMESIS], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_BOMBARDIER_VS_GRENADIER)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_BOMBARDIER_VS_GRENADIER]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_BOMBARDIER_VS_GRENADIER], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
	else if (CheckBit(g_currentmode, MODE_NIGHTMARE)) 
	{
		iRand = random_num(0, ArraySize(Array:g_ambience[AMBIENCE_NIGHTMARE]) - 1)
		ArrayGetString(Array:g_ambience[AMBIENCE_NIGHTMARE], iRand, buffer, charsmax(buffer))
		PlaySound(buffer)
	}
}

// Ambience Sounds Stop Task
StopAmbienceSounds(){ client_cmd(0, "mp3 stop; stopsound"); }

// Flashlight Charge Task
public ChargeFlashLight(taskid)
{
	// Retrieve player id
	static id; id = taskid - TASK_CHARGE

	// Drain or charge?
	if (g_flashlight[id]) g_flashbattery[id] -= FlashLightDrain
	else g_flashbattery[id] += FlashLightCharge
	
	// Battery fully charged
	if (g_flashbattery[id] >= 100)
	{
		// Don't exceed 100%
		g_flashbattery[id] = 100
		
		// Update flashlight battery on HUD
		message_begin(MSG_ONE, get_user_msgid("FlashBat"), _, id)
		write_byte(100) // battery
		message_end()
		
		// Task not needed anymore
		remove_task(taskid)
		return
	}
	
	// Battery depleted
	if (g_flashbattery[id] <= 0)
	{
		// Turn it off
		g_flashlight[id] = false
		g_flashbattery[id] = 0
		
		// Play flashlight toggle sound
		emit_sound(id, CHAN_ITEM, sound_flashlight, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Update flashlight status on HUD
		message_begin(MSG_ONE, get_user_msgid("Flashlight"), _, id)
		write_byte(0) // toggle
		write_byte(0) // battery
		message_end()
		
		// Remove flashlight task for this player
		remove_task(id+TASK_FLASH)
	}
	else
	{
		// Update flashlight battery on HUD
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("FlashBat"), _, id)
		write_byte(g_flashbattery[id]) // battery
		message_end()
	}
}

// Remove Spawn Protection Task
public remove_spawn_protection(taskid)
{
	// Retrieve player index
	static id; id = taskid - TASK_SPAWN

	// Not alive
	if (!g_isalive[id]) return
	
	// Remove spawn protection
	g_nodamage[id] = false
	set_pev(id, pev_effects, pev(id, pev_effects) & ~EF_NODRAW)
}

// Hide Player's Money Task
public task_hide_money(taskid)
{
	// Retrieve player index
	static id; id = taskid - TASK_SPAWN

	// Not alive
	if (!g_isalive[id]) return
	
	// Hide money
	HideWeapon(id, HIDE_MONEY)
	
	// Hide the HL crosshair that's drawn
	HideCrosshair(id)
}

// Turn Off Flashlight and Restore Batteries
turn_off_flashlight(id)
{
	// Restore batteries for the next use
	fm_cs_set_user_batteries(id, 100)
	
	// Check if flashlight is on
	if (pev(id, pev_effects) & EF_DIMLIGHT) set_pev(id, pev_impulse, IMPULSE_FLASHLIGHT) // Turn it off 
	else set_pev(id, pev_impulse, 0) // Clear any stored flashlight impulse (bugfix) 
	
	// Turn off custom flashlight
	if (g_cached_customflash)
	{
		// Turn it off
		g_flashlight[id] = false
		g_flashbattery[id] = 100
		
		// Update flashlight HUD
		message_begin(MSG_ONE, get_user_msgid("Flashlight"), _, id)
		write_byte(0) // toggle
		write_byte(100) // battery
		message_end()
		
		// Remove previous tasks
		remove_task(id + TASK_CHARGE)
		remove_task(id + TASK_FLASH)
	}
}

// Infection Bomb Explosion
OnInfectionExplode(ent)
{
	static iRand, buffer[100]
	// Round ended (bugfix)
	if (g_endround) return
	
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Send TE_BEAMCYLINDER 
	SendGrenadeBeamCylinder(ent, 0, 200, 0, 200)
	
	// Infection nade explode sound
	iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_GRENADE_INFECT]) - 1)
	ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_INFECT], iRand, buffer, charsmax(buffer))
	emit_sound(ent, CHAN_WEAPON, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Get attacker
	static attacker; attacker = pev(ent, pev_owner)
	
	// Infection bomb owner disconnected? (bugfix)
	if (!is_user_valid_connected(attacker))
	{
		// Get rid of the grenade
		engfunc(EngFunc_RemoveEntity, ent)
		return
	}
	
	// Collisions
	static victim; victim = -1

	// Count
	new count
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive non-spawnprotected humans
		if (!is_user_valid_alive(victim) || CheckBit(g_playerTeam[victim], TEAM_ZOMBIE) || g_nodamage[victim]) continue
		
		// Last human is killed
		if (fnGetHumans() == 1)
		{
			ExecuteHamB(Ham_Killed, victim, attacker, 0)
			continue
		}
		
		// Infected victim's sound
		iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_GRENADE_INFECT_PLAYER]) - 1)
		ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_INFECT_PLAYER], iRand, buffer, charsmax(buffer))
		emit_sound(victim, CHAN_VOICE, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		SendDeathMsg(attacker, victim) // send death notice
		FixScoreAttrib(victim) // fix the "dead" attrib on scoreboard
		UpdateFrags(attacker, victim, ZombieRewardInfectFrags, 1, 1)
		g_ammopacks[attacker] += ZombieRewardInfectPacks // add corresponding frags & deaths	
		
		set_user_health(attacker, pev(attacker, pev_health) + 250) // infection HP bonus	
		
		// Turn into zombie
		MakeZombie(victim, CLASS_ZOMBIE, attacker)

		// Increase count
		count++
	}

	client_print_color(attacker, print_team_grey, "%s Players infected with grenade: ^4%i", CHAT_PREFIX, count)

	// Increase infections
	g_infections[attacker] += count

	// Update his database
	MySQL_UPDATE_DATABASE(attacker)
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Killing Explode
OnKillingExplode(ent)
{
	// Round ended (bugfix)
	if (g_endround) return
	
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Send TE_BEAMCYLINDER 
	SendGrenadeBeamCylinder(ent, 128, 0, 255, 200)
	
	// Get attacker
	static attacker; attacker = pev(ent, pev_owner)
	
	// Infection bomb owner disconnected? (bugfix)
	if (!is_user_valid_connected(attacker))
	{
		// Get rid of the grenade
		engfunc(EngFunc_RemoveEntity, ent)
		return
	}
	
	// Collisions
	static victim; victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		if (CheckBit(g_playerClass[attacker], CLASS_BOMBARDIER))
		{
			// Only effect alive non-spawnprotected humans
			if (!is_user_valid_alive(victim) || CheckBit(g_playerTeam[victim], TEAM_ZOMBIE) || g_nodamage[victim]) continue
			
			// Last human is killed
			ExecuteHamB(Ham_Killed, victim, attacker, 0)
			
			//SendDeathMsg(attacker, victim) // send death notice
			FixScoreAttrib(victim) // fix the "dead" attrib on scoreboard
			UpdateFrags(attacker, victim, ZombieRewardInfectFrags, 1, 1)
			g_ammopacks[attacker] += ZombieRewardInfectPacks // add corresponding frags & deaths	
		}
		else
		{
			// Only effect alive non-spawnprotected humans
			if (!is_user_valid_alive(victim) || CheckBit(g_playerTeam[victim], TEAM_HUMAN) || g_nodamage[victim]) continue
			
			// Last human is killed
			ExecuteHamB(Ham_Killed, victim, attacker, 0)
			
			//SendDeathMsg(attacker, victim) // send death notice
			FixScoreAttrib(victim) // fix the "dead" attrib on scoreboard
			UpdateFrags(attacker, victim, ZombieRewardInfectFrags, 1, 1)
			g_ammopacks[attacker] += ZombieRewardInfectPacks // add corresponding frags & deaths	
		}
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)

	// Give Bombardier his grenade
	if (CheckBit(g_playerClass[attacker], CLASS_BOMBARDIER)) fm_give_item(attacker, "weapon_hegrenade")
}

public OnConcussionExplode(ent)
{
	// Round ended (bugfix)
	if (g_endround) return
	
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Send TE_BEAMCYLINDER 
	SendGrenadeBeamCylinder(ent, 0, 0, 255,200)
	
	// Get attacker
	static attacker; attacker = pev(ent, pev_owner)
	
	// Infection bomb owner disconnected? (bugfix)
	if (!is_user_valid_connected(attacker))
	{
		// Get rid of the grenade
		engfunc(EngFunc_RemoveEntity, ent)
		return
	}

	// Collisions
	static victim; victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive non-spawnprotected humans
		if (!is_user_valid_alive(victim) || CheckBit(g_playerTeam[victim], TEAM_ZOMBIE) || g_nodamage[victim]) continue	
		
		// Continiously affect them
		set_task (0.2, "affect_victim", victim + TASK_CONCUSSION, _, _, "a", 35)
	}

	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Bubble bomb explode
public OnForceFieldExplode(ent)
{
	// Round ended (bugfix)
	if (g_endround) return

	// Get attacker
	static attacker; attacker = pev(ent, pev_owner)
	
	// Bubble bomb owner disconnected? (bugfix)
	if (!is_user_valid_connected(attacker))
	{
		// Get rid of the grenade
		engfunc(EngFunc_RemoveEntity, ent)
		return
	}

	// Create entitity
	new iEntity = create_entity("info_target")
	
	// Check if entity is valid
	if (!is_valid_ent(iEntity)) return 
	
	// Get origin
	new Float: Origin[3] 
	entity_get_vector(ent, EV_VEC_origin, Origin)
	
	// Set Entity class name
	entity_set_string(iEntity, EV_SZ_classname, BubbleEntityClassName)
	
	// Set Origin and other
	entity_set_vector(iEntity,EV_VEC_origin, Origin)
	entity_set_model(iEntity, BubbleGrenadeModel)
	entity_set_int(iEntity, EV_INT_solid, SOLID_TRIGGER)
	entity_set_size(iEntity, BubbleGrenadeMins, BubbleGrenadeMaxs)
	entity_set_int(iEntity, EV_INT_renderfx, kRenderFxGlowShell)
	entity_set_int(iEntity, EV_INT_rendermode, kRenderTransAlpha)
	entity_set_float(iEntity, EV_FL_renderamt, 50.0)
	
	// Check if Valid Entity and Apply glow color
	if (is_valid_ent(iEntity))
	{
		new Float:vColor[3]
		for(new i; i < 3; i++)
		vColor[i] = random_float(0.0, 255.0)
		
		// Glow function
		entity_set_vector(iEntity, EV_VEC_rendercolor, vColor)
	}

	// Set task to remove the entity
	set_task(300.0, "DeleteEntityGrenade", TASK_REMOVE_FORECEFIELD + iEntity)
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Remove entity function of Bubble Grenade
public DeleteEntityGrenade(taskid) 
{
	new entity = taskid - TASK_REMOVE_FORECEFIELD

	if (is_valid_ent(entity)) remove_entity(entity)
}

public OnAntidoteExplode(ent)
{
	// Round ended (bugfix)
	if (g_endround) return
	
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Send TE_BEAMCYLINDER 
	SendGrenadeBeamCylinder(ent, 255, 72, 0, 200)
	
	// Get attacker
	static attacker; attacker = pev(ent, pev_owner)
	
	// Infection bomb owner disconnected? (bugfix)
	if (!is_user_valid_connected(attacker))
	{
		// Get rid of the grenade
		engfunc(EngFunc_RemoveEntity, ent)
		return
	}

	// Collisions
	static victim; victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive non-spawnprotected zombies
		if (!is_user_valid_alive(victim) || CheckBit(g_playerTeam[victim], TEAM_HUMAN) || g_nodamage[victim]) continue

		// Last human is killed
		if (fnGetZombies() == 1) continue

		// Make them all human
		MakeHuman(victim)
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// We are going to affect you
public affect_victim(taskid)
{
	// Retrieve index
	static id; id = taskid - TASK_CONCUSSION

	// Dead
	if (!g_isalive[id]) return
		
	// Make a screen fade
	//UTIL_ScreenFade(i, {200, 0, 0}, 1.0, 0.5, 100, FFADE_IN, true, false)

	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, id)
	write_short(1<<13) // Duration
	write_short(1<<14) // Hold Time
	write_short(FFADE_IN) // Fade type
	write_byte(random_num(50, 200)) // Red amount
	write_byte(random_num(50, 200)) // Green amount
	write_byte(random_num(50, 200)) // Blue amount
	write_byte(random_num(50, 200)) // Alpha
	message_end()
		
	// Make a screen shake
	SendScreenShake(id, 0xFFFF, 1<<13, 0xFFFF)
	
	// Remove task after all
	remove_task (id)
}

// HE Grenade Explosion
public OnExplosionExplode(ent)
{
	// Get origin
	static Float:origin[3], victim, Float:clorigin[3],Float: clvelocity[3], special[3], Float:distance, Float:damage, health, attacker
	pev(ent, pev_origin, origin)
	FVecIVec(origin, special)
	attacker = pev(ent, pev_owner)
	
	// Check if the attacker is a valid connected client
	if(!pev_valid(attacker) || !is_user_connected(attacker))
	{
		engfunc(EngFunc_RemoveEntity, ent)
		return
	}
	
	// Send TE_EXPLOSION message
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(special[0])
	write_coord(special[1])
	write_coord(special[2])
	write_short(g_explosionspr)
	write_byte(32)
	write_byte(16)
	write_byte(0)
	message_end()

	// Send TE_BEAMCYLINDER
	SendGrenadeBeamCylinder(ent, 255, 0, 0, 200)

	if (CheckBit(g_currentmode, MODE_BOMBARDIER_VS_GRENADIER))
	{
		for (victim = 1 ; victim <= g_maxplayers; victim++)
		{
			if (!is_user_alive(victim)) continue
			
			if (attacker == victim) continue
			
			pev(victim, pev_origin, clorigin)
			distance = get_distance_f(origin, clorigin)

			if (distance < 330)
			{
				damage = 700.0 - distance
				health = get_user_health(victim)
				damage = float(floatround(damage))

				// Throw him away in his current vector
				pev(victim , pev_velocity, clvelocity)
				xs_vec_mul_scalar(clvelocity, 2.75, clvelocity)
				clvelocity[2] *= 1.75
				set_pev(victim, pev_velocity, clvelocity)

				// Send Screenfade message
				UTIL_ScreenFade(victim, {200, 0, 0}, 1.0, 0.5, 100, FFADE_IN, true, false)
				
				// Play flatline sound on client
				client_cmd(victim, "spk fvox/flatline")
				
				// Send Screenshake message
				SendScreenShake(victim, 4096 * 6, 4096 * random_num(4, 12), 4096 * random_num(4, 12))

				damage *= 1.50

				// Checks
				if (health - floatround(damage))
					ExecuteHamB(Ham_TakeDamage, victim, ent, attacker, damage, DMG_BLAST)
				else
				{
					ExecuteHamB(Ham_Killed, victim, attacker, 2)
					SendLavaSplash(victim)
				}
			}
		}
	}
	else
	{
		for (victim = 1 ; victim <= g_maxplayers; victim++)
		{
			if (!is_user_alive(victim)) continue
			
			if (CheckBit(g_playerTeam[victim], TEAM_HUMAN)) continue
			
			pev(victim, pev_origin, clorigin)
			distance = get_distance_f(origin, clorigin)

			if (distance < 330)
			{
				damage = 700.0 - distance
				health = get_user_health(victim)
				damage = float(floatround(damage))

				// Throw him away in his current vector
				pev(victim , pev_velocity, clvelocity)
				xs_vec_mul_scalar(clvelocity, 2.75, clvelocity)
				clvelocity[2] *= 1.75
				set_pev(victim, pev_velocity, clvelocity)

				// Send Screenfade message
				UTIL_ScreenFade(victim, {200, 0, 0}, 1.0, 0.5, 100, FFADE_IN, true, false)
				
				// Play flatline sound on client
				client_cmd(victim, "spk fvox/flatline")
				
				// Send Screenshake message
				SendScreenShake(victim, 4096 * 6, 4096 * random_num(4, 12), 4096 * random_num(4, 12))

				if (CheckBit(g_playerClass[victim], CLASS_NEMESIS) || CheckBit(g_playerClass[victim], CLASS_ASSASIN) 
				|| CheckBit(g_playerClass[victim], CLASS_BOMBARDIER) || CheckBit(g_playerClass[victim], CLASS_REVENANT)) damage *= 1.50

				// Checks
				if (health - floatround(damage))
					ExecuteHamB(Ham_TakeDamage, victim, ent, attacker, damage, DMG_BLAST)
				else
				{
					ExecuteHamB(Ham_Killed, victim, attacker, 2)
					SendLavaSplash(victim)
				}
			}
		}
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)

	if (CheckBit(g_currentmode, MODE_BOMBARDIER_VS_GRENADIER)) if (CheckBit(g_playerClass[attacker], CLASS_BOMBARDIER)) fm_give_item(attacker, "weapon_hegrenade")

	// Give Grenadier his grenade
	if (CheckBit(g_playerClass[attacker], CLASS_GRENADIER)) fm_give_item(attacker, "weapon_hegrenade")
}

// Fire Grenade Explosion
OnNapalmExplode(ent)
{
	static iRand, buffer[100]

	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Send TE_DLIGHT
	//SendGrenadeLight(200, 50, 0, 555, originF)
	
	// Send TE_BEAMCYLINDER 
	SendGrenadeBeamCylinder(ent, 255, 255, 0, 200)
	
	// Fire nade explode sound
	iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_GRENADE_FIRE]) - 1)
	ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_FIRE], iRand, buffer, charsmax(buffer))
	emit_sound(ent, CHAN_WEAPON, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Collisions
	static victim; victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive zombies
		if (!is_user_valid_alive(victim) || CheckBit(g_playerTeam[victim], TEAM_HUMAN) || g_frozen[victim] || g_nodamage[victim]) continue

		// Set the burning flag
		g_burning[victim] = true
		
		// Set Yellow Rendering ( Glow ) on Victims.
		set_glow(victim, 200, 200, 0, 25)
		
		// Send ScreenFade message
		UTIL_ScreenFade(victim, {200, 200, 0}, 0.0, 0.0, 100, FFADE_STAYOUT, true, false)
		
		// Heat icon?
		if (HUDIcons)
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Damage"), _, victim)
			write_byte(0) // damage save
			write_byte(0) // damage take
			write_long(DMG_BURN) // damage type
			write_coord(0) // x
			write_coord(0) // y
			write_coord(0) // z
			message_end()
		}
		
		if (CheckBit(g_playerClass[victim], CLASS_NEMESIS) || CheckBit(g_playerClass[victim], CLASS_ASSASIN) || CheckBit(g_playerClass[victim], CLASS_BOMBARDIER)) g_burning_duration[victim] += FireDuration // fire duration (nemesis is fire resistant)
		else g_burning_duration[victim] += FireDuration * 5
		
		// Set burning task on victim if not present
		if (!task_exists(victim + TASK_BURN))
			set_task(0.2, "burning_flame", victim + TASK_BURN, _, _, "b")
		
		static iParams[2]
		iParams[0] = victim
		iParams[1] = 0
		// Set a task to remove the burn effects from victim
		set_task(float(FireDuration), "remove_effects", _, iParams, sizeof(iParams))
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Frost Grenade Explosion
OnFrostExplode(ent)
{
	static iRand, buffer[100]
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Send TE_DLIGHT
	//SendGrenadeLight(0, 206, 209, 555, originF)
	
	// Send TE_BEAMCYLINDER 
	SendGrenadeBeamCylinder(ent, 0, 206, 209, 200)
	
	// Frost nade explode sound
	iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_GRENADE_FROST]) - 1)
	ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_FROST], iRand, buffer, charsmax(buffer))
	emit_sound(ent, CHAN_WEAPON, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Collisions
	static victim; victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive unfrozen zombies
		if (!is_user_valid_alive(victim) || CheckBit(g_playerTeam[victim], TEAM_HUMAN) || g_frozen[victim] || g_burning[victim] || g_nodamage[victim]) continue
		
		// Nemesis shouldn't be frozen
		if (CheckBit(g_playerClass[victim], CLASS_NEMESIS) || CheckBit(g_playerClass[victim], CLASS_ASSASIN) || CheckBit(g_playerClass[victim], CLASS_BOMBARDIER))
		{
			// Get player's origin
			static origin2[3]
			get_user_origin(victim, origin2)
			
			// Broken glass sound
			iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_GRENADE_FROST_BREAK]) - 1)
			ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_FROST_BREAK], iRand, buffer, charsmax(buffer))
			emit_sound(victim, CHAN_BODY, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			// Glass shatter
			SendGlassBreak(victim)
			
			continue
		}
		
		// Freeze icon?
		if (HUDIcons)
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Damage"), _, victim)
			write_byte(0) // damage save
			write_byte(0) // damage take
			write_long(DMG_DROWN) // damage type - DMG_FREEZE
			write_coord(0) // x
			write_coord(0) // y
			write_coord(0) // z
			message_end()
		}
		
		// Light blue glow while frozen
		set_glow(victim, 0, 206, 209, 25)
		
		// Freeze sound
		iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_GRENADE_FROST_PLAYER]) - 1)
		ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_FROST_PLAYER], iRand, buffer, charsmax(buffer))
		emit_sound(victim, CHAN_BODY, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Add a blue tint to their screen
		UTIL_ScreenFade(victim, {0, 200, 200}, 0.0, 0.0, 100, FFADE_STAYOUT, true, false)
		
		// Set the frozen flag
		g_frozen[victim] = true
		
		// Save player's old gravity (bugfix)
		pev(victim, pev_gravity, g_frozen_gravity[victim])
		
		// Prevent from jumping
		if (pev(victim, pev_flags) & FL_ONGROUND) set_pev(victim, pev_gravity, 999999.9) // set really high
		else set_pev(victim, pev_gravity, 0.000001) // no gravity
		
		// Prevent from moving
		ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)
		
		static iParams[2]
		iParams[0] = victim
		iParams[1] = 1
		// Set a task to remove the freeze
		set_task(FrostDuration, "remove_effects", _, iParams, sizeof(iParams))
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

public remove_effects(iParams[])
{
	new id = iParams[0]

	if (!g_isalive[id]) return 

	switch (iParams[1])
	{
		case 0: { if (!g_burning[id]) return; g_burning[id] = false; }
		case 1:
		{
			if (!g_frozen[id]) return; g_frozen[id] = false;

			// Restore gravity and maxspeed (bugfix)
			set_pev(id, pev_gravity, g_frozen_gravity[id])
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id)

			// Broken glass sound
			static iRand, buffer[100]
			iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_GRENADE_FROST_BREAK]) - 1)
			ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_FROST_BREAK], iRand, buffer, charsmax(buffer))
			emit_sound(id, CHAN_BODY, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
			// Glass shatter
			SendGlassBreak(id)
		}
	}

	// Nemesis or Survivor glow / remove glow
	if (CheckBit(g_playerClass[id], CLASS_NEMESIS))
	{
		if (NemesisGlow) set_glow(id, g_glowColor[__nemesis][__red], g_glowColor[__nemesis][__green], g_glowColor[__nemesis][__blue], 25)
		else remove_glow(id)
	}
	else if (CheckBit(g_playerClass[id], CLASS_ASSASIN))
	{
		if (AssassinGlow) set_glow(id, g_glowColor[__assasin][__red], g_glowColor[__assasin][__green], g_glowColor[__assasin][__blue], 25)
		else remove_glow(id)
	}
	else if (CheckBit(g_playerClass[id], CLASS_SURVIVOR))
	{
		if (SurvivorGlow) set_glow(id, g_glowColor[__survivor][__red], g_glowColor[__survivor][__green], g_glowColor[__survivor][__blue], 25)
		else remove_glow(id)
	}
	else if (CheckBit(g_playerClass[id], CLASS_SNIPER))
	{ 
		if (SniperGlow) set_glow(id, g_glowColor[__sniper][__red], g_glowColor[__sniper][__green], g_glowColor[__sniper][__blue], 25)
		else remove_glow(id)
	}
	else if (CheckBit(g_playerClass[id], CLASS_SAMURAI))
	{
		if (SamuraiGlow) set_glow(id, g_glowColor[__samurai][__red], g_glowColor[__samurai][__green], g_glowColor[__samurai][__blue], 25)
		else remove_glow(id)
	}
	else if (CheckBit(g_playerClass[id], CLASS_GRENADIER))
	{
		if (GrenadierGlow) set_glow(id, g_glowColor[__grenadier][__red], g_glowColor[__grenadier][__green], g_glowColor[__grenadier][__blue], 25)
		else remove_glow(id)
	}
	else if (CheckBit(g_playerClass[id], CLASS_TERMINATOR))
	{
		if (TerminatorGlow) set_glow(id, g_glowColor[__terminator][__red], g_glowColor[__terminator][__green], g_glowColor[__terminator][__blue], 25)
		else remove_glow(id)
	}
	else if (CheckBit(g_playerClass[id], CLASS_REVENANT))
	{
		if (RevenantGlow) set_glow(id, g_glowColor[__revenant][__red], g_glowColor[__revenant][__green], g_glowColor[__revenant][__blue], 25)
		else remove_glow(id)
	}
	else if (CheckBit(g_playerClass[id], CLASS_BOMBARDIER))
	{
		if (BombardierGlow) set_glow(id, g_glowColor[__bombardier][__red], g_glowColor[__bombardier][__green], g_glowColor[__bombardier][__blue], 25)
		else remove_glow(id)
	}
	else remove_glow(id)
	
	// Gradually remove screen's blue tint
	UTIL_ScreenFade(id, {0, 200, 200}, 1.0, 0.0, 100, FFADE_IN, true, false)
}

// Set Custom Weapon Models
replace_weapon_models(id, weaponid)
{
	static iRand, buffer[1024]
	switch (weaponid)
	{
	case CSW_KNIFE: // Custom knife models
		{
			if (CheckBit(g_playerTeam[id], TEAM_ZOMBIE))
			{
				if (CheckBit(g_playerClass[id], CLASS_NEMESIS)) // Nemesis
				{
					iRand = random_num(0, ArraySize(Array:g_weaponModels[V_KNIFE_NEMESIS]) - 1)
					ArrayGetString(Array:g_weaponModels[V_KNIFE_NEMESIS], iRand, buffer, charsmax(buffer))
					set_pev(id, pev_viewmodel2, buffer)
					set_pev(id, pev_weaponmodel2, "")
				}
				else if (CheckBit(g_playerClass[id], CLASS_ASSASIN)) // Assassins
				{
					iRand = random_num(0, ArraySize(Array:g_weaponModels[V_KNIFE_ASSASIN]) - 1)
					ArrayGetString(Array:g_weaponModels[V_KNIFE_ASSASIN], iRand, buffer, charsmax(buffer))
					set_pev(id, pev_viewmodel2, buffer)
					set_pev(id, pev_weaponmodel2, "")
				}
				else if (CheckBit(g_playerClass[id], CLASS_REVENANT)) // Assassins
				{
					iRand = random_num(0, ArraySize(Array:g_weaponModels[V_KNIFE_REVENANT]) - 1)
					ArrayGetString(Array:g_weaponModels[V_KNIFE_REVENANT], iRand, buffer, charsmax(buffer))
					set_pev(id, pev_viewmodel2, buffer)
					set_pev(id, pev_weaponmodel2, "")
				}
				else // Zombies
				{
					set_pev(id, pev_viewmodel2, g_cZombieClasses[g_zombieclass[id]][ClawModel])
					set_pev(id, pev_weaponmodel2, "")
				}
			}
			else // Humans
			{
				if (CheckBit(g_playerClass[id], CLASS_SAMURAI))
				{
					iRand = random_num(0, ArraySize(Array:g_weaponModels[V_KNIFE_SAMURAI]) - 1)
					ArrayGetString(Array:g_weaponModels[V_KNIFE_SAMURAI], iRand, buffer, charsmax(buffer))
					set_pev(id, pev_viewmodel2, buffer)

					iRand = random_num(0, ArraySize(Array:g_weaponModels[P_KNIFE_SAMURAI]) - 1)
					ArrayGetString(Array:g_weaponModels[P_KNIFE_SAMURAI], iRand, buffer, charsmax(buffer))
					set_pev(id, pev_weaponmodel2, buffer)
				}
				else if (CheckBit(g_playerClass[id], CLASS_GRENADIER))
				{
					iRand = random_num(0, ArraySize(Array:g_weaponModels[V_KNIFE_HUMAN]) - 1)
					ArrayGetString(Array:g_weaponModels[V_KNIFE_HUMAN], iRand, buffer, charsmax(buffer))
					set_pev(id, pev_viewmodel2, buffer)

					iRand = random_num(0, ArraySize(Array:g_weaponModels[P_KNIFE_HUMAN]) - 1)
					ArrayGetString(Array:g_weaponModels[P_KNIFE_HUMAN], iRand, buffer, charsmax(buffer))
					set_pev(id, pev_weaponmodel2, buffer)
				}
				else
				{
					if (get_user_jetpack(id)) set_jetpack(id)
					else
					{
						iRand = random_num(0, ArraySize(Array:g_weaponModels[V_KNIFE_HUMAN]) - 1)
						ArrayGetString(Array:g_weaponModels[V_KNIFE_HUMAN], iRand, buffer, charsmax(buffer))
						set_pev(id, pev_viewmodel2, buffer)

						iRand = random_num(0, ArraySize(Array:g_weaponModels[P_KNIFE_HUMAN]) - 1)
						ArrayGetString(Array:g_weaponModels[P_KNIFE_HUMAN], iRand, buffer, charsmax(buffer))
						set_pev(id, pev_weaponmodel2, buffer)
					}	
				}
			}
		}
	case CSW_AWP: // Sniper's AWP
		{
			if (CheckBit(g_playerClass[id], CLASS_SNIPER))
			{
				iRand = random_num(0, ArraySize(Array:g_weaponModels[V_AWP_SNIPER]) - 1)
				ArrayGetString(Array:g_weaponModels[V_AWP_SNIPER], iRand, buffer, charsmax(buffer))
				set_pev(id, pev_viewmodel2, buffer)

				iRand = random_num(0, ArraySize(Array:g_weaponModels[P_AWP_SNIPER]) - 1)
				ArrayGetString(Array:g_weaponModels[P_AWP_SNIPER], iRand, buffer, charsmax(buffer))
				set_pev(id, pev_weaponmodel2, buffer)
			}
		}
	case CSW_SG550:		// Crossbow
		{
			if (g_has_crossbow[id])
			{
				set_pev(id, pev_viewmodel2, crossbow_V_MODEL)
				set_pev(id, pev_weaponmodel2, crossbow_P_MODEL)
				set_pdata_float(id, 83, 1.0, OFFSET_LINUX)
			}
		}
	case CSW_AK47: if (g_goldenweapons[id]) set_goldenak47(id)   
	case CSW_M4A1: if (g_goldenweapons[id]) set_goldenm4a1(id) 
	case CSW_XM1014: if (g_goldenweapons[id]) set_goldenxm1014(id) 
	case CSW_DEAGLE: if (g_goldenweapons[id]) set_goldendeagle(id)    
	case CSW_HEGRENADE: // Infection bomb or Explode grenade
		{
			if (CheckBit(g_playerClass[id], CLASS_ZOMBIE)) 
			{
				iRand = random_num(0, ArraySize(Array:g_weaponModels[V_INFECTION_NADE]) - 1)
				ArrayGetString(Array:g_weaponModels[V_INFECTION_NADE], iRand, buffer, charsmax(buffer))
				set_pev(id, pev_viewmodel2, buffer)
			}
			else 
			{
				iRand = random_num(0, ArraySize(Array:g_weaponModels[V_EXPLOSION_NADE]) - 1)
				ArrayGetString(Array:g_weaponModels[V_EXPLOSION_NADE], iRand, buffer, charsmax(buffer))
				set_pev(id, pev_viewmodel2, buffer)
			}
		}
	case CSW_FLASHBANG: 
		{
			iRand = random_num(0, ArraySize(Array:g_weaponModels[V_NAPALM_NADE]) - 1)
			ArrayGetString(Array:g_weaponModels[V_NAPALM_NADE], iRand, buffer, charsmax(buffer))
			set_pev(id, pev_viewmodel2, buffer) // Fire grenade 
		}
	case CSW_SMOKEGRENADE: 
		{
			iRand = random_num(0, ArraySize(Array:g_weaponModels[V_FROST_NADE]) - 1)
			ArrayGetString(Array:g_weaponModels[V_FROST_NADE], iRand, buffer, charsmax(buffer))
			set_pev(id, pev_viewmodel2, buffer) // Frost grenade 
		}
	}
}

// Reset Player Vars
reset_vars(id, resetall)
{
	// Set Human Bits
	g_playerTeam[id] = 0
	g_playerTeam[id] = TEAM_HUMAN
	g_playerClass[id] = CLASS_HUMAN
	//SetBit(g_playerClass[id], CLASS_HUMAN)

	g_firstzombie[id] = false
	g_lastzombie[id] = false
	g_concussionbomb[id] = 0	// Abhinash
	g_antidotebomb[id] = 0
	g_killingbomb[id] = 0
	g_bubblebomb[id] = 0
	g_lasthuman[id] = false
	g_frozen[id] = false
	g_nodamage[id] = false
	g_respawn_as_zombie[id] = false
	g_nvision[id] = false
	g_nvisionenabled[id] = false
	g_flashlight[id] = false
	g_flashbattery[id] = 100
	g_canbuy[id] = true
	g_burning_duration[id] = 0
	g_iKillsThisRound[id] = 0
	g_norecoil[id] = false
	set_zombie(id, false)
	
	if (resetall)
	{
		g_zombieclass[id] = -1
		g_zombieclassnext[id] = -1
		g_damagedealt_human[id] = 0
		g_damagedealt_zombie[id] = 0
		g_goldenweapons[id] = false
		g_has_crossbow[id] = false
	}
}

// Set spectators nightvision
public spec_nvision(id)
{
	// Not connected, alive, or bot
	if (!g_isconnected[id] || g_isalive[id] || g_isbot[id]) return
	
	// Give Night Vision?
	if (NightVisionEnabled)
	{
		g_nvision[id] = true
		
		// Turn on Night Vision automatically?
		if (NightVisionEnabled)
		{
			g_nvisionenabled[id] = true
			
			// Custom nvg?
			if (CustomNightVision)
			{
				remove_task(id+TASK_NVISION)
				set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
			}
			else set_user_gnvision(id, 1)
		}
	}
}

// Show HUD Task
public ShowHUD(taskid)
{
	static id; id = ID_SHOWHUD
	
	// Player died?
	if (!g_isalive[id])
	{
		// Get spectating target
		id = pev(id, PEV_SPEC_TARGET)
		
		// Target not alive
		if (!g_isalive[id]) return
	}
	
	// Format classname
	static message[128], red, green, blue
	
	if (CheckBit(g_playerTeam[id], TEAM_ZOMBIE)) // Zombies
	{
		red   = 255
		green = 50
		blue  = 0
		
		formatex(message, charsmax(message), "%s - Health: %s - Packs: %s - Points: %s", g_classString[ID_SHOWHUD], AddCommas(pev(ID_SHOWHUD, pev_health)), AddCommas(g_ammopacks[ID_SHOWHUD]), AddCommas(clamp(g_points[ID_SHOWHUD], 0, 99999)))
	}	
	else // Humans
	{
		red   = 0
		green = 150
		blue  = 0
		
		formatex(message, charsmax(message), "%s - Health: %s - Armor: %d - Packs: %s - Points: %s", g_classString[ID_SHOWHUD], AddCommas(pev(ID_SHOWHUD, pev_health)), pev(ID_SHOWHUD, pev_armorvalue), AddCommas(g_ammopacks[ID_SHOWHUD]), AddCommas(clamp(g_points[ID_SHOWHUD], 0, 99999)))
	}
	
	// Spectating someone else?
	if (id != ID_SHOWHUD)
	{
		set_hudmessage(red, green, blue, -1.0, 0.79, 0, 6.0, 1.1, 0.0, 0.0, -1)
		ShowSyncHudMsg(ID_SHOWHUD, g_MsgSync2, "Spectating %s%s^n%s - Health: %s - Armor: %d - Packs: %s - Points: %s^nFrom: %s, %s", \
		g_vip[id] ? " (Gold Member ®)" : "", g_playerName[id], g_classString[id], AddCommas(pev(id, pev_health)), pev(id, pev_armorvalue), AddCommas(g_ammopacks[id]), AddCommas(clamp(g_points[id], 0, 99999)), g_playercountry[id], g_playercity[id])
	}
	else
	{
		// Show health, class and ammo packs
		set_hudmessage(red, green, blue, HUD_STATS_X, HUD_STATS_Y, 0, 6.0, 1.1, 0.0, 0.0, -1)
		ShowSyncHudMsg(ID_SHOWHUD, g_MsgSync2, "%s", message)
	}
}

// Play idle zombie sounds
public zombie_play_idle(taskid)
{
	//Retrieve player index
	static id; id = taskid - TASK_BLOOD
	static iRand, buffer[100]

	// Round ended/new one starting
	if (g_endround || g_newround) return
	
	// Last zombie?
	if (g_lastzombie[id]) 
	{
		iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_IDLE_LAST]) - 1)
		ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_IDLE_LAST], iRand, buffer, charsmax(buffer))
		emit_sound(id, CHAN_VOICE, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	else 
	{
		iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_ZOMBIE_IDLE]) - 1)
		ArrayGetString(Array:g_miscSounds[SOUND_ZOMBIE_IDLE], iRand, buffer, charsmax(buffer))
		emit_sound(id, CHAN_VOICE, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
}

// Madness Over Task
public madness_over(taskid)
{
	//Retrieve player index
	static id; id = taskid - TASK_BLOOD

	g_nodamage[id] = false
	remove_glow(id)
}

// NeO's set weapon function
set_weapon(id, weapon_id, clip = 0)
{
	if (!(CSW_P228 <= weapon_id <= CSW_P90) || !is_user_alive(id)) return -1
	
	new weapon_name[20] , iWeaponEntity , bool:bIsGrenade
	
	const GrenadeBits = ((1 << CSW_HEGRENADE) | (1 << CSW_FLASHBANG) | (1 << CSW_SMOKEGRENADE) | (1 << CSW_C4))
	
	if ((bIsGrenade = bool:!!(GrenadeBits & (1 << weapon_id))))
	clip = clamp(clip ? clip : 10000 , 1)
	
	get_weaponname(weapon_id, weapon_name, charsmax(weapon_name))
	
	if ((iWeaponEntity = user_has_weapon(id, weapon_id) ? find_ent_by_owner(-1, weapon_name, id) : give_item(id, weapon_name)) > 0)
	{
		if (weapon_id != CSW_KNIFE)
		{
			if (!clip && !bIsGrenade) cs_set_weapon_ammo(iWeaponEntity, 10000) 
			else if (clip && !bIsGrenade)
			{
				cs_set_user_bpammo(id, weapon_id, clip)
				
				if (weapon_id == CSW_C4) 
				cs_set_user_plant(id, 1, 1)
			}
			else if (clip && bIsGrenade) cs_set_user_bpammo(id, weapon_id, clip) 
		}
	}
	
	return iWeaponEntity
}

// Get Zombies -returns alive zombies number-
fnGetZombies()
{
	static iZombies, id
	iZombies = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && CheckBit(g_playerTeam[id], TEAM_ZOMBIE)) iZombies++
	}
	
	return iZombies
}

// Get Humans -returns alive humans number-
fnGetHumans()
{
	static iHumans, id
	iHumans = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && CheckBit(g_playerTeam[id], TEAM_HUMAN)) iHumans++
	}
	
	return iHumans
}

// Get Nemesis -returns alive nemesis number-
fnGetNemesis()
{
	static iNemesis, id
	iNemesis = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_NEMESIS)) iNemesis++
	}
	
	return iNemesis
}

// Get Assassin -returns alive assassin number-
fnGetAssassin()
{
	static iAssasin, id
	iAssasin = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_ASSASIN)) iAssasin++
	}
	
	return iAssasin
}

// Bombardier -- Abhinash
// Get Bombardier -returns alive bombardier number-
fnGetBombardier()
{
	static iBombardier, id
	iBombardier = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_BOMBARDIER)) iBombardier++
	}
	
	return iBombardier
}

// Get Survivors -returns alive survivors number-
fnGetSurvivors()
{
	static iSurvivors, id
	iSurvivors = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_SURVIVOR)) iSurvivors++
	}
	
	return iSurvivors
}

// Get Snipers -returns alive snipers number-
fnGetSnipers()
{
	static iSnipers, id
	iSnipers = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_SNIPER)) iSnipers++
	}
	
	return iSnipers
}


// Get Samurai -returns alive Samurai number-
/*fnGetSamurai()
{
	static iSamurai, id
	iSamurai = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_SAMURAI)) iSamurai++
	}
	
	return iSamurai
}*/

// Get Grenadier -returns alive Grenadier number-
fnGetGrenadier()
{
	static iGrenadier, id
	iGrenadier = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_GRENADIER)) iGrenadier++
	}
	
	return iGrenadier
}

// Get Terminator -returns alive Terminator number-
/*fnGetTerminators()
{
	static iTerminator, id
	iTerminator = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_TERMINATOR)) iTerminator++
	}
	
	return iTerminator
}

// Get Revenants -returns alive Revenant number-
fnGetRevenants()
{
	static iRevenants, id
	iRevenants = 0

	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_REVENANT)) iRevenants++
	}

	return iRevenants
}*/

// Get Alive -returns alive players number-
fnGetAlive()
{
	static iAlive, id
	iAlive = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id]) iAlive++
	}
	
	return iAlive
}

// Get Random Alive -returns index of alive player number n -
fnGetRandomAlive(n)
{
	static iAlive, id
	iAlive = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id]) iAlive++
		
		if (iAlive == n) return id
	}
	
	return -1
}

// Get Playing -returns number of users playing-
fnGetPlaying()
{
	static iPlaying, id, team
	iPlaying = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isconnected[id])
		{
			team = fm_cs_get_user_team(id)
			
			if (team != FM_CS_TEAM_SPECTATOR && team != FM_CS_TEAM_UNASSIGNED) iPlaying++
		}
	}
	
	return iPlaying
}

// Get CTs -returns number of CTs connected-
fnGetCTs()
{
	static iCTs, id
	iCTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isconnected[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_CT) iCTs++
		}
	}
	
	return iCTs
}

// Get Ts -returns number of Ts connected-
fnGetTs()
{
	static iTs, id
	iTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isconnected[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_T) iTs++
		}
	}
	
	return iTs
}

// Get Alive CTs -returns number of CTs alive-
fnGetAliveCTs()
{
	static iCTs, id
	iCTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_CT) iCTs++
		}
	}
	
	return iCTs
}

// Get Alive Ts -returns number of Ts alive-
fnGetAliveTs()
{
	static iTs, id
	iTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_T) iTs++
		}
	}
	
	return iTs
}

fnGetLastHuman()
{
	new id = 1
	while (id <= g_maxplayers)
	{
		if (g_isalive[id] && g_isconnected[id] && CheckBit(g_playerTeam[id], TEAM_HUMAN)) return id 
		id++
	}
	return PLUGIN_CONTINUE
}

fnGetLastZombie()
{
	new id = 1
	while (id <= g_maxplayers)
	{
		if (g_isalive[id] && g_isconnected[id] && CheckBit(g_playerTeam[id], TEAM_ZOMBIE)) return id 
		id++
	}
	return PLUGIN_CONTINUE
}

// Last Zombie Check -check for last zombie and set its flag-
fnCheckLastZombie()
{
	static id
	for (id = 1; id <= g_maxplayers; id++)
	{
		// Last zombie
		if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_ZOMBIE) && fnGetZombies() == 1) 
		{
			if(!g_lastzombie[id]) ExecuteForward(g_forwards[USER_LAST_ZOMBIE], g_forwardRetVal, id) // Last zombie forward
			g_lastzombie[id] = true 
		}
		else g_lastzombie[id] = false 
		
		// Last human
		if (g_isalive[id] && CheckBit(g_playerClass[id], CLASS_HUMAN) && fnGetHumans() == 1)
		{
			if (!g_lasthuman[id]) set_user_health(id, pev(id, pev_health) + LastHumanExtraHealth) // Reward extra hp 
			ExecuteForward(g_forwards[USER_LAST_HUMAN], g_forwardRetVal, id) // Last human forward	
			g_lasthuman[id] = true
		}
		else g_lasthuman[id] = false
	}
}

// Save player's stats to database
SaveStatistics(id)
{
	// Check whether there is another record already in that slot
	if (db_name[id][0] && !equal(g_playerName[id], db_name[id]))
	{
		// If DB size is exceeded, write over old records
		if (db_slot_i >= sizeof db_name)
		db_slot_i = g_maxplayers+1
		
		// Move previous record onto an additional save slot
		copy(db_name[db_slot_i], charsmax(db_name[]), db_name[id])
		db_ammopacks[db_slot_i] = db_ammopacks[id]
		db_zombieclass[db_slot_i] = db_zombieclass[id]
		db_slot_i++
	}
	
	// Now save the current player stats
	copy(db_name[id], charsmax(db_name[]), g_playerName[id]) // name
	db_ammopacks[id] = g_ammopacks[id]  // ammo packs
	db_zombieclass[id] = g_zombieclassnext[id] // zombie class
}

// Load player's stats from database (if a record is found)
load_stats(id)
{
	// Look for a matching record
	static i
	for (i = 0; i < sizeof db_name; i++)
	{
		if (equal(g_playerName[id], db_name[i]))
		{
			// Bingo!
			g_ammopacks[id] = db_ammopacks[i]
			g_zombieclass[id] = db_zombieclass[i]
			g_zombieclassnext[id] = db_zombieclass[i]
			return
		}
	}
}

// Checks if a player is allowed to be zombie
allowed_zombie(id)
{
	if (CheckBit(g_playerClass[id], CLASS_ZOMBIE) || g_endround || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && CheckBit(g_playerTeam[id], TEAM_HUMAN) && fnGetHumans() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to be human
allowed_human(id)
{
	if (CheckBit(g_playerClass[id], CLASS_HUMAN) || g_endround || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && CheckBit(g_playerTeam[id], TEAM_ZOMBIE) && fnGetZombies() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to be survivor
allowed_survivor(id)
{
	if (g_endround || CheckBit(g_playerClass[id], CLASS_SURVIVOR) || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && CheckBit(g_playerTeam[id], TEAM_ZOMBIE) && fnGetZombies() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to be sniper
allowed_sniper(id)
{
	if (g_endround || CheckBit(g_playerClass[id], CLASS_SNIPER) || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && CheckBit(g_playerTeam[id], TEAM_ZOMBIE) && fnGetZombies() == 1))
	return false
	
	return true
}

// Abhinash
// Checks if a player is allowed to be samurai
allowed_samurai(id)
{
	if (g_endround || CheckBit(g_playerClass[id], CLASS_SAMURAI) || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && CheckBit(g_playerTeam[id], TEAM_ZOMBIE) && fnGetZombies() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to be grenadier
allowed_grenadier(id)
{
	if (g_endround || CheckBit(g_playerClass[id], CLASS_GRENADIER) || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && CheckBit(g_playerTeam[id], TEAM_ZOMBIE) && fnGetZombies() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to be Terminator
allowed_terminator(id)
{
	if (g_endround || CheckBit(g_playerClass[id], CLASS_TERMINATOR) || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && CheckBit(g_playerTeam[id], TEAM_ZOMBIE) && fnGetZombies() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to be nemesis
allowed_nemesis(id)
{
	if (g_endround || CheckBit(g_playerClass[id], CLASS_NEMESIS) || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && CheckBit(g_playerTeam[id], TEAM_HUMAN) && fnGetHumans() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to be assassin
allowed_assassin(id)
{
	if (g_endround || CheckBit(g_playerClass[id], CLASS_ASSASIN) || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && CheckBit(g_playerTeam[id], TEAM_HUMAN) && fnGetHumans() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to be bombardier
allowed_bombardier(id)
{
	if (g_endround || CheckBit(g_playerClass[id], CLASS_BOMBARDIER) || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && CheckBit(g_playerTeam[id], TEAM_HUMAN) && fnGetHumans() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to be revenant
allowed_revenant(id)
{
	if (g_endround || CheckBit(g_playerClass[id], CLASS_REVENANT) || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && CheckBit(g_playerTeam[id], TEAM_HUMAN) && fnGetHumans() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to respawn
allowed_respawn(id)
{
	static team
	team = fm_cs_get_user_team(id)
	
	if (g_endround || team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED || g_isalive[id])
	return false
	
	return true
}

// Checks if swarm mode is allowed
allowed_swarm()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG))
	return false
	
	return true
}

// Checks if multi infection mode is allowed
allowed_multi()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround(fnGetAlive() * MultiInfection_ratio, floatround_ceil) < 2 || floatround(fnGetAlive() * MultiInfection_ratio, floatround_ceil) >= fnGetAlive())
	return false
	
	return true
}

// Checks if plague mode is allowed
allowed_plague()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround((fnGetAlive() - (Plague_nemesisCount + Plague_survivorCount)) * Plague_ratio, floatround_ceil) < 1
		|| fnGetAlive() - (Plague_survivorCount + Plague_nemesisCount + floatround((fnGetAlive() - (Plague_nemesisCount + Plague_survivorCount)) * Plague_ratio, floatround_ceil)) < 1)
	return false
	
	return true
}

// Checks if synapsis mode is allowed
allowed_synapsis()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround((fnGetAlive() - (Synapsis_nemesisCount + Synapsis_survivorCount + Synapsis_sniperCount)) * Synapsis_ratio, floatround_ceil) < 1
		|| fnGetAlive() - (Synapsis_nemesisCount + Synapsis_survivorCount + Synapsis_sniperCount + floatround((fnGetAlive() - (Synapsis_nemesisCount + Synapsis_survivorCount + Synapsis_sniperCount)) * Synapsis_ratio, floatround_ceil)) < 1)
	return false
	
	return true
}

// Checks if armageddon mode is allowed
allowed_armageddon()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround(fnGetAlive() * Armageddon_ratio, floatround_ceil) < 2 || floatround(fnGetAlive() * Armageddon_ratio, floatround_ceil) >= fnGetAlive())
	return false
	
	return true
}

// Checks if survivor vs assasin mode is allowed
allowed_survivor_vs_assasin()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround(fnGetAlive() * SurvivorVsAssasin_ratio, floatround_ceil) < 2 || floatround(fnGetAlive() * SurvivorVsAssasin_ratio, floatround_ceil) >= fnGetAlive())
	return false
	
	return true
}

// Checks if bombardier vs grenadier mode is allowed
allowed_bombardier_vs_grenadier()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround(fnGetAlive() * BombardierVsGrenadier_ratio, floatround_ceil) < 2 || floatround(fnGetAlive() * BombardierVsGrenadier_ratio, floatround_ceil) >= fnGetAlive())
	return false
	
	return true
}

// Checks if apocalypse mode is allowed
allowed_apocalypse()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround(fnGetAlive() * Apocalypse_ratio, floatround_ceil) < 2 || floatround(fnGetAlive() * Apocalypse_ratio, floatround_ceil) >= fnGetAlive())
	return false
	
	return true
}

// Checks if nightmare mode is allowed
allowed_nightmare()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround(fnGetAlive() * Nightmare_ratio, floatround_ceil) < 2 || floatround(fnGetAlive() * Nightmare_ratio, floatround_ceil) >= fnGetAlive())
	return false
	
	return true
}

// Abhinash
// Checks if devil mode is allowed
allowed_devil()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround(fnGetAlive() * SniperVsNemesis_ratio, floatround_ceil) < 2 || floatround(fnGetAlive() * SniperVsNemesis_ratio, floatround_ceil) >= fnGetAlive())
	return false
	
	return true
}

CanBuy(category, item, id)
{
	switch (category)
	{
		case EXTRA_HUMANS:
		{	
			switch (item)
			{
				case EXTRA_NIGHTVISION: return true 
				case EXTRA_FORCEFIELD_NADE: return true 
				case EXTRA_KILL_NADE:
				{
					if (g_endround || CheckBit(g_currentmode, MODE_SWARM) 
					|| CheckBit(g_currentmode, MODE_NEMESIS) || CheckBit(g_currentmode, MODE_ASSASIN) 
					|| CheckBit(g_currentmode, MODE_SURVIVOR) || CheckBit(g_currentmode, MODE_SNIPER) 
					|| CheckBit(g_currentmode, MODE_SAMURAI) || CheckBit(g_currentmode, MODE_GRENADIER)
					|| CheckBit(g_currentmode, MODE_SWARM) || CheckBit(g_currentmode, MODE_PLAGUE)
					|| CheckBit(g_currentmode, MODE_SURVIVOR_VS_NEMESIS) || CheckBit(g_currentmode, MODE_SURVIVOR_VS_ASSASIN)
					|| CheckBit(g_currentmode, MODE_SNIPER_VS_ASSASIN) || CheckBit(g_currentmode, MODE_SNIPER_VS_NEMESIS)
					|| CheckBit(g_currentmode, MODE_NIGHTMARE) || CheckBit(g_currentmode, MODE_SYNAPSIS)
					|| CheckBit(g_currentmode, MODE_REVENANT) || CheckBit(g_currentmode, MODE_TERMINATOR)) return false
					else
					{
						if (LIMIT[id][KILL_NADE] == 2)
						{
							client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
							return false
						}

						return true 
					}
				}
				case EXTRA_EXPLOSION_NADE: return true 
				case EXTRA_NAPALM_NADE: return true 
				case EXTRA_FROST_NADE: return true 
				case EXTRA_ANTIDOTE_NADE:
				{
					if (g_endround || CheckBit(g_currentmode, MODE_SWARM) 
					|| CheckBit(g_currentmode, MODE_NEMESIS) || CheckBit(g_currentmode, MODE_ASSASIN) 
					|| CheckBit(g_currentmode, MODE_SURVIVOR) || CheckBit(g_currentmode, MODE_SNIPER) 
					|| CheckBit(g_currentmode, MODE_SAMURAI) || CheckBit(g_currentmode, MODE_GRENADIER)
					|| CheckBit(g_currentmode, MODE_SWARM) || CheckBit(g_currentmode, MODE_PLAGUE)
					|| CheckBit(g_currentmode, MODE_SURVIVOR_VS_NEMESIS) || CheckBit(g_currentmode, MODE_SURVIVOR_VS_ASSASIN)
					|| CheckBit(g_currentmode, MODE_SNIPER_VS_ASSASIN) || CheckBit(g_currentmode, MODE_SNIPER_VS_NEMESIS)
					|| CheckBit(g_currentmode, MODE_NIGHTMARE) || CheckBit(g_currentmode, MODE_SYNAPSIS)
					|| CheckBit(g_currentmode, MODE_REVENANT) || CheckBit(g_currentmode, MODE_TERMINATOR)) return false
					else
					{
						if (LIMIT[id][ANTIDOTE_NADE] == 2)
						{
							client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
							return false
						}

						return true 
					}
				}
				case EXTRA_MULTIJUMP: return true 
				case EXTRA_JETPACK: return true 
				case EXTRA_TRYDER:
				{
					if (LIMIT[id][TRYDER] == 2)
					{
						client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
						return false
					}

					return true 
				}
				case EXTRA_ARMOR_100: return true 
				case EXTRA_ARMOR_200: return true 
				case EXTRA_CROSSBOW: return true 
				case EXTRA_GOLDEN_WEAPONS: return true
				case EXTRA_CLASS_NEMESIS, EXTRA_CLASS_ASSASIN, EXTRA_CLASS_SNIPER, EXTRA_CLASS_SURVIVOR:
				{
					if (g_modestarted ||  g_endround)
					{
						client_print_color(id, print_team_grey, "%s You cannot ^4buy mode ^1right now", CHAT_PREFIX)
						return false
					}
					else
					{
						if (g_roundcount >= 10)
						{
							if (LIMIT[id][MODES] == 1)
							{
								client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
								return false
							}
							else if (g_lastmode != MODE_INFECTION)
							{
								client_print_color(id, print_team_grey, "%s You must wait ^4one ^1more round to buy a mode.", CHAT_PREFIX)
								return false
							}

							return true 
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You must wait till round^3 10 ^1to buy a ^4mode.", CHAT_PREFIX)
							return false
						}
					}
				}
			}	
		}
		case EXTRA_ZOMBIES:
		{
			switch (item)
			{
				case EXTRA_INFECTION_NADE:
				{
					if (g_endround || CheckBit(g_currentmode, MODE_SWARM) 
					|| CheckBit(g_currentmode, MODE_NEMESIS) || CheckBit(g_currentmode, MODE_ASSASIN) 
					|| CheckBit(g_currentmode, MODE_SURVIVOR) || CheckBit(g_currentmode, MODE_SNIPER) 
					|| CheckBit(g_currentmode, MODE_SAMURAI) || CheckBit(g_currentmode, MODE_GRENADIER)
					|| CheckBit(g_currentmode, MODE_SWARM) || CheckBit(g_currentmode, MODE_PLAGUE)
					|| CheckBit(g_currentmode, MODE_SURVIVOR_VS_NEMESIS) || CheckBit(g_currentmode, MODE_SURVIVOR_VS_ASSASIN)
					|| CheckBit(g_currentmode, MODE_SNIPER_VS_ASSASIN) || CheckBit(g_currentmode, MODE_SNIPER_VS_NEMESIS)
					|| CheckBit(g_currentmode, MODE_NIGHTMARE) || CheckBit(g_currentmode, MODE_SYNAPSIS)
					|| CheckBit(g_currentmode, MODE_REVENANT) || CheckBit(g_currentmode, MODE_TERMINATOR)) return false

					return true
				}
				case EXTRA_CONCUSSION_NADE: 
				{
					if (g_endround || CheckBit(g_currentmode, MODE_SWARM) 
					|| CheckBit(g_currentmode, MODE_NEMESIS) || CheckBit(g_currentmode, MODE_ASSASIN) 
					|| CheckBit(g_currentmode, MODE_SURVIVOR) || CheckBit(g_currentmode, MODE_SNIPER) 
					|| CheckBit(g_currentmode, MODE_SAMURAI)
					|| CheckBit(g_currentmode, MODE_SWARM) || CheckBit(g_currentmode, MODE_PLAGUE)
					|| CheckBit(g_currentmode, MODE_SURVIVOR_VS_NEMESIS) || CheckBit(g_currentmode, MODE_SURVIVOR_VS_ASSASIN)
					|| CheckBit(g_currentmode, MODE_SNIPER_VS_ASSASIN) || CheckBit(g_currentmode, MODE_SNIPER_VS_NEMESIS)
					|| CheckBit(g_currentmode, MODE_NIGHTMARE) || CheckBit(g_currentmode, MODE_SYNAPSIS)
					|| CheckBit(g_currentmode, MODE_REVENANT)) return false

					return true
				}
				case EXTRA_ANTIDOTE:
				{
					if (g_endround || CheckBit(g_currentmode, MODE_SWARM) 
					|| CheckBit(g_currentmode, MODE_NEMESIS) || CheckBit(g_currentmode, MODE_ASSASIN) 
					|| CheckBit(g_currentmode, MODE_SURVIVOR) || CheckBit(g_currentmode, MODE_SAMURAI) 
					|| CheckBit(g_currentmode, MODE_SNIPER) || CheckBit(g_currentmode, MODE_PLAGUE) 
					|| CheckBit(g_currentmode, MODE_SURVIVOR_VS_NEMESIS) || CheckBit(g_currentmode, MODE_SURVIVOR_VS_ASSASIN) 
					|| CheckBit(g_currentmode, MODE_SNIPER_VS_ASSASIN) || CheckBit(g_currentmode, MODE_NIGHTMARE) 
					|| CheckBit(g_currentmode, MODE_SYNAPSIS) || CheckBit(g_currentmode, MODE_GRENADIER) 
					|| CheckBit(g_currentmode, MODE_REVENANT) || CheckBit(g_currentmode, MODE_TERMINATOR) || fnGetZombies() <= 1) return false

					return true 
				}
				case EXTRA_MADNESS:
				{
					if (g_nodamage[id]) return false 

					return true 
				}
				case EXTRA_KNIFE_BLINK: return true 
			}
		}
		case PSHOP_PACKS:
		{	
			switch (item)
			{
				case PSHOP_PACKS_100, PSHOP_PACKS_200, PSHOP_PACKS_300, PSHOP_PACKS_400, PSHOP_PACKS_500:
				{
					if (LIMIT[id][PACKS])
					{
						client_print_color(id, print_team_grey, "%s You can only buy packs once a round.", CHAT_PREFIX)
						return false
					}

					return true 
				}
			}	
		}
		case PSHOP_FEATURES:
		{
			switch (item)
			{
				case PSHOP_FEATURE_GOD_MODE:
				{
					if (g_endround || CheckBit(g_currentmode, MODE_SWARM) 
					|| CheckBit(g_currentmode, MODE_NEMESIS) || CheckBit(g_currentmode, MODE_ASSASIN) 
					|| CheckBit(g_currentmode, MODE_SURVIVOR) || CheckBit(g_currentmode, MODE_SNIPER) 
					|| CheckBit(g_currentmode, MODE_PLAGUE) || CheckBit(g_currentmode, MODE_GRENADIER)
					|| CheckBit(g_currentmode, MODE_REVENANT) || CheckBit(g_currentmode, MODE_TERMINATOR))
					{
						client_print_color(id, print_team_grey, "%s This item is not available in current round", CHAT_PREFIX)
						return false
					}
					else if (CheckBit(g_playerClass[id], CLASS_SNIPER) || CheckBit(g_playerClass[id], CLASS_SURVIVOR)) return true
					else
					{
						client_print_color(id, print_team_grey, "%s This item is not for %s", CHAT_PREFIX, g_classString[id])
						return false
					}
				}
				case PSHOP_FEATURE_DOUBLE_DAMAGE, PSHOP_FEATURE_NO_RECOIL, PSHOP_FEATURE_INVISIBILITY, PSHOP_FEATURE_SPRINT, PSHOP_FEATURE_LOW_GRAVITY, PSHOP_FEATURE_HEAD_HUNTER:
				{
					if (CheckBit(g_playerTeam[id], TEAM_ZOMBIE))
					{
						client_print_color(id, print_team_grey, "%s This item is not for %s", CHAT_PREFIX, g_classString[id])
						return false
					}

					return true 	
				}
			}	
		}
		case PSHOP_MODES:
		{
			switch (item)
			{
				case PSHOP_MODE_NIGHTCRAWLER: return true 
				case PSHOP_MODE_SONIC_VS_SHADOW: return true 
				case PSHOP_MODE_BOMBARDIER_VS_GRENADIER: return true
				case PSHOP_MODE_SURVIVOR_VS_NEMESIS, PSHOP_MODE_SURVIVOR_VS_ASSASIN, PSHOP_MODE_SNIPER_VS_ASSASIN, PSHOP_MODE_SNIPER_VS_NEMESIS, PSHOP_MODE_NIGHTMARE, PSHOP_MODE_SYNAPSIS,
				PSHOP_MODE_SAMURAI, PSHOP_MODE_GRENADIER, PSHOP_MODE_TERMINATOR, PSHOP_MODE_BOMBARDIER, PSHOP_MODE_REVENANT:
				{
					if (g_modestarted || g_endround)
					{
						client_print_color(id, print_team_grey, "%s You cannot ^4buy mode ^1right now", CHAT_PREFIX)
						return false
					}
					else
					{
						if (g_roundcount >= 10)
						{
							if (LIMIT[id][CUSTOM_MODES])
							{
								client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
								return false
							}
							else if (g_lastmode != MODE_INFECTION)
							{
								client_print_color(id, print_team_grey, "%s You must wait ^4one ^1more round to buy a mode.", CHAT_PREFIX)
								return false
							}

							return true 
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You must wait till round^3 10 ^1to buy a ^4mode.", CHAT_PREFIX)
							return false
						}
					}
				}
			}
		}
	}

	return true
}

// Abhinash's custom built LogToFile() Funtion
LogToFile(action, admin, target = 0)
{
	static logdata[200], authid[32], ip[16]
	get_user_authid(admin, authid, charsmax(authid))
	get_user_ip(admin, ip, charsmax(ip), 1)

	switch (action)
	{
		case LOG_SLAY: 							formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] slayed %s. [ Players: %d / %d ]", 							g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_SLAP: 							formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] slapped %s. [ Players: %d / %d ]", 							g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_KICK:							formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] kicked %s. [ Players: %d / %d ]", 							g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_GAG:							formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] gagged %s. [ Players: %d / %d ]", 							g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_BAN:							formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] banned %s. [ Players: %d / %d ]", 							g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_FREEZE: 						formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] froze %s. [ Players: %d / %d ]", 							g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_NICK: 							formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] changed nickname of %s. [ Players: %d / %d ]", 				g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_MAP: 							formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] changed map to . [ Players: %d / %d ]", 					g_playerName[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case LOG_MAKE_ZOMBIE: 					formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Zombie. [ Players: %d / %d ]", 					g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_MAKE_HUMAN: 					formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Human. [ Players: %d / %d ]", 					g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_MAKE_NEMESIS:			 		formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Nemesis. [ Players: %d / %d ]", 					g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_MAKE_ASSASIN: 					formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Assassin. [ Players: %d / %d ]", 					g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_MAKE_BOMBARDIER: 				formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Bombardier. [ Players: %d / %d ]", 				g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_MAKE_SNIPER: 					formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Sniper. [ Players: %d / %d ]", 					g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_MAKE_SURVIVOR: 				formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Survivor. [ Players: %d / %d ]", 					g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_MAKE_SAMURAI: 					formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Samurai. [ Players: %d / %d ]", 					g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_MAKE_GRENADIER: 				formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Grenadier. [ Players: %d / %d ]", 				g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_MAKE_TERMINATOR: 				formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Terminator. [ Players: %d / %d ]", 				g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_MAKE_REVENANT: 				formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Revenant. [ Players: %d / %d ]", 				    g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
		case LOG_MODE_MULTIPLE_INFECTION: 		formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Multi-infection mode. [ Players: %d / %d ]", 		g_playerName[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case LOG_MODE_SWARM: 					formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Swarm mode. [ Players: %d / %d ]", 					g_playerName[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case LOG_MODE_PLAGUE: 					formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Plague mode. [ Players: %d / %d ]", 				g_playerName[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case LOG_MODE_SYNAPSIS: 				formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Synapsis mode. [ Players: %d / %d ]", 				g_playerName[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case LOG_MODE_SURVIVOR_VS_ASSASIN: 		formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Survivor vs Assasin mode. [ Players: %d / %d ]", 	g_playerName[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case LOG_MODE_SURVIVOR_VS_NEMESIS: 		formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Armageddon mode. [ Players: %d / %d ]", 			g_playerName[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case LOG_MODE_BOMBARDIER_VS_GRENADIER: 	formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Bombardier vs Grenadier mode. [ Players: %d / %d ]", 			g_playerName[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case LOG_MODE_NIGHTMARE: 				formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Nightmare mode. [ Players: %d / %d ]", 				g_playerName[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case LOG_MODE_SNIPER_VS_ASSASIN: 		formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Sniper vs Assassin mode. [ Players: %d / %d ]", 	g_playerName[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case LOG_MODE_SNIPER_VS_NEMESIS: 		formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Sniper vs Nemesis mode. [ Players: %d / %d ]", 		g_playerName[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case LOG_RESPAWN_PLAYER: 				formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] respawned %s. [ Players: %d / %d ]", 						g_playerName[admin], authid, ip, g_playerName[target], fnGetPlaying(), g_maxplayers)
	}

	log_to_file("ZombieQueen.log", logdata)
}

// Set proper maxspeed for player
set_player_maxspeed(id)
{
	// If frozen, prevent from moving
	if (g_frozen[id]) set_pev(id, pev_maxspeed, 20.0) 
	else if (g_raptor_speeded[id]) set_pev(id, pev_maxspeed, 500.0) 
	else
	{
		if (CheckBit(g_playerTeam[id], TEAM_ZOMBIE))
		{
			if (CheckBit(g_playerClass[id], CLASS_NEMESIS)) set_pev(id, pev_maxspeed, NemesisSpeed)
			else if (CheckBit(g_playerClass[id], CLASS_ASSASIN)) set_pev(id, pev_maxspeed, AssassinSpeed)
			else if (CheckBit(g_playerClass[id], CLASS_BOMBARDIER)) set_pev(id, pev_maxspeed, BombardierSpeed)
			else if (CheckBit(g_playerClass[id], CLASS_REVENANT)) set_pev(id, pev_maxspeed, RevenantSpeed)
			else set_pev(id, pev_maxspeed, g_cZombieClasses[g_zombieclass[id]][Speed])
		}
		else
		{
			if (CheckBit(g_playerClass[id], CLASS_SURVIVOR)) set_pev(id, pev_maxspeed, SurvivorSpeed)
			else if (CheckBit(g_playerClass[id], CLASS_SNIPER)) set_pev(id, pev_maxspeed, SniperSpeed)
			else if (CheckBit(g_playerClass[id], CLASS_SAMURAI)) set_pev(id, pev_maxspeed, SamuraiSpeed)		
			else if (CheckBit(g_playerClass[id], CLASS_GRENADIER)) set_pev(id, pev_maxspeed, GrenadierSpeed)
			else if (CheckBit(g_playerClass[id], CLASS_TERMINATOR)) set_pev(id, pev_maxspeed, TerminatorSpeed)		
			else if (CheckBit(g_playerClass[id], CLASS_SAMURAI)) set_pev(id, pev_maxspeed, TryderSpeed)
			else set_pev(id, pev_maxspeed, HumanSpeed)

			if (g_speed[id]) set_pev(id, pev_maxspeed, 500.0)
		}
	}
}

AdminHasFlag(id, flag)
{
	new i
	while (i < 49)
	{
		if (flag == g_adminInfo[id][_aFlags][i]) return true
		i++
	}

	return PLUGIN_CONTINUE
}

VipHasFlag(id, flag)
{
	new i
	while (i < 32)
	{
		if (flag == g_vipInfo[id][_vFlags][i]) return true
		i++
	}

	return PLUGIN_CONTINUE
}

/*================================================================================
 [Custom Natives]
=================================================================================*/

// Native: admin_has_flag
public native_admin_has_flag(id, flag){ return AdminHasFlag(id, flag); }

// Native: zp_get_user_zombie
public native_get_user_zombie(id){ return CheckBit(g_playerClass[id], CLASS_ZOMBIE); }

// Native: MakeZombie
public native_make_user_zombie(id)
{
	// ZQ Disabled
	if (!g_pluginenabled) return false

	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZQ] Invalid Player (%d)", id)
		return false
	}

	// Not allowed to be zombie
	if (!allowed_zombie(id)) return false

	// New round ?
	if (g_newround)
	{
		// Set as first zombie
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_INFECTION, id)
	}
	else MakeZombie(id) // Just infect

	return true
}

// Native: IsHuman
public native_get_user_human(id){ return CheckBit(g_playerClass[id], CLASS_HUMAN); }

// Native: MakeHuman
public native_make_user_human(id)
{
	// ZQ Disabled
	if (!g_pluginenabled) return false

	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZQ] Invalid Player (%d)", id)
		return false
	}

	// Not allowed to be human
	if (!allowed_human(id)) return false

	// Make him Human
	MakeHuman(id)

	return true
}

// Native: GetPacks
public native_get_user_packs(id){ return g_ammopacks[id]; }

// Native: Addpacks
public native_add_user_packs(id, amount)
{
	if (!amount) return false

	g_ammopacks[id] += amount

	return true
}

// Native: SetPacks
public native_set_user_packs(id, amount){ g_ammopacks[id] = amount; }

// Native: GetPoints
public native_get_user_points(id){ return g_points[id]; }

// Native: AddPoints
public native_add_user_points(id, amount)
{
	if (!amount) return false

	g_points[id] += amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: SetPoints
public native_set_user_points(id, amount)
{
	if (!amount) return false

	g_points[id] = amount
	MySQL_UPDATE_DATABASE(amount)

	return true
}

// Native: GetKills
public native_get_user_kills(id){ return g_kills[id]; }

// Native: AddKills
public native_add_user_kills(id, amount)
{
	if (!amount) return false

	g_kills[id] += amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: SetKills
public native_set_user_kills(id, amount)
{
	if (!amount) return false

	g_kills[id] = amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: GetInfections
public native_get_user_infections(id){ return g_infections[id]; }

// Native: AddInfections
public native_add_user_infections(id, amount)
{
	if (!amount) return false

	g_infections[id] += amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: SetInfections
public native_set_user_infections(id, amount)
{
	if (!amount) return false

	g_infections[id] = amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: GetNemesisKills
public native_get_user_nemesis_kills(id){ return g_nemesiskills[id]; }

// Native: AddNemesisKills
public native_add_user_nemesis_kills(id, amount)
{
	if (!amount) return false

	g_nemesiskills[id] += amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: SetNemesisKills
public native_set_user_nemesis_kills(id, amount)
{
	if (!amount) return false

	g_nemesiskills[id] = amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: GetAssasinKills
public native_get_user_assasin_kills(id){ return g_assasinkills[id]; }

// Native: AddAssasinKills
public native_add_user_assasin_kills(id, amount)
{
	if (!amount) return false

	g_assasinkills[id] += amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: SetAssasinkills
public native_set_user_assasin_kills(id, amount)
{
	if (!amount) return false

	g_assasinkills[id] = amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: GetBombardierKills
public native_get_user_bombardier_kills(id){ return g_bombardierkills[id]; }

// Native: AddBombardierKills
public native_add_user_bombardier_kills(id, amount)
{
	if (!amount) return false

	g_bombardierkills[id] += amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: SetBombariderkills
public native_set_user_bombardier_kills(id, amount)
{
	if (!amount) return false

	g_bombardierkills[id] = amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: GetRevenantKills
public native_get_user_revenant_kills(id){ return g_revenantkills[id]; }

// Native: AddRevenantKills
public native_add_user_revenant_kills(id, amount)
{
	if (!amount) return false

	g_revenantkills[id] += amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: SetRevenantKills
public native_set_user_revenant_kills(id, amount)
{
	if (!amount) return false

	g_revenantkills[id] = amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: GetSurvivorKills
public native_get_user_survivor_kills(id){ return g_survivorkills[id]; }

// Native: AddSurvivorkills
public native_add_user_survivor_kills(id, amount)
{
	if (!amount) return false

	g_survivorkills[id] += amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: SetSurvivorkills
public native_set_user_survivor_kills(id, amount)
{
	if (!amount) return false

	g_survivorkills[id] = amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: GetSniperKills
public native_get_user_sniper_kills(id){ return g_sniperkills[id]; }

// Native: AddSniperKills
public native_add_user_sniper_kills(id, amount)
{
	if (!amount) return false

	g_sniperkills[id] += amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: SetSniperKills
public native_set_user_sniper_kills(id, amount)
{
	if (!amount) return false

	g_sniperkills[id] = amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: GetSmauraiKills
public native_get_user_samurai_kills(id){ return g_samuraikills[id]; }

// Native: AddSamuraiKills
public native_add_user_samurai_kills(id, amount)
{
	if (!amount) return false

	g_samuraikills[id] += amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: SetSamuraiKills
public native_set_user_samurai_kills(id, amount)
{
	if (!amount) return false

	g_samuraikills[id] = amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: GetGrenadierKills
public native_get_user_grenadier_kills(id){ return g_grenadierkills[id]; }

// Native: AddGrenadierKills
public native_add_user_grenadier_kills(id, amount)
{
	if (!amount) return false

	g_grenadierkills[id] += amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: SetGrenadierKills
public native_set_user_grenadier_kills(id, amount)
{
	if (!amount) return false

	g_grenadierkills[id] = amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: GetTerminatorKills
public native_get_user_terminator_kills(id){ return g_terminatorkills[id]; }

// Native: AddTerminatorKills
public native_add_user_terminator_kills(id, amount)
{
	if (!amount) return false

	g_terminatorkills[id] += amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: SetTerminatorKills
public native_set_user_terminator_kills(id, amount)
{
	if (!amount) return false

	g_terminatorkills[id] = amount
	MySQL_UPDATE_DATABASE(id)

	return true
}
// Native: GetNemesis
public native_get_user_nemesis(id){ return CheckBit(g_playerClass[id], CLASS_NEMESIS); }

// Native: MakeNemesis
public native_make_user_nemesis(id)
{
	// ZQ Disabled
	if (!g_pluginenabled) return false

	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZQ] Invalid Player (%d)", id)
		return false
	}

	// Not allowed to be nemesis
	if (!allowed_nemesis(id)) return false

	// New round ?
	if (g_newround)
	{
		// Set as first nemesis
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_NEMESIS, id)
	}
	else MakeZombie(id, CLASS_NEMESIS) // Just make him nemesis

	return true
}

// Native: GetAssasin
public native_get_user_assassin(id){ return CheckBit(g_playerClass[id], CLASS_ASSASIN); }

// Native: MakeAssasin
public native_make_user_assasin(id)
{
	// ZQ Disabled
	if (!g_pluginenabled) return false

	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZQ] Invalid Player (%d)", id)
		return false
	}

	// Not allowed to be assasin
	if (!allowed_assassin(id)) return false

	// New round ?
	if (g_newround)
	{
		// Set as first assasin
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_ASSASIN, id)
	}
	else MakeZombie(id, CLASS_ASSASIN) // Just make him assasin

	return true
}

// Native: GetBombardier
public native_get_user_bombardier(id){ return CheckBit(g_playerClass[id], CLASS_BOMBARDIER); }

// Native: MakeBombardier
public native_make_user_bombardier(id)
{
	// ZQ Disabled
	if (!g_pluginenabled) return false

	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZQ] Invalid Player (%d)", id)
		return false
	}

	// Not allowed to be bombardier
	if (!allowed_bombardier(id)) return false

	// New round ?
	if (g_newround)
	{
		// Set as first bombardier
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_BOMBARDIER, id)
	}
	else MakeZombie(id, CLASS_BOMBARDIER) // Turn him into a Bombardier

	return true
}

// Native: GetRevenant
public native_get_user_revenant(id){ return CheckBit(g_playerClass[id], CLASS_REVENANT); }

// Native: MakeRevenant
public native_make_user_revenant(id)
{
	// ZQ Disabled
	if (!g_pluginenabled) return false

	if (!is_user_valid_alive(id)) 
	{
		log_error(AMX_ERR_NATIVE, "[ZQ] Invalid Player (%d)", id)
		return false
	}

	// Not allowed to be Revenant ?
	if (!allowed_revenant(id)) return false

	if (g_newround)
	{
		// Set as first Revenant
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_REVENANT, id)
	}
	else MakeZombie(id, CLASS_REVENANT) // Make him revenant

	return true
}

// Native: GetSniper
public native_get_user_sniper(id){ return CheckBit(g_playerClass[id], CLASS_SNIPER); }

// Native: MakeSniper
public native_make_user_sniper(id)
{
	// ZQ Disabled
	if (!g_pluginenabled) return false

	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZQ] Invalid Player (%d)", id)
		return false
	}

	// Not allowed to be bombardier
	if (!allowed_sniper(id)) return false

	// New round ?
	if (g_newround)
	{
		// Set as first sniper
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_SNIPER, id)
	}
	else MakeHuman(id, CLASS_SNIPER) // Just make him sniper

	return true
}

// Native: GetSurvivor
public native_get_user_survivor(id){ return CheckBit(g_playerClass[id], CLASS_SURVIVOR); }

// Native: MakeSurvivor
public native_make_user_survivor(id)
{
	// ZQ Disabled
	if (!g_pluginenabled) return false

	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZQ] Invalid Player (%d)", id)
		return false
	}

	// Not allowed to be survivor
	if (!allowed_survivor(id)) return false

	// New round ?
	if (g_newround)
	{
		// Set as first survivor
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_SURVIVOR, id)
	}
	else MakeHuman(id, CLASS_SURVIVOR) // Just make him survivor

	return true
}

// Native: GetSamurai
public native_get_user_samurai(id){ return CheckBit(g_playerClass[id], CLASS_SAMURAI); }

// Native: MakeSamurai
public native_make_user_samurai(id)
{
	// ZQ Disabled
	if (!g_pluginenabled) return false

	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZQ] Invalid Player (%d)", id)
		return false
	}

	// Not allowed to be survivor
	if (!allowed_samurai(id)) return false

	// New round ?
	if (g_newround)
	{
		// Set as first samurai
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_SAMURAI, id)
	}
	else MakeHuman(id, CLASS_SAMURAI) // Just make him samurai

	return true
}

// Native: GetGrenadier
public native_get_user_grenadier(id){ return CheckBit(g_playerClass[id], CLASS_GRENADIER); }

// Native: MakeGrenadier
public native_make_user_grenadier(id)
{
	// ZQ Disabled ?
	if (!g_pluginenabled) return false

	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZQ] Invalid Player (%d)", id)
		return false
	}

	// Not allowed to be grenadier ?
	if (!allowed_grenadier(id)) return false

	// New round ?
	if (g_newround)
	{
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_GRENADIER, id)
	}
	else MakeHuman(id, CLASS_GRENADIER) // Make him Grenadier

	return true
}

// Native: GetTerminator
public native_get_user_terminator(id){ return CheckBit(g_playerClass[id], CLASS_TERMINATOR); }

// Native: MakeTerminator
public native_make_user_terminator(id)
{
	// ZQ Disabled ?
	if (!g_pluginenabled) return false

	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZQ] Invalid Player (%d)", id)
		return false
	}

	// Not allowed to be terminator ?
	if (!allowed_terminator(id)) return false

	// New round ?
	if (g_newround)
	{
		remove_task(TASK_MAKEZOMBIE)
		start_mode(MODE_TERMINATOR, id)
	}
	else MakeHuman(id, CLASS_TERMINATOR) // Make him Terminator

	return true
}

// Native: RespawnPlayer
public native_respawn_player(id)
{
	if (!allowed_respawn(id)) return false

	respawn_player_manually(id)

	return true
}

// Native: GetClassString
public native_get_class_string(plugin, params)
{
	new id = get_param(1)
	set_string(2, g_classString[id], get_param(3))
}

// Native: IsInfectionRound
public native_is_infection_round(){ return CheckBit(g_currentmode, MODE_INFECTION); }

// Native: StartInfectionRound
public native_start_infection_round()
{
	if (g_modestarted) return false

	remove_task(TASK_MAKEZOMBIE)
	start_mode(MODE_INFECTION, fnGetRandomAlive(random_num(1, fnGetAlive())))

	return true
}

// Native: IsMultiInfectionRound
public native_is_multi_infection_round(){ return CheckBit(g_currentmode, MODE_MULTI_INFECTION); }

//Native: StartMultiInfectionRound
public native_start_multi_infection_round()
{
	if (!allowed_multi()) return false

	remove_task(TASK_MAKEZOMBIE)
	start_mode(MODE_MULTI_INFECTION, 0)

	return true
}

// Native: IsSwarmRound
public native_is_swarm_round(){ return CheckBit(g_currentmode, MODE_SWARM); }

// Native: StartSwarmRound
public native_start_swarm_round()
{
	if (!allowed_swarm()) return false

	remove_task(TASK_MAKEZOMBIE)
	start_mode(MODE_SWARM, 0)

	return true
}

// Native: IsPlagueRound
public native_is_plague_round(){ return CheckBit(g_currentmode, MODE_PLAGUE); }

// Native: StartPlagueRound
public native_start_plague_round()
{
	if (!allowed_plague()) return false

	remove_task(TASK_MAKEZOMBIE)
	start_mode(MODE_PLAGUE, 0)

	return true
}

// Native: IsArmageddonRound
public native_is_armageddon_round(){ return CheckBit(g_currentmode, MODE_SURVIVOR_VS_NEMESIS); }

// Native: StartArmageddonRound
public native_start_armageddon_round()
{
	if (!allowed_armageddon()) return false

	remove_task(TASK_MAKEZOMBIE)
	start_mode(MODE_SURVIVOR_VS_NEMESIS, 0)

	return true
}

// Native: IsApocalypseRound
public native_is_apocalypse_round(){ return CheckBit(g_currentmode, MODE_SNIPER_VS_ASSASIN); }

// Native: StartApocalypseRound
public native_start_apocalypse_round()
{
	if (!allowed_apocalypse()) return false

	remove_task(TASK_MAKEZOMBIE)
	start_mode(MODE_SNIPER_VS_ASSASIN, 0)

	return true
}

// Native: IsDevilRound
public native_is_devil_round(){ return CheckBit(g_currentmode, MODE_SNIPER_VS_NEMESIS); }

// Native: StartDevilRound
public native_start_devil_round()
{
	if (!allowed_devil()) return false

	remove_task(TASK_MAKEZOMBIE)
	start_mode(MODE_SNIPER_VS_NEMESIS, 0)

	return true
}

// Native: IsNightmareRound
public native_is_nightmare_round(){ return CheckBit(g_currentmode, MODE_NIGHTMARE); }

// Native: StartNightmareRound
public native_start_nightmare_round()
{
	if (!allowed_nightmare()) return false

	remove_task(TASK_MAKEZOMBIE)
	start_mode(MODE_NIGHTMARE, 0)

	return true
}

// Native: IsSynapsisRound
public native_is_synapsis_round(){ return CheckBit(g_currentmode, MODE_SYNAPSIS); }

// Native: StartSynapsisRound
public native_start_synapsis_round()
{
	if (!allowed_synapsis()) return false

	remove_task(TASK_MAKEZOMBIE)
	start_mode(MODE_SYNAPSIS, 0)

	return true
}

// Native: IsSurvivorVsAssasinRound
public native_is_survivor_vs_assasin_round(){ return CheckBit(g_currentmode, MODE_SURVIVOR_VS_ASSASIN); }

// Native: StartSurvivorVsAssasinRound
public native_start_survivor_vs_assasin_round()
{
	if (!allowed_survivor_vs_assasin()) return false

	remove_task(TASK_MAKEZOMBIE)
	start_mode(MODE_SURVIVOR_VS_ASSASIN, 0)

	return true
}

// Native: IsBombardierVsGrenadierRound
public native_is_bombardier_vs_grenadier_round(){ return CheckBit(g_currentmode, MODE_BOMBARDIER_VS_GRENADIER); }

// Native: StartBombardierVsGrenadierRound
public native_start_bombardier_vs_grenadier_round()
{
	if (!allowed_bombardier_vs_grenadier()) return false

	remove_task(TASK_MAKEZOMBIE)
	start_mode(MODE_BOMBARDIER_VS_GRENADIER, 0)

	return true
}

// Native: RegisterPointsShopWeapon
public native_register_points_shop_weapon(plugin, param)
{
    // Create an array to hold our item data
    new ItemData[pointsShopDataStructure]
    
    // Get item name from function
    get_string(1, ItemData[ItemName], charsmax(ItemData[ItemName]))
    
    // Get item cost from function
    ItemData[ItemCost] = get_param(2)
    
    // Add item to array and increase size
    ArrayPushArray(g_pointsShopWeapons, ItemData)
    g_pointsShopTotalWeapons++
    
    // Return the index of this item in the array
    // This creates the unique item index
    return (g_pointsShopTotalWeapons - 1)
}

// To be used internallly
public register_points_shop_weapon(const name[], const price)
{
	// Create an array to hold our item data
    new ItemData[pointsShopDataStructure]
    
    // Get item name from function
    formatex(ItemData[ItemName], charsmax(ItemData[ItemName]), name)
    
    // Get item cost from function
    ItemData[ItemCost] = price
    
    // Add item to array and increase size
    ArrayPushArray(g_pointsShopWeapons, ItemData)
    g_pointsShopTotalWeapons++
    
    // Return the index of this item in the array
    // This creates the unique item index
    return (g_pointsShopTotalWeapons - 1)
}

// To be used internally
public register_extra_item(const name[], price, team)
{
	// Create an array to hold our item data
	new ItemData[extraItemsDataStructure]

	// Get item name from function
	formatex(ItemData[ItemName], charsmax(ItemData[ItemName]), name)

	// Get item cost from function
	ItemData[ItemCost] = price

	// Get item team from function
	ItemData[ItemTeam] = team

	// Add item to array and increase size
	ArrayPushArray(g_extraitems, ItemData)
	g_extraitemsCount++

	// Return the index of this item in the array
	// This creates the unique item index
	return (g_extraitemsCount - 1)
}

/*================================================================================
	[Custom Messages]
=================================================================================*/

// Custom Night Vision
public set_user_nvision(taskid)
{
	// Retrieve player id
	static id
	id = taskid - TASK_NVISION

	if (CheckBit(g_playerClass[id], CLASS_NEMESIS) || (CheckBit(g_playerTeam[id], TEAM_ZOMBIE) && g_nodamage[id])) SendNightVision(id, NColorNemesis_R, NColorNemesis_G, NColorNemesis_B) // Nemesis / Madness  
	else if (CheckBit(g_playerClass[id], CLASS_ASSASIN)) SendNightVision(id, NColorAssassin_R, NColorAssassin_G, NColorAssassin_B) // Assassin  	
	else if (CheckBit(g_playerClass[id], CLASS_BOMBARDIER)) SendNightVision(id, NColorBombardier_R, NColorBombardier_G, NColorBombardier_B) // Bombardier  	
	else if (CheckBit(g_playerTeam[id], TEAM_HUMAN)) SendNightVision(id, NColorHuman_R, NColorHuman_G, NColorHuman_B) // Human  
	else if (!g_isalive[id]) SendNightVision(id, NColorSpectator_R, NColorSpectator_G, NColorSpectator_B) // Spectators 
	else SendNightVision(id, NColorZombie_R, NColorZombie_G, NColorZombie_B) // Zombie 
	
}

// Game Nightvision
set_user_gnvision(id, toggle)
{
	// Toggle NVG message
	message_begin(MSG_ONE, get_user_msgid("NVGToggle"), _, id)
	write_byte(toggle) // toggle
	message_end()
}

// Custom Flashlight
public set_user_flashlight_1(taskid)
{
	// Retrieve player id
	static id; id = taskid - TASK_FLASH

	// Get player and aiming origins
	static Float:originF[3], Float:destoriginF[3]
	pev(id, pev_origin, originF)
	fm_get_aim_origin(id, destoriginF)

	// Max distance check
	if (get_distance_f(originF, destoriginF) > FlashLightDistance) return

	// Flashlight
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, destoriginF, 0)
	write_byte(TE_DLIGHT) // TE id
	engfunc(EngFunc_WriteCoord, destoriginF[0]) // x
	engfunc(EngFunc_WriteCoord, destoriginF[1]) // y
	engfunc(EngFunc_WriteCoord, destoriginF[2]) // z
	write_byte(FlashLightSize) // radius
	write_byte(FlColor1_R) // r
	write_byte(FlColor1_G) // g
	write_byte(FlColor1_B) // b
	write_byte(3) // life
	write_byte(0) // decay rate
	message_end()
}

// Custom Flashlight
public set_user_flashlight_2(taskid)
{
	// Retrieve player id
	static id; id = taskid - TASK_FLASH

	// Get player and aiming origins
	static Float:originF[3], Float:destoriginF[3]
	pev(id, pev_origin, originF)
	fm_get_aim_origin(id, destoriginF)

	// Max distance check
	if (get_distance_f(originF, destoriginF) > FlashLightDistance) return

	// Flashlight
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, destoriginF, 0)
	write_byte(TE_DLIGHT) // TE id
	engfunc(EngFunc_WriteCoord, destoriginF[0]) // x
	engfunc(EngFunc_WriteCoord, destoriginF[1]) // y
	engfunc(EngFunc_WriteCoord, destoriginF[2]) // z
	write_byte(FlashLightSize) // radius
	write_byte(FlColor2_R) // r
	write_byte(FlColor2_B) // g
	write_byte(FlColor2_G) // b
	write_byte(3) // life
	write_byte(0) // decay rate
	message_end()
}

// Infection special effects
infection_effects(id)
{
	if (!g_frozen[id] && InfectionScreenFade)
	{
		if (CheckBit(g_playerClass[id], CLASS_NEMESIS)) UTIL_ScreenFade(id, {200, 0, 0}, 1.0, 0.5, 100, FFADE_IN, true, false) 
		else if (CheckBit(g_playerClass[id], CLASS_ASSASIN)) UTIL_ScreenFade(id, {0, 150, 0}, 1.0, 0.5, 100, FFADE_IN, true, false) 
		else UTIL_ScreenFade(id, {165, 42, 42}, 1.0, 0.5, 225, FFADE_IN, true, false) 
	}
	
	// Screen shake?
	if (InfectionScreenShake) SendScreenShake(id, UNIT_SECOND * 4, UNIT_SECOND * 2, UNIT_SECOND * 10)
	
	// Infection icon?
	if (HUDIcons)
	{
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Damage"), _, id)
		write_byte(0) // damage save
		write_byte(0) // damage take
		write_long(DMG_NERVEGAS) // damage type - DMG_RADIATION
		write_coord(0) // x
		write_coord(0) // y
		write_coord(0) // z
		message_end()
	}
	
	// Get player's origin
	static origin[3]
	get_user_origin(id, origin)
	
	// Tracers?
	if (InfectionTracers) SendImplosion(id) 
	
	// Particle burst?
	if (InfectionParticles) SendParticleBurst(id) 
	
	// Light sparkle?
	if (InfectionSparkle) SendInfectionLight(id) 
}

// Make zombies leave footsteps and bloodstains on the floor
public make_blood(taskid)
{
	//Retrieve player index
	static id; id = taskid - TASK_BLOOD

	// Only bleed when moving on ground
	if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 80) return
	
	// Get user origin
	static Float:originF[3]
	pev(id, pev_origin, originF)
	
	// If ducking set a little lower
	if (pev(id, pev_bInDuck)) originF[2] -= 18.0
	else originF[2] -= 36.0
	
	// Send the decal message
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_WORLDDECAL) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	write_byte(zombie_decals[random(sizeof zombie_decals)] + (g_czero * 12)) // random decal number (offsets +12 for CZ)
	message_end()
} 

// Burning Flames
public burning_flame(taskid)
{
	// Retrieve player index
	static id; id = taskid - TASK_BURN

	// Get player origin and flags
	static flags; flags = pev(id, pev_flags)

	static iRand, buffer[100]
	
	// Madness mode - in water - burning stopped
	if (g_nodamage[id] || (flags & FL_INWATER) || g_burning_duration[id] < 1)
	{
		// Smoke sprite
		SendSmoke(id)
		
		// Task not needed anymore
		remove_task(taskid)
		return
	}
	
	// Randomly play burning zombie scream sounds (not for nemesis)
	if (CheckBit(g_playerClass[id], CLASS_ZOMBIE) && !random_num(0, 20))
	{
		iRand = random_num(0, ArraySize(Array:g_miscSounds[SOUND_GRENADE_FIRE_PLAYER]) - 1)
		ArrayGetString(Array:g_miscSounds[SOUND_GRENADE_FIRE_PLAYER], iRand, buffer, charsmax(buffer))
		emit_sound(id, CHAN_VOICE, buffer, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	// Fire slow down, unless nemesis
	if (CheckBit(g_playerClass[id], CLASS_ZOMBIE) && (flags & FL_ONGROUND) && FireSlowdown > 0.0)
	{
		static Float:velocity[3]
		pev(id, pev_velocity, velocity)
		xs_vec_mul_scalar(velocity, FireSlowdown, velocity)
		set_pev(id, pev_velocity, velocity)
	}
	
	// Get player's health
	static health; health = pev(id, pev_health)
	
	// Take damage from the fire
	if (health - floatround(FireDamage, floatround_ceil) > 0)
		set_user_health(id, health - floatround(FireDamage, floatround_ceil))
	
	// Flame sprite
	SendFlame(id)
	
	// Decrease burning duration counter
	g_burning_duration[id]--
}

// Update Player Frags and Deaths
UpdateFrags(attacker, victim, frags, deaths, scoreboard)
{
	// Set attacker frags
	set_pev(attacker, pev_frags, float(pev(attacker, pev_frags) + frags))
	
	// Set victim deaths
	fm_cs_set_user_deaths(victim, cs_get_user_deaths(victim) + deaths)
	
	// Update scoreboard with attacker and victim info
	if (scoreboard)
	{
		SendScoreInfo(attacker)
		SendScoreInfo(victim)
	}
}

// Plays a sound on clients
PlaySound(const sound[])
{
	if (equal(sound[strlen(sound)-4], ".mp3"))
		client_cmd(0, "mp3 play ^"sound/%s^"", sound)
	else
		client_cmd(0, "spk ^"%s^"", sound)
}

/*================================================================================
	[Stocks]
=================================================================================*/

// Create fog
stock CreateFog (const index = 0, const red = 127, const green = 127, const blue = 127, const Float:density_f = 0.001, bool:clear = false) 
{    
	static msgFog
	
	if (msgFog || (msgFog = get_user_msgid("Fog")))     
	{         
		new density = _:floatclamp(density_f, 0.0001, 0.25) * _:!clear                
		message_begin(index ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, msgFog, .player = index)        
		write_byte(clamp(red, 0, 255))
		write_byte(clamp(green, 0, 255)) 
		write_byte(clamp(blue , 0, 255)) 
		write_byte((density & 0xFF))
		write_byte((density >>  8) & 0xFF) 
		write_byte((density >> 16) & 0xFF)
		write_byte((density >> 24) & 0xFF)
		message_end()
	} 
}

// Set an entity's key value (from fakemeta_util)
stock fm_set_kvd(entity, const key[], const value[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)
	
	dllfunc(DLLFunc_KeyValue, entity, 0)
}

// Set entity's rendering type (from fakemeta_util)
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal)
{
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)
	
	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(100))
}

// Set entity's glow
stock set_glow(entity, r , g, b , amount)
{
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)
	
	set_pev(entity, pev_renderfx, kRenderFxGlowShell)
	set_pev(entity, pev_rendermode, kRenderNormal)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_renderamt, float(amount))
}

// Set entity's glow
stock remove_glow(entity)
{
	set_pev(entity, pev_renderfx, kRenderFxNone)
	set_pev(entity, pev_rendermode, kRenderNormal)
	set_pev(entity, pev_renderamt, float(0))
}

// Simplified get_weaponid (CS only)
stock cs_weapon_name_to_id(const weapon[]) 
{
	static i
	for (i = 0; i < sizeof WEAPONENTNAMES; i++) if (equal(weapon, WEAPONENTNAMES[i])) return i

	return 0
}

// Get entity's speed (from fakemeta_util)
stock fm_get_speed(entity)
{
	static Float:velocity[3]
	pev(entity, pev_velocity, velocity)
	
	return floatround(vector_length(velocity))
}

// Get entity's aim origins (from fakemeta_util)
stock fm_get_aim_origin(id, Float:origin[3])
{
	static Float:origin1F[3], Float:origin2F[3]
	pev(id, pev_origin, origin1F)
	pev(id, pev_view_ofs, origin2F)
	xs_vec_add(origin1F, origin2F, origin1F)
	
	pev(id, pev_v_angle, origin2F)
	engfunc(EngFunc_MakeVectors, origin2F)
	global_get(glb_v_forward, origin2F)
	xs_vec_mul_scalar(origin2F, 9999.0, origin2F)
	xs_vec_add(origin1F, origin2F, origin2F)
	
	engfunc(EngFunc_TraceLine, origin1F, origin2F, 0, id, 0)
	get_tr2(0, TR_vecEndPos, origin)
}

// Find entity by its owner (from fakemeta_util)
stock fm_find_ent_by_owner(entity, const classname[], owner)
{
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) { /* keep looping */ }
	return entity
}

// Give an item to a player (from fakemeta_util)
stock fm_give_item(id, const item[])
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item))
	if (!pev_valid(ent)) return
	
	static Float:originF[3]
	pev(id, pev_origin, originF)
	set_pev(ent, pev_origin, originF)
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, ent)
	
	static save
	save = pev(ent, pev_solid)
	dllfunc(DLLFunc_Touch, ent, id)
	if (pev(ent, pev_solid) != save) return
	
	engfunc(EngFunc_RemoveEntity, ent)
}

// Strip user weapons (from fakemeta_util)
stock fm_strip_user_weapons(id)
{
	static ent; ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
	if (!pev_valid(ent)) return
	
	dllfunc(DLLFunc_Spawn, ent)
	dllfunc(DLLFunc_Use, ent, id)
	engfunc(EngFunc_RemoveEntity, ent)
}

// Drop primary/secondary weapons
stock drop_weapons(id, dropwhat)
{
	// Get user weapons
	static weapons[32], num, i, weaponid
	num = 0 // reset passed weapons count (bugfix)
	get_user_weapons(id, weapons, num)
	
	// Loop through them and drop primaries or secondaries
	for (i = 0; i < num; i++)
	{
		// Prevent re-indexing the array
		weaponid = weapons[i]
		
		if ((dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)) || (dropwhat == 2 && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)))
		{
			// Get weapon entity
			static wname[32], weapon_ent
			get_weaponname(weaponid, wname, charsmax(wname))
			weapon_ent = fm_find_ent_by_owner(-1, wname, id)
			
			// Hack: store weapon bpammo on PEV_ADDITIONAL_AMMO
			set_pev(weapon_ent, PEV_ADDITIONAL_AMMO, cs_get_user_bpammo(id, weaponid))
			
			// Player drops the weapon and looses his bpammo
			engclient_cmd(id, "drop", wname)
			cs_set_user_bpammo(id, weaponid, 0)
		}
	}
}

// Stock by (probably) Twilight Suzuka -counts number of chars in a string
stock str_count(const str[], searchchar)
{
	new count, i, len = strlen(str)
	
	for (i = 0; i <= len; i++)
	{
		if (str[i] == searchchar)
		count++
	}
	
	return count
}

// Get User Current Weapon Entity
stock fm_cs_get_current_weapon_ent(id)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE) return -1
	
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX)
}

// Get Weapon Entity's Owner
stock fm_cs_get_weapon_ent_owner(ent)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(ent) != PDATA_SAFE) return -1
	
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
}

// Set User Deaths
stock fm_cs_set_user_deaths(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE) return
	
	set_pdata_int(id, OFFSET_CSDEATHS, value, OFFSET_LINUX)
}

// Get User Team
stock fm_cs_get_user_team(id)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE) return FM_CS_TEAM_UNASSIGNED
	
	return get_pdata_int(id, OFFSET_CSTEAMS, OFFSET_LINUX)
}

// Set a Player's Team
stock fm_cs_set_user_team(id, team)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE) return
	
	set_pdata_int(id, OFFSET_CSTEAMS, team, OFFSET_LINUX)
}

// Set User Money
stock fm_cs_set_user_money(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE) return
	
	set_pdata_int(id, OFFSET_CSMONEY, value, OFFSET_LINUX)
}

// Set User Flashlight Batteries
stock fm_cs_set_user_batteries(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE) return
	
	set_pdata_int(id, OFFSET_FLASHLIGHT_BATTERY, value, OFFSET_LINUX)
}

// Update Player's Team on all clients (adding needed delays)
stock fm_user_team_update(id)
{
	static Float:current_time; current_time = get_gametime()
	
	if (current_time - g_teams_targettime >= 0.1)
	{
		set_task(0.1, "fm_cs_set_user_team_msg", id+TASK_TEAM)
		g_teams_targettime = current_time + 0.1
	}
	else
	{
		set_task((g_teams_targettime + 0.1) - current_time, "fm_cs_set_user_team_msg", id+TASK_TEAM)
		g_teams_targettime = g_teams_targettime + 0.1
	}
}

// Send User Team Message
public fm_cs_set_user_team_msg(taskid)
{
	static id; id = taskid - TASK_TEAM

	// Set the switching team flag
	g_switchingteam = true
	
	// Tell everyone my new team
	emessage_begin(MSG_ALL, get_user_msgid("TeamInfo"))
	ewrite_byte(id) // player
	ewrite_string(CS_TEAM_NAMES[fm_cs_get_user_team(id)]) // team
	emessage_end()
	
	// Done switching team
	g_switchingteam = false
}

// Set User Model
/*public set_user_model(player, const model[])
{
	engfunc(EngFunc_SetClientKeyValue, player, engfunc(EngFunc_GetInfoKeyBuffer, player), "model", model)
}

// Get User Model -model passed byref-
stock get_user_model(player, model[], len)
{
	engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, player), "model", model, len)
}*/

// Add Commas in number function - added by Abhinash
public AddCommas(number) 
{ 
	new count, i, str[29], str2[35], len
	num_to_str(number, str, charsmax(str))
	len = strlen(str)

	for(i = 0; i < len; i++) 
	{
		if(i != 0 && ((len - i) %3 == 0)) 
		{
			add(str2, charsmax(str2), ",", 1)
			count++
			add(str2[i+count], 1, str[i], 1)
		}
		else add(str2[i+count], 1, str[i], 1)
	}
	return str2;
}

public CreateBot(const iBotName[])
{
	static iBot; iBot = engfunc(EngFunc_CreateFakeClient, iBotName)
	
	if (!iBot || !pev_valid(iBot))
	{
		log_amx("Bot creation failed")
		return FMRES_IGNORED
	}

	dllfunc(MetaFunc_CallGameEntity, "player", iBot)
	set_pev(iBot, pev_flags, FL_FAKECLIENT)
	
	set_pev(iBot, pev_model, "")
	set_pev(iBot, pev_viewmodel2, "")
	set_pev(iBot, pev_modelindex, 0)
	
	set_pev(iBot, pev_renderfx, kRenderFxNone)
	set_pev(iBot, pev_rendermode, kRenderTransAlpha)
	set_pev(iBot, pev_renderamt, 0.0)
	
	set_pdata_int(iBot, 114, 0)
	message_begin(MSG_ALL, get_user_msgid("TeamInfo"))
	write_byte(iBot)
	write_string("UNASSIGNED")
	message_end()
	
	g_bot[iBot] = true
	g_iBotsCount++

	return FMRES_HANDLED
}  

public RemoveBot()
{
	static i
	for(i = 1; i <= get_maxplayers(); i++) 
	{
		if (g_bot[i]) server_cmd("kick #%d", get_user_userid(i))
	}
}

// Set User Model
public ChangeModels(taskid)
{	
	static id; id = taskid - TASK_MODEL
	static iRand
	static bool:already_has_model; already_has_model = false
	static currentmodel[33]; get_user_model(id, currentmodel, charsmax(currentmodel))
	static tempmodel[33]

	// Check if model change is needed
	if (CheckBit(g_playerClass[id], CLASS_HUMAN))
	{
		if (g_admin[id] && equali(g_adminInfo[id][_aRank], "RANK_OWNER"))
		{
			if (g_vip[id] && VipHasFlag(id, 'i'))
			{
				for (new i; i < ArraySize(Array:g_playerModel[MODEL_VIP]); i++)
				{
					ArrayGetString(Array:g_playerModel[MODEL_VIP], i, tempmodel, charsmax(tempmodel))
					if (equali(currentmodel, tempmodel[i])) already_has_model = true
				}

				if (!already_has_model)
				{
					iRand = random_num(0, ArraySize(Array:g_playerModel[MODEL_VIP]) - 1)
					ArrayGetString(Array:g_playerModel[MODEL_VIP], iRand, tempmodel, charsmax(tempmodel))
					set_user_model(id, tempmodel)
					log_amx("Owner + VIP model changed to = %s", tempmodel)
				}
			}
			else
			{
				for (new i; i < ArraySize(Array:g_playerModel[MODEL_OWNER]); i++)
				{
					ArrayGetString(Array:g_playerModel[MODEL_OWNER], i, tempmodel, charsmax(tempmodel))
					if (equali(currentmodel, tempmodel[i])) already_has_model = true
				}

				if (!already_has_model)
				{
					iRand = random_num(0, ArraySize(Array:g_playerModel[MODEL_OWNER]) - 1)
					ArrayGetString(Array:g_playerModel[MODEL_OWNER], iRand, tempmodel, charsmax(tempmodel))
					set_user_model(id, tempmodel)
					log_amx("Owner model changed to = %s", tempmodel)
				}
			}
		}
		else if (g_admin[id] && !equali(g_adminInfo[id][_aRank], "RANK_OWNER"))
		{
			if (g_vip[id] && VipHasFlag(id, 'i'))
			{
				for (new i; i < ArraySize(Array:g_playerModel[MODEL_VIP]); i++)
				{
					ArrayGetString(Array:g_playerModel[MODEL_VIP], i, tempmodel, charsmax(tempmodel))
					if (equali(currentmodel, tempmodel[i])) already_has_model = true
				}

				if (!already_has_model)
				{
					iRand = random_num(0, ArraySize(Array:g_playerModel[MODEL_VIP]) - 1)
					ArrayGetString(Array:g_playerModel[MODEL_VIP], iRand, tempmodel, charsmax(tempmodel))
					set_user_model(id, tempmodel)
					log_amx("Admin + VIP model changed to = %s", tempmodel)
				}
			}
			else
			{
				for (new i; i < ArraySize(Array:g_playerModel[MODEL_ADMIN]); i++)
				{
					ArrayGetString(Array:g_playerModel[MODEL_ADMIN], i, tempmodel, charsmax(tempmodel))
					if (equali(currentmodel, tempmodel[i])) already_has_model = true
				}

				if (!already_has_model)
				{
					iRand = random_num(0, ArraySize(Array:g_playerModel[MODEL_ADMIN]) - 1)
					ArrayGetString(Array:g_playerModel[MODEL_ADMIN], iRand, tempmodel, charsmax(tempmodel))
					set_user_model(id, tempmodel)
					log_amx("Admin model changed to = %s", tempmodel)
				}
			}
		}
		else if (g_vip[id] && VipHasFlag(id, 'i'))
		{
			for (new i; i < ArraySize(Array:g_playerModel[MODEL_VIP]); i++)
			{
				ArrayGetString(Array:g_playerModel[MODEL_VIP], i, tempmodel, charsmax(tempmodel))
				if (equali(currentmodel, tempmodel[i])) already_has_model = true
			}

			if (!already_has_model)
			{
				iRand = random_num(0, ArraySize(Array:g_playerModel[MODEL_VIP]) - 1)
				ArrayGetString(Array:g_playerModel[MODEL_VIP], iRand, tempmodel, charsmax(tempmodel))
				set_user_model(id, tempmodel)
				log_amx("VIP model changed to = %s", tempmodel)
			}
		}
		else
		{
			for (new i; i < ArraySize(Array:g_playerModel[MODEL_HUMAN]); i++)
			{
				ArrayGetString(Array:g_playerModel[MODEL_HUMAN], i, tempmodel, charsmax(tempmodel))
				if (equali(currentmodel, tempmodel[i])) already_has_model = true
			}

			if (!already_has_model)
			{
				iRand = random_num(0, ArraySize(Array:g_playerModel[MODEL_HUMAN]) - 1)
				ArrayGetString(Array:g_playerModel[MODEL_HUMAN], iRand, tempmodel, charsmax(tempmodel))
				set_user_model(id, tempmodel)
				log_amx("Human model changed to = %s", tempmodel)
			}
		}
	}
	else if (CheckBit(g_playerClass[id], CLASS_SURVIVOR))
	{
		for (new i; i < ArraySize(Array:g_playerModel[MODEL_SURVIVOR]); i++)
		{
			ArrayGetString(Array:g_playerModel[MODEL_SURVIVOR], i, tempmodel, charsmax(tempmodel))
			if (equali(currentmodel, tempmodel[i])) already_has_model = true
		}

		if (!already_has_model)
		{
			iRand = random_num(0, ArraySize(Array:g_playerModel[MODEL_SURVIVOR]) - 1)
			ArrayGetString(Array:g_playerModel[MODEL_SURVIVOR], iRand, tempmodel, charsmax(tempmodel))
			set_user_model(id, tempmodel)
			log_amx("Survivor model changed to = %s", tempmodel)
		}
	}
	else if (CheckBit(g_playerClass[id], CLASS_SNIPER))
	{
		for (new i; i < ArraySize(Array:g_playerModel[MODEL_SNIPER]); i++)
		{
			ArrayGetString(Array:g_playerModel[MODEL_SNIPER], i, tempmodel, charsmax(tempmodel))
			if (equali(currentmodel, tempmodel[i])) already_has_model = true
		}

		if (!already_has_model)
		{
			iRand = random_num(0, ArraySize(Array:g_playerModel[MODEL_SNIPER]) - 1)
			ArrayGetString(Array:g_playerModel[MODEL_SNIPER], iRand, tempmodel, charsmax(tempmodel))
			set_user_model(id, tempmodel)
			log_amx("Samurai model changed to = %s", tempmodel)
		}
	}
	else if (CheckBit(g_playerClass[id], CLASS_SAMURAI))
	{
		for (new i; i < ArraySize(Array:g_playerModel[MODEL_SAMURAI]); i++)
		{
			ArrayGetString(Array:g_playerModel[MODEL_SAMURAI], i, tempmodel, charsmax(tempmodel))
			if (equali(currentmodel, tempmodel[i])) already_has_model = true
		}

		if (!already_has_model)
		{
			iRand = random_num(0, ArraySize(Array:g_playerModel[MODEL_SAMURAI]) - 1)
			ArrayGetString(Array:g_playerModel[MODEL_SAMURAI], iRand, tempmodel, charsmax(tempmodel))
			set_user_model(id, tempmodel)
			log_amx("Samurai model changed to = %s", tempmodel)
		}
	}
	else if (CheckBit(g_playerClass[id], CLASS_TERMINATOR))
	{
		for (new i; i < ArraySize(Array:g_playerModel[MODEL_TERMINATOR]); i++)
		{
			ArrayGetString(Array:g_playerModel[MODEL_TERMINATOR], i, tempmodel, charsmax(tempmodel))
			if (equali(currentmodel, tempmodel[i])) already_has_model = true
		}

		if (!already_has_model)
		{
			iRand = random_num(0, ArraySize(Array:g_playerModel[MODEL_TERMINATOR]) - 1)
			ArrayGetString(Array:g_playerModel[MODEL_TERMINATOR], iRand, tempmodel, charsmax(tempmodel))
			set_user_model(id, tempmodel)
			log_amx("Terminator model changed to = %s", tempmodel)
		}
	}
	else if (CheckBit(g_playerClass[id], CLASS_GRENADIER))
	{
		for (new i; i < ArraySize(Array:g_playerModel[MODEL_GRENADIER]); i++)
		{
			ArrayGetString(Array:g_playerModel[MODEL_GRENADIER], i, tempmodel, charsmax(tempmodel))
			if (equali(currentmodel, tempmodel[i])) already_has_model = true
		}

		if (!already_has_model)
		{
			iRand = random_num(0, ArraySize(Array:g_playerModel[MODEL_GRENADIER]) - 1)
			ArrayGetString(Array:g_playerModel[MODEL_GRENADIER], iRand, tempmodel, charsmax(tempmodel))
			set_user_model(id, tempmodel)
			log_amx("Grenadier model changed to = %s", tempmodel)
		}
	}
	else if (CheckBit(g_playerClass[id], CLASS_NEMESIS))
	{
		for (new i; i < ArraySize(Array:g_playerModel[MODEL_NEMESIS]); i++)
		{
			ArrayGetString(Array:g_playerModel[MODEL_NEMESIS], i, tempmodel, charsmax(tempmodel))
			if (equali(currentmodel, tempmodel[i])) already_has_model = true
		}

		if (!already_has_model)
		{
			iRand = random_num(0, ArraySize(Array:g_playerModel[MODEL_NEMESIS]) - 1)
			ArrayGetString(Array:g_playerModel[MODEL_NEMESIS], iRand, tempmodel, charsmax(tempmodel))
			set_user_model(id, tempmodel)
			log_amx("Grenadier model changed to = %s", tempmodel)
		}
	}
	else if (CheckBit(g_playerClass[id], CLASS_ASSASIN))
	{
		for (new i; i < ArraySize(Array:g_playerModel[MODEL_ASSASIN]); i++)
		{
			ArrayGetString(Array:g_playerModel[MODEL_ASSASIN], i, tempmodel, charsmax(tempmodel))
			if (equali(currentmodel, tempmodel[i])) already_has_model = true
		}

		if (!already_has_model)
		{
			iRand = random_num(0, ArraySize(Array:g_playerModel[MODEL_ASSASIN]) - 1)
			ArrayGetString(Array:g_playerModel[MODEL_ASSASIN], iRand, tempmodel, charsmax(tempmodel))
			set_user_model(id, tempmodel)
			log_amx("Grenadier model changed to = %s", tempmodel)
		}
	}
	else if (CheckBit(g_playerClass[id], CLASS_BOMBARDIER))
	{
		for (new i; i < ArraySize(Array:g_playerModel[MODEL_BOMBARDIER]); i++)
		{
			ArrayGetString(Array:g_playerModel[MODEL_BOMBARDIER], i, tempmodel, charsmax(tempmodel))
			if (equali(currentmodel, tempmodel[i])) already_has_model = true
		}

		if (!already_has_model)
		{
			iRand = random_num(0, ArraySize(Array:g_playerModel[MODEL_BOMBARDIER]) - 1)
			ArrayGetString(Array:g_playerModel[MODEL_BOMBARDIER], iRand, tempmodel, charsmax(tempmodel))
			set_user_model(id, tempmodel)
			log_amx("Grenadier model changed to = %s", tempmodel)
		}
	}
	else if (CheckBit(g_playerClass[id], CLASS_REVENANT))
	{
		for (new i; i < ArraySize(Array:g_playerModel[MODEL_REVENANT]); i++)
		{
			ArrayGetString(Array:g_playerModel[MODEL_REVENANT], i, tempmodel, charsmax(tempmodel))
			if (equali(currentmodel, tempmodel[i])) already_has_model = true
		}

		if (!already_has_model)
		{
			iRand = random_num(0, ArraySize(Array:g_playerModel[MODEL_REVENANT]) - 1)
			ArrayGetString(Array:g_playerModel[MODEL_REVENANT], iRand, tempmodel, charsmax(tempmodel))
			set_user_model(id, tempmodel)
			log_amx("Grenadier model changed to = %s", tempmodel)
		}
	}
	else if (CheckBit(g_playerClass[id], CLASS_ZOMBIE))
	{
		if (equali(currentmodel, g_cZombieClasses[g_zombieclass[id]][Model])) already_has_model = true

		if (!already_has_model)
		{
			set_user_model(id, g_cZombieClasses[g_zombieclass[id]][Model])
			log_amx("Zombie %s model changed to %s", g_playerName[id], g_cZombieClasses[g_zombieclass[id]][Model])
		}	
	}

	return PLUGIN_CONTINUE
}

PrecachePlayerModel(const modelname[]) 
{
	static longname[128]
	formatex(longname, charsmax(longname), "models/player/%s/%s.mdl", modelname, modelname)  	
	engfunc(EngFunc_PrecacheModel, longname) 
}

bool:IsCurrentTimeBetween(iStart, iEnd)
{
    new iHour; time(iHour)
    return bool:(iStart < iEnd ? (iStart <= iHour < iEnd) : (iStart <= iHour || iHour < iEnd))
}

/*public EarthQuake()
	{
	new players[32], iPlayerCount, i, player
	new Screen = get_user_msgid("ScreenShake")
	
	get_players(players, iPlayerCount, "a") 
	for(i = 0; i < iPlayerCount; i++)
	{
	player = players[i]
	
	if(zp_get_user_zombie(player) || zp_get_user_nemesis(player))
	continue
	
	message_begin(MSG_ONE, Screen, {0,0,0}, player)
	write_short(255<< 14 )
	write_short(10 << 14)
	write_short(255<< 14)
	message_end()
	}
}*/