if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Sepulcher.Pantheon == nil then AZP.BossTools.Sepulcher.Pantheon = {} end
if AZP.BossTools.Sepulcher.Pantheon.Events == nil then AZP.BossTools.Sepulcher.Pantheon.Events = {} end

local EventFrame = nil
local BossHealthTicker = nil
local CurrentBoss = ""
local ReconstructionCastCount = 0

function AZP.BossTools.Sepulcher.Pantheon:OnLoadSelf()
    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    EventFrame:RegisterEvent("ENCOUNTER_END")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Sepulcher.Pantheon:OnEvent(...) end)
end



function AZP.BossTools.Sepulcher.Pantheon:OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        AZP.BossTools.Sepulcher.Pantheon.Events:CombatLogEventUnfiltered(...)
    elseif event == "ENCOUNTER_END" then
        AZP.BossTools.Sepulcher.Pantheon.Events:EncounterEnd(...)
    end
end

function AZP.BossTools.Sepulcher.Pantheon.Events:EncounterEnd(...)
    if BossHealthTicker ~= nil then
        BossHealthTicker:Cancel()
        BossHealthTicker = nil
    end
    ReconstructionCastCount = 0
end

function AZP.BossTools.Sepulcher.Pantheon:TrackHealth()
    local lowestHealth = nil
    local highestHealth = nil
    for bossNum = 1, 4 do
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

function AZP.BossTools.Sepulcher.Pantheon.Events:CombatLogEventUnfiltered(...)
    local _, SubEvent, _, _, _, _, _, _, _, _, _, SpellID = CombatLogGetCurrentEventInfo()
    if SpellID == AZP.BossTools.IDs.Sepulcher.Pantheon.Reconstruction then
        if SubEvent == "SPELL_CAST_SUCCESS" then
            ReconstructionCastCount = ReconstructionCastCount + 1
            if ReconstructionCastCount == 8 then
                local unitRole = UnitGroupRolesAssigned("player")
                local _, _, _, _, isHeroic = GetDifficultyInfo(GetRaidDifficultyID())
                if unitRole == "DAMAGER" and isHeroic == true then
                    BossHealthTicker = C_Timer.NewTicker(5, function() AZP.BossTools.Sepulcher.Pantheon:TrackHealth() end)
                end
            end
        end
    end
end

AZP.BossTools.Sepulcher.Pantheon:OnLoadSelf()
