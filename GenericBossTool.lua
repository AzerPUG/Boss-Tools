if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Generic == nil then AZP.BossTools.Generic = {} end
if AZP.BossTools.Generic.Events == nil then AZP.BossTools.Generic.Events = {} end

local AZPBTGenericAssignedPlayers, AZPBTGenericGUIDs, AZPBTGenericEditBoxes = {}, {}, {}
local AZPGenericOptions = nil

local rows, cols = 0, 0

local EventFrame, GenericBTFrame = nil, nil

local dragging, previousParent, previousPoint = false, nil, {}
local GemFrame = nil

function AZP.BossTools.Generic:OnLoadBoth()
    AZPGenericOptions = CreateFrame("FRAME", nil, UIParent, "BackdropTemplate")
    AZPGenericOptions:SetSize(700, 400)
    AZPGenericOptions:SetPoint("CENTER", 0, 0)
    AZPGenericOptions:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    AZPGenericOptions:SetBackdropColor(1, 1, 1, 1)
    AZPGenericOptions:EnableMouse(true)
    AZPGenericOptions:SetMovable(true)
    AZPGenericOptions:RegisterForDrag("LeftButton")
    AZPGenericOptions:SetScript("OnDragStart", AZPGenericOptions.StartMoving)
    AZPGenericOptions:SetScript("OnDragStop", function() AZPGenericOptions:StopMovingOrSizing() end)
    AZP.BossTools.Generic:FillOptionsPanel(AZPGenericOptions)

    local AZPBossToolsVaultFrame = AZP.BossTools.AZPBossToolsVaultFrame
    AZPBossToolsVaultFrame.GenericButton = CreateFrame("Button", nil, AZPBossToolsVaultFrame)
    AZPBossToolsVaultFrame.GenericButton:SetSize(20, 20)
    AZPBossToolsVaultFrame.GenericButton:SetPoint("TOPLEFT", AZPBossToolsVaultFrame, "TOPLEFT", 3, -23)
    AZPBossToolsVaultFrame.GenericButton:SetScript("OnClick", function() AZPBossToolsVaultFrame:Hide() AZPGenericOptions:Show() end)
    AZPBossToolsVaultFrame.GenericButton.Texture = AZPBossToolsVaultFrame.GenericButton:CreateTexture(nil, "ARTWORK")
    AZPBossToolsVaultFrame.GenericButton.Texture:SetSize(20, 20)
    AZPBossToolsVaultFrame.GenericButton.Texture:SetPoint("CENTER", 0, 0)
    AZPBossToolsVaultFrame.GenericButton.Texture:SetTexture(GetFileIDFromPath("Interface/BUTTONS/UI-AttributeButton-Encourage-Up"))

    AZP.BossTools.Generic:CreateMainFrame()
end

function AZP.BossTools.Generic:OnLoadSelf()
    C_ChatInfo.RegisterAddonMessagePrefix("AZPGENERICINFO")

    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    EventFrame:RegisterEvent("VARIABLES_LOADED")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Generic:OnEvent(...) end)

    AZP.BossTools.Generic:OnLoadBoth()
end

function AZP.BossTools.Generic:CreateMainFrame()
    GenericBTFrame = CreateFrame("FRAME", nil, UIParent, "BackdropTemplate")
    GenericBTFrame:SetPoint("TOPLEFT", 100, -200)
    GenericBTFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    GenericBTFrame:EnableMouse(true)
    GenericBTFrame:SetMovable(true)
    GenericBTFrame:RegisterForDrag("LeftButton")
    GenericBTFrame:SetScript("OnDragStart", GenericBTFrame.StartMoving)
    GenericBTFrame:SetScript("OnDragStop", function() GenericBTFrame:StopMovingOrSizing() end)

    GenericBTFrame.Header = GenericBTFrame:CreateFontString("GenericBTFrame", "ARTWORK", "GameFontNormalHuge")
    GenericBTFrame.Header:SetSize(GenericBTFrame:GetWidth(), 25)
    GenericBTFrame.Header:SetPoint("TOP", 0, -5)
    GenericBTFrame.Header:SetText("Generic BossTool")

    GenericBTFrame.closeButton = CreateFrame("Button", nil, GenericBTFrame, "UIPanelCloseButton")
    GenericBTFrame.closeButton:SetSize(20, 21)
    GenericBTFrame.closeButton:SetPoint("TOPRIGHT", GenericBTFrame, "TOPRIGHT", 2, 2)
    GenericBTFrame.closeButton:SetScript("OnClick", function() GenericBTFrame:Hide() end)

    GenericBTFrame.GenericLabels = {}
end

function AZP.BossTools.Generic:FillMainFrame()
    GenericBTFrame:Show()
    local Rows, Cols = 0, 0
    for iRow = 1, #AZPBTGenericAssignedPlayers do
        Rows = iRow
        GenericBTFrame.GenericLabels[#GenericBTFrame.GenericLabels + 1] = {}
        for iCol = 1, #AZPBTGenericAssignedPlayers[iRow] do
            if iCol > Cols then Cols = iCol end
            if GenericBTFrame.GenericLabels[iRow][iCol] == nil then
                GenericBTFrame.GenericLabels[iRow][iCol] = GenericBTFrame:CreateFontString("GenericBTFrame", "ARTWORK", "GameFontNormal")
            end
            GenericBTFrame.GenericLabels[iRow][iCol]:SetSize(75, 25)
            GenericBTFrame.GenericLabels[iRow][iCol]:SetPoint("TOPLEFT", 75 * (iCol - 1), -25 * iRow - 5)
            GenericBTFrame.GenericLabels[iRow][iCol]:SetJustifyH("MIDDLE")
            if AZPBTGenericAssignedPlayers[iRow][iCol] == "-" then
                GenericBTFrame.GenericLabels[iRow][iCol]:SetText("-")
            else
                local curClassID = AZP.BossTools:GetClassIndexFromGUID(AZPBTGenericAssignedPlayers[iRow][iCol])
                local _, _, _, curClassColor = AZP.BossTools:GetClassColor(curClassID)
                local curName = AZPBTGenericGUIDs[AZPBTGenericAssignedPlayers[iRow][iCol]]
                GenericBTFrame.GenericLabels[iRow][iCol]:SetText(string.format("\124cFF%s%s\124r", curClassColor, curName))
            end
        end
    end

    GenericBTFrame:SetSize(Cols * 75, Rows * 25 + 30)
end

function AZP.BossTools.Generic:FillOptionsPanel(frameToFill)
    frameToFill.Header = frameToFill:CreateFontString("frameToFill", "ARTWORK", "GameFontNormalHuge")
    frameToFill.Header:SetPoint("TOP", 0, -10)
    frameToFill.Header:SetText("|cFF00FFFFAzerPUG's BossTools Options!|r")
    frameToFill.SubHeader = frameToFill:CreateFontString("frameToFill", "ARTWORK", "GameFontNormalLarge")
    frameToFill.SubHeader:SetPoint("TOP", 0, -35)
    frameToFill.SubHeader:SetText("|cFF00FFFFGeneric Boss Tool|r")

    -- frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    -- frameToFill.LockMoveButton:SetSize(100, 25)
    -- frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -50, -55)
    -- frameToFill.LockMoveButton:SetText("Lock Frame")
    -- frameToFill.LockMoveButton:SetScript("OnClick", function ()
    --     if AZP.BossTools.BossFrames.Generic:IsMovable() then
    --         AZP.BossTools.BossFrames.Generic:EnableMouse(false)
    --         AZP.BossTools.BossFrames.Generic:SetMovable(false)
    --         frameToFill.LockMoveButton:SetText("UnLock Frame!")
    --     else
    --         AZP.BossTools.BossFrames.Generic:EnableMouse(true)
    --         AZP.BossTools.BossFrames.Generic:SetMovable(true)
    --         frameToFill.LockMoveButton:SetText("Lock Frame")
    --     end
    -- end)

    -- frameToFill.ShowHideButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    -- frameToFill.ShowHideButton:SetSize(100, 25)
    -- frameToFill.ShowHideButton:SetPoint("TOPRIGHT", -50, -85)
    -- frameToFill.ShowHideButton:SetText("Hide Frame!")
    -- frameToFill.ShowHideButton:SetScript("OnClick", function () AZP.BossTools.Generic:ShowHideFrame() end)

    frameToFill.RowLabel = frameToFill:CreateFontString("RowLabel", "ARTWORK", "GameFontNormalLarge")
    frameToFill.RowLabel:SetSize(50, 25)
    frameToFill.RowLabel:SetPoint("TOPLEFT", 5, -5)
    frameToFill.RowLabel:SetText("Rows")

    frameToFill.RowEditBox = CreateFrame("EditBox", nil, frameToFill, "InputBoxTemplate BackdropTemplate")
    frameToFill.RowEditBox:SetSize(25, 25)
    frameToFill.RowEditBox:SetPoint("LEFT", frameToFill.RowLabel, "RIGHT", 5, 0)
    frameToFill.RowEditBox:SetFrameLevel(5)
    frameToFill.RowEditBox:SetAutoFocus(false)

    frameToFill.ColumnLabel = frameToFill:CreateFontString("ColumnLabel", "ARTWORK", "GameFontNormalLarge")
    frameToFill.ColumnLabel:SetSize(50, 25)
    frameToFill.ColumnLabel:SetPoint("TOP", frameToFill.RowLabel, "BOTTOM", 0, 0)
    frameToFill.ColumnLabel:SetText("Columns")

    frameToFill.ColumnEditBox = CreateFrame("EditBox", nil, frameToFill, "InputBoxTemplate BackdropTemplate")
    frameToFill.ColumnEditBox:SetSize(25, 25)
    frameToFill.ColumnEditBox:SetPoint("LEFT", frameToFill.ColumnLabel, "RIGHT", 5, 0)
    frameToFill.ColumnEditBox:SetFrameLevel(5)
    frameToFill.ColumnEditBox:SetAutoFocus(false)
    --frameToFill.ColumnEditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Generic:OnEditFocusLost("Left", i) end)

    local numRows, numCols = 0, 0

    frameToFill.CreateEditBoxes = CreateFrame("BUTTON", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.CreateEditBoxes:SetSize(80, 25)
    frameToFill.CreateEditBoxes:SetPoint("TOPLEFT", frameToFill.ColumnLabel, "BOTTOMLEFT", 0, 0)
    frameToFill.CreateEditBoxes:SetText("Add Boxes")
    frameToFill.CreateEditBoxes:SetScript("OnClick",
    function ()
        for iRow = 1, #AZPBTGenericEditBoxes do
            for iCol = 1, #AZPBTGenericEditBoxes[iRow] do
                local curFrame = AZPBTGenericEditBoxes[iRow][iCol]
                local curBox = curFrame.EditBox
                curBox:ClearAllPoints()
                curBox:SetParent(nil)
                curBox:Hide()
                curBox = nil
                curFrame:ClearAllPoints()
                curFrame:SetParent(nil)
                curFrame:Hide()
                curFrame = nil
            end
        end
        numRows = tonumber(frameToFill.RowEditBox:GetText())
        numCols = tonumber(frameToFill.ColumnEditBox:GetText())
        AZPBTGenericEditBoxes = {}
        AZPBTGenericAssignedPlayers = {}
        for iRow = 1, numRows do
            AZPBTGenericEditBoxes[#AZPBTGenericEditBoxes + 1] = {}
            AZPBTGenericAssignedPlayers[iRow] = {}
            for iCol = 1, numCols do
                AZPBTGenericAssignedPlayers[iRow][iCol] = "-"
                local curFrame = CreateFrame("FRAME", nil, frameToFill)
                curFrame:SetSize(75, 25)
                curFrame:SetPoint("TOPLEFT", 85 * (iCol - 1) + 20, -25 * iRow - 75)
                curFrame:SetFrameStrata("HIGH")
                curFrame:SetFrameLevel(10)
                curFrame:SetScript("OnEnter", function() AZP.BossTools.Generic:StartHoverOverCopy(iRow, iCol) end)
                curFrame:SetScript("OnLeave", function() AZP.BossTools.Generic:StopHoverOverCopy(iRow, iCol) end)
                curFrame:SetScript("OnMouseDown", function() curFrame.EditBox:SetFocus() end)
                curFrame.EditBox = CreateFrame("EditBox", nil, curFrame, "InputBoxTemplate BackdropTemplate")
                curFrame.EditBox:SetSize(curFrame:GetWidth(), curFrame:GetHeight())
                curFrame.EditBox:SetPoint("CENTER", 0, 0)
                curFrame.EditBox:SetFrameLevel(5)
                curFrame.EditBox:SetAutoFocus(false)
                curFrame.EditBox:SetScript("OnEditFocusLost", function() AZP.BossTools.Generic:OnEditFocusLost(iRow, iCol) end)
                curFrame.EditBox:SetScript("OnTextSet", function() AZP.BossTools.Generic:OnEditFocusLost(iRow, iCol) end)
                curFrame.EditBox:SetBackdrop({
                    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                    insets = { left = -4, right = 1, top = 6, bottom = 6 },
                })
                curFrame.EditBox:SetBackdropColor(1, 1, 1, 1)

                AZPBTGenericEditBoxes[iRow][#AZPBTGenericEditBoxes[iRow] + 1] = curFrame
            end
        end
    end)

    frameToFill.ShareButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.ShareButton:SetSize(100, 25)
    frameToFill.ShareButton:SetPoint("TOPRIGHT", -50, -25)
    frameToFill.ShareButton:SetText("Share List")
    frameToFill.ShareButton:SetScript("OnClick", function() AZP.BossTools.Generic:ShareAssignees() end )

    ------------------------------------------------------------------------------------

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
        curFrame:SetScript("OnMouseDown", function() GemFrame = curFrame AZP.BossTools.Generic:StartHoveringCopy() end)
        curFrame:SetScript("OnMouseUp", function() AZP.BossTools.Generic:StopHoveringCopy() end)

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

function AZP.BossTools.Generic:ShareAssignees()
    local FoundRaidIDs = nil
    for iRow = 1, #AZPBTGenericAssignedPlayers do
        for iCol = 1, #AZPBTGenericAssignedPlayers[iRow] do
            if AZPBTGenericAssignedPlayers[iRow][iCol] == "-" then
                if FoundRaidIDs == nil then
                    FoundRaidIDs = "0"
                else
                    if iCol == 1 then FoundRaidIDs = string.format("%s0", FoundRaidIDs)
                    else FoundRaidIDs = string.format("%s,0", FoundRaidIDs) end
                end
            else
                for raidID = 1, 40 do
                    if UnitGUID(string.format("raid%d", raidID)) == AZPBTGenericAssignedPlayers[iRow][iCol] then
                        if FoundRaidIDs == nil then
                            FoundRaidIDs = string.format("%d", raidID)
                        else
                            if iCol == 1 then FoundRaidIDs = string.format("%s%d", FoundRaidIDs, raidID)
                            else FoundRaidIDs = string.format("%s,%d", FoundRaidIDs, raidID) end
                        end
                    end
                end
            end
        end
        FoundRaidIDs = string.format("%s:", FoundRaidIDs)
    end
    C_ChatInfo.SendAddonMessage("AZPGENERICINFO", FoundRaidIDs ,"RAID", 1)
    --print("FoundRaidIDs:", FoundRaidIDs)
    return FoundRaidIDs
end

function AZP.BossTools.Generic:ReceiveAssignees(receiveAssignees)
    --print("receiveAssignees:", receiveAssignees)
    local RaidIDs = {}
    local iRow = 0
    for RowText in string.gmatch(receiveAssignees, "[^:]+") do
        iRow = iRow + 1
        RaidIDs[iRow] = {}
        local iCol = 0
        for ColText in string.gmatch(RowText, "[^,]+") do
            iCol = iCol + 1
            if ColText == "0" then
                RaidIDs[iRow][iCol] = "-"
            else
                RaidIDs[iRow][iCol] = UnitGUID(string.format("Raid%s", ColText))
            end
        end
    end

    AZPBTGenericAssignedPlayers = RaidIDs
    AZP.BossTools.Generic:FillMainFrame()
end

function AZP.BossTools.Generic:StartHoveringCopy()
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

function AZP.BossTools.Generic:StopHoveringCopy()
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

function AZP.BossTools.Generic:StartHoverOverCopy(iRow, iCol)
    if dragging == true then
        GemFrame.parent = AZPBTGenericEditBoxes[iRow][iCol]
        AZPBTGenericEditBoxes[iRow][iCol].EditBox:SetBackdropColor(0.25, 1, 0.25, 1)
    end
end

function AZP.BossTools.Generic:StopHoverOverCopy(iRow, iCol)
    local curFrame = AZPBTGenericEditBoxes[iRow][iCol]
    --if curFrame == nil then print("curFrame == nil") end
    --if curFrame.EditBox == nil then print("curFrame.EditBox == nil") end
    curFrame.EditBox:SetBackdropColor(1, 1, 1, 1)
    if GemFrame ~= nil then if GemFrame.parent ~= nil then GemFrame.parent = nil end end
end

function AZP.BossTools.Generic:OnEditFocusLost(iRow, iCol)
    local editBoxFrame = AZPBTGenericEditBoxes[iRow][iCol].EditBox
    if (editBoxFrame:GetText() ~= nil and editBoxFrame:GetText() ~= "") then
        for k = 1, 40 do
            local curName = GetRaidRosterInfo(k)
            if curName ~= nil then
                if string.find(curName, "-") then
                    curName = string.match(curName, "(.+)-")
                end
                if curName == editBoxFrame:GetText() then
                    local curGUID = UnitGUID("raid" .. k)
                    AZPBTGenericGUIDs[curGUID] = curName
                    AZPBTGenericAssignedPlayers[iRow][iCol] = curGUID
                    --AZP.BossTools.Sepulcher.Skolex:UpdateMainFrame()
                end
            end
        end
    else
        table.remove(AZPBTGenericAssignedPlayers[iRow], iCol)
    end
    AZP.BossTools.Generic:FillMainFrame()
end

function AZP.BossTools.Generic:OnEvent(_, event, ...)
    if event == "VARIABLES_LOADED" then
        AZP.BossTools.Generic:RefreshNames()
    elseif event == "CHAT_MSG_ADDON" then
        AZP.BossTools.Generic.Events:ChatMsgAddon(...)
    elseif event == "GROUP_ROSTER_UPDATE" then
        AZP.BossTools.Generic.Events:GroupRosterUpdate(...)
    end
end

function AZP.BossTools.Generic.Events:ChatMsgAddon(...)
    local prefix, payload, _, sender = ...
    if prefix == "AZPGENERICINFO" then
        --AZP.BossTools.Generic:CacheRaidNames()
        AZP.BossTools.Generic:ReceiveAssignees(payload)
        --AZP.BossTools:ShowReceiveFrame(sender, "Generic")
        --AZP.BossTools.ReceiveFrame:Show()
        --AZP.BossTools.Generic:CreateMainFrame()
    end
end

function AZP.BossTools.Generic:RefreshNames()
    local allUnitNames = {}
    local allNameLabels = AZPGenericOptions.AllNamesFrame.allNameLabels

    for _, frame in ipairs(allNameLabels) do
        frame:Hide()
    end

    for i = 1, 40 do
        local name = UnitName("RAID"..i)
        if name ~= nil then
            local _, _, classIndex = UnitClass("RAID"..i)
            allUnitNames[i] = {name, classIndex}
            local curGUID = UnitGUID("RAID" .. i)
            AZPBTGenericGUIDs[curGUID] = name
        end
    end

    for Index, curNameClass in pairs(allUnitNames) do
        local curFrame = allNameLabels[Index]
        if curFrame == nil then
            curFrame = CreateFrame("FRAME", nil, AZPGenericOptions.AllNamesFrame, "BackdropTemplate")
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
            curFrame:SetScript("OnMouseDown", function() GemFrame = curFrame AZP.BossTools.Generic:StartHoveringCopy() end)
            curFrame:SetScript("OnMouseUp", function() AZP.BossTools.Generic:StopHoveringCopy() end)

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

function AZP.BossTools.Generic.Events:GroupRosterUpdate(...)
    AZP.BossTools.Generic:RefreshNames(...)
end

AZP.BossTools.Generic:OnLoadSelf()