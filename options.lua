-- ============================================================================
-- OPTIONS PANEL
-- ============================================================================

local ADDON_NAME = "AssistantButtonVisualizer"
local PANEL_NAME = "AssistantButtonVisualizerOptions"
local ABV_PREFIX = "|cff00ff00ABV:|r"

-- Function to create the options panel
local function CreateOptionsPanel()
    -- Create a frame for the options panel
    local panel = CreateFrame("Frame", PANEL_NAME)
    panel.name = "Assistant Button Visualizer" -- This name appears in the Addon list
    
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

    -- Visibility Mode Label
    local visibilityLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    visibilityLabel:SetPoint("TOPLEFT", lockButton, "BOTTOMLEFT", 0, -20)
    visibilityLabel:SetText("Visibility Mode")

    -- Visibility Mode Cycle Button
    local visibilityBtn = CreateFrame("Button", "AssistantButton_VisibilityBtn", panel, "UIMenuButtonStretchTemplate")
    visibilityBtn:SetPoint("LEFT", visibilityLabel, "RIGHT", 20, 0)
    visibilityBtn:SetSize(120, 24)
    visibilityBtn:SetText(AssistantButtonVisualizerDB and AssistantButtonVisualizerDB.visibility == "COMBAT" and "In Combat" or "Always")

    -- Function to update button text based on DB
    local function UpdateVisibilityButtonText()
        if AssistantButtonVisualizerDB.visibility == "COMBAT" then
            visibilityBtn:SetText("In Combat")
        else
            visibilityBtn:SetText("Always")
        end
    end

    visibilityBtn:SetScript("OnShow", function(self)
         -- Ensure DB is loaded (though it should be by the time options are opened)
        if not AssistantButtonVisualizerDB.visibility then AssistantButtonVisualizerDB.visibility = "ALWAYS" end
        UpdateVisibilityButtonText()
    end)

    visibilityBtn:SetScript("OnClick", function(self)
        if AssistantButtonVisualizerDB.visibility == "ALWAYS" then
            AssistantButtonVisualizerDB.visibility = "COMBAT"
        else
            AssistantButtonVisualizerDB.visibility = "ALWAYS"
        end
        UpdateVisibilityButtonText()
        
        -- Force Show the main frame to restart its OnUpdate loop 
        -- so it can re-evaluate visibility immediately.
        if ABV_MainFrame then ABV_MainFrame:Show() end
        
        print(ABV_PREFIX .. " Visibility set to: " .. AssistantButtonVisualizerDB.visibility)
    end)
    


    -- Opacity Slider
    local opacityLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    opacityLabel:SetPoint("TOPLEFT", visibilityLabel, "BOTTOMLEFT", 0, -40)
    opacityLabel:SetText("Opacity")

    local slider = CreateFrame("Slider", "AssistantButton_OpacitySlider", panel, "OptionsSliderTemplate")
    slider:SetPoint("LEFT", opacityLabel, "RIGHT", 20, 0)
    slider:SetWidth(200)
    slider:SetHeight(20)
    slider:SetMinMaxValues(0.1, 1.0)
    slider:SetValueStep(0.1)
    slider:SetObeyStepOnDrag(true)
    
    _G[slider:GetName() .. "Low"]:SetText("0.1")
    _G[slider:GetName() .. "High"]:SetText("1.0")
    
    local valueLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    valueLabel:SetPoint("LEFT", slider, "RIGHT", 10, 0)
    slider.ValueLabel = valueLabel

    slider:SetScript("OnShow", function(self)
        local val = AssistantButtonVisualizerDB.alpha or 0.3
        self:SetValue(val)
        if self.ValueLabel then
            self.ValueLabel:SetText(string.format("%d%%", val * 100))
        end
    end)
    
    slider:SetScript("OnValueChanged", function(self, value)
        -- Round to 1 decimal place to avoid floating point weirdness
        value = math.floor(value * 10 + 0.5) / 10
        if AssistantButton_SetAlpha then
            AssistantButton_SetAlpha(value)
        end
        if self.ValueLabel then
            self.ValueLabel:SetText(string.format("%d%%", value * 100))
        end
    end)

    -- Icon Size Slider
    local sizeLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    sizeLabel:SetPoint("TOPLEFT", opacityLabel, "BOTTOMLEFT", 0, -40)
    sizeLabel:SetText("Icon Size")

    local sizeSlider = CreateFrame("Slider", "AssistantButton_SizeSlider", panel, "OptionsSliderTemplate")
    sizeSlider:SetPoint("LEFT", sizeLabel, "RIGHT", 20, 0)
    sizeSlider:SetWidth(200)
    sizeSlider:SetHeight(20)
    sizeSlider:SetMinMaxValues(16, 128)
    sizeSlider:SetValueStep(1)
    sizeSlider:SetObeyStepOnDrag(true)

    _G[sizeSlider:GetName() .. "Low"]:SetText("16")
    _G[sizeSlider:GetName() .. "High"]:SetText("128")

    local sizeValueLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    sizeValueLabel:SetPoint("LEFT", sizeSlider, "RIGHT", 10, 0)
    sizeSlider.ValueLabel = sizeValueLabel

    sizeSlider:SetScript("OnShow", function(self)
        local val = AssistantButtonVisualizerDB.size or 64
        self:SetValue(val)
        if self.ValueLabel then
            self.ValueLabel:SetText(tostring(val))
        end
    end)

    sizeSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        if AssistantButton_SetSize then
            AssistantButton_SetSize(value)
        end
        if self.ValueLabel then
            self.ValueLabel:SetText(tostring(value))
        end
    end)

    -- Action Slot Slider
    local slotLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    slotLabel:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 0, -40)
    slotLabel:SetText("Action Slot")

    local slotSlider = CreateFrame("Slider", "AssistantButton_SlotSlider", panel, "OptionsSliderTemplate")
    slotSlider:SetPoint("LEFT", slotLabel, "RIGHT", 20, 0)
    slotSlider:SetWidth(200)
    slotSlider:SetHeight(20)
    slotSlider:SetMinMaxValues(1, 120)
    slotSlider:SetValueStep(1)
    slotSlider:SetObeyStepOnDrag(true)
    slotSlider.tooltipText = "Select the action slot (1-120) where the ability will be placed.\nCommon slots:\nBar 1: 1-12\nBar 2: 13-24\nBar 3: 25-36\nBar 4: 37-48\nBar 5: 49-60\nBar 6: 61-72"
    
    _G[slotSlider:GetName() .. "Low"]:SetText("1")
    _G[slotSlider:GetName() .. "High"]:SetText("120")
    
    local slotValueLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    slotValueLabel:SetPoint("LEFT", slotSlider, "RIGHT", 10, 0)
    slotSlider.ValueLabel = slotValueLabel


    slotSlider:SetScript("OnShow", function(self)
        local val = AssistantButtonVisualizerDB.slot or 88
        self:SetValue(val)
        if self.ValueLabel then
            self.ValueLabel:SetText(tostring(val))
        end
    end)
    
    slotSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        if self.ValueLabel then
            self.ValueLabel:SetText(tostring(value))
        end
        
        -- Update Apply button state
        local currentSaved = AssistantButtonVisualizerDB.slot or 88
        if value ~= currentSaved then
            if panel.applyBtn then panel.applyBtn:Enable() end
        else
            if panel.applyBtn then panel.applyBtn:Disable() end
        end
    end)

    -- Apply Button
    local applyBtn = CreateFrame("Button", "AssistantButton_SlotApplyBtn", panel, "UIPanelButtonTemplate")
    applyBtn:SetPoint("TOPLEFT", slotSlider, "BOTTOMLEFT", 0, -10)
    applyBtn:SetSize(80, 22)
    applyBtn:SetText("Apply")
    applyBtn:Disable()
    panel.applyBtn = applyBtn

    applyBtn:SetScript("OnClick", function(self)
        local value = math.floor(slotSlider:GetValue() + 0.5)
        if AssistantButton_SetSlot then
            AssistantButton_SetSlot(value)
            print(ABV_PREFIX .. " Applied new slot: " .. value)
        end
        self:Disable()
    end)

    -- Help description for slots
    local slotHelp = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    slotHelp:SetPoint("TOPLEFT", applyBtn, "BOTTOMLEFT", 0, -16)
    slotHelp:SetWidth(400)
    slotHelp:SetJustifyH("LEFT")
    slotHelp:SetText("Standard bars use 1-120. We recommend using a high slot (like 80+) that isn't on your visible bars to avoid overwriting your icons.")

    
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
