--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Options panel
    Registered in the game's AddOns settings. Sections: profile, visibility,
    appearance, position and language.

    Built from the factory in UI\Widgets.lua, so it works with the templates
    of every supported client.
------------------------------------------------------------------------------]]

local _, ns = ...

local Options = ns:NewModule("Options")
local Database = ns.Database
local Mover = ns.Mover
local Widgets = ns.Widgets
local L = ns.L

local CONTENT_WIDTH = 580
local COLUMN = 300          -- x offset of the second column
local LINE = 28             -- height of a checkbox row

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function Notify()
    ns:SendMessage("ABV_SETTINGS_CHANGED")
end

--- Getter and setter of a profile setting.
local function ProfileValue(key)
    return function() return ns.settings[key] end,
        function(value) ns.settings[key] = value; Notify() end
end

local function ListOptions(values, prefix)
    return function()
        local options = {}
        for _, value in ipairs(values) do
            options[#options + 1] = { value = value, label = L[prefix .. value] }
        end
        return options
    end
end

local function LocaleOptions()
    local options = {}
    for _, code in ipairs(ns.AVAILABLE_LOCALES) do
        options[#options + 1] = { value = code, label = L["LOCALE_" .. code] }
    end
    return options
end

local function OtherProfileOptions()
    local options = {}
    for _, name in ipairs(Database:GetProfileNames()) do
        if name ~= Database.activeProfile then
            options[#options + 1] = { value = name, label = name }
        end
    end
    return options
end

local function Percent(value)
    return ("%d%%"):format(ns.Round(value * 100))
end

local function Seconds(value)
    return ("%.1f s"):format(value)
end

--------------------------------------------------------------------------------
-- Panel
--------------------------------------------------------------------------------

function Options:BuildPanel(panel)
    local widgets = {}
    self.widgets = widgets

    local scrollTemplate = Widgets.HasTemplate("ScrollFrameTemplate") and "ScrollFrameTemplate" or "UIPanelScrollFrameTemplate"
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, scrollTemplate)
    scrollFrame:SetPoint("TOPLEFT", 0, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", -26, 4)
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(CONTENT_WIDTH + 32, 900)
    scrollFrame:SetScrollChild(content)

    local x = 16
    local y = -12

    local title = Widgets.CreateText(content, "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", x, y)
    title:SetText(ns.coloredTitle)
    local version = Widgets.CreateText(content, "GameFontDisable")
    version:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 8, 2)
    version:SetText("v" .. (ns.Compat.GetAddOnMetadata("Version") or "?"))

    local subtitle = Widgets.CreateText(content, "GameFontHighlightSmall", "OPTIONS_SUBTITLE")
    subtitle:SetPoint("TOPLEFT", x, y - 30)
    subtitle:SetWidth(CONTENT_WIDTH)
    subtitle:SetWordWrap(true)
    y = y - 70

    local function Header(key)
        local header = Widgets.CreateHeader(content, key)
        header:SetPoint("TOPLEFT", x, y)
        y = y - 28
    end

    local function Caption(key, offset)
        local caption = Widgets.CreateText(content, "GameFontNormal", key)
        caption:SetPoint("TOPLEFT", x + (offset or 0), y)
        return caption
    end

    local function Checkbox(name, key, offset)
        local getValue, setValue = ProfileValue(name)
        local checkbox = Widgets.CreateCheckbox(content, key, getValue, setValue)
        checkbox:SetPoint("TOPLEFT", x - 4 + (offset or 0), y)
        widgets[name] = checkbox
        return checkbox
    end

    ------------------------------------------------------------------ Profile
    Header("SECTION_PROFILE")
    Caption("OPT_PROFILE_MODE")
    Caption("OPT_PROFILE_COPY", COLUMN)
    y = y - 18
    widgets.mode = Widgets.CreateDropdown(content, 220, ListOptions(Database.MODES, "PROFILE_MODE_"),
        function() return Database:GetMode() end,
        function(value) Database:SetMode(value) end)
    widgets.mode:SetPoint("TOPLEFT", x, y)
    widgets.copy = Widgets.CreateDropdown(content, 220, OtherProfileOptions,
        function() return nil end,
        function(value)
            Database:CopyFrom(value)
            ns:Print(L["PROFILE_COPIED"], value)
        end)
    widgets.copy:SetPoint("TOPLEFT", x + COLUMN, y)
    Widgets.SetPlaceholder(widgets.copy, "OPT_PROFILE_COPY_PICK")
    y = y - 32
    widgets.activeProfile = Widgets.CreateText(content, "GameFontHighlightSmall")
    widgets.activeProfile:SetPoint("TOPLEFT", x, y - 4)
    widgets.resetProfile = Widgets.CreateButton(content, 180, "OPT_PROFILE_RESET", function()
        Database:ResetProfile()
        ns:Print(L["PROFILE_RESET_DONE"])
    end)
    widgets.resetProfile:SetPoint("TOPLEFT", x + COLUMN, y)
    y = y - 40

    ------------------------------------------------------------------ Visibility
    Header("SECTION_VISIBILITY")
    Caption("OPT_VISIBILITY")
    y = y - 18
    widgets.visibility = Widgets.CreateDropdown(content, 220, ListOptions(Database.VISIBILITY_MODES, "VISIBILITY_"),
        ProfileValue("visibility"))
    widgets.visibility:SetPoint("TOPLEFT", x, y)
    Checkbox("hideMounted", "OPT_HIDE_MOUNTED", COLUMN)
    y = y - LINE
    Checkbox("hideWithoutSuggestion", "OPT_HIDE_EMPTY", COLUMN)
    y = y - LINE - 12

    ------------------------------------------------------------------ Appearance
    Header("SECTION_APPEARANCE")
    widgets.size = Widgets.CreateSlider(content, "OPT_SIZE", Database.MIN_SIZE, Database.MAX_SIZE, 1,
        function(value) return tostring(ns.Round(value)) end, ProfileValue("size"))
    widgets.size:SetPoint("TOPLEFT", x, y)
    widgets.fade = Widgets.CreateSlider(content, "OPT_FADE", 0, Database.MAX_FADE, 0.1, Seconds, ProfileValue("fade"))
    widgets.fade:SetPoint("TOPLEFT", x + COLUMN, y)
    y = y - 52
    widgets.alphaCombat = Widgets.CreateSlider(content, "OPT_ALPHA_COMBAT", 0.1, 1, 0.05, Percent, ProfileValue("alphaCombat"))
    widgets.alphaCombat:SetPoint("TOPLEFT", x, y)
    widgets.alphaOutOfCombat = Widgets.CreateSlider(content, "OPT_ALPHA_OOC", 0, 1, 0.05, Percent, ProfileValue("alphaOutOfCombat"))
    widgets.alphaOutOfCombat:SetPoint("TOPLEFT", x + COLUMN, y)
    y = y - 56
    Caption("OPT_BORDER")
    y = y - 18
    widgets.border = Widgets.CreateDropdown(content, 220, ListOptions(Database.BORDERS, "BORDER_"), ProfileValue("border"))
    widgets.border:SetPoint("TOPLEFT", x, y)
    Checkbox("cropIcon", "OPT_CROP", COLUMN)
    y = y - LINE
    Checkbox("glow", "OPT_GLOW", COLUMN)
    y = y - LINE
    Checkbox("colorByState", "OPT_COLOR_BY_STATE", COLUMN)
    y = y - LINE - 12

    ------------------------------------------------------------------ Position
    Header("SECTION_POSITION")
    Checkbox("locked", "OPT_LOCK")
    y = y - LINE - 4
    widgets.move = Widgets.CreateButton(content, 180, nil, function()
        Mover:Toggle()
    end)
    widgets.move:SetPoint("TOPLEFT", x, y)
    widgets.center = Widgets.CreateButton(content, 180, "OPT_RESET_POSITION", function()
        Database:ResetPosition()
        ns:Print(L["POSITION_RESET"])
    end)
    widgets.center:SetPoint("LEFT", widgets.move, "RIGHT", 10, 0)
    y = y - 28
    if Mover:HasEditMode() then
        local editModeHelp = Widgets.CreateText(content, "GameFontDisableSmall", "OPT_EDIT_MODE_HELP")
        editModeHelp:SetPoint("TOPLEFT", x, y)
        editModeHelp:SetWidth(CONTENT_WIDTH)
        editModeHelp:SetWordWrap(true)
        y = y - 24
    end
    y = y - 12

    ------------------------------------------------------------------ Language
    Header("SECTION_LANGUAGE")
    Caption("OPT_LANGUAGE")
    y = y - 18
    widgets.language = Widgets.CreateDropdown(content, 220, LocaleOptions,
        function() return ns.global.locale end,
        function(value)
            ns.global.locale = value
            ns:SetLocale(value)
        end)
    widgets.language:SetPoint("TOPLEFT", x, y)
    y = y - 40

    content:SetHeight(-y + 16)
end

function Options:Refresh()
    local widgets = self.widgets
    if not widgets then
        return
    end
    Widgets.RefreshTexts()
    for _, name in ipairs({
        "mode", "copy", "visibility", "hideMounted", "hideWithoutSuggestion", "size", "fade",
        "alphaCombat", "alphaOutOfCombat", "border", "cropIcon", "glow", "colorByState",
        "locked", "language",
    }) do
        widgets[name]:Refresh()
    end
    widgets.activeProfile:SetText(L["PROFILE_ACTIVE"]:format(Database.activeProfile or "?"))
    widgets.move:SetText(Mover.active and L["OPT_MOVE_DONE"] or L["OPT_MOVE"])
end

function Options:OnInitialize()
    local panel = CreateFrame("Frame")
    panel.name = ns.title
    panel:Hide()
    panel:SetScript("OnShow", function()
        if not self.widgets then
            self:BuildPanel(panel)
        end
        self:Refresh()
    end)
    self.panel = panel
    self.category = Widgets.RegisterPanel(panel, ns.title)

    local function RefreshIfShown()
        if panel:IsShown() then
            self:Refresh()
        end
    end
    for _, message in ipairs({
        "ABV_SETTINGS_CHANGED", "ABV_LOCALE_CHANGED", "ABV_PROFILE_CHANGED", "ABV_MOVER_CHANGED",
    }) do
        ns:RegisterMessage(message, RefreshIfShown)
    end
end

--- Opens the game settings on this addon's page.
function Options:Open()
    Widgets.OpenPanel(self.panel, self.category)
end
