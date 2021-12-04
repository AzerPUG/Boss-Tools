if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Tarragrue == nil then AZP.BossTools.Tarragrue = {} end
if AZP.BossTools.Tarragrue.Events == nil then AZP.BossTools.Tarragrue.Events = {} end

local AZPBTTarragrueOptions = nil

local EventFrame = nil

local TarragruePowerUsefullness = {[1] = "Useless", [2] = "Bad", [3] = "Decent", [4] = "Good", [5] = "Amazing!"}

local TarragruePowers =
{
    [347966] = {HealerUse = 1, TankUse = 3, DPSUse = 1, Goal =   1, Banned = false, Name =          "Ever-Beating Heart"},
    [348041] = {HealerUse = 1, TankUse = 1, DPSUse = 1, Goal =   1, Banned = false, Name =         "Satchel of the Hunt"},
    [348063] = {HealerUse = 1, TankUse = 1, DPSUse = 1, Goal =   1, Banned = false, Name =    "Disembodied Mystic Hands"},
    [347980] = {HealerUse = 3, TankUse = 3, DPSUse = 3, Goal =   3, Banned = false, Name =               "Unstable Form"},
    [347976] = {HealerUse = 3, TankUse = 5, DPSUse = 4, Goal = nil, Banned = false, Name =      "Blade of the Lifetaker"},
    [347969] = {HealerUse = 2, TankUse = 4, DPSUse = 2, Goal = nil, Banned = false, Name =           "Elethium Diffuser"},
    [347961] = {HealerUse = 1, TankUse = 5, DPSUse = 1, Goal = nil, Banned = false, Name =            "Ephemeral Effigy"},
    [347934] = {HealerUse = 4, TankUse = 5, DPSUse = 4, Goal = nil, Banned = false, Name =         "Overgrowth Seedling"},
    [347962] = {HealerUse = 3, TankUse = 5, DPSUse = 3, Goal = nil, Banned = false, Name =              "The Stone Ward"},
    [347947] = {HealerUse = 4, TankUse = 4, DPSUse = 3, Goal = nil, Banned = false, Name =            "Obleron Ephemera"},
    [348025] = {HealerUse = 2, TankUse = 3, DPSUse = 5, Goal = nil, Banned = false, Name =           "Potent Acid Gland"},
    [348027] = {HealerUse = 3, TankUse = 3, DPSUse = 4, Goal = nil, Banned = false, Name =              "Erratic Howler"},
    [351871] = {HealerUse = 2, TankUse = 4, DPSUse = 3, Goal = nil, Banned = false, Name =            "Leeching Strikes"},
    [347972] = {HealerUse = 4, TankUse = 2, DPSUse = 4, Goal = nil, Banned = false, Name =            "Huddled Carvings"},
    [347943] = {HealerUse = 3, TankUse = 5, DPSUse = 3, Goal = nil, Banned = false, Name =           "Obleron Endurance"},
    [347944] = {HealerUse = 3, TankUse = 3, DPSUse = 3, Goal = nil, Banned = false, Name =              "Obleron Spikes"},
    [347946] = {HealerUse = 3, TankUse = 3, DPSUse = 3, Goal = nil, Banned = false, Name =            "Obleron Talisman"},
    [347948] = {HealerUse = 3, TankUse = 3, DPSUse = 3, Goal = nil, Banned = false, Name =               "Obleron Venom"},
    [347945] = {HealerUse = 3, TankUse = 3, DPSUse = 3, Goal = nil, Banned = false, Name =               "Obleron Winds"},
    [353747] = {HealerUse = 2, TankUse = 3, DPSUse = 4, Goal = nil, Banned = false, Name =            "Pulsing Rot-hive"},
    [353743] = {HealerUse = 2, TankUse = 2, DPSUse = 2, Goal = nil, Banned = false, Name =              "Soulward Clasp"},
    [348059] = {HealerUse = 1, TankUse = 1, DPSUse = 1, Goal = nil, Banned =  true, Name =         "Twisted Samophlange"},
    [347975] = {HealerUse = 4, TankUse = 5, DPSUse = 4, Goal = nil, Banned = false, Name =           "Tremorbeast Heart"},
    [347967] = {HealerUse = 4, TankUse = 4, DPSUse = 4, Goal = nil, Banned = false, Name =        "Oddly Intangible Key"},
    [353242] = {HealerUse = 2, TankUse = 2, DPSUse = 2, Goal = nil, Banned = false, Name =          "Overwhelming Power"},
    [347960] = {HealerUse = 3, TankUse = 1, DPSUse = 3, Goal = nil, Banned = false, Name =           "Resonating Effigy"},
    [347978] = {HealerUse = 2, TankUse = 2, DPSUse = 2, Goal = nil, Banned = false, Name =               "Spectral Oats"},
    [347985] = {HealerUse = 3, TankUse = 1, DPSUse = 4, Goal = nil, Banned = false, Name = "V'lara's Cape of Subterfuge"},
    [347968] = {HealerUse = 4, TankUse = 3, DPSUse = 4, Goal = nil, Banned = false, Name =            "Elethium Weights"},
    [347982] = {HealerUse = 2, TankUse = 3, DPSUse = 2, Goal = nil, Banned = false, Name =         "Stoneflesh Figurine"},
    [348040] = {HealerUse = 1, TankUse = 1, DPSUse = 1, Goal = nil, Banned = false, Name =               "Negation Well"},
    [351897] = {HealerUse = 1, TankUse = 3, DPSUse = 1, Goal = nil, Banned = false, Name =                 "Spiked Skin"},
    [348043] = {HealerUse = 1, TankUse = 1, DPSUse = 1, Goal = nil, Banned =  true, Name =              "Lumbering Form"},
    [347988] = {HealerUse = 1, TankUse = 1, DPSUse = 1, Goal = nil, Banned =  true, Name =               "Ten of Towers"},
}

function AZP.BossTools.Tarragrue:OnLoadSelf()
    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:RegisterEvent("VARIABLES_LOADED")
    EventFrame:RegisterEvent("PLAYER_CHOICE_UPDATE")
    EventFrame:RegisterEvent("CHAT_MSG_LOOT")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Tarragrue:OnEvent(...) end)

    AZPBTTarragrueOptions = CreateFrame("FRAME", nil)
    AZPBTTarragrueOptions.name = "|cFF00FFFFTarragrue|r"
    AZPBTTarragrueOptions.parent = AZP.BossTools.ParentOptionFrame.name
    InterfaceOptions_AddCategory(AZPBTTarragrueOptions)

    AZPBTTarragrueOptions.Header = AZPBTTarragrueOptions:CreateFontString("AZPBTTarragrueOptions", "ARTWORK", "GameFontNormalHuge")
    AZPBTTarragrueOptions.Header:SetPoint("TOP", 0, -10)
    AZPBTTarragrueOptions.Header:SetText("|cFF00FFFFAzerPUG's BossTools Options!|r")
    AZPBTTarragrueOptions.SubHeader = AZPBTTarragrueOptions:CreateFontString("AZPBTTarragrueOptions", "ARTWORK", "GameFontNormalLarge")
    AZPBTTarragrueOptions.SubHeader:SetPoint("TOP", 0, -35)
    AZPBTTarragrueOptions.SubHeader:SetText("|cFF00FFFFTarragrue|r")

    AZPBTTarragrueOptions:Hide()
end

function AZP.BossTools.Tarragrue:OnVarsLoaded()
    -- ?
end

function AZP.BossTools.Tarragrue:OnEvent(_, event, ...)
    if event == "VARIABLES_LOADED" then
        AZP.BossTools.Tarragrue:OnVarsLoaded()
    elseif event == "ADDON_LOADED" then
    elseif event == "CHAT_MSG_LOOT" then
        local chatText = ...
        chatText = string.gsub(chatText, "|", "-")
        local loc = string.find(chatText, ":")
        chatText = string.sub(chatText, loc + 1, #chatText)
        loc = string.find(chatText, ":")
        chatText = string.sub(chatText, loc + 1, loc + 4)
        chatText = tonumber(chatText)
        local powerTaken = nil
        if AZP.BossTools.MawPowers[chatText] ~= nil then powerTaken = GetSpellLink(AZP.BossTools.MawPowers[chatText]) end
        local preChatMsg = "(AddOn testing message) I am a number whore and purposely took "
        local postChatMsg = ", even though it was clearly banned! Please remove me from your raid! I deserve it!"
        if powerTaken ~= nul then SendChatMessage(string.format("%s%s%s", preChatMsg, powerTaken, postChatMsg), "RAID") end

    elseif event == "PLAYER_CHOICE_UPDATE" then
        if PlayerChoiceFrame.Marker ~= nil then
            for _, frame in ipairs(PlayerChoiceFrame.Marker) do
                frame.Texture:SetTexture(nil)
                frame:Hide()
            end
        end
        PlayerChoiceFrame.Marker = {}
        for i = 1, 3 do
            local choiceInfo = PlayerChoiceFrame.choiceInfo
            if choiceInfo ~= nil then
                local curID = choiceInfo.options[i].spellID
                local curFrame = CreateFrame("FRAME", nil, PlayerChoiceFrame, "BackdropTemplate")

                curFrame:SetSize(200, 200)
                curFrame:SetPoint("CENTER", 260 * (i - 1) - 257, 00)
                curFrame:SetFrameLevel(10)

                curFrame.Texture = curFrame:CreateTexture(nil, "ARTWORK")
                curFrame.Texture:SetSize(180, 180)
                curFrame.Texture:SetPoint("CENTER", 0, 70)

                curFrame.Text = curFrame:CreateFontString("AZPBTTarragrueOptions", "ARTWORK", "GameFontNormalHuge")
                curFrame.Text:SetPoint("CENTER", 3, -10)

                local v1, v2, v3 = curFrame.Text:GetFont()
                curFrame.Text:SetFont(v1, v2 + 10, v3)
                curFrame.Text:SetTextColor(1, 0, 0, 1)

                PlayerChoiceFrame.Marker[#PlayerChoiceFrame.Marker + 1] = curFrame

                if curID == 348043 or curID == 347988 then
                    curFrame.Text:SetText("BANNED!")
                    curFrame.Texture:SetTexture(GetFileIDFromPath("Interface\\RAIDFRAME\\ReadyCheck-NotReady"))
                else
                    curFrame.Text:SetText(nil)
                    curFrame.Texture:SetTexture(nil)
                end
            end
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local v1, subevent, v3, v4, v5, v6, v7, v8, v9, v10, v11, SpellID = CombatLogGetCurrentEventInfo()
        if SpellID == 0 then
        end
    end
end

AZP.BossTools.Tarragrue:OnLoadSelf()