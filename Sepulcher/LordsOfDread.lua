if AZP == nil then AZP = {} end
if AZP.BossTools == nil then AZP.BossTools = {} end
if AZP.BossTools.Sepulcher == nil then AZP.BossTools.Sepulcher = {} end
if AZP.BossTools.Sepulcher.LordsOfDread == nil then AZP.BossTools.Sepulcher.LordsOfDread = {} end

AZP.BossTools.BossFrames.LordsOfDread = nil
AZP.BossTools.Sepulcher.LordsOfDread.Targets = {}
AZP.BossTools.Sepulcher.LordsOfDread.Events = {}

local currentPull = nil
local currentVoting = nil

function AZP.BossTools.Sepulcher.LordsOfDread:OnLoadSelf()
    C_ChatInfo.RegisterAddonMessagePrefix("AZPDreadVote")

    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:RegisterEvent("ENCOUNTER_START")
    EventFrame:RegisterEvent("ENCOUNTER_END")

    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Sepulcher.LordsOfDread:OnEvent(...) end)

    AZP.BossTools.BossFrames.LordsOfDread = CreateFrame("FRAME", nil, UIPanel, "BackdropTemplate")
    AZP.BossTools.BossFrames.LordsOfDread:SetSize(120, 50)
    AZP.BossTools.BossFrames.LordsOfDread:SetPoint("TOPLEFT", 100, -200)
    AZP.BossTools.BossFrames.LordsOfDread:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    AZP.BossTools.BossFrames.LordsOfDread:EnableMouse(true)
    AZP.BossTools.BossFrames.LordsOfDread:SetMovable(true)
    AZP.BossTools.BossFrames.LordsOfDread:RegisterForDrag("LeftButton")
    AZP.BossTools.BossFrames.LordsOfDread:SetScript("OnDragStart", AZP.BossTools.BossFrames.LordsOfDread.StartMoving)
    AZP.BossTools.BossFrames.LordsOfDread:SetScript("OnDragStop", function() AZP.BossTools.BossFrames.LordsOfDread:StopMovingOrSizing() end)

    AZP.BossTools.BossFrames.LordsOfDread.Header = AZP.BossTools.BossFrames.LordsOfDread:CreateFontString("AZP.BossTools.BossFrames.LordsOfDread", "ARTWORK", "GameFontNormal")
    AZP.BossTools.BossFrames.LordsOfDread.Header:SetSize(AZP.BossTools.BossFrames.LordsOfDread:GetWidth(), 25)
    AZP.BossTools.BossFrames.LordsOfDread.Header:SetPoint("TOP", 0, -5)
    AZP.BossTools.BossFrames.LordsOfDread.Header:SetText("Vote Infiltrator")

    AZP.BossTools.BossFrames.LordsOfDread.HelpButton = CreateFrame("BUTTON", nil, AZP.BossTools.BossFrames.LordsOfDread, "UIPanelButtonTemplate")
    AZP.BossTools.BossFrames.LordsOfDread.HelpButton:SetSize(75, 20)
    AZP.BossTools.BossFrames.LordsOfDread.HelpButton:SetPoint("Bottom", 0, 5)
    AZP.BossTools.BossFrames.LordsOfDread.HelpButton:SetText("Vote")
    AZP.BossTools.BossFrames.LordsOfDread.HelpButton:SetScript("OnClick", function() AZP.BossTools.Sepulcher.LordsOfDread:Vote() end)
end

function AZP.BossTools.Sepulcher.LordsOfDread:OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        AZP.BossTools.Sepulcher.LordsOfDread.Events:CombatLogEventUnfiltered(...)
    elseif event == "CHAT_MSG_ADDON" then
        AZP.BossTools.Sepulcher.LordsOfDread.Events:ChatMsgAddon(...)
    elseif event == "ENCOUNTER_START" then
        AZP.BossTools.Sepulcher.LordsOfDread.Events:EncounterStart(...)
    elseif event == "ENCOUNTER_END" then
        AZP.BossTools.Sepulcher.LordsOfDread.Events:EncounterEnd(...)
    elseif event == "GROUP_ROSTER_UPDATE" then
        AZP.BossTools.Sepulcher.LordsOfDread.Events:GroupRosterUpdate(...)
    end
end

function AZP.BossTools.Sepulcher.LordsOfDread.Events:ChatMsgAddon(...)
    if UnitIsGroupLeader("player") ~= true then return end
    local prefix, payload, _, sender = ...
    if prefix == "AZPDreadVote" then
        if currentVoting == nil then
            print(string.format("Received vote from %s, but no vote is currently in progress.", sender))
        else
            if currentVoting[payload] == nil then 
                currentVoting[payload] = 1
            else
                currentVoting[payload] = currentVoting[payload] + 1
            end
            if currentVoting[payload] >= 3 and not tContains(AZP.BossTools.Sepulcher.LordsOfDread.Targets, payload) then
                if(#AZP.BossTools.Sepulcher.LordsOfDread.Targets == 2) then
                    print("Vote for infiltrator failed, too many targets.")
                    return
                end
                tinsert(AZP.BossTools.Sepulcher.LordsOfDread.Targets, payload)
                SetRaidTarget(payload, 6 + #AZP.BossTools.Sepulcher.LordsOfDread.Targets)
            end

            if currentVoting.votees == nil then currentVoting.votees = {} end
            tinsert(currentVoting.votees, {sender = sender, payload = payload})
        end
    end
end

function AZP.BossTools.Sepulcher.LordsOfDread.Events:CombatLogEventUnfiltered(...)
    local _, SubEvent, _, _, _, _, _, _, _, _, _, SpellID = CombatLogGetCurrentEventInfo()
    if SubEvent == "SPELL_CAST_SUCCESS" then
        if SpellID == AZP.BossTools.IDs.Sepulcher.LordsOfDread.Infiltration then
            AZP.BossTools.Sepulcher.LordsOfDread.Events:Infiltration()
        end
    end
end

function AZP.BossTools.Sepulcher.LordsOfDread.Events:EncounterStart(ID)
    if UnitIsGroupLeader("player") ~= true then return end
    if ID == AZP.BossTools.IDs.Sepulcher.LordsOfDread.Encounter then
        currentPull = {}

        if AZPBTLordsOfDreadVotes == nil then AZPBTLordsOfDreadVotes = {} end
        tinsert(AZPBTLordsOfDreadVotes, currentPull)

        AZP.BossTools.Sepulcher.LordsOfDread.Targets = {}
        AZP.BossTools.BossFrames.LordsOfDread:Show()
    end
end

function AZP.BossTools.Sepulcher.LordsOfDread.Events:End(ID)
    if UnitIsGroupLeader("player") ~= true then return end
    if ID == AZP.BossTools.IDs.Sepulcher.LordsOfDread.Encounter then
        currentPull = false;
    end
end

function AZP.BossTools.Sepulcher.LordsOfDread.Events:Infiltration()
    if UnitIsGroupLeader("player") ~= true then return end
    if currentPull == nil then print("Did not register Encounter start.") return end
    currentVoting = {}
    tinsert(currentPull, currentVoting)
    C_Timer.After(40, function()
        currentVoting = nil
        for _,player in ipairs(AZP.BossTools.Sepulcher.LordsOfDread.Targets) do
            SetRaidTarget(player, 0)
        end
    end)
end

function AZP.BossTools.Sepulcher.LordsOfDread:Vote()
    local unitGUID = UnitGUID("target")
    if unitGUID == nil then
        print("You must target a player to vote for.")
        return
    end

    for i = 1, 40 do
        local unit = "raid" .. i
        if UnitGUID(unit) == unitGUID then
            C_ChatInfo.SendAddonMessage("AZPDreadVote", unit, "RAID")
            break
        end
    end
end

AZP.BossTools.Sepulcher.LordsOfDread:OnLoadSelf()
