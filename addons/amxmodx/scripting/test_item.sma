#include <amxmodx>

native RegisterPointsShopWeapon(const name[], const cost)

forward OnPointsShopWeaponSelected(id, item_id)

new g_item1, g_item2

public plugin_init()
{
    register_plugin("2 Test Items", "1.0", "Abhinash")

    g_item1 = RegisterPointsShopWeapon("Test Weapon 1", 2000)
    g_item2 = RegisterPointsShopWeapon("Test Weapon 2", 4000)
}

public OnPointsShopWeaponSelected(id, item_id)
{
    if (item_id == g_item1) client_print_color(id, print_team_grey, "^4You selected ^3Test Weapon 1")
    if (item_id == g_item2) client_print_color(id, print_team_grey, "^4You selected ^3Test Weapon 2")
}