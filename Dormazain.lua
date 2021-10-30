if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Dormazain == nil then AZP.BossTools.Dormazain = {} end
if AZP.BossTools.Dormazain.Events == nil then AZP.BossTools.Dormazain.Events = {} end

local AssignedPlayers = {}
local AZPBTDormazainOptions = nil
local AZPBTDormazainGUIDs, AZPBTDormazainLeftEditBoxes, AZPBTDormazainMidEditBoxes, AZPBTDormazainRightEditBoxes = {}, {}, {}, {}

local ChainsCount = 0

local EventFrame = nil

function AZP.BossTools.Dormazain:OnLoadBoth()
    for i=1,6 do
        local chainsSet = string.format("Chain%d", i)
        AssignedPlayers[chainsSet] = {}
    end
    AZP.BossTools.Dormazain:CreateMainFrame()
end

function AZP.BossTools.Dormazain:OnLoadSelf()
    C_ChatInfo.RegisterAddonMessagePrefix("AZPDORMINFO")

    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Dormazain:OnEvent(...) end)

    AZPBTDormazainOptions = CreateFrame("FRAME", nil)
    AZPBTDormazainOptions.name = "|cFF00FFFFDormazain|r"
    AZPBTDormazainOptions.parent = AZP.BossTools.ParentOptionFrame.name
    InterfaceOptions_AddCategory(AZPBTDormazainOptions)

    AZPBTDormazainOptions.header = AZPBTDormazainOptions:CreateFontString("AZPBTDormazainOptions", "ARTWORK", "GameFontNormalHuge")
    AZPBTDormazainOptions.header:SetPoint("TOP", 0, -10)
    AZPBTDormazainOptions.header:SetText("|cFF00FFFFAzerPUG's BossTools Options!|r")
    AZPBTDormazainOptions.SubHeader = AZPBTDormazainOptions:CreateFontString("AZPBTDormazainOptions", "ARTWORK", "GameFontNormalLarge")
    AZPBTDormazainOptions.SubHeader:SetPoint("TOP", 0, -35)
    AZPBTDormazainOptions.SubHeader:SetText("|cFF00FFFFDormazain|r")

    AZPBTDormazainOptions.footer = AZPBTDormazainOptions:CreateFontString("AZPBTDormazainOptions", "ARTWORK", "GameFontNormalLarge")
    AZPBTDormazainOptions.footer:SetPoint("TOP", 0, -400)
    AZPBTDormazainOptions.footer:SetText(
        "|cFF00FFFFAzerPUG Links:\n" ..
        "Website: www.azerpug.com\n" ..
        "Discord: www.azerpug.com/discord\n" ..
        "Twitch: www.twitch.tv/azerpug\n|r"
    )

    AZP.BossTools.Dormazain:FillOptionsPanel(AZPBTDormazainOptions)
    AZP.BossTools.Dormazain:OnLoadBoth()
end

function AZP.BossTools.Dormazain:CreateMainFrame()
    local DormazainFrame = CreateFrame("FRAME", nil, UIPanel, "BackdropTemplate")
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
        DormazainFrame.TextLabels[i]:SetText(string.format("Chain %d:", i))

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

    DormazainFrame.closeButton = CreateFrame("Button", nil, DormazainFrame, "UIPanelCloseButton")
    DormazainFrame.closeButton:SetSize(20, 21)
    DormazainFrame.closeButton:SetPoint("TOPRIGHT", DormazainFrame, "TOPRIGHT", 2, 2)
    DormazainFrame.closeButton:SetScript("OnClick", function() DormazainFrame:Hide() end)

    AZP.BossTools.BossFrames.Dormazain = DormazainFrame
    DormazainFrame:Hide()
end

function AZP.BossTools.Dormazain:FillOptionsPanel(frameToFill)
    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -75, -50)
    frameToFill.LockMoveButton:SetText("Share List")
    frameToFill.LockMoveButton:SetScript("OnClick", function() AZP.BossTools.Dormazain:ShareAssignees() end )

    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -75, -100)
    frameToFill.LockMoveButton:SetText("Lock Frame")
    frameToFill.LockMoveButton:SetScript("OnClick", function ()
        if AZP.BossTools.BossFrames.Dormazain:IsMovable() then
            AZP.BossTools.BossFrames.Dormazain:EnableMouse(false)
            AZP.BossTools.BossFrames.Dormazain:SetMovable(false)
            frameToFill.LockMoveButton:SetText("UnLock Frame!")
        else
            AZP.BossTools.BossFrames.Dormazain:EnableMouse(true)
            AZP.BossTools.BossFrames.Dormazain:SetMovable(true)
            frameToFill.LockMoveButton:SetText("Lock Frame")
        end
    end)

    frameToFill.ShowHideButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.ShowHideButton:SetSize(100, 25)
    frameToFill.ShowHideButton:SetPoint("TOPRIGHT", -75, -150)
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
        frameToFill.textlabels[i]:SetText(string.format("Chain %d:", i))

        AZPBTDormazainLeftEditBoxes[i] = CreateFrame("EditBox", nil, frameToFill, "InputBoxTemplate")
        AZPBTDormazainLeftEditBoxes[i]:SetSize(100, 25)
        AZPBTDormazainLeftEditBoxes[i]:SetPoint("LEFT", frameToFill.textlabels[i], "RIGHT", 10, 0)
        AZPBTDormazainLeftEditBoxes[i]:SetAutoFocus(false)
        AZPBTDormazainLeftEditBoxes[i]:SetScript("OnEditFocusLost", function() AZP.BossTools.Dormazain:OnEditFocusLost("Left", i) end)

        AZPBTDormazainMidEditBoxes[i] = CreateFrame("EditBox", nil, frameToFill, "InputBoxTemplate")
        AZPBTDormazainMidEditBoxes[i]:SetSize(100, 25)
        AZPBTDormazainMidEditBoxes[i]:SetPoint("LEFT", AZPBTDormazainLeftEditBoxes[i], "RIGHT", 10, 0)
        AZPBTDormazainMidEditBoxes[i]:SetAutoFocus(false)
        AZPBTDormazainMidEditBoxes[i]:SetScript("OnEditFocusLost", function() AZP.BossTools.Dormazain:OnEditFocusLost("Mid", i) end)

        AZPBTDormazainRightEditBoxes[i] = CreateFrame("EditBox", nil, frameToFill, "InputBoxTemplate")
        AZPBTDormazainRightEditBoxes[i]:SetSize(100, 25)
        AZPBTDormazainRightEditBoxes[i]:SetPoint("LEFT", AZPBTDormazainMidEditBoxes[i], "RIGHT", 10, 0)
        AZPBTDormazainRightEditBoxes[i]:SetAutoFocus(false)
        AZPBTDormazainRightEditBoxes[i]:SetScript("OnEditFocusLost", function() AZP.BossTools.Dormazain:OnEditFocusLost("Right", i) end)
    end

    frameToFill:Hide()
end

function AZP.BossTools.Dormazain:OnEditFocusLost(position, chains)
    local editBoxFrame = nil
    local chainsSet = string.format("Chain%d", chains)
    if position == "Left" then
        editBoxFrame = AZPBTDormazainLeftEditBoxes[chains]
    elseif position == "Mid" then
        editBoxFrame = AZPBTDormazainMidEditBoxes[chains]
    elseif position == "Right" then
        editBoxFrame = AZPBTDormazainRightEditBoxes[chains]
    end
    print(editBoxFrame:GetText())
    if (editBoxFrame:GetText() ~= nil and editBoxFrame:GetText() ~= "") then
        for k = 1, 40 do
            local curName = GetRaidRosterInfo(k)
            if curName ~= nil then
                if string.find(curName, "-") then
                    curName = string.match(curName, "(.+)-")
                end
                if curName == editBoxFrame:GetText() then
                    local curGUID = UnitGUID("raid" .. k)
                    print("Found GUID:", curGUID)
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
        local ring = AssignedPlayers[chainsSet]
        local left = ring.Left
        local mid = ring.Mid
        local right = ring.Right

        if left ~= nil then
            local name = AZPBTDormazainGUIDs[left]
            if name == nil then name = "" end
            AZP.BossTools.BossFrames.Dormazain.LeftLabels[i]:SetText(name)
            AZPBTDormazainLeftEditBoxes[i]:SetText(name)
        else
            AZPBTDormazainLeftEditBoxes[i]:SetText("")
            AZP.BossTools.BossFrames.Dormazain.LeftLabels[i]:SetText("")
        end
        if mid ~= nil then
            local name = AZPBTDormazainGUIDs[mid]
            if name == nil then name = "" end
            AZP.BossTools.BossFrames.Dormazain.MidLabels[i]:SetText(name)
            AZPBTDormazainMidEditBoxes[i]:SetText(name)
        else
            AZPBTDormazainMidEditBoxes[i]:SetText("")
            AZP.BossTools.BossFrames.Dormazain.MidLabels[i]:SetText("")
        end
        if right ~= nil then
            local name = AZPBTDormazainGUIDs[right]
            if name == nil then name = "" end
            AZP.BossTools.BossFrames.Dormazain.RightLabels[i]:SetText(name)
            AZPBTDormazainRightEditBoxes[i]:SetText(name)
        else
            AZPBTDormazainRightEditBoxes[i]:SetText("")
            AZP.BossTools.BossFrames.Dormazain.RightLabels[i]:SetText("")
        end
    end
end

function AZP.BossTools.Dormazain:ReceiveAssignees(receiveAssignees)     -- XXX
    local chains, left, mid, right = string.match(receiveAssignees, "([^:]*):([^:]*):([^:]*):([^:]*)")
    if left == "" then left = nil end
    if mid == "" then mid = nil end
    if right == "" then right = nil end
    AssignedPlayers[chains] = {Left = left, Mid = mid, Right = right}
    AZP.BossTools.Dormazain:UpdateMainFrame()
end

function AZP.BossTools.Dormazain:OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        AZP.BossTools.Dormazain.Events:CombatLogEventUnfiltered(...)
    elseif event == "CHAT_MSG_ADDON" then
        AZP.BossTools.Dormazain.Events:ChatMsgAddon(...)
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

function AZP.BossTools.Dormazain.Events:WarmongerShackles()
    print("WarmongerShackles Called!")
    ChainsCount = ChainsCount + 1           -- SET BACK TO 0 WHEN COMBAT ENDS OR STARTS, OR WIPES WILL FUCK IT UP!!
    local curChain = string.format("Chain%s", ChainsCount)
    local curGUID = UnitGUID("PLAYER")
    local assignedPosition = nil
    if AZPBTDormazainChains[curChain].Left == curGUID then assignedPosition = "Left" end
    if AZPBTDormazainChains[curChain].Mid == curGUID then assignedPosition = "Mid" end
    if AZPBTDormazainChains[curChain].Right == curGUID then assignedPosition = "Right" end

    if assignedPosition ~= nil then
        local warnText = string.format("ChainSet %d - Pick up %s!", ChainsCount, assignedPosition)
        print(warnText)
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