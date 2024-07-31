--[[
Author:		Cyprias, Kader
License:	All Rights Reserved
]]
local folder, core = ...
LibStub("AceAddon-3.0"):NewAddon(core, folder, "AceConsole-3.0", "AceEvent-3.0")

-- global lookup
local Debug = core.Debug

local LibNameplates = LibStub("LibNameplates-1.0", true)
if not LibNameplates then
	error(folder .. " requires LibNameplates-1.0.")
	return
end

local LSM = LibStub("LibSharedMedia-3.0")
if not LSM then
	error(folder .. " requires LibSharedMedia-3.0.")
	return
end

-- local
core.title = "Plate Buffs"
core.version = GetAddOnMetadata(folder, "X-Curse-Packaged-Version") or ""
core.titleFull = core.title .. " " .. core.version
core.addonDir = "Interface\\AddOns\\" .. folder .. "\\"

core.LibNameplates = LibNameplates
core.LSM = LSM

local LDS = LibStub("LibDualSpec-1.0", true)

local L = LibStub("AceLocale-3.0"):GetLocale(folder, true)
core.L = L

-- Nameplates with these names are totems. By default we ignore totem nameplates.
local totemList = {
	2484, --Earthbind Totem
	8143, --Tremor Totem
	8177, --Grounding Totem
	8512, --Windfury Totem
	6495, --Sentry Totem
	8170, --Cleansing Totem
	3738, --Wrath of Air Totem
	2062, --Earth Elemental Totem
	2894, --Fire Elemental Totem
	58734, --Magma Totem
	58582, --Stoneclaw Totem
	58753, --Stoneskin Totem
	58739, --Fire Resistance Totem
	58656, --Flametongue Totem
	58745, --Frost Resistance Totem
	58757, --Healing Stream Totem
	58774, --Mana Spring Totem
	58749, --Nature Resistance Totem
	58704, --Searing Totem
	58643, --Strength of Earth Totem
	57722 --Totem of Wrath
}

-- Important spells, add them with huge icons.
local defaultSpells1 = {
	-- mage
	118, --Polymorph
	45438, --Ice Block
	
	-- shaman
	51514, --Hex
	
	-- warlock
	710, --Banish
	6358, --Seduction
	5782, --Fear
	5484, --Howl of Terror
	6789, --Death Coil
	
	-- rogue
	6770, --Sap
	2094, --Blind
	31230, --cheat death
	
	-- priest
	605, --Mind Control
	8122, --Psychic Scream
	33206, --Pain Suppression (priest)
	47585, --Dispersion (priest)
	9484, -- shackle undead
	47788, -- guardian spirit
	
	-- druid
	33786, --Cyclone
	339, --Entangling Roots
	29166, --Innervate (druid)
	61336, --survival instincts
	34496, --survival instincts
	
	-- hunter
	19386, --Wyvern Sting (hunter)
	19263, --Deterrence
	
	-- paladin
	642, --Divine Shield
	
	-- warrior
	23920, -- spell reflection
	18499, -- berserker rage
	
	-- misc
	23335, -- Silverwing Flag (alliance WSG flag)
	23333, -- Warsong Flag (horde WSG flag)
	34976, -- Netherstorm Flag (EotS flag)
	14267, -- Horde Flag 
	14268 -- Alliance Flag
	
}

-- semi-important spells, add them with mid size icons.
local defaultSpells2 = {
	-- mage
	12472, -- Icy Veins (mage)
	44572, -- Deep Freeze (mage)
	122, -- frost nova
	12494, --frostbite
	55080, -- shattered barrier
	31661, -- dragon's breath
	33395, -- freeze (pet nova)
	12042, -- Arcane Power
	38643, -- Blink
	41425, -- Hypothermia 
	12357, -- Impact
	28500, -- Invisibility 
	31641, -- Blazing Speed
	54749, -- Burning Determination
	12043, -- Presence of Mind
	12051 , -- Evocation
	43039, --Ice Barrier
	18469, -- improved counterspell
	64346, --fiery payback
	28682, -- combustion
	
	-- shaman
	16166, -- elemental mastery
	8178, -- grounding totem
	64695, -- earthgrab (earthbind root effect)
	30823, -- Shamanistic Rage
	16188, -- Ancestral Swiftness
	55277, -- stoneclaw absorb
	58875, -- spirit walk (spirit wolf)
	58861, -- bash (spirit wolf)
	16191, -- mana tide totem
	
	-- warlock
	19647, -- spelllock
	30283, -- shadowfury
	18708, -- Fel Domination
	8612, -- Phase Shift
	20329, -- Phase Shift
	47241, -- Metamorphosis
  	7812, -- sacrifice (voidwalker)
	6229, -- shadow ward
	
	-- rogue
	31224, -- Cloak of Shadows (rogue)
	26669, -- Evasion (rogue)
	11305, -- Sprint
	408, -- kidney shot
	1833, -- cheap shot
	1776, -- gouge
	1330, -- garrote silence
	51690, -- killing spree
	13750, -- adrenaline rush
	45182, -- cheating death
	14278, -- Ghostly Strike
	36554, -- Shadowstep
	13877, -- Blade Flurry	
	51722, --Dismantle
	51713, --Shadow Dance
	14177, --Cold Blood
	
	-- priest
	15487, --Silence (priest)
	10060, -- Power Infusion (priest)
	64044, -- Psychic Horror
	10060, -- power's infusion
	27827, -- Spirit of Redemption
	6346, -- Fear Ward
	
	-- druid
	22812, -- Barkskin (druid)
	53312, -- Nature's Grasp
	1850, -- Dash
	2637, -- Hibernate
	16689, -- Nature's Grasp (Druid)
	5211, -- bash
	22570, -- maim
	16811, -- Nature's Grasp
	49803, -- Pounce
	53201, -- Starfall
	50334, -- Berserk
	22842, -- Frenzied Regeneration
	19675, -- Feral Charge Effect
	38373, -- The Beast Within
	9634, -- dire bear form
	17116, -- Nature's Swiftness
	
	-- hunter
	37587, --Bestial Wrath (hunter)
	19574, --Bestial Wrath
	34490, --Silencing Shot (hunter)
	19503, --Scatter Shot (hunter)
	1499, --Freezing Trap
	60192, --freezing trap
	3355, -- Freezing Arrow Effect
	14309, --Freezing Trap Effect
	60210, --Freezing Arrow Effect
	53480, -- Roar of Sacrifice
	54216, -- master's call
	3045, -- rapid fire
	19577, -- Intimidation 
	19574, -- Bestial Wrath 
	56651, -- Master's Call
	53476, -- Pet Intervene
	53548, -- pin (pet)
	53479, -- Last Stand (pet)
	1742, -- Cower (pet)
	26064, -- Shell Shield (pet)
	26065, -- Shell Shield (pet)
	40087, -- Shell Shield (pet)
	64804, -- Entrapment
	
	-- paladin
	53563, --Beacon of Light (pally)
	498, --Divine Protection
	31884, --Avenging Wrath (pally)
	498, --Divine Protection
	20066, --Repentance (pally)
	10326, --Turn Evil (pally)
	10278, --Hand of Protection (pally)
	1022, -- Hand of protection
	6940, -- hand of sacrifice
	1044, -- hand of freedom
	1038, -- hand of salvation
	31821, -- aura mastery
	31850, -- ardent defender
	66235, -- ardent defender
	53659, -- sacred cleansing
	853, -- Hammer of Justice
	31842, -- Divine Illumination
	19752, -- Divine Intervention 
	64205, -- Divine Sacrifice
	20216, -- Divine Favor
	54428, -- Divine Plea
	
	-- warrior
	871, -- shield wall
	5246, --Intimidating Shout (warrior)
	46924, --Bladestorm (warrior)
	46968, --Shockwave (warrior)
	1719, -- recklessness
	7922, -- charge stun
	20253, -- intercept stun
	23694, -- Improved Hamstring
	2565, -- Shield Block
	676, -- Disarm
	12292, -- Death Wish
	12809, -- Concussion Blow
	18498, -- Gag Order
	3411, -- Intervene
	55694, 	-- Enraged Regeneration
	12328, -- Sweeping Strikes
	20230, -- Retaliation
	64849, -- Unrelenting Assault
	12976, -- Last Stand
	23694, -- Improved Hamstring
	58373, -- Glyph of Hamstring
	
	-- dk
	47476, --Strangulate (dk) 55334?
	49039, --Lichborne (DK)
	48792, --Icebound Fortitude ibf (DK) 58130 ?
	48707, -- AMS
	47481, -- gnaw (pet stun)
	48707 , -- Anti-Magic Shell
	51052, -- Anti-Magic Zone
	51271, -- Unbreakable Armor
	55233, -- Vampiric Blood
	51209, -- hungering cold
	45524, -- chains of ice
	49016, -- Hysteria
	
	30217, --Adamantite Grenade
	24375, --War Stomp
	67867 --Trampled (ToC arena spell when you run over someone)
	
}

-- used to add spell only by name ( no need spellid )
local defaultSpells3 = {
	--5782 -- Fear
	-- mage
	43008, -- Ice Armor
	168, -- Frost Armor
	43024, -- Mage Armor
	43046, -- Molten Armor
	44543, -- Fingers of Frost
	
	-- shaman
	55600, -- Earth Shield
	53819, -- Maelstrom weapon
	
	-- warlock
	30299, -- nether protection
	
	-- rogue
	58427, -- Overkill
	
	-- priest
	15286, -- Vampiric Embrace
	15473, -- shadowform
	6788, -- Weakend Soul
	
	-- paladin
	59578, -- Art of War
	25771, -- Forbearance 
	53601, -- Sacred Shield
	54149, -- Infusion of Light
	
	-- druid
	--52610, -- savage roar 
	69369, -- Predatory Swiftness
	48441, -- rejuvenation
	48451, -- lifebloom
	33981, -- tree of life
	783, -- travel form
	768, -- feral form (?)
	
	-- warrior
	60503, -- Taste For Blood
	
	-- dk
	48263, -- Frost Presence
	49222, -- bone shield

	-- hunter
	34074, -- aspect of the viper
	
	-- dmg racials
	33697, -- blood fury
	26297, -- berserking
	
		-- trinkets 
	60436, -- Grim Toll
	65020, -- Mjolnir Runestone
	71541, -- Icy Rage (WFS)
	67772, -- Paragon (DV HC)
	67708, -- Paragon (DV NM)
	75456, -- Piercing Twilight (STS) HC
	75458, -- Piercing Twilight (STS) NM
	75473, -- CTS HC
	75466, -- CTS NM
	71601, -- DFO NM 
	71644, -- DFO HC
	55775, -- Swordguard Embroidery (tailoring ap proc)
	55637, -- Lightweave (tailoring sp proc
	71636, -- Siphoned Power (phylactery hc)
	71605, -- Siphoned Power (phylactery nm)
	-- DBW HC
	71556, -- AGI
	71559, -- CRIT
	71558, -- AP
	71560, -- HASTE Speed of the Vrykul
	71561, -- STR	
	-- DBW NM
	71484, -- STR 
	71492, -- HASTE 
	71486, -- AP Power of the Taunka
	71491, -- CRIT
	71485, -- AGI
	
		-- misc
	72623,  --Drink
	14823, --Drinking
	25888, --Food
	2825, --Bloodlust
	32182, --Heroism
	28730, --Arcane Torrent
	7744, --Will of the Forsaken
	53908, --Speed POT
	54861, --Nitro Boots
	61242, --Parachute
	2335, --Swiftness Potion
	6624, --Free Action Potion
	6615, --Free Action Potion
	3448, --Lesser Invisibility Potion
	11464, --Invisibility Potion
	17634, --Potion of Petrification
	53905, --Indestructible Potion
	54221 --Potion of Speed
}

local regEvents = {
	"PLAYER_TARGET_CHANGED",
	"UPDATE_MOUSEOVER_UNIT",
	"UNIT_AURA",
	"UNIT_TARGET"
}

core.db = {}
local db
local P  --db.profile

core.defaultSettings = {
	profile = {
		spellOpts = {},
		ignoreDefaultSpell = {} -- default spells that user has removed. Seems odd but this'll save space in the DB file allowing PB to load faster.
	}
}

core.buffFrames = {}
core.guidBuffs = {}
core.nametoGUIDs = {}
-- w/o servername
core.buffBars = {}

local buffBars = core.buffBars
local guidBuffs = core.guidBuffs
local nametoGUIDs = core.nametoGUIDs
local buffFrames = core.buffFrames
local defaultSettings = core.defaultSettings

local _
local pairs = pairs
local UnitExists = UnitExists
local GetSpellInfo = GetSpellInfo

local nameToPlate = {}

core.iconTestMode = false

local table_getn = table.getn

local totems = {}
do
	local name, texture, _
	for i = 1, table_getn(totemList) do
		name, _, texture = GetSpellInfo(totemList[i])
		totems[name] = texture
	end
end

--Add default spells to defaultSettings table.
for i = 1, table_getn(defaultSpells1) do
	local spellName = GetSpellInfo(defaultSpells1[i])
	if spellName then
		core.defaultSettings.profile.spellOpts[spellName] = {
			spellID = defaultSpells1[i],
			increase = 2,
			cooldownSize = 18,
			show = 1,
			stackSize = 18
		}
	end
end

for i = 1, table_getn(defaultSpells2) do
	local spellName = GetSpellInfo(defaultSpells2[i])
	if spellName then
		core.defaultSettings.profile.spellOpts[spellName] = {
			spellID = defaultSpells2[i],
			increase = 1.5,
			cooldownSize = 14,
			show = 1,
			stackSize = 14
		}
	end
end


for i = 1, table_getn(defaultSpells3) do
	local spellName = GetSpellInfo(defaultSpells3[i])
	if spellName then
		core.defaultSettings.profile.spellOpts[spellName] = {
			--spellID = "No SpellID", -- wasn't used anyway, making it a lesser important buffs category
			spellID = defaultSpells3[i],
			increase = 1,
			cooldownSize = 10,
			show = 1,
			stackSize = 10
		}
	end
end

core.Dummy = function() end

function core:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("PB_DB", core.defaultSettings, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileDeleted", "OnProfileChanged")
	self:RegisterChatCommand("pb", "MySlashProcessorFunc")

	if LDS then LDS:EnhanceDatabase(self.db, self.title) end

	self:BuildAboutMenu()

	local config = LibStub("AceConfig-3.0")
	local dialog = LibStub("AceConfigDialog-3.0")
	config:RegisterOptionsTable(self.title, self.CoreOptionsTable)
	dialog:AddToBlizOptions(self.title, self.titleFull)

	config:RegisterOptionsTable(self.title .. "Who", self.WhoOptionsTable)
	dialog:AddToBlizOptions(self.title .. "Who", L["Who"], self.titleFull)

	config:RegisterOptionsTable(self.title .. "Spells", self.SpellOptionsTable)
	dialog:AddToBlizOptions(self.title .. "Spells", L["Specific Spells"], self.titleFull)

	config:RegisterOptionsTable(self.title .. "dSpells", self.DefaultSpellOptionsTable)
	dialog:AddToBlizOptions(self.title .. "dSpells", L["Default Spells"], self.titleFull)

	config:RegisterOptionsTable(self.title .. "Rows", self.BarOptionsTable)
	dialog:AddToBlizOptions(self.title .. "Rows", L["Rows"], self.titleFull)

	config:RegisterOptionsTable(self.title .. "About", self.AboutOptionsTable)
	dialog:AddToBlizOptions(self.title .. "About", L.about, self.titleFull)

	--last UI
	local optionsTable = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	config:RegisterOptionsTable(self.title .. "Profile", optionsTable)
	dialog:AddToBlizOptions(self.title .. "Profile", L["Profiles"], self.titleFull)

	if LDS then LDS:EnhanceOptions(optionsTable, self.db) end

	LSM:Register("font", "Friz Quadrata TT CYR", [[Interface\AddOns\AleaUI\media\FrizQuadrataTT_New.ttf]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
end

local function GetPlateName(plate)
	return LibNameplates:GetName(plate)
end
core.GetPlateName = GetPlateName

local function GetPlateType(plate)
	return LibNameplates:GetType(plate)
end
core.GetPlateType = GetPlateType

local function IsPlateInCombat(plate)
	return LibNameplates:IsInCombat(plate)
end
core.IsPlateInCombat = IsPlateInCombat

local function GetPlateThreat(plate)
	return LibNameplates:GetThreatSituation(plate)
end
core.GetPlateThreat = GetPlateThreat

local function GetPlateReaction(plate)
	return LibNameplates:GetReaction(plate)
end
core.GetPlateReaction = GetPlateReaction

local function GetPlateGUID(plate)
	return LibNameplates:GetGUID(plate)
end
core.GetPlateGUID = GetPlateGUID

local function PlateIsBoss(plate)
	return LibNameplates:IsBoss(plate)
end
core.PlateIsBoss = PlateIsBoss

local function PlateIsElite(plate)
	return LibNameplates:IsElite(plate)
end
core.PlateIsElite = PlateIsElite

local function GetPlateByGUID(guid)
	return LibNameplates:GetNameplateByGUID(guid)
end
core.GetPlateByGUID = GetPlateByGUID

local function GetPlateByName(name, maxhp)
	return LibNameplates:GetNameplateByName(name, maxhp)
end
core.GetPlateByName = GetPlateByName

local function GetTargetPlate()
	return LibNameplates:GetTargetNameplate()
end
core.GetTargetPlate = GetTargetPlate

do
	local OnEnable = core.OnEnable
	function core:OnEnable(...)
		if OnEnable then
			OnEnable(self, ...)
		end

		db = self.db
		P = db.profile

		for i, event in pairs(regEvents) do
			self:RegisterEvent(event)
		end

		LibNameplates.RegisterCallback(self, "LibNameplates_NewNameplate")
		LibNameplates.RegisterCallback(self, "LibNameplates_FoundGUID")
		LibNameplates.RegisterCallback(self, "LibNameplates_RecycleNameplate")

		if P.playerCombatWithOnly == true or P.npcCombatWithOnly == true then
			LibNameplates.RegisterCallback(self, "LibNameplates_CombatChange")
			LibNameplates.RegisterCallback(self, "LibNameplates_ThreatChange")
		end

		-- Update old options.
		if P.cooldownSize < 6 then
			P.cooldownSize = core.defaultSettings.profile.cooldownSize
		end
		if P.stackSize < 6 then
			P.stackSize = core.defaultSettings.profile.stackSize
		end

		for plate in pairs(core.buffBars) do
			for i = 1, table_getn(core.buffBars[plate]) do
				core.buffBars[plate][i]:Show() --reshow incase user disabled addon.
			end
		end
	end
end

do
	local prev_OnDisable = core.OnDisable
	function core:OnDisable(...)
		if prev_OnDisable then
			prev_OnDisable(self, ...)
		end

		LibNameplates.UnregisterAllCallbacks(self)

		for plate in pairs(core.buffBars) do
			for i = 1, table_getn(core.buffBars[plate]) do
				core.buffBars[plate][i]:Hide() --makesure all frames stop OnUpdating.
			end
		end
	end
end

-- User has reset proflie, so we reset our spell exists options.
function core:OnProfileChanged(...)
	self:Disable()
	self:Enable()
end

-- /da function brings up the UI options
function core:MySlashProcessorFunc(input)
	InterfaceOptionsFrame_OpenToCategory(self.titleFull)
	InterfaceOptionsFrame_OpenToCategory(self.titleFull)
end

-- note to self, not buffBars
function core:HidePlateSpells(plate)
	if buffFrames[plate] then
		for i = 1, table_getn(buffFrames[plate]) do
			buffFrames[plate][i]:Hide()
		end
	end
end

local function isTotem(name)
	return totems[name]
end

function core:ShouldAddBuffs(plate)
	local plateName = GetPlateName(plate) or "UNKNOWN"

	if P.showTotems == false and isTotem(plateName) then
		return false
	end

	local plateType = GetPlateType(plate)
	if (P.abovePlayers == true and plateType == "PLAYER") or (P.aboveNPC == true and plateType == "NPC") then
		if plateType == "PLAYER" and P.playerCombatWithOnly == true and (not IsPlateInCombat(plate)) then
			return false
		end

		if plateType == "NPC" and P.npcCombatWithOnly == true and (not IsPlateInCombat(plate) and GetPlateThreat(plate) == "LOW") then
			return false
		end

		local plateReaction = GetPlateReaction(plate)
		if P.aboveFriendly == true and plateReaction == "FRIENDLY" then
			return true
		elseif P.aboveNeutral == true and plateReaction == "NEUTRAL" then
			return true
		elseif P.aboveHostile == true and plateReaction == "HOSTILE" then
			return true
		elseif P.aboveTapped == true and plateReaction == "TAPPED" then
			return true
		end
	end

	return false
end

function core:AddOurStuffToPlate(plate)
	local GUID = GetPlateGUID(plate)
	if GUID then
		self:RemoveOldSpells(GUID)
		self:AddBuffsToPlate(plate, GUID)
		return
	end

	local plateName = GetPlateName(plate) or "UNKNOWN"
	if P.saveNameToGUID == true and nametoGUIDs[plateName] and (GetPlateType(plate) == "PLAYER" or PlateIsBoss(plate)) then
		self:RemoveOldSpells(nametoGUIDs[plateName])
		self:AddBuffsToPlate(plate, nametoGUIDs[plateName])
	elseif P.unknownSpellDataIcon == true then
		self:AddUnknownIcon(plate)
	end
end

function core:LibNameplates_RecycleNameplate(event, plate)
	self:HidePlateSpells(plate)
end

function core:LibNameplates_NewNameplate(event, plate)
	if self:ShouldAddBuffs(plate) == true then
		core:AddOurStuffToPlate(plate)
	end
end

function core:LibNameplates_FoundGUID(event, plate, GUID, unitID)
	if self:ShouldAddBuffs(plate) == true then
		if not guidBuffs[GUID] then
			self:CollectUnitInfo(unitID)
		end

		self:RemoveOldSpells(GUID)
		self:AddBuffsToPlate(plate, GUID)
	end
end

function core:HaveSpellOpts(spellName, spellID)
	if not P.ignoreDefaultSpell[spellName] and P.spellOpts[spellName] then
		if P.spellOpts[spellName].grabid then
			if P.spellOpts[spellName].spellID == spellID then
				return P.spellOpts[spellName]
			else
				return false
			end
		else
			return P.spellOpts[spellName]
		end
	end
	return false
end

do
	local UnitGUID = UnitGUID
	local UnitName = UnitName
	local UnitIsPlayer = UnitIsPlayer
	local UnitClassification = UnitClassification
	local table_remove = table.remove
	local table_insert = table.insert
	local UnitBuff = UnitBuff
	local UnitDebuff = UnitDebuff

	function core:CollectUnitInfo(unitID)
		if not unitID or UnitIsUnit(unitID, "player") then return end

		local GUID = UnitGUID(unitID)
		if not GUID then return end

		local unitName = UnitName(unitID)
		if unitName and P.saveNameToGUID == true and UnitIsPlayer(unitID) or UnitClassification(unitID) == "worldboss" then
			nametoGUIDs[unitName] = GUID
		end

		if P.watchUnitIDAuras == true then
			guidBuffs[GUID] = guidBuffs[GUID] or {}

			--Remove all the entries.
			for i = table_getn(guidBuffs[GUID]), 1, -1 do
				table_remove(guidBuffs[GUID], i)
			end

			local i = 1
			local name, icon, count, duration, expirationTime, unitCaster, spellId, debuffType

			
			while UnitBuff(unitID, i) do
				name, _, icon, count, _, duration, expirationTime, unitCaster, _, _, spellId = UnitBuff(unitID, i)
				icon = icon:upper():gsub("(.+)\\(.+)\\", "")

				local spellOpts = self:HaveSpellOpts(name, spellId)
				if spellOpts and spellOpts.show and P.defaultBuffShow ~= 4 then
					if
						spellOpts.show == 1 or
						(spellOpts.show == 2 and unitCaster == "player") or
						(spellOpts.show == 4 and not UnitCanAttack("player", unitID)) or
						(spellOpts.show == 5 and UnitCanAttack("player", unitID))
					then
						table_insert(guidBuffs[GUID], {
							name = name,
							icon = icon,
							expirationTime = expirationTime,
							startTime = expirationTime - duration,
							duration = duration,
							playerCast = (unitCaster == "player") and 1,
							stackCount = count,
							sID = spellId,
							caster = unitCaster and core:GetFullName(unitCaster)
						})
					end
				elseif duration > 0 then
					if
						P.defaultBuffShow == 1 or
						(P.defaultBuffShow == 2 and unitCaster == "player") or
						(P.defaultBuffShow == 4 and unitCaster == "player")
					then
						table_insert(guidBuffs[GUID], {
							name = name,
							icon = icon,
							expirationTime = expirationTime,
							startTime = expirationTime - duration,
							duration = duration,
							playerCast = (unitCaster == "player") and 1,
							stackCount = count,
							sID = spellId,
							caster = unitCaster and core:GetFullName(unitCaster)
						})
					end
				end

				i = i + 1
			end

			i = 1
			while UnitDebuff(unitID, i) do
				name, _, icon, count, debuffType, duration, expirationTime, unitCaster, _, _, spellId = UnitDebuff(unitID, i)
				icon = icon:upper():gsub("INTERFACE\\ICONS\\", "")

				local spellOpts = self:HaveSpellOpts(name, spellId)
				if spellOpts and spellOpts.show and P.defaultDebuffShow ~= 4 then
					if
						spellOpts.show == 1 or
						(spellOpts.show == 2 and unitCaster == "player") or
						(spellOpts.show == 4 and not UnitCanAttack("player", unitID)) or
						(spellOpts.show == 5 and UnitCanAttack("player", unitID))
					then
						table_insert(guidBuffs[GUID], {
							name = name,
							icon = icon,
							expirationTime = expirationTime,
							startTime = expirationTime - duration,
							duration = duration,
							playerCast = (unitCaster == "player") and 1,
							stackCount = count,
							debuffType = debuffType,
							isDebuff = true,
							sID = spellId,
							caster = unitCaster and core:GetFullName(unitCaster)
						})
					end
				elseif duration > 0 then
					if
						P.defaultDebuffShow == 1 or
						(P.defaultDebuffShow == 2 and unitCaster == "player") or
						(P.defaultDebuffShow == 4 and unitCaster == "player")
					then
						table_insert(guidBuffs[GUID], {
							name = name,
							icon = icon,
							expirationTime = expirationTime,
							startTime = expirationTime - duration,
							duration = duration,
							playerCast = (unitCaster == "player") and 1,
							stackCount = count,
							debuffType = debuffType,
							isDebuff = true,
							sID = spellId,
							caster = unitCaster and core:GetFullName(unitCaster)
						})
					end
				end
				i = i + 1
			end

			if core.iconTestMode == true then
				for j = table_getn(guidBuffs[GUID]), 1, -1 do
					for t = 1, P.iconsPerBar - 1 do
						table_insert(guidBuffs[GUID], j, guidBuffs[GUID][j]) --reinsert the entry abunch of times.
					end
				end
			end
		end

		if unitName and not self:UpdatePlateByGUID(GUID) and (UnitIsPlayer(unitID) or UnitClassification(unitID) == "worldboss") then
			-- LibNameplates can't find a nameplate that matches that GUID. Since the unitID's a player/worldboss which have unique names, add buffs to the frame that matches that name.
			-- Note, this /can/ add buffs to the wrong frame if a hunter pet has the same name as a player. This is so rare that I'll risk it.
			self:UpdatePlateByName(unitName, UnitHealthMax(unitID))
		end
	end
end

function core:PLAYER_TARGET_CHANGED(event, ...)
	if UnitExists("target") then
		self:CollectUnitInfo("target")
	end
end

function core:UNIT_TARGET(event, unitID)
	if not UnitIsUnit(unitID, "player") and UnitExists(unitID .. "target") then
		self:CollectUnitInfo(unitID .. "target")
	end
end

function core:LibNameplates_CombatChange(event, plate, inCombat)
	if core:ShouldAddBuffs(plate) == true then
		core:AddOurStuffToPlate(plate)
	else
		core:HidePlateSpells(plate)
	end
end

function core:LibNameplates_ThreatChange(event, plate, threatSit)
	if core:ShouldAddBuffs(plate) == true then
		core:AddOurStuffToPlate(plate)
	else
		core:HidePlateSpells(plate)
	end
end

function core:UPDATE_MOUSEOVER_UNIT(event, ...)
	if UnitExists("mouseover") then
		self:CollectUnitInfo("mouseover")
	end
end

function core:UNIT_AURA(event, unitID)
	if UnitExists(unitID) then
		self:CollectUnitInfo(unitID)
	end
end

function core:AddNewSpell(spellName, spellID)
	Debug("AddNewSpell", spellName, spellID)
	P.ignoreDefaultSpell[spellName] = nil
	P.spellOpts[spellName] = {show = 1, spellID = spellID}
	self:BuildSpellUI()
end

function core:RemoveSpell(spellName)
	if self.defaultSettings.profile.spellOpts[spellName] then
		P.ignoreDefaultSpell[spellName] = true
	end
	P.spellOpts[spellName] = nil
	core:BuildSpellUI()
end

function core:UpdatePlateByGUID(GUID)
	local plate = GetPlateByGUID(GUID)
	if plate and self:ShouldAddBuffs(plate) == true then
		self:AddBuffsToPlate(plate, GUID)
		return true
	end
	return false
end

-- This will add buff frames to a frame matching a given name.
-- This should only be used for player names because mobs/npcs can share the same name.
function core:UpdatePlateByName(name, maxhp)
	local GUID = nametoGUIDs[name]
	if GUID then
		local plate = GetPlateByName(name, maxhp)
		if plate and self:ShouldAddBuffs(plate) == true then
			core:AddBuffsToPlate(plate, GUID)
			return true
		end
	end
	return false
end

-- This should speed up the look up and the display when it comes
-- to targeted units and their nameplates, hopefully.
function core:UpdateTargetPlate(GUID)
	if UnitExists("target") and UnitGUID("target") == GUID then
		local plate = GetTargetPlate()
		if plate and self:ShouldAddBuffs(plate) == true then
			self:AddBuffsToPlate(plate, GUID)
			return true
		end
	end
	return false
end

function core:GetAllSpellIDs()
	local spells, name = {}, nil

	for i, spellID in pairs(defaultSpells1) do
		name = GetSpellInfo(spellID)
		spells[name] = spellID
	end
	for i, spellID in pairs(defaultSpells2) do
		name = GetSpellInfo(spellID)
		spells[name] = spellID
	end

	for i = 76567, 1, -1 do --76567
		name = GetSpellInfo(i)
		if name and not spells[name] then
			spells[name] = i
		end
	end
	return spells
end

function core:SkinCallback(skin, glossAlpha, gloss, _, _, colors)
	self.db.profile.skin_SkinID = skin
	self.db.profile.skin_Gloss = glossAlpha
	self.db.profile.skin_Backdrop = gloss
	self.db.profile.skin_Colors = colors
end
