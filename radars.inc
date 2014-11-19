//------------------------------------------------------------------------------

/*
	SA-MP Radars include
	
	Description:
		This include provide code to create vehicle radars in SA-MP.

	License:
		The MIT License (MIT)
		Copyright (c) 2014 WiRR-
		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modiY, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:
		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.

	Author:
		WiRR

	Contributors:
		Y_Less - ALS Hooking method

	Version:
		0.2
*/

//------------------------------------------------------------------------------

#include <a_samp>

#if defined inc_radars_included
	#endinput
#endif
#define inc_radars_included

//------------------------------------------------------------------------------

/*
native CreateRadar(Float:X, Float:Y, Float:Z, Float:rX, Float:rY, Float:rZ, Float:DrawDistance = 200.0, maxspeed = 140, radius = 15.0, activated = true);
native SetRadarPosition(radarid, Float:Y, Float:Z, Float:rX, Float:rY, Float:rZ, Float:DrawDistance = 200.0);
native GetRadarPosition(radarid, &Float:Y, &Float:Z, &Float:rX, &Float:rY, &Float:rZ);
native SetRadarActivated(radarid, bool:activated);
native SetRadarRadius(radarid, Float:radius);
native SetRadarMaxSpeed(radarid, maxspeed);
native IsRadarActivated(radarid);
native GetRadarMaxSpeed(radarid);
native GetRadarObjectID(radarid);
native GetRadarRadius(radarid);
native IsValidRadar(radarid);
native DestroyRadar(radarid);
*/

//------------------------------------------------------------------------------

#if !defined MAX_RADARS
	#define MAX_RADARS 32
#endif

#if !defined RADAR_MODEL_ID
	#define RADAR_MODEL_ID 18880
#endif

#define INVALID_RADAR_ID -1

//------------------------------------------------------------------------------

enum E_RADAR_DATA
{
	Float:E_RADAR_POS[3],
	Float:E_RADAR_ROT[3],
	Float:E_RADAR_DRAWDIST,
	Float:E_RADAR_RADIUS,
	bool:E_RADAR_ISACTIVE,
	E_RADAR_MAXSPEED,
	E_RADAR_OBJECTID
}
static g_eRadarData[MAX_RADARS][E_RADAR_DATA];
static g_radarTimerID;

//------------------------------------------------------------------------------

forward OnRadarUpdate();
forward OnPlayerEnterRadar(playerid, radarid, speed);

//------------------------------------------------------------------------------

stock CreateRadar(Float:X, Float:Y, Float:Z, Float:rX, Float:rY, Float:rZ, Float:DrawDistance = 200.0, MaxSpeed = 80, Float:Radius = 15.0, bool:isActive = true)
{
	new radarid = GetFreeRadarID();

	if(radarid == INVALID_RADAR_ID)
	{
		print("ERROR: Limit of radars exceeded! Increase the limit or reduce the created radars.");
		return 0;
	}

	g_eRadarData[radarid][E_RADAR_POS][0]		= X;
	g_eRadarData[radarid][E_RADAR_POS][1]		= Y;
	g_eRadarData[radarid][E_RADAR_POS][2]		= Z;

	g_eRadarData[radarid][E_RADAR_ROT][0]		= rX;
	g_eRadarData[radarid][E_RADAR_ROT][1]		= rY;
	g_eRadarData[radarid][E_RADAR_ROT][2]		= rZ;

	g_eRadarData[radarid][E_RADAR_DRAWDIST]		= DrawDistance;
	g_eRadarData[radarid][E_RADAR_MAXSPEED]		= MaxSpeed;

	g_eRadarData[radarid][E_RADAR_RADIUS] 		= Radius;
	g_eRadarData[radarid][E_RADAR_ISACTIVE] 	= isActive;

	g_eRadarData[radarid][E_RADAR_OBJECTID]		= CreateObject(RADAR_MODEL_ID, X, Y, Z, rX, rY, rZ, DrawDistance);

	return radarid;
}

//------------------------------------------------------------------------------

stock GetRadarObjectID(radarid)
	return g_eRadarData[radarid][E_RADAR_OBJECTID];

//------------------------------------------------------------------------------

stock IsValidRadar(radarid)
	return !(g_eRadarData[radarid][E_RADAR_POS][0] == 0.0 && g_eRadarData[radarid][E_RADAR_POS][1] == 0.0 && g_eRadarData[radarid][E_RADAR_POS][2] == 0.0);

//------------------------------------------------------------------------------

stock DestroyRadar(radarid)
{
	if(IsValidRadar(radarid))
		DestroyObject(g_eRadarData[radarid][E_RADAR_OBJECTID]);

	g_eRadarData[radarid][E_RADAR_OBJECTID] = INVALID_OBJECT_ID;

	g_eRadarData[radarid][E_RADAR_POS][0]		= 0.0;
	g_eRadarData[radarid][E_RADAR_POS][1]		= 0.0;
	g_eRadarData[radarid][E_RADAR_POS][2]		= 0.0;

	g_eRadarData[radarid][E_RADAR_ROT][0]		= 0.0;
	g_eRadarData[radarid][E_RADAR_ROT][1]		= 0.0;
	g_eRadarData[radarid][E_RADAR_ROT][2]		= 0.0;

	g_eRadarData[radarid][E_RADAR_DRAWDIST]		= 0;
	g_eRadarData[radarid][E_RADAR_MAXSPEED]		= 0;

	g_eRadarData[radarid][E_RADAR_RADIUS] 		= 0;
	g_eRadarData[radarid][E_RADAR_ISACTIVE]		= false;
	return 1;
}

// -----------------------------------------------------------------------------

stock SetRadarPosition(radarid, Float:X, Float:Y, Float:Z, Float:rX, Float:rY, Float:rZ, Float:DrawDistance = 200.0)
{
	g_eRadarData[radarid][E_RADAR_POS][0] = X;
	g_eRadarData[radarid][E_RADAR_POS][1] = Y;
	g_eRadarData[radarid][E_RADAR_POS][2] = Z;

	g_eRadarData[radarid][E_RADAR_ROT][0] = rX;
	g_eRadarData[radarid][E_RADAR_ROT][1] = rY;
	g_eRadarData[radarid][E_RADAR_ROT][2] = rZ;

	if(IsValidRadar(radarid))
		DestroyObject(g_eRadarData[radarid][E_RADAR_OBJECTID]);

	g_eRadarData[radarid][E_RADAR_OBJECTID] = CreateObject(RADAR_MODEL_ID, X, Y, Z, rX, rY, rZ, DrawDistance);
	return 1;
}

// -----------------------------------------------------------------------------

stock GetRadarPosition(radarid, &Float:X, &Float:Y, &Float:Z, &Float:rX, &Float:rY, &Float:rZ)
{
	X = g_eRadarData[radarid][E_RADAR_POS][0];
	Y = g_eRadarData[radarid][E_RADAR_POS][1];
	Z = g_eRadarData[radarid][E_RADAR_POS][2];

	rX = g_eRadarData[radarid][E_RADAR_ROT][0];
	rY = g_eRadarData[radarid][E_RADAR_ROT][1];
	rZ = g_eRadarData[radarid][E_RADAR_ROT][2];
	return 1;
}

// -----------------------------------------------------------------------------

stock SetRadarRadius(radarid, Float:radius)
	return g_eRadarData[radarid][E_RADAR_RADIUS] = radius;

// -----------------------------------------------------------------------------

stock Float:GetRadarRadius(radarid)
	return g_eRadarData[radarid][E_RADAR_RADIUS];

// -----------------------------------------------------------------------------

stock SetRadarMaxSpeed(radarid, maxspeed)
	return g_eRadarData[radarid][E_RADAR_MAXSPEED] = maxspeed;

// -----------------------------------------------------------------------------

stock GetRadarMaxSpeed(radarid)
{
	return g_eRadarData[radarid][E_RADAR_MAXSPEED];
}

// -----------------------------------------------------------------------------

stock SetRadarActivated(radarid, bool:activated)
	return g_eRadarData[radarid][E_RADAR_ISACTIVE] = activated;

// -----------------------------------------------------------------------------

stock IsRadarActivated(radarid)
	return g_eRadarData[radarid][E_RADAR_ISACTIVE];

// -----------------------------------------------------------------------------

stock GetFreeRadarID()
{
	for(new i; i < MAX_RADARS; i++)
		if(!IsValidRadar(i))
			return i;

	return INVALID_RADAR_ID;
}

// -----------------------------------------------------------------------------

#if defined FILTERSCRIPT
	public OnFilterScriptInit()
	{
		g_radarTimerID = SetTimer("OnRadarUpdate", 1000, true);
		#if defined inc_Radars_OnFilterScriptInit
			return inc_Radars_OnFilterScriptInit();
		#else
			return 1;
		#endif
	}
	#if defined _ALS_OnFilterScriptInit
		#undef OnFilterScriptInit
	#else
		#define _ALS_OnFilterScriptInit
	#endif
	 
	#define OnFilterScriptInit inc_Radars_OnFilterScriptInit
	#if defined inc_Radars_OnFilterScriptInit
		forward inc_Radars_OnFilterScriptInit();
	#endif

// -----------------------------------------------------------------------------

	public OnFilterScriptExit()
	{
		KillTimer(g_radarTimerID);
		#if defined inc_Radars_OnFilterScriptExit
			return inc_Radars_OnFilterScriptExit();
		#else
			return 1;
		#endif
	}
	#if defined _ALS_OnFilterScriptExit
		#undef OnFilterScriptExit
	#else
		#define _ALS_OnFilterScriptExit
	#endif
	 
	#define OnFilterScriptExit inc_Radars_OnFilterScriptExit
	#if defined inc_Radars_OnFilterScriptExit
		forward inc_Radars_OnFilterScriptExit();
	#endif
#else
	public OnGameModeInit()
	{
		g_radarTimerID = SetTimer("OnRadarUpdate", 1000, true);
		#if defined inc_Radars_OnGameModeInit
			return inc_Radars_OnGameModeInit();
		#else
			return 1;
		#endif
	}
	#if defined _ALS_OnGameModeInit
		#undef OnGameModeInit
	#else
		#define _ALS_OnGameModeInit
	#endif
	 
	#define OnGameModeInit inc_Radars_OnGameModeInit
	#if defined inc_Radars_OnGameModeInit
		forward inc_Radars_OnGameModeInit();
	#endif

// -----------------------------------------------------------------------------

	public OnGameModeExit()
	{
		KillTimer(g_radarTimerID);
		#if defined inc_Radars_OnGameModeExit
			return inc_Radars_OnGameModeExit();
		#else
			return 1;
		#endif
	}
	#if defined _ALS_OnGameModeExit
		#undef OnGameModeExit
	#else
		#define _ALS_OnGameModeExit
	#endif
	 
	#define OnGameModeExit inc_Radars_OnGameModeExit
	#if defined inc_Radars_OnGameModeExit
		forward inc_Radars_OnGameModeExit();
	#endif
#endif

// -----------------------------------------------------------------------------

stock Float:_getPlayerSpeed(playerid, bool:UseMPH = false)
{
    new Float:speed_x,Float:speed_y,Float:speed_z,Float:temp_speed;
    GetVehicleVelocity(vehicleid,speed_x,speed_y,speed_z);
    if(UseMPH == false) temp_speed = floatsqroot(((speed_x*speed_x)+(speed_y*speed_y))+(speed_z*speed_z))*136.666667;
    else temp_speed = floatsqroot(((speed_x*speed_x)+(speed_y*speed_y))+(speed_z*speed_z))*85.4166672;
    floatround(temp_speed,floatround_round);
    return temp_speed;
}

// -----------------------------------------------------------------------------

public OnRadarUpdate()
{
	for(new slots = GetMaxPlayers(), i; i < slots; i++)
	{
		if(!IsPlayerConnected(i))
			continue;

		if(GetPVarInt(i, "enteredRadar"))
		{
			DeletePVar(i, "enteredRadar");
			continue;
		}

		for(new r; r < MAX_RADARS; r++)
		{
			if(!IsValidRadar(r) || !IsRadarActivated(r))
				continue;

			if(!IsPlayerInRangeOfPoint(i, g_eRadarData[r][E_RADAR_RADIUS],  g_eRadarData[r][E_RADAR_POS][0],  g_eRadarData[r][E_RADAR_POS][1],  g_eRadarData[r][E_RADAR_POS][2]))
				continue;

			if(_getPlayerSpeed(i) < g_eRadarData[r][E_RADAR_MAXSPEED])
				continue;

			OnPlayerEnterRadar(i, i, _getPlayerSpeed(i));
			SetPVarInt(i, "enteredRadar", 1);
		}
	}
}

// -----------------------------------------------------------------------------

// END	OF	FILE

// -----------------------------------------------------------------------------
