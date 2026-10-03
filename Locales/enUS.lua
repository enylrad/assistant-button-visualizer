--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - English strings (also the fallback for missing translations)
------------------------------------------------------------------------------]]

local _, ns = ...

ns.Locales = ns.Locales or {}

ns.Locales.enUS = {
    -- General
    SPELL_INSTALLED = "spell placed in action slot |cffffd200%d|r.",
    CLEARED_OLD_SLOT = "cleared the previous action slot |cffffd200%d|r.",
    SLOT_CHANGED_PENDING = "action slot changed to |cffffd200%d|r. The spell will be moved when combat ends.",
    ERROR_INVALID_SPELL = "the Assistant Button spell is not available for this character.",
    POSITION_RESET = "button moved back to the center of the screen.",
    FORCING_MANUAL = "placing the spell in its action slot...",
    APPLIED_NEW_SLOT = "now using action slot |cffffd200%d|r.",
    HELP_HEADER = "commands:",
    HELP_OPTIONS = "|cffffd200/abv|r - open the options",
    HELP_RESET = "|cffffd200/abv reset|r - move the button back to the center",
    HELP_INSTALL = "|cffffd200/abv install|r - place the spell in action slot %d",
    HELP_HELP = "|cffffd200/abv help|r - show this help",

    -- Options
    OPTIONS_SUBTITLE = "Shows the Assistant Button suggestion anywhere on the screen. Drag the button to move it while it is unlocked.",
    OPT_LOCK = "Lock position (also lets clicks go through)",
    OPT_COLOR_BY_STATE = "Tint when out of range or not usable",
    OPT_VISIBILITY = "Show the button",
    VISIBILITY_ALWAYS = "Always",
    VISIBILITY_COMBAT = "In combat",
    VISIBILITY_HOSTILE = "With a hostile target",
    VISIBILITY_INSTANCE = "In instances",
    OPT_HIDE_MOUNTED = "Hide while mounted (out of combat)",
    OPT_OPACITY = "Opacity",
    OPT_SIZE = "Icon size",
    OPT_SLOT = "Action slot",
    OPT_APPLY = "Apply",
    OPT_SLOT_HELP = "The spell is kept in this action slot (1-120) so the button can mirror it. Pick one that is not on your visible bars, such as 80 or higher, so none of your icons is replaced. Bars 1 to 6 use slots 1-72.",
    OPT_INSTALL = "Place the spell now",
    OPT_RESET_POSITION = "Center the button",
    OPT_LANGUAGE = "Addon language",
    LOCALE_auto = "Game language",
    LOCALE_enUS = "English",
    LOCALE_esES = "Español",
}
