if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Sylvanas == nil then AZP.BossTools.Sylvanas = {} end
if AZP.BossTools.Sylvanas.Events == nil then AZP.BossTools.Sylvanas.Events = {} end

local AZPBTSylvanasOptions = nil

local EventFrame = nil

local CurTicker = nil
local SylvEncounter = 2435
local BasheeShroud = {ID = 350857, Count = 0}

local SylvPhases = {"P1", "PI", "P2", "P3"}

function AZP.BossTools.Sylvanas:OnLoadSelf()
    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("ENCOUNTER_START")
    EventFrame:RegisterEvent("ENCOUNTER_END")
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:RegisterEvent("VARIABLES_LOADED")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Sylvanas:OnEvent(...) end)

    AZPBTSylvanasOptions = CreateFrame("FRAME", nil)
    AZPBTSylvanasOptions.name = "|cFF00FFFFSylvanas|r"
    AZPBTSylvanasOptions.parent = AZP.BossTools.ParentOptionFrame.name
    InterfaceOptions_AddCategory(AZPBTSylvanasOptions)

    AZPBTSylvanasOptions.Header = AZPBTSylvanasOptions:CreateFontString("AZPBTSylvanasOptions", "ARTWORK", "GameFontNormalHuge")
    AZPBTSylvanasOptions.Header:SetPoint("TOP", 0, -10)
    AZPBTSylvanasOptions.Header:SetText("|cFF00FFFFAzerPUG's BossTools Options!|r")
    AZPBTSylvanasOptions.SubHeader = AZPBTSylvanasOptions:CreateFontString("AZPBTSylvanasOptions", "ARTWORK", "GameFontNormalLarge")
    AZPBTSylvanasOptions.SubHeader:SetPoint("TOP", 0, -35)
    AZPBTSylvanasOptions.SubHeader:SetText("|cFF00FFFFSylvanas|r")



    AZPBTSylvanasOptions.CreateNewTimerLabel = AZPBTSylvanasOptions:CreateFontString("AZPBTSylvanasOptions", "ARTWORK", "GameFontNormalLarge")
    AZPBTSylvanasOptions.CreateNewTimerLabel:SetPoint("LEFT", AZPBTSylvanasOptions.CreateNewTimerButton, "RIGHT", 10, 0)
    AZPBTSylvanasOptions.CreateNewTimerLabel:SetText("Create New Timer")

    AZPBTSylvanasOptions.scrollFrame = CreateFrame("ScrollFrame", "scrollFrame", AZPBTSylvanasOptions, "UIPanelScrollFrameTemplate");
    AZPBTSylvanasOptions.scrollFrame:SetSize(600, 500)
    AZPBTSylvanasOptions.scrollFrame:SetPoint("TOPLEFT", -2, -35)
    AZPBTSylvanasOptions.scrollPanel = CreateFrame("Frame", "scrollPanel")
    AZPBTSylvanasOptions.scrollPanel:SetSize(500, 1000)
    AZPBTSylvanasOptions.scrollPanel:SetPoint("TOP")
    AZPBTSylvanasOptions.scrollFrame:SetScrollChild(AZPBTSylvanasOptions.scrollPanel)

    AZPBTSylvanasOptions.CreateNewTimerButton = CreateFrame("FRAME", nil, AZPBTSylvanasOptions.scrollPanel)
    AZPBTSylvanasOptions.CreateNewTimerButton:SetSize(20, 20)
    AZPBTSylvanasOptions.CreateNewTimerButton:SetPoint("TOPLEFT", 50, -100)
    AZPBTSylvanasOptions.CreateNewTimerButton:SetScript("OnMouseDown", function() AZP.BossTools.Sylvanas:CreateNewTimer("PX", 0, "Text Here") end)
    AZPBTSylvanasOptions.CreateNewTimerButton.Texture = AZPBTSylvanasOptions.CreateNewTimerButton:CreateTexture(nil, "BACKGROUND")
    AZPBTSylvanasOptions.CreateNewTimerButton.Texture:SetTexture("Interface\\BUTTONS\\UI-PlusButton-Up")
    AZPBTSylvanasOptions.CreateNewTimerButton.Texture:SetSize(20, 20)
    AZPBTSylvanasOptions.CreateNewTimerButton.Texture:SetAllPoints(true)

    AZPBTSylvanasOptions.TimerFrames = {}
    AZPBTSylvanasOptions:Hide()

    -- AZP.BossTools.Sylvanas:CreateNewTimer("P1",   5, "All DPS CDs + Pots + Hero")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P1",  60, "Panda - Tide")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P1", 110, "Tex - Tranq")

    -- AZP.BossTools.Sylvanas:CreateNewTimer("PI",   1, "Stack in Middle")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("PI",   5, "Panda - Link")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("PI",  10, "Rhalya - AMast")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("PI",  15, "Tex - Convoke")

    -- AZP.BossTools.Sylvanas:CreateNewTimer("P2",   1, "All DPS CDs")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P2",  35, "Tex - Tranq")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P2",  75, "Panda - Tide")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P2", 110, "Stack on Summoner + Pots!")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P2", 111, "Tex - HotW")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P2", 125, "Rhalya - AMast")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P2", 126, "Panda - Link")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P2", 160, "2 Min DPS CDs")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P2", 175, "Tex - Tranq")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P2", 210, "4 Min DPS CDs")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P2", 225, "Tex - Convoke")

    -- AZP.BossTools.Sylvanas:CreateNewTimer("P3",  20, "3 Min DPS CDs")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P3",  40, "Tex - Clear Platforms")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P3",  50, "Panda - Link")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P3",  60, "Rhalya - AMast")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P3",  70, "Panda - Tide")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P3",  95, "2 Min DPS CDs")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P3", 110, "Tex - Convoke")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P3", 120, "Tex - Tranq")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P3", 240, "All DPS CDs + Pots + Hero")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P3", 241, "IN'QUEH MELE'NAH!")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P3", 250, "Stack on Boss")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P3", 255, "Panda - Link, Tide")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P3", 265, "Rhalya - AMast")
    -- AZP.BossTools.Sylvanas:CreateNewTimer("P3", 275, "Tex - Tranq")
end

function AZP.BossTools.Sylvanas:OnVarsLoaded()
    if AZPBTSylvTimers == nil then AZPBTSylvTimers = {} end
    for phase, data in pairs(AZPBTSylvTimers) do
        for timer, text in pairs(data) do
            AZP.BossTools.Sylvanas:CreateNewTimer(phase, timer, text)
        end
    end
end

function AZP.BossTools.Sylvanas:PhaseDropdownSelect(Index, Text)
    UIDropDownMenu_SetText(AZPBTSylvanasOptions.TimerFrames[Index].DropDown, Text)
    CloseDropDownMenus()
end

function AZP.BossTools.Sylvanas:PositionOf(list, key)
    for i, v in ipairs(list) do
        if v == key then
            return i
        end
    end
    return #list
end

function AZP.BossTools.Sylvanas:SortFrames(frames)
    table.sort(frames, function(a,b)
        local phaseIndexA = AZP.BossTools.Sylvanas:PositionOf(SylvPhases, a.Phase)
        local phaseIndexB = AZP.BossTools.Sylvanas:PositionOf(SylvPhases, b.Phase)
        return phaseIndexA < phaseIndexB or phaseIndexA == phaseIndexB and a.Timer < b.Timer
    end)

    AZP.BossTools.Sylvanas:ReOrderFrames()
end

function AZP.BossTools.Sylvanas:CreateNewTimer(Phase, Timer, RWTextBox)
    local curFrame = CreateFrame("FRAME", nil, AZPBTSylvanasOptions.scrollPanel)
    curFrame.Index = #AZPBTSylvanasOptions.TimerFrames + 1
    curFrame:SetSize(500, 25)
    curFrame:SetPoint("TOPLEFT", 25, -100 - (curFrame.Index - 1) * 25)

    curFrame.Phase = Phase
    curFrame.Timer = Timer
    curFrame.RWText = RWText

    curFrame.Label = CreateFrame("EditBox", nil, curFrame, "InputBoxTemplate")
    curFrame.Label:SetSize(100, 25)
    curFrame.Label:SetPoint("TOPLEFT", 5, 0)
    curFrame.Label:SetText(string.format("Label %s", curFrame.Index))
    curFrame.Label:SetAutoFocus(false)

    curFrame.DropDown = CreateFrame("Button", nil, curFrame, "UIDropDownMenuTemplate")
    curFrame.DropDown:SetPoint("LEFT", curFrame.Label, "RIGHT", -15, -3)
    UIDropDownMenu_SetWidth(curFrame.DropDown, 50)
    UIDropDownMenu_Initialize(curFrame.DropDown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        info.func = AZP.BossTools.Sylvanas.PhaseDropdownSelect
        for i = 1, #SylvPhases do
            info.text = SylvPhases[i]
            info.arg1 = curFrame.Index
            info.arg2 = SylvPhases[i]
            UIDropDownMenu_AddButton(info, 1)
        end
    end)
    UIDropDownMenu_SetText(curFrame.DropDown, curFrame.Phase)

    curFrame.TimerBox = CreateFrame("EditBox", nil, curFrame, "InputBoxTemplate")
    curFrame.TimerBox:SetSize(30, 25)
    curFrame.TimerBox:SetPoint("LEFT", curFrame.DropDown, "RIGHT", -5, 3)
    curFrame.TimerBox:SetAutoFocus(false)
    curFrame.TimerBox:SetText(Timer)

    curFrame.RWTextBox = CreateFrame("EditBox", nil, curFrame, "InputBoxTemplate")
    curFrame.RWTextBox:SetSize(200, 25)
    curFrame.RWTextBox:SetPoint("LEFT", curFrame.TimerBox, "RIGHT", 10, 0)
    curFrame.RWTextBox:SetAutoFocus(false)
    curFrame.RWTextBox:SetText(RWTextBox)
    -- curFrame.RWTextBox:SetScript("OnEditFocusLost",
    -- function()
    --     if curFrame.DropDown:GetText() ~= nil and curFrame.TimerBox:GetText() ~= nil and curFrame.RWTextBox:GetText() ~= nil then
    --         AZP.BossTools.Sylvanas:AddInfoTimer(curFrame.DropDown:GetText(), curFrame.TimerBox:GetText(), curFrame.RWTextBox:GetText(), curFrame.Index) 
    --         print(string.format("RWTextBox EditBox %d Lost Focus", curFrame.Index))
    --     end
    -- end)

    curFrame.SaveButton = CreateFrame("FRAME", nil, curFrame)
    curFrame.SaveButton:SetSize(25, 25)
    curFrame.SaveButton:SetPoint("LEFT", curFrame.RWTextBox, "RIGHT", 5, 0)
    curFrame.SaveButton.Texture = curFrame.SaveButton:CreateTexture(nil, "BACKGROUND")
    curFrame.SaveButton.Texture:SetTexture("Interface\\BUTTONS\\LockButton-Locked-Up")
    curFrame.SaveButton.Texture:SetSize(20, 20)
    curFrame.SaveButton.Texture:SetAllPoints(true)

    curFrame.RemoveButton = CreateFrame("FRAME", nil, curFrame)
    curFrame.RemoveButton:SetSize(20, 20)
    curFrame.RemoveButton:SetPoint("LEFT", curFrame.SaveButton, "RIGHT", 5, 0)
    curFrame.RemoveButton.Texture = curFrame.RemoveButton:CreateTexture(nil, "BACKGROUND")
    curFrame.RemoveButton.Texture:SetTexture("Interface\\BUTTONS\\UI-MinusButton-Up")
    curFrame.RemoveButton.Texture:SetSize(20, 20)
    curFrame.RemoveButton.Texture:SetAllPoints(true)

    AZPBTSylvanasOptions.TimerFrames[curFrame.Index] = curFrame

    curFrame.SaveButton:SetScript("OnMouseDown",
    function()
        AZP.BossTools.Sylvanas:RemoveFromSavedVar(Phase, Timer)
        local setPhase = UIDropDownMenu_GetText(curFrame.DropDown, curFrame.Phase)
        print(setPhase)
        local setTimer = tonumber(curFrame.TimerBox:GetText())
        local setText = curFrame.RWTextBox:GetText()
        AZP.BossTools.Sylvanas:SaveTimerInfo(setPhase, setTimer, setText)
        curFrame.Phase = setPhase
        curFrame.Timer = setTimer
        curFrame.RWText = setText
        AZP.BossTools.Sylvanas:SortFrames(AZPBTSylvanasOptions.TimerFrames)
    end)
    curFrame.RemoveButton:SetScript("OnMouseDown", function() AZP.BossTools.Sylvanas:DestroyTimer(curFrame.Index) end)

    AZP.BossTools.Sylvanas:SortFrames(AZPBTSylvanasOptions.TimerFrames)

    -- AZPBTSylvanasOptions:Hide()
end

function AZP.BossTools.Sylvanas:ReOrderFrames()
    local lastFrame = AZPBTSylvanasOptions.TimerFrames[#AZPBTSylvanasOptions.TimerFrames]
    for index, frame in ipairs(AZPBTSylvanasOptions.TimerFrames) do
        frame.Index = index
        frame:SetPoint("TOPLEFT", 25, -100 - (index - 1) * 25)
    end

    local ButtonPoint = {}
    ButtonPoint[1], ButtonPoint[2], ButtonPoint[3], ButtonPoint[4], ButtonPoint[5] = lastFrame:GetPoint()
    AZPBTSylvanasOptions.CreateNewTimerButton:SetPoint(ButtonPoint[1], ButtonPoint[2], ButtonPoint[3], ButtonPoint[4], ButtonPoint[5] - 25)
end

function AZP.BossTools.Sylvanas:SaveTimerInfo(Phase, Timer, RWTextBox)
    print(string.format("Trying to save AZPBTSylvTimers[%s][%s] = %s", Phase, Timer, RWTextBox))
    if AZPBTSylvTimers == nil or AZPBTSylvTimers == {} then AZPBTSylvTimers = {} AZPBTSylvTimers.P1 = {} AZPBTSylvTimers.PI = {} AZPBTSylvTimers.P2 = {} AZPBTSylvTimers.P3 = {} end
    AZPBTSylvTimers[Phase][tonumber(Timer)] = RWTextBox
end

function AZP.BossTools.Sylvanas:RemoveFromSavedVar(Phase, Timer)
    AZPBTSylvTimers[Phase][tonumber(Timer)] = nil
end

function AZP.BossTools.Sylvanas:DestroyTimer(Index)
    local curFrame = AZPBTSylvanasOptions.TimerFrames[Index]
    local Phase = UIDropDownMenu_GetText(curFrame.DropDown, curFrame.Phase)
    local Timer = curFrame.TimerBox:GetText()

    AZP.BossTools.Sylvanas:RemoveFromSavedVar(Phase, Timer)

    AZPBTSylvanasOptions.TimerFrames[Index]:SetParent(nil)
    AZPBTSylvanasOptions.TimerFrames[Index]:Hide()

    for i = Index, #AZPBTSylvanasOptions.TimerFrames - 1 do
        AZPBTSylvanasOptions.TimerFrames[i] = AZPBTSylvanasOptions.TimerFrames[i + 1]
        AZPBTSylvanasOptions.TimerFrames[i].Index = AZPBTSylvanasOptions.TimerFrames[i].Index - 1
    end

    AZPBTSylvanasOptions.TimerFrames[#AZPBTSylvanasOptions.TimerFrames] = nil

    for i = 1, #AZPBTSylvanasOptions.TimerFrames do
        AZPBTSylvanasOptions.TimerFrames[i]:SetPoint("TOPLEFT", 25, -100 - (i - 1) * 25)
    end

    local ButtonPoint = {}
    ButtonPoint[1], ButtonPoint[2], ButtonPoint[3], ButtonPoint[4], ButtonPoint[5] = AZPBTSylvanasOptions.CreateNewTimerButton:GetPoint()
    AZPBTSylvanasOptions.CreateNewTimerButton:SetPoint(ButtonPoint[1], ButtonPoint[2], ButtonPoint[3], ButtonPoint[4], ButtonPoint[5] + 25)
end

function AZP.BossTools.Sylvanas:OnEvent(self, event, ...)
    if event == "VARIABLES_LOADED" then
        AZP.BossTools.Sylvanas:OnVarsLoaded()
    elseif event == "ENCOUNTER_START" then
        if ... == SylvEncounter then
            print("ENCOUNTER_START")
            AZP.BossTools.Sylvanas:Timer("P1")
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local v1, subevent, v3, v4, v5, v6, v7, v8, v9, v10, v11, SpellID = CombatLogGetCurrentEventInfo()
        if SpellID == BasheeShroud.ID then
            if subevent == "SPELL_AURA_APPLIED" then
                BasheeShroud.Count = BasheeShroud.Count + 1
                print("Banshee Shroud Applied, Stack:", BasheeShroud.Count)
                if BasheeShroud.Count == 1 then CurTicker:Cancel() AZP.BossTools.Sylvanas:Timer("PI1") AZP.BossTools.Sylvanas:RaidWarning("Boss no feel auchies!") end
                if BasheeShroud.Count == 2 then AZP.BossTools.Sylvanas:RaidWarning("Boss no feel auchies!") end
                if BasheeShroud.Count == 4 then AZP.BossTools.Sylvanas:RaidWarning("Boss no feel auchies!") end
            elseif subevent == "SPELL_AURA_REMOVED" then
                print("Banshee Shroud Removed, Stack:", BasheeShroud.Count)
                if BasheeShroud.Count == 1 then CurTicker:Cancel() AZP.BossTools.Sylvanas:Timer("P2") AZP.BossTools.Sylvanas:RaidWarning("Boss feels auchies, PEW-PEW-PEW!") end
                if BasheeShroud.Count == 2 then AZP.BossTools.Sylvanas:RaidWarning("Boss feels auchies, PEW-PEW-PEW!") end
                if BasheeShroud.Count == 4 then CurTicker:Cancel() AZP.BossTools.Sylvanas:Timer("P3") end
            end
        end
    elseif event == "ENCOUNTER_END" then
        if ... == SylvEncounter then
            CurTicker:Cancel()
            BasheeShroud.Count = 0
            print("ENCOUNTER_END")
        end
    end
end

function AZP.BossTools.Sylvanas:Timer(Phase)
    local Timer = 0
    CurTicker = C_Timer.NewTicker(1, function() Timer = Timer + 1 AZP.BossTools.Sylvanas:CheckTime(Phase, Timer) end, 600)
end

function AZP.BossTools.Sylvanas:CheckTime(Phase, Timer)
    local curTimers = AZPBTSylvTimers[Phase]
    
    if curTimers[Timer] ~= nil then AZP.BossTools.Sylvanas:RaidWarning(curTimers[Timer]) end
end

function AZP.BossTools.Sylvanas:RaidWarning(RWTextBox)
    SendChatMessage(RWTextBox, "RAID_WARNING")
end

AZP.BossTools.Sylvanas:OnLoadSelf()