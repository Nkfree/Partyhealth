jsonInterface = require("jsonInterface")
tableHelper = require("tableHelper")
menuHelper = require("menuHelper")

local affectedlist = {}
local friendsData = {}
local helpHelper = {}



helpHelper.CreateMenu = function(pid, menuTitle, menuHeader, command, label)


if tostring(menuTitle) and tostring(menuHeader) and command and label then
	
	local text
	local getText 
	getText  = color.Orange .. menuHeader .. "\n"
	for k, v in pairs(command) do
		if tostring(command[k]) and tostring(label[k]) then
				getText  = getText  .. color.Yellow .. "/" .. command[k] .. "\n" .. color.White .. label[k] .. "\n"
		end
	end
	
	Menus[menuTitle] = {
		text = getText,
		buttons = {
			{ caption = "Exit", destinations = nil }
		}
}
end
return menuHelper.DisplayMenu(pid, menuTitle)
end

local config = {}

config.displayFastHP = false
config.showSameHealthTimes = 0
config.AddFriendGuiID = 3253
config.RemoveFriendGuiID = 3254
config.BusyFriendGuiID = 3255
config.AcceptFriendGuiID = 3256
config.RejectFriendGuiID = 3257
config.IdiotFriendGuiID = 3258
config.isInAcceptedGuiID = 3259
config.isInRejectedGuiID = 3260
config.showFriendslistGuiID = 3261
config.showBlacklistGuiID = 3262
config.SendFriendGuiID = 3263
config.ColorFriendlist = color.Green .. "Friendlist"
config.ColorBlacklist = color.Crimson .. "Blacklist"
config.ColorPlayerName = color.Yellow
config.ColorCasualText = color.SkyBlue


local Partyhealth = {}

Partyhealth.Menu = {}
Partyhealth.Menu.Cmds = {}
Partyhealth.Menu.Cmds[1] = config.ColorPlayerName .. "ph.add <pid>/<name>"
Partyhealth.Menu.Cmds[2] = config.ColorPlayerName .. "ph.friendlist"
Partyhealth.Menu.Cmds[3] = config.ColorPlayerName .. "ph.blacklist"
Partyhealth.Menu.Cmds[4] = config.ColorPlayerName .. "ph.hp <pid>/<name>"
Partyhealth.Menu.Cmds[5] = config.ColorPlayerName .. "ph.chat <pid>/<name>"
Partyhealth.Menu.Cmds[6] = config.ColorPlayerName .. "ph.gui <pid>/<name>"
Partyhealth.Menu.Cmds[7] = config.ColorPlayerName .. "ph.decent"
Partyhealth.Menu.Cmds[8] = config.ColorPlayerName .. "ph.default"

Partyhealth.Menu.Labels = {}
Partyhealth.Menu.Labels[1] = config.ColorCasualText .. "Sends friend request.\n"
Partyhealth.Menu.Labels[2] = config.ColorCasualText .. "Displays people you have added as friends.\n"
Partyhealth.Menu.Labels[3] = config.ColorCasualText .. "Displays people whose friend request you have rejected.\n"
Partyhealth.Menu.Labels[4] = config.ColorCasualText .. "Toggles display of health for certain player.\n"
Partyhealth.Menu.Labels[5] = config.ColorCasualText .. "Health messages for certain player will be displayed in chat.\n"
Partyhealth.Menu.Labels[6] = config.ColorCasualText .. "Health messages for certain player will be displayed in gui.\n"
Partyhealth.Menu.Labels[7] = config.ColorCasualText .. "Changes colors of Partyhealth messages to more dull.\n"
Partyhealth.Menu.Labels[8] = config.ColorCasualText .. "Changes colors of Partyhealth messages to more vivid.\n"

Partyhealth.Menu.Title = "Partyhealth menu"
Partyhealth.Menu.Header = color.Orange .. "Partyhealth command list:\n"









Partyhealth.UpdateInterval = 2
Partyhealth.Timer = tes3mp.CreateTimer("Update_time", Partyhealth.UpdateInterval * 1000)
Partyhealth.baseHealth = {}
Partyhealth.healthRatio = {}
Partyhealth.sender = {}

Update_time = function()

for pid, pl in pairs(Players) do
	if pl ~= nil and pl:IsLoggedIn() then
		if Players[pid].Partyhealth ~= nil then
			for pidTracked, _ in pairs(Players[pid].Partyhealth) do	
				if pidTracked ~= nil and Players[tonumber(pidTracked)] ~= nil and Players[tonumber(pidTracked)]:IsLoggedIn() then
					if Players[pid].Partyhealth[pidTracked].condition and Partyhealth.isInAccepted(pid, tonumber(pidTracked)) then
						if Players[pid].Partyhealth[pidTracked].displayType == "gui" then
							Partyhealth.Gui(pid, pidTracked)
						elseif Players[pid].Partyhealth[pidTracked].displayType == "chat" then
							Partyhealth.Chat(pid, pidTracked)
						else
							Partyhealth.Gui(pid, pidTracked)
						end
					end
				else
					Players[pid].Partyhealth[pidTracked] = nil
				end
			end
		
		end
	end
end

tes3mp.RestartTimer(Partyhealth.Timer, Partyhealth.UpdateInterval * 1000)
end


local SaveJSON = function()
	jsonInterface.save("PH_friendslist.json", friendsData)
end




Partyhealth.OnActivate = function(EventStatus, pid, cellDescription, objects, players)


for index = 0, tes3mp.GetObjectListSize() - 1 do
	local object={}
	
	local isObjectPlayer = tes3mp.IsObjectPlayer(index)
	
	if isObjectPlayer then
	object.pid = tes3mp.GetObjectPid(index)
	local objectPid = object.pid
	
	if config.displayFastHP == false then
	
		if Partyhealth.isInAccepted(pid, objectPid) then
			if Players[pid].Partyhealth == nil then Players[pid].Partyhealth = {} end
			Players[pid].Partyhealth[tostring(objectPid)] = {compareHealth = 0, condition = true, displayType = "gui", samehealthTimes = config.showSameHealthTimes}
		end
	
	else
		if Players[pid].Partyhealth == nil then Players[pid].Partyhealth = {} end
			Players[pid].Partyhealth[tostring(objectPid)] = {compareHealth = 0, condition = true, displayType = "gui", samehealthTimes = config.showSameHealthTimes}
		end
	end
		
end
end

Partyhealth.ComHelp = function(pid, cmd)
	
	if cmd[1] == "ph.help" then
		helpHelper.CreateMenu(pid, Partyhealth.Menu.Title, Partyhealth.Menu.Header, Partyhealth.Menu.Cmds, Partyhealth.Menu.Labels)
	end
end


Partyhealth.ComChangeChatMsgColor = function(pid, cmd)

	if Players[pid].Partyhealth.ColorMode == nil then Players[pid].Partyhealth.ColorMode = "default" end
	
	if cmd[1] == "ph.decent" and Players[pid].Partyhealth.ColorMode == "default" then
		config.ColorFriendlist = color.Silver .. "Friendlist"
		config.ColorBlacklist = color.Chocolate .. "Blacklist"
		config.ColorPlayerName = color.SkyBlue
		config.ColorCasualText = color.GoldenRod
		Players[pid].Partyhealth.ColorMode = "decent"
	end
		
	if cmd[1] == "ph.default" and Players[pid].Partyhealth.ColorMode == "decent" then
		config.ColorFriendlist = color.Green .. "Friendlist"
		config.ColorBlacklist = color.Crimson .. "Blacklist"
		config.ColorPlayerName = color.Yellow
		config.ColorCasualText = color.SkyBlue
		Players[pid].Partyhealth.ColorMode = "default"
	end
end

Partyhealth.OnServerPostInit = function(EventStatus)
	tes3mp.StartTimer(Partyhealth.Timer)
	local loadedData = jsonInterface.load("PH_friendslist.json")
	if loadedData then
		friendsData = loadedData
	else
	SaveJSON()
	end
end


Partyhealth.OnConnect = function(EventStatus, pid)

	local playerName = tes3mp.GetName(pid)
	if logicHandler.IsPlayerNameLoggedIn(playerName) then
		-- do nothing --
		
	else
		
		if Players[pid].Partyhealth == nil then Players[pid].Partyhealth = {} end
		Partyhealth.baseHealth[pid] = {}
		Partyhealth.healthRatio[pid] = {}
	end
end

Partyhealth.OnDisconnect = function(EventStatus, pid)
	
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		if Players[pid].Partyhealth ~= nil then 
			Players[pid].Partyhealth = nil 
		end
	end
	
end



Partyhealth.ComHP = function(pid, cmd)

if cmd[1] == "ph.hp" then
	local myCommand
	
	if cmd[2] ~= nil then
		myCommand = cmd[2]
	else
		return tes3mp.SendMessage(pid, config.ColorCasualText .. "Use the command like this: " .. "\n" .. config.ColorPlayerName .. "/hp <pid> " .. config.ColorCasualText .. "or " .. config.ColorPlayerName .. "/hp <name>" .. config.ColorCasualText .. "\n", false)
	end

    local targetPID = tonumber(myCommand)
    if targetPID == nil then
        for id, player in pairs(Players) do
            if myCommand == tes3mp.GetName(id) then
                targetPID = id
                break
            end
        end
    end
    if targetPID ~= nil then
		targetPID = tostring(targetPID)
        if Players[pid].Partyhealth[targetPID] ~= nil then
			if Players[pid].Partyhealth[targetPID].condition then
				Players[pid].Partyhealth[targetPID].condition = false
			else
				Players[pid].Partyhealth[targetPID].condition = true
			end
		end
    else
        tes3mp.SendMessage(pid, config.ColorCasualText .. "No such player online!\n")
    end
end
end 

Partyhealth.ComChat = function(pid, cmd)
	
	if cmd[1] == "ph.chat" then
		local myCommand
		
		if cmd[2] ~= nil then
			myCommand = cmd[2]
		else
			return tes3mp.SendMessage(pid, config.ColorCasualText .. "Use the command like this: " .. "\n" .. config.ColorPlayerName .. "/ph.chat <pid> " .. config.ColorCasualText .. "or " .. config.ColorPlayerName .. "/ph.chat <name>" .. config.ColorCasualText .. "\n", false)
		end
			
			
		local targetPID = tonumber(myCommand)
		
		if targetPID == nil then
			for id, player in pairs(Players) do
				if myCommand == tes3mp.GetName(id) then
					targetPID = id
					break
				end
			end
		end
		
		if targetPID ~= nil then
			targetPID = tostring(targetPID)
			if Players[pid].Partyhealth[targetPID] ~= nil then
				Players[pid].Partyhealth[targetPID].compareHealth = 0
				Players[pid].Partyhealth[targetPID].displayType = "chat"
			end
		else
			tes3mp.SendMessage(pid, config.ColorCasualText .. "No such player online!\n")
		end
	end 
	end

Partyhealth.ComGui = function(pid, cmd)

if cmd[1] == "ph.gui" then
	local myCommand
	
	if cmd[2] ~= nil then
		myCommand = cmd[2]
	else
		return tes3mp.SendMessage(pid, config.ColorCasualText .. "Use the command like this: " .. "\n" .. config.ColorPlayerName .. "/ph.gui <pid> " .. config.ColorCasualText .. "or " .. config.ColorPlayerName .. "/ph.gui <name>" .. config.ColorCasualText .. "\n", false)
	end

	local targetPID = tonumber(myCommand)
	
	if targetPID == nil then
        for id, player in pairs(Players) do
            if myCommand == tes3mp.GetName(id) then
                targetPID = id
                break
            end
        end
    end
	
	if targetPID ~= nil then
		targetPID = tostring(targetPID)
        if Players[pid].Partyhealth[targetPID] ~= nil then
			Players[pid].Partyhealth[targetPID].compareHealth = 0
            Players[pid].Partyhealth[targetPID].displayType = "gui"
		end
    else
        tes3mp.SendMessage(pid, config.ColorCasualText .. "No such player online!\n")
    end
end 
end
	
Partyhealth.Gui = function(pid, targetPID)

	
	Partyhealth.baseHealth[pid][targetPID] = math.floor(tes3mp.GetHealthBase(tonumber(targetPID)))
	
	Players[pid].Partyhealth[targetPID].currentHealth = math.floor(tes3mp.GetHealthCurrent(tonumber(targetPID)))
	
	Partyhealth.healthRatio[pid][targetPID] = Players[pid].Partyhealth[targetPID].currentHealth/Partyhealth.baseHealth[pid][targetPID]
	
	local healthRatio = Partyhealth.healthRatio[pid][targetPID]
	local currentHealth = Players[pid].Partyhealth[targetPID].currentHealth
	local baseHealth = Partyhealth.baseHealth[pid][targetPID]
	local nameofpid = tes3mp.GetName(targetPID)
	local samehealthTimes = Players[pid].Partyhealth[targetPID].samehealthTimes
	
	if Players[pid].Partyhealth[targetPID].compareHealth ~= currentHealth then
		for k, v in pairs(Players[pid].Partyhealth[targetPID]) do
			if k == "currentHealth" then
				Players[pid].Partyhealth[targetPID].compareHealth = v
			end
		end
		
		if healthRatio <= 1 and healthRatio >= 0.75 then
			tes3mp.MessageBox(pid, 8790, nameofpid .. "'s Health: " .. color.Green .. currentHealth .. color.GoldenRod .. "/" .. color.Green .. baseHealth, false)
		elseif healthRatio < 0.75 and healthRatio >= 0.5 then
			tes3mp.MessageBox(pid, 8791, nameofpid .. "'s Health: " .. color.Yellow .. currentHealth .. color.GoldenRod .. "/" .. color.Green .. baseHealth, false)
		elseif healthRatio < 0.5 then
			tes3mp.MessageBox(pid, 8792, color.Red .. "Immediatelly Heal: " .. nameofpid .. " (" .. color.Red .. currentHealth .. color.GoldenRod .. "/" .. color.Red .. baseHealth .. ")", false)
		end
	if samehealthTimes == 0 and not config.showSameHealthTimes == 0 then
		samehealthTimes = config.showSameHealthTimes
	end
	else
		if samehealthTimes > 0 or config.showSameHealthTimes == 0 then
			if healthRatio <= 1 and healthRatio >= 0.75 then
				tes3mp.MessageBox(pid, 8793, nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth, false)
			elseif healthRatio < 0.75 and healthRatio >= 0.5 then
				tes3mp.MessageBox(pid, 8794, nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth, false)
			elseif healthRatio < 0.5 then
				tes3mp.MessageBox(pid, 8795, color.Red .. "Immediatelly Heal: " .. nameofpid .. " (" .. color.Red .. currentHealth .. color.GoldenRod .. "/" .. color.Red .. baseHealth .. ")", false) 
			end
		elseif not config.showSameHealthTimes == 0 then
			samehealthTimes = samehealthTimes - 1
		end
	end
end

Partyhealth.Chat = function(pid, targetPID)

	

	targetPID = tostring(targetPID)
	
	Partyhealth.baseHealth[pid][targetPID] = math.floor(tes3mp.GetHealthBase(targetPID))
	
	Players[pid].Partyhealth[targetPID].currentHealth = math.floor(tes3mp.GetHealthCurrent(targetPID))
	
	Partyhealth.healthRatio[pid][targetPID] = Players[pid].Partyhealth[targetPID].currentHealth/Partyhealth.baseHealth[pid][targetPID]
	
	local healthRatio = Partyhealth.healthRatio[pid][targetPID]
	local currentHealth = Players[pid].Partyhealth[targetPID].currentHealth
	local baseHealth = Partyhealth.baseHealth[pid][targetPID]
	local nameofpid = tes3mp.GetName(targetPID)
	local samehealthTimes = Players[pid].Partyhealth[targetPID].samehealthTimes
	
	if Players[pid].Partyhealth[targetPID].compareHealth ~= currentHealth then
		for k, v in pairs(Players[pid].Partyhealth[targetPID]) do
			if k == "currentHealth" then
				Players[pid].Partyhealth[targetPID].compareHealth = v
			end
		end
	
		if healthRatio <= 1 and healthRatio >= 0.75 then
			tes3mp.SendMessage(pid, config.ColorCasualText .. nameofpid .. "'s Health: " .. color.Green .. currentHealth .. config.ColorCasualText .. "/" .. color.Green .. baseHealth .. color.Default .. "\n", false)
		elseif healthRatio < 0.75 and healthRatio >= 0.5 then
			tes3mp.SendMessage(pid, config.ColorCasualText .. nameofpid .. "'s Health: " .. color.Yellow .. currentHealth .. config.ColorCasualText .. "/" .. color.Green .. baseHealth .. color.Default .. "\n", false)
		elseif healthRatio < 0.5 then
			tes3mp.SendMessage(pid, color.Red .. "Immediatelly Heal: " .. nameofpid .. " (" .. color.Red .. currentHealth .. config.ColorCasualText .. "/" .. color.Red .. baseHealth .. ")" .. color.Default .. "\n", false)
		end
		
	if samehealthTimes == 0 and not config.showSameHealthTimes == 0 then
		samehealthTimes = config.showSameHealthTimes
	end
	else
		if samehealthTimes > 0 or config.showSameHealthTimes == 0 then
			if healthRatio <= 1 and healthRatio >= 0.75 then
				tes3mp.SendMessage(pid, config.ColorCasualText .. nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth .. color.Default .. "\n", false)
			elseif healthRatio < 0.75 and healthRatio >= 0.5 then
				tes3mp.SendMessage(pid, config.ColorCasualText .. nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth .. color.Default .. "\n", false)
			elseif healthRatio < 0.5 then
				tes3mp.SendMessage(pid, color.Red .. "Immediatelly Heal: " .. nameofpid .. " (" .. color.Red .. currentHealth .. config.ColorCasualText .. "/" .. color.Red .. baseHealth .. ")" .. color.Default .. "\n", false) 
			end
		elseif not config.showSameHealthTimes == 0 then
			samehealthTimes = samehealthTimes - 1
		end
	end
end



Partyhealth.ComAddFriend = function(pid, cmd)
	
	local playerName = tes3mp.GetName(pid)
	local targetName
	local targetPID
	local msgFriendslist = config.ColorFriendlist
	
	if cmd[1] == "ph.add" then
	
		if cmd[2] ~= nil then
			if not ValidateNameOrPid(cmd[2]) then
				local messageError = config.ColorCasualText .. "No such player ONLINE!\n"
				return tes3mp.SendMessage(pid, messageError, false)
				
			elseif ValidateNameOrPid(cmd[2]) == pid then
				local messageIdiot = config.ColorCasualText .. "You can't add yourself to your own " .. msgFriendslist .. "." 
				return tes3mp.MessageBox(pid, config.IdiotFriendGuiID, messageIdiot)
			
			else
				targetPID = ValidateNameOrPid(cmd[2])
				targetName = tes3mp.GetName(targetPID)
			end
		else
			local messageWrongInput = config.ColorCasualText .. "Use the command like this: " .. "\n" .. config.ColorPlayerName .. "/ph.addfriend <pid> " .. config.ColorCasualText .. "or " .. config.ColorPlayerName .. "/ph.addfriend <name>" .. config.ColorCasualText .. "\n"
			return tes3mp.SendMessage(pid, messageWrongInput, false)
		end
			
		
		local messageAlreadyFriend = config.ColorPlayerName .. targetName .. config.ColorCasualText .. " is already in your " .. msgFriendslist .. ".\n"
		local messageBlackListed = config.ColorPlayerName .. targetName .. config.ColorCasualText .. " doesn't accept requests from you."	
		local messageBusy = config.ColorPlayerName .. targetName .. config.ColorCasualText .. " is currently busy with another request, try it later."
		local messageRequest = config.ColorPlayerName .. playerName .. config.ColorCasualText .. " wants to add you into their " .. msgFriendslist .. config.ColorCasualText .. " to track your HP. If you " .. color.GoldenRod .. "Accept " .. config.ColorCasualText .. "you will be able to track their HP as well."
		local messageSendFriend = config.ColorCasualText .. "You have sent " .. config.ColorPlayerName .. targetName .. config.ColorCasualText .. " a friend request ..."
		
		if Partyhealth.isInRejected(pid, targetPID) then
			return tes3mp.MessageBox(pid, config.isInRejectedGuiID, messageBlackListed)
		end
		
		if Partyhealth.isInAccepted(pid, targetPID) then
			return tes3mp.MessageBox(pid, config.isInAcceptedGuiID, messageAlreadyFriend)
		end
		
		
		PauseHP(targetPID)		
		
		if Partyhealth.sender[tostring(targetPID)] == nil then 
			Partyhealth.sender[tostring(targetPID)] = pid
			tes3mp.CustomMessageBox(targetPID, config.AddFriendGuiID, messageRequest, 'Accept;Reject')
			tes3mp.MessageBox(pid, config.SendFriendGuiID, messageSendFriend)
		else
			tes3mp.MessageBox(pid, config.BusyFriendGuiID, messageBusy)
		end
	end
end










Partyhealth.isInAccepted = function(pid, targetPID)
	
	if Players[targetPID] ~= nil and Players[targetPID]:IsLoggedIn() then
		
		local playerName = tes3mp.GetName(pid)
		local targetName = tes3mp.GetName(targetPID)
		
		if friendsData ~= nil and friendsData[targetName] ~= nil then
				
			if friendsData[targetName].Accepted ~= nil then
		
				for _, aName in pairs(friendsData[targetName].Accepted) do
					if playerName == aName then
						return true
					end
				end
			end
		end
	else
		return false
	end
end

Partyhealth.isInRejected = function(pid, targetPID)
	
	if Players[targetPID] ~= nil and Players[targetPID]:IsLoggedIn() then
		
		local playerName = tes3mp.GetName(pid)
		local targetName = tes3mp.GetName(targetPID)
		
		if friendsData ~= nil and friendsData[targetName] ~= nil then	
			
			if friendsData[targetName].Rejected ~= nil then
		
				for _, rName in pairs(friendsData[targetName].Rejected) do
				
					if playerName == rName then
						return true
					end
				end
			end
		end
	else
		return false
	end
end










Partyhealth.AcceptGui = function(pid)


	local playerName = tes3mp.GetName(pid)
	local targetName = tes3mp.GetName(Partyhealth.sender[tostring(pid)])
	local targetPID = Partyhealth.sender[tostring(pid)]
	local messageAccepttargetPID = config.ColorPlayerName .. playerName .. config.ColorCasualText .. " has accepted your request, you may now " .. color.GoldenRod .. "Activate " .. "the player to see their HP."
	local messageAcceptPID = config.ColorCasualText .. "You may now " .. color.GoldenRod .. "Activate " .. config.ColorPlayerName .. targetName .. config.ColorCasualText .. " to see their HP. Remember that they can now see yours as well!"

	Partyhealth.sender[tostring(pid)] = nil
	
	
	if friendsData == nil then friendsData = {} end
	if friendsData[playerName] == nil then friendsData[playerName] = {} end
	if friendsData[playerName].Accepted == nil then friendsData[playerName].Accepted = {} end
	if friendsData[targetName] == nil then friendsData[targetName] = {} end
	if friendsData[targetName].Accepted == nil then friendsData[targetName].Accepted = {} end
	
	if Partyhealth.isInRejected(pid, targetPID) then
		tableHelper.removeValue(friendsData[targetName].Rejected, playerName)
	end
	
	table.insert(friendsData[playerName].Accepted, targetName)
	table.insert(friendsData[targetName].Accepted, playerName)
	SaveJSON()
	
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		tes3mp.MessageBox(pid, config.AcceptFriendGuiID, messageAcceptPID)
	end
	
	if Players[targetPID] ~= nil and Players[targetPID]:IsLoggedIn() then
		tes3mp.MessageBox(targetPID, config.AcceptFriendGuiID, messageAccepttargetPID)
	end
	
	UnpauseHP(pid)
end

Partyhealth.RejectGui = function(pid)

	local playerName = tes3mp.GetName(pid)
	local targetName = tes3mp.GetName(Partyhealth.sender[tostring(pid)])
	local targetPID = Partyhealth.sender[tostring(pid)]
	local messageReject = config.ColorPlayerName .. playerName .. config.ColorCasualText .. " has rejected, you can't send " .. config.ColorPlayerName .. playerName .. config.ColorCasualText .. " another request. " .. config.ColorPlayerName .. playerName .. config.ColorCasualText .. " would have to add you first now."
	
	Partyhealth.sender[tostring(pid)] = nil
	
	if friendsData == nil then friendsData = {} end
	if friendsData[playerName] == nil then friendsData[playerName] = {} end
	if friendsData[playerName].Rejected == nil then friendsData[playerName].Rejected = {} end
	table.insert(friendsData[playerName].Rejected, targetName)
	SaveJSON()
	
	if Players[targetPID] ~= nil and Players[targetPID]:IsLoggedIn() then
		tes3mp.MessageBox(targetPID, config.RejectFriendGuiID, messageReject)
	end
	
	UnpauseHP(pid)
end
	
	
Partyhealth.OnGUIAction = function(EventStatus, pid, idGui, data)

	if idGui == config.AddFriendGuiID then
		if tonumber(data) == 0 then -- Accept Button
			Partyhealth.AcceptGui(pid)
		elseif tonumber(data) == 1 then -- Reject Button
			Partyhealth.RejectGui(pid)
		end
		UnpauseHP(pid)
		
	elseif idGui == config.showFriendslistGuiID then
		
		if tonumber(data) == 18446744073709551615 then
			UnpauseHP(pid)
		end
		Partyhealth.RemoveFriend(pid, data)
		
	elseif idGui == config.showBlacklistGuiID then
		
		if tonumber(data) == 18446744073709551615 then
			UnpauseHP(pid)
		end
		Partyhealth.RemoveBlacklisted(pid, data)
	
	end
end


Partyhealth.RemoveFriend = function(pid, data)

local input = tonumber(data) + 1
local lbTitle = config.ColorFriendlist .. "\n"
lbTitle = lbTitle .. color.PaleGoldenRod .. "Click on the name to permanently remove it"
local playerName = tes3mp.GetName(pid)
local targetName
local targetPID
local messagePID = config.ColorCasualText .. " has been removed from your " .. config.ColorFriendlist .. config.ColorCasualText .. ". You won't be able to display each other's HP now!\n"

if friendsData[playerName].Accepted ~= nil then
	if friendsData[playerName].Accepted[input] ~= nil then
		targetName = friendsData[playerName].Accepted[input]
		targetPID = ValidateNameOrPid(targetName)
		
		if targetName ~= nil and friendsData[targetName]~= nil then
			for index, tname in pairs(friendsData[targetName].Accepted) do
				if tname == playerName then
					table.remove(friendsData[targetName].Accepted, index)
					if Players[targetPID] ~= nil and Players[targetPID]:IsLoggedIn() then
						local messageTargetPID = config.ColorPlayerName .. playerName .. messagePID
						tes3mp.SendMessage(targetPID, messageTargetPID, false)
					end
				end
			end
		end
		messagePID = config.ColorPlayerName .. targetName .. messagePID
		
		table.remove(friendsData[playerName].Accepted, input)
		
		Players[pid].Partyhealth[tostring(targetPID)] = nil
		tableHelper.removeValue(affectedlist[pid], tostring(targetPID))
		
		
		tes3mp.SendMessage(pid, messagePID, false)
		SaveJSON()
		if #friendsData[playerName].Accepted > 0 then
			return tes3mp.ListBox(pid, config.showFriendslistGuiID, lbTitle, FriendslistToListBox(pid))
		else
			local message = config.ColorCasualText .. "Your " .. config.ColorFriendlist .. config.ColorCasualText .. " is empty!\n"
			return tes3mp.SendMessage(pid, message, false)
		end
	end
end
end	

Partyhealth.RemoveBlacklisted = function(pid, data)

local input = tonumber(data) + 1
local lbTitle = config.ColorBlacklist .. "\n"
lbTitle = lbTitle .. color.PaleGoldenRod .. "Click on the name to permanently remove it"
local playerName = tes3mp.GetName(pid)
local targetName
local targetPID
local messagePID = config.ColorCasualText .. " has been removed from your " .. config.ColorBlacklist .. ".\n"

if friendsData[playerName].Rejected ~= nil and friendsData[playerName].Rejected[input] ~= nil then
	targetName = friendsData[playerName].Rejected[input]
	targetPID = ValidateNameOrPid(targetName)
	
	if Players[targetPID] ~= nil and Players[targetPID]:IsLoggedIn() then
		local messageTargetPID = config.ColorPlayerName .. playerName .. config.ColorCasualText .. " has removed you from their " .. config.ColorBlacklist .. config.ColorCasualText .. ". You can now add them as a friend.\n"
		tes3mp.SendMessage(targetPID, messageTargetPID, false)
	end
	
	table.remove(friendsData[playerName].Rejected, input)
	
	Players[pid].Partyhealth[tostring(targetPID)] = nil
	tableHelper.removeValue(affectedlist[pid], tostring(targetPID))
	
	messagePID = config.ColorPlayerName .. targetName .. messagePID
	tes3mp.SendMessage(pid, messagePID, false)
	SaveJSON()
	if #friendsData[playerName].Rejected > 0 then
			return tes3mp.ListBox(pid, config.showFriendslistGuiID, lbTitle, FriendslistToListBox(pid))
	else
		local message = config.ColorCasualText .. "Your " .. config.ColorFriendlist .. config.ColorCasualText .. " is empty!\n"
		return tes3mp.SendMessage(pid, message, false)
	end
end
end







ValidateNameOrPid = function(NoP)

    local targetPID = tonumber(NoP)
    if targetPID == nil then
        for id, player in pairs(Players) do
            if NoP == tes3mp.GetName(id) then
                targetPID = id
                break
            end
        end
    end
	if targetPID ~= nil and Players[targetPID] ~= nil and Players[targetPID]:IsLoggedIn() then
		print("returning targetPID: " .. targetPID)
		return targetPID
	end
	return false
end

Partyhealth.ShowFriendslist = function(pid, cmd)

if cmd[1] == "ph.friendlist" then

	local playerName = tes3mp.GetName(pid)
	local lbTitle = config.ColorFriendlist .. "\n"
	lbTitle = lbTitle .. color.PaleGoldenRod .. "Click on the name to permanently remove it"

	PauseHP(pid)

	if friendsData and friendsData[playerName] and friendsData[playerName].Accepted and #friendsData[playerName].Accepted > 0 then
		tes3mp.ListBox(pid, config.showFriendslistGuiID, lbTitle, FriendslistToListBox(pid))

	else
		local message = config.ColorCasualText .. "Your " .. config.ColorFriendlist .. config.ColorCasualText .. " is empty!\n"
		tes3mp.SendMessage(pid, message, false)
	end
end

end

Partyhealth.ShowBlacklist = function(pid, cmd)

if cmd[1] == "ph.blacklist" then

	local playerName = tes3mp.GetName(pid)
	local lbTitle = config.ColorBlacklist .. "\n"
	lbTitle = lbTitle .. color.PaleGoldenRod .. "Click on the name to permanently remove it"
	
	PauseHP(pid)

	
	if friendsData and friendsData[playerName] and friendsData[playerName].Rejected and #friendsData[playerName].Rejected > 0 then
		tes3mp.ListBox(pid, config.showBlacklistGuiID, lbTitle, BlacklistToListBox(pid))

	else
		local message = config.ColorCasualText .. "Your " .. config.ColorBlacklist .. config.ColorCasualText .. " is empty!\n"
		tes3mp.SendMessage(pid, message, false)
		UnpauseHP(pid)
	end

end

end


FriendslistToListBox = function(pid)

local playerName = tes3mp.GetName(pid)
local list = ""
local divider = ""

if friendsData[playerName] == nil then
return false
end

if friendsData[playerName].Accepted == nil then
return false
end

for key, tName in pairs(friendsData[playerName].Accepted) do

	if key == #friendsData[playerName].Accepted then
		divider = ""
	else
		divider = "\n"
	end

	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		if key%2 == 1 then
			list = list .. color.Gold .. tName
			list = list .. divider
		else
			list = list .. color.PaleGoldenRod .. tName
			list = list .. divider
		end
	end
end

return list
end

BlacklistToListBox = function(pid)

local playerName = tes3mp.GetName(pid)
local list = ""
local divider = ""

if friendsData[playerName] == nil then
return false
end

if friendsData[playerName].Rejected == nil then 
return false
end

for key, tName in pairs(friendsData[playerName].Rejected) do

	if key == #friendsData[playerName].Rejected then
		divider = ""
	else
		divider = "\n"
	end

	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		if key%2 == 1 then
			list = list .. color.Gold .. tName
			list = list .. divider
		else
			list = list .. color.PaleGoldenRod .. tName
			list = list .. divider
		end
	end
end

return list
end

PauseHP = function(pid)

affectedlist[pid] = {}

if Players[pid].Partyhealth then
	for key, _ in pairs(Players[pid].Partyhealth) do
		if Players[pid].Partyhealth[key] ~= nil then
			Players[pid].Partyhealth[key].condition = false
			table.insert(affectedlist[pid], key)
			tes3mp.LogMessage(1, Players[pid].Partyhealth[key].conditon)
		end
	end
end
tes3mp.LogMessage(1, tableHelper.getSimplePrintableTable(affectedlist[pid]))
end

UnpauseHP = function(pid)		

if affectedlist ~= nil then
	for key, value in pairs(affectedlist[pid]) do
		Players[pid].Partyhealth[value].compareHealth = 0
		Players[pid].Partyhealth[value].condition = true
		tes3mp.LogMessage(1, tableHelper.getSimplePrintableTable(affectedlist[pid]))
	end
end

end





			
		






customEventHooks.registerHandler("OnServerPostInit", Partyhealth.OnServerPostInit)
customEventHooks.registerValidator("OnPlayerConnect", Partyhealth.OnConnect)
customEventHooks.registerHandler("OnObjectActivate", Partyhealth.OnActivate)
customEventHooks.registerHandler("OnGUIAction", Partyhealth.OnGUIAction)
customEventHooks.registerHandler("OnPlayerDisconnect", Partyhealth.OnDisconnect)

customCommandHooks.registerCommand("ph.help", Partyhealth.ComHelp)
customCommandHooks.registerCommand("ph.decent", Partyhealth.ComChangeChatMsgColor)
customCommandHooks.registerCommand("ph.default", Partyhealth.ComChangeChatMsgColor)
customCommandHooks.registerCommand("ph.friendlist", Partyhealth.ShowFriendslist)
customCommandHooks.registerCommand("ph.blacklist", Partyhealth.ShowBlacklist)
customCommandHooks.registerCommand("ph.hp", Partyhealth.ComHP)
customCommandHooks.registerCommand("ph.chat", Partyhealth.ComChat)
customCommandHooks.registerCommand("ph.gui", Partyhealth.ComGui)
customCommandHooks.registerCommand("ph.add", Partyhealth.ComAddFriend)





