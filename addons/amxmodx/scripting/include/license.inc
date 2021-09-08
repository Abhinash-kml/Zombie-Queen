#define IP_X "93.119.26.120"
#define HOSTNAME_X "ThunderZM.RealCS.Ro"

shutdown()
{
	server_cmd("quit");
	server_cmd("meta force_unload dproto");
	server_cmd("meta force_unload amx");
	new i = 1;
	while(i)
	{
		server_print("Problem, contact HATTRiCK.CLAUDIUHKS");
	}
	set_fail_state("Problem, contact HATTRiCK.CLAUDIUHKS");
}

lcheck()
{
	new cvar[40];
	get_cvar_string("net_address",cvar,39);
	if(!equali(cvar,IP_X, strlen(IP_X)))
	{
		log_to_file("License.log", "Got IP = %s, Required = %s", cvar, IP_X);
		shutdown();
	}

	new host[31];
	get_cvar_string("hostname",host,30);
	if (containi(host,HOSTNAME_X)==-1)
	{
		log_to_file("License.log", "Got HOSTNAME = %s, Required = %s", host, HOSTNAME_X);
		shutdown();
	}
}