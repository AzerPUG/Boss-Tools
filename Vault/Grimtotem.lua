if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Vault.Grimtotem == nil then AZP.BossTools.Vault.Grimtotem = {} end
if AZP.BossTools.Vault.Grimtotem.Events == nil then AZP.BossTools.Vault.Grimtotem.Events = {} end

local AZPBTGrimIDs = {DebuffFire = 374023}

local EventFrame = nil

function AZP.BossTools.Vault.Grimtotem:OnLoad()
    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:RegisterEvent("ENCOUNTER_END")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Vault.Grimtotem:OnEvent(...) end)

    AZP.BossTools.Vault.Grimtotem:CreateMainFrame()
end

function AZP.BossTools.Vault.Grimtotem:CreateMainFrame()
    AZP.BossTools.BossFrames.Grimtotem = CreateFrame("FRAME", nil, UIParent)
    AZP.BossTools.BossFrames.Grimtotem:SetSize(150, 75)
    AZP.BossTools.BossFrames.Grimtotem:SetPoint("TOP", 0, -200)
    AZP.BossTools.BossFrames.Grimtotem:EnableMouse(true)
    AZP.BossTools.BossFrames.Grimtotem:SetMovable(true)
    AZP.BossTools.BossFrames.Grimtotem:RegisterForDrag("LeftButton")
    AZP.BossTools.BossFrames.Grimtotem:SetScript("OnDragStart", AZP.BossTools.BossFrames.Grimtotem.StartMoving)
    AZP.BossTools.BossFrames.Grimtotem:SetScript("OnDragStop", function() AZP.BossTools.BossFrames.Grimtotem:StopMovingOrSizing() end)

    AZP.BossTools.BossFrames.Grimtotem.Icon = AZP.BossTools.BossFrames.Grimtotem:CreateTexture(nil, "ARTWORK")
    AZP.BossTools.BossFrames.Grimtotem.Icon:SetSize(75, 75)
    AZP.BossTools.BossFrames.Grimtotem.Icon:SetPoint("TOP", 0, 0)
    AZP.BossTools.BossFrames.Grimtotem.Icon:SetTexture("Interface/ICONS/spell_fire_moltenblood")

    AZP.BossTools.BossFrames.Grimtotem.MarkerL = AZP.BossTools.BossFrames.Grimtotem:CreateTexture(nil, "ARTWORK")
    AZP.BossTools.BossFrames.Grimtotem.MarkerL:SetSize(75, 75)
    AZP.BossTools.BossFrames.Grimtotem.MarkerL:SetPoint("RIGHT", AZP.BossTools.BossFrames.Grimtotem.Icon, "LEFT", 5, 0)
    AZP.BossTools.BossFrames.Grimtotem.MarkerL:SetTexture(394581)
    AZP.BossTools.BossFrames.Grimtotem.MarkerL:SetTexture("Interface/BUTTONS/UI-MicroStream-Red")
    AZP.BossTools.BossFrames.Grimtotem.MarkerL:SetRotation(-1.5708)

    AZP.BossTools.BossFrames.Grimtotem.MarkerR = AZP.BossTools.BossFrames.Grimtotem:CreateTexture(nil, "ARTWORK")
    AZP.BossTools.BossFrames.Grimtotem.MarkerR:SetSize(75, 75)
    AZP.BossTools.BossFrames.Grimtotem.MarkerR:SetPoint("LEFT", AZP.BossTools.BossFrames.Grimtotem.Icon, "RIGHT", -5, 0)
    AZP.BossTools.BossFrames.Grimtotem.MarkerR:SetTexture(394581)
    AZP.BossTools.BossFrames.Grimtotem.MarkerR:SetTexture("Interface/BUTTONS/UI-MicroStream-Green")
    AZP.BossTools.BossFrames.Grimtotem.MarkerR:SetRotation(1.5708)

    AZP.BossTools.BossFrames.Grimtotem.Text = AZP.BossTools.BossFrames.Grimtotem:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    AZP.BossTools.BossFrames.Grimtotem.Text:SetPoint("TOP", AZP.BossTools.BossFrames.Grimtotem.Icon, "BOTTOM", 0, -5)
    AZP.BossTools.BossFrames.Grimtotem.Text:SetText("Grimtotem")

    AZP.BossTools.BossFrames.Grimtotem.MarkerL:Hide()
    AZP.BossTools.BossFrames.Grimtotem.Icon:Hide()
    AZP.BossTools.BossFrames.Grimtotem.MarkerR:Hide()
    AZP.BossTools.BossFrames.Grimtotem.Text:Hide()
end

function AZP.BossTools.Vault.Grimtotem:CompareIDs()
    local fireBuffPresent = false
    for i = 1, 40 do
        local _, _, _, _, _, _, _, _, _, spellID = UnitDebuff("player", i)
        if spellID == AZPBTGrimIDs.DebuffFire then
            fireBuffPresent = true
        end
    end

    AZP.BossTools.BossFrames.Grimtotem.Icon:Show()
    AZP.BossTools.BossFrames.Grimtotem.Text:Show()

    if fireBuffPresent == true then
        AZP.BossTools.BossFrames.Grimtotem.Icon:SetTexture("Interface/ICONS/spell_fire_moltenblood")
        AZP.BossTools.BossFrames.Grimtotem.MarkerL:Show()
        AZP.BossTools.BossFrames.Grimtotem.Text:SetText("LEFT")
        AZP.BossTools.BossFrames.Grimtotem.Text:SetTextColor(1, 0, 0)
        C_Timer.After(10, function() AZP.BossTools.BossFrames.Grimtotem.MarkerL:Hide() AZP.BossTools.BossFrames.Grimtotem.Icon:Hide() AZP.BossTools.BossFrames.Grimtotem.Text:Hide() end)
    else
        AZP.BossTools.BossFrames.Grimtotem.Icon:SetTexture("Interface/ICONS/spell_fire_moltenblood")
        AZP.BossTools.BossFrames.Grimtotem.MarkerR:Show()
        AZP.BossTools.BossFrames.Grimtotem.Text:SetText("RIGHT")
        AZP.BossTools.BossFrames.Grimtotem.Text:SetTextColor(0, 1, 0)
        C_Timer.After(10, function() AZP.BossTools.BossFrames.Grimtotem.Icon:Hide() AZP.BossTools.BossFrames.Grimtotem.MarkerR:Hide() AZP.BossTools.BossFrames.Grimtotem.Text:Hide() end)
    end
end

function AZP.BossTools.Vault.Grimtotem.Events:CombatLogEventUnfiltered(...)
    local _, combatEvent, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
    if combatEvent == "SPELL_AURA_APPLIED" then
        if spellID == AZPBTGrimIDs.DebuffFire then
            AZP.BossTools.Vault.Grimtotem:CompareIDs()
        end
    end
end

function AZP.BossTools.Vault.Grimtotem:OnEvent(_, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        AZP.BossTools.Vault.Grimtotem.Events:CombatLogEventUnfiltered(...)
    end
end

AZP.BossTools.Vault.Grimtotem:OnLoad()