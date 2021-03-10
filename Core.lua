local ShowMyStatsAddon = LibStub("AceAddon-3.0"):NewAddon("ShowMyStats", "AceConsole-3.0", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
--local AceGUISharedMediaWidgets = LibStub:GetLibrary("AceGUISharedMediaWidgets-1.0", true)



local defaults = {
    profile = {
        stats = {
            "strength",
            "agility",
            "intellect",
            "stamina",
        
            "crit",
            "haste",
            "mastery",
            "versatility",
            "lifesteal",
            "avoidance",
            --"speed",
        
            "manaregen",
        
            "armor",
            "dodge",
            "parry",
            "block",
            "stagger",
        
            "absorb"
        },
        font = {
            type = 1,
            size = 16,
            alignment = 3,
            outline = 1,
        },
        background = {
            color = {
                r = 0,
                g = 0,
                b = 0,
                a = 0,
            },
        },
        position = {
            x = -150,
            y = -250,
            anchor = 'TOP',
        },
        haste = {
            enabled = true,
            color = {
                r = 0.4,
                g = 0.7,
                b = 0.9,
                a = 1,
            },
        },
        crit = {
            enabled = true,
            color = {
                r = 0.9,
                g = 0.7,
                b = 0.4,
                a = 1,
            },
        },
        mastery = {
            enabled = true,
            color = {
                r = 0.3,
                g = 0.3,
                b = 0.9,
                a = 1,
            },
        },
        versatility = {
            enabled = true,
            color = {
                r = 0.2,
                g = 0.9,
                b = 0.4,
                a = 1,
            },
        },
        ['**'] = {
            enabled = false,
            color = {
                r = 255/255,
                g = 255/255,
                b = 255/255,
                a = 1,
            },
        },
    }
}

function ShowMyStatsAddon:OnInitialize()
    -- Code that you want to run when the addon is first loaded goes here.
    self.db = LibStub("AceDB-3.0"):New("ShowMyStatsDB", defaults)
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    self.configFrameShown = false
    self.text = {}
    self:CreateInterfaceOptionsFrame()
    self.alignments = {"TOP", "TOPLEFT", "TOPRIGHT"}
    self.alignment = self.alignments[self.db.profile.font.alignment]
    self.outlines = {"OUTLINE", "THICKOUTLINE", "MONOCHROME", ""}
    self.outline = self.outlines[self.db.profile.font.outline]

    self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "UpdateHandler")
    --self:RegisterEvent("UNIT_INVENTORY_CHANGED", "UpdateHandler")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateHandler")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateHandler")

    -- official events from doll code
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateHandler");
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "UpdateHandler");
	self:RegisterEvent("UNIT_MODEL_CHANGED", "UpdateHandler");
	self:RegisterEvent("UNIT_LEVEL", "UpdateHandler");
	self:RegisterEvent("UNIT_STATS", "UpdateHandler");
	self:RegisterEvent("UNIT_RANGEDDAMAGE", "UpdateHandler");
	self:RegisterEvent("UNIT_ATTACK_POWER", "UpdateHandler");
	self:RegisterEvent("UNIT_RANGED_ATTACK_POWER", "UpdateHandler");
	self:RegisterEvent("UNIT_ATTACK", "UpdateHandler");
	self:RegisterEvent("UNIT_SPELL_HASTE", "UpdateHandler");
	self:RegisterEvent("UNIT_RESISTANCES", "UpdateHandler");
	self:RegisterEvent("PLAYER_GUILD_UPDATE", "UpdateHandler");
	self:RegisterEvent("SKILL_LINES_CHANGED", "UpdateHandler");
	self:RegisterEvent("COMBAT_RATING_UPDATE", "UpdateHandler");
	self:RegisterEvent("MASTERY_UPDATE", "UpdateHandler");
	self:RegisterEvent("SPEED_UPDATE", "UpdateHandler");
	self:RegisterEvent("LIFESTEAL_UPDATE", "UpdateHandler");
	self:RegisterEvent("AVOIDANCE_UPDATE", "UpdateHandler");
	self:RegisterEvent("KNOWN_TITLES_UPDATE", "UpdateHandler");
	self:RegisterEvent("UNIT_NAME_UPDATE", "UpdateHandler");
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "UpdateHandler");
	self:RegisterEvent("BAG_UPDATE", "UpdateHandler");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "UpdateHandler");
	self:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE", "UpdateHandler");
	self:RegisterEvent("PLAYER_DAMAGE_DONE_MODS", "UpdateHandler");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "UpdateHandler");
	self:RegisterEvent("UNIT_DAMAGE", "UpdateHandler");
	self:RegisterEvent("UNIT_ATTACK_SPEED", "UpdateHandler");
	self:RegisterEvent("UNIT_MAXHEALTH", "UpdateHandler");
	self:RegisterEvent("UNIT_AURA", "UpdateHandler");
	self:RegisterEvent("SPELL_POWER_CHANGED", "UpdateHandler");
	self:RegisterEvent("CHARACTER_ITEM_FIXUP_NOTIFICATION", "UpdateHandler");
	self:RegisterEvent("TRIAL_STATUS_UPDATE", "UpdateHandler");
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateHandler");
	self:RegisterEvent("GX_RESTARTED", "UpdateHandler");
end

function ShowMyStatsAddon:OnEnable()
    -- Called when the addon is enabled
end

function ShowMyStatsAddon:OnDisable()
    -- Called when the addon is disabled
end





local options = { -- TODO: what is this?
    name = "ShowMyStats",
    handler = ShowMyStatsAddon,
    type = 'group',
    args = {
        msg = {
            type = 'input',
            name = 'My Message',
            desc = 'The message for my addon',
            set = 'SetMyMessage',
            get = 'GetMyMessage',
        },
    },
}
function ShowMyStatsAddon:GetMyMessage(info)
    return myMessageVar
end
function ShowMyStatsAddon:SetMyMessage(info, input)
    myMessageVar = input
end
LibStub("AceConfig-3.0"):RegisterOptionsTable("ShowMyStats", options, {"sms", "showmystats"})


function ShowMyStatsAddon:CreateInterfaceOptionsFrame()
    local frame = CreateFrame("Frame", "ShowMyStats", UIParent);
    frame.name = "ShowMyStats"
    InterfaceOptions_AddCategory(frame)

    local fontString = frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    fontString:SetPoint("CENTER", 0, 200)
    fontString:SetText("Please click the button below to open the configuration panel of this Addon. You can also type /sms or /showmystats into your chat window to open it.")
    fontString:SetWidth(500)
    --fontString:SetHeight(500)
    fontString:Show()

    local button = CreateFrame("Button", "ButtonTest", frame, "UIPanelButtonTemplate")
    button:SetSize(180, 22)
    button:SetText("Open configuration panel")
    button:SetPoint("CENTER",0, 150)
    button:SetScript("OnClick", function()
        self:ShowConfigFrame()
    end)
    --button:Show()
    --frame:AddChild(button)
end

ShowMyStatsAddon:RegisterChatCommand("sms", "ShowConfigFrame")
ShowMyStatsAddon:RegisterChatCommand("showmystats", "ShowConfigFrame")
function ShowMyStatsAddon:ShowConfigFrame()
    if self.configFrameShown then
        return
    end
    self.configFrameShown = true

    local frame = AceGUI:Create("Frame")
    self.configFrame = frame
    frame:SetTitle("ShowMyStats")
    frame:SetStatusText("ShowMyStats Configuration Panel")
    frame:SetCallback("OnClose", function(widget) 
        self.configFrameShown = false
        AceGUI:Release(widget) 
    end)
    frame:SetLayout("Flow") -- List/FLow/Fill

    local headingPosition = AceGUI:Create("Heading")
    headingPosition:SetWidth(500)
    headingPosition:SetText("Frame Configuration")
    frame:AddChild(headingPosition)


    local sliderX = AceGUI:Create("Slider")
    sliderX:SetValue(self.db.profile.position.x)
    sliderX:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.position.x = value
        self:MoveStatFrame()
    end)
    sliderX:SetSliderValues(-1000, 1000, 1)
    sliderX:SetLabel("Horizontal Position")
    frame:AddChild(sliderX)

    local sliderY = AceGUI:Create("Slider")
    sliderY:SetValue(self.db.profile.position.y)
    sliderY:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.position.y = value
        self:MoveStatFrame()
    end)
    sliderY:SetSliderValues(-1000, 1000, 1)
    sliderY:SetLabel("Vertical Position")
    frame:AddChild(sliderY)

    local dropdownAnchor = AceGUI:Create("Dropdown")
    --dropdownAnchor:SetWidth(250)
    dropdownAnchor:SetList({
        TOP = "Top",
        RIGHT = "Right",
        BOTTOM = "Bottom",
        LEFT = "Left",
        TOPRIGHT = "Top right",
        TOPLEFT = "Top left",
        BOTTOMLEFT = "Bottom left",
        BOTTOMRIGHT = "Bottom right",
        CENTER = "Center"
    })
    dropdownAnchor:SetCallback("OnValueChanged", function(widget, event, key)
        self.db.profile.position.anchor = key
        self:MoveStatFrame()
    end)
    dropdownAnchor:SetValue(self.db.profile.position.anchor)
    dropdownAnchor:SetLabel("Anchor")
    frame:AddChild(dropdownAnchor)

    local colorPickerBackground = AceGUI:Create("ColorPicker")
    colorPickerBackground:SetHasAlpha(true)
    colorPickerBackground:SetLabel("Background colour")
    --colorPickerBackground:SetWidth(250)
    colorPickerBackground:SetColor(
        self.db.profile.background.color.r, 
        self.db.profile.background.color.g,
        self.db.profile.background.color.b,
        self.db.profile.background.color.a
    )
    colorPickerBackground:SetCallback("OnValueConfirmed", function(widget, event, r, g, b, a)
        self.db.profile.background.color.r = r
        self.db.profile.background.color.g = g
        self.db.profile.background.color.b = b
        self.db.profile.background.color.a = a
        ShowMyStatsAddon:UpdateStatFrameBackgroundTexture()
    end)
    colorPickerBackground:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
        self.db.profile.background.color.r = r
        self.db.profile.background.color.g = g
        self.db.profile.background.color.b = b
        self.db.profile.background.color.a = a
        ShowMyStatsAddon:UpdateStatFrameBackgroundTexture()
    end)
    frame:AddChild(colorPickerBackground)

    ----------------------- FONT CONFIGS
    local headingStats = AceGUI:Create("Heading")
    headingStats:SetWidth(500)
    headingStats:SetText("Font Configuration")
    frame:AddChild(headingStats)

    local sliderFontSize = AceGUI:Create("Slider")
    sliderFontSize:SetValue(self.db.profile.font.size)
    sliderFontSize:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.font.size = value
        self:UpdateStatFrame()
    end)
    sliderFontSize:SetSliderValues(4, 64, 1)
    sliderFontSize:SetLabel("Font Size")
    frame:AddChild(sliderFontSize)

    local dropdownFont = AceGUI:Create("Dropdown")
    dropdownFont:SetList(LSM:List(LSM.MediaType.FONT))
    dropdownFont:SetCallback("OnValueChanged", function(widget, event, key)
        self.db.profile.font.type = key
        self.font = LSM:Fetch(LSM.MediaType.FONT, LSM:List(LSM.MediaType.FONT)[self.db.profile.font.type])
        self:UpdateStatFrame()
    end)
    dropdownFont:SetValue(self.db.profile.font.type)
    dropdownFont:SetLabel("Font")
    frame:AddChild(dropdownFont)

    local dropdownAlignment = AceGUI:Create("Dropdown")
    dropdownAlignment:SetList({"Centered", "Left-Aligned", "Right-Aligned"})
    dropdownAlignment:SetCallback("OnValueChanged", function(widget, event, key)
        self.db.profile.font.alignment = key
        self.alignment = self.alignments[key]
        self:UpdateStatFrame()
    end)
    dropdownAlignment:SetValue(self.db.profile.font.alignment)
    dropdownAlignment:SetLabel("Alignment")
    frame:AddChild(dropdownAlignment)

    local dropdownOutline = AceGUI:Create("Dropdown")
    dropdownOutline:SetList({"Normal", "Thick", "Pixel-Font-Outline", "None"})
    dropdownOutline:SetCallback("OnValueChanged", function(widget, event, key)
        self.db.profile.font.outline = key
        self.outline = self.outlines[key]
        self:UpdateStatFrame()
    end)
    dropdownOutline:SetValue(self.db.profile.font.outline)
    dropdownOutline:SetLabel("Outline")
    frame:AddChild(dropdownOutline)

    ----------------------- STAT CONFIGS
    local headingStats = AceGUI:Create("Heading")
    headingStats:SetWidth(500)
    headingStats:SetText("Stat Configuration")
    frame:AddChild(headingStats)

    local scrollcontainer = AceGUI:Create("InlineGroup") -- best: SimpleGroup "InlineGroup" is also good
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetFullHeight(true) -- probably?
    scrollcontainer:SetLayout("Fill") -- important!
    frame:AddChild(scrollcontainer)
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow") -- probably?
    scrollcontainer:AddChild(scroll)



    for statIndex, statName in ipairs(self.db.profile.stats) do
        local checkbox = AceGUI:Create("CheckBox")
        checkbox:SetLabel(firstToUpper(statName) .. " enabled")
        checkbox:SetWidth(200)
        checkbox:SetValue(self.db.profile[statName].enabled)
        checkbox:SetCallback("OnValueChanged", function(widget, event, value)
            self.db.profile[statName].enabled = value
            self:UpdateStatFrame()
        end)
        scroll:AddChild(checkbox)

        local colorPicker = AceGUI:Create("ColorPicker")
        colorPicker:SetLabel(firstToUpper(statName) .. " colour")
        colorPicker:SetWidth(200)
        colorPicker:SetColor(
            self.db.profile[statName].color.r, 
            self.db.profile[statName].color.g,
            self.db.profile[statName].color.b,
            self.db.profile[statName].color.a
        )
        colorPicker:SetCallback("OnValueConfirmed", function(widget, event, r, g, b, a)
            self.db.profile[statName].color.r = r
            self.db.profile[statName].color.g = g
            self.db.profile[statName].color.b = b
            self.db.profile[statName].color.a = a
            ShowMyStatsAddon:UpdateStatFrame()
        end)
        colorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
            self.db.profile[statName].color.r = r
            self.db.profile[statName].color.g = g
            self.db.profile[statName].color.b = b
            self.db.profile[statName].color.a = a
            ShowMyStatsAddon:UpdateStatFrame()
        end)
        scroll:AddChild(colorPicker)

--[[    local buttonUp = AceGUI:Create("Button") -- alternative: Icon 
        buttonUp:SetWidth(80)
        buttonUp:SetText("Up")
        scroll:AddChild(buttonUp)

        local buttonDown = AceGUI:Create("Button")
        buttonDown:SetWidth(80)
        buttonDown:SetText("Down")
        scroll:AddChild(buttonDown) ]]

        iconSize = 20
        iconPadding = 2
        local iconUp = AceGUI:Create("Icon")
        
        iconUp:SetImageSize(iconSize, iconSize)
        iconUp:SetWidth(iconSize + iconPadding * 2)

        if statIndex ~= 1 then
            iconUp:SetImage(293773) -- FileDataID (newer method) or filePath (older one)
            iconUp:SetCallback("OnClick", function(widget, event, test)
                local tmp = self.db.profile.stats[statIndex]
                self.db.profile.stats[statIndex] = self.db.profile.stats[statIndex - 1]
                self.db.profile.stats[statIndex - 1] = tmp
                self.configFrameShown = false
                self.configFrame:Release()
                self:ShowConfigFrame()
                self:UpdateStatFrame()
            end)
        else
            iconUp:SetDisabled(true)
        end
        scroll:AddChild(iconUp)

        local iconDown = AceGUI:Create("Icon")
            
            iconDown:SetImageSize(iconSize, iconSize)
            iconDown:SetWidth(iconSize + iconPadding * 2)
        if statIndex ~= table.getn(self.db.profile.stats) then
            iconDown:SetImage(293770)
            iconDown:SetCallback("OnClick", function(widget, event, test)
                local tmp = self.db.profile.stats[statIndex]
                self.db.profile.stats[statIndex] = self.db.profile.stats[statIndex + 1]
                self.db.profile.stats[statIndex + 1] = tmp
                self.configFrameShown = false
                self.configFrame:Release()
                self:ShowConfigFrame()
                self:UpdateStatFrame()
            end)
        else
            iconDown:SetDisabled(true)
        end
        scroll:AddChild(iconDown)
    end
end

-- HOW TO HANDLE USER PROFILES AND WHAT KIND OF CONFIG TO REFRESH?
function ShowMyStatsAddon:RefreshConfig()
    --self:Print("refresh config")
end











--https://www.townlong-yak.com/framexml/live/PaperDollFrame.lua
local mainStatIndex = {
    strength = 1,
    agility = 2,
    stamina = 3,
    intellect = 4,
}
function ShowMyStatsAddon:GetMainStatInfo(mainStatName)
    local base, stat, posBuff, negBuff = UnitStat("player", mainStatIndex[mainStatName])
    return firstToUpper(mainStatName) .. ": " .. stat
end

function ShowMyStatsAddon:GetMasteryInfo()
    local masteryeffect, coefficient = GetMasteryEffect() -- mastery*coefficient=masteryeffect
    local mastery = GetMastery() -- pure value 
    return "Mastery: " .. string.format("%.0f%%", masteryeffect)
end

function ShowMyStatsAddon:GetCritInfo()
	local spellCrit, rangedCrit, meleeCrit;
	local critChance;
	-- Start at 2 to skip physical damage
	local holySchool = 2;
	local minCrit = GetSpellCritChance(holySchool);
	local spellCrit;
	for i=(holySchool+1), 7 do
		spellCrit = GetSpellCritChance(i);
		minCrit = min(minCrit, spellCrit);
	end
	spellCrit = minCrit
	rangedCrit = GetRangedCritChance();
	meleeCrit = GetCritChance();
	if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
		critChance = spellCrit;
	elseif (rangedCrit >= meleeCrit) then
		critChance = rangedCrit;
	else
		critChance = meleeCrit;
	end
    return "Crit: " .. string.format("%.0f%%", critChance)
end

function ShowMyStatsAddon:GetHasteInfo()
    local haste = GetHaste()
    return "Haste: " .. string.format("%.0f%%", haste)
end

function ShowMyStatsAddon:GetVersatilityInfo()
    local versatilityDamageBonus = GetCombatRatingBonus(29) + GetVersatilityBonus(29);
	local versatilityDamageTakenReduction = GetCombatRatingBonus(31) + GetVersatilityBonus(31);
    return string.format("Versatility: %.0f%%", versatilityDamageBonus)
end

function ShowMyStatsAddon:GetAbsorbInfo()
    local absorb = UnitGetTotalAbsorbs("player")
    return string.format("Absorb: %d", absorb)
end

function ShowMyStatsAddon:GetSpeedInfo()
    local currentSpeed, runningSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
    local maxSpeed = max(currentSpeed, runningSpeed, flightSpeed, swimSpeed)
    maxSpeed = maxSpeed - BASE_MOVEMENT_SPEED
    maxSpeed = (maxSpeed / 7) * 100
    return string.format("Speed: %.0f%%", maxSpeed)
end

function ShowMyStatsAddon:GetArmorInfo()
    local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
    local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel("player"));
    return string.format("Armor: %d (%.0f%%)", effectiveArmor, armorReduction)
end

function ShowMyStatsAddon:GetStaggerInfo()
    local stagger, staggerAgainstTarget = C_PaperDollInfo.GetStaggerPercentage("player");
    return string.format("Stagger: %.0f%%", stagger)
end

function ShowMyStatsAddon:GetDodgeInfo()
    local chance = GetDodgeChance()
    return string.format("Dodge: %.0f%%", chance)
end

function ShowMyStatsAddon:GetBlockInfo()
    local chance = GetBlockChance()
    return string.format("Block: %.0f%%", chance)
end

function ShowMyStatsAddon:GetParryInfo()
    local chance = GetParryChance()
    return string.format("Parry: %.0f%%", chance)
end

function ShowMyStatsAddon:GetManaRegenInfo()
	local base, combat = GetManaRegen();
	-- All mana regen stats are displayed as mana/5 sec.
	--base = floor(base * 5.0);
	--combat = floor(combat * 5.0);
    -- Combat mana regen is most important to the player, so we display it as the main value
    return string.format("Mana per second: %.0f", combat)
end

function ShowMyStatsAddon:GetLifeStealInfo()
    local lifesteal = GetLifesteal();
    return string.format("Lifesteal: %.0f%%", lifesteal)
end

function ShowMyStatsAddon:GetAvoidanceInfo()
    local avoidance = GetAvoidance();
    return string.format("Avoidance: %.0f%%", avoidance)
end

function ShowMyStatsAddon:GetStatInfo(statName)
    if statName == "strength" then
        return self:GetMainStatInfo("strength")
    elseif statName == "agility" then
        return self:GetMainStatInfo("agility")
    elseif statName == "stamina" then
        return self:GetMainStatInfo("stamina")
    elseif statName == "intellect" then
        return self:GetMainStatInfo("intellect")
    elseif statName == "mastery" then
        return self:GetMasteryInfo()
    elseif statName == "haste" then
        return self:GetHasteInfo()
    elseif statName == "crit" then
        return self:GetCritInfo()
    elseif statName == "versatility" then
        return self:GetVersatilityInfo()
    elseif statName == "absorb" then
        return self:GetAbsorbInfo()
    elseif statName == "speed" then
        return self:GetSpeedInfo()
    elseif statName == "armor" then
        return self:GetArmorInfo()
    elseif statName == "stagger" then
        return self:GetStaggerInfo()
    elseif statName == "dodge" then
        return self:GetDodgeInfo()
    elseif statName == "block" then
        return self:GetBlockInfo()
    elseif statName == "parry" then
        return self:GetParryInfo()
    elseif statName == "manaregen" then
        return self:GetManaRegenInfo()
    elseif statName == "lifesteal" then
        return self:GetLifeStealInfo()
    elseif statName == "avoidance" then
        return self:GetAvoidanceInfo()
    end
end



-- GetBlockChance()
-- GetCritChance() 
-- GetDodgeChance()
-- GetLifesteal()
-- GetManaRegen()
-- GetParryChance()
-- GetPowerRegen()
-- GetRangedCritChance()
-- GetShieldBlock()
-- GetUnitSpeed("unit")
-- UnitArmor("unit")
-- UnitDamage("unit")
-- UnitRangeDamage/RangePower/Range...































function ShowMyStatsAddon:UpdateHandler(event, arg1, arg2)
    ShowMyStatsAddon:ShowStatFrame()
end
function ShowMyStatsAddon:ShowStatFrame()
    if self.f == nil then
        self:ConstructStatFrame()
    end
    self:UpdateStatFrame()
end

function ShowMyStatsAddon:ConstructStatFrame()
    self.font = LSM:Fetch(LSM.MediaType.FONT, LSM:List(LSM.MediaType.FONT)[self.db.profile.font.type])
    self.f = CreateFrame("Frame",nil,UIParent);
    --self.f:SetMovable(true)
    --self.f:EnableMouse(true)
    --self.f:RegisterForDrag("LeftButton")
    --self.f:SetScript("OnDragStart", self.f.StartMoving)
    --self.f:SetScript("OnDragStop", self.f.StopMovingOrSizing)
    --------------------------------------------self.f:SetScript("OnReceiveDrag", self.Test)
    self.f:SetFrameStrata("BACKGROUND")
    local counter = 0
    for statIndex, statName in ipairs(self.db.profile.stats) do
        self.text[statIndex] = self.f:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        self.text[statIndex]:SetFont(self.font, self.db.profile.font.size, self.outline)
        self.text[statIndex]:SetPoint(self.alignment, 0, (counter) * (-self.db.profile.font.size))
        self.text[statIndex]:SetHeight(self.db.profile.font.size)
        --self.text[statIndex]:SetShadowColor(0,0,0)
        --self.text[statIndex]:SetShadowOffset(1,1)
        self.text[statIndex]:SetTextColor(
            self.db.profile[statName].color.r,
            self.db.profile[statName].color.g,
            self.db.profile[statName].color.b,
            self.db.profile[statName].color.a
        )
        if self.db.profile[statName].enabled then
            self.text[statIndex]:SetText(self:GetStatInfo(statName))
            counter = counter + 1
        else
            self.text[statIndex]:SetText("")
        end
        self.text[statIndex]:Show()
    end
    self.backgroundTexture = self.f:CreateTexture("ARTWORK");
    self.backgroundTexture:SetAllPoints();
    self.backgroundTexture:SetColorTexture(
        self.db.profile.background.color.r,
        self.db.profile.background.color.g,
        self.db.profile.background.color.b
    ); 
    self.backgroundTexture:SetAlpha(self.db.profile.background.color.a);
    self:MoveStatFrame()
    self.f:Show()
end

function ShowMyStatsAddon:UpdateStatFrame()
    local widestText = 0
    local counter = 0
    for statIndex, statName in ipairs(self.db.profile.stats) do
        self.text[statIndex]:SetFont(self.font, self.db.profile.font.size, self.outline)
        self.text[statIndex]:ClearAllPoints()
        self.text[statIndex]:SetPoint(self.alignment, 0, (counter) * (-self.db.profile.font.size))
        self.text[statIndex]:SetHeight(self.db.profile.font.size)
        self.text[statIndex]:SetTextColor(
            self.db.profile[statName].color.r,
            self.db.profile[statName].color.g,
            self.db.profile[statName].color.b,
            self.db.profile[statName].color.a
        )
        if self.db.profile[statName].enabled then
            local text = self:GetStatInfo(statName)
            self.text[statIndex]:SetText(text)
            local stringWidth = self.text[statIndex]:GetStringWidth()
            if stringWidth > widestText then
                widestText = stringWidth
            end
            counter = counter + 1
        else
            self.text[statIndex]:SetText("")
        end
    end

    self:ResizeStatFrame(widestText + 0, counter * self.db.profile.font.size + 0)
end

function ShowMyStatsAddon:MoveStatFrame()
    self.f:ClearAllPoints()
    self.f:SetPoint(
        self.db.profile.position.anchor,
        self.db.profile.position.x,
        self.db.profile.position.y
    )
end

function ShowMyStatsAddon:ResizeStatFrame(width, height)
    self.f:SetWidth(width)
    self.f:SetHeight(height)
end

function ShowMyStatsAddon:UpdateStatFrameBackgroundTexture()
    self.backgroundTexture:SetColorTexture(
        self.db.profile.background.color.r,
        self.db.profile.background.color.g,
        self.db.profile.background.color.b
    ); 
    self.backgroundTexture:SetAlpha(self.db.profile.background.color.a);
end










-- HELPER FUNCTIONS

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end