if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Dormazain == nil then AZP.BossTools.Dormazain = {} end
if AZP.BossTools.Dormazain.Events == nil then AZP.BossTools.Dormazain.Events = {} end

local AssignedPlayers = {}
local AZPBTDormazainGUIDs, AZPBTDormazainLeftEditBoxes, AZPBTDormazainMidEditBoxes, AZPBTDormazainRightEditBoxes = {}, {}, {}, {}

local ChainsCount = 0

local DormazainFrame, DormazainOptions, EventFrame = nil, nil, nil

local dragging, previousParent, previousPoint = false, nil, {}

function AZP.BossTools.Dormazain:OnLoadBoth()
    for i=1,6 do
        local chainsSet = string.format("Chain%d", i)
        AssignedPlayers[chainsSet] = {}
    end

    DormazainOptions = CreateFrame("FRAME", nil, UIParent, "BackdropTemplate")
    DormazainOptions:SetSize(700, 400)
    DormazainOptions:SetPoint("CENTER", 0, 0)
    DormazainOptions:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    DormazainOptions:SetBackdropColor(1, 1, 1, 1)
    DormazainOptions:EnableMouse(true)
    DormazainOptions:SetMovable(true)
    DormazainOptions:RegisterForDrag("LeftButton")
    DormazainOptions:SetScript("OnDragStart", DormazainOptions.StartMoving)
    DormazainOptions:SetScript("OnDragStop", function() DormazainOptions:StopMovingOrSizing() end)
    AZP.BossTools.Dormazain:FillOptionsPanel(DormazainOptions)
    AZP.BossTools.Dormazain:CreateMainFrame()
end

function AZP.BossTools.Dormazain:OnLoadSelf()
    C_ChatInfo.RegisterAddonMessagePrefix("AZPDORMINFO")

    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:RegisterEvent("ENCOUNTER_END")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Dormazain:OnEvent(...) end)

    AZP.BossTools.Dormazain:OnLoadBoth()
end

function AZP.BossTools.Dormazain:CreateMainFrame()
    DormazainFrame = CreateFrame("FRAME", nil, UIPanel, "BackdropTemplate")
    AZP.BossTools.BossFrames.Dormazain = DormazainFrame
    DormazainFrame:SetSize(300, 125)
    DormazainFrame:SetPoint("TOPLEFT", 100, -200)
    DormazainFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    DormazainFrame:EnableMouse(true)
    DormazainFrame:SetMovable(true)
    DormazainFrame:RegisterForDrag("LeftButton")
    DormazainFrame:SetScript("OnDragStart", DormazainFrame.StartMoving)
    DormazainFrame:SetScript("OnDragStop", function() DormazainFrame:StopMovingOrSizing() end)

    DormazainFrame.Header = DormazainFrame:CreateFontString("DormazainFrame", "ARTWORK", "GameFontNormalHuge")
    DormazainFrame.Header:SetSize(DormazainFrame:GetWidth(), 25)
    DormazainFrame.Header:SetPoint("TOP", 0, -5)
    DormazainFrame.Header:SetText("Chains Assignments")

    DormazainFrame.TextLabels = {}
    DormazainFrame.LeftLabels = {}
    DormazainFrame.MidLabels = {}
    DormazainFrame.RightLabels = {}

    for i = 1, 5 do
        DormazainFrame.TextLabels[i] = DormazainFrame:CreateFontString("DormazainFrame", "ARTWORK", "GameFontNormal")
        DormazainFrame.TextLabels[i]:SetSize(50, 25)
        DormazainFrame.TextLabels[i]:SetPoint("TOPLEFT", 0, ((i - 1) * -15) -35)
        DormazainFrame.TextLabels[i]:SetJustifyH("RIGHT")
        DormazainFrame.TextLabels[i]:SetText(string.format("Set %d:", i))

        DormazainFrame.LeftLabels[i] = DormazainFrame:CreateFontString("DormazainFrame", "ARTWORK", "GameFontNormal")
        DormazainFrame.LeftLabels[i]:SetSize(75, 25)
        DormazainFrame.LeftLabels[i]:SetPoint("LEFT", DormazainFrame.TextLabels[i], "RIGHT", 5, 0)
        DormazainFrame.LeftLabels[i]:SetJustifyH("MIDDLE")
        DormazainFrame.LeftLabels[i]:SetText("-")

        DormazainFrame.MidLabels[i] = DormazainFrame:CreateFontString("DormazainFrame", "ARTWORK", "GameFontNormal")
        DormazainFrame.MidLabels[i]:SetSize(75, 25)
        DormazainFrame.MidLabels[i]:SetPoint("LEFT", DormazainFrame.LeftLabels[i], "RIGHT", 5, 0)
        DormazainFrame.MidLabels[i]:SetJustifyH("MIDDLE")
        DormazainFrame.MidLabels[i]:SetText("-")

        DormazainFrame.RightLabels[i] = DormazainFrame:CreateFontString("DormazainFrame", "ARTWORK", "GameFontNormal")
        DormazainFrame.RightLabels[i]:SetSize(75, 25)
        DormazainFrame.RightLabels[i]:SetPoint("LEFT", DormazainFrame.MidLabels[i], "RIGHT", 5, 0)
        DormazainFrame.RightLabels[i]:SetJustifyH("MIDDLE")
        DormazainFrame.RightLabels[i]:SetText("-")
    end

    DormazainFrame.OptionsButton = CreateFrame("Button", nil, DormazainFrame, "UIPanelButtonTemplate")
    DormazainFrame.OptionsButton:SetSize(12, 12)
    DormazainFrame.OptionsButton:SetPoint("TOPLEFT", DormazainFrame, "TOPLEFT", 2, 0)
    DormazainFrame.OptionsButton:SetScript("OnClick", function() DormazainOptions:Show() end)
    DormazainFrame.OptionsButton.Texture = DormazainFrame.OptionsButton:CreateTexture(nil, "ARTWORK")
    DormazainFrame.OptionsButton.Texture:SetSize(10, 10)
    DormazainFrame.OptionsButton.Texture:SetPoint("CENTER", 0, 0)
    DormazainFrame.OptionsButton.Texture:SetTexture(GetFileIDFromPath("Interface\\GossipFrame\\HealerGossipIcon"))

    DormazainFrame.CloseButton = CreateFrame("Button", nil, DormazainFrame, "UIPanelCloseButton")
    DormazainFrame.CloseButton:SetSize(20, 21)
    DormazainFrame.CloseButton:SetPoint("TOPRIGHT", DormazainFrame, "TOPRIGHT", 2, 2)
    DormazainFrame.CloseButton:SetScript("OnClick", function() DormazainFrame:Hide() end)

    DormazainFrame:Hide()
end

function AZP.BossTools.Dormazain:FillOptionsPanel(frameToFill)
    frameToFill.header = frameToFill:CreateFontString("frameToFill", "ARTWORK", "GameFontNormalHuge")
    frameToFill.header:SetPoint("TOP", 0, -10)
    frameToFill.header:SetText("|cFF00FFFFAzerPUG's BossTools Options!|r")
    frameToFill.SubHeader = frameToFill:CreateFontString("frameToFill", "ARTWORK", "GameFontNormalLarge")
    frameToFill.SubHeader:SetPoint("TOP", 0, -35)
    frameToFill.SubHeader:SetText("|cFF00FFFFDormazain|r")

    frameToFill.footer = frameToFill:CreateFontString("frameToFill", "ARTWORK", "GameFontNormalLarge")
    frameToFill.footer:SetPoint("TOP", 0, -400)
    frameToFill.footer:SetText(
        "|cFF00FFFFAzerPUG Links:\n" ..
        "Website: www.azerpug.com\n" ..
        "Discord: www.azerpug.com/discord\n" ..
        "Twitch: www.twitch.tv/azerpug\n|r"
    )

    frameToFill.ShareButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.ShareButton:SetSize(100, 25)
    frameToFill.ShareButton:SetPoint("TOPRIGHT", -25, -50)
    frameToFill.ShareButton:SetText("Share List")
    frameToFill.ShareButton:SetScript("OnClick", function() AZP.BossTools.Dormazain:ShareAssignees() end )

    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -25, -75)
    frameToFill.LockMoveButton:SetText("Lock Frame")
    frameToFill.LockMoveButton:SetScript("OnClick", function ()
        if DormazainFrame:IsMovable() then
            DormazainFrame:EnableMouse(false)
            DormazainFrame:SetMovable(false)
            frameToFill.LockMoveButton:SetText("UnLock Frame!")
        else
            DormazainFrame:EnableMouse(true)
            DormazainFrame:SetMovable(true)
            frameToFill.LockMoveButton:SetText("Lock Frame")
        end
    end)

    frameToFill.ShowHideButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.ShowHideButton:SetSize(100, 25)
    frameToFill.ShowHideButton:SetPoint("TOPRIGHT", -25, -100)
    frameToFill.ShowHideButton:SetText("Hide Frame!")
    frameToFill.ShowHideButton:SetScript("OnClick", function () AZP.BossTools.Dormazain:ShowHideFrame() end)

    frameToFill.textlabels = {}

    frameToFill.LeftHeader = frameToFill:CreateFontString("LeftChainFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.LeftHeader:SetSize(100, 25)
    frameToFill.LeftHeader:SetPoint("TOPLEFT", 70, -100)
    frameToFill.LeftHeader:SetText("Left")

    frameToFill.MidHeader = frameToFill:CreateFontString("LeftChainFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.MidHeader:SetSize(100, 25)
    frameToFill.MidHeader:SetPoint("LEFT", frameToFill.LeftHeader, "RIGHT", 10, 0)
    frameToFill.MidHeader:SetText("Mid")

    frameToFill.RightHeader = frameToFill:CreateFontString("LeftChainFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.RightHeader:SetSize(100, 25)
    frameToFill.RightHeader:SetPoint("LEFT", frameToFill.MidHeader, "RIGHT", 10, 0)
    frameToFill.RightHeader:SetText("Right")

    for i = 1,5 do
        frameToFill.textlabels[i] = frameToFill:CreateFontString("frameToFill", "ARTWORK", "GameFontNormalLarge")
        frameToFill.textlabels[i]:SetSize(50, 25)
        frameToFill.textlabels[i]:SetPoint("TOPLEFT", 10, -30 * i - 100)
        frameToFill.textlabels[i]:SetText(string.format("Set %d:", i))

        AZPBTDormazainLeftEditBoxes[i] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTDormazainLeftEditBoxes[i]:SetSize(100, 25)
        AZPBTDormazainLeftEditBoxes[i]:SetPoint("LEFT", frameToFill.textlabels[i], "RIGHT", 10, 0)
        AZPBTDormazainLeftEditBoxes[i]:SetFrameStrata("HIGH")
        AZPBTDormazainLeftEditBoxes[i]:SetFrameLevel(10)
        AZPBTDormazainLeftEditBoxes[i]:SetScript("OnEnter", function() AZP.BossTools.Dormazain:StartHoverOverCopy(AZPBTDormazainLeftEditBoxes[i]) end)
        AZPBTDormazainLeftEditBoxes[i]:SetScript("OnLeave", function() AZP.BossTools.Dormazain:StopHoverOverCopy(AZPBTDormazainLeftEditBoxes[i]) end)
        AZPBTDormazainLeftEditBoxes[i]:SetScript("OnMouseDown", function() AZPBTDormazainLeftEditBoxes[i].EditBox:SetFocus() end)
        AZPBTDormazainLeftEditBoxes[i].EditBox = CreateFrame("EditBox", nil, AZPBTDormazainLeftEditBoxes[i], "InputBoxTemplate BackdropTemplate")
        AZPBTDormazainLeftEditBoxes[i].EditBox:SetSize(100, 25)
        AZPBTDormazainLeftEditBoxes[i].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTDormazainLeftEditBoxes[i].EditBox:SetFrameLevel(5)
        AZPBTDormazainLeftEditBoxes[i].EditBox:SetAutoFocus(false)
        AZPBTDormazainLeftEditBoxes[i].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Dormazain:OnEditFocusLost("Left", i) end)
        AZPBTDormazainLeftEditBoxes[i].EditBox:SetScript("OnTextSet", function() AZP.BossTools.Dormazain:OnEditFocusLost("Left", i) end)
        AZPBTDormazainLeftEditBoxes[i].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTDormazainLeftEditBoxes[i].EditBox:SetBackdropColor(1, 1, 1, 1)

        AZPBTDormazainMidEditBoxes[i] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTDormazainMidEditBoxes[i]:SetSize(100, 25)
        AZPBTDormazainMidEditBoxes[i]:SetPoint("LEFT", AZPBTDormazainLeftEditBoxes[i], "RIGHT", 10, 0)
        AZPBTDormazainMidEditBoxes[i]:SetFrameStrata("HIGH")
        AZPBTDormazainMidEditBoxes[i]:SetFrameLevel(10)
        AZPBTDormazainMidEditBoxes[i]:SetScript("OnEnter", function() AZP.BossTools.Dormazain:StartHoverOverCopy(AZPBTDormazainMidEditBoxes[i]) end)
        AZPBTDormazainMidEditBoxes[i]:SetScript("OnLeave", function() AZP.BossTools.Dormazain:StopHoverOverCopy(AZPBTDormazainMidEditBoxes[i]) end)
        AZPBTDormazainMidEditBoxes[i]:SetScript("OnMouseDown", function() AZPBTDormazainMidEditBoxes[i].EditBox:SetFocus() end)
        AZPBTDormazainMidEditBoxes[i].EditBox = CreateFrame("EditBox", nil, AZPBTDormazainMidEditBoxes[i], "InputBoxTemplate BackdropTemplate")
        AZPBTDormazainMidEditBoxes[i].EditBox:SetSize(100, 25)
        AZPBTDormazainMidEditBoxes[i].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTDormazainMidEditBoxes[i].EditBox:SetFrameLevel(5)
        AZPBTDormazainMidEditBoxes[i].EditBox:SetAutoFocus(false)
        AZPBTDormazainMidEditBoxes[i].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Dormazain:OnEditFocusLost("Mid", i) end)
        AZPBTDormazainMidEditBoxes[i].EditBox:SetScript("OnTextSet", function() AZP.BossTools.Dormazain:OnEditFocusLost("Mid", i) end)
        AZPBTDormazainMidEditBoxes[i].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTDormazainMidEditBoxes[i].EditBox:SetBackdropColor(1, 1, 1, 1)

        AZPBTDormazainRightEditBoxes[i] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTDormazainRightEditBoxes[i]:SetSize(100, 25)
        AZPBTDormazainRightEditBoxes[i]:SetPoint("LEFT", AZPBTDormazainMidEditBoxes[i], "RIGHT", 10, 0)
        AZPBTDormazainRightEditBoxes[i]:SetFrameStrata("HIGH")
        AZPBTDormazainRightEditBoxes[i]:SetFrameLevel(10)
        AZPBTDormazainRightEditBoxes[i]:SetScript("OnEnter", function() AZP.BossTools.Dormazain:StartHoverOverCopy(AZPBTDormazainRightEditBoxes[i]) end)
        AZPBTDormazainRightEditBoxes[i]:SetScript("OnLeave", function() AZP.BossTools.Dormazain:StopHoverOverCopy(AZPBTDormazainRightEditBoxes[i]) end)
        AZPBTDormazainRightEditBoxes[i]:SetScript("OnMouseDown", function() AZPBTDormazainRightEditBoxes[i].EditBox:SetFocus() end)
        AZPBTDormazainRightEditBoxes[i].EditBox = CreateFrame("EditBox", nil, AZPBTDormazainRightEditBoxes[i], "InputBoxTemplate BackdropTemplate")
        AZPBTDormazainRightEditBoxes[i].EditBox:SetSize(100, 25)
        AZPBTDormazainRightEditBoxes[i].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTDormazainRightEditBoxes[i].EditBox:SetFrameLevel(5)
        AZPBTDormazainRightEditBoxes[i].EditBox:SetAutoFocus(false)
        AZPBTDormazainRightEditBoxes[i].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Dormazain:OnEditFocusLost("Right", i) end)
        AZPBTDormazainRightEditBoxes[i].EditBox:SetScript("OnTextSet", function() AZP.BossTools.Dormazain:OnEditFocusLost("Right", i) end)
        AZPBTDormazainRightEditBoxes[i].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTDormazainRightEditBoxes[i].EditBox:SetBackdropColor(1, 1, 1, 1)
    end

    frameToFill.AllNamesFrame = CreateFrame("FRAME", nil, frameToFill, "BackdropTemplate")
    frameToFill.AllNamesFrame:SetSize(100, 325)
    frameToFill.AllNamesFrame:SetPoint("TOPRIGHT", -150, -50)
    frameToFill.AllNamesFrame:SetFrameLevel(3)
    frameToFill.AllNamesFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frameToFill.AllNamesFrame:SetBackdropColor(1, 1, 1, 1)

    local allUnitNames = {}
    frameToFill.AllNamesFrame.allNameLabels = {}

    for i = 1, 40 do
        local name = UnitName("RAID"..i)
        if name ~= nil then
            local _, _, classIndex = UnitClass("RAID"..i)
            allUnitNames[i] = {name, classIndex}
        end
    end

    for Index, curNameClass in pairs(allUnitNames) do
        local curFrame = CreateFrame("FRAME", nil, frameToFill.AllNamesFrame, "BackdropTemplate")
        frameToFill.AllNamesFrame.allNameLabels[Index] = curFrame
        curFrame:SetSize(85, 20)
        curFrame:SetPoint("TOP", 0, -18 * Index + 15)
        curFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        curFrame:SetBackdropColor(1, 1, 1, 1)
        curFrame:SetScript("OnMouseDown", function() GemFrame = curFrame AZP.BossTools.Dormazain:StartHoveringCopy() end)
        curFrame:SetScript("OnMouseUp", function() AZP.BossTools.Dormazain:StopHoveringCopy() end)

        curFrame.NameLabel = curFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        curFrame.NameLabel:SetSize(85, 20)
        curFrame.NameLabel:SetPoint("CENTER", 0, 0)
        curFrame.NameLabel:SetText(string.format("\124cFF%s%s\124r", AZP.BossTools:GetClassHEXColor(curNameClass[2]), curNameClass[1]))
        curFrame.NameLabel.Name = curNameClass[1]
    end

    frameToFill.CloseButton = CreateFrame("Button", nil, frameToFill, "UIPanelCloseButton")
    frameToFill.CloseButton:SetSize(20, 21)
    frameToFill.CloseButton:SetPoint("TOPRIGHT", frameToFill, "TOPRIGHT", 2, 2)
    frameToFill.CloseButton:SetScript("OnClick", function() frameToFill:Hide() end)

    frameToFill:Hide()
end

function AZP.BossTools.Dormazain:OnEditFocusLost(position, chains)
    local editBoxFrame = nil
    local chainsSet = string.format("Chain%d", chains)
    if position == "Left" then
        editBoxFrame = AZPBTDormazainLeftEditBoxes[chains].EditBox
    elseif position == "Mid" then
        editBoxFrame = AZPBTDormazainMidEditBoxes[chains].EditBox
    elseif position == "Right" then
        editBoxFrame = AZPBTDormazainRightEditBoxes[chains].EditBox
    end
    if (editBoxFrame:GetText() ~= nil and editBoxFrame:GetText() ~= "") then
        for k = 1, 40 do
            local curName = GetRaidRosterInfo(k)
            if curName ~= nil then
                if string.find(curName, "-") then
                    curName = string.match(curName, "(.+)-")
                end
                if curName == editBoxFrame:GetText() then
                    local curGUID = UnitGUID("raid" .. k)
                    AZPBTDormazainGUIDs[curGUID] = curName
                    AssignedPlayers[chainsSet][position] = curGUID
                    AZP.BossTools.Dormazain:UpdateMainFrame()
                end
            end
        end
    else
        if AssignedPlayers[chainsSet] ~= nil then
            AssignedPlayers[chainsSet][position] = nil
        end
    end

    AZPBTDormazainChains = AssignedPlayers
end

function AZP.BossTools.Dormazain:ShareAssignees()
    for ring, players in pairs(AssignedPlayers) do
        if players ~= nil then
            local message = string.format("%s:%s:%s:%s", ring, players.Left or "", players.Mid or "", players.Right or "")
            C_ChatInfo.SendAddonMessage("AZPDORMINFO", message ,"RAID", 1)
        end
    end
end

function AZP.BossTools.Dormazain:CacheRaidNames()
    if IsInRaid() == true then
        for k = 1, 40 do
            local curName = GetRaidRosterInfo(k)
            if curName ~= nil then
                if string.find(curName, "-") then
                    curName = string.match(curName, "(.+)-")
                end
                local curGUID = UnitGUID("raid" .. k)
                AZPBTDormazainGUIDs[curGUID] = curName
            end
        end
    end
end

function AZP.BossTools.Dormazain:UpdateMainFrame()
    if IsInRaid() == false then
        print("BossTools Dormazain only works in raid.")
        return
    end
    local playerGUID = UnitGUID("player")

    for i = 1, 5 do
        local chainsSet = string.format("Chain%d", i)
        local set = AssignedPlayers[chainsSet]
        local left = set.Left
        local mid = set.Mid
        local right = set.Right

        if left ~= nil then
            local name = AZPBTDormazainGUIDs[left]
            if name == nil then name = "" end
            local curClassID = AZP.BossTools:GetClassIndexFromGUID(left) --Create custom function with param left, mid, right
            local _, _, _, curColor = AZP.BossTools:GetClassColor(curClassID)
            local curName = string.format("\124cFF%s%s\124r", curColor, name)
            AZP.BossTools.BossFrames.Dormazain.LeftLabels[i]:SetText(curName)
            AZPBTDormazainLeftEditBoxes[i]:SetText(name)
        else
            AZPBTDormazainLeftEditBoxes[i].EditBox:SetText("")
            DormazainFrame.LeftLabels[i]:SetText("")
        end
        if mid ~= nil then
            local name = AZPBTDormazainGUIDs[mid]
            if name == nil then name = "" end
            local curClassID = AZP.BossTools:GetClassIndexFromGUID(mid)
            local _, _, _, curColor = AZP.BossTools:GetClassColor(curClassID)
            local curName = string.format("\124cFF%s%s\124r", curColor, name)
            AZP.BossTools.BossFrames.Dormazain.MidLabels[i]:SetText(curName)
            AZPBTDormazainMidEditBoxes[i]:SetText(name)
        else
            AZPBTDormazainMidEditBoxes[i].EditBox:SetText("")
            DormazainFrame.MidLabels[i]:SetText("")
        end
        if right ~= nil then
            local name = AZPBTDormazainGUIDs[right]
            if name == nil then name = "" end
            local curClassID = AZP.BossTools:GetClassIndexFromGUID(right)
            local _, _, _, curColor = AZP.BossTools:GetClassColor(curClassID)
            local curName = string.format("\124cFF%s%s\124r", curColor, name)
            AZP.BossTools.BossFrames.Dormazain.RightLabels[i]:SetText(curName)
            AZPBTDormazainRightEditBoxes[i]:SetText(name)
        else
            AZPBTDormazainRightEditBoxes[i].EditBox:SetText("")
            DormazainFrame.RightLabels[i]:SetText("")
        end
    end
end

function AZP.BossTools.Dormazain:ReceiveAssignees(receiveAssignees)
    local chains, left, mid, right = string.match(receiveAssignees, "([^:]*):([^:]*):([^:]*):([^:]*)")
    if left == "" then left = nil end
    if mid == "" then mid = nil end
    if right == "" then right = nil end
    AssignedPlayers[chains] = {Left = left, Mid = mid, Right = right}
    AZPBTDormazainChains = AssignedPlayers
    AZP.BossTools.Dormazain:UpdateMainFrame()

    AZPBTDormazainChains = AssignedPlayers
end

function AZP.BossTools.Dormazain:StartHoveringCopy()
    dragging = true
    local v1, v2, v3, v4, v5 = GemFrame:GetPoint()
    previousPoint = {v1, v2, v3, v4, v5}
    previousParent = GemFrame:GetParent()
    GemFrame:SetBackdropColor(1, 0, 0, 0.75)
    GemFrame:ClearAllPoints()
    GemFrame:SetParent(UIParent)
    GemFrame:SetScript("OnUpdate", function()
        GemFrame:SetFrameStrata("HIGH")
        GemFrame:SetFrameLevel(6)
        local scale = 0.7 --GetCVar("UIScale") does not work, needs ElvUI scale, if ElvUI is used!
        local xVal, yVal = GetCursorPosition()
        GemFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", (xVal / scale), (yVal / scale))
    end)
end

function AZP.BossTools.Dormazain:StopHoveringCopy()
    GemFrame:SetScript("OnUpdate", nil)
    if previousParent ~= nil then
        if dragging == true then
            GemFrame:ClearAllPoints()
            GemFrame:SetParent(previousParent)
            GemFrame:SetPoint(previousPoint[1], previousPoint[2], previousPoint[3],previousPoint[4], previousPoint[5])
            if GemFrame.parent ~= nil then GemFrame.parent.EditBox:SetText(GemFrame.NameLabel.Name) end
            dragging = false
        end
    end
    GemFrame:SetBackdropColor(1, 1, 1, 1)
    GemFrame = nil
end

function AZP.BossTools.Dormazain:StartHoverOverCopy(SocketFrame)
    if dragging == true then
        GemFrame.parent = SocketFrame
        SocketFrame.EditBox:SetBackdropColor(0.25, 1, 0.25, 1)
    end
end

function AZP.BossTools.Dormazain:StopHoverOverCopy(SocketFrame)
    SocketFrame.EditBox:SetBackdropColor(1, 1, 1, 1)
    if GemFrame ~= nil then if GemFrame.parent ~= nil then GemFrame.parent = nil end end
end

function AZP.BossTools.Dormazain:ShowHideFrame()
    if DormazainFrame:IsShown() == true then DormazainFrame:Hide() DormazainOptions.ShowHideButton:SetText("Show Frame!")
    elseif DormazainFrame:IsShown() == false then DormazainFrame:Show() DormazainOptions.ShowHideButton:SetText("Hide Frame!") end
end

function AZP.BossTools.Dormazain:OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        AZP.BossTools.Dormazain.Events:CombatLogEventUnfiltered(...)
    elseif event == "CHAT_MSG_ADDON" then
        AZP.BossTools.Dormazain.Events:ChatMsgAddon(...)
    elseif event == "ENCOUNTER_END" then
        AZP.BossTools.Dormazain.Events:EncounterEnd(...)
    end
end

function AZP.BossTools.Dormazain.Events:CombatLogEventUnfiltered(...)
    local _, SubEvent, _, _, _, _, _, _, _, _, _, SpellID = CombatLogGetCurrentEventInfo()
    if SubEvent == "SPELL_AURA_APPLIED" then
        if SpellID == AZP.BossTools.IDs.Dormazain.Spell.WarmongerShackles then
            AZP.BossTools.Dormazain.Events:WarmongerShackles()
        end
    end
end

function AZP.BossTools.Dormazain.Events:EncounterEnd(...)
    ChainsCount = 0
end

function AZP.BossTools.Dormazain.Events:WarmongerShackles()
    ChainsCount = ChainsCount + 1
    local curChain = string.format("Chain%s", ChainsCount)
    local curGUID = UnitGUID("PLAYER")
    local assignedPosition = nil
    if AZPBTDormazainChains[curChain].Left == curGUID then assignedPosition = "Left" end
    if AZPBTDormazainChains[curChain].Mid == curGUID then assignedPosition = "Mid" end
    if AZPBTDormazainChains[curChain].Right == curGUID then assignedPosition = "Right" end

    if assignedPosition ~= nil then
        local warnText = string.format("ChainSet %d - Pick up %s!", ChainsCount, assignedPosition)
        AZP.BossTools:WarnPlayer(warnText)
    end
end

function AZP.BossTools.Dormazain.Events:ChatMsgAddon(...)
    local prefix, payload, _, sender = ...
    if prefix == "AZPDORMINFO" then
        AZP.BossTools.Dormazain:CacheRaidNames()
        AZP.BossTools.Dormazain:ReceiveAssignees(payload)
    end
end

AZP.BossTools.Dormazain:OnLoadSelf()