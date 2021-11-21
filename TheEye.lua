if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.TheEye == nil then AZP.BossTools.TheEye = {} end
if AZP.BossTools.TheEye.Events == nil then AZP.BossTools.TheEye.Events = {} end

local AssignedPlayers = {Left = {}, Right = {},}
local AZPBTTheEyeOptions = nil
local AZPBTTheEyeGUIDs, AZPBTTheEyeLeftEditBoxes, AZPBTTheEyeRightEditBoxes = {}, {}, {}

local EventFrame = nil

local dragging, previousParent, previousPoint = false, nil, {}
local GemFrame = nil

function AZP.BossTools.TheEye:OnLoadBoth()
    TheEyeOptions = CreateFrame("FRAME", nil, UIParent, "BackdropTemplate")
    TheEyeOptions:SetSize(700, 400)
    TheEyeOptions:SetPoint("CENTER", 0, 0)
    TheEyeOptions:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    TheEyeOptions:SetBackdropColor(1, 1, 1, 1)
    TheEyeOptions:EnableMouse(true)
    TheEyeOptions:SetMovable(true)
    TheEyeOptions:RegisterForDrag("LeftButton")
    TheEyeOptions:SetScript("OnDragStart", TheEyeOptions.StartMoving)
    TheEyeOptions:SetScript("OnDragStop", function() TheEyeOptions:StopMovingOrSizing() end)
    AZP.BossTools.TheEye:FillOptionsPanel(TheEyeOptions)
    AZP.BossTools.TheEye:CreateMainFrame()
end

function AZP.BossTools.TheEye:OnLoadSelf()
    C_ChatInfo.RegisterAddonMessagePrefix("AZPEYEINFO")

    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.TheEye:OnEvent(...) end)

    AZP.BossTools.TheEye:OnLoadBoth()
end

function AZP.BossTools.TheEye:CreateMainFrame()
    local TheEyeFrame = CreateFrame("FRAME", nil, UIPanel, "BackdropTemplate")
    TheEyeFrame:SetSize(350, 200)
    TheEyeFrame:SetPoint("TOPLEFT", 100, -200)
    TheEyeFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    TheEyeFrame:EnableMouse(true)
    TheEyeFrame:SetMovable(true)
    TheEyeFrame:RegisterForDrag("LeftButton")
    TheEyeFrame:SetScript("OnDragStart", TheEyeFrame.StartMoving)
    TheEyeFrame:SetScript("OnDragStop", function() TheEyeFrame:StopMovingOrSizing() end)

    TheEyeFrame.Header = TheEyeFrame:CreateFontString("TheEyeFrame", "ARTWORK", "GameFontNormalHuge")
    TheEyeFrame.Header:SetSize(TheEyeFrame:GetWidth(), 25)
    TheEyeFrame.Header:SetPoint("TOP", 0, -5)
    TheEyeFrame.Header:SetText("Sides Assignments")

    TheEyeFrame.Sepparator = CreateFrame("FRAME", nil, TheEyeFrame, "BackdropTemplate")
    TheEyeFrame.Sepparator:SetSize(3, 150)
    TheEyeFrame.Sepparator:SetPoint("BOTTOM", 0, 10)
    TheEyeFrame.Sepparator:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    })
    TheEyeFrame.Sepparator:SetBackdropColor(0, 0, 0, 1)

    TheEyeFrame.LeftLabels = {}
    TheEyeFrame.RightLabels = {}

    for i = 1, 10 do
        TheEyeFrame.LeftLabels[i] = TheEyeFrame:CreateFontString("TheEyeFrame", "ARTWORK", "GameFontNormal")
        TheEyeFrame.LeftLabels[i]:SetSize(75, 25)
        TheEyeFrame.LeftLabels[i]:SetPoint("TOPLEFT", 0, ((i - 1) * -15) -35)
        TheEyeFrame.LeftLabels[i]:SetJustifyH("MIDDLE")
        TheEyeFrame.LeftLabels[i]:SetText("-")

        TheEyeFrame.LeftLabels[i + 10] = TheEyeFrame:CreateFontString("TheEyeFrame", "ARTWORK", "GameFontNormal")
        TheEyeFrame.LeftLabels[i + 10]:SetSize(75, 25)
        TheEyeFrame.LeftLabels[i + 10]:SetPoint("LEFT", TheEyeFrame.LeftLabels[i], "RIGHT", 5, 0)
        TheEyeFrame.LeftLabels[i + 10]:SetJustifyH("MIDDLE")
        TheEyeFrame.LeftLabels[i + 10]:SetText("-")

        TheEyeFrame.RightLabels[i + 10] = TheEyeFrame:CreateFontString("TheEyeFrame", "ARTWORK", "GameFontNormal")
        TheEyeFrame.RightLabels[i + 10]:SetSize(75, 25)
        TheEyeFrame.RightLabels[i + 10]:SetPoint("TOPRIGHT", 0, ((i - 1) * -15) -35)
        TheEyeFrame.RightLabels[i + 10]:SetJustifyH("MIDDLE")
        TheEyeFrame.RightLabels[i + 10]:SetText("-")

        TheEyeFrame.RightLabels[i] = TheEyeFrame:CreateFontString("TheEyeFrame", "ARTWORK", "GameFontNormal")
        TheEyeFrame.RightLabels[i]:SetSize(75, 25)
        TheEyeFrame.RightLabels[i]:SetPoint("RIGHT", TheEyeFrame.RightLabels[i + 10], "LEFT", -5, 0)
        TheEyeFrame.RightLabels[i]:SetJustifyH("MIDDLE")
        TheEyeFrame.RightLabels[i]:SetText("-")
    end

    TheEyeFrame.OptionsButton = CreateFrame("Button", nil, TheEyeFrame, "UIPanelButtonTemplate")
    TheEyeFrame.OptionsButton:SetSize(12, 12)
    TheEyeFrame.OptionsButton:SetPoint("TOPLEFT", TheEyeFrame, "TOPLEFT", 2, 0)
    TheEyeFrame.OptionsButton:SetScript("OnClick", function() TheEyeOptions:Show() end)
    TheEyeFrame.OptionsButton.Texture = TheEyeFrame.OptionsButton:CreateTexture(nil, "ARTWORK")
    TheEyeFrame.OptionsButton.Texture:SetSize(10, 10)
    TheEyeFrame.OptionsButton.Texture:SetPoint("CENTER", 0, 0)
    TheEyeFrame.OptionsButton.Texture:SetTexture(GetFileIDFromPath("Interface\\GossipFrame\\HealerGossipIcon"))

    TheEyeFrame.closeButton = CreateFrame("Button", nil, TheEyeFrame, "UIPanelCloseButton")
    TheEyeFrame.closeButton:SetSize(20, 21)
    TheEyeFrame.closeButton:SetPoint("TOPRIGHT", TheEyeFrame, "TOPRIGHT", 2, 2)
    TheEyeFrame.closeButton:SetScript("OnClick", function() TheEyeFrame:Hide() end)

    AZP.BossTools.BossFrames.TheEye = TheEyeFrame
    TheEyeFrame:Hide()
end

function AZP.BossTools.TheEye:FillOptionsPanel(frameToFill)
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
    frameToFill.ShareButton:SetScript("OnClick", function() AZP.BossTools.TheEye:ShareAssignees() end )

    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -50, -55)
    frameToFill.LockMoveButton:SetText("Lock Frame")
    frameToFill.LockMoveButton:SetScript("OnClick", function ()
        if AZP.BossTools.BossFrames.TheEye:IsMovable() then
            AZP.BossTools.BossFrames.TheEye:EnableMouse(false)
            AZP.BossTools.BossFrames.TheEye:SetMovable(false)
            frameToFill.LockMoveButton:SetText("UnLock Frame!")
        else
            AZP.BossTools.BossFrames.TheEye:EnableMouse(true)
            AZP.BossTools.BossFrames.TheEye:SetMovable(true)
            frameToFill.LockMoveButton:SetText("Lock Frame")
        end
    end)

    frameToFill.ShowHideButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.ShowHideButton:SetSize(100, 25)
    frameToFill.ShowHideButton:SetPoint("TOPRIGHT", -50, -85)
    frameToFill.ShowHideButton:SetText("Hide Frame!")
    frameToFill.ShowHideButton:SetScript("OnClick", function () AZP.BossTools.TheEye:ShowHideFrame() end)

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
        AZPBTTheEyeLeftEditBoxes[i] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTTheEyeLeftEditBoxes[i]:SetSize(75, 25)
        AZPBTTheEyeLeftEditBoxes[i]:SetPoint("TOPLEFT", 20, -25 * i - 75)
        AZPBTTheEyeLeftEditBoxes[i]:SetFrameStrata("HIGH")
        AZPBTTheEyeLeftEditBoxes[i]:SetFrameLevel(10)
        AZPBTTheEyeLeftEditBoxes[i]:SetScript("OnEnter", function() AZP.BossTools.TheEye:StartHoverOverCopy(AZPBTTheEyeLeftEditBoxes[i]) end)
        AZPBTTheEyeLeftEditBoxes[i]:SetScript("OnLeave", function() AZP.BossTools.TheEye:StopHoverOverCopy(AZPBTTheEyeLeftEditBoxes[i]) end)
        AZPBTTheEyeLeftEditBoxes[i]:SetScript("OnMouseDown", function() AZPBTTheEyeLeftEditBoxes[i].EditBox:SetFocus() end)
        AZPBTTheEyeLeftEditBoxes[i].EditBox = CreateFrame("EditBox", nil, AZPBTTheEyeLeftEditBoxes[i], "InputBoxTemplate BackdropTemplate")
        AZPBTTheEyeLeftEditBoxes[i].EditBox:SetSize(AZPBTTheEyeLeftEditBoxes[i]:GetWidth(), AZPBTTheEyeLeftEditBoxes[i]:GetHeight())
        AZPBTTheEyeLeftEditBoxes[i].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTTheEyeLeftEditBoxes[i].EditBox:SetFrameLevel(5)
        AZPBTTheEyeLeftEditBoxes[i].EditBox:SetAutoFocus(false)
        AZPBTTheEyeLeftEditBoxes[i].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.TheEye:OnEditFocusLost("Left", i) end)
        AZPBTTheEyeLeftEditBoxes[i].EditBox:SetScript("OnTextSet", function() AZP.BossTools.TheEye:OnEditFocusLost("Left", i) end)
        AZPBTTheEyeLeftEditBoxes[i].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTTheEyeLeftEditBoxes[i].EditBox:SetBackdropColor(1, 1, 1, 1)

        AZPBTTheEyeLeftEditBoxes[i + 10] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTTheEyeLeftEditBoxes[i + 10]:SetSize(75, 25)
        AZPBTTheEyeLeftEditBoxes[i + 10]:SetPoint("LEFT", AZPBTTheEyeLeftEditBoxes[i], "RIGHT", 10, 0)
        AZPBTTheEyeLeftEditBoxes[i + 10]:SetFrameStrata("HIGH")
        AZPBTTheEyeLeftEditBoxes[i + 10]:SetFrameLevel(10)
        AZPBTTheEyeLeftEditBoxes[i + 10]:SetScript("OnEnter", function() AZP.BossTools.TheEye:StartHoverOverCopy(AZPBTTheEyeLeftEditBoxes[i + 10]) end)
        AZPBTTheEyeLeftEditBoxes[i + 10]:SetScript("OnLeave", function() AZP.BossTools.TheEye:StopHoverOverCopy(AZPBTTheEyeLeftEditBoxes[i + 10]) end)
        AZPBTTheEyeLeftEditBoxes[i + 10]:SetScript("OnMouseDown", function() AZPBTTheEyeLeftEditBoxes[i + 10].EditBox:SetFocus() end)
        AZPBTTheEyeLeftEditBoxes[i + 10].EditBox = CreateFrame("EditBox", nil, AZPBTTheEyeLeftEditBoxes[i + 10], "InputBoxTemplate BackdropTemplate")
        AZPBTTheEyeLeftEditBoxes[i + 10].EditBox:SetSize(AZPBTTheEyeLeftEditBoxes[i + 10]:GetWidth(), AZPBTTheEyeLeftEditBoxes[i + 10]:GetHeight())
        AZPBTTheEyeLeftEditBoxes[i + 10].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTTheEyeLeftEditBoxes[i + 10].EditBox:SetFrameLevel(5)
        AZPBTTheEyeLeftEditBoxes[i + 10].EditBox:SetAutoFocus(false)
        AZPBTTheEyeLeftEditBoxes[i + 10].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.TheEye:OnEditFocusLost("Left", i + 10) end)
        AZPBTTheEyeLeftEditBoxes[i + 10].EditBox:SetScript("OnTextSet", function() AZP.BossTools.TheEye:OnEditFocusLost("Left", i + 10) end)
        AZPBTTheEyeLeftEditBoxes[i + 10].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTTheEyeLeftEditBoxes[i + 10].EditBox:SetBackdropColor(1, 1, 1, 1)

        AZPBTTheEyeRightEditBoxes[i] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTTheEyeRightEditBoxes[i]:SetSize(75, 25)
        AZPBTTheEyeRightEditBoxes[i]:SetPoint("LEFT", AZPBTTheEyeLeftEditBoxes[i + 10], "RIGHT", 25, 0)
        AZPBTTheEyeRightEditBoxes[i]:SetFrameStrata("HIGH")
        AZPBTTheEyeRightEditBoxes[i]:SetFrameLevel(10)
        AZPBTTheEyeRightEditBoxes[i]:SetScript("OnEnter", function() AZP.BossTools.TheEye:StartHoverOverCopy(AZPBTTheEyeRightEditBoxes[i]) end)
        AZPBTTheEyeRightEditBoxes[i]:SetScript("OnLeave", function() AZP.BossTools.TheEye:StopHoverOverCopy(AZPBTTheEyeRightEditBoxes[i]) end)
        AZPBTTheEyeRightEditBoxes[i]:SetScript("OnMouseDown", function() AZPBTTheEyeRightEditBoxes[i].EditBox:SetFocus() end)
        AZPBTTheEyeRightEditBoxes[i].EditBox = CreateFrame("EditBox", nil, AZPBTTheEyeRightEditBoxes[i], "InputBoxTemplate BackdropTemplate")
        AZPBTTheEyeRightEditBoxes[i].EditBox:SetSize(AZPBTTheEyeRightEditBoxes[i]:GetWidth(), AZPBTTheEyeRightEditBoxes[i]:GetHeight())
        AZPBTTheEyeRightEditBoxes[i].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTTheEyeRightEditBoxes[i].EditBox:SetFrameLevel(5)
        AZPBTTheEyeRightEditBoxes[i].EditBox:SetAutoFocus(false)
        AZPBTTheEyeRightEditBoxes[i].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.TheEye:OnEditFocusLost("Right", i) end)
        AZPBTTheEyeRightEditBoxes[i].EditBox:SetScript("OnTextSet", function() AZP.BossTools.TheEye:OnEditFocusLost("Right", i) end)
        AZPBTTheEyeRightEditBoxes[i].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTTheEyeRightEditBoxes[i].EditBox:SetBackdropColor(1, 1, 1, 1)

        AZPBTTheEyeRightEditBoxes[i + 10] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTTheEyeRightEditBoxes[i + 10]:SetSize(75, 25)
        AZPBTTheEyeRightEditBoxes[i + 10]:SetPoint("LEFT", AZPBTTheEyeRightEditBoxes[i], "RIGHT", 10, 0)
        AZPBTTheEyeRightEditBoxes[i + 10]:SetFrameStrata("HIGH")
        AZPBTTheEyeRightEditBoxes[i + 10]:SetFrameLevel(10)
        AZPBTTheEyeRightEditBoxes[i + 10]:SetScript("OnEnter", function() AZP.BossTools.TheEye:StartHoverOverCopy(AZPBTTheEyeRightEditBoxes[i + 10]) end)
        AZPBTTheEyeRightEditBoxes[i + 10]:SetScript("OnLeave", function() AZP.BossTools.TheEye:StopHoverOverCopy(AZPBTTheEyeRightEditBoxes[i + 10]) end)
        AZPBTTheEyeRightEditBoxes[i + 10]:SetScript("OnMouseDown", function() AZPBTTheEyeRightEditBoxes[i + 10].EditBox:SetFocus() end)
        AZPBTTheEyeRightEditBoxes[i + 10].EditBox = CreateFrame("EditBox", nil, AZPBTTheEyeRightEditBoxes[i + 10], "InputBoxTemplate BackdropTemplate")
        AZPBTTheEyeRightEditBoxes[i + 10].EditBox:SetSize(AZPBTTheEyeRightEditBoxes[i + 10]:GetWidth(), AZPBTTheEyeRightEditBoxes[i + 10]:GetHeight())
        AZPBTTheEyeRightEditBoxes[i + 10].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTTheEyeRightEditBoxes[i + 10].EditBox:SetFrameLevel(5)
        AZPBTTheEyeRightEditBoxes[i + 10].EditBox:SetAutoFocus(false)
        AZPBTTheEyeRightEditBoxes[i + 10].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.TheEye:OnEditFocusLost("Right", i + 10) end)
        AZPBTTheEyeRightEditBoxes[i + 10].EditBox:SetScript("OnTextSet", function() AZP.BossTools.TheEye:OnEditFocusLost("Right", i + 10) end)
        AZPBTTheEyeRightEditBoxes[i + 10].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTTheEyeRightEditBoxes[i + 10].EditBox:SetBackdropColor(1, 1, 1, 1)
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
        curFrame:SetScript("OnMouseDown", function() GemFrame = curFrame AZP.BossTools.TheEye:StartHoveringCopy() end)
        curFrame:SetScript("OnMouseUp", function() AZP.BossTools.TheEye:StopHoveringCopy() end)

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

function AZP.BossTools.TheEye:OnEditFocusLost(position, index)
    local editBoxFrame = nil
    if position == "Left" then
        editBoxFrame = AZPBTTheEyeLeftEditBoxes[index].EditBox
    elseif position == "Right" then
        editBoxFrame = AZPBTTheEyeRightEditBoxes[index].EditBox
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
                    AZPBTTheEyeGUIDs[curGUID] = curName
                    AssignedPlayers[position][index] = curGUID
                    AZP.BossTools.TheEye:UpdateMainFrame()
                end
            end
        end
    else
        table.remove(AssignedPlayers[position], index)
    end

    AZPBTTheEyeSides = AssignedPlayers
end

function AZP.BossTools.TheEye:GetRaidIDs(side)
    local FoundRaidIDs = nil
    for index,guid in ipairs(side) do
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

function AZP.BossTools.TheEye:ShareAssignees()
    for ring, players in pairs(AssignedPlayers) do
        if players ~= nil then
            local leftPlayerString = AZP.BossTools.TheEye:GetRaidIDs(AssignedPlayers.Left)
            local rightPlayerString = AZP.BossTools.TheEye:GetRaidIDs(AssignedPlayers.Right)
            local message = string.format("%s:%s", leftPlayerString or "", rightPlayerString or "")
            C_ChatInfo.SendAddonMessage("AZPEYEINFO", message ,"RAID", 1)
        end
    end
end

function AZP.BossTools.TheEye:ReceiveAssignees(receiveAssignees)
    local left, right = string.match(receiveAssignees, "([^:]*):([^:]*)")
    AssignedPlayers.Left = {}
    AssignedPlayers.Right = {}
    for RaidID in string.gmatch(left, "%d+") do
        table.insert(AssignedPlayers.Left, UnitGUID(string.format("raid%d", RaidID)))
    end

    for RaidID in string.gmatch(right, "%d+") do
        table.insert(AssignedPlayers.Right, UnitGUID(string.format("raid%d", RaidID)))
    end

    AZP.BossTools.TheEye:UpdateMainFrame()
end

function AZP.BossTools.TheEye:CacheRaidNames()
    if IsInRaid() == true then
        for k = 1, 40 do
            local curName = GetRaidRosterInfo(k)
            if curName ~= nil then
                if string.find(curName, "-") then
                    curName = string.match(curName, "(.+)-")
                end
                local curGUID = UnitGUID("raid" .. k)
                AZPBTTheEyeGUIDs[curGUID] = curName
            end
        end
    end
end

function AZP.BossTools.TheEye:UpdateMainFrame()
    if IsInRaid() == false then
        print("BossTools TheEye only works in raid.")
        return
    end
    local playerGUID = UnitGUID("player")
    AZPBTTheEyeSides = AssignedPlayers

    for i = 1, 20 do
        local left = AssignedPlayers.Left[i]
        local right = AssignedPlayers.Right[i]

        if left ~= nil then
            local name = AZPBTTheEyeGUIDs[left]
            if name == nil then name = "" end
            local curClassID = AZP.BossTools:GetClassIndexFromGUID(left) --Create custom function with param left, mid, right
            local _, _, _, curColor = AZP.BossTools:GetClassColor(curClassID)
            local curName = string.format("\124cFF%s%s\124r", curColor, name)
            AZP.BossTools.BossFrames.TheEye.LeftLabels[i]:SetText(curName)
            AZPBTTheEyeLeftEditBoxes[i].EditBox:SetText(name)
        else
            AZPBTTheEyeLeftEditBoxes[i].EditBox:SetText("")
            AZP.BossTools.BossFrames.TheEye.LeftLabels[i]:SetText("")
        end
        if right ~= nil then
            local name = AZPBTTheEyeGUIDs[right]
            if name == nil then name = "" end
            local curClassID = AZP.BossTools:GetClassIndexFromGUID(right) --Create custom function with param left, mid, right
            local _, _, _, curColor = AZP.BossTools:GetClassColor(curClassID)
            local curName = string.format("\124cFF%s%s\124r", curColor, name)
            AZP.BossTools.BossFrames.TheEye.RightLabels[i]:SetText(curName)
            AZPBTTheEyeRightEditBoxes[i].EditBox:SetText(name)
        else
            AZPBTTheEyeRightEditBoxes[i].EditBox:SetText("")
            AZP.BossTools.BossFrames.TheEye.RightLabels[i]:SetText("")
        end
    end
end

function AZP.BossTools.TheEye:StartHoveringCopy()
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

function AZP.BossTools.TheEye:StopHoveringCopy()
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

function AZP.BossTools.TheEye:StartHoverOverCopy(SocketFrame)
    if dragging == true then
        GemFrame.parent = SocketFrame
        SocketFrame.EditBox:SetBackdropColor(0.25, 1, 0.25, 1)
    end
end

function AZP.BossTools.TheEye:StopHoverOverCopy(SocketFrame)
    SocketFrame.EditBox:SetBackdropColor(1, 1, 1, 1)
    if GemFrame ~= nil then if GemFrame.parent ~= nil then GemFrame.parent = nil end end
end

function AZP.BossTools.TheEye:OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        AZP.BossTools.TheEye.Events:CombatLogEventUnfiltered(...)
    elseif event == "CHAT_MSG_ADDON" then
        AZP.BossTools.TheEye.Events:ChatMsgAddon(...)
    end
end

function AZP.BossTools.TheEye.Events:CombatLogEventUnfiltered(...)
    local _, SubEvent, _, _, _, _, _, _, _, _, _, SpellID = CombatLogGetCurrentEventInfo()
    if SubEvent == "SPELL_CAST_SUCCESS" then
        if SpellID == AZP.BossTools.IDs.TheEye.Spell.StygianEjection then
            AZP.BossTools.TheEye.Events:StygianEjection()
        end
    end
end

function AZP.BossTools.TheEye.Events:StygianEjection()
    local curGUID = UnitGUID("PLAYER")
    local side = nil
    if tContains(AZPBTTheEyeSides.Left, curGUID) then
        side = "Left"
    elseif tContains(AZPBTTheEyeSides.Right, curGUID) then
        side = "Right"
    end

    if side ~= nil then
        local warnText = string.format("SplitPhase! Go %s!", side)  -- ("SplitPhase! Go %s%S%s!", marker, side, marker)
        AZP.BossTools:WarnPlayer(warnText)
    end
end

function AZP.BossTools.TheEye.Events:ChatMsgAddon(...)
    local prefix, payload, _, sender = ...
    if prefix == "AZPEYEINFO" then
        AZP.BossTools.TheEye:CacheRaidNames()
        AZP.BossTools.TheEye:ReceiveAssignees(payload)
    end
end

AZP.BossTools.TheEye:OnLoadSelf()