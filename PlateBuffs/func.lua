-- Isolate the environment
local folder, core = ...

-- globals
local _G = _G
local tostring = tostring
local getn = table.getn
local math_floor = math.floor
local string_sub = string.sub
local string_len = string.len
local string_match = string.match
local string_format = string.format
local GetUnitName = GetUnitName

local L = core.L or LibStub("AceLocale-3.0"):GetLocale(folder, true)

local strDebugFrom = "|cffffff00[%s]|r"
local strWhiteBar = "|cffffff00 || |r"

local colouredName = "|cff7f7f7f{|r|cffff0000PB|r|cff7f7f7f}|r "
function core.echo(...)
    local tbl = {...}
    local msg = tostring(tbl[1])
    for i = 2, getn(tbl) do
        msg = msg .. strWhiteBar .. tostring(tbl[i])
    end

    local cf = _G["ChatFrame1"]
    if cf then
        cf:AddMessage(colouredName .. msg, .7, .7, .7)
    end
end

core.DEBUG = false

-- simple print function.
function core.Debug(from, ...)
    if core.DEBUG == false then return end
    local tbl = {...}
    local msg = tostring(tbl[1])
    for i = 2, getn(tbl) do
        msg = msg .. strWhiteBar .. tostring(tbl[i])
    end
    core.echo(strDebugFrom:format(from) .. " " .. tostring(msg))
end

-- zeroes is the number of decimal places. eg 1=*.*, 3=*.***
function core:Round(num, zeros)
    return math_floor(num * 10 ^ (zeros or 0) + 0.5) / 10 ^ (zeros or 0)
end

function core:RedToGreen(current, max)
    if max == 0 then
        max = 1
    end
    local percentage = (current / max) * 100
    local red, green = 0, 0
    if percentage >= 50 then
        green = 1
        red = ((100 - percentage) / 100) * 2
    else
        red = 1
        green = ((100 - (100 - percentage)) / 100) * 2
    end
    return red, green, 0
end

do
	local chunks = {
	    year = 31536000,
	    month = 2592000,
	    day = 86400,
	    hour = 3600,
	    minute = 60
	}

    -- Returns the number of hours in a readable string format.
    -- maxLenth 1="1h", 2="1h, 33m", 3="1h, 33m, 21s", ect
	function core:SecondsToString(seconds, maxLenth)
	    local msg = ""
	    maxLenth = maxLenth or 2
	    if seconds == 0 then
	        msg = "0s "
	    else
	        local sYear, sMonth, sDay, sHour, sMinute = 0, 0, 0, 0, 0

	        while seconds > (chunks.year - 1) do
	            sYear = sYear + 1
	            seconds = seconds - chunks.year
	        end

	        while seconds > (chunks.month - 1) do
	            sMonth = sMonth + 1
	            seconds = seconds - chunks.month
	        end

	        while seconds > (chunks.day - 1) do
	            sDay = sDay + 1
	            seconds = seconds - chunks.day
	        end

	        while seconds > (chunks.hour - 1) do
	            sHour = sHour + 1
	            seconds = seconds - chunks.hour
	        end

	        while seconds > (chunks.minute - 1) do
	            sMinute = sMinute + 1
	            seconds = seconds - chunks.minute
	        end

	        local sLenth = 0
	        if sYear > 0 and sLenth < maxLenth then
	            sLenth = sLenth + 1
	            msg = sYear .. "y "
	        end

	        if sMonth > 0 and sLenth < maxLenth then
	            sLenth = sLenth + 1
	            msg = msg .. sMonth .. "mo "
	        end

	        if sDay > 0 and sLenth < maxLenth then
	            sLenth = sLenth + 1
	            msg = msg .. sDay .. "d "
	        end

	        if sHour > 0 and sLenth < maxLenth then
	            sLenth = sLenth + 1
	            msg = msg .. sHour .. "h "
	        end

	        if sMinute > 0 and sLenth < maxLenth then
	            sLenth = sLenth + 1
	            msg = msg .. sMinute .. "m "
	        end

	        if seconds > 0 and sLenth < maxLenth then
	            sLenth = sLenth + 1
	            msg = msg .. seconds .. " "
	        end
	    end

	    msg = string_sub(msg, 1, string_len(msg) - 1)

	    return msg
	end
end

-- Returns a unit's name with server if server isn't our own.
-- This name matches the one shown in combatlog.
function core:GetFullName(unitID)
    local name, realm = UnitName(unitID)
    local fullname = name
    if realm and realm ~= "" then
		fullname = fullname.."-"..realm
    end
    return fullname
end

function core:RemoveServerName(name)
    if name ~= nil then
		return string_match(name, "(.+)-") or name --name
    end
end