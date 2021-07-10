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
    AZPRTRohKaloAlphaFrame:SetSize(175, 150)
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
    AZPRTRohKaloAlphaFrame.HelpButton:SetSize(75, 20)
    AZPRTRohKaloAlphaFrame.HelpButton:SetPoint("TOP", -40, -30)
    AZPRTRohKaloAlphaFrame.HelpButton:SetText("I Need Help!")
    AZPRTRohKaloAlphaFrame.HelpButton:SetScript("OnClick", function()  end)

    AZPRTRohKaloAlphaFrame.SafeButton = CreateFrame("BUTTON", nil, AZPRTRohKaloAlphaFrame, "UIPanelButtonTemplate")
    AZPRTRohKaloAlphaFrame.SafeButton:SetSize(75, 20)
    AZPRTRohKaloAlphaFrame.SafeButton:SetPoint("TOP", 40, -30)
    AZPRTRohKaloAlphaFrame.SafeButton:SetText("I Can Solo!")
    AZPRTRohKaloAlphaFrame.SafeButton:SetScript("OnClick", function()  end)

    AZPRTRohKaloAlphaFrame.LeftLabels = {}
    AZPRTRohKaloAlphaFrame.RightLabels = {}

    for i = 1, 6 do
        AZPRTRohKaloAlphaFrame.LeftLabels[i] = AZPRTRohKaloAlphaFrame:CreateFontString("AZPRTRohKaloAlphaFrame", "ARTWORK", "GameFontNormal")
        AZPRTRohKaloAlphaFrame.LeftLabels[i]:SetSize(100, 25)
        AZPRTRohKaloAlphaFrame.LeftLabels[i]:SetPoint("TOP", -55, ((i - 1) * -15) -50)
        AZPRTRohKaloAlphaFrame.LeftLabels[i]:SetText("Alpha" .. i)
        AZPRTRohKaloAlphaFrame.LeftLabels[i]:SetJustifyH("RIGHT")

        AZPRTRohKaloAlphaFrame.RightLabels[i] = AZPRTRohKaloAlphaFrame:CreateFontString("AZPRTRohKaloAlphaFrame", "ARTWORK", "GameFontNormal")
        AZPRTRohKaloAlphaFrame.RightLabels[i]:SetSize(100, 25)
        AZPRTRohKaloAlphaFrame.RightLabels[i]:SetPoint("TOP", 55, ((i - 1) * -15) -50)
        AZPRTRohKaloAlphaFrame.RightLabels[i]:SetText("Beta" .. i)
        AZPRTRohKaloAlphaFrame.RightLabels[i]:SetJustifyH("LEFT")
    end
end

AZP.BossTools.RohKalo:OnLoad()