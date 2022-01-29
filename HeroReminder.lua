if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.HeroReminder == nil then AZP.BossTools.HeroReminder = {} end
if AZP.BossTools.HeroReminder.Events == nil then AZP.BossTools.HeroReminder.Events = {} end

local AZPBTHeroReminderFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")

function AZP.BossTools.HeroReminder.OnLoad()    
    AZPBTHeroReminderFrame:SetSize(250, 250)
    AZPBTHeroReminderFrame:SetPoint("CENTER", 0, 0)
    AZPBTHeroReminderFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    AZPBTHeroReminderFrame:EnableMouse(true)
    AZPBTHeroReminderFrame:SetMovable(true)
    AZPBTHeroReminderFrame:RegisterForDrag("LeftButton")
    AZPBTHeroReminderFrame:SetScript("OnDragStart", AZPBTHeroReminderFrame.StartMoving)
    AZPBTHeroReminderFrame:SetScript("OnDragStop", function() AZPBTHeroReminderFrame:StopMovingOrSizing() end)

    AZPBTHeroReminderFrame.Header = AZPBTHeroReminderFrame:CreateFontString("AZPBTHeroReminderFrame", "ARTWORK", "GameFontNormalHuge")
    AZPBTHeroReminderFrame.Header:SetSize(AZPBTHeroReminderFrame:GetWidth(), 50)
    AZPBTHeroReminderFrame.Header:SetPoint("TOP", 0, -5)
    AZPBTHeroReminderFrame.Header:SetText("AzerPUG's BossTools\nHeroReminder")

    AZPBTHeroReminderFrame.SubHeader = AZPBTHeroReminderFrame:CreateFontString("AZPBTHeroReminderFrame", "ARTWORK", "GameFontNormalLarge")
    AZPBTHeroReminderFrame.SubHeader:SetSize(AZPBTHeroReminderFrame:GetWidth(), 50)
    AZPBTHeroReminderFrame.SubHeader:SetPoint("TOP", AZPBTHeroReminderFrame.Header, "BOTTOM", 0, 10)
    AZPBTHeroReminderFrame.SubHeader:SetText("Hero Times for\nSanctum of Domination")

    AZPBTHeroReminderFrame.BossNames =
    {
        "The Tarragrue",
        "The Eye of the Jailer",
        "The Nine",
        "Remnant of Ner'Zhul",
        "Soulrender Dormazain",
        "Painsmith Raznal",
        "Guardian of the First Ones",
        "Fatescribe Roh-Kalo",
        "Kel'Thuzad",
        "Sylvanas Windrunner",
    }
    AZPBTHeroReminderFrame.HeroTimes =
    {
        "10%",
        "Phase 3",
        "Phase 2",
        "30%",
        "5 seconds",
        "Phase 3",
        "5 seconds",
        "Phase 3",
        "Phase 4",
        "5 seconds + CD",
    }
    AZPBTHeroReminderFrame.BossLabels = {}
    AZPBTHeroReminderFrame.NormalLabels = {}

    for i = 1, 10 do
        AZPBTHeroReminderFrame.BossLabels[i] = AZPBTHeroReminderFrame:CreateFontString("AZPBTHeroReminderFrame", "ARTWORK", "GameFontNormal")
        AZPBTHeroReminderFrame.BossLabels[i]:SetSize(150, 25)
        AZPBTHeroReminderFrame.BossLabels[i]:SetPoint("TOP", -65, ((i - 1) * -15) -85)
        AZPBTHeroReminderFrame.BossLabels[i]:SetJustifyH("RIGHT")
        AZPBTHeroReminderFrame.BossLabels[i]:SetText(AZPBTHeroReminderFrame.BossNames[i])

        AZPBTHeroReminderFrame.NormalLabels[i] = AZPBTHeroReminderFrame:CreateFontString("AZPBTHeroReminderFrame", "ARTWORK", "GameFontNormal")
        AZPBTHeroReminderFrame.NormalLabels[i]:SetSize(100, 25)
        AZPBTHeroReminderFrame.NormalLabels[i]:SetPoint("TOP", 65, ((i - 1) * -15) -85)
        AZPBTHeroReminderFrame.NormalLabels[i]:SetJustifyH("LEFT")
        AZPBTHeroReminderFrame.NormalLabels[i]:SetText(AZPBTHeroReminderFrame.HeroTimes[i])
    end

    AZPBTHeroReminderFrame.closeButton = CreateFrame("Button", nil, AZPBTHeroReminderFrame, "UIPanelCloseButton")
    AZPBTHeroReminderFrame.closeButton:SetSize(20, 21)
    AZPBTHeroReminderFrame.closeButton:SetPoint("TOPRIGHT", AZPBTHeroReminderFrame, "TOPRIGHT", 2, 2)
    AZPBTHeroReminderFrame.closeButton:SetScript("OnClick", function() AZP.BossTools.HeroReminder:ShowHideFrame() end)

    local AZPBossToolsFrame = AZP.BossTools.AZPBossToolsFrame
    local _, _, curClass = UnitClass("PLAYER")

    AZPBossToolsFrame.HeroButton = CreateFrame("Button", nil, AZPBossToolsFrame)
    AZPBossToolsFrame.HeroButton:SetSize(20, 20)
    AZPBossToolsFrame.HeroButton:SetPoint("TOPLEFT", AZPBossToolsFrame, "TOPLEFT", 3, -2)
    AZPBossToolsFrame.HeroButton:SetScript("OnClick", function() AZPBossToolsFrame:Hide() AZPBTHeroReminderFrame:Show() end)
    AZPBossToolsFrame.HeroButton.Texture = AZPBossToolsFrame.HeroButton:CreateTexture(nil, "ARTWORK")
    AZPBossToolsFrame.HeroButton.Texture:SetSize(20, 20)
    AZPBossToolsFrame.HeroButton.Texture:SetPoint("CENTER", 0, 0)
    local filePath = nil
        if curClass == 3 then filePath = "Interface/ICONS/Spell_Shadow_UnholyFrenzy"        -- Ancient Hysteria for Hunter.
    elseif curClass == 7 then filePath = "Interface/ICONS/Ability_Shaman_Heroism"           -- Heroism for Shaman.
    --elseif curClass == 7 then filePath = "Interface/ICONS/Spell_Nature_BloodLust"         -- Bloodlust for Traitor Shaman.
    elseif curClass == 8 then filePath = "Interface/ICONS/Ability_Mage_TimeWarp"            -- Timewarp for Mage.
                         else filePath = "Interface/ICONS/INV_Leatherworking_Drums" end     -- Drums for Others.
    AZPBossToolsFrame.HeroButton.Texture:SetTexture(GetFileIDFromPath(filePath))

    AZPBTHeroReminderFrame:Hide()
end

function AZP.BossTools.HeroReminder:ShowHideFrame()
    if AZPBTHeroReminderFrame:IsShown() then
        AZPBTHeroReminderFrame:Hide()
    else
        AZPBTHeroReminderFrame:Show()
    end
end

AZP.BossTools.HeroReminder.OnLoad()

AZP.SlashCommands["HR"] = function()
    AZP.BossTools.HeroReminder:ShowHideFrame()
end

AZP.SlashCommands["hr"] = AZP.SlashCommands["HR"]
AZP.SlashCommands["Hero"] = AZP.SlashCommands["HR"]
AZP.SlashCommands["hero"] = AZP.SlashCommands["HR"]
AZP.SlashCommands["Hero Reminder"] = AZP.SlashCommands["HR"]
AZP.SlashCommands["hero reminder"] = AZP.SlashCommands["HR"]
