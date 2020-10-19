-- TODO: ace 3 addon lib nutzen


local f = CreateFrame("Frame",nil,UIParent)
f:SetFrameStrata("BACKGROUND")
f:SetWidth(128) -- Set these to whatever height/width is needed 
f:SetHeight(64) -- for your Texture

--local t = f:CreateTexture(nil,"BACKGROUND")
--t:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp")
--t:SetAllPoints(f)
--f.texture = t

local text = f:CreateFontString(nil, "OVERLAY", "GameTooltipText")
--text:SetText(getAllInfos())
text:SetPoint("CENTER", 0, 0)
text:Show()

f:SetPoint("CENTER",-200,300)
f:Show()

local name, addon = ...

local ShowMyStats_EventFrame = CreateFrame("Frame")




ShowMyStats_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
ShowMyStats_EventFrame:RegisterEvent("UNIT_AURA", "OnEvent")
ShowMyStats_EventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "OnEvent")
ShowMyStats_EventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED", "OnEvent")
ShowMyStats_EventFrame:RegisterEvent("UNIT_LEVEL", "OnEvent")
ShowMyStats_EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
ShowMyStats_EventFrame:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
ShowMyStats_EventFrame:RegisterEvent("PLAYER_TALENT_UPDATE", "OnEvent")

ShowMyStats_EventFrame:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
ShowMyStats_EventFrame:RegisterEvent("PLAYER_TOTEM_UPDATE")
ShowMyStats_EventFrame:SetScript("OnEvent",
    function(self, event, ...)
        if event == "PLAYER_PVP_KILLS_CHANGED" then
            unitTarget = ...;
            -- UnitName(unitTarget);
        else
            text:SetText(getAllInfos())
        end
    end)
    
SLASH_SHOWMYSTATS1 = "/sms";
SLASH_SHOWMYSTATS2 = "/showmystats";
function SlashCmdList.SHOWMYSTATS(arg1)
    print("NOT IMPLEMENTED! :(")
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