local ShowMyStatsAddon = LibStub("AceAddon-3.0"):NewAddon("ShowMyStats", "AceConsole-3.0", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local defaults = {
    profile = {
        position = {
            x = 0,
            y = 0,
            anchor = 'CENTER',
        },
        mastery = {
            enabled = true,
        },
        spellHaste = {
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
    "mastery",
    "spellHaste",
    "spellCrit",
    "versatility",
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
    frame:SetLayout("List") -- List/FLow/Fill
    
    local heading = AceGUI:Create("Heading")
    heading:SetWidth(500)
    heading:SetText("Please check all stats that you want to be shown.")
    frame:AddChild(heading)

    for statIndex, statName in ipairs(stats) do
        local checkbox = AceGUI:Create("CheckBox")
        checkbox:SetLabel(statName .. " enabled")
        checkbox:SetWidth(250)
        checkbox:SetValue(self.db.profile[statName].enabled)
        checkbox:SetCallback("OnValueChanged", function(widget, event, value)
            --self:RefreshConfig()
            self.db.profile[statName].enabled = value
            self:Print(string.format("Changed %s to %s", statName, tostring(value)))
        end)
        frame:AddChild(checkbox)

        local colorPicker = AceGUI:Create("ColorPicker")
        colorPicker:SetLabel(statName .. " color")
        colorPicker:SetWidth(250)
        colorPicker:SetColor(
            self.db.profile[statName].color.r, 
            self.db.profile[statName].color.g,
            self.db.profile[statName].color.b,
            self.db.profile[statName].color.a
        )
        colorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
            self.db.profile[statName].color.r = r
            self.db.profile[statName].color.g = g
            self.db.profile[statName].color.b = b
            self.db.profile[statName].color.a = a
        end)
        frame:AddChild(colorPicker)
    end
end

-- HOW TO HANDLE USER PROFILES AND WHAT KIND OF CONFIG TO REFRESH?
function ShowMyStatsAddon:RefreshConfig()
    self:Print("refresh config")
end












function getAllInfos()
    return getMasteryInfo() .. "\n" .. getSpellCritInfo() .. "\n" .. getHasteInfo() .. "\n" .. getVersatilityInfo() .. "\n" .. getAbsorbInfo()
end

function getMasteryInfo()
    masteryeffect, coefficient = GetMasteryEffect() -- mastery*coefficient=masteryeffect
    mastery = GetMastery() -- pure value 
    return "Mastery: " .. string.format("%.2f", masteryeffect)
end

function getSpellCritInfo()
    shadowSpellCrit = GetSpellCritChance(6)
    return "SpellCrit: " .. string.format("%.2f", shadowSpellCrit)
end

function getHasteInfo()
    spellHastePercent  = UnitSpellHaste("player")
    return "Haste: " .. string.format("%.2f", spellHastePercent)
end

function getVersatilityInfo()
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

function getAbsorbInfo()
    local absorb = UnitGetTotalAbsorbs("player")
    return "Absorb: " .. absorb
end

function ShowMyStatsAddon:ShowStatFrame()
    if self.f == nil then
        self.f = CreateFrame("Frame",nil,UIParent);
        self.f:SetFrameStrata("BACKGROUND")
        self.f:SetWidth(128) -- Set these to whatever height/width is needed 
        self.f:SetHeight(64) -- for your Texture
        self.text = self.f:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        self.text:SetPoint("CENTER", 0, 0)
        self.text:Show()
        self.f:SetPoint("CENTER",-200,300)
        self.f:Show()
    end
    self.text:SetText(getAllInfos())
end
ShowMyStatsAddon:ShowStatFrame()




































function ShowMyStatsAddon:UpdateHandler()
    ShowMyStatsAddon:ShowStatFrame()
end
ShowMyStatsAddon:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateHandler")
ShowMyStatsAddon:RegisterEvent("UNIT_AURA", "UpdateHandler")
ShowMyStatsAddon:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "UpdateHandler")
ShowMyStatsAddon:RegisterEvent("UNIT_INVENTORY_CHANGED", "UpdateHandler")
ShowMyStatsAddon:RegisterEvent("UNIT_LEVEL", "UpdateHandler")
ShowMyStatsAddon:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateHandler")
ShowMyStatsAddon:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateHandler")
ShowMyStatsAddon:RegisterEvent("PLAYER_TALENT_UPDATE", "UpdateHandler")