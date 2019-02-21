# TES3MP-Partyhealth-Add-on

## What it does:
When ```Player1``` 'Activates' ```Player2``` he gets continuous update of ```Player2```'s health as GUImessage.

## How to INSTALL:
1. Download the ```Partyhealth.lua``` and put it in */mp-stuff/scripts/*
2. Open ```eventHandler.lua``` and find this code:
```
eventHandler.OnObjectActivate = function(pid, cellDescription)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        if LoadedCells[cellDescription] ~= nil then

            tes3mp.ReadReceivedObjectList()
            -- Add your own logic here to prevent objects from being activated in certain places,
            -- or to make specific things happen in certain situations, such as when players
            -- are activated by other players
            local isValid = true

            for index = 0, tes3mp.GetObjectListSize() - 1 do

                local debugMessage = "- "
                local isObjectPlayer = tes3mp.IsObjectPlayer(index)
                local objectPid, objectRefId, objectUniqueIndex

                if isObjectPlayer then
```
at the bottom add: 
```
Players[pid].assignedTargetPd = tes3mp.GetObjectPid(index)
Partyhealth.condition[pid] = true
``` 
then save and close the ```eventHandler```.

3. Open ```serverCore.lua``` at the top add ```Partyhealth = require("Partyhealth")``` and find this code: 
```
function UpdateTime()
	
	
        if config.passTimeWhenEmpty or tableHelper.getCount(Players) > 0 then
```
at the bottom add: 
```
secondsUntilPartyUpdate = secondsUntilPartyUpdate - 1

	if secondsUntilPartyUpdate < 1 then
		secondsUntilPartyUpdate = 2
		for pid, pl in pairs(Players) do
			if pl ~= nil and pl:IsLoggedIn() then
				if Players[pid].assignedTargetPd ~= nil then
					if  Players[Players[pid].assignedTargetPd] ~= nil and Players[Players[pid].assignedTargetPd]:IsLoggedIn() then
						if Partyhealth.condition[pid] then
							Partyhealth.One(pid, Players[pid].assignedTargetPd )
						end
					else
						Partyhealth.condition[pid] = false
					end
				end
			end
		end
	end
``` 
then save and close the ```serverCore```.

4. Open ```commmandHandler.lua``` at the top add ```Partyhealth = require("Partyhealth")``` and add this code somewhere under other commands:
```
	elseif cmd[1] == "hp" then
		Partyhealth.condition[pid] = false
```
then save and close the ```commandHandler```.
That should be all.


## How to do it:
If it needs further explanation - approach another ```Player``` and hit the button which you use for opening ```doors```.

## Known problems:
1. I didn't have option to test it with more players than 2 - I don't know how organized it will be when you activate more than one player.



## Credits
Each of these guys helped me with another part of the code as it was the first thing that I ever "did":

```DavidC```

```discordpeter```

```nox7```
