#include <amxmodx>

native zp_get_user_ammo_packs(id)
native zp_set_user_ammo_packs(id, amount)
native GetLevel(id)

enum _: itemStruct
{
    ItemName[32],
    ItemCost,
    ItemLevel
}

new Array:g_items, g_totalItems
new g_levelItemSelected

public plugin_init()
{
    register_plugin("Levels shop", "1.0", "Abhinash")

    g_items = ArrayCreate(itemStruct)

    g_levelItemSelected = CreateMultiForward("OnLevelShopItemSelected", ET_IGNORE, FP_CELL, FP_CELL)
}

public plugin_natives()
{
    register_native("RegisterLevelShopItem", "native_register_level_item")
    register_native("ShowLevelsShopMenu", "native_show_level_shop_menu")
}

public ShowMenu(id)
{
    new menu = menu_create("Levels Shop", "LevelsShopHandler")

    new ItemData[itemStruct], itemString[100], data[3]

    for (new i = 0; i < g_totalItems; i++)
    {
        ArrayGetArray(g_items, i, ItemData)

        formatex(itemString, charsmax(itemString), "%s | \yLevel %i \w| \r%i Ammo", ItemData[ItemName], ItemData[ItemLevel], ItemData[ItemCost])

        num_to_str(i, data, charsmax(data))

        menu_additem(menu, itemString, data)
    }

    menu_display(id, menu, 0)
}

public LevelsShopHandler(id, menu, item)
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
        client_print_color(id, print_team_grey, "^4[LEVEL SYSTEM] ^1You cant buy this ^3item ^1because you are ^3dead^1.")
        return PLUGIN_HANDLED
    }
    else if (GetLevel(id) < ItemData[ItemLevel]) 
    {
        client_print_color(id, print_team_grey, "^4[LEVEL SYSTEM] ^1You dont have enough ^3level ^1to buy this item.")
        return PLUGIN_HANDLED
    }
    else if (zp_get_user_ammo_packs(id) < ItemData[ItemCost]) 
    {
        client_print_color(id, print_team_grey, "^4[LEVEL SYSTEM] ^1You dont have enough ^3ammo ^1to buy this item.")
        return PLUGIN_HANDLED
    }
    else
    {
        // Subtract the players packs and give him the item
        zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) - ItemData[ItemCost])

        // Execute the forward
        new g_forwardRetVal
        ExecuteForward(g_levelItemSelected, g_forwardRetVal, id, choice)
    }

    return PLUGIN_CONTINUE
}

public native_show_level_shop_menu(iPlugin, iParams)
{
    new id; id = get_param(1)
    ShowMenu(id)

    return true
}

public native_register_level_item(iPlugin, iParams)
{
    new ItemData[itemStruct]

    get_string(1, ItemData[ItemName], charsmax(ItemData[ItemName]))

    ItemData[ItemLevel] = get_param(2)
    ItemData[ItemCost] = get_param(3)

    ArrayPushArray(g_items, ItemData)
    g_totalItems++

    return (g_totalItems - 1)
}