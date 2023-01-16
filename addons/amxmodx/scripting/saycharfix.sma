#include <amxmodx> 
#include <time> 
#include <amxmisc> 

new const gBlockcmd[][]= 
{ 
"#Cstrike_GIGN_Label", 
"#Cstrike_Spetsnaz_Label", 
"@ #Cstrike_Spetsnaz_Label", 
"#1Cstike", 
"#", 
"*", 
"%" 
} 

public plugin_init() 
{ 
register_plugin("Fix bug (say / say_team)", "1.0", "Ghost95V & popeye10 & JazZ."); 
}

public client_command(Client) 
{ 
static Cmd[6], Said[100]; 
read_args(Said,99); 
remove_quotes(Said); 
read_argv(0,Cmd,5); 
if(equali(Cmd,"Say_team",3)&&containi(Said,"% ")!=-1){ 
ColorPrint(Client,"!g[AMXX] !tNo Characters percent allowed !!!"); 
return 1; 
} 
if(equali(Cmd,"Say_team",3)&&containi(Said,"# ")!=-1) 
{ 
ColorPrint(Client,"!g[AMXX] !tCharacters not allowed !!!"); 
return 1; 
} 
if(equali(Cmd,"Say",3)&&containi(Said,"%")!=-1){ 
ColorPrint(Client,"!g[AMXX] !tNo Characters percent allowed !!!"); 
return 1; 
} 
if(equali(Cmd,"Say",3)&&containi(Said,"#")!=-1) 
{ 
ColorPrint(Client,"!g[AMXX] !tCharacters not allowed !!!"); 
return 1; 
} 
return PLUGIN_CONTINUE; 
}

public client_putinserver(id)
{
if (is_user_connected(id))
{
new szName[32];
get_user_name(id, szName, 31);
for(new i = 0; i < sizeof(gBlockcmd); i++) {
if(containi(szName, gBlockcmd[i]) != -1) {
server_cmd("kick #%d ^"Cheat Detected^"", get_user_userid(id));
return 1;
}
}

}
return 0;
} 

public client_infochanged(id) 
{
static const name[] = "name";
static szNewName[32], szOldName[32];
get_user_info(id, name, szNewName, 31 ); 
get_user_name(id, szOldName, 31 ); 

for(new i = 0; i < sizeof(gBlockcmd); i++){
if(containi(szNewName, gBlockcmd[i]) != -1)
{
replace_all( szNewName, 32, gBlockcmd[i], "" );
set_user_info(id, name, szNewName );
}
}
} 

stock ColorPrint(const id, const input[], any:...) 
{ 
new count = 1, players[32] 

static msg[191] 

vformat(msg, 190, input, 3) 

replace_all(msg, 190, "!g", "^4") 
replace_all(msg, 190, "!y", "^1") 
replace_all(msg, 190, "!t", "^3") 
replace_all(msg, 190, "!t2", "^0") 

if (id) players[0] = id; else get_players(players, count, "ch") 
{ 
for (new i = 0; i < count; i++) 
{ 
if (is_user_connected(players[i])) 
{ 
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]) 
write_byte(players[i]) 
write_string(msg) 
message_end() 
} 
} 
} 
}