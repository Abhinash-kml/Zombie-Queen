#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Thunder Effects"
#define VERSION "1.0"
#define AUTHOR "LegendofWarior"

new light

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	set_task(5.0, "lightning", .flags = "b")
}
public plugin_precache() 
{ 
	light = precache_model("sprites/lgtning.spr") 
}
public lightning()
{
	new xy[2]
	xy[0] = random_num(-2000,2200)
	xy[1] = random_num(-2000,2200)
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte(0) 
	write_coord(xy[0]) 
	write_coord(xy[1]) 
	write_coord(4000) 
	write_coord(xy[0]) 
	write_coord(xy[1]) 
	write_coord(-2000) 
	write_short(light) 
	write_byte(5) // framestart 
	write_byte(25) // framerate 
	write_byte(10) // life 
	write_byte(200) // width 
	write_byte(100) // noise 
	write_byte(random(256)) // r, g, b 
	write_byte(random(256)) // r, g, b 
	write_byte(random(256)) // r, g, b 
	write_byte(255) // brightness 
	write_byte(200) //  
	message_end() 
}

