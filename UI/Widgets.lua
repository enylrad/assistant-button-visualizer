--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Widgets
    Small factory of option widgets built from the client's own templates.
    Mainline clients (Retail, Forever) get the current settings widgets;
    Classic clients get the classic slider art and a self-drawn dropdown.

    Every widget with a value exposes :Refresh(), which reads it again.
    Texts given as locale keys follow the addon language.
------------------------------------------------------------------------------]]

local _, ns = ...

local Widgets = {}
ns.Widgets = Widgets
local L = ns.L

-- Templates every supported client ships, for clients that cannot be asked.
local UNIVERSAL_TEMPLATES = {
    UIPanelButtonTemplate = true,
    UICheckButtonTemplate = true,
}

--- Returns true when the running client defines an XML template.
function Widgets.HasTemplate(name)
    if C_XMLUtil and C_XMLUtil.GetTemplateInfo then
        return C_XMLUtil.GetTemplateInfo(name) ~= nil
    end
    return UNIVERSAL_TEMPLATES[name] == true
end

local BACKDROP_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil

--------------------------------------------------------------------------------
-- Localized texts
--------------------------------------------------------------------------------

-- Font strings whose text follows the active locale: { fontString, key }.
local localizedTexts = {}

function Widgets.SetLocalizedText(fontString, key)
    localizedTexts[#localizedTexts + 1] = { fontString, key }
    fontString:SetText(L[key])
end

--- Applies the active locale to every localized text.
function Widgets.RefreshTexts()
    for _, entry in ipairs(localizedTexts) do
        entry[1]:SetText(L[entry[2]])
    end
end

--------------------------------------------------------------------------------
-- Basic widgets
--------------------------------------------------------------------------------

function Widgets.CreateText(parent, template, key)
    local text = parent:CreateFontString(nil, "ARTWORK", template or "GameFontHighlight")
    text:SetJustifyH("LEFT")
    if key then
        Widgets.SetLocalizedText(text, key)
    end
    return text
end

function Widgets.CreateHeader(parent, key)
    local header = Widgets.CreateText(parent, "GameFontNormalLarge", key)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(1, 1, 1, 0.15)
    line:SetHeight(1)
    line:SetPoint("LEFT", header, "RIGHT", 8, 0)
    line:SetPoint("RIGHT", parent, "RIGHT", -16, 0)
    return header
end

function Widgets.CreateButton(parent, width, key, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 22)
    if key then
        Widgets.SetLocalizedText(button:GetFontString(), key)
    end
    button:SetScript("OnClick", onClick)
    return button
end

function Widgets.CreateCheckbox(parent, key, getValue, setValue)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetSize(26, 26)
    -- Template labels differ between clients; use our own and blank theirs.
    for _, field in ipairs({ "Text", "text" }) do
        if checkbox[field] and checkbox[field].SetText then
            checkbox[field]:SetText("")
        end
    end
    local label = Widgets.CreateText(checkbox, "GameFontHighlight", key)
    label:SetPoint("LEFT", checkbox, "RIGHT", 2, 1)
    checkbox:SetHitRectInsets(0, -240, 0, 0)

    checkbox:SetScript("OnClick", function(self)
        setValue(self:GetChecked() and true or false)
    end)
    checkbox.Refresh = function(self)
        self:SetChecked(getValue() and true or false)
    end
    return checkbox
end

--------------------------------------------------------------------------------
-- Slider
--------------------------------------------------------------------------------

--- Settings slider with stepper arrows (mainline clients).
local function CreateModernSlider(holder, minValue, maxValue, step, format, getValue, setValue)
    local mixin = MinimalSliderWithSteppersMixin
    if not (mixin and mixin.Event and mixin.Label and Widgets.HasTemplate("MinimalSliderWithSteppersTemplate")) then
        return false
    end
    local slider = CreateFrame("Frame", nil, holder, "MinimalSliderWithSteppersTemplate")
    slider:SetPoint("BOTTOMLEFT", 0, 0)
    slider:SetPoint("BOTTOMRIGHT", -44, 0)
    slider:SetHeight(20)

    local steps = math.max(1, math.floor((maxValue - minValue) / step + 0.5))
    local ok = pcall(slider.Init, slider, getValue(), minValue, maxValue, steps, {
        [mixin.Label.Right] = format,
    })
    if not ok then
        slider:Hide()
        return false
    end

    local updating = false
    slider:RegisterCallback(mixin.Event.OnValueChanged, function(_, value)
        if not updating then
            setValue(ns.Round(ns.Round(value / step) * step, 2))
        end
    end, holder)

    holder.Refresh = function()
        updating = true
        slider:SetValue(getValue())
        updating = false
    end
    return true
end

local SLIDER_BACKDROP = {
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 3, right = 3, top = 6, bottom = 6 },
}

--- Slider with the classic options slider art (every client).
local function CreateClassicSlider(holder, minValue, maxValue, step, format, getValue, setValue)
    local value = Widgets.CreateText(holder, "GameFontHighlight")
    value:SetPoint("TOPRIGHT", -44, 0)
    value:SetJustifyH("RIGHT")

    local slider = CreateFrame("Slider", nil, holder, BACKDROP_TEMPLATE)
    slider:SetOrientation("HORIZONTAL")
    slider:SetHeight(17)
    slider:SetPoint("BOTTOMLEFT", 0, 2)
    slider:SetPoint("BOTTOMRIGHT", -44, 2)
    if slider.SetBackdrop then
        slider:SetBackdrop(SLIDER_BACKDROP)
    end
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    if slider.SetObeyStepOnDrag then
        slider:SetObeyStepOnDrag(true)
    end

    local updating = false
    slider:SetScript("OnValueChanged", function(_, raw)
        local rounded = ns.Round(ns.Round(raw / step) * step, 2)
        value:SetText(format(rounded))
        if not updating then
            setValue(rounded)
        end
    end)
    slider:EnableMouseWheel(true)
    slider:SetScript("OnMouseWheel", function(self, delta)
        self:SetValue(ns.Clamp(self:GetValue() + delta * step, minValue, maxValue))
    end)

    holder.Refresh = function()
        updating = true
        slider:SetValue(getValue())
        updating = false
        value:SetText(format(getValue()))
    end
    return true
end

--- Creates a captioned slider. `format` turns a value into its label.
function Widgets.CreateSlider(parent, key, minValue, maxValue, step, format, getValue, setValue)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(260, 40)
    local caption = Widgets.CreateText(holder, "GameFontNormal", key)
    caption:SetPoint("TOPLEFT")
    if not CreateModernSlider(holder, minValue, maxValue, step, format, getValue, setValue) then
        CreateClassicSlider(holder, minValue, maxValue, step, format, getValue, setValue)
    end
    return holder
end

--------------------------------------------------------------------------------
-- Dropdown
--------------------------------------------------------------------------------

--- Dropdown of the current menu system (mainline clients).
local function CreateModernDropdown(parent, width, buildOptions, getValue, setValue)
    if not Widgets.HasTemplate("WowStyle1DropdownTemplate") then
        return nil
    end
    local ok, dropdown = pcall(CreateFrame, "DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
    if not (ok and dropdown and dropdown.SetupMenu) then
        return nil
    end
    dropdown:SetWidth(width)
    dropdown:SetupMenu(function(_, root)
        if root.SetScrollMode then
            root:SetScrollMode(380)
        end
        for _, option in ipairs(buildOptions()) do
            root:CreateRadio(option.label,
                function(value) return getValue() == value end,
                function(value) setValue(value) end,
                option.value)
        end
    end)
    dropdown.Refresh = function(self)
        if self.placeholderKey and self.SetDefaultText then
            self:SetDefaultText(L[self.placeholderKey])
        end
        self:GenerateMenu()
    end
    return dropdown
end

local MENU_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}
local ITEM_HEIGHT = 18

--- Self-drawn dropdown built from a button and a list (every client).
local function CreateClassicDropdown(parent, width, buildOptions, getValue, setValue)
    local dropdown = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    dropdown:SetSize(width, 22)
    local text = dropdown:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("LEFT", 8, 0)
    text:SetPoint("RIGHT", -18, 0)
    text:SetJustifyH("LEFT")
    local arrow = dropdown:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    arrow:SetPoint("RIGHT", -6, 0)
    arrow:SetText("v")

    local menu = CreateFrame("Frame", nil, dropdown, BACKDROP_TEMPLATE)
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -2)
    menu:SetWidth(width)
    if menu.SetBackdrop then
        menu:SetBackdrop(MENU_BACKDROP)
        menu:SetBackdropColor(0, 0, 0, 0.95)
    end
    menu:EnableMouse(true)
    menu:Hide()
    menu.items = {}

    dropdown.Refresh = function()
        local current = getValue()
        for _, option in ipairs(buildOptions()) do
            if option.value == current then
                dropdown:SetText(option.label)
                return
            end
        end
        if current == nil and dropdown.placeholderKey then
            dropdown:SetText(L[dropdown.placeholderKey])
        else
            dropdown:SetText(tostring(current or ""))
        end
    end

    local function Open()
        local options = buildOptions()
        local current = getValue()
        for i, option in ipairs(options) do
            local item = menu.items[i]
            if not item then
                item = CreateFrame("Button", nil, menu)
                item:SetHeight(ITEM_HEIGHT)
                item:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
                item.text = item:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
                item.text:SetPoint("LEFT", 8, 0)
                item.text:SetPoint("RIGHT", -8, 0)
                item.text:SetJustifyH("LEFT")
                menu.items[i] = item
            end
            item:SetPoint("TOPLEFT", 4, -6 - (i - 1) * ITEM_HEIGHT)
            item:SetPoint("TOPRIGHT", -4, -6 - (i - 1) * ITEM_HEIGHT)
            item.text:SetText(option.label)
            if option.value == current then
                item.text:SetTextColor(1, 0.82, 0)
            else
                item.text:SetTextColor(1, 1, 1)
            end
            item:SetScript("OnClick", function()
                menu:Hide()
                setValue(option.value)
                dropdown:Refresh()
            end)
            item:Show()
        end
        for i = #options + 1, #menu.items do
            menu.items[i]:Hide()
        end
        menu:SetHeight(#options * ITEM_HEIGHT + 12)
        menu:Show()
    end

    dropdown:SetScript("OnClick", function()
        if menu:IsShown() then
            menu:Hide()
        else
            Open()
        end
    end)
    dropdown:HookScript("OnHide", function()
        menu:Hide()
    end)
    return dropdown
end

--- Text shown by a dropdown while nothing is selected (a locale key).
function Widgets.SetPlaceholder(dropdown, key)
    dropdown.placeholderKey = key
    if dropdown.SetDefaultText then
        dropdown:SetDefaultText(L[key])
    end
end

--- Creates a dropdown. `buildOptions` returns a list of { value, label } and
--- is evaluated every time the menu is opened or refreshed.
function Widgets.CreateDropdown(parent, width, buildOptions, getValue, setValue)
    return CreateModernDropdown(parent, width, buildOptions, getValue, setValue)
        or CreateClassicDropdown(parent, width, buildOptions, getValue, setValue)
end

--------------------------------------------------------------------------------
-- Settings registration
--------------------------------------------------------------------------------

--- Adds a panel to the game's AddOns settings. Returns the category, if any.
function Widgets.RegisterPanel(panel, title)
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, title)
        Settings.RegisterAddOnCategory(category)
        return category
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
    return nil
end

--- Opens the game settings on a registered panel.
function Widgets.OpenPanel(panel, category)
    if category and Settings and Settings.OpenToCategory then
        local id = category.GetID and category:GetID() or category.ID
        Settings.OpenToCategory(id)
    elseif InterfaceOptionsFrame_OpenToCategory then
        -- Called twice: the first call may only open the frame.
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    end
end
