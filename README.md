##SA-MP Speed Radars

A SA:MP library containing functions to create radars that detect when a player exceeds the speed limit of the radar.

***If you use any get speed function it is better to change the include to yours or vice-versa. Otherwise, it will give false-positives.***

##Creating a radar

Use the radar creator filterscript to create and save radars.

![](https://sc-cdn.scaleengine.net/i/316f349dbffc7cd615e66819c38c499c.jpg)

![](https://sc-cdn.scaleengine.net/i/7f8ce6bb40266c65ca1e7a8dc47bbde4.jpg)

![](https://sc-cdn.scaleengine.net/i/ad6beffd219e49eaf56a057165c1e231.jpg)

##Example code

```c
new gRadar;

public OnGameModeInit()
{
    gRadar = CreateRadar(2156.21, -2036.12, 36.11,   0.00, 0.00, 0.00);
    return 1;
}

public OnPlayerEnterRadar(playerid, radarid, Float:speed)
{
    switch(radarid)
    {
        case gRadar:
        {
            GameTextForPlayer(playerid,"~r~You were fined!", 5000, 3);
            GivePlayerMoney(playerid, -500);
        }
    }
    return 1;
}
```

##Documentation

Check wiki for full functions documentation.
