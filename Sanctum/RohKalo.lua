if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Sanctum.RohKalo == nil then AZP.BossTools.Sanctum.RohKalo = {} end
if AZP.BossTools.Sanctum.RohKalo.Events == nil then AZP.BossTools.Sanctum.RohKalo.Events = {} end

local AssignedPlayers = {}
local AZPBossToolsRohKaloOptionPanel = nil
local AZPBossToolsRohKaloGUIDs, AZPBossToolsRohKaloAlphaEditBoxes, AZPBossToolsRohKaloBetaEditBoxes = {}, {}, {}

if AZPBossToolsRohKaloSettingsList == nil then AZPBossToolsRohKaloSettingsList = {} end

if AZPAZPShownLocked == nil then AZPAZPShownLocked = {false, false} end

local UpdateFrame, EventFrame = nil, nil
local HaveShowedUpdateNotification = false

local curScale = 0.75

local newBuffScanRequest = false

local cooldownTicker = nil

if RKAnnounceCoE == nil then RKAnnounceCoE = false end
local BuffSide = "Diamond"

local optionHeader = "|cFF00FFFFBossTools RohKalo|r"

function AZP.BossTools.Sanctum.RohKalo:CheckIDs()
    if AZPBTRKIDs == nil then AZPBTRKIDs = {SpellID = 351969, BuffID = 354964} end
    -- Testing Purposes: SpellID = 5221, BuffID = 768 (CatForm and Shred)
end

function AZP.BossTools.Sanctum.RohKalo:OnLoadBoth()
    for i = 1, 6 do
        AssignedPlayers[string.format( "Ring%d",i )] = {}
    end
    AZP.BossTools.Sanctum.RohKalo:CreateMainFrame()
end

-- function AZP.BossTools.Sanctum.RohKalo:OnLoadCore()
--     AZP.BossTools.Sanctum.RohKalo:OnLoadBoth()
--     AZP.Core:RegisterEvents("COMBAT_LOG_EVENT_UNFILTERED", function(...) AZP.BossTools.Sanctum.RohKalo.Events:CombatLogEventUnfiltered(...) end)
--     AZP.Core:RegisterEvents("VARIABLES_LOADED", function(...) AZP.BossTools.Sanctum.RohKalo.Events:VariablesLoaded(...) end)
--     AZP.Core:RegisterEvents("CHAT_MSG_ADDON", function(...) AZP.BossTools.Sanctum.RohKalo.Events:ChatMsgAddonInterrupts(...) end)

--     AZP.OptionsPanels:RemovePanel("BossTools RohKalo")
--     AZP.OptionsPanels:Generic("BossTools RohKalo", optionHeader, function(frame)
--         AZPBossTools.RohKaloOptionPanel = frame
--         AZP.BossTools.Sanctum.RohKalo:FillOptionsPanel(frame)
--     end)
-- end

function AZP.BossTools.Sanctum.RohKalo:GetPlayersWithHeroicBuff()
    local players = {}
    for i = 1, 40 do
        local unit = string.format("raid%d", i)
        local currentBuffIndex = 1
        local buffName, icon, _, _, _, expirationTimer, _, _, _, buffID = UnitDebuff(unit, currentBuffIndex)
        while buffName ~= nil do
            currentBuffIndex = currentBuffIndex + 1
            if buffID == AZPBTRKIDs.BuffID then
                table.insert(players, {GUID = UnitGUID(unit), Unit = unit})
            end
            buffName, icon, _, _, _, expirationTimer, _, _, _, buffID = UnitDebuff(unit, currentBuffIndex)
        end
    end
    return players
end

function AZP.BossTools.Sanctum.RohKalo:ConcatTable(dest, ...)
    for i = 1, select("#", ...) do
        local t = select(i, ...)
        for _,v in ipairs(t) do
            table.insert(dest, v)
        end
    end
end

function AZP.BossTools.Sanctum.RohKalo:OrganizePlayers()
    local tanks, healers, dps = {}, {}, {}
    local alphas, betas = {}, {}
    local players = AZP.BossTools.Sanctum.RohKalo:GetPlayersWithHeroicBuff()
    local OwnGUID = UnitGUID("player")
    table.sort(players, function(a,b) return a.GUID > b.GUID end)
    for _, player in ipairs(players) do
        if player.GUID == OwnGUID then
            AZP.BossTools:WarnPlayer("|cFF00FFFFBUFF ACTIVE, PAY ATTENTION!|r")
        end
        local role = UnitGroupRolesAssigned(player.Unit)
        if role == "TANK" then
            table.insert(tanks, player.GUID)
        elseif role == "HEALER" then
            table.insert(healers, player.GUID)
        else
            table.insert(dps, player.GUID)
        end
    end

    local bigList = {}
    AZP.BossTools.Sanctum.RohKalo:ConcatTable(bigList, dps, tanks, healers)
    newBuffScanRequest = false

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
        AZP.BossTools.Sanctum.RohKalo:CacheRaidNames()
        AZP.BossTools.Sanctum.RohKalo:UpdateRohKaloFrame()
    end
end

function AZP.BossTools.Sanctum.RohKalo:OnLoadSelf()
    C_ChatInfo.RegisterAddonMessagePrefix("AZPVERSIONS")
    C_ChatInfo.RegisterAddonMessagePrefix("AZPRKHHelp")
    C_ChatInfo.RegisterAddonMessagePrefix("AZPRKHINFO")
    C_ChatInfo.RegisterAddonMessagePrefix("AZPRKHIDChange")

    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("VARIABLES_LOADED")
    EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:RegisterEvent("ENCOUNTER_END")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Sanctum.RohKalo:OnEvent(...) end)

    AZPBossToolsRohKaloOptionPanel = CreateFrame("FRAME", nil)
    AZPBossToolsRohKaloOptionPanel.name = "|cFF00FFFFRoh-Kalo|r"
    AZPBossToolsRohKaloOptionPanel.parent = AZP.BossTools.ParentOptionFrame.name
    InterfaceOptions_AddCategory(AZPBossToolsRohKaloOptionPanel)

    AZPBossToolsRohKaloOptionPanel.header = AZPBossToolsRohKaloOptionPanel:CreateFontString("AZPBossToolsRohKaloOptionPanel", "ARTWORK", "GameFontNormalHuge")
    AZPBossToolsRohKaloOptionPanel.header:SetPoint("TOP", 0, -10)
    AZPBossToolsRohKaloOptionPanel.header:SetText("|cFF00FFFFAzerPUG's BossTools Options!|r")
    AZPBossToolsRohKaloOptionPanel.SubHeader = AZPBossToolsRohKaloOptionPanel:CreateFontString("AZPBossToolsRohKaloOptionPanel", "ARTWORK", "GameFontNormalLarge")
    AZPBossToolsRohKaloOptionPanel.SubHeader:SetPoint("TOP", 0, -35)
    AZPBossToolsRohKaloOptionPanel.SubHeader:SetText("|cFF00FFFFRoh-Kalo|r")

    AZPBossToolsRohKaloOptionPanel.footer = AZPBossToolsRohKaloOptionPanel:CreateFontString("AZPBossToolsRohKaloOptionPanel", "ARTWORK", "GameFontNormalLarge")
    AZPBossToolsRohKaloOptionPanel.footer:SetPoint("TOP", 0, -400)
    AZPBossToolsRohKaloOptionPanel.footer:SetText(
        "|cFF00FFFFAzerPUG Links:\n" ..
        "Website: www.azerpug.com\n" ..
        "Discord: www.azerpug.com/discord\n" ..
        "Twitch: www.twitch.tv/azerpug\n|r"
    )

    AZP.BossTools.Sanctum.RohKalo:FillOptionsPanel(AZPBossToolsRohKaloOptionPanel)
    AZP.BossTools.Sanctum.RohKalo:OnLoadBoth()

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

function AZP.BossTools.Sanctum.RohKalo:FillOptionsPanel(frameToFill)
    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -75, -50)
    frameToFill.LockMoveButton:SetText("Share List")
    frameToFill.LockMoveButton:SetScript("OnClick", function() AZP.BossTools.Sanctum.RohKalo:ShareAssignees() end )

    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -75, -100)
    frameToFill.LockMoveButton:SetText("Lock Frame")
    frameToFill.LockMoveButton:SetScript("OnClick", function ()
        if AZP.BossTools.BossFrames.RohKalo:IsMovable() then
            AZP.BossTools.BossFrames.RohKalo:EnableMouse(false)
            AZP.BossTools.BossFrames.RohKalo:SetMovable(false)
            frameToFill.LockMoveButton:SetText("UnLock Frame!")
        else
            AZP.BossTools.BossFrames.RohKalo:EnableMouse(true)
            AZP.BossTools.BossFrames.RohKalo:SetMovable(true)
            frameToFill.LockMoveButton:SetText("Lock Frame")
        end
    end)

    frameToFill.ShowHideButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.ShowHideButton:SetSize(100, 25)
    frameToFill.ShowHideButton:SetPoint("TOPRIGHT", -75, -150)
    frameToFill.ShowHideButton:SetText("Hide Frame!")
    frameToFill.ShowHideButton:SetScript("OnClick", function () AZP.BossTools.Sanctum.RohKalo:ShowHideFrame() end)

    frameToFill.CallOfEternityFrame = CreateFrame("Frame", nil, frameToFill)
    frameToFill.CallOfEternityFrame:SetSize(100, 50)
    frameToFill.CallOfEternityFrame:SetPoint("TOP", frameToFill.ShowHideButton, "BOTTOM", 0, -50)
    frameToFill.CallOfEternityFrame.Text = frameToFill.CallOfEternityFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    frameToFill.CallOfEternityFrame.Text:SetText("Announce Call of Eternity Locations.")
    frameToFill.CallOfEternityFrame.Text:SetSize(100, 50)
    frameToFill.CallOfEternityFrame.Text:SetPoint("Center", 0, 0)
    frameToFill.CallOfEternityFrame.CoECheckBox = CreateFrame("CheckButton", nil, frameToFill.CallOfEternityFrame, "ChatConfigCheckButtonTemplate")
    frameToFill.CallOfEternityFrame.CoECheckBox:SetSize(25, 25)
    frameToFill.CallOfEternityFrame.CoECheckBox:SetPoint("LEFT", 0, 0)
    frameToFill.CallOfEternityFrame.CoECheckBox:SetHitRectInsets(0, 0, 0, 0)
    frameToFill.CallOfEternityFrame.CoECheckBox:SetChecked(RKAnnounceCoE)
    frameToFill.CallOfEternityFrame.CoECheckBox:SetScript("OnClick",function()
        if frameToFill.CallOfEternityFrame.CoECheckBox:GetChecked() == true then
            RKAnnounceCoE = true
        else
            RKAnnounceCoE = false
        end
    end)

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
            AZP.BossTools.Sanctum.RohKalo:OnEditFocusLost("Alpha", i)
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
            AZP.BossTools.Sanctum.RohKalo:OnEditFocusLost("Beta", i)
        end)
    end

    frameToFill.backupHeader = frameToFill:CreateFontString("AssigneesFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.backupHeader:SetSize(100, 25)
    frameToFill.backupHeader:SetPoint("BOTTOM", AZPBossToolsRohKaloBetaEditBoxes[1], "TOP", 0, 0)
    frameToFill.backupHeader:SetText("Beta")

    frameToFill:Hide()
end

function AZP.BossTools.Sanctum.RohKalo:CreateMainFrame()
    AZP.BossTools.BossFrames.RohKalo = CreateFrame("FRAME", nil, UIPanel, "BackdropTemplate")
    AZP.BossTools.BossFrames.RohKalo:SetSize(175, 150)
    AZP.BossTools.BossFrames.RohKalo:SetPoint("TOPLEFT", 100, -200)
    AZP.BossTools.BossFrames.RohKalo:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    AZP.BossTools.BossFrames.RohKalo:EnableMouse(true)
    AZP.BossTools.BossFrames.RohKalo:SetMovable(true)
    AZP.BossTools.BossFrames.RohKalo:RegisterForDrag("LeftButton")
    AZP.BossTools.BossFrames.RohKalo:SetScript("OnDragStart", AZP.BossTools.BossFrames.RohKalo.StartMoving)
    AZP.BossTools.BossFrames.RohKalo:SetScript("OnDragStop", function() AZP.BossTools.BossFrames.RohKalo:StopMovingOrSizing() end)

    AZP.BossTools.BossFrames.RohKalo.Header = AZP.BossTools.BossFrames.RohKalo:CreateFontString("AZP.BossTools.BossFrames.RohKalo", "ARTWORK", "GameFontNormalHuge")
    AZP.BossTools.BossFrames.RohKalo.Header:SetSize(AZP.BossTools.BossFrames.RohKalo:GetWidth(), 25)
    AZP.BossTools.BossFrames.RohKalo.Header:SetPoint("TOP", 0, -5)
    AZP.BossTools.BossFrames.RohKalo.Header:SetText("Alpha XXX")

    AZP.BossTools.BossFrames.RohKalo.HelpButton = CreateFrame("BUTTON", nil, AZP.BossTools.BossFrames.RohKalo, "UIPanelButtonTemplate")
    AZP.BossTools.BossFrames.RohKalo.HelpButton:SetSize(75, 20)
    AZP.BossTools.BossFrames.RohKalo.HelpButton:SetPoint("TOP", 40, -30)
    AZP.BossTools.BossFrames.RohKalo.HelpButton:SetText("I Need Help!")
    AZP.BossTools.BossFrames.RohKalo.HelpButton:SetScript("OnClick", function() AZP.BossTools.Sanctum.RohKalo:RequestHelp() end)

    AZP.BossTools.BossFrames.RohKalo.SafeButton = CreateFrame("BUTTON", nil, AZP.BossTools.BossFrames.RohKalo, "UIPanelButtonTemplate")
    AZP.BossTools.BossFrames.RohKalo.SafeButton:SetSize(75, 20)
    AZP.BossTools.BossFrames.RohKalo.SafeButton:SetPoint("TOP", -40, -30)
    AZP.BossTools.BossFrames.RohKalo.SafeButton:SetText("I Can Solo!")
    AZP.BossTools.BossFrames.RohKalo.SafeButton:SetScript("OnClick", function() AZP.BossTools.Sanctum.RohKalo:OrganizePlayers() end)

    AZP.BossTools.BossFrames.RohKalo.LeftLabels = {}
    AZP.BossTools.BossFrames.RohKalo.RightLabels = {}

    for i = 1, 6 do
        AZP.BossTools.BossFrames.RohKalo.LeftLabels[i] = AZP.BossTools.BossFrames.RohKalo:CreateFontString("AZP.BossTools.BossFrames.RohKalo", "ARTWORK", "GameFontNormal")
        AZP.BossTools.BossFrames.RohKalo.LeftLabels[i]:SetSize(100, 25)
        AZP.BossTools.BossFrames.RohKalo.LeftLabels[i]:SetPoint("TOP", -55, ((i - 1) * -15) -50)
        AZP.BossTools.BossFrames.RohKalo.LeftLabels[i]:SetJustifyH("RIGHT")

        AZP.BossTools.BossFrames.RohKalo.RightLabels[i] = AZP.BossTools.BossFrames.RohKalo:CreateFontString("AZP.BossTools.BossFrames.RohKalo", "ARTWORK", "GameFontNormal")
        AZP.BossTools.BossFrames.RohKalo.RightLabels[i]:SetSize(100, 25)
        AZP.BossTools.BossFrames.RohKalo.RightLabels[i]:SetPoint("TOP", 55, ((i - 1) * -15) -50)
        AZP.BossTools.BossFrames.RohKalo.RightLabels[i]:SetJustifyH("LEFT")
    end

    AZP.BossTools.BossFrames.RohKalo.closeButton = CreateFrame("Button", nil, AZP.BossTools.BossFrames.RohKalo, "UIPanelCloseButton")
    AZP.BossTools.BossFrames.RohKalo.closeButton:SetSize(20, 21)
    AZP.BossTools.BossFrames.RohKalo.closeButton:SetPoint("TOPRIGHT", AZP.BossTools.BossFrames.RohKalo, "TOPRIGHT", 2, 2)
    AZP.BossTools.BossFrames.RohKalo.closeButton:SetScript("OnClick", function() AZP.BossTools.Sanctum.RohKalo:ShowHideFrame() end)
end

function AZP.BossTools.Sanctum.RohKalo.Events:CombatLogEventUnfiltered(...)
    local v1, combatEvent, v3, UnitGUID, casterName, v6, v7, destGUID, destName, v10, v11, spellID, v13, v14, v15 = CombatLogGetCurrentEventInfo()
    if combatEvent == "SPELL_AURA_APPLIED" then
        if spellID == AZPBTRKIDs.BuffID then
            if newBuffScanRequest == false then
                newBuffScanRequest = true
                C_Timer.After(1, function() AZP.BossTools.Sanctum.RohKalo:OrganizePlayers() end)
            end
        elseif spellID == 350554 then
            if RKAnnounceCoE == true then
                C_Timer.After(1, function() AZP.BossTools.Sanctum.RohKalo:CallOfEternity() end)
            end
        end
    end
end

function AZP.BossTools.Sanctum.RohKalo:CallOfEternity()
    local SideIcon = nil
    if BuffSide == "Circle" then SideIcon = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3.png:0\124t" BuffSide = "Diamond" end
    if BuffSide == "Diamond" then SideIcon = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2.png:0\124t" BuffSide = "Circle" end
    for i = 1, 40 do
        local buffName, _, _, _, _, _, _, _, _, buffID = UnitDebuff("Player", i)
        if buffName ~= nil then
            if tonumber(buffID) == 350568 then
                AZP.BossTools:WarnPlayer(string.format("|cFFFF0000Drop bomb on %s%s%s!|r", SideIcon, BuffSide, SideIcon))
            end
        end
    end
end

function AZP.BossTools.Sanctum.RohKalo.Events:VariablesLoaded(...)
    AZP.BossTools.Sanctum.RohKalo:LoadSavedVars()
    AZP.BossTools.Sanctum.RohKalo:ShareVersion()
    AZP.BossTools.Sanctum.RohKalo:CheckIDs()
    AZPBossToolsRohKaloOptionPanel.CallOfEternityFrame.CoECheckBox:SetChecked(RKAnnounceCoE)
end

function AZP.BossTools.Sanctum.RohKalo.Events:ChatMsgAddon(...)
    local prefix, payload, _, sender = ...
    if prefix == "AZPRKHINFO" then
        AZP.BossTools.Sanctum.RohKalo:ReceiveAssignees(payload)
        AZP.BossTools.Sanctum.RohKalo:CacheRaidNames()
        AZP.BossTools:ShowReceiveFrame(sender, "Sanctum", "RohKalo")
        AZP.BossTools.ReceiveFrame:Show()
    elseif prefix == "AZPRKHHelp" then
        AZP.BossTools.Sanctum.RohKalo:HelpRequested(payload)
        AZP.BossTools.Sanctum.RohKalo:CacheRaidNames()
    elseif prefix == "AZPRKHIDChange" and sender == "Tex-Ravencrest" then
        local field, ID = string.match(payload, "([^=]+)=([0-9]*)")
        AZPBTRKIDs[field] = tonumber(ID)
    end
end

function AZP.BossTools.Sanctum.RohKalo.Events:ChatMsgAddonVersion(...)
    local prefix, payload, _, sender = ...
    if prefix == "AZPVERSIONS" then
        -- local version = AZP.BossTools.Sanctum.RohKalo:GetSpecificAddonVersion(payload, "BT")
        -- if version ~= nil then
        --     AZP.BossTools.Sanctum.RohKalo:ReceiveVersion(version)
        -- end
    end
end

function AZP.BossTools.Sanctum.RohKalo:LoadSavedVars()
    if AZPBossToolsRohKaloLocation == nil then
        AZPBossToolsRohKaloLocation = {"CENTER", nil, nil, 0, 0}
    end

    if AZPBTRohKalo ~= nil then
        AZP.BossTools.Sanctum.RohKalo:CacheRaidNames()
        AssignedPlayers = AZPBTRohKalo
        for i = 1, 6 do
            if AssignedPlayers[string.format("Ring%d", i)] == nil then
                AssignedPlayers[string.format("Ring%d", i)] = {}
            end
        end
        AZP.BossTools.Sanctum.RohKalo:UpdateRohKaloFrame()
    end
    AZP.BossTools.BossFrames.RohKalo:SetPoint(AZPBossToolsRohKaloLocation[1], AZPBossToolsRohKaloLocation[4], AZPBossToolsRohKaloLocation[5])

    if AZPAZPShownLocked[1] then
        AZPBossToolsRohKaloOptionPanel.LockMoveButton:SetText("Move RohKalo!")
        AZP.BossTools.BossFrames.RohKalo:EnableMouse(false)
        AZP.BossTools.BossFrames.RohKalo:SetMovable(false)
    else
        AZPBossToolsRohKaloOptionPanel.LockMoveButton:SetText("Lock RohKalo!")
        AZP.BossTools.BossFrames.RohKalo:EnableMouse(true)
        AZP.BossTools.BossFrames.RohKalo:SetMovable(true)
    end

    if AZPAZPShownLocked[2] == false or AZPAZPShownLocked[2] == nil then
        AZP.BossTools.BossFrames.RohKalo:Hide()
        AZPBossToolsRohKaloOptionPanel.ShowHideButton:SetText("Show RohKalo!")
    else
        AZP.BossTools.BossFrames.RohKalo:Show()
        AZPBossToolsRohKaloOptionPanel.ShowHideButton:SetText("Hide RohKalo!")
    end
end

function AZP.BossTools.Sanctum.RohKalo:ShowHideFrame()
    if AZP.BossTools.BossFrames.RohKalo:IsShown() then
        AZP.BossTools.BossFrames.RohKalo:Hide()
        AZPBossToolsRohKaloOptionPanel.ShowHideButton:SetText("Show RohKalo!")
        AZPAZPShownLocked[2] = true
    else
        AZP.BossTools.BossFrames.RohKalo:Show()
        AZPBossToolsRohKaloOptionPanel.ShowHideButton:SetText("Hide RohKalo!")
        AZPAZPShownLocked[2] = false
    end
end

function AZP.BossTools.Sanctum.RohKalo:RequestHelp()
    local ownGUID = UnitGUID("player")
    for _, players in pairs(AssignedPlayers) do
        if players.Alpha == ownGUID then
            C_ChatInfo.SendAddonMessage("AZPRKHHelp", players.Beta ,"RAID", 1)
        end
    end
end

function AZP.BossTools.Sanctum.RohKalo:HelpRequested(requestedGUID)
    local ownGUID = UnitGUID("player")
    if requestedGUID == ownGUID then
        local ringRequested = nil
        for ring, players in pairs(AssignedPlayers) do
            if players.Beta == ownGUID then
                ringRequested = ring
            end
        end
        AZP.BossTools:WarnPlayer(string.format("|cFFFF0000Help on %s!|r", ringRequested))
    end
end

function AZP.BossTools.Sanctum.RohKalo:SaveLocation()
    local temp = {}
    temp[1], temp[2], temp[3], temp[4], temp[5] = AZP.BossTools.BossFrames.RohKalo:GetPoint()
    AZPBossToolsRohKaloLocation = temp
end

function AZP.BossTools.Sanctum.RohKalo:CacheRaidNames()
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

function AZP.BossTools.Sanctum.RohKalo:OnEditFocusLost(role, ring)
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
                    AZP.BossTools.Sanctum.RohKalo:UpdateRohKaloFrame()
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

function AZP.BossTools.Sanctum.RohKalo:ShareAssignees()
    for ring, players in pairs(AssignedPlayers) do
        if players ~= nil then
            local message = string.format("%s:%s:%s", ring, players.Alpha or "", players.Beta or "" )
            C_ChatInfo.SendAddonMessage("AZPRKHINFO", message ,"RAID", 1)
        end
    end
end

function AZP.BossTools.Sanctum.RohKalo:UpdateRohKaloFrame()
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
            AZP.BossTools.BossFrames.RohKalo.LeftLabels[i]:SetText(name)
            AZPBossToolsRohKaloAlphaEditBoxes[i].editbox:SetText(name)
        else
            AZPBossToolsRohKaloAlphaEditBoxes[i].editbox:SetText("")
            AZP.BossTools.BossFrames.RohKalo.LeftLabels[i]:SetText("")
        end
        if beta ~= nil then
            local name = AZPBossToolsRohKaloGUIDs[beta]
            if name == nil then name = "" end
            AZP.BossTools.BossFrames.RohKalo.RightLabels[i]:SetText(name)
            AZPBossToolsRohKaloBetaEditBoxes[i].editbox:SetText(name)
        else
            AZPBossToolsRohKaloBetaEditBoxes[i].editbox:SetText("")
            AZP.BossTools.BossFrames.RohKalo.RightLabels[i]:SetText("")
        end

        if alpha == playerGUID then
            headerText = string.format( "Alpha %d", i )
        end

        if beta == playerGUID then 
            headerText = string.format( "Beta %d", i )
        end
    end

    AZP.BossTools.BossFrames.RohKalo.Header:SetText(headerText)
end

function AZP.BossTools.Sanctum.RohKalo:ReceiveAssignees(receiveAssignees)
    local ring, alpha, beta = string.match(receiveAssignees, "([^:]*):([^:]*):([^:]*)")
    if alpha == "" then alpha = nil end
    if beta == "" then beta = nil end
    AssignedPlayers[ring] = {Alpha = alpha, Beta = beta}
    AZP.BossTools.Sanctum.RohKalo:UpdateRohKaloFrame()
end

function AZP.BossTools.Sanctum.RohKalo:ShareVersion()
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

function AZP.BossTools.Sanctum.RohKalo:ReceiveVersion(version)
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

function AZP.BossTools.Sanctum.RohKalo:GetSpecificAddonVersion(versionString, addonWanted)
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

function AZP.BossTools.Sanctum.RohKalo.Events:EncounterEnd(_, _, _, _, success)
    if success == true then
        AZPBTRohKalo = nil
    end
end

function AZP.BossTools.Sanctum.RohKalo:OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        AZP.BossTools.Sanctum.RohKalo.Events:CombatLogEventUnfiltered(...)
    elseif event == "VARIABLES_LOADED" then
        AZP.BossTools.Sanctum.RohKalo.Events:VariablesLoaded(...)
    elseif event == "CHAT_MSG_ADDON" then
        AZP.BossTools.Sanctum.RohKalo.Events:ChatMsgAddonVersion(...)
        AZP.BossTools.Sanctum.RohKalo.Events:ChatMsgAddon(...)
    elseif event == "GROUP_ROSTER_UPDATE" then
        AZP.BossTools.Sanctum.RohKalo:ShareVersion()
    elseif event == "ENCOUNTER_END" then
        AZP.BossTools.Sanctum.RohKalo.Events:EncounterEnd(...)
    end
end

AZP.BossTools.Sanctum.RohKalo:OnLoadSelf()