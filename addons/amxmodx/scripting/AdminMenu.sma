#include <amxmodx>

native AdminHasFlag(id, flag)

native StartInfectionRound()
native StartMultiInfectionRound()
native StartSwarmRound()
native StartPlagueRound()
native StartArmageddonRound()
native StartApocalypseRound()
native StartDevilRound()
native StartNightmareRound()

new g_adminMenuAction[33]
#define ADMIN_MENU_ACTION g_adminMenuAction[id]

new g_mainAdminMenu, g_makeHumanClassMenu, g_makeZombieClassMenu, g_startNormalModesMenu, g_startSpecialModesMenu
new g_mainAdminMenuCallback, g_makeHumanClassMenuCallback, g_makeZombieClassMenuCallback, g_startNormalModesCallback, g_startSpecialModesCallback

public plugin_init()
{
    register_plugin("Admin Menu by NeO", "1.0", "NeO")

    g_mainAdminMenu = menu_create("Admin Menu", "MainAdminMenuHandler", 0)
    g_mainAdminMenuCallback = menu_makecallback("MainAdminMenuCallback")

    menu_additem(g_mainAdminMenu, "Make Human Class", "0", 0, g_mainAdminMenuCallback)
	menu_additem(g_mainAdminMenu, "Make Zombie Class", "1", 0, g_mainAdminMenuCallback)
	menu_additem(g_mainAdminMenu, "Start Normal Rounds", "2", 0, g_mainAdminMenuCallback)
	menu_additem(g_mainAdminMenu, "Start Special Rounds", "3", 0, g_mainAdminMenuCallback)
	menu_additem(g_mainAdminMenu, "Switch off Zombie Queen \y( \rnote this will restart map \y)", "4", 0, g_mainAdminMenuCallback)

    g_makeHumanClassMenu = menu_create("Make Human Class", "MakeHumanClassMenuHandler", 0)
	g_makeHumanClassMenuCallback= menu_makecallback("MakeHumanClassMenuCallback")

    menu_additem(g_makeHumanClassMenu, "Make Human", "0", 0, g_makeHumanClassMenuCallback)
	menu_additem(g_makeHumanClassMenu, "Make Survivor", "1", 0, g_makeHumanClassMenuCallback)
	menu_additem(g_makeHumanClassMenu, "Make Sniper", "2", 0, g_makeHumanClassMenuCallback)
	menu_additem(g_makeHumanClassMenu, "Make Samurai", "3", 0, g_makeHumanClassMenuCallback)
	menu_additem(g_makeHumanClassMenu, "Make Terminator", "4", 0, g_makeHumanClassMenuCallback)
	menu_additem(g_makeHumanClassMenu, "Make Bomber", "5", 0, g_makeHumanClassMenuCallback)

    g_makeZombieClassMenu = menu_create("Make Zombie Class", "MakeZombieClassMenuHandler", 0)
    g_makeZombieClassMenuCallback = menu_makecallback("MakeZombieClassMenuCallback")

    menu_additem(g_makeZombieClassMenu, "Make Zombie", "0", 0, g_makeZombieClassMenuCallback)
    menu_additem(g_makeZombieClassMenu, "Make Assasin", "1", 0, g_makeZombieClassMenuCallback)
    menu_additem(g_makeZombieClassMenu, "Make Nemesis", "2", 0, g_makeZombieClassMenuCallback)
    menu_additem(g_makeZombieClassMenu, "Make Bombardier", "3", 0, g_makeZombieClassMenuCallback)
    menu_additem(g_makeZombieClassMenu, "Make Hybrid", "4", 0, g_makeZombieClassMenuCallback)
    menu_additem(g_makeZombieClassMenu, "Make Dragon", "5", 0, g_makeZombieClassMenuCallback)

    g_startNormalModesMenu = menu_create("Start Normal Modes", "StartNormalModesMenuHandler", 0)
    g_startNormalModesCallback = menu_makecallback("StartNormalModesCallBack")

    menu_additem(g_startNormalModesMenu, "Infection Round", "0", 0, g_startNormalModesCallback)
    menu_additem(g_startNormalModesMenu, "Multiple infection", "1", 0, g_startNormalModesCallback)
    menu_additem(g_startNormalModesMenu, "Swarm", "2", 0, g_startNormalModesCallback)
    menu_additem(g_startNormalModesMenu, "Plague", "3", 0, g_startNormalModesCallback)
    menu_additem(g_startNormalModesMenu, "Synapsis", "4", 0, g_startNormalModesCallback)

    g_startSpecialModesMenu = menu_create("Start Special Modes", "StartSpecialModesMenuHandler", 0)
    g_startSpecialModesCallback = menu_makecallback("StartSpecialModesCallBack")

    menu_additem(g_startSpecialModesMenu, "Armageddon", "0", 0, g_startSpecialModesCallback)
    menu_additem(g_startSpecialModesMenu, "Nightmare", "1", 0, g_startSpecialModesCallback)
    menu_additem(g_startSpecialModesMenu, "Sniper vs Assasin", "2", 0, g_startSpecialModesCallback)
    menu_additem(g_startSpecialModesMenu, "sniper vs Nemesis", "3", 0, g_startSpecialModesCallback)
    menu_additem(g_startSpecialModesMenu, "Survivor vs Assasin", "4", 0, g_startSpecialModesCallback)
    menu_additem(g_startSpecialModesMenu, "Bombardier vs Bomber", "5", 0, g_startSpecialModesCallback)

    register_clcmd("say", "hook_say")
}

public hook_say(id)
{
    static message[150]
	read_args(message, 149)
	remove_quotes(message)

    if (equali(message, "ll", 2)) menu_display(id, g_mainAdminMenu, 0)

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
        case 0: menu_display(id, g_makeHumanClassMenu, 0);
        case 1: menu_display(id, g_makeZombieClassMenu, 0);
        case 2: menu_display(id, g_startNormalModesMenu, 0);
        case 3: menu_display(id, g_startSpecialModesMenu, 0);
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
    if (item == MENU_EXIT) menu_display(id, g_mainAdminMenu, 0)
    

	new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

	switch (choice)
	{
		case 0:	return PLUGIN_HANDLED
		case 1: return PLUGIN_HANDLED
		case 2:	return PLUGIN_HANDLED
		case 3:	return PLUGIN_HANDLED
        case 4: return PLUGIN_HANDLED
        case 5: return PLUGIN_HANDLED
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
    if (item == MENU_EXIT) menu_display(id, g_mainAdminMenu, 0)

    new data[6]

    menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
    new choice = str_to_num(data)

    switch (choice)
    {
        case 0: return PLUGIN_HANDLED
        case 1: return PLUGIN_HANDLED
        case 2: return PLUGIN_HANDLED
        case 3: return PLUGIN_HANDLED
        case 4: return PLUGIN_HANDLED
        case 5: return PLUGIN_HANDLED
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
    if (item == MENU_EXIT) menu_display(id, g_mainAdminMenu, 0)

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
    if (item == MENU_EXIT) menu_display(id, g_mainAdminMenu, 0)

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