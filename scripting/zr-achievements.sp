#include <sourcemod> 

public Plugin:myinfo =
{
 name = "ZR-Achievements",
 author = "theSaint",
 description = "Achievements system for Zombie Escape servers",
 version = "1.0",
 url = "http://ggeasy.pl"
};

char sAuthID3[3MAXPLAYERS+1][32];

// database handle
Database gH_SQL = null;



public void OnPluginStart() 
{
	SQL_DBConnect();
}

void SQL_DBConnect()
{
	if(gH_SQL != null)
	{
		delete gH_SQL;
	}

	char[] sError = new char[255];

	if(SQL_CheckConfig("zrachievements"))
	{
		gH_SQL = SQL_Connect("zrachievements", true, sError, 255);

		if(gH_SQL == null)
		{
			SetFailState("ZR-Achievements startup Failed. Reason: %s", sError);
		}
	}

	else
	{
		gH_SQL = SQLite_UseDatabase("zrachievements", sError, 255);
	}

	// support unicode names
	//gH_SQL.SetCharset("utf8");

	//Call_StartForward(gH_Forwards_OnDatabaseLoaded);
	//Call_PushCell(gH_SQL);
	//Call_Finish();

	//char[] sDriver = new char[8];
	//gH_SQL.Driver.GetIdentifier(sDriver, 8);
	//gB_MySQL = StrEqual(sDriver, "mysql", false);

	char[] sQuery = new char[512];
	FormatEx(sQuery, 512, "CREATE TABLE IF NOT EXISTS `zra_stats` (`auth` VARCHAR(32) NOT NULL, `zombies_killed` INT NOT NULL DEFAULT 0, `humans_infected` INT NOT NULL DEFAULT 0, `time_played` INT NOT NULL DEFAULT 0, PRIMARY KEY (`auth`));");
	
	// CREATE TABLE IF NOT EXISTS
	gH_SQL.Query(SQL_CreateTable_Callback, sQuery);
}

public void SQL_CreateTable_Callback(Database db, DBResultSet results, const char[] error, any data)
{
	if(results == null)
	{
		LogError("ZR-Achievements: Users' data table creation failed. Reason: %s", error);

		return;
	}
}

public void OnClientPutInServer(int client)
{

	if(IsFakeClient(client))
	{
		return;
	}

	if(gH_SQL == null)
	{
		return;
	}


	if(!GetClientAuthId(client, AuthId_Steam3, sAuthID3[client], 32))
	{
		KickClient(client, "%T", "VerificationFailed", client);

		return;
	}

	//char[] sName = new char[MAX_NAME_LENGTH];
	//GetClientName(client, sName, MAX_NAME_LENGTH);

	//int iLength = ((strlen(sName) * 2) + 1);
	//char[] sEscapedName = new char[iLength]; // dynamic arrays! I love you, SourcePawn 1.7!
	//gH_SQL.Escape(sName, sEscapedName, iLength);

	char[] sQuery = new char[512];
	FormatEx(sQuery, 512, "INSERT IGNORE INTO zra_stats SET auth='%s';", sAuthID3[client]);

	gH_SQL.Query(SQL_InsertUser_Callback, sQuery, GetClientSerial(client));
}

public void SQL_InsertUser_Callback(Database db, DBResultSet results, const char[] error, any data)
{
	if(results == null)
	{
		int client = GetClientFromSerial(data);

		if(client == 0)
		{
			LogError("ZR-Achievements! Failed to insert a disconnected player's data to the table. Reason: %s", error);
		}

		else
		{
			LogError("ZR-Achievements! Failed to insert \"%N\"'s data to the table. Reason: %s", client, error);
		}

		return;
	}
}

public void ZR_OnClientInfected(client, attacker, motherInfect, respawnOverride, respawn)
{

	if(IsFakeClient(attacker))
	{
		return;
	}
	
	if(IsFakeClient(client))
	{
		return;
	}

	if(gH_SQL == null)
	{
		return;
	}
	
	char[] sQuery = new char[512];
	FormatEx(sQuery, 512, "UPDATE zra_stats SET humans_infected = humans_infected+1 WHERE auth='%s';", sAuthID3[attacker]);
	
	PrintToChatAll("Increment for %s",  sAuthID3[attacker]);

	gH_SQL.Query(SQL_IncrementHumansInfected_Callback, sQuery);
}

public void SQL_IncrementHumansInfected_Callback(Database db, DBResultSet results, const char[] error, any data)
{
	if(results == null)
	{
		LogError("ZR-Achievements: Users' data table creation failed. Reason: %s", error);

		return;
	}
}