if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Vault.Razageth == nil then AZP.BossTools.Vault.Razageth = {} end
if AZP.BossTools.Vault.Razageth.Events == nil then AZP.BossTools.Vault.Razageth.Events = {} end

local AZPBTRazIDs = {DebuffMin = 394579, DebuffPlus = 394576}

local AssignedPlayers = {}
local AZPBossToolsRazagethOptionPanel = nil
local AZPBossToolsRazagethGUIDs, AZPBossToolsRazagethAlphaEditBoxes, AZPBossToolsRazagethBetaEditBoxes = {}, {}, {}

if AZPBossToolsRazagethSettingsList == nil then AZPBossToolsRazagethSettingsList = {} end

if AZPAZPShownLocked == nil then AZPAZPShownLocked = {false, false} end

local UpdateFrame, EventFrame = nil, nil
local HaveShowedUpdateNotification = false

if RKAnnounceCoE == nil then RKAnnounceCoE = false end

local optionHeader = "|cFF00FFFFBossTools Razageth|r"

function AZP.BossTools.Vault.Razageth:GetPlayersWithHeroicBuff()
    local players = {}
    for i = 1, 40 do
        local unit = string.format("raid%d", i)
        local currentBuffIndex = 1
        local buffName, icon, _, _, _, _, _, _, _, buffID = UnitDebuff(unit, currentBuffIndex)
        while buffName ~= nil do
            currentBuffIndex = currentBuffIndex + 1
            if buffID == AZPBTRazIDs.BuffID then
                table.insert(players, {GUID = UnitGUID(unit), Unit = unit})
            end
            buffName, icon, _, _, _, _, _, _, _, buffID = UnitDebuff(unit, currentBuffIndex)
        end
    end
    return players
end

function AZP.BossTools.Vault.Razageth:ConcatTable(dest, ...)
    for i = 1, select("#", ...) do
        local t = select(i, ...)
        for _,v in ipairs(t) do
            table.insert(dest, v)
        end
    end
end

function AZP.BossTools.Vault.Razageth:OrganizePlayers()
    local tanks, healers, dps = {}, {}, {}
    local alphas, betas = {}, {}
    local players = AZP.BossTools.Vault.Razageth:GetPlayersWithHeroicBuff()
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
    AZP.BossTools.Vault.Razageth:ConcatTable(bigList, dps, tanks, healers)
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
        AZP.BossTools.Vault.Razageth:CacheRaidNames()
        AZP.BossTools.Vault.Razageth:UpdateRazagethFrame()
    end
end

function AZP.BossTools.Vault.Razageth:OnLoadSelf()
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
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Vault.Razageth:OnEvent(...) end)

    AZPBossToolsRazagethOptionPanel = CreateFrame("FRAME", nil)
    AZPBossToolsRazagethOptionPanel.name = "|cFF00FFFFRoh-Kalo|r"
    AZPBossToolsRazagethOptionPanel.parent = AZP.BossTools.ParentOptionFrame.name
    InterfaceOptions_AddCategory(AZPBossToolsRazagethOptionPanel)

    AZPBossToolsRazagethOptionPanel.header = AZPBossToolsRazagethOptionPanel:CreateFontString("AZPBossToolsRazagethOptionPanel", "ARTWORK", "GameFontNormalHuge")
    AZPBossToolsRazagethOptionPanel.header:SetPoint("TOP", 0, -10)
    AZPBossToolsRazagethOptionPanel.header:SetText("|cFF00FFFFAzerPUG's BossTools Options!|r")
    AZPBossToolsRazagethOptionPanel.SubHeader = AZPBossToolsRazagethOptionPanel:CreateFontString("AZPBossToolsRazagethOptionPanel", "ARTWORK", "GameFontNormalLarge")
    AZPBossToolsRazagethOptionPanel.SubHeader:SetPoint("TOP", 0, -35)
    AZPBossToolsRazagethOptionPanel.SubHeader:SetText("|cFF00FFFFRoh-Kalo|r")

    AZPBossToolsRazagethOptionPanel.footer = AZPBossToolsRazagethOptionPanel:CreateFontString("AZPBossToolsRazagethOptionPanel", "ARTWORK", "GameFontNormalLarge")
    AZPBossToolsRazagethOptionPanel.footer:SetPoint("TOP", 0, -400)
    AZPBossToolsRazagethOptionPanel.footer:SetText(
        "|cFF00FFFFAzerPUG Links:\n" ..
        "Website: www.azerpug.com\n" ..
        "Discord: www.azerpug.com/discord\n" ..
        "Twitch: www.twitch.tv/azerpug\n|r"
    )

    AZP.BossTools.Vault.Razageth:FillOptionsPanel(AZPBossToolsRazagethOptionPanel)

    for i = 1, 6 do
        AssignedPlayers[string.format("Ring%d", i)] = {}
    end
    AZP.BossTools.Vault.Razageth:CreateMainFrame()
end

function AZP.BossTools.Vault.Razageth:FillOptionsPanel(frameToFill)
    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -75, -50)
    frameToFill.LockMoveButton:SetText("Share List")
    frameToFill.LockMoveButton:SetScript("OnClick", function() AZP.BossTools.Vault.Razageth:ShareAssignees() end )

    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -75, -100)
    frameToFill.LockMoveButton:SetText("Lock Frame")
    frameToFill.LockMoveButton:SetScript("OnClick", function ()
        if AZP.BossTools.BossFrames.Razageth:IsMovable() then
            AZP.BossTools.BossFrames.Razageth:EnableMouse(false)
            AZP.BossTools.BossFrames.Razageth:SetMovable(false)
            frameToFill.LockMoveButton:SetText("UnLock Frame!")
        else
            AZP.BossTools.BossFrames.Razageth:EnableMouse(true)
            AZP.BossTools.BossFrames.Razageth:SetMovable(true)
            frameToFill.LockMoveButton:SetText("Lock Frame")
        end
    end)

    frameToFill.ShowHideButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.ShowHideButton:SetSize(100, 25)
    frameToFill.ShowHideButton:SetPoint("TOPRIGHT", -75, -150)
    frameToFill.ShowHideButton:SetText("Hide Frame!")
    frameToFill.ShowHideButton:SetScript("OnClick", function () AZP.BossTools.Vault.Razageth:ShowHideFrame() end)

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

        AZPBossToolsRazagethAlphaEditBoxes[i] = AssigneesFrame

        AssigneesFrame.editbox:SetScript("OnEditFocusLost",
        function()
            AZP.BossTools.Vault.Razageth:OnEditFocusLost("Alpha", i)
        end)
    end

    frameToFill.assigneeHeader = frameToFill:CreateFontString("AssigneesFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.assigneeHeader:SetSize(100, 25)
    frameToFill.assigneeHeader:SetPoint("BOTTOM", AZPBossToolsRazagethAlphaEditBoxes[1].editbox, "TOP", 0, 0)
    frameToFill.assigneeHeader:SetText("Alpha")

    for i = 1, 6 do
        local BackUpsFrame = CreateFrame("Frame", nil, frameToFill)
        BackUpsFrame:SetSize(100, 25)
        BackUpsFrame:SetPoint("LEFT", AZPBossToolsRazagethAlphaEditBoxes[i], "RIGHT", 5, 0)
        BackUpsFrame.editbox = CreateFrame("EditBox", nil, BackUpsFrame, "InputBoxTemplate")
        BackUpsFrame.editbox:SetSize(100, 25)
        BackUpsFrame.editbox:SetPoint("LEFT",0, 0)
        BackUpsFrame.editbox:SetAutoFocus(false)
        AZPBossToolsRazagethBetaEditBoxes[i] = BackUpsFrame

        BackUpsFrame.editbox:SetScript("OnEditFocusLost",
        function()
            AZP.BossTools.Vault.Razageth:OnEditFocusLost("Beta", i)
        end)
    end

    frameToFill.backupHeader = frameToFill:CreateFontString("AssigneesFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.backupHeader:SetSize(100, 25)
    frameToFill.backupHeader:SetPoint("BOTTOM", AZPBossToolsRazagethBetaEditBoxes[1], "TOP", 0, 0)
    frameToFill.backupHeader:SetText("Beta")

    frameToFill:Hide()
end

function AZP.BossTools.Vault.Razageth:CreateMainFrame()
    -- local TempFrame1 = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
    -- TempFrame1:SetSize(100, 100)
    -- TempFrame1:SetPoint("CENTER", -75, 0)
    -- TempFrame1:EnableMouse(true)
    -- TempFrame1:SetScript("OnMouseDown", function() AZP.BossTools.Vault.Razageth:CompareIDs(394579) end)

    -- local TempFrame2 = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
    -- TempFrame2:SetSize(100, 100)
    -- TempFrame2:SetPoint("CENTER", 75, 0)
    -- TempFrame2:EnableMouse(true)
    -- TempFrame2:SetScript("OnMouseDown", function() AZP.BossTools.Vault.Razageth:CompareIDs(394576) end)

    AZP.BossTools.BossFrames.Razageth = CreateFrame("FRAME", nil, UIParent)
    AZP.BossTools.BossFrames.Razageth:SetSize(150, 75)
    AZP.BossTools.BossFrames.Razageth:SetPoint("TOP", 0, -200)
    AZP.BossTools.BossFrames.Razageth:EnableMouse(true)
    AZP.BossTools.BossFrames.Razageth:SetMovable(true)
    AZP.BossTools.BossFrames.Razageth:RegisterForDrag("LeftButton")
    AZP.BossTools.BossFrames.Razageth:SetScript("OnDragStart", AZP.BossTools.BossFrames.Razageth.StartMoving)
    AZP.BossTools.BossFrames.Razageth:SetScript("OnDragStop", function() AZP.BossTools.BossFrames.Razageth:StopMovingOrSizing() end)

    AZP.BossTools.BossFrames.Razageth.Icon = AZP.BossTools.BossFrames.Razageth:CreateTexture(nil, "ARTWORK")
    AZP.BossTools.BossFrames.Razageth.Icon:SetSize(75, 75)
    AZP.BossTools.BossFrames.Razageth.Icon:SetPoint("LEFT", 0, 0)
    AZP.BossTools.BossFrames.Razageth.Icon:SetTexture(394579)

    AZP.BossTools.BossFrames.Razageth.Marker = AZP.BossTools.BossFrames.Razageth:CreateTexture(nil, "ARTWORK")
    AZP.BossTools.BossFrames.Razageth.Marker:SetSize(75, 75)
    AZP.BossTools.BossFrames.Razageth.Marker:SetPoint("LEFT", AZP.BossTools.BossFrames.Razageth.Icon, "RIGHT", 5, 0)
    AZP.BossTools.BossFrames.Razageth.Marker:SetTexture(394581)

    --AZP.BossTools.BossFrames.Razageth:Hide()
    AZP.BossTools.BossFrames.Razageth.Icon:Hide()
    AZP.BossTools.BossFrames.Razageth.Marker:Hide()
end

function AZP.BossTools.Vault.Razageth:CompareIDs(curID)
    if curID == AZPBTRazIDs.DebuffMin then
        AZP.BossTools.BossFrames.Razageth.Icon:Show()
        AZP.BossTools.BossFrames.Razageth.Marker:Show()
        AZP.BossTools.BossFrames.Razageth.Icon:SetTexture(135768)
        AZP.BossTools.BossFrames.Razageth.Marker:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_7")
        C_Timer.After(10, function() AZP.BossTools.BossFrames.Razageth.Icon:Hide() AZP.BossTools.BossFrames.Razageth.Marker:Hide() end)
    elseif curID == AZPBTRazIDs.DebuffPlus then
        AZP.BossTools.BossFrames.Razageth.Icon:Show()
        AZP.BossTools.BossFrames.Razageth.Marker:Show()
        AZP.BossTools.BossFrames.Razageth.Icon:SetTexture(135769)
        AZP.BossTools.BossFrames.Razageth.Marker:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_6")
        C_Timer.After(10, function() AZP.BossTools.BossFrames.Razageth.Icon:Hide() AZP.BossTools.BossFrames.Razageth.Marker:Hide() end)
    end
end

function AZP.BossTools.Vault.Razageth.Events:CombatLogEventUnfiltered(...)
    local _, combatEvent, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
    if combatEvent == "SPELL_AURA_APPLIED" then
        AZP.BossTools.Vault.Razageth:CompareIDs(spellID)
    end
end

function AZP.BossTools.Vault.Razageth.Events:VariablesLoaded(...)
    -- AZP.BossTools.Vault.Razageth:LoadSavedVars()
    -- AZP.BossTools.Vault.Razageth:ShareVersion()
    -- AZP.BossTools.Vault.Razageth:CheckIDs()
    -- AZPBossToolsRazagethOptionPanel.CallOfEternityFrame.CoECheckBox:SetChecked(RKAnnounceCoE)
end

-- function AZP.BossTools.Vault.Razageth.Events:ChatMsgAddon(...)
--     local prefix, payload, _, sender = ...
--     if prefix == "AZPRKHINFO" then
--         AZP.BossTools.Vault.Razageth:ReceiveAssignees(payload)
--         AZP.BossTools.Vault.Razageth:CacheRaidNames()
--         AZP.BossTools:ShowReceiveFrame(sender, "Vault", "Razageth")
--         AZP.BossTools.ReceiveFrame:Show()
--     elseif prefix == "AZPRKHHelp" then
--         AZP.BossTools.Vault.Razageth:HelpRequested(payload)
--         AZP.BossTools.Vault.Razageth:CacheRaidNames()
--     elseif prefix == "AZPRKHIDChange" and sender == "Tex-Ravencrest" then
--         local field, ID = string.match(payload, "([^=]+)=([0-9]*)")
--         AZPBTRazIDs[field] = tonumber(ID)
--     end
-- end

function AZP.BossTools.Vault.Razageth:LoadSavedVars()
    if AZPBossToolsRazagethLocation == nil then
        AZPBossToolsRazagethLocation = {"CENTER", nil, nil, 0, 0}
    end

    if AZPBTRazageth ~= nil then
        AZP.BossTools.Vault.Razageth:CacheRaidNames()
        AssignedPlayers = AZPBTRazageth
        for i = 1, 6 do
            if AssignedPlayers[string.format("Ring%d", i)] == nil then
                AssignedPlayers[string.format("Ring%d", i)] = {}
            end
        end
        AZP.BossTools.Vault.Razageth:UpdateRazagethFrame()
    end
    AZP.BossTools.BossFrames.Razageth:SetPoint(AZPBossToolsRazagethLocation[1], AZPBossToolsRazagethLocation[4], AZPBossToolsRazagethLocation[5])

    if AZPAZPShownLocked[1] then
        AZPBossToolsRazagethOptionPanel.LockMoveButton:SetText("Move Razageth!")
        AZP.BossTools.BossFrames.Razageth:EnableMouse(false)
        AZP.BossTools.BossFrames.Razageth:SetMovable(false)
    else
        AZPBossToolsRazagethOptionPanel.LockMoveButton:SetText("Lock Razageth!")
        AZP.BossTools.BossFrames.Razageth:EnableMouse(true)
        AZP.BossTools.BossFrames.Razageth:SetMovable(true)
    end

    if AZPAZPShownLocked[2] == false or AZPAZPShownLocked[2] == nil then
        AZP.BossTools.BossFrames.Razageth:Hide()
        AZPBossToolsRazagethOptionPanel.ShowHideButton:SetText("Show Razageth!")
    else
        AZP.BossTools.BossFrames.Razageth:Show()
        AZPBossToolsRazagethOptionPanel.ShowHideButton:SetText("Hide Razageth!")
    end
end

function AZP.BossTools.Vault.Razageth:ShowHideFrame()
    if AZP.BossTools.BossFrames.Razageth:IsShown() then
        AZP.BossTools.BossFrames.Razageth:Hide()
        AZPBossToolsRazagethOptionPanel.ShowHideButton:SetText("Show Razageth!")
        AZPAZPShownLocked[2] = true
    else
        AZP.BossTools.BossFrames.Razageth:Show()
        AZPBossToolsRazagethOptionPanel.ShowHideButton:SetText("Hide Razageth!")
        AZPAZPShownLocked[2] = false
    end
end

function AZP.BossTools.Vault.Razageth:SaveLocation()
    local temp = {}
    temp[1], temp[2], temp[3], temp[4], temp[5] = AZP.BossTools.BossFrames.Razageth:GetPoint()
    AZPBossToolsRazagethLocation = temp
end

-- function AZP.BossTools.Vault.Razageth:CacheRaidNames()
--     if IsInRaid() == true then
--         for k = 1, 40 do
--             local curName = GetRaidRosterInfo(k)
--             if curName ~= nil then
--                 if string.find(curName, "-") then
--                     curName = string.match(curName, "(.+)-")
--                 end
--                 local curGUID = UnitGUID("raid" .. k)
--                 AZPBossToolsRazagethGUIDs[curGUID] = curName
--             end
--         end
--     end
-- end

-- function AZP.BossTools.Vault.Razageth:OnEditFocusLost(role, ring)
--     local editBoxFrame = nil
--     local ringName = string.format("Ring%d", ring)
--     if role == "Alpha" then
--         editBoxFrame = AZPBossToolsRazagethAlphaEditBoxes[ring]
--     else
--         editBoxFrame = AZPBossToolsRazagethBetaEditBoxes[ring]
--     end
--     if (editBoxFrame.editbox:GetText() ~= nil and editBoxFrame.editbox:GetText() ~= "") then
--         for k = 1, 40 do
--             local curName = GetRaidRosterInfo(k)
--             if curName ~= nil then
--                 if string.find(curName, "-") then
--                     curName = string.match(curName, "(.+)-")
--                 end
--                 if curName == editBoxFrame.editbox:GetText() then
--                     local curGUID = UnitGUID("raid" .. k)
--                     AZPBossToolsRazagethGUIDs[curGUID] = curName
--                     AssignedPlayers[ringName][role] = curGUID
--                     AZP.BossTools.Vault.Razageth:UpdateRazagethFrame()
--                 end
--             end
--         end
--     else
--         if AssignedPlayers[ringName] ~= nil then
--             AssignedPlayers[ringName][role] = nil
--         end
--     end

--     AZPBTRazageth = AssignedPlayers
-- end

-- function AZP.BossTools.Vault.Razageth:ShareAssignees()
--     for ring, players in pairs(AssignedPlayers) do
--         if players ~= nil then
--             local message = string.format("%s:%s:%s", ring, players.Alpha or "", players.Beta or "" )
--             C_ChatInfo.SendAddonMessage("AZPRKHINFO", message ,"RAID", 1)
--         end
--     end
-- end

-- function AZP.BossTools.Vault.Razageth:UpdateRazagethFrame()
--     if IsInRaid() == false then
--         print("BossTools Razageth only works in raid.")
--         return
--     end
--     local playerGUID = UnitGUID("player")
--     local headerText = "Not Assigned"

--     for i = 1, 6 do
--         local ring = AssignedPlayers[string.format( "Ring%d", i)]
--         local alpha = ring.Alpha
--         local beta = ring.Beta

--         if alpha ~= nil then
--             local name = AZPBossToolsRazagethGUIDs[alpha]
--             if name == nil then name = "" end
--             AZP.BossTools.BossFrames.Razageth.LeftLabels[i]:SetText(name)
--             AZPBossToolsRazagethAlphaEditBoxes[i].editbox:SetText(name)
--         else
--             AZPBossToolsRazagethAlphaEditBoxes[i].editbox:SetText("")
--             AZP.BossTools.BossFrames.Razageth.LeftLabels[i]:SetText("")
--         end
--         if beta ~= nil then
--             local name = AZPBossToolsRazagethGUIDs[beta]
--             if name == nil then name = "" end
--             AZP.BossTools.BossFrames.Razageth.RightLabels[i]:SetText(name)
--             AZPBossToolsRazagethBetaEditBoxes[i].editbox:SetText(name)
--         else
--             AZPBossToolsRazagethBetaEditBoxes[i].editbox:SetText("")
--             AZP.BossTools.BossFrames.Razageth.RightLabels[i]:SetText("")
--         end

--         if alpha == playerGUID then
--             headerText = string.format( "Alpha %d", i )
--         end

--         if beta == playerGUID then 
--             headerText = string.format( "Beta %d", i )
--         end
--     end

--     AZP.BossTools.BossFrames.Razageth.Header:SetText(headerText)
-- end

-- function AZP.BossTools.Vault.Razageth:ReceiveAssignees(receiveAssignees)
--     local ring, alpha, beta = string.match(receiveAssignees, "([^:]*):([^:]*):([^:]*)")
--     if alpha == "" then alpha = nil end
--     if beta == "" then beta = nil end
--     AssignedPlayers[ring] = {Alpha = alpha, Beta = beta}
--     AZP.BossTools.Vault.Razageth:UpdateRazagethFrame()
-- end

function AZP.BossTools.Vault.Razageth.Events:EncounterEnd(_, _, _, _, success)
    if success == true then
        AZPBTRazageth = nil
    end
end

function AZP.BossTools.Vault.Razageth:OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        AZP.BossTools.Vault.Razageth.Events:CombatLogEventUnfiltered(...)
    elseif event == "VARIABLES_LOADED" then
        AZP.BossTools.Vault.Razageth.Events:VariablesLoaded(...)
    elseif event == "CHAT_MSG_ADDON" then
        -- AZP.BossTools.Vault.Razageth.Events:ChatMsgAddon(...)
    elseif event == "GROUP_ROSTER_UPDATE" then
        -- AZP.BossTools.Vault.Razageth:ShareVersion()
    elseif event == "ENCOUNTER_END" then
        AZP.BossTools.Vault.Razageth.Events:EncounterEnd(...)
    end
end

AZP.BossTools.Vault.Razageth:OnLoadSelf()