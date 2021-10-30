if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

AZP.VersionControl["BossTools"] = 8
if AZP.BossTools == nil then AZP.BossTools = {} end
if AZP.BossTools.Events == nil then AZP.BossTools.Events = {} end

AZP.BossTools.ParentOptionFrame = nil
AZP.BossTools.PopUpFrame = nil
AZP.BossTools.BossFrames = {}

local AZPRTBossToolsFrame = nil

local soundID = 8959
local soundChannel = 1

local BossFileIDs =
{
    Tarragrue = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Tarragrue.blp"),
    Dormazain = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Soulrender Dormazain.blp"),
    RohKalo   = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Fatescribe Roh-Talo.blp"),
}

function AZP.BossTools.OnLoad()
    AZP.BossTools.ParentOptionFrame = CreateFrame("FRAME", nil)
    AZP.BossTools.ParentOptionFrame.name = "|cFF00FFFFAzerPUG's BossTools|r"
    InterfaceOptions_AddCategory(AZP.BossTools.ParentOptionFrame)

    AZP.BossTools.ParentOptionFrame.Header = AZP.BossTools.ParentOptionFrame:CreateFontString("AZPBossToolsRohKaloOptionPanel", "ARTWORK", "GameFontNormalHuge")
    AZP.BossTools.ParentOptionFrame.Header:SetPoint("TOP", 0, -10)
    AZP.BossTools.ParentOptionFrame.Header:SetText(string.format("AzerPUG's BossTools v%s", AZP.VersionControl["BossTools"]))

    AZP.BossTools.ParentOptionFrame.SubHeader = AZP.BossTools.ParentOptionFrame:CreateFontString("AZPBossToolsRohKaloOptionPanel", "ARTWORK", "GameFontNormalLarge")
    AZP.BossTools.ParentOptionFrame.SubHeader:SetPoint("TOP", AZP.BossTools.ParentOptionFrame.Header, "BOTTOM", 0, -5)
    AZP.BossTools.ParentOptionFrame.SubHeader:SetText("Options Panel")

    AZP.BossTools:CreateSelectorFrame()
    AZP.BossTools:CreatePopUpFrame()
end

function AZP.BossTools:CreateSelectorFrame()
    AZPRTBossToolsFrame = CreateFrame("FRAME", nil, UIParent, "BackdropTemplate")
    AZPRTBossToolsFrame:SetPoint("CENTER", 0, 0)
    AZPRTBossToolsFrame:SetSize(265, 150)
    AZPRTBossToolsFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })

    AZPRTBossToolsFrame.Header = AZPRTBossToolsFrame:CreateFontString("AZPRTBossToolsFrame", "ARTWORK", "GameFontNormalHuge")
    AZPRTBossToolsFrame.Header:SetSize(AZPRTBossToolsFrame:GetWidth(), 25)
    AZPRTBossToolsFrame.Header:SetPoint("TOP", 0, -5)
    AZPRTBossToolsFrame.Header:SetText(string.format("AzerPUG's BossTools v%s", AZP.VersionControl["BossTools"]))

    AZPRTBossToolsFrame.SubHeader = AZPRTBossToolsFrame:CreateFontString("AZPRTBossToolsFrame", "ARTWORK", "GameFontNormalLarge")
    AZPRTBossToolsFrame.SubHeader:SetSize(AZPRTBossToolsFrame:GetWidth(), 25)
    AZPRTBossToolsFrame.SubHeader:SetPoint("TOP", AZPRTBossToolsFrame.Header, "BOTTOM", 0, 5)
    AZPRTBossToolsFrame.SubHeader:SetText("Boss Selector Frame")

    local BossWidth, BossHeight = 100, 75

    AZPRTBossToolsFrame.Tarragrue = CreateFrame("FRAME", nil, AZPRTBossToolsFrame)
    AZPRTBossToolsFrame.Tarragrue:SetSize(BossWidth, BossHeight)
    AZPRTBossToolsFrame.Tarragrue:SetPoint("BOTTOM", -80, -1)
    AZPRTBossToolsFrame.Tarragrue:SetScript("OnMouseDown", function() AZPRTBossToolsFrame:Hide() AZP.BossTools.BossFrames.Tarragrue:Show() end)
    AZPRTBossToolsFrame.Tarragrue.Button = AZPRTBossToolsFrame.Tarragrue:CreateTexture(nil, "ARTWORK")
    AZPRTBossToolsFrame.Tarragrue.Button:SetSize(AZPRTBossToolsFrame.Tarragrue:GetWidth(), 55)
    AZPRTBossToolsFrame.Tarragrue.Button:SetPoint("BOTTOM", 0, 0)
    AZPRTBossToolsFrame.Tarragrue.Button:SetTexture(BossFileIDs.Tarragrue)
    AZPRTBossToolsFrame.Tarragrue.Label = AZPRTBossToolsFrame.Tarragrue:CreateFontString("AZPRTBossToolsFrame", "ARTWORK", "GameFontNormalLarge")
    AZPRTBossToolsFrame.Tarragrue.Label:SetSize(AZPRTBossToolsFrame.Tarragrue:GetWidth() -20, 25)
    AZPRTBossToolsFrame.Tarragrue.Label:SetPoint("TOP", -10, 0)
    AZPRTBossToolsFrame.Tarragrue.Label:SetText("Tarragrue")

    AZPRTBossToolsFrame.Dormazain = CreateFrame("FRAME", nil, AZPRTBossToolsFrame)
    AZPRTBossToolsFrame.Dormazain:SetSize(BossWidth, BossHeight)
    AZPRTBossToolsFrame.Dormazain:SetPoint("BOTTOM", 10, -1)
    AZPRTBossToolsFrame.Dormazain:SetScript("OnMouseDown", function() AZPRTBossToolsFrame:Hide() AZP.BossTools.BossFrames.Dormazain:Show() end)
    AZPRTBossToolsFrame.Dormazain.Button = AZPRTBossToolsFrame.Dormazain:CreateTexture(nil, "ARTWORK")
    AZPRTBossToolsFrame.Dormazain.Button:SetSize(100, 55)
    AZPRTBossToolsFrame.Dormazain.Button:SetPoint("BOTTOM", 0, 0)
    AZPRTBossToolsFrame.Dormazain.Button:SetTexture(BossFileIDs.Dormazain)
    AZPRTBossToolsFrame.Dormazain.Label = AZPRTBossToolsFrame.Dormazain:CreateFontString("AZPRTBossToolsFrame", "ARTWORK", "GameFontNormalLarge")
    AZPRTBossToolsFrame.Dormazain.Label:SetSize(AZPRTBossToolsFrame.Dormazain:GetWidth() -20, 25)
    AZPRTBossToolsFrame.Dormazain.Label:SetPoint("TOP", -10, 0)
    AZPRTBossToolsFrame.Dormazain.Label:SetText("Dormazain")

    AZPRTBossToolsFrame.RohKalo = CreateFrame("FRAME", nil, AZPRTBossToolsFrame)
    AZPRTBossToolsFrame.RohKalo:SetSize(BossWidth, BossHeight)
    AZPRTBossToolsFrame.RohKalo:SetPoint("BOTTOM", 100, -1)
    AZPRTBossToolsFrame.RohKalo:SetScript("OnMouseDown", function() AZPRTBossToolsFrame:Hide() AZP.BossTools.BossFrames.RohKalo:Show() end)
    AZPRTBossToolsFrame.RohKalo.Button = AZPRTBossToolsFrame.RohKalo:CreateTexture(nil, "ARTWORK")
    AZPRTBossToolsFrame.RohKalo.Button:SetSize(100, 55)
    AZPRTBossToolsFrame.RohKalo.Button:SetPoint("BOTTOM", 0, 0)
    AZPRTBossToolsFrame.RohKalo.Button:SetTexture(BossFileIDs.RohKalo)
    AZPRTBossToolsFrame.RohKalo.Label = AZPRTBossToolsFrame.RohKalo:CreateFontString("AZPRTBossToolsFrame", "ARTWORK", "GameFontNormalLarge")
    AZPRTBossToolsFrame.RohKalo.Label:SetSize(AZPRTBossToolsFrame.RohKalo:GetWidth() -20, 25)
    AZPRTBossToolsFrame.RohKalo.Label:SetPoint("TOP", -10, 0)
    AZPRTBossToolsFrame.RohKalo.Label:SetText("Roh-Kalo")

    AZPRTBossToolsFrame.closeButton = CreateFrame("Button", nil, AZPRTBossToolsFrame, "UIPanelCloseButton")
    AZPRTBossToolsFrame.closeButton:SetSize(20, 21)
    AZPRTBossToolsFrame.closeButton:SetPoint("TOPRIGHT", AZPRTBossToolsFrame, "TOPRIGHT", 2, 2)
    AZPRTBossToolsFrame.closeButton:SetScript("OnClick", function() AZPRTBossToolsFrame:Hide() end)

    --AZPRTBossToolsFrame:Hide()
end

function AZP.BossTools:CreatePopUpFrame()
    AZP.BossTools.PopUpFrame = CreateFrame("FRAME", nil, UIParent)
    AZP.BossTools.PopUpFrame:SetPoint("CENTER", 0, 250)
    AZP.BossTools.PopUpFrame:SetSize(200, 50)

    AZP.BossTools.PopUpFrame.text = AZP.BossTools.PopUpFrame:CreateFontString("PopUpFrame", "ARTWORK", "GameFontNormalHuge")
    AZP.BossTools.PopUpFrame.text:SetPoint("CENTER", 0, 0)
    AZP.BossTools.PopUpFrame.text:SetSize(AZP.BossTools.PopUpFrame:GetWidth(), AZP.BossTools.PopUpFrame:GetHeight())
    AZP.BossTools.PopUpFrame.text:SetScale(0.5)
    AZP.BossTools.PopUpFrame.text:Hide()
end

function AZP.BossTools:CheckIfDead(playerGUID)
    local deathStatus
    for i = 1, 40 do
        local curGUID = UnitGUID("Raid" .. i)
        if curGUID ~= nil then
            if curGUID == playerGUID then
                deathStatus = UnitIsDeadOrGhost("Raid" .. i)
            end
        end
    end
    return deathStatus
end

function AZP.BossTools:GetClassColor(classIndex)
        if classIndex ==  0 then return 0.00, 0.00, 0.00      -- None
    elseif classIndex ==  1 then return 0.78, 0.61, 0.43      -- Warrior
    elseif classIndex ==  2 then return 0.96, 0.55, 0.73      -- Paladin
    elseif classIndex ==  3 then return 0.67, 0.83, 0.45      -- Hunter
    elseif classIndex ==  4 then return 1.00, 0.96, 0.41      -- Rogue
    elseif classIndex ==  5 then return 1.00, 1.00, 1.00      -- Priest
    elseif classIndex ==  6 then return 0.77, 0.12, 0.23      -- Death Knight
    elseif classIndex ==  7 then return 0.00, 0.44, 0.87      -- Shaman
    elseif classIndex ==  8 then return 0.25, 0.78, 0.92      -- Mage
    elseif classIndex ==  9 then return 0.53, 0.53, 0.93      -- Warlock
    elseif classIndex == 10 then return 0.00, 1.00, 0.60      -- Monk
    elseif classIndex == 11 then return 1.00, 0.49, 0.04      -- Druid
    elseif classIndex == 12 then return 0.64, 0.19, 0.79      -- Demon Hunter
    end
end

function AZP.BossTools:WarnPlayer(text)
    print("WarnPlayer Called!")
    local curScale = 0.5
    AZP.BossTools.PopUpFrame.text:SetScale(curScale)
    AZP.BossTools.PopUpFrame.text:Show()
    AZP.BossTools.PopUpFrame.text:SetText(text)
    PlaySound(soundID, soundChannel)
    C_Timer.NewTimer(2.5, function() AZP.BossTools.PopUpFrame.text:Hide() end)
    C_Timer.NewTicker(0.005,
    function()
        curScale = curScale + 0.15
        AZP.BossTools.PopUpFrame.text:SetScale(curScale)
    end,
    35)
end

AZP.BossTools.OnLoad()

AZP.SlashCommands["BT"] = function()
    if AZPRTBossToolsFrame ~= nil then AZPRTBossToolsFrame:Show() end
end

AZP.SlashCommands["bt"] = AZP.SlashCommands["BT"]
AZP.SlashCommands["boos tools"] = AZP.SlashCommands["BT"]
AZP.SlashCommands["Boss Tools"] = AZP.SlashCommands["BT"]
AZP.SlashCommands["bosstools"] = AZP.SlashCommands["BT"]
AZP.SlashCommands["BossTools"] = AZP.SlashCommands["BT"]