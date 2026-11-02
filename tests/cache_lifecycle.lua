-- Run from the repository root with Lua 5.1. Blizzard APIs are mocked.

now = 100
zone = 'none'
strmatch = string.match
function GetTime() return now end
function GetServerTime() return math.floor(now) end
function IsInInstance() return zone ~= 'none', zone end
function IsRatedBattleground() return rated or false end
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
function geterrorhandler() return function(e) error(e) end end
function GetSpellInfo(id) return 'Spell'..tostring(id), '', 'icon' end
function UnitGUID(unit) return unit == 'player' and 'playerGUID' or nil end
function UnitExists(unit) return unit == 'player' end
function UnitIsUnit(a,b) return a == b end
function UnitIsPlayer() return true end
function UnitName(unit) return unit end
function UnitAura() return nil end
function GetPlayerInfoByGUID() return 'Mage', 'MAGE' end
function strsplit(delimiter, value)
    local a,b = value:match('([^'..delimiter..']+)'..delimiter..'(.*)')
    return a or value, b
end
function tContains(t,v) for _,x in ipairs(t) do if x == v then return true end end end
bit = {band = function(a,b)
    local result, place = 0, 1
    while a > 0 and b > 0 do
        if a%2 == 1 and b%2 == 1 then result = result + place end
        a,b,place = math.floor(a/2), math.floor(b/2), place*2
    end
    return result
end}
bit_band = bit.band
COMBATLOG_OBJECT_TYPE_PLAYER = 1
COMBATLOG_OBJECT_REACTION_HOSTILE = 2
DEFAULT_CHAT_FRAME = {AddMessage = function() end}
function CreateFrame()
    local f = {scripts={}, events={}}
    function f:SetScript(k,v) self.scripts[k] = v end
    function f:GetScript(k) return self.scripts[k] end
    function f:RegisterEvent(k) self.events[k] = true end
    function f:UnregisterEvent(k) self.events[k] = nil end
    function f:UnregisterAllEvents() wipe(self.events) end
    function f:CreateTexture() return {SetAllPoints=function() end} end
    return f
end
function count(t) local n=0 for _ in pairs(t) do n=n+1 end return n end

dofile("PlateBuffs/libs/LibStub/LibStub.lua")
dofile("PlateBuffs/libs/CallbackHandler-1.0/CallbackHandler-1.0.lua")
dofile("PlateBuffs/libs/LibAuraInfo-1.0/LibAuraInfo-1.0.lua")

    AI=LibStub('LibAuraInfo-1.0')
    AI.auraInfo={[1]='10;1'}; AI.auraInfoPvP={}
    assert(not AI.frame:GetScript('OnUpdate'))
    a,b,c={},{},{}
    AI.RegisterCallback(a,'LibAuraInfo_AURA_APPLIED',function() end)
    AI.RegisterCallback(b,'LibAuraInfo_AURA_REMOVED',function() end)
    AI.RegisterCallback(c,'LibAuraInfo_AURA_REMOVED',function() end)
    AI.frame.TEST_EVENT=function() end
    for i=1,2000 do
        local guid='guid'..i
        AI.frame:COMBAT_LOG_EVENT_UNFILTERED('CLEU',now,'TEST_EVENT',guid,'Name',1,guid,'Name',1)
        AI:AddAuraFromUnitID(guid,1,guid,true,'Magic',10,now+10,1)
    end
    assert(count(AI.GUIDAuras)==2000)
    AI:AddAuraFromUnitID('live',1,'caster',true,'Magic',7200,now+7200,1)
    AI:AddAuraFromUnitID('permanent',1,'caster',false,'none',0,0,1)
    AI:RemoveExpiredAuras('permanent');assert(AI.GUIDAuras.permanent)
    AI.GUIDDrEffects_reset.old=now+15;AI.GUIDDrEffects_diminished.old=0.5
    AI.GUIDDurations['caster-1']=20
    assert(AI:GetDuration(1,'caster')==20)
    now=500;AI.frame:GetScript('OnUpdate')(AI.frame,400)
    assert(count(AI.GUIDAuras)==1 and AI.GUIDAuras.live)
    assert(not next(AI.GUIDData_name) and not next(AI.GUIDData_flags))
    assert(not next(AI.GUIDDrEffects_reset) and not next(AI.GUIDDrEffects_diminished))
    now=2001;AI:PruneTransientData();assert(not next(AI.GUIDDurations))
    AI.UnregisterAllCallbacks(a);AI.UnregisterAllCallbacks(b)
    assert(AI.trackAuras and AI.frame.events.COMBAT_LOG_EVENT_UNFILTERED and AI.GUIDAuras.live)
    AI.UnregisterAllCallbacks(c)
    assert(not AI.trackAuras and not AI.frame:GetScript('OnUpdate'))
    assert(not AI.frame.events.COMBAT_LOG_EVENT_UNFILTERED and not next(AI.GUIDAuras))
    AI.RegisterCallback(a,'LibAuraInfo_AURA_APPLIED',function() end)
    assert(AI.frame:GetScript('OnUpdate') and AI.trackAuras)
    AI.frame:PLAYER_TARGET_CHANGED()
    AI.frame:UNIT_AURA('UNIT_AURA','missing')
    AI.frame:UNIT_TARGET('UNIT_TARGET','missing')


print("PASS: cache lifecycle regression checks")
