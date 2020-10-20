local ShowMyStatsAddon = LibStub("AceAddon-3.0"):NewAddon("ShowMyStats", "AceConsole-3.0", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local defaults = {
    profile = {
        orientation = {
            vertical = "DOWN",
            --horizontal = "RIGHT"
        },
        position = {
            x = -150,
            y = -250,
            anchor = 'TOP',
        },
        haste = {
            enabled = true,
        },
        crit = {
            enabled = true,
        },
        mastery = {
            enabled = true,
        },
        versatility = {
            enabled = true,
        },
        ['**'] = {
            enabled = false,
            color = {
                r = 255,
                g = 255,
                b = 255,
                a = 1,
            },
        },
    }
}
local stats = {
    "strength",
    "agility",
    "stamina",
    "intellect",
    "mastery",
    "haste",
    "crit",
    "versatility",
    "absorb",
    "armor",
    "speed"
}
local options = {
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

function ShowMyStatsAddon:OnInitialize()
    -- Code that you want to run when the addon is first loaded goes here.
    self:Print("Hello World!")
    self.db = LibStub("AceDB-3.0"):New("ShowMyStatsDB", defaults)
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    self.configFrameShown = false
    self.text = {}

    self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateHandler")
    self:RegisterEvent("UNIT_AURA", "UpdateHandler")
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "UpdateHandler")
    self:RegisterEvent("UNIT_INVENTORY_CHANGED", "UpdateHandler")
    self:RegisterEvent("UNIT_LEVEL", "UpdateHandler")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateHandler")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateHandler")
    self:RegisterEvent("PLAYER_TALENT_UPDATE", "UpdateHandler")
end

function ShowMyStatsAddon:OnEnable()
    -- Called when the addon is enabled
end

function ShowMyStatsAddon:OnDisable()
    -- Called when the addon is disabled
end





function ShowMyStatsAddon:GetMyMessage(info)
    return myMessageVar
end
function ShowMyStatsAddon:SetMyMessage(info, input)
    myMessageVar = input
end
LibStub("AceConfig-3.0"):RegisterOptionsTable("ShowMyStats", options, {"sms", "showmystats"})




ShowMyStatsAddon:RegisterChatCommand("sms", "ShowConfigFrame")
ShowMyStatsAddon:RegisterChatCommand("showmystats", "ShowConfigFrame")
function ShowMyStatsAddon:ShowConfigFrame()
    if self.configFrameShown then
        return
    end
    self.configFrameShown = true

    local frame = AceGUI:Create("Frame")
    frame:SetTitle("ShowMyStats")
    frame:SetStatusText("ShowMyStats Configuration Panel")
    frame:SetCallback("OnClose", function(widget) 
        self.configFrameShown = false
        AceGUI:Release(widget) 
    end)
    frame:SetLayout("Flow") -- List/FLow/Fill

    local headingPosition = AceGUI:Create("Heading")
    headingPosition:SetWidth(500)
    headingPosition:SetText("Please choose the desired position of the stat frame.")
    frame:AddChild(headingPosition)

    local sliderX = AceGUI:Create("Slider")
    sliderX:SetValue(self.db.profile.position.x)
    sliderX:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.position.x = value
        self:MoveStatFrame()
    end)
    sliderX:SetSliderValues(-1000, 1000, 1)
    sliderX:SetLabel("x-Axis")
    frame:AddChild(sliderX)

    local sliderY = AceGUI:Create("Slider")
    sliderY:SetValue(self.db.profile.position.y)
    sliderY:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.profile.position.y = value
        self:MoveStatFrame()
    end)
    sliderY:SetSliderValues(-1000, 1000, 1)
    sliderY:SetLabel("y-Axis")
    frame:AddChild(sliderY)

    local dropdownAnchor = AceGUI:Create("Dropdown")
    dropdownAnchor:SetWidth(250)
    dropdownAnchor:SetList({
        TOP = "top",
        RIGHT = "right",
        BOTTOM = "bottom",
        LEFT = "left",
        TOPRIGHT = "top right",
        TOPLEFT = "top left",
        BOTTOMLEFT = "bottom left",
        BOTTOMRIGHT = "bottom right",
        CENTER = "center"
    })
    dropdownAnchor:SetCallback("OnValueChanged", function(widget, event, key)
        self.db.profile.position.anchor = key
        self:MoveStatFrame()
    end)
    dropdownAnchor:SetValue(self.db.profile.position.anchor)
    dropdownAnchor:SetLabel("Anchor")
    frame:AddChild(dropdownAnchor)

    ----------------------- STAT CONFIGS
    local headingStats = AceGUI:Create("Heading")
    headingStats:SetWidth(500)
    headingStats:SetText("Please check all stats that you want to be shown.")
    frame:AddChild(headingStats)

    local scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetFullHeight(true) -- probably?
    scrollcontainer:SetLayout("Fill") -- important!
    frame:AddChild(scrollcontainer)
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow") -- probably?
    scrollcontainer:AddChild(scroll)



    for statIndex, statName in ipairs(stats) do
        local checkbox = AceGUI:Create("CheckBox")
        checkbox:SetLabel(statName .. " enabled")
        checkbox:SetWidth(250)
        checkbox:SetValue(self.db.profile[statName].enabled)
        checkbox:SetCallback("OnValueChanged", function(widget, event, value)
            self.db.profile[statName].enabled = value
            self:UpdateStatFrame()
        end)
        scroll:AddChild(checkbox)

        local colorPicker = AceGUI:Create("ColorPicker")
        colorPicker:SetLabel(statName .. " color")
        colorPicker:SetWidth(250)
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
    end
end

-- HOW TO HANDLE USER PROFILES AND WHAT KIND OF CONFIG TO REFRESH?
function ShowMyStatsAddon:RefreshConfig()
    self:Print("refresh config")
end











local mainStatIndex = {
    strength = 1,
    agility = 2,
    stamina = 3,
    intellect = 4,
}
function ShowMyStatsAddon:GetMainStatInfo(mainStatName)
    base, stat, posBuff, negBuff = UnitStat("player", mainStatIndex[mainStatName])
    return mainStatName .. ": " .. stat
end

function ShowMyStatsAddon:GetMasteryInfo()
    masteryeffect, coefficient = GetMasteryEffect() -- mastery*coefficient=masteryeffect
    mastery = GetMastery() -- pure value 
    return "Mastery: " .. string.format("%.0f%%", masteryeffect)
end

function ShowMyStatsAddon:GetCritInfo()
    shadowSpellCrit = GetSpellCritChance(6)
    return "SpellCrit: " .. string.format("%.0f%%", shadowSpellCrit)
end

function ShowMyStatsAddon:GetHasteInfo()
    spellHastePercent  = UnitSpellHaste("player")
    return "Spell Haste: " .. string.format("%.0f%%", spellHastePercent)
end

function ShowMyStatsAddon:GetVersatilityInfo()
    ratio = 0.082 -- only for lv50!!! TODO: calculate dynamically
    versaStat = GetCombatRating(29)
    versa = 0
    for i=1, versaStat, 1 do
        if versa < 25 then
            versa = versa + ratio
        elseif versa < 34 then
            versa = versa + ratio * 0.9
        elseif versa < 42 then
            versa = versa + ratio * 0.8
        elseif versa < 49 then
            versa = versa + ratio * 0.7
        elseif versa < 106 then
            versa = versa + ratio * 0.6
        end
    end
    return "Versatility: " .. string.format("%.0f%%", versa)
end

function ShowMyStatsAddon:GetAbsorbInfo()
    local absorb = UnitGetTotalAbsorbs("player")
    return "Absorb: " .. absorb
end

function ShowMyStatsAddon:GetSpeedInfo()
    currentSpeed, runningSpeed = GetUnitSpeed("player")
    return string.format("Speed: %d%%", (runningSpeed / 7) * 100)
end

function ShowMyStatsAddon:GetArmorInfo()
    base, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
    return string.format("Armor: %d", effectiveArmor)
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































function ShowMyStatsAddon:UpdateHandler()
    ShowMyStatsAddon:ShowStatFrame()
end
function ShowMyStatsAddon:ShowStatFrame()
    if self.f == nil then
        self:ConstructStatFrame()
    end
    self:UpdateStatFrame()
end
function ShowMyStatsAddon:ConstructStatFrame()
    self.f = CreateFrame("Frame",nil,UIParent);
    --self.f:SetMovable(true)
    --self.f:EnableMouse(true)
    --self.f:RegisterForDrag("LeftButton")
    --self.f:SetScript("OnDragStart", self.f.StartMoving)
    --self.f:SetScript("OnDragStop", self.f.StopMovingOrSizing)
    --------------------------------------------self.f:SetScript("OnReceiveDrag", self.Test)
    self.f:SetFrameStrata("BACKGROUND")
    local counter = 0
    for statIndex, statName in ipairs(stats) do
        self.text[statIndex] = self.f:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        self.text[statIndex]:SetPoint("TOP", 0, (counter) * (-16))
        --self.text[statIndex]:SetWidth(150)
        self.text[statIndex]:SetHeight(16)
        self.text[statIndex]:SetShadowColor(0,0,0)
        self.text[statIndex]:SetShadowOffset(2,2)
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
    local tex = self.f:CreateTexture("ARTWORK");
    tex:SetAllPoints();
    tex:SetColorTexture(0,0,0); tex:SetAlpha(0.10);
    self:MoveStatFrame()
    self.f:Show()
end
function ShowMyStatsAddon:UpdateStatFrame()
    local widestText = 0
    local counter = 0
    for statIndex, statName in ipairs(stats) do
        self.text[statIndex]:SetPoint("TOP", 0, (counter) * (-16))
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

    self:ResizeStatFrame(widestText, counter * 16)
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
