if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Vault.Razageth == nil then AZP.BossTools.Vault.Razageth = {} end
if AZP.BossTools.Vault.Razageth.Events == nil then AZP.BossTools.Vault.Razageth.Events = {} end

local AZPBTRazIDs = {DebuffMin = 394579, DebuffPlus = 394576}

local EventFrame = nil

function AZP.BossTools.Vault.Razageth:OnLoad()
    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("ENCOUNTER_END")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Vault.Razageth:OnEvent(...) end)

    AZP.BossTools.Vault.Razageth:CreateMainFrame()
end

function AZP.BossTools.Vault.Razageth:CreateMainFrame()
    AZP.BossTools.BossFrames.Razageth = CreateFrame("FRAME", nil, UIParent)
    AZP.BossTools.BossFrames.Razageth:SetSize(150, 75)
    AZP.BossTools.BossFrames.Razageth:SetPoint("TOP", 0, -200)
    -- AZP.BossTools.BossFrames.Razageth:EnableMouse(true)
    -- AZP.BossTools.BossFrames.Razageth:SetMovable(true)
    -- AZP.BossTools.BossFrames.Razageth:RegisterForDrag("LeftButton")
    -- AZP.BossTools.BossFrames.Razageth:SetScript("OnDragStart", AZP.BossTools.BossFrames.Razageth.StartMoving)
    -- AZP.BossTools.BossFrames.Razageth:SetScript("OnDragStop", function() AZP.BossTools.BossFrames.Razageth:StopMovingOrSizing() end)

    AZP.BossTools.BossFrames.Razageth.Icon = AZP.BossTools.BossFrames.Razageth:CreateTexture(nil, "ARTWORK")
    AZP.BossTools.BossFrames.Razageth.Icon:SetSize(75, 75)
    AZP.BossTools.BossFrames.Razageth.Icon:SetPoint("LEFT", 0, 0)
    AZP.BossTools.BossFrames.Razageth.Icon:SetTexture(394579)

    AZP.BossTools.BossFrames.Razageth.Marker = AZP.BossTools.BossFrames.Razageth:CreateTexture(nil, "ARTWORK")
    AZP.BossTools.BossFrames.Razageth.Marker:SetSize(75, 75)
    AZP.BossTools.BossFrames.Razageth.Marker:SetPoint("LEFT", AZP.BossTools.BossFrames.Razageth.Icon, "RIGHT", 5, 0)
    AZP.BossTools.BossFrames.Razageth.Marker:SetTexture(394581)

    AZP.BossTools.BossFrames.Razageth.Icon:Hide()
    AZP.BossTools.BossFrames.Razageth.Marker:Hide()
end

function AZP.BossTools.Vault.Razageth:CompareIDs(curID)
    if curID == AZPBTRazIDs.DebuffMin then
        AZP.BossTools.BossFrames.Razageth.Icon:Show()
        AZP.BossTools.BossFrames.Razageth.Marker:Show()
        AZP.BossTools.BossFrames.Razageth.Icon:SetTexture(135768)
        AZP.BossTools.BossFrames.Razageth.Marker:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_7")
        C_Timer.After(10, function() AZP.BossTools.BossFrames.Razageth.Icon:Hide() AZP.BossTools.BossFrames.Razageth.Marker:Hide() end)
    elseif curID == AZPBTRazIDs.DebuffPlus then
        AZP.BossTools.BossFrames.Razageth.Icon:Show()
        AZP.BossTools.BossFrames.Razageth.Marker:Show()
        AZP.BossTools.BossFrames.Razageth.Icon:SetTexture(135769)
        AZP.BossTools.BossFrames.Razageth.Marker:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_6")
        C_Timer.After(10, function() AZP.BossTools.BossFrames.Razageth.Icon:Hide() AZP.BossTools.BossFrames.Razageth.Marker:Hide() end)
    end
end

function AZP.BossTools.Vault.Razageth.Events:CombatLogEventUnfiltered(...)
    local _, combatEvent, _, _, _, _, _, DestGUIUD, _, _, _, spellID = CombatLogGetCurrentEventInfo()
    if combatEvent == "SPELL_AURA_APPLIED" then
        if DestGUIUD == UnitGUID("PLAYER") then
            AZP.BossTools.Vault.Razageth:CompareIDs(spellID)
        end
    end
end

function AZP.BossTools.Vault.Razageth:OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        AZP.BossTools.Vault.Razageth.Events:CombatLogEventUnfiltered(...)
    end
end

AZP.BossTools.Vault.Razageth:OnLoad()