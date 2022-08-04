#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <sqlx>

new const zombieModels[][] = 
{
    "csbd_assassin",
    "csbd_clasic",
    "csbd_frozen",
    "csbd_hunter",
    "csbd_mutant",
    "csbd_nemesis",
    "csbd_predator_blue",
    "csbd_raptor",
    "csbd_regenerator",
    "frozen",
    "hunter",
    "monster_assassin",
    "monster_nemesis",
    "mutant",
    "predator_blue",
    "raptor",
    "regenerator",
    "zclasic"
}

// Points
new g_points[33]

// SQLx
new Handle:g_SqlTuple
new g_Error[512]			// Error buffer

new g_playerIP[33][32], g_playerName[33][32]

enum _:itemStruct
{
    ItemName[64],
    ItemCost
}

new Array:g_items
new g_pointsItemSelected, g_totalItems

public plugin_precache()
{
    g_items = ArrayCreate(itemStruct)
}

public plugin_init()
{
    register_plugin("Points Shop", "2.0", "Abhinash")

    g_pointsItemSelected = CreateMultiForward("OnPointsShopSelectedEx", ET_IGNORE, FP_CELL, FP_CELL, FP_STRING)

    MySql_Init()

    RegisterHam(Ham_Killed, "player", "OnPlayerKilled")

    register_clcmd("say /points", "SayFunc")
}

public plugin_natives()
{
    register_native("RegisterPointsShopWeaponEx", "native_register_points_item")
    register_native("ShowPointsShopMenu", "native_show_points_shop_menu")
    register_native("IsZombie", "native_is_zombie")
    register_native("IsHuman", "native_is_human")
}

public client_putinserver(id)
{
    if (is_user_bot(id))
    formatex(g_playerIP[id], charsmax(g_playerIP), "%i.%i.%i.0", random_num(0,255), random_num(0,255), random_num(0,255))
    else get_user_ip(id, g_playerIP[id], charsmax(g_playerIP[]), 1)

    get_user_name(id, g_playerName[id], charsmax(g_playerName[]))

    // Load his data
	MySQL_LOAD_DATABASE(id)
}

public OnPlayerKilled(victim, attacker, shouldgib)
{
    if (attacker == victim) return

    g_points[attacker] += 400
    MySQL_UPDATE_DATABASE(attacker)
}

public SayFunc(id)
{
    ShowMenu(id)
}

public MySql_Init()
{
	// Set Affinity to use SQLite instead of SQL
	SQL_SetAffinity("sqlite")

    // We tell the API that this is the information we want to connect to,
    // just not yet. basically it's like storing it in global variables
	g_SqlTuple = SQL_MakeDbTuple("", "", "", "ThunderZM")
   
    // Ok, we're ready to connect
	new ErrorCode, Handle:SqlConnection = SQL_Connect(g_SqlTuple, ErrorCode, g_Error, charsmax(g_Error))

	if (SqlConnection == Empty_Handle)
    {
		// stop the plugin with an error message
        set_fail_state(g_Error)
    }

	new Handle:Queries

    // We must now prepare some random queries
	Queries = SQL_PrepareQuery(SqlConnection, "CREATE TABLE IF NOT EXISTS `thunderzm` (IP varchar(32), POINTS INT(11))")

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
		//  if (equal(g_playerSteamID[id], "ID_PENDING"))
		//  return PLUGIN_HANDLED

		new szTemp[512]

	    // Now we will insturt the values into our table.
		format(szTemp, charsmax(szTemp), "INSERT INTO `thunderzm` (`IP`, `POINTS`) VALUES ('%s', '0');", g_playerIP[id])
		SQL_ThreadQuery(g_SqlTuple, "IgnoreHandle", szTemp)

		// set_dhudmessage(0, 255, 255, 0.03, 0.5, 2, 6.0, 10.0)
		// show_dhudmessage(id, "You are now ranked!")
	} 
	else 
	{
	    // if there are results found
		g_points[id] = SQL_ReadResult(Query, 1)

		// set_dhudmessage(0, 255, 255, 0.03, 0.5, 2, 6.0, 10.0)
		// show_dhudmessage(id, "You are now ranked!")
	}
    
	return PLUGIN_HANDLED
}

public MySQL_LOAD_DATABASE(id)
{
	new szTemp[512]

	new data[1]
	data[0] = id

	//we will now select from the table `tutorial` where the steamid match
	format(szTemp, charsmax(szTemp), "SELECT * FROM `thunderzm` WHERE `IP` = '%s'", g_playerIP[id])
	SQL_ThreadQuery(g_SqlTuple, "RegisterPlayerInDatabase", szTemp, data, 1)
}

public MySQL_UPDATE_DATABASE(id)
{
	new szTemp[512]

	// Here we will update the user hes information in the database where the steamid matches.
	format(szTemp, charsmax(szTemp), "UPDATE `thunderzm` SET `POINTS` = '%i' WHERE `IP` = '%s';", g_points[id], g_playerIP[id])
	SQL_ThreadQuery(g_SqlTuple, "IgnoreHandle", szTemp)
} 

public IgnoreHandle(FailState, Handle:Query, Error[], Errcode, Data[], DataSize)
{
	SQL_FreeHandle(Query)

	return PLUGIN_HANDLED
}

public ShowMenu(id)
{
    new buffer[128]
    formatex(buffer, charsmax(buffer), "\yPoints Shop \r| \yPoints: \r%i", g_points[id])
    new menu = menu_create(buffer, "PointsShopHandler")

    new ItemData[itemStruct], itemString[100], data[3]

    for (new i = 0; i < g_totalItems; i++)
    {
        ArrayGetArray(g_items, i, ItemData)

        formatex(itemString, charsmax(itemString), "%s \r[ %i points ]", ItemData[ItemName], ItemData[ItemCost])

        num_to_str(i, data, charsmax(data))

        menu_additem(menu, itemString, data)
    }

    menu_display(id, menu, 0)
}

public PointsShopHandler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new data[3], choice, ItemData[itemStruct]

    menu_item_getinfo(menu, item, _, data, charsmax(data), _, _, _)
    choice = str_to_num(data)

    ArrayGetArray(g_items, choice, ItemData)

    if (!is_user_alive(id))
    {
        // client_print_color(id, print_team_grey, "^4[POINTS SYSTEM] ^1You cant buy this ^3item ^1because you are ^3dead^1.")
        Message(id, "^4[POINTS SYSTEM] ^1You cant buy this ^3item ^1because you are ^3dead^1.")
        return PLUGIN_HANDLED
    }
    else if (g_points[id] < ItemData[ItemCost]) 
    {
        // client_print_color(id, print_team_grey, "^4[POINTS SYSTEM] ^1You dont have enough ^3points ^1to buy this item.")
        Message(id, "^4[POINTS SYSTEM] ^1You dont have enough ^3points ^1to buy this item.")
        return PLUGIN_HANDLED
    }
    else
    {
        // Subtract the players packs and give him the item
        g_points[id] -= ItemData[ItemCost]
        MySQL_UPDATE_DATABASE(id)

        // Execute the forward
        new g_forwardRetVal
        ExecuteForward(g_pointsItemSelected, g_forwardRetVal, id, choice, g_playerName[id])
    }

    return PLUGIN_CONTINUE
}

public native_show_points_shop_menu(iPlugin, iParams)
{
    new id; id = get_param(1)
    ShowMenu(id)

    return true
}

public native_register_points_item(iPlugin, iParams)
{
    new ItemData[itemStruct]

    get_string(1, ItemData[ItemName], charsmax(ItemData[ItemName]))
    log_amx("ItemData[ItemName] = %s", ItemData[ItemName])

    ItemData[ItemCost] = get_param(2)
    log_amx("ItemData[ItemCost] = %i", ItemData[ItemCost])

    ArrayPushArray(g_items, ItemData)
    g_totalItems++
    log_amx("g_totalItems = %i", g_totalItems)

    return (g_totalItems - 1)
}

public native_is_zombie(iPlugin, iParams)
{
    new id; id = get_param(1)

    return IsZombie(id)
}

public native_is_human(iPlugin, iParams)
{
    new id; id = get_param(1)

    return IsHuman(id)
}

public IsZombie(id)
{
    new buffer[100], bool:flag = false
    cs_get_user_model(id, buffer, charsmax(buffer))

    for (new i = 0; i < sizeof(zombieModels); i++)
    {
        if (!equali(buffer, zombieModels[i]))
        {
            flag = true
            break
        }
    }

    return flag
}

public IsHuman(id)
{
    return IsZombie(id) ? false : true
}

Message(v, c[], any: ...)
{
	static cBuffer[192], q
	vformat(cBuffer, 191, c, 3)

	if (v)
	{
		message_begin(MSG_ONE_UNRELIABLE, q, _, v)
		write_byte(v)
		write_string(cBuffer)
		message_end()
	}

	else
	{
		static i[32], j, k
		get_players(i, j, "ch")
		for (k = 0; k < j; k++)
		{
			message_begin(MSG_ONE_UNRELIABLE, q, _, i[k])
			write_byte(i[k])
			write_string(cBuffer)
			message_end()
		}
	}
}