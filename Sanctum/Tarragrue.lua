if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

if AZP.BossTools.Sanctum.Tarragrue == nil then AZP.BossTools.Sanctum.Tarragrue = {} end
if AZP.BossTools.Sanctum.Tarragrue.Events == nil then AZP.BossTools.Sanctum.Tarragrue.Events = {} end

local AZPBTTarragrueOptions = nil

local EventFrame = nil

function AZP.BossTools.Sanctum.Tarragrue:OnLoadSelf()
    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("PLAYER_CHOICE_UPDATE")
    EventFrame:RegisterEvent("CHAT_MSG_LOOT")
    EventFrame:SetScript("OnEvent", function(...) AZP.BossTools.Sanctum.Tarragrue:OnEvent(...) end)

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

function AZP.BossTools.Sanctum.Tarragrue:OnEvent(_, event, ...)
    if event == "ADDON_LOADED" then
    elseif event == "CHAT_MSG_LOOT" then
        local chatText, playerName = ...
        chatText = string.gsub(chatText, "|", "-")
        local loc = string.find(chatText, ":")
        chatText = string.sub(chatText, loc + 1, #chatText)
        loc = string.find(chatText, ":")
        chatText = string.sub(chatText, loc + 1, loc + 4)
        chatText = tonumber(chatText)
        local powerTaken = nil
        if AZP.BossTools.MawPowers[chatText] ~= nil then powerTaken = GetSpellLink(AZP.BossTools.MawPowers[chatText]) end
        local unitName, unitServer = UnitFullName("PLAYER")
        local unitNameServer = string.format("%s-%s", unitName, unitServer)
        local PreppedChatMsg = "I am a number whore and purposely took %s, even though it was clearly banned! Please remove me from your raid! I deserve it!"
        if powerTaken ~= nul then if playerName == unitNameServer then SendChatMessage(string.format(PreppedChatMsg, powerTaken), "RAID") end end

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
    end
end

AZP.BossTools.Sanctum.Tarragrue:OnLoadSelf()