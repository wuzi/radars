##SA-MP Speed Radars

A SA:MP library containing functions to create radars that detect when a player exceeds the speed limit of the radar.

##Creating a radar

You can use JernejL's map editor to position the radar:

![http://img819.imageshack.us/img819/1883/screenshotfrom201302140.th.png](http://img819.imageshack.us/img819/1883/screenshotfrom201302140.png)

![http://img228.imageshack.us/img228/1883/screenshotfrom201302140.png](http://img228.imageshack.us/img228/1883/screenshotfrom201302140.png)

![http://img41.imageshack.us/img41/5025/sampscreen.png](http://img41.imageshack.us/img41/5025/sampscreen.png)

```c
public OnGameModeInit()
{
	CreateRadar(1146.78, -1390.08, 12.83,   0.00, 0.00, 270.00);
	return 1;
}
```

##Example code

```c
new g_radarTest;

public OnGameModeInit()
{
    g_radarTest = CreateRadar(1146.78, -1390.08, 12.83,   0.00, 0.00, 270.00);
    return 1;
}

public OnPlayerEnterRadar(playerid, radarid, speed)
{
    if(radarid == g_radarTest)
    {
        GameTextForPlayer(playerid,"~n~~n~~n~~n~~n~~n~~r~You were fined!", 5000, 3);
        GivePlayerMoney(playerid, -500);
    }
    return 1;
}
```

##In-game creator

I might create an in-game creator in the future.

##Documentation

Check wiki for full functions documentation.
