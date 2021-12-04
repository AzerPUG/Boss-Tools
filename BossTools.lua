if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

AZP.VersionControl["BossTools"] = 11
if AZP.BossTools == nil then AZP.BossTools = {} end
if AZP.BossTools.Events == nil then AZP.BossTools.Events = {} end

AZP.BossTools.ParentOptionFrame = nil
AZP.BossTools.PopUpFrame = nil
AZP.BossTools.BossFrames = {}
AZP.BossTools.BossIcons = {}

local AZPRTBossToolsFrame = nil

local soundID = 8959
local soundChannel = 1

local BossInfo =
{
    Tarragrue =
    {
        Name = "Tarragrue",
        Index = 1,
        Active = "Soon",
        FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Tarragrue.blp"),
    },
    TheEye =
    {
        Name = "The Eye",
        Index = 2,
        Active = true,
        FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS- Eye of the Jailer.blp"),
    },
    TheNine =
    {
        Name = "The Nine",
        Index = 3,
        Active = false,
        FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-The Nine.blp"),
    },
    NerZhul =
    {
        Name = "Ner'Zhul",
        Index = 4,
        Active = false,
        FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Remnant of Ner zhul.blp"),
    },
    Dormazain =
    {
        Name = "Dormazain",
        Index = 5,
        Active = true,
        FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Soulrender Dormazain.blp"),
    },
    Painsmith =
    {
        Name = "Painsmith",
        Index = 6,
        Active = false,
        FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Painsmith Raznal.blp"),
    },
    Guardian =
    {
        Name = "Guardian",
        Index = 7,
        Active = false,
        FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Guardian of the First Ones.blp"),
    },
    RohKalo =
    {
        Name = "Roh-Kalo",
        Index = 8,
        Active = true,
        FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Fatescribe Roh-Talo.blp"),
    },
    KelThuzad =
    {
        Name = "Kel'Thuzad",
        Index = 9,
        Active = true,
        FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Kel Thuzad Shadowlands.blp"),
    },
    Sylvanas =
    {
        Name = "Sylvanas",
        Index = 10,
        Active = false,
        FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Sylvanas Windrunner Shadowlands.blp"),
    },
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
    AZP.BossTools:ApplyTaintFix()
end

function AZP.BossTools:ApplyTaintFix()
    if (UIDD_REFRESH_OVERREAD_PATCH_VERSION or 0) < 3 then
        UIDD_REFRESH_OVERREAD_PATCH_VERSION = 3
        local function drop(t, k)
            local c = 42
            t[k] = nil
            while not issecurevariable(t, k) do
                if t[c] == nil then
                    t[c] = nil
                end
                c = c + 1
            end
        end
        hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
            if UIDD_REFRESH_OVERREAD_PATCH_VERSION ~= 3 then
                return
            end
            for i=1, UIDROPDOWNMENU_MAXLEVELS do
                for j=1+_G["DropDownList" .. i].numButtons, UIDROPDOWNMENU_MAXBUTTONS do
                    local b, _ = _G["DropDownList" .. i .. "Button" .. j]
                    _ = issecurevariable(b, "checked")      or drop(b, "checked")
                    _ = issecurevariable(b, "notCheckable") or drop(b, "notCheckable")
                end
            end
        end)
    end
end

function AZP.BossTools:CreateSelectorFrame()
    AZPRTBossToolsFrame = CreateFrame("FRAME", nil, UIParent, "BackdropTemplate")
    AZPRTBossToolsFrame:SetPoint("CENTER", 0, 0)
    AZPRTBossToolsFrame.Background = AZPRTBossToolsFrame:CreateTexture(nil, "ARTWORK")
    AZPRTBossToolsFrame.Background:SetPoint("CENTER", 0, 0)
    AZPRTBossToolsFrame.Background:SetTexture(GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-LOREBG-SanctumofDomination"))
    AZPRTBossToolsFrame.Background:SetTexCoord(0.03425, 0.72525, 0.0585, 0.60)
    AZPRTBossToolsFrame.Background:SetAlpha(0.8)
    AZPRTBossToolsFrame:SetBackdrop({
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })

    AZPRTBossToolsFrame.Header = AZPRTBossToolsFrame:CreateFontString("AZPRTBossToolsFrame", "ARTWORK", "GameFontNormalHuge")
    AZPRTBossToolsFrame.Header:SetSize(AZPRTBossToolsFrame:GetWidth(), 25)
    AZPRTBossToolsFrame.Header:SetPoint("TOP", 0, -15)
    AZPRTBossToolsFrame.Header:SetText(string.format("AzerPUG's BossTools v%s", AZP.VersionControl["BossTools"]))

    AZPRTBossToolsFrame.SubHeader = AZPRTBossToolsFrame:CreateFontString("AZPRTBossToolsFrame", "ARTWORK", "GameFontNormalLarge")
    AZPRTBossToolsFrame.SubHeader:SetSize(AZPRTBossToolsFrame:GetWidth(), 50)
    AZPRTBossToolsFrame.SubHeader:SetPoint("TOP", AZPRTBossToolsFrame.Header, "BOTTOM", 0, 5)
    AZPRTBossToolsFrame.SubHeader:SetText("Sanctum of Domination\nBoss Selector Frame")

    local BossWidth, BossHeight = 100, 75

    for Boss, Info in pairs(BossInfo) do
        if Info.Active ~= false then
            local curFrame = CreateFrame("FRAME", nil, AZPRTBossToolsFrame)
            curFrame:SetSize(BossWidth, BossHeight)
            curFrame:SetScript("OnMouseDown", function() if AZP.BossTools.BossFrames[Boss] ~= nil then AZPRTBossToolsFrame:Hide() AZP.BossTools.BossFrames[Boss]:Show() end end)
            curFrame.Button = curFrame:CreateTexture(nil, "ARTWORK")
            curFrame.Button:SetSize(curFrame:GetWidth(), 55)
            curFrame.Button:SetPoint("BOTTOM", 0, 0)
            curFrame.Button:SetTexture(Info.FileID)
            curFrame.Label = curFrame:CreateFontString("AZPRTBossToolsFrame", "ARTWORK", "GameFontNormalLarge")
            curFrame.Label:SetSize(curFrame:GetWidth() -20, 25)
            curFrame.Label:SetPoint("TOP", -10, -5)
            curFrame.Label:SetText(Info.Name)

            if Info.Active == "Soon" then
                curFrame.Button:SetDesaturated(true)
                curFrame.ComingSoon = curFrame:CreateFontString("AZPRTBossToolsFrame", "ARTWORK", "GameFontNormalLarge")
                curFrame.ComingSoon:SetSize(curFrame:GetWidth() -20, 50)
                curFrame.ComingSoon:SetPoint("TOP", -10, -25)
                curFrame.ComingSoon:SetText("Coming\nSoon!")
            end

            curFrame.Index = Info.Index
            AZP.BossTools.BossIcons[#AZP.BossTools.BossIcons + 1] = curFrame
        end
    end

    local iconsPerRow = {math.floor(#AZP.BossTools.BossIcons / 2), math.ceil(#AZP.BossTools.BossIcons / 2)}
    local FrameWidth = (iconsPerRow[2] * 85 + 25)
    if FrameWidth < 280 then FrameWidth = 280 end
    AZPRTBossToolsFrame:SetSize(FrameWidth, FrameWidth - 15)
    AZPRTBossToolsFrame.Background:SetSize(AZPRTBossToolsFrame:GetWidth() - 5, AZPRTBossToolsFrame:GetHeight() - 5)

    table.sort(AZP.BossTools.BossIcons, function(a,b) return a.Index < b.Index end)

    if #AZP.BossTools.BossIcons == 0 then return
    elseif #AZP.BossTools.BossIcons > 0 then
        for i = 1, #AZP.BossTools.BossIcons do
            local BottomOffset = {[1] = 0, [2] = 8, [3] =  9, [4] = 10, [5] = 13,}
            local   LeftOffset = {[1] = 0, [2] = 35, [3] = 22, [4] = 17, [5] = 11,}
            if i == 1 then AZP.BossTools.BossIcons[i]:SetPoint("BOTTOM", (-35 * iconsPerRow[1]) + LeftOffset[iconsPerRow[1]], 100)
            elseif i == (iconsPerRow[1] + 1) then AZP.BossTools.BossIcons[i]:SetPoint("BOTTOM", (-35 * iconsPerRow[2]) + LeftOffset[iconsPerRow[2]], BottomOffset[iconsPerRow[2]])
            else AZP.BossTools.BossIcons[i]:SetPoint("LEFT", AZP.BossTools.BossIcons[i-1], "RIGHT", -10, 0) end
        end
    end

    AZPRTBossToolsFrame.closeButton = CreateFrame("Button", nil, AZPRTBossToolsFrame, "UIPanelCloseButton")
    AZPRTBossToolsFrame.closeButton:SetSize(20, 21)
    AZPRTBossToolsFrame.closeButton:SetPoint("TOPRIGHT", AZPRTBossToolsFrame, "TOPRIGHT", 1, 2)
    AZPRTBossToolsFrame.closeButton:SetScript("OnClick", function() AZPRTBossToolsFrame:Hide() end)

    AZPRTBossToolsFrame:Hide()
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

function AZP.BossTools:ShowBossFrame(Boss)

    AZP.BossTools.BossFrames[Boss]:Show()
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

function AZP.BossTools:GetClassIndexFromGUID(curGUID)
    local curClassID = nil
    for i = 1, 40 do
        if UnitGUID("RAID" .. i) == curGUID then
            _, _, curClassID = UnitClass("RAID" .. i)
            return curClassID
        end
    end
end

function AZP.BossTools:GetClassColor(classIndex)
        if classIndex ==  0 then return 0.00, 0.00, 0.00, "000000"      -- None
    elseif classIndex ==  1 then return 0.78, 0.61, 0.43, "C69B6D"      -- Warrior
    elseif classIndex ==  2 then return 0.96, 0.55, 0.73, "F48CBA"      -- Paladin
    elseif classIndex ==  3 then return 0.67, 0.83, 0.45, "AAD372"      -- Hunter
    elseif classIndex ==  4 then return 1.00, 0.96, 0.41, "FFF468"      -- Rogue
    elseif classIndex ==  5 then return 1.00, 1.00, 1.00, "FFFFFF"      -- Priest
    elseif classIndex ==  6 then return 0.77, 0.12, 0.23, "C41E3A"      -- Death Knight
    elseif classIndex ==  7 then return 0.00, 0.44, 0.87, "0070DD"      -- Shaman
    elseif classIndex ==  8 then return 0.25, 0.78, 0.92, "3FC7EB"      -- Mage
    elseif classIndex ==  9 then return 0.53, 0.53, 0.93, "8788EE"      -- Warlock
    elseif classIndex == 10 then return 0.00, 1.00, 0.60, "00FF98"      -- Monk
    elseif classIndex == 11 then return 1.00, 0.49, 0.04, "FF7C0A"      -- Druid
    elseif classIndex == 12 then return 0.64, 0.19, 0.79, "A330C9"      -- Demon Hunter
    end
end

function AZP.BossTools:WarnPlayer(text)
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