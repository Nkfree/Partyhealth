Partyhealth = {}

Partyhealth.baseHealth = {}
Partyhealth.condition = {}
Partyhealth.currentHealth = {}
Partyhealth.Display = {}
Partyhealth.healthRatio = {}

function Partyhealth.OnConnect(pid)
	
	if type(Partyhealth.currentHealth[pid]) ~= table then
		Partyhealth.currentHealth[pid] = {}
	end
	
	if type(Partyhealth.baseHealth[pid]) ~= table then
		Partyhealth.baseHealth[pid] = {}
	end
	
	if type(Partyhealth.healthRatio[pid]) ~= table then
		Partyhealth.healthRatio[pid] = {}
	end
	
	if type(Players[pid].data.customVariables.comparehealth) ~= table then
		Players[pid].data.customVariables.comparehealth = {}
	end
end

function Partyhealth.OnDisconnect(pid)

	for k,v in pairs(Players[pid].data.customVariables.comparehealth) do
	Players[pid].data.customVariables.comparehealth[k] = nil
	end
end
	
function Partyhealth.Gui(pid, targetpd)
	

	
	Partyhealth.baseHealth[pid][targetpd] = math.floor(tes3mp.GetHealthBase(targetpd))
	Partyhealth.currentHealth[pid][targetpd] = math.floor(tes3mp.GetHealthCurrent(targetpd))
	Partyhealth.healthRatio[pid][targetpd] = Partyhealth.currentHealth[pid][targetpd]/Partyhealth.baseHealth[pid][targetpd]
	
	local baseHealth = Partyhealth.baseHealth[pid][targetpd]
	local healthRatio = Partyhealth.healthRatio[pid][targetpd]
    local nameofpid = tes3mp.GetName(targetpd)
	local currentHealth = Partyhealth.currentHealth[pid][targetpd]
	
	

	if Players[pid].data.customVariables.comparehealth[targetpd] ~= currentHealth then
		for k, v in pairs(Partyhealth.currentHealth[pid]) do
			Players[pid].data.customVariables.comparehealth[k] = v
		end
		
		if healthRatio <= 1 and healthRatio >= 0.75 then
			tes3mp.MessageBox(pid, 8790, nameofpid .. "'s Health: " .. color.Green .. currentHealth .. color.GoldenRod .. "/" .. color.Green .. baseHealth, false)
		elseif healthRatio < 0.75 and healthRatio >= 0.5 then
			tes3mp.MessageBox(pid, 8791, nameofpid .. "'s Health: " .. color.Yellow .. currentHealth .. color.GoldenRod .. "/" .. color.Green .. baseHealth, false)
		elseif healthRatio < 0.5 then
			tes3mp.MessageBox(pid, 8792, color.Red .. "Immediatelly Heal: " .. nameofpid .. " (" .. color.Red .. currentHealth .. color.GoldenRod .. "/" .. color.Red .. baseHealth .. ")", false)
		end
	Players[pid]:Save()
	else
		tes3mp.LogMessage(2, "The healths were equal!")
		if healthRatio <= 1 and healthRatio >= 0.75 then
			tes3mp.MessageBox(pid, 8793, nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth, false)
		elseif healthRatio < 0.75 and healthRatio >= 0.5 then
			tes3mp.MessageBox(pid, 8794, nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth, false)
		elseif healthRatio < 0.5 then
			tes3mp.MessageBox(pid, 8795, color.Red .. "Immediatelly Heal: " .. nameofpid .. " (" .. color.Red .. currentHealth .. color.GoldenRod .. "/" .. color.Red .. baseHealth .. ")", false) 
		end
	end
end

function Partyhealth.Chat(pid, targetpd)

	

	Partyhealth.baseHealth[pid][targetpd] = math.floor(tes3mp.GetHealthBase(targetpd))
	Partyhealth.currentHealth[pid][targetpd] = math.floor(tes3mp.GetHealthCurrent(targetpd))
	Partyhealth.healthRatio[pid][targetpd] = Partyhealth.currentHealth[pid][targetpd]/Partyhealth.baseHealth[pid][targetpd]
	
	local baseHealth = Partyhealth.baseHealth[pid][targetpd]
	local healthRatio = Partyhealth.healthRatio[pid][targetpd]
    local nameofpid = tes3mp.GetName(targetpd)
	local currentHealth = Partyhealth.currentHealth[pid][targetpd]
	
	
	
	if Players[pid].data.customVariables.comparehealth[targetpd] ~= currentHealth then
	for k, v in pairs(Partyhealth.currentHealth[pid]) do
		Players[pid].data.customVariables.comparehealth[k] = v
	end
	
		if healthRatio <= 1 and healthRatio >= 0.75 then
			tes3mp.SendMessage(pid, color.Default .. nameofpid .. "'s Health: " .. color.Green .. currentHealth .. color.Default .. "/" .. color.Green .. baseHealth .. color.Default .. "\n", false)
		elseif healthRatio < 0.75 and healthRatio >= 0.5 then
			tes3mp.SendMessage(pid, color.Default .. nameofpid .. "'s Health: " .. color.Yellow .. currentHealth .. color.Default .. "/" .. color.Green .. baseHealth .. color.Default .. "\n", false)
		elseif healthRatio < 0.5 then
			tes3mp.SendMessage(pid, color.Red .. "Immediatelly Heal: " .. nameofpid .. " (" .. color.Red .. currentHealth .. color.Default .. "/" .. color.Red .. baseHealth .. ")" .. color.Default .. "\n", false)
		end
	else
		if healthRatio <= 1 and healthRatio >= 0.75 then
			tes3mp.SendMessage(pid, color.Default .. nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth .. color.Default .. "\n", false)
		elseif healthRatio < 0.75 and healthRatio >= 0.5 then
			tes3mp.SendMessage(pid, color.Default .. nameofpid .. "'s Health: " .. currentHealth .. "/" .. baseHealth .. color.Default .. "\n", false)
		elseif healthRatio < 0.5 then
			tes3mp.SendMessage(pid, color.Red .. "Immediatelly Heal: " .. nameofpid .. " (" .. color.Red .. currentHealth .. color.Default .. "/" .. color.Red .. baseHealth .. ")" .. color.Default .. "\n", false) 
		end
	end
end



return Partyhealth
