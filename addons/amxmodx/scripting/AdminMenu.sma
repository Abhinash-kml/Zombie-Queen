#include <amxmodx>

native AdminHasFlag(id, flag)

new g_mainAdminMenuCallBack, g_makeClassMenuCallBack, g_startNormalModesCallback, g_startSpecialModesCallBack

public plugin_init()
{
    register_plugin("Admin Menu by NeO", "1.0", "NeO")

    g_mainAdminMenuCallBack = menu_makecallback("MainAdminMenuCallBack")
	g_makeClassMenuCallBack	= menu_makecallback("MakeClassMenuCallBack")
    g_startNormalModesCallback = menu_makecallback("StartNormalModesCallBack")
    g_startSpecialModesCallBack = menu_makecallback("StartSpecialModesCallBack")

    register_clcmd("say", "hook_say")
}

public hook_say(id)
{
    static message[150]
	read_args(message, 149)
	remove_quotes(message)

    if (equali(message, "ll", 2)) ShowTestMenu(id)

    return PLUGIN_CONTINUE
}

ShowTestMenu(id)
{
	new menu = menu_create("Test Admin Menu", "MainAdminMenuHandler", 0)

	menu_additem(menu, "Make class", "0", 0, g_mainAdminMenuCallBack)
	menu_additem(menu, "Start normal modes", "1", 0, g_mainAdminMenuCallBack)
	menu_additem(menu, "Start special modes", "2", 0, g_mainAdminMenuCallBack)
	menu_additem(menu, "Switch off Zombie Queen \y( \rnote this will restart map \y)", "3", 0, g_mainAdminMenuCallBack)

	menu_display(id, menu, 0)
}

public MainAdminMenuHandler(id, menu, item)
{
	if (item != -3)
	{
		new data[6]

		menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
		new choice = str_to_num(data)

		switch (choice)
		{
			case 0: { ShowMakeClassMenu(id); }
			case 1: { ShowStartNormalModesMenu(id); }
			case 2: { ShowStartSpecialModesMenu(id); }
			case 3: { client_print_color(id, print_team_grey, "^3You have access to this command"); return PLUGIN_HANDLED; }
		}
	}

	return PLUGIN_CONTINUE
}

public MainAdminMenuCallBack(id, menu, item)
{
	new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

	switch (choice)
	{
		case 0: return AdminHasFlag(id, 'a') ? ITEM_ENABLED : ITEM_DISABLED
		case 1: return AdminHasFlag(id, 'b') ? ITEM_ENABLED : ITEM_DISABLED
		case 2: return AdminHasFlag(id, 'c') ? ITEM_ENABLED : ITEM_DISABLED
		case 3: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
	}

	return ITEM_IGNORE
}

ShowMakeClassMenu(id)
{
	new menu = menu_create("Make class menu", "MakeClassMenuHandler", 0)

	menu_additem(menu, "Make Zombie / Human", "0", 0, g_makeClassMenuCallBack)
	menu_additem(menu, "Make Survivor", "1", 0, g_makeClassMenuCallBack)
	menu_additem(menu, "Make Sniper", "2", 0, g_makeClassMenuCallBack)
	menu_additem(menu, "Make Samurai", "3", 0, g_makeClassMenuCallBack)
	menu_additem(menu, "Make Assasin", "4", 0, g_makeClassMenuCallBack)
	menu_additem(menu, "Make Nemesis", "5", 0, g_makeClassMenuCallBack)
	menu_additem(menu, "Make Bombardier", "6", 0, g_makeClassMenuCallBack)

	menu_display(id, menu, 0)
}

public MakeClassMenuHandler(id, menu, item)
{
	new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

	switch (choice)
	{
		case 0:	return PLUGIN_HANDLED
		case 1: return PLUGIN_HANDLED
		case 2:	return PLUGIN_HANDLED
		case 3:	return PLUGIN_HANDLED
		case 4:	return PLUGIN_HANDLED
		case 5:	return PLUGIN_HANDLED
		case 6: return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public MakeClassMenuCallBack(id, menu, item)
{
	new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

	switch (choice)
	{
		case 0: return AdminHasFlag(id, 'a') ? ITEM_ENABLED : ITEM_DISABLED
		case 1: return AdminHasFlag(id, 'b') ? ITEM_ENABLED : ITEM_DISABLED
		case 2: return AdminHasFlag(id, 'c') ? ITEM_ENABLED : ITEM_DISABLED
		case 3: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
		case 4: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
		case 5: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
		case 6: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
	}

	return ITEM_IGNORE
}

ShowStartNormalModesMenu(id)
{
    new menu = menu_create("Start normal modes menu", "StartNormalModesMenuHandler", 0)

    menu_additem(menu, "Multiple infection", "0", 0, g_startNormalModesCallback)
    menu_additem(menu, "Swarm", "1", 0, g_startNormalModesCallback)
    menu_additem(menu, "Plague", "2", 0, g_startNormalModesCallback)
    menu_additem(menu, "Synapsis", "3", 0, g_startNormalModesCallback)

    menu_display(id, menu, 0)
}

public StartNormalModesMenuHandler(id, menu, item)
{
    new data[6]

	menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
	new choice = str_to_num(data)

    switch (choice)
    {
        case 0: return PLUGIN_HANDLED
        case 1: return PLUGIN_HANDLED
        case 2: return PLUGIN_HANDLED
        case 3: return PLUGIN_HANDLED
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
		case 2: return AdminHasFlag(id, '}') ? ITEM_ENABLED : ITEM_DISABLED
		case 3: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
    }

    return ITEM_IGNORE
}

ShowStartSpecialModesMenu(id)
{
    new menu = menu_create("Start special modes menu", "StartSpecialModesMenuHandler", 0)

    menu_additem(menu, "Armageddon", "0", 0, g_startSpecialModesCallBack)
    menu_additem(menu, "Nightmare", "1", 0, g_startSpecialModesCallBack)
    menu_additem(menu, "Sniper vs Assasin", "2", 0, g_startSpecialModesCallBack)
    menu_additem(menu, "sniper vs Nemesis", "3", 0, g_startSpecialModesCallBack)
    menu_additem(menu, "Survivor vs Assasin", "4", 0, g_startSpecialModesCallBack)
    menu_additem(menu, "Bombardier vs Bomber", "5", 0, g_startSpecialModesCallBack)

    menu_display(id, menu, 0)
}

public StartSpecialModesMenuHandler(id, menu, item)
{
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
		case 3: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
		case 4: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
		case 5: return AdminHasFlag(id, '[') ? ITEM_ENABLED : ITEM_DISABLED
    }

    return ITEM_IGNORE
}