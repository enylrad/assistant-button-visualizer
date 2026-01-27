local _, addonTable = ...
local L = {}
addonTable.L = L

-- English (Default)
L["FRAME_LOCKED"] = " Frame Locked."
L["FRAME_UNLOCKED"] = " Frame Unlocked."
L["CLEARED_OLD_SLOT"] = " Cleared old slot "
L["CANNOT_CLEAR_COMBAT"] = " Cannot clear old slot %d while in combat."
L["SLOT_CHANGED_PENDING"] = " Slot changed to %d. Re-installation pending combat end."
L["SPELL_INSTALLED"] = " Spell installed to slot "
L["ERROR_INVALID_SPELL"] = " Error: Invalid Spell ID or spell not learned."
L["POSITION_RESET"] = " Position reset to center."
L["FORCING_MANUAL"] = " Forcing manual check/installation..."
L["COMMANDS_LIST"] = " Commands:|r"
L["CMD_RESET_DESC"] = "Resets the frame position to the center."
L["CMD_INSTALL_DESC"] = "Checks slot %d and installs the spell if missing."

-- Options
L["TITLE"] = "Assistant Button Visualizer"
L["DESCRIPTION"] = "Configure the Assistant Button visualizer settings."
L["LOCK_POSITION"] = "Lock Position"
L["LOCK_POSITION_DESC"] = "Lock the button frame to prevent accidental movement."
L["VISIBILITY_MODE"] = "Visibility Mode"
L["IN_COMBAT"] = "In Combat"
L["ALWAYS"] = "Always"
L["VISIBILITY_SET"] = " Visibility set to: "
L["OPACITY"] = "Opacity"
L["ICON_SIZE"] = "Icon Size"
L["ACTION_SLOT"] = "Action Slot"
L["SLOT_TOOLTIP"] = "Select the action slot (1-120) where the ability will be placed.\nCommon slots:\nBar 1: 1-12\nBar 2: 13-24\nBar 3: 25-36\nBar 4: 37-48\nBar 5: 49-60\nBar 6: 61-72"
L["APPLY"] = "Apply"
L["APPLIED_NEW_SLOT"] = " Applied new slot: %d"
L["SLOT_HELP"] = "Standard bars use 1-120. We recommend using a high slot (like 80+) that isn't on your visible bars to avoid overwriting your icons."
