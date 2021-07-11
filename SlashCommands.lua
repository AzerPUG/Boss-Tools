if AZP == nil then AZP = {} end
if AZP.SlashCommands == nil then 
    AZP.SlashCommands = {}
    SLASH_AZP1 = '/azp'
    SlashCmdList['AZP'] = function(arg)
        local fn = AZP.SlashCommands[arg]
        if type(fn) == "function" then
            fn()
        end
    end
end