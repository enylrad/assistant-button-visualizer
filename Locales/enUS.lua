--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - English strings (also the fallback for missing translations)
------------------------------------------------------------------------------]]

local _, ns = ...

ns.Locales = ns.Locales or {}

ns.Locales.enUS = {
    -- General
    API_MISSING = "this client has no assisted combat suggestions, so there is nothing to show.",
    CLEARED_OLD_SLOT = "removed the Assistant Button spell from action slot |cffffd200%d|r; it is not needed any more.",
    POSITION_RESET = "button moved back to the center of the screen.",
    PROFILE_COPIED = "copied the profile |cffffd200%s|r.",
    PROFILE_RESET_DONE = "the active profile was reset.",
    PROFILE_ACTIVE = "Active profile: |cffffd200%s|r",
    MOVER_HINT = "Drag to move. Right click or Escape to finish.",
    HELP_HEADER = "commands:",
    HELP_OPTIONS = "|cffffd200/abv|r - open the options",
    HELP_MOVE = "|cffffd200/abv move|r - move the button",
    HELP_RESET = "|cffffd200/abv reset|r - move the button back to the center",
    HELP_HELP = "|cffffd200/abv help|r - show this help",

    -- Options
    OPTIONS_SUBTITLE = "Shows the spell the Assistant Button suggests anywhere on the screen.",

    SECTION_PROFILE = "Profile",
    OPT_PROFILE_MODE = "Use a profile",
    PROFILE_MODE_account = "Shared by all characters",
    PROFILE_MODE_character = "Per character",
    PROFILE_MODE_spec = "Per specialization",
    OPT_PROFILE_COPY = "Copy from",
    OPT_PROFILE_COPY_PICK = "Pick a profile...",
    OPT_PROFILE_RESET = "Reset profile",

    SECTION_VISIBILITY = "Visibility",
    OPT_VISIBILITY = "Show the button",
    VISIBILITY_ALWAYS = "Always",
    VISIBILITY_COMBAT = "In combat",
    VISIBILITY_HOSTILE = "With a hostile target",
    VISIBILITY_INSTANCE = "In instances",
    OPT_HIDE_MOUNTED = "Hide while mounted (out of combat)",
    OPT_HIDE_EMPTY = "Hide when there is no suggestion",

    SECTION_APPEARANCE = "Appearance",
    OPT_SIZE = "Icon size",
    OPT_FADE = "Fade time",
    OPT_ALPHA_COMBAT = "Opacity in combat",
    OPT_ALPHA_OOC = "Opacity out of combat",
    OPT_SHAPE = "Icon shape",
    SHAPE_square = "Square",
    SHAPE_rounded = "Rounded",
    SHAPE_circle = "Circle",
    SHAPE_soft = "Soft circle",
    OPT_SHAPE_HELP = "The action button border only fits the square; the soft circle has no border.",
    OPT_BORDER = "Border",
    BORDER_none = "None",
    BORDER_thin = "Thin",
    BORDER_blizzard = "Action button",
    OPT_CROP = "Crop the icon edges",
    OPT_GLOW = "Flash when the suggestion changes",
    OPT_COLOR_BY_STATE = "Tint when out of range or not usable",

    SECTION_POSITION = "Position",
    OPT_LOCK = "Lock position (also lets clicks go through)",
    OPT_MOVE = "Move",
    OPT_MOVE_DONE = "Done moving",
    OPT_RESET_POSITION = "Center the button",
    OPT_EDIT_MODE_HELP = "The button can also be moved from the game's Edit Mode.",

    SECTION_LANGUAGE = "Language",
    OPT_LANGUAGE = "Addon language",
    LOCALE_auto = "Game language",
    LOCALE_enUS = "English",
    LOCALE_esES = "Español",
}
