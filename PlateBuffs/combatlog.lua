local folder, core = ...

local P
local playerGUID
local Debug = core.Debug
local guidBuffs = core.guidBuffs
local nametoGUIDs = core.nametoGUIDs
local _

local bit_band = bit.band
local GetTime = GetTime
local table_insert = table.insert
local table_remove = table.remove

local GetSpellInfo = GetSpellInfo

local LibAI = LibStub("LibAuraInfo-1.0", true)
if not LibAI then
	error(folder .. " requires LibAuraInfo-1.0.")
	return
end

do
	local UnitGUID = UnitGUID
	local prev_OnEnable = core.OnEnable
	function core:OnEnable()
		prev_OnEnable(self)
		P = self.db.profile
		playerGUID = UnitGUID("player")
		core:RegisterLibAuraInfo()
	end
end

do
	local CombatLogClearEntries = CombatLogClearEntries
	function core:RegisterLibAuraInfo()
		LibAI.UnregisterAllCallbacks(self)
		if P.watchCombatlog == true then
			LibAI.RegisterCallback(self, "LibAuraInfo_AURA_APPLIED")
			LibAI.RegisterCallback(self, "LibAuraInfo_AURA_REMOVED")
			LibAI.RegisterCallback(self, "LibAuraInfo_AURA_REFRESH")
			LibAI.RegisterCallback(self, "LibAuraInfo_AURA_APPLIED_DOSE")
			LibAI.RegisterCallback(self, "LibAuraInfo_AURA_CLEAR")

			CombatLogClearEntries()
		end
	end
end

do
	local prev_OnDisable = core.OnDisable
	function core:OnDisable(...)
		if prev_OnDisable then
			prev_OnDisable(self, ...)
		end
		LibAI.UnregisterAllCallbacks(self)
	end
end

do
	local COMBATLOG_OBJECT_TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER or 0x00000400
	function core:FlagIsPlayer(flags)
		return (bit_band(flags, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0)
	end
end

do
	local COMBATLOG_OBJECT_REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY or 0x00000010
	function core:FlagIsFriendly(flags)
		return (bit_band(flags, COMBATLOG_OBJECT_REACTION_FRIENDLY) ~= 0)
	end
end

do
	local COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE or 0x00000040
	function core:FlagIsHostle(flags)
		return (bit_band(flags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= 0)
	end
end

function core:ForceNameplateUpdate(dstGUID)
	if not self:UpdateTargetPlate(dstGUID) and not self:UpdatePlateByGUID(dstGUID) then
		-- We can't find a nameplate that matches that GUID.
		-- Lets check if the GUID is a player, if so find a
		-- nameplate that matches the player's name.
		local dstName, dstFlags = LibAI:GetGUIDInfo(dstGUID)
		if dstFlags and self:FlagIsPlayer(dstFlags) then
			local shortName = self:RemoveServerName(dstName) -- Nameplates don't have server names.
			nametoGUIDs[shortName] = dstGUID
			self:UpdatePlateByName(shortName)
		end
	end
end

function core:AddSpellToGUID(dstGUID, spellID, srcName, spellName, spellTexture, duration, srcGUID, isDebuff, debuffType, expires, stackCount)
	guidBuffs[dstGUID] = guidBuffs[dstGUID] or {}
	if #guidBuffs[dstGUID] > 0 then
		self:RemoveOldSpells(dstGUID)
	end

	local dstName, dstFlags = LibAI:GetGUIDInfo(dstGUID)
	local getTime = GetTime()
	local count = #guidBuffs[dstGUID]
	if count == 0 then
		i = 0
		table_insert(guidBuffs[dstGUID], i + 1, {
			name = spellName,
			icon = spellTexture,
			duration = (duration or 0),
			playerCast = srcGUID == playerGUID and 1,
			stackCount = stackCount or 0,
			startTime = getTime,
			expirationTime = expires or 0 - 0.1,
			sID = spellID,
			caster = srcName
		})

		if isDebuff then
			guidBuffs[dstGUID][i + 1].isDebuff = true
			guidBuffs[dstGUID][i + 1].debuffType = debuffType or "none"
		end

		return true
	else
		for i = 1, count do
			if
				guidBuffs[dstGUID][i].sID == spellID and
					(not guidBuffs[dstGUID][i].caster or guidBuffs[dstGUID][i].caster == srcName)
			 then
				guidBuffs[dstGUID][i].expirationTime = expires or 0 - 0.1
				guidBuffs[dstGUID][i].startTime = getTime
				return true
			elseif i == count then
				table_insert(guidBuffs[dstGUID], i + 1, {
					name = spellName,
					icon = spellTexture,
					duration = (duration or 0),
					playerCast = srcGUID == playerGUID and 1,
					stackCount = stackCount or 0,
					startTime = getTime,
					expirationTime = expires or 0 - 0.1,
					sID = spellID,
					caster = srcName
				})

				if isDebuff then
					guidBuffs[dstGUID][i + 1].isDebuff = true
					guidBuffs[dstGUID][i + 1].debuffType = debuffType or "none"
				end
				return true
			end
		end
	end
	return false
end

do
	local function CheckFilter(tip, spelllist)
		if tip == "BUFF" then
			return not (spelllist and P.defaultBuffShow == 4)
		elseif tip == "DEBUFF" then
			return not (spelllist and P.defaultDebuffShow == 4)
		end
		return nil
	end

	function core:LibAuraInfo_AURA_APPLIED(event, dstGUID, spellID, srcGUID, spellSchool, auraType)
		if dstGUID == playerGUID then return end

		local found, stackCount, debuffType, duration, expires, isDebuff, casterGUID = LibAI:GUIDAuraID(dstGUID, spellID)

		local spellName, _, spellTexture = GetSpellInfo(spellID)
		local dstName, dstFlags = LibAI:GetGUIDInfo(dstGUID)

		if found then
			spellTexture = spellTexture:upper():gsub("INTERFACE\\ICONS\\", "")

			local updateBars = false
			local spellOpts = core:HaveSpellOpts(spellName, spellID)

			if spellOpts and spellOpts.show and CheckFilter(auraType, true) then
				if
					P.spellOpts[spellName].show == 1 or
					(P.spellOpts[spellName].show == 2 and srcGUID == playerGUID) or
					(P.spellOpts[spellName].show == 4 and core:FlagIsFriendly(dstFlags)) or
					(P.spellOpts[spellName].show == 5 and core:FlagIsHostle(dstFlags))
				then
					updateBars = self:AddSpellToGUID(dstGUID, spellID, LibAI:GetGUIDInfo(srcGUID), spellName, spellTexture, duration, srcGUID, isDebuff, debuffType, expires, stackCount)
				end
			else
				if
					(auraType == "BUFF" and P.defaultBuffShow == 1) or
					((P.defaultBuffShow == 2 and srcGUID == playerGUID) or (P.defaultBuffShow == 4 and srcGUID == playerGUID)) or
					(auraType == "DEBUFF" and P.defaultDebuffShow == 1) or
					((P.defaultDebuffShow == 2 and srcGUID == playerGUID) or (P.defaultDebuffShow == 4 and srcGUID == playerGUID))
				then
					updateBars = self:AddSpellToGUID(dstGUID, spellID, LibAI:GetGUIDInfo(srcGUID), spellName, spellTexture, duration, srcGUID, isDebuff, debuffType, expires, stackCount)
				end
			end

			if updateBars then
				core:ForceNameplateUpdate(dstGUID)
			end
		end
	end
end

function core:LibAuraInfo_AURA_REMOVED(event, dstGUID, spellID, srcGUID, spellSchool, auraType)
	if guidBuffs[dstGUID] and dstGUID ~= playerGUID then
		local srcName = LibAI:GetGUIDInfo(srcGUID)
		for i = #guidBuffs[dstGUID], 1, -1 do
			if guidBuffs[dstGUID][i].sID == spellID and (not guidBuffs[dstGUID][i].caster or guidBuffs[dstGUID][i].caster == srcName) then
				table_remove(guidBuffs[dstGUID], i)
				self:ForceNameplateUpdate(dstGUID)
				return
			end
		end
	end
end

function core:LibAuraInfo_AURA_REFRESH(event, dstGUID, spellID, srcGUID, spellSchool, auraType, expirationTime)
	if dstGUID == playerGUID then return end

	local spellName = GetSpellInfo(spellID)
	if guidBuffs[dstGUID] then
		local srcName = LibAI:GetGUIDInfo(srcGUID)
		for i = #guidBuffs[dstGUID], 1, -1 do
			if guidBuffs[dstGUID][i].sID == spellID and (not guidBuffs[dstGUID][i].caster or guidBuffs[dstGUID][i].caster == srcName) then
				guidBuffs[dstGUID][i].startTime = GetTime()
				guidBuffs[dstGUID][i].expirationTime = expirationTime
				self:ForceNameplateUpdate(dstGUID)
				return
			end
		end
	end

	local dstName = LibAI:GetGUIDInfo(dstGUID)
	if not LibAI:GUIDAuraID(dstGUID, spellID) then
		Debug("SPELL_AURA_REFRESH", LibAI:GUIDAuraID(dstGUID, spellID), dstName, spellName, "passing to SPELL_AURA_APPLIED")
	end
	self:LibAuraInfo_AURA_APPLIED(event, dstGUID, spellID, srcGUID, spellSchool, auraType)
end

function core:LibAuraInfo_AURA_APPLIED_DOSE(event, dstGUID, spellID, srcGUID, spellSchool, auraType, stackCount, expirationTime)
	local spellName = GetSpellInfo(spellID)

	if guidBuffs[dstGUID] then
		local srcName = LibAI:GetGUIDInfo(srcGUID)
		for i = #guidBuffs[dstGUID], 1, -1 do
			if guidBuffs[dstGUID][i].sID == spellID and (not guidBuffs[dstGUID][i].caster or guidBuffs[dstGUID][i].caster == srcName) then
				guidBuffs[dstGUID][i].stackCount = stackCount
				guidBuffs[dstGUID][i].startTime = GetTime()
				guidBuffs[dstGUID][i].expirationTime = expirationTime
				self:ForceNameplateUpdate(dstGUID)
				return
			end
		end
	end

	local dstName = LibAI:GetGUIDInfo(dstGUID)
	if not LibAI:GUIDAuraID(dstGUID, spellID) then
		Debug("LAURA_APPLIED_DOSE", dstName, spellName, "passing to SPELL_AURA_APPLIED")
	end
	self:LibAuraInfo_AURA_APPLIED(event, dstGUID, spellID, srcGUID, spellSchool, auraType)
end

do
	local table_getn = table.getn
	function core:LibAuraInfo_AURA_CLEAR(event, dstGUID)
		if guidBuffs[dstGUID] and dstGUID ~= playerGUID then
			-- Remove all known buffs for that person.
			-- Maybe we're in a BG and don't need their old buffs on our plates.
			for i = table_getn(guidBuffs[dstGUID]), 1, -1 do
				table_remove(guidBuffs[dstGUID], i)
			end
			self:ForceNameplateUpdate(dstGUID)
		end
	end
end