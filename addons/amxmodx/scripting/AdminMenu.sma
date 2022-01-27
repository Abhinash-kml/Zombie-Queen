#include <amxmodx>
#include <amxmisc>

native AdminHasFlag(id, flag)

native MakeZombie(id)
native MakeHuman(id)
native MakeNemesis(id)
native MakeAssasin(id)
native MakeBombardier(id)
native MakeSniper(id)
native MakeSurvivor(id)
native MakeSamurai(id)

native StartInfectionRound()
native StartMultiInfectionRound()
native StartSwarmRound()
native StartPlagueRound()
native StartArmageddonRound()
native StartApocalypseRound()
native StartDevilRound()
native StartNightmareRound()

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
    ACTION_MAKE_ZOMBIE,
    ACTION_MAKE_ASSASIN,
    ACTION_MAKE_NEMESIS,
    ACTION_MAKE_BOMBARDIER,
    ACTION_RESPAWN_PLAYER
}

enum _: menuBackActions
{
    MENU_BACK_MAKE_HUMAN_CLASS = 0,
    MENU_BACK_MAKE_ZOMBIE_CLASS,
    MENU_BACK_RESPAWN_PLAYERS
}

new g_mainAdminMenuCallback, g_makeHumanClassMenuCallback, g_makeZombieClassMenuCallback, g_startNormalModesCallback, g_startSpecialModesCallback

public plugin_init()
{
    register_plugin("Admin Menu by NeO", "1.0", "NeO")

    g_mainAdminMenuCallback = menu_makecallback("MainAdminMenuCallback")
	g_makeHumanClassMenuCallback= menu_makecallback("MakeHumanClassMenuCallback")
    g_makeZombieClassMenuCallback = menu_makecallback("MakeZombieClassMenuCallback")
    g_startNormalModesCallback = menu_makecallback("StartNormalModesCallBack")
    g_startSpecialModesCallback = menu_makecallback("StartSpecialModesCallBack")

    register_clcmd("say", "hook_say")
    register_clcmd("+adminmenu", "ShowMainAdminMenu")
}

public ShowMainAdminMenu(id)
{
    new g_mainAdminMenu = menu_create("Admin Menu", "MainAdminMenuHandler", 0)

    menu_additem(g_mainAdminMenu, "Make Human Class", "0", 0, g_mainAdminMenuCallback)
	menu_additem(g_mainAdminMenu, "Make Zombie Class", "1", 0, g_mainAdminMenuCallback)
	menu_additem(g_mainAdminMenu, "Start Normal Rounds", "2", 0, g_mainAdminMenuCallback)
	menu_additem(g_mainAdminMenu, "Start Special Rounds", "3", 0, g_mainAdminMenuCallback)
	menu_additem(g_mainAdminMenu, "Switch off Zombie Queen \y( \rnote this will restart map \y)", "4", 0, g_mainAdminMenuCallback)

    menu_display(id, g_mainAdminMenu, 0)
}

public ShowMakeHumanClassMenu(id)
{
    new g_makeHumanClassMenu = menu_create("Make Human Class", "MakeHumanClassMenuHandler", 0)

    menu_additem(g_makeHumanClassMenu, "Make Human", "0", 0, g_makeHumanClassMenuCallback)
	menu_additem(g_makeHumanClassMenu, "Make Survivor", "1", 0, g_makeHumanClassMenuCallback)
	menu_additem(g_makeHumanClassMenu, "Make Sniper", "2", 0, g_makeHumanClassMenuCallback)
	menu_additem(g_makeHumanClassMenu, "Make Samurai", "3", 0, g_makeHumanClassMenuCallback)
	menu_additem(g_makeHumanClassMenu, "Make Terminator", "4", 0, g_makeHumanClassMenuCallback)
	menu_additem(g_makeHumanClassMenu, "Make Bomber", "5", 0, g_makeHumanClassMenuCallback)

    menu_display(id, g_makeHumanClassMenu, 0)
}

public ShowMakeZombieClassMenu(id)
{
    new g_makeZombieClassMenu = menu_create("Make Zombie Class", "MakeZombieClassMenuHandler", 0)

    menu_additem(g_makeZombieClassMenu, "Make Zombie", "0", 0, g_makeZombieClassMenuCallback)
    menu_additem(g_makeZombieClassMenu, "Make Assasin", "1", 0, g_makeZombieClassMenuCallback)
    menu_additem(g_makeZombieClassMenu, "Make Nemesis", "2", 0, g_makeZombieClassMenuCallback)
    menu_additem(g_makeZombieClassMenu, "Make Bombardier", "3", 0, g_makeZombieClassMenuCallback)
    menu_additem(g_makeZombieClassMenu, "Make Hybrid", "4", 0, g_makeZombieClassMenuCallback)
    menu_additem(g_makeZombieClassMenu, "Make Dragon", "5", 0, g_makeZombieClassMenuCallback)

    menu_display(id, g_makeZombieClassMenu, 0)
}

public ShowStartNormalModesMenu(id)
{
    new g_startNormalModesMenu = menu_create("Start Normal Modes", "StartNormalModesMenuHandler", 0)

    menu_additem(g_startNormalModesMenu, "Infection Round", "0", 0, g_startNormalModesCallback)
    menu_additem(g_startNormalModesMenu, "Multiple infection", "1", 0, g_startNormalModesCallback)
    menu_additem(g_startNormalModesMenu, "Swarm", "2", 0, g_startNormalModesCallback)
    menu_additem(g_startNormalModesMenu, "Plague", "3", 0, g_startNormalModesCallback)
    menu_additem(g_startNormalModesMenu, "Synapsis", "4", 0, g_startNormalModesCallback)

    menu_display(id, g_startNormalModesMenu, 0)
}

public ShowStartSpecialModesMenu(id)
{
    new g_startSpecialModesMenu = menu_create("Start Special Modes", "StartSpecialModesMenuHandler", 0)
    menu_additem(g_startSpecialModesMenu, "Armageddon", "0", 0, g_startSpecialModesCallback)
    menu_additem(g_startSpecialModesMenu, "Nightmare", "1", 0, g_startSpecialModesCallback)
    menu_additem(g_startSpecialModesMenu, "Sniper vs Assasin", "2", 0, g_startSpecialModesCallback)
    menu_additem(g_startSpecialModesMenu, "sniper vs Nemesis", "3", 0, g_startSpecialModesCallback)
    menu_additem(g_startSpecialModesMenu, "Survivor vs Assasin", "4", 0, g_startSpecialModesCallback)
    menu_additem(g_startSpecialModesMenu, "Bombardier vs Bomber", "5", 0, g_startSpecialModesCallback)

    menu_display(id, g_startSpecialModesMenu, 0)
}

public hook_say(id)
{
    static message[150]
	read_args(message, 149)
	remove_quotes(message)

    if (equali(message, "ll", 2)) ShowMainAdminMenu(id)

    return PLUGIN_CONTINUE
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
        case 0: ShowMakeHumanClassMenu(id)
        case 1: ShowMakeZombieClassMenu(id)
        case 2: ShowStartNormalModesMenu(id)
        case 3: ShowStartSpecialModesMenu(id)
        case 4: { client_print_color(id, print_team_grey, "^3You have access to this command"); return PLUGIN_HANDLED; }
    }

	return PLUGIN_CONTINUE
}

public MainAdminMenuCallback(id, menu, item)
{
	new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

	switch (choice)
	{
		case 0: return AdminHasFlag(id, 'a') ? ITEM_ENABLED : ITEM_DISABLED
		case 1: return AdminHasFlag(id, 'b') ? ITEM_ENABLED : ITEM_DISABLED
		case 2: return AdminHasFlag(id, 'c') ? ITEM_ENABLED : ITEM_DISABLED
		case 3: return AdminHasFlag(id, 'a') ? ITEM_ENABLED : ITEM_DISABLED
		case 4: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
	}

	return ITEM_IGNORE
}

public MakeHumanClassMenuHandler(id, menu, item)
{
    if (item == MENU_EXIT) { menu_destroy(menu); ShowMainAdminMenu(id); return PLUGIN_HANDLED; }
    
	new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

	switch (choice)
	{
		case 0:	{ ADMIN_MENU_ACTION = ACTION_MAKE_HUMAN; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_HUMAN_CLASS; ShowPlayersMenu(id); }
		case 1: { ADMIN_MENU_ACTION = ACTION_MAKE_SURVIVOR; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_HUMAN_CLASS; ShowPlayersMenu(id); }
		case 2:	{ ADMIN_MENU_ACTION = ACTION_MAKE_SNIPER; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_HUMAN_CLASS; ShowPlayersMenu(id); }
		case 3:	{ ADMIN_MENU_ACTION = ACTION_MAKE_SAMURAI; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_HUMAN_CLASS; ShowPlayersMenu(id); }
        case 4: { return PLUGIN_HANDLED; }
        case 5: { return PLUGIN_HANDLED; }
	}

	return PLUGIN_CONTINUE
}

public MakeHumanClassMenuCallback(id, menu, item)
{
	new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

	switch (choice)
	{
		case 0: return AdminHasFlag(id, 'a') ? ITEM_ENABLED : ITEM_DISABLED
		case 1: return AdminHasFlag(id, 'b') ? ITEM_ENABLED : ITEM_DISABLED
		case 2: return AdminHasFlag(id, 'c') ? ITEM_ENABLED : ITEM_DISABLED
		case 3: return AdminHasFlag(id, 'a') ? ITEM_ENABLED : ITEM_DISABLED
		case 4: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
		case 5: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
	}

	return ITEM_IGNORE
}

public MakeZombieClassMenuHandler(id, menu, item)
{
    if (item == MENU_EXIT) { menu_destroy(menu); ShowMainAdminMenu(id); return PLUGIN_HANDLED; }

    new data[6]

    menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
    new choice = str_to_num(data)

    switch (choice)
    {
        case 0: { ADMIN_MENU_ACTION = ACTION_MAKE_ZOMBIE; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_ZOMBIE_CLASS; ShowPlayersMenu(id); }
        case 1: { ADMIN_MENU_ACTION = ACTION_MAKE_ASSASIN; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_ZOMBIE_CLASS; ShowPlayersMenu(id); }
        case 2: { ADMIN_MENU_ACTION = ACTION_MAKE_NEMESIS; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_ZOMBIE_CLASS; ShowPlayersMenu(id); }
        case 3: { ADMIN_MENU_ACTION = ACTION_MAKE_BOMBARDIER; PL_MENU_BACK_ACTION = MENU_BACK_MAKE_ZOMBIE_CLASS; ShowPlayersMenu(id); }
        case 4: { return PLUGIN_HANDLED; }
        case 5: { return PLUGIN_HANDLED; }
    }

    return PLUGIN_CONTINUE
}

public MakeZombieClassMenuCallback(id, menu, item)
{
    new data[6]

    menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
    new choice = str_to_num(data)

    switch (choice)
    {
        case 0: return AdminHasFlag(id, 'a') ? ITEM_ENABLED : ITEM_DISABLED
        case 1: return AdminHasFlag(id, 'a') ? ITEM_ENABLED : ITEM_DISABLED
        case 2: return AdminHasFlag(id, 'a') ? ITEM_ENABLED : ITEM_DISABLED
        case 3: return AdminHasFlag(id, 'a') ? ITEM_ENABLED : ITEM_DISABLED
        case 4: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
        case 5: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
    }

    return ITEM_IGNORE
}

public StartNormalModesMenuHandler(id, menu, item)
{
    if (item == MENU_EXIT) { menu_destroy(menu); ShowMainAdminMenu(id); return PLUGIN_HANDLED; }
    new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

    switch (choice)
    {
        case 0: { StartInfectionRound(); }
        case 1: { StartMultiInfectionRound(); }
        case 2: { StartSwarmRound(); }
        case 3: { StartPlagueRound(); }
        case 4: { return PLUGIN_HANDLED; }
    }

    return PLUGIN_CONTINUE
}

public StartNormalModesCallBack(id, menu, item)
{
    new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

    switch (choice)
    {
        case 0: return AdminHasFlag(id, 'a') ? ITEM_ENABLED : ITEM_DISABLED
		case 1: return AdminHasFlag(id, 'b') ? ITEM_ENABLED : ITEM_DISABLED
		case 2: return AdminHasFlag(id, 'c') ? ITEM_ENABLED : ITEM_DISABLED
		case 3: return AdminHasFlag(id, 'd') ? ITEM_ENABLED : ITEM_DISABLED
        case 4: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
    }

    return ITEM_IGNORE
}

public StartSpecialModesMenuHandler(id, menu, item)
{
    if (item == MENU_EXIT) { menu_destroy(menu); ShowMainAdminMenu(id); return PLUGIN_HANDLED; }

    new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

    switch (choice)
    {
        case 0: { StartArmageddonRound(); }
        case 1: { StartNightmareRound(); }
        case 2: { StartApocalypseRound(); }
        case 3: { StartDevilRound(); }
        case 4: { return PLUGIN_HANDLED; }
        case 5: { return PLUGIN_HANDLED; }
    }

    return PLUGIN_CONTINUE
}

public StartSpecialModesCallBack(id, menu, item)
{
    new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

    switch (choice)
    {
        case 0: return AdminHasFlag(id, 'a') ? ITEM_ENABLED : ITEM_DISABLED
		case 1: return AdminHasFlag(id, 'b') ? ITEM_ENABLED : ITEM_DISABLED
		case 2: return AdminHasFlag(id, 'c') ? ITEM_ENABLED : ITEM_DISABLED
		case 3: return AdminHasFlag(id, 'a') ? ITEM_ENABLED : ITEM_DISABLED
		case 4: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
		case 5: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
    }

    return ITEM_IGNORE
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
        case ACTION_MAKE_ZOMBIE: formatex(buffer, charsmax(buffer), "\yMake Zombie")
        case ACTION_MAKE_ASSASIN: formatex(buffer, charsmax(buffer), "\yMake Assasin")
        case ACTION_MAKE_NEMESIS: formatex(buffer, charsmax(buffer), "\yMake Nemesis")
        case ACTION_MAKE_BOMBARDIER: formatex(buffer, charsmax(buffer), "\yMake Bombardier")
        case ACTION_RESPAWN_PLAYER: formatex(buffer, charsmax(buffer), "\yRespawn Players")
    }

    new menu = menu_create(buffer, "PlayersMenuHandler", 0)
    
    // Variables for storing infos
    new players[32], pnum, tempid
    new name[32], userid[32]

    //Fill players with available players
    get_players_ex(players, pnum)

    for (new i = 0; i < pnum; i++)
    {
        //Save a tempid so we do not re-index
        tempid = players[i]

        //Get the players name and userid as strings
        get_user_name(tempid, name, charsmax(name))

        //We will use the data parameter to send the userid, so we can identify which player was selected in the handler
        formatex(userid, charsmax(userid), "%d", get_user_userid(tempid))

        //Add the item for this player
        menu_additem(menu, name, userid, 0)
    }

    //We now have all players in the menu, lets display the menu
    menu_display(id, menu, 0)
}

public PlayersMenuHandler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        switch (PL_MENU_BACK_ACTION)
        {
            case MENU_BACK_MAKE_HUMAN_CLASS: { menu_destroy(menu); ShowMakeHumanClassMenu(id); return PLUGIN_HANDLED; }
            case MENU_BACK_MAKE_ZOMBIE_CLASS: { menu_destroy(menu); ShowMakeZombieClassMenu(id); return PLUGIN_HANDLED; }
        }
    }

    new data[6]

    menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)

    new userid = str_to_num(data)

    new target = find_player("k", userid)

    switch (ADMIN_MENU_ACTION)
    {
        case ACTION_MAKE_HUMAN: { MakeHuman(target); menu_destroy(menu); ShowPlayersMenu(id); }
        case ACTION_MAKE_SNIPER: { MakeSniper(target); menu_destroy(menu); ShowPlayersMenu(id); }
        case ACTION_MAKE_SURVIVOR: { MakeSurvivor(target); menu_destroy(menu); ShowPlayersMenu(id); }
        case ACTION_MAKE_SAMURAI: { MakeSamurai(target); menu_destroy(menu); ShowPlayersMenu(id); }
        case ACTION_MAKE_ZOMBIE: { MakeZombie(target); menu_destroy(menu); ShowPlayersMenu(id); }
        case ACTION_MAKE_ASSASIN: { MakeAssasin(target); menu_destroy(menu); ShowPlayersMenu(id); }
        case ACTION_MAKE_NEMESIS: { MakeNemesis(target); menu_destroy(menu); ShowPlayersMenu(id); }
        case ACTION_MAKE_BOMBARDIER: { MakeBombardier(target); menu_destroy(menu); ShowPlayersMenu(id); }
    }

    return PLUGIN_CONTINUE;
}