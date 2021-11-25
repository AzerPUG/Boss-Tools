if AZP == nil then AZP = {} end
if AZP.BossTools.Test == nil then AZP.BossTools.Test = {} end
if AZP.BossTools.Test.Events == nil then AZP.BossTools.Test.Events = {} end

local AZPBTTestFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
local CompanionModel = nil

local tempCounter = 0

function AZP.BossTools.Test:OnLoad()
    AZPBTTestFrame:SetSize(250, 250)
    AZPBTTestFrame:SetPoint("CENTER", 0, 0)
    AZPBTTestFrame:EnableMouse(true)
    AZPBTTestFrame:SetMovable(true)
    AZPBTTestFrame:RegisterForDrag("LeftButton")
    AZPBTTestFrame:SetScript("OnDragStart", AZPBTTestFrame.StartMoving)
    AZPBTTestFrame:SetScript("OnDragStop", function() AZPBTTestFrame:StopMovingOrSizing() end)
    AZPBTTestFrame:SetScript("OnUpdate", function() AZP.BossTools.Test:Derp() end)
    AZPBTTestFrame:RegisterEvent("ADDON_LOADED")
    AZPBTTestFrame:SetScript("OnEvent", function(...) AZP.BossTools.Test:OnEvent(...) end)

    AZPBTTestFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    AZPBTTestFrame:SetBackdropColor(0.25, 0.25, 0.25, 0.80)

    AZPBTTestFrame.StringX = AZPBTTestFrame:CreateFontString("AZPBTTestFrame.StringX", "ARTWORK", "GameFontNormalHuge")
    AZPBTTestFrame.StringX:SetPoint("TOP", 0, 0)

    AZPBTTestFrame.StringY = AZPBTTestFrame:CreateFontString("AZPBTTestFrame.StringY", "ARTWORK", "GameFontNormalHuge")
    AZPBTTestFrame.StringY:SetPoint("TOP", 0, -20)

    AZPBTTestFrame.StringAr = AZPBTTestFrame:CreateFontString("AZPBTTestFrame.StringAr", "ARTWORK", "GameFontNormalHuge")
    AZPBTTestFrame.StringAr:SetPoint("TOP", 0, -40)

    AZPBTTestFrame.StringAd = AZPBTTestFrame:CreateFontString("AZPBTTestFrame.StringAd", "ARTWORK", "GameFontNormalHuge")
    AZPBTTestFrame.StringAd:SetPoint("TOP", 0, -60)
    
end

function AZP.BossTools.Test:Derp()
    local curX, curY, curFacing, otherX, otherY = AZP.BossTools.Test:GetPossitionsAndFacing()

    local roll, facing = AZP.BossTools.Test:CalculateAngles(curX, curY, curFacing, otherX, otherY)

    CompanionModel:SetRoll(roll)
    CompanionModel:SetFacing(0)
end

function AZP.BossTools.Test:GetPossitionsAndFacing()
    local curMap = C_Map.GetBestMapForUnit("PLAYER")
    local curPos = C_Map.GetPlayerMapPosition(curMap, "PLAYER")
    local curX, curY = curPos:GetXY()

    local otherMap = C_Map.GetBestMapForUnit("RAID2")
    local otherPos = C_Map.GetPlayerMapPosition(otherMap, "RAID2")
    local otherX, otherY = otherPos:GetXY()

    curX = curX * 100 - 50
    curY = 100 - curY * 100 - 50

    otherX = otherX * 100 - 50
    otherY = 100 - otherY * 100 - 50

    local facing = GetPlayerFacing()
    AZPBTTestFrame.StringX:SetText(string.format("CurX: %.2f     - OtherX: %.2f", curX, otherX))
    AZPBTTestFrame.StringY:SetText(string.format("CurY: %.2f     - OtherY: %.2f", curY, otherY))
    return curX, curY, facing, otherX, otherY
end

function AZP.BossTools.Test:CalculateAngles(curX, curY, curFacing, otherX, otherY)
    local deltaX, deltaY = otherX - curX, otherY - curY
    local roll = math.atan(deltaX / deltaY)

    roll = 0.5 * math.pi - roll
    if curY < otherY then roll = roll + math.pi end

    local facing = math.sqrt(deltaX * deltaX + deltaY * deltaY) / math.pi

    return roll - curFacing, facing
end

function AZP.BossTools.Test:OnEvent(...)
    local _, event, pl1, pl2, pl3, pl4, pl5, pl6 = ...
    if event == "ADDON_LOADED" then if pl1 == "AzerPUGsBossTools" then AZP.BossTools.Test.Events:AddonLoaded() end end
end

function AZP.BossTools.Test.Events:AddonLoaded()
    CompanionModel = CreateFrame("PlayerModel", nil, AZPBTTestFrame)
    CompanionModel:Hide()
    CompanionModel:SetSize(250, 250)
    CompanionModel:SetPosition(0, 0, 0)
    CompanionModel:SetPoint("CENTER", 0, 0)
    CompanionModel.x, CompanionModel.y, CompanionModel.z = 0, 0, 0
    CompanionModel:Show()
    CompanionModel:SetScale(1)
    CompanionModel:SetSequence(0)
    CompanionModel:SetPitch(-0.5 * math.pi)
    CompanionModel:SetModel(197089)

end

AZP.BossTools.Test:OnLoad()