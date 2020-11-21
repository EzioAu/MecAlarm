local U = _G["MecAlarm"].Utils
local P = _G["MecAlarm"].PlayerStatus
local Vashj = _G["MecAlarm"].BossModules.Vashj

local time_since_last_mc = 0;
local mc_count = 0;
local is_unequip_candidate = false;
local weapons_need_to_be_reequipped = false;
local mh_weapon = nil
local oh_weapon = nil

-------------------------------------------------
--Frame definitions
-------------------------------------------------

--Define the controller frame
local frame = CreateFrame("FRAME", "VashjController");
if P.Zone ~= "Serpentshrine Cavern" then
	--Initially hide the frame if not in SSC when you log in
	frame:Hide()
end

--Define the mind control frame
local mc = CreateFrame("FRAME", "VashjMindControlHandler", VashjController);
mc:Hide()

-------------------------------------------------
--Functions
-------------------------------------------------
local function hasPersuasion()
	for i=1,16 do
		local debuffName = UnitDebuff("player", i)
		if debuffName == "Persuasion" then
			return true
		end
	end
	
	return false
end

local function doesWeaponNeedToBeUnequipped()
	local melee_specs = {"Ret", "Arms", "Fury", "Enhance"}
	if P.Class == "Hunter" or P.Class == "Rogue" or U.isInList(melee_specs, P.Spec) then
		return true
	else 
		return false
	end
end

local function getItemNameBySlot(slot)
	local itemLink = GetInventoryItemLink("player", slot);
	if itemLink == nil then
		return nil
	else
		local itemName = GetItemInfo(itemLink);
		return itemName;
	end
end

local function isWeaponHandEquipped(weapon_hand)
	if weapon_hand == nil or IsEquippedItem(weapon_hand)==1 then
		return true
	end
end

local function isWeaponEquipped()
	return isWeaponHandEquipped(mh_weapon) or isWeaponHandEquipped(oh_weapon)
end

local function areBothWeaponsEquipped()
	return isWeaponHandEquipped(mh_weapon) and isWeaponHandEquipped(oh_weapon)
end

local function unequipWeapons()
	PickupInventoryItem(16)
	PutItemInBackpack()
	PickupInventoryItem(17)
	PutItemInBackpack()
end

local function equipWeapons()
	EquipItemByName(mh_weapon, 16)
	EquipItemByName(oh_weapon, 17)
end

local function areInCombatWithVashj()
	for i = 1, GetNumRaidMembers() do
		if UnitName("raid"..i.."target") == "Lady Vashj" and UnitAffectingCombat("raid"..i.."target") then
			return true
		end
	end
	
	return false
end

mc:SetScript("OnShow", function(self)
	time_since_last_mc = 0
	mc_count = 0
	is_unequip_candidate = doesWeaponNeedToBeUnequipped()
	if is_unequip_candidate then
		mh_weapon = getItemNameBySlot(16)
		oh_weapon = getItemNameBySlot(17)
	end
end);

mc:SetScript("OnUpdate", function(self, elapsed)
	time_since_last_mc = time_since_last_mc + elapsed

	if is_unequip_candidate and isWeaponEquipped() then
		if (mc_count == 0 and time_since_last_mc > 13) or (mc_count > 0 and time_since_last_mc > 18) then
			mc_count = mc_count + 1
			unequipWeapons()
		end
	end
end)

frame:SetScript("OnUpdate", function(self, elapsed)
	if weapons_need_to_be_reequipped and time_since_last_mc > 0.5 then 
		if hasPersuasion() then
			unequipWeapons()
			weapons_need_to_be_reequipped = false
		else
			equipWeapons()
			if areBothWeaponsEquipped() then
				weapons_need_to_be_reequipped = false
			end
		end
	elseif mc:IsVisible() and time_since_last_mc > 5 and areInCombatWithVashj() == false then
		--here is our case for when the fight is over and we need to re-equip the player's weapons
		time_since_last_mc = 0
		mc_count = 0
		weapons_need_to_be_reequipped = true
		mc:Hide()
	elseif weapons_need_to_be_reequipped and mc_count == 0 then
		equipWeapons()
		if areBothWeaponsEquipped() then
			weapons_need_to_be_reequipped = false
		end
	end
end)

-------------------------------------------------
--Event handling
-------------------------------------------------
local events = {};
function events:ZONE_CHANGED_NEW_AREA(...)
	if GetZoneText() == "Serpentshrine Cavern" then
		frame:Show()
	else
		frame:Hide()
	end
end

function events:CHAT_MSG_MONSTER_YELL(...)
	local text = ...
	if string.find(text, "You may want to take cover.") then
		mc:Show()
	end
end

--function events:PLAYER_REGEN_ENABLED(...)
--	if areInCombatWithVashj() and mc:IsVisible() and hasPersuasion() == false then
--		time_since_last_mc = 0
--		mc_count = 0
--		weapons_need_to_be_reequipped = true
--		mc:Hide()
--	end
--end

function events:COMBAT_LOG_EVENT_UNFILTERED(...)
	local subevent = select(2, ...)
	if subevent == "SPELL_CAST_SUCCESS" then
		local spellName = select(10,...)
		if spellName == "Persuasion" then
			time_since_last_mc = 0
			weapons_need_to_be_reequipped = true
		end
	end
end

frame:SetScript("OnEvent", function(self, event, ...)
	events[event](self, ...); -- call one of the functions above
end);
for k, v in pairs(events) do
	frame:RegisterEvent(k); -- Register all events for which handlers have been defined
end
