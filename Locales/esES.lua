local _, addonTable = ...
local L = addonTable.L

if GetLocale() == "esES" or GetLocale() == "esMX" then
    L["FRAME_LOCKED"] = " Marco bloqueado."
    L["FRAME_UNLOCKED"] = " Marco desbloqueado."
    L["CLEARED_OLD_SLOT"] = " Ranura antigua limpiada "
    L["CANNOT_CLEAR_COMBAT"] = " No se puede limpiar la ranura antigua %d en combate."
    L["SLOT_CHANGED_PENDING"] = " Ranura cambiada a %d. Reinstalación pendiente al finalizar combate."
    L["SPELL_INSTALLED"] = " Hechizo instalado en la ranura "
    L["ERROR_INVALID_SPELL"] = " Error: ID de hechizo inválido o hechizo no aprendido."
    L["POSITION_RESET"] = " Posición restablecida al centro."
    L["FORCING_MANUAL"] = " Forzando comprobación/instalación manual..."
    L["COMMANDS_LIST"] = " Comandos:|r"
    L["CMD_RESET_DESC"] = "Restablece la posición del marco al centro."
    L["CMD_INSTALL_DESC"] = "Comprueba la ranura %d e instala el hechizo si falta."

    -- Options
    L["TITLE"] = "Assistant Button Visualizer"
    L["DESCRIPTION"] = "Configura las opciones del visualizador del botón asistente."
    L["LOCK_POSITION"] = "Bloquear Posición"
    L["LOCK_POSITION_DESC"] = "Bloquea el marco para prevenir movimientos accidentales."
    L["VISIBILITY_MODE"] = "Modo de Visibilidad"
    L["IN_COMBAT"] = "En Combate"
    L["ALWAYS"] = "Siempre"
    L["VISIBILITY_SET"] = " Visibilidad establecida a: "
    L["OPACITY"] = "Opacidad"
    L["ICON_SIZE"] = "Tamaño del Icono"
    L["ACTION_SLOT"] = "Ranura de Acción"
    L["SLOT_TOOLTIP"] = "Selecciona la ranura de acción (1-120) donde se colocará la habilidad.\nRanuras comunes:\nBarra 1: 1-12\nBarra 2: 13-24\nBarra 3: 25-36\nBarra 4: 37-48\nBarra 5: 49-60\nBarra 6: 61-72"
    L["APPLY"] = "Aplicar"
    L["APPLIED_NEW_SLOT"] = " Nueva ranura aplicada: %d"
    L["SLOT_HELP"] = "Las barras estándar usan 1-120. Recomendamos usar una ranura alta (como 80+) que no esté en tus barras visibles para evitar sobrescribir tus iconos."
end
