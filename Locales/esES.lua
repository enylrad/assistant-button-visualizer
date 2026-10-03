--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Spanish strings (esES, also used for esMX)
------------------------------------------------------------------------------]]

local _, ns = ...

ns.Locales = ns.Locales or {}

ns.Locales.esES = {
    -- General
    SPELL_INSTALLED = "hechizo colocado en la casilla de acción |cffffd200%d|r.",
    CLEARED_OLD_SLOT = "se ha vaciado la casilla de acción anterior |cffffd200%d|r.",
    SLOT_CHANGED_PENDING = "casilla de acción cambiada a |cffffd200%d|r. El hechizo se moverá al terminar el combate.",
    ERROR_INVALID_SPELL = "el hechizo del Botón Asistente no está disponible para este personaje.",
    POSITION_RESET = "el botón ha vuelto al centro de la pantalla.",
    FORCING_MANUAL = "colocando el hechizo en su casilla de acción...",
    APPLIED_NEW_SLOT = "ahora se usa la casilla de acción |cffffd200%d|r.",
    HELP_HEADER = "comandos:",
    HELP_OPTIONS = "|cffffd200/abv|r - abre las opciones",
    HELP_RESET = "|cffffd200/abv reset|r - devuelve el botón al centro",
    HELP_INSTALL = "|cffffd200/abv install|r - coloca el hechizo en la casilla de acción %d",
    HELP_HELP = "|cffffd200/abv help|r - muestra esta ayuda",

    -- Options
    OPTIONS_SUBTITLE = "Muestra la sugerencia del Botón Asistente en cualquier parte de la pantalla. Arrastra el botón para moverlo mientras esté desbloqueado.",
    OPT_LOCK = "Bloquear posición (los clics también lo atraviesan)",
    OPT_VISIBILITY = "Mostrar el botón",
    VISIBILITY_ALWAYS = "Siempre",
    VISIBILITY_COMBAT = "En combate",
    OPT_OPACITY = "Opacidad",
    OPT_SIZE = "Tamaño del icono",
    OPT_SLOT = "Casilla de acción",
    OPT_APPLY = "Aplicar",
    OPT_SLOT_HELP = "El hechizo se guarda en esta casilla de acción (1-120) para que el botón pueda reflejarlo. Elige una que no esté en tus barras visibles, como la 80 o superior, para no sustituir ninguno de tus iconos. Las barras 1 a 6 usan las casillas 1-72.",
    OPT_INSTALL = "Colocar el hechizo ahora",
    OPT_RESET_POSITION = "Centrar el botón",
    OPT_LANGUAGE = "Idioma del addon",
    LOCALE_auto = "Idioma del juego",
    LOCALE_enUS = "English",
    LOCALE_esES = "Español",
}
