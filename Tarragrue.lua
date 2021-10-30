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
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Tarragrue:OnEvent(...) end)

    AZPBTSylvOptions = CreateFrame("FRAME", nil)
    AZPBTSylvOptions.name = "|cFF00FFFFTarragrue|r"
    AZPBTSylvOptions.parent = AZP.BossTools.ParentOptionFrame.name
    InterfaceOptions_AddCategory(AZPBTSylvOptions)

    AZPBTSylvOptions.Header = AZPBTSylvOptions:CreateFontString("AZPBTSylvOptions", "ARTWORK", "GameFontNormalHuge")
    AZPBTSylvOptions.Header:SetPoint("TOP", 0, -10)
    AZPBTSylvOptions.Header:SetText("|cFF00FFFFAzerPUG's BossTools Options!|r")
    AZPBTSylvOptions.SubHeader = AZPBTSylvOptions:CreateFontString("AZPBTSylvOptions", "ARTWORK", "GameFontNormalLarge")
    AZPBTSylvOptions.SubHeader:SetPoint("TOP", 0, -35)
    AZPBTSylvOptions.SubHeader:SetText("|cFF00FFFFTarragrue|r")

    AZPBTSylvOptions:Hide()
end

function AZP.BossTools.Tarragrue:OnVarsLoaded()
    -- ?
end

function AZP.BossTools.Tarragrue:OnEvent(self, event, ...)
    if event == "VARIABLES_LOADED" then
        AZP.BossTools.Tarragrue:OnVarsLoaded()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local v1, subevent, v3, v4, v5, v6, v7, v8, v9, v10, v11, SpellID = CombatLogGetCurrentEventInfo()
        if SpellID == 0 then
        end
    end
end

AZP.BossTools.Tarragrue:OnLoadSelf()