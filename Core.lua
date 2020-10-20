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
        mastery = {
            enabled = true,
        },
        versatility = {
            enabled = true,
        },
        ['**'] = {
            enabled = true,
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
    "spellHaste",
    "spellCrit",
    "versatility",
    "absorb",
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












function ShowMyStatsAddon:GetAllInfos()
    return 
    ShowMyStatsAddon:GetMainStatInfo("strength") .. "\n" .. 
    ShowMyStatsAddon:GetMainStatInfo("agility") .. "\n" .. 
    ShowMyStatsAddon:GetMainStatInfo("stamina") .. "\n" .. 
    ShowMyStatsAddon:GetMainStatInfo("intellect") .. "\n" .. 
    ShowMyStatsAddon:GetMasteryInfo() .. "\n" .. 
    ShowMyStatsAddon:GetSpellCritInfo() .. "\n" .. 
    ShowMyStatsAddon:GetSpellHasteInfo() .. "\n" .. 
    ShowMyStatsAddon:GetVersatilityInfo() .. "\n" .. 
    ShowMyStatsAddon:GetAbsorbInfo()
end

local mainStatIndex = {
    strength = 1,
    agility = 2,
    stamina = 3,
    intellect = 4,
}
function ShowMyStatsAddon:GetMainStatInfo(mainStatName)
    if self.db.profile[mainStatName].enabled == false then
        return ""
    end
    base, stat, posBuff, negBuff = UnitStat("player", mainStatIndex[mainStatName])
    return mainStatName .. ": " .. stat
end

function ShowMyStatsAddon:GetMasteryInfo()
    if self.db.profile.mastery.enabled == false then
        return ""
    end
    masteryeffect, coefficient = GetMasteryEffect() -- mastery*coefficient=masteryeffect
    mastery = GetMastery() -- pure value 
    return "Mastery: " .. string.format("%.2f", masteryeffect)
end

function ShowMyStatsAddon:GetSpellCritInfo()
    if self.db.profile.spellCrit.enabled == false then
        return ""
    end
    shadowSpellCrit = GetSpellCritChance(6)
    return "SpellCrit: " .. string.format("%.2f", shadowSpellCrit)
end

function ShowMyStatsAddon:GetSpellHasteInfo()
    if self.db.profile.spellHaste.enabled == false then
        return ""
    end
    spellHastePercent  = UnitSpellHaste("player")
    return "Spell Haste: " .. string.format("%.2f", spellHastePercent)
end

function ShowMyStatsAddon:GetVersatilityInfo()
    if self.db.profile.versatility.enabled == false then
        return ""
    end
    ratio = 0.082
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
    return "Versatility: " .. string.format("%.2f", versa)
end

function ShowMyStatsAddon:GetAbsorbInfo()
    if self.db.profile.absorb.enabled == false then
        return ""
    end
    local absorb = UnitGetTotalAbsorbs("player")
    return "Absorb: " .. absorb
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
    elseif statName == "spellHaste" then
        return self:GetSpellHasteInfo()
    elseif statName == "spellCrit" then
        return self:GetSpellCritInfo()
    elseif statName == "versatility" then
        return self:GetVersatilityInfo()
    elseif statName == "absorb" then
        return self:GetAbsorbInfo()
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
    self.f:SetWidth(150) -- Set these to whatever height/width is needed 
    self.f:SetHeight(200) -- for your Texture
    --self.text = self.f:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    --self.text:SetTextColor(0.5, 1, 0.2, 0.5)
    --self.text:SetPoint("CENTER", 0, 0)
    --self.text:Show()
    local counter = 0
    for statIndex, statName in ipairs(stats) do
        self.text[statIndex] = self.f:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        self.text[statIndex]:SetPoint("TOP", 0, (counter) * (-16))
        self.text[statIndex]:SetWidth(150)
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
    --local tex = self.f:CreateTexture("ARTWORK");
    --tex:SetAllPoints();
    --tex:SetTexture(1.0, 0.5, 0); tex:SetAlpha(0.5);
    self:MoveStatFrame()
    self.f:Show()
end
function ShowMyStatsAddon:UpdateStatFrame()
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
            self.text[statIndex]:SetText(self:GetStatInfo(statName))
            counter = counter + 1
        else
            self.text[statIndex]:SetText("")
        end
    end
end
function ShowMyStatsAddon:MoveStatFrame()
    self.f:ClearAllPoints()
    self.f:SetPoint(
        self.db.profile.position.anchor,
        self.db.profile.position.x,
        self.db.profile.position.y
    )
end