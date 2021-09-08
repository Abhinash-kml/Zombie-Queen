#include <amxmodx>
#include <engine>
#include <fakemeta>
#define PLUGIN "Player Camera"
#define VERSION "1.0"
#define AUTHOR "XunTric"
public plugin_init()
{
     register_plugin(PLUGIN, VERSION, AUTHOR)
     register_menucmd(register_menuid("Choose Camera View"), 1023, "setview") 
     register_forward(FM_AddToFullPack, "AddToFullPack")
     register_clcmd("say /camera", "chooseview")
     register_clcmd("say /cam", "chooseview") 
}
public plugin_modules()
{
     require_module("engine")
}
public plugin_precache()
{
     precache_model("models/rpgrocket.mdl")
}
public chooseview(id)
{
    new menu[192] 
    new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4 
    format(menu, 191, "\yChoose Camera View^n^n\r1.\w Upleft View^n\r2.\w 3rd Person View^n\r3.\w Normal View^n^n\r0.\w Exit") 
    show_menu(id, keys, menu)      
    return PLUGIN_CONTINUE
}
public setview(id, key, menu)
{
     if(key == 0) {
          set_view(id, CAMERA_UPLEFT)
          return PLUGIN_HANDLED
     }
     if(key == 1) {
          set_view(id, CAMERA_3RDPERSON)
          return PLUGIN_HANDLED
     }
     if(key == 2) {
          set_view(id, CAMERA_NONE)
          return PLUGIN_HANDLED
     }
     else {
          return PLUGIN_HANDLED
     }
     return PLUGIN_HANDLED
}  
public AddToFullPack(es, e, ent, host, hostflags, player, pSet)
{
     if( player )
     {
         if(ent == host)
         {
             set_pev(ent, pev_rendermode, kRenderNormal)
             set_pev(ent, pev_renderamt, 0)
         }
     }
     return FMRES_IGNORED
}  