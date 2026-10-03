--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Database
    Owns the account-wide saved variable AssistantButtonVisualizerDB.

    Layout:
      AssistantButtonVisualizerDB = {
          schema   = <number>,
          settings = {
              point, relativePoint, x, y,  -- button position on UIParent
              locked, visibility, alpha, size, slot, locale,
          },
      }

    Versions up to 1.1.x stored the settings at the top level of the table;
    they are moved into `settings` on load.
------------------------------------------------------------------------------]]

local _, ns = ...

local Database = ns:NewModule("Database")

local SCHEMA_VERSION = 1

Database.MIN_SLOT = 1
Database.MAX_SLOT = 120
Database.MIN_SIZE = 16
Database.MAX_SIZE = 128

-- Visibility modes, in the order shown in the options.
Database.VISIBILITY_MODES = { "ALWAYS", "COMBAT" }

local DEFAULT_SETTINGS = {
    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = 0,
    locked = false,
    visibility = "ALWAYS",
    alpha = 0.3,
    size = 64,
    slot = 88,          -- a slot outside the default visible bars
    locale = "auto",
}

local LEGACY_KEYS = { "point", "relativePoint", "x", "y", "locked", "visibility", "alpha", "size", "slot" }

--- Moves the flat 1.1.x settings into the settings table.
local function MigrateLegacy(db, settings)
    for _, key in ipairs(LEGACY_KEYS) do
        if db[key] ~= nil then
            if settings[key] == nil then
                settings[key] = db[key]
            end
            db[key] = nil
        end
    end
end

--- Keeps the saved values inside the ranges the addon supports.
local function Sanitize(settings)
    settings.slot = ns.Clamp(math.floor(tonumber(settings.slot) or DEFAULT_SETTINGS.slot), Database.MIN_SLOT, Database.MAX_SLOT)
    settings.size = ns.Clamp(math.floor(tonumber(settings.size) or DEFAULT_SETTINGS.size), Database.MIN_SIZE, Database.MAX_SIZE)
    settings.alpha = ns.Clamp(tonumber(settings.alpha) or DEFAULT_SETTINGS.alpha, 0.1, 1)
    if not tContains(Database.VISIBILITY_MODES, settings.visibility) then
        settings.visibility = DEFAULT_SETTINGS.visibility
    end
end

function Database:OnInitialize()
    local db = _G.AssistantButtonVisualizerDB
    if type(db) ~= "table" then
        db = {}
        _G.AssistantButtonVisualizerDB = db
    end
    local settings = type(db.settings) == "table" and db.settings or {}
    MigrateLegacy(db, settings)
    db.schema = db.schema or SCHEMA_VERSION
    db.settings = ns.ApplyDefaults(settings, DEFAULT_SETTINGS)
    Sanitize(db.settings)

    ns.db = db
    ns.settings = db.settings
    ns:SetLocale(db.settings.locale)
end

--- Moves the button back to the center of the screen.
function Database:ResetPosition()
    local settings = ns.settings
    settings.point = DEFAULT_SETTINGS.point
    settings.relativePoint = DEFAULT_SETTINGS.relativePoint
    settings.x = DEFAULT_SETTINGS.x
    settings.y = DEFAULT_SETTINGS.y
    ns:SendMessage("ABV_POSITION_CHANGED")
end
