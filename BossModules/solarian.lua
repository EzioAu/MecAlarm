local U = _G["MecAlarm"].Utils
local P = _G["MecAlarm"].PlayerStatus
local Solarian = _G["MecAlarm"].BossModules.Solarian

local time_since_raid_refresh = 0
local time_since_player_refresh = 0
local raiders = {}

-------------------------------------------------
--Frame definitions
-------------------------------------------------

--Define the controller frame
local frame = CreateFrame("FRAME", "SolarianController");
if P.Zone ~= "Tempest Keep" then
	--Initially hide the frame if not in TK when you log in
	frame:Hide()
end

--Define color frame
local f2 = CreateFrame("FRAME", "SolarianScreenColorFrame", SolarianController);
f2:Hide()
f2:SetHeight(2000)
f2:SetWidth(2000)
f2:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
f2.background = f2:CreateTexture(nil, "BACKGROUND")
f2.background:SetTexture(0, 1, 0, 0.2)
f2.background:SetAllPoints()

---------------------------------------
---Counts frame -----------------------
---------------------------------------
local f3 = CreateFrame("FRAME", nil, SolarianController)
f3:SetHeight(300)
f3:SetWidth(130)
f3:SetPoint("CENTER",UIParent, "LEFT", 0, 0)

-- Text
f3.text = f3:CreateFontString(nil, "ARTWORK")
f3.text:SetFont("Interface\\AddOns\\MecAlarm\\media\\skurri.ttf", 10)
f3.text:SetPoint("TOPLEFT", 10, -10)
f3.text:SetPoint("BOTTOMRIGHT", -3, 10)
f3.text:SetJustifyH("RIGHT")
f3.text:SetJustifyV("TOP")
f3.text:SetText("test")

-- Movable
f3:EnableMouse(true)
f3:SetMovable(true)
f3:SetClampedToScreen(true)
f3:RegisterForDrag("LeftButton")
f3:SetScript("OnDragStart",
            function(self) if self:IsMovable() then self:StartMoving() end end)
f3:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
f3:SetFrameStrata("BACKGROUND")
f3:SetResizable(true)
f3:SetMinResize(70, 100)
f3:SetScript("OnSizeChanged", function (self, width, height)
	local height_ = self:GetHeight()
	local width_ = self:GetWidth()
end)

-- Background
f3.background = f3:CreateTexture(nil, "BACKGROUND")
f3.background:SetTexture(0, 0, 0, 0.2)
f3.background:SetAllPoints()

-- Resize Button
rb = CreateFrame("Button", nil, f3)
rb:SetPoint("BOTTOMRIGHT", 0, 0)
rb:SetHeight(16)
rb:SetWidth(16)
rb:SetNormalTexture("Interface\\AddOns\\MecAlarm\\media\\Resize.tga")
rb:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then f3:StartSizing("BOTTOMRIGHT") end
end)
rb:SetScript("OnMouseUp", function(self, button) f3:StopMovingOrSizing() end)

-- Hide Frame
f3:Hide()

-------------------------------------------------
--Functions
-------------------------------------------------
local function UpdateRaidMemberWrathCount(unitId, name)
	local wrathCount = 0

	for i=1,8 do
		local debuffName, rank, icon, count, _, duration, expirationTime = UnitDebuff(unitId, i)
		if debuffName ~= nil then
			if debuffName == "Wrath of the Astromancer" then
				wrathCount = math.max(wrathCount, count)
			end
		end
	end
	
	raiders[name]["wrathCount"] = wrathCount
end

local function UpdatePlayerWrathCount()
	if raiders[P.Name] == nil then
		raiders[P.Name] = {}
	end
	raiders[P.Name]["hasShortDebuff"] = false
	raiders[P.Name]["hasLongDebuff"] = false
	if raiders[P.Name]["shortCount"] ~= nil then
		local oldShortCount = raiders[P.Name]["shortCount"]
	end
	raiders[P.Name]["shortCount"] = 0
	local shortCount = 0

	for i=1,8 do
		local debuffName, rank, icon, count, debuffType, duration, expirationTime = UnitDebuff("player", i)
		if debuffName == "Wrath of the Astromancer" then
			if duration ~= nil then
				if duration < 20 then
					raiders[P.Name]["hasShortDebuff"] = true
					shortCount = shortCount + 1
				else
					raiders[P.Name]["hasLongDebuff"] = true
				end
			else
				raiders[P.Name]["hasShortDebuff"] = true
				shortCount = shortCount + 1
			end
		end
	end
	
	raiders[P.Name]["shortCount"] = shortCount
	
	if shortCount > 0 then
		SendAddonMessage("MA", P.Name.."?"..shortCount, "RAID")
	elseif oldShortCount ~= shortCount then
		SendAddonMessage("MA", P.Name.."?"..shortCount, "RAID")
	end
	
end

local function GetRaidMemberStatuses()	
	for i=1,GetNumRaidMembers() do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i);
		if zone == "Tempest Keep" and online then
			if raiders[name] == nil then
				raiders[name] = {}
			end
			raiders[name]["raidIndex"] = i
			raiders[name]["class"] = i
			raiders[name]["isDead"] = isDead
			UpdateRaidMemberWrathCount("raid"..i, name)
		end
	end
end

local function MakeTextColored(str, hex)
	str = "|cff" .. hex .. str .. "|r"
	return str
end

local function MakeTextString(tbl)
	local str = ""
	local new_line = ""

	for k, v in pairs(tbl) do
		local shortCnt = ""
		if v.shortCount ~= nil then
			if v.shortCount > 0 then 
				shortCnt = v.shortCount .. "x " 
				new_line = MakeTextColored(shortCnt .. v.name, "32CD32")
			else --shortCount is 0
				new_line = shortCnt .. v.name
			end
		else
			new_line = v.name
		end
		new_line = new_line .. ": " .. MakeTextColored(U.rpad(""..v.wrathCount,3,"  "), "33A8FF")
		
		str = str .. new_line .. "\n"
	end
	
	return str
end

local function SetCounterFrameText()
	local zt = {}
	
	for k,v in pairs(raiders) do
		if v.isDead ~= 1 then
			table.insert(zt, {name = k, wrathCount = v.wrathCount, shortCount = v.shortCount})
		end
	end
	
	table.sort (zt, function (k1, k2) 
		if k1.wrathCount ~= k2.wrathCount then
			return k1.wrathCount > k2.wrathCount 
		end
		
		return k1.name < k2.name
	end)
	
	f3.text:SetText(MakeTextString(zt))
end

local function aWrathDebuffExists()
	for k,v in pairs(raiders) do
		if v.wrathCount ~= nil then
			if v.wrathCount > 0 then
				return true
			end
		end
	end
	
	return false
end

frame:SetScript("OnUpdate", function(self, elapsed)
	time_since_raid_refresh = time_since_raid_refresh + elapsed
	time_since_player_refresh = time_since_player_refresh + elapsed
	
	if time_since_raid_refresh > 1 then
		time_since_raid_refresh = 0
		GetRaidMemberStatuses()
		SetCounterFrameText()
		
		if aWrathDebuffExists() then
			f3:Show()
		else
			f3:Hide()
		end
	end
	
	if time_since_player_refresh > 0.15 then
		time_since_player_refresh = 0
		UpdatePlayerWrathCount()
		
		if raiders[P.Name].hasShortDebuff then
			f2:Show()
			f2.background:SetTexture(0, 1, 0, 0.3)
		elseif raiders[P.Name].hasLongDebuff then
			f2:Show()
			f2.background:SetTexture(0, 0, 1, 0.3)
		else
			f2:Hide()
		end
	end
end)

-------------------------------------------------
--Event handling
-------------------------------------------------
local events = {};
function events:ZONE_CHANGED_NEW_AREA(...)
	if GetZoneText() == "Tempest Keep" then
		frame:Show()
	else
		frame:Hide()
	end
end
function events:CHAT_MSG_ADDON(...)
	local arg1, arg2, arg3 = ...
	if arg1=="MA" then
		local destName = U.split(arg2, "?")[1]
		local count = U.split(arg2, "?")[2]
		if destName ~= P.Name then
			if raiders[destName] == nil then raiders[destName] = {} end
			raiders[destName]["shortCount"] = tonumber(count)
		end
	end
end
function events:PLAYER_REGEN_DISABLED(...)
	raiders = {}
end

frame:SetScript("OnEvent", function(self, event, ...)
	events[event](self, ...); -- call one of the functions above
end);
for k, v in pairs(events) do
	frame:RegisterEvent(k); -- Register all events for which handlers have been defined
end
