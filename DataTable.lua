if AZP == nil then AZP = {} end
if AZP.BossTools == nil then AZP.BossTools = {} end

AZP.BossTools.IDs =
{
    TheEye =
    {
        Spell =
        {
            StygianEjection = 348117,
        },
    },
    Dormazain =
    {
        Spell =
        {
            WarmongerShackles = 350415,
        },
    },
}

AZP.BossTools.BossInfo =
{
    Sanctum =
    {
        Tarragrue =
        {
            Name = "Tarragrue",
            ID = 2423,
            Index = 1,
            Active = "Soon",
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Tarragrue.blp"),
        },
        TheEye =
        {
            Name = "The Eye",
            ID = 2433,
            Index = 2,
            Active = true,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS- Eye of the Jailer.blp"),
            Spells =
            {
                StygianEjection = 348117,
            },
        },
        TheNine =
        {
            Name = "The Nine",
            ID = 2429,
            Index = 3,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-The Nine.blp"),
        },
        NerZhul =
        {
            Name = "Ner'Zhul",
            ID = 2432,
            Index = 4,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Remnant of Ner zhul.blp"),
        },
        Dormazain =
        {
            Name = "Dormazain",
            ID = 2434,
            Index = 5,
            Active = true,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Soulrender Dormazain.blp"),
            Spell =
            {
                WarmongerShackles = 350415,
            },
        },
        Painsmith =
        {
            Name = "Painsmith",
            ID = 2430,
            Index = 6,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Painsmith Raznal.blp"),
        },
        Guardian =
        {
            Name = "Guardian",
            ID = 2436,
            Index = 7,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Guardian of the First Ones.blp"),
        },
        RohKalo =
        {
            Name = "Roh-Kalo",
            ID = 2431,
            Index = 8,
            Active = true,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Fatescribe Roh-Talo.blp"),
        },
        KelThuzad =
        {
            Name = "Kel'Thuzad",
            ID = 2422,
            Index = 9,
            Active = true,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Kel Thuzad Shadowlands.blp"),
        },
        Sylvanas =
        {
            Name = "Sylvanas",
            ID = 2435,
            Index = 10,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Sylvanas Windrunner Shadowlands.blp"),
            Spell =
            {
                BansheeShroud = 350857,
            },
        },
    },
    Sepulcher =
    {
        Guardian =
        {
            Name = "Guardian",
            ID = 0,
            Index = 1,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\?.blp"),
        },
        Dausegne =
        {
            Name = "Dausegne",
            ID = 0,
            Index = 2,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\?.blp"),
        },
        XyMox =
        {
            Name = "Xy'Mox",
            ID = 0,
            Index = 3,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\?.blp"),
        },
        Pantheon =
        {
            Name = "Pantheon",
            ID = 0,
            Index = 4,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\?.blp"),
        },
        Lihuvim =
        {
            Name = "Lihuvim",
            ID = 0,
            Index = 5,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\?.blp"),
        },
        Skolex =
        {
            Name = "Skolex",
            ID = 0,
            Index = 6,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\?.blp"),
        },
        Halondrus =
        {
            Name = "Halondrus",
            ID = 0,
            Index = 7,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\?.blp"),
        },
        Anduin =
        {
            Name = "Anduin",
            ID = 0,
            Index = 8,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\?.blp"),
        },
        LordsOfDread =
        {
            Name = "Lords Of Dread",
            ID = 0,
            Index = 9,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\?.blp"),
        },
        Rygelon =
        {
            Name = "Rygelon",
            ID = 0,
            Index = 10,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\?.blp"),
        },
        TheJailer =
        {
            Name = "The Jailer",
            ID = 0,
            Index = 11,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\?.blp"),
        },
    }
}