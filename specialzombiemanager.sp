#include <sourcemod>

#define BLACKLIST_MAX_SIZE		16
#define BLACKLIST_MAX_NAME_SIZE 64

public Plugin myinfo =
{
	name		= "Special zombies manager",
	author		= "Swat",
	description = "Remove certain special zombies from spawning.",
	version		= "1"
}

ConVar szm_special_zombie_blacklist;
ConVar szm_witch_disabled;

public OnPluginStart()
{
	szm_special_zombie_blacklist = CreateConVar("szm_special_zombie_blacklist", "none", "blacklist of all the special zombies you do not want to spawn in.");
	szm_witch_disabled			 = CreateConVar("szm_witch_disabled", "false", "disable witch from spawning in, use 'szm_special_zombie_blacklist witch' instead.");

	HookConVarChange(szm_special_zombie_blacklist, onBlacklistChange);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("witch_spawn", Event_WitchSpawn, EventHookMode_Post);
}

public void onBlacklistChange(ConVar convar, char[] oldValue, char[] newValue)
{
	char blackListString[256];
	GetConVarString(szm_special_zombie_blacklist, blackListString, 256);
	SetConVarBool(szm_witch_disabled, StrContains(blackListString, "witch", false) != -1);

	if (strcmp(blackListString, "none", false) == 0)
	{
		PrintToServer("[szm] Disabled special zombie blacklist");
	}
	else {
		char disabledMessage[36] = "[szm] Disabled the following mobs: ";
		StrCat(disabledMessage, 256 + 36, blackListString);

		PrintToServer(disabledMessage);
	}
}

public Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadCast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (IsValidEntity(client) && GetClientTeam(client) == 3 && IsUndesiredEnemy(client))
	{
		RemoveEntity(client);
	}
}

public Event_WitchSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	if (GetConVarBool(szm_witch_disabled))
	{
		PrintToServer("[szm] Prevented the spawn of a witch");
		new witch = GetEventInt(event, "witchid");
		RemoveEntity(witch);
	}
}

bool IsUndesiredEnemy(int client)
{
	char zombieType[16];
	char blacklist[256];

	GetClientName(client, zombieType, 16);

	GetConVarString(szm_special_zombie_blacklist, blacklist, 256);
	bool isUndesired = StrContains(blacklist, zombieType, false) != -1;

	if (isUndesired)
	{
		char preventionMessage[32] = "[szm] Prevented the spawn of a ";
		StrCat(preventionMessage, 32 + 16, zombieType);
		PrintToServer(preventionMessage);
	}

	return isUndesired;
}
