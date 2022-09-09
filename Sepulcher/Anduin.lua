if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Sepulcher.Anduin == nil then AZP.BossTools.Sepulcher.Anduin = {} end
if AZP.BossTools.Sepulcher.Anduin.Events == nil then AZP.BossTools.Sepulcher.Anduin.Events = {} end

local AssignedPlayers = {{}, {},}
local AZPBTAnduinOptions = nil
local AZPBTAnduinGUIDs, AZPBTAnduinEditBoxes = {}, {{}, {}}

local EventFrame = nil

local dragging, previousParent, previousPoint = false, nil, {}
local GemFrame = nil

function AZP.BossTools.Sepulcher.Anduin:OnLoadBoth()
    AnduinOptions = CreateFrame("FRAME", nil, UIParent, "BackdropTemplate")
    AnduinOptions:SetSize(700, 400)
    AnduinOptions:SetPoint("CENTER", 0, 0)
    AnduinOptions:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    AnduinOptions:SetBackdropColor(1, 1, 1, 1)
    AnduinOptions:EnableMouse(true)
    AnduinOptions:SetMovable(true)
    AnduinOptions:RegisterForDrag("LeftButton")
    AnduinOptions:SetScript("OnDragStart", AnduinOptions.StartMoving)
    AnduinOptions:SetScript("OnDragStop", function() AnduinOptions:StopMovingOrSizing() end)
    AZP.BossTools.Sepulcher.Anduin:FillOptionsPanel(AnduinOptions)
    AZP.BossTools.Sepulcher.Anduin:CreateMainFrame()
end

function AZP.BossTools.Sepulcher.Anduin:OnLoadSelf()
    C_ChatInfo.RegisterAddonMessagePrefix("AZPAnduinINFO")

    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    EventFrame:RegisterEvent("ENCOUNTER_END")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Sepulcher.Anduin:OnEvent(...) end)

    AZP.BossTools.Sepulcher.Anduin:OnLoadBoth()
end

function AZP.BossTools.Sepulcher.Anduin:CreateMainFrame()
    local AnduinFrame = CreateFrame("FRAME", nil, UIPanel, "BackdropTemplate")
    AnduinFrame:SetSize(250, 75)
    AnduinFrame:SetPoint("TOPLEFT", 100, -200)
    AnduinFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    AnduinFrame:EnableMouse(true)
    AnduinFrame:SetMovable(true)
    AnduinFrame:RegisterForDrag("LeftButton")
    AnduinFrame:SetScript("OnDragStart", AnduinFrame.StartMoving)
    AnduinFrame:SetScript("OnDragStop", function() AnduinFrame:StopMovingOrSizing() end)

    AnduinFrame.Header = AnduinFrame:CreateFontString("AnduinFrame", "ARTWORK", "GameFontNormalHuge")
    AnduinFrame.Header:SetSize(AnduinFrame:GetWidth(), 25)
    AnduinFrame.Header:SetPoint("TOP", 0, -5)
    AnduinFrame.Header:SetText("CC Assignments")

    AnduinFrame.Assignments = {{}, {}}

    for i = 1, 2 do
        for j = 1, 3 do
            AnduinFrame.Assignments[i][j] = AnduinFrame:CreateFontString("AnduinFrame", "ARTWORK", "GameFontNormal")
            AnduinFrame.Assignments[i][j]:SetSize(75, 25)
            AnduinFrame.Assignments[i][j]:SetPoint("TOPLEFT", j * 80 - 70, ((i - 1) * -15) -35)
            AnduinFrame.Assignments[i][j]:SetJustifyH("MIDDLE")
            AnduinFrame.Assignments[i][j]:SetText("-")
        end
    end

    AnduinFrame.OptionsButton = CreateFrame("Button", nil, AnduinFrame, "UIPanelButtonTemplate")
    AnduinFrame.OptionsButton:SetSize(12, 12)
    AnduinFrame.OptionsButton:SetPoint("TOPLEFT", AnduinFrame, "TOPLEFT", 2, 0)
    AnduinFrame.OptionsButton:SetScript("OnClick", function() AnduinOptions:Show() end)
    AnduinFrame.OptionsButton.Texture = AnduinFrame.OptionsButton:CreateTexture(nil, "ARTWORK")
    AnduinFrame.OptionsButton.Texture:SetSize(10, 10)
    AnduinFrame.OptionsButton.Texture:SetPoint("CENTER", 0, 0)
    AnduinFrame.OptionsButton.Texture:SetTexture(GetFileIDFromPath("Interface\\GossipFrame\\HealerGossipIcon"))

    AnduinFrame.closeButton = CreateFrame("Button", nil, AnduinFrame, "UIPanelCloseButton")
    AnduinFrame.closeButton:SetSize(20, 21)
    AnduinFrame.closeButton:SetPoint("TOPRIGHT", AnduinFrame, "TOPRIGHT", 2, 2)
    AnduinFrame.closeButton:SetScript("OnClick", function() AnduinFrame:Hide() end)

    AZP.BossTools.BossFrames.Anduin = AnduinFrame
    AnduinFrame:Hide()
end

function AZP.BossTools.Sepulcher.Anduin:FillOptionsPanel(frameToFill)
    frameToFill.Header = frameToFill:CreateFontString("frameToFill", "ARTWORK", "GameFontNormalHuge")
    frameToFill.Header:SetPoint("TOP", 0, -10)
    frameToFill.Header:SetText("|cFF00FFFFAzerPUG's BossTools Options!|r")
    frameToFill.SubHeader = frameToFill:CreateFontString("frameToFill", "ARTWORK", "GameFontNormalLarge")
    frameToFill.SubHeader:SetPoint("TOP", 0, -35)
    frameToFill.SubHeader:SetText("|cFF00FFFFAnduin|r")

    frameToFill.ShareButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.ShareButton:SetSize(100, 25)
    frameToFill.ShareButton:SetPoint("TOPRIGHT", -50, -25)
    frameToFill.ShareButton:SetText("Share List")
    frameToFill.ShareButton:SetScript("OnClick", function() AZP.BossTools.Sepulcher.Anduin:ShareAssignees() end )

    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -50, -55)
    frameToFill.LockMoveButton:SetText("Lock Frame")
    frameToFill.LockMoveButton:SetScript("OnClick", function ()
        if AZP.BossTools.BossFrames.Anduin:IsMovable() then
            AZP.BossTools.BossFrames.Anduin:EnableMouse(false)
            AZP.BossTools.BossFrames.Anduin:SetMovable(false)
            frameToFill.LockMoveButton:SetText("UnLock Frame!")
        else
            AZP.BossTools.BossFrames.Anduin:EnableMouse(true)
            AZP.BossTools.BossFrames.Anduin:SetMovable(true)
            frameToFill.LockMoveButton:SetText("Lock Frame")
        end
    end)

    frameToFill.ShowHideButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.ShowHideButton:SetSize(100, 25)
    frameToFill.ShowHideButton:SetPoint("TOPRIGHT", -50, -85)
    frameToFill.ShowHideButton:SetText("Hide Frame!")
    frameToFill.ShowHideButton:SetScript("OnClick", function () AZP.BossTools.Sepulcher.Anduin:ShowHideFrame() end)

    frameToFill.textlabels = {}

    frameToFill.DiamondHeader = frameToFill:CreateFontString("DiamondChainFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.DiamondHeader:SetSize(100, 25)
    frameToFill.DiamondHeader:SetPoint("TOPLEFT", 20, -75)
    frameToFill.DiamondHeader:SetText("Diamond")

    frameToFill.SquareHeader = frameToFill:CreateFontString("DiamondChainFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.SquareHeader:SetSize(100, 25)
    frameToFill.SquareHeader:SetPoint("LEFT", frameToFill.DiamondHeader, "RIGHT", 25, 0)
    frameToFill.SquareHeader:SetText("Square")

    frameToFill.TriangleHeader = frameToFill:CreateFontString("DiamondChainFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.TriangleHeader:SetSize(100, 25)
    frameToFill.TriangleHeader:SetPoint("LEFT", frameToFill.SquareHeader, "RIGHT", 25, 0)
    frameToFill.TriangleHeader:SetText("Triangle")

    for i = 1, 2 do
        for j = 1, 3 do
            AZPBTAnduinEditBoxes[i][j] = CreateFrame("FRAME", nil, frameToFill)
            AZPBTAnduinEditBoxes[i][j]:SetSize(75, 25)
            AZPBTAnduinEditBoxes[i][j]:SetPoint("TOPLEFT", 125 * j - 90, -25 * i - 75)
            AZPBTAnduinEditBoxes[i][j]:SetFrameStrata("HIGH")
            AZPBTAnduinEditBoxes[i][j]:SetFrameLevel(10)
            AZPBTAnduinEditBoxes[i][j]:SetScript("OnEnter", function() AZP.BossTools.Sepulcher.Anduin:StartHoverOverCopy(AZPBTAnduinEditBoxes[i][j]) end)
            AZPBTAnduinEditBoxes[i][j]:SetScript("OnLeave", function() AZP.BossTools.Sepulcher.Anduin:StopHoverOverCopy(AZPBTAnduinEditBoxes[i][j]) end)
            AZPBTAnduinEditBoxes[i][j]:SetScript("OnMouseDown", function() AZPBTAnduinEditBoxes[i][j].EditBox:SetFocus() end)
            AZPBTAnduinEditBoxes[i][j].EditBox = CreateFrame("EditBox", nil, AZPBTAnduinEditBoxes[i][j], "InputBoxTemplate BackdropTemplate")
            AZPBTAnduinEditBoxes[i][j].EditBox:SetSize(AZPBTAnduinEditBoxes[i][j]:GetWidth(), AZPBTAnduinEditBoxes[i][j]:GetHeight())
            AZPBTAnduinEditBoxes[i][j].EditBox:SetPoint("CENTER", 0, 0)
            AZPBTAnduinEditBoxes[i][j].EditBox:SetFrameLevel(5)
            AZPBTAnduinEditBoxes[i][j].EditBox:SetAutoFocus(false)
            AZPBTAnduinEditBoxes[i][j].EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Sepulcher.Anduin:OnEditFocusLost(i, j) end)
            AZPBTAnduinEditBoxes[i][j].EditBox:SetScript("OnTextSet", function() AZP.BossTools.Sepulcher.Anduin:OnEditFocusLost(i, j) end)
            AZPBTAnduinEditBoxes[i][j].EditBox:SetBackdrop({
                bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                insets = { left = -4, right = 1, top = 6, bottom = 6 },
            })
            AZPBTAnduinEditBoxes[i][j].EditBox:SetBackdropColor(1, 1, 1, 1)
        end
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
        curFrame:SetScript("OnMouseDown", function() GemFrame = curFrame AZP.BossTools.Sepulcher.Anduin:StartHoveringCopy() end)
        curFrame:SetScript("OnMouseUp", function() AZP.BossTools.Sepulcher.Anduin:StopHoveringCopy() end)

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

function AZP.BossTools.Sepulcher.Anduin:RefreshNames()
    local allUnitNames = {}
    local allNameLabels = AnduinOptions.AllNamesFrame.allNameLabels

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
            curFrame = CreateFrame("FRAME", nil, AnduinOptions.AllNamesFrame, "BackdropTemplate")
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
            curFrame:SetScript("OnMouseDown", function() GemFrame = curFrame AZP.BossTools.Sepulcher.Anduin:StartHoveringCopy() end)
            curFrame:SetScript("OnMouseUp", function() AZP.BossTools.Sepulcher.Anduin:StopHoveringCopy() end)

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

function AZP.BossTools.Sepulcher.Anduin:OnEditFocusLost(i, j)
    local editBoxFrame = AZPBTAnduinEditBoxes[i][j].EditBox
    if (editBoxFrame:GetText() ~= nil and editBoxFrame:GetText() ~= "") then
        for k = 1, 40 do
            local curName = GetRaidRosterInfo(k)
            if curName ~= nil then
                if string.find(curName, "-") then
                    curName = string.match(curName, "(.+)-")
                end
                if curName == editBoxFrame:GetText() then
                    local curGUID = UnitGUID("raid" .. k)
                    AZPBTAnduinGUIDs[curGUID] = curName
                    AssignedPlayers[i][j] = curGUID
                    AZP.BossTools.Sepulcher.Anduin:UpdateMainFrame()
                end
            end
        end
    else
        table.remove(AssignedPlayers[i], j)
    end

    AZPBTAnduinGroups = AssignedPlayers
end

function AZP.BossTools.Sepulcher.Anduin:GetRaidIDs(side)
    local FoundRaidIDs = nil
    for _, guid in ipairs(side) do
        for raidID = 1, 40 do
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

function AZP.BossTools.Sepulcher.Anduin:ShareAssignees()
    local PlayerString1 = AZP.BossTools.Sepulcher.Anduin:GetRaidIDs(AssignedPlayers[1])
    local PlayerString2 = AZP.BossTools.Sepulcher.Anduin:GetRaidIDs(AssignedPlayers[2])
    local message = string.format("%s:%s", PlayerString1, PlayerString2)
    C_ChatInfo.SendAddonMessage("AZPAnduinINFO", message ,"RAID", 1)
end

function AZP.BossTools.Sepulcher.Anduin:ReceiveAssignees(receiveAssignees)
    local first, second = string.match(receiveAssignees, "([^:]*):([^:]*)")
    AssignedPlayers = {{}, {}}
    for RaidID in string.gmatch(first, "%d+") do
        table.insert(AssignedPlayers[1], UnitGUID(string.format("raid%d", RaidID)))
    end

    for RaidID in string.gmatch(second, "%d+") do
        table.insert(AssignedPlayers[2], UnitGUID(string.format("raid%d", RaidID)))
    end

    DevTools_Dump(AssignedPlayers)

    AZP.BossTools.Sepulcher.Anduin:UpdateMainFrame()
end

function AZP.BossTools.Sepulcher.Anduin:CacheRaidNames()
    if IsInRaid() == true then
        for k = 1, 40 do
            local curName = GetRaidRosterInfo(k)
            if curName ~= nil then
                if string.find(curName, "-") then
                    curName = string.match(curName, "(.+)-")
                end
                local curGUID = UnitGUID("raid" .. k)
                AZPBTAnduinGUIDs[curGUID] = curName
            end
        end
    end
end

function AZP.BossTools.Sepulcher.Anduin:UpdateMainFrame()
    if IsInRaid() == false then
        return
    end

    for i = 1, 2 do
        for j = 1, 3 do
            local name = AZPBTAnduinGUIDs[AssignedPlayers[i][j]]
            if name == nil then name = ""
            else
                local curClassID = AZP.BossTools:GetClassIndexFromGUID(AssignedPlayers[i][j])
                local _, _, _, curColor = AZP.BossTools:GetClassColor(curClassID)
                local curName = string.format("\124cFF%s%s\124r", curColor, name)
                AZP.BossTools.BossFrames.Anduin.Assignments[i][j]:SetText(curName)
            end
            AZPBTAnduinEditBoxes[i][j].EditBox:SetText(name)
        end
    end
end

function AZP.BossTools.Sepulcher.Anduin:StartHoveringCopy()
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

function AZP.BossTools.Sepulcher.Anduin:StopHoveringCopy()
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

function AZP.BossTools.Sepulcher.Anduin:StartHoverOverCopy(SocketFrame)
    if dragging == true then
        GemFrame.parent = SocketFrame
        SocketFrame.EditBox:SetBackdropColor(0.25, 1, 0.25, 1)
    end
end

function AZP.BossTools.Sepulcher.Anduin:StopHoverOverCopy(SocketFrame)
    SocketFrame.EditBox:SetBackdropColor(1, 1, 1, 1)
    if GemFrame ~= nil then if GemFrame.parent ~= nil then GemFrame.parent = nil end end
end

function AZP.BossTools.Sepulcher.Anduin.Events:EncounterEnd(_, _, _, _, success)
    if success == true then
        AZPBTAnduinGroups = nil
    end
end

function AZP.BossTools.Sepulcher.Anduin:OnEvent(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
        AZP.BossTools.Sepulcher.Anduin.Events:ChatMsgAddon(...)
    elseif event == "GROUP_ROSTER_UPDATE" then
        AZP.BossTools.Sepulcher.Anduin.Events:GroupRosterUpdate(...)
    elseif event == "ENCOUNTER_END" then
        AZP.BossTools.Sepulcher.Anduin.Events:EncounterEnd(...)
    end
end

function AZP.BossTools.Sepulcher.Anduin.Events:ChatMsgAddon(...)
    local prefix, payload, _, sender = ...
    if prefix == "AZPAnduinINFO" then
        AZP.BossTools.Sepulcher.Anduin:CacheRaidNames()
        AZP.BossTools.Sepulcher.Anduin:ReceiveAssignees(payload)
        AZP.BossTools:ShowReceiveFrame(sender, "Sepulcher", "Anduin")
        AZP.BossTools.ReceiveFrame:Show()
    end
end

function AZP.BossTools.Sepulcher.Anduin.Events:GroupRosterUpdate(...)
    AZP.BossTools.Sepulcher.Anduin:RefreshNames(...)
end

AZP.BossTools.Sepulcher.Anduin:OnLoadSelf()