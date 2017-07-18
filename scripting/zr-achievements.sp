#include <sourcemod>  

public Plugin:myinfo =
{
 name = "ZR-Achievements",
 author = "theSaint",
 description = "Achievements system for Zombie Escape servers",
 version = "1.0",
 url = "http://ggeasy.pl"
};

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