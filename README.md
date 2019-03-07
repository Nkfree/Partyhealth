# TES3MP-Partyhealth-Add-on

## What it does:
When ```Player1``` 'Activates' ```Player2``` he gets continuous update of ```Player2```'s health as GUImessage.

## How to INSTALL:
1. Download the ```Partyhealth.lua``` and put it in */mp-stuff/scripts/*
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
```
below add: 
```lua
if type(Players[pid].playersTracked) ~= "table" then Players[pid].playersTracked = {} end
if not tableHelper.containsValue(Players[pid].playersTracked, tes3mp.GetObjectPid(index)) then
	table.insert(Players[pid].playersTracked, tes3mp.GetObjectPid(index))
end
Partyhealth.condition[pid] = true
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
				if Players[pid].playersTracked ~= nil then
					for _, pidTracked in pairs(Players[pid].playersTracked) do
						if  pidTracked ~= nil and Players[pidTracked]:IsLoggedIn() then
							if Partyhealth.condition[pid] then
								if Partyhealth.Display[pid] == "gui" then
									Partyhealth.Gui(pid, pidTracked)
								elseif Partyhealth.Display[pid] == "chat" then
									Partyhealth.Chat(pid, pidTracked)
								else
									Partyhealth.Gui(pid, pidTracked)
								end
							end
						else
							Partyhealth.condition[pid] = false
							Partyhealth.Display[pid] = "gui"
						end
					end
				end
			else
				Partyhealth.condition[pid] = false
				Partyhealth.Display[pid] = "gui"
			end
		end
end
``` 
then find this code: 
```lua
function OnPlayerConnect(pid)
```
and at the bottom above last ```end``` (not below the function) add: ```Partyhealth.OnConnect(pid)```

lastly find this code:
```lua
function OnPlayerDisconnect(pid)
```
and just below the function add: ```Partyhealth.OnDisconnect(pid)```

then save and close the ```serverCore```.

4. Open ```commmandHandler.lua``` at the top add ```Partyhealth = require("Partyhealth")``` and add this code somewhere under other commands:
```lua
elseif cmd[1] == "hp" then
	Partyhealth.condition[pid] = false

elseif cmd[1] == "show" then
if cmd[2] == "chat" or cmd[2] == "Chat" or cmd[2] == "1" then
	Partyhealth.Display[pid] = "chat" 
elseif cmd[2] == "Gui" or cmd[2] == "gui" or cmd[2] == "0" or cmd[2] == "Default" or cmd[2] == "default" then
	Partyhealth.Display[pid] = "gui"
else
	tes3mp.SendMessage(pid, "Wrong input, for chat use: 'chat' or '1', for gui use: 'gui' or '1'".."\n", false)  
	Partyhealth.Display[pid] = "gui"
end
```
then save and close the ```commandHandler```.
That should be all.


## How to do it in-game (if it needs further explanation):
Approach another ```Player``` and hit the button which you use for opening ```doors```.

## Known problems:
Feel free to tell me, I don't know if I'll be able to solve them though.



## Credits
Each of these guys helped me with another part of the code as it was the first thing that I ever "did":

```DavidC```

```discordpeter```

```nox7```
