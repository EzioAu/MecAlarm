MecAlarm = {}

local AddOnName, AddOn = "MecAlarm", MecAlarm
_G[AddOnName] = AddOn

local frame = CreateFrame("FRAME", "MecAlarmMainframe");

-- Modules
AddOn["Utils"] = {}
AddOn["PlayerStatus"] = {}
AddOn["BossModules"] = {}
AddOn.BossModules["Solarian"] = {}
AddOn.BossModules["Vashj"] = {}

-- PlayerStatus
AddOn.PlayerStatus["Name"] = UnitName("player")
AddOn.PlayerStatus["Class"] = UnitClass("player")
AddOn.PlayerStatus["Zone"] = GetZoneText()

local function hasTalent(tab, talentId)
	local name, iconTexture, tier, column, pointsSpent = GetTalentInfo(tab, talentId)
	if pointsSpent > 0 then
		return true
	end
	
	return false
end

local function getTalentSpec()
	local class = AddOn.PlayerStatus["Class"]
	
	if class == "Druid" then
		if hasTalent(1,18) then
			AddOn.PlayerStatus["Spec"] = "Balance"
		elseif hasTalent(2,18) then 
			AddOn.PlayerStatus["Spec"] = "Feral"
		else
			AddOn.PlayerStatus["Spec"] = "Resto"
		end
	elseif class == "Hunter" then
		if hasTalent(1,18) then
			AddOn.PlayerStatus["Spec"] = "BM"
		elseif hasTalent(2,19) then 
			AddOn.PlayerStatus["Spec"] = "Marksman"
		else
			AddOn.PlayerStatus["Spec"] = "Survival"
		end
	elseif class == "Mage" then
		if hasTalent(1,22) then
			AddOn.PlayerStatus["Spec"] = "Arcane"
		elseif hasTalent(2,14) then 
			AddOn.PlayerStatus["Spec"] = "Fire"
		elseif hasTalent(3,21) then 
			AddOn.PlayerStatus["Spec"] = "Frost"
		else
			AddOn.PlayerStatus["Spec"] = "Fire"
		end
	elseif class == "Paladin" then
		if hasTalent(1,15) then
			AddOn.PlayerStatus["Spec"] = "Holy"
		elseif hasTalent(2,19) then 
			AddOn.PlayerStatus["Spec"] = "Prot"
		else
			AddOn.PlayerStatus["Spec"] = "Ret"
		end
	elseif class == "Priest" then
		if hasTalent(1,21) then
			AddOn.PlayerStatus["Spec"] = "Disc"
		elseif hasTalent(2,16) then 
			AddOn.PlayerStatus["Spec"] = "Holy"
		else
			AddOn.PlayerStatus["Spec"] = "Shadow"
		end
	elseif class == "Rogue" then
		if hasTalent(1,21) then
			AddOn.PlayerStatus["Spec"] = "Ass"
		elseif hasTalent(2,21) then 
			AddOn.PlayerStatus["Spec"] = "Combat"
		else
			AddOn.PlayerStatus["Spec"] = "Subtlety"
		end
	elseif class == "Shaman" then
		if hasTalent(1,16) then
			AddOn.PlayerStatus["Spec"] = "Elemental"
		elseif hasTalent(2,20) then 
			AddOn.PlayerStatus["Spec"] = "Enhance"
		else
			AddOn.PlayerStatus["Spec"] = "Resto"
		end
	elseif class == "Warlock" then
		if hasTalent(1,21) then
			AddOn.PlayerStatus["Spec"] = "Affliction"
		elseif hasTalent(2,20) then 
			AddOn.PlayerStatus["Spec"] = "Demo"
		else
			AddOn.PlayerStatus["Spec"] = "Destruction"
		end
	elseif class == "Warrior" then
		if hasTalent(1,20) then
			AddOn.PlayerStatus["Spec"] = "Arms"
		elseif hasTalent(2,16) then 
			AddOn.PlayerStatus["Spec"] = "Fury"
		elseif hasTalent(3,19) then 
			AddOn.PlayerStatus["Spec"] = "Prot"
		end
	end
end

getTalentSpec()

---------------------------------------------------
--Event handling
-------------------------------------------------
local events = {};
function events:CHARACTER_POINTS_CHANGED(...)
	getTalentSpec()
end

frame:SetScript("OnEvent", function(self, event, ...)
	events[event](self, ...); -- call one of the functions above
end);
for k, v in pairs(events) do
	frame:RegisterEvent(k); -- Register all events for which handlers have been defined
end