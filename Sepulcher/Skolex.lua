if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Sepulcher.Skolex == nil then AZP.BossTools.Sepulcher.Skolex = {} end
if AZP.BossTools.Sepulcher.Skolex.Events == nil then AZP.BossTools.Sepulcher.Skolex.Events = {} end

local AssignedPlayers = {Diamond = {}, Square = {},}
local AZPBTSkolexOptions = nil
local AZPBTSkolexGUIDs, AZPBTSkolexDiamondEditBoxes, AZPBTSkolexSquareEditBoxes = {}, {}, {}
local RetchResetNumber = 3
local RetchAmount, BurrowAmount = 0, 0
local CurrentMarker = "Diamond"

local EventFrame = nil

local dragging, previousParent, previousPoint = false, nil, {}
local GemFrame = nil

function AZP.BossTools.Sepulcher.Skolex:OnLoadBoth()
    SkolexOptions = CreateFrame("FRAME", nil, UIParent, "BackdropTemplate")
    SkolexOptions:SetSize(700, 400)
    SkolexOptions:SetPoint("CENTER", 0, 0)
    SkolexOptions:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    SkolexOptions:SetBackdropColor(1, 1, 1, 1)
    SkolexOptions:EnableMouse(true)
    SkolexOptions:SetMovable(true)
    SkolexOptions:RegisterForDrag("LeftButton")
    SkolexOptions:SetScript("OnDragStart", SkolexOptions.StartMoving)
    SkolexOptions:SetScript("OnDragStop", function() SkolexOptions:StopMovingOrSizing() end)
    AZP.BossTools.Sepulcher.Skolex:FillOptionsPanel(SkolexOptions)
    AZP.BossTools.Sepulcher.Skolex:CreateMainFrame()
end

function AZP.BossTools.Sepulcher.Skolex:OnLoadSelf()
    C_ChatInfo.RegisterAddonMessagePrefix("AZPSKOLEXINFO")

    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:RegisterEvent("ENCOUNTER_END")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Sepulcher.Skolex:OnEvent(...) end)

    AZP.BossTools.Sepulcher.Skolex:OnLoadBoth()
end

function AZP.BossTools.Sepulcher.Skolex:CreateMainFrame()
    local SkolexFrame = CreateFrame("FRAME", nil, UIPanel, "BackdropTemplate")
    SkolexFrame:SetSize(200, 100)
    SkolexFrame:SetPoint("TOPLEFT", 100, -200)
    SkolexFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    SkolexFrame:EnableMouse(true)
    SkolexFrame:SetMovable(true)
    SkolexFrame:RegisterForDrag("LeftButton")
    SkolexFrame:SetScript("OnDragStart", SkolexFrame.StartMoving)
    SkolexFrame:SetScript("OnDragStop", function() SkolexFrame:StopMovingOrSizing() end)

    SkolexFrame.Header = SkolexFrame:CreateFontString("SkolexFrame", "ARTWORK", "GameFontNormalHuge")
    SkolexFrame.Header:SetSize(SkolexFrame:GetWidth(), 25)
    SkolexFrame.Header:SetPoint("TOP", 0, -5)
    SkolexFrame.Header:SetText("Marker Assignments")

    SkolexFrame.Sepparator = CreateFrame("FRAME", nil, SkolexFrame, "BackdropTemplate")
    SkolexFrame.Sepparator:SetSize(3, 50)
    SkolexFrame.Sepparator:SetPoint("BOTTOM", 0, 10)
    SkolexFrame.Sepparator:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    })
    SkolexFrame.Sepparator:SetBackdropColor(0, 0, 0, 1)

    SkolexFrame.DiamondLabels = {}
    SkolexFrame.SquareLabels = {}

    for i = 1, 3 do
        SkolexFrame.DiamondLabels[i] = SkolexFrame:CreateFontString("SkolexFrame", "ARTWORK", "GameFontNormal")
        SkolexFrame.DiamondLabels[i]:SetSize(75, 25)
        SkolexFrame.DiamondLabels[i]:SetPoint("TOPLEFT", 10, ((i - 1) * -15) -35)
        SkolexFrame.DiamondLabels[i]:SetJustifyH("MIDDLE")
        SkolexFrame.DiamondLabels[i]:SetText("-")

        SkolexFrame.SquareLabels[i] = SkolexFrame:CreateFontString("SkolexFrame", "ARTWORK", "GameFontNormal")
        SkolexFrame.SquareLabels[i]:SetSize(75, 25)
        SkolexFrame.SquareLabels[i]:SetPoint("TOPLEFT", 110, ((i - 1) * -15) -35)
        SkolexFrame.SquareLabels[i]:SetJustifyH("MIDDLE")
        SkolexFrame.SquareLabels[i]:SetText("-")
    end

    SkolexFrame.OptionsButton = CreateFrame("Button", nil, SkolexFrame, "UIPanelButtonTemplate")
    SkolexFrame.OptionsButton:SetSize(12, 12)
    SkolexFrame.OptionsButton:SetPoint("TOPLEFT", SkolexFrame, "TOPLEFT", 2, 0)
    SkolexFrame.OptionsButton:SetScript("OnClick", function() SkolexOptions:Show() end)
    SkolexFrame.OptionsButton.Texture = SkolexFrame.OptionsButton:CreateTexture(nil, "ARTWORK")
    SkolexFrame.OptionsButton.Texture:SetSize(10, 10)
    SkolexFrame.OptionsButton.Texture:SetPoint("CENTER", 0, 0)
    SkolexFrame.OptionsButton.Texture:SetTexture(GetFileIDFromPath("Interface\\GossipFrame\\HealerGossipIcon"))

    SkolexFrame.closeButton = CreateFrame("Button", nil, SkolexFrame, "UIPanelCloseButton")
    SkolexFrame.closeButton:SetSize(20, 21)
    SkolexFrame.closeButton:SetPoint("TOPRIGHT", SkolexFrame, "TOPRIGHT", 2, 2)
    SkolexFrame.closeButton:SetScript("OnClick", function() SkolexFrame:Hide() end)

    AZP.BossTools.BossFrames.Skolex = SkolexFrame
    SkolexFrame:Hide()
end

function AZP.BossTools.Sepulcher.Skolex:FillOptionsPanel(frameToFill)
    frameToFill.Header = frameToFill:CreateFontString("frameToFill", "ARTWORK", "GameFontNormalHuge")
    frameToFill.Header:SetPoint("TOP", 0, -10)
    frameToFill.Header:SetText("|cFF00FFFFAzerPUG's BossTools Options!|r")
    frameToFill.SubHeader = frameToFill:CreateFontString("frameToFill", "ARTWORK", "GameFontNormalLarge")
    frameToFill.SubHeader:SetPoint("TOP", 0, -35)
    frameToFill.SubHeader:SetText("|cFF00FFFFSkolex|r")

    frameToFill.ShareButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.ShareButton:SetSize(100, 25)
    frameToFill.ShareButton:SetPoint("TOPRIGHT", -50, -25)
    frameToFill.ShareButton:SetText("Share List")
    frameToFill.ShareButton:SetScript("OnClick", function() AZP.BossTools.Sepulcher.Skolex:ShareAssignees() end )

    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -50, -55)
    frameToFill.LockMoveButton:SetText("Lock Frame")
    frameToFill.LockMoveButton:SetScript("OnClick", function ()
        if AZP.BossTools.BossFrames.Skolex:IsMovable() then
            AZP.BossTools.BossFrames.Skolex:EnableMouse(false)
            AZP.BossTools.BossFrames.Skolex:SetMovable(false)
            frameToFill.LockMoveButton:SetText("UnLock Frame!")
        else
            AZP.BossTools.BossFrames.Skolex:EnableMouse(true)
            AZP.BossTools.BossFrames.Skolex:SetMovable(true)
            frameToFill.LockMoveButton:SetText("Lock Frame")
        end
    end)

    frameToFill.ShowHideButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.ShowHideButton:SetSize(100, 25)
    frameToFill.ShowHideButton:SetPoint("TOPRIGHT", -50, -85)
    frameToFill.ShowHideButton:SetText("Hide Frame!")
    frameToFill.ShowHideButton:SetScript("OnClick", function () AZP.BossTools.Sepulcher.Skolex:ShowHideFrame() end)

    frameToFill.textlabels = {}

    frameToFill.DiamondHeader = frameToFill:CreateFontString("DiamondChainFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.DiamondHeader:SetSize(160, 25)
    frameToFill.DiamondHeader:SetPoint("TOPLEFT", 20, -75)
    frameToFill.DiamondHeader:SetText("Diamond")

    frameToFill.SquareHeader = frameToFill:CreateFontString("DiamondChainFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.SquareHeader:SetSize(160, 25)
    frameToFill.SquareHeader:SetPoint("LEFT", frameToFill.DiamondHeader, "RIGHT", 25, 0)
    frameToFill.SquareHeader:SetText("Square")

    for i = 1, 3 do
        AZPBTSkolexDiamondEditBoxes[i] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTSkolexDiamondEditBoxes[i]:SetSize(75, 25)
        AZPBTSkolexDiamondEditBoxes[i]:SetPoint("TOPLEFT", 65, -25 * i - 75)
        AZPBTSkolexDiamondEditBoxes[i]:SetFrameStrata("HIGH")
        AZPBTSkolexDiamondEditBoxes[i]:SetFrameLevel(10)
        AZPBTSkolexDiamondEditBoxes[i]:SetScript("OnEnter", function() AZP.BossTools.Sepulcher.Skolex:StartHoverOverCopy(AZPBTSkolexDiamondEditBoxes[i]) end)
        AZPBTSkolexDiamondEditBoxes[i]:SetScript("OnLeave", function() AZP.BossTools.Sepulcher.Skolex:StopHoverOverCopy(AZPBTSkolexDiamondEditBoxes[i]) end)
        AZPBTSkolexDiamondEditBoxes[i]:SetScript("OnMouseDown", function() AZPBTSkolexDiamondEditBoxes[i].EditBox:SetFocus() end)
        AZPBTSkolexDiamondEditBoxes[i].EditBox = CreateFrame("EditBox", nil, AZPBTSkolexDiamondEditBoxes[i], "InputBoxTemplate BackdropTemplate")
        AZPBTSkolexDiamondEditBoxes[i].EditBox:SetSize(AZPBTSkolexDiamondEditBoxes[i]:GetWidth(), AZPBTSkolexDiamondEditBoxes[i]:GetHeight())
        AZPBTSkolexDiamondEditBoxes[i].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTSkolexDiamondEditBoxes[i].EditBox:SetFrameLevel(5)
        AZPBTSkolexDiamondEditBoxes[i].EditBox:SetAutoFocus(false)
        AZPBTSkolexDiamondEditBoxes[i].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Sepulcher.Skolex:OnEditFocusLost("Diamond", i) end)
        AZPBTSkolexDiamondEditBoxes[i].EditBox:SetScript("OnTextSet", function() AZP.BossTools.Sepulcher.Skolex:OnEditFocusLost("Diamond", i) end)
        AZPBTSkolexDiamondEditBoxes[i].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTSkolexDiamondEditBoxes[i].EditBox:SetBackdropColor(1, 1, 1, 1)

        AZPBTSkolexSquareEditBoxes[i] = CreateFrame("FRAME", nil, frameToFill)
        AZPBTSkolexSquareEditBoxes[i]:SetSize(75, 25)
        AZPBTSkolexSquareEditBoxes[i]:SetPoint("LEFT", AZPBTSkolexDiamondEditBoxes[i], "RIGHT", 110, 0)
        AZPBTSkolexSquareEditBoxes[i]:SetFrameStrata("HIGH")
        AZPBTSkolexSquareEditBoxes[i]:SetFrameLevel(10)
        AZPBTSkolexSquareEditBoxes[i]:SetScript("OnEnter", function() AZP.BossTools.Sepulcher.Skolex:StartHoverOverCopy(AZPBTSkolexSquareEditBoxes[i]) end)
        AZPBTSkolexSquareEditBoxes[i]:SetScript("OnLeave", function() AZP.BossTools.Sepulcher.Skolex:StopHoverOverCopy(AZPBTSkolexSquareEditBoxes[i]) end)
        AZPBTSkolexSquareEditBoxes[i]:SetScript("OnMouseDown", function() AZPBTSkolexSquareEditBoxes[i].EditBox:SetFocus() end)
        AZPBTSkolexSquareEditBoxes[i].EditBox = CreateFrame("EditBox", nil, AZPBTSkolexSquareEditBoxes[i], "InputBoxTemplate BackdropTemplate")
        AZPBTSkolexSquareEditBoxes[i].EditBox:SetSize(AZPBTSkolexSquareEditBoxes[i]:GetWidth(), AZPBTSkolexSquareEditBoxes[i]:GetHeight())
        AZPBTSkolexSquareEditBoxes[i].EditBox:SetPoint("CENTER", 0, 0)
        AZPBTSkolexSquareEditBoxes[i].EditBox:SetFrameLevel(5)
        AZPBTSkolexSquareEditBoxes[i].EditBox:SetAutoFocus(false)
        AZPBTSkolexSquareEditBoxes[i].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Sepulcher.Skolex:OnEditFocusLost("Square", i) end)
        AZPBTSkolexSquareEditBoxes[i].EditBox:SetScript("OnTextSet", function() AZP.BossTools.Sepulcher.Skolex:OnEditFocusLost("Square", i) end)
        AZPBTSkolexSquareEditBoxes[i].EditBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = { left = -4, right = 1, top = 6, bottom = 6 },
        })
        AZPBTSkolexSquareEditBoxes[i].EditBox:SetBackdropColor(1, 1, 1, 1)
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
        curFrame:SetScript("OnMouseDown", function() GemFrame = curFrame AZP.BossTools.Sepulcher.Skolex:StartHoveringCopy() end)
        curFrame:SetScript("OnMouseUp", function() AZP.BossTools.Sepulcher.Skolex:StopHoveringCopy() end)

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

function AZP.BossTools.Sepulcher.Skolex:RefreshNames()
    local allUnitNames = {}
    local allNameLabels = SkolexOptions.AllNamesFrame.allNameLabels

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
            curFrame = CreateFrame("FRAME", nil, SkolexOptions.AllNamesFrame, "BackdropTemplate")
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
            curFrame:SetScript("OnMouseDown", function() GemFrame = curFrame AZP.BossTools.Sepulcher.Skolex:StartHoveringCopy() end)
            curFrame:SetScript("OnMouseUp", function() AZP.BossTools.Sepulcher.Skolex:StopHoveringCopy() end)

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

function AZP.BossTools.Sepulcher.Skolex:OnEditFocusLost(sides, index)
    local editBoxFrame = nil
    if sides == "Diamond" then
        editBoxFrame = AZPBTSkolexDiamondEditBoxes[index].EditBox
    elseif sides == "Square" then
        editBoxFrame = AZPBTSkolexSquareEditBoxes[index].EditBox
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
                    AZPBTSkolexGUIDs[curGUID] = curName
                    AssignedPlayers[sides][index] = curGUID
                    AZP.BossTools.Sepulcher.Skolex:UpdateMainFrame()
                end
            end
        end
    else
        table.remove(AssignedPlayers[sides], index)
    end

    AZPBTSkolexSides = AssignedPlayers
end

function AZP.BossTools.Sepulcher.Skolex:GetRaidIDs(side)
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

function AZP.BossTools.Sepulcher.Skolex:ShareAssignees()
    for ring, players in pairs(AssignedPlayers) do
        if players ~= nil then
            local leftPlayerString = AZP.BossTools.Sepulcher.Skolex:GetRaidIDs(AssignedPlayers.Diamond)
            local rightPlayerString = AZP.BossTools.Sepulcher.Skolex:GetRaidIDs(AssignedPlayers.Square)
            local message = string.format("%s:%s", leftPlayerString or "", rightPlayerString or "")
            C_ChatInfo.SendAddonMessage("AZPSKOLEXINFO", message ,"RAID", 1)
        end
    end
end

function AZP.BossTools.Sepulcher.Skolex:ReceiveAssignees(receiveAssignees)
    local left, right = string.match(receiveAssignees, "([^:]*):([^:]*)")
    AssignedPlayers.Diamond = {}
    AssignedPlayers.Square = {}
    for RaidID in string.gmatch(left, "%d+") do
        table.insert(AssignedPlayers.Diamond, UnitGUID(string.format("raid%d", RaidID)))
    end

    for RaidID in string.gmatch(right, "%d+") do
        table.insert(AssignedPlayers.Square, UnitGUID(string.format("raid%d", RaidID)))
    end

    AZP.BossTools.Sepulcher.Skolex:UpdateMainFrame()
end

function AZP.BossTools.Sepulcher.Skolex:CacheRaidNames()
    if IsInRaid() == true then
        for k = 1, 40 do
            local curName = GetRaidRosterInfo(k)
            if curName ~= nil then
                if string.find(curName, "-") then
                    curName = string.match(curName, "(.+)-")
                end
                local curGUID = UnitGUID("raid" .. k)
                AZPBTSkolexGUIDs[curGUID] = curName
            end
        end
    end
end

function AZP.BossTools.Sepulcher.Skolex:UpdateMainFrame()
    if IsInRaid() == false then
        return
    end
    local playerGUID = UnitGUID("player")
    AZPBTSkolexSides = AssignedPlayers

    for i = 1, 3 do
        local Diamond = AssignedPlayers.Diamond[i]
        local Square = AssignedPlayers.Square[i]

        if Diamond ~= nil then
            local name = AZPBTSkolexGUIDs[Diamond]
            if name == nil then name = "" end
            local curClassID = AZP.BossTools:GetClassIndexFromGUID(Diamond)
            local _, _, _, curColor = AZP.BossTools:GetClassColor(curClassID)
            local curName = string.format("\124cFF%s%s\124r", curColor, name)
            AZP.BossTools.BossFrames.Skolex.DiamondLabels[i]:SetText(curName)
            AZPBTSkolexDiamondEditBoxes[i].EditBox:SetText(name)
        else
            AZPBTSkolexDiamondEditBoxes[i].EditBox:SetText("")
            AZP.BossTools.BossFrames.Skolex.DiamondLabels[i]:SetText("")
        end
        if Square ~= nil then
            local name = AZPBTSkolexGUIDs[Square]
            if name == nil then name = "" end
            local curClassID = AZP.BossTools:GetClassIndexFromGUID(Square)
            local _, _, _, curColor = AZP.BossTools:GetClassColor(curClassID)
            local curName = string.format("\124cFF%s%s\124r", curColor, name)
            AZP.BossTools.BossFrames.Skolex.SquareLabels[i]:SetText(curName)
            AZPBTSkolexSquareEditBoxes[i].EditBox:SetText(name)
        else
            AZPBTSkolexSquareEditBoxes[i].EditBox:SetText("")
            AZP.BossTools.BossFrames.Skolex.SquareLabels[i]:SetText("")
        end
    end
end

function AZP.BossTools.Sepulcher.Skolex:StartHoveringCopy()
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

function AZP.BossTools.Sepulcher.Skolex:StopHoveringCopy()
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

function AZP.BossTools.Sepulcher.Skolex:StartHoverOverCopy(SocketFrame)
    if dragging == true then
        GemFrame.parent = SocketFrame
        SocketFrame.EditBox:SetBackdropColor(0.25, 1, 0.25, 1)
    end
end

function AZP.BossTools.Sepulcher.Skolex:StopHoverOverCopy(SocketFrame)
    SocketFrame.EditBox:SetBackdropColor(1, 1, 1, 1)
    if GemFrame ~= nil then if GemFrame.parent ~= nil then GemFrame.parent = nil end end
end

function AZP.BossTools.Sepulcher.Skolex:OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        AZP.BossTools.Sepulcher.Skolex.Events:CombatLogEventUnfiltered(...)
    elseif event == "CHAT_MSG_ADDON" then
        AZP.BossTools.Sepulcher.Skolex.Events:ChatMsgAddon(...)
    elseif event == "GROUP_ROSTER_UPDATE" then
        AZP.BossTools.Sepulcher.Skolex.Events:GroupRosterUpdate(...)
    elseif event == "ENCOUNTER_END" then
        BurrowAmount = 0
        RetchAmount = 0
        CurrentMarker = "Diamond"
    end
end

--[[
    Reset at 2.
    Start - Diamond Quadrant
    Retch + 1 - 1 - Square Quadrant
    Retch + 1 - 2 - Stack Diamond
    Burrow Boss move to Diamond - Change Diamond to old boss location.
    Retch + 1 - 1 - Square Quadrant
    Retch + 1 - 2 - Stack Diamond
    Burrow Boss move to Diamond - Change Diamond to old boss location.

    Reset at 3.
    Start - Diamond Quadrant
    Retch + 1 - 1 - Square Quadrant
    Retch + 1 - 2 - Diamond Quadrant
    Retch + 1 - 3 - Stack Square
    Burrow Boss move to Square - Change Square to old boss location.
    Retch + 1 - 1 - Diamond Quadrant
    Retch + 1 - 2 - Square Quadrant
    Retch + 1 - 3 - Stack Diamond
    Burrow Boss move to Diamond - Change Diamond to old boss location.

    Reset at 4.
    Start - Diamond Quadrant
    Retch + 1 - 1 - Square Quadrant
    Retch + 1 - 2 - Diamond Quadrant
    Retch + 1 - 3 - Square Quadrant
    Retch + 1 - 4 - Stack Diamond
    Burrow Boss move to Diamond - Change Diamond to old boss location.
    Retch + 1 - 1 - Square Quadrant
    Retch + 1 - 2 - Diamond Quadrant
    Retch + 1 - 3 - Square Quadrant
    Retch + 1 - 4 - Stack Diamond
    Burrow Boss move to Diamond - Change Diamond to old boss location.

]]

function AZP.BossTools.Sepulcher.Skolex.Events:CombatLogEventUnfiltered(...)
    local _, SubEvent, _, _, _, _, _, _, _, _, _, SpellID = CombatLogGetCurrentEventInfo()
    if SubEvent == "SPELL_CAST_SUCCESS" then
        if SpellID == AZP.BossTools.IDs.Sepulcher.Skolex.Retch then
            AZP.BossTools.Sepulcher.Skolex.Events:Retch()
        elseif SpellID == AZP.BossTools.IDs.Sepulcher.Skolex.Burrow then
            AZP.BossTools.Sepulcher.Skolex.Events:Burrow()
        end
    end
end

function AZP.BossTools.Sepulcher.Skolex.Events:Retch()
    RetchAmount = RetchAmount + 1

    if CurrentMarker == "Diamond" then CurrentMarker = "Square"
    elseif CurrentMarker == "Square" then CurrentMarker = "Diamond" end

    local printText = ""

    if RetchAmount == RetchResetNumber then
        printText = string.format("Stack on %s quickly!", CurrentMarker)
    else
        printText = string.format("Move to %s quadrant!", CurrentMarker)
    end

    AZP.BossTools:WarnPlayer(printText)
end

function AZP.BossTools.Sepulcher.Skolex.Events:Burrow()
    BurrowAmount = BurrowAmount + 1
    RetchAmount = 0
    AZP.BossTools:WarnPlayer(string.format("Move to %s quadrant!", CurrentMarker))
end

function AZP.BossTools.Sepulcher.Skolex.Events:ChatMsgAddon(...)
    local prefix, payload, _, sender = ...
    if prefix == "AZPSKOLEXINFO" then
        AZP.BossTools.Sepulcher.Skolex:CacheRaidNames()
        AZP.BossTools.Sepulcher.Skolex:ReceiveAssignees(payload)
        AZP.BossTools:ShowReceiveFrame(sender, "Sepulcher", "Skolex")
        AZP.BossTools.ReceiveFrame:Show()
    end
end

function AZP.BossTools.Sepulcher.Skolex.Events:GroupRosterUpdate(...)
    AZP.BossTools.Sepulcher.Skolex:RefreshNames(...)
end

AZP.BossTools.Sepulcher.Skolex:OnLoadSelf()