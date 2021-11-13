if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.TheEye == nil then AZP.BossTools.TheEye = {} end
if AZP.BossTools.TheEye.Events == nil then AZP.BossTools.TheEye.Events = {} end

local AssignedPlayers = {Left = {}, Right = {},}
local AZPBTTheEyeOptions = nil
local AZPBTTheEyeGUIDs, AZPBTTheEyeLeftEditBoxes, AZPBTTheEyeRightEditBoxes = {}, {}, {}

local EventFrame = nil

    --[[
            ToDo List:
            - Able to send all RaidIDs (RAID1, RAID2, RAID3)
            - On receive, check the GUIDs and save those (we MUST save the GUIDs!!)
            - On raidID change, make sure the GUIDs are still saved to the right location and the same people go in correcly
            Popup what side to go to (Left and Right for now, marker addition later!)
            




            Not all names can be send at once. Split it to send only 1 name at a time?
            Send GUID + Side and add to that specific sides list (AssignedPlayers.Left or AssignedPlayer.Right)
            Create Option Panel, in the main frame should be a extra button, like with Dormazain!
            ReCheck everything and test them shits.
    ]]

function AZP.BossTools.TheEye:OnLoadBoth()
    AZP.BossTools.TheEye:CreateMainFrame()
end

function AZP.BossTools.TheEye:OnLoadSelf()
    C_ChatInfo.RegisterAddonMessagePrefix("AZPEYEINFO")

    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:RegisterEvent("ENCOUNTER_END")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.TheEye:OnEvent(...) end)

    AZPBTTheEyeOptions = CreateFrame("FRAME", nil)
    AZPBTTheEyeOptions.name = "|cFF00FFFFTheEye|r"
    AZPBTTheEyeOptions.parent = AZP.BossTools.ParentOptionFrame.name
    InterfaceOptions_AddCategory(AZPBTTheEyeOptions)

    AZPBTTheEyeOptions.header = AZPBTTheEyeOptions:CreateFontString("AZPBTTheEyeOptions", "ARTWORK", "GameFontNormalHuge")
    AZPBTTheEyeOptions.header:SetPoint("TOP", 0, -10)
    AZPBTTheEyeOptions.header:SetText("|cFF00FFFFAzerPUG's BossTools Options!|r")
    AZPBTTheEyeOptions.SubHeader = AZPBTTheEyeOptions:CreateFontString("AZPBTTheEyeOptions", "ARTWORK", "GameFontNormalLarge")
    AZPBTTheEyeOptions.SubHeader:SetPoint("TOP", 0, -35)
    AZPBTTheEyeOptions.SubHeader:SetText("|cFF00FFFFTheEye|r")

    AZPBTTheEyeOptions.footer = AZPBTTheEyeOptions:CreateFontString("AZPBTTheEyeOptions", "ARTWORK", "GameFontNormalLarge")
    AZPBTTheEyeOptions.footer:SetPoint("TOP", 0, -400)
    AZPBTTheEyeOptions.footer:SetText(
        "|cFF00FFFFAzerPUG Links:\n" ..
        "Website: www.azerpug.com\n" ..
        "Discord: www.azerpug.com/discord\n" ..
        "Twitch: www.twitch.tv/azerpug\n|r"
    )

    AZP.BossTools.TheEye:FillOptionsPanel(AZPBTTheEyeOptions)
    AZP.BossTools.TheEye:OnLoadBoth()
end

function AZP.BossTools.TheEye:CreateMainFrame()
    local TheEyeFrame = CreateFrame("FRAME", nil, UIPanel, "BackdropTemplate")
    TheEyeFrame:SetSize(300, 125)
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
    TheEyeFrame.Header:SetText("sides Assignments")

    TheEyeFrame.TextLabels = {}
    TheEyeFrame.LeftLabels = {}
    TheEyeFrame.RightLabels = {}

    for i = 1, 20 do
        TheEyeFrame.TextLabels[i] = TheEyeFrame:CreateFontString("TheEyeFrame", "ARTWORK", "GameFontNormal")
        TheEyeFrame.TextLabels[i]:SetSize(50, 25)
        TheEyeFrame.TextLabels[i]:SetPoint("TOPLEFT", 0, ((i - 1) * -15) -35)
        TheEyeFrame.TextLabels[i]:SetJustifyH("RIGHT")
        TheEyeFrame.TextLabels[i]:SetText(string.format("Chain %d:", i))

        TheEyeFrame.LeftLabels[i] = TheEyeFrame:CreateFontString("TheEyeFrame", "ARTWORK", "GameFontNormal")
        TheEyeFrame.LeftLabels[i]:SetSize(75, 25)
        TheEyeFrame.LeftLabels[i]:SetPoint("LEFT", TheEyeFrame.TextLabels[i], "RIGHT", 5, 0)
        TheEyeFrame.LeftLabels[i]:SetJustifyH("MIDDLE")
        TheEyeFrame.LeftLabels[i]:SetText("-")

        TheEyeFrame.RightLabels[i] = TheEyeFrame:CreateFontString("TheEyeFrame", "ARTWORK", "GameFontNormal")
        TheEyeFrame.RightLabels[i]:SetSize(75, 25)
        TheEyeFrame.RightLabels[i]:SetPoint("LEFT", TheEyeFrame.LeftLabels[i], "RIGHT", 5, 0)
        TheEyeFrame.RightLabels[i]:SetJustifyH("MIDDLE")
        TheEyeFrame.RightLabels[i]:SetText("-")
    end

    TheEyeFrame.closeButton = CreateFrame("Button", nil, TheEyeFrame, "UIPanelCloseButton")
    TheEyeFrame.closeButton:SetSize(20, 21)
    TheEyeFrame.closeButton:SetPoint("TOPRIGHT", TheEyeFrame, "TOPRIGHT", 2, 2)
    TheEyeFrame.closeButton:SetScript("OnClick", function() TheEyeFrame:Hide() end)

    AZP.BossTools.BossFrames.TheEye = TheEyeFrame
    TheEyeFrame:Hide()
end

function AZP.BossTools.TheEye:FillOptionsPanel(frameToFill)
    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -75, -50)
    frameToFill.LockMoveButton:SetText("Share List")
    frameToFill.LockMoveButton:SetScript("OnClick", function() AZP.BossTools.TheEye:ShareAssignees() end )

    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -75, -100)
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
    frameToFill.ShowHideButton:SetPoint("TOPRIGHT", -75, -150)
    frameToFill.ShowHideButton:SetText("Hide Frame!")
    frameToFill.ShowHideButton:SetScript("OnClick", function () AZP.BossTools.TheEye:ShowHideFrame() end)

    frameToFill.textlabels = {}

    frameToFill.LeftHeader = frameToFill:CreateFontString("LeftChainFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.LeftHeader:SetSize(100, 25)
    frameToFill.LeftHeader:SetPoint("TOPLEFT", 70, -100)
    frameToFill.LeftHeader:SetText("Left")

    frameToFill.RightHeader = frameToFill:CreateFontString("LeftChainFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.RightHeader:SetSize(100, 25)
    frameToFill.RightHeader:SetPoint("LEFT", frameToFill.LeftHeader, "RIGHT", 10, 0)
    frameToFill.RightHeader:SetText("Right")

    for i = 1,10 do
        frameToFill.textlabels[i] = frameToFill:CreateFontString("frameToFill", "ARTWORK", "GameFontNormalLarge")
        frameToFill.textlabels[i]:SetSize(50, 25)
        frameToFill.textlabels[i]:SetPoint("TOPLEFT", 10, -30 * i - 100)
        frameToFill.textlabels[i]:SetText(string.format("Chain %d:", i))

        AZPBTTheEyeLeftEditBoxes[i] = CreateFrame("EditBox", nil, frameToFill, "InputBoxTemplate")
        AZPBTTheEyeLeftEditBoxes[i]:SetSize(75, 25)
        AZPBTTheEyeLeftEditBoxes[i]:SetPoint("LEFT", frameToFill.textlabels[i], "RIGHT", 10, 0)
        AZPBTTheEyeLeftEditBoxes[i]:SetAutoFocus(false)
        AZPBTTheEyeLeftEditBoxes[i]:SetScript("OnEditFocusLost", function() AZP.BossTools.TheEye:OnEditFocusLost(AZPBTTheEyeLeftEditBoxes[i], "Left", i) end)

        AZPBTTheEyeLeftEditBoxes[i + 10] = CreateFrame("EditBox", nil, frameToFill, "InputBoxTemplate")
        AZPBTTheEyeLeftEditBoxes[i + 10]:SetSize(75, 25)
        AZPBTTheEyeLeftEditBoxes[i + 10]:SetPoint("LEFT", AZPBTTheEyeLeftEditBoxes[i], "RIGHT", 10, 0)
        AZPBTTheEyeLeftEditBoxes[i + 10]:SetAutoFocus(false)
        AZPBTTheEyeLeftEditBoxes[i + 10]:SetScript("OnEditFocusLost", function() AZP.BossTools.TheEye:OnEditFocusLost(AZPBTTheEyeLeftEditBoxes[i + 10], "Left", i+10) end)

        AZPBTTheEyeRightEditBoxes[i] = CreateFrame("EditBox", nil, frameToFill, "InputBoxTemplate")
        AZPBTTheEyeRightEditBoxes[i]:SetSize(75, 25)
        AZPBTTheEyeRightEditBoxes[i]:SetPoint("LEFT", AZPBTTheEyeLeftEditBoxes[i + 10], "RIGHT", 10, 0)
        AZPBTTheEyeRightEditBoxes[i]:SetAutoFocus(false)
        AZPBTTheEyeRightEditBoxes[i]:SetScript("OnEditFocusLost", function() AZP.BossTools.TheEye:OnEditFocusLost(AZPBTTheEyeRightEditBoxes[i], "Right", i) end)

        AZPBTTheEyeRightEditBoxes[i + 10] = CreateFrame("EditBox", nil, frameToFill, "InputBoxTemplate")
        AZPBTTheEyeRightEditBoxes[i + 10]:SetSize(75, 25)
        AZPBTTheEyeRightEditBoxes[i + 10]:SetPoint("LEFT", AZPBTTheEyeRightEditBoxes[i], "RIGHT", 10, 0)
        AZPBTTheEyeRightEditBoxes[i + 10]:SetAutoFocus(false)
        AZPBTTheEyeRightEditBoxes[i + 10]:SetScript("OnEditFocusLost", function() AZP.BossTools.TheEye:OnEditFocusLost(AZPBTTheEyeRightEditBoxes[i + 10], "Right", i+10) end)
    end

    frameToFill:Hide()
end

function AZP.BossTools.TheEye:OnEditFocusLost(editBoxFrame, sides, index)
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
                    AssignedPlayers[sides][index] = curGUID
                    AZP.BossTools.TheEye:UpdateMainFrame()
                end
            end
        end
    else
        table.remove(AssignedPlayers[sides], index)
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


function AZP.BossTools.TheEye:ReceiveAssignees(receiveAssignees)     -- XXX
    print(receiveAssignees)
    local left, right = string.match(receiveAssignees, "([^:]*):([^:]*)")
    AssignedPlayers.Left = {}
    AssignedPlayers.Right = {}
    for RaidID in string.gmatch(left, "%d+") do
        print("Raid ID left: ", RaidID)
        table.insert(AssignedPlayers.Left, UnitGUID(string.format("raid%d", RaidID)))
    end

    for RaidID in string.gmatch(right, "%d+") do
        print("Raid ID right: ", RaidID)
        table.insert(AssignedPlayers.Right, UnitGUID(string.format("raid%d", RaidID)))
    end

    -- local sides, left, right = string.match(receiveAssignees, "([^:]*):([^:]*):([^:]*)")
    -- if left == "" then left = nil end
    -- if right == "" then right = nil end
    -- AssignedPlayers = {Left = left, Right = right}
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
            AZP.BossTools.BossFrames.TheEye.LeftLabels[i]:SetText(name)
            AZPBTTheEyeLeftEditBoxes[i]:SetText(name)
        else
            AZPBTTheEyeLeftEditBoxes[i]:SetText("")
            AZP.BossTools.BossFrames.TheEye.LeftLabels[i]:SetText("")
        end
        if right ~= nil then
            local name = AZPBTTheEyeGUIDs[right]
            if name == nil then name = "" end
            AZP.BossTools.BossFrames.TheEye.RightLabels[i]:SetText(name)
            AZPBTTheEyeRightEditBoxes[i]:SetText(name)
        else
            AZPBTTheEyeRightEditBoxes[i]:SetText("")
            AZP.BossTools.BossFrames.TheEye.RightLabels[i]:SetText("")
        end
    end
end


function AZP.BossTools.TheEye:OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        AZP.BossTools.TheEye.Events:CombatLogEventUnfiltered(...)
    elseif event == "CHAT_MSG_ADDON" then
        AZP.BossTools.TheEye.Events:ChatMsgAddon(...)
    elseif event == "ENCOUNTER_END" then
        AZP.BossTools.TheEye.Events:EncounterEnd(...)
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
    -- for i = 1, #AZPBTTheEyeSides do
    --     if AZPBTTheEyeChains.Left[i] == curGUID then side = "Left" end
    --     if AZPBTTheEyeChains.Right[i] == curGUID then side = "Right" end
    -- end

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