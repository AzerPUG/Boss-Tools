if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Sepulcher.Pantheon == nil then AZP.BossTools.Sepulcher.Pantheon = {} end
if AZP.BossTools.Sepulcher.Pantheon.Events == nil then AZP.BossTools.Sepulcher.Pantheon.Events = {} end

local EventFrame = nil
local BossHealthTicker = nil
local CurrentBoss = ""

function AZP.BossTools.Sepulcher.Pantheon:OnLoadSelf()
    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("ENCOUNTER_START")
    EventFrame:RegisterEvent("ENCOUNTER_END")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Sepulcher.Pantheon:OnEvent(...) end)
end



function AZP.BossTools.Sepulcher.Pantheon:OnEvent(self, event, ...)
    if event == "ENCOUNTER_END" then
        AZP.BossTools.Sepulcher.Pantheon.Events:EncounterEnd(...)
    elseif event == "ENCOUNTER_START" then
        AZP.BossTools.Sepulcher.Pantheon.Events:EncounterStart(...)
    end
end

function AZP.BossTools.Sepulcher.Pantheon.Events:EncounterEnd(...)
    if BossHealthTicker ~= nil then
        BossHealthTicker:Cancel()
        BossHealthTicker = nil
    end
end

function AZP.BossTools.Sepulcher.Pantheon.Events:EncounterStart(encounterID, encounterName, difficultyID, groupSize)
    if encounterID == 2544 then
        local unitRole = UnitGroupRolesAssigned("player")
        local _, _, _, _, isHeroic = GetDifficultyInfo(GetRaidDifficultyID())
        if unitRole == "DAMAGER" and isHeroic == true then
            BossHealthTicker = C_Timer.NewTicker(5, function() AZP.BossTools.Sepulcher.Pantheon:TrackHealth() end)
        end
    end
end

function AZP.BossTools.Sepulcher.Pantheon:TrackHealth()
    local lowestHealth = nil
    local highestHealth = nil
    for bossNum=1,4 do
        local bossId = string.format("boss%d", bossNum)
        local health = UnitHealth(bossId)
        local maxHealth = UnitHealthMax(bossId)

        if maxHealth == 0 then
            return --n'th boss doesn't exist. Ignore current phase.
        end

        local percent = health / maxHealth * 100

        if lowestHealth == nil then
            lowestHealth =  {Boss = bossId, Health = percent }
        end
        if percent < lowestHealth.Health then
            lowestHealth = {Boss = bossId, Health = percent }
        end

        if highestHealth == nil then
            highestHealth =  {Boss = bossId, Health = percent }
        end
        if percent > highestHealth.Health then
            highestHealth = {Boss = bossId, Health = percent }
        end
    end

    local lowestHealthPercent = lowestHealth.Health
    local highestHealthPercent = highestHealth.Health

    local threshold = lowestHealthPercent / 10

    if highestHealthPercent - lowestHealthPercent > threshold then
        if(CurrentBoss ~= highestHealth.Boss) then
            CurrentBoss = highestHealth.Boss
            AZP.BossTools:WarnPlayer(UnitName(highestHealth.Boss))
        end
    end
end

AZP.BossTools.Sepulcher.Pantheon:OnLoadSelf()