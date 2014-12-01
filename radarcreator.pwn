//------------------------------------------------------------------------------

/*
	SA-MP Radar creator
	
	Description:
		This filterscript provide code to create and save radars in game.

	License:
		The MIT License (MIT)
		Copyright (c) 2014 Larceny
		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
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
		Larceny

	Contributors:
		Y_Less - GetXYInFrontOfPlayer function

	Version:
		1.5
*/

//------------------------------------------------------------------------------

#define FILTERSCRIPT

#include <a_samp>
#include <radars>

//------------------------------------------------------------------------------

#define DIALOG_UPDATES		2157
#define DIALOG_EDITOR		2158
#define DIALOG_CAPTION		"Radar Editor 1.5"
#define DIALOG_INFO			"1.\tCreate a Radar\n2.\tEdit nearest radar\n3.\tDelete nearest radar\n4.\tGo to radar\n5.\tExport nearest radar\n6.\tExport all radars\n7.\tUpdates"

#define COLOR_INFO			0x00a4a7ff
#define COLOR_ERROR			0xff4040ff

#define PlaySelectSound(%0)	PlayerPlaySound(%0,1083,0.0,0.0,0.0)
#define PlayCancelSound(%0)	PlayerPlaySound(%0,1084,0.0,0.0,0.0)
#define PlayErrorSound(%0)	PlayerPlaySound(%0,1085,0.0,0.0,0.0)

//------------------------------------------------------------------------------

enum E_RC_PLAYER
{
	E_RC_PLAYER_RADAR_ID,
	bool:E_RC_PLAYER_IS_EDITING
}
new gPlayerData[MAX_PLAYERS][E_RC_PLAYER];

//------------------------------------------------------------------------------

public OnFilterScriptInit()
{
	printf("- Radar Creator loaded.");
	SendClientMessageToAll(COLOR_INFO, "* /radar to open radar editor.");
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i))
			continue;

		ResetPlayerVars(i);
	}
	return 1;
}

//------------------------------------------------------------------------------

public OnFilterScriptExit()
{
	for(new i; i < MAX_RADARS; i++)
		if(IsValidRadar(i))
			DestroyRadar(i);
	return 1;
}

//------------------------------------------------------------------------------

public OnPlayerSpawn(playerid)
{
	SendClientMessage(playerid, COLOR_INFO, "* /radar to open radar editor.");
	return 1;
}

//------------------------------------------------------------------------------

public OnPlayerCommandText(playerid, cmdtext[])
{
    if(!strcmp(cmdtext, "/radar", true))
    {
    	if(gPlayerData[playerid][E_RC_PLAYER_IS_EDITING])
    		return SendClientMessage(playerid, COLOR_ERROR, "* You are editing a radar already!");

        ShowPlayerDialog(playerid, DIALOG_EDITOR, DIALOG_STYLE_LIST, DIALOG_CAPTION, DIALOG_INFO, "Select", "Cancel");
        PlaySelectSound(playerid);
        return 1;
    }
    return 0;
}

//------------------------------------------------------------------------------

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_EDITOR:
		{
			if(!response)
				return PlayCancelSound(playerid);

			switch(listitem)
			{
				case 0: // Create a Radar
				{
					new Float:X, Float:Y, Float:Z;
					GetPlayerPos(playerid, X, Y, Z);
					GetXYInFrontOfPlayer(playerid, X, Y, 5.0);
					gPlayerData[playerid][E_RC_PLAYER_RADAR_ID] = CreateRadar( X, Y, Z, 0.00, 0.00, 0.00 );
					gPlayerData[playerid][E_RC_PLAYER_IS_EDITING] = true;

					EditObject(playerid, GetRadarObjectID(gPlayerData[playerid][E_RC_PLAYER_RADAR_ID]));
					SendClientMessage(playerid, COLOR_INFO, "* Edit the radar position and save.");
					PlaySelectSound(playerid);
					return 1;
				}
				case 1: //Edit nearest radar
				{
					new
						radarid = INVALID_RADAR_ID,
						Float:distance = 20.0,
						Float:X,
						Float:Y,
						Float:Z,
						Float:placeholder;

					for(new i; i < MAX_RADARS; i++)
					{
						if(!IsValidRadar(i))
							continue;

						GetRadarPosition(i, X, Y, Z, placeholder, placeholder, placeholder);
						if(GetPlayerDistanceFromPoint(playerid, X, Y, Z) < distance)
						{
							distance = GetPlayerDistanceFromPoint(playerid, X, Y, Z);
							radarid = i;
						}
					}

					if(radarid == INVALID_RADAR_ID)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* No radars near you!");
						ShowPlayerDialog(playerid, DIALOG_EDITOR, DIALOG_STYLE_LIST, DIALOG_CAPTION, DIALOG_INFO, "Select", "Cancel");
						PlayErrorSound(playerid);
						return 1;
					}

					gPlayerData[playerid][E_RC_PLAYER_RADAR_ID]		= radarid;
					gPlayerData[playerid][E_RC_PLAYER_IS_EDITING]	= true;
					EditObject(playerid, GetRadarObjectID(gPlayerData[playerid][E_RC_PLAYER_RADAR_ID]));
					PlaySelectSound(playerid);
					return 1;
				}
				case 2: // Delete nearest radar
				{
					new
						radarid = INVALID_RADAR_ID,
						Float:distance = 20.0,
						Float:X,
						Float:Y,
						Float:Z,
						Float:placeholder;

					for(new i; i < MAX_RADARS; i++)
					{
						if(!IsValidRadar(i))
							continue;

						GetRadarPosition(i, X, Y, Z, placeholder, placeholder, placeholder);
						if(GetPlayerDistanceFromPoint(playerid, X, Y, Z) < distance)
						{
							distance = GetPlayerDistanceFromPoint(playerid, X, Y, Z);
							radarid = i;
						}
					}

					if(radarid == INVALID_RADAR_ID)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* No radars near you!");
						ShowPlayerDialog(playerid, DIALOG_EDITOR, DIALOG_STYLE_LIST, DIALOG_CAPTION, DIALOG_INFO, "Select", "Cancel");
						PlayErrorSound(playerid);
						return 1;
					}

					DestroyRadar(radarid);
					PlaySelectSound(playerid);
					return 1;
				}
				case 3: //Go to radar
				{
					new
						Float:X,
						Float:Y,
						Float:Z,
						Float:placeholder;

					new dialogList[2048];

					for(new i; i < MAX_RADARS; i++)
					{
						if(!IsValidRadar(i))
							continue;

						GetRadarPosition(i, X, Y, Z, placeholder, placeholder, placeholder);

						new radarInfo[40];
						format(radarInfo, 40, "RadarID: %d\tDistance: %.2f\n", i, GetPlayerDistanceFromPoint(playerid, X, Y, Z));
						strins(dialogList, radarInfo, strlen(dialogList));
					}

					if(strlen(dialogList) < 1)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* No radars created!");
						ShowPlayerDialog(playerid, DIALOG_EDITOR, DIALOG_STYLE_LIST, DIALOG_CAPTION, DIALOG_INFO, "Select", "Cancel");
						PlayErrorSound(playerid);
						return 1;
					}

					ShowPlayerDialog(playerid, DIALOG_EDITOR+1, DIALOG_STYLE_LIST, DIALOG_CAPTION, dialogList, "Go", "Back");
					PlaySelectSound(playerid);
					return 1;
				}
				case 4: //Export nearest radar
				{
					new
						radarid = INVALID_RADAR_ID,
						Float:distance = 20.0,
						Float:X,
						Float:Y,
						Float:Z,
						Float:rX,
						Float:rY,
						Float:rZ;

					for(new i; i < MAX_RADARS; i++)
					{
						if(!IsValidRadar(i))
							continue;

						GetRadarPosition(i, X, Y, Z, rX, rY, rZ);
						if(GetPlayerDistanceFromPoint(playerid, X, Y, Z) < distance)
						{
							distance = GetPlayerDistanceFromPoint(playerid, X, Y, Z);
							radarid = i;
						}
					}

					if(radarid == INVALID_RADAR_ID)
					{
						SendClientMessage(playerid, COLOR_ERROR, "* No radars near you!");
						ShowPlayerDialog(playerid, DIALOG_EDITOR, DIALOG_STYLE_LIST, DIALOG_CAPTION, DIALOG_INFO, "Select", "Cancel");
						PlayErrorSound(playerid);
						return 1;
					}

					GetRadarPosition(radarid, X, Y, Z, rX, rY, rZ);

					new textToSave[128];
					new File:radarFile = fopen("radars.txt", io_append);
			        format(textToSave, 256, "CreateRadar(%f, %f, %f, %f, %f, %f);\n", X, Y, Z, rX, rY, rZ);
			        fwrite(radarFile, textToSave);
			        fclose(radarFile);

			        PlaySelectSound(playerid);
			        SendClientMessage(playerid, COLOR_INFO, "* Nearest radar saved to scriptfiles/radars.txt");
			        return 1;
				}
				case 5: // Export all radars
				{
					new count;
					for(new i; i < MAX_RADARS; i++)
					{
						if(!IsValidRadar(i))
							continue;

						count++;

						new Float:X, Float:Y, Float:Z, Float:rX, Float:rY, Float:rZ;
						GetRadarPosition(i, X, Y, Z, rX, rY, rZ);

						new textToSave[128];
						new File:radarFile = fopen("radars.txt", io_append);
			        	format(textToSave, 256, "CreateRadar(%f, %f, %f, %f, %f, %f);\n", X, Y, Z, rX, rY, rZ);
			        	fwrite(radarFile, textToSave);
			        	fclose(radarFile);
					}

					if(count != 0)
					{
						PlaySelectSound(playerid);
			        	SendClientMessage(playerid, COLOR_INFO, "* All radars saved to scriptfiles/radars.txt");						
					}
					else
					{
						PlayErrorSound(playerid);
			        	SendClientMessage(playerid, COLOR_ERROR, "* No radars created!");	
			        	ShowPlayerDialog(playerid, DIALOG_EDITOR, DIALOG_STYLE_LIST, DIALOG_CAPTION, DIALOG_INFO, "Select", "Cancel");
					}
					return 1;
				}
				case 6: // Updates
				{
					ShowPlayerDialog(playerid, DIALOG_UPDATES, DIALOG_STYLE_MSGBOX, DIALOG_CAPTION, "Radar Creator & Radar Include created by Larceny\n\nFor new updates or report a bug/suggestion go to:\nhttps://github.com/Larceny-/SA-MP-Radars", "Back", "");
					PlaySelectSound(playerid);
					return 1;
				}
			}
		}
		case DIALOG_EDITOR+1:
		{
			if(!response)
			{
				ShowPlayerDialog(playerid, DIALOG_EDITOR, DIALOG_STYLE_LIST, DIALOG_CAPTION, DIALOG_INFO, "Select", "Cancel");
				PlayCancelSound(playerid);
				return 1;
			}

			new radaridList[MAX_RADARS], count;
			for(new i; i < MAX_RADARS; i++)
			{
				if(!IsValidRadar(i))
					continue;

				radaridList[count] = i;
				count++;
			}

			new	Float:X, Float:Y, Float:Z, Float:placeholder;
			GetRadarPosition(radaridList[listitem], X, Y, Z, placeholder, placeholder, placeholder);

			SetPlayerPos(playerid, X+1.0, Y+1.0, Z+1.0);

			PlaySelectSound(playerid);
			return 1;
		}
		case DIALOG_UPDATES:
		{
			ShowPlayerDialog(playerid, DIALOG_EDITOR, DIALOG_STYLE_LIST, DIALOG_CAPTION, DIALOG_INFO, "Select", "Cancel");
			PlaySelectSound(playerid);
			return 1;
		}
	}
	return 0;
}

//------------------------------------------------------------------------------

public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	new Float:oldX, Float:oldY, Float:oldZ, Float:oldRotX, Float:oldRotY, Float:oldRotZ;
	GetObjectPos(objectid, oldX, oldY, oldZ);
	GetObjectRot(objectid, oldRotX, oldRotY, oldRotZ);

	if(!playerobject)
	{
	    if(!IsValidObject(objectid)) return 1;

	    SetObjectPos(objectid, fX, fY, fZ);		          
        SetObjectRot(objectid, fRotX, fRotY, fRotZ);
	}
 
	if(response == EDIT_RESPONSE_FINAL)
	{
		if(objectid == GetRadarObjectID(gPlayerData[playerid][E_RC_PLAYER_RADAR_ID]))
			SetRadarPosition(gPlayerData[playerid][E_RC_PLAYER_RADAR_ID], fX, fY, fZ, fRotX, fRotY, fRotZ);

		gPlayerData[playerid][E_RC_PLAYER_IS_EDITING] = false;
		PlaySelectSound(playerid);
	}
 
	if(response == EDIT_RESPONSE_CANCEL)
	{
		if(!playerobject)
		{
			if(objectid == GetRadarObjectID(gPlayerData[playerid][E_RC_PLAYER_RADAR_ID]))
			{
				new Float:rPos[3], Float:rRot[3];
				GetRadarPosition(gPlayerData[playerid][E_RC_PLAYER_RADAR_ID], rPos[0], rPos[1], rPos[2], rRot[0], rRot[1], rRot[2]);
				SetRadarPosition(gPlayerData[playerid][E_RC_PLAYER_RADAR_ID], rPos[0], rPos[1], rPos[2], rRot[0], rRot[1], rRot[2]);
			}
			else
			{
				SetObjectPos(objectid, oldX, oldY, oldZ);
				SetObjectRot(objectid, oldRotX, oldRotY, oldRotZ);				
			}
		}
		else
		{
			SetPlayerObjectPos(playerid, objectid, oldX, oldY, oldZ);
			SetPlayerObjectRot(playerid, objectid, oldRotX, oldRotY, oldRotZ);				
		}
		gPlayerData[playerid][E_RC_PLAYER_IS_EDITING] = false;
		PlayCancelSound(playerid);
	}
	return 1;
}

//------------------------------------------------------------------------------

public OnPlayerEnterRadar(playerid, radarid, Float:speed)
{
	new message[64];
	format(message, sizeof(message), "* You entered in radarid: %d at %.0f KMH.", radarid, speed);
	SendClientMessage(playerid, COLOR_INFO, message);
	return 1;
}

//------------------------------------------------------------------------------

public OnPlayerConnect(playerid)
{
	ResetPlayerVars(playerid);
	return 1;
}

//------------------------------------------------------------------------------

GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{	// Created by Y_Less

	new Float:a;

	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);

	if (GetPlayerVehicleID(playerid)) {
	    GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

//------------------------------------------------------------------------------

ResetPlayerVars(playerid)
{
	gPlayerData[playerid][E_RC_PLAYER_RADAR_ID]		= INVALID_RADAR_ID;	
	gPlayerData[playerid][E_RC_PLAYER_IS_EDITING]	= false;
}

//------------------------------------------------------------------------------
