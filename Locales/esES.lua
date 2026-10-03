--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Spanish strings (esES, also used for esMX)
------------------------------------------------------------------------------]]

local _, ns = ...

ns.Locales = ns.Locales or {}

ns.Locales.esES = {
    -- General
    API_MISSING = "este cliente no tiene sugerencias de combate asistido; se usa el método de la casilla de acción.",
    SPELL_INSTALLED = "hechizo colocado en la casilla de acción |cffffd200%d|r.",
    CLEARED_OLD_SLOT = "se ha quitado el hechizo del Botón Asistente de la casilla |cffffd200%d|r; ya no hace falta.",
    SLOT_CHANGED_PENDING = "casilla de acción cambiada a |cffffd200%d|r. El hechizo se moverá al terminar el combate.",
    ERROR_INVALID_SPELL = "el hechizo del Botón Asistente no está disponible para este personaje.",
    POSITION_RESET = "el botón ha vuelto al centro de la pantalla.",
    FORCING_MANUAL = "colocando el hechizo en su casilla de acción...",
    APPLIED_NEW_SLOT = "ahora se usa la casilla de acción |cffffd200%d|r.",
    PROFILE_COPIED = "se ha copiado el perfil |cffffd200%s|r.",
    PROFILE_RESET_DONE = "se ha restablecido el perfil activo.",
    PROFILE_ACTIVE = "Perfil activo: |cffffd200%s|r",
    MOVER_HINT = "Arrastra para mover. Clic derecho o Escape para terminar.",
    HELP_HEADER = "comandos:",
    HELP_OPTIONS = "|cffffd200/abv|r - abre las opciones",
    HELP_MOVE = "|cffffd200/abv move|r - mueve el botón",
    HELP_RESET = "|cffffd200/abv reset|r - devuelve el botón al centro",
    HELP_HELP = "|cffffd200/abv help|r - muestra esta ayuda",

    -- Options
    OPTIONS_SUBTITLE = "Muestra en cualquier parte de la pantalla el hechizo que sugiere el Botón Asistente.",

    SECTION_PROFILE = "Perfil",
    OPT_PROFILE_MODE = "Usar un perfil",
    PROFILE_MODE_account = "Compartido por todos los personajes",
    PROFILE_MODE_character = "Por personaje",
    PROFILE_MODE_spec = "Por especialización",
    OPT_PROFILE_COPY = "Copiar de",
    OPT_PROFILE_COPY_PICK = "Elige un perfil...",
    OPT_PROFILE_RESET = "Restablecer perfil",

    SECTION_VISIBILITY = "Visibilidad",
    OPT_VISIBILITY = "Mostrar el botón",
    VISIBILITY_ALWAYS = "Siempre",
    VISIBILITY_COMBAT = "En combate",
    VISIBILITY_HOSTILE = "Con un objetivo hostil",
    VISIBILITY_INSTANCE = "En instancias",
    OPT_HIDE_MOUNTED = "Ocultar en montura (fuera de combate)",
    OPT_HIDE_EMPTY = "Ocultar si no hay sugerencia",

    SECTION_APPEARANCE = "Apariencia",
    OPT_SIZE = "Tamaño del icono",
    OPT_FADE = "Tiempo de fundido",
    OPT_ALPHA_COMBAT = "Opacidad en combate",
    OPT_ALPHA_OOC = "Opacidad fuera de combate",
    OPT_BORDER = "Borde",
    BORDER_none = "Ninguno",
    BORDER_thin = "Fino",
    BORDER_blizzard = "Botón de acción",
    OPT_CROP = "Recortar los bordes del icono",
    OPT_GLOW = "Destello al cambiar la sugerencia",
    OPT_COLOR_BY_STATE = "Colorear fuera de alcance o si no se puede usar",

    SECTION_POSITION = "Posición",
    OPT_LOCK = "Bloquear posición (los clics también lo atraviesan)",
    OPT_MOVE = "Mover",
    OPT_MOVE_DONE = "Terminar de mover",
    OPT_RESET_POSITION = "Centrar el botón",
    OPT_EDIT_MODE_HELP = "El botón también se puede mover desde el Modo Edición del juego.",

    SECTION_SOURCE = "Sugerencia e idioma",
    OPT_SOURCE = "Leer la sugerencia de",
    SOURCE_api = "Combate asistido (recomendado)",
    SOURCE_slot = "Una casilla de acción (método 1.x)",
    OPT_SOURCE_HELP = "El combate asistido no necesita nada en tus barras. El método de la casilla guarda el hechizo del Botón Asistente en una casilla y la refleja; úsalo solo si el otro no te funciona.",
    OPT_SLOT = "Casilla de acción",
    OPT_APPLY = "Aplicar",
    OPT_INSTALL = "Colocar el hechizo ahora",
    OPT_LANGUAGE = "Idioma del addon",
    LOCALE_auto = "Idioma del juego",
    LOCALE_enUS = "English",
    LOCALE_esES = "Español",
}
