--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Localization
    Resolves user-facing strings through the active locale with an English
    fallback. The active locale can follow the client or be forced by the user
    in the options, and can be switched at runtime.

    Locale files register their tables in ns.Locales[<code>] before this file
    runs (see the TOC order).
------------------------------------------------------------------------------]]

local _, ns = ...

ns.Locales = ns.Locales or {}

-- Client locales that are served by another table.
local LOCALE_ALIASES = {
    esMX = "esES",
    enGB = "enUS",
}

-- Locales selectable from the options panel, in display order.
ns.AVAILABLE_LOCALES = { "auto", "enUS", "esES" }

ns.activeLocale = "enUS"

--- String lookup table. Missing keys fall back to English, then to the key
--- itself so that a missing translation is visible but never breaks the UI.
ns.L = setmetatable({}, {
    __index = function(_, key)
        local active = ns.Locales[ns.activeLocale]
        local value = active and active[key]
        if value == nil then
            value = ns.Locales.enUS and ns.Locales.enUS[key]
        end
        return value or key
    end,
    __newindex = function()
        error("AssistantButtonVisualizer: the localization table is read-only", 2)
    end,
})

--- Resolves a locale setting ("auto" or a locale code) to a loaded table code.
local function ResolveLocale(setting)
    local code = setting
    if not code or code == "auto" then
        code = GetLocale()
    end
    code = LOCALE_ALIASES[code] or code
    if not ns.Locales[code] then
        code = "enUS"
    end
    return code
end

--- Activates a locale and notifies the UI so it can refresh its texts.
--- @param setting string "auto" or a locale code such as "esES"
function ns:SetLocale(setting)
    local resolved = ResolveLocale(setting)
    local changed = resolved ~= ns.activeLocale
    ns.activeLocale = resolved
    if changed then
        ns:SendMessage("ABV_LOCALE_CHANGED", resolved)
    end
end

-- Follow the client language until the saved settings are loaded.
ns.activeLocale = ResolveLocale("auto")
