#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <cstrike>

#define ADMFLAG_BUNNYHOP ADMFLAG_ROOT

bool g_BunnyhopState[MAXPLAYERS] = {  };

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
	g_BunnyhopState[client] = false;
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
	
	char TargetArg[16] = {  };
	char StateArg[2] = {  };
	GetCmdArg(1, TargetArg, sizeof(TargetArg));
	GetCmdArg(2, StateArg, sizeof(StateArg));
	
	bool State = view_as<bool>(StringToInt(StateArg));
	
	if (TargetArg[0] != '@')
	{
		int ClientID = StringToInt(TargetArg);
		g_BunnyhopState[ClientID] = State;
		
		if (ClientID != client)
		{
			char ClientName[256] = {  };
			GetClientName(client, ClientName, sizeof(ClientName));
			ReplyToCommand(client, "[SM] toggled autobunnyhop on: %s", ClientName);
		}
		
		PrintToChat(ClientID, "[SM] toggled autobunnyhop on you");
	}
	
	else
	{
		for (int i = 1; i < MaxClients && i < MAXPLAYERS; ++i)
		{
			if (IsClientInGame(i))
			{
				if ((StrEqual(TargetArg, "@all")) || 
					(StrEqual(TargetArg, "@t") && GetClientTeam(i) == CS_TEAM_T) ||
					(StrEqual(TargetArg, "@ct") && GetClientTeam(i) == CS_TEAM_CT) ||
					(IsPlayerAlive(i) ? StrEqual(TargetArg, "@alive") : StrEqual(TargetArg, "@dead")) ||
					(StrEqual(TargetArg, "@humans") && !IsFakeClient(i)))
				{
					g_BunnyhopState[i] = State;
					PrintToChat(i, "[SM] toggled autobunnyhop on you");
				}
			}
		}
	}
	
	return Plugin_Handled;
}
