if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

AZP.VersionControl["BossTools RohKalo"] = 19
if AZP.BossTools.RohKalo == nil then AZP.BossTools.RohKalo = {} end
if AZP.BossTools.RohKalo.Events == nil then AZP.BossTools.RohKalo.Events = {} end

local AssignedPlayers = {}
local AZPRTRohKaloAlphaFrame, AZPBossToolsRohKaloOptionPanel = nil, nil
local AZPBossToolsRohKaloGUIDs, AZPBossToolsRohKaloAlphaEditBoxes, AZPBossToolsRohKaloBetaEditBoxes = {}, {}, {}

if AZPBossToolsRohKaloSettingsList == nil then AZPBossToolsRohKaloSettingsList = {} end

if AZPAZPShownLocked == nil then AZPAZPShownLocked = {false, false} end

local UpdateFrame, EventFrame = nil, nil
local HaveShowedUpdateNotification = false

local PopUpFrame = nil
local curScale = 0.75
local soundID = 8959
local soundChannel = 1

local cooldownTicker = nil

local optionHeader = "|cFF00FFFFBossTools RohKalo|r"

function AZP.BossTools.RohKalo:OnLoadBoth()
    for i = 1, 6 do
        AssignedPlayers[string.format( "Ring%d",i )] = {}
    end
    AZP.BossTools.RohKalo:CreateMainFrame()
    AZP.BossTools.RohKalo:CreatePopUpFrame()
end

-- function AZP.BossTools.RohKalo:OnLoadCore()
--     AZP.BossTools.RohKalo:OnLoadBoth()
--     AZP.Core:RegisterEvents("COMBAT_LOG_EVENT_UNFILTERED", function(...) AZP.BossTools.RohKalo.Events:CombatLogEventUnfiltered(...) end)
--     AZP.Core:RegisterEvents("VARIABLES_LOADED", function(...) AZP.BossTools.RohKalo.Events:VariablesLoaded(...) end)
--     AZP.Core:RegisterEvents("CHAT_MSG_ADDON", function(...) AZP.BossTools.RohKalo.Events:ChatMsgAddonInterrupts(...) end)
--     AZP.Core:RegisterEvents("ENCOUNTER_START", function(...) AZP.BossTools.RohKalo.Events:PlayerEnterCombat(...) end)
--     AZP.Core:RegisterEvents("ENCOUNTER_END", function(...) AZP.BossTools.RohKalo.Events:PlayerLeaveCombat(...) end)

--     AZP.OptionsPanels:RemovePanel("BossTools RohKalo")
--     AZP.OptionsPanels:Generic("BossTools RohKalo", optionHeader, function(frame)
--         AZPBossTools.RohKaloOptionPanel = frame
--         AZP.BossTools.RohKalo:FillOptionsPanel(frame)
--     end)
-- end

function AZP.BossTools.RohKalo:GetPlayersWithHeroicBuff()
    local players = {}
    for i = 1, 40 do
        local unit = string.format("raid%d", i)
        local currentBuffIndex = 1
        local buffName, icon, _, _, _, expirationTimer, _, _, _, buffID = UnitBuff(unit, currentBuffIndex)
        while buffName ~= nil do
            currentBuffIndex = currentBuffIndex + 1
            --if buffID == 354964 then
            if buffID == 768 then
                table.insert(players, {ID = UnitGUID(unit), Unit= unit })
            end
            buffName, icon, _, _, _, expirationTimer, _, _, _, buffID = UnitBuff(unit, currentBuffIndex)
        end
    end
    return players
end

function AZP.BossTools.RohKalo:ConcatTable(dest, ...)
    for i = 1, select("#", ...) do
        local t = select(i, ...)
        for _,v in ipairs(t) do
            table.insert(dest, v)
        end
    end
end

function AZP.BossTools.RohKalo:OrganizePlayers()
    local tanks, healers, dps = {}, {}, {}
    local alphas, betas = {}, {}
    local players = AZP.BossTools.RohKalo:GetPlayersWithHeroicBuff()
    

    table.sort(players, function(a,b) return a.ID > b.ID end)
    for _, player in ipairs(players) do
        local role = UnitGroupRolesAssigned(player.Unit)
        if role == "TANK" then
            table.insert(tanks, player.ID)
        elseif role == "HEALER" then
            table.insert(healers, player.ID)
        else
            table.insert(dps, player.ID)
        end
    end

    local bigList = {}
    AZP.BossTools.RohKalo:ConcatTable(bigList, dps, tanks, healers)

    local numPlayers = #bigList
    if numPlayers > 0 then

        for i = 1, 6 do
            AssignedPlayers[string.format("Ring%d", i)] = {}
        end
            
        for i, player in ipairs(bigList) do
            if i <= ceil(numPlayers/2) then
                table.insert(alphas, player)
            else
                table.insert(betas, player)
            end
        end

        for i, playerID in ipairs(alphas) do
            AssignedPlayers[string.format( "Ring%d",i )].Alpha = playerID
            if betas[i] ~= nil then
                AssignedPlayers[string.format( "Ring%d",i )].Beta = betas[i]
            end
        end
        AZP.BossTools.RohKalo:CacheRaidNames()
        AZP.BossTools.RohKalo:UpdateRohKaloFrame()
    end
end

function AZP.BossTools.RohKalo:OnLoadSelf()
    C_ChatInfo.RegisterAddonMessagePrefix("AZPVERSIONS")
    C_ChatInfo.RegisterAddonMessagePrefix("AZPRKHHelp")
    C_ChatInfo.RegisterAddonMessagePrefix("AZPRKHINFO")

    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("VARIABLES_LOADED")
    EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.RohKalo:OnEvent(...) end)

    AZPBossToolsRohKaloOptionPanel = CreateFrame("FRAME", nil)
    AZPBossToolsRohKaloOptionPanel.name = "|cFF00FFFFAzerPUG's BossTools|r"
    InterfaceOptions_AddCategory(AZPBossToolsRohKaloOptionPanel)

    AZPBossToolsRohKaloOptionPanel.header = AZPBossToolsRohKaloOptionPanel:CreateFontString("AZPBossToolsRohKaloOptionPanel", "ARTWORK", "GameFontNormalHuge")
    AZPBossToolsRohKaloOptionPanel.header:SetPoint("TOP", 0, -10)
    AZPBossToolsRohKaloOptionPanel.header:SetText("|cFF00FFFFAzerPUG's BossTools Options!|r")

    AZPBossToolsRohKaloOptionPanel.footer = AZPBossToolsRohKaloOptionPanel:CreateFontString("AZPBossToolsRohKaloOptionPanel", "ARTWORK", "GameFontNormalLarge")
    AZPBossToolsRohKaloOptionPanel.footer:SetPoint("TOP", 0, -400)
    AZPBossToolsRohKaloOptionPanel.footer:SetText(
        "|cFF00FFFFAzerPUG Links:\n" ..
        "Website: www.azerpug.com\n" ..
        "Discord: www.azerpug.com/discord\n" ..
        "Twitch: www.twitch.tv/azerpug\n|r"
    )

    AZP.BossTools.RohKalo:FillOptionsPanel(AZPBossToolsRohKaloOptionPanel)
    AZP.BossTools.RohKalo:OnLoadBoth()

    UpdateFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    UpdateFrame:SetPoint("CENTER", 0, 250)
    UpdateFrame:SetSize(400, 200)
    UpdateFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    UpdateFrame:SetBackdropColor(0.25, 0.25, 0.25, 0.80)
    UpdateFrame.header = UpdateFrame:CreateFontString("UpdateFrame", "ARTWORK", "GameFontNormalHuge")
    UpdateFrame.header:SetPoint("TOP", 0, -10)
    UpdateFrame.header:SetText("|cFFFF0000AzerPUG's BossTools.RohKalo is out of date!|r")

    UpdateFrame.text = UpdateFrame:CreateFontString("UpdateFrame", "ARTWORK", "GameFontNormalLarge")
    UpdateFrame.text:SetPoint("TOP", 0, -40)
    UpdateFrame.text:SetText("Error!")

    local UpdateFrameCloseButton = CreateFrame("Button", nil, UpdateFrame, "UIPanelCloseButton")
    UpdateFrameCloseButton:SetWidth(25)
    UpdateFrameCloseButton:SetHeight(25)
    UpdateFrameCloseButton:SetPoint("TOPRIGHT", UpdateFrame, "TOPRIGHT", 2, 2)
    UpdateFrameCloseButton:SetScript("OnClick", function() UpdateFrame:Hide() end )

    UpdateFrame:Hide()
end

function AZP.BossTools.RohKalo:FillOptionsPanel(frameToFill)
    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -75, -50)
    frameToFill.LockMoveButton:SetText("Share List")
    frameToFill.LockMoveButton:SetScript("OnClick", function() AZP.BossTools.RohKalo:ShareAssignees() end )

    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -75, -100)
    frameToFill.LockMoveButton:SetText("Lock Frame")
    frameToFill.LockMoveButton:SetScript("OnClick", function ()
        if AZPRTRohKaloAlphaFrame:IsMovable() then
            AZPRTRohKaloAlphaFrame:EnableMouse(false)
            AZPRTRohKaloAlphaFrame:SetMovable(false)
            frameToFill.LockMoveButton:SetText("UnLock Frame!")
        else
            AZPRTRohKaloAlphaFrame:EnableMouse(true)
            AZPRTRohKaloAlphaFrame:SetMovable(true)
            frameToFill.LockMoveButton:SetText("Lock Frame")
        end
    end)

    frameToFill.ShowHideButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.ShowHideButton:SetSize(100, 25)
    frameToFill.ShowHideButton:SetPoint("TOPRIGHT", -75, -150)
    frameToFill.ShowHideButton:SetText("Hide Frame!")
    frameToFill.ShowHideButton:SetScript("OnClick", function () AZP.BossTools.RohKalo:ShowHideFrame() end)

    frameToFill:Hide()

    for i = 1,6 do
        local AssigneesFrame = CreateFrame("Frame", nil, frameToFill)
        AssigneesFrame:SetSize(200, 25)
        AssigneesFrame:SetPoint("TOPLEFT", 25, -30*i - 75)
        AssigneesFrame.editbox = CreateFrame("EditBox", nil, AssigneesFrame, "InputBoxTemplate")
        AssigneesFrame.editbox:SetSize(100, 25)
        AssigneesFrame.editbox:SetPoint("LEFT", 100, 0)
        AssigneesFrame.editbox:SetAutoFocus(false)
        AssigneesFrame.text = AssigneesFrame:CreateFontString("AssigneesFrame", "ARTWORK", "GameFontNormalLarge")
        AssigneesFrame.text:SetSize(100, 25)
        AssigneesFrame.text:SetPoint("LEFT", 0, 0)
        AssigneesFrame.text:SetText("Ring " .. i .. ":")

        AZPBossToolsRohKaloAlphaEditBoxes[i] = AssigneesFrame

        AssigneesFrame.editbox:SetScript("OnEditFocusLost",
        function()
            AZP.BossTools.RohKalo:OnEditFocusLost("Alpha", i)
        end)
    end

    frameToFill.assigneeHeader = frameToFill:CreateFontString("AssigneesFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.assigneeHeader:SetSize(100, 25)
    frameToFill.assigneeHeader:SetPoint("BOTTOM", AZPBossToolsRohKaloAlphaEditBoxes[1].editbox, "TOP", 0, 0)
    frameToFill.assigneeHeader:SetText("Alpha")

    for i = 1, 6 do
        local BackUpsFrame = CreateFrame("Frame", nil, frameToFill)
        BackUpsFrame:SetSize(100, 25)
        BackUpsFrame:SetPoint("LEFT", AZPBossToolsRohKaloAlphaEditBoxes[i], "RIGHT", 5, 0)
        BackUpsFrame.editbox = CreateFrame("EditBox", nil, BackUpsFrame, "InputBoxTemplate")
        BackUpsFrame.editbox:SetSize(100, 25)
        BackUpsFrame.editbox:SetPoint("LEFT",0, 0)
        BackUpsFrame.editbox:SetAutoFocus(false)
        AZPBossToolsRohKaloBetaEditBoxes[i] = BackUpsFrame

        BackUpsFrame.editbox:SetScript("OnEditFocusLost",
        function()
            AZP.BossTools.RohKalo:OnEditFocusLost("Beta", i)
        end)
    end

    frameToFill.backupHeader = frameToFill:CreateFontString("AssigneesFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.backupHeader:SetSize(100, 25)
    frameToFill.backupHeader:SetPoint("BOTTOM", AZPBossToolsRohKaloBetaEditBoxes[1], "TOP", 0, 0)
    frameToFill.backupHeader:SetText("Beta")

    frameToFill:Hide()
end

function AZP.BossTools.RohKalo:CreateMainFrame()

    AZPRTRohKaloAlphaFrame = CreateFrame("FRAME", nil, UIPanel, "BackdropTemplate")
    AZPRTRohKaloAlphaFrame:SetSize(175, 150)
    AZPRTRohKaloAlphaFrame:SetPoint("TOPLEFT", 100, -200)
    AZPRTRohKaloAlphaFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    AZPRTRohKaloAlphaFrame:EnableMouse(true)
    AZPRTRohKaloAlphaFrame:SetMovable(true)
    AZPRTRohKaloAlphaFrame:RegisterForDrag("LeftButton")
    AZPRTRohKaloAlphaFrame:SetScript("OnDragStart", AZPRTRohKaloAlphaFrame.StartMoving)
    AZPRTRohKaloAlphaFrame:SetScript("OnDragStop", function() AZPRTRohKaloAlphaFrame:StopMovingOrSizing() end)

    AZPRTRohKaloAlphaFrame.Header = AZPRTRohKaloAlphaFrame:CreateFontString("AZPRTRohKaloAlphaFrame", "ARTWORK", "GameFontNormalHuge")
    AZPRTRohKaloAlphaFrame.Header:SetSize(AZPRTRohKaloAlphaFrame:GetWidth(), 25)
    AZPRTRohKaloAlphaFrame.Header:SetPoint("TOP", 0, -5)
    AZPRTRohKaloAlphaFrame.Header:SetText("Alpha XXX")

    AZPRTRohKaloAlphaFrame.HelpButton = CreateFrame("BUTTON", nil, AZPRTRohKaloAlphaFrame, "UIPanelButtonTemplate")
    AZPRTRohKaloAlphaFrame.HelpButton:SetSize(75, 20)
    AZPRTRohKaloAlphaFrame.HelpButton:SetPoint("TOP", 40, -30)
    AZPRTRohKaloAlphaFrame.HelpButton:SetText("I Need Help!")
    AZPRTRohKaloAlphaFrame.HelpButton:SetScript("OnClick", function() AZP.BossTools.RohKalo:RequestHelp() end)

    AZPRTRohKaloAlphaFrame.SafeButton = CreateFrame("BUTTON", nil, AZPRTRohKaloAlphaFrame, "UIPanelButtonTemplate")
    AZPRTRohKaloAlphaFrame.SafeButton:SetSize(75, 20)
    AZPRTRohKaloAlphaFrame.SafeButton:SetPoint("TOP", -40, -30)
    AZPRTRohKaloAlphaFrame.SafeButton:SetText("I Can Solo!")
    AZPRTRohKaloAlphaFrame.SafeButton:SetScript("OnClick", function() AZP.BossTools.RohKalo:OrganizePlayers() end)

    AZPRTRohKaloAlphaFrame.LeftLabels = {}
    AZPRTRohKaloAlphaFrame.RightLabels = {}

    for i = 1, 6 do
        AZPRTRohKaloAlphaFrame.LeftLabels[i] = AZPRTRohKaloAlphaFrame:CreateFontString("AZPRTRohKaloAlphaFrame", "ARTWORK", "GameFontNormal")
        AZPRTRohKaloAlphaFrame.LeftLabels[i]:SetSize(100, 25)
        AZPRTRohKaloAlphaFrame.LeftLabels[i]:SetPoint("TOP", -55, ((i - 1) * -15) -50)
        AZPRTRohKaloAlphaFrame.LeftLabels[i]:SetJustifyH("RIGHT")

        AZPRTRohKaloAlphaFrame.RightLabels[i] = AZPRTRohKaloAlphaFrame:CreateFontString("AZPRTRohKaloAlphaFrame", "ARTWORK", "GameFontNormal")
        AZPRTRohKaloAlphaFrame.RightLabels[i]:SetSize(100, 25)
        AZPRTRohKaloAlphaFrame.RightLabels[i]:SetPoint("TOP", 55, ((i - 1) * -15) -50)
        AZPRTRohKaloAlphaFrame.RightLabels[i]:SetJustifyH("LEFT")
    end

    AZPRTRohKaloAlphaFrame.closeButton = CreateFrame("Button", nil, AZPRTRohKaloAlphaFrame, "UIPanelCloseButton")
    AZPRTRohKaloAlphaFrame.closeButton:SetSize(20, 21)
    AZPRTRohKaloAlphaFrame.closeButton:SetPoint("TOPRIGHT", AZPRTRohKaloAlphaFrame, "TOPRIGHT", 2, 2)
    AZPRTRohKaloAlphaFrame.closeButton:SetScript("OnClick", function() AZP.BossTools.RohKalo:ShowHideFrame() end )
end

function AZP.BossTools.RohKalo:CreatePopUpFrame()
    PopUpFrame = CreateFrame("FRAME", nil, UIParent)
    PopUpFrame:SetPoint("CENTER", 0, 250)
    PopUpFrame:SetSize(200, 50)

    PopUpFrame.text = PopUpFrame:CreateFontString("PopUpFrame", "ARTWORK", "GameFontNormalHuge")
    PopUpFrame.text:SetPoint("CENTER", 0, 0)
    PopUpFrame.text:SetScale(0.5)
    PopUpFrame.text:Hide()
end

function AZP.BossTools.RohKalo.Events:CombatLogEventUnfiltered(...)
    local v1, combatEvent, v3, UnitGUID, casterName, v6, v7, destGUID, destName, v10, v11, spellID, v13, v14, v15 = CombatLogGetCurrentEventInfo()
    -- v12 == SpellID, but not always, sometimes several IDs for one spell (when multiple things happen on one spell)
    if combatEvent == "SPELL_CAST_SUCCESS" then
        if spellID == 5221 then
            AZP.BossTools.RohKalo:OrganizePlayers()
        end
    end
end

function AZP.BossTools.RohKalo.Events:VariablesLoaded(...)
    AZP.BossTools.RohKalo:LoadSavedVars()
    AZP.BossTools.RohKalo:ShareVersion()
end

function AZP.BossTools.RohKalo.Events:ChatMsgAddon(...)
    local prefix, payload, _, sender = ...
    if prefix == "AZPRKHINFO" then
        AZP.BossTools.RohKalo:ReceiveAssignees(payload)
        AZP.BossTools.RohKalo:CacheRaidNames()
    elseif prefix == "AZPRKHHelp" then
        AZP.BossTools.RohKalo:HelpRequested(payload)
        AZP.BossTools.RohKalo:CacheRaidNames()
    end
end

function AZP.BossTools.RohKalo.Events:ChatMsgAddonVersion(...)
    local prefix, payload, _, sender = ...
    if prefix == "AZPVERSIONS" then
        -- local version = AZP.BossTools.RohKalo:GetSpecificAddonVersion(payload, "BT")
        -- if version ~= nil then
        --     AZP.BossTools.RohKalo:ReceiveVersion(version)
        -- end
    end
end

function AZP.BossTools.RohKalo.Events:PlayerEnterCombat()
    cooldownTicker = C_Timer.NewTicker(1, function() AZP.BossTools.RohKalo:TickCoolDowns() end, 1000)
end

function AZP.BossTools.RohKalo.Events:PlayerLeaveCombat()
    cooldownTicker:Cancel()
    -- AZP.BossTools.RohKalo:SaveInterrupts()
end


function AZP.BossTools.RohKalo:LoadSavedVars()
    if AZPBossToolsRohKaloLocation == nil then
        AZPBossToolsRohKaloLocation = {"CENTER", nil, nil, 0, 0}
    end

    if AZPBTRohKalo ~= nil then
        AZP.BossTools.RohKalo:CacheRaidNames()
        AssignedPlayers = AZPBTRohKalo
        for i = 1, 6 do
            if AssignedPlayers[string.format("Ring%d", i)] == nil then
                AssignedPlayers[string.format("Ring%d", i)] = {}
            end
        end
        AZP.BossTools.RohKalo:UpdateRohKaloFrame()
    end
    AZPRTRohKaloAlphaFrame:SetPoint(AZPBossToolsRohKaloLocation[1], AZPBossToolsRohKaloLocation[4], AZPBossToolsRohKaloLocation[5])

    if AZPAZPShownLocked[1] then
        AZPBossToolsRohKaloOptionPanel.LockMoveButton:SetText("Move RohKalo!")
        AZPRTRohKaloAlphaFrame:EnableMouse(false)
        AZPRTRohKaloAlphaFrame:SetMovable(false)
    else
        AZPBossToolsRohKaloOptionPanel.LockMoveButton:SetText("Lock RohKalo!")
        AZPRTRohKaloAlphaFrame:EnableMouse(true)
        AZPRTRohKaloAlphaFrame:SetMovable(true)
    end

    if AZPAZPShownLocked[2] then
        AZPRTRohKaloAlphaFrame:Hide()
        AZPBossToolsRohKaloOptionPanel.ShowHideButton:SetText("Show RohKalo!")
    else
        AZPRTRohKaloAlphaFrame:Show()
        AZPBossToolsRohKaloOptionPanel.ShowHideButton:SetText("Hide RohKalo!")
    end
end

function AZP.BossTools.RohKalo:ShowHideFrame()
    if AZPRTRohKaloAlphaFrame:IsShown() then
        AZPRTRohKaloAlphaFrame:Hide()
        AZPBossToolsRohKaloOptionPanel.ShowHideButton:SetText("Show RohKalo!")
        AZPAZPShownLocked[2] = true
    else
        AZPRTRohKaloAlphaFrame:Show()
        AZPBossToolsRohKaloOptionPanel.ShowHideButton:SetText("Hide RohKalo!")
        AZPAZPShownLocked[2] = false
    end
end

function AZP.BossTools.RohKalo:RequestHelp()
    local ownGUID = UnitGUID("player")
    for _, players in pairs(AssignedPlayers) do
        if players.Alpha == ownGUID then
            C_ChatInfo.SendAddonMessage("AZPRKHHelp", players.Beta ,"RAID", 1)
        end
    end
end

function AZP.BossTools.RohKalo:HelpRequested(requestedGUID)
    local ownGUID = UnitGUID("player")
    if requestedGUID == ownGUID then
        local ringRequested = nil
        for ring, players in pairs(AssignedPlayers) do
            if players.Beta == ownGUID then
                ringRequested = ring
            end
        end
        AZP.BossTools.RohKalo:WarnPlayer(string.format("|cFFFF0000Help on %s!|r", ringRequested))
    end
end

function AZP.BossTools.RohKalo:WarnPlayer(text)
    local curScale = 0.5
    PopUpFrame.text:SetScale(curScale)
    PopUpFrame.text:Show()
    PopUpFrame.text:SetText(text)
    PlaySound(soundID, soundChannel)
    C_Timer.NewTimer(2.5, function() PopUpFrame.text:Hide() end)
    C_Timer.NewTicker(0.005,
    function()
        curScale = curScale + 0.15
        PopUpFrame.text:SetScale(curScale)
    end,
    35)
end

function AZP.BossTools.RohKalo:SaveLocation()
    local temp = {}
    temp[1], temp[2], temp[3], temp[4], temp[5] = AZPRTRohKaloAlphaFrame:GetPoint()
    AZPBossToolsRohKaloLocation = temp
end

function AZP.BossTools.RohKalo:GetClassColor(classIndex)
        if classIndex ==  0 then return 0.00, 0.00, 0.00      -- None
    elseif classIndex ==  1 then return 0.78, 0.61, 0.43      -- Warrior
    elseif classIndex ==  2 then return 0.96, 0.55, 0.73      -- Paladin
    elseif classIndex ==  3 then return 0.67, 0.83, 0.45      -- Hunter
    elseif classIndex ==  4 then return 1.00, 0.96, 0.41      -- Rogue
    elseif classIndex ==  5 then return 1.00, 1.00, 1.00      -- Priest
    elseif classIndex ==  6 then return 0.77, 0.12, 0.23      -- Death Knight
    elseif classIndex ==  7 then return 0.00, 0.44, 0.87      -- Shaman
    elseif classIndex ==  8 then return 0.25, 0.78, 0.92      -- Mage
    elseif classIndex ==  9 then return 0.53, 0.53, 0.93      -- Warlock
    elseif classIndex == 10 then return 0.00, 1.00, 0.60      -- Monk
    elseif classIndex == 11 then return 1.00, 0.49, 0.04      -- Druid
    elseif classIndex == 12 then return 0.64, 0.19, 0.79      -- Demon Hunter
    end
end

function AZP.BossTools.RohKalo:CheckIfDead(playerGUID)
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

function AZP.BossTools.RohKalo:CacheRaidNames()
    if IsInRaid() == true then
        for k = 1, 40 do
            local curName = GetRaidRosterInfo(k)
            if curName ~= nil then
                if string.find(curName, "-") then
                    curName = string.match(curName, "(.+)-")
                end
                local curGUID = UnitGUID("raid" .. k)
                AZPBossToolsRohKaloGUIDs[curGUID] = curName
            end
        end
    end
end

function AZP.BossTools.RohKalo:OnEditFocusLost(role, ring)
    local editBoxFrame = nil
    local ringName = string.format("Ring%d", ring)
    if role == "Alpha" then
        editBoxFrame = AZPBossToolsRohKaloAlphaEditBoxes[ring]
    else
        editBoxFrame = AZPBossToolsRohKaloBetaEditBoxes[ring]
    end
    if (editBoxFrame.editbox:GetText() ~= nil and editBoxFrame.editbox:GetText() ~= "") then
        for k = 1, 40 do
            local curName = GetRaidRosterInfo(k)
            if curName ~= nil then
                if string.find(curName, "-") then
                    curName = string.match(curName, "(.+)-")
                end
                if curName == editBoxFrame.editbox:GetText() then
                    local curGUID = UnitGUID("raid" .. k)
                    AZPBossToolsRohKaloGUIDs[curGUID] = curName
                    AssignedPlayers[ringName][role] = curGUID
                    AZP.BossTools.RohKalo:UpdateRohKaloFrame()
                end
            end
        end
    else
        if AssignedPlayers[ringName] ~= nil then
            AssignedPlayers[ringName][role] = nil
        end
    end

    AZPBTRohKalo = AssignedPlayers
end

function AZP.BossTools.RohKalo:ShareAssignees()
    for ring, players in pairs(AssignedPlayers) do
        if players ~= nil then
            local message = string.format("%s:%s:%s", ring, players.Alpha or "", players.Beta or "" )
            C_ChatInfo.SendAddonMessage("AZPRKHINFO", message ,"RAID", 1)
        end
    end
end

function AZP.BossTools.RohKalo:UpdateRohKaloFrame()
    if IsInRaid() == false then
        print("BossTools RohKalo only works in raid.")
        return
    end
    local playerGUID = UnitGUID("player")
    local headerText = "Not Assigned"


    
    for i = 1, 6 do
        local ring = AssignedPlayers[string.format( "Ring%d", i)]
        local alpha = ring.Alpha
        local beta = ring.Beta

        if alpha ~= nil then
            local name = AZPBossToolsRohKaloGUIDs[alpha]
            if name == nil then name = "" end
            AZPRTRohKaloAlphaFrame.LeftLabels[i]:SetText(name)
            AZPBossToolsRohKaloAlphaEditBoxes[i].editbox:SetText(name)
        else
            AZPBossToolsRohKaloAlphaEditBoxes[i].editbox:SetText("")
            AZPRTRohKaloAlphaFrame.LeftLabels[i]:SetText("")
        end
        if beta ~= nil then
            local name = AZPBossToolsRohKaloGUIDs[beta]
            if name == nil then name = "" end
            AZPRTRohKaloAlphaFrame.RightLabels[i]:SetText(name)
            AZPBossToolsRohKaloBetaEditBoxes[i].editbox:SetText(name)
        else
            AZPBossToolsRohKaloBetaEditBoxes[i].editbox:SetText("")
            AZPRTRohKaloAlphaFrame.RightLabels[i]:SetText("")
        end

        if alpha == playerGUID then
            headerText = string.format( "Alpha %d", i )
        end

        if beta == playerGUID then 
            headerText = string.format( "Beta %d", i )
        end
    end

    AZPRTRohKaloAlphaFrame.Header:SetText(headerText)
end

function AZP.BossTools.RohKalo:ReceiveAssignees(receiveAssignees)
    local ring, alpha, beta = string.match(receiveAssignees, "([^:]*):([^:]*):([^:]*)")
    if alpha == "" then alpha = nil end
    if beta == "" then beta = nil end
    AssignedPlayers[ring] = {Alpha = alpha, Beta = beta}
    AZP.BossTools.RohKalo:UpdateRohKaloFrame()
end

function AZP.BossTools.RohKalo:ShareVersion()
    -- local versionString = string.format("|BT:%d|", AZP.VersionControl["BossTools RohKalo"])
    -- if UnitInBattleground("player") ~= nil then
    --     -- BG stuff?
    -- else
    --     if IsInGroup() then
    --         if IsInRaid() then
    --             C_ChatInfo.SendAddonMessage("AZPVERSIONS", versionString ,"RAID", 1)
    --         else
    --             C_ChatInfo.SendAddonMessage("AZPVERSIONS", versionString ,"PARTY", 1)
    --         end
    --     end
    --     if IsInGuild() then
    --         C_ChatInfo.SendAddonMessage("AZPVERSIONS", versionString ,"GUILD", 1)
    --     end
    -- end
end

function AZP.BossTools.RohKalo:ReceiveVersion(version)
    if version > AZP.VersionControl["BossTools RohKalo"] then
        if (not HaveShowedUpdateNotification) then
            HaveShowedUpdateNotification = true
            UpdateFrame:Show()
            UpdateFrame.text:SetText(
                "Please download the new version through the CurseForge app.\n" ..
                "Or use the CurseForge website to download it manually!\n\n" .. 
                "Newer Version: v" .. version .. "\n" .. 
                "Your version: v" .. AZP.VersionControl["BossTools RohKalo"]
            )
        end
    end
end

function AZP.BossTools.RohKalo:GetSpecificAddonVersion(versionString, addonWanted)
    local pattern = "|([A-Z]+):([0-9]+)|"
    local index = 1
    while index < #versionString do
        local _, endPos = string.find(versionString, pattern, index)
        local addon, version = string.match(versionString, pattern, index)
        index = endPos + 1
        if addon == addonWanted then
            return tonumber(version)
        end
    end
end

function AZP.BossTools.RohKalo:OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        AZP.BossTools.RohKalo.Events:CombatLogEventUnfiltered(...)
    elseif event == "VARIABLES_LOADED" then
        AZP.BossTools.RohKalo.Events:VariablesLoaded(...)
    elseif event == "CHAT_MSG_ADDON" then
        AZP.BossTools.RohKalo.Events:ChatMsgAddonVersion(...)
        AZP.BossTools.RohKalo.Events:ChatMsgAddon(...)
    elseif event == "GROUP_ROSTER_UPDATE" then
        AZP.BossTools.RohKalo:ShareVersion()
    end
end

AZP.BossTools.RohKalo:OnLoadSelf()


AZP.SlashCommands["RKH"] = function()
    if AZPRTRohKaloAlphaFrame ~= nil then AZPRTRohKaloAlphaFrame:Show() end
end

AZP.SlashCommands["rkh"] = AZP.SlashCommands["RKH"]
