local EventFrame = CreateFrame("FRAME", nil)
EventFrame:RegisterEvent("VARIABLES_LOADED")
EventFrame:SetScript("OnEvent", function(...) HotFTestOnEvent(...) end)

local testFrame, InnerModelFrame = nil, nil

function HotFTestLoadVariables()
    local xMid, yMid = 50, 50

    testFrame = CreateFrame("Frame", nil, UIParent, "BackDropTemplate")
    testFrame:SetSize(250, 250)
    testFrame:SetPoint("Center", 300, 0)

    testFrame.arrow = testFrame:CreateTexture(nil, "OVERLAY")
    testFrame.arrow:SetTexture("Interface\\Addons\\AzerPUGsBossTools\\Arrow")
    testFrame.arrow:SetAllPoints()

    -- testFrame:RegisterForDrag("LeftButton")
    -- testFrame:SetScript("OnDragStart", function() testFrame:StartMoving() end)
    -- testFrame:SetScript("OnDragStop", function() testFrame:StopMovingOrSizing() end)

    -- InnerModelFrame = CreateFrame("PlayerModel", nil, testFrame)
    -- InnerModelFrame:Hide()
    -- InnerModelFrame:SetSize(200, 200)
    -- InnerModelFrame:SetPosition(-2, 0, 0)
    -- InnerModelFrame:SetPoint("CENTER", 0, 0)
    -- InnerModelFrame.x, InnerModelFrame.y, InnerModelFrame.z = 0, 0, 0
    -- InnerModelFrame:Show()
    -- InnerModelFrame:SetScale(2)
    -- InnerModelFrame:SetModel(903797)
end

function HotFTestOnEvent(self, event, ...)
    if event == "VARIABLES_LOADED" then
        C_Timer.After(5, function() HotFTestLoadVariables() end)
    end
end