if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Sepulcher.DeSausage == nil then AZP.BossTools.Sepulcher.DeSausage = {} end
if AZP.BossTools.Sepulcher.DeSausage.Events == nil then AZP.BossTools.Sepulcher.DeSausage.Events = {} end

local AssignedPlayers = {Left = {}, Right = {},}
local AZPBTDeSausageOptions = nil
local AZPBTDeSausageGUIDs, AZPBTDeSausageLeftEditBoxes, AZPBTDeSausageRightEditBoxes = {}, {}, {}

local CurrentGroup = 1

local EventFrame = nil

local dragging, previousParent, previousPoint = false, nil, {}
local GemFrame = nil

function AZP.BossTools.Sepulcher.DeSausage:OnLoadBoth()
    DeSausageOptions = CreateFrame("FRAME", nil, UIParent, "BackdropTemplate")
    DeSausageOptions:SetSize(700, 400)
    DeSausageOptions:SetPoint("CENTER", 0, 0)
    DeSausageOptions:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    DeSausageOptions:SetBackdropColor(1, 1, 1, 1)
    DeSausageOptions:EnableMouse(true)
    DeSausageOptions:SetMovable(true)
    DeSausageOptions:RegisterForDrag("LeftButton")
    DeSausageOptions:SetScript("OnDragStart", DeSausageOptions.StartMoving)
    DeSausageOptions:SetScript("OnDragStop", function() DeSausageOptions:StopMovingOrSizing() end)
    AZP.BossTools.Sepulcher.DeSausage:FillOptionsPanel(DeSausageOptions)
    AZP.BossTools.Sepulcher.DeSausage:CreateMainFrame()
end

function AZP.BossTools.Sepulcher.DeSausage:OnLoadSelf()
    C_ChatInfo.RegisterAddonMessagePrefix("AZPSAUSAGEINFO")

    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Sepulcher.DeSausage:OnEvent(...) end)

    AZP.BossTools.Sepulcher.DeSausage:OnLoadBoth()
end

function AZP.BossTools.Sepulcher.DeSausage:CreateMainFrame()
    local DeSausageFrame = CreateFrame("FRAME", nil, UIPanel, "BackdropTemplate")
    DeSausageFrame:SetSize(350, 200)
    DeSausageFrame:SetPoint("TOPLEFT", 100, -200)
    DeSausageFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    DeSausageFrame:EnableMouse(true)
    DeSausageFrame:SetMovable(true)
    DeSausageFrame:RegisterForDrag("LeftButton")
    DeSausageFrame:SetScript("OnDragStart", DeSausageFrame.StartMoving)
    DeSausageFrame:SetScript("OnDragStop", function() DeSausageFrame:StopMovingOrSizing() end)

    DeSausageFrame.Header = DeSausageFrame:CreateFontString("DeSausageFrame", "ARTWORK", "GameFontNormalHuge")
    DeSausageFrame.Header:SetSize(DeSausageFrame:GetWidth(), 25)
    DeSausageFrame.Header:SetPoint("TOP", 0, -5)
    DeSausageFrame.Header:SetText("Sides Assignments")

    DeSausageFrame.Sepparator = CreateFrame("FRAME", nil, DeSausageFrame, "BackdropTemplate")
    DeSausageFrame.Sepparator:SetSize(3, 150)
    DeSausageFrame.Sepparator:SetPoint("BOTTOM", 0, 10)
    DeSausageFrame.Sepparator:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    })
    DeSausageFrame.Sepparator:SetBackdropColor(0, 0, 0, 1)

    DeSausageFrame.LeftLabels = {}
    DeSausageFrame.RightLabels = {}

    for i = 1, 10 do
        DeSausageFrame.LeftLabels[i] = DeSausageFrame:CreateFontString("DeSausageFrame", "ARTWORK", "GameFontNormal")
        DeSausageFrame.LeftLabels[i]:SetSize(75, 25)
        DeSausageFrame.LeftLabels[i]:SetPoint("TOPLEFT", 0, ((i - 1) * -15) -35)
        DeSausageFrame.LeftLabels[i]:SetJustifyH("MIDDLE")
        DeSausageFrame.LeftLabels[i]:SetText("-")

        DeSausageFrame.LeftLabels[i + 10] = DeSausageFrame:CreateFontString("DeSausageFrame", "ARTWORK", "GameFontNormal")
        DeSausageFrame.LeftLabels[i + 10]:SetSize(75, 25)
        DeSausageFrame.LeftLabels[i + 10]:SetPoint("LEFT", DeSausageFrame.LeftLabels[i], "RIGHT", 5, 0)
        DeSausageFrame.LeftLabels[i + 10]:SetJustifyH("MIDDLE")
        DeSausageFrame.LeftLabels[i + 10]:SetText("-")

        DeSausageFrame.RightLabels[i + 10] = DeSausageFrame:CreateFontString("DeSausageFrame", "ARTWORK", "GameFontNormal")
        DeSausageFrame.RightLabels[i + 10]:SetSize(75, 25)
        DeSausageFrame.RightLabels[i + 10]:SetPoint("TOPRIGHT", 0, ((i - 1) * -15) -35)
        DeSausageFrame.RightLabels[i + 10]:SetJustifyH("MIDDLE")
        DeSausageFrame.RightLabels[i + 10]:SetText("-")

        DeSausageFrame.RightLabels[i] = DeSausageFrame:CreateFontString("DeSausageFrame", "ARTWORK", "GameFontNormal")
        DeSausageFrame.RightLabels[i]:SetSize(75, 25)
        DeSausageFrame.RightLabels[i]:SetPoint("RIGHT", DeSausageFrame.RightLabels[i + 10], "LEFT", -5, 0)
        DeSausageFrame.RightLabels[i]:SetJustifyH("MIDDLE")
        DeSausageFrame.RightLabels[i]:SetText("-")
    end

    DeSausageFrame.OptionsButton = CreateFrame("Button", nil, DeSausageFrame, "UIPanelButtonTemplate")
    DeSausageFrame.OptionsButton:SetSize(12, 12)
    DeSausageFrame.OptionsButton:SetPoint("TOPLEFT", DeSausageFrame, "TOPLEFT", 2, 0)
    DeSausageFrame.OptionsButton:SetScript("OnClick", function() DeSausageOptions:Show() end)
    DeSausageFrame.OptionsButton.Texture = DeSausageFrame.OptionsButton:CreateTexture(nil, "ARTWORK")
    DeSausageFrame.OptionsButton.Texture:SetSize(10, 10)
    DeSausageFrame.OptionsButton.Texture:SetPoint("CENTER", 0, 0)
    DeSausageFrame.OptionsButton.Texture:SetTexture(GetFileIDFromPath("Interface\\GossipFrame\\HealerGossipIcon"))

    DeSausageFrame.closeButton = CreateFrame("Button", nil, DeSausageFrame, "UIPanelCloseButton")
    DeSausageFrame.closeButton:SetSize(20, 21)
    DeSausageFrame.closeButton:SetPoint("TOPRIGHT", DeSausageFrame, "TOPRIGHT", 2, 2)
    DeSausageFrame.closeButton:SetScript("OnClick", function() DeSausageFrame:Hide() end)

    AZP.BossTools.BossFrames.DeSausage = DeSausageFrame
    DeSausageFrame:Hide()
end

function AZP.BossTools.Sepulcher.DeSausage:FillOptionsPanel(frameToFill)
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
    frameToFill.ShareButton:SetScript("OnClick", function() AZP.BossTools.Sepulcher.DeSausage:ShareAssignees() end )

    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -50, -55)
    frameToFill.LockMoveButton:SetText("Lock Frame")
    frameToFill.LockMoveButton:SetScript("OnClick", function ()
        if AZP.BossTools.BossFrames.DeSausage:IsMovable() then
            AZP.BossTools.BossFrames.DeSausage:EnableMouse(false)
            AZP.BossTools.BossFrames.DeSausage:SetMovable(false)
            frameToFill.LockMoveButton:SetText("UnLock Frame!")
        else
            AZP.BossTools.BossFrames.DeSausage:EnableMouse(true)
            AZP.BossTools.BossFrames.DeSausage:SetMovable(true)
            frameToFill.LockMoveButton:SetText("Lock Frame")
        end
    end)

    frameToFill.ShowHideButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.ShowHideButton:SetSize(100, 25)
    frameToFill.ShowHideButton:SetPoint("TOPRIGHT", -50, -85)
    frameToFill.ShowHideButton:SetText("Hide Frame!")
    frameToFill.ShowHideButton:SetScript("OnClick", function () AZP.BossTools.Sepulcher.DeSausage:ShowHideFrame() end)

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
        AZPBTDeSausageLeftEditBoxes[i] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTDeSausageLeftEditBoxes[i]:SetSize(75, 25)
        AZPBTDeSausageLeftEditBoxes[i]:SetPoint("TOPLEFT", 20, -25 * i - 75)
        AZPBTDeSausageLeftEditBoxes[i]:SetFrameStrata("HIGH")
        AZPBTDeSausageLeftEditBoxes[i]:SetFrameLevel(10)
        AZPBTDeSausageLeftEditBoxes[i]:SetScript("OnEnter", function() AZP.BossTools.Sepulcher.DeSausage:StartHoverOverCopy(AZPBTDeSausageLeftEditBoxes[i]) end)
        AZPBTDeSausageLeftEditBoxes[i]:SetScript("OnLeave", function() AZP.BossTools.Sepulcher.DeSausage:StopHoverOverCopy(AZPBTDeSausageLeftEditBoxes[i]) end)
        AZPBTDeSausageLeftEditBoxes[i]:SetScript("OnMouseDown", function() AZPBTDeSausageLeftEditBoxes[i].EditBox:SetFocus() end)
        AZPBTDeSausageLeftEditBoxes[i].EditBox = CreateFrame("EditBox", nil, AZPBTDeSausageLeftEditBoxes[i], "InputBoxTemplate BackdropTemplate")
        AZPBTDeSausageLeftEditBoxes[i].EditBox:SetSize(AZPBTDeSausageLeftEditBoxes[i]:GetWidth(), AZPBTDeSausageLeftEditBoxes[i]:GetHeight())
        AZPBTDeSausageLeftEditBoxes[i].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTDeSausageLeftEditBoxes[i].EditBox:SetFrameLevel(5)
        AZPBTDeSausageLeftEditBoxes[i].EditBox:SetAutoFocus(false)
        AZPBTDeSausageLeftEditBoxes[i].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Sepulcher.DeSausage:OnEditFocusLost("Left", i) end)
        AZPBTDeSausageLeftEditBoxes[i].EditBox:SetScript("OnTextSet", function() AZP.BossTools.Sepulcher.DeSausage:OnEditFocusLost("Left", i) end)
        AZPBTDeSausageLeftEditBoxes[i].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTDeSausageLeftEditBoxes[i].EditBox:SetBackdropColor(1, 1, 1, 1)

        AZPBTDeSausageLeftEditBoxes[i + 10] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTDeSausageLeftEditBoxes[i + 10]:SetSize(75, 25)
        AZPBTDeSausageLeftEditBoxes[i + 10]:SetPoint("LEFT", AZPBTDeSausageLeftEditBoxes[i], "RIGHT", 10, 0)
        AZPBTDeSausageLeftEditBoxes[i + 10]:SetFrameStrata("HIGH")
        AZPBTDeSausageLeftEditBoxes[i + 10]:SetFrameLevel(10)
        AZPBTDeSausageLeftEditBoxes[i + 10]:SetScript("OnEnter", function() AZP.BossTools.Sepulcher.DeSausage:StartHoverOverCopy(AZPBTDeSausageLeftEditBoxes[i + 10]) end)
        AZPBTDeSausageLeftEditBoxes[i + 10]:SetScript("OnLeave", function() AZP.BossTools.Sepulcher.DeSausage:StopHoverOverCopy(AZPBTDeSausageLeftEditBoxes[i + 10]) end)
        AZPBTDeSausageLeftEditBoxes[i + 10]:SetScript("OnMouseDown", function() AZPBTDeSausageLeftEditBoxes[i + 10].EditBox:SetFocus() end)
        AZPBTDeSausageLeftEditBoxes[i + 10].EditBox = CreateFrame("EditBox", nil, AZPBTDeSausageLeftEditBoxes[i + 10], "InputBoxTemplate BackdropTemplate")
        AZPBTDeSausageLeftEditBoxes[i + 10].EditBox:SetSize(AZPBTDeSausageLeftEditBoxes[i + 10]:GetWidth(), AZPBTDeSausageLeftEditBoxes[i + 10]:GetHeight())
        AZPBTDeSausageLeftEditBoxes[i + 10].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTDeSausageLeftEditBoxes[i + 10].EditBox:SetFrameLevel(5)
        AZPBTDeSausageLeftEditBoxes[i + 10].EditBox:SetAutoFocus(false)
        AZPBTDeSausageLeftEditBoxes[i + 10].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Sepulcher.DeSausage:OnEditFocusLost("Left", i + 10) end)
        AZPBTDeSausageLeftEditBoxes[i + 10].EditBox:SetScript("OnTextSet", function() AZP.BossTools.Sepulcher.DeSausage:OnEditFocusLost("Left", i + 10) end)
        AZPBTDeSausageLeftEditBoxes[i + 10].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTDeSausageLeftEditBoxes[i + 10].EditBox:SetBackdropColor(1, 1, 1, 1)

        AZPBTDeSausageRightEditBoxes[i] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTDeSausageRightEditBoxes[i]:SetSize(75, 25)
        AZPBTDeSausageRightEditBoxes[i]:SetPoint("LEFT", AZPBTDeSausageLeftEditBoxes[i + 10], "RIGHT", 25, 0)
        AZPBTDeSausageRightEditBoxes[i]:SetFrameStrata("HIGH")
        AZPBTDeSausageRightEditBoxes[i]:SetFrameLevel(10)
        AZPBTDeSausageRightEditBoxes[i]:SetScript("OnEnter", function() AZP.BossTools.Sepulcher.DeSausage:StartHoverOverCopy(AZPBTDeSausageRightEditBoxes[i]) end)
        AZPBTDeSausageRightEditBoxes[i]:SetScript("OnLeave", function() AZP.BossTools.Sepulcher.DeSausage:StopHoverOverCopy(AZPBTDeSausageRightEditBoxes[i]) end)
        AZPBTDeSausageRightEditBoxes[i]:SetScript("OnMouseDown", function() AZPBTDeSausageRightEditBoxes[i].EditBox:SetFocus() end)
        AZPBTDeSausageRightEditBoxes[i].EditBox = CreateFrame("EditBox", nil, AZPBTDeSausageRightEditBoxes[i], "InputBoxTemplate BackdropTemplate")
        AZPBTDeSausageRightEditBoxes[i].EditBox:SetSize(AZPBTDeSausageRightEditBoxes[i]:GetWidth(), AZPBTDeSausageRightEditBoxes[i]:GetHeight())
        AZPBTDeSausageRightEditBoxes[i].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTDeSausageRightEditBoxes[i].EditBox:SetFrameLevel(5)
        AZPBTDeSausageRightEditBoxes[i].EditBox:SetAutoFocus(false)
        AZPBTDeSausageRightEditBoxes[i].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Sepulcher.DeSausage:OnEditFocusLost("Right", i) end)
        AZPBTDeSausageRightEditBoxes[i].EditBox:SetScript("OnTextSet", function() AZP.BossTools.Sepulcher.DeSausage:OnEditFocusLost("Right", i) end)
        AZPBTDeSausageRightEditBoxes[i].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTDeSausageRightEditBoxes[i].EditBox:SetBackdropColor(1, 1, 1, 1)

        AZPBTDeSausageRightEditBoxes[i + 10] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTDeSausageRightEditBoxes[i + 10]:SetSize(75, 25)
        AZPBTDeSausageRightEditBoxes[i + 10]:SetPoint("LEFT", AZPBTDeSausageRightEditBoxes[i], "RIGHT", 10, 0)
        AZPBTDeSausageRightEditBoxes[i + 10]:SetFrameStrata("HIGH")
        AZPBTDeSausageRightEditBoxes[i + 10]:SetFrameLevel(10)
        AZPBTDeSausageRightEditBoxes[i + 10]:SetScript("OnEnter", function() AZP.BossTools.Sepulcher.DeSausage:StartHoverOverCopy(AZPBTDeSausageRightEditBoxes[i + 10]) end)
        AZPBTDeSausageRightEditBoxes[i + 10]:SetScript("OnLeave", function() AZP.BossTools.Sepulcher.DeSausage:StopHoverOverCopy(AZPBTDeSausageRightEditBoxes[i + 10]) end)
        AZPBTDeSausageRightEditBoxes[i + 10]:SetScript("OnMouseDown", function() AZPBTDeSausageRightEditBoxes[i + 10].EditBox:SetFocus() end)
        AZPBTDeSausageRightEditBoxes[i + 10].EditBox = CreateFrame("EditBox", nil, AZPBTDeSausageRightEditBoxes[i + 10], "InputBoxTemplate BackdropTemplate")
        AZPBTDeSausageRightEditBoxes[i + 10].EditBox:SetSize(AZPBTDeSausageRightEditBoxes[i + 10]:GetWidth(), AZPBTDeSausageRightEditBoxes[i + 10]:GetHeight())
        AZPBTDeSausageRightEditBoxes[i + 10].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTDeSausageRightEditBoxes[i + 10].EditBox:SetFrameLevel(5)
        AZPBTDeSausageRightEditBoxes[i + 10].EditBox:SetAutoFocus(false)
        AZPBTDeSausageRightEditBoxes[i + 10].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Sepulcher.DeSausage:OnEditFocusLost("Right", i + 10) end)
        AZPBTDeSausageRightEditBoxes[i + 10].EditBox:SetScript("OnTextSet", function() AZP.BossTools.Sepulcher.DeSausage:OnEditFocusLost("Right", i + 10) end)
        AZPBTDeSausageRightEditBoxes[i + 10].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTDeSausageRightEditBoxes[i + 10].EditBox:SetBackdropColor(1, 1, 1, 1)
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
        curFrame:SetScript("OnMouseDown", function() GemFrame = curFrame AZP.BossTools.Sepulcher.DeSausage:StartHoveringCopy() end)
        curFrame:SetScript("OnMouseUp", function() AZP.BossTools.Sepulcher.DeSausage:StopHoveringCopy() end)

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

function AZP.BossTools.Sepulcher.DeSausage:RefreshNames()
    local allUnitNames = {}
    local allNameLabels = DeSausageOptions.AllNamesFrame.allNameLabels

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
            curFrame = CreateFrame("FRAME", nil, DeSausageOptions.AllNamesFrame, "BackdropTemplate")
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
            curFrame:SetScript("OnMouseDown", function() GemFrame = curFrame AZP.BossTools.Sepulcher.DeSausage:StartHoveringCopy() end)
            curFrame:SetScript("OnMouseUp", function() AZP.BossTools.Sepulcher.DeSausage:StopHoveringCopy() end)

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

function AZP.BossTools.Sepulcher.DeSausage:OnEditFocusLost(sides, index)
    local editBoxFrame = nil
    if sides == "Left" then
        editBoxFrame = AZPBTDeSausageLeftEditBoxes[index].EditBox
    elseif sides == "Right" then
        editBoxFrame = AZPBTDeSausageRightEditBoxes[index].EditBox
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
                    AZPBTDeSausageGUIDs[curGUID] = curName
                    AssignedPlayers[sides][index] = curGUID
                    AZP.BossTools.Sepulcher.DeSausage:UpdateMainFrame()
                end
            end
        end
    else
        table.remove(AssignedPlayers[sides], index)
    end

    AZPBTDeSausageSides = AssignedPlayers
end

function AZP.BossTools.Sepulcher.DeSausage:GetRaidIDs(side)
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

function AZP.BossTools.Sepulcher.DeSausage:ShareAssignees()
    for ring, players in pairs(AssignedPlayers) do
        if players ~= nil then
            local leftPlayerString = AZP.BossTools.Sepulcher.DeSausage:GetRaidIDs(AssignedPlayers.Left)
            local rightPlayerString = AZP.BossTools.Sepulcher.DeSausage:GetRaidIDs(AssignedPlayers.Right)
            local message = string.format("%s:%s", leftPlayerString or "", rightPlayerString or "")
            C_ChatInfo.SendAddonMessage("AZPSAUSAGEINFO", message ,"RAID", 1)
        end
    end
end

function AZP.BossTools.Sepulcher.DeSausage:ReceiveAssignees(receiveAssignees)
    local left, right = string.match(receiveAssignees, "([^:]*):([^:]*)")
    AssignedPlayers.Left = {}
    AssignedPlayers.Right = {}
    for RaidID in string.gmatch(left, "%d+") do
        table.insert(AssignedPlayers.Left, UnitGUID(string.format("raid%d", RaidID)))
    end

    for RaidID in string.gmatch(right, "%d+") do
        table.insert(AssignedPlayers.Right, UnitGUID(string.format("raid%d", RaidID)))
    end

    AZP.BossTools.Sepulcher.DeSausage:UpdateMainFrame()
end

function AZP.BossTools.Sepulcher.DeSausage:CacheRaidNames()
    if IsInRaid() == true then
        for k = 1, 40 do
            local curName = GetRaidRosterInfo(k)
            if curName ~= nil then
                if string.find(curName, "-") then
                    curName = string.match(curName, "(.+)-")
                end
                local curGUID = UnitGUID("raid" .. k)
                AZPBTDeSausageGUIDs[curGUID] = curName
            end
        end
    end
end

function AZP.BossTools.Sepulcher.DeSausage:UpdateMainFrame()
    if IsInRaid() == false then
        return
    end
    local playerGUID = UnitGUID("player")
    AZPBTDeSausageSides = AssignedPlayers

    for i = 1, 20 do
        local left = AssignedPlayers.Left[i]
        local right = AssignedPlayers.Right[i]

        if left ~= nil then
            local name = AZPBTDeSausageGUIDs[left]
            if name == nil then name = "" end
            local curClassID = AZP.BossTools:GetClassIndexFromGUID(left)
            local _, _, _, curColor = AZP.BossTools:GetClassColor(curClassID)
            local curName = string.format("\124cFF%s%s\124r", curColor, name)
            AZP.BossTools.BossFrames.DeSausage.LeftLabels[i]:SetText(curName)
            AZPBTDeSausageLeftEditBoxes[i].EditBox:SetText(name)
        else
            AZPBTDeSausageLeftEditBoxes[i].EditBox:SetText("")
            AZP.BossTools.BossFrames.DeSausage.LeftLabels[i]:SetText("")
        end
        if right ~= nil then
            local name = AZPBTDeSausageGUIDs[right]
            if name == nil then name = "" end
            local curClassID = AZP.BossTools:GetClassIndexFromGUID(right)
            local _, _, _, curColor = AZP.BossTools:GetClassColor(curClassID)
            local curName = string.format("\124cFF%s%s\124r", curColor, name)
            AZP.BossTools.BossFrames.DeSausage.RightLabels[i]:SetText(curName)
            AZPBTDeSausageRightEditBoxes[i].EditBox:SetText(name)
        else
            AZPBTDeSausageRightEditBoxes[i].EditBox:SetText("")
            AZP.BossTools.BossFrames.DeSausage.RightLabels[i]:SetText("")
        end
    end
end

function AZP.BossTools.Sepulcher.DeSausage:StartHoveringCopy()
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

function AZP.BossTools.Sepulcher.DeSausage:StopHoveringCopy()
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

function AZP.BossTools.Sepulcher.DeSausage:StartHoverOverCopy(SocketFrame)
    if dragging == true then
        GemFrame.parent = SocketFrame
        SocketFrame.EditBox:SetBackdropColor(0.25, 1, 0.25, 1)
    end
end

function AZP.BossTools.Sepulcher.DeSausage:StopHoverOverCopy(SocketFrame)
    SocketFrame.EditBox:SetBackdropColor(1, 1, 1, 1)
    if GemFrame ~= nil then if GemFrame.parent ~= nil then GemFrame.parent = nil end end
end

function AZP.BossTools.Sepulcher.DeSausage:OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        AZP.BossTools.Sepulcher.DeSausage.Events:CombatLogEventUnfiltered(...)
    elseif event == "CHAT_MSG_ADDON" then
        AZP.BossTools.Sepulcher.DeSausage.Events:ChatMsgAddon(...)
    elseif event == "GROUP_ROSTER_UPDATE" then
        AZP.BossTools.Sepulcher.DeSausage.Events:GroupRosterUpdate(...)
    end
end

function AZP.BossTools.Sepulcher.DeSausage.Events:CombatLogEventUnfiltered(...)
    local _, SubEvent, _, _, _, _, _, _, _, _, _, SpellID = CombatLogGetCurrentEventInfo()
    if SubEvent == "SPELL_CAST_SUCCESS" then
        if SpellID == AZP.BossTools.IDs.DeSausage.Barrage then
            AZP.BossTools.Sepulcher.DeSausage.Events:Barrage()
        end
    end
end

function AZP.BossTools.Sepulcher.DeSausage.Events:Barrage()
    -- print to CurrentGroup to soak.

    
    if CurrentGroup == 1 then
        CurrentGroup = 2
    elseif CurrentGroup == 2 then
        CurrentGroup = 1
    end
end

function AZP.BossTools.Sepulcher.DeSausage.Events:ChatMsgAddon(...)
    local prefix, payload, _, sender = ...
    if prefix == "AZPSAUSAGEINFO" then
        AZP.BossTools.Sepulcher.DeSausage:CacheRaidNames()
        AZP.BossTools.Sepulcher.DeSausage:ReceiveAssignees(payload)
        AZP.BossTools:ShowReceiveFrame(sender, "Sepulcher", "DeSausage")
        AZP.BossTools.ReceiveFrame:Show()
    end
end

function AZP.BossTools.Sepulcher.DeSausage.Events:GroupRosterUpdate(...)
    AZP.BossTools.Sepulcher.DeSausage:RefreshNames(...)
end

AZP.BossTools.Sepulcher.DeSausage:OnLoadSelf()