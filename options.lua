-- ============================================================================
-- OPTIONS PANEL
-- ============================================================================

local ADDON_NAME = "AssistantButton"
local PANEL_NAME = "AssistantButtonOptions"

-- Function to create the options panel
local function CreateOptionsPanel()
    -- Create a frame for the options panel
    local panel = CreateFrame("Frame", PANEL_NAME)
    panel.name = "AssistantButton" -- This name appears in the Addon list
    
    -- Title
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Assistant Button Visualizer")

    -- Description
    local description = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    description:SetText("Configure the Assistant Button visualizer settings.")

    -- Lock Position Checkbox
    local lockButton = CreateFrame("CheckButton", "AssistantButton_LockPosition", panel, "InterfaceOptionsCheckButtonTemplate")
    lockButton:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -16)
    lockButton.Text:SetText("Lock Position")
    lockButton.tooltipText = "Lock the button frame to prevent accidental movement."
    
    -- OnShow handler to update the checkbox state from SavedVariables
    lockButton:SetScript("OnShow", function(self)
        self:SetChecked(AssistantButtonVisualizerDB.locked)
    end)

    -- OnClick handler to save the setting and apply changes
    lockButton:SetScript("OnClick", function(self)
        local isLocked = self:GetChecked()
        AssistantButtonVisualizerDB.locked = isLocked
        
        -- Call the global function defined in core.lua to apply the lock
        if AssistantButton_SetLock then
            AssistantButton_SetLock(isLocked)
        end
    end)
    
    -- Register the panel with the standard Interface Options
    if Settings and Settings.RegisterCanvasLayoutCategory then
        -- Dragonflight and later (10.0+)
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
    else
        -- Fallback for older clients (though TOC says 11.0, good to be safe)
        InterfaceOptions_AddCategory(panel)
    end
end

-- Create the panel when the addon loads (or simply run it now since files assume loaded in order)
CreateOptionsPanel()
