--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Bootstrap
    Loaded last. Wires the saved variables, the module lifecycle, the slash
    commands and the addon compartment entry together.
------------------------------------------------------------------------------]]

local ADDON_NAME, ns = ...

ns:RegisterEvent("ADDON_LOADED", function(_, loadedName)
    if loadedName ~= ADDON_NAME then
        return
    end
    ns:CallModules("OnInitialize")
end)

ns:RegisterEvent("PLAYER_LOGIN", function()
    ns:CallModules("OnLogin")
end)

--------------------------------------------------------------------------------
-- Slash commands
--------------------------------------------------------------------------------

local function PrintHelp()
    local L = ns.L
    ns:Print(L["HELP_HEADER"])
    for _, line in ipairs({ "HELP_OPTIONS", "HELP_MOVE", "HELP_RESET", "HELP_HELP" }) do
        DEFAULT_CHAT_FRAME:AddMessage("  " .. L[line])
    end
end

SLASH_ASSISTANTBUTTONVISUALIZER1 = "/abv"
SlashCmdList.ASSISTANTBUTTONVISUALIZER = function(input)
    local command = strtrim(input or ""):lower()
    if command == "" or command == "options" or command == "config" then
        ns.Options:Open()
    elseif command == "reset" then
        ns.Database:ResetPosition()
        ns:Print(ns.L["POSITION_RESET"])
    elseif command == "move" then
        ns.Mover:Toggle()
    elseif command == "install" and ns.Assist:GetSource() == "slot" then
        ns:Print(ns.L["FORCING_MANUAL"])
        ns.Assist:Install(true)
    else
        PrintHelp()
    end
end

--------------------------------------------------------------------------------
-- Addon compartment (minimap addons menu)
--------------------------------------------------------------------------------

function AssistantButtonVisualizer_OnAddonCompartmentClick()
    ns.Options:Open()
end
