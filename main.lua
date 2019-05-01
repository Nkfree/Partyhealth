jsonInterface = require("jsonInterface")
tableHelper = require("tableHelper")
menuHelper = require("menuHelper")

-- define tables we'll be working with
local affectedlist = {}
local config = {}
local friendsData = {}
local Partyhealth = {}
Partyhealth.baseHealth = {}
Partyhealth.healthRatio = {}
Partyhealth.Cmd = {}
Partyhealth.Menu = {}
Partyhealth.Menu.Cmds = {}
Partyhealth.Menu.Labels = {}
Partyhealth.sender = {}

-- CHANGE THESE ACCORDING TO INSTRUCTIONS
-- define config entries
config.displayFastHP = false -- when true you can activate player beforehand and when you add them to your friendlist their hp will get displayed immediatelly
config.showSameHealthTimes = 3 -- if you don't want same health to be displayed over and over you can set how many times the same value will get displayed; set to 0 to disable

-- commands used in-game; change the command inside ""
Partyhealth.Cmd[1] = "ph.add" -- sends friend request
Partyhealth.Cmd[2] = "ph.friendlist" -- displays people you have added as friends
Partyhealth.Cmd[3] = "ph.blacklist" -- displays people whose friend request you have rejected
Partyhealth.Cmd[4] = "ph.hp" -- toggles display of health for certain player
Partyhealth.Cmd[5] = "ph.chat" -- health messages for certain player will be displayed in chat
Partyhealth.Cmd[6] = "ph.gui" -- health messages for certain player will be displayed in gui
Partyhealth.Cmd[7] = "ph.decent" -- changes colors of Partyhealth messages to more dull
Partyhealth.Cmd[8] = "ph.default" -- changes colors of Partyhealth messages to more vivid
Partyhealth.Cmd[9] = "ph.help" -- displays help menu for Partyhealth

-- DO NOT change these unless you know what you are doing
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

-- define timer Partyhealth variables
Partyhealth.UpdateInterval = 2
Partyhealth.Timer = tes3mp.CreateTimer("Update_time", Partyhealth.UpdateInterval * 1000)

-- define menu for Partyhealth
Partyhealth.Menu.Cmds[1] = config.ColorPlayerName .. Partyhealth.Cmd[1] .. " <pid>/<name>"
Partyhealth.Menu.Cmds[2] = config.ColorPlayerName .. Partyhealth.Cmd[2]
Partyhealth.Menu.Cmds[3] = config.ColorPlayerName .. Partyhealth.Cmd[3]
Partyhealth.Menu.Cmds[4] = config.ColorPlayerName .. Partyhealth.Cmd[4] .. " <pid>/<name>"
Partyhealth.Menu.Cmds[5] = config.ColorPlayerName .. Partyhealth.Cmd[5] .. " <pid>/<name>"
Partyhealth.Menu.Cmds[6] = config.ColorPlayerName .. Partyhealth.Cmd[6] .. " <pid>/<name>"
Partyhealth.Menu.Cmds[7] = config.ColorPlayerName .. Partyhealth.Cmd[7]
Partyhealth.Menu.Cmds[8] = config.ColorPlayerName .. Partyhealth.Cmd[8]


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

-- save or create db for friendlist or blacklist
local SaveJSON = function()
	jsonInterface.save("PH_friendslist.json", friendsData)
end


-- function that the Partyhealth.Timer activates and that continually displays health messages
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



Partyhealth.Menu.Create = function(pid, menuTitle, menuHeader, command, label)
	if tostring(menuTitle) and tostring(menuHeader) and command and label then
		local text
		local getText
		getText = color.Orange .. menuHeader .. "\n"
		for k, v in pairs(command) do
			if tostring(command[k]) and tostring(label[k]) then
				getText = getText .. color.Yellow .. "/" .. command[k] .. "\n" .. color.White .. label[k] .. "\n"
			end
		end

		Menus[menuTitle] = {
			text = getText,
			buttons = {
				{caption = "Exit", destinations = nil}
			}
		}
	end
	return menuHelper.DisplayMenu(pid, menuTitle)
end



-- functions that hook onto serverCore



Partyhealth.OnActivate = function(EventStatus, pid, cellDescription, objects, players)
	for index = 0, tes3mp.GetObjectListSize() - 1 do
		local object = {}

		local isObjectPlayer = tes3mp.IsObjectPlayer(index)

		if isObjectPlayer then
			object.pid = tes3mp.GetObjectPid(index)
			local objectPid = object.pid

			if config.displayFastHP == false then

				if Partyhealth.isInAccepted(pid, objectPid) then
					if Players[pid].Partyhealth == nil then Players[pid].Partyhealth = {} end
					Players[pid].Partyhealth[tostring(objectPid)] = {compareHealth = 0, condition = true, displayType = "gui", sameHealthTimes = config.showSameHealthTimes}
				end

			else
				if Players[pid].Partyhealth == nil then Players[pid].Partyhealth = {} end
				Players[pid].Partyhealth[tostring(objectPid)] = {compareHealth = 0, condition = true, displayType = "gui", sameHealthTimes = config.showSameHealthTimes}
			end
		end

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



Partyhealth.OnPlayerFinishLogin = function(EventStatus, pid)
	if Players[pid].Partyhealth == nil then Players[pid].Partyhealth = {} end
	Partyhealth.baseHealth[pid] = {}
	Partyhealth.healthRatio[pid] = {}
end



Partyhealth.OnDisconnect = function(EventStatus, pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		if Players[pid].Partyhealth ~= nil then
			Players[pid].Partyhealth = nil
		end
	end

end


-- all usable Partyhealth commands
Partyhealth.ComAddFriend = function(pid, cmd)-- command that servers to add another player to one's friendlist
	local playerName = tes3mp.GetName(pid)
	local targetName
	local targetPID
	local msgFriendslist = config.ColorFriendlist

	if cmd[1] == Partyhealth.Cmd[1] then

		if cmd[2] ~= nil then
			if not ValidateNameOrPid(cmd[2]) then
				local messageError = config.ColorCasualText .. "No such player online!\n"
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



Partyhealth.ComHelp = function(pid, cmd)-- displays HELP
	if cmd[1] == Partyhealth.Cmd[9] then
		Partyhealth.Menu.Create(pid, Partyhealth.Menu.Title, Partyhealth.Menu.Header, Partyhealth.Menu.Cmds, Partyhealth.Menu.Labels)
	end
end



Partyhealth.ComHP = function(pid, cmd)-- pauses or unpauses HP messages for certain player
	if cmd[1] == Partyhealth.Cmd[4] then
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



Partyhealth.ComChangeChatMsgColor = function(pid, cmd)-- gives option to switch to less distracting colors
	if Players[pid].Partyhealth.ColorMode == nil then Players[pid].Partyhealth.ColorMode = "default" end

	if cmd[1] == Partyhealth.Cmd[7] and Players[pid].Partyhealth.ColorMode == "default" then
		config.ColorFriendlist = color.Silver .. "Friendlist"
		config.ColorBlacklist = color.Chocolate .. "Blacklist"
		config.ColorPlayerName = color.SkyBlue
		config.ColorCasualText = color.GoldenRod
		Players[pid].Partyhealth.ColorMode = "decent"
	end

	if cmd[1] == Partyhealth.Cmd[8] and Players[pid].Partyhealth.ColorMode == "decent" then
		config.ColorFriendlist = color.Green .. "Friendlist"
		config.ColorBlacklist = color.Crimson .. "Blacklist"
		config.ColorPlayerName = color.Yellow
		config.ColorCasualText = color.SkyBlue
		Players[pid].Partyhealth.ColorMode = "default"
	end
end



Partyhealth.ComChat = function(pid, cmd)-- allows to display HP for certain player in the chat instead of GUI
	if cmd[1] == Partyhealth.Cmd[5] then
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



Partyhealth.ComGui = function(pid, cmd)-- allows to revert display mod of hp messages back to GUI
	if cmd[1] == Partyhealth.Cmd[6] then
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



Partyhealth.ShowFriendslist = function(pid, cmd)-- displays friendlist and allows for removing players from there
	if cmd[1] == Partyhealth.Cmd[2] then

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



Partyhealth.ShowBlacklist = function(pid, cmd)-- displays blacklist and allows for removing players from there
	if cmd[1] == Partyhealth.Cmd[3] then

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


-- functions that handle HP displaying
Partyhealth.Gui = function(pid, targetPID)-- defines how HP is going to be displayed on GUI
	Partyhealth.baseHealth[pid][targetPID] = math.floor(tes3mp.GetHealthBase(tonumber(targetPID)))

	Players[pid].Partyhealth[targetPID].currentHealth = math.floor(tes3mp.GetHealthCurrent(tonumber(targetPID)))

	Partyhealth.healthRatio[pid][targetPID] = Players[pid].Partyhealth[targetPID].currentHealth / Partyhealth.baseHealth[pid][targetPID]

	local healthRatio = Partyhealth.healthRatio[pid][targetPID]
	local currentHealth = Players[pid].Partyhealth[targetPID].currentHealth
	local baseHealth = Partyhealth.baseHealth[pid][targetPID]
	local nameofpid = tes3mp.GetName(targetPID)

	print("Players[pid].Partyhealth[targetPID].sameHealthTimes IF: " .. Players[pid].Partyhealth[targetPID].sameHealthTimes)
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
		if Players[pid].Partyhealth[targetPID].sameHealthTimes == 0 and config.showSameHealthTimes ~= 0 then
			Players[pid].Partyhealth[targetPID].sameHealthTimes = config.showSameHealthTimes
		end
		print("Players[pid].Partyhealth[targetPID].sameHealthTimes IF: " .. Players[pid].Partyhealth[targetPID].sameHealthTimes)
	else
		if Players[pid].Partyhealth[targetPID].sameHealthTimes > 0 then
			if healthRatio <= 1 and healthRatio >= 0.75 then
				tes3mp.MessageBox(pid, 8793, nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth, false)
			elseif healthRatio < 0.75 and healthRatio >= 0.5 then
				tes3mp.MessageBox(pid, 8794, nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth, false)
			elseif healthRatio < 0.5 then
				tes3mp.MessageBox(pid, 8795, color.Red .. "Immediatelly Heal: " .. nameofpid .. " (" .. color.Red .. currentHealth .. color.GoldenRod .. "/" .. color.Red .. baseHealth .. ")", false)
			end
			Players[pid].Partyhealth[targetPID].sameHealthTimes = Players[pid].Partyhealth[targetPID].sameHealthTimes - 1
		end
		print("Players[pid].Partyhealth[targetPID].sameHealthTimes ELSE: " .. Players[pid].Partyhealth[targetPID].sameHealthTimes)
	end
end



Partyhealth.Chat = function(pid, targetPID)-- defines how HP is going to be displayed in chat
	targetPID = tostring(targetPID)

	Partyhealth.baseHealth[pid][targetPID] = math.floor(tes3mp.GetHealthBase(targetPID))
	Players[pid].Partyhealth[targetPID].currentHealth = math.floor(tes3mp.GetHealthCurrent(targetPID))

	Partyhealth.healthRatio[pid][targetPID] = Players[pid].Partyhealth[targetPID].currentHealth / Partyhealth.baseHealth[pid][targetPID]

	local healthRatio = Partyhealth.healthRatio[pid][targetPID]
	local currentHealth = Players[pid].Partyhealth[targetPID].currentHealth
	local baseHealth = Partyhealth.baseHealth[pid][targetPID]
	local nameofpid = tes3mp.GetName(targetPID)

	print("Players[pid].Partyhealth[targetPID].sameHealthTimes IF: " .. Players[pid].Partyhealth[targetPID].sameHealthTimes)
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
		if Players[pid].Partyhealth[targetPID].sameHealthTimes == 0 and config.showSameHealthTimes ~= 0 then
			Players[pid].Partyhealth[targetPID].sameHealthTimes = config.showSameHealthTimes
		end
		print("Players[pid].Partyhealth[targetPID].sameHealthTimes IF: " .. Players[pid].Partyhealth[targetPID].sameHealthTimes)
	else
		if Players[pid].Partyhealth[targetPID].sameHealthTimes > 0 then
			if healthRatio <= 1 and healthRatio >= 0.75 then
				tes3mp.SendMessage(pid, config.ColorCasualText .. nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth .. color.Default .. "\n", false)
			elseif healthRatio < 0.75 and healthRatio >= 0.5 then
				tes3mp.SendMessage(pid, config.ColorCasualText .. nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth .. color.Default .. "\n", false)
			elseif healthRatio < 0.5 then
				tes3mp.SendMessage(pid, color.Red .. "Immediatelly Heal: " .. nameofpid .. " (" .. color.Red .. currentHealth .. config.ColorCasualText .. "/" .. color.Red .. baseHealth .. ")" .. color.Default .. "\n", false)
			end
			Players[pid].Partyhealth[targetPID].sameHealthTimes = Players[pid].Partyhealth[targetPID].sameHealthTimes - 1
			print("Players[pid].Partyhealth[targetPID].sameHealthTimes ELSE: " .. Players[pid].Partyhealth[targetPID].sameHealthTimes)
		end
	end
end



Partyhealth.isInAccepted = function(pid, targetPID)-- checks for whether player is in one's friendlist
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



Partyhealth.isInRejected = function(pid, targetPID)-- checks for whether player is in one's blacklist
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


-- GUI functions
Partyhealth.AcceptGui = function(pid)-- defines what happens when you click 'Accept' after somebody sent you friend request
	local playerName = tes3mp.GetName(pid)
	local targetName = tes3mp.GetName(Partyhealth.sender[tostring(pid)])
	local targetPID = Partyhealth.sender[tostring(pid)]
	local messageAccepttargetPID = config.ColorPlayerName .. playerName .. config.ColorCasualText .. " has accepted your request, you may now " .. color.GoldenRod .. "Activate " .. config.ColorCasualText .. "the player to see their HP."
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



Partyhealth.RejectGui = function(pid)-- defines what happens when you click 'Reject' after somebody sent you friend request
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



Partyhealth.RemoveFriend = function(pid, data)-- defines what happens when you click an entry in friendlist
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

			if targetName ~= nil and friendsData[targetName] ~= nil then
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



Partyhealth.RemoveBlacklisted = function(pid, data)-- defines what happens when you click an entry in blacklist
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


-- misc functions
ValidateNameOrPid = function(NoP)-- checks whether pid used is logged in / converts player name to pid if that is logged in
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
		return targetPID
	end
	return false
end



FriendslistToListBox = function(pid)-- converts data from .json file to list that can be displayed on GUI as friendlist
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
			if key % 2 == 1 then
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



BlacklistToListBox = function(pid)-- converts data from .json file to list that can be displayed on GUI as blacklist
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
			if key % 2 == 1 then
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



PauseHP = function(pid)-- pauses hp messages of all active players as the messages interfered with another GUI functions such as removing player from friendlist/blacklist
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



UnpauseHP = function(pid)-- unpauses hp after another GUI element is closed
	if affectedlist ~= nil then
		for key, value in pairs(affectedlist[pid]) do
			Players[pid].Partyhealth[value].compareHealth = 0
			Players[pid].Partyhealth[value].condition = true
			tes3mp.LogMessage(1, tableHelper.getSimplePrintableTable(affectedlist[pid]))
		end
	end
end


-- custom hooks that help for easier implementation of the script
customEventHooks.registerHandler("OnServerPostInit", Partyhealth.OnServerPostInit)
customEventHooks.registerValidator("OnPlayerFinishLogin", Partyhealth.OnPlayerFinishLogin)
customEventHooks.registerHandler("OnObjectActivate", Partyhealth.OnActivate)
customEventHooks.registerHandler("OnGUIAction", Partyhealth.OnGUIAction)
customEventHooks.registerHandler("OnPlayerDisconnect", Partyhealth.OnDisconnect)



customCommandHooks.registerCommand(Partyhealth.Cmd[9], Partyhealth.ComHelp)
customCommandHooks.registerCommand(Partyhealth.Cmd[7], Partyhealth.ComChangeChatMsgColor)
customCommandHooks.registerCommand(Partyhealth.Cmd[8], Partyhealth.ComChangeChatMsgColor)
customCommandHooks.registerCommand(Partyhealth.Cmd[2], Partyhealth.ShowFriendslist)
customCommandHooks.registerCommand(Partyhealth.Cmd[3], Partyhealth.ShowBlacklist)
customCommandHooks.registerCommand(Partyhealth.Cmd[4], Partyhealth.ComHP)
customCommandHooks.registerCommand(Partyhealth.Cmd[5], Partyhealth.ComChat)
customCommandHooks.registerCommand(Partyhealth.Cmd[6], Partyhealth.ComGui)
customCommandHooks.registerCommand(Partyhealth.Cmd[1], Partyhealth.ComAddFriend)
