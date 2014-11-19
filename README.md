##SA-MP Speed Radars

A SA:MP library containing functions to create radars that detect when a player exceeds the speed limit of the radar.

##Creating a radar

Use the radar creator filterscript to create and save radars.

![](https://sc-cdn.scaleengine.net/i/da34b2f0d2341945fcea4538fdcd5adc.jpg)

![](https://sc-cdn.scaleengine.net/i/4e333249e609edb0cc29a0bf0b9660c9.jpg)

![](https://sc-cdn.scaleengine.net/i/e41a075b5682565b74bb949f29d8c43b.jpg)
This may look awkward but it is because i am using wine, on windows it will be okay.

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

##Documentation

Check wiki for full functions documentation.
