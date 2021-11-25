if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.KelThuzad == nil then AZP.BossTools.KelThuzad = {} end
if AZP.BossTools.KelThuzad.Events == nil then AZP.BossTools.KelThuzad.Events = {} end

local AssignedPlayers = {}

------------------------------------------------------------
------------------- Adjustable Variables -------------------
------------------------------------------------------------
local phaseTime = 45
local buffID = 348787
local manual = true
local percStrings =
{
    [1] = "100 - 60",
    [2] =  "60 - 20",
    [3] =  "20 -  0",
}
------------------------------------------------------------

local phaseCounter = 0
local curTimer = 0

local KelThuzadFrame, KelThuzadOptions, EventFrame = nil, nil, nil

function AZP.BossTools.KelThuzad:OnLoad()
    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:RegisterEvent("ENCOUNTER_END")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.KelThuzad:OnEvent(...) end)

    AZP.BossTools.KelThuzad:CreateKelThuzadFrame()
end

function AZP.BossTools.KelThuzad:CreateKelThuzadFrame()
    KelThuzadFrame = CreateFrame("FRAME", nil, UIPanel, "BackdropTemplate")
    AZP.BossTools.BossFrames.KelThuzad = KelThuzadFrame
    KelThuzadFrame:SetSize(150, 75)
    KelThuzadFrame:SetPoint("TOPLEFT", 100, -200)
    KelThuzadFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    KelThuzadFrame:EnableMouse(true)
    KelThuzadFrame:SetMovable(true)
    KelThuzadFrame:RegisterForDrag("LeftButton")
    KelThuzadFrame:SetScript("OnDragStart", KelThuzadFrame.StartMoving)
    KelThuzadFrame:SetScript("OnDragStop", function() KelThuzadFrame:StopMovingOrSizing() end)

    KelThuzadFrame.Header = KelThuzadFrame:CreateFontString("KelThuzadFrame", "ARTWORK", "GameFontNormalHuge")
    KelThuzadFrame.Header:SetSize(KelThuzadFrame:GetWidth(), 25)
    KelThuzadFrame.Header:SetPoint("TOP", 0, -2)
    KelThuzadFrame.Header:SetText("Kel'Thuzad")

    KelThuzadFrame.SubHeader = KelThuzadFrame:CreateFontString("UpdateFrame", "ARTWORK", "GameFontNormalLarge")
    KelThuzadFrame.SubHeader:SetSize(150, 35)
    KelThuzadFrame.SubHeader:SetPoint("TOP", 0, -15)
    KelThuzadFrame.SubHeader:SetText("-")

    KelThuzadFrame.timer = KelThuzadFrame:CreateFontString("UpdateFrame", "ARTWORK", "GameFontNormalHuge")
    KelThuzadFrame.timer:SetSize(100, 35)
    KelThuzadFrame.timer:SetPoint("CENTER", 0, -20)
    local v1, v2, v3 = KelThuzadFrame.timer:GetFont()
    KelThuzadFrame.timer:SetFont(v1, 38, v3)
    KelThuzadFrame.timer:SetText("-")

    if manual == true then
        KelThuzadFrame.startButton = CreateFrame("BUTTON", nil, KelThuzadFrame)
        KelThuzadFrame.startButton:SetSize(22, 22)
        KelThuzadFrame.startButton:SetPoint("TOPLEFT", -2, 0)
        KelThuzadFrame.startButton:SetScript("OnMouseDown", function() AZP.BossTools.KelThuzad:CreateTimer() end)
        KelThuzadFrame.startButton:SetHighlightTexture(GetFileIDFromPath("Interface\\Timer\\ChallengesGlow-Logo.blp"))

        KelThuzadFrame.startButton.Texture = KelThuzadFrame.startButton:CreateTexture(nil, "ARTWORK")
        KelThuzadFrame.startButton.Texture:SetSize(KelThuzadFrame.startButton:GetWidth(), KelThuzadFrame.startButton:GetHeight())
        KelThuzadFrame.startButton.Texture:SetPoint("CENTER", 0, 0)
        KelThuzadFrame.startButton.Texture:SetTexture(GetFileIDFromPath("Interface\\Timer\\Challenges-Logo.blp"))
    end

    KelThuzadFrame.CloseButton = CreateFrame("Button", nil, KelThuzadFrame, "UIPanelCloseButton")
    KelThuzadFrame.CloseButton:SetSize(20, 21)
    KelThuzadFrame.CloseButton:SetPoint("TOPRIGHT", KelThuzadFrame, "TOPRIGHT", 2, 2)
    KelThuzadFrame.CloseButton:SetScript("OnClick", function() KelThuzadFrame:Hide() end)

    KelThuzadFrame:Hide()
end



function AZP.BossTools.KelThuzad:CreateTimer()
    phaseCounter = phaseCounter + 1
    KelThuzadFrame.SubHeader:SetText(percStrings[phaseCounter])
    curTimer = phaseTime
    C_Timer.NewTicker(1, function() AZP.BossTools.KelThuzad:TickTimer() end, phaseTime)
end

function AZP.BossTools.KelThuzad:TickTimer()
    local preString, postString = "\124cFF", "\124r"
    local midString = nil
        if curTimer  > 30 then midString = "00FF00"
    elseif curTimer  > 20 then midString = "FFFF00"
    elseif curTimer  > 10 then midString = "FF8800"
    elseif curTimer <= 10 then midString = "FF0000" end
    local tempString = string.format("%s%s%s%s", preString, midString, curTimer, postString)
    KelThuzadFrame.timer:SetText(tempString)
    curTimer = curTimer - 1
end

function AZP.BossTools.KelThuzad:OnEvent(_, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        AZP.BossTools.KelThuzad.Events:CombatLogEventUnfiltered()
    elseif event == "ENCOUNTER_END" then
        phaseCounter = 0
    end
end

function AZP.BossTools.KelThuzad.Events:CombatLogEventUnfiltered()
    local _, SubEvent, _, _, _, _, _, TargetGUID, _, _, _, SpellID = CombatLogGetCurrentEventInfo()
    if SubEvent == "SPELL_AURA_APPLIED" then
        if SpellID == buffID then
            if TargetGUID == UnitGUID("PLAYER") then
                AZP.BossTools.KelThuzad:CreateTimer()
            end
        end
    end
end

AZP.BossTools.KelThuzad:OnLoad()