#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <cstrike>

#define ADMFLAG_BUNNYHOP ADMFLAG_ROOT

int g_BunnyhopState[MAXPLAYERS] = {  };

public Plugin my_info =
{
	name = "Admin Auto Bunnyhop",
	author = "rdbo",
	description = "Toggle Auto Bunnyhop on Players",
	version = "1.0",
	url = ""
}

public void OnPluginStart()
{
	PrintToServer("[SM] Admin Auto Bunnyhop plugin has been loaded");
	RegAdminCmd("sm_bunnyhop", CMD_Bunnyhop, ADMFLAG_BUNNYHOP, "Toggle Bunnyhop on a Player");
}

public void OnClientDisconnect(int client)
{
	g_BunnyhopState[client] = 0;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (IsClientInGame(client) && g_BunnyhopState[client])
	{
		int flags = GetEntityFlags(client);
		
		if ((buttons & IN_JUMP) && !(flags & FL_ONGROUND))
		{
			buttons &= ~IN_JUMP;
		}
	}
}

public Action CMD_Bunnyhop(int client, int args)
{
	if (args != 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_bunnyhop <client_id> <state>");
		return Plugin_Handled;
	}
	
	char ClientIDArg[3];
	char StateArg[2];
	GetCmdArg(1, ClientIDArg, sizeof(ClientIDArg));
	GetCmdArg(2, StateArg, sizeof(StateArg));
	
	int ClientID = StringToInt(ClientIDArg);
	int State = StringToInt(StateArg);
	
	g_BunnyhopState[ClientID] = State;
	
	if (ClientID != client)
	{
		char ClientName[256];
		GetClientName(client, ClientName, sizeof(ClientName));
		PrintToChat(client, "[SM] toggled autobunnyhop on: %s", ClientName);
		PrintToChat(ClientID, "[SM] toggled autobunnyhop on you");
	}
	
	else
	{
		PrintToChat(client, "[SM] toggled autobunnyhop on self");
	}
	
	return Plugin_Handled;
}