local Partyhealth = {}

Partyhealth.baseHealth = {}
Partyhealth.healthRatio = {}
local config = {}
config.showsamehealth = 0

function Partyhealth.OnActivate(pid, targetpd)
	if Players[pid].Partyhealth == nil then Players[pid].Partyhealth = {} end
	Players[pid].Partyhealth[tostring(targetpd)] = {compareHealth = 0, condition = true, currentHealth = 0, samehealthTimes = config.showsamehealth}
end		

function Partyhealth.OnConnect(pid)

	local playerName = tes3mp.GetName(pid)
	if logicHandler.IsPlayerNameLoggedIn(playerName) then
		print("PartyhealthCheck to ensure connect attempt from player with already existing name won't crash the server.\n")
		
	else
		if Players[pid].Partyhealth ~= nil then Players[pid].Partyhealth = {} end
		if type(Partyhealth.baseHealth[pid]) ~= table then Partyhealth.baseHealth[pid] = {} end
		print (Partyhealth.baseHealth[pid])
		if type(Partyhealth.healthRatio[pid]) ~= table then Partyhealth.healthRatio[pid] = {} end
	
	end
end


function Partyhealth.OnDisconnect(pid)

	if Players[pid].Partyhealth ~= nil then Players[pid].Partyhealth = nil end
	
end
			

function Partyhealth.ComHP(pid, myCommand)
	if myCommand ~= nil then
		myCommand = tostring(myCommand)
		for pidTracked, _ in pairs(Players[pid].Partyhealth) do
			if (myCommand == pidTracked or myCommand == tes3mp.GetName(pidTracked) or myCommand == string.lower(tes3mp.GetName(pidTracked)) and Players[pid].Partyhealth[pidTracked].condition) then
				Players[pid].Partyhealth[pidTracked].condition = false
				Players[pid].Partyhealth[pidTracked].compareHealth = 0
			elseif (myCommand == pidTracked or myCommand == tes3mp.GetName(pidTracked) or myCommand == string.lower(tes3mp.GetName(pidTracked)) and Players[pid].Partyhealth[pidTracked].condition) == false then
				Players[pid].Partyhealth[pidTracked].condition = true
			else
				 tes3mp.SendMessage(pid, "ID or name not in the system!\n", false)
			end
		end
	end
end

function Partyhealth.ComChat(pid, myCommand)
	for pidTracked, _ in pairs(Players[pid].Partyhealth) do
				if (myCommand == pidTracked or myCommand == tes3mp.GetName(pidTracked) or myCommand == string.lower(tes3mp.GetName(pidTracked))) then
					if Players[pid].Partyhealth[pidTracked].displayType == nil then Players[pid].Partyhealth[pidTracked].displayType = '' end
					if Players[pid].Partyhealth[pidTracked].condition == false then Players[pid].Partyhealth[pidTracked].condition = true end
					Players[pid].Partyhealth[pidTracked].compareHealth = 0
					Players[pid].Partyhealth[pidTracked].displayType = "chat"
				end
	end
end

function Partyhealth.ComGui(pid, myCommand)
	for pidTracked, _ in pairs(Players[pid].Partyhealth) do
				if (myCommand == pidTracked or myCommand == tes3mp.GetName(pidTracked) or myCommand == string.lower(tes3mp.GetName(pidTracked))) then
					if Players[pid].Partyhealth[pidTracked].displayType == nil then Players[pid].Partyhealth[pidTracked].displayType = '' end
					if Players[pid].Partyhealth[pidTracked].condition == false then Players[pid].Partyhealth[pidTracked].condition = true end
					Players[pid].Partyhealth[pidTracked].compareHealth = 0
					Players[pid].Partyhealth[pidTracked].displayType = "gui"
				end
	end
end
	
function Partyhealth.Gui(pid, targetpd)


	
	targetpd = tostring(targetpd)
	
	Partyhealth.baseHealth[pid][targetpd] = math.floor(tes3mp.GetHealthBase(targetpd))
	
	Players[pid].Partyhealth[targetpd].currentHealth = math.floor(tes3mp.GetHealthCurrent(targetpd))
	
	Partyhealth.healthRatio[pid][targetpd] = Players[pid].Partyhealth[targetpd].currentHealth/Partyhealth.baseHealth[pid][targetpd]
	
	local healthRatio = Partyhealth.healthRatio[pid][targetpd]
	local currentHealth = Players[pid].Partyhealth[targetpd].currentHealth
	local baseHealth = Partyhealth.baseHealth[pid][targetpd]
	local nameofpid = tes3mp.GetName(targetpd)
	local samehealthTimes = Players[pid].Partyhealth[targetpd].samehealthTimes
	
	if Players[pid].Partyhealth[targetpd].compareHealth ~= currentHealth then
		for k, v in pairs(Players[pid].Partyhealth[targetpd]) do
			if k == "currentHealth" then
				Players[pid].Partyhealth[targetpd].compareHealth = v
			end
		end
		
		if healthRatio <= 1 and healthRatio >= 0.75 then
			tes3mp.MessageBox(pid, 8790, nameofpid .. "'s Health: " .. color.Green .. currentHealth .. color.GoldenRod .. "/" .. color.Green .. baseHealth, false)
		elseif healthRatio < 0.75 and healthRatio >= 0.5 then
			tes3mp.MessageBox(pid, 8791, nameofpid .. "'s Health: " .. color.Yellow .. currentHealth .. color.GoldenRod .. "/" .. color.Green .. baseHealth, false)
		elseif healthRatio < 0.5 then
			tes3mp.MessageBox(pid, 8792, color.Red .. "Immediatelly Heal: " .. nameofpid .. " (" .. color.Red .. currentHealth .. color.GoldenRod .. "/" .. color.Red .. baseHealth .. ")", false)
		end
	if samehealthTimes == 0 and not config.showsamehealth == 0 then
		samehealthTimes = config.showsamehealth
	end
	else
		if samehealthTimes > 0 or config.showsamehealth == 0 then
			if healthRatio <= 1 and healthRatio >= 0.75 then
				tes3mp.MessageBox(pid, 8793, nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth, false)
			elseif healthRatio < 0.75 and healthRatio >= 0.5 then
				tes3mp.MessageBox(pid, 8794, nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth, false)
			elseif healthRatio < 0.5 then
				tes3mp.MessageBox(pid, 8795, color.Red .. "Immediatelly Heal: " .. nameofpid .. " (" .. color.Red .. currentHealth .. color.GoldenRod .. "/" .. color.Red .. baseHealth .. ")", false) 
			end
		elseif not config.showsamehealth == 0 then
			samehealthTimes = samehealthTimes - 1
		end
	end
end

function Partyhealth.Chat(pid, targetpd)

	

	targetpd = tostring(targetpd)
	
	Partyhealth.baseHealth[pid][targetpd] = math.floor(tes3mp.GetHealthBase(targetpd))
	
	Players[pid].Partyhealth[targetpd].currentHealth = math.floor(tes3mp.GetHealthCurrent(targetpd))
	
	Partyhealth.healthRatio[pid][targetpd] = Players[pid].Partyhealth[targetpd].currentHealth/Partyhealth.baseHealth[pid][targetpd]
	
	local healthRatio = Partyhealth.healthRatio[pid][targetpd]
	local currentHealth = Players[pid].Partyhealth[targetpd].currentHealth
	local baseHealth = Partyhealth.baseHealth[pid][targetpd]
	local nameofpid = tes3mp.GetName(targetpd)
	local samehealthTimes = Players[pid].Partyhealth[targetpd].samehealthTimes
	
	if Players[pid].Partyhealth[targetpd].compareHealth ~= currentHealth then
		for k, v in pairs(Players[pid].Partyhealth[targetpd]) do
			if k == "currentHealth" then
				Players[pid].Partyhealth[targetpd].compareHealth = v
			end
		end
	
		if healthRatio <= 1 and healthRatio >= 0.75 then
			tes3mp.SendMessage(pid, color.Default .. nameofpid .. "'s Health: " .. color.Green .. currentHealth .. color.Default .. "/" .. color.Green .. baseHealth .. color.Default .. "\n", false)
		elseif healthRatio < 0.75 and healthRatio >= 0.5 then
			tes3mp.SendMessage(pid, color.Default .. nameofpid .. "'s Health: " .. color.Yellow .. currentHealth .. color.Default .. "/" .. color.Green .. baseHealth .. color.Default .. "\n", false)
		elseif healthRatio < 0.5 then
			tes3mp.SendMessage(pid, color.Red .. "Immediatelly Heal: " .. nameofpid .. " (" .. color.Red .. currentHealth .. color.Default .. "/" .. color.Red .. baseHealth .. ")" .. color.Default .. "\n", false)
		end
	if samehealthTimes == 0 and not config.showsamehealth == 0 then
		samehealthTimes = config.showsamehealth
	end
	else
		if samehealthTimes > 0 or config.showsamehealth == 0 then
			if healthRatio <= 1 and healthRatio >= 0.75 then
				tes3mp.SendMessage(pid, color.Default .. nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth .. color.Default .. "\n", false)
			elseif healthRatio < 0.75 and healthRatio >= 0.5 then
				tes3mp.SendMessage(pid, color.Default .. nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth .. color.Default .. "\n", false)
			elseif healthRatio < 0.5 then
				tes3mp.SendMessage(pid, color.Red .. "Immediatelly Heal: " .. nameofpid .. " (" .. color.Red .. currentHealth .. color.Default .. "/" .. color.Red .. baseHealth .. ")" .. color.Default .. "\n", false) 
			end
		elseif not config.showsamehealth == 0 then
			samehealthTimes = samehealthTimes - 1
		end
	end
end



return Partyhealth
