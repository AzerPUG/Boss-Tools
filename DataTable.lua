if AZP == nil then AZP = {} end
if AZP.BossTools == nil then AZP.BossTools = {} end

AZP.BossTools.MawPowers =
{
    [1425] = 348043,
    [1420] = 347988,
}

AZP.BossTools.IDs =
{
    Sepulcher =
    {
        DeSausage =
        {
            Barrage = 360960,
        },
        Skolex =
        {
            Retch = 360092,
            Burrow = 359770,
        },
    },
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

AZP.BossTools.Markers =
{
          Star = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1.png:14\124t",
        Circle = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2.png:14\124t",
    GayDiamond = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3.png:14\124t",
      Triangle = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4.png:14\124t",
          Moon = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5.png:14\124t",
        Square = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6.png:14\124t",
         Cross = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7.png:14\124t",
         Skull = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8.png:14\124t",
}

AZP.BossTools.BossInfo =
{
    Sanctum =
    {
        Background = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-LOREBG-SanctumofDomination"),
        Tarragrue =
        {
            Name = "Tarragrue",
            ID = 2423,
            Index = 1,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Tarragrue.blp"),
            Hero = "10%",
        },
        TheEye =
        {
            Name = "The Eye",
            ID = 2433,
            Index = 2,
            Active = true,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS- Eye of the Jailer.blp"),
            Hero = "Phase 3",
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
            Hero = "Phase 2",
        },
        NerZhul =
        {
            Name = "Ner'Zhul",
            ID = 2432,
            Index = 4,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Remnant of Ner zhul.blp"),
            Hero = "30%",
        },
        Dormazain =
        {
            Name = "Dormazain",
            ID = 2434,
            Index = 5,
            Active = true,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Soulrender Dormazain.blp"),
            Hero = "5 seconds",
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
            Hero = "Phase 3",
        },
        Guardian =
        {
            Name = "Guardian",
            ID = 2436,
            Index = 7,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Guardian of the First Ones.blp"),
            Hero = "5 seconds",
        },
        RohKalo =
        {
            Name = "Roh-Kalo",
            ID = 2431,
            Index = 8,
            Active = true,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Fatescribe Roh-Talo.blp"),
            Hero = "Phase 3",
        },
        KelThuzad =
        {
            Name = "Kel'Thuzad",
            ID = 2422,
            Index = 9,
            Active = true,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Kel Thuzad Shadowlands.blp"),
            Hero = "Phase 4",
        },
        Sylvanas =
        {
            Name = "Sylvanas",
            ID = 2435,
            Index = 10,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Sylvanas Windrunner Shadowlands.blp"),
            Hero = "5 seconds + CD",
            Spell =
            {
                BansheeShroud = 350857,
            },
        },
    },
    Sepulcher =
    {
        Background = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-LOREBG-SepulcherOfTheFirstOnes"),
        Guardian =
        {
            Name = "Guardian",
            ID = 0,
            Index = 1,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-VigilantGuardian.blp"),
            Hero = "P3",
        },
        Skolex =
        {
            Name = "Skolex",
            ID = 0,
            Index = 6,
            Active = true,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Skolex.blp"),
            Hero = "Pull",
        },
        XyMox =
        {
            Name = "Xy'Mox",
            ID = 0,
            Index = 3,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-ArtificerXymox_Sepulcher.blp"),
            Hero = "P3",
        },
        Dausegne =
        {
            Name = "Dausegne",
            ID = 0,
            Index = 2,
            Active = "Soon",
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Dausegne.blp"),
            Hero = "Pull",
        },
        Pantheon =
        {
            Name = "Pantheon",
            ID = 0,
            Index = 4,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-PrototypePantheon.blp"),
            Hero = "P3",
        },
        Lihuvim =
        {
            Name = "Lihuvim",
            ID = 0,
            Index = 5,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Lihuvim.blp"),
            Hero = "Pull",
        },
        Halondrus =
        {
            Name = "Halondrus",
            ID = 0,
            Index = 7,
            Active = "Soon",
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Halondrus.blp"),
            Hero = "P3",
        },
        Anduin =
        {
            Name = "Anduin",
            ID = 0,
            Index = 8,
            Active = "Soon",
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-AnduinShadowlands.blp"),
            Hero = "P1.5",
        },
        LordsOfDread =
        {
            Name = "Lords Of Dread",
            ID = 0,
            Index = 9,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-LordsOfDread.blp"),
            Hero = "Undetermined",
        },
        Rygelon =
        {
            Name = "Rygelon",
            ID = 0,
            Index = 10,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Rygelon.blp"),
            Hero = "Pull",
        },
        TheJailer =
        {
            Name = "The Jailer",
            ID = 0,
            Index = 11,
            Active = false,
            FileID = GetFileIDFromPath("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Jailer.blp"),
            Hero = "Undetermined",
        },
    }
}