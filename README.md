## Radars

A SA:MP library containing functions to create speed radars to detect when a player exceeds the speed limit.

### Creating a radar

You can use the [radar creator](https://github.com/Wuzi/radars/blob/master/radarcreator.pwn) or place the object id 18880 with [samp-map-editor](http://forum.sa-mp.com/showthread.php?t=282801) and get the coordinates.

### Example

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

### Functions

Check [wiki](https://github.com/Wuzi/radars/wiki/Documentation) for a list with functions.
