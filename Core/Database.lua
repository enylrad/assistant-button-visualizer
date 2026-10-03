--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Database
    Owns the account-wide saved variable AssistantButtonVisualizerDB and the
    profiles stored in it.

    Layout:
      AssistantButtonVisualizerDB = {
          schema   = <number>,
          global   = { locale },
          profiles = { [name] = { point, relativePoint, x, y, size, locked,
                                  visibility, hideMounted, hideWithoutSuggestion,
                                  alphaCombat, alphaOutOfCombat, fade, shape, border,
                                  cropIcon, glow, colorByState } },
          chars    = { ["Name-Realm"] = { mode } },
      }

    Each character picks how its profile is chosen (mode):
      account    one profile shared by every character ("Default")
      character  one profile per character ("Name-Realm")
      spec       one profile per specialization ("Name-Realm - Spec"); clients
                 without specializations use the character profile

    Versions before 2.0 kept one set of settings (and up to 1.1.x at the top
    level of the table); they become the "Default" profile.
------------------------------------------------------------------------------]]

local _, ns = ...

local Database = ns:NewModule("Database")
local Compat = ns.Compat

local SCHEMA_VERSION = 2

Database.DEFAULT_PROFILE = "Default"
Database.MIN_SIZE = 16
Database.MAX_SIZE = 128
Database.MAX_FADE = 1

-- Choices shown in the options, in display order.
Database.MODES = { "account", "character", "spec" }
Database.VISIBILITY_MODES = { "ALWAYS", "COMBAT", "HOSTILE", "INSTANCE" }
Database.BORDERS = { "none", "thin", "blizzard" }
Database.SHAPES = { "square", "rounded", "circle", "soft" }

local DEFAULT_PROFILE = {
    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = 0,
    size = 64,
    locked = false,
    visibility = "ALWAYS",
    hideMounted = false,
    hideWithoutSuggestion = true,
    alphaCombat = 1,
    alphaOutOfCombat = 0.6,
    fade = 0.2,             -- seconds; 0 shows and hides at once
    shape = "square",       -- square, rounded, circle or soft (a circle that fades out)
    border = "thin",
    cropIcon = true,
    glow = true,            -- pulse when the suggestion changes
    colorByState = true,    -- tint when out of range or not usable
}

local DEFAULT_GLOBAL = {
    locale = "auto",
}

-- Action slot 1.x used when none was saved.
local LEGACY_DEFAULT_SLOT = 88

local LEGACY_KEYS = { "point", "relativePoint", "x", "y", "locked", "visibility", "alpha", "size", "slot" }

--------------------------------------------------------------------------------
-- Migration
--------------------------------------------------------------------------------

--- Turns the settings of 1.x into the "Default" profile. Returns the action
--- slot 1.x used, so the spell left there can be removed.
local function MigrateFromV1(db)
    local old = type(db.settings) == "table" and db.settings or {}
    -- 1.1.x stored the settings at the top level of the table.
    for _, key in ipairs(LEGACY_KEYS) do
        if db[key] ~= nil then
            if old[key] == nil then
                old[key] = db[key]
            end
            db[key] = nil
        end
    end

    local profile = {}
    for _, key in ipairs({ "point", "relativePoint", "x", "y", "size", "locked", "visibility", "hideMounted", "colorByState" }) do
        profile[key] = old[key]
    end
    if old.alpha then
        profile.alphaCombat = old.alpha
        profile.alphaOutOfCombat = old.alpha
    end
    -- 1.x showed a placeholder when there was nothing to mirror.
    profile.hideWithoutSuggestion = false

    db.global = { locale = old.locale }
    db.profiles = { [Database.DEFAULT_PROFILE] = profile }
    db.settings = nil
    return tonumber(old.slot) or LEGACY_DEFAULT_SLOT
end

--- Keeps the saved values inside the ranges the addon supports.
local function SanitizeProfile(profile)
    profile.size = ns.Clamp(math.floor(tonumber(profile.size) or DEFAULT_PROFILE.size), Database.MIN_SIZE, Database.MAX_SIZE)
    profile.alphaCombat = ns.Clamp(tonumber(profile.alphaCombat) or DEFAULT_PROFILE.alphaCombat, 0.1, 1)
    profile.alphaOutOfCombat = ns.Clamp(tonumber(profile.alphaOutOfCombat) or DEFAULT_PROFILE.alphaOutOfCombat, 0, 1)
    profile.fade = ns.Clamp(tonumber(profile.fade) or DEFAULT_PROFILE.fade, 0, Database.MAX_FADE)
    if not tContains(Database.VISIBILITY_MODES, profile.visibility) then
        profile.visibility = DEFAULT_PROFILE.visibility
    end
    if not tContains(Database.BORDERS, profile.border) then
        profile.border = DEFAULT_PROFILE.border
    end
    if not tContains(Database.SHAPES, profile.shape) then
        profile.shape = DEFAULT_PROFILE.shape
    end
end

local function SanitizeGlobal(global)
    -- Settings of the action slot method, which development builds of 2.0 had.
    global.source = nil
    global.slot = nil
end

--------------------------------------------------------------------------------
-- Profiles
--------------------------------------------------------------------------------

local function GetCharacter()
    local chars = ns.db.chars
    local key = Compat.GetCharacterKey()
    local char = chars[key]
    if type(char) ~= "table" then
        char = { mode = "account" }
        chars[key] = char
    end
    if not tContains(Database.MODES, char.mode) then
        char.mode = "account"
    end
    return char, key
end

--- Returns the name of the profile the current character should use.
function Database:ResolveProfileName()
    local char, key = GetCharacter()
    if char.mode == "character" then
        return key
    elseif char.mode == "spec" then
        local spec = Compat.GetSpecName()
        return spec and (key .. " - " .. spec) or key
    end
    return self.DEFAULT_PROFILE
end

--- Returns the profile mode of the current character.
function Database:GetMode()
    return (GetCharacter()).mode
end

--- Makes `name` the active profile, creating it as a copy of the previous
--- one (so switching mode keeps the current look) when it does not exist.
local function Activate(name)
    local profiles = ns.db.profiles
    if type(profiles[name]) ~= "table" then
        profiles[name] = ns.DeepCopy(ns.settings or DEFAULT_PROFILE)
    end
    local profile = ns.ApplyDefaults(profiles[name], DEFAULT_PROFILE)
    SanitizeProfile(profile)
    local changed = ns.settings ~= profile
    ns.settings = profile
    Database.activeProfile = name
    if changed then
        ns:SendMessage("ABV_PROFILE_CHANGED", name)
    end
end

--- Re-resolves the active profile (after a mode or specialization change).
function Database:Refresh()
    Activate(self:ResolveProfileName())
end

--- Changes how the current character picks its profile.
function Database:SetMode(mode)
    if not tContains(self.MODES, mode) then
        return
    end
    GetCharacter().mode = mode
    self:Refresh()
end

--- Returns the names of every stored profile, sorted.
function Database:GetProfileNames()
    local names = {}
    for name in pairs(ns.db.profiles) do
        names[#names + 1] = name
    end
    table.sort(names)
    return names
end

--- Copies another profile into the active one.
function Database:CopyFrom(name)
    local source = ns.db.profiles[name]
    if type(source) ~= "table" or name == self.activeProfile then
        return
    end
    wipe(ns.settings)
    for key, value in pairs(ns.DeepCopy(source)) do
        ns.settings[key] = value
    end
    ns.ApplyDefaults(ns.settings, DEFAULT_PROFILE)
    SanitizeProfile(ns.settings)
    ns:SendMessage("ABV_PROFILE_CHANGED", self.activeProfile)
end

--- Restores the defaults of the active profile.
function Database:ResetProfile()
    wipe(ns.settings)
    ns.ApplyDefaults(ns.settings, DEFAULT_PROFILE)
    ns:SendMessage("ABV_PROFILE_CHANGED", self.activeProfile)
end

--- Moves the button back to the center of the screen.
function Database:ResetPosition()
    local settings = ns.settings
    settings.point = DEFAULT_PROFILE.point
    settings.relativePoint = DEFAULT_PROFILE.relativePoint
    settings.x = DEFAULT_PROFILE.x
    settings.y = DEFAULT_PROFILE.y
    ns:SendMessage("ABV_POSITION_CHANGED")
end

--------------------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------------------

function Database:OnInitialize()
    local db = _G.AssistantButtonVisualizerDB
    if type(db) ~= "table" then
        db = { schema = SCHEMA_VERSION }
        _G.AssistantButtonVisualizerDB = db
    end
    if (db.schema or 1) < 2 then
        self.legacySlot = MigrateFromV1(db)
    end
    db.schema = SCHEMA_VERSION
    db.global = ns.ApplyDefaults(type(db.global) == "table" and db.global or {}, DEFAULT_GLOBAL)
    SanitizeGlobal(db.global)
    db.profiles = type(db.profiles) == "table" and db.profiles or {}
    db.chars = type(db.chars) == "table" and db.chars or {}

    ns.db = db
    ns.global = db.global
    -- Until the character is known, the shared profile is active.
    Activate(self.DEFAULT_PROFILE)
    ns:SetLocale(db.global.locale)
end

function Database:OnLogin()
    -- The character name and specialization are only known at login.
    self:Refresh()
    local function Refresh()
        if self:GetMode() == "spec" then
            self:Refresh()
        end
    end
    ns:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", function(_, unit)
        if unit == nil or unit == "player" then
            Refresh()
        end
    end)
    ns:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", Refresh)
end
