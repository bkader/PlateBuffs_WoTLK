local folder, core = ...

if not core.LibNameplates then return end

local MSQ = core.MSQ or LibStub("LibButtonFacade", true) or LibStub("Masque", true)
core.MSQ = MSQ

--Globals
local _G = _G
local pairs = pairs
local table_insert = table.insert
local table_sort = table.sort
local table_getn = table.getn
local Debug = core.Debug
local tonumber = tonumber
local GetSpellInfo = GetSpellInfo
local select = select

core.tooltip = core.tooltip or CreateFrame("GameTooltip", folder .. "Tooltip", UIParent, "GameTooltipTemplate")
local tooltip = core.tooltip
tooltip:Show()
tooltip:SetOwner(UIParent, "ANCHOR_NONE")

-- local
local spellIDs = {}

local L = core.L or LibStub("AceLocale-3.0"):GetLocale(folder, true)

local P = {}
local prev_OnEnable = core.OnEnable
function core:OnEnable()
	prev_OnEnable(self)
	P = self.db.profile

	if P.addSpellDescriptions == true then
		spellIDs = self:GetAllSpellIDs()
	end

	self:BuildSpellUI()
end

local defaultSettings = core.defaultSettings.profile

defaultSettings.defaultBuffShow = 3
defaultSettings.defaultDebuffShow = 2
defaultSettings.unknownSpellDataIcon = false
defaultSettings.saveNameToGUID = true
defaultSettings.watchCombatlog = true
defaultSettings.addSpellDescriptions = false
defaultSettings.watchUnitIDAuras = true
defaultSettings.abovePlayers = true
defaultSettings.aboveNPC = true
defaultSettings.aboveFriendly = true
defaultSettings.aboveNeutral = true
defaultSettings.aboveHostile = true
defaultSettings.aboveTapped = true
defaultSettings.textureSize = 0.1
defaultSettings.barAnchorPoint = "BOTTOM"
defaultSettings.plateAnchorPoint = "TOP"
defaultSettings.barOffsetX = 0
defaultSettings.barOffsetY = 8 --bit north incase user's running Threat plates.
defaultSettings.iconsPerBar = 6
defaultSettings.barGrowth = 1
defaultSettings.numBars = 2
defaultSettings.iconSize = 24
defaultSettings.iconSize2 = 24
defaultSettings.increase = 1
defaultSettings.biggerSelfSpells = true
defaultSettings.showCooldown = true
defaultSettings.shrinkBar = true
defaultSettings.showBarBackground = false
defaultSettings.frameLevel = 0
defaultSettings.cooldownSize = 10
defaultSettings.stackSize = 10
defaultSettings.intervalX = 12
defaultSettings.intervalY = 12
defaultSettings.digitsnumber = 1
defaultSettings.showCooldownTexture = true
defaultSettings.borderTexture = "Interface\\Addons\\PlateBuffs\\media\\border.tga"
defaultSettings.colorByType = true
defaultSettings.color1 = {0.80, 0, 0}
defaultSettings.color2 = {0.20, 0.60, 1.00}
defaultSettings.color3 = {0.60, 0.00, 1.00}
defaultSettings.color4 = {0.60, 0.40, 0}
defaultSettings.color5 = {0.00, 0.60, 0}
defaultSettings.color6 = {0.00, 1.00, 0}
defaultSettings.blinkTimeleft = 0.2
defaultSettings.showTotems = false
defaultSettings.npcCombatWithOnly = true
defaultSettings.playerCombatWithOnly = false

core.CoreOptionsTable = {
	name = core.titleFull,
	type = "group",
	childGroups = "tab",
	get = function(info)
		local key = info[#info]
		return P[key]
	end,
	set = function(info, v)
		local key = info[#info]
		P[key] = v
	end,
	args = {
		enable = {
			type = "toggle",
			name = L["Enable"],
			desc = L["Enables / Disables the addon"],
			order = 1,
			width = "double",
			get = function(info)
				return core:IsEnabled()
			end,
			set = function(info, val)
				if val == true then
					core:Enable()
				else
					core:Disable()
				end
			end
		},
		defaultBuffShow = {
			type = "select",
			name = L["Show Buffs"],
			desc = L["Show buffs above nameplate."],
			order = 3,
			values = {ALL, L["Mine + SpellList"], L["Only SpellList"], L["Mine Only"]}
		},
		defaultDebuffShow = {
			type = "select",
			name = L["Show Debuffs"],
			desc = L["Show debuffs above nameplate."],
			order = 4,
			values = {ALL, L["Mine + SpellList"], L["Only SpellList"], L["Mine Only"]}
		},
		unknownSpellDataIcon = {
			type = "toggle",
			name = L["Show question mark"],
			desc = L["Display a question mark above plates we don't know spells for. Target or mouseover those plates."],
			order = 5
		},
		saveNameToGUID = {
			type = "toggle",
			name = L["Save player GUID"],
			desc = L["Remember player GUID's so target/mouseover isn't needed every time nameplate appears.\nKeep this enabled"],
			order = 6,
			get = function(info)
				return P.saveNameToGUID
			end,
			set = function(info, val)
				P.saveNameToGUID = val
			end
		},
		watchCombatlog = {
			type = "toggle",
			name = L["Watch Combatlog"],
			desc = L["Watch combatlog for people gaining/losing spells.\nDisable this if you're having performance issues."],
			order = 7,
			get = function()
				return P.watchCombatlog
			end,
			set = function(info, val)
				P.watchCombatlog = not P.watchCombatlog
				core:RegisterLibAuraInfo()
			end
		},
		addSpellDescriptions = {
			type = "toggle",
			name = L["Add Spell Description"],
			desc = L["Add spell descriptions to the specific spell's list.\nDisabling this will lower memory usage and login time."],
			order = 7,
			get = function()
				return P.addSpellDescriptions
			end,
			set = function(info, val)
				P.addSpellDescriptions = not P.addSpellDescriptions

				if P.addSpellDescriptions then
					spellIDs = core:GetAllSpellIDs()
					core:BuildSpellUI()
				end
			end
		},
		borderTexture = {
			name = L["Border Texture"],
			desc = L["Set border texture."],
			type = "select",
			order = 8,
			values = {
				[""] = NONE,
				["Interface\\Addons\\PlateBuffs\\media\\border.tga"] = "Default",
				["Masque"] = (MSQ and "Masque" or nil)
			},
			set = function(info, val)
				P.borderTexture = val
				core:ResetAllPlateIcons()
			end
		},
		textureSize = {
			name = L["Texture size"],
			desc = L["increase texture size.\nDefaul=0.1"],
			type = "range",
			order = 9,
			min = 0,
			max = 0.3,
			step = 0.01,
			bigStep = 0.1,
			set = function(info, val)
				P.textureSize = val
				core:ResetAllPlateIcons()
			end
		},
		colorHeader = {
			type = "header",
			name = L["Border colors"],
			order = 10
		},
		colorbyType = {
			type = "toggle",
			name = L["Color by type"],
			desc = L["If not set Physical color used for all debuffs"],
			order = 11,
			width = "double",
			get = function(info)
				return P.colorByType
			end,
			set = function(info, val)
				P.colorByType = val
			end
		},
		color1 = {
			type = "color",
			name = L["Physical"],
			order = 12,
			get = function(info)
				return P.color1[1], P.color1[2], P.color1[3], 1
			end,
			set = function(info, r, g, b)
				P.color1 = {r, g, b}
			end
		},
		color2 = {
			name = L["Magic"],
			type = "color",
			order = 13,
			get = function(info)
				return P.color2[1], P.color2[2], P.color2[3], 1
			end,
			set = function(info, r, g, b)
				P.color2 = {r, g, b}
			end
		},
		color3 = {
			name = L["Curse"],
			type = "color",
			order = 14,
			get = function(info)
				return P.color3[1], P.color3[2], P.color3[3], 1
			end,
			set = function(info, r, g, b)
				P.color3 = {r, g, b}
			end
		},
		color4 = {
			name = L["Disease"],
			type = "color",
			order = 15,
			get = function(info)
				return P.color4[1], P.color4[2], P.color4[3], 1
			end,
			set = function(info, r, g, b)
				P.color4 = {r, g, b}
			end
		},
		color5 = {
			name = L["Poison"],
			type = "color",
			order = 16,
			get = function(info)
				return P.color5[1], P.color5[2], P.color5[3], 1
			end,
			set = function(info, r, g, b)
				P.color5 = {r, g, b}
			end
		},
		color6 = {
			name = L["Buff"],
			type = "color",
			order = 17,
			get = function(info)
				return P.color6[1], P.color6[2], P.color6[3], 1
			end,
			set = function(info, r, g, b)
				P.color6 = {r, g, b}
			end
		}
	}
}

core.WhoOptionsTable = {
	type = "group",
	name = core.titleFull,
	childGroups = "tab",
	get = function(info)
		local key = info[#info]
		return P[key]
	end,
	set = function(info, v)
		local key = info[#info]
		P[key] = v
	end,
	args = {
		typeHeader = {
			type = "header",
			name = L["Type"],
			order = 1
		},
		abovePlayers = {
			type = "toggle",
			name = L["Players"],
			desc = L["Add buffs above players"],
			order = 2
		},
		aboveNPC = {
			type = "toggle",
			name = L["NPC"],
			desc = L["Add buffs above NPCs"],
			order = 3
		},
		reactionHeader = {
			name = L["Reaction"],
			type = "header",
			order = 4
		},
		aboveFriendly = {
			type = "toggle",
			name = L["Friendly"],
			desc = L["Add buffs above friendly plates"],
			order = 5
		},
		aboveNeutral = {
			type = "toggle",
			name = L["Neutral"],
			desc = L["Add buffs above neutral plates"],
			order = 6
		},
		aboveHostile = {
			type = "toggle",
			name = L["Hostile"],
			desc = L["Add buffs above hostile plates"],
			order = 7
		},
		aboveTapped = {
			type = "toggle",
			name = L["Tapped"],
			desc = L["Add buffs above tapped plates"],
			order = 8
		},
		otherHeader = {
			name = L["Other"],
			type = "header",
			order = 9
		},
		showTotems = {
			type = "toggle",
			name = L["Show Totems"],
			desc = L["Show spell icons on totems"],
			order = 10
		},
		npcCombatWithOnly = {
			type = "toggle",
			name = L["NPC combat only"],
			desc = L["Only show spells above nameplates that are in combat."],
			order = 11,
			set = function(info, val)
				P.npcCombatWithOnly = val
				core:Disable()
				core:Enable()
			end
		},
		playerCombatWithOnly = {
			type = "toggle",
			name = L["Player combat only"],
			desc = L["Only show spells above nameplates that are in combat."],
			order = 12,
			set = function(info, val)
				P.playerCombatWithOnly = val
				core:Disable()
				core:Enable()
			end
		}
	}
}

core.BarOptionsTable = {
	type = "group",
	name = core.titleFull,
	childGroups = "tab",
	get = function(info)
		local key = info[#info]
		return P[key]
	end,
	set = function(info, v)
		local key = info[#info]
		P[key] = v
	end,
	args = {
		barAnchorPoint = {
			type = "select",
			name = L["Row Anchor Point"],
			order = 1,
			desc = L["Point of the buff frame that gets anchored to the nameplate.\ndefault = Bottom"],
			values = {
				TOP = L["Top"],
				BOTTOM = L["Bottom"],
				TOPLEFT = L["Top Left"],
				BOTTOMLEFT = L["Bottom Left"],
				TOPRIGHT = L["Top Right"],
				BOTTOMRIGHT = L["Bottom Right"]
			},
			set = function(info, val)
				P.barAnchorPoint = val
				core:ResetAllBarPoints()
			end
		},
		plateAnchorPoint = {
			type = "select",
			name = L["Plate Anchor Point"],
			order = 2,
			desc = L["Point of the nameplate our buff frame gets anchored to.\ndefault = Top"],
			values = {
				TOP = L["Top"],
				BOTTOM = L["Bottom"],
				TOPLEFT = L["Top Left"],
				BOTTOMLEFT = L["Bottom Left"],
				TOPRIGHT = L["Top Right"],
				BOTTOMRIGHT = L["Bottom Right"]
			},
			set = function(info, val)
				P.plateAnchorPoint = val
				core:ResetAllBarPoints()
			end
		},
		barOffsetX = {
			type = "range",
			name = L["Row X Offset"],
			desc = L["Left to right offset."],
			order = 3,
			min = -256,
			max = 256,
			step = 1,
			bigStep = 10,
			set = function(info, val)
				P.barOffsetX = val
				core:ResetAllBarPoints()
			end
		},
		barOffsetY = {
			type = "range",
			name = L["Row Y Offset"],
			desc = L["Up to down offset."],
			order = 4,
			min = -256,
			max = 256,
			step = 1,
			bigStep = 10,
			set = function(info, val)
				P.barOffsetY = val
				core:ResetAllBarPoints()
			end
		},
		numBars = {
			type = "range",
			name = L["Max bars"],
			desc = L["Max number of bars to show."],
			order = 5,
			min = 1,
			max = 4,
			step = 1,
			set = function(info, val)
				P.numBars = val
				core:ResetAllPlateIcons()
				core:UpdateBarsBackground()
				core:ShowAllKnownSpells()
			end
		},
		iconsPerBar = {
			type = "range",
			name = L["Icons per bar"],
			desc = L["Number of icons to display per bar."],
			order = 6,
			min = 1,
			max = 16,
			step = 1,
			set = function(info, val)
				P.iconsPerBar = val
				core:ResetAllPlateIcons()
				core:ShowAllKnownSpells()
			end
		},
		barGrowth = {
			type = "select",
			name = L["Row Growth"],
			desc = L["Which way do the bars grow, up or down."],
			order = 7,
			values = {L["Up"], L["Down"]},
			set = function(info, val)
				P.barGrowth = val
				core:ResetAllBarPoints()
			end
		},
		separator = {
			type = "description",
			name = " ",
			order = 8
		},
		biggerSelfSpells = {
			type = "toggle",
			name = L["Larger self spells"],
			desc = L["Make your spells 20% bigger then other's."],
			order = 9
		},
		shrinkBar = {
			type = "toggle",
			name = L["Shrink Bar"],
			desc = L["Shrink the bar horizontally when spells frames are hidden."],
			order = 10,
			set = function(info, val)
				P.shrinkBar = val
				core:UpdateAllPlateBarSizes()
			end
		},
		showBarBackground = {
			type = "toggle",
			name = L["Show bar background"],
			desc = L["Show the area where spell icons will be. This is to help you configure the bars."],
			order = 11,
			set = function(info, val)
				P.showBarBackground = val
				core:UpdateBarsBackground()
			end
		},
		iconTestMode = {
			type = "toggle",
			name = L["Test Mode"],
			desc = L["For each spell on someone, multiply it by the number of icons per bar.\nThis option won't be saved at logout."],
			order = 12,
			width = "double",
			get = function()
				return core.iconTestMode
			end,
			set = function()
				core.iconTestMode = not core.iconTestMode
			end
		}
	}
}

local tmpNewName = ""
local tmpNewID = ""

core.SpellOptionsTable = {
	type = "group",
	name = core.titleFull,
	args = {
		inputName = {
			type = "input",
			name = L["Spell name"],
			desc = L["Input a spell name. (case sensitive)\nOr spellID"],
			order = 1,
			get = function(info)
				return tmpNewName, tmpNewID
			end,
			set = function(info, val)
				local spellLink = GetSpellLink(tonumber(val) or val)
				if spellLink then
					local spellID = spellLink:match("spell:(%d+)")
					if spellID then
						local spellName = GetSpellInfo(spellID)
						if spellName then
							tmpNewName = spellName
							tmpNewID = tonumber(spellID)
							return
						end
					end
				end
				tmpNewName = val
				tmpNewID = "No spellID"
			end
		},
		addName = {
			type = "execute",
			name = L["Add spell"],
			desc = L["Add spell to list."],
			order = 2,
			func = function(info)
				if tmpNewName ~= "" then
					if tmpNewID ~= "" then
						core:AddNewSpell(tmpNewName, tmpNewID)
					else
						core:AddNewSpell(tmpNewName)
					end
					tmpNewName = ""
				end
			end
		},
		spellList = {
			type = "group",
			order = 3,
			name = L["Specific Spells"],
			args = {} --done late
		}
	}
}

core.DefaultSpellOptionsTable = {
	type = "group",
	name = core.titleFull,
	get = function(info)
		local key = info[#info]
		return P[key]
	end,
	set = function(info, v)
		local key = info[#info]
		P[key] = v
	end,
	args = {
		spellDesc = {
			type = "description",
			name = L["Spells not in the Specific Spells list will use these options."],
			order = 1,
			width = "full"
		},
		iconSize = {
			type = "range",
			name = L["Icon width"],
			desc = L["Size of the icons."],
			order = 2,
			min = 8,
			max = 80,
			step = 1,
			set = function(info, val)
				P.iconSize = val
				core:ResetIconSizes()
			end
		},
		iconSize2 = {
			type = "range",
			name = L["Icon height"],
			desc = L["Size of the icons."],
			order = 3,
			min = 8,
			max = 80,
			step = 1,
			set = function(info, val)
				P.iconSize2 = val
				core:ResetIconSizes()
			end
		},
		intervalX = {
			type = "range",
			name = L["Interval X"],
			desc = L["Change interval between icons."],
			order = 4,
			min = 0,
			max = 80,
			step = 1,
			set = function(info, val)
				P.intervalX = val
				core:ResetIconSizes()
			end
		},
		intervalY = {
			type = "range",
			name = L["Interval Y"],
			desc = L["Change interval between icons."],
			order = 5,
			min = 0,
			max = 80,
			step = 1,
			set = function(info, val)
				P.intervalY = val
				core:ResetIconSizes()
			end
		},
		cooldownSize = {
			type = "range",
			name = L["Cooldown Text Size"],
			desc = L["Text size"],
			order = 6,
			min = 6,
			max = 20,
			step = 1,
			set = function(info, val)
				P.cooldownSize = val

				core:ResetCooldownSize()
				core:ResetAllPlateIcons()
				core:ResetIconSizes()
				core:ShowAllKnownSpells()
			end
		},
		stackSize = {
			type = "range",
			name = L["Stack Text Size"],
			desc = L["Text size"],
			order = 7,
			min = 6,
			max = 20,
			step = 1,
			set = function(info, val)
				P.stackSize = val
				core:ResetStackSizes()
			end
		},
		digitsnumber = {
			type = "range",
			name = L["Digits number"],
			desc = L["Digits number after the decimal point."],
			order = 8,
			min = 0,
			max = 2,
			step = 1,
			set = function(info, val)
				P.digitsnumber = val
			end
		},
		blinkTimeleft = {
			type = "range",
			name = L["Blink Timeleft"],
			desc = L["Blink spell if below x% timeleft, (only if it's below 60 seconds)"],
			order = 9,
			min = 0,
			max = 1,
			step = 0.05,
			isPercent = true
		},
		showCooldown = {
			type = "toggle",
			name = L["Show cooldown"],
			desc = L["Show cooldown text under the spell icon."],
			order = 10,
			set = function(info, val)
				P.showCooldown = val
				core:ResetIconSizes()
				core:ShowAllKnownSpells()
			end
		},
		showCooldownTexture = {
			type = "toggle",
			name = L["Show cooldown overlay"],
			desc = L["Show a clock overlay over spell textures showing the time remaining."] .. "\n" .. L["This overlay tends to disappear when the frame's moving."],
			order = 11,
			set = function(info, val)
				P.showCooldownTexture = val
			end
		}
	}
}

do
	local _spelliconcache = {}
	local function SpellString(spellID, size)
		size = size or 12
		if not _spelliconcache[spellID .. size] then
			if spellID and tonumber(spellID) then
				local icon = select(3, GetSpellInfo(spellID))
				_spelliconcache[spellID .. size] = "\124T" .. icon .. ":" .. size .. "\124t"
				return _spelliconcache[spellID .. size]
			else
				return "\124TInterface\\Icons\\" .. core.unknownIcon .. ":" .. size .. "\124t"
			end
		else
			return _spelliconcache[spellID .. size]
		end
	end

	function core:BuildSpellUI()
		local SpellOptionsTable = core.SpellOptionsTable
		SpellOptionsTable.args.spellList.args = {}

		local list = {}
		for name, data in pairs(P.spellOpts) do
			if not P.ignoreDefaultSpell[name] then
				table_insert(list, name)
			end
		end

		table_sort(list, function(a, b) return (a and b) and a < b end)

		local testDone = false
		local spellName, data, spellID
		local spellDesc, spellTexture
		local iconSize
		local nameColour
		local iconTexture

		for i = 1, table_getn(list) do
			spellName = list[i]
			data = P.spellOpts[spellName]
			spellID = P.spellOpts[spellName].spellID or "No spellID"
			iconSize = data.increase or P.increase
			iconTexture = SpellString(spellID)

			if data.show == 1 then
				nameColour = "|cff00ff00%s|r" --green
			elseif data.show == 3 then
				nameColour = "|cffff0000%s|r" --red
			elseif data.show == 5 then
				nameColour = "|cffcd00cd%s|r" --purple
			elseif data.show == 4 then
				nameColour = "|cffb9ffff%s|r" --birizoviy
			else
				nameColour = "|cffffff00%s|r" --yellow
			end

			spellDesc = "??"
			spellTexture = "Interface\\Icons\\" .. core.unknownIcon

			if spellIDs[spellName] or (spellID and type(spellID) == "number") then
				spellIDs[spellName] = spellIDs[spellName] or spellID
				tooltip:SetHyperlink("spell:" .. spellIDs[spellName])

				spellTexture = select(3, GetSpellInfo(spellIDs[spellName]))

				local lines = tooltip:NumLines()
				if lines > 0 then
					spellDesc = _G[folder .. "TooltipTextLeft" .. lines] and _G[folder .. "TooltipTextLeft" .. lines]:GetText() or "??"
				end
			end

			--add spell to table.
			SpellOptionsTable.args.spellList.args[spellName] = {
				type = "group",
				name = iconTexture .. " " .. nameColour:format(spellName .. " (" .. iconSize .. ") #" .. spellID),
				desc = spellDesc, --L["Spell name"],
				order = i,
				args = {}
			}
			if P.addSpellDescriptions == true then
				SpellOptionsTable.args.spellList.args[spellName].args.spellDesc = {
					type = "description",
					name = spellDesc,
					image = spellTexture,
					imageWidth = 32,
					imageHeight = 32,
					order = 1
				}
			end
			SpellOptionsTable.args.spellList.args[spellName].args.showOpt = {
				type = "select",
				name = L["Show"],
				desc = L["Always show spell, only show your spell, never show spell"],
				values = {
					L["Always"],
					L["Mine only"],
					L["Never"],
					L["Only Friend"],
					L["Only Enemy"]
				},
				order = 2,
				get = function(info)
					return P.spellOpts[info[2]].show or 1
				end,
				set = function(info, val)
					P.spellOpts[info[2]].show = val
					core:BuildSpellUI()
				end
			}

			SpellOptionsTable.args.spellList.args[spellName].args.spellID = {
				type = "input",
				name = "Spell ID",
				desc = "Change spellID",
				order = 3,
				get = function(info)
					return tostring(P.spellOpts[info[2]].spellID or "Spell ID not set")
				end,
				set = function(info, val)
					local num = tonumber(val)
					if num then
						P.spellOpts[info[2]].spellID = num
					else
						P.spellOpts[info[2]].spellID = "No SpellID"
					end
				end
			}
			SpellOptionsTable.args.spellList.args[spellName].args.iconSize = {
				type = "range",
				name = L["Icon multiplication"],
				desc = L["Size of the icons."],
				order = 4,
				min = 1,
				max = 3,
				step = 0.1,
				get = function(info)
					return P.spellOpts[info[2]].increase or P.increase
				end,
				set = function(info, val)
					P.spellOpts[info[2]].increase = val

					core:ResetIconSizes()
					core:BuildSpellUI()
				end
			}

			SpellOptionsTable.args.spellList.args[spellName].args.cooldownSize = {
				type = "range",
				name = L["Cooldown Text Size"],
				desc = L["Text size"],
				order = 5,
				min = 6,
				max = 20,
				step = 1,
				get = function(info)
					return P.spellOpts[info[2]].cooldownSize or P.cooldownSize
				end,
				set = function(info, val)
					P.spellOpts[info[2]].cooldownSize = val

					core:ResetCooldownSize()
					core:ResetAllPlateIcons()
					core:ResetIconSizes()
					core:ShowAllKnownSpells()
					core:BuildSpellUI()
				end
			}

			SpellOptionsTable.args.spellList.args[spellName].args.stackSize = {
				type = "range",
				name = L["Stack Text Size"],
				desc = L["Text size"],
				order = 6,
				min = 6,
				max = 20,
				step = 1,
				get = function(info)
					return P.spellOpts[info[2]].stackSize or P.stackSize
				end,
				set = function(info, val)
					P.spellOpts[info[2]].stackSize = val
					core:ResetStackSizes()
					core:BuildSpellUI()
				end
			}

			if data.when then
				SpellOptionsTable.args.spellList.args[spellName].args.addedWhen = {
					type = "description",
					name = L["Added: "] .. data.when,
					order = 7
				}
			end

			SpellOptionsTable.args.spellList.args[spellName].args.grabID = {
				type = "toggle",
				name = L["Check SpellID"],
				desc = L["Check SpellID"],
				order = 8,
				get = function(info)
					return P.spellOpts[info[2]].grabid
				end,
				set = function(info, val)
					P.spellOpts[info[2]].grabid = not P.spellOpts[info[2]].grabid
				end
			}

			SpellOptionsTable.args.spellList.args[spellName].args.removeSpell = {
				type = "execute",
				order = 100,
				name = L["Remove Spell"],
				desc = L["Remove spell from list"],
				func = function(info)
					core:RemoveSpell(info[2])
				end
			}
		end
	end
end

do
	core.AboutOptionsTable = {
		name = core.titleFull,
		type = "group",
		childGroups = "tab",
		get = function(info)
			local key = info[#info]
			return P[key]
		end,
		set = function(info, v)
			local key = info[#info]
			P[key] = v
		end,
		args = {}
	}

	local tostring = tostring
	local GetAddOnMetadata = GetAddOnMetadata
	local fields = {
		"Author",
		"X-Category",
		"X-License",
		"X-Email",
		"Email",
		"eMail",
		"X-Website",
		"X-Credits",
		"X-Localizations",
		"X-Donate",
		"X-Discord",
		"X-Bitcoin"
	}
	local haseditbox = {
		["X-Website"] = true,
		["X-Email"] = true,
		["X-Donate"] = true,
		["X-Discord"] = true,
		["Email"] = true,
		["eMail"] = true,
		["X-Bitcoin"] = true
	}
	local fNames = {
		["Author"] = L.author,
		["X-License"] = L.license,
		["X-Website"] = L.website,
		["X-Donate"] = L.donate,
		["X-Discord"] = "Discord",
		["X-Email"] = L.email,
		["X-Bitcoin"] = L.bitcoinAddress
	}
	local yellow = "|cffffd100%s|r"

	local val
	function core:BuildAboutMenu()
		self.AboutOptionsTable.args.about = {
			type = "group",
			name = L.about,
			order = 99,
			args = {}
		}

		self.AboutOptionsTable.args.about.args.title = {
			type = "description",
			name = yellow:format(L.title .. ": ") .. self.title,
			order = 1
		}
		self.AboutOptionsTable.args.about.args.version = {
			type = "description",
			name = yellow:format(L.version .. ": ") .. self.version,
			order = 2
		}
		self.AboutOptionsTable.args.about.args.notes = {
			type = "description",
			name = yellow:format(L.notes .. ": ") .. tostring(GetAddOnMetadata(folder, "Notes")),
			order = 3
		}

		for i, field in pairs(fields) do
			val = GetAddOnMetadata(folder, field)
			if val then
				if haseditbox[field] then
					self.AboutOptionsTable.args.about.args[field] = {
						type = "input",
						name = fNames[field] or field,
						desc = L.clickCopy,
						order = i + 10,
						width = "double",
						get = function(info)
							local key = info[#info]
							return GetAddOnMetadata(folder, key)
						end
					}
				else
					self.AboutOptionsTable.args.about.args[field] = {
						type = "description",
						name = yellow:format((fNames[field] or field) .. ": ") .. val,
						width = "double",
						order = i + 10
					}
				end
			end
		end

		LibStub("AceConfig-3.0"):RegisterOptionsTable(self.title, self.AboutOptionsTable) --
		LibStub("AceConfigDialog-3.0"):SetDefaultSize(self.title, 600, 500) --680
	end
end