if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Sepulcher.HeroReminder == nil then AZP.BossTools.Sepulcher.HeroReminder = {} end
if AZP.BossTools.Sepulcher.HeroReminder.Events == nil then AZP.BossTools.Sepulcher.HeroReminder.Events = {} end

local AZPBTHeroReminderFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")

function AZP.BossTools.Sepulcher.HeroReminder.OnLoad()
    AZPBTHeroReminderFrame:SetSize(250, 230)
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
    AZPBTHeroReminderFrame.Header:SetText("AzerPUG's BossTools\nSepulcher HeroReminder")

    AZPBTHeroReminderFrame.BossLabels = {}
    AZPBTHeroReminderFrame.HeroTimes = {}

    for bossName, BossInfo in pairs(AZP.BossTools.BossInfo.Sepulcher) do
        if bossName ~= "Background" then
            local curBossName = AZPBTHeroReminderFrame:CreateFontString("AZPBTHeroReminderFrame", "ARTWORK", "GameFontNormal")
            curBossName:SetSize(150, 25)
            curBossName:SetPoint("TOP", -65, ((BossInfo.Index - 1) * -15) -55)
            curBossName:SetJustifyH("RIGHT")
            curBossName:SetText(bossName)
            AZPBTHeroReminderFrame.BossLabels[bossName] = curBossName

            local curHeroTime = AZPBTHeroReminderFrame:CreateFontString("AZPBTHeroReminderFrame", "ARTWORK", "GameFontNormal")
            curHeroTime:SetSize(100, 25)
            curHeroTime:SetPoint("TOP", 65, ((BossInfo.Index - 1) * -15) -55)
            curHeroTime:SetJustifyH("LEFT")
            curHeroTime:SetText(BossInfo.Hero)
            AZPBTHeroReminderFrame.HeroTimes[bossName] = curHeroTime
        end
    end

    AZPBTHeroReminderFrame.closeButton = CreateFrame("Button", nil, AZPBTHeroReminderFrame, "UIPanelCloseButton")
    AZPBTHeroReminderFrame.closeButton:SetSize(20, 21)
    AZPBTHeroReminderFrame.closeButton:SetPoint("TOPRIGHT", AZPBTHeroReminderFrame, "TOPRIGHT", 2, 2)
    AZPBTHeroReminderFrame.closeButton:SetScript("OnClick", function() AZP.BossTools.Sepulcher.HeroReminder:ShowHideFrame() end)

    local AZPBossToolsSepulcherFrame = AZP.BossTools.AZPBossToolsSepulcherFrame
    local _, _, curClass = UnitClass("PLAYER")

    AZPBossToolsSepulcherFrame.HeroButton = CreateFrame("Button", nil, AZPBossToolsSepulcherFrame)
    AZPBossToolsSepulcherFrame.HeroButton:SetSize(20, 20)
    AZPBossToolsSepulcherFrame.HeroButton:SetPoint("TOPLEFT", AZPBossToolsSepulcherFrame, "TOPLEFT", 3, -2)
    AZPBossToolsSepulcherFrame.HeroButton:SetScript("OnClick", function() AZPBossToolsSepulcherFrame:Hide() AZPBTHeroReminderFrame:Show() end)
    AZPBossToolsSepulcherFrame.HeroButton.Texture = AZPBossToolsSepulcherFrame.HeroButton:CreateTexture(nil, "ARTWORK")
    AZPBossToolsSepulcherFrame.HeroButton.Texture:SetSize(20, 20)
    AZPBossToolsSepulcherFrame.HeroButton.Texture:SetPoint("CENTER", 0, 0)
    local filePath = nil
        if curClass == 3 then filePath = "Interface/ICONS/Spell_Shadow_UnholyFrenzy"        -- Ancient Hysteria for Hunter.
    elseif curClass == 7 then filePath = "Interface/ICONS/Ability_Shaman_Heroism"           -- Heroism for Shaman.
    --elseif curClass == 7 then filePath = "Interface/ICONS/Spell_Nature_BloodLust"         -- Bloodlust for Traitor Shaman.
    elseif curClass == 8 then filePath = "Interface/ICONS/Ability_Mage_TimeWarp"            -- Timewarp for Mage.
                         else filePath = "Interface/ICONS/INV_Leatherworking_Drums" end     -- Drums for Others.
    AZPBossToolsSepulcherFrame.HeroButton.Texture:SetTexture(GetFileIDFromPath(filePath))

    AZPBTHeroReminderFrame:Hide()
end

function AZP.BossTools.Sepulcher.HeroReminder:SanctumData()

end

function AZP.BossTools.Sepulcher.HeroReminder:SepulcherData()

end

function AZP.BossTools.Sepulcher.HeroReminder:ShowHideFrame()
    if AZPBTHeroReminderFrame:IsShown() then
        AZPBTHeroReminderFrame:Hide()
    else
        AZPBTHeroReminderFrame:Show()
    end
end

AZP.BossTools.Sepulcher.HeroReminder.OnLoad()

AZP.SlashCommands["HR"] = function()
    AZP.BossTools.Sepulcher.HeroReminder:ShowHideFrame()
end

AZP.SlashCommands["hr"] = AZP.SlashCommands["HR"]
AZP.SlashCommands["Hero"] = AZP.SlashCommands["HR"]
AZP.SlashCommands["hero"] = AZP.SlashCommands["HR"]
AZP.SlashCommands["Hero Reminder"] = AZP.SlashCommands["HR"]
AZP.SlashCommands["hero reminder"] = AZP.SlashCommands["HR"]
