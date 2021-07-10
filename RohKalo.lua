if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

AZP.VersionControl["BossTools"] = 1
if AZP.BossTools == nil then AZP.BossTools = {} end
if AZP.BossTools.RohKalo == nil then AZP.BossTools.RohKalo = {} end
if AZP.BossTools.Events == nil then AZP.BossTools.Events = {} end

local AZPRTRohKaloAlphaFrame = nil
local AZPRTRohKaloBetaFrame = nil

function AZP.BossTools.RohKalo:OnLoad()
    AZPRTRohKaloAlphaFrame = CreateFrame("FRAME", nil, UIPanel, "BackdropTemplate")
    AZPRTRohKaloAlphaFrame:SetSize(300, 200)
    AZPRTRohKaloAlphaFrame:SetPoint("TOPLEFT", 100, -200)
    AZPRTRohKaloAlphaFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })

    AZPRTRohKaloAlphaFrame.Header = AZPRTRohKaloAlphaFrame:CreateFontString("AZPRTRohKaloAlphaFrame", "ARTWORK", "GameFontNormalHuge")
    AZPRTRohKaloAlphaFrame.Header:SetSize(AZPRTRohKaloAlphaFrame:GetWidth(), 25)
    AZPRTRohKaloAlphaFrame.Header:SetPoint("TOP", 0, -5)
    AZPRTRohKaloAlphaFrame.Header:SetText("Alpha XXX")

    AZPRTRohKaloAlphaFrame.HelpButton = CreateFrame("BUTTON", nil, AZPRTRohKaloAlphaFrame, "UIPanelButtonTemplate")
    AZPRTRohKaloAlphaFrame.HelpButton:SetSize(100, 20)
    AZPRTRohKaloAlphaFrame.HelpButton:SetPoint("TOPLEFT", 10, -30)
    AZPRTRohKaloAlphaFrame.HelpButton:SetText("I Need Help!")
    AZPRTRohKaloAlphaFrame.HelpButton:SetScript("OnClick", function()  end)

    AZPRTRohKaloAlphaFrame.SafeButton = CreateFrame("BUTTON", nil, AZPRTRohKaloAlphaFrame, "UIPanelButtonTemplate")
    AZPRTRohKaloAlphaFrame.SafeButton:SetSize(100, 20)
    AZPRTRohKaloAlphaFrame.SafeButton:SetPoint("LEFT", AZPRTRohKaloAlphaFrame.HelpButton, "RIGHT", 25, 0)
    AZPRTRohKaloAlphaFrame.SafeButton:SetText("I Can Solo!")
    AZPRTRohKaloAlphaFrame.SafeButton:SetScript("OnClick", function()  end)

    AZPRTRohKaloAlphaFrame.LeftLabel = AZPRTRohKaloAlphaFrame:CreateFontString("AZPRTRohKaloAlphaFrame", "ARTWORK", "GameFontNormal")
    AZPRTRohKaloAlphaFrame.LeftLabel:SetSize(100, 25)
    AZPRTRohKaloAlphaFrame.LeftLabel:SetPoint("TOP", AZPRTRohKaloAlphaFrame.HelpButton, "BOTTOM", 25, 0)
    AZPRTRohKaloAlphaFrame.LeftLabel:SetText("Alpha XXX")
    -- Something that makes it align to right

    AZPRTRohKaloAlphaFrame.RightLabel = AZPRTRohKaloAlphaFrame:CreateFontString("AZPRTRohKaloAlphaFrame", "ARTWORK", "GameFontNormal")
    AZPRTRohKaloAlphaFrame.RightLabel:SetSize(100, 25)
    AZPRTRohKaloAlphaFrame.RightLabel:SetPoint("TOP", AZPRTRohKaloAlphaFrame.SafeButton, "BOTTOM", 25, 0)
    AZPRTRohKaloAlphaFrame.RightLabel:SetText("Alpha XXX")
    -- Something that makes it align to left
end

AZP.BossTools.RohKalo:OnLoad()


--[[

    Order of the people based on raid#
    Should be the same for all individual AddOns, as th raid# does not change.

--]]