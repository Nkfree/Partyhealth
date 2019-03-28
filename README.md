# TES3MP-Partyhealth-Add-on

## What it does:
When ```Player1``` 'Activates' ```Player2``` he gets continuous update of ```Player2```'s health as GUI or CHAT message.

## How to INSTALL:
1. Download the ```Partyhealth.lua``` and put it in */server/scripts/*
2. Open ```eventHandler.lua``` and find this code:
```lua
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
                    object.pid = tes3mp.GetObjectPid(index)
		    local objectPid = object.pid
```
below add: 
```lua
Partyhealth.OnActivate(pid, objectPid)
``` 
then save and close the ```eventHandler```.

3. Open ```serverCore.lua``` at the top add ```Partyhealth = require("Partyhealth")``` and find this code: 
```lua
function UpdateTime()
	
	
        if config.passTimeWhenEmpty or tableHelper.getCount(Players) > 0 then
```
below add: 
```lua
secondsUntilPartyUpdate = secondsUntilPartyUpdate - 1

if secondsUntilPartyUpdate < 1 then
	secondsUntilPartyUpdate = 2
	for pid, pl in pairs(Players) do
		if pl ~= nil and pl:IsLoggedIn() then
			if Players[pid].Partyhealth ~= nil then
				for pidTracked, _ in pairs(Players[pid].Partyhealth) do	
					if pidTracked ~= nil and Players[tonumber(pidTracked)] ~= nil and Players[tonumber(pidTracked)]:IsLoggedIn() then
						if Players[pid].Partyhealth[pidTracked].condition == true then
							if Players[pid].Partyhealth[pidTracked].displayType == "gui" then
								Partyhealth.Gui(pid, pidTracked)
							elseif Players[pid].Partyhealth[pidTracked].displayType == "chat" then
								Partyhealth.Chat(pid, pidTracked)
							else
								Partyhealth.Gui(pid, pidTracked)
							end
						end
					else
						print("pidTracked: "..pidTracked.." was deleted\n")
						Players[pid].Partyhealth[pidTracked] = nil
					end
				end

			end
		end
	end
end
``` 
then find this code: 
```lua
function OnPlayerConnect(pid)
```
and at the bottom of the function above last ```end``` add: ```Partyhealth.OnConnect(pid)```

lastly find this code:
```lua
function OnPlayerDisconnect(pid)
```
and just below the function add: ```Partyhealth.OnDisconnect(pid)```

then save and close the ```serverCore```.

4. Open ```commmandHandler.lua``` at the top add ```Partyhealth = require("Partyhealth")``` and add this code somewhere under other commands:
```lua
elseif cmd[1] == "hp" then
	Partyhealth.ComHP(pid, cmd[2])

elseif cmd[1] == "chat" or cmd[1] == "Chat" or cmd[1] == "1" and cmd[2] ~= nil then
	Partyhealth.ComChat(pid, cmd[2])

elseif cmd[1] == "Gui" or cmd[1] == "gui" or cmd[1] == "0" or cmd[1] == "Default" or cmd[1] == "default" and cmd[2] ~= nil then
	Partyhealth.ComGui(pid, cmd[2])
```
then save and close the ```commandHandler```.
That should be all.


## How to do it in-game (if it needs further explanation):
Approach another ```Player``` and hit the button which you use for opening ```doors```.

To turn it off write in CHAT ```/hp``` (notice: It will stop all mesagges from appearing and you will have to Activate player again.)
To switch between GUI message and chat message use any of these in the CHAT:
GUI - /show default ; /show gui ; /show 0
CHAT - /show chat ; /show 1

## Known problems:
Feel free to tell me, I don't know if I'll be able to solve them though.


## Credits
Each of these guys helped me with another part of the code as it was the first thing that I ever "did":

```DavidC```

```discordpeter```

```nox7```
