local U = _G["MecAlarm"].Utils

local function print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end
U["print"] = print


local function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end
U["split"] = split

local function nvl(value, ifnull)
	if value == nil then
		return ifnull
	else
		return value
	end
end
U["nvl"] = nvl

local function rpad(s, l, c)
	local srep = string.rep
	local res = s .. srep(c or ' ', l - #s)
	return res, res ~= s
end
U["rpad"] = rpad

local function isInList(tbl, val)
	--checks if a given table contains a given value
    for index, value in pairs(tbl) do
        if value == val then
            return true
        end
    end
    return false
end
U["isInList"] = isInList

local function isInTable(tbl, val)
	--checks if a given table contains a given value
    for index, value in pairs(tbl) do
        if index == val then
            return true
        end
    end
    return false
end
U["isInTable"] = isInTable