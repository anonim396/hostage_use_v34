#include <sourcemod>
#include <sdktools>
#include <dhooks>
#include <cstrike>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
	name = "hostage_use",
	author = "",
	description = "",
	version = "1.0.0",
	url = ""
};

DHookSetup g_HostageUse = null;
float g_fLastUse[MAXPLAYERS+1] = {0.0, ...};

public void OnPluginStart()
{
	GameData gameconf = new GameData("hostage_use.gamedata");
	if(gameconf == null)
		SetFailState("Failed to find hostage_use.gamedata.txt");

	g_HostageUse = DHookCreateFromConf(gameconf, "CHostage::HostageUse");
	if(g_HostageUse == null)
		SetFailState("Failed to create detour \"CHostage::HostageUse\"");
	
	if(!DHookEnableDetour(g_HostageUse, false, Detour_HostageUse))
		SetFailState("Error enabling detour \"CHostage::HostageUse\"");
	
	gameconf.Close();
}

public void OnMapStart()
{
	AddFileToDownloadsTable("sound/hostage/hos1.wav");
	AddFileToDownloadsTable("sound/hostage/hos2.wav");
	
	PrecacheSound("hostage/hos1.wav");
	PrecacheSound("hostage/hos2.wav");
}

public MRESReturn Detour_HostageUse(int hostage, DHookParam hParams)
{
	int client = hParams.Get(1);
	if(GetClientTeam(client) == CS_TEAM_CT)
		return MRES_Ignored;

	//PrintToChat(client, "Used %d hostage", hostage);

	float now = GetEngineTime();
	if(now - g_fLastUse[client] < 1.0)
		return MRES_Ignored;

	g_fLastUse[client] = now;
	EmitSoundToAll(GetRandomInt(0, 1) ? "hostage/hos1.wav" : "hostage/hos2.wav", hostage);

	return MRES_Ignored;
}