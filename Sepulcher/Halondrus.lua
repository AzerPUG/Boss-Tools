if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Sepulcher.Halondrus == nil then AZP.BossTools.Sepulcher.Halondrus = {} end
if AZP.BossTools.Sepulcher.Halondrus.Events == nil then AZP.BossTools.Sepulcher.Halondrus.Events = {} end

local AssignedPlayers = {Left = {}, Right = {},}
local AZPBTHalondrusOptions = nil
local AZPBTHalondrusGUIDs, AZPBTHalondrusLeftEditBoxes, AZPBTHalondrusRightEditBoxes = {}, {}, {}

local EventFrame = nil

local dragging, previousParent, previousPoint = false, nil, {}
local GemFrame = nil

function AZP.BossTools.Sepulcher.Halondrus:OnLoadBoth()
    HalondrusOptions = CreateFrame("FRAME", nil, UIParent, "BackdropTemplate")
    HalondrusOptions:SetSize(700, 400)
    HalondrusOptions:SetPoint("CENTER", 0, 0)
    HalondrusOptions:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    HalondrusOptions:SetBackdropColor(1, 1, 1, 1)
    HalondrusOptions:EnableMouse(true)
    HalondrusOptions:SetMovable(true)
    HalondrusOptions:RegisterForDrag("LeftButton")
    HalondrusOptions:SetScript("OnDragStart", HalondrusOptions.StartMoving)
    HalondrusOptions:SetScript("OnDragStop", function() HalondrusOptions:StopMovingOrSizing() end)
    AZP.BossTools.Sepulcher.Halondrus:FillOptionsPanel(HalondrusOptions)
    AZP.BossTools.Sepulcher.Halondrus:CreateMainFrame()
end

function AZP.BossTools.Sepulcher.Halondrus:OnLoadSelf()
    C_ChatInfo.RegisterAddonMessagePrefix("AZPSAUSAGEINFO")

    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Sepulcher.Halondrus:OnEvent(...) end)

    AZP.BossTools.Sepulcher.Halondrus:OnLoadBoth()
end

function AZP.BossTools.Sepulcher.Halondrus:CreateMainFrame()
    local HalondrusFrame = CreateFrame("FRAME", nil, UIPanel, "BackdropTemplate")
    HalondrusFrame:SetSize(350, 200)
    HalondrusFrame:SetPoint("TOPLEFT", 100, -200)
    HalondrusFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    HalondrusFrame:EnableMouse(true)
    HalondrusFrame:SetMovable(true)
    HalondrusFrame:RegisterForDrag("LeftButton")
    HalondrusFrame:SetScript("OnDragStart", HalondrusFrame.StartMoving)
    HalondrusFrame:SetScript("OnDragStop", function() HalondrusFrame:StopMovingOrSizing() end)

    HalondrusFrame.Header = HalondrusFrame:CreateFontString("HalondrusFrame", "ARTWORK", "GameFontNormalHuge")
    HalondrusFrame.Header:SetSize(HalondrusFrame:GetWidth(), 25)
    HalondrusFrame.Header:SetPoint("TOP", 0, -5)
    HalondrusFrame.Header:SetText("Sides Assignments")

    HalondrusFrame.Sepparator = CreateFrame("FRAME", nil, HalondrusFrame, "BackdropTemplate")
    HalondrusFrame.Sepparator:SetSize(3, 150)
    HalondrusFrame.Sepparator:SetPoint("BOTTOM", 0, 10)
    HalondrusFrame.Sepparator:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    })
    HalondrusFrame.Sepparator:SetBackdropColor(0, 0, 0, 1)

    HalondrusFrame.LeftLabels = {}
    HalondrusFrame.RightLabels = {}

    for i = 1, 10 do
        HalondrusFrame.LeftLabels[i] = HalondrusFrame:CreateFontString("HalondrusFrame", "ARTWORK", "GameFontNormal")
        HalondrusFrame.LeftLabels[i]:SetSize(75, 25)
        HalondrusFrame.LeftLabels[i]:SetPoint("TOPLEFT", 0, ((i - 1) * -15) -35)
        HalondrusFrame.LeftLabels[i]:SetJustifyH("MIDDLE")
        HalondrusFrame.LeftLabels[i]:SetText("-")

        HalondrusFrame.LeftLabels[i + 10] = HalondrusFrame:CreateFontString("HalondrusFrame", "ARTWORK", "GameFontNormal")
        HalondrusFrame.LeftLabels[i + 10]:SetSize(75, 25)
        HalondrusFrame.LeftLabels[i + 10]:SetPoint("LEFT", HalondrusFrame.LeftLabels[i], "RIGHT", 5, 0)
        HalondrusFrame.LeftLabels[i + 10]:SetJustifyH("MIDDLE")
        HalondrusFrame.LeftLabels[i + 10]:SetText("-")

        HalondrusFrame.RightLabels[i + 10] = HalondrusFrame:CreateFontString("HalondrusFrame", "ARTWORK", "GameFontNormal")
        HalondrusFrame.RightLabels[i + 10]:SetSize(75, 25)
        HalondrusFrame.RightLabels[i + 10]:SetPoint("TOPRIGHT", 0, ((i - 1) * -15) -35)
        HalondrusFrame.RightLabels[i + 10]:SetJustifyH("MIDDLE")
        HalondrusFrame.RightLabels[i + 10]:SetText("-")

        HalondrusFrame.RightLabels[i] = HalondrusFrame:CreateFontString("HalondrusFrame", "ARTWORK", "GameFontNormal")
        HalondrusFrame.RightLabels[i]:SetSize(75, 25)
        HalondrusFrame.RightLabels[i]:SetPoint("RIGHT", HalondrusFrame.RightLabels[i + 10], "LEFT", -5, 0)
        HalondrusFrame.RightLabels[i]:SetJustifyH("MIDDLE")
        HalondrusFrame.RightLabels[i]:SetText("-")
    end

    HalondrusFrame.OptionsButton = CreateFrame("Button", nil, HalondrusFrame, "UIPanelButtonTemplate")
    HalondrusFrame.OptionsButton:SetSize(12, 12)
    HalondrusFrame.OptionsButton:SetPoint("TOPLEFT", HalondrusFrame, "TOPLEFT", 2, 0)
    HalondrusFrame.OptionsButton:SetScript("OnClick", function() HalondrusOptions:Show() end)
    HalondrusFrame.OptionsButton.Texture = HalondrusFrame.OptionsButton:CreateTexture(nil, "ARTWORK")
    HalondrusFrame.OptionsButton.Texture:SetSize(10, 10)
    HalondrusFrame.OptionsButton.Texture:SetPoint("CENTER", 0, 0)
    HalondrusFrame.OptionsButton.Texture:SetTexture(GetFileIDFromPath("Interface\\GossipFrame\\HealerGossipIcon"))

    HalondrusFrame.closeButton = CreateFrame("Button", nil, HalondrusFrame, "UIPanelCloseButton")
    HalondrusFrame.closeButton:SetSize(20, 21)
    HalondrusFrame.closeButton:SetPoint("TOPRIGHT", HalondrusFrame, "TOPRIGHT", 2, 2)
    HalondrusFrame.closeButton:SetScript("OnClick", function() HalondrusFrame:Hide() end)

    AZP.BossTools.BossFrames.Halondrus = HalondrusFrame
    HalondrusFrame:Hide()
end

function AZP.BossTools.Sepulcher.Halondrus:FillOptionsPanel(frameToFill)
    frameToFill.Header = frameToFill:CreateFontString("frameToFill", "ARTWORK", "GameFontNormalHuge")
    frameToFill.Header:SetPoint("TOP", 0, -10)
    frameToFill.Header:SetText("|cFF00FFFFAzerPUG's BossTools Options!|r")
    frameToFill.SubHeader = frameToFill:CreateFontString("frameToFill", "ARTWORK", "GameFontNormalLarge")
    frameToFill.SubHeader:SetPoint("TOP", 0, -35)
    frameToFill.SubHeader:SetText("|cFF00FFFFThe Eye of the Jailer|r")

    frameToFill.ShareButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.ShareButton:SetSize(100, 25)
    frameToFill.ShareButton:SetPoint("TOPRIGHT", -50, -25)
    frameToFill.ShareButton:SetText("Share List")
    frameToFill.ShareButton:SetScript("OnClick", function() AZP.BossTools.Sepulcher.Halondrus:ShareAssignees() end )

    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -50, -55)
    frameToFill.LockMoveButton:SetText("Lock Frame")
    frameToFill.LockMoveButton:SetScript("OnClick", function ()
        if AZP.BossTools.BossFrames.Halondrus:IsMovable() then
            AZP.BossTools.BossFrames.Halondrus:EnableMouse(false)
            AZP.BossTools.BossFrames.Halondrus:SetMovable(false)
            frameToFill.LockMoveButton:SetText("UnLock Frame!")
        else
            AZP.BossTools.BossFrames.Halondrus:EnableMouse(true)
            AZP.BossTools.BossFrames.Halondrus:SetMovable(true)
            frameToFill.LockMoveButton:SetText("Lock Frame")
        end
    end)

    frameToFill.ShowHideButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.ShowHideButton:SetSize(100, 25)
    frameToFill.ShowHideButton:SetPoint("TOPRIGHT", -50, -85)
    frameToFill.ShowHideButton:SetText("Hide Frame!")
    frameToFill.ShowHideButton:SetScript("OnClick", function () AZP.BossTools.Sepulcher.Halondrus:ShowHideFrame() end)

    frameToFill.textlabels = {}

    frameToFill.LeftHeader = frameToFill:CreateFontString("LeftChainFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.LeftHeader:SetSize(160, 25)
    frameToFill.LeftHeader:SetPoint("TOPLEFT", 20, -75)
    frameToFill.LeftHeader:SetText("Left")

    frameToFill.RightHeader = frameToFill:CreateFontString("LeftChainFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.RightHeader:SetSize(160, 25)
    frameToFill.RightHeader:SetPoint("LEFT", frameToFill.LeftHeader, "RIGHT", 25, 0)
    frameToFill.RightHeader:SetText("Right")

    for i = 1,10 do
        AZPBTHalondrusLeftEditBoxes[i] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTHalondrusLeftEditBoxes[i]:SetSize(75, 25)
        AZPBTHalondrusLeftEditBoxes[i]:SetPoint("TOPLEFT", 20, -25 * i - 75)
        AZPBTHalondrusLeftEditBoxes[i]:SetFrameStrata("HIGH")
        AZPBTHalondrusLeftEditBoxes[i]:SetFrameLevel(10)
        AZPBTHalondrusLeftEditBoxes[i]:SetScript("OnEnter", function() AZP.BossTools.Sepulcher.Halondrus:StartHoverOverCopy(AZPBTHalondrusLeftEditBoxes[i]) end)
        AZPBTHalondrusLeftEditBoxes[i]:SetScript("OnLeave", function() AZP.BossTools.Sepulcher.Halondrus:StopHoverOverCopy(AZPBTHalondrusLeftEditBoxes[i]) end)
        AZPBTHalondrusLeftEditBoxes[i]:SetScript("OnMouseDown", function() AZPBTHalondrusLeftEditBoxes[i].EditBox:SetFocus() end)
        AZPBTHalondrusLeftEditBoxes[i].EditBox = CreateFrame("EditBox", nil, AZPBTHalondrusLeftEditBoxes[i], "InputBoxTemplate BackdropTemplate")
        AZPBTHalondrusLeftEditBoxes[i].EditBox:SetSize(AZPBTHalondrusLeftEditBoxes[i]:GetWidth(), AZPBTHalondrusLeftEditBoxes[i]:GetHeight())
        AZPBTHalondrusLeftEditBoxes[i].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTHalondrusLeftEditBoxes[i].EditBox:SetFrameLevel(5)
        AZPBTHalondrusLeftEditBoxes[i].EditBox:SetAutoFocus(false)
        AZPBTHalondrusLeftEditBoxes[i].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Sepulcher.Halondrus:OnEditFocusLost("Left", i) end)
        AZPBTHalondrusLeftEditBoxes[i].EditBox:SetScript("OnTextSet", function() AZP.BossTools.Sepulcher.Halondrus:OnEditFocusLost("Left", i) end)
        AZPBTHalondrusLeftEditBoxes[i].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTHalondrusLeftEditBoxes[i].EditBox:SetBackdropColor(1, 1, 1, 1)

        AZPBTHalondrusLeftEditBoxes[i + 10] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTHalondrusLeftEditBoxes[i + 10]:SetSize(75, 25)
        AZPBTHalondrusLeftEditBoxes[i + 10]:SetPoint("LEFT", AZPBTHalondrusLeftEditBoxes[i], "RIGHT", 10, 0)
        AZPBTHalondrusLeftEditBoxes[i + 10]:SetFrameStrata("HIGH")
        AZPBTHalondrusLeftEditBoxes[i + 10]:SetFrameLevel(10)
        AZPBTHalondrusLeftEditBoxes[i + 10]:SetScript("OnEnter", function() AZP.BossTools.Sepulcher.Halondrus:StartHoverOverCopy(AZPBTHalondrusLeftEditBoxes[i + 10]) end)
        AZPBTHalondrusLeftEditBoxes[i + 10]:SetScript("OnLeave", function() AZP.BossTools.Sepulcher.Halondrus:StopHoverOverCopy(AZPBTHalondrusLeftEditBoxes[i + 10]) end)
        AZPBTHalondrusLeftEditBoxes[i + 10]:SetScript("OnMouseDown", function() AZPBTHalondrusLeftEditBoxes[i + 10].EditBox:SetFocus() end)
        AZPBTHalondrusLeftEditBoxes[i + 10].EditBox = CreateFrame("EditBox", nil, AZPBTHalondrusLeftEditBoxes[i + 10], "InputBoxTemplate BackdropTemplate")
        AZPBTHalondrusLeftEditBoxes[i + 10].EditBox:SetSize(AZPBTHalondrusLeftEditBoxes[i + 10]:GetWidth(), AZPBTHalondrusLeftEditBoxes[i + 10]:GetHeight())
        AZPBTHalondrusLeftEditBoxes[i + 10].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTHalondrusLeftEditBoxes[i + 10].EditBox:SetFrameLevel(5)
        AZPBTHalondrusLeftEditBoxes[i + 10].EditBox:SetAutoFocus(false)
        AZPBTHalondrusLeftEditBoxes[i + 10].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Sepulcher.Halondrus:OnEditFocusLost("Left", i + 10) end)
        AZPBTHalondrusLeftEditBoxes[i + 10].EditBox:SetScript("OnTextSet", function() AZP.BossTools.Sepulcher.Halondrus:OnEditFocusLost("Left", i + 10) end)
        AZPBTHalondrusLeftEditBoxes[i + 10].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTHalondrusLeftEditBoxes[i + 10].EditBox:SetBackdropColor(1, 1, 1, 1)

        AZPBTHalondrusRightEditBoxes[i] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTHalondrusRightEditBoxes[i]:SetSize(75, 25)
        AZPBTHalondrusRightEditBoxes[i]:SetPoint("LEFT", AZPBTHalondrusLeftEditBoxes[i + 10], "RIGHT", 25, 0)
        AZPBTHalondrusRightEditBoxes[i]:SetFrameStrata("HIGH")
        AZPBTHalondrusRightEditBoxes[i]:SetFrameLevel(10)
        AZPBTHalondrusRightEditBoxes[i]:SetScript("OnEnter", function() AZP.BossTools.Sepulcher.Halondrus:StartHoverOverCopy(AZPBTHalondrusRightEditBoxes[i]) end)
        AZPBTHalondrusRightEditBoxes[i]:SetScript("OnLeave", function() AZP.BossTools.Sepulcher.Halondrus:StopHoverOverCopy(AZPBTHalondrusRightEditBoxes[i]) end)
        AZPBTHalondrusRightEditBoxes[i]:SetScript("OnMouseDown", function() AZPBTHalondrusRightEditBoxes[i].EditBox:SetFocus() end)
        AZPBTHalondrusRightEditBoxes[i].EditBox = CreateFrame("EditBox", nil, AZPBTHalondrusRightEditBoxes[i], "InputBoxTemplate BackdropTemplate")
        AZPBTHalondrusRightEditBoxes[i].EditBox:SetSize(AZPBTHalondrusRightEditBoxes[i]:GetWidth(), AZPBTHalondrusRightEditBoxes[i]:GetHeight())
        AZPBTHalondrusRightEditBoxes[i].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTHalondrusRightEditBoxes[i].EditBox:SetFrameLevel(5)
        AZPBTHalondrusRightEditBoxes[i].EditBox:SetAutoFocus(false)
        AZPBTHalondrusRightEditBoxes[i].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Sepulcher.Halondrus:OnEditFocusLost("Right", i) end)
        AZPBTHalondrusRightEditBoxes[i].EditBox:SetScript("OnTextSet", function() AZP.BossTools.Sepulcher.Halondrus:OnEditFocusLost("Right", i) end)
        AZPBTHalondrusRightEditBoxes[i].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTHalondrusRightEditBoxes[i].EditBox:SetBackdropColor(1, 1, 1, 1)

        AZPBTHalondrusRightEditBoxes[i + 10] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTHalondrusRightEditBoxes[i + 10]:SetSize(75, 25)
        AZPBTHalondrusRightEditBoxes[i + 10]:SetPoint("LEFT", AZPBTHalondrusRightEditBoxes[i], "RIGHT", 10, 0)
        AZPBTHalondrusRightEditBoxes[i + 10]:SetFrameStrata("HIGH")
        AZPBTHalondrusRightEditBoxes[i + 10]:SetFrameLevel(10)
        AZPBTHalondrusRightEditBoxes[i + 10]:SetScript("OnEnter", function() AZP.BossTools.Sepulcher.Halondrus:StartHoverOverCopy(AZPBTHalondrusRightEditBoxes[i + 10]) end)
        AZPBTHalondrusRightEditBoxes[i + 10]:SetScript("OnLeave", function() AZP.BossTools.Sepulcher.Halondrus:StopHoverOverCopy(AZPBTHalondrusRightEditBoxes[i + 10]) end)
        AZPBTHalondrusRightEditBoxes[i + 10]:SetScript("OnMouseDown", function() AZPBTHalondrusRightEditBoxes[i + 10].EditBox:SetFocus() end)
        AZPBTHalondrusRightEditBoxes[i + 10].EditBox = CreateFrame("EditBox", nil, AZPBTHalondrusRightEditBoxes[i + 10], "InputBoxTemplate BackdropTemplate")
        AZPBTHalondrusRightEditBoxes[i + 10].EditBox:SetSize(AZPBTHalondrusRightEditBoxes[i + 10]:GetWidth(), AZPBTHalondrusRightEditBoxes[i + 10]:GetHeight())
        AZPBTHalondrusRightEditBoxes[i + 10].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTHalondrusRightEditBoxes[i + 10].EditBox:SetFrameLevel(5)
        AZPBTHalondrusRightEditBoxes[i + 10].EditBox:SetAutoFocus(false)
        AZPBTHalondrusRightEditBoxes[i + 10].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Sepulcher.Halondrus:OnEditFocusLost("Right", i + 10) end)
        AZPBTHalondrusRightEditBoxes[i + 10].EditBox:SetScript("OnTextSet", function() AZP.BossTools.Sepulcher.Halondrus:OnEditFocusLost("Right", i + 10) end)
        AZPBTHalondrusRightEditBoxes[i + 10].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTHalondrusRightEditBoxes[i + 10].EditBox:SetBackdropColor(1, 1, 1, 1)
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
        curFrame:SetScript("OnMouseDown", function() GemFrame = curFrame AZP.BossTools.Sepulcher.Halondrus:StartHoveringCopy() end)
        curFrame:SetScript("OnMouseUp", function() AZP.BossTools.Sepulcher.Halondrus:StopHoveringCopy() end)

        curFrame.NameLabel = curFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        curFrame.NameLabel:SetSize(85, 20)
        curFrame.NameLabel:SetPoint("CENTER", 0, 0)
        local _, _, _, curClassColor = AZP.BossTools:GetClassColor(curNameClass[2])
        curFrame.NameLabel:SetText(string.format("\124cFF%s%s\124r", curClassColor, curNameClass[1]))
        curFrame.NameLabel.Name = curNameClass[1]
    end

    frameToFill.closeButton = CreateFrame("Button", nil, frameToFill, "UIPanelCloseButton")
    frameToFill.closeButton:SetSize(20, 21)
    frameToFill.closeButton:SetPoint("TOPRIGHT", frameToFill, "TOPRIGHT", 2, 2)
    frameToFill.closeButton:SetScript("OnClick", function() frameToFill:Hide() end)

    frameToFill:Hide()
end

function AZP.BossTools.Sepulcher.Halondrus:RefreshNames()
    local allUnitNames = {}
    local allNameLabels = HalondrusOptions.AllNamesFrame.allNameLabels

    for _, frame in ipairs(allNameLabels) do
        frame:Hide()
    end

    for i = 1, 40 do
        local name = UnitName("RAID"..i)
        if name ~= nil then
            local _, _, classIndex = UnitClass("RAID"..i)
            allUnitNames[i] = {name, classIndex}
        end
    end

    for Index, curNameClass in pairs(allUnitNames) do
        local curFrame = allNameLabels[Index]
        if curFrame == nil then
            curFrame = CreateFrame("FRAME", nil, HalondrusOptions.AllNamesFrame, "BackdropTemplate")
            allNameLabels[Index] = curFrame
            curFrame:SetSize(85, 20)
            curFrame:SetPoint("TOP", 0, -18 * Index + 15)
            curFrame:SetBackdrop({
                bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                edgeSize = 10,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            curFrame:SetBackdropColor(1, 1, 1, 1)
            curFrame:SetScript("OnMouseDown", function() GemFrame = curFrame AZP.BossTools.Sepulcher.Halondrus:StartHoveringCopy() end)
            curFrame:SetScript("OnMouseUp", function() AZP.BossTools.Sepulcher.Halondrus:StopHoveringCopy() end)

            curFrame.NameLabel = curFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            curFrame.NameLabel:SetSize(85, 20)
            curFrame.NameLabel:SetPoint("CENTER", 0, 0)
        end
        local _, _, _, curClassColor = AZP.BossTools:GetClassColor(curNameClass[2])
        if curClassColor == nil then return end
        curFrame.NameLabel:SetText(string.format("\124cFF%s%s\124r", curClassColor, curNameClass[1]))
        curFrame.NameLabel.Name = curNameClass[1]
        curFrame:Show()
    end
end

function AZP.BossTools.Sepulcher.Halondrus:OnEditFocusLost(sides, index)
    local editBoxFrame = nil
    if sides == "Left" then
        editBoxFrame = AZPBTHalondrusLeftEditBoxes[index].EditBox
    elseif sides == "Right" then
        editBoxFrame = AZPBTHalondrusRightEditBoxes[index].EditBox
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
                    AZPBTHalondrusGUIDs[curGUID] = curName
                    AssignedPlayers[sides][index] = curGUID
                    AZP.BossTools.Sepulcher.Halondrus:UpdateMainFrame()
                end
            end
        end
    else
        table.remove(AssignedPlayers[sides], index)
    end

    AZPBTHalondrusSides = AssignedPlayers
end

function AZP.BossTools.Sepulcher.Halondrus:GetRaidIDs(side)
    local FoundRaidIDs = nil
    for index, guid in ipairs(side) do
        for raidID=1,40 do
            if UnitGUID(string.format("raid%d", raidID)) == guid then
                if FoundRaidIDs == nil then
                    FoundRaidIDs = string.format("%d", raidID)
                else
                    FoundRaidIDs = string.format("%s,%d", FoundRaidIDs, raidID)
                end
            end
        end
    end
    return FoundRaidIDs
end

function AZP.BossTools.Sepulcher.Halondrus:ShareAssignees()
    for ring, players in pairs(AssignedPlayers) do
        if players ~= nil then
            local leftPlayerString = AZP.BossTools.Sepulcher.Halondrus:GetRaidIDs(AssignedPlayers.Left)
            local rightPlayerString = AZP.BossTools.Sepulcher.Halondrus:GetRaidIDs(AssignedPlayers.Right)
            local message = string.format("%s:%s", leftPlayerString or "", rightPlayerString or "")
            C_ChatInfo.SendAddonMessage("AZPSAUSAGEINFO", message ,"RAID", 1)
        end
    end
end

function AZP.BossTools.Sepulcher.Halondrus:ReceiveAssignees(receiveAssignees)
    local left, right = string.match(receiveAssignees, "([^:]*):([^:]*)")
    AssignedPlayers.Left = {}
    AssignedPlayers.Right = {}
    for RaidID in string.gmatch(left, "%d+") do
        table.insert(AssignedPlayers.Left, UnitGUID(string.format("raid%d", RaidID)))
    end

    for RaidID in string.gmatch(right, "%d+") do
        table.insert(AssignedPlayers.Right, UnitGUID(string.format("raid%d", RaidID)))
    end

    AZP.BossTools.Sepulcher.Halondrus:UpdateMainFrame()
end

function AZP.BossTools.Sepulcher.Halondrus:CacheRaidNames()
    if IsInRaid() == true then
        for k = 1, 40 do
            local curName = GetRaidRosterInfo(k)
            if curName ~= nil then
                if string.find(curName, "-") then
                    curName = string.match(curName, "(.+)-")
                end
                local curGUID = UnitGUID("raid" .. k)
                AZPBTHalondrusGUIDs[curGUID] = curName
            end
        end
    end
end

function AZP.BossTools.Sepulcher.Halondrus:UpdateMainFrame()
    if IsInRaid() == false then
        return
    end
    local playerGUID = UnitGUID("player")
    AZPBTHalondrusSides = AssignedPlayers

    for i = 1, 20 do
        local left = AssignedPlayers.Left[i]
        local right = AssignedPlayers.Right[i]

        if left ~= nil then
            local name = AZPBTHalondrusGUIDs[left]
            if name == nil then name = "" end
            local curClassID = AZP.BossTools:GetClassIndexFromGUID(left)
            local _, _, _, curColor = AZP.BossTools:GetClassColor(curClassID)
            local curName = string.format("\124cFF%s%s\124r", curColor, name)
            AZP.BossTools.BossFrames.Halondrus.LeftLabels[i]:SetText(curName)
            AZPBTHalondrusLeftEditBoxes[i].EditBox:SetText(name)
        else
            AZPBTHalondrusLeftEditBoxes[i].EditBox:SetText("")
            AZP.BossTools.BossFrames.Halondrus.LeftLabels[i]:SetText("")
        end
        if right ~= nil then
            local name = AZPBTHalondrusGUIDs[right]
            if name == nil then name = "" end
            local curClassID = AZP.BossTools:GetClassIndexFromGUID(right)
            local _, _, _, curColor = AZP.BossTools:GetClassColor(curClassID)
            local curName = string.format("\124cFF%s%s\124r", curColor, name)
            AZP.BossTools.BossFrames.Halondrus.RightLabels[i]:SetText(curName)
            AZPBTHalondrusRightEditBoxes[i].EditBox:SetText(name)
        else
            AZPBTHalondrusRightEditBoxes[i].EditBox:SetText("")
            AZP.BossTools.BossFrames.Halondrus.RightLabels[i]:SetText("")
        end
    end
end

function AZP.BossTools.Sepulcher.Halondrus:StartHoveringCopy()
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

function AZP.BossTools.Sepulcher.Halondrus:StopHoveringCopy()
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

function AZP.BossTools.Sepulcher.Halondrus:StartHoverOverCopy(SocketFrame)
    if dragging == true then
        GemFrame.parent = SocketFrame
        SocketFrame.EditBox:SetBackdropColor(0.25, 1, 0.25, 1)
    end
end

function AZP.BossTools.Sepulcher.Halondrus:StopHoverOverCopy(SocketFrame)
    SocketFrame.EditBox:SetBackdropColor(1, 1, 1, 1)
    if GemFrame ~= nil then if GemFrame.parent ~= nil then GemFrame.parent = nil end end
end

function AZP.BossTools.Sepulcher.Halondrus:OnEvent(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
        AZP.BossTools.Sepulcher.Halondrus.Events:ChatMsgAddon(...)
    elseif event == "GROUP_ROSTER_UPDATE" then
        AZP.BossTools.Sepulcher.Halondrus.Events:GroupRosterUpdate(...)
    end
end

function AZP.BossTools.Sepulcher.Halondrus.Events:ChatMsgAddon(...)
    local prefix, payload, _, sender = ...
    if prefix == "AZPSAUSAGEINFO" then
        AZP.BossTools.Sepulcher.Halondrus:CacheRaidNames()
        AZP.BossTools.Sepulcher.Halondrus:ReceiveAssignees(payload)
        AZP.BossTools:ShowReceiveFrame(sender, "Sepulcher", "Halondrus")
        AZP.BossTools.ReceiveFrame:Show()
    end
end

function AZP.BossTools.Sepulcher.Halondrus.Events:GroupRosterUpdate(...)
    AZP.BossTools.Sepulcher.Halondrus:RefreshNames(...)
end

AZP.BossTools.Sepulcher.Halondrus:OnLoadSelf()