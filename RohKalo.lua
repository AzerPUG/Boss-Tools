if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

AZP.VersionControl["BossTools"] = 1
if AZP.BossTools == nil then AZP.BossTools = {} end
if AZP.BossTools.RohKalo == nil then AZP.BossTools.RohKalo = {} end
if AZP.BossTools.Events == nil then AZP.BossTools.Events = {} end

local AZPRTRohKaloAlphaFrame = nil
local AZPRTRohKaloOptionPanel = nil
local AZPRTRohKaloAsigneesAndBackUps, AZPRTRohKaloAsigneesEditBoxes, AZPRTRohKaloBackUpEditBoxes  = {}, {}, {}
local assignedRing, assignedRole =  "0", "Not Assigned"
local PopUpFrame = nil
local soundID = 8959
local soundChannel = 1
local EventFrame = nil

local Roles = {
    ["A"] = "Alpha",
    ["B"] = "Beta",
    ["Not"] = "Not Assigned"
}

local playerList = {
    [Roles.A] = {

    },

    [Roles.B] = {

    }
}

function AZP.BossTools.RohKalo:OnLoadSelf()
    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("VARIABLES_LOADED")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.RohKalo:OnEvent(...) end)

    AZPRTRohKaloOptionPanel = CreateFrame("FRAME", nil)
    AZPRTRohKaloOptionPanel.name = "|cFF00FFFFAzerPUG's Interrupt Helper|r"
    InterfaceOptions_AddCategory(AZPRTRohKaloOptionPanel)

    AZPRTRohKaloOptionPanel.header = AZPRTRohKaloOptionPanel:CreateFontString("AZPInterruptHelperOptionPanel", "ARTWORK", "GameFontNormalHuge")
    AZPRTRohKaloOptionPanel.header:SetPoint("TOP", 0, -10)
    AZPRTRohKaloOptionPanel.header:SetText("|cFF00FFFFAzerPUG's Interrupt Helper Options!|r")

    AZPRTRohKaloOptionPanel.footer = AZPRTRohKaloOptionPanel:CreateFontString("AZPInterruptHelperOptionPanel", "ARTWORK", "GameFontNormalLarge")
    AZPRTRohKaloOptionPanel.footer:SetPoint("TOP", 0, -400)
    AZPRTRohKaloOptionPanel.footer:SetText(
        "|cFF00FFFFAzerPUG Links:\n" ..
        "Website: www.azerpug.com\n" ..
        "Discord: www.azerpug.com/discord\n" ..
        "Twitch: www.twitch.tv/azerpug\n|r"
    )

    AZP.BossTools.RohKalo:FillOptionsPanel(AZPRTRohKaloOptionPanel)

    AZPRTRohKaloAlphaFrame = CreateFrame("FRAME", nil, UIPanel, "BackdropTemplate")
    AZPRTRohKaloAlphaFrame:SetSize(175, 150)
    AZPRTRohKaloAlphaFrame:SetPoint("TOPLEFT", 100, -200)
    AZPRTRohKaloAlphaFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })

    AZPRTRohKaloAlphaFrame.Header = AZPRTRohKaloAlphaFrame:CreateFontString("AZPRTRohKaloAlphaFrame", "ARTWORK", "GameFontNormalHuge")
    AZPRTRohKaloAlphaFrame.Header:SetSize(AZPRTRohKaloAlphaFrame:GetWidth(), 25)
    AZPRTRohKaloAlphaFrame.Header:SetPoint("TOP", 0, -5)
    AZPRTRohKaloAlphaFrame.Header:SetText("Alpha XXX")

    AZPRTRohKaloAlphaFrame.HelpButton = CreateFrame("BUTTON", nil, AZPRTRohKaloAlphaFrame, "UIPanelButtonTemplate")
    AZPRTRohKaloAlphaFrame.HelpButton:SetSize(75, 20)
    AZPRTRohKaloAlphaFrame.HelpButton:SetPoint("TOP", -40, -30)
    AZPRTRohKaloAlphaFrame.HelpButton:SetText("I Need Help!")
    AZPRTRohKaloAlphaFrame.HelpButton:SetScript("OnClick", function() AZP.BossTools.RohKalo:ShareHelpRequest() end)

    AZPRTRohKaloAlphaFrame.SafeButton = CreateFrame("BUTTON", nil, AZPRTRohKaloAlphaFrame, "UIPanelButtonTemplate")
    AZPRTRohKaloAlphaFrame.SafeButton:SetSize(75, 20)
    AZPRTRohKaloAlphaFrame.SafeButton:SetPoint("TOP", 40, -30)
    AZPRTRohKaloAlphaFrame.SafeButton:SetText("I Can Solo!")
    AZPRTRohKaloAlphaFrame.SafeButton:SetScript("OnClick", function()  end)

    AZPRTRohKaloAlphaFrame.LeftLabels = {}
    AZPRTRohKaloAlphaFrame.RightLabels = {}

    for i = 1, 6 do
        AZPRTRohKaloAlphaFrame.LeftLabels[i] = AZPRTRohKaloAlphaFrame:CreateFontString("AZPRTRohKaloAlphaFrame", "ARTWORK", "GameFontNormal")
        AZPRTRohKaloAlphaFrame.LeftLabels[i]:SetSize(100, 25)
        AZPRTRohKaloAlphaFrame.LeftLabels[i]:SetPoint("TOP", -55, ((i - 1) * -15) -50)
        AZPRTRohKaloAlphaFrame.LeftLabels[i]:SetText("Alpha" .. i)
        AZPRTRohKaloAlphaFrame.LeftLabels[i]:SetJustifyH("RIGHT")

        AZPRTRohKaloAlphaFrame.RightLabels[i] = AZPRTRohKaloAlphaFrame:CreateFontString("AZPRTRohKaloAlphaFrame", "ARTWORK", "GameFontNormal")
        AZPRTRohKaloAlphaFrame.RightLabels[i]:SetSize(100, 25)
        AZPRTRohKaloAlphaFrame.RightLabels[i]:SetPoint("TOP", 55, ((i - 1) * -15) -50)
        AZPRTRohKaloAlphaFrame.RightLabels[i]:SetText("Beta" .. i)
        AZPRTRohKaloAlphaFrame.RightLabels[i]:SetJustifyH("LEFT")
    end

    AZP.BossTools.RohKalo:CreatePopUpFrame()
    AZPRTRohKaloAlphaFrame.Header:SetText(string.format("%s %s", assignedRole, assignedRing))
    C_ChatInfo.RegisterAddonMessagePrefix("AZPRKHData")
end


function AZP.BossTools.RohKalo:FillOptionsPanel(frameToFill)
    frameToFill.LockMoveButton = CreateFrame("Button", nil, frameToFill, "UIPanelButtonTemplate")
    frameToFill.LockMoveButton:SetSize(100, 25)
    frameToFill.LockMoveButton:SetPoint("TOPRIGHT", -75, -50)
    frameToFill.LockMoveButton:SetText("Share List")
    frameToFill.LockMoveButton:SetScript("OnClick", function() AZP.BossTools.RohKalo:ShareList() end )

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
    frameToFill.ShowHideButton:SetScript("OnClick", function () AZP.RohKaloHelper:ShowHideFrame() end)

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

        AZPRTRohKaloAsigneesEditBoxes[i] = AssigneesFrame

        AssigneesFrame.editbox:SetScript("OnEditFocusLost",
        function()
            for j = 1, 6 do
                if (AZPRTRohKaloAsigneesEditBoxes[j].editbox:GetText() ~= nil and AZPRTRohKaloAsigneesEditBoxes[j].editbox:GetText() ~= "") then
                    for k = 1, 40 do
                        local curName = GetRaidRosterInfo(k)
                        if curName ~= nil then
                            if string.find(curName, "-") then
                                curName = string.match(curName, "(.+)-")
                            end
                            if curName == AZPRTRohKaloAsigneesEditBoxes[j].editbox:GetText() then
                                local curGUID = UnitGUID("raid" .. k)
                                local ring = AZPRTRohKaloAsigneesAndBackUps[j];
                                if ring == nil then ring = {} AZPRTRohKaloAsigneesAndBackUps[j] = ring end
                                ring[Roles.A] = { curGUID, curName }
                            end
                        end
                    end
                end
            end
        end)
    end

    frameToFill.assigneeHeader = frameToFill:CreateFontString("AssigneesFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.assigneeHeader:SetSize(100, 25)
    frameToFill.assigneeHeader:SetPoint("BOTTOM", AZPRTRohKaloAsigneesEditBoxes[1].editbox, "TOP", 0, 0)
    frameToFill.assigneeHeader:SetText("Alpha")

    for i = 1, 6 do
        local BackUpsFrame = CreateFrame("Frame", nil, frameToFill)
        BackUpsFrame:SetSize(100, 25)
        BackUpsFrame:SetPoint("LEFT", AZPRTRohKaloAsigneesEditBoxes[i], "RIGHT", 5, 0)
        BackUpsFrame.editbox = CreateFrame("EditBox", nil, BackUpsFrame, "InputBoxTemplate")
        BackUpsFrame.editbox:SetSize(100, 25)
        BackUpsFrame.editbox:SetPoint("LEFT",0, 0)
        BackUpsFrame.editbox:SetAutoFocus(false)
        AZPRTRohKaloBackUpEditBoxes[i] = BackUpsFrame

        BackUpsFrame.editbox:SetScript("OnEditFocusLost",
        function()
            for j = 1,6 do
                if (AZPRTRohKaloBackUpEditBoxes[j].editbox:GetText() ~= nil and AZPRTRohKaloBackUpEditBoxes[j].editbox:GetText() ~= "") then
                    for k = 1, 40 do
                        local curName = GetRaidRosterInfo(k)
                        if curName ~= nil then
                            if string.find(curName, "-") then
                                curName = string.match(curName, "(.+)-")
                            end
                            if curName == AZPRTRohKaloBackUpEditBoxes[j].editbox:GetText() then
                                local curGUID = UnitGUID("raid" .. k)
                                local ring = AZPRTRohKaloAsigneesAndBackUps[j];
                                if ring == nil then ring = {} AZPRTRohKaloAsigneesAndBackUps[j] = ring end
                                ring[Roles.B] = { curGUID, curName }
                            end
                        end
                    end
                end
            end
        end)
    end

    frameToFill.backupHeader = frameToFill:CreateFontString("AssigneesFrame", "ARTWORK", "GameFontNormalLarge")
    frameToFill.backupHeader:SetSize(100, 25)
    frameToFill.backupHeader:SetPoint("BOTTOM", AZPRTRohKaloBackUpEditBoxes[1], "TOP", 0, 0)
    frameToFill.backupHeader:SetText("Beta")

    frameToFill:Hide()
end

function AZP.BossTools.RohKalo:ShareList()
    local assignAlphaMessage = "1:Assignments:A"
    local assignBetaMessage = "1:Assignments:B"

    for _,v in ipairs(AZPRTRohKaloAsigneesAndBackUps) do
        assignAlphaMessage = assignAlphaMessage .. ":" .. v[Roles.A][1]
        assignBetaMessage = assignBetaMessage .. ":" .. v[Roles.B][1]
    end

    print(assignAlphaMessage, assignBetaMessage)

    -- AZP.BossTools.Events:AddonMessage(nil, "AZPRKHData", assignAlphaMessage)
    -- AZP.BossTools.Events:AddonMessage(nil, "AZPRKHData", assignBetaMessage)
    C_ChatInfo.SendAddonMessage("AZPRKHData", assignAlphaMessage ,"RAID", 1)
    C_ChatInfo.SendAddonMessage("AZPRKHData", assignBetaMessage ,"RAID", 1)


end

function AZP.BossTools.RohKalo:ShareHelpRequest()
    -- Format for v1
    -- version|HelpRequest|player-guid|assignedRing|
    -- version|Assignments|role|{player-guid * n players}

    local message = string.format("1:HelpRequest:%s:%s", UnitGUID("player"), assignedRing)
    -- AZP.BossTools.Events:AddonMessage(nil, "AZPRKHData", message)
    C_ChatInfo.SendAddonMessage("AZPRKHData", message ,"RAID", 1)

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

function AZP.BossTools.Events:AddonMessage(...)
    local prefix, payload, _, sender = ...

    if prefix == "AZPRKHData" then
        local protocolVersion = string.match(payload, "(%d):.*")
        if protocolVersion == "1" then
            local _, requestType, data = string.match(payload, "(%d):([^:]*):(.*)")
            if requestType == "HelpRequest" then
                local requestOrigin, ring = string.match(data, "([^:]*):(.*)")
                if ring == assignedRing then
                    print("Yo! Your help was requested!")
                    local name, realm = select(6, GetPlayerInfoByGUID(requestOrigin))
                    AZP.BossTools.RohKalo:WarnPlayer(string.format("|cFFFF0000Help on ring %d!|r", assignedRing))
                end
            elseif requestType == "Assignments" then
                local role, players = string.match(data, "([^:]*):(.*)")

                local pattern = "([^:]+)"
                local stringIndex = 1
                local index = 0
                while stringIndex < #players do
                    local _, endPos = string.find(players, pattern, stringIndex)
                    local unitGUID = string.match(players, pattern, stringIndex)
                    stringIndex = endPos + 1
                    index = index + 1
                    playerList[Roles[role]][index] = unitGUID
                end

                AZP.BossTools.RohKalo:UpdatePlayerList()
            end

            if AZP.BossTools.RohKalo.DebugPrint == true then
                print(protocolVersion, senderGUID, requestType, data)
            end
        end
    end
end
function AZP.BossTools.RohKalo:UpdatePlayerList()
    local playerGUID = UnitGUID("player")

    assignedRing = 0
    assignedRole = Roles.Not

    local alphaAssignment = AZP.BossTools.RohKalo:GetIndex(playerList[Roles.A], playerGUID)
    local headerText = Roles.Not
    if alphaAssignment ~= nil then
        headerText = string.format("%s %s", Roles.A, alphaAssignment)
        assignedRole = Roles.A
        assignedRing = alphaAssignment
    else 
        local betaAssignment = AZP.BossTools.RohKalo:GetIndex(playerList[Roles.B], playerGUID)
        if betaAssignment ~= nil then
            assignedRole = Roles.B
            headerText = string.format("%s %s", Roles.B, betaAssignment)
            assignedRing = betaAssignment
        end
    end

    AZPRTRohKaloAlphaFrame.Header:SetText(headerText)
    for i = 1, 6 do
        local alpha = playerList[Roles.A][i]
        local beta = playerList[Roles.B][i]

        if alpha ~= nil then
            local name = select(6, GetPlayerInfoByGUID(alpha))
            AZPRTRohKaloAlphaFrame.LeftLabels[i]:SetText(name)
            AZPRTRohKaloAsigneesEditBoxes[i].editbox:SetText(name)
        end
        if beta ~= nil then
            local name = select(6, GetPlayerInfoByGUID(beta))
            AZPRTRohKaloAlphaFrame.RightLabels[i]:SetText(name)
            AZPRTRohKaloBackUpEditBoxes[i].editbox:SetText(name)
        end
    end
end
function AZP.BossTools.RohKalo:GetIndex(table, targetGUID)
    for i,GUID in ipairs(table) do
        if GUID == targetGUID then
            return i
        end
    end
    return nil
end

function AZP.BossTools.RohKalo:OnEvent(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
        AZP.BossTools.Events:AddonMessage(...)
    elseif event == "VARIABLES_LOADED" then
        
    end
end

--[[

    Order of the people based on raid#
    Should be the same for all individual AddOns, as th raid# does not change.

--]]
AZP.BossTools.RohKalo:OnLoadSelf()
