if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

AZP.VersionControl["BossTools"] = 34
if AZP.BossTools == nil then AZP.BossTools = {} end
if AZP.BossTools.Events == nil then AZP.BossTools.Events = {} end

if AZP.BossTools.Sanctum == nil then AZP.BossTools.Sanctum = {} end
if AZP.BossTools.Sepulcher == nil then AZP.BossTools.Sepulcher = {} end

AZP.BossTools.ParentOptionFrame = nil
AZP.BossTools.PopUpFrame = nil
AZP.BossTools.BossFrames = {}
AZP.BossTools.BossIcons = {}
AZP.BossTools.BossIcons.Sanctum = {}
AZP.BossTools.BossIcons.Sepulcher = {}
AZP.BossTools.ReceiveFrame = nil

local AZPBossToolsSanctumFrame, AZPBossToolsSepulcherFrame = nil, nil

local soundID = 8959
local soundChannel = 1

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

    AZP.BossTools:CreateSanctumSelectorFrame()
    AZP.BossTools:CreateSepulcherSelectorFrame()
    AZP.BossTools:CreatePopUpFrame()
    AZP.BossTools:ApplyTaintFix()
    AZP.BossTools:CreateReceiveFrame()
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

function AZP.BossTools:CreateSanctumSelectorFrame()
    AZPBossToolsSanctumFrame = CreateFrame("FRAME", nil, UIParent, "BackdropTemplate")
    AZPBossToolsSanctumFrame:SetPoint("CENTER", 0, 0)
    AZPBossToolsSanctumFrame.Background = AZPBossToolsSanctumFrame:CreateTexture(nil, "ARTWORK")
    AZPBossToolsSanctumFrame.Background:SetPoint("CENTER", 0, 0)
    AZPBossToolsSanctumFrame.Background:SetTexture(AZP.BossTools.BossInfo.Sanctum.Background)
    AZPBossToolsSanctumFrame.Background:SetTexCoord(0.03425, 0.72525, 0.0585, 0.60)
    AZPBossToolsSanctumFrame.Background:SetAlpha(0.8)
    AZPBossToolsSanctumFrame:SetBackdrop({
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })

    AZPBossToolsSanctumFrame.Header = AZPBossToolsSanctumFrame:CreateFontString("AZPBossToolsSanctumFrame", "ARTWORK", "GameFontNormalHuge")
    AZPBossToolsSanctumFrame.Header:SetSize(AZPBossToolsSanctumFrame:GetWidth(), 25)
    AZPBossToolsSanctumFrame.Header:SetPoint("TOP", 0, -15)
    AZPBossToolsSanctumFrame.Header:SetText(string.format("AzerPUG's BossTools v%s", AZP.VersionControl["BossTools"]))

    AZPBossToolsSanctumFrame.SubHeader = AZPBossToolsSanctumFrame:CreateFontString("AZPBossToolsSanctumFrame", "ARTWORK", "GameFontNormalLarge")
    AZPBossToolsSanctumFrame.SubHeader:SetSize(AZPBossToolsSanctumFrame:GetWidth(), 50)
    AZPBossToolsSanctumFrame.SubHeader:SetPoint("TOP", AZPBossToolsSanctumFrame.Header, "BOTTOM", 0, 5)
    AZPBossToolsSanctumFrame.SubHeader:SetText("Sanctum of Domination\nBoss Selector Frame")

    local BossWidth, BossHeight = 100, 75

    for Boss, Info in pairs(AZP.BossTools.BossInfo.Sanctum) do
        if Boss ~= "Background" then
            if Info.Active ~= false then
                local curFrame = CreateFrame("FRAME", nil, AZPBossToolsSanctumFrame)
                curFrame:SetSize(BossWidth, BossHeight)
                curFrame:SetScript("OnMouseDown", function() if AZP.BossTools.BossFrames[Boss] ~= nil then AZPBossToolsSanctumFrame:Hide() AZP.BossTools.BossFrames[Boss]:Show() end end)
                curFrame.Button = curFrame:CreateTexture(nil, "ARTWORK")
                curFrame.Button:SetSize(curFrame:GetWidth(), 55)
                curFrame.Button:SetPoint("BOTTOM", 0, 0)
                curFrame.Button:SetTexture(Info.FileID)
                curFrame.Label = curFrame:CreateFontString("AZPBossToolsSanctumFrame", "ARTWORK", "GameFontNormalLarge")
                curFrame.Label:SetSize(curFrame:GetWidth() -20, 25)
                curFrame.Label:SetPoint("TOP", -10, -5)
                curFrame.Label:SetText(Info.Name)

                if Info.Active == "Soon" then
                    curFrame.Button:SetDesaturated(true)
                    curFrame.ComingSoon = curFrame:CreateFontString("AZPBossToolsSanctumFrame", "ARTWORK", "GameFontNormalLarge")
                    curFrame.ComingSoon:SetSize(curFrame:GetWidth() -20, 50)
                    curFrame.ComingSoon:SetPoint("TOP", -10, -25)
                    curFrame.ComingSoon:SetText("Coming\nSoon!")
                end

                curFrame.Index = Info.Index
                AZP.BossTools.BossIcons.Sanctum[#AZP.BossTools.BossIcons.Sanctum + 1] = curFrame
            end
        end
    end

    local iconsPerRow = {math.floor(#AZP.BossTools.BossIcons.Sanctum / 2), math.ceil(#AZP.BossTools.BossIcons.Sanctum / 2)}
    local FrameWidth = (iconsPerRow[2] * 85 + 25)
    if FrameWidth < 280 then FrameWidth = 280 end
    AZPBossToolsSanctumFrame:SetSize(FrameWidth, FrameWidth - 15)
    AZPBossToolsSanctumFrame.Background:SetSize(AZPBossToolsSanctumFrame:GetWidth() - 5, AZPBossToolsSanctumFrame:GetHeight() - 5)

    table.sort(AZP.BossTools.BossIcons.Sanctum, function(a,b) return a.Index < b.Index end)

    if #AZP.BossTools.BossIcons.Sanctum == 0 then return
    elseif #AZP.BossTools.BossIcons.Sanctum > 0 then
        for i = 1, #AZP.BossTools.BossIcons.Sanctum do
            local BottomOffset = {[1] = 0, [2] = 8, [3] =  9, [4] = 10, [5] = 13,}
            local   LeftOffset = {[1] = 0, [2] = 35, [3] = 22, [4] = 17, [5] = 11,}
            if i == 1 then AZP.BossTools.BossIcons.Sanctum[i]:SetPoint("BOTTOM", (-35 * iconsPerRow[1]) + LeftOffset[iconsPerRow[1]], 100)
            elseif i == (iconsPerRow[1] + 1) then AZP.BossTools.BossIcons.Sanctum[i]:SetPoint("BOTTOM", (-35 * iconsPerRow[2]) + LeftOffset[iconsPerRow[2]], BottomOffset[iconsPerRow[2]])
            else AZP.BossTools.BossIcons.Sanctum[i]:SetPoint("LEFT", AZP.BossTools.BossIcons.Sanctum[i-1], "RIGHT", -10, 0) end
        end
    end

    AZPBossToolsSanctumFrame.closeButton = CreateFrame("Button", nil, AZPBossToolsSanctumFrame, "UIPanelCloseButton")
    AZPBossToolsSanctumFrame.closeButton:SetSize(20, 21)
    AZPBossToolsSanctumFrame.closeButton:SetPoint("TOPRIGHT", AZPBossToolsSanctumFrame, "TOPRIGHT", 1, 2)
    AZPBossToolsSanctumFrame.closeButton:SetScript("OnClick", function() AZPBossToolsSanctumFrame:Hide() end)

    AZP.BossTools.AZPBossToolsSanctumFrame = AZPBossToolsSanctumFrame
    AZPBossToolsSanctumFrame:Hide()
end

function AZP.BossTools:CreateSepulcherSelectorFrame()
    AZPBossToolsSepulcherFrame = CreateFrame("FRAME", nil, UIParent, "BackdropTemplate")
    AZPBossToolsSepulcherFrame:SetPoint("CENTER", 0, 0)
    AZPBossToolsSepulcherFrame.Background = AZPBossToolsSepulcherFrame:CreateTexture(nil, "ARTWORK")
    AZPBossToolsSepulcherFrame.Background:SetPoint("CENTER", 0, 0)
    AZPBossToolsSepulcherFrame.Background:SetTexture(AZP.BossTools.BossInfo.Sepulcher.Background)
    AZPBossToolsSepulcherFrame.Background:SetTexCoord(0.03425, 0.72525, 0.0585, 0.60)
    AZPBossToolsSepulcherFrame.Background:SetAlpha(0.8)
    AZPBossToolsSepulcherFrame:SetBackdrop({
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })

    AZPBossToolsSepulcherFrame.Header = AZPBossToolsSepulcherFrame:CreateFontString("AZPBossToolsSepulcherFrame", "ARTWORK", "GameFontNormalHuge")
    AZPBossToolsSepulcherFrame.Header:SetSize(AZPBossToolsSepulcherFrame:GetWidth(), 25)
    AZPBossToolsSepulcherFrame.Header:SetPoint("TOP", 0, -15)
    AZPBossToolsSepulcherFrame.Header:SetText(string.format("AzerPUG's BossTools v%s", AZP.VersionControl["BossTools"]))

    AZPBossToolsSepulcherFrame.SubHeader = AZPBossToolsSepulcherFrame:CreateFontString("AZPBossToolsSepulcherFrame", "ARTWORK", "GameFontNormalLarge")
    AZPBossToolsSepulcherFrame.SubHeader:SetSize(AZPBossToolsSepulcherFrame:GetWidth(), 50)
    AZPBossToolsSepulcherFrame.SubHeader:SetPoint("TOP", AZPBossToolsSepulcherFrame.Header, "BOTTOM", 0, 5)
    AZPBossToolsSepulcherFrame.SubHeader:SetText("Sepulcher of the First Ones\nBoss Selector Frame")

    local BossWidth, BossHeight = 100, 75

    for Boss, Info in pairs(AZP.BossTools.BossInfo.Sepulcher) do
        if Boss ~= "Background" then
            if Info.Active ~= false then
                local curFrame = CreateFrame("FRAME", nil, AZPBossToolsSepulcherFrame)
                curFrame:SetSize(BossWidth, BossHeight)
                curFrame:SetScript("OnMouseDown", function() if AZP.BossTools.BossFrames[Boss] ~= nil then  AZPBossToolsSepulcherFrame:Hide() AZP.BossTools.BossFrames[Boss]:Show() end end)
                curFrame.Button = curFrame:CreateTexture(nil, "ARTWORK")
                curFrame.Button:SetSize(curFrame:GetWidth(), 55)
                curFrame.Button:SetPoint("BOTTOM", 0, 0)
                curFrame.Button:SetTexture(Info.FileID)
                curFrame.Label = curFrame:CreateFontString("AZPBossToolsSepulcherFrame", "ARTWORK", "GameFontNormalLarge")
                curFrame.Label:SetSize(curFrame:GetWidth() -20, 25)
                curFrame.Label:SetPoint("TOP", -10, -5)
                curFrame.Label:SetText(Info.Name)

                if Info.Active == "Soon" then
                    curFrame.Button:SetDesaturated(true)
                    curFrame.ComingSoon = curFrame:CreateFontString("AZPBossToolsSepulcherFrame", "ARTWORK", "GameFontNormalLarge")
                    curFrame.ComingSoon:SetSize(curFrame:GetWidth() -20, 50)
                    curFrame.ComingSoon:SetPoint("TOP", -10, -25)
                    curFrame.ComingSoon:SetText("Coming\nSoon!")
                end

                curFrame.Index = Info.Index
                AZP.BossTools.BossIcons.Sepulcher[#AZP.BossTools.BossIcons.Sepulcher + 1] = curFrame
            end
        end
    end

    local iconsPerRow = {math.floor(#AZP.BossTools.BossIcons.Sepulcher / 2), math.ceil(#AZP.BossTools.BossIcons.Sepulcher / 2)}
    local FrameWidth = (iconsPerRow[2] * 85 + 25)
    if FrameWidth < 280 then FrameWidth = 280 end
    AZPBossToolsSepulcherFrame:SetSize(FrameWidth, FrameWidth - 15)
    AZPBossToolsSepulcherFrame.Background:SetSize(AZPBossToolsSepulcherFrame:GetWidth() - 5, AZPBossToolsSepulcherFrame:GetHeight() - 5)

    table.sort(AZP.BossTools.BossIcons.Sepulcher, function(a,b) return a.Index < b.Index end)

    if #AZP.BossTools.BossIcons.Sepulcher == 0 then return
    elseif #AZP.BossTools.BossIcons.Sepulcher > 0 then
        for i = 1, #AZP.BossTools.BossIcons.Sepulcher do
            local BottomOffset = {[1] = 0, [2] = 8, [3] =  9, [4] = 10, [5] = 13,}
            local   LeftOffset = {[1] = 0, [2] = 35, [3] = 22, [4] = 17, [5] = 11,}
            if i == 1 then AZP.BossTools.BossIcons.Sepulcher[i]:SetPoint("BOTTOM", (-35 * iconsPerRow[1]) + LeftOffset[iconsPerRow[1]], 100)
            elseif i == (iconsPerRow[1] + 1) then AZP.BossTools.BossIcons.Sepulcher[i]:SetPoint("BOTTOM", (-35 * iconsPerRow[2]) + LeftOffset[iconsPerRow[2]], BottomOffset[iconsPerRow[2]])
            else AZP.BossTools.BossIcons.Sepulcher[i]:SetPoint("LEFT", AZP.BossTools.BossIcons.Sepulcher[i-1], "RIGHT", -10, 0) end
        end
    end

    AZPBossToolsSepulcherFrame.closeButton = CreateFrame("Button", nil, AZPBossToolsSepulcherFrame, "UIPanelCloseButton")
    AZPBossToolsSepulcherFrame.closeButton:SetSize(20, 21)
    AZPBossToolsSepulcherFrame.closeButton:SetPoint("TOPRIGHT", AZPBossToolsSepulcherFrame, "TOPRIGHT", 1, 2)
    AZPBossToolsSepulcherFrame.closeButton:SetScript("OnClick", function() AZPBossToolsSepulcherFrame:Hide() end)

    AZP.BossTools.AZPBossToolsSepulcherFrame = AZPBossToolsSepulcherFrame
    AZPBossToolsSepulcherFrame:Hide()
end

function AZP.BossTools:CreateReceiveFrame()
    AZP.BossTools.ReceiveFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    AZP.BossTools.ReceiveFrame:SetPoint("CENTER", 0, 250)
    AZP.BossTools.ReceiveFrame:SetSize(250, 125)
    AZP.BossTools.ReceiveFrame:EnableMouse(true)
    AZP.BossTools.ReceiveFrame:SetMovable(true)
    AZP.BossTools.ReceiveFrame:RegisterForDrag("LeftButton")
    AZP.BossTools.ReceiveFrame:SetScript("OnDragStart", AZP.BossTools.ReceiveFrame.StartMoving)
    AZP.BossTools.ReceiveFrame:SetScript("OnDragStop", function() AZP.BossTools.ReceiveFrame:StopMovingOrSizing() end)
    AZP.BossTools.ReceiveFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    AZP.BossTools.ReceiveFrame:SetBackdropColor(0.25, 0.25, 0.25, 0.80)
    AZP.BossTools.ReceiveFrame.header = AZP.BossTools.ReceiveFrame:CreateFontString("UpdateFrame", "ARTWORK", "GameFontNormalHuge")
    AZP.BossTools.ReceiveFrame.header:SetPoint("TOP", 0, -10)
    AZP.BossTools.ReceiveFrame.header:SetText("Received data")

    AZP.BossTools.ReceiveFrame.subHeader = AZP.BossTools.ReceiveFrame:CreateFontString("UpdateFrame", "ARTWORK", "GameFontNormalLarge")
    AZP.BossTools.ReceiveFrame.subHeader:SetPoint("TOP", AZP.BossTools.ReceiveFrame.header, "BOTTOM", 0, -15)
    AZP.BossTools.ReceiveFrame.subHeader:SetText("Received data for %s\nSent by %s")
    AZP.BossTools.ReceiveFrame.subHeader:SetWidth(225)
    AZP.BossTools.ReceiveFrame.subHeader:SetJustifyH("LEFT")

    AZP.BossTools.ReceiveFrame.openButton = CreateFrame("Button", nil, AZP.BossTools.ReceiveFrame, "UIPanelButtonTemplate")
    AZP.BossTools.ReceiveFrame.openButton:SetSize(100, 25)
    AZP.BossTools.ReceiveFrame.openButton:SetPoint("BOTTOM", 0, 10)
    AZP.BossTools.ReceiveFrame.openButton:SetText("Open")
    AZP.BossTools.ReceiveFrame.openButton:SetScript("OnClick", function() AZP.BossTools:ShowCurrentDataFrame() end)

    AZP.BossTools.ReceiveFrame.closeButton = CreateFrame("Button", nil, AZP.BossTools.ReceiveFrame, "UIPanelCloseButton")
    AZP.BossTools.ReceiveFrame.closeButton:SetSize(20, 21)
    AZP.BossTools.ReceiveFrame.closeButton:SetPoint("TOPRIGHT", AZP.BossTools.ReceiveFrame, "TOPRIGHT", 1, 2)
    AZP.BossTools.ReceiveFrame.closeButton:SetScript("OnClick", function() AZP.BossTools.ReceiveFrame:Hide() end)

    AZP.BossTools.ReceiveFrame:Hide()
end

function AZP.BossTools:ShowCurrentDataFrame()
    AZP.BossTools:ShowBossFrame(AZP.BossTools.ReceiveFrame.Boss)
    AZP.BossTools.ReceiveFrame:Hide()
end

function AZP.BossTools:ShowReceiveFrame(sender, raid, boss)
    local bossInfo = AZP.BossTools.BossInfo[raid][boss]
    if bossInfo ~= nil then
        AZP.BossTools.ReceiveFrame.Boss = boss
        AZP.BossTools.ReceiveFrame.subHeader:SetText(string.format("Received data for %s\nSent by %s", bossInfo.Name, sender))
    end
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
    elseif classIndex == 13 then return 0.20, 0.58, 0.50, "33937F"      -- Evoker
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

AZP.SlashCommands["BTA"] = function()
    if AZPBossToolsSanctumFrame ~= nil then AZPBossToolsSanctumFrame:Show() end
end

AZP.SlashCommands["BT"] = function()
    if AZPBossToolsSepulcherFrame ~= nil then AZPBossToolsSepulcherFrame:Show() end
end

AZP.SlashCommands["bt"] = AZP.SlashCommands["BT"]
AZP.SlashCommands["boss tools"] = AZP.SlashCommands["BT"]
AZP.SlashCommands["Boss Tools"] = AZP.SlashCommands["BT"]
AZP.SlashCommands["bosstools"] = AZP.SlashCommands["BT"]
AZP.SlashCommands["BossTools"] = AZP.SlashCommands["BT"]

AZP.SlashCommands["bta"] = AZP.SlashCommands["BTA"]
AZP.SlashCommands["boos tools all"] = AZP.SlashCommands["BTA"]
AZP.SlashCommands["Boss Tools All"] = AZP.SlashCommands["BTA"]
AZP.SlashCommands["bosstoolsall"] = AZP.SlashCommands["BTA"]
AZP.SlashCommands["BossToolsAll"] = AZP.SlashCommands["BTA"]
AZP.SlashCommands["BTO"] = AZP.SlashCommands["BTA"]
AZP.SlashCommands["bto"] = AZP.SlashCommands["BTA"]
AZP.SlashCommands["boos tools old"] = AZP.SlashCommands["BTA"]
AZP.SlashCommands["Boss Tools Old"] = AZP.SlashCommands["BTA"]
AZP.SlashCommands["bosstoolsold"] = AZP.SlashCommands["BTA"]
AZP.SlashCommands["BossToolsOld"] = AZP.SlashCommands["BTA"]


-- Remove in next version, temporary fix to remove old data.
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("VARIABLES_LOADED")
EventFrame:SetScript("OnEvent", function ()
    AZPBTTheEyeSides = nil
    AZPBTDormazainChains = nil
    AZPBTRohKalo = nil
    RKAnnounceCoE = nil
    AZPBTLordsOfDreadVotes = nil
    AZPBTAnduinGroups = nil
end)