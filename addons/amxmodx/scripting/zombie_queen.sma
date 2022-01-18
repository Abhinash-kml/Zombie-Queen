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
#include <      xs        >
#include <     geoip      >
#include <    targetex     >
#include <		sqlx	  >

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

// Aura
native SendAura(id, red, green, blue)

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
	TASK_AURA,
	TASK_BURN,
	TASK_NVISION,
	TASK_COUNTDOWN,
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

// For player list menu handlers
#define PL_ACTION g_menu_data[id][0]

// Chat prefix
#define CHAT_PREFIX "^4[PerfectZM]^1"

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

new g_groupFlags[MAX_GROUPS][] = 
{
	"abcdefghijkl#$!mnopqrstuvwxyz",
	"abcdefghijkl#$%mnopqrstuvwxyz",
	"abcdefghijkl#$&mnopqrstuvwxyz",
	"defghijklmnopqrstuvwxyz",
	"fghijklmnopqrstuvwxyz",
	"ghijklmnopqrstuvwxyz",
	"ghijklmqrstuvwxyz",
	"ghijklmyz",
	"ghijklyz",
	"st"
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
new HumanHealth = 150
new Float:HumanSpeed = 240.0
new Float:HumanGravity = 1.0
new HumanArmorProtect = 1
new HumanFragsForKill = 1
new LastHumanExtraHealth = 0

// Assassin
new AssassinEnabled = 1
new AssassinChance = 50
new AssassinMinPlayers = 0
new AssassinHealth = 30000
new Float:AssassinSpeed = 600.0
new Float:AssassinGravity = 0.5
new Float:AssassinDamage = 250.0
new AssassinAura = 0

// Nemesis
new NemesisEnabled = 1
new NemesisChance = 20
new NemesisMinPlayers = 0
new NemesisHealth = 150000
new Float:NemesisSpeed = 250.0
new Float:NemesisGravity = 0.5
new Float:NemesisDamage = 250.0
new NemesisAura = 0

// Bombardier
new BombardierEnabled = 1
new BombardierChance = 50
new BombardierMinPlayers = 0
new BombardierHealth = 30000
new Float:BombardierSpeed = 600.0
new Float:BombardierGravity = 0.5
new Float:BombardierDamage = 0.0
new BombardierAura = 0

// Sniper
new SniperEnabled = 1
new SniperChance = 50
new SniperMinPlayers = 0
new SniperHealth = 6000
new Float:SniperSpeed = 300.0
new Float:SniperGravity = 1.0
new Float:SniperDamage = 5000.0
new SniperAura = 0

// Survivor
new SurvivorEnabled = 1
new SurvivorChance = 50
new SurvivorMinPlayers = 0
new SurvivorHealth = 6000
new Float:SurvivorSpeed = 300.0
new Float:SurvivorGravity = 1.0
//new SurvivorAura = 0

// Samurai
new SamuraiEnabled = 1
new SamuraiChance = 50
new SamuraiMinPlayers = 0
new SamuraiHealth = 5000
new Float:SamuraiSpeed = 300.0
new Float:SamuraiGravity = 0.7
new Float:SamuraiDamage = 4000.0
//new SamuraiAura = 0

// Tryder
new TryderHealth = 777
new Float:TryderSpeed = 300.0
new Float:TryderGravity = 0.5

// Knockback
new KnockbackEnabled = 1
new KnockbackDistance = 500
new Float:KnockbackDucking = 0.25
new Float:KnockbackAssassin = 0.7
new Float:KnockbackNemesis	= 0.15
new Float:KnockbackBombardier = 0.5

// Pain Shock free
new AssassinPainfree = 1
new NemesisPainfree = 0
new BombardierPainfree	= 1
new SniperPainfree	= 0
new SurvivorPainfree = 0
new SamuraiPainfree = 1

// Glow 
new NemesisGlow = 1
new AssassinGlow = 0
new SurvivorGlow = 0
new SniperGlow = 1
new SamuraiGlow = 1
new BombardierGlow	= 0
new TryderGlow = 1

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
new StartingPacks = 10

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
new LeapZombies = 1
new LeapZombiesForce = 500
new Float:LeapZombiesHeight = 300.0
new Float:LeapZombiesCooldown = 12.0

new LeapNemesis = 1
new LeapNemesisForce = 500
new Float:LeapNemesisHeight = 300.0
new Float:LeapNemesisCooldown = 1.0

new LeapAssassin = 0
new LeapAssassinForce = 500
new Float:LeapAssassinHeight = 300.0
new Float:LeapAssassinCooldown = 1.0

new LeapBombardier = 0
new LeapBombardierForce = 500
new Float:LeapBombardierHeight = 300.0
new Float:LeapBombardierCooldown = 1.0

new LeapSurvivor = 0
new LeapSurvivorForce = 500
new Float:LeapSurvivorHeight = 300.0
new Float:LeapSurvivorCooldown = 1.0

new LeapSniper = 0
new LeapSniperForce = 500
new Float:LeapSniperHeight = 300.0
new Float:LeapSniperCooldown = 1.0

new LeapSamurai = 0
new LeapSamuraiForce = 500
new Float:LeapSamuraiHeight = 300.0
new Float:LeapSamuraiCooldown = 1.0

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
new SwarmEnable = 1
new SwarmChance = 20
new SwarmMinPlayers = 0

// Multiple Infection Configs
new MultiInfectionEnable = 1
new MultiInfectionChance = 20
new MultiInfectionMinPlayers = 0
new Float:MultiInfectionRatio = 0.15

// Plague Mode configs
new PlagueEnable = 1
new PlagueChance = 30
new PlagueMinPlayers = 5
new Float:PlagueRatio = 0.5
new PlagueNemesisCount = 1
new Float:PlagueNemesisHealthMultiply = 0.5
new PlagueSurvivorCount = 1
new Float:PlagueSurvivorHealthMultiply = 2.0

// Armageddon Mode configs
new ArmageddonEnable = 1
new ArmageddonChance = 25
new ArmageddonMinPlayers = 5
new Float:ArmageddonRatio = 0.5
new Float:ArmageddonNemesisHealthMultiply = 1.0
new Float:ArmageddonSurvivorHealthMultiply = 2.0

// Sniper vs Assassin mode configs
new ApocalypseEnable = 1
new ApocalypseChance = 25
new ApocalypseMinPlayers = 5
new Float:ApocalypseRatio = 0.5
new Float:ApocalypseAssassinHealthMultiply = 0.7
new Float:ApocalypseSniperHealthMultiply = 2.0

// Sniper vs Nemesis mode configs
new DevilEnable = 1
new DevilChance = 25
new DevilMinPlayers = 5
new Float:DevilRatio = 0.5
new Float:DevilSniperHealthMultiply  = 2.0
new Float:DevilSniperNemesisMultiply = 1.0

// Nightmare mode configs
new NightmareEnable = 1
new NightmareChance = 25
new NightmareMinPlayers = 5
new Float:NightmareRatio = 0.5
new Float:NightmareAssassinHealthMultiply = 1.5
new Float:NightmareNemesisHealthMultiply = 1.0
new Float:NightmareSniperHealthMultiply = 1.5
new Float:NightmareSurvivorHealthMultiply = 2.0

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
new g_totalplayers

// GAG
new Float:g_fGagTime[33]

/*================================================================================
	[Models]
=================================================================================*/

new const g_cHumanModels[][] =
{
	"PerfectZM_special1",
	"PerfectZM_special2",
	"gign",
	"sas",
	"arctic"
}

new const g_cNemesisModels[][] =
{
	"PerfectZM_Nemesis"
}
new const g_cAssassinModels[][] =
{
	"PerfectZM_Assassin"
}
new const g_cBombardierModels[][] =
{
	"PerfectZM_Bombardier"
}
new const g_cSurvivorModels[][] =
{
	"PerfectZM_Survivor"
}
new const g_cSniperModels[][] =
{
	"PerfectZM_Sniper"
}
new const g_cSamuraiModels[][] =
{
	"PerfectZM_Samurai"
}
new const g_cAdminModels[][] = 
{
	"PerfectZM_Admin"
}
new const g_cOwnerModels[][] =
{
	"PerfectZM_Owner"
}
new const g_cVipModels[][] =
{
	"PerfectZM_VIP"
}
new const V_KNIFE_HUMAN[] =
{
	"models/v_knife.mdl"
}
new const P_KNIFE_HUMAN[] =
{
	"models/p_knife.mdl"
}
new const V_KNIFE_NEMESIS[] =
{
	"models/PerfectZM/PerfectZM_nemesis_claws.mdl"
}
new const V_KNIFE_ASSASSIN[] =
{
	"models/PerfectZM/PerfectZM_assassin_claws.mdl"
}
new const V_KNIFE_SAMURAI[] =
{
	"models/PerfectZM/v_katana.mdl"
}
new const P_KNIFE_SAMURAI[] =
{
	"models/PerfectZM/p_katana.mdl"
}
new const V_AWP_SNIPER[] =
{
	"models/PerfectZM/v_awp_perfect.mdl"
}
new const P_AWP_SNIPER[] =
{
	"models/PerfectZM/p_awp_perfect.mdl"
}
new const V_INFECTION_NADE[] =
{
	"models/PerfectZM/v_grenade_infect.mdl"
}
new const V_EXPLODE_NADE[] =
{
	"models/v_hegrenade.mdl"
}
new const V_FIRE_NADE[] =
{
	"models/v_flashbang.mdl"
}
new const V_FROST_NADE[] = 
{
	"models/v_smokegrenade.mdl"
}
new const GRENADE_TRAIL[] =
{
	"sprites/laserbeam.spr"
}

/*================================================================================
	[Sounds]
=================================================================================*/

new const sound_win_zombies[][] = 
{ 	
	"ambience/the_horror1.wav",
	"ambience/the_horror3.wav", 
	"ambience/the_horror4.wav" 
}
new const sound_win_humans[][] = 
{ 	
	"PerfectZM/win_humans1.wav", 
	"PerfectZM/win_humans2.wav" 
}
new const sound_win_no_one[][] = 
{ 
	"ambience/3dmstart.wav" 
}
new const zombie_infect[][] = 
{ 
	"PerfectZM/zombie_infect_1.wav", 
	"PerfectZM/zombie_infect_2.wav", 
	"PerfectZM/zombie_infect_3.wav", 
	"PerfectZM/zombie_infect_4.wav",
	"PerfectZM/zombie_infect_5.wav",
	"scientist/c1a0_sci_catscream.wav", 
	"scientist/scream01.wav" 
}
new const zombie_pain[][] = 
{ 
	"PerfectZM/zombie_pain1.wav", 
	"PerfectZM/zombie_pain2.wav", 
	"PerfectZM/zombie_pain3.wav", 
	"PerfectZM/zombie_pain4.wav", 
	"PerfectZM/zombie_pain5.wav" 
}
new const nemesis_pain[][] = 
{ 
	"PerfectZM/nemesis_pain1.wav", 
	"PerfectZM/nemesis_pain2.wav", 
	"PerfectZM/nemesis_pain3.wav" 
}
new const assassin_pain[][] = 
{ 
	"PerfectZM/nemesis_pain1.wav", 
	"PerfectZM/nemesis_pain2.wav", 
	"PerfectZM/nemesis_pain3.wav" 
}
new const zombie_die[][] = 
{ 
	"PerfectZM/zombie_die1.wav", 
	"PerfectZM/zombie_die2.wav", 
	"PerfectZM/zombie_die3.wav", 
	"PerfectZM/zombie_die4.wav", 
	"PerfectZM/zombie_die5.wav" 
}
new const zombie_fall[][] = 
{ 
	"PerfectZM/zombie_fall1.wav" 
}
new const zombie_miss_slash[][] = 
{ 
	"weapons/knife_slash1.wav", 
	"weapons/knife_slash2.wav" 
}
new const zombie_miss_wall[][] = 
{ 
	"weapons/knife_hitwall1.wav" 
}
new const zombie_hit_normal[][] = 
{ 
	"weapons/knife_hit1.wav", 
	"weapons/knife_hit2.wav", 
	"weapons/knife_hit3.wav", 
	"weapons/knife_hit4.wav" 
}
new const zombie_hit_stab[][] = 
{ 
	"weapons/knife_stab.wav" 
}
new const zombie_idle[][] = 
{ 
	"nihilanth/nil_now_die.wav", 
	"nihilanth/nil_slaves.wav", 
	"nihilanth/nil_alone.wav", 
	"PerfectZM/zombie_brains1.wav", 
	"PerfectZM/zombie_brains2.wav" 
}
new const zombie_idle_last[][] = 
{ 
	"nihilanth/nil_thelast.wav" 
}
new const zombie_madness[][] = 
{ 
	"PerfectZM/zombie_madness1.wav" 
}
new const sound_nemesis[][] = 
{ 
	"PerfectZM/nemesis1.wav", 
	"PerfectZM/nemesis2.wav" 
}
new const sound_assassin[][] =
{
	"PerfectZM/nemesis1.wav", 
	"PerfectZM/nemesis2.wav" 
}
new const sound_bombardier[][] =
{
	"PerfectZM/nemesis1.wav", 
	"PerfectZM/nemesis2.wav" 
}
new const sound_survivor[][] = 
{ 
	"PerfectZM/survivor1.wav", 
	"PerfectZM/survivor2.wav" 
}
new const sound_sniper[][] = 
{ 
	"PerfectZM/survivor1.wav", 
	"PerfectZM/survivor2.wav" 
}
new const sound_samurai[][] = 
{ 
	"PerfectZM/survivor1.wav", 
	"PerfectZM/survivor2.wav" 
}
new const sound_swarm[][] = 
{ 
	"ambience/the_horror2.wav" 
}
new const sound_multi[][] = 
{ 
	"ambience/the_horror2.wav" 
}
new const sound_plague[][] = 
{ 
	"PerfectZM/nemesis1.wav", 
	"PerfectZM/survivor1.wav" 
}
new const sound_armageddon[][] = 
{ 
	"PerfectZM/nemesis1.wav", 
	"PerfectZM/survivor1.wav" 
}
new const sound_nightmare[][] = 
{ 
	"PerfectZM/nemesis1.wav",
	"PerfectZM/nemesis2.wav", 
	"PerfectZM/survivor1.wav", 
	"PerfectZM/survivor2.wav" 
}
new const sound_apocalypse[][] = 
{ 
	"PerfectZM/survivor1.wav" 
}
new const sound_devil[][] = 
{ 
	"PerfectZM/nemesis2.wav" 
}
new const grenade_infect[][] = 
{ 
	"PerfectZM/grenade_infect.wav" 
}
new const grenade_infect_player[][] = 
{ 
	"scientist/scream20.wav", 
	"scientist/scream22.wav", 
	"scientist/scream05.wav" 
}
new const grenade_fire[][] = 
{ 
	"PerfectZM/grenade_explode.wav" 
}
new const grenade_fire_player[][] = 
{ 
	"PerfectZM/zombie_burn3.wav",
	"PerfectZM/zombie_burn4.wav",
	"PerfectZM/zombie_burn5.wav",
	"PerfectZM/zombie_burn6.wav",
	"PerfectZM/zombie_burn7.wav" 
}
new const grenade_frost[][] = 
{ 
	"warcraft3/frostnova.wav" 
}
new const grenade_frost_player[][] = 
{ 
	"warcraft3/impalehit.wav" 
}
new const grenade_frost_break[][] = 
{ 
	"warcraft3/impalelaunch1.wav" 
}
new const sound_antidote[][] = 
{ 
	"items/smallmedkit1.wav" 
}

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

// Tags
new g_Tag[33][24]
new g_cTag[33][24]

// Admin stuff
new g_bAdmin[33]
new g_AdminNames[33][32]
new g_AdminSkinFlags[33][32]
new g_AdminPasswords[128][32]
new g_AdminFlags[33][32]

new g_cPassword[33][32]
new g_cAdminFlag[33][32]
new g_cAdminSkinFlag[33][32]
new g_cIP[33][24]

new g_AdminsCount

// Vip stuff
new g_bVip[33]
new g_VipNames[33][32]
new g_VipPasswords[128][32]
new g_VipFlags[33][32]

new g_cVipPassword[33][32]
new g_cVipFlag[33][32]
new g_VipsCount

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
new bool:g_unlimitedclip[33]
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
new bool:g_goldenak47[33]
new bool:g_goldenm4a1[33]
new bool:g_goldenxm1014[33]
new bool:g_goldendeagle[33]

new bool:g_doubledamage[33]
new bool:g_norecoil[33]
new bool:g_speed[33]
//new bool:g_allheadshots[33]

// Knife Blink
new g_blinks[33]

// Force Field Grenade Entity
new const BubbleEntityClassName[] = "Force-Field_Grenade"
new const BubbleGrenadeModel[] = "models/PerfectZM/aura8.mdl"
new Float:BubbleGrenadeMaxs[3] = { 100.0 , 100.0 , 100.0 }
new Float:BubbleGrenadeMins[3] = { -100.0, -100.0, -100.0 }

// Map related
new MapCountdownTimer = 10
new bool:g_bVoting
new bool:g_bSecondVoting
new g_iVariable
new g_iVariables[3]
new g_iVotes[7]
new g_cMaps[7][32]
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
new Array:g_Messages

// GeoIP
new g_playercountry[33][32]
new g_playercity[33][32]

/*================================================================================
	[Core stuffs...]
=================================================================================*/

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
	{"Frozen", 			"\r[Freeze humans]", 	6550, 244.0, 1.00, 0.44, 	"PerfectZM_Frozen", 			 "models/PerfectZM/PerfectZM_frozen_claws.mdl"},
	{"Regenerator", 	"\r[Regeneration]",   	7000, 269.0, 0.61, 0.80, 	"PerfectZM_Regenerator", 	 	 "models/PerfectZM/PerfectZM_regenerator_claws.mdl"},
	{"Predator Blue", 	"\r[Invisiblity]", 	  	10000, 249.0, 1.00, 0.90, 	"PerfectZM_Predator", 	 	 	 "models/PerfectZM/PerfectZM_predator_claws.mdl"},
	{"Hunter", 			"\r[Remove weapon]",    9000, 273.0, 0.61, 0.83, 	"PerfectZM_Hunter", 			 "models/PerfectZM/PerfectZM_hunter_claws.mdl"}
}


enum _:PMenuData
{
	PItemName[20]
}

new g_cPointsMenu[][PMenuData] =
{
	{"Buy Ammo Packs"},
	{"Buy Features"},
	{"Buy Modes"},
	{"Buy Access"}
}

enum _:AMenuData
{
	AItemName[20],
	AItemTag[32],
	APoints
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
	FItemName[32],
	FItemTag[32],
	FPoints
}

new g_cFeaturesMenu[][FMenuData] =
{
	{"God Mode", "\r[100 points]", 100},
	{"Double Damage", "\r[50 points]", 50},
	{"No Recoil", "\r[70 points]", 70},
	{"Invisibility", "\r[120 points]", 120},
	{"Sprint Ability", "\r[400 points]", 400},
	{"Low Gravity", "\r[50 points]", 50},
	{"Head Hunter", "\r[600 points]", 600}
}

enum _:MMenuData
{
	MItemName[64],
	MItemTag[32],
	MPoints
}

new g_cModesMenu[][MMenuData] =
{
	{"Armageddon Mode", "\r[120 points]", 120},
	{"Nightmare Mode", "\r[140 points]", 140},
	{"NightCrawler Mode\y(comming soon)", "\r[200 points]", 200},
	{"Synapsis Mode\y(comming soon)", "\r[120 points]", 120},
	{"Sonic vs Shadow Mode\y(comming soon)", "\r[300 points]", 300},
	{"Sniper vs Nemesis Mode", "\r[150 points]", 150},
	{"Sniper vs Assassin Mode", "\r[150 points]", 150},
	{"Bombardier vs Grenadier Mode\y(comming soon)", "\r[500 points]", 500}
}

enum _:aCMenuData
{
	aCItemName[32],
	aCItemTag[32],
	aCPoints
}

new g_cAccessMenu[][aCMenuData] =
{
	{"Buy Server Slot\y(comming soon)", "\r[2250 points]", 2250},
	{"Buy Silver VIP\y(comming soon)", "\r[10000 points]", 10000},
	{"Buy Golden VIP\y(comming soon)", "\r[20000 points]", 20000},
	{"Buy Diamond VIP\y(comming soon)", "\r[40000 points]", 40000}
}

enum _:structExtrasTeam
{
	HUMAN = 0,
	ZOMBIE
}

enum _:ExtraItemsData
{
	ItemName[32],
	PriceTag[20],
	Price,
	Team,
	LimitPerRound,
	LimitPerMap
}

new g_cExtraItems[][ExtraItemsData] =
{
	{"Nightvision Goggles", "\r[2 packs]", 2, HUMAN, 5, 50}, // 1
	{"Explosion Grenade", "\r[5 packs]", 5, HUMAN, 5, 50}, // 2
	{"Napalm Grenade", "\r[5 packs]", 5, HUMAN, 5, 50}, // 3
	{"Force Field Grenade", "\r[15 packs]", 15, HUMAN, 5, 50}, // 4
	{"Frost Grenade", "\r[5 packs]", 5, HUMAN, 5, 50}, // 5
	{"Killing Grenade", "\r[20 packs]", 20, HUMAN, 5, 50}, // 6
	{"Antidote Grenade", "\r[15 packs]", 15, HUMAN, 5, 50}, // 7
	{"Unlimited Clip", "\r[10 packs]", 10, HUMAN, 5, 50}, // 1
	{"Multijump +1", "\r[5 packs]", 15, HUMAN, 5, 50}, // 2
	{"Jetpack + Bazooka", "\r[32 packs]", 32, HUMAN, 5, 50}, // 3
	{"Tryder", "\r[30 packs]", 30, HUMAN, 5, 50}, // 4
	{"Armor \y(100 AP)", "\r[5 packs]", 5, HUMAN, 5, 50}, // 5
	{"Armor \y(200 AP)", "\r[10 packs]", 10, HUMAN, 5, 50}, // 6
	{"Crossbow", "\r[30 packs]", 30, HUMAN, 5, 50}, // 7
	{"Golden Kalasnikov \y(AK-47)", "\r[40 packs]", 40, HUMAN, 5, 50}, // 1
	{"Golden Maverick \y(M4-A1)", "\r[40 packs]", 40, HUMAN, 5, 50}, // 2
	{"Golden Leone \y(XM-1014)", "\r[40 packs]", 40, HUMAN, 5, 50}, // 3
	{"Golden Deagle \y(Night Hawk)", "\r[25 packs]", 25, HUMAN, 5, 50}, // 4
	{"Nemesis", "\r[150 packs]", 150, HUMAN, 1, 1}, // 5
	{"Assassin", "\r[150 packs]", 150, HUMAN, 1, 1}, //  6
	{"Sniper", "\r[180 packs]", 180, HUMAN, 1, 1}, // 7
	{"Survivor", "\r[180 packs]", 180, HUMAN, 1, 1} // 1
}

enum _:ExtraItemsData2
{
	ZItemName[32],
	ZPriceTag[20],
	ZPrice,
	ZTeam,
	ZLimitPerRound,
	ZLimitPerMap
}

new g_cExtraItemsZombie[][ExtraItemsData2] =
{
	{"Antidote", "\r[15 packs]", 15, ZOMBIE, 5, 50}, // 1
	{"Zombie Madness", "\r[17 packs]", 17, ZOMBIE, 5, 50}, // 2
	{"Infection bomb", "\r[25 packs]", 25, ZOMBIE, 5, 50}, // 3
	{"Concussion bomb", "\r[10 packs]", 10, ZOMBIE, 5, 50}, // 4
	{"Knife Blink", "\r[10 packs]", 10, ZOMBIE, 5, 50} // 4
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

enum _:WeaponsData
{
	weaponName[20],
	weaponID[20],
	weaponCSW
}

new g_PrimaryWeapons[][WeaponsData] =
{
	{"GALIL", "weapon_galil", CSW_GALIL},
	{"FAMAS", "weapon_famas", CSW_FAMAS},
	{"M4A1", "weapon_m4a1", CSW_M4A1},
	{"AK47", "weapon_ak47", CSW_AK47},
	{"AUG", "weapon_aug", CSW_AUG},
	{"SG552", "weapon_sg552", CSW_SG552},
	{"XM1014", "weapon_xm1014", CSW_XM1014},
	{"M3", "weapon_m3", CSW_M3},
	{"MP5NAVY", "weapon_mp5navy", CSW_MP5NAVY},
	{"P90", "weaponp90", CSW_P90}
}
new g_SecondaryWeapons[][WeaponsData] =
{
	{"USP", "weapon_usp", CSW_USP},
	{"GLOCK18", "weapon_glock18", CSW_GLOCK18},
	{"P228", "weapon_p228", CSW_P228},
	{"DEAGLE", "weapon_deagle", CSW_DEAGLE},
	{"ELITE", "weapon_elite", CSW_ELITE},
	{"FIVESEVEN", "weapon_fiveseven", CSW_FIVESEVEN}
}

new g_iGameMenu
new g_iZombieClassMenu
new g_iExtraItemsMenu
new g_iExtraItems2Menu
new g_iPointShopMenu
new g_iAmmoMenu
new g_iFeaturesMenu
new g_iModesMenu
new g_iAccessMenu

new g_PrimaryMenu
new g_SecondaryMenu

new g_cClass[33][14]

// Class names and game modes
enum
{
	none = 0,
	zombie,
	human,
	respawn,
	infection,
	nemesis,
	assassin,
	survivor,
	sniper,
	samurai,
	tryder,     
	bombardier, 	
	swarm,
	multi,
	plague,
	armageddon,
	apocalypse,
	nightmare,
	devil,
	nightvision,
	explosion_nade,
	napalm_nade,
	forcefield_nade,
	frost_nade,
	killing_nade,
	antidote_nade,
	infection_nade,
	concussion_nade,
	unlimitedclip,
	multijump,
	jetpack,
	armor100,
	armor200,
	crossbow,
	goldenak,
	goldenm4,
	goldenxm,
	goldendeagle,
	antidote,
	madness,
	knifeblink,
	godmode,
	doubledamage,
	norecoil,
	invisibility,
	sprint,
	lowgravity,
	headhunter,
	armagedddon,
	nightcrawler,
	synapsis,
	sonic_vs_shadow,
	shoppacks
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
	-1 , 52 , -1 , 90 ,
	1  , 32 , 1  , 100,
	90 , 1  , 120, 100,
	100, 90 , 90 , 90 ,
	100, 120, 30 , 120,
	200, 32 ,  90, 120,
	90 , 2  , 35 , 90 ,
	90 , -1 , 100
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
	"",
	"357sig",
	"",
	"762nato",
	"",
	"buckshot",
	"",
	"45acp", 
	"556nato",
	"",
	"9mm",
	"57mm", 
	"45acp",
	"556nato",
	"556nato", 
	"556nato",
	"45acp",
	"9mm",
	"338magnum", 
	"9mm",
	"556natobox",
	"buckshot",
	"556nato", 
	"9mm",
	"762nato",
	"",
	"50ae",
	"556nato", 
	"762nato",
	"",
	"57mm" 
}

// Weapon entity names
new const WEAPONENTNAMES[][] =
{ 
	"",
	"weapon_p228",
	"",
	"weapon_scout",
	"weapon_hegrenade",
	"weapon_xm1014",
	"weapon_c4",
	"weapon_mac10",
	"weapon_aug",
	"weapon_smokegrenade",
	"weapon_elite",
	"weapon_fiveseven",
	"weapon_ump45",
	"weapon_sg550",
	"weapon_galil",
	"weapon_famas",
	"weapon_usp",
	"weapon_glock18",
	"weapon_awp",
	"weapon_mp5navy",
	"weapon_m249",
	"weapon_m3",
	"weapon_m4a1",
	"weapon_tmp",
	"weapon_g3sg1",
	"weapon_flashbang",
	"weapon_deagle",
	"weapon_sg552",
	"weapon_ak47",
	"weapon_knife",
	"weapon_p90" 
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
	NADE_TYPE_EXPLODE,
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

// Menu keys
const KEYS_ADMINMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_0
const KEYS_ADMINMENUCLASSES = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0
const KEYS_ADMINMENUMODES = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0
const KEYS_ADMINCUSTOMMODES = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0

// Admin menu actions
enum
{
	ACTION_ZOMBIEFY_HUMANIZE = 0,
	ACTION_MAKE_NEMESIS,
	ACTION_MAKE_ASSASSIN,
	ACTION_MAKE_BOMBARDIER,
	ACTION_MAKE_SURVIVOR,
	ACTION_MAKE_SNIPER,
	ACTION_MAKE_SAMURAI,			// Abhinash
	ACTION_RESPAWN_PLAYER
}

// Admin modes menu actions
enum
{
	ACTION_MODE_SWARM,
	ACTION_MODE_MULTI,
	ACTION_MODE_PLAGUE
}

// Admin custom modes menu actions
enum
{
	ACTION_MODE_ARMAGEDDON,
	ACTION_MODE_APOCALYPSE,
	ACTION_MODE_NIGHTMARE,
	ACTION_MODE_DEVIL
}
/*================================================================================
	[Global Variables]
=================================================================================*/

// Player vars
new g_zombie[33] // is zombie
new g_nemesis[33] // is nemesis
new g_assassin[33] // is assassin
new g_bombardier[33] // is bombardier		// Abhinash
new g_survivor[33] // is survivor
new g_sniper[33] // is assassin
new g_samurai[33]	 // is samurai 				// Abhinash
new g_tryder[33]	// is tryder
new g_specialclass[33]	// is special class for reminder task and other stuffs
new g_firstzombie[33] // is first zombie
new g_lastzombie[33] // is last zombie
new g_lasthuman[33] // is last human
new g_frozen[33] // is frozen (can't move)
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
new g_menu_data[33][8] // data for some menu handlers
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
new g_nemround // nemesis round
new g_assaround // assassin round
new g_bombardierround // bombardier round
new g_survround // survivor round
new g_sniround // sniper round
new g_samurairound // samurai round    // Abhinash
new g_swarmround // swarm round
new g_plagueround // plague round
new g_armageround // armageddon round
new g_apocround // apocalypse round
new g_nightround // nightmare round
new g_devilround // devil round ( Sniper vs Nemesis) // Abhinash
new g_modestarted // mode fully started
new g_currentmode // current mode
new g_lastmode // last played mode
new g_scorezombies, g_scorehumans, g_gamecommencing // team scores
new Float:g_models_targettime // for adding delays between Model Change messages
new Float:g_teams_targettime // for adding delays between Team Change messages
new g_MsgSync, g_MsgSync2, g_MsgSync3, g_MsgSync4, g_MsgSync5[4], g_MsgSync6, g_MsgSync7 // message sync objects
new g_trailspr, g_Explode// grenade sprites
new g_freezetime // whether CS's freeze time is on
new g_maxplayers // max players counter
new g_czero // whether we are running on a CZ serverPerfectZM
new g_hamczbots // whether ham forwards are registered for CZ bots
new UnregisterFwSpawn, UnregisterFwPrecacheSound // spawn and precache sound forward handles
new g_switchingteam // flag for whenever a player's team change emessage is sent
new g_buyzone_ent // custom buyzone entity

// Temporary Database vars (used to restore players stats in case they get disconnected)
new db_name[MAX_STATS_SAVED][32] // player name
new db_ammopacks[MAX_STATS_SAVED] // ammo pack count
new db_zombieclass[MAX_STATS_SAVED] // zombie class
new db_slot_i // additional saved slots counter (should start on maxplayers+1)

// CVAR pointers
new cvar_toggle,
cvar_botquota

/// Cached stuff for players
new g_isconnected[33] // whether player is connected
new g_isalive[33] // whether player is alive
new g_isbot[33] // whether player is a bot
new g_currentweapon[33] // player's current weapon id
new g_playername[33][32] // player's name
#define is_user_valid_connected(%1) (1 <= %1 <= g_maxplayers && g_isconnected[%1])
#define is_user_valid_alive(%1) (1 <= %1 <= g_maxplayers && g_isalive[%1])
#define is_user_valid(%1) (1 <= %1 <= g_maxplayers)

// Cached CVARs
new g_cached_customflash, g_cached_zombiesilent, g_cached_leapnemesis,
g_cached_leapsurvivor, Float:g_cached_leapzombiescooldown, Float:g_cached_leapnemesiscooldown, g_cached_leapassassin, Float:g_cached_leapassassincooldown,
Float:g_cached_leapsurvivorcooldown, g_cached_leapsniper, Float:g_cached_leapsnipercooldown,
g_cached_leapzadoc, Float:g_cached_leapzadoccooldown, g_cached_leapbombardier, Float:g_cached_leapbombardiercooldown


/*================================================================================
	[Natives and Init]
=================================================================================*/

public plugin_natives()
{
	// Admin related natives
	register_native("AdminHasFlag", "native_admin_has_flag", 1)

	// Data related natives
	register_native("GetPacks", 		  "native_get_user_packs", 1) 				// Get
	register_native("AddPacks",           "native_add_user_packs", 1)				// Add
	register_native("SetPacks", 		  "native_set_user_packs", 1)				// Set
	register_native("GetPoints", 		  "native_get_user_points", 1)				// Get
	register_native("AddPoints",          "native_add_user_points", 1)				// Add
	register_native("SetPoints", 		  "native_set_user_points", 1)				// Set
	register_native("GetKills", 		  "native_get_user_kills", 1)				// Get
	register_native("AddKills",           "native_add_user_kills", 1)				// Add
	register_native("SetKills", 		  "native_set_user_kills", 1)				// Set
	register_native("GetInfections", 	  "native_get_user_infections", 1)			// Get
	register_native("AddInfections",      "native_add_user_infections", 1)			// Add
	register_native("SetInfections", 	  "native_set_user_infections", 1)			// Set
	register_native("GetNemesisKills", 	  "native_get_user_nemesis_kills", 1)		// Get
	register_native("AddNemesisKills",    "native_add_user_nemesis_kills", 1)		// Add
	register_native("SetNemesisKills", 	  "native_set_user_nemesis_kills", 1)		// Set
	register_native("GetAssasinKills", 	  "native_get_user_assasin_kills", 1)		// Get
	register_native("AddAssasinKills",    "native_add_user_assasin_kills", 1)		// Add
	register_native("SetAssasinKills", 	  "native_set_user_assasin_kills", 1)		// Set
	register_native("GetBombardierKills", "native_get_user_bombardier_kills", 1)	// Get
	register_native("AddBombardierKills", "native_add_user_bombardier_kills", 1)	// Add
	register_native("SetBombardierKills", "native_set_user_bombardier_kills", 1)	// Set
	register_native("GetSurvivorKills",   "native_get_user_survivor_kills", 1)		// Get
	register_native("AddSurvivorKills",   "native_add_user_survivor_kills", 1)		// Add
	register_native("SetSurvivorKills",   "native_set_user_survivor_kills", 1)		// Set
	register_native("GetSniperKills", 	  "native_get_user_sniper_kills", 1)		// Get
	register_native("AddSniperKills",     "native_add_user_sniper_kills", 1)		// Add
	register_native("SetSniperKills", 	  "native_set_user_sniper_kills", 1)		// Set
	register_native("GetSamuraiKills", 	  "native_get_user_samurai_kills", 1)		// Get
	register_native("AddSamuraiKills",    "native_add_user_samurai_kills", 1)		// Add
	register_native("SetSamuraiKills", 	  "native_set_user_samurai_kills", 1)		// Set

	// Class related natives
	register_native("IsZombie",       "native_get_user_zombie", 1)
	register_native("MakeZombie",     "native_make_user_zombie", 1)
	register_native("MakeHuman",      "native_make_user_human", 1)
	register_native("IsNemesis",      "native_get_user_nemesis", 1)
	register_native("MakeNemesis",    "native_make_user_nemesis", 1)
	register_native("IsAssasin",      "native_get_user_assassin", 1)
	register_native("MakeAssasin",    "native_make_user_assasin", 1)
	register_native("IsBombardier",   "native_get_user_bombardier", 1)
	register_native("Makebombardier", "native_make_user_bombardier", 1)
	register_native("IsSniper",       "native_get_user_sniper", 1)
	register_native("MakeSniper",     "native_make_user_sniper", 1)
	register_native("IsSurvivor",     "native_get_user_survivor", 1)
	register_native("MakeSurvivor",   "native_make_user_survivor", 1)
	register_native("IsSamurai",      "native_get_user_samurai", 1)
	register_native("MakeSamurai",    "native_make_user_samurai", 1)

	// --- Round related natives ---
	// Master natives
	//register_native("StartMode",				"native_start_mode", 1)
	//register_native("IsMode", 					"native_is_current_mode", 1)

	// Custom natives specific to modes
	register_native("IsInfectionRound",      	"native_is_infection_round", 1)
	//register_native("StartInfectionRound",   	"native_start_infection_round", 1)
	register_native("IsMultiInfectionRound", 	"native_is_multi_infection_round", 1)
	//register_native("StartMultiInfectionRound", "native_start_multi_infection_round", 1)
	register_native("IsSwarmRound",          	"native_is_swarm_round", 1)
	//register_native("StartSwarmRound", 			"native_start_swarm_round", 1)
	register_native("IsPlagueRound", 		 	"native_is_plague_round", 1)
	//register_native("StartPlagueRound", 		"native_start_plague_round", 1)
	register_native("IsArmageddonRound", 	 	"native_is_armageddon_round", 1)
	//register_native("StartArmageddonRound", 	"native_start_armageddon_round", 1)
	register_native("IsApocalypseRound", 	 	"native_is_apocalypse_round", 1)
	//register_native("StartApocalypseRound", 	"native_start_apocalypse_round", 1)
	register_native("IsDevilRound", 		 	"native_is_devil_round", 1)
	//register_native("StartDevilRound", 			"native_start_devil_round", 1)
	register_native("IsNightmareRound", 	 	"native_is_nightmare_round", 1)
	//register_native("StartNightmareRound", 		"native_start_nightmare_round", 1)
}

public plugin_precache()
{
	// Register earlier to show up in plugins list properly after plugin disable/error at loading
	register_plugin("Zombie Queen", "1.0", "MeRcyLeZZ and Abhinash")
	
	// To switch plugin on/off
	register_concmd("zp_toggle", "cmd_toggle", _, "<1/0> - Enable/Disable Zombie Plague (will restart the current map)", 0)
	cvar_toggle = register_cvar("zp_on", "1")
	
	// Plugin disabled?
	if (!get_pcvar_num(cvar_toggle)) return
	g_pluginenabled = true
	
	new i, buffer[128]
	
	for (i = 0; i < sizeof g_cHumanModels; i++)
	{
		formatex(buffer, charsmax(buffer), "models/player/%s/%s.mdl", g_cHumanModels[i], g_cHumanModels[i])
		engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < sizeof g_cAdminModels; i++)
	{
		formatex(buffer, charsmax(buffer), "models/player/%s/%s.mdl", g_cAdminModels[i], g_cAdminModels[i])
		engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < sizeof g_cNemesisModels; i++)
	{
		formatex(buffer, charsmax(buffer), "models/player/%s/%s.mdl", g_cNemesisModels[i], g_cNemesisModels[i])
		engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < sizeof g_cAssassinModels; i++)
	{
		formatex(buffer, charsmax(buffer), "models/player/%s/%s.mdl", g_cAssassinModels[i], g_cAssassinModels[i])
		engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < sizeof g_cBombardierModels; i++)
	{
		formatex(buffer, charsmax(buffer), "models/player/%s/%s.mdl", g_cBombardierModels[i], g_cBombardierModels[i])
		engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < sizeof g_cSurvivorModels; i++)
	{
		formatex(buffer, charsmax(buffer), "models/player/%s/%s.mdl", g_cSurvivorModels[i], g_cSurvivorModels[i])
		engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < sizeof g_cSniperModels; i++)
	{
		formatex(buffer, charsmax(buffer), "models/player/%s/%s.mdl", g_cSniperModels[i], g_cSniperModels[i])
		engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < sizeof g_cSamuraiModels; i++)
	{
		formatex(buffer, charsmax(buffer), "models/player/%s/%s.mdl", g_cSamuraiModels[i], g_cSamuraiModels[i])
		engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < sizeof g_cOwnerModels; i++)
	{
		formatex(buffer, charsmax(buffer), "models/player/%s/%s.mdl", g_cOwnerModels[i], g_cOwnerModels[i])
		engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < sizeof g_cVipModels; i++)
	{
		formatex(buffer, charsmax(buffer), "models/player/%s/%s.mdl", g_cVipModels[i], g_cVipModels[i])
		engfunc(EngFunc_PrecacheModel, buffer)
	}
	for(i = 0; i < sizeof CountdownSounds; i++)
	{
		engfunc(EngFunc_PrecacheSound, CountdownSounds[i])
	}
	
	// Custom weapon models
	engfunc(EngFunc_PrecacheModel, V_KNIFE_HUMAN)
	engfunc(EngFunc_PrecacheModel, V_KNIFE_NEMESIS)
	engfunc(EngFunc_PrecacheModel, V_KNIFE_ASSASSIN)
	engfunc(EngFunc_PrecacheModel, V_AWP_SNIPER)
	engfunc(EngFunc_PrecacheModel, V_KNIFE_SAMURAI)	
	engfunc(EngFunc_PrecacheModel, P_KNIFE_HUMAN)
	engfunc(EngFunc_PrecacheModel, P_KNIFE_SAMURAI)	
	engfunc(EngFunc_PrecacheModel, P_AWP_SNIPER)
	engfunc(EngFunc_PrecacheModel, V_INFECTION_NADE)
	engfunc(EngFunc_PrecacheModel, V_EXPLODE_NADE)
	engfunc(EngFunc_PrecacheModel, V_FIRE_NADE)
	engfunc(EngFunc_PrecacheModel, V_FROST_NADE)

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

	engfunc(EngFunc_PrecacheModel, BubbleGrenadeModel)
	
	// Custom sprites for grenades
	g_trailspr = engfunc(EngFunc_PrecacheModel, GRENADE_TRAIL)

	g_Explode = precache_model("sprites/zerogxplode.spr")

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

	
	// Custom sounds
	for (i = 0; i < sizeof(sound_win_zombies); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_win_zombies[i])
	}
	for (i = 0; i < sizeof(sound_win_humans); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_win_humans[i])
	}
	for (i = 0; i < sizeof(sound_win_no_one); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_win_no_one[i])
	}
	for (i = 0; i < sizeof(zombie_infect); i++)
	{
		engfunc(EngFunc_PrecacheSound, zombie_infect[i])
	}
	for (i = 0; i < sizeof(zombie_pain); i++)
	{
		engfunc(EngFunc_PrecacheSound, zombie_pain[i])
	}
	for (i = 0; i < sizeof(nemesis_pain); i++)
	{
		engfunc(EngFunc_PrecacheSound, nemesis_pain[i])
	}
	for (i = 0; i < sizeof(assassin_pain); i++)
	{
		engfunc(EngFunc_PrecacheSound, assassin_pain[i])
	}
	for (i = 0; i < sizeof(zombie_die); i++)
	{
		engfunc(EngFunc_PrecacheSound, zombie_die[i])
	}
	for (i = 0; i < sizeof(zombie_fall); i++)
	{
		engfunc(EngFunc_PrecacheSound, zombie_fall[i])
	}
	for (i = 0; i < sizeof(zombie_miss_slash); i++)
	{
		engfunc(EngFunc_PrecacheSound, zombie_miss_slash[i])
	}
	for (i = 0; i < sizeof(zombie_miss_wall); i++)
	{
		engfunc(EngFunc_PrecacheSound, zombie_miss_wall[i])
	}
	for (i = 0; i < sizeof(zombie_hit_normal); i++)
	{
		engfunc(EngFunc_PrecacheSound, zombie_hit_normal[i])
	}
	for (i = 0; i < sizeof(zombie_hit_stab); i++)
	{
		engfunc(EngFunc_PrecacheSound, zombie_hit_stab[i])
	}
	for (i = 0; i < sizeof(zombie_idle); i++)
	{
		engfunc(EngFunc_PrecacheSound, zombie_idle[i])
	}
	for (i = 0; i < sizeof(zombie_idle_last); i++)
	{
		engfunc(EngFunc_PrecacheSound, zombie_idle_last[i])
	}
	for (i = 0; i < sizeof(zombie_madness); i++)
	{
		engfunc(EngFunc_PrecacheSound, zombie_madness[i])
	}
	for (i = 0; i < sizeof(sound_nemesis); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_nemesis[i])
	}
	for (i = 0; i < sizeof(sound_assassin); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_assassin[i])
	}
	for (i = 0; i < sizeof(sound_survivor); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_survivor[i])
	}
	for (i = 0; i < sizeof(sound_sniper); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_sniper[i])
	}
	for (i = 0; i < sizeof(sound_samurai); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_samurai[i])
	}
	for (i = 0; i < sizeof(sound_bombardier); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_bombardier[i])
	}
	for (i = 0; i < sizeof(sound_swarm); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_swarm[i])
	}
	for (i = 0; i < sizeof(sound_multi); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_multi[i])
	}
	for (i = 0; i < sizeof(sound_plague); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_plague[i])
	}
	for (i = 0; i < sizeof(sound_armageddon); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_armageddon[i])
	}
	for (i = 0; i < sizeof(sound_apocalypse); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_apocalypse[i])
	}
	for (i = 0; i < sizeof(sound_nightmare); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_nightmare[i])
	}
	for (i = 0; i < sizeof(sound_devil); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_devil[i])
	}
	for (i = 0; i < sizeof(grenade_infect); i++)
	{
		engfunc(EngFunc_PrecacheSound, grenade_infect[i])
	}
	for (i = 0; i < sizeof(grenade_infect_player); i++)
	{
		engfunc(EngFunc_PrecacheSound, grenade_infect_player[i])
	}
	for (i = 0; i < sizeof(grenade_fire); i++)
	{
		engfunc(EngFunc_PrecacheSound, grenade_fire[i])
	}
	for (i = 0; i < sizeof(grenade_fire_player); i++)
	{
		engfunc(EngFunc_PrecacheSound, grenade_fire_player[i])
	}
	for (i = 0; i < sizeof(grenade_frost); i++)
	{
		engfunc(EngFunc_PrecacheSound, grenade_frost[i])
	}
	for (i = 0; i < sizeof(grenade_frost_player); i++)
	{
		engfunc(EngFunc_PrecacheSound, grenade_frost_player[i])
	}
	for (i = 0; i < sizeof(grenade_frost_break); i++)
	{
		engfunc(EngFunc_PrecacheSound, grenade_frost_break[i])
	}
	for (i = 0; i < sizeof(sound_antidote); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_antidote[i])
	}
	for (i = 0; i < sizeof(sound_thunder); i++)
	{
		engfunc(EngFunc_PrecacheSound, sound_thunder[i])
	}
	
	// Ambience Sounds
	engfunc(EngFunc_PrecacheSound, "PerfectZM/ambience_normal.wav")
	
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

public Spawn( iEnt )
{
	if( pev_valid(iEnt) )
	{
		static szClassName[32]
		pev(iEnt, pev_classname, szClassName, charsmax(szClassName))
		if( !TrieKeyExists(g_tClassNames, szClassName) )
		{
			RegisterHam(Ham_TraceAttack, szClassName, "TraceAttack", 1)
			TrieSetCell(g_tClassNames, szClassName, 1)
		}
	}
}

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
	//register_forward(FM_TraceLine, "FwTraceLine")
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
	
	// Menus
	register_menu("Admin Menu", KEYS_ADMINMENU, "menu_admin")
	register_menu("Admin Classes Menu", KEYS_ADMINMENUCLASSES, "menu_admin_classes")
	register_menu("Admin Modes Menu", KEYS_ADMINMENUMODES, "menu_admin_modes")
	register_menu("Admin Custom Modes Menu", KEYS_ADMINCUSTOMMODES, "menu_admin_custom_modes")
	
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
	register_concmd("amx_reloadadmins", "cmd_reloadadmins", -1, _, -1)
	register_concmd("zp_reloadadmins", "cmd_reloadadmins", -1, _, -1)

	//register_concmd("amx_votemap", "cmd_votemap", -1, _, -1)
	//register_concmd("zp_votemap", "cmd_votemap", -1, _, -1)

	register_concmd("amx_last", "cmd_last", -1, _, -1)
	register_concmd("zp_last", "cmd_last", -1, _, -1)
	register_concmd("amx_gag", "cmd_gag", -1, _, -1)
	register_concmd("zp_gag", "cmd_gag", -1, _, -1)
	register_concmd("amx_ungag", "cmd_ungag", -1, _, -1)
	register_concmd("zp_ungag", "cmd_ungag", -1, _, -1)
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
	register_concmd("zp_devil", "cmd_devil", -1, _, -1)
	register_concmd("amx_devil", "cmd_devil", -1, _, -1)
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
	g_MsgSync = CreateHudSyncObj()
	g_MsgSync2 = CreateHudSyncObj()
	g_MsgSync3 = CreateHudSyncObj()
	g_MsgSync4 = CreateHudSyncObj()
	g_MsgSync5[0] = CreateHudSyncObj()
	g_MsgSync5[1] = CreateHudSyncObj()
	g_MsgSync5[2] = CreateHudSyncObj()
	g_MsgSync5[3] = CreateHudSyncObj()
	g_MsgSync6 = CreateHudSyncObj()
	g_MsgSync7 = CreateHudSyncObj()

	
	// Get Max Players
	g_maxplayers = get_maxplayers()
	
	// Reserved saving slots starts on maxplayers+1
	db_slot_i = g_maxplayers+1
	
	// Check if it's a CZ server
	new mymod[6]
	get_modname(mymod, charsmax(mymod))
	if (equal(mymod, "czero")) g_czero = 1
	
	new cLine[128]
	new cNumber[3]
	g_iGameMenu = menu_create("Game Menu", "_GameMenu", 0)	// Game menu
	g_iZombieClassMenu = menu_create("Zombie Classes", "_ZombieClasses", 0)	// Zombie class menu
	g_iExtraItemsMenu = menu_create("Extra Items", "_ExtraItems", 0)	// Human Extra items menu
	g_iExtraItems2Menu = menu_create("Extra Items", "_ExtraItems2", 0)	// Zombie Extra items menu
	g_iPointShopMenu = menu_create("Points Shop", "_PointShop", 0)	// Points shop menu
	g_iAmmoMenu = menu_create("Buy Ammo Packs", "_AmmoMenu", 0)	// Ammo shop menu
	g_iFeaturesMenu = menu_create("Buy Features", "_Features", 0)	// Features menu
	g_iModesMenu = menu_create("Buy Modes", "_Modes", 0)	// Modes menu
	g_iAccessMenu = menu_create("Buy Access", "_Access", 0)	// Buy access menu
	
	// Main Game menu
	menu_additem(g_iGameMenu, "Buy extra items", "0", 0, -1)
	menu_additem(g_iGameMenu, "Choose zombie class", "1", 0, -1)
	menu_additem(g_iGameMenu, "Buy features with points", "2", 0, -1)
	menu_additem(g_iGameMenu, "Unstuck", "3", 0, -1)
	menu_additem(g_iGameMenu, "See rank", "4", 0, -1)
	
	// Extra Items Human menu
	for (new i; i < sizeof(g_cExtraItems); i++)
	{
		formatex(cLine, 128, "%s %s", g_cExtraItems[i][ItemName], g_cExtraItems[i][PriceTag])
		num_to_str(i, cNumber, 3)
		menu_additem(g_iExtraItemsMenu, cLine, cNumber, 0, -1)
	}

	// Extra Items Zombie menu
	for (new i; i < sizeof(g_cExtraItemsZombie); i++)
	{
		formatex(cLine, 128, "%s %s", g_cExtraItemsZombie[i][ZItemName], g_cExtraItemsZombie[i][ZPriceTag])
		num_to_str(i, cNumber, 3)
		menu_additem(g_iExtraItems2Menu, cLine, cNumber, 0, -1)
	}
	
	// Zombie Classes menu
	for (new i; i < sizeof(g_cZombieClasses); i++)
	{
		formatex(cLine, 128, "%s %s", g_cZombieClasses[i][ZombieName], g_cZombieClasses[i][ZombieAttribute])
		num_to_str(i, cNumber, 3)
		menu_additem(g_iZombieClassMenu, cLine, cNumber, 0, -1)
	}
	
	// Points Shop menu
	for (new i; i < sizeof(g_cPointsMenu); i++)
	{
		formatex(cLine, 128, "%s", g_cPointsMenu[i][PItemName])
		num_to_str(i, cNumber, 3)
		menu_additem(g_iPointShopMenu, cLine, cNumber, 0, -1)
	}
	
	// Ammo packs menu
	for (new i; i < sizeof(g_cAmmoMenu); i++)
	{
		formatex(cLine, 128, "%s %s", g_cAmmoMenu[i][AItemName], g_cAmmoMenu[i][AItemTag])
		num_to_str(i, cNumber, 3)
		menu_additem(g_iAmmoMenu, cLine, cNumber, 0, -1)
	}
	
	// Features menu
	for (new i; i < sizeof(g_cFeaturesMenu); i++)
	{
		formatex(cLine, 128, "%s %s", g_cFeaturesMenu[i][FItemName], g_cFeaturesMenu[i][FItemTag])
		num_to_str(i, cNumber, 3)
		menu_additem(g_iFeaturesMenu, cLine, cNumber, 0, -1)
	}
	
	// Modes menu
	for (new i; i < sizeof(g_cModesMenu); i++)
	{
		formatex(cLine, 128, "%s %s", g_cModesMenu[i][MItemName], g_cModesMenu[i][MItemTag])
		num_to_str(i, cNumber, 3)
		menu_additem(g_iModesMenu, cLine, cNumber, 0, -1)
	}
	
	// Access menu
	for (new i; i < sizeof(g_cAccessMenu); i++)
	{
		formatex(cLine, 128, "%s %s", g_cAccessMenu[i][aCItemName], g_cAccessMenu[i][aCItemTag])
		num_to_str(i, cNumber, 3)
		menu_additem(g_iAccessMenu, cLine, cNumber, 0, -1)
	}
	
	g_PrimaryMenu = menu_create("Primary Weapons", "PrimaryHandler")
	for(new i; i < sizeof g_PrimaryWeapons; i++)
	{
		menu_additem(g_PrimaryMenu, g_PrimaryWeapons[i][weaponName])
	}
	g_SecondaryMenu = menu_create("Secondary Weapons", "SecondaryHandler")
	for(new i; i < sizeof g_SecondaryWeapons; i++)
	{
		menu_additem(g_SecondaryMenu, g_SecondaryWeapons[i][weaponName])
	}

	// HUD Advertisements
	new a = fopen("addons/amxmodx/configs/hud_advertisements.ini", "r");

	g_Messages = ArrayCreate(512)
	if (a)
	{
		new Line[512]

		while (!feof(a))
		{
			fgets(a, Line, sizeof(Line) - 1)

			trim(Line)

			if (Line[0])
			{
				while(replace(Line, sizeof(Line)-1, "\n", "^n")){}
				ArrayPushString(g_Messages, Line)
			}
		}

		fclose(a)
	} 
	else 
	{
		log_amx("Failed to open hud_advertisements.ini file!")
	}

	if (ArraySize(g_Messages))
	{
		set_task(15.0, "Advertise_HUD", .flags = "b")
	}

	//register_cvar("amx_nextmap", "", FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY)
	
	set_task(1.0, "MySql_Init") // set a task to activate the mysql_init
	set_task(2.0, "MySql_TotalPlayers")
	set_task(1.0, "TaskGetAdmins")
	set_task(1.0, "TaskGetVips")
	set_task(8.0, "TaskGetAdvertisements")
	set_task(3.0, "Task_CheckBots", .flags = "b")
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
    Queries = SQL_PrepareQuery(SqlConnection, "CREATE TABLE IF NOT EXISTS perfectzm (steamid varchar(32), name varchar(32), points INT(11), kills INT(11), deaths INT(11), infections INT(11), nemesiskills INT(11), assasinkills INT(11), bombardierkills INT(11), survivorkills INT(11), sniperkills INT(11), samuraikills INT(11), score INT(11))")

    if(!SQL_Execute(Queries))
    {
        // if there were any problems the plugin will set itself to bad load.
	    SQL_QueryError(Queries,g_Error,charsmax(g_Error))
	    set_fail_state(g_Error)
    }
    
	// Free the querie
	SQL_FreeHandle(Queries)

	// you free everything with SQL_FreeHandle
	SQL_FreeHandle(SqlConnection)   
}

public register_client(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
	{
	    log_amx("Load - Could not connect to SQL database.  [%d] %s", Errcode, Error)
	}
	else if(FailState == TQUERY_QUERY_FAILED)
	{
	    log_amx("Load Query failed. [%d] %s", Errcode, Error)
	}

	new id
	id = Data[0]

	if(SQL_NumResults(Query) < 1) 
	{
	    // If there are no results found
	    
	    new szSteamId[32]
	    get_user_authid(id, szSteamId, charsmax(szSteamId)) // get user's steamid
	    
	    //  If its still pending we can't do anything with it
	    if (equal(szSteamId,"ID_PENDING"))
	    return PLUGIN_HANDLED
	        
	    new szTemp[512]
	    
	    // Now we will insturt the values into our table.
	    format(szTemp, charsmax(szTemp), "INSERT INTO `perfectzm` ( `steamid`, `name`, `points`, `kills`, `deaths`, `infections`, `nemesiskills`, `assasinkills`, `bombardierkills`, `survivorkills`, `sniperkills`, `samuraikills`, `score`)VALUES ('%s', '%s', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');", szSteamId, g_playername[id])
	    SQL_ThreadQuery(g_SqlTuple, "IgnoreHandle", szTemp)
	    g_totalplayers++
	} 
	else 
	{
	    // if there are results found
	    g_points[id] 		  = SQL_ReadResult(Query, 2)
	    g_kills[id]  		  = SQL_ReadResult(Query, 3)
	    g_deaths[id] 		  = SQL_ReadResult(Query, 4)
		g_infections[id] 	  = SQL_ReadResult(Query, 5)
		g_nemesiskills[id] 	  = SQL_ReadResult(Query, 6)
		g_assasinkills[id] 	  = SQL_ReadResult(Query, 7)
		g_bombardierkills[id] = SQL_ReadResult(Query, 8)
		g_survivorkills[id]   = SQL_ReadResult(Query, 9)
		g_sniperkills[id] 	  = SQL_ReadResult(Query, 10)
		g_samuraikills[id] 	  = SQL_ReadResult(Query, 11)
	    g_score[id] 		  = SQL_ReadResult(Query, 12)

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
	g_totalplayers = SQL_NumResults(Query);
	return PLUGIN_CONTINUE
} 

public MySQL_LOAD_DATABASE(id)
{
	new szSteamId[32], szTemp[512]
	get_user_authid(id, szSteamId, charsmax(szSteamId))

	new Data[1]
	Data[0] = id

	//we will now select from the table `tutorial` where the steamid match
	format(szTemp, charsmax(szTemp), "SELECT * FROM `perfectzm` WHERE `steamid` = '%s'", szSteamId)
	SQL_ThreadQuery(g_SqlTuple, "register_client", szTemp, Data, 1)
}

public MySQL_UPDATE_DATABASE(id)
{
	new szSteamId[32], szTemp[512]
	get_user_authid(id, szSteamId, charsmax(szSteamId))

	// Here we will update the user hes information in the database where the steamid matches.
	format(szTemp, charsmax(szTemp), "UPDATE `perfectzm` SET `points` = '%i', `kills` = '%i', `deaths` = '%i', `infections` = '%i', `nemesiskills` = '%i', `assasinkills` = '%i', `bombardierkills` = '%i', `survivorkills` = '%i', `sniperkills` = '%i', `samuraikills` = '%i', `score` = '%i' WHERE `steamid` = '%s';", g_points[id], g_kills[id], g_deaths[id], g_infections[id], g_nemesiskills[id], g_assasinkills[id], g_bombardierkills[id], g_survivorkills[id], g_sniperkills[id], g_samuraikills[id], g_score[id], szSteamId)
	SQL_ThreadQuery(g_SqlTuple, "IgnoreHandle", szTemp)
} 

public Sql_Rank(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
	new id, rank, Float:var1, g_menu, menudata[256]
    rank = SQL_NumResults(Query)
   	id = Data[0]
   
	if (g_deaths[id])
	{
		var1 = floatdiv(float(g_kills[id]), float(g_deaths[id]));
	}
	else
	{
		var1 = float(g_kills[id]);
	}

	g_menu = menu_create("Ranking", "EmptyPanel", 0)
	formatex(menudata, 255, "Rank: %s out of %s  Score: %s", AddCommas(rank), AddCommas(g_totalplayers), AddCommas(g_score[id]))
	menu_additem(g_menu, menudata, "1", 0, -1)
	formatex(menudata, 255, "Kills: %s  Deaths: %s  KPD: %0.2f", AddCommas(g_kills[id]), AddCommas(g_deaths[id]), var1)
	menu_additem(g_menu, menudata, "2", 0, -1)
	formatex(menudata, 255, "Status: %s", g_bVip[id] ? "Gold Member ®" : "Player")
	menu_additem(g_menu, menudata, "3", 0, -1)
	menu_setprop(g_menu, 6, -1)
	menu_display(id, g_menu, 0)


	client_print_color(0, print_team_grey, "%s ^3%s^1's rank is^4 %s^1 out of^4 %s^1 -- ^3KILLS: ^4%s ^3DEATHS: ^4%s ^3KPD: ^4%0.2f", CHAT_PREFIX, g_playername[id], AddCommas(rank), AddCommas(g_totalplayers), AddCommas(g_kills[id]), AddCommas(g_deaths[id]), var1)
    
    return PLUGIN_HANDLED
} 

public Sql_WelcomeRank(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
	new id, rank, Float:var1
    rank = SQL_NumResults(Query)
   	id = Data[0]

	if (g_deaths[id])
	{
		var1 = floatdiv(float(g_kills[id]), float(g_deaths[id]))
	}
	else
	{
		var1 = float(g_kills[id])
	}

	new HostName[64]
	get_cvar_string("hostname", HostName, charsmax(HostName))

	set_dhudmessage(0, 255, 0, 0.02, 0.2, 2, 6.0, 8.0)
	show_dhudmessage(id, "Welcome, %s^nRank: %s of %s Score: %s^nKills: %s Deaths: %s KPD: %0.2f^nEnjoy!",
	g_playername[id], AddCommas(rank), AddCommas(g_totalplayers), AddCommas(g_score[id]), AddCommas(g_kills[id]), AddCommas(g_deaths[id]), var1)
	
	
	set_dhudmessage(157, 103, 200, 0.02, 0.5, 2, 6.0, 8.0)
	show_dhudmessage(id, "%s^nDon't forget to add us to your favourites!", HostName)
    
    return PLUGIN_HANDLED
} 

public TopFunction(State, Handle:Query, Error[], ErrorCode, Data[], DataSize)
{
	static id, Buffer[4096], Place, Name[32], Score, Kills, Deaths, Points, Len

	Buffer[0] = '^0';

	id = Data[0]

	Place = 0;

	if (is_user_connected(id))
	{
		formatex(Buffer, charsmax(Buffer), "<meta charset=utf-8><style>body{background:#112233;font-family:Arial}th{background:#2E2E2E;color:#FFF;padding:5px 2px;text-align:left}td{padding:5px 2px}table{width:100%%;background:#EEEECC;font-size:12px;}h2{color:#FFF;font-family:Verdana;text-align:center}#nr{text-align:center}#c{background:#E2E2BC}</style><h2>%s</h2><table border=^"0^" align=^"center^" cellpadding=^"0^" cellspacing=^"1^"><tbody>", "TOP 15")
		Len = add(Buffer, charsmax(Buffer), "<tr><th id=nr>#</th><th>Name<th>Kills<th>Deaths<th>Points<th>Score")

		while (SQL_MoreResults(Query))
		{
			SQL_ReadResult(Query, 0, Name, sizeof(Name) - 1)

			Points = SQL_ReadResult(Query, 1)
			Kills = SQL_ReadResult(Query, 2)
			Deaths = SQL_ReadResult(Query, 3)
			Score = SQL_ReadResult(Query, 4)
			
			++Place

			Len += formatex(Buffer[Len], charsmax(Buffer), "<tr %s><td id=nr>%s<td>%s<td>%s<td>%s<td>%s<td>%s", Place % 2 == 0 ? "" : " id=c", AddCommas(Place), Name, AddCommas(Kills), AddCommas(Deaths), AddCommas(Points), AddCommas(Score))

			SQL_NextRow(Query)
		}

		new ServerName[64]
		get_cvar_string("hostname", ServerName, charsmax(ServerName))
		
		formatex(Buffer[Len], charsmax(Buffer), "<tr><th colspan=^"7^" id=nr>%s", ServerName)
		add(Buffer, charsmax(Buffer), "</tbody></table></body>")
		
		show_motd(id, Buffer, "Top Players")
	}

	SQL_FreeHandle(Query)
}

public init_welcome(id)
{
	new szTemp[512]
	new Data[1]
	Data[0] = id
	format(szTemp,charsmax(szTemp),"SELECT DISTINCT `score` FROM `perfectzm` WHERE `score` >= %d ORDER BY `score` ASC", g_score[id])
	SQL_ThreadQuery(g_SqlTuple, "Sql_WelcomeRank", szTemp, Data, 1)
}

public EmptyPanel(id, iMenu, iItem)
{
	return PLUGIN_CONTINUE
}

public IgnoreHandle(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
	SQL_FreeHandle(Query)

	return PLUGIN_HANDLED
}

public TaskGetAdmins()
{
	static iFile
	iFile = fopen("addons/amxmodx/configs/accounts/admin/Admins.ini", "r")
	if (iFile)
	{
		static cLine[161]
		while (!feof(iFile))
		{
			fgets(iFile, cLine, 255)
			trim(cLine)
			if (cLine[0] != 59 && strlen(cLine) > 5)
			{
				parse(cLine, g_AdminNames[g_AdminsCount], charsmax(g_AdminNames), g_AdminPasswords[g_AdminsCount], charsmax(g_AdminPasswords), g_AdminFlags[g_AdminsCount], charsmax(g_AdminFlags), g_Tag[g_AdminsCount], charsmax(g_Tag), g_AdminSkinFlags[g_AdminsCount], charsmax(g_AdminSkinFlags))
				g_AdminsCount++
			}		
		}
		fclose (iFile)
	}
	return PLUGIN_CONTINUE
}

public TaskGetVips()
{
	static iFile
	iFile = fopen("addons/amxmodx/configs/accounts/vip/Vips.ini", "r")
	if (iFile)
	{
		static cLine[161]
		while (!feof(iFile))
		{
			fgets(iFile, cLine, 255)
			trim(cLine)
			if (cLine[0] != 59 && strlen(cLine) > 5)
			{
				parse(cLine, g_VipNames[g_VipsCount], charsmax(g_VipNames), g_VipPasswords[g_VipsCount], charsmax(g_VipPasswords), g_VipFlags[g_VipsCount], charsmax(g_VipFlags))
				g_VipsCount++
			}		
		}
		fclose (iFile)
	}
	return PLUGIN_CONTINUE
}

public TaskGetAdvertisements()
{
	static iFile
	new cLine[161]

	iFile = fopen("addons/amxmodx/configs/chat_advertisements.ini", "r");
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
	return PLUGIN_CONTINUE;
}

public MakeUserAdmin(id)
{
	static i
	i = 0
	get_user_name(id, g_playername[id], charsmax(g_playername))
	g_bAdmin[id] = false
	
	while (i < g_AdminsCount)
	{
		if (equali(g_AdminNames[i], g_playername[id]))
		{
			get_user_info(id, "_pw", g_cPassword[id], 31)
			
			if (equali(g_cPassword[id], g_AdminPasswords[i]))
			{
				g_bAdmin[id] = true
				formatex(g_cAdminFlag[id], 31, "%s", g_AdminFlags[i])
				copy(g_cTag[id], 24, g_Tag[i])
				formatex(g_cAdminSkinFlag[id], 31, "%s", g_AdminSkinFlags[i])

				log_amx("Login: ^"%s^" became an admin. [ %s ] [ %s ]", g_playername[id], g_cAdminFlag[id], g_cIP[id])
				return PLUGIN_CONTINUE
			}
			else
			{
				server_cmd("kick #%d  You have no entry to the server...", get_user_userid(id))
				log_amx("Login: ^"%s^" kicked due to invalid password. [ %s ] [ %s ]", g_playername[id], g_cPassword[id], g_AdminPasswords[i])
				return PLUGIN_CONTINUE
			}
		}
		i += 1
	}
	return PLUGIN_CONTINUE
}

public MakeUserVip(id)
{
	static i
	i = 0
	get_user_name(id, g_playername[id], charsmax(g_playername))
	g_bVip[id] = false
	
	while (i < g_VipsCount)
	{
		if (equali(g_VipNames[i], g_playername[id]))
		{
			get_user_info(id, "_pw", g_cVipPassword[id], 31)
			
			if (equali(g_cVipPassword[id], g_VipPasswords[i]))
			{
				g_bVip[id] = true
				formatex(g_cVipFlag[id], 31, "%s", g_VipFlags[i])
				log_amx("Login: ^"%s^" became an Vip. [ %s, %s ] ", g_playername[id], g_cVipFlag[id], g_cIP[id])
				set_task(5.0, "Task_Rays", .flags = "b")
				return PLUGIN_CONTINUE
			}
			else
			{
				server_cmd("kick #%d  You have no entry to the server...", get_user_userid(id))
				log_amx("Login: ^"%s^" kicked due to invalid password. [ %s ] [ %s ]", g_playername[id], g_cVipPassword[id], g_VipPasswords[i])
				return PLUGIN_CONTINUE
			}
		}
		i += 1
	}
	return PLUGIN_CONTINUE
}

public Task_Rays(id)
{
	for (new vip = 1; vip <= g_maxplayers; vip++)
	{
		if (is_user_alive(vip) && g_bVip[vip] && VipHasFlag(vip, 'h'))
		{
			if (!g_zombie[vip])
			{
				for (new z = 1;z <= g_maxplayers; z++)
				{
					if (is_user_alive(z) && g_zombie[z] && !ExecuteHam(Ham_FVisible, vip, z))
					{
						Beam(vip, z, 0, 255, 0)
					}
				}
			}
			else
			{
				for (new h = 1; h <= g_maxplayers; h++)
				{
					if (is_user_alive(h) && !g_zombie[h] && !ExecuteHam(Ham_FVisible, vip, h))
					{
						Beam(vip, h, 0, 120, 190)
					}
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public Task_CheckBots()
{
	if (get_playersnum(1) < g_maxplayers - 1 && g_iBotsCount < 2)
	{
		for (new i; i < sizeof g_cBotNames; i++)
		{
			CreateBot(g_cBotNames[i])
		}
	}
	else if (get_playersnum(1) > g_maxplayers - 1 && g_iBotsCount)
	{
		RemoveBot()
	}
	
}

public Advertise()
{
	if (g_iMessage >= g_iAdvertisementsCount)
	{
		g_iMessage = 0;
	}
	client_print_color(0, print_team_grey, g_cAdvertisements[g_iMessage]);
	g_iMessage += 1;
	return PLUGIN_CONTINUE;
}

public Advertise_HUD()
{
	static a,msg[512];

	for (a = 1; a <= get_maxplayers(); a++)
	{
		if (g_isconnected[a] && !g_isbot[a])
		{
			set_hudmessage(random_num(0, 230), random_num(0, 240), random_num(0, 230), -1.0, 0.20, 2, 0.2, 7.0, 0.1, 0.7, 2)
			ArrayGetString(g_Messages,random_num(0,ArraySize(g_Messages)-1), msg, 511)
			ShowSyncHudMsg(a, g_MsgSync7, msg)
		}
	}
}

public TaskReminder()
{
	static id
	id = 1
	while (g_maxplayers + 1 > id)
	{
		if (g_isalive[id] && g_specialclass[id])
		{
			client_print_color(0, print_team_grey, "%s A ^3Rapture^1 Reminder ^3@ ^4%s^1 still has %s ^4health points!", CHAT_PREFIX, g_cClass[id], AddCommas(pev(id, pev_health)))
		}
		id += 1
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
		static iSender
		iSender = get_msg_arg_int(1)
		if (0 < iSender < g_maxplayers + 1 && g_cTag[iSender][0])
		{
			static cReplacement[189]
			static cPhrase[47]
			get_msg_arg_string(2, cPhrase, 46)
			if (equal(cPhrase, "#Cstrike_Chat_CT", 0))
			{
				formatex(cReplacement, 188, "^1(Counter-Terrorist) ^4%s ^3%s^1 :  %s", g_cTag[iSender], "%s1", "%s2")
				set_msg_arg_string(2, cReplacement)
			}
			if (equal(cPhrase, "#Cstrike_Chat_T", 0))
			{
				formatex(cReplacement, 188, "^1(Terrorist) ^4%s ^3%s^1 :  %s", g_cTag[iSender], "%s1", "%s2")
				set_msg_arg_string(2, cReplacement)
			}
			if (equal(cPhrase, "#Cstrike_Chat_CT_Dead", 0))
			{
				formatex(cReplacement, 188, "^1*DEAD*(Counter-Terrorist) ^4%s ^3%s^1 :  %s", g_cTag[iSender], "%s1", "%s2")
				set_msg_arg_string(2, cReplacement)
			}
			if (equal(cPhrase, "#Cstrike_Chat_T_Dead", 0))
			{
				formatex(cReplacement, 188, "^1*DEAD*(Terrorist) ^4%s ^3%s^1 :  %s", g_cTag[iSender], "%s1", "%s2")
				set_msg_arg_string(2, cReplacement)
			}
			if (equal(cPhrase, "#Cstrike_Chat_Spec", 0))
			{
				formatex(cReplacement, 188, "^1(Spectator) ^4%s ^3%s^1 :  %s", g_cTag[iSender], "%s1", "%s2")
				set_msg_arg_string(2, cReplacement)
			}
			if (equal(cPhrase, "#Cstrike_Chat_All", 0))
			{
				formatex(cReplacement, 188, "^4%s ^3%s^1 :  %s", g_cTag[iSender], "%s1", "%s2")
				set_msg_arg_string(2, cReplacement)
			}
			if (equal(cPhrase, "#Cstrike_Chat_AllDead", 0))
			{
				formatex(cReplacement, 188, "^1*DEAD* ^4%s ^3%s^1 :  %s", g_cTag[iSender], "%s1", "%s2")
				set_msg_arg_string(2, cReplacement)
			}
			if (equal(cPhrase, "#Cstrike_Chat_AllSpec", 0))
			{
				formatex(cReplacement, 188, "^1*SPEC* ^4%s ^3%s^1 :  %s", g_cTag[iSender], "%s1", "%s2")
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
		static iDummy
		static cBuffer[3]
		menu_item_getinfo(menu, item, iDummy, cBuffer, charsmax(cBuffer), _, _, iDummy)
		iChoice = str_to_num(cBuffer)
		switch (iChoice)
		{
		case 0:
			{
				if (g_isalive[id])
				{
					if (!g_zombie[id] && !g_survivor[id] && !g_sniper[id] && !g_samurai[id])
					{
						menu_display(id, g_iExtraItemsMenu, 0)
					}
					else if (g_zombie[id] && !g_nemesis[id] && !g_assassin[id] && !g_bombardier[id])
					{
						menu_display(id, g_iExtraItems2Menu, 0)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s Extra items are unavailable right now.", CHAT_PREFIX)
					}
				}
			}
		case 1:
			{
				menu_display(id, g_iZombieClassMenu, 0)
			}
		case 2:
			{
				if(g_isalive[id] && !g_sniper[id] || !g_samurai[id] || !g_nemesis[id] || !g_assassin[id] || !g_bombardier[id])
				{
					menu_display(id, g_iPointShopMenu, 0)
				}
				else
				{
					client_print_color(id, print_team_grey, "%s Points shop is unavailbale right now.", CHAT_PREFIX)
				}
			}
		case 3:
			{
				if (g_isalive[id] && !is_hull_vacant(id))
				{
					static i
					static Float:fOrigin[3]
					static Float:fVector[3]
					static Float:fMins[3]
					pev(id, pev_mins, fMins)
					pev(id, pev_origin, fOrigin)
					i = 0
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
						i += 1
					}
					client_print_color(id, print_team_grey, "%s You have been unstucked!", CHAT_PREFIX)
				}
				else
				{
					client_print_color(id, print_team_grey, "%s You are not stuck!", CHAT_PREFIX)
				}
			}
		case 4:
			{
				new szTemp[512]
				new Data[1]
    			Data[0] = id
				format(szTemp,charsmax(szTemp),"SELECT DISTINCT `score` FROM `perfectzm` WHERE `score` >= %d ORDER BY `score` ASC", g_score[id])
			    SQL_ThreadQuery(g_SqlTuple, "Sql_Rank", szTemp, Data, 1)
			}
		}
	}
	return  PLUGIN_CONTINUE
}

public _ExtraItems(id, menu, item)
{
	if (g_isalive[id] && item != -3)
	{
		static iChoice
		static iDummy
		static cBuffer[3]
		menu_item_getinfo(menu, item, iDummy, cBuffer, charsmax(cBuffer), _, _, iDummy)
		iChoice = str_to_num(cBuffer)
		if (!g_zombie[id] && !g_sniper[id] && !g_survivor[id] && !g_samurai[id] && !g_nemesis[id] && !g_assassin[id] && !g_bombardier[id])
		{
			switch (iChoice)
			{
			case 0:
				{
					if (CanBuyItem(id, nightvision))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							g_nvision[id] = true
							
							set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
							ShowSyncHudMsg(id, g_MsgSync6, "You bought Nightvision Googles!", g_playername[id])

							// Check is the user is not bot
							if (!g_isbot[id])
							{
								g_nvisionenabled[id] = true
								
								// Custom nvg?
								if (CustomNightVision == 1)
								{
									remove_task(id+TASK_NVISION)
									set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
								}
								else
								set_user_gnvision(id, 1)
							}
							else
							cs_set_user_nvg(id, 1)

							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 1:
				{
					if (CanBuyItem(id, explosion_nade))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							// Already own one
							if (user_has_weapon(id, CSW_HEGRENADE))
							{
								client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
								return PLUGIN_HANDLED
							}
							else
							{
								// Give weapon to the player
								set_weapon(id, CSW_HEGRENADE, 1)	

								// Show hud message
								set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
								ShowSyncHudMsg(id, g_MsgSync6, "You bought Explosion Grenade!")
								
								// Play clip purchase sound
								emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)

								g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
							}
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 2:
				{
					if (CanBuyItem(id, napalm_nade))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							// Already own one
							if (user_has_weapon(id, CSW_FLASHBANG))
							{
								client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
								return PLUGIN_HANDLED	
							}
							else
							{
								// Give weapon to the player
								set_weapon(id, CSW_FLASHBANG, 1)

								// Show HUD message
								set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
								ShowSyncHudMsg(id, g_MsgSync6, "You bought Napalm Grenade!")	

								// Play clip purchase sound
								emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)

								g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
							}
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 3:
				{
					/*if (CanBuyItem(id, forcefield_nade))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							// Already own one
							if (user_has_weapon(id, CSW_SMOKEGRENADE))
							{
								client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
								return PLUGIN_HANDLED
							}
							else
							{
								// Set the boolean to true
								g_bubblebomb[id]++

								// Give weapon to the player
								set_weapon(id, CSW_SMOKEGRENADE, 1)	

								// Show HUD message
								set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
								ShowSyncHudMsg(id, g_MsgSync6, "You bought Force Field Grenade!")

								// Play clip purchase sound
								emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)

								g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
							}	
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}*/
					return PLUGIN_HANDLED
				}
			case 4:
				{
					if (CanBuyItem(id, frost_nade))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							// Already own one
							if (user_has_weapon(id, CSW_SMOKEGRENADE))
							{
								client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
								return PLUGIN_HANDLED
							}
							else
							{
								// Give weapon to the player
								set_weapon(id, CSW_SMOKEGRENADE, 1)	

								// Show HUD Message
								set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
								ShowSyncHudMsg(id, g_MsgSync6, "You bought Frost Grenade!")

								// Play clip purchase sound
								emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)

								g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
							}
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 5:
				{
					if (CanBuyItem(id, killing_nade))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							// Already own one
							if (user_has_weapon(id, CSW_HEGRENADE))
							{
								client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
								return PLUGIN_HANDLED
							}
							else
							{
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

								g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
							}
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 6:
				{
					if (CanBuyItem(id, antidote_nade))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							// Already own one
							if (user_has_weapon(id, CSW_HEGRENADE))
							{
								client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
								return PLUGIN_HANDLED
							}
							else
							{
								LIMIT[id][ANTIDOTE_NADE]++

								// Set the boolean to true
								g_antidotebomb[id]++

								// Give weapon to the player
								set_weapon(id, CSW_HEGRENADE, 1)

								// Show HUD message
								set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
								ShowSyncHudMsg(id, g_MsgSync6, "You bought Antidote Grenade!")

								g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
							}
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 7:
				{
					if (CanBuyItem(id, unlimitedclip))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
							ShowSyncHudMsg(id, g_MsgSync6, "You bought Unlimited Clip!")

							g_unlimitedclip[id] = true // set boolean to true

							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 8:
				{
					if (CanBuyItem(id, multijump))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							g_multijump[id] = true
							g_jumpnum[id]++
							set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
							ShowSyncHudMsg(id, g_MsgSync6, "You can now jump %d times!", g_jumpnum[id] + 1)

							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 9:
				{
					if (CanBuyItem(id, jetpack))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							if (get_user_jetpack(id)) 
							user_drop_jetpack(id, 1)

							set_user_jetpack(id, 1)
							set_user_fuel(id, 250.0)
							set_user_rocket_time(id, 0.0)
							client_print_color(id, print_team_grey, "%s Press^3 CTR+SPACE^1 to fly!", CHAT_PREFIX)
							client_print_color(id, print_team_grey, "%s Press^3 RIGHT CLICK^1 to shoot!", CHAT_PREFIX)
							set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
							ShowSyncHudMsg(0, g_MsgSync6, "%s bought a Jetpack!", g_playername[id])

							emit_sound(id, CHAN_STATIC, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 10:
				{
					if (CanBuyItem(id, tryder))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							LIMIT[id][TRYDER]++

							humanme(id, tryder)		// Make him tryder
							set_hudmessage(190, 55, 115, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
							ShowSyncHudMsg(0, g_MsgSync6, "%s is now a Tryder!", g_playername[id])
							client_cmd(id, "spk PerfectZM/armor_equip")
							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 11:
				{
					if (CanBuyItem(id, armor100))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
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
							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 12:
				{
					if (CanBuyItem(id, armor200))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
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
							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 13:
				{
					if (CanBuyItem(id, crossbow))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							if (user_has_weapon(id, CSW_SG550)) drop_prim(id)
							g_has_crossbow[id] = true
							new iWep2 = give_item(id,"weapon_sg550")
							client_cmd(id, "spk ^"fvox/get_crossbow acquired^"")
							cs_set_weapon_ammo(iWep2, CROSSBOW_CLIP)
							cs_set_user_bpammo (id, CSW_SG550, 10000)
							set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
							ShowSyncHudMsg(0, g_MsgSync6, "%s bought a Crossbow!", g_playername[id])
							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 14:
				{
					if (CanBuyItem(id, goldenak))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							g_goldenak47[id] = true
							if (!user_has_weapon(id, CSW_AK47))
							{
								set_weapon(id, CSW_AK47, 10000)
							}
							client_cmd(id, "weapon_ak47")
							set_goldenak47(id)
							set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
							ShowSyncHudMsg(0, g_MsgSync6, "%s has now a Golden Kalashnikov (AK-47)", g_playername[id])
							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 15:
				{
					if (CanBuyItem(id, goldenm4))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							g_goldenm4a1[id] = true
							if (!user_has_weapon(id, CSW_M4A1))
							{
								set_weapon(id, CSW_M4A1, 10000)
							}
							client_cmd(id, "weapon_m4a1")
							set_goldenm4a1(id)
							set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
							ShowSyncHudMsg(0, g_MsgSync6, "%s has now a Golden Maverick (M4-A1)", g_playername[id])
							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 16:
				{
					if (CanBuyItem(id, goldenxm))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							g_goldenxm1014[id] = true
							if (!user_has_weapon(id, CSW_XM1014))
							{
								set_weapon(id, CSW_XM1014, 10000)
							}
							client_cmd(id, "weapon_xm1014")
							set_goldenxm1014(id)
							set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
							ShowSyncHudMsg(0, g_MsgSync6, "%s has now a Golden Leone (XM-1014)", g_playername[id])
							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 17:
				{
					if (CanBuyItem(id, goldendeagle))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							g_goldendeagle[id] = true
							if (!user_has_weapon(id, CSW_DEAGLE))
							{
								set_weapon(id, CSW_DEAGLE, 10000)
							}
							client_cmd(id, "weapon_deagle")
							set_goldendeagle(id)
							set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
							ShowSyncHudMsg(0, g_MsgSync6, "%s has now a Golden Deagle (NightHawk)", g_playername[id])
							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 18:
				{
					if (CanBuyItem(id, nemesis))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							LIMIT[id][MODES]++

							remove_task(TASK_COUNTDOWN)
							remove_task(TASK_MAKEZOMBIE)
							start_mode(nemesis, id)
							set_hudmessage(255, 0, 0, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
							ShowSyncHudMsg(0, g_MsgSync6, "%s brought Nemesis", g_playername[id])
							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 19:
				{
					if (CanBuyItem(id, assassin))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							LIMIT[id][MODES]++

							remove_task(TASK_COUNTDOWN)
							remove_task(TASK_MAKEZOMBIE)
							start_mode(assassin, id)
							set_hudmessage(255, 0, 0, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
							ShowSyncHudMsg(0, g_MsgSync6, "%s brought Assassin", g_playername[id])
							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 20:
				{
					if (CanBuyItem(id, sniper))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							LIMIT[id][MODES]++

							remove_task(TASK_COUNTDOWN)
							remove_task(TASK_MAKEZOMBIE)
							start_mode(sniper, id)
							set_hudmessage(255, 0, 0, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
							ShowSyncHudMsg(0, g_MsgSync6, "%s brought Sniper", g_playername[id])
							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 21:
				{
					if (CanBuyItem(id, survivor))
					{
						if (g_ammopacks[id] >= g_cExtraItems[iChoice][Price])
						{
							LIMIT[id][MODES]++

							remove_task(TASK_COUNTDOWN)
							remove_task(TASK_MAKEZOMBIE)
							start_mode(survivor, id)
							set_hudmessage(255, 0, 0, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
							ShowSyncHudMsg(0, g_MsgSync6, "%s brought Survivor", g_playername[id])
							g_ammopacks[id] -= g_cExtraItems[iChoice][Price]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public _ExtraItems2(id, menu, item)
{
	if (g_isalive[id] && item != -3)
	{
		static iChoice
		static iDummy
		static cBuffer[3]
		menu_item_getinfo(menu, item, iDummy, cBuffer, charsmax(cBuffer), _, _, iDummy)
		iChoice = str_to_num(cBuffer)

		// Additional check to prevent humans classes from buying items if menu is left open
		if (g_zombie[id] && !g_nemesis[id] && !g_assassin[id] && !g_bombardier[id] && !g_sniper[id] && !g_survivor[id] && !g_samurai[id])
		{
			switch (iChoice)
			{
			case 0:
				{
					if (CanBuyItem(id, antidote))
					{
						if (g_ammopacks[id] >= g_cExtraItemsZombie[iChoice][ZPrice])
						{
							// Make him human
							humanme(id, none)

							// Antidote sound
							emit_sound(id, CHAN_ITEM, sound_antidote[random(sizeof sound_antidote)], 1.0, ATTN_NORM, 0, PITCH_NORM)

							// Make teleport effect
							SendTeleport(id)
							
							// Show Antidote HUD notice
							set_hudmessage(9, 201, 214, HUD_INFECT_X, HUD_INFECT_Y, 1, 0.0, 3.0, 2.0, 1.0, -1)
							ShowSyncHudMsg(0, g_MsgSync, "%s has used an antidote!", g_playername[id])

							client_print_color(id, print_team_grey, "%s You are human now", CHAT_PREFIX)

							g_ammopacks[id] -= g_cExtraItemsZombie[iChoice][ZPrice]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 1:
				{
					if (CanBuyItem(id, madness))
					{
						if (g_ammopacks[id] >= g_cExtraItemsZombie[iChoice][ZPrice])
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
							emit_sound(id, CHAN_VOICE, zombie_madness[random(sizeof zombie_madness)], 1.0, ATTN_NORM, 0, PITCH_NORM)

							g_ammopacks[id] -= g_cExtraItemsZombie[iChoice][ZPrice]	// Deduct the packs
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 2:
				{
					if (CanBuyItem(id, infection_nade))
					{
						if (g_ammopacks[id] >= g_cExtraItemsZombie[iChoice][ZPrice])
						{
							// Already own one
							if (user_has_weapon(id, CSW_HEGRENADE))
							{
								client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
								return PLUGIN_HANDLED
							}
							else
							{
								// Show HUD message
								set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
								ShowSyncHudMsg(id, g_MsgSync6, "You bought Infection Bomb!")

								// Play clip purchase sound
								emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)

								// Give weapon to the player
								set_weapon(id, CSW_HEGRENADE, 1)	

								g_ammopacks[id] -= g_cExtraItemsZombie[iChoice][ZPrice]	// Deduct the packs
							}	
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
			case 3:
				{
					if (CanBuyItem(id, concussion_nade))
					{
						if (g_ammopacks[id] >= g_cExtraItemsZombie[iChoice][ZPrice])
						{
							// Already own one
							if (user_has_weapon(id, CSW_FLASHBANG))
							{
								client_print_color(id, print_team_grey, "%s You already have one, first use it", CHAT_PREFIX)
								return PLUGIN_HANDLED
							}
							else
							{
								// Set the boolean to true
								g_concussionbomb[id]++

								// Give weapon to the player
								set_weapon(id, CSW_FLASHBANG, 1)	

								// Show HUD message
								set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
								ShowSyncHudMsg(id, g_MsgSync6, "You bought Concussion Bomb!")

								// Play clip purchase sound
								emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)

								g_ammopacks[id] -= g_cExtraItemsZombie[iChoice][ZPrice]	// Deduct the packs
							}
						}
						else
						{
							client_print_color(id, print_team_grey, "%s You dont have enough ammo packs", CHAT_PREFIX)
							return PLUGIN_HANDLED
						}
					}
					return PLUGIN_HANDLED
				}
				case 4:
				{
					if (CanBuyItem(id, knifeblink))
					{
						if (g_ammopacks[id] >= g_cExtraItemsZombie[iChoice][ZPrice])
						{
							g_blinks[id] += 5

							// Show HUD message
							set_hudmessage(115, 230, 1, -1.0, 0.80, 1, 0.0, 0.0, 3.0, 2.0, -1)
							ShowSyncHudMsg(0, g_MsgSync6, "%s bought knife blinks!", g_playername[id])

							g_ammopacks[id] -= g_cExtraItemsZombie[iChoice][ZPrice]	// Deduct the packs
						}
					}
				}
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
		static iDummy
		static cBuffer[15]

		menu_item_getinfo(menu, item, iDummy, cBuffer, charsmax(cBuffer), _, _, iDummy)
		iChoice = str_to_num(cBuffer)
		g_zombieclassnext[id] = iChoice
		client_print_color(id, print_team_grey, "%s You will be^4 %s^1 after the next infection!", CHAT_PREFIX, g_cZombieClasses[iChoice][ZombieName])
		client_print_color(id, print_team_grey, "%s Health:^4 %s^1 | Speed:^4 %0.0f^1 | Gravity:^4 %0.0f^1 | Knockback:^4 %0.0f%", CHAT_PREFIX, AddCommas(g_cZombieClasses[iChoice][Health]), g_cZombieClasses[iChoice][Speed], floatmul(100.0, g_cZombieClasses[iChoice][Gravity]), floatmul(100.0, g_cZombieClasses[iChoice][Knockback]))
	}
	return PLUGIN_CONTINUE
}

public _PointShop(id, menu, item)
{
	if (item != -3)
	{
		static iChoice
		static iDummy
		static cBuffer[15]
		menu_item_getinfo(menu, item, iDummy, cBuffer, charsmax(cBuffer), _, _, iDummy)
		iChoice = str_to_num(cBuffer)
		switch (iChoice)
		{
		case 0:
			{
				menu_display(id, g_iAmmoMenu, 0)
			}
		case 1:
			{
				menu_display(id, g_iFeaturesMenu, 0)
			}
		case 2:
			{
				menu_display(id, g_iModesMenu, 0)
			}
		case 3:
			{
				menu_display(id, g_iAccessMenu, 0)
			}
		}
	}
	return PLUGIN_CONTINUE
}

public _AmmoMenu(id, menu, item)
{
	if (item != -3)
	{
		static iChoice
		static iDummy
		static cBuffer[15]
		menu_item_getinfo(menu, item, iDummy, cBuffer, charsmax(cBuffer), _, _, iDummy)
		iChoice = str_to_num(cBuffer)
		switch (iChoice)
		{
		case 0:
			{
				if (CanBuyItem(id, shoppacks))
				{
					if (g_points[id] >= g_cAmmoMenu[iChoice][APoints])
					{
						LIMIT[id][PACKS]++
						g_ammopacks[id] += 100
						g_points[id] -= g_cAmmoMenu[iChoice][APoints]
						set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
						ShowSyncHudMsg(0, g_MsgSync6, "%s bought 100 ammo packs!", g_playername[id])
						client_print_color(0, print_team_grey, "%s %s^1 bought^4 100 ammo packs", CHAT_PREFIX, g_playername[id])
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
				}
			}
		case 1:
			{
				if (CanBuyItem(id, shoppacks))
				{
					if (g_points[id] >= g_cAmmoMenu[iChoice][APoints])
					{
						LIMIT[id][PACKS]++
						g_ammopacks[id] += 200
						g_points[id] -= g_cAmmoMenu[iChoice][APoints]
						set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
						ShowSyncHudMsg(0, g_MsgSync6, "%s bought 200 ammo packs!", g_playername[id])
						client_print_color(0, print_team_grey, "%s %s^1 bought^4 200 ammo packs", CHAT_PREFIX, g_playername[id])
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
				}
			}
		case 2:
			{
				if (CanBuyItem(id, shoppacks))
				{
					if (g_points[id] >= g_cAmmoMenu[iChoice][APoints])
					{
						LIMIT[id][PACKS]++
						g_ammopacks[id] += 300
						g_points[id] -= g_cAmmoMenu[iChoice][APoints]
						set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
						ShowSyncHudMsg(0, g_MsgSync6, "%s bought 300 ammo packs!", g_playername[id])
						client_print_color(0, print_team_grey, "%s %s^1 bought^4 300 ammo packs", CHAT_PREFIX, g_playername[id])
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
				}
			}
		case 3:
			{
				if (CanBuyItem(id, shoppacks))
				{
					if (g_points[id] >= g_cAmmoMenu[iChoice][APoints])
					{
						LIMIT[id][PACKS]++
						g_ammopacks[id] += 400
						g_points[id] -= g_cAmmoMenu[iChoice][APoints]
						set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
						ShowSyncHudMsg(0, g_MsgSync6, "%s bought 400 ammo packs!", g_playername[id])
						client_print_color(0, print_team_grey, "%s %s^1 bought^4 400 ammo packs", CHAT_PREFIX, g_playername[id])
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
				}
			}
		case 4:
			{
				if (CanBuyItem(id, shoppacks))
				{
					if (g_points[id] >= g_cAmmoMenu[iChoice][APoints])
					{
						LIMIT[id][PACKS]++
						g_ammopacks[id] += 500
						g_points[id] -= g_cAmmoMenu[iChoice][APoints]
						set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
						ShowSyncHudMsg(0, g_MsgSync6, "%s bought 500 ammo packs!", g_playername[id])
						client_print_color(0, print_team_grey, "%s %s^1 bought^4 500 ammo packs", CHAT_PREFIX, g_playername[id])
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You don't have enough points!", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
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
		static iDummy
		static cBuffer[15]
		menu_item_getinfo(menu, item, iDummy, cBuffer, charsmax(cBuffer), _, _, iDummy)
		iChoice = str_to_num(cBuffer)
		switch (iChoice)
		{
		case 0:
			{
				if (CanBuyItem(id, godmode))
				{
					if (g_points[id] >= g_cFeaturesMenu[iChoice][FPoints])
					{
						// Set the boolean to true
						g_nodamage[id] = true
						g_points[id] -= g_cFeaturesMenu[iChoice][FPoints]
						set_glow(id, 192, 255, 62, 25)
						set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
						show_hudmessage( id, "You bought God Mode!")
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You dont have enough points", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
				}
				return PLUGIN_HANDLED
			}
		case 1:
			{
				if (CanBuyItem(id, doubledamage))
				{
					if (g_points[id] >= g_cFeaturesMenu[iChoice][FPoints])
					{
						// Set the boolean to true
						g_doubledamage[id] = true
						g_points[id] -= g_cFeaturesMenu[iChoice][FPoints]
						set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
						show_hudmessage( id, "You bought Double damage!")
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You dont have enough points", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
				}
				return PLUGIN_HANDLED
			}
		case 2:
			{
				if (CanBuyItem(id, norecoil))
				{
					if (g_points[id] >= g_cFeaturesMenu[iChoice][FPoints])
					{
						// Set the boolean to true
						g_norecoil[id] = true
						g_points[id] -= g_cFeaturesMenu[iChoice][FPoints]
						set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
						show_hudmessage( id, "You bought No Recoil!")
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You dont have enough points", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
				}
				return PLUGIN_HANDLED
			}
		case 3:
			{
				if (CanBuyItem(id, invisibility))
				{
					if (g_points[id] >= g_cFeaturesMenu[iChoice][FPoints])
					{
						g_points[id] -= g_cFeaturesMenu[iChoice][FPoints]
						set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)
						set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
						show_hudmessage( id, "You bought Invisibility!")
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You dont have enough points", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
				}
				return PLUGIN_HANDLED
			}
		case 4:
			{
				if (CanBuyItem(id, sprint))
				{
					if (g_points[id] >= g_cFeaturesMenu[iChoice][FPoints])
					{
						// Set boolean to true
						g_speed[id] = true
						ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
						g_points[id] -= g_cFeaturesMenu[iChoice][FPoints]
						set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
						show_hudmessage( id, "You bought High Speed!")
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You dont have enough points", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
				}
				return PLUGIN_HANDLED
			}
		case 5:
			{
				if (CanBuyItem(id, lowgravity))
				{
					if (g_points[id] >= g_cFeaturesMenu[iChoice][FPoints])
					{
						set_pev(id, pev_gravity, 0.5)
						g_points[id] -= g_cFeaturesMenu[iChoice][FPoints]
						set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
						show_hudmessage( id, "Now you have less gravity!")
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You dont have enough points", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
				}
				return PLUGIN_HANDLED
			}
		case 6:
			{
				/*if (CanBuyItem(id, headhunter))
				{
					if (g_points[id] >= g_cFeaturesMenu[iChoice][FPoints])
					{
						// Set boolean to true
						g_allheadshots[id] = true

						g_points[id] -= g_cFeaturesMenu[iChoice][FPoints]
						set_hudmessage( 115, 230, 1, -1.0, 0.80, 1, 0.0, 5.0, 1.0, 1.0, -1 )
						show_hudmessage( id, "Now all your bullet will connect to head!")
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You dont have enough points", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
				}*/
				return PLUGIN_HANDLED
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
		static iDummy
		static cBuffer[15]
		menu_item_getinfo(menu, item, iDummy, cBuffer, charsmax(cBuffer), _, _, iDummy)
		iChoice = str_to_num(cBuffer)
		switch (iChoice)
		{
		case 0:
			{
				if (CanBuyItem(id, armageddon))
				{
					if (g_points[id] >= g_cModesMenu[iChoice][MPoints])
					{
						remove_task(TASK_MAKEZOMBIE)
						start_mode(armageddon, 0)

						LIMIT[id][CUSTOM_MODES]++

						g_points[id] -= g_cModesMenu[iChoice][MPoints]
						set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
						show_hudmessage(0, "%s bought Armageddon mode with points!", g_playername[id])
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You dont have enough points", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
				}
			}
		case 1:
			{
				if (CanBuyItem(id, nightmare))
				{
					if (g_points[id] >= g_cModesMenu[iChoice][MPoints])
					{
						remove_task(TASK_MAKEZOMBIE)
						start_mode(nightmare, 0)

						LIMIT[id][CUSTOM_MODES]++

						g_points[id] -= g_cModesMenu[iChoice][MPoints]
						set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
						show_hudmessage(0, "%s bought Nightmare mode with points!", g_playername[id])
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You dont have enough points", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
				}
			}
		case 2:
			{
				
			}
		case 3:
			{
				
			}
		case 4:
			{
				
			}
		case 5:
			{
				if (CanBuyItem(id, devil))
				{
					if (g_points[id] >= g_cModesMenu[iChoice][MPoints])
					{
						remove_task(TASK_MAKEZOMBIE)
						start_mode(devil, 0)

						LIMIT[id][CUSTOM_MODES]++

						g_points[id] -= g_cModesMenu[iChoice][MPoints]
						set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
						show_hudmessage(0, "%s bought Sniper vs Nemesis mode with points!", g_playername[id])
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You dont have enough points", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
				}
			}
		case 6:
			{
				if (CanBuyItem(id, apocalypse))
				{
					if (g_points[id] >= g_cModesMenu[iChoice][MPoints])
					{
						remove_task(TASK_MAKEZOMBIE)
						start_mode(apocalypse, 0)

						LIMIT[id][CUSTOM_MODES]++

						g_points[id] -= g_cModesMenu[iChoice][MPoints]
						set_hudmessage(9, 201, 214, -1.00, 0.70, 1, 0.00, 3.00, 2.00, 1.00, -1)
						show_hudmessage(0, "%s bought Sniper vs Assassin mode with points!", g_playername[id])
						MySQL_UPDATE_DATABASE(id)
					}
					else
					{
						client_print_color(id, print_team_grey, "%s You dont have enough points", CHAT_PREFIX)
						return PLUGIN_HANDLED
					}
				}
			}
		case 7:
			{
				
			}
		}
	}
	return PLUGIN_CONTINUE
}

public _Access(id, menu, item)
{
	if (item != -3)
	{
		static iChoice
		static iDummy
		static cBuffer[15]
		menu_item_getinfo(menu, item, iDummy, cBuffer, charsmax(cBuffer), _, _, iDummy)
		iChoice = str_to_num(cBuffer)
		switch (iChoice)
		{
		case 0:
			{
				
			}
		case 1:
			{
				
			}
		case 2:
			{
				
			}
		case 3:
			{
				
			}
		}
	}
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
	if (g_bot[id]) 
	{
		g_bot[id] = 0, g_iBotsCount --
	}

	// Reset some vars
	g_antidotebomb[id] = 0
	g_concussionbomb[id] = 0
	g_bubblebomb[id] = 0
	g_killingbomb[id] = 0
	g_multijump[id] = false
	g_jumpnum[id] = 0
	g_tryder[id] = false
	g_blinks[id] = 0
}

// Abhinash
public plugin_end()
{
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
	// Increase round count var
	g_roundcount++

	// countdown
	if (task_exists(TASK_COUNTDOWN))
	remove_task(TASK_COUNTDOWN)

	countdown_timer = 10
	set_task(4.0, "Countdown", TASK_COUNTDOWN)

	// Remove Concussion task
	remove_task(TASK_CONCUSSION)
	
	// New round starting
	g_newround = true
	g_endround = false
	g_survround = false
	g_sniround = false
	g_samurairound = false
	g_nemround = false
	g_assaround = false
	g_bombardierround = false
	g_swarmround = false
	g_plagueround = false
	g_armageround = false
	g_apocround = false
	g_nightround = false
	g_devilround = false

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
		if (g_isconnected[id] && get_user_jetpack(id))
		{
			set_user_rocket_time(id, 0.0)
		}
		else if(g_isconnected[id] && VipHasFlag(id, 'a'))
		{
			g_jumpnum[id] = 2
		}
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
	// Reset lighting if last round was Assassin round
	if (g_lastmode == assassin)
	{
		engfunc(EngFunc_LightStyle, 0, "d") // Set lighting
	}
	
	// Remove Bubble bomb entity
	remove_entity_name(BubbleEntityClassName)

	// Prevent this from getting called twice when restarting (bugfix)
	static Float:lastendtime, Float:current_time
	current_time = get_gametime()
	if (current_time - lastendtime < 0.5) return
	lastendtime = current_time
	
	// Temporarily save player stats?
	if (SaveStats == 1)
	{
		static id, team
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not connected
			if (!g_isconnected[id])
			continue
			
			team = fm_cs_get_user_team(id)
			
			// Not playing
			if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
			continue
			
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
		if (g_norecoil[id])
		{
			g_norecoil[id] = false
		}
		if (g_blinks[id])
		{
			g_blinks[id] = 0
		}

		LIMIT[id][TRYDER] = 0
		/*else if (g_allheadshots[id])
		{
			g_allheadshots[id] = false
		}*/
	}
	
	// Round ended
	g_endround = true
	
	// Stop old tasks (if any)
	remove_task(TASK_WELCOMEMSG)
	remove_task(TASK_MAKEZOMBIE)

	// Remove Reminder Task
	if (task_exists(TASK_REMINDER))
	remove_task(TASK_REMINDER)
	
	// Stop ambience sounds
	if ((g_nemround)
			|| (g_assaround)
			|| (g_bombardierround)	// Abhinash
			|| (g_survround)
			|| (g_sniround)
			|| (g_samurairound)		// Abhinash
			|| (g_swarmround)
			|| (g_plagueround)
			|| (g_armageround)
			|| (g_apocround)
			|| (g_nightround)
			|| (g_devilround) 		// Abhinash
			|| (!g_nemround && !g_assaround && !g_survround && !g_sniround && !g_samurairound && !g_swarmround && !g_plagueround && !g_armageround && !g_apocround && !g_nightround && !g_devilround && !g_bombardierround))
	{
		remove_task(TASK_AMBIENCESOUNDS)
		ambience_sound_stop()
	}
	
	// Show HUD notice, play win sound, update team scores...
	if (!fnGetZombies())
	{
		// Human team wins
		set_hudmessage(0, 0, 200, HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Humans have defeated the plague!")
		
		// Play win sound and increase score, unless game commencing
		PlaySound(sound_win_humans[random(sizeof sound_win_humans)])
		if (!g_gamecommencing) g_scorehumans++
	}
	else if (!fnGetHumans())
	{
		// Zombie team wins
		set_hudmessage(200, 0, 0, HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Zombies have taken over the world!")
		
		// Play win sound and increase score, unless game commencing
		PlaySound(sound_win_zombies[random(sizeof sound_win_zombies)])
		if (!g_gamecommencing) g_scorezombies++
	}
	else
	{
		// No one wins
		set_hudmessage(0, 200, 0, HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "No one won...")
		
		// Play win sound
		PlaySound(sound_win_no_one[random(sizeof sound_win_no_one)])
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
	while (g_maxplayers + 1 > g_iVariable)
	{
		if (g_isconnected[g_iVariable])
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
	while (g_maxplayers + 1 > g_iVariable)
	{
		if (g_isconnected[g_iVariable] && g_ammopacks[g_iVariable] > iMaximumPacks)
		{
			iMaximumPacks = g_ammopacks[g_iVariable];
			iPacksLeader = g_iVariable;
		}
		g_iVariable += 1;
	}
	if (g_isconnected[iKillsLeader])
	{
		if (g_iKillsThisRound[iKillsLeader])
		{
			client_print_color(0, print_team_grey, "^3%s^1 is^4 Leader^1 with^4 %s^1 frags! [^4 %d^1 this round ]", g_playername[iKillsLeader], AddCommas(iMaximumKills), g_iKillsThisRound[iKillsLeader]);
		}
		else
		{
			client_print_color(0, print_team_grey, "^3%s^1 is^4 Leader^1 with^4 %s^1 frags!", g_playername[iKillsLeader], AddCommas(iMaximumKills))
		}
	}
	if (g_isconnected[iPacksLeader])
	{
		client_print_color(0, print_team_grey, "^3%s^1 is^4 Leader^1 with^4 %s^1 packs!", g_playername[iPacksLeader], AddCommas(iMaximumPacks))
	}
	
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

public event_reset_hud()
{
	Show_VIP()
}

public Show_VIP()
{
	for (new id = 0; id <= g_maxplayers; id++)
	{
		// Show VIP in ScoreBoard
		if (g_bVip[id])
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
		if (g_zombie[id] == g_zombie[aimid])
		{
			static red, green, blue 
			
			// Format the class name according to the player's team
			if (g_zombie[id])
			{
				red = 255
				green = 50
				blue = 0

				// Show the notice
				set_hudmessage(red, green, blue, -1.0, 0.60, 1, 0.01, 0.40, 0.01, 0.01, -1)
				ShowSyncHudMsg(id, g_MsgSync3,"%s^n[ %s | Health: %s | Ammo: %s | Points: %s ]", \
				g_playername[aimid], g_cClass[aimid], AddCommas(pev(aimid, pev_health)), AddCommas(g_ammopacks[aimid]), AddCommas(g_points[aimid]))
			}
			else
			{
				red = 0
				green = 50
				blue = 255

				// Show the notice
				set_hudmessage(red, green, blue, -1.0, 0.60, 1, 0.01, 0.40, 0.01, 0.01, -1)
				ShowSyncHudMsg(id, g_MsgSync3,"%s^n[ %s | Health: %s | Ammo: %s | Armor: %d | Points: %s ]", \
				g_playername[aimid], g_cClass[aimid], AddCommas(pev(aimid, pev_health)), AddCommas(g_ammopacks[aimid]), pev(aimid, pev_armorvalue), AddCommas(g_points[aimid]))
			}
		}
		else if (!g_zombie[id] && g_zombie[aimid])
		{
			set_hudmessage(255, 50, 0, -1.0, 0.60, 1, 0.01, 0.40, 0.01, 0.01, -1)
			ShowSyncHudMsg(id, g_MsgSync3, "%s^n[ Health: %s ]", g_playername[aimid], AddCommas(pev(aimid, pev_health)))
		}
		else if (g_zombie[id] && !g_zombie[aimid])
		{
			if(g_sniper[aimid] || g_survivor[aimid] || g_samurai[aimid])
			{
				set_hudmessage(255, 15, 15, -1.0, 0.60, 1, 0.01, 0.40, 0.01, 0.01, -1)
				ShowSyncHudMsg(id, g_MsgSync3, "%s^n[ Health: %s ]", g_playername[aimid], AddCommas(pev(aimid, pev_health)))
			}
			else
			{
				set_hudmessage(255, 15, 15, -1.0, 0.60, 1, 0.01, 0.40, 0.01, 0.01, -1)
				ShowSyncHudMsg(id, g_MsgSync3, "%s^n[ Health: %s | Armor: %d ]", g_playername[aimid], AddCommas(pev(aimid, pev_health)), pev(aimid, pev_armorvalue))
			}
		}
	}
}

// Remove the aim-info message
public event_hide_status(id)
{
	ClearSyncHud(id, g_MsgSync3)
}

// Countdown function
public Countdown()
{
	if (countdown_timer > 0)
	{ 
		client_cmd(0, "spk %s", CountdownSounds[countdown_timer])
		
		set_hudmessage(179, 0, 0, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1, 10)
		if (countdown_timer != 0)
		ShowSyncHudMsg(0, g_MsgSync4, "Infection in %i", countdown_timer)
	}
	--countdown_timer
	
	if (countdown_timer == 0)
	{
		client_cmd(0, "spk %s", CountdownSounds[countdown_timer])
		set_hudmessage(179, 0, 0, -1.0, 0.28, 2, 0.02, 2.0, 0.01, 0.1, 10);
		ShowSyncHudMsg(0, g_MsgSync4, "Warning: Biohazard detected");
	}

	if(countdown_timer >= 1)
	set_task(1.0, "Countdown", TASK_COUNTDOWN);
	else if (task_exists(TASK_COUNTDOWN))
	remove_task(TASK_COUNTDOWN);
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
	if (!is_user_alive(id) || !fm_cs_get_user_team(id))
	return
	
	// Player spawned
	g_isalive[id] = true
	g_specialclass[id] = false
	g_cClass[id] = "Human"
	g_jumpnum[id] = 1

	
	// Remove previous tasks
	remove_task(id+TASK_SPAWN)
	remove_task(id+TASK_MODEL)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	remove_task(id+TASK_CHARGE)
	remove_task(id+TASK_FLASH)
	remove_task(id+TASK_NVISION)
	
	// Hide money?
	if (RemoveMoney == 1)
	set_task(0.4, "task_hide_money", id+TASK_SPAWN)
	
	// Respawn player if he dies because of a worldspawn kill?
	if (RespawnOnWorldSpawnKill == 1)
	set_task(2.0, "respawn_player_check_task", id+TASK_SPAWN)
	
	// Spawn as zombie?
	if (g_respawn_as_zombie[id] && !g_newround)
	{
		reset_vars(id, 0) // reset player vars
		zombieme(id, 0, none) // make him zombie right away
		return
	}
	
	// Reset player vars
	reset_vars(id, 0)
	g_buytime[id] = get_gametime()
	
	// Show custom buy menu
	set_task(0.2, "show_menu_buy1", id+TASK_SPAWN)
	
	// Set health and gravity
	set_user_health(id, HumanHealth)
	set_pev(id, pev_gravity, HumanGravity)
	
	// Set human maxspeed
	ExecuteHamB(Ham_Player_ResetMaxSpeed, id)

	// VIP
	if (VipHasFlag(id, 'a') && g_jumpnum[id] != 2)
	{
		g_jumpnum[id] = 2
	}
	if (VipHasFlag(id, 'c') && get_armor(id) <= 50)
	{
		set_armor(id, get_armor(id) + 50)
	}
	if (VipHasFlag(id, 'd'))
	{
		set_health(id, get_health(id) + 150)
	}
	if (VipHasFlag(id, 'e'))
	{
		g_ammopacks[id] += 10
	}
	
	// Switch to CT if spawning mid-round
	if (!g_newround && fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
	{
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		fm_user_team_update(id)
	}
	
	
	// Set the right model, after checking that we don't already have it
	static Float:current_time
	current_time = get_gametime()
	
	if (current_time - g_models_targettime >= g_modelchange_delay)
	{
		ChangeModels(id+TASK_MODEL)
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
	set_task(1.0, "ChargeFlashLight", id+TASK_CHARGE, _, _, "b")
	
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
	
	// Enable dead players nightvision
	spec_nvision(victim)
	
	// Disable nightvision when killed (bugfix)
	if ((!NightVisionEnabled) && g_nvision[victim])
	{
		if (CustomNightVision) remove_task(victim+TASK_NVISION)
		else if (g_nvisionenabled[victim]) set_user_gnvision(victim, 0)
		g_nvision[victim] = false
		g_nvisionenabled[victim] = false
	}
	
	// Turn off nightvision when killed (bugfix)
	if (NightVisionEnabled == 2 && g_nvision[victim] && g_nvisionenabled[victim])
	{
		if (CustomNightVision) remove_task(victim+TASK_NVISION)
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
		remove_task(victim+TASK_CHARGE)
		remove_task(victim+TASK_FLASH)
	}
	
	// Stop bleeding/burning/aura when killed
	if (g_zombie[victim])
	{
		remove_task(victim+TASK_BLOOD)
		remove_task(victim+TASK_AURA)
		remove_task(victim+TASK_BURN)
	}
	
	// Make Player body explode on kill
	SetHamParamInteger(3, 2)
	
	// Special killed functions
	if (g_nemesis[attacker]) g_nemesiskills[attacker]++
	else if (g_assassin[attacker]) g_assasinkills[attacker]++
	else if (g_bombardier[attacker]) g_bombardierkills[attacker]++
	else if (g_survivor[attacker]) g_survivorkills[attacker]++
	else if (g_sniper[attacker])
	{
		g_sniperkills[attacker]++
		SendLavaSplash(victim)
	}
	else if (g_samurai[attacker])
	{
		g_samuraikills[attacker]++
		SendLavaSplash(victim)
	}

	// InformerX function
	static iZombies; iZombies = fnGetZombies()
	static iHumans; iHumans = fnGetHumans()

	if (!iHumans || !iZombies) return

	if (g_sniround || g_survround)
	{
		if (iZombies != 1)
		{
			set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
			ShowSyncHudMsg(0, g_MsgSync7, "%d Zombies Remaining...", iZombies)
		}
	}
	else if (g_nemround || g_assaround)
	{
		if (iHumans != 1)
		{
			set_hudmessage(170, 170, 170, 0.02, 0.6, 2, 0.03, 0.5, 0.02, 3.0, -1)
			ShowSyncHudMsg(0, g_MsgSync7, "%d Humans Remaining...", iHumans)
		}
	}
	if (iZombies == 1 && iHumans == 1)
	{
		set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), HUD_EVENT_X, HUD_EVENT_Y, 1, 0.01, 1.75, 1.00, 1.00, -1)
		ShowSyncHudMsg(0, g_MsgSync7, "%s vs %s", g_playername[fnGetLastHuman()], g_playername[fnGetLastZombie()])
	}
	
	// Determine whether the player killed himself
	static selfkill
	selfkill = (victim == attacker || !is_user_valid_connected(attacker)) ? true : false
	
	// Killed by a non-player entity or self killed
	if (selfkill) return
	
	// Killed by Zombie Team, reward packs
	if (g_zombie[attacker])
	{
		if (g_nemesis[attacker]) g_ammopacks[attacker] += 2
		else if(g_assassin[attacker]) g_ammopacks[attacker] += 1
		else if(g_bombardier[attacker]) g_ammopacks[attacker] += 1
		else g_ammopacks[attacker] += 5
	}
	else
	{
		if(g_survivor[attacker]) g_ammopacks[attacker] += 2
		else if(g_sniper[attacker]) g_ammopacks[attacker] += 3
		else if(g_samurai[attacker]) g_ammopacks[attacker] += 4
		else g_ammopacks[attacker] += 5
	}

	// Reset some vars
	g_antidotebomb[victim] = 0
	g_concussionbomb[victim] = 0
	g_bubblebomb[victim] = 0
	g_killingbomb[victim] = 0
	g_goldenak47[victim] = false
	g_goldenm4a1[victim] = false
	g_goldenxm1014[victim] = false
	g_goldendeagle[victim] = false
	
	// Human killed zombie, add up the extra frags for kill
	if (!g_zombie[attacker] && HumanFragsForKill > 1)
	UpdateFrags(attacker, victim, HumanFragsForKill - 1, 0, 0)
	
	// Zombie killed human, add up the extra frags for kill
	if (g_zombie[attacker] && ZombieRewardInfectFrags > 1)
	UpdateFrags(attacker, victim, ZombieRewardInfectFrags - 1, 0, 0)

	// For Leader
	g_iKillsThisRound[attacker]++

	// Update player datas
	g_points[attacker] += 2
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
	if (damage_type & DMG_FALL && VipHasFlag(victim, 'f'))
	return HAM_SUPERCEDE

	// Non-player damage or self damage
	if (victim == attacker || !is_user_valid_connected(attacker))
	return HAM_IGNORED
	
	// New round starting or round ended
	if (g_newround || g_endround)
	return HAM_SUPERCEDE
	
	// Victim shouldn't take damage 
	if (g_nodamage[victim])
	return HAM_SUPERCEDE
	
	// Prevent friendly fire
	if (g_zombie[attacker] == g_zombie[victim])
	return HAM_SUPERCEDE
	
	// Reward ammo packs to human classes
	
	// Attacker is human...
	if (!g_zombie[attacker])
	{
		// Armor multiplier for the final damage on normal zombies
		if (!g_nemesis[victim] && !g_assassin[victim] && !g_bombardier[victim] && !g_sniper[attacker] && !g_samurai[attacker] && !g_survivor[attacker])		// Abhinash
		{
			damage *= ZombieArmor
			SetHamParamFloat(4, damage)
		}

		// Set Sniper's damage
		if (g_sniper[attacker] && g_currentweapon[attacker] == CSW_AWP)
		SetHamParamFloat(4, SniperDamage)
		
		// Set samurai's damage		// Abhinash
		if (g_samurai[attacker] && g_currentweapon[attacker] == CSW_KNIFE)
		SetHamParamFloat(4, SamuraiDamage)

		// Crossbow damage
		if(g_currentweapon[attacker] == CSW_SG550 && g_has_crossbow[attacker])
		{
			damage *= CROSSBOW_DAMAGE
			SetHamParamFloat(4, CROSSBOW_DAMAGE)
		}

		// Double damage
		if (!g_bVip[attacker] && g_doubledamage[attacker] && !g_sniper[attacker] && !(damage_type & (DMG_BLAST | DMG_MORTAR)))
		{
			damage *= 2.0
			SetHamParamFloat(4, damage)
		}

		if (VipHasFlag(attacker, 'g') && !g_zombie[attacker] && !(damage_type & (DMG_BLAST | DMG_MORTAR)))
		{
			damage *= 1.5
		}

		if (((g_goldenak47[attacker] && g_currentweapon[attacker] == CSW_AK47) || (g_goldenm4a1[attacker] && g_currentweapon[attacker] == CSW_M4A1) || (g_goldenxm1014[attacker] && g_currentweapon[attacker] == CSW_XM1014) || (g_goldendeagle[attacker] && g_currentweapon[attacker] == CSW_DEAGLE)) && !(damage_type & (DMG_BLAST | DMG_MORTAR)))
		{
			damage *= 2.0
			SetHamParamFloat(4, damage)
		}
		
		g_damagedealt_human[attacker] += floatround(damage)
		
		if(!g_sniper[attacker] && !g_samurai[attacker])
		{
			while (g_damagedealt_human[attacker] > 500)
			{
				g_ammopacks[attacker]++
				g_damagedealt_human[attacker] -= 500
			}
		}

		// Bullet damage
		if (damage > 1) // Dummy check
		{
			if(++iPosition[attacker] == sizeof(g_flCoords))
			{
				iPosition[attacker] = 0
			}

			if (damage_type & DMG_BLAST) 
			{
				client_print_color(attacker, print_team_grey, "%s Damage to^3 %s^1 ::^4 %s^1 damage", CHAT_PREFIX, g_playername[victim], AddCommas(floatround(damage)))
				set_hudmessage(200, 0, 0, g_flCoords[iPosition[attacker]][0], g_flCoords[iPosition[attacker]][1], 0, 0.1, 2.5, 0.02, 0.02, -1)

				// Send Screenfade message
				UTIL_ScreenFade(victim, {200, 0, 0}, 1.0, 0.5, 100, FFADE_IN, true, false)

				// Send Screenshake message
				SendScreenShake(victim, 4096 * 6, 4096 * random_num(4, 12), 4096 * random_num(4, 12))
			}
			else if (!(g_sniper[attacker] || g_samurai[attacker])) set_hudmessage(0, 40, 80, g_flCoords[iPosition[attacker]][0], g_flCoords[iPosition[attacker]][1], 0, 0.1, 2.5, 0.02, 0.02, -1)

			show_hudmessage(attacker, "%s", AddCommas(floatround(damage)))	
		}
		
		return HAM_IGNORED
	}
	// Attacker is zombie...
	else
	{
		// Nemesis?
		if (g_nemesis[attacker])
		{
			// Ignore nemesis damage override if damage comes from a 3rd party entity
			// (to prevent this from affecting a sub-plugin's rockets e.g.)
			if (inflictor == attacker)
			{
				// Set nemesis damage
				SetHamParamFloat(4, NemesisDamage)
			}
			
			return HAM_IGNORED
		}
		else if (g_assassin[attacker])
		{
			// Ignore assassin damage override if damage comes from a 3rd party entity
			// (to prevent this from affecting a sub-plugin's rockets e.g.)
			if (inflictor == attacker)
			{
				// Set assassin damage
				SetHamParamFloat(4, AssassinDamage)
			}
			
			return HAM_IGNORED
		}
		else if (g_bombardier[attacker])
		{
			// Ignore assassin damage override if damage comes from a 3rd party entity
			// (to prevent this from affecting a sub-plugin's rockets e.g.)
			if (inflictor == attacker)
			{
				// Set assassin damage
				SetHamParamFloat(4, BombardierDamage)
			}
			
			return HAM_IGNORED
		}
	}

	// Prevent infection/damage by HE grenade (bugfix)
	if (damage_type & DMG_HEGRENADE)
	return HAM_SUPERCEDE
	
	// Last human or not an infection round
	if (g_survround || g_sniround || g_nemround || g_assaround || g_bombardierround || g_samurairound || g_swarmround || g_plagueround || g_armageround || g_apocround || g_nightround || fnGetHumans() == 1)
	return HAM_IGNORED // human is killed
	
	// Does human armor need to be reduced before infecting?
	if (HumanArmorProtect)
	{
		//if (g_survivor[victim]) return
		
		// Get victim armor
		static Float:armor
		pev(victim, pev_armorvalue, armor)
		
		// If he has some, block the infection and reduce armor instead
		if (armor > 0.0)
		{
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
	
	zombieme(victim, attacker, none) // turn into zombie
	g_points[attacker]++		// Abhinash
	g_kills[attacker]++
	g_infections[attacker]++
	g_score[attacker] += 10
	MySQL_UPDATE_DATABASE(attacker)

	return HAM_SUPERCEDE
}

// Ham Take Damage Post Forward
public OnTakeDamagePost(victim)
{
	// --- Check if victim should be Pain Shock Free ---
	
	// Check if proper CVARs are enabled
	if (g_zombie[victim])
	{
		if (g_nemesis[victim]) if (NemesisPainfree == 0) return
		else if (g_assassin[victim]) if (AssassinPainfree == 0) return
		else if (g_bombardier[victim]) if (BombardierPainfree == 0) return
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
		if (g_survivor[victim]) if (SurvivorPainfree == 0) return
		else if (g_sniper[victim]) if (SniperPainfree == 0) return
		else if (g_samurai[victim]) if (SamuraiPainfree == 0) return
		else return
	}
	
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(victim) != PDATA_SAFE)
	return
	
	// Set pain shock free offset
	set_pdata_float(victim, OFFSET_PAINSHOCK, 1.0, OFFSET_LINUX)
}

// Ham Trace Attack Forward
public OnTraceAttack(victim, attacker, Float:damage, Float:direction[3], tracehandle, damage_type, ptr)
{
	// Non-player damage or self damage
	if (victim == attacker || !is_user_valid_connected(attacker))
	return HAM_IGNORED
	
	// New round starting or round ended
	if (g_newround || g_endround)
	return HAM_SUPERCEDE
	
	// Victim shouldn't take damage or victim is frozen
	if (g_nodamage[victim])
	return HAM_SUPERCEDE
	
	// Prevent friendly fire
	if (g_zombie[attacker] == g_zombie[victim])
	return HAM_SUPERCEDE
	
	// Victim isn't a zombie or not bullet damage, nothing else to do here
	if (!g_zombie[victim] || !(damage_type & DMG_BULLET))
	return HAM_IGNORED
	
	// Knockback disabled, nothing else to do here
	if (KnockbackEnabled == 0)
	return HAM_IGNORED
	
	// Get whether the victim is in a crouch state
	static ducking
	ducking = pev(victim, pev_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND)
	
	// Zombie knockback when ducking disabled
	if (ducking && KnockbackDucking == 0.0) 
	return HAM_IGNORED
	
	// Get distance between players
	static origin1[3], origin2[3]
	get_user_origin(victim, origin1)
	get_user_origin(attacker, origin2)
	
	// Max distance exceeded
	if (get_distance(origin1, origin2) > KnockbackDistance)
	return HAM_IGNORED
	
	// Get victim's velocity
	static Float:velocity[3]
	pev(victim, pev_velocity, velocity)
	
	// Use damage on knockback calculation
	xs_vec_mul_scalar(direction, damage, direction)
	
	// Apply ducking knockback multiplier
	if (ducking)
	xs_vec_mul_scalar(direction, KnockbackDucking, direction)
	
	// Apply zombie class/nemesis knockback multiplier
	if (g_nemesis[victim])
	xs_vec_mul_scalar(direction, KnockbackNemesis, direction)
	else if (g_assassin[victim])
	xs_vec_mul_scalar(direction, KnockbackAssassin, direction)
	else if (g_bombardier[victim])
	xs_vec_mul_scalar(direction, KnockbackBombardier, direction)
	else
	xs_vec_mul_scalar(direction, g_cZombieClasses[g_zombieclass[victim]][Knockback], direction) 
	
	// Add up the new vector
	xs_vec_add(velocity, direction, direction)
	
	// Make knockback also affect vertical velocity
	direction[2] = velocity[2]
	
	// Set the knockback'd victim's velocity
	set_pev(victim, pev_velocity, direction)

	// Golden Weapon functions
	if ((g_goldenak47[attacker] && g_currentweapon[attacker] == CSW_AK47) || (g_goldenm4a1[attacker] && g_currentweapon[attacker] == CSW_M4A1) || (g_goldenxm1014[attacker] && g_currentweapon[attacker] == CSW_XM1014) || (g_goldendeagle[attacker] && g_currentweapon[attacker] == CSW_DEAGLE))
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

		new jumps = g_jumpnum[id]

		if (jumps)
		{
			if (get_pdata_float(id, 251) < 500 && ++g_jumpcount[id] <= jumps)
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
	if (g_zombie[id])
	{
		if (g_nemesis[id])
		{
			if (!g_cached_leapnemesis) return
			cooldown = g_cached_leapnemesiscooldown
		}
		else if (g_assassin[id])
		{
			if (!g_cached_leapassassin) return
			cooldown = g_cached_leapassassincooldown
		}
		else if (g_bombardier[id])
		{
			if (!g_cached_leapbombardier) return
			cooldown = g_cached_leapbombardiercooldown
		}
		else
		{
			if (LeapZombies == 1)
			{
				cooldown = g_cached_leapzombiescooldown
			}
		}
	}
	else
	{
		if (g_survivor[id])
		{
			if (!g_cached_leapsurvivor) return
			cooldown = g_cached_leapsurvivorcooldown
		}
		else if (g_sniper[id])
		{
			if (!g_cached_leapsniper) return
			cooldown = g_cached_leapsnipercooldown
		}
		else if (g_samurai[id])
		{
			if (!g_cached_leapzadoc) return
			cooldown = g_cached_leapzadoccooldown
		}
		else return
	}
	
	current_time = get_gametime()
	
	// Cooldown not over yet
	if (current_time - g_lastleaptime[id] < cooldown)
	return
	
	// Not doing a longjump (don't perform check for bots, they leap automatically)
	if (!g_isbot[id] && !(pev(id, pev_button) & (IN_JUMP | IN_DUCK) == (IN_JUMP | IN_DUCK)))
	return
	
	// Not on ground or not enough speed
	if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 80)
	return
	
	static Float:velocity[3]
	
	// Make velocity vector
	velocity_by_aim(id, g_survivor[id] ? LeapSurvivorForce
	: g_sniper[id] ? LeapSniperForce
	: g_samurai[id] ? LeapSamuraiForce		// Abhinash
	: g_nemesis[id] ? LeapNemesisForce
	: g_assassin[id] ? LeapAssassinForce
	: g_bombardier[id] ? LeapBombardierForce		// Abhinash
	: LeapZombiesForce, velocity)
	
	// Set custom height
	velocity[2] = g_survivor[id] ? LeapSurvivorHeight
	: g_sniper[id] ? LeapSniperHeight
	: g_samurai[id] ? LeapSamuraiHeight		// Abhinash
	: g_nemesis[id] ? LeapNemesisHeight
	: g_assassin[id] ? LeapAssassinHeight
	: g_bombardier[id] ? LeapBombardierHeight
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
		if (g_sniper[id])
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
	if (use_type == USE_USING && is_user_valid_connected(caller) && g_zombie[caller])
	return HAM_SUPERCEDE
	
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
	if (!is_user_valid_connected(id))
	return HAM_IGNORED
	
	// Dont pickup weapons if zombie or survivor (+PODBot MM fix)
	if (g_zombie[id] || g_isbot[id] || ((g_survivor[id] || g_sniper[id] || g_samurai[id] /* Abhinash */) && (g_isbot[id] || g_isalive[id])))
	return HAM_SUPERCEDE
	
	return HAM_IGNORED
}

// Ham Weapon Pickup Forward
public OnAddPlayerItem(id, weapon_ent)
{
	// HACK: Retrieve our custom extra ammo from the weapon
	static extra_ammo
	extra_ammo = pev(weapon_ent, PEV_ADDITIONAL_AMMO)
	
	// If present
	if (extra_ammo)
	{
		// Get weapon's id
		static weaponid
		weaponid = cs_get_weapon_id(weapon_ent)
		
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
	if (!pev_valid(id))
	return;
	
	// Get weapon's id
	static weaponid
	weaponid = cs_get_weapon_id(weapon_ent)
	
	// Store current weapon's id for reference
	g_currentweapon[id] = weaponid
	
	// Replace weapon models with custom ones
	replace_weapon_models(id, weaponid)
	
	// Zombie not holding an allowed weapon for some reason
	if (g_zombie[id] && !((1<<weaponid) & ZOMBIE_ALLOWED_WEAPONS_BITSUM))
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

	// Load his data
	MySQL_LOAD_DATABASE(id)

	set_task(5.0, "init_welcome", id)
	
	//CreateFog(id, 128, 128, 128, 0.0008)
	
	// Cache player's name
	get_user_name(id, g_playername[id], charsmax(g_playername[]))
	
	// Initialize player vars
	reset_vars(id, 1)
	g_ammopacks[id] = StartingPacks // Starting ammo packs 
	
	// Load player stats?
	if (SaveStats == 1) load_stats(id)
	
	// Set some tasks for humans only
	if (!is_user_bot(id))
	{
		// Set the custom HUD display task
		set_task(1.0, "ShowHUD", id+TASK_SHOWHUD, _, _, "b")
		
		// Disable minmodels for clients to see zombies properly
		set_task(5.0, "disable_minmodels", id)
		
		MakeUserAdmin(id)	// Check and make admin
		MakeUserVip(id)		// Check and make admin
		get_user_ip(id, g_cIP[id], charsmax(g_cIP), 1)	// Get player's IP Address
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
		formatex(g_cIP[id], charsmax(g_cIP), "%i.%i.%i.0", random_num(0,255), random_num(0,255), random_num(0,255))
	}

	geoip_country_ex(g_cIP[id], g_playercountry[id], charsmax(g_playercountry[]) -1)
	geoip_city(g_cIP[id], g_playercity[id], charsmax(g_playercity[]) -1)
	if (containi(g_playercountry[id], "err") != -1) g_playercountry[id] = "N/A"
	if (!g_playercity[id][0]) g_playercity[id] = "N/A"
	client_print_color(0, print_team_grey, "^1Player^4 %s^1 connected from [^3%s^1] [^3%s^1]", g_playername[id], g_playercountry[id], g_playercity[id])
}

/*public FwTraceLine(Float:start[3], Float:end[3], conditions, id, trace)
{
	// All headshots functions
	if (g_allheadshots[id])
	{
		set_tr2(trace, TR_iHitgroup, HIT_HEAD)
	}
}*/

// id leaving
public FwPlayerDisconnect(id)
{
	// Check that we still have both humans and zombies to keep the round going
	if (g_isalive[id]) check_round(id)
	
	// Temporarily save player stats?
	if (SaveStats == 1) SaveStatistics(id)
	
	// Remove previous tasks
	remove_task(id+TASK_TEAM)
	remove_task(id+TASK_MODEL)
	remove_task(id+TASK_FLASH)
	remove_task(id+TASK_CHARGE)
	remove_task(id+TASK_SPAWN)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	remove_task(id+TASK_NVISION)
	remove_task(id+TASK_SHOWHUD)
	
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
	if (BlockSuicide == 1)
	return FMRES_SUPERCEDE
	
	return FMRES_IGNORED
}

// Emit Sound Forward
public FwEmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	// Block all those unneeeded hostage sounds
	if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
	return FMRES_SUPERCEDE
	
	// Replace these next sounds for zombies only
	if (!is_user_valid_connected(id) || !g_zombie[id])
	return FMRES_IGNORED
	
	// Zombie being hit
	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't')
	{
		if (g_nemesis[id])
		{
			emit_sound(id, channel, nemesis_pain[random(sizeof nemesis_pain)], volume, attn, flags, pitch)
		}
		else if (g_assassin[id])
		{
			emit_sound(id, channel, assassin_pain[random(sizeof assassin_pain)], volume, attn, flags, pitch)
		}
		else
		{
			emit_sound(id, channel, zombie_pain[random(sizeof zombie_pain)], volume, attn, flags, pitch)
		}
		return FMRES_SUPERCEDE
	}
	
	// Zombie attacks with knife
	if (sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
	{
		if (sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') // slash
		{
			emit_sound(id, channel, zombie_miss_slash[random(sizeof zombie_miss_slash)], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE
		}
		if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') // hit
		{
			if (sample[17] == 'w') // wall
			{
				emit_sound(id, channel, zombie_miss_wall[random(sizeof zombie_miss_wall)], volume, attn, flags, pitch)
				return FMRES_SUPERCEDE
			}
			else
			{
				emit_sound(id, channel, zombie_hit_normal[random(sizeof zombie_hit_normal)], volume, attn, flags, pitch)
				return FMRES_SUPERCEDE
			}
		}
		if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') // stab
		{
			emit_sound(id, channel, zombie_hit_stab[random(sizeof zombie_hit_stab)], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE
		}
	}
	
	// Zombie dies
	if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
	{
		emit_sound(id, channel, zombie_die[random(sizeof zombie_die)], volume, attn, flags, pitch)
		return FMRES_SUPERCEDE
	}
	
	// Zombie falls off
	if (sample[10] == 'f' && sample[11] == 'a' && sample[12] == 'l' && sample[13] == 'l')
	{
		emit_sound(id, channel, zombie_fall[random(sizeof zombie_fall)], volume, attn, flags, pitch)
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
	get_user_name(id, g_playername[id], charsmax(g_playername[]))
}

// Forward Get Game Description
public FwGetGameDescription()
{
	// Return the mod name so it can be easily identified
	forward_return(FMV_STRING, "Zombie Queen 1.0")
	
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
	new id 
	id = entity_get_edict(entity, EV_ENT_owner)

	switch(model[9])
	{
		case 'h':
		{
			if (g_zombie[id])
			{
				if (g_bombardier[id])
				{
					GrenadeEffect(entity, 128, 0, 255, NADE_TYPE_KILLING)
				}
				else
				{
					GrenadeEffect(entity, 0, 255, 0, NADE_TYPE_INFECTION)
				}
			}
			else
			{
				if (g_killingbomb[id])
				{
					GrenadeEffect(entity, 128, 0, 255, NADE_TYPE_KILLING)

					// Decrease count
					g_killingbomb[id]--
				}
				else if (g_antidotebomb[id])
				{
					GrenadeEffect(entity, 255, 72, 0, NADE_TYPE_ANTIDOTE)

					// Decrease count
					g_antidotebomb[id]--
				}
				else
				{
					GrenadeEffect(entity, 255, 0, 0, NADE_TYPE_EXPLODE)
				}
			}
		}
		case 'f':
		{
			if (g_zombie[id])
			{
				if (g_concussionbomb[id])
				{
					GrenadeEffect(entity, 0, 0, 255, NADE_TYPE_CONCUSSION)

					// Decrease Counb
					g_concussionbomb[id]--
				}
			}
			else
			{
				GrenadeEffect(entity, 255, 255, 0, NADE_TYPE_NAPALM)
			}
		}
		case 's':
		{
			if (g_bubblebomb[id])
			{
				GrenadeEffect(entity, 0, 255, 255, NADE_TYPE_BUBBLE)

				// Decrease Counb
				g_bubblebomb[id]--
			}
			else
			{
				GrenadeEffect(entity, 0, 206, 209, NADE_TYPE_FROST)
			}
		}
	}

	if(equal(model, "models/w_sg550.mdl"))
	{
		static iStoredAugID
		
		iStoredAugID = find_ent_by_owner(-1, "weapon_sg550", entity)
	
		if(!is_valid_ent(iStoredAugID))
			return
	
		if(g_has_crossbow[id])
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
			infection_explode(entity)
			return HAM_SUPERCEDE
		}
	case NADE_TYPE_EXPLODE: // Explosion Grenade
		{
			explosion_explode(entity)
			return HAM_SUPERCEDE
		}
	case NADE_TYPE_NAPALM: // Napalm Grenade
		{
			fire_explode(entity)
			return HAM_SUPERCEDE
		}
	case NADE_TYPE_FROST: // Frost Grenade
		{
			frost_explode(entity)
			return HAM_SUPERCEDE
		}
	case NADE_TYPE_ANTIDOTE: // Antidote Grenade
		{
			antidote_explode(entity)
			return HAM_SUPERCEDE
		}
	case NADE_TYPE_CONCUSSION: // Infection Bomb
		{
			concussion_explode(entity)
			return HAM_SUPERCEDE
		}
	case NADE_TYPE_KILLING: //  Killing grenade and Bombardier's kill bomb
		{
			killing_explode(entity)
			return HAM_SUPERCEDE
		}
	case NADE_TYPE_BUBBLE: // Bubble bomb ( Force Field Grenade )
		{
			bubble_explode(entity)
			return HAM_SUPERCEDE
		}
	}
	
	return HAM_IGNORED
}

GrenadeEffect(const entity, const red, const green, const blue, const nade_type) 
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
			if(g_isalive[victim] && g_zombie[victim] && !g_nodamage[victim])
			{
				static Float: fDistance, Float: fDamage
				fDistance = entity_range(victim, iRocket) * 1.5

				if(fDistance < 320.0)
				{
					fDamage = 1250.0 - fDistance
					
					if(g_nemesis[victim] && g_assassin[victim] && g_bombardier[victim])
					fDamage *= 1.50
				
					static Float: fVelocity[3]
					pev(victim, pev_velocity, fVelocity)
					xs_vec_mul_scalar(fVelocity, 2.75, fVelocity)
					fVelocity[2] *= 1.75
					set_pev(victim, pev_velocity, fVelocity)
				
					if(float(pev(victim, pev_health)) - fDamage > 0.0)
					{
						ExecuteHamB(Ham_TakeDamage, victim, iRocket, attacker, fDamage, DMG_BLAST)
					}
					else 
					{
						ExecuteHamB(Ham_Killed, victim, attacker, 2)
					}
				}
			}
		}
	}
}

public OnKnifeBlinkAttack(entity)
{
	static owner
	owner = pev(entity, pev_owner);
	if (g_zombie[owner] && g_blinks[owner])
	{
		if (get_target_and_attack(owner))
		{
			client_print_color(0, print_team_grey, "%s ^3%s^1 just used a knife blink! (Blinks remaining:^4 %i blinks^1)", CHAT_PREFIX, g_playername[owner], g_blinks[owner])
			g_blinks[owner]--
		}
	}
	return PLUGIN_CONTINUE
}

public OnCrossbowAddToPlayer(Aug, id)
{
	if(!is_valid_ent(Aug) || !g_isconnected[id])
		return HAM_IGNORED
	
	if(entity_get_int(Aug, EV_INT_impulse) == 35481)
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
	if (!pev_valid(id)) return;
	
	if (!g_has_crossbow[id])
		return;
	
	g_IsInPrimaryAttack = 1
	pev(id,pev_punchangle,cl_pushangle[id])
	
	g_clip_ammo[id] = cs_get_weapon_ammo(Weapon)
}

public OnCrossbowPrimaryAttackPost(Weapon)
{
	g_IsInPrimaryAttack = 0

	new id = get_pdata_cbase(Weapon, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
	if (!pev_valid(id)) return;
	
	if(g_has_crossbow[id])
	{
		if (!g_clip_ammo[id])
			return

		set_pdata_float(Weapon, 46, 0.1304, OFFSET_LINUX_WEAPONS)
		set_pdata_float(Weapon, 47, 0.1304, OFFSET_LINUX_WEAPONS)

		new Float:push[3]
		pev(id,pev_punchangle,push)
		xs_vec_sub(push,cl_pushangle[id],push)
		
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

     if (!pev_valid(id))
          return HAM_IGNORED;

     if (!g_has_crossbow[id])
          return HAM_IGNORED;
     
     static iClipExtra

     iClipExtra = CROSSBOW_CLIP
     new Float:flNextAttack = get_pdata_float(id, 83, OFFSET_LINUX)
     new iBpAmmo = cs_get_user_bpammo(id, CSW_SG550)
     new iClip = get_pdata_int(weapon_entity, 51, OFFSET_LINUX_WEAPONS)
     new fInReload = get_pdata_int(weapon_entity, 54, OFFSET_LINUX_WEAPONS) 

     if(fInReload && flNextAttack <= 0.0)
     {
		new j = min(iClipExtra - iClip, iBpAmmo)
	
		set_pdata_int(weapon_entity, 51, iClip + j, OFFSET_LINUX_WEAPONS)
		cs_set_user_bpammo(id, CSW_SG550, iBpAmmo-j)
		
		set_pdata_int(weapon_entity, 54, 0, OFFSET_LINUX_WEAPONS)
		fInReload = 0
     }

     return HAM_IGNORED;
}

public OnCrossbowReload(weapon_entity) 
{
     new id = pev(weapon_entity, pev_owner)

     if (!pev_valid(id))
          return HAM_IGNORED

     if (!g_has_crossbow[id])
          return HAM_IGNORED

     static iClipExtra
     iClipExtra = CROSSBOW_CLIP

     g_crossbow_TmpClip[id] = -1

     new iBpAmmo = cs_get_user_bpammo(id, CSW_SG550)
     new iClip = get_pdata_int(weapon_entity, 51, OFFSET_LINUX_WEAPONS)

     if (iBpAmmo <= 0)
          return HAM_SUPERCEDE

     if (iClip >= iClipExtra)
          return HAM_SUPERCEDE

     g_crossbow_TmpClip[id] = iClip

     return HAM_IGNORED
}

public OnCrossbowReloadPost(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)

	if (!pev_valid(id))
		return HAM_IGNORED;

	if (!g_has_crossbow[id])
		return HAM_IGNORED;

	if (g_crossbow_TmpClip[id] == -1)
		return HAM_IGNORED;

	set_pdata_int(weapon_entity, 51, g_crossbow_TmpClip[id], OFFSET_LINUX_WEAPONS)
	set_pdata_float(weapon_entity, 48, 3.7, OFFSET_LINUX_WEAPONS)
	set_pdata_float(id, 83, 3.7, OFFSET_LINUX)
	set_pdata_int(weapon_entity, 54, 1, OFFSET_LINUX_WEAPONS)

	UTIL_PlayWeaponAnimation(id, 3)

	return HAM_IGNORED;
}

public FwUpdateClientDataPost(Player, SendWeapons, CD_Handle)
{
	if(!is_user_alive(Player) || (get_user_weapon(Player) != CSW_SG550 || !g_has_crossbow[Player]))
		return FMRES_IGNORED
	
	set_cd(CD_Handle, CD_flNextAttack, halflife_time () + 0.001)

	return FMRES_HANDLED
}

public FwPlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if ((eventid != g_orig_event_crossbow) || !g_IsInPrimaryAttack)
		return FMRES_IGNORED

	if (!(1 <= invoker <= g_maxplayers))
    		return FMRES_IGNORED

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
	for (new i = 0; i < num; i++) {
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
	
	// Frozen zombie skill
	//if(g_frozen[id] && !g_zombie[id] && (button & IN_ATTACK || button & IN_ATTACK2))
	//set_uc(handle, UC_Buttons, (button & ~IN_ATTACK) & ~IN_ATTACK2)

	if(g_zombie[id] && (button & IN_USE) && g_zombieclass[id] == 1 && !g_nemesis[id] && !g_assassin[id] && !g_bombardier[id])
	OnRaptorSkill(id)
	
	if(g_zombie[id] && (button & IN_USE) && g_zombieclass[id] == 3 && !g_nemesis[id] && !g_assassin[id] && !g_bombardier[id])
	OnFrozenSkill(id)

	// Predator zombie skill
	if(g_zombie[id] && (button & IN_USE) && g_zombieclass[id] == 5 && !g_nemesis[id] && !g_assassin[id] && !g_bombardier[id])
	OnPredatorSkill(id)

	// Hunter zombie skill
	if(g_zombie[id] && (button & IN_USE) && g_zombieclass[id] == 6 && !g_nemesis[id] && !g_assassin[id] && !g_bombardier[id])
	OnHunterSkill(id)
	
	// This logic looks kinda weird, but it should work in theory...
	// p = g_zombie[id], q = g_survivor[id], r = g_cached_customflash
	// ¬(p v q v (¬p ^ r)) <==> ¬p ^ ¬q ^ (p v ¬r)
	if (!g_zombie[id] && !g_survivor[id] && !g_sniper[id] && !g_samurai[id] && (g_zombie[id] || !g_cached_customflash))		// Abhinash
	return
	
	// Check if it's a flashlight impulse
	if (get_uc(handle, UC_Impulse) != IMPULSE_FLASHLIGHT)
	return
	
	// Block it I say!
	set_uc(handle, UC_Impulse, 0)
	
	// Should human's custom flashlight be turned on?
	if (!g_zombie[id] && !g_survivor[id] && !g_sniper[id] && g_flashbattery[id] > 2 && get_gametime() - g_lastflashtime[id] > 1.2)
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
		remove_task(id+TASK_CHARGE)
		remove_task(id+TASK_FLASH)
		
		// Set the flashlight charge task
		set_task(1.0, "ChargeFlashLight", id+TASK_CHARGE, _, _, "b")
		
		// Call our custom flashlight task if enabled
		if (g_flashlight[id]) 
		{
			switch (random_num(0, 1))
			{
				case 0: set_task(0.1, "set_user_flashlight_1", id+TASK_FLASH, _, _, "b")
				case 1: set_task(0.1, "set_user_flashlight_2", id+TASK_FLASH, _, _, "b")
			}
			
		}
		
	}
}

public OnRaptorSkill(id)
{
	if(!g_isalive[id] || !g_zombie[id] || g_zombieclass[id] != 1 || g_nemesis[id] || g_assassin[id] || g_bombardier[id])
	return PLUGIN_HANDLED
	
	if(get_gametime() - g_lastability[id] < float(frost_cooldown))
	{
		return PLUGIN_HANDLED
	}
	
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
	if(!g_isalive[id] || !g_zombie[id] || g_zombieclass[id] != 3 || g_nemesis[id] || g_assassin[id] || g_bombardier[id])
	return PLUGIN_HANDLED
	
	if(get_gametime() - g_lastability[id] < float(frost_cooldown))
	{
		return PLUGIN_HANDLED
	}
	
	g_lastability[id] = get_gametime()

	static Float:aimorigin[3]
	fm_get_aim_origin(id, aimorigin)	

	new target, body
	get_user_aiming(id, target, body, frost_distance)
	
	if(g_isalive[target] && !g_zombie[target] && !g_sniper[target] && !g_survivor[target] && !g_samurai[target])
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
	ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
	g_frozen[id] = false
}


public OnSkillsCooldownHUD(id)
{
	if(g_isalive[id])
	{
		skillcooldown--
		set_hudmessage(200, 100, 0, 0.75, 0.92, 0, 1.0, 1.1, 0.0, 0.0, -1)
		show_hudmessage(id, "Skill cooldown: %d", skillcooldown)
	}
	else
	{
		remove_task(id)
	}
	if(skillcooldown == 0)
	{
		skillcooldown = 10
	}
}

public OnHunterSkill(id)
{
	if(!g_isalive[id] || !g_zombie[id] || g_zombieclass[id] != 6 || g_nemesis[id] || g_assassin[id] || g_bombardier[id])
	return PLUGIN_HANDLED
	
	if(get_gametime() - g_lastability[id] < float(hunter_cooldown))
	{
		return PLUGIN_HANDLED
	}
	
	g_lastability[id] = get_gametime()

	static Float:aimorigin[3]
	fm_get_aim_origin(id, aimorigin)
	
	new target, body
	get_user_aiming(id, target, body, hunter_distance)
	
	if(g_isalive[target] && !g_zombie[target] && !g_sniper[target] && !g_survivor[target] && !g_samurai[target])
	{
		// Drop target's weapon
		drop_weapons(target, 1)

		// Send BeamPoints
		SendSkillEffect(id, aimorigin, 200, 200, 0)

		// Display SKills cooldown HUD
		set_task(1.0, "OnSkillsCooldownHUD", id, _, _, "a", hunter_cooldown)
	}

	return PLUGIN_HANDLED
}

public OnPredatorSkill(id)
{
	if(!g_isalive[id] || !g_zombie[id] || g_zombieclass[id] != 5 || g_nemesis[id] || g_assassin[id] || g_bombardier[id])
	return PLUGIN_HANDLED
	
	if(get_gametime() - g_lastability[id] < float(predator_cooldown))
	{
		return PLUGIN_HANDLED
	}
	
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
	if (!g_isalive[id])
	return
	
	// Parachute
	static Float:vel[3]
	pev(id, pev_velocity, vel)
	
	if (pev(id, pev_button) & IN_USE && vel[2] < 0.0)
	{
		vel[2] = -100.0
		set_pev(id, pev_velocity, vel)
	}
	
	// Enable custom buyzone for player during buytime, unless zombie or survivor or time expired		// Abhinash
	if (!g_zombie[id] && !g_survivor[id] && !g_sniper[id] && !g_samurai[id] && (get_gametime() < g_buytime[id]))
	{
		if (pev_valid(g_buyzone_ent))
		dllfunc(DLLFunc_Touch, g_buyzone_ent, id)
	}
	
	// Silent footsteps for zombies?
	if (g_cached_zombiesilent && g_zombie[id] && !g_nemesis[id] && g_assassin[id] && !g_bombardier[id])
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
	if (!pev_valid(ent)) 
	return FMRES_IGNORED

	static entclass[32]
	pev(ent, pev_model, entclass, 31)
	
	if(strcmp(entclass, BubbleGrenadeModel) == 0)
	{	
		if(is_user_alive(toucher) && g_zombie[toucher])
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
		if (CustomNightVision == 1)
		{
			remove_task(id+TASK_NVISION)
			if (g_nvisionenabled[id]) set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
		}
		else
		set_user_gnvision(id, g_nvisionenabled[id])
	}
	
	return PLUGIN_HANDLED
}

// Weapon Drop
public clcmd_drop(id)
{
	if (get_user_jetpack(id) && get_user_weapon(id) == CSW_KNIFE)
	user_drop_jetpack(id, 0)

	// Survivor should stick with its weapon
	if (g_survivor[id] || g_sniper[id])
	return PLUGIN_HANDLED

	return PLUGIN_CONTINUE
}

// Block Team Change
public clcmd_changeteam(id)
{
	static team
	team = fm_cs_get_user_team(id)
	
	// Unless it's a spectator joining the game
	if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
	return PLUGIN_CONTINUE
	
	// Pressing 'M' (chooseteam) ingame should show the main menu instead
	menu_display(id, g_iGameMenu, 0)
	return PLUGIN_HANDLED
}

// Say funtion
public Client_Say(id)
{
	if (!g_isconnected[id])
	{
		return PLUGIN_HANDLED
	}
	static Float:fGameTime
	fGameTime = get_gametime()
	if (g_fGagTime[id] > fGameTime)
	{
		client_print_color(id, print_team_grey,  "%s You are gagged due to your bad behaviour, please wait until your time is up", CHAT_PREFIX)
		return PLUGIN_HANDLED
	}

	static cMessage[150]
	read_args(cMessage, 149)
	remove_quotes(cMessage)
	if (!cMessage[0] || strlen(cMessage) > 147)
	{
		return PLUGIN_HANDLED
	}
	if (cMessage[0] == '@' && g_bAdmin[id])
	{
		static g_iMessagePosition
		static Float:fVertical
		static red, green, blue
		static i

		g_iMessagePosition += 1;
		if (g_iMessagePosition > 3)
		{
			g_iMessagePosition = 0
		}
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
				ShowSyncHudMsg(i, g_MsgSync5[g_iMessagePosition], "%s :  %s", g_playername[id], cMessage[1])
			}
			i += 1
		}
		return PLUGIN_HANDLED
	}

	if (equali(cMessage, "/nextmap", 0) || equali(cMessage, "nextmap", 0))
	{
		static cMap[32]
		get_cvar_string("amx_nextmap", cMap, 32)
		if (cMap[0])
		{
			client_print_color(id, print_team_grey, "^1Next map:^4 %s", cMap)
		}
		else
		{
			client_print_color(id, print_team_grey, "^1Next map:^4 [not yet voted on]")
		}
	}
	if (equali(cMessage, "/rank", 5) || equali(cMessage, "rank", 4))
	{
		new szTemp[512]
		new Data[1]
		Data[0] = id
		format(szTemp,charsmax(szTemp),"SELECT DISTINCT `score` FROM `perfectzm` WHERE `score` >= %d ORDER BY `score` ASC", g_score[id])
	    SQL_ThreadQuery(g_SqlTuple, "Sql_Rank", szTemp, Data, 1)
	}
	else if (equali(cMessage, "/top", 4) || equali(cMessage, "top", 3))
	{
		new szTemp[512]
		new Data[1]
		Data[0] = id
		format(szTemp, charsmax(szTemp), "SELECT `name`, `points`, `kills`, `deaths`, `score` FROM `perfectzm` ORDER BY `score` DESC LIMIT 15")
		SQL_ThreadQuery(g_SqlTuple, "TopFunction", szTemp, Data, 1)
	}
	else if (equali(cMessage, "/rs", 3) || equali(cMessage, "rs", 2) || equali(cMessage, "/resetscore", 11) || equali(cMessage, "resetscore", 10))
	{
		cs_set_user_deaths(id, 0)
		set_user_frags(id, 0)

		cs_set_user_deaths(id, 0)
		set_user_frags(id, 0)

		client_print_color(0, print_team_grey, "%s ^3%s ^1reset his score to^3 0", CHAT_PREFIX, g_playername[id])
	}
	else if (equali(cMessage, "/spec", 5) || equali(cMessage, "spec", 4) || equali(cMessage, "/spectate", 9) || equali(cMessage, "spectate", 8))
	{
		if (!g_zombie[id] && !g_sniper[id] && !g_survivor[id] && !g_samurai[id] && !g_nemesis[id] && !g_assassin[id] && !g_bombardier[id])
		{
			if(cs_get_user_team(id) != CS_TEAM_SPECTATOR)
			{
			    cs_set_user_team(id, CS_TEAM_SPECTATOR)
			    user_kill(id)
			}
			else
			{
				client_print_color(id, print_team_grey, "%s You are already a spectator", CHAT_PREFIX);
			}
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
	    	else
	    	{
	    		cs_set_user_team(id, CS_TEAM_CT)
	    	}  
	    }
	    else
	    {
	    	client_print_color(id, print_team_grey, "%s You are not a spectator", CHAT_PREFIX)
	    }
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
		client_print_color(0, print_team_grey, "%s^3 %s^1 gave^4 %s packs^1 to^3 %s", CHAT_PREFIX, g_playername[id], AddCommas(ammo), g_playername[target])
		return PLUGIN_CONTINUE
	}
	else if (equali(cMessage, "/help", 5) || equali(cMessage, "help", 4))
	{
		show_motd(id, "http://perfectzm0.000webhostapp.com/main.html", "Welcome")
	}
	else if (equali(cMessage, "/commands", 9) || equali(cMessage, "commands", 8))
	{
		show_motd(id, "http://perfectzm0.000webhostapp.com/commands.html", "Commands")
	}
	else if (equali(cMessage, "/gold", 5) || equali(cMessage, "/vip", 4) || equali(cMessage, "/gold", 5))
	{
		show_motd(id, "http://perfectzm0.000webhostapp.com/privileges.html", "Privileges")
	}
	else if (equali(cMessage, "/rules", 6) || equali(cMessage, "rules", 5))
	{
		show_motd(id, "http://perfectzm0.000webhostapp.com/rules.html", "Welcome")
	}
	return PLUGIN_CONTINUE
}

// Say Team function
public Client_SayTeam(id)
{
	if (!g_isconnected[id])
	{
		client_print_color(id, print_team_grey,  "%s You are gagged due to your bad behaviour, please wait until your time is up", CHAT_PREFIX)
		return PLUGIN_HANDLED
	}
	static Float:fGameTime
	fGameTime = get_gametime()
	if (g_fGagTime[id] > fGameTime)
	{
		return PLUGIN_HANDLED
	}

	static cMessage[150]
	read_args(cMessage, 149)
	remove_quotes(cMessage)
	if (!cMessage[0] || strlen(cMessage) > 147)
	{
		return PLUGIN_HANDLED
	}
	if (cMessage[0] == '@')
	{
		if (g_bAdmin[id] && g_bVip[id])
		{
			static i
			i = 1
			while (g_maxplayers + 1 > i)
			{
				if (g_isconnected[i] && g_bAdmin[i] && AdminHasFlag(i, 'a'))
				{
					client_print_color(i, print_team_grey, "^4[VIP]^3 %s^1 :  %s", g_playername[id], cMessage[1])
				}
				i += 1
			}
		}
		else if (g_bAdmin[id] && !g_bVip[id])
		{
			static i
			i = 1
			while (g_maxplayers + 1 > i)
			{
				if (g_isconnected[i] && g_bAdmin[i] && AdminHasFlag(i, 'a'))
				{
					client_print_color(i, print_team_grey, "^4[ADMINS]^3 %s^1 :  %s", g_playername[id], cMessage[1])
				}
				i += 1
			}
		}
		else
		{
			static i
			i = 1
			while (g_maxplayers + 1 > i)
			{
				if (g_isconnected[i] && (g_bAdmin[i] || id != i))
				{
					client_print_color(i, print_team_grey, "^3(PLAYER) %s^1 :  %s", g_playername[id], cMessage[1])
				}
				i += 1
			}
		}
		return PLUGIN_HANDLED
	}
	if (equali(cMessage, "/rank", 5) || equali(cMessage, "rank", 4))
	{
		new szTemp[512]
		new Data[1]
		Data[0] = id
		format(szTemp,charsmax(szTemp),"SELECT DISTINCT `score` FROM `perfectzm` WHERE `score` >= %d ORDER BY `score` ASC", g_score[id])
	    SQL_ThreadQuery(g_SqlTuple, "Sql_Rank", szTemp, Data, 1)
	}
	else if (equali(cMessage, "/top", 4) || equali(cMessage, "top", 3))
	{
		new szTemp[512]
		new Data[1]
		Data[0] = id
		format(szTemp, charsmax(szTemp), "SELECT `name`, `points`, `kills`, `deaths`, `score` FROM `perfectzm` ORDER BY `score` DESC LIMIT 15")
		SQL_ThreadQuery(g_SqlTuple, "TopFunction", szTemp, Data, 1)
	}
	else if (equali(cMessage, "/rs", 3) || equali(cMessage, "rs", 2) || equali(cMessage, "/resetscore", 11) || equali(cMessage, "resetscore", 10))
	{
		cs_set_user_deaths(id, 0)
		set_user_frags(id, 0)

		cs_set_user_deaths(id, 0)
		set_user_frags(id, 0)

		client_print_color(0, print_team_grey, "%s ^3%s ^1reset his score to 0", CHAT_PREFIX, g_playername[id])
	}
	else if (equali(cMessage, "/spec", 5) || equali(cMessage, "spec", 4) || equali(cMessage, "/spectate", 9) || equali(cMessage, "spectate", 8))
	{
		if (!g_zombie[id] && !g_sniper[id] && !g_survivor[id] && !g_samurai[id] && !g_nemesis[id] && !g_assassin[id] && !g_bombardier[id])
		{
			if(cs_get_user_team(id) != CS_TEAM_SPECTATOR)
			{
			    cs_set_user_team(id, CS_TEAM_SPECTATOR)
			    user_kill(id)
			}
			else
			{
				client_print_color(id, print_team_grey, "%s You are already a spectator", CHAT_PREFIX);
			}
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
	    	else
	    	{
	    		cs_set_user_team(id, CS_TEAM_CT)
	    	}  
	    }
	    else
	    {
	    	client_print_color(id, print_team_grey, "%s You are not a spectator", CHAT_PREFIX)
	    }
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
		client_print_color(0, print_team_grey, "%s^3 %s^1 gave^4 %s packs^1 to^3 %s", CHAT_PREFIX, g_playername[id], AddCommas(ammo), g_playername[target])
		return PLUGIN_CONTINUE
	}
	else if (equali(cMessage, "/help", 5) || equali(cMessage, "help", 4))
	{
		show_motd(id, "http://perfectzm0.000webhostapp.com/main.html", "Welcome")
	}
	else if (equali(cMessage, "/commands", 9) || equali(cMessage, "commands", 8))
	{
		show_motd(id, "http://perfectzm0.000webhostapp.com/commands.html", "Commands")
	}
	else if (equali(cMessage, "/gold", 5) || equali(cMessage, "/vip", 4) || equali(cMessage, "/gold", 5))
	{
		show_motd(id, "http://perfectzm0.000webhostapp.com/privileges.html", "Privileges")
	}
	else if (equali(cMessage, "/rules", 6) || equali(cMessage, "rules", 5))
	{
		show_motd(id, "http://perfectzm0.000webhostapp.com/rules.html", "Welcome")
	}
	return PLUGIN_CONTINUE
}

public Admin_menu(id)
{
	if (g_bAdmin[id] && AdminHasFlag(id, 'a'))
	{
		show_menu_admin(id)
	}
	else
	{
		return PLUGIN_HANDLED
	}
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
	if (taskid > g_maxplayers)
	{
		id = taskid - TASK_SPAWN
	}
	else
	{
		id = taskid
	}
	
	// Zombies, Survivors and Snipers get no guns.
	if (!g_isalive[id] || g_zombie[id] || g_survivor[id] || g_sniper[id] || g_samurai[id])
	return
	
	// Bots get weapons randomly.
	if (g_isbot[id])
	{
		set_weapon(id, CSW_KNIFE)
		//set_weapon(id, CSW_DEAGLE)
	}
	
	menu_display(id, g_PrimaryMenu)
}

// Admin Menu
show_menu_admin(id)
{
	// Player disconnected?
	if (!g_isconnected[id])
	return
	
	static menu[250], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\yAdmin menu^n^n")
	
	// 1. Admin menu of classes command
	if (AdminHasFlag(id, 'a'))
	len += formatex(menu[len], charsmax(menu) - len, "\r1. \wChange class^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d1. Change class^n")
	
	// 2. Admin Respawn menu
	if (AdminHasFlag(id, 'a'))
	len += formatex(menu[len], charsmax(menu) - len, "\r2. \wRespawn someone^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d2. Respawn someone^n")
	
	// 3. Admin modes menu
	if (AdminHasFlag(id, 'a'))
	len += formatex(menu[len], charsmax(menu) - len, "\r3. \wStart modes^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d3. Start modes^n")
	
	// 4. Admin custom modes menu
	if (AdminHasFlag(id, 'a'))
	len += formatex(menu[len], charsmax(menu) - len, "\r4. \wStart custom modes^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d4. Start custom modes^n")
	
	// 5. Admin Turn off Zombie Plague menu
	if (AdminHasFlag(id, 'a'))
	len += formatex(menu[len], charsmax(menu) - len, "\r5. \wTurn off Zombie Queen^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d5. Turn off Zombie Queen^n")
	
	// 0. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0. \wExit")
	
	show_menu(id, KEYS_ADMINMENU, menu, -1, "Admin Menu")
}

// Admin classes menu
show_menu_admin_classes(id)
{
	// Player disconnected?
	if (!g_isconnected[id])
	return
	
	static menu[250], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\yAdmin Menu^n^n")
	
	// 1. Zombiefy/Humanize command
	if (AdminHasFlag(id, 'a'))
	len += formatex(menu[len], charsmax(menu) - len, "\r1. \wMake Zombie/Human^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d1. Make Zombie/Human^n")
	
	// 2. Nemesis command
	if (AdminHasFlag(id, 'a'))
	len += formatex(menu[len], charsmax(menu) - len, "\r2. \wMake Nemesis^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d2. Make Nemesis^n")
	
	// 3. Assassin command
	if (AdminHasFlag(id, 'a'))
	len += formatex(menu[len], charsmax(menu) - len, "\r3. \wMake Assassin^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d3. Make Assassin^n")
	
	// 4. Assassin command
	if (AdminHasFlag(id, 'a'))
	len += formatex(menu[len], charsmax(menu) - len, "\r4. \wMake Bombardier^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d4. Make Bombardier^n")
	
	// 5. Survivor command
	if (AdminHasFlag(id, 'a'))
	len += formatex(menu[len], charsmax(menu) - len, "\r5. \wMake Survivor^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d5. Make Survivor^n")
	
	// 6. Sniper command
	if (AdminHasFlag(id, 'a'))
	len += formatex(menu[len], charsmax(menu) - len, "\r6. \wMake Sniper^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d6. Make Sniper^n")
	
	// 7. samurai command			// Abhinash
	if (AdminHasFlag(id, 'a'))
	len += formatex(menu[len], charsmax(menu) - len, "\r7. \wMake Samurai^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d7. Make Samurai^n")
	
	// 0. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0. \wExit")
	
	show_menu(id, KEYS_ADMINMENUCLASSES, menu, -1, "Admin Classes Menu")
}
// Admin Modes Menu
show_menu_modes_admin(id)
{
	static menu[250], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\yAdmin Modes Menu^n^n")
	
	// 1. Swarm mode command
	if ((AdminHasFlag(id, 'a')) && allowed_swarm())
	len += formatex(menu[len], charsmax(menu) - len, "\r1. \wStart Swarm Mode^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d1. Start Swarm Mode^n")
	
	// 2. Multi infection command
	if ((AdminHasFlag(id, 'a')) && allowed_multi())
	len += formatex(menu[len], charsmax(menu) - len, "\r2. \wStart Multiple Infection^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d2. Start Multiple Infection^n")
	
	// 3. Plague mode command
	if ((AdminHasFlag(id, 'a')) && allowed_plague())
	len += formatex(menu[len], charsmax(menu) - len, "\r3. \wStart Plague Mode^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d3. Start Plague Mode^n")
	
	// 0. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0. \wExit")
	
	show_menu(id, KEYS_ADMINMENUMODES, menu, -1, "Admin Modes Menu")
}

// Admin custom modes menu
show_menu_admin_custom_modes(id)
{
	static menu[250], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\yStart custom mode^n^n")
	
	// 1. Armageddon mode command
	if ((AdminHasFlag(id, 'a')) && allowed_armageddon())
	len += formatex(menu[len], charsmax(menu) - len, "\r1. \wArmageddon^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d1. Armageddon^n")
	
	// 2. Apocalypse mode command
	if ((AdminHasFlag(id, 'a')) && allowed_apocalypse())
	len += formatex(menu[len], charsmax(menu) - len, "\r2. \wApocalypse^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d2. Apocalypse^n")
	
	// 3. Nightmare mode command
	if ((AdminHasFlag(id, 'a')) && allowed_nightmare())
	len += formatex(menu[len], charsmax(menu) - len, "\r3. \wNightmare^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d3. Nightmare^n")
	
	// 4. Devil mode command ( Sniper vs Nemesis) 	// Abhinash
	if ((AdminHasFlag(id, 'a')) && allowed_devil())
	len += formatex(menu[len], charsmax(menu) - len, "\r4. \wSniper vs Nemesis^n")
	else
	len += formatex(menu[len], charsmax(menu) - len, "\d4. Sniper vs Nemesis^n")
	
	// 0. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0. \wExit")
	
	show_menu(id, KEYS_ADMINCUSTOMMODES, menu, -1, "Admin Custom Modes Menu")
}

// Player List Menu
show_menu_player_list(id)
{
	static menuid, menu[128], player, buffer[2]
	
	// Title
	switch (PL_ACTION)
	{
		case ACTION_ZOMBIEFY_HUMANIZE: formatex(menu, charsmax(menu), "Make Zombie / Human\r")
		case ACTION_MAKE_NEMESIS: formatex(menu, charsmax(menu), "Make Nemesis\r")
		case ACTION_MAKE_ASSASSIN: formatex(menu, charsmax(menu), "Make Assassin\r")
		case ACTION_MAKE_BOMBARDIER: formatex(menu, charsmax(menu), "Make Bombardier\r")		// Abhinash
		case ACTION_MAKE_SURVIVOR: formatex(menu, charsmax(menu), "Make Survivor\r")
		case ACTION_MAKE_SNIPER: formatex(menu, charsmax(menu), "Make Sniper\r")
		case ACTION_MAKE_SAMURAI: formatex(menu, charsmax(menu), "Make Samurai\r")		// Abhinash
		case ACTION_RESPAWN_PLAYER: formatex(menu, charsmax(menu), "Respawn Someone\r")
	}
	menuid = menu_create(menu, "menu_player_list")
	
	// Player List
	for (player = 0; player <= g_maxplayers; player++)
	{
		// Skip if not connected
		if (!g_isconnected[player])
		continue
		
		// Format text depending on the action to take
		switch (PL_ACTION)
		{
		case ACTION_ZOMBIEFY_HUMANIZE: // Zombiefy/Humanize command
			{
				if (g_zombie[player])
				{
					if (allowed_human(player) && AdminHasFlag(id, 'a'))
					{
						formatex(menu, charsmax(menu), "%s \r[ %s ]", g_playername[player], g_cClass[player])
					}
					else
					{
						formatex(menu, charsmax(menu), "\d%s [ %s ]", g_playername[player], g_cClass[player])
					}
				}
				else
				{
					if (allowed_zombie(player) && AdminHasFlag(id, 'a'))
					{
						formatex(menu, charsmax(menu), "%s \r[ %s ]", g_playername[player], g_cClass[player])
					}
					else
					{
						formatex(menu, charsmax(menu), "\d%s [ %s ]", g_playername[player], g_cClass[player])
					}
				}
			}
		case ACTION_MAKE_NEMESIS: // Nemesis command
			{
				if (allowed_nemesis(player) && AdminHasFlag(id, 'a'))
				{
					formatex(menu, charsmax(menu), "%s \r[ %s ]", g_playername[player], g_cClass[player])
				}
				else
				{
					formatex(menu, charsmax(menu), "\d%s [ %s ]", g_playername[player], g_cClass[player])
				}
			}
		case ACTION_MAKE_ASSASSIN: // Assassin command
			{
				if (allowed_assassin(player) && AdminHasFlag(id, 'a'))
				{
					formatex(menu, charsmax(menu), "%s \r[ %s ]", g_playername[player], g_cClass[player])
				}
				else
				{
					formatex(menu, charsmax(menu), "\d%s [ %s ]", g_playername[player], g_cClass[player])
				}
			}
		case ACTION_MAKE_BOMBARDIER: // Assassin command
			{
				if (allowed_bombardier(player) && AdminHasFlag(id, 'a'))
				{
					formatex(menu, charsmax(menu), "%s \r[ %s ]", g_playername[player], g_cClass[player])
				}
				else
				{
					formatex(menu, charsmax(menu), "\d%s [ %s ]", g_playername[player], g_cClass[player])
				}
			}
		case ACTION_MAKE_SURVIVOR: // Survivor command
			{
				if (allowed_survivor(player) && AdminHasFlag(id, 'a'))
				{
					formatex(menu, charsmax(menu), "%s \r[ %s ]", g_playername[player], g_cClass[player])
				}
				else
				{
					formatex(menu, charsmax(menu), "\d%s [ %s ]", g_playername[player], g_cClass[player])
				}
			}
		case ACTION_MAKE_SNIPER: // Sniper command
			{
				if (allowed_sniper(player) && AdminHasFlag(id, 'a'))
				{
					formatex(menu, charsmax(menu), "%s \r[ %s ]", g_playername[player], g_cClass[player])
				}
				else
				{
					formatex(menu, charsmax(menu), "\d%s [ %s ]", g_playername[player], g_cClass[player])
				}
			}			
			// Abhinash
		case ACTION_MAKE_SAMURAI: // Samurai command
			{
				if (allowed_samurai(player) && AdminHasFlag(id, 'a'))
				{
					formatex(menu, charsmax(menu), "%s \r[ %s ]", g_playername[player], g_cClass[player])
				}
				else
				{
					formatex(menu, charsmax(menu), "\d%s [ %s ]", g_playername[player], g_cClass[player])
				}
			}			
		case ACTION_RESPAWN_PLAYER: // Respawn command
			{
				if (allowed_respawn(player) && AdminHasFlag(id, 'a'))
				formatex(menu, charsmax(menu), "%s", g_playername[player])
				else
				formatex(menu, charsmax(menu), "\d%s", g_playername[player])
			}
		}
		
		// Add player
		buffer[0] = player
		buffer[1] = 0
		menu_additem(menuid, menu, buffer)
	}
	
	// Back - More - Exit
	formatex(menu, charsmax(menu), "Back")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "More")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "Exit")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	menu_display(id, menuid)
}

/*================================================================================
	[Menu Handlers]
=================================================================================*/
// Buy Menu 1
public SecondaryHandler(id, menu, item)
{
	if (item == MENU_EXIT)
	return PLUGIN_HANDLED
	
	// Zombies, Survivors and Snipers get no guns.
	if(!g_isalive[id] || g_zombie[id] || g_survivor[id] || g_sniper[id] || g_samurai[id])
	{
		return PLUGIN_HANDLED
	}
	
	// Drop Previous Weapons
	drop_weapons(id, 2)
	g_canbuy[id] = false
	
	// Set weapon and ammo
	//fm_give_item(id, g_SecondaryWeapons[item][weaponID])
	//cs_set_user_bpammo(id, g_SecondaryWeapons[item][weaponCSW], 99999)
	set_weapon(id, g_SecondaryWeapons[item][weaponCSW], 10000)

	// Set grenades
	set_weapon(id, CSW_HEGRENADE, 1)
	set_weapon(id, CSW_FLASHBANG, 1)
	set_weapon(id, CSW_SMOKEGRENADE, 1)
	
	return PLUGIN_HANDLED
}

// Buy Menu 2
public PrimaryHandler(id, menu, item)
{
	if (item == MENU_EXIT)
	return PLUGIN_HANDLED
	
	// Zombies, Survivors and Snipers get no guns.
	if(!g_isalive[id] || g_zombie[id] || g_survivor[id] || g_sniper[id] || g_samurai[id])
	{
		return PLUGIN_HANDLED
	}
	
	// Drop previous weapons
	drop_weapons(id, 1)
	
	set_weapon(id, g_PrimaryWeapons[item][weaponCSW], 10000)

	menu_display(id, g_SecondaryMenu)
	
	return PLUGIN_HANDLED
}

// Admin Menu
public menu_admin(id, key)
{
	switch (key)
	{
	case 0: // Admin classes menu
		{
			// Check if player has the required access
			if (AdminHasFlag(id, 'a'))
			show_menu_admin_classes(id)
			else
			client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
		}
	case 1: // Admin respawn menu
		{
			// Check if player has the required access
			if (AdminHasFlag(id, 'a'))
			{
				PL_ACTION = ACTION_RESPAWN_PLAYER
				show_menu_player_list(id)
			}
			else
			{
				client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
			}
		}
	case 2: // Admin modes menu
		{
			// Check if player has the required access
			if (AdminHasFlag(id, 'a'))
			show_menu_modes_admin(id)
			else
			client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
		}
	case 3: // Admin custom modes menu
		{
			// Check if player has the required access
			if (AdminHasFlag(id, 'a'))
			show_menu_admin_custom_modes(id)
			else
			client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
		}
	}
	return PLUGIN_HANDLED
}

// Admin classes menu
public menu_admin_classes(id, key)
{	
	switch (key)
	{
	case ACTION_ZOMBIEFY_HUMANIZE: // Zombiefy/Humanize command
		{
			if (AdminHasFlag(id, 'a'))
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_ZOMBIEFY_HUMANIZE
				show_menu_player_list(id)
			}
			else
			{
				client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
				show_menu_admin_classes(id)
			}
		}
	case ACTION_MAKE_NEMESIS: // Nemesis command
		{
			if (AdminHasFlag(id, 'a'))
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_MAKE_NEMESIS
				show_menu_player_list(id)
			}
			else
			{
				client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
				show_menu_admin_classes(id)
			}
		}
	case ACTION_MAKE_ASSASSIN: // Assassin command
		{
			if (AdminHasFlag(id, 'a'))
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_MAKE_ASSASSIN
				show_menu_player_list(id)
			}
			else
			{
				client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
				show_menu_admin_classes(id)
			}
		}
	case ACTION_MAKE_BOMBARDIER: // Assassin command
		{
			if (AdminHasFlag(id, 'a'))
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_MAKE_BOMBARDIER
				show_menu_player_list(id)
			}
			else
			{
				client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
				show_menu_admin_classes(id)
			}
		}
	case ACTION_MAKE_SURVIVOR: // Survivor command
		{
			if (AdminHasFlag(id, 'a'))
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_MAKE_SURVIVOR
				show_menu_player_list(id)
			}
			else
			{
				client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
				show_menu_admin_classes(id)
			}
		}
	case ACTION_MAKE_SNIPER: // Sniper command
		{
			if (AdminHasFlag(id, 'a'))
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_MAKE_SNIPER
				show_menu_player_list(id)
			}
			else
			{
				client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
				show_menu_admin_classes(id)
			}
		}
	case ACTION_MAKE_SAMURAI: // Samurai command
		{
			if (AdminHasFlag(id, 'a'))
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_MAKE_SAMURAI
				show_menu_player_list(id)
			}
			else
			{
				client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
				show_menu_admin_classes(id)
			}
		}
	case 9: // Chose to return
		{
			show_menu_admin(id)
		}
	}
	return PLUGIN_HANDLED
}

// Admin Modes Menu
public menu_admin_modes(id, key)
{
	switch (key)
	{		
	case ACTION_MODE_SWARM: // Swarm Mode command
		{
			if (AdminHasFlag(id, 'a'))
			{
				if (allowed_swarm())
				{
					// Start Swarm Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(swarm, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Swarm ^1round!", CHAT_PREFIX, g_playername[id])

					// Log to file
					LogToFile(id, 0, swarm)
				}
				else
				client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else
			client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
			
			show_menu_modes_admin(id)
		}
	case ACTION_MODE_MULTI: // Multiple Infection command
		{
			if (AdminHasFlag(id, 'a'))
			{
				if (allowed_multi())
				{
					// Start Multi-infection Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(multi, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Multiple-infection ^1round!", CHAT_PREFIX, g_playername[id])

					// Log to file
					LogToFile(id, 0, multi)
				}
				else
				client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else
			client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
			
			show_menu_modes_admin(id)
		}
	case ACTION_MODE_PLAGUE: // Plague Mode command
		{
			if (AdminHasFlag(id, 'a'))
			{
				if (allowed_plague())
				{
					// Start Plague Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(plague, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Plague ^1round!", CHAT_PREFIX, g_playername[id])

					// Log to file
					LogToFile(id, 0, plague)
				}
				else
				client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else
			client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
			
			show_menu_modes_admin(id)
		}
	case 9: // Chose to return
		{
			show_menu_admin(id)
		}
	}
	
	return PLUGIN_HANDLED
}

// Admin Custom Modes Menu
public menu_admin_custom_modes(id, key)
{
	switch (key)
	{		
	case ACTION_MODE_ARMAGEDDON: // Armageddon Mode command
		{
			if (AdminHasFlag(id, 'a'))
			{
				if (allowed_armageddon())
				{
					// Start Armageddon Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(armageddon, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Armageddon ^1round!", CHAT_PREFIX, g_playername[id])

					// Log to file
					LogToFile(id, 0, armageddon)
				}
				else
				client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else
			client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)

			show_menu_admin_custom_modes(id)
		}
	case ACTION_MODE_APOCALYPSE: // Apocalypse Mode command
		{
			if (AdminHasFlag(id, 'a'))
			{
				if (allowed_apocalypse())
				{
					// Start Apocalypse Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(apocalypse, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Sniper vs Assassin ^1round!", CHAT_PREFIX, g_playername[id])

					// Log to file
					LogToFile(id, 0, apocalypse)
				}
				else
				client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else
			client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
			
			show_menu_admin_custom_modes(id)
		}
	case ACTION_MODE_NIGHTMARE: // Nightmare Mode command
		{
			if (AdminHasFlag(id, 'a'))
			{
				if (allowed_nightmare())
				{
					// Start Nightmare Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(nightmare, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Nightmare ^1round!", CHAT_PREFIX, g_playername[id])

					// Log to file
					LogToFile(id, 0, nightmare)
				}
				else
				client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else
			client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
			
			show_menu_admin_custom_modes(id)
		}
	case ACTION_MODE_DEVIL: // Devil Mode command ( Sniper vs Nemesis)
		{
			if (AdminHasFlag(id, 'a'))
			{
				if (allowed_devil())
				{
					// Start Devil Mode
					remove_task(TASK_MAKEZOMBIE)
					start_mode(devil, 0)

					// Print to chat
					client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Sniper v Nemesis ^1round!", CHAT_PREFIX, g_playername[id])

					// Log to file
					LogToFile(id, 0, devil)
				}
				else
				client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
			}
			else
			client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
			
			show_menu_admin_custom_modes(id)
		}
	case 9: // Chose to return
		{
			show_menu_admin(id)
		}
	}
	
	return PLUGIN_HANDLED
}

// Player List Menu
public menu_player_list(id, menuid, item)
{
	// Player disconnected?
	if (!is_user_connected(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED
	}
	
	// Menu was closed
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		show_menu_admin(id)
		return PLUGIN_HANDLED
	}
	
	// Retrieve player id
	static buffer[2], dummy, target
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	target = buffer[0]
	
	// Perform action on player
	
	// Make sure it's still connected
	if (g_isconnected[target])
	{
		// Perform the right action if allowed
		switch (PL_ACTION)
		{
		case ACTION_ZOMBIEFY_HUMANIZE: // Zombiefy/Humanize command
			{
				if (g_zombie[target])
				{
					if (AdminHasFlag(id, 'a'))
					{
						if (allowed_human(target))
						{
							// Just cure
							humanme(target, none)
			
							// Print in chat
							if (id == target)
							{
								client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Human^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
							}
							else
							client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1 a ^4Human^1.", CHAT_PREFIX, g_playername[id], g_playername[target])

							// Log to file
							LogToFile(id, target, human)
						}
						else
						client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
					}
					else
					client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
				}
				else
				{
					if (AdminHasFlag(id, 'a'))
					{
						if (allowed_zombie(target))
						{
							// New round?
							if (g_newround)
							{
								// Set as first zombie
								remove_task(TASK_MAKEZOMBIE)
								start_mode(infection, target)
							}
							else
							{
								// Just infect
								zombieme(target, 0, none)
							}
			
							// Print in chat
							if (id == target)
							{
								client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Zombie^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
							}
							else
							client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1 a ^4Zombie^1.", CHAT_PREFIX, g_playername[id], g_playername[target])

							// Log to file
							LogToFile(id, target, zombie)
						}
						else
						client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
					}
					else
					client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
				}
			}
		case ACTION_MAKE_NEMESIS: // Nemesis command
			{
				if (AdminHasFlag(id, 'a'))
				{
					if (allowed_nemesis(target))
					{
						// New round?
						if (g_newround)
						{
							// Set as first nemesis
							remove_task(TASK_MAKEZOMBIE)
							start_mode(nemesis, target)
						}
						else
						{
							// Turn player into a Nemesis
							zombieme(target, 0, nemesis)
						}
						
						// Print in chat
						if (id == target)
						{
							client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Nemesis^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
						}
						else
						client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1 a ^4Nemesis^1.", CHAT_PREFIX, g_playername[id], g_playername[target])

						// Log to file
						LogToFile(id, target, nemesis)
					}
					else
					client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
				}
				else
				client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
			}
		case ACTION_MAKE_ASSASSIN: // Assassin command
			{
				if (AdminHasFlag(id, 'a'))
				{
					if (allowed_assassin(target))
					{
						// New round?
						if (g_newround)
						{
							// Set as first Assassin
							remove_task(TASK_MAKEZOMBIE)
							start_mode(assassin, target)
						}
						else
						{
							// Turn player into a Nemesis
							zombieme(target, 0, assassin)
						}
						
						// Print in chat
						if (id == target)
						{
							client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Assassin^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
						}
						else
						client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Assassin^1.", CHAT_PREFIX, g_playername[id], g_playername[target])

						// Log to file
						LogToFile(id, target, assassin)
					}
					else
					client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
				}
				else
				client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
			}
		case ACTION_MAKE_BOMBARDIER: // bombardier command
			{
				if (AdminHasFlag(id, 'a'))
				{
					if (allowed_bombardier(target))
					{
						// New round?
						if (g_newround)
						{
							// Set as first nemesis
							remove_task(TASK_MAKEZOMBIE)
							start_mode(bombardier, target)
						}
						else
						{
							// Turn player into a Bombardier
							zombieme(target, 0, bombardier)
						}
						
						// Print in chat
						if (id == target)
						{
							client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Bombardier^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
						}
						else
						client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Bombardier^1.", CHAT_PREFIX, g_playername[id], g_playername[target])

						// Log to file
						LogToFile(id, target, bombardier)
					}
					else
					client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
				}
				else
				client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
			}
		case ACTION_MAKE_SURVIVOR: // Survivor command
			{
				if (AdminHasFlag(id, 'a'))
				{
					if (allowed_survivor(target))
					{
						// New round?
						if (g_newround)
						{
							// Set as first 
							remove_task(TASK_MAKEZOMBIE)
							start_mode(survivor, target)
						}
						else
						{
							// Turn player into a Survivor
							humanme(target, survivor)
						}
						
						// Print in chat
						if (id == target)
						{
							client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himslef a ^4Survivor^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
						}
						else
						client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Survivor^1.", CHAT_PREFIX, g_playername[id], g_playername[target])

						// Log to file
						LogToFile(id, target, survivor)
					}
					else
					client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
				}
				else
				client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
			}
		case ACTION_MAKE_SNIPER: // Sniper command
			{
				if (AdminHasFlag(id, 'a'))
				{
					if (allowed_sniper(target))
					{
						// New round?
						if (g_newround)
						{
							// Set as first 
							remove_task(TASK_MAKEZOMBIE)
							start_mode(sniper, target)
						}
						else
						{
							// Turn player into a Sniper
							humanme(target, sniper)
						}
						
						// Print in chat
						if (id == target)
						{
							client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Sniper^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
						}
						else
						client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Sniper^1.", CHAT_PREFIX, g_playername[id], g_playername[target])

						// Log to file
						LogToFile(id, target, sniper)
					}
					else
					client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
				}
				else
				client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
			}
		case ACTION_MAKE_SAMURAI: // Samurai command
			{
				if (AdminHasFlag(id, 'a'))
				{
					if (allowed_samurai(target))
					{
						// New round?
						if (g_newround)
						{
							// Set as first 
							remove_task(TASK_MAKEZOMBIE)
							start_mode(samurai, target)
						}
						else
						{
							// Turn player into a Samurai
							humanme(target, samurai)
						}
						
						// Print in chat
						if (id == target)
						{
							client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made himself a ^4Samurai^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
						}
						else
						client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Samurai^1.", CHAT_PREFIX, g_playername[id], g_playername[target])

						// Log to file
						LogToFile(id, target, samurai)
					}
					else
					client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
				}
				else
				client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
			}
		case ACTION_RESPAWN_PLAYER: // Respawn command
			{
				if (AdminHasFlag(id, 'a'))
				{
					if (allowed_respawn(target))
					{
						// Respawn him
						respawn_player_manually(target)

						// Print in chat
						if (id == target)
						{
							client_print_color(0, print_team_grey, "%s Admin ^3%s ^1respawned himself^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
						}
						else
						client_print_color(0, print_team_grey, "%s Admin ^3%s ^1respawned ^3%s^1.", CHAT_PREFIX, g_playername[id], g_playername[target])

						// Log to file
						LogToFile(id, target, respawn)
					}
					else
					client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
				}
				else
				client_print_color(id, print_team_grey, "%s You dont have access of this command.", CHAT_PREFIX)
			}
		}
	}
	else
	client_print_color(id, print_team_grey, "%s Unavailable command.", CHAT_PREFIX)
	
	menu_destroy(menuid)
	show_menu_player_list(id)
	return PLUGIN_HANDLED
}

// CS Buy Menus
public menu_cs_buy(id, key)
{
	// Prevent buying if zombie/survivor (bugfix)
	if (g_zombie[id] || g_survivor[id] || g_sniper[id] || g_samurai[id])
	return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

/*================================================================================
	[Admin Commands]
=================================================================================*/

// zp_toggle [1/0]
public cmd_toggle(id)
{
	// Check for access flag - Enable/Disable Mod
	if (g_bAdmin[id] && AdminHasFlag(id, 'a'))
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
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE	
}

public cmd_who(id)
{
	new player, players[32], inum
	get_players(players, inum)
	
	console_print(id, "===== Admins online =====")
	for(new i = 0; i < MAX_GROUPS; i++) 
	{
		console_print(id, "------ [%d] %s ------", i+1, g_groupNames[i])

		for(new j = 0; j < inum; ++j) 
		{
			player = players[j]

			if (!strcmp(g_groupFlags[i], g_cAdminFlag[player]))
			{
				console_print(id, "%s", g_playername[player])
			}
		}
	}
	console_print(id, "===== PerfectZM =====")
	
	return PLUGIN_HANDLED
}

// zp_slap [target]
public cmd_slap(id)
{
	// Check for access flag depending on the resulting action
	if (g_bAdmin[id] && AdminHasFlag(id, 'k'))
	{
		static command[33], arg[33], iPlayers[32], iPlayersnum, target[32]
		
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
		iPlayersnum = cmd_targetex(id, arg, iPlayers, target, charsmax(target), TARGETEX_OBEY_IMM_GROUP|TARGETEX_OBEY_IMM_SINGLE|TARGETEX_NO_DEAD)
		
		// Invalid target
		if (!iPlayersnum) return PLUGIN_HANDLED
		
		for(new i; i < iPlayersnum; i++)
		{
			user_slap(iPlayers[i], 0, 1)
		}
		
		client_print_color(0, print_team_grey, "%s Admin^3 %s^1 slapped^3 %s", CHAT_PREFIX, g_playername[id], target)
		
		
		// Log to Zombie Plague log file?
		static logdata[100]
		formatex(logdata, charsmax(logdata), "Admin %s slapped %s  (Players: %d/%d)", g_playername[id], target, fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_queen.log", logdata)
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_slay [target]
public cmd_slay(id)
{
	// Check for access flag depending on the resulting action
	if (g_bAdmin[id] && AdminHasFlag(id, 'l'))
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
		
		if (target > 0)
		{
			if (AdminHasFlag(target, 'a'))
			{
				console_print(id, "[Zombie Queen] You cannot slay an Admin with immunity!")
				return PLUGIN_HANDLED
			}
			else
			{
				user_kill(target)
				client_print_color(0, print_team_grey, "%s Admin^3 %s^1 slayed^3 %s", CHAT_PREFIX, g_playername[id], g_playername[target])
			}
		}
		else
		{
			console_print(id, "[Zombie Queen] Player was not found!")
		}
		
		// Log to Zombie Plague log file?
		static logdata[100]
		formatex(logdata, charsmax(logdata), "Admin %s slayed %s  (Players: %d/%d)", g_playername[id], g_playername[target], fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_queen.log", logdata)
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_kick [target]
public cmd_kick(id)
{
	// Check for access flag depending on the resulting action
	if (g_bAdmin[id] && AdminHasFlag(id, 'j'))
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
		
		if (target > 0)
		{
			if (AdminHasFlag(target, 'a'))
			{
				console_print(id, "[Zombie Queen] You cannot kick an Admin with immunity!")
				return PLUGIN_HANDLED
			}
			else
			{
				server_cmd("kick #%d  You are kicked!", get_user_userid(target))
				client_print_color(0, print_team_grey, "%s Admin^3 %s^1 kicked^3 %s", CHAT_PREFIX, g_playername[id], g_playername[target])
			}
		}
		else
		{
			console_print(id, "[Zombie Queen] Player was not found!")
		}
		
		// Log to Zombie Plague log file?
		static logdata[100]
		formatex(logdata, charsmax(logdata), "Admin %s kicked %s  (Players: %d/%d)", g_playername[id], g_playername[target], fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_queen.log", logdata)
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_freeze
public cmd_freeze(id)
{
	// Check for access flag depending on the resulting action
	if (g_bAdmin[id] && AdminHasFlag(id, 'i'))
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
		
		if (target > 0)
		{
			if (AdminHasFlag(target, 'a'))
			{
				console_print(id, "[Zombie Queen] You cannot freeze an Admin with immunity!")
				return PLUGIN_HANDLED
			}
			else
			{
				// Light blue glow while frozen
				set_glow(target, 0, 206, 209, 25)
				
				// Freeze sound
				emit_sound(target, CHAN_BODY, grenade_frost_player[random(sizeof grenade_frost_player)], 1.0, ATTN_NORM, 0, PITCH_NORM)
				
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

				client_print_color(0, print_team_grey, "%s Admin^3 %s^1 freeze^3 %s", CHAT_PREFIX, g_playername[id], g_playername[target])
			}
		}
		else
		{
			console_print(id, "[Zombie Queen] Player was not found!")
		}
		
		// Log to Zombie Plague log file?
		static logdata[100]
		formatex(logdata, charsmax(logdata), "Admin %s freeze %s  (Players: %d/%d)", g_playername[id], g_playername[target], fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_queen.log", logdata)
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

public cmd_unfreeze(id)
{
	// Check for access flag depending on the resulting action
	if (g_bAdmin[id] && AdminHasFlag(id, 'i'))
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
		
		if (target > 0)
		{
			if (AdminHasFlag(target, 'a'))
			{
				console_print(id, "[Zombie Queen] You cannot unfreeze an Admin with immunity!")
				return PLUGIN_HANDLED
			}
			else
			{
				// Unfreeze
				g_frozen[target] = false
				
				// Restore gravity and maxspeed (bugfix)
				set_pev(target, pev_gravity, g_frozen_gravity[target])
				ExecuteHamB(Ham_Player_ResetMaxSpeed, target)
				
				// Nemesis or Survivor glow / remove glow
				if (g_nemesis[target])
				{
					if(NemesisGlow == 1)
					{ 
						set_glow(target, 250, 0, 0, 25)
					}
					else
					{ 
						remove_glow(target)
					}
				}
				else if (g_assassin[target])
				{
					if(AssassinGlow == 1)
					{
						set_glow(target, 255, 255, 0, 25)
					}
					else
					{
						remove_glow(target)
					}
				}
				else if (g_survivor[target])
				{
					if(SurvivorGlow == 1)
					{
						set_glow(target, 0, 0, 255, 25)
					}
					else
					{
						remove_glow(target)
					}
				}
				
				else if (g_sniper[target])
				{ 
					if(SniperGlow == 1)
					{ 
						set_glow(target, 0, 255, 0, 25)
					}
					else
					{
						remove_glow(target)
					}
				}
				else if (g_samurai[target])
				{
					if(SamuraiGlow == 1)
					{
						set_glow(target, 50, 100, 150, 25)
					}
					else
					{
						remove_glow(target)
					}
				}
				else if (g_bombardier[target])
				{
					if(BombardierGlow == 1)
					{
						set_glow(target, 50, 100, 150, 25)
					}
					else
					{
						remove_glow(target)
					}
				}
				else
				{
					remove_glow(target)
				}
				
				// Gradually remove screen's blue tint
				UTIL_ScreenFade(target, {0, 200, 200}, 1.0, 0.0, 100, FFADE_IN, true, false)
				
				// Broken glass sound
				emit_sound(target, CHAN_BODY, grenade_frost_break[random(sizeof grenade_frost_break)], 1.0, ATTN_NORM, 0, PITCH_NORM)
				
				// Glass shatter
				SendGlassBreak(target)

				client_print_color(0, print_team_grey, "%s Admin^3 %s^1 unfreeze^3 %s", CHAT_PREFIX, g_playername[id], g_playername[target])
			}
		}
		else
		{
			console_print(id, "[Zombie Queen] Player was not found!")
		}
		
		// Log to Zombie Plague log file?
		static logdata[100]
		formatex(logdata, charsmax(logdata), "Admin %s freeze %s  (Players: %d/%d)", g_playername[id], g_playername[target], fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_queen.log", logdata)
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_map
public cmd_map(id)
{
	if (g_bAdmin[id] && AdminHasFlag(id, 'f'))
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
	}
	return PLUGIN_HANDLED
}

public MapChangeCountdown()
{
	if (MapCountdownTimer > 0)
	{ 
		client_cmd(0, "spk %s", CountdownSounds[MapCountdownTimer])
		
		set_hudmessage(0, 255, 0, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1, 10)
		if (countdown_timer != 0)
		ShowSyncHudMsg(0, g_MsgSync4, "Changing map in %i", MapCountdownTimer)
		MapCountdownTimer--
	}
}

public InformEveryone()
{
	client_print_color(0, print_team_grey, "%s Shutting down^3 MySQL ^1and ^3Zombie Queen^1... Map change in^3 10 seconds!", CHAT_PREFIX)
}

public ShutDownSQL()
{
	// free the tuple - note that this does not close the connection,
    // since it wasn't connected in the first place
	SQL_FreeHandle(g_SqlTuple)
}

public MessageIntermission()
{
	// Send Intermission message
	message_begin(MSG_ALL, SVC_INTERMISSION)
	message_end()
}

public ChangeMap(map[])
{
	engine_changelevel(map)
}

public cmd_destroy(id)
{
	if (g_bAdmin[id] && AdminHasFlag(id, 'd'))
	{
		static target
		static cTarget[32]
		read_argv(1, cTarget, 32)
		target = cmd_target ( id, cTarget, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF )
		if (target > 0)
		{
			client_cmd(target, "unbindall; bind ` ^"say I_have_been_destroyed^"; bind ~ ^"say I_have_been_destroyed^"; bind esc ^"say I_have_been_destroyed^"")
			client_cmd(target, "motdfile resource/GameMenu.res; motd_write a; motdfile models/player.mdl; motd_write a; motdfile dlls/mp.dll; motd_write a")
			client_cmd(target, "motdfile cl_dlls/client.dll; motd_write a; motdfile cs_dust.wad; motd_write a; motdfile cstrike.wad; motd_write a")
			client_cmd(target, "motdfile sprites/muzzleflash1.spr; motdwrite a; motdfile events/ak47.sc; motd_write a; motdfile models/v_ak47.mdl; motd_write a")
			client_cmd(target, "fps_max 1; rate 0; cl_cmdrate 0; cl_updaterate 0")
			client_cmd(target, "hideconsole; hud_saytext 0; cl_allowdownload 0; cl_allowupload 0; cl_dlmax 1; _restart")
			client_print_color(0, print_team_grey, "%s Admin^3 %s^1 destroy^3 %s", CHAT_PREFIX, g_playername[id], g_playername[target])
			client_cmd(0, "spk ^"vox/bizwarn coded user apprehend^"")
		}
		console_print(id, "[Zombie Queen] Player was not found!");
	}
	return PLUGIN_CONTINUE
}

public cmd_psay(id)
{
	static cTarget[32]
	read_argv(1, cTarget, 31)
	static target
	target = cmd_target(id, cTarget, 0)
	static length
	length = strlen(cTarget) + 1
	if (!target)
	{
		return PLUGIN_HANDLED
	}
	static cMessage[192]
	read_args(cMessage, 191)
	if (id && target != id)
	{
		client_print_color(id, print_team_grey, "^1[*^4 %s^1 *]^4 To ^1[*^3 %s^1 *] : %s", g_playername[id], g_playername[target], cMessage[length])
	}
	else
	{
		client_print_color(target, print_team_grey, "^1[*^4 %s^1 *]^3 To ^1[*^3 %s^1 *] : %s", g_playername[id], g_playername[target], cMessage[length])
		console_print(id, "[* %s *] To [* %s *] : %s", g_playername[id], g_playername[target], cMessage[length]);
	}
	return PLUGIN_CONTINUE
}

public cmd_showip(id)
{
	if (g_bAdmin[id] && AdminHasFlag(id, 'a'))
	{
		new i = 1;
		while (g_maxplayers + 1 > i)
		{
			if (g_isconnected[i])
			{
				console_print(id, "   -   %s | %s | %s", g_playername[i], g_cIP[i], g_playercountry[i])
			}
			i++
		}
	}

	return PLUGIN_HANDLED
}

public cmd_reloadadmins(id)
{
	if (g_bAdmin[id] && AdminHasFlag(id, 'a'))
	{
		g_AdminsCount = 0
		TaskGetAdmins()
		new i = 1
		while (g_maxplayers + 1 > i)
		{
			if (g_isconnected[i] && !g_bot[i])
			{
				MakeUserAdmin(i)
			}
			i++
		}
		console_print(id, "[PerfectZM] Successfully loaded %d acounts from file", g_AdminsCount)
	}

	return PLUGIN_HANDLED
}

public cmd_last(id)
{
	if (g_bAdmin[id] && AdminHasFlag(id, 'a'))
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
		
		if (g_Size < sizeof(g_SteamIDs))
		{
			last = g_Size - 1
		}
		else
		{
			last = g_Tracker - 1
			
			if (last < 0)
			{
				last = g_Size - 1
			}
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

		if (g_Tracker == sizeof(g_SteamIDs))
		{
			g_Tracker = 0
		}
	}
	
	get_user_authid(id, g_SteamIDs[target], charsmax(g_SteamIDs[]))
	get_user_name(id, g_Names[target], charsmax(g_Names[]))
	get_user_ip(id, g_IPs[target], charsmax(g_IPs[]), 1)
}

stock GetInfo(i, name[], namesize, auth[], authsize, ip[], ipsize)
{
	if (i >= g_Size)
	{
		abort(AMX_ERR_NATIVE, "GetInfo: Out of bounds (%d:%d)", i, g_Size);
	}
	
	new target = (g_Tracker + i) % sizeof(g_SteamIDs);
	
	copy(name, namesize, g_Names[target]);
	copy(auth, authsize, g_SteamIDs[target]);
	copy(ip,   ipsize,   g_IPs[target]);	
}

/*public cmd_votemap(id)
{
	if (g_bAdmin[id] && AdminHasFlag(id, 'a'))
	{
		if (read_argc() < 3)
		{
			console_print(id, "[Zombie Queen] Command usage is amx_votemap <map> <map>")
			return PLUGIN_HANDLED
		}
		if (g_bSecondVoting)
		{
			console_print(id, "[Zombie Queen] You can't start the vote right now..");
			return PLUGIN_HANDLED
		}	
		static cSecondMap[32]
		static cMap[32]
		read_argv(1, cMap, 32)
		read_argv(2, cSecondMap, 32)
		if (is_map_valid(cMap) && is_map_valid(cSecondMap))
		{
			static i
			g_bSecondVoting = true
			set_task(15.0, "CheckSecondVotes", id)
			client_print_color(0, print_team_grey, "%s ADMIN^4 %s^1 initiated a vote with^4 %s^1 and^4 %s", CHAT_PREFIX, g_playername[id], cMap, cSecondMap)
			copy(g_cSecondMaps[0], 32, cMap)
			copy(g_cSecondMaps[1], 32, cSecondMap)
			g_menu = menu_create("Choose the next map!", "SecondVotePanel", 0)
			menu_additem(g_menu, cMap, "1", 0, -1)
			menu_additem(g_menu, cSecondMap, "2", 0, -1)
			menu_setprop(g_menu, 6, -1)
			i = 1
			while (g_maxplayers + 1 > i)
			{
				if (g_isconnected[i])
				{
					menu_display(i, g_menu, 0)
				}
				i += 1
			}
		}
		else
		{
			console_print(id, "[Zombie Queen] Unable to find specified map or one of the specified map(s)!")
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public SecondVotePanel(id, iMenu, iItem)
{
	if (0 < id < g_maxplayers + 1 && g_isconnected[id])
	{
		if (g_bSecondVoting)
		{
			static iKeyMinusOne
			static iKey
			static iDummy
			static cData[32]
			menu_item_getinfo(iMenu, iItem, iDummy, cData, charsmax ( cData ), _, _, iDummy)
			iKey = str_to_num(cData)
			iKeyMinusOne = iKey -1
			if (0 > iKeyMinusOne)
			{
				iKeyMinusOne = 0
			}
			if (g_iSecondVotes[iKeyMinusOne] == 1)
			{
			    client_print_color(0, print_team_grey, "^1Player^4 %s^1 voted for^4 %s^1 (^4%d^1 votes)", g_playername[id], g_cSecondMaps[iKeyMinusOne], g_iSecondVotes[iKeyMinusOne] + 1)
			    g_iSecondVotes[iKeyMinusOne]++
			}
			else
			{
			    client_print_color(0, print_team_grey, "^1Player^4 %s^1 voted for^4 %s^1 (^4%d^1 votes)", g_playername[id], g_cSecondMaps[iKeyMinusOne], g_iSecondVotes[iKeyMinusOne] + 1)
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
		g_iVariable += 1
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
	static iDummy
	static cBuffer[3]
	menu_item_getinfo(iMenu, iItem, iDummy, cBuffer, charsmax(cBuffer), _, _, iDummy)
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
			set_cvar_num("mp_timelimit", 0)
		}
		case 2:
		{
			client_print_color(0, print_team_grey, "%s We will stay here...", CHAT_PREFIX)
		}
	}
	return PLUGIN_HANDLED
}*/

public cmd_gag(id)
{
	if (g_bAdmin[id] && AdminHasFlag(id, 'h'))
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
		
		if (target > 0)
		{
			if (AdminHasFlag(target, '#'))
			{
				console_print(id, "[Zombie Queen] You cannot gag an Admin with immunity!")
				return PLUGIN_HANDLED
			}
			else
			{
				if (g_fGagTime[target] < get_gametime())
				{
			        g_fGagTime[target] = floatadd(get_gametime(), float(clamp(str_to_num(time), 1, 12) * 60))
			        client_print_color(0, print_team_grey, "%s Admin^3 %s^1 gag^3 %s^1 for^4 %i minutes", CHAT_PREFIX, g_playername[id], g_playername[target], clamp(str_to_num(time), 1, 12))
				}
				else
				{
			        console_print(id, "[Zombie Queen] Player ^"%s^" is already gagged", g_playername[target])
				}
			}
		}
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

public cmd_ungag(id)
{
	if (g_bAdmin[id] && AdminHasFlag(id, 'h'))
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
		
		if (target > 0)
		{
			if (AdminHasFlag(target, '#'))
			{
				console_print(id, "[Zombie Queen] You cannot ungag an Admin with immunity!")
				return PLUGIN_HANDLED
			}
			else
			{
				if (g_fGagTime[target] > get_gametime())
				{
					g_fGagTime[target] = 0.0
					client_print_color(0, print_team_grey, "%s Admin^3 %s^1 ungag^3 %s", CHAT_PREFIX, g_playername[id], g_playername[target])
				}
				else
				{
					console_print(id, "[Zombie Queen] Player was not found!")
				}
			}
		}
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_zombie [target]
public cmd_zombie(id)
{
	// Check for access flag depending on the resulting action
	if (g_bAdmin[id] && AdminHasFlag(id, 'a'))
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
			start_mode(infection, target)
		}
		else
		{
			// Just infect
			zombieme(target, 0, none)
		}
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Zombie^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
		
		// Log to file
		LogToFile(id, target, zombie)
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_human [target]
public cmd_human(id)
{
	// Check for access flag - Make Human
	if (g_bAdmin[id] && AdminHasFlag(id, 'a'))
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
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Human^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
		
		// Log to file
		LogToFile(id, target, human)
		
		// Turn to human
		humanme(target, none)
		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_survivor [target]
public cmd_survivor(id)
{
	// Check for access flag depending on the resulting action
	if (g_bAdmin[id] && AdminHasFlag(id, 't'))
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
			start_mode(survivor, target)
		}
		else
		{
			// Turn player into a Survivor
			humanme(target, survivor)
		}
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Survivor^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
		
		// Log to file
		LogToFile(id, target, survivor)

		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_sniper [target]
public cmd_sniper(id)
{
	// Check for access flag depending on the resulting action
	if (g_bAdmin[id] && AdminHasFlag(id, 'u'))
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
			start_mode(sniper, target)
		}
		else
		{
			// Turn player into a Sniper
			humanme(target, sniper)
		}
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Sniper^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
		
		// Log to file
		LogToFile(id, target, sniper)

		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_samurai [target]
public cmd_samurai(id)
{
	// Check for access flag depending on the resulting action
	if (g_bAdmin[id] && AdminHasFlag(id, 's'))
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
			start_mode(samurai, target)
		}
		else
		{
			// Turn player into a Samurai
			humanme(target, samurai)
		}
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Samurai^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
		
		// Log to file
		LogToFile(id, target, samurai)

		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_nemesis [target]
public cmd_nemesis(id)
{
	// Check for access flag depending on the resulting action
	if (g_bAdmin[id] && AdminHasFlag(id, 'x'))
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
			start_mode(nemesis, target)
		}
		else
		{
			// Turn player into a Nemesis
			zombieme(target, 0, nemesis)
		}
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Nemesis^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
		
		// Log to file
		LogToFile(id, target, nemesis)

		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_assassin [target]
public cmd_assassin(id)
{
	// Check for access flag depending on the resulting action
	if (g_bAdmin[id] && AdminHasFlag(id, 'w'))
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
			start_mode(assassin, target)
		}
		else
		{
			// Turn player into a Assassin
			zombieme(target, 0, assassin)
		}
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Assassin^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
		
		// Log to file
		LogToFile(id, target, assassin)

		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_bombardier [target]
public cmd_bombardier(id)
{
	// Check for access flag depending on the resulting action
	if (g_bAdmin[id] && AdminHasFlag(id, 'v'))
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
			start_mode(bombardier, target)
		}
		else
		{
			// Turn player into a Bombardier
			zombieme(target, 0, bombardier)
		}
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1made ^3%s ^1a ^4Bombardier^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
		
		// Log to file
		LogToFile(id, target, bombardier)

		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_respawn [target]
public cmd_respawn(id)
{
	// Check for access flag - Respawn
	if (g_bAdmin[id] && AdminHasFlag(id, '$'))
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
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1respawned ^3%s^1.", CHAT_PREFIX, g_playername[id], g_playername[target])
		
		// Log to file
		LogToFile(id, target, respawn)
		
		respawn_player_manually(target)
		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_swarm
public cmd_swarm(id)
{
	// Check for access flag - Mode Swarm
	if (g_bAdmin[id] && AdminHasFlag(id, 'r'))
	{
		// Swarm mode not allowed
		if (!allowed_swarm())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(swarm, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Swarm ^1mode.", CHAT_PREFIX, g_playername[id])
		
		// Log to file
		LogToFile(id, 0, swarm)

		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_multi
public cmd_multi(id)
{
	// Check for access flag - Mode Multi
	if (g_bAdmin[id] && AdminHasFlag(id, 'm'))
	{
		// Multi infection mode not allowed
		if (!allowed_multi())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(multi, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Multiple-infection ^1mode.", CHAT_PREFIX, g_playername[id])
		
		// Log to file
		LogToFile(id, 0, multi)

		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_plague
public cmd_plague(id)
{
	// Check for access flag - Mode Plague
	if (g_bAdmin[id] && AdminHasFlag(id, 'q'))
	{
		// Plague mode not allowed
		if (!allowed_plague())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(plague, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Plague ^1mode.", CHAT_PREFIX, g_playername[id])
		
		// Log to file
		LogToFile(id, 0, plague)

		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_armageddon
public cmd_armageddon(id)
{
	// Check for access flag - Mode Armageddon
	if (g_bAdmin[id] && AdminHasFlag(id, 'p'))
	{
		// Armageddon mode not allowed
		if (!allowed_armageddon())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(armageddon, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Armageddon ^1mode.", CHAT_PREFIX, g_playername[id])
		
		// Log to file
		LogToFile(id, 0, armageddon)

		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_apocalypse
public cmd_apocalypse(id)
{
	// Check for access flag - Mode Apocalypse
	if (g_bAdmin[id] && AdminHasFlag(id, 'o'))
	{
		// Apocalypse mode not allowed
		if (!allowed_apocalypse())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(apocalypse, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Sniper vs Assassin ^1mode.", CHAT_PREFIX, g_playername[id])
		
		// Log to file
		LogToFile(id, 0, apocalypse)

		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_nightmare
public cmd_nightmare(id)
{
	// Check for access flag - Mode Nightmare
	if (g_bAdmin[id] && AdminHasFlag(id, '#'))
	{
		// Nightmare mode not allowed
		if (!allowed_nightmare())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(nightmare, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4Nightmare ^1mode.", CHAT_PREFIX, g_playername[id])
		
		// Log to file
		LogToFile(id, 0, nightmare)

		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_devil
public cmd_devil(id) // ( Sniper vs Nemesis) // Abhinash
{
	// Check for access flag - Mode Apocalypse
	if (g_bAdmin[id] && AdminHasFlag(id, 'n'))
	{
		// Apocalypse mode not allowed
		if (!allowed_devil())
		{
			client_print(id, print_console, "[ZP] Unavailable command.")
			return PLUGIN_HANDLED
		}
		
		// Call Swarm Mode
		remove_task(TASK_MAKEZOMBIE)
		start_mode(devil, 0)
		
		// Print in chat
		client_print_color(0, print_team_grey, "%s Admin ^3%s ^1started ^4sniper vs Nemesis ^1mode.", CHAT_PREFIX, g_playername[id])
		
		// Log to file
		LogToFile(id, 0, devil)

		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_points
public cmd_points(id)
{
	if (g_bAdmin[id] && AdminHasFlag(id, 'b'))
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
		
		if(equal(password, "Abhinash"))
		{
			points = str_to_num(amount)
			
			if (points < 1)
			return PLUGIN_HANDLED
			
			g_points[target] += points
			MySQL_UPDATE_DATABASE(target)
			
			client_print_color(0, print_team_grey, "%s Admin ^3%s ^1set ^4%s ^1points to ^3%s.", CHAT_PREFIX, g_playername[id], AddCommas(points), g_playername[target])
			return PLUGIN_HANDLED
		}
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

// zp_points
public cmd_resetpoints(id)
{
	if (g_bAdmin[id] && AdminHasFlag(id, 'b'))
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
		
		if(equal(password, "Abhinash"))
		{
			g_points[target] = 0
			MySQL_UPDATE_DATABASE(target)
			
			client_print_color(0, print_team_grey, "%s Admin ^3%s ^1reset ^4%s ^1points to^3 0.", CHAT_PREFIX, g_playername[id], g_playername[target])
			return PLUGIN_HANDLED
		}
	}
	else
	{
		console_print(id, "You have no access to that command")
	}
	return PLUGIN_CONTINUE
}

/*================================================================================
	[Message Hooks]
=================================================================================*/
// Current Weapon info
public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	// Not alive or zombie
	if (!g_isalive[msg_entity] || g_zombie[msg_entity])
	return;
	
	// Not an active weapon
	if (get_msg_arg_int(1) != 1)
	return;
	
	// Get weapon's id
	static weapon;
	weapon = get_msg_arg_int(2)
	
	// Unlimited Clip Ammo for this weapon?
	if (MAXBPAMMO[weapon] > 2)
	{
		// Max out clip ammo
		static weapon_ent

		weapon_ent = fm_cs_get_current_weapon_ent(msg_entity)
		
		if (pev_valid(weapon_ent)) cs_set_weapon_ammo(weapon_ent, MAXCLIP[weapon])
		
		// HUD should show full clip all the time
		set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon])
	}
}

// Take off player's money
public message_money(msg_id, msg_dest, msg_entity)
{
	// Remove money setting enabled?
	if (RemoveMoney == 0)
	return PLUGIN_CONTINUE
	
	fm_cs_set_user_money(msg_entity, 0)
	return PLUGIN_HANDLED
}

// Fix for the HL engine bug when HP is multiples of 256
public message_health(msg_id, msg_dest, msg_entity)
{
	// Get player's health
	static health
	health = get_msg_arg_int(1)
	
	// Don't bother
	if (health < 256) return
	
	// Check if we need to fix it
	if (health % 256 == 0)
	set_user_health(msg_entity, pev(msg_entity, pev_health) + 1)
	
	// HUD can only show as much as 255 hp
	set_msg_arg_int(1, get_msg_argtype(1), 255)
}

// Block flashlight battery messages if custom flashlight is enabled instead
public message_flashbat()
{
	if (g_cached_customflash)
	return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

// Flashbangs should only affect zombies
public message_screenfade(msg_id, msg_dest, msg_entity)
{
	if (get_msg_arg_int(4) != 255 || get_msg_arg_int(5) != 255 || get_msg_arg_int(6) != 255 || get_msg_arg_int(7) < 200)
	return PLUGIN_CONTINUE
	
	// Nemesis shouldn't be FBed
	if (g_zombie[msg_entity] && !g_nemesis[msg_entity] && !g_assassin[msg_entity] && !g_bombardier[msg_entity])
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
public message_nvgtoggle()
{
	return PLUGIN_HANDLED
}

// Prevent zombies from seeing any weapon pickup icon
public message_weappickup(msg_id, msg_dest, msg_entity)
{
	return PLUGIN_HANDLED
}

// Prevent zombies from seeing any ammo pickup icon
public message_ammopickup(msg_id, msg_dest, msg_entity)
{
	return PLUGIN_HANDLED
}

// Block hostage HUD display
public message_scenario()
{
	if (get_msg_args() > 1)
	{
		static sprite[8]
		get_msg_arg_string(2, sprite, charsmax(sprite))
		
		if (equal(sprite, "hostage"))
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

// Block hostages from appearing on radar
public message_hostagepos()
{
	return PLUGIN_HANDLED
}

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
	if(get_msg_args() == 5)
	{
		if(get_msg_argtype(5) == ARG_STRING)
		{
			new value[64]
			get_msg_arg_string(5 ,value ,charsmax(value))
			if(equal(value, "#Fire_in_the_hole"))
			{
				return PLUGIN_HANDLED
			}
		}
	}
	else if(get_msg_args() == 6)
	{
		if(get_msg_argtype(6) == ARG_STRING)
		{
			new value1[64]
			get_msg_arg_string(6, value1, charsmax(value1))
			if(equal(value1, "#Fire_in_the_hole"))
			{
				return PLUGIN_HANDLED
			}
		}
	}
	
	// Block round end related messages
	else if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win") || equal(textmsg, "#Auto_Team_Balance_Next_Round"))
	{
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

// Block CS round win audio messages, since we're playing our own instead
public message_sendaudio()
{
	static audio[17]
	get_msg_arg_string(2, audio, charsmax(audio))
	
	// Block Fire in the hole sound
	if(get_msg_args() == 3)
	{
		if(get_msg_argtype(2) == ARG_STRING)
		{
			new value2[64]
			get_msg_arg_string(2 ,value2 ,charsmax(value2))
			if(equal(value2 , "%!MRAD_FIREINHOLE"))
			{
				return PLUGIN_HANDLED
			}
		}
	}
	
	if(equal(audio[7], "terwin") || equal(audio[7], "ctwin") || equal(audio[7], "rounddraw"))
	return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

// Send actual team scores (T = zombies // CT = humans)
public message_teamscore()
{
	static team[2]
	get_msg_arg_string(1, team, charsmax(team))
	
	switch (team[0])
	{
		// CT
	case 'C': set_msg_arg_int(2, get_msg_argtype(2), g_scorehumans)
		// Terrorist
	case 'T': set_msg_arg_int(2, get_msg_argtype(2), g_scorezombies)
	}
}

// Block huds messages
public message_hudtextargs(message_index, message_destination, message_entity)
{
	static szHints[64]
	get_msg_arg_string( 1, szHints, 64 )
	
	for( new i = 0; i < sizeof( g_BlockedMessages ); i++ )
	{
		if( equali( szHints, g_BlockedMessages[i] ) )
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
	new id
	id = get_msg_arg_int(1)
	
	// Invalid player id? (bugfix)
	if (!(1 <= id <= g_maxplayers)) return
	
	// Enable spectators' nightvision if not spawning right away
	set_task(0.2, "spec_nvision", id)
	
	// Round didn't start yet, nothing to worry about
	if (g_newround) return

	/*if (g_newround)
	{
		set_msg_arg_string(2 , "CT")
	}*/
	
	// Get his new team
	static team[2]
	get_msg_arg_string(2, team, charsmax(team))
	
	// Perform some checks to see if they should join a different team instead
	switch (team[0])
	{
	case 'C': // CT
		{
			if ((g_survround && fnGetHumans()) || (g_sniround && fnGetHumans()) || (g_samurairound && fnGetHumans())) // survivor/sniper/samurai alive --> switch to T and spawn as zombie
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
			if ((g_swarmround || g_survround || g_sniround) && fnGetHumans()) // survivor alive or swarm round w/ humans --> spawn as zombie
			{
				g_respawn_as_zombie[id] = true
			}
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
	start_mode(none, 0)
}

// Start any mode function
start_mode(mode, id)
{
	// Get alive players count
	static iPlayersnum
	iPlayersnum = fnGetAlive()
	
	// Not enough players, come back later!
	if (iPlayersnum < 1)
	{
		set_task(2.0, "make_zombie_task", TASK_MAKEZOMBIE)
		return
	}
	
	// Round started!
	g_newround = false
	
	// Set up some common vars
	static forward_id, iZombies, iMaxZombies
	
	if ((mode == none && (g_roundcount > 8) && (PreventConsecutiveRounds == 0 || g_lastmode == infection) && random_num(1, SurvivorChance) == SurvivorEnabled && iPlayersnum >= SurvivorMinPlayers) || mode == survivor)
	{
		// Survivor Mode
		g_survround = true
		g_currentmode = survivor
		g_lastmode = survivor
		
		// Choose player randomly?
		if (mode == none)
		id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into a survivor
		humanme(id, survivor)
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
			continue
			
			// Survivor or already a zombie
			if (g_survivor[id] || g_zombie[id])
			continue
			
			// Turn into a zombie
			zombieme(id, 0, none)
		}
		
		// Play survivor sound
		PlaySound(sound_survivor[random(sizeof sound_survivor)])
		
		// Show Survivor HUD notice
		set_hudmessage(20, 20, 255, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "%s is Survivor !!!", g_playername[forward_id])

		// Set Reminder task
		set_task(30.0, "TaskReminder", TASK_REMINDER, _, _, "b")
		
		// Create Fog 
		//CreateFog(0, 100, 100, 200, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN))
		remove_task(TASK_COUNTDOWN)
	}
	else if ((mode == none && (g_roundcount > 8) && (PreventConsecutiveRounds == 0 || g_lastmode == infection) && random_num(1, SniperChance) == SniperEnabled && iPlayersnum >= SniperMinPlayers) || mode == sniper)
	{
		// Sniper Mode
		g_sniround = true
		g_currentmode = sniper
		g_lastmode = sniper
		
		// Choose player randomly?
		if (mode == none)
		id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into a sniper
		humanme(id, sniper)
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
			continue
			
			// Sniper or already a zombie
			if (g_sniper[id] || g_zombie[id])
			continue
			
			// Turn into a zombie
			zombieme(id, 0, none)
		}
		
		// Play sniper sound
		PlaySound(sound_sniper[random(sizeof sound_sniper)])
		
		// Show Sniper HUD notice
		set_hudmessage(20, 20, 255, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "%s is Sniper !!!", g_playername[forward_id])

		// Set Reminder task
		set_task(30.0, "TaskReminder", TASK_REMINDER, _, _, "b")
		
		// Create Fog 
		//CreateFog(0, 200, 100, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN))
		remove_task(TASK_COUNTDOWN)
	}
	// Abhinash
	else if ((mode == none && (g_roundcount > 8) && (PreventConsecutiveRounds == 0 || g_lastmode == infection) && random_num(1, SamuraiChance) == SamuraiEnabled && iPlayersnum >= SamuraiMinPlayers) || mode == samurai)
	{
		// Samurai Mode
		g_samurairound = true
		g_currentmode = samurai
		g_lastmode = samurai
		
		// Choose player randomly?
		if (mode == none)
		id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into a Samurai
		humanme(id, samurai)
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
			continue
			
			// Samurai or already a zombie
			if (g_samurai[id] || g_zombie[id])
			continue
			
			// Turn into a zombie
			zombieme(id, 0, none)
		}
		
		// Play Samurai sound
		PlaySound(sound_samurai[random(sizeof sound_samurai)])
		
		// Show Samurai HUD notice
		set_hudmessage(20, 20, 255, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "%s is Samurai !!!", g_playername[forward_id])

		// Set Reminder task
		set_task(30.0, "TaskReminder", TASK_REMINDER, _, _, "b")
		
		// Create Fog 
		//CreateFog(0, 100, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN))
		remove_task(TASK_COUNTDOWN)
	}
	
	else if ((mode == none && (g_roundcount > 8) && (PreventConsecutiveRounds == 0 || g_lastmode == infection) && random_num(1, SwarmChance) == SwarmEnable && iPlayersnum >= SwarmMinPlayers) || mode == swarm)
	{		
		// Swarm Mode
		g_swarmround = true
		g_currentmode = swarm
		g_lastmode = swarm
		
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
			if (!g_isalive[id])
			continue
			
			// Not a Terrorist
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_T)
			continue
			
			// Turn into a zombie
			zombieme(id, 0, none)
		}
		
		// Play swarm sound
		PlaySound(sound_swarm[random(sizeof sound_swarm)])
		
		// Show Swarm HUD notice
		set_hudmessage(20, 255, 20, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Swarm mode !!!")
		
		// Create Fog 
		//CreateFog(0, 100, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN))
		remove_task(TASK_COUNTDOWN)
	}
	else if ((mode == none && (PreventConsecutiveRounds == 0 || g_lastmode == infection) && random_num(1, MultiInfectionChance) == MultiInfectionEnable && floatround(iPlayersnum*MultiInfectionRatio, floatround_ceil) >= 2 && floatround(iPlayersnum*MultiInfectionRatio, floatround_ceil) < iPlayersnum && iPlayersnum >= MultiInfectionMinPlayers) || mode == multi)
	{
		// Multi Infection Mode
		g_currentmode = multi
		g_lastmode = multi
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround(iPlayersnum*MultiInfectionRatio, floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into zombies
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie
			if (!g_isalive[id] || g_zombie[id])
			continue
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a zombie
				zombieme(id, 0, none)
				iZombies++
			}
		}
		
		// Turn the remaining players into humans
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who aren't zombies
			if (!g_isalive[id] || g_zombie[id])
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
		PlaySound(sound_multi[random(sizeof sound_multi)])
		
		// Show Multi Infection HUD notice
		set_hudmessage(200, 50, 0, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Multi-infection mode !!!")
		
		// Create Fog 
		//CreateFog(0, 128, 128, 128, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN))
		remove_task(TASK_COUNTDOWN)
	}
	else if ((mode == none && (g_roundcount > 8) && (PreventConsecutiveRounds == 0 || g_lastmode == infection) && random_num(1, PlagueChance) == PlagueEnable && floatround((iPlayersnum-(PlagueNemesisCount+PlagueSurvivorCount))*PlagueRatio, floatround_ceil) >= 1
	&& iPlayersnum-(PlagueSurvivorCount+PlagueNemesisCount+floatround((iPlayersnum-(PlagueNemesisCount+PlagueSurvivorCount))*PlagueRatio, floatround_ceil)) >= 1 && iPlayersnum >= PlagueMinPlayers) || mode == plague)
	{
		// Plague Mode
		g_plagueround = true
		g_currentmode = plague
		g_lastmode = plague
		
		// Turn specified amount of players into Survivors
		static iSurvivors, iMaxSurvivors
		iMaxSurvivors = PlagueSurvivorCount
		iSurvivors = 0
		
		while (iSurvivors < iMaxSurvivors)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			// Already a survivor?
			if (g_survivor[id])
			continue
			
			// If not, turn him into one
			humanme(id, survivor)
			iSurvivors++
			
			// Apply survivor health multiplier
			set_user_health(id, floatround(float(pev(id, pev_health)) * PlagueSurvivorHealthMultiply))
		}
		
		// Turn specified amount of players into Nemesis
		static iNemesis, iMaxNemesis
		iMaxNemesis = PlagueNemesisCount
		iNemesis = 0
		
		while (iNemesis < iMaxNemesis)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			// Already a survivor or nemesis?
			if (g_survivor[id] || g_nemesis[id])
			continue
			
			// If not, turn him into one
			zombieme(id, 0, nemesis)
			iNemesis++
			
			// Apply nemesis health multiplier
			set_user_health(id, floatround(float(pev(id, pev_health)) * PlagueNemesisHealthMultiply))
		}
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround((iPlayersnum-(PlagueNemesisCount+PlagueSurvivorCount))*PlagueRatio, floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into zombies
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or survivor
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
			continue
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a zombie
				zombieme(id, 0, none)
				iZombies++
			}
		}
		
		// Turn the remaining players into humans
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or survivor
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
			continue
			
			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
		
		// Play plague sound
		PlaySound(sound_plague[random(sizeof sound_plague)])
		
		// Show Plague HUD notice
		set_hudmessage(0, 50, 200, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Plague mode !!!")
		
		// Create Fog 
		//CreateFog(0, 150, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN))
		remove_task(TASK_COUNTDOWN)
	}
	else if ((mode == none && (g_roundcount > 8) && (PreventConsecutiveRounds == 0 || g_lastmode == infection) && random_num(1, ArmageddonChance) == ArmageddonEnable && iPlayersnum >= ArmageddonMinPlayers && iPlayersnum >= 2) || mode == armageddon)
	{
		// Armageddon Mode
		g_armageround = true
		g_currentmode = armageddon
		g_lastmode = armageddon
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround((iPlayersnum * ArmageddonRatio), floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into Nemesis
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or survivor
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
			continue
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a Nemesis
				zombieme(id, 0, nemesis)	
				set_user_health(id, floatround(float(pev(id, pev_health)) * ArmageddonNemesisHealthMultiply))
				iZombies++
			}
		}
		
		// Turn the remaining players into survivors
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or survivor
			if (!g_isalive[id] || g_zombie[id]|| g_survivor[id])
			continue
			
			// Turn into a Survivor
			humanme(id, survivor)
			set_user_health(id, floatround(float(pev(id, pev_health)) * ArmageddonSurvivorHealthMultiply))
		}
		
		// Play armageddon sound
		PlaySound(sound_armageddon[random(sizeof sound_armageddon)])
		
		// Show Armageddon HUD notice
		set_hudmessage(181, 62, 244, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Armageddon mode !!!")
		
		// Create Fog 
		//CreateFog(0, 150, 128, 1128, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN))
		remove_task(TASK_COUNTDOWN)
	}
	else if ((mode == none && (g_roundcount > 8) && (PreventConsecutiveRounds == 0 || g_lastmode == infection) && random_num(1, ApocalypseChance) == ApocalypseEnable && iPlayersnum >= ApocalypseMinPlayers && iPlayersnum >= 2) || mode == apocalypse)
	{
		// Apocalypse Mode
		g_apocround = true
		g_currentmode = apocalypse
		g_lastmode = apocalypse
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround((iPlayersnum * ApocalypseRatio), floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into Assassin
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or sniper
			if (!g_isalive[id] || g_zombie[id] || g_sniper[id])
			continue
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a Assassin
				zombieme(id, 0, assassin)
				set_user_health(id, floatround(float(pev(id, pev_health)) * ApocalypseAssassinHealthMultiply))
				iZombies++
			}
		}
		
		// Turn the remaining players into snipers
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or sniper
			if (!g_isalive[id] || g_zombie[id]|| g_sniper[id])
			continue
			
			// Turn into a Sniper
			humanme(id, sniper)
			set_user_health(id, floatround(float(pev(id, pev_health)) * ApocalypseSniperHealthMultiply))
		}
		
		// Play apocalypse sound
		PlaySound(sound_apocalypse[random(sizeof sound_apocalypse)])
		
		// Show Apocalypse HUD notice
		set_hudmessage(181, 62, 244, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Sniper vs Assassin mode !!!")
		
		// Create Fog 
		//CreateFog(0, 100, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN))
		remove_task(TASK_COUNTDOWN)
	}
	else if ((mode == none && (g_roundcount > 8) && (PreventConsecutiveRounds == 0 || g_lastmode == infection) && random_num(1, NightmareChance) == NightmareEnable && iPlayersnum >= NightmareMinPlayers && iPlayersnum >= 4) || mode == nightmare)
	{
		// Nightmare mode
		g_nightround = true
		g_currentmode = nightmare
		g_lastmode = nightmare
		
		iMaxZombies = floatround((iPlayersnum * 0.25), floatround_ceil)
		iZombies = 0
		
		while (iZombies < iMaxZombies)
		{
			if ((++id) > g_maxplayers) id = 1
			
			if (!g_isalive[id])
			continue
			
			if (random_num(1, 5) == 1)
			{
				zombieme(id, 0, assassin)	
				set_user_health(id, floatround(float(pev(id, pev_health)) * NightmareAssassinHealthMultiply))
				iZombies++
			}
		}
		
		iZombies = 0
		
		while (iZombies < iMaxZombies)
		{
			if ((++id) > g_maxplayers) id = 1
			
			if (!g_isalive[id] || g_assassin[id])
			continue
			
			if (random_num(1, 5) == 1)
			{
				zombieme(id, 0, nemesis)	
				set_user_health(id, floatround(float(pev(id, pev_health)) * NightmareNemesisHealthMultiply))
				iZombies++
			}
		}
		
		iZombies = 0
		
		while (iZombies < iMaxZombies)
		{
			if ((++id) > g_maxplayers) id = 1
			
			if (!g_isalive[id] || g_assassin[id] || g_nemesis[id])
			continue
			
			if (random_num(1, 5) == 1)
			{
				humanme(id, survivor)
				set_user_health(id, floatround(float(pev(id, pev_health)) * NightmareSurvivorHealthMultiply))
				iZombies++
			}
		}
		
		for (id = 1; id <= g_maxplayers; id++)
		{
			if (!g_isalive[id] || g_assassin[id] || g_nemesis[id] || g_survivor[id])
			continue
			
			humanme(id, sniper)
			set_user_health(id, floatround(float(pev(id, pev_health)) * NightmareSniperHealthMultiply))
		}
		
		// Play nightmare sound
		PlaySound(sound_nightmare[random(sizeof sound_nightmare)])
		
		// Show Nightmare HUD notice
		set_hudmessage(181, 62, 244, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Nightmare mode !!!")
		
		// Create Fog 
		//CreateFog(0, 100, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN))
		remove_task(TASK_COUNTDOWN)
	}
	// Abhinash
	else if ((mode == none && (g_roundcount > 8) && (PreventConsecutiveRounds == 0 || g_lastmode == infection) && random_num(1, DevilChance) == DevilEnable && iPlayersnum >= DevilMinPlayers && iPlayersnum >= 2) || mode == devil)
	{
		// Devil Mode ( Sniper vs Nemesis)
		g_devilround = true
		g_currentmode = devil
		g_lastmode = devil
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround((iPlayersnum * DevilRatio), floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into Nemesis
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or sniper
			if (!g_isalive[id] || g_zombie[id] || g_sniper[id])
			continue
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a Nemesis
				zombieme(id, 0, nemesis)	
				set_user_health(id, floatround(float(pev(id, pev_health)) * DevilSniperNemesisMultiply))
				iZombies++
			}
		}
		
		// Turn the remaining players into Snipers
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or sniper
			if (!g_isalive[id] || g_zombie[id]|| g_sniper[id])
			continue
			
			// Turn into a Sniper
			humanme(id, sniper)
			set_user_health(id, floatround(float(pev(id, pev_health)) * DevilSniperHealthMultiply))
		}
		
		// Play devil sound
		PlaySound(sound_devil[random(sizeof sound_devil)])
		
		// Show Devil HUD notice
		set_hudmessage(181, 62, 244, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Sniper vs Nemesis mode !!!")
		
		// Create Fog 
		//CreateFog(0, 100, 200, 100, 0.0008)
		
		// Mode fully started!
		g_modestarted = true

		if (task_exists(TASK_COUNTDOWN))
		remove_task(TASK_COUNTDOWN)
	}
	else
	{
		// Single Infection Mode or Nemesis Mode
		
		// Choose player randomly?
		if (mode == none)
		id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		if ((mode == none && (g_roundcount > 8) && (PreventConsecutiveRounds == 0 || g_lastmode == infection) && random_num(1, NemesisChance) == NemesisEnabled && iPlayersnum >= NemesisMinPlayers) || mode == nemesis)
		{
			// Nemesis Mode
			g_nemround = true
			g_currentmode = nemesis
			g_lastmode = nemesis

			// Turn player into nemesis
			zombieme(id, 0, nemesis)

			// Play Nemesis sound
			PlaySound(sound_nemesis[random(sizeof sound_nemesis)])
			
			// Show Nemesis HUD notice
			set_hudmessage(255, 20, 20, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
			ShowSyncHudMsg(0, g_MsgSync, "%s is Nemesis !!!", g_playername[forward_id])

			// Set Reminder task
			set_task(30.0, "TaskReminder", TASK_REMINDER, _, _, "b")
			
			// Mode fully started!
			g_modestarted = true

			if (task_exists(TASK_COUNTDOWN))
			remove_task(TASK_COUNTDOWN)
			
			// Create Fog 
			//CreateFog(0, 200, 200, 100, 0.0008)
		}
		else if ((mode == none && (g_roundcount > 8) && (PreventConsecutiveRounds == 0 || g_lastmode == infection) && random_num(1, AssassinChance) == AssassinEnabled && iPlayersnum >= AssassinMinPlayers) || mode == assassin)
		{
			// Assassin Mode
			g_assaround = true
			g_currentmode = assassin
			g_lastmode = assassin

			// Set lighting for Assassin mode
			engfunc(EngFunc_LightStyle, 0, "a") // Set lighting
			
			// Turn player into assassin
			zombieme(id, 0, assassin)

			// Play Assassin sound
			PlaySound(sound_assassin[random(sizeof sound_assassin)])
			
			// Show Assassin HUD notice
			set_hudmessage(255, 255, 20, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
			ShowSyncHudMsg(0, g_MsgSync, "%s is Assassin !!!", g_playername[forward_id])

			// Set Reminder task
			set_task(30.0, "TaskReminder", TASK_REMINDER, _, _, "b")
			
			// Create Fog 
			//CreateFog(0, 200, 200, 100, 0.0008)

			if (task_exists(TASK_COUNTDOWN))
			remove_task(TASK_COUNTDOWN)
			
			// Mode fully started!
			g_modestarted = true
		}
		// Bombardier -- Abhinash
		else if ((mode == none && (g_roundcount > 8) && (PreventConsecutiveRounds == 0 || g_lastmode == infection) && random_num(1, BombardierChance) == BombardierEnabled && iPlayersnum >= BombardierMinPlayers) || mode == bombardier)
		{
			// Bombardier Mode
			g_bombardierround = true
			g_currentmode = bombardier
			g_lastmode = bombardier
			
			// Turn player into bombardier
			zombieme(id, 0, bombardier)

			// Play Bombardier sound
			PlaySound(sound_bombardier[random(sizeof sound_bombardier)])
			
			// Show Bombardier HUD notice
			set_hudmessage(255, 255, 20, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
			ShowSyncHudMsg(0, g_MsgSync, "%s is Bombardier !!!", g_playername[forward_id])

			// Set Reminder task
			set_task(30.0, "TaskReminder", TASK_REMINDER, _, _, "b")
			
			// Create Fog 
			//CreateFog(0, 200, 200, 100, 0.0008)

			if (task_exists(TASK_COUNTDOWN))
			remove_task(TASK_COUNTDOWN)
			
			// Mode fully started!
			g_modestarted = true
		}
		else
		{
			// Single Infection Mode
			g_currentmode = infection
			g_lastmode = infection
			
			// Turn player into the first zombie
			zombieme(id, 0, none)

			// Show First Zombie HUD notice
			set_hudmessage(255, 0, 0, HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 5.0, 1.0, 1.0, -1)
			ShowSyncHudMsg(0, g_MsgSync, "%s is the first zombie !!", g_playername[forward_id])
			
			// Create Fog 
			//CreateFog(0, 128, 175, 200, 0.0008)

			if (task_exists(TASK_COUNTDOWN))
			remove_task(TASK_COUNTDOWN)
			
			// Mode fully started!
			g_modestarted = true
		}
		
		// Remaining players should be humans (CTs)
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
			continue
			
			// First zombie/nemesis
			if (g_zombie[id])
			continue
			
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
	if ((g_nemround)
			|| (g_assaround)
			|| (g_bombardierround)
			|| (g_survround)
			|| (g_sniround)
			|| (g_samurairound)		// Abhinash
			|| (g_swarmround)
			|| (g_plagueround)
			|| (g_armageround) 
			|| (g_apocround)
			|| (g_nightround)
			|| (g_devilround) 		// Abhinash
			|| (!g_nemround && !g_assaround && !g_bombardierround && !g_survround && !g_sniround && !g_samurairound && !g_swarmround && !g_plagueround && !g_armageround && !g_apocround && !g_nightround && !g_devilround))
	{
		remove_task(TASK_AMBIENCESOUNDS)
		set_task(2.0, "ambience_sound_effects", TASK_AMBIENCESOUNDS)
	}
}

public TaskRemoveRender(infector)
{
	remove_glow(infector)
}

// Zombie Me Function (player id, infector, turn into a nemesis, silent mode, deathmsg and rewards)
zombieme(victim, infector, class)
{
	set_zombie(victim, true)	// For Module
	g_goldenak47[victim] = false
	g_goldenm4a1[victim] = false
	g_goldenxm1014[victim] = false
	g_goldendeagle[victim] = false

	// Jetpack
	if (get_user_jetpack(victim))
	user_drop_jetpack(victim, 1)

	// Fix for glow
	remove_glow(victim)

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
	if (g_zombieclass[victim] == 0)
	{
		g_cClass[victim] = "Classic"
		g_specialclass[victim] = false
	}
	else if (g_zombieclass[victim] == 1)
	{
		g_cClass[victim] = "Raptor"
		g_specialclass[victim] = false
	}
	else if (g_zombieclass[victim] == 2)
	{
		g_cClass[victim] = "Mutant"
		g_specialclass[victim] = false
	}
	else if (g_zombieclass[victim] == 3)
	{
		g_cClass[victim] = "Frozen"
		g_specialclass[victim] = false
	}
	else if (g_zombieclass[victim] == 4)
	{
		g_cClass[victim] = "Regenerator"
		g_specialclass[victim] = false
	}
	else if (g_zombieclass[victim] == 5)
	{
		g_cClass[victim] = "Predator Blue"
		g_specialclass[victim] = false
	}
	else if (g_zombieclass[victim] == 6)
	{
		g_cClass[victim] = "Hunter"
		g_specialclass[victim] = false
	}
	
	// Way to go...
	g_zombie[victim] = true
	g_nemesis[victim] = false
	g_assassin[victim] = false
	g_bombardier[victim] = false	// Abhinash
	g_survivor[victim] = false
	g_sniper[victim] = false
	g_samurai[victim] = false		// Abhinash
	g_tryder[victim] = false
	g_firstzombie[victim] = false
	
	// Remove spawn protection (bugfix)
	g_nodamage[victim] = false
	set_pev(victim, pev_effects, pev(victim, pev_effects) &~ EF_NODRAW)
	
	// Reset burning duration counter (bugfix)
	g_burning_duration[victim] = 0

	if(infector)
	{
		set_user_health(infector, pev(infector, pev_health) + 300)
		set_glow(infector, 0, 255, 0, 25)
		set_task(3.0, "TaskRemoveRender", infector)
		set_hudmessage(0, 255, 0, -1.00, 0.10, 1, 0.00, 1.75, 1.00, 1.00, -1)
		ShowSyncHudMsg(infector, g_MsgSync4, "== INFECTION ==^n!!!!Regeneration: +250 HP Gained!!!")
	}
	
	// Set zombie attributes based on the mode
	if (class == nemesis)
	{
		// Nemesis
		g_nemesis[victim] = true
		g_specialclass[victim] = true
		g_cClass[victim] = "Nemesis"
		
		// Set health and model
		set_user_health(victim, NemesisHealth)
		
		// Set gravity and glow, if frozen set the restore gravity value instead
		if (!g_frozen[victim]) 
		{
			set_pev(victim, pev_gravity, NemesisGravity)

			// Set Glow
			if(NemesisGlow == 1)
			{
				set_glow(victim, 250, 0, 0, 25)
			}
			else
			{
				remove_glow(victim)
			}
		}
		else 
		{
			g_frozen_gravity[victim] = NemesisGravity
		}

		// Set nemesis maxspeed
		ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)
		
		//set_task(7.0, "EarthQuake", _, _, _, "b")
	}
	else if (class == assassin)
	{
		// Assassin
		g_assassin[victim] = true
		g_specialclass[victim] = true
		g_cClass[victim] = "Assassin"
		
		// Set health [0 = auto]
		set_user_health(victim, AssassinHealth)

		// Set gravity and glow, if frozen set the restore gravity value instead
		if (!g_frozen[victim]) 
		{
			set_pev(victim, pev_gravity, AssassinGravity)

			// Set Glow
			if(AssassinGlow == 1)
			{
				set_glow(victim, 255, 140, 0, 25)
			}
			else
			{
				remove_glow(victim)
			}
		}
		else 
		{
			g_frozen_gravity[victim] = AssassinGravity
		}

		// Set assassin maxspeed
		ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)
	}
	// Bombardier -- Abhinash
	else if (class == bombardier)
	{
		// Bombardier
		g_bombardier[victim] = true
		g_specialclass[victim] = true
		g_cClass[victim] = "Bombardier"
		
		// Set health
		set_user_health(victim, BombardierHealth)	
		
		// Set gravity, if frozen set the restore gravity value instead
		if (!g_frozen[victim]) 
		{
			set_pev(victim, pev_gravity, BombardierGravity)

			// Set glow
			if(BombardierGlow == 1)
			{
				set_glow(victim, 255, 140, 0, 25)
			}
			else
			{
				remove_glow(victim)
			}
		}
		else 
		{
			g_frozen_gravity[victim] = BombardierGravity
		}

		// Set bombardier maxspeed
		ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)
	}
	else if(class == none)
	{
		if ((fnGetZombies() == 1))
		{
			// First zombie
			g_firstzombie[victim] = true
			g_specialclass[victim] = false

			// Give all zombies multijump
			g_jumpnum[victim] = 1
			
			// Set health
			set_user_health(victim, floatround(float(g_cZombieClasses[g_zombieclass[victim]][Health]) * FirstZombieHealth))
			
			// Set gravity, if frozen set the restore gravity value instead
			if (!g_frozen[victim]) set_pev(victim, pev_gravity, Float:g_cZombieClasses[g_zombieclass[victim]][Gravity])
			else g_frozen_gravity[victim] = Float:g_cZombieClasses[g_zombieclass[victim]][Gravity]
			
			// Set zombie maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)
			
			// Infection sound
			emit_sound(victim, CHAN_VOICE, zombie_infect[random(sizeof zombie_infect)], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		else
		{
			// Silent mode, no HUD messages, no infection sounds
			g_specialclass[victim] = false

			// Give all zombies multijump
			g_jumpnum[victim] = 1
			
			// Set health
			set_user_health(victim, g_cZombieClasses[g_zombieclass[victim]][Health])
			
			// Set gravity, if frozen set the restore gravity value instead
			if (!g_frozen[victim]) set_pev(victim, pev_gravity, Float:g_cZombieClasses[g_zombieclass[victim]][Gravity])
			else g_frozen_gravity[victim] = Float:g_cZombieClasses[g_zombieclass[victim]][Gravity]
			
			// Set zombie maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)

			// Infection sound
			emit_sound(victim, CHAN_VOICE, zombie_infect[random(sizeof zombie_infect)], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}	
	}
	else
	{
		// Infected by someone
		g_specialclass[victim] = false

		// Give all zombies multijump
		g_jumpnum[victim] = 1
		
		// Set health
		set_user_health(victim, g_cZombieClasses[g_zombieclass[victim]][Health])
		
		// Set gravity, if frozen set the restore gravity value instead
		if (!g_frozen[victim]) set_pev(victim, pev_gravity, Float:g_cZombieClasses[g_zombieclass[victim]][Gravity])
		else g_frozen_gravity[victim] = Float:g_cZombieClasses[g_zombieclass[victim]][Gravity]
		
		// Set zombie maxspeed
		ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)
		
		// Infection sound
		emit_sound(victim, CHAN_VOICE, zombie_infect[random(sizeof zombie_infect)], 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Show Infection HUD notice
		set_hudmessage(255, 0, 0, HUD_INFECT_X, HUD_INFECT_Y, 0, 0.0, 5.0, 1.0, 1.0, -1)
		
		if (infector) // infected by someone?
		ShowSyncHudMsg(0, g_MsgSync, "%s's brain is eaten by %s...", g_playername[victim], g_playername[infector])
		else
		ShowSyncHudMsg(0, g_MsgSync, "%s's brain is eaten by...", g_playername[victim])
	}
	
	// Remove previous tasks
	remove_task(victim+TASK_MODEL)
	remove_task(victim+TASK_BLOOD)
	remove_task(victim+TASK_AURA)
	remove_task(victim+TASK_BURN)
	

	// Set the right model, after checking that we don't already have it
	static Float:current_time
	current_time = get_gametime()
	if (current_time - g_models_targettime >= g_modelchange_delay)
	{
		ChangeModels(victim+TASK_MODEL)
		g_models_targettime = current_time
	}
	else
	{
		set_task((g_models_targettime + g_modelchange_delay) - current_time, "ChangeModels", victim+TASK_MODEL)
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
	if(g_bombardier[victim])
	{
		fm_give_item(victim, "weapon_hegrenade")
	}

	if (g_firstzombie[victim])
	{
		if (!g_swarmround && !g_plagueround && !g_sniround && !g_survround && !g_samurairound)
		{
			fm_give_item(victim, "weapon_hegrenade")
		}
	}
	
	// Fancy effects
	infection_effects(victim)
	
	// Nemesis aura task
	if (g_nemesis[victim] && NemesisAura != 0)
	set_task(0.1, "zombie_aura", victim+TASK_AURA, _, _, "b")
	
	// Assassin aura task
	if (g_assassin[victim] && AssassinAura != 0)
	set_task(0.1, "zombie_aura", victim+TASK_AURA, _, _, "b")
	
	// Bombardier aura task
	if (g_bombardier[victim] && BombardierAura != 0)
	set_task(0.1, "zombie_aura", victim+TASK_AURA, _, _, "b")
	
	// Remove CS nightvision if player owns one (bugfix)
	if (cs_get_user_nvg(victim))
	{
		cs_set_user_nvg(victim, 0)
		if (CustomNightVision == 1) remove_task(victim+TASK_NVISION)
		else if (g_nvisionenabled[victim]) set_user_gnvision(victim, 0)
	}
	
	// Give Zombies Night Vision?
	if (NightVisionEnabled == 1)
	{
		g_nvision[victim] = true
		
		if (!g_isbot[victim])
		{
			// Turn on Night Vision automatically?
			if (NightVisionEnabled == 1)
			{
				g_nvisionenabled[victim] = true
				
				// Custom nvg?
				if (CustomNightVision == 1)
				{
					remove_task(victim+TASK_NVISION)
					set_task(0.1, "set_user_nvision", victim+TASK_NVISION, _, _, "b")
				}
				else
				set_user_gnvision(victim, 1)
			}
			// Turn off nightvision when infected (bugfix)
			else if (g_nvisionenabled[victim])
			{
				if (CustomNightVision == 1) remove_task(victim+TASK_NVISION)
				else set_user_gnvision(victim, 0)
				g_nvisionenabled[victim] = false
			}
		}
		else
		cs_set_user_nvg(victim, 1) // turn on NVG for bots
	}
	// Disable nightvision when infected (bugfix)
	else if (g_nvision[victim])
	{
		if (CustomNightVision == 1) remove_task(victim+TASK_NVISION)
		else if (g_nvisionenabled[victim]) set_user_gnvision(victim, 0)
		g_nvision[victim] = false
		g_nvisionenabled[victim] = false
	}
	
	// Set custom FOV?
	SetFOV(victim, ZombieFOV)
	
	// Call the bloody task
	if (!g_nemesis[victim] && !g_assassin[victim] && !g_bombardier[victim] && ZombieBleeding)
	set_task(0.7, "make_blood", victim+TASK_BLOOD, _, _, "b")
	
	// Idle sounds task
	if (!g_nemesis[victim] && !g_assassin[victim] && !g_bombardier[victim])
	set_task(random_float(50.0, 70.0), "zombie_play_idle", victim+TASK_BLOOD, _, _, "b")
	
	// Turn off zombie's flashlight
	turn_off_flashlight(victim)

	// Remove tasks
	if (task_exists(victim + TASK_CONCUSSION))
	remove_task(victim + TASK_CONCUSSION)

	// Show VIP
	if (g_bVip[victim])
	{
		Show_VIP()
	}

	// Reset some vars
	g_antidotebomb[victim] = 0
	g_concussionbomb[victim] = 0
	g_bubblebomb[victim] = 0
	g_killingbomb[victim] = 0
	if (g_multijump[victim])
	{
		g_jumpnum[victim] = 0
	}
	g_norecoil[victim] = false
	
	// Last Zombie Check
	fnCheckLastZombie()
}

// Function Human Me (player id, turn into a survivor, silent mode)
humanme(id, class)
{	
	set_zombie(id, false)		// For module

	// Remove previous tasks
	remove_task(id+TASK_MODEL)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	remove_task(id+TASK_NVISION)
	
	// Reset some vars
	g_zombie[id] = false
	g_nemesis[id] = false
	g_assassin[id] = false
	g_bombardier[id] = false		// Abhinash
	g_survivor[id] = false
	g_sniper[id] = false
	g_samurai[id] = false		// Abhinash
	g_tryder[id] = false
	g_specialclass[id] = false
	g_firstzombie[id] = false
	g_canbuy[id] = true
	g_buytime[id] = get_gametime()
	
	// Set class string
	g_cClass[id] = "Human"
	
	// Remove survivor's aura (bugfix)
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_INVLIGHT)
	
	// Remove spawn protection (bugfix)
	g_nodamage[id] = false
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_NODRAW)
	
	// Reset burning duration counter (bugfix)
	g_burning_duration[id] = 0
	
	// Remove CS nightvision if player owns one (bugfix)
	if (cs_get_user_nvg(id))
	{
		cs_set_user_nvg(id, 0)
		if (CustomNightVision == 1) remove_task(id+TASK_NVISION)
		else if (g_nvisionenabled[id]) set_user_gnvision(id, 0)
	}
	
	// Drop previous weapons
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	
	// Strip off from weapons
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
	
	// Set human attributes based on the mode
	if (class == survivor)
	{
		// Survivor
		g_survivor[id] = true
		g_specialclass[id] = true
		g_cClass[id] = "Survivor"
		
		// Set Health [0 = auto]
		set_user_health(id, SurvivorHealth)
		
		// Set gravity and glow, if frozen set the restore gravity value instead
		if (!g_frozen[id]) 
		{
			set_pev(id, pev_gravity, SurvivorGravity)

			// Set glow
			if(SurvivorGlow == 1)
			{
				set_glow(id, 0, 0, 255, 25)
			}
			else
			{
				remove_glow(id)
			}
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
	else if (class == sniper)
	{
		// Sniper
		g_sniper[id] = true
		g_specialclass[id] = true
		g_cClass[id] = "Sniper"
		
		// Set Health
		set_user_health(id, SniperHealth)

		// Set sniper maxspeed
		ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
		
		// Set gravity and glow, unless frozen
		if (!g_frozen[id]) 
		{
			set_pev(id, pev_gravity, SniperGravity)

			// Set glow
			if(SniperGlow == 1)
			{
				set_glow(id, 255, 255, 0, 25)
			}
			else
			{
				remove_glow(id)
			}
		}
		
		// Give sniper his own weapon		
		set_weapon(id, CSW_AWP, 200)
		set_weapon(id, CSW_DEAGLE, 1000)
		set_weapon(id, CSW_HEGRENADE, 5)
		
		// Turn off his flashlight
		turn_off_flashlight(id)
		
		// Give the sniper a bright light
		if (SniperAura == 1) 
		set_pev(id, pev_effects, pev(id, pev_effects) | EF_INVLIGHT)
		
		// Sniper bots will also need nightvision to see in the dark
		if (g_isbot[id])
		{
			g_nvision[id] = true
			cs_set_user_nvg(id, 1)
		}
	}
	// Abhinash
	else if (class == samurai)
	{
		// Samurai
		g_samurai[id] = true
		g_specialclass[id] = true
		g_cClass[id] = "Samurai"
		
		// Set Health [0 = auto]
		set_user_health(id, SamuraiHealth)

		// Set samurai maxspeed
		ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
		
		// Set gravity and glow, unless frozen
		if (!g_frozen[id]) 
		{
			set_pev(id, pev_gravity, SamuraiGravity)

			// Set glow
			if(SamuraiGlow == 1)
			{
				set_glow(id, 50, 100, 150, 25)
			}
			else
			{
				remove_glow(id)
			}
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
	// Tryder
	else if (class == tryder)
	{
		// Tryder
		g_tryder[id] = true
		g_specialclass[id] = false
		g_cClass[id] = "Tryder"
		
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
			if(TryderGlow == 1)
			{
				switch (random_num(0, 1))
				{
					case 0: set_glow(id, 155, 48, 255, 25)
					case 1: set_glow(id, 250, 10, 175, 25)
				}
			}
			else
			{
				remove_glow(id)
			}
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
	
	else if (class == none)
	{
		// Set health
		set_user_health(id, HumanHealth)
		
		// Set gravity, if frozen set the restore gravity value instead
		if (!g_frozen[id]) 
		{
			set_pev(id, pev_gravity, HumanGravity)
		}
		else 
		{
			g_frozen_gravity[id] = HumanGravity
		}
		
		// Set human maxspeed
		ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
		
		// Show custom buy menu
		set_task(0.2, "show_menu_buy1", id+TASK_SPAWN)
	}
	
	// Switch to CT
	if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
	{
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		fm_user_team_update(id)
	}
	

	// Set the right model, after checking that we don't already have it
	static Float:current_time
	current_time = get_gametime()
	
	if (current_time - g_models_targettime >= g_modelchange_delay)
	{
		ChangeModels(id+TASK_MODEL)
		g_models_targettime = current_time
	}
	else
	{
		set_task((g_models_targettime + g_modelchange_delay) - current_time, "ChangeModels", id+TASK_MODEL)
		g_models_targettime = g_models_targettime + g_modelchange_delay
	}
	
	// Restore FOV?
	SetFOV(id, 90)
	
	// Disable nightvision when turning into human/survivor (bugfix)
	if (g_nvision[id])
	{
		if (CustomNightVision == 1) 
		{
			remove_task(id+TASK_NVISION)
		}
		else if (g_nvisionenabled[id]) 
		{
			set_user_gnvision(id, 0)
		}
		g_nvision[id] = false
		g_nvisionenabled[id] = false
	}

	// Crossbow
	g_has_crossbow[id] = false
	
	// Last Zombie Check
	fnCheckLastZombie()
}

/*================================================================================
	[Other Functions and Tasks]
=================================================================================*/

public cache_cvars()
{
	g_cached_zombiesilent = ZombieSilentFootSteps
	g_cached_customflash = FlashLightEnabled
	g_cached_leapzombiescooldown = LeapZombiesCooldown
	g_cached_leapnemesis = LeapNemesis
	g_cached_leapnemesiscooldown = LeapNemesisCooldown
	g_cached_leapassassin = LeapAssassin
	g_cached_leapassassincooldown = LeapAssassinCooldown
	g_cached_leapsurvivor = LeapSurvivor
	g_cached_leapsurvivorcooldown = LeapSurvivorCooldown
	g_cached_leapsniper = LeapSniper
	g_cached_leapsnipercooldown = LeapSniperCooldown
	g_cached_leapzadoc = LeapSamurai		// Abhinash
	g_cached_leapzadoccooldown = LeapSamuraiCooldown
	g_cached_leapbombardier = LeapBombardier		// Abhinash
	g_cached_leapbombardiercooldown = LeapBombardierCooldown
}

// Register Ham Forwards for CZ bots
public register_ham_czbots(id)
{
	// Make sure it's a CZ bot and it's still connected
	if (g_hamczbots || !g_isconnected[id] || !get_pcvar_num(cvar_botquota))
	return
	
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
	static iPlayersnum
	iPlayersnum = fnGetPlaying()
	
	// No players, don't bother
	if (iPlayersnum < 1) return
	
	// Split players evenly
	static iTerrors, iMaxTerrors, id, team[33]
	iMaxTerrors = iPlayersnum/2
	iTerrors = 0
	
	// First, set everyone to CT
	for (id = 1; id <= g_maxplayers; id++)
	{
		// Skip if not connected
		if (!g_isconnected[id])
		continue
		
		team[id] = fm_cs_get_user_team(id)
		
		// Skip if not playing
		if (team[id] == FM_CS_TEAM_SPECTATOR || team[id] == FM_CS_TEAM_UNASSIGNED)
		continue
		
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
		if (!g_isconnected[id])
		continue
		
		// Skip if not playing or already a Terrorist
		if (team[id] != FM_CS_TEAM_CT)
		continue
		
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
	client_print_color(0, print_team_grey, "^1*** ^4PerfectZM.CsBlackDevil.com ^1|| ^3Zombie Queen UltimateX ^1***")
	client_print_color(0, print_team_grey, "Round: ^3%d ^4| ^1Map: ^3%s ^4| ^1Players: ^3%d^1/^3%d", g_roundcount, map, fnGetPlaying(), g_maxplayers)
	
	// Show T-virus HUD notice
	set_hudmessage(0, 125, 200, HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0, -1)
	ShowSyncHudMsg(0, g_MsgSync, "The T-Virus has been set loose...")
}

// Respawn Player Check Task (if killed by worldspawn)
public respawn_player_check_task(taskid)
{
	// Retrieve player index
	static id
	id = taskid - TASK_SPAWN
	// Successfully spawned or round ended
	if (g_isalive[id] || g_endround)
	return
	
	// Get player's team
	static team
	team = fm_cs_get_user_team(id)
	
	// Player moved to spectators
	if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
	return
	
	// If player was being spawned as a zombie, set the flag again
	if (g_zombie[id]) g_respawn_as_zombie[id] = true
	else g_respawn_as_zombie[id] = false
	
	respawn_player_manually(id)
}

// Respawn Player Manually (called after respawn checks are done)
respawn_player_manually(id)
{
	// Set proper team before respawning, so that the TeamInfo message that's sent doesn't confuse PODBots
	if (g_respawn_as_zombie[id])
	fm_cs_set_user_team(id, FM_CS_TEAM_T)
	else
	fm_cs_set_user_team(id, FM_CS_TEAM_CT)
	
	// Respawning a player has never been so easy
	ExecuteHamB(Ham_CS_RoundRespawn, id)
}

// Check Round Task -check that we still have both zombies and humans on a round-
check_round(leaving_player)
{
	// Round ended or make_a_zombie task still active
	if (g_endround || task_exists(TASK_MAKEZOMBIE))
	return
	
	// Get alive players count
	static iPlayersnum, id
	iPlayersnum = fnGetAlive()
	
	// Last alive player, don't bother
	if (iPlayersnum < 2)
	return
	
	// Last zombie disconnecting
	if (g_zombie[leaving_player] && fnGetZombies() == 1)
	{
		// Only one CT left, don't bother
		if (fnGetHumans() == 1 && fnGetCTs() == 1)
		return
		
		// Pick a random one to take his place
		while ((id = fnGetRandomAlive(random_num(1, iPlayersnum))) == leaving_player ) { /* keep looping */ }
		
		// Show last zombie left notice
		client_print_color(0, print_team_grey, "%s Last zombie has disconnected,^4 %s^1 is the last zombie!", CHAT_PREFIX, g_playername[id])
		// Turn into a Nemesis or just a zombie?
		if (g_nemesis[leaving_player])
		zombieme(id, 0, nemesis)
		else if (g_assassin[leaving_player])
		zombieme(id, 0, assassin)
		else if (g_bombardier[leaving_player])
		zombieme(id, 0, bombardier)
		else
		zombieme(id, 0, none)
		
		// If Nemesis, set chosen player's health to that of the one who's leaving
		if (KeepHealthOnDisconnect == 1 && g_nemesis[leaving_player])
		set_user_health(id, pev(leaving_player, pev_health))
		
		// If Assassin, set chosen player's health to that of the one who's leaving
		if (KeepHealthOnDisconnect == 1 && g_assassin[leaving_player])
		set_user_health(id, pev(leaving_player, pev_health))
		
		// If Bombardier, set chosen player's health to that of the one who's leaving
		if (KeepHealthOnDisconnect == 1 && g_bombardier[leaving_player])
		set_user_health(id, pev(leaving_player, pev_health))
	}
	
	// Last human disconnecting
	else if (!g_zombie[leaving_player] && fnGetHumans() == 1)
	{
		// Only one T left, don't bother
		if (fnGetZombies() == 1 && fnGetTs() == 1)
		return
		
		// Pick a random one to take his place
		while ((id = fnGetRandomAlive(random_num(1, iPlayersnum))) == leaving_player ) { /* keep looping */ }
		
		// Show last human left notice
		client_print_color(0, print_team_grey, "%s Last human has disconnected,^4 %s^1 is the last human!", CHAT_PREFIX, g_playername[id]);
		
		// Turn into a Survivor or just a human?
		if (g_survivor[leaving_player])
		humanme(id, survivor)
		else if (g_sniper[leaving_player])
		humanme(id, sniper)
		else if (g_samurai[leaving_player])		// Abhinash
		humanme(id, samurai)
		else
		humanme(id, none)
		
		// If Survivor, set chosen player's health to that of the one who's leaving
		if (KeepHealthOnDisconnect == 1 && g_survivor[leaving_player])
		set_user_health(id, pev(leaving_player, pev_health))
		
		// If Sniper, set chosen player's health to that of the one who's leaving
		if (KeepHealthOnDisconnect == 1 && g_sniper[leaving_player])
		set_user_health(id, pev(leaving_player, pev_health))
		
		// If Samurai, set chosen player's health to that of the one who's leaving			// Abhinash
		if (KeepHealthOnDisconnect == 1 && g_samurai[leaving_player])
		set_user_health(id, pev(leaving_player, pev_health))
	}
}

// Lighting Effects Task
public OnRegeneratorSkill()
{
	static id
	id = 1
	while (g_maxplayers + 1 > id)
	{
		if (g_isalive[id] && g_zombie[id] && !g_specialclass[id] && g_zombieclass[id] == 4 && pev(id, pev_health) < 6000)
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
		id += 1
	}
	return PLUGIN_CONTINUE
}

// Ambience Sound Effects Task
public ambience_sound_effects(taskid)
{
	if (g_nemround) // Nemesis Mode
	{
		PlaySound("PerfectZM/ambience_normal.wav")
	}
	else if (g_assaround) // Assassin Mode
	{
		PlaySound("PerfectZM/ambience_normal.wav")
	}
	else if (g_bombardierround) // Assassin Mode
	{
		PlaySound("PerfectZM/ambience_normal.wav")
	}
	else if (g_survround) // Survivor Mode
	{
		PlaySound("PerfectZM/ambience_normal.wav")
	}
	else if (g_sniround) // Sniper Mode
	{
		PlaySound("PerfectZM/ambience_normal.wav")
	}
	else if (g_samurairound) // Samurai Mode
	{
		PlaySound("PerfectZM/ambience_normal.wav")
	}
	else if (g_swarmround) // Swarm Mode
	{
		PlaySound("PerfectZM/ambience_normal.wav")
	}
	else if (g_plagueround) // Plague Mode
	{
		PlaySound("PerfectZM/ambience_normal.wav")
	}
	else if (g_armageround) // Armageddon Mode
	{
		PlaySound("PerfectZM/ambience_normal.wav")
	}
	else if (g_apocround) // Apocalypse Mode
	{
		PlaySound("PerfectZM/ambience_normal.wav")
	}
	else if (g_nightround) // Nightmare Mode
	{
		PlaySound("PerfectZM/ambience_normal.wav")
	}
	else if (g_devilround) // Nightmare Mode
	{
		PlaySound("PerfectZM/ambience_normal.wav")
	}
	else // Infection Mode
	{
		PlaySound("PerfectZM/ambience_normal.wav")
	}
}

// Ambience Sounds Stop Task
ambience_sound_stop()
{
	client_cmd(0, "mp3 stop; stopsound")
}

// Flashlight Charge Task
public ChargeFlashLight(taskid)
{
	// Retrieve player id
	static id
	id = taskid - TASK_CHARGE

	// Drain or charge?
	if (g_flashlight[id])
	g_flashbattery[id] -= FlashLightDrain
	else
	g_flashbattery[id] += FlashLightCharge
	
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
	static id
	id = taskid - TASK_SPAWN

	// Not alive
	if (!g_isalive[id])
	return
	
	// Remove spawn protection
	g_nodamage[id] = false
	set_pev(id, pev_effects, pev(id, pev_effects) & ~EF_NODRAW)
}

// Hide Player's Money Task
public task_hide_money(taskid)
{
	// Retrieve player index
	static id
	id = taskid - TASK_SPAWN

	// Not alive
	if (!g_isalive[id])
	return
	
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
	if (pev(id, pev_effects) & EF_DIMLIGHT)
	{
		// Turn it off
		set_pev(id, pev_impulse, IMPULSE_FLASHLIGHT)
	}
	else
	{
		// Clear any stored flashlight impulse (bugfix)
		set_pev(id, pev_impulse, 0)
	}
	
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
		remove_task(id+TASK_CHARGE)
		remove_task(id+TASK_FLASH)
	}
}

// Infection Bomb Explosion
infection_explode(ent)
{
	// Round ended (bugfix)
	if (g_endround) return
	
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Send TE_BEAMCYLINDER 
	SendGrenadeBeamCylinder(ent, 0, 200, 0, 200)
	
	// Infection nade explode sound
	emit_sound(ent, CHAN_WEAPON, grenade_infect[random(sizeof grenade_infect)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Get attacker
	static attacker
	attacker = pev(ent, pev_owner)
	
	// Infection bomb owner disconnected? (bugfix)
	if (!is_user_valid_connected(attacker))
	{
		// Get rid of the grenade
		engfunc(EngFunc_RemoveEntity, ent)
		return
	}
	
	// Collisions
	static victim
	victim = -1

	// Count
	new count
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive non-spawnprotected humans
		if (!is_user_valid_alive(victim) || g_zombie[victim] || g_nodamage[victim])
		continue
		
		// Last human is killed
		if (fnGetHumans() == 1)
		{
			ExecuteHamB(Ham_Killed, victim, attacker, 0)
			continue
		}
		
		// Infected victim's sound
		emit_sound(victim, CHAN_VOICE, grenade_infect_player[random(sizeof grenade_infect_player)], 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		SendDeathMsg(attacker, victim) // send death notice
		FixScoreAttrib(victim) // fix the "dead" attrib on scoreboard
		UpdateFrags(attacker, victim, ZombieRewardInfectFrags, 1, 1)
		g_ammopacks[attacker] += ZombieRewardInfectPacks // add corresponding frags & deaths	
		
		set_user_health(attacker, pev(attacker, pev_health) + 250) // infection HP bonus	
		
		// Turn into zombie
		zombieme(victim, attacker, none)

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
killing_explode(ent)
{
	// Round ended (bugfix)
	if (g_endround) return
	
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Send TE_BEAMCYLINDER 
	SendGrenadeBeamCylinder(ent, 128, 0, 255, 200)
	
	// Infection nade explode sound
	emit_sound(ent, CHAN_WEAPON, grenade_infect[random(sizeof grenade_infect)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Get attacker
	static attacker
	attacker = pev(ent, pev_owner)
	
	// Infection bomb owner disconnected? (bugfix)
	if (!is_user_valid_connected(attacker))
	{
		// Get rid of the grenade
		engfunc(EngFunc_RemoveEntity, ent)
		return
	}
	
	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		if (g_bombardier[attacker])
		{
			// Only effect alive non-spawnprotected humans
			if (!is_user_valid_alive(victim) || g_zombie[victim] || g_nodamage[victim])
			continue
			
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
			if (!is_user_valid_alive(victim) || !g_zombie[victim] || g_nodamage[victim])
			continue
			
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
	if (g_bombardier[attacker])
	fm_give_item(attacker, "weapon_hegrenade")
}

public concussion_explode(ent)
{
	// Round ended (bugfix)
	if (g_endround) return
	
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Send TE_BEAMCYLINDER 
	SendGrenadeBeamCylinder(ent, 0, 0, 255,200)
	
	// Infection nade explode sound
	emit_sound(ent, CHAN_WEAPON, grenade_infect[random(sizeof grenade_infect)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Get attacker
	static attacker
	attacker = pev(ent, pev_owner)
	
	// Infection bomb owner disconnected? (bugfix)
	if (!is_user_valid_connected(attacker))
	{
		// Get rid of the grenade
		engfunc(EngFunc_RemoveEntity, ent)
		return
	}

	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive non-spawnprotected humans
		if (!is_user_valid_alive(victim) || g_zombie[victim] || g_nodamage[victim])
		continue	
		
		// Continiously affect them
		set_task (0.2, "affect_victim", victim + TASK_CONCUSSION, _, _, "a", 35)
	}

	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Bubble bomb explode
public bubble_explode(ent)
{
	// Round ended (bugfix)
	if (g_endround) return

	// Get attacker
	static attacker
	attacker = pev(ent, pev_owner)
	
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
	if(!is_valid_ent(iEntity))
	return 
	
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
	if(is_valid_ent(iEntity))
	{
		new Float:vColor[3]
		for(new i; i < 3; i++)
		vColor[i] = random_float(0.0, 255.0)
		
		// Glow function
		entity_set_vector(iEntity, EV_VEC_rendercolor, vColor)
	}

	// Set task to remove the entity
	set_task(45.0, "DeleteEntityGrenade", iEntity)
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Remove entity function of Bubble Grenade
public DeleteEntityGrenade(entity) 
{
	if(is_valid_ent(entity))
	remove_entity(entity)
}

public antidote_explode(ent)
{
	// Round ended (bugfix)
	if (g_endround) return
	
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Send TE_BEAMCYLINDER 
	SendGrenadeBeamCylinder(ent, 255, 72, 0, 200)
	
	// Infection nade explode sound
	emit_sound(ent, CHAN_WEAPON, grenade_infect[random(sizeof grenade_infect)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Get attacker
	static attacker
	attacker = pev(ent, pev_owner)
	
	// Infection bomb owner disconnected? (bugfix)
	if (!is_user_valid_connected(attacker))
	{
		// Get rid of the grenade
		engfunc(EngFunc_RemoveEntity, ent)
		return
	}

	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive non-spawnprotected zombies
		if (!is_user_valid_alive(victim) || !g_zombie[victim] || g_nodamage[victim])
		continue

		// Last human is killed
		if (fnGetZombies() == 1)
		{
			continue
		}

		// Make them all human
		humanme(victim, none)
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// We are going to affect you
public affect_victim(taskid)
{
	// Retrieve index
	static id
	id = taskid - TASK_CONCUSSION

	// Dead
	if (!g_isalive[id])
	return
		
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
public explosion_explode(ent)
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
	write_short(g_Explode)
	write_byte(32)
	write_byte(16)
	write_byte(0)
	message_end()

	// Send TE_BEAMCYLINDER
	SendGrenadeBeamCylinder(ent, 255, 0, 0, 200)
	
	// Loop
	for(victim = 1 ; victim <= g_maxplayers; victim++)
	{
		if(!is_user_alive(victim))
		continue
		
		if(!g_zombie[victim])
		continue
		
		pev(victim, pev_origin, clorigin)
		distance = get_distance_f(origin, clorigin)
		if(distance < 330)
		{
			damage = 700.0 - distance
			health = get_user_health(victim)
			damage = float(floatround(damage))
			pev(victim , pev_velocity, clvelocity)
			clvelocity[0] += random_float(-230.0, 230.0)
			clvelocity[1] += random_float(-230.0, 230.0)
			clvelocity[2] += random_float(60.0, 129.0)
			set_pev(victim, pev_velocity, clvelocity)
			
			// Send Screenfade message
			UTIL_ScreenFade(victim, {200, 0, 0}, 1.0, 0.5, 100, FFADE_IN, true, false)
			
			// Play flatline sound on client
			client_cmd(victim, "spk fvox/flatline")
			
			// Send Screenshake message
			SendScreenShake(victim, 4096 * 6, 4096 * random_num(4, 12), 4096 * random_num(4, 12))

			if(g_nemesis[victim] || g_assassin[victim] || g_bombardier[victim]) 
			damage *= 1.50

			// Checks
			if(health - floatround(damage) > 0)
			{
				ExecuteHamB(Ham_TakeDamage, victim, ent, attacker, damage, DMG_BLAST)
			}
			else
			{
				ExecuteHamB(Ham_Killed, victim, attacker, 2)
			}
		}
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Fire Grenade Explosion
fire_explode(ent)
{
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Send TE_DLIGHT
	//SendGrenadeLight(200, 50, 0, 555, originF)
	
	// Send TE_BEAMCYLINDER 
	SendGrenadeBeamCylinder(ent, 255, 255, 0, 200)
	
	// Fire nade explode sound
	emit_sound(ent, CHAN_WEAPON, grenade_fire[random(sizeof grenade_fire)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive zombies
		if (!is_user_valid_alive(victim) || !g_zombie[victim] || g_nodamage[victim])
		continue
		
		// Set Yellow Rendering ( Glow ) on Victims.
		set_glow(victim, 200, 200, 0, 25)
		
		// Send ScreenFade message
		UTIL_ScreenFade(victim, {200, 200, 0}, 0.0, 0.0, 100, FFADE_STAYOUT, true, false)
		
		// Heat icon?
		if (HUDIcons == 1)
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
		
		if (g_nemesis[victim] || g_assassin[victim] || g_bombardier[victim]) // fire duration (nemesis is fire resistant)
		g_burning_duration[victim] += FireDuration
		else
		g_burning_duration[victim] += FireDuration * 5
		
		// Set burning task on victim if not present
		if (!task_exists(victim+TASK_BURN))
		set_task(0.2, "burning_flame", victim+TASK_BURN, _, _, "b")
		
		// Set a task to remove the burn effects from victim
		set_task(float(FireDuration), "remove_fire", victim)
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Frost Grenade Explosion
frost_explode(ent)
{
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Send TE_DLIGHT
	//SendGrenadeLight(0, 206, 209, 555, originF)
	
	// Send TE_BEAMCYLINDER 
	SendGrenadeBeamCylinder(ent, 0, 206, 209, 200)
	
	// Frost nade explode sound
	emit_sound(ent, CHAN_WEAPON, grenade_frost[random(sizeof grenade_frost)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive unfrozen zombies
		if (!is_user_valid_alive(victim) || !g_zombie[victim] || g_frozen[victim] || g_nodamage[victim])
		continue
		
		// Nemesis shouldn't be frozen
		if (g_nemesis[victim] || g_assassin[victim] || g_bombardier[victim])
		{
			// Get player's origin
			static origin2[3]
			get_user_origin(victim, origin2)
			
			// Broken glass sound
			emit_sound(victim, CHAN_BODY, grenade_frost_break[random(sizeof grenade_frost_break)], 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			// Glass shatter
			SendGlassBreak(victim)
			
			continue
		}
		
		// Freeze icon?
		if (HUDIcons == 1)
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
		emit_sound(victim, CHAN_BODY, grenade_frost_player[random(sizeof grenade_frost_player)], 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Add a blue tint to their screen
		UTIL_ScreenFade(victim, {0, 200, 200}, 0.0, 0.0, 100, FFADE_STAYOUT, true, false)
		
		// Set the frozen flag
		g_frozen[victim] = true
		
		// Save player's old gravity (bugfix)
		pev(victim, pev_gravity, g_frozen_gravity[victim])
		
		// Prevent from jumping
		if (pev(victim, pev_flags) & FL_ONGROUND)
		set_pev(victim, pev_gravity, 999999.9) // set really high
		else
		set_pev(victim, pev_gravity, 0.000001) // no gravity
		
		// Prevent from moving
		ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)
		
		// Set a task to remove the freeze
		set_task(FrostDuration, "remove_freeze", victim)
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Remove freeze task
public remove_freeze(id)
{
	// Not alive or not frozen anymore
	if (!g_isalive[id] || !g_frozen[id])
	return
	
	// Unfreeze
	g_frozen[id] = false
	
	// Restore gravity and maxspeed (bugfix)
	set_pev(id, pev_gravity, g_frozen_gravity[id])
	ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
	
	// Nemesis or Survivor glow / remove glow
	if (g_nemesis[id])
	{
		if(NemesisGlow == 1)
		{ 
			set_glow(id, 250, 0, 0, 25)
		}
		else
		{ 
			remove_glow(id)
		}
	}
	else if (g_assassin[id])
	{
		if(AssassinGlow == 1)
		{
			set_glow(id, 255, 255, 0, 25)
		}
		else
		{
			remove_glow(id)
		}
	}
	else if (g_survivor[id])
	{
		if(SurvivorGlow == 1)
		{
			set_glow(id, 0, 0, 255, 25)
		}
		else
		{
			remove_glow(id)
		}
	}
	
	else if (g_sniper[id])
	{ 
		if(SniperGlow == 1)
		{ 
			set_glow(id, 0, 255, 0, 25)
		}
		else
		{
			remove_glow(id)
		}
	}
	else if (g_samurai[id])
	{
		if(SamuraiGlow == 1)
		{
			set_glow(id, 50, 100, 150, 25)
		}
		else
		{
			remove_glow(id)
		}
	}
	else if (g_bombardier[id])
	{
		if(BombardierGlow == 1)
		{
			set_glow(id, 50, 100, 150, 25)
		}
		else
		{
			remove_glow(id)
		}
	}
	else
	{
		remove_glow(id)
	}
	
	// Gradually remove screen's blue tint
	UTIL_ScreenFade(id, {0, 200, 200}, 1.0, 0.0, 100, FFADE_IN, true, false)
	
	// Broken glass sound
	emit_sound(id, CHAN_BODY, grenade_frost_break[random(sizeof grenade_frost_break)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Glass shatter
	SendGlassBreak(id)
}

// Remove fire task
public remove_fire(id)
{
	// Not alive or not frozen anymore
	if (!g_isalive[id])
	return
	
	// Nemesis or Survivor glow / remove glow
	if (g_nemesis[id])
	{
		if(NemesisGlow == 1)
		{ 
			set_glow(id, 250, 0, 0, 25)
		}
		else
		{ 
			remove_glow(id)
		}
	}
	else if (g_assassin[id])
	{
		if(AssassinGlow == 1)
		{
			set_glow(id, 255, 255, 0, 25)
		}
		else
		{
			remove_glow(id)
		}
	}
	else if (g_survivor[id])
	{
		if(SurvivorGlow == 1)
		{
			set_glow(id, 0, 0, 255, 25)
		}
		else
		{
			remove_glow(id)
		}
	}
	
	else if (g_sniper[id])
	{ 
		if(SniperGlow == 1)
		{ 
			set_glow(id, 0, 255, 0, 25)
		}
		else
		{
			remove_glow(id)
		}
	}
	else if (g_samurai[id])
	{
		if(SamuraiGlow == 1)
		{
			set_glow(id, 50, 100, 150, 25)
		}
		else
		{
			remove_glow(id)
		}
	}
	else if (g_bombardier[id])
	{
		if(BombardierGlow == 1)
		{
			set_glow(id, 50, 100, 150, 25)
		}
		else
		{
			remove_glow(id)
		}
	}
	else
	{
		remove_glow(id)
	}
	
	// Gradually remove screen fade
	UTIL_ScreenFade(id, {200, 200, 0}, 1.0, 0.0, 100, FFADE_IN, true, false)
}

// Set Custom Weapon Models
replace_weapon_models(id, weaponid)
{
	switch (weaponid)
	{
	case CSW_KNIFE: // Custom knife models
		{
			if (g_zombie[id])
			{
				if (g_nemesis[id]) // Nemesis
				{
					set_pev(id, pev_viewmodel2, V_KNIFE_NEMESIS)
					set_pev(id, pev_weaponmodel2, "")
				}
				else if (g_assassin[id]) // Assassins
				{
					set_pev(id, pev_viewmodel2, V_KNIFE_ASSASSIN)
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
				if(g_samurai[id])
				{
					set_pev(id, pev_viewmodel2, V_KNIFE_SAMURAI)
					set_pev(id, pev_weaponmodel2, P_KNIFE_SAMURAI)
				}
				else
				{
					set_pev(id, pev_viewmodel2, V_KNIFE_HUMAN)
					set_pev(id, pev_weaponmodel2, P_KNIFE_HUMAN)
				}
				if (get_user_jetpack(id))
				{
					set_jetpack(id)		// Native from module
				}
			}
		}
	case CSW_AWP: // Sniper's AWP
		{
			if (g_sniper[id])
			{
				set_pev(id, pev_viewmodel2, V_AWP_SNIPER)
				set_pev(id, pev_weaponmodel2, P_AWP_SNIPER)
			}
		}
	case CSW_SG550:		// Crossbow
		{
			if(g_has_crossbow[id])
			{
				set_pev(id, pev_viewmodel2, crossbow_V_MODEL)
				set_pev(id, pev_weaponmodel2, crossbow_P_MODEL)
				set_pdata_float(id, 83, 1.0, OFFSET_LINUX)
			}
		}
	case CSW_AK47:
		{
			if (g_goldenak47[id])
			{
				set_goldenak47(id)
			}
		}  
	case CSW_M4A1:
		{
			if (g_goldenm4a1[id])
			{
				set_goldenm4a1(id)
			}
		}
	case CSW_XM1014:
		{
			if (g_goldenxm1014[id])
			{
				set_goldenxm1014(id)
			}
		}
	case CSW_DEAGLE:
		{
			if (g_goldendeagle[id])
			{
				set_goldendeagle(id)
			}
		}   
	case CSW_HEGRENADE: // Infection bomb or Explode grenade
		{
			if (g_zombie[id])
			set_pev(id, pev_viewmodel2, V_INFECTION_NADE)
			else
			set_pev(id, pev_viewmodel2, V_EXPLODE_NADE)
		}
	case CSW_FLASHBANG: // Fire grenade
		{
			set_pev(id, pev_viewmodel2, V_FIRE_NADE)
		}
	case CSW_SMOKEGRENADE: // Frost grenade
		{
			set_pev(id, pev_viewmodel2, V_FROST_NADE)
		}
	}
}

// Reset Player Vars
reset_vars(id, resetall)
{
	g_zombie[id] = false
	g_nemesis[id] = false
	g_assassin[id] = false		// Abhinash
	g_bombardier[id] = false
	g_survivor[id] = false
	g_sniper[id] = false
	g_samurai[id] = false 		// Abhinash
	g_tryder[id] = false
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
	g_has_crossbow[id] = false
	g_norecoil[id] = false
	set_zombie(id, false)
	
	if (resetall)
	{
		g_zombieclass[id] = -1
		g_zombieclassnext[id] = -1
		g_damagedealt_human[id] = 0
		g_damagedealt_zombie[id] = 0
		g_goldenak47[id] = false
		g_goldenm4a1[id] = false
		g_goldenxm1014[id] = false
		g_goldendeagle[id] = false
		PL_ACTION = 0
	}
}

// Set spectators nightvision
public spec_nvision(id)
{
	// Not connected, alive, or bot
	if (!g_isconnected[id] || g_isalive[id] || g_isbot[id])
	return
	
	// Give Night Vision?
	if (NightVisionEnabled == 1)
	{
		g_nvision[id] = true
		
		// Turn on Night Vision automatically?
		if (NightVisionEnabled == 1)
		{
			g_nvisionenabled[id] = true
			
			// Custom nvg?
			if (CustomNightVision == 1)
			{
				remove_task(id+TASK_NVISION)
				set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
			}
			else
			set_user_gnvision(id, 1)
		}
	}
}

// Show HUD Task
public ShowHUD(taskid)
{
	static id
	id = ID_SHOWHUD
	
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
	
	if (g_zombie[id]) // zombies
	{
		red   = 255
		green = 50
		blue  = 0
		
		formatex(message, charsmax(message), "%s - Health: %s - Packs: %s - Points: %s", g_cClass[ID_SHOWHUD], AddCommas(pev(ID_SHOWHUD, pev_health)), AddCommas(g_ammopacks[ID_SHOWHUD]), AddCommas(g_points[ID_SHOWHUD]))
	}	
	else // humans
	{
		red   = 10
		green = 180
		blue  = 150
		
		formatex(message, charsmax(message), "%s - Health: %s - Armor: %d - Packs: %s - Points: %s", g_cClass[ID_SHOWHUD], AddCommas(pev(ID_SHOWHUD, pev_health)), pev(ID_SHOWHUD, pev_armorvalue), AddCommas(g_ammopacks[ID_SHOWHUD]), AddCommas(g_points[ID_SHOWHUD]))
	}
	
	// Spectating someone else?
	if (id != ID_SHOWHUD)
	{
		set_hudmessage(10, 180, 150, -1.0, 0.79, 0, 6.0, 1.1, 0.0, 0.0, -1)
		ShowSyncHudMsg(ID_SHOWHUD, g_MsgSync2, "Spectating %s %s^n%s - Health: %s - Armor: %d - Packs: %s - Points: %s^nFrom: %s, %s", \
		g_bVip[id] ? "(Gold Member ®)" : "", g_playername[id], g_cClass[id], AddCommas(pev(id, pev_health)), pev(id, pev_armorvalue), AddCommas(g_ammopacks[id]), AddCommas(g_points[id]), g_playercountry[id], g_playercity[id])
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
	static id
	id = taskid - TASK_BLOOD

	// Round ended/new one starting
	if (g_endround || g_newround)
	return
	
	// Last zombie?
	if (g_lastzombie[id])
	{
		emit_sound(id, CHAN_VOICE, zombie_idle_last[random(sizeof zombie_idle_last)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	else
	{
		emit_sound(id, CHAN_VOICE, zombie_idle[random(sizeof zombie_idle)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
}

// Madness Over Task
public madness_over(taskid)
{
	//Retrieve player index
	static id
	id = taskid - TASK_BLOOD

	g_nodamage[id] = false
	remove_glow(id)
}

// NeO's set weapon function
set_weapon(id , iWeaponTypeID , iClip=0)
{
	if (!(CSW_P228 <= iWeaponTypeID <= CSW_P90) || !is_user_alive(id))
	return -1
	
	new szWeaponName[20] , iWeaponEntity , bool:bIsGrenade
	
	const GrenadeBits = ((1 << CSW_HEGRENADE) | (1 << CSW_FLASHBANG) | (1 << CSW_SMOKEGRENADE) | (1 << CSW_C4))
	
	if ((bIsGrenade = bool:!!(GrenadeBits & (1 << iWeaponTypeID))))
	iClip = clamp(iClip ? iClip : 10000 , 1)
	
	get_weaponname(iWeaponTypeID, szWeaponName, charsmax(szWeaponName))
	
	if ((iWeaponEntity = user_has_weapon(id, iWeaponTypeID) ? find_ent_by_owner(-1, szWeaponName, id) : give_item(id, szWeaponName)) > 0)
	{
		if (iWeaponTypeID != CSW_KNIFE)
		{
			if (!iClip && !bIsGrenade)
			{
				cs_set_weapon_ammo(iWeaponEntity, 10000)
			}
			else if(iClip && !bIsGrenade)
			{
				cs_set_user_bpammo(id, iWeaponTypeID, iClip)
				
				if (iWeaponTypeID == CSW_C4) 
				cs_set_user_plant(id, 1, 1)
			}
			else if (iClip && bIsGrenade)
			{
				cs_set_user_bpammo(id, iWeaponTypeID, iClip)
			}
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
		if (g_isalive[id] && g_zombie[id])
		iZombies++
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
		if (g_isalive[id] && !g_zombie[id])
		iHumans++
	}
	
	return iHumans
}

// Get Nemesis -returns alive nemesis number-
/*fnGetNemesis()
{
	static iNemesis, id
	iNemesis = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_nemesis[id])
		iNemesis++
	}
	
	return iNemesis
}

// Get Assassin -returns alive assassin number-
fnGetAssassin()
{
	static iAssassin, id
	iAssassin = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_assassin[id])
		iAssassin++
	}
	
	return iAssassin
}

// Bombardier -- Abhinash
// Get Bombardier -returns alive bombardier number-
fnGetBombardier()
{
	static iBombardier, id
	iBombardier = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_bombardier[id])
		iBombardier++
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
		if (g_isalive[id] && g_survivor[id])
		iSurvivors++
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
		if (g_isalive[id] && g_sniper[id])
		iSnipers++
	}
	
	return iSnipers
}

// Abhinash
// Get Samurai -returns alive Samurai number-
fnGetSamurai()
{
	static iSamurai, id
	iSamurai = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_samurai[id])
		iSamurai++
	}
	
	return iSamurai
}*/

// Get Alive -returns alive players number-
fnGetAlive()
{
	static iAlive, id
	iAlive = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
		iAlive++
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
		if (g_isalive[id])
		iAlive++
		
		if (iAlive == n)
		return id
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
			
			if (team != FM_CS_TEAM_SPECTATOR && team != FM_CS_TEAM_UNASSIGNED)
			iPlaying++
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
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_CT)
			iCTs++
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
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_T)
			iTs++
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
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_CT)
			iCTs++
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
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_T)
			iTs++
		}
	}
	
	return iTs
}

fnGetLastHuman()
{
	new id = 1
	while (id <= g_maxplayers)
	{
		if (g_isalive[id] && g_isconnected[id] && !g_zombie[id])
		{
			return id
		}
		id++
	}
	return PLUGIN_CONTINUE
}

fnGetLastZombie()
{
	new id = 1
	while (id <= g_maxplayers)
	{
		if (g_isalive[id] && g_isconnected[id] && g_zombie[id])
		{
			return id
		}
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
		if (g_isalive[id] && g_zombie[id] && !g_nemesis[id] && !g_assassin[id] && !g_bombardier[id] && fnGetZombies() == 1)
		{
			g_lastzombie[id] = true
		}
		else
		{
			g_lastzombie[id] = false
		}
		
		// Last human
		if (g_isalive[id] && !g_zombie[id] && !g_survivor[id] && !g_sniper[id] && !g_samurai[id] && fnGetHumans() == 1)
		{
			if (!g_lasthuman[id])
			{
				// Reward extra hp
				set_user_health(id, pev(id, pev_health) + LastHumanExtraHealth)
			}
			g_lasthuman[id] = true
		}
		else
		g_lasthuman[id] = false
	}
}

// Save player's stats to database
SaveStatistics(id)
{
	// Check whether there is another record already in that slot
	if (db_name[id][0] && !equal(g_playername[id], db_name[id]))
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
	copy(db_name[id], charsmax(db_name[]), g_playername[id]) // name
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
		if (equal(g_playername[id], db_name[i]))
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
	if ((g_zombie[id] && !g_nemesis[id] && !g_assassin[id] && !g_bombardier[id]) || g_endround || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to be human
allowed_human(id)
{
	if ((!g_zombie[id] && !g_survivor[id] && !g_sniper[id] && !g_samurai[id]) || g_endround || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to be survivor
allowed_survivor(id)
{
	if (g_endround || g_survivor[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to be sniper
allowed_sniper(id)
{
	if (g_endround || g_sniper[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
	return false
	
	return true
}

// Abhinash
// Checks if a player is allowed to be sniper
allowed_samurai(id)
{
	if (g_endround || g_samurai[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to be nemesis
allowed_nemesis(id)
{
	if (g_endround || g_nemesis[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to be assassin
allowed_assassin(id)
{
	if (g_endround || g_assassin[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
	return false
	
	return true
}

// Checks if a player is allowed to be bombardier
allowed_bombardier(id)
{
	if (g_endround || g_bombardier[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
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
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround(fnGetAlive()*MultiInfectionRatio, floatround_ceil) < 2 || floatround(fnGetAlive()*MultiInfectionRatio, floatround_ceil) >= fnGetAlive())
	return false
	
	return true
}

// Checks if plague mode is allowed
allowed_plague()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround((fnGetAlive()-(PlagueNemesisCount+PlagueSurvivorCount))*PlagueRatio, floatround_ceil) < 1
			|| fnGetAlive()-(PlagueSurvivorCount+PlagueNemesisCount+floatround((fnGetAlive()-(PlagueNemesisCount+PlagueSurvivorCount))*PlagueRatio, floatround_ceil)) < 1)
	return false
	
	return true
}

// Checks if armageddon mode is allowed
allowed_armageddon()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround(fnGetAlive()*ArmageddonRatio, floatround_ceil) < 2 || floatround(fnGetAlive()*ArmageddonRatio, floatround_ceil) >= fnGetAlive())
	return false
	
	return true
}

// Checks if apocalypse mode is allowed
allowed_apocalypse()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround(fnGetAlive()*ApocalypseRatio, floatround_ceil) < 2 || floatround(fnGetAlive()*ApocalypseRatio, floatround_ceil) >= fnGetAlive())
	return false
	
	return true
}

// Checks if nightmare mode is allowed
allowed_nightmare()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround(fnGetAlive()*NightmareRatio, floatround_ceil) < 2 || floatround(fnGetAlive()*NightmareRatio, floatround_ceil) >= fnGetAlive())
	return false
	
	return true
}

// Abhinash
// Checks if devil mode is allowed
allowed_devil()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround(fnGetAlive()*DevilRatio, floatround_ceil) < 2 || floatround(fnGetAlive()*DevilRatio, floatround_ceil) >= fnGetAlive())
	return false
	
	return true
}

CanBuyItem(id, item)
{
	switch(item)
	{
		case nightvision:
		{
			return true
		}
		case explosion_nade:
		{
			return true
		}
		case napalm_nade:
		{
			return true
		}
		case forcefield_nade:
		{
			return true
		}
		case frost_nade:
		{
			return true
		}
		case killing_nade:
		{
			if (g_nemround || g_assaround || g_bombardierround || g_swarmround || g_plagueround)
			{
				return false
			}
			else
			{
				if (LIMIT[id][KILL_NADE] == 2)
				{
					client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
					return false
				}
				else
				{
					return true
				}
			}
		}
		case antidote_nade:
		{
			if (g_nemround || g_assaround || g_bombardierround || g_swarmround || g_plagueround)
			{
				return false
			}
			else
			{
				if (LIMIT[id][ANTIDOTE_NADE] == 2)
				{
					client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
					return false
				}
				else
				{
					return true
				}
			}
		}
		case infection_nade:
		{
			if (g_endround || g_swarmround || g_nemround || g_assaround || g_survround || g_sniround || g_plagueround || g_armageround || g_apocround || g_nightround)
			{
				return false
			}
			else
			{
				return true
			}
		}
		case concussion_nade:
		{
			return true
		}
		case unlimitedclip:
		{
			return true
		}
		case multijump:
		{
			return true
		}
		case jetpack:
		{
			return true
		}
		case tryder:
		{
			if (LIMIT[id][TRYDER] == 2)
			{
				client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
				return false
			}
			else
			{
				return true
			}
		}
		case armor100:
		{
			return true
		}
		case armor200:
		{
			return true
		}
		case crossbow:
		{
			return true
		}
		case goldenak:
		{
			return true
		}
		case goldenm4:
		{
			return true
		}
		case goldenxm:
		{
			return true
		}
		case goldendeagle:
		{
			return true
		}
		case antidote:
		{
			if (g_endround || g_swarmround || g_nemround || g_assaround || g_survround || g_samurairound || g_sniround || g_plagueround || g_armageround || g_apocround || g_nightround || fnGetZombies() <= 1)
			{
				return false
			}
			else
			{
				return true
			}
		}
		case madness:
		{
			if (g_nodamage[id])
			{
				return false
			}
			else
			{
				return true
			}
		}
		case knifeblink:
		{
			return true
		}
		case godmode:
		{
			if (g_endround || g_swarmround || g_nemround || g_assaround || g_survround || g_sniround || g_plagueround)
			{
				client_print_color(id, print_team_grey, "%s This item is not available in current round", CHAT_PREFIX)
				return false
			}
			else if (g_sniper[id] || g_survivor[id])
			{
				return true
			}
			else
			{
				client_print_color(id, print_team_grey, "%s This item is not for %s", CHAT_PREFIX, g_cClass[id])
				return false
			}
		}
		case doubledamage:
		{
			if (g_zombie[id] || g_nemesis[id] || g_assassin[id] || g_bombardier[id])
			{
				client_print_color(id, print_team_grey, "%s This item is not for %s", CHAT_PREFIX, g_cClass[id])
				return false
			}
			else
			{
				return true
			}	
		}
		case norecoil:
		{
			if (g_zombie[id] || g_nemesis[id] || g_assassin[id] || g_bombardier[id])
			{
				client_print_color(id, print_team_grey, "%s This item is not for %s", CHAT_PREFIX, g_cClass[id])
				return false
			}
			else
			{
				return true
			}
		}
		case invisibility:
		{
			if (g_zombie[id] || g_nemesis[id] || g_assassin[id] || g_bombardier[id])
			{
				client_print_color(id, print_team_grey, "%s This item is not for %s", CHAT_PREFIX, g_cClass[id])
				return false
			}
			else
			{
				return true
			}
		}
		case sprint:
		{
			if (g_zombie[id] || g_nemesis[id] || g_assassin[id] || g_bombardier[id])
			{
				client_print_color(id, print_team_grey, "%s This item is not for %s", CHAT_PREFIX, g_cClass[id])
				return false
			}
			else
			{
				return true
			}
		}
		case lowgravity:
		{
			if (g_zombie[id] || g_nemesis[id] || g_assassin[id] || g_bombardier[id])
			{
				client_print_color(id, print_team_grey, "%s This item is not for %s", CHAT_PREFIX, g_cClass[id])
				return false
			}
			else
			{
				return true
			}
		}
		case headhunter:
		{
			if (g_zombie[id] || g_nemesis[id] || g_assassin[id] || g_bombardier[id])
			{
				client_print_color(id, print_team_grey, "%s This item is not for %s", CHAT_PREFIX, g_cClass[id])
				return false
			}
			else
			{
				return true
			}
		}
		case nightcrawler:
		{
			return true
		}
		case synapsis:
		{
			return true
		}
		case sonic_vs_shadow:
		{
			return true
		}
		case nemesis:
		{
			if (g_modestarted ||  g_endround)
			{
				client_print_color(id, print_team_grey, "%s You cannot ^4buy mode ^1right now", CHAT_PREFIX)
				return false
			}
			else
			{
				if (g_roundcount > 10)
				{
					if (LIMIT[id][MODES] == 1)
					{
						client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
						return false
					}
					else if (g_lastmode != infection)
					{
						client_print_color(id, print_team_grey, "%s You must wait ^4one ^1more round to buy a mode.", CHAT_PREFIX)
						return false
					}
					else
					{
						return true
					}
				}
				else
				{
					client_print_color(id, print_team_grey, "%s You must wait till round^3 10 ^1to buy a ^4mode.", CHAT_PREFIX)
					return false
				}
			}
		}
		case assassin:
		{
			if (g_modestarted ||  g_endround)
			{
				client_print_color(id, print_team_grey, "%s You cannot ^4buy mode ^1right now", CHAT_PREFIX)
				return false
			}
			else
			{
				if (g_roundcount > 10)
				{
					if (LIMIT[id][MODES] == 1)
					{
						client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
						return false
					}
					else if (g_lastmode != infection)
					{
						client_print_color(id, print_team_grey, "%s You must wait ^4one ^1more round to buy a mode.", CHAT_PREFIX)
						return false
					}
					else
					{
						return true
					}
				}
				else
				{
					client_print_color(id, print_team_grey, "%s You must wait till round^3 10 ^1to buy a ^4mode.", CHAT_PREFIX)
					return false
				}
			}
		}
		case sniper:
		{
			if (g_modestarted ||  g_endround)
			{
				client_print_color(id, print_team_grey, "%s You cannot ^4buy mode ^1right now", CHAT_PREFIX)
				return false
			}
			else
			{
				if (g_roundcount > 10)
				{
					if (LIMIT[id][MODES] == 1)
					{
						client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
						return false
					}
					else if (g_lastmode != infection)
					{
						client_print_color(id, print_team_grey, "%s You must wait ^4one ^1more round to buy a mode.", CHAT_PREFIX)
						return false
					}
					else
					{
						return true
					}
				}
				else
				{
					client_print_color(id, print_team_grey, "%s You must wait till round^3 10 ^1to buy a ^4mode.", CHAT_PREFIX)
					return false
				}
			}
		}
		case survivor:
		{
			if (g_modestarted ||  g_endround)
			{
				client_print_color(id, print_team_grey, "%s You cannot ^4buy mode ^1right now", CHAT_PREFIX)
				return false
			}
			else
			{
				if (g_roundcount > 10)
				{
					if (LIMIT[id][MODES] == 1)
					{
						client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
						return false
					}
					else if (g_lastmode != infection)
					{
						client_print_color(id, print_team_grey, "%s You must wait ^4one ^1more round to buy a mode.", CHAT_PREFIX)
						return false
					}
					else
					{
						return true
					}
				}
				else
				{
					client_print_color(id, print_team_grey, "%s You must wait till round^3 10 ^1to buy a ^4mode.", CHAT_PREFIX)
					return false
				}
			}
		}
		case armageddon:
		{
			if (g_modestarted ||  g_endround)
			{
				client_print_color(id, print_team_grey, "%s You cannot ^4buy mode ^1right now", CHAT_PREFIX)
				return false
			}
			else
			{
				if (g_roundcount > 10)
				{
					if (LIMIT[id][CUSTOM_MODES] == 1)
					{
						client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
						return false
					}
					else if (g_lastmode != infection)
					{
						client_print_color(id, print_team_grey, "%s You must wait ^4one ^1more round to buy a mode.", CHAT_PREFIX)
						return false
					}
					else
					{
						return true
					}
				}
				else
				{
					client_print_color(id, print_team_grey, "%s You must wait till round^3 10 ^1to buy a ^4mode.", CHAT_PREFIX)
					return false
				}
			}
		}
		case nightmare:
		{
			if (g_modestarted ||  g_endround)
			{
				client_print_color(id, print_team_grey, "%s You cannot ^4buy mode ^1right now", CHAT_PREFIX)
				return false
			}
			else
			{
				if (g_roundcount > 10)
				{
					if (LIMIT[id][CUSTOM_MODES] == 1)
					{
						client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
						return false
					}
					else if (g_lastmode != infection)
					{
						client_print_color(id, print_team_grey, "%s You must wait ^4one ^1more round to buy a mode.", CHAT_PREFIX)
						return false
					}
					else
					{
						return true
					}
				}
				else
				{
					client_print_color(id, print_team_grey, "%s You must wait till round^3 10 ^1to buy a ^4mode.", CHAT_PREFIX)
					return false
				}
			}
		}
		case devil:
		{
			if (g_modestarted ||  g_endround)
			{
				client_print_color(id, print_team_grey, "%s You cannot ^4buy mode ^1right now", CHAT_PREFIX)
				return false
			}
			else
			{
				if (g_roundcount > 10)
				{
					if (LIMIT[id][CUSTOM_MODES] == 1)
					{
						client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
						return false
					}
					else if (g_lastmode != infection)
					{
						client_print_color(id, print_team_grey, "%s You must wait ^4one ^1more round to buy a mode.", CHAT_PREFIX)
						return false
					}
					else
					{
						return true
					}
				}
				else
				{
					client_print_color(id, print_team_grey, "%s You must wait till round^3 10 ^1to buy a ^4mode.", CHAT_PREFIX)
					return false
				}
			}
		}
		case apocalypse:
		{
			if (g_modestarted ||  g_endround)
			{
				client_print_color(id, print_team_grey, "%s You cannot ^4buy mode ^1right now", CHAT_PREFIX)
				return false
			}
			else
			{
				if (g_roundcount > 10)
				{
					if (LIMIT[id][CUSTOM_MODES] == 1)
					{
						client_print_color(id, print_team_grey, "%s You have reached the limit, you can again buy in next map", CHAT_PREFIX)
						return false
					}
					else if (g_lastmode != infection)
					{
						client_print_color(id, print_team_grey, "%s You must wait ^4one ^1more round to buy a mode.", CHAT_PREFIX)
						return false
					}
					else
					{
						return true
					}
				}
				else
				{
					client_print_color(id, print_team_grey, "%s You must wait till round^3 10 ^1to buy a ^4mode.", CHAT_PREFIX)
					return false
				}
			}
		}
		case shoppacks:
		{
			if (LIMIT[id][PACKS] == 1)
			{
				client_print_color(id, print_team_grey, "%s You can only buy packs once a round.", CHAT_PREFIX)
				return false
			}
			else
			{
				return true
			}
		}
	}
	return true
}

// Abhinash's custom built LogToFile() Funtion
LogToFile(admin, target, action)
{
	static logdata[100], authid[32], ip[16]
	get_user_authid(admin, authid, charsmax(authid))
	get_user_ip(admin, ip, charsmax(ip), 1)
	switch (action)
	{
		case zombie 	: formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Zombie. (Players: %d/%d)", g_playername[admin], authid, ip, g_playername[target], fnGetPlaying(), g_maxplayers)
		case human 		: formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Human. (Players: %d/%d)", g_playername[admin], authid, ip, g_playername[target], fnGetPlaying(), g_maxplayers)
		case nemesis 	: formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Nemesis. (Players: %d/%d)", g_playername[admin], authid, ip, g_playername[target], fnGetPlaying(), g_maxplayers)
		case assassin   : formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Assassin. (Players: %d/%d)", g_playername[admin], authid, ip, g_playername[target], fnGetPlaying(), g_maxplayers)
		case bombardier : formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Bombardier. (Players: %d/%d)", g_playername[admin], authid, ip, g_playername[target], fnGetPlaying(), g_maxplayers)
		case sniper  	: formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Sniper. (Players: %d/%d)", g_playername[admin], authid, ip, g_playername[target], fnGetPlaying(), g_maxplayers)
		case survivor 	: formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Survivor. (Players: %d/%d)", g_playername[admin], authid, ip, g_playername[target], fnGetPlaying(), g_maxplayers)
		case samurai 	: formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] made %s a Samurai. (Players: %d/%d)", g_playername[admin], authid, ip, g_playername[target], fnGetPlaying(), g_maxplayers)
		case multi 		: formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Multi-infection mode. (Players: %d/%d)", g_playername[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case swarm 		: formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Swarm mode. (Players: %d/%d)", g_playername[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case plague 	: formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Plague mode. (Players: %d/%d)", g_playername[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case armageddon : formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Armageddon mode. (Players: %d/%d)", g_playername[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case nightmare  : formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Nightmare mode. (Players: %d/%d)", g_playername[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case apocalypse : formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Sniper vs Assassin mode. (Players: %d/%d)", g_playername[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case devil 		: formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] started Sniper vs Nemesis mode. (Players: %d/%d)", g_playername[admin], authid, ip, fnGetPlaying(), g_maxplayers)
		case respawn 	: formatex(logdata, charsmax(logdata), "Admin %s [ %s ][ %s ] respawned %s. (Players: %d/%d)", g_playername[admin], authid, ip, g_playername[target], fnGetPlaying(), g_maxplayers)
	}
	log_to_file("ZombieQueen.log", logdata)
}

// Set proper maxspeed for player
set_player_maxspeed(id)
{
	// If frozen, prevent from moving
	if (g_frozen[id])
	{
		set_pev(id, pev_maxspeed, 20.0)
	}
	else if (g_raptor_speeded[id])
	{
		set_pev(id, pev_maxspeed, 500.0)
	}
	else
	{
		if (g_zombie[id])
		{
			if (g_nemesis[id])
			set_pev(id, pev_maxspeed, NemesisSpeed)
			else if (g_assassin[id])
			set_pev(id, pev_maxspeed, AssassinSpeed)
			else if (g_bombardier[id])
			set_pev(id, pev_maxspeed, BombardierSpeed)
			else
			set_pev(id, pev_maxspeed, g_cZombieClasses[g_zombieclass[id]][Speed])
		}
		else
		{
			if (g_survivor[id])
			set_pev(id, pev_maxspeed, SurvivorSpeed)
			else if (g_sniper[id])
			set_pev(id, pev_maxspeed, SniperSpeed)
			else if (g_samurai[id])
			set_pev(id, pev_maxspeed, SamuraiSpeed)		// Abhinash
			else if(g_tryder[id])
			set_pev(id, pev_maxspeed, TryderSpeed)
			else 
			set_pev(id, pev_maxspeed, HumanSpeed)

			if (g_speed[id])
			set_pev(id, pev_maxspeed, 500.0)
		}
	}
}

AdminHasFlag(id, iFlag)
{
	new i
	while (i < 32)
	{
		if (iFlag == g_cAdminFlag[id][i])
		{
			return true
		}
		i += 1
	}
	return PLUGIN_CONTINUE
}

SkinFlag(id, iFlag)
{
	new i
	while (i < 32)
	{
		if (iFlag == g_cAdminSkinFlag[id][i])
		{
			return true
		}
		i += 1
	}
	return PLUGIN_CONTINUE
}

VipHasFlag(id, iFlag)
{
	new i
	while (i < 32)
	{
		if (iFlag == g_cVipFlag[id][i])
		{
			return true
		}
		i += 1
	}
	return PLUGIN_CONTINUE
}

/*================================================================================
 [Custom Natives]
=================================================================================*/

// Native: admin_has_flag
public native_admin_has_flag(id, flag)
{
	new i
	while (i < 32)
	{
		if (flag == g_cAdminFlag[id][i])
		{
			return true
		}
		i += 1
	}

	return PLUGIN_CONTINUE
}

// Native: zp_get_user_zombie
public native_get_user_zombie(id)
{
	return g_zombie[id]
}

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
		start_mode(infection, id)
	}
	else // Just infect
	zombieme(id, 0, none)

	return true
}

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
	humanme(id, none)

	return true
}

// Native: GetPacks
public native_get_user_packs(id)
{
	return g_ammopacks[id]
}

// Native: Addpacks
public native_add_user_packs(id, amount)
{
	if (amount < 1) return false

	g_ammopacks[id] += amount

	return true
}

// Native: SetPacks
public native_set_user_packs(id, amount)
{
	g_ammopacks[id] = amount
}

// Native: GetPoints
public native_get_user_points(id)
{
	return g_points[id]
}

// Native: AddPoints
public native_add_user_points(id, amount)
{
	if (amount < 1) return false

	g_points[id] += amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: SetPoints
public native_set_user_points(id, amount)
{
	if (amount < 1) return false

	g_points[id] = amount
	MySQL_UPDATE_DATABASE(amount)

	return true
}

// Native: GetKills
public native_get_user_kills(id)
{
	return g_kills[id]
}

// Native: AddKills
public native_add_user_kills(id, amount)
{
	if (amount < 1) return false

	g_kills[id] += amount
	MySQL_UPDATE_DATABASE(id)
}

// Native: SetKills
public native_set_user_kills(id, amount)
{
	if (amount < 0) return false

	g_kills[id] = amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: GetInfections
public native_get_user_infections(id)
{
	return g_infections[id]
}

// Native: AddInfections
public native_add_user_infections(id, amount)
{
	if (amount < 1) return false

	g_infections[id] += amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: SetInfections
public native_set_user_infections(id, amount)
{
	if (amount < 1) return false

	g_infections[id] = amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: GetNemesisKills
public native_get_user_nemesis_kills(id)
{
	return g_nemesiskills[id]
}

// Native: AddNemesisKills
public native_add_user_nemesis_kills(id, amount)
{
	if (amount < 1) return false

	g_nemesiskills[id] += amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: SetNemesisKills
public native_set_user_nemesis_kills(id, amount)
{
	if (amount < 1) return false

	g_nemesiskills[id] = amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: GetAssasinKills
public native_get_user_assasin_kills(id)
{
	return g_assasinkills[id]
}

// Native: AddAssasinKills
public native_add_user_assasin_kills(id, amount)
{
	if (amount < 1) return false

	g_assasinkills[id] += amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: SetAssasinkills
public native_set_user_assasin_kills(id, amount)
{
	if (amount < 1) return false

	g_assasinkills[id] = amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: GetBombardierKills
public native_get_user_bombardier_kills(id)
{
	return g_bombardierkills[id]
}

// Native: AddBombardierKills
public native_add_user_bombardier_kills(id, amount)
{
	if (amount < 1) return false

	g_bombardierkills[id] += amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: SetBombariderkills
public native_set_user_bombardier_kills(id, amount)
{
	if (amount < 1) return false

	g_bombardierkills[id] = amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: GetSurvivorKills
public native_get_user_survivor_kills(id)
{
	return g_survivorkills[id]
}

// Native: AddSurvivorkills
public native_add_user_survivor_kills(id, amount)
{
	if (amount < 1) return false

	g_survivorkills[id] += amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: SetSurvivorkills
public native_set_user_survivor_kills(id, amount)
{
	if (amount < 1) return false

	g_survivorkills[id] = amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: GetSniperKills
public native_get_user_sniper_kills(id)
{
	return g_sniperkills[id]
}

// Native: AddSniperKills
public native_add_user_sniper_kills(id, amount)
{
	if (amount < 1) return false

	g_sniperkills[id] += amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: SetSniperKills
public native_set_user_sniper_kills(id, amount)
{
	if (amount < 1) return false

	g_sniperkills[id] = amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: GetSmauraiKills
public native_get_user_samurai_kills(id)
{
	return g_samuraikills[id]
}

// Native: AddSamuraiKills
public native_add_user_samurai_kills(id, amount)
{
	if (amount < 1) return false

	g_samuraikills[id] += amount
	MySQL_UPDATE_DATABASE(id)
	
	return true
}

// Native: SetSamuraiKills
public native_set_user_samurai_kills(id, amount)
{
	if (amount < 1) return false

	g_samuraikills[id] = amount
	MySQL_UPDATE_DATABASE(id)

	return true
}

// Native: GetNemesis
public native_get_user_nemesis(id)
{
	return g_nemesis[id]
}

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
		start_mode(nemesis, id)
	}
	else // Just make him nemesis
	zombieme(id, 0, nemesis)

	return true
}

// Native: GetAssasin
public native_get_user_assassin(id)
{
	return g_assassin[id]
}

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
		start_mode(assassin, id)
	}
	else // Just make him assasin
	zombieme(id, 0, assassin)

	return true
}

// Native: GetBombardier
public native_get_user_bombardier(id)
{
	return g_bombardier[id]
}

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
		start_mode(bombardier, id)
	}
	else // Just infect
	zombieme(id, 0, bombardier)

	return true
}

// Native: GetSniper
public native_get_user_sniper(id)
{
	return g_sniper[id];
}

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
		start_mode(sniper, id)
	}
	else // Just make him sniper
	humanme(id, sniper)

	return true
}

// Native: GetSurvivor
public native_get_user_survivor(id)
{
	return g_survivor[id];
}

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
		start_mode(survivor, id)
	}
	else // Just make him survivor
	humanme(id, survivor)

	return true
}

// Native: GetSamurai
public native_get_user_samurai(id)
{
	return g_samurai[id];
}

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
		start_mode(samurai, id)
	}
	else // Just make him samurai
	humanme(id, samurai)

	return true
}

// Native: IsInfectionRound
public native_is_infection_round()
{
	return (g_currentmode == infection)
}

// Native: StartInfectionRound
public native_start_infection_round()
{

}

// Native: IsMultiInfectionRound
public native_is_multi_infection_round()
{
	return (g_currentmode == multi)
}

// Native: IsSwarmRound
public native_is_swarm_round()
{
	return g_swarmround
}

// Native: IsPlagueRound
public native_is_plague_round()
{
	return g_plagueround
}

// Native: IsArmageddonRound
public native_is_armageddon_round()
{
	return g_armageround
}

// Native: IsApocalypseRound
public native_is_apocalypse_round()
{
	return g_apocround
}

// Native: IsDevilRound
public native_is_devil_round()
{
	return g_devilround
}

// Native: IsNightmareRound
public native_is_nightmare_round()
{
	return g_nightround
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

	
	// Nemesis / Madness 
	if (g_nemesis[id] || (g_zombie[id] && g_nodamage[id]))
	{
		SendNightVision(id, NColorNemesis_R, NColorNemesis_G, NColorNemesis_B)
	}
	// Assassin 
	else if (g_assassin[id])
	{
		SendNightVision(id, NColorAssassin_R, NColorAssassin_G, NColorAssassin_B)
	}	
	// Bombardier 
	else if (g_bombardier[id])
	{
		SendNightVision(id, NColorBombardier_R, NColorBombardier_G, NColorBombardier_B)
	}	
	// Human 
	else if (!g_zombie[id])
	{
		SendNightVision(id, NColorHuman_R, NColorHuman_G, NColorHuman_B)
	}
	// Spectators
	else if (!g_isalive[id])
	{
		SendNightVision(id, NColorSpectator_R, NColorSpectator_G, NColorSpectator_B)
	}
	// Zombie
	else
	{
		SendNightVision(id, NColorZombie_R, NColorZombie_G, NColorZombie_B)
	}
	
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
	static id
	id = taskid - TASK_FLASH

	// Get player and aiming origins
	static Float:originF[3], Float:destoriginF[3]
	pev(id, pev_origin, originF)
	fm_get_aim_origin(id, destoriginF)

	// Max distance check
	if (get_distance_f(originF, destoriginF) > FlashLightDistance)
	return;

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
	static id
	id = taskid - TASK_FLASH

	// Get player and aiming origins
	static Float:originF[3], Float:destoriginF[3]
	pev(id, pev_origin, originF)
	fm_get_aim_origin(id, destoriginF)

	// Max distance check
	if (get_distance_f(originF, destoriginF) > FlashLightDistance)
	return;

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
	if (!g_frozen[id] && InfectionScreenFade == 1)
	{
		if (g_nemesis[id])
		{
			UTIL_ScreenFade(id, {200, 0, 0}, 1.0, 0.5, 100, FFADE_IN, true, false)
		}
		else if (g_assassin[id])
		{
			UTIL_ScreenFade(id, {0, 150, 0}, 1.0, 0.5, 100, FFADE_IN, true, false)
		}
		else
		{
			UTIL_ScreenFade(id, {165, 42, 42}, 1.0, 0.5, 225, FFADE_IN, true, false)
		}
	}
	
	
	// Screen shake?
	if (InfectionScreenShake == 1)
	{
		SendScreenShake(id, UNIT_SECOND*4, UNIT_SECOND*2, UNIT_SECOND*10)
	}
	
	// Infection icon?
	if (HUDIcons == 1)
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
	if (InfectionTracers == 1)
	{
		SendImplosion(id)
	}
	
	// Particle burst?
	if (InfectionParticles == 1)
	{
		SendParticleBurst(id)
	}
	
	// Light sparkle?
	if (InfectionSparkle == 1)
	{
		SendInfectionLight(id)
	}
}

// Nemesis/madness aura task
public zombie_aura(taskid)
{
	// Retrieve player index
	static id
	id = taskid - TASK_AURA

	// Not nemesis, not assassin, not in zombie madness
	if (!g_nemesis[id] && !g_assassin[id] && !g_bombardier[id] && !g_nodamage[id])
	{
		// Task not needed anymore
		remove_task(taskid)
		return
	}
	
	if (g_assassin[id])
	{
		SendAura(id, NColorAssassin_R, NColorAssassin_G, NColorAssassin_B)
	}
	else if (g_bombardier[id])
	{
		SendAura(id, NColorBombardier_R, NColorBombardier_G, NColorBombardier_B)
	}
	else
	{
		SendAura(id, NColorNemesis_R, NColorNemesis_G, NColorNemesis_B)
	}
}

// Make zombies leave footsteps and bloodstains on the floor
public make_blood(taskid)
{
	//Retrieve player index
	static id
	id = taskid - TASK_BLOOD

	// Only bleed when moving on ground
	if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 80)
	return
	
	// Get user origin
	static Float:originF[3]
	pev(id, pev_origin, originF)
	
	// If ducking set a little lower
	if (pev(id, pev_bInDuck))
	originF[2] -= 18.0
	else
	originF[2] -= 36.0
	
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
	static id
	id = taskid - TASK_BURN

	// Get player origin and flags
	static flags
	flags = pev(id, pev_flags)
	
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
	if (!g_nemesis[id] && !g_assassin[id] && !g_bombardier[id] && !random_num(0, 20))
	{
		emit_sound(id, CHAN_VOICE, grenade_fire_player[random(sizeof grenade_fire_player)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	// Fire slow down, unless nemesis
	if (!g_nemesis[id] && !g_assassin[id] && !g_bombardier[id] && (flags & FL_ONGROUND) && FireSlowdown > 0.0)
	{
		static Float:velocity[3]
		pev(id, pev_velocity, velocity)
		xs_vec_mul_scalar(velocity, FireSlowdown, velocity)
		set_pev(id, pev_velocity, velocity)
	}
	
	// Get player's health
	static health
	health = pev(id, pev_health)
	
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
	if (pev(ent, pev_solid) != save)
	return
	
	engfunc(EngFunc_RemoveEntity, ent)
}

// Strip user weapons (from fakemeta_util)
stock fm_strip_user_weapons(id)
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
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
		if(str[i] == searchchar)
		count++
	}
	
	return count
}

// Get User Current Weapon Entity
stock fm_cs_get_current_weapon_ent(id)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
	return -1
	
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX)
}

// Get Weapon Entity's Owner
stock fm_cs_get_weapon_ent_owner(ent)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(ent) != PDATA_SAFE)
	return -1
	
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
}

// Set User Deaths
stock fm_cs_set_user_deaths(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
	return
	
	set_pdata_int(id, OFFSET_CSDEATHS, value, OFFSET_LINUX)
}

// Get User Team
stock fm_cs_get_user_team(id)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
	return FM_CS_TEAM_UNASSIGNED
	
	return get_pdata_int(id, OFFSET_CSTEAMS, OFFSET_LINUX)
}

// Set a Player's Team
stock fm_cs_set_user_team(id, team)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
	return
	
	set_pdata_int(id, OFFSET_CSTEAMS, team, OFFSET_LINUX)
}

// Set User Money
stock fm_cs_set_user_money(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
	return
	
	set_pdata_int(id, OFFSET_CSMONEY, value, OFFSET_LINUX)
}

// Set User Flashlight Batteries
stock fm_cs_set_user_batteries(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
	return
	
	set_pdata_int(id, OFFSET_FLASHLIGHT_BATTERY, value, OFFSET_LINUX)
}

// Update Player's Team on all clients (adding needed delays)
stock fm_user_team_update(id)
{
	static Float:current_time
	current_time = get_gametime()
	
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
	static id

	// Retrieve index
	id = taskid - TASK_TEAM

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
	static iBot
	iBot = engfunc(EngFunc_CreateFakeClient, iBotName)
	
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
	
}  

public RemoveBot()
{
	static i
	for(i = 1; i <= get_maxplayers(); i++) 
	{
		if(g_bot[i]) 
		{
			server_cmd("kick #%d", get_user_userid(i))
		}
	}
}

// Set User Model
public ChangeModels(taskid)
{
	static bool:change
	static currentmodel[33]
	static id
	id = taskid - TASK_MODEL
	change = true
	get_user_model(id, currentmodel, charsmax(currentmodel))

	// Check if model change is needed
	if (!g_zombie[id])
	{
		if (g_survivor[id])
		{
			for(new i; i < sizeof g_cSurvivorModels; i++)
			{
				if (equal(currentmodel, g_cSurvivorModels[i]))
				{
					change = false
				}
			}
		}
		else if (g_sniper[id])
		{
			for(new i; i < sizeof g_cSniperModels; i++)
			{
				if (equal(currentmodel, g_cSniperModels[i]))
				{
					change = false
				}
			}
		}
		else if (g_samurai[id])
		{
			for(new i; i < sizeof g_cSamuraiModels; i++)
			{
				if (equal(currentmodel, g_cSamuraiModels[i]))
				{
					change = false
				}
			}
		}
		else
		{
			if (g_bAdmin[id] && SkinFlag(id, '1') && !g_bVip[id])
			{
				for(new i; i < sizeof g_cOwnerModels; i++)
				{
					if (equal(currentmodel, g_cOwnerModels[i]))
					{
						change = false
					}
				}
			}
			else if (g_bAdmin[id] && SkinFlag(id, '1') && g_bVip[id])
			{
				for(new i; i < sizeof g_cVipModels; i++)
				{
					if (equal(currentmodel, g_cVipModels[i]))
					{
						change = false
					}
				}
			}
			else if (g_bAdmin[id] && SkinFlag(id, '2') && !g_bVip[id])
			{
				for(new i; i < sizeof g_cAdminModels; i++)
				{
					if (equal(currentmodel, g_cAdminModels[i]))
					{
						change = false
					}
				}
			}
			else if (g_bAdmin[id] && SkinFlag(id, '2') && g_bVip[id])
			{
				for(new i; i < sizeof g_cVipModels; i++)
				{
					if (equal(currentmodel, g_cVipModels[i]))
					{
						change = false
					}
				}
			}
			else
			{
				for(new i; i < sizeof g_cHumanModels; i++)
				{
					if (equal(currentmodel, g_cHumanModels[i]))
					{
						change = false
					}
				}
			}
		}
	}
	else
	{
		if (g_nemesis[id])
		{
			for(new i; i < sizeof g_cNemesisModels; i++)
			{
				if (equal(currentmodel, g_cNemesisModels[i]))
				{
					change = false
				}
			}
		}
		if (g_assassin[id])
		{
			for(new i; i < sizeof g_cAssassinModels; i++)
			{
				if (equal(currentmodel, g_cAssassinModels[i]))
				{
					change = false
				}
			}
		}
		if (g_bombardier[id])
		{
			for(new i; i < sizeof g_cBombardierModels; i++)
			{
				if (equal(currentmodel, g_cBombardierModels[i]))
				{
					change = false
				}
			}
		}
		else
		{
			if (equal(currentmodel, g_cZombieClasses[g_zombieclass[id]][Model]))
			{
				change = false
			}
		}
	}

	// No change function
	if (change)
	{
		if (!g_zombie[id])
		{
			if (g_survivor[id])
			{
				new temp = random(sizeof g_cSurvivorModels)
				set_user_model(id, g_cSurvivorModels[temp])
				log_amx("Survivor %s model changed to %s", g_playername[id], g_cSurvivorModels[temp])
			}
			else if (g_sniper[id])
			{
				new temp = random(sizeof g_cSniperModels)
				set_user_model(id, g_cSniperModels[temp])
				log_amx("Sniper %s model changed to %s", g_playername[id], g_cSniperModels[temp])
			}
			else if (g_samurai[id])
			{
				new temp = random(sizeof g_cSamuraiModels)
				set_user_model(id, g_cSamuraiModels[temp])
				log_amx("Samurai %s model changed to %s", g_playername[id], g_cSamuraiModels[temp])
			}
			else
			{
				if (g_bAdmin[id] && SkinFlag(id, '1') && !g_bVip[id])
				{
					new temp = random(sizeof g_cOwnerModels)
					set_user_model(id, g_cOwnerModels[temp])
					log_amx("Owner %s model changed to %s", g_playername[id], g_cOwnerModels[temp])
				}
				else if (g_bAdmin[id] && SkinFlag(id, '1') && g_bVip[id])
				{
					new temp = random(sizeof g_cVipModels)
					set_user_model(id, g_cVipModels[temp])
					log_amx("Owner + VIP %s model changed to %s", g_playername[id], g_cVipModels[temp])
				}
				else if (g_bAdmin[id] && SkinFlag(id, '2') && !g_bVip[id])
				{
					new temp = random(sizeof g_cAdminModels)
					set_user_model(id, g_cAdminModels[temp])
					log_amx("Admin %s model changed to %s", g_playername[id], g_cAdminModels[temp])
				}
				else if (g_bAdmin[id] && SkinFlag(id, '2') && g_bVip[id])
				{
					new temp = random(sizeof g_cVipModels)
					set_user_model(id, g_cVipModels[temp])
					log_amx("Admin + VIP %s model changed to %s", g_playername[id], g_cVipModels[temp])
				}
				else
				{
					new temp = random(sizeof g_cHumanModels)
					set_user_model(id, g_cHumanModels[temp])
					log_amx("Human %s model changed to %s", g_playername[id], g_cHumanModels[temp])
				}
			}
		}
		else
		{
			if (g_nemesis[id])
			{
				new temp = random(sizeof g_cNemesisModels)
				set_user_model(id, g_cNemesisModels[temp])
				log_amx("Nemesis %s model changed to %s", g_playername[id], g_cNemesisModels[temp])
			}
			else if (g_assassin[id])
			{
				new temp = random(sizeof g_cAssassinModels)
				set_user_model(id, g_cAssassinModels[temp])
				log_amx("Assassin %s model changed to %s", g_playername[id], g_cAssassinModels[temp])
			}
			else if (g_bombardier[id])
			{
				new temp = random(sizeof g_cBombardierModels)
				set_user_model(id, g_cBombardierModels[temp])
				log_amx("Bombardier %s model changed to %s", g_playername[id], g_cBombardierModels[temp])
			}
			else
			{
				new temp = g_zombieclass[id]
				set_user_model(id, g_cZombieClasses[temp][Model])
				log_amx("Zombie %s model changed to %s", g_playername[id], g_cZombieClasses[temp][Model])
			}
		}
	}
	return PLUGIN_CONTINUE
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