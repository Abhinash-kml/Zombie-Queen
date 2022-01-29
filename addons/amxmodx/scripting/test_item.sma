#include <amxmodx>

native shop_item_add( const szName[ ], const iCost );

forward shop_item_selected( iPlayer, iItemIndex );

new g_item1, g_item2

public plugin_init()
{
    register_plugin("2 Test Items", "1.0", "Abhinash")

    g_item1 = shop_item_add("Test item 1", 2000)
    g_item2 = shop_item_add("Test item 2", 4000)
}

public shop_item_selected(id, itemid)
{
    if (itemid == g_item1) client_print_color(id, print_team_grey, "^4You selected ^3Test Item 1")
    if (itemid == g_item2) client_print_color(id, print_team_grey, "^4You selected ^3Test Item 2")
}