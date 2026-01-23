-- CONFIGURATION
-- IMPORTANT: If playing in Spanish, this MUST be "Asistente de botón único"
local SPELL_NAME = "Single-Button Assistant" 
local GHOST_SLOT = 88 
local FRAME_SIZE = 64
local BASE_ALPHA = 0.3

-- DATABASE INIT
local function InitDB()
    if not SBAGhostDB then
        SBAGhostDB = { point = "CENTER", x = 0, y = 0 }
    end
end

-- FRAME CREATION
local f = CreateFrame("Frame", "SBAGhostFrame", UIParent)
f:SetSize(FRAME_SIZE, FRAME_SIZE)
f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")

-- VISUALS
local texture = f:CreateTexture(nil, "BACKGROUND")
texture:SetAllPoints(f)
f.texture = texture

-- DRAG LOGIC
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    SBAGhostDB.point = point
    SBAGhostDB.x = x
    SBAGhostDB.y = y
end)

-- LOGIC: READ THE GHOST SLOT (TEXTURE ONLY)
local function UpdateGhost()
    local icon = GetActionTexture(GHOST_SLOT)
    
    if icon then
        f.texture:SetTexture(icon)
        f.texture:SetDesaturated(false)
        f:SetAlpha(BASE_ALPHA) 
        f:Show()
    else
        -- If empty, show red placeholder
        f.texture:SetColorTexture(1, 0, 0, 0.5)
        f:SetAlpha(1.0)
        f:Show()
    end
end

-- AUTOMATED INSTALLATION FUNCTION
local function InstallSBA()
    -- Safety check: Cannot modify actions in combat
    if InCombatLockdown() then return end

    -- Find Spell ID
    local spellInfo = C_Spell.GetSpellInfo(SPELL_NAME)
    
    if spellInfo and spellInfo.spellID then
        -- Check if the slot already has the correct icon/action to avoid spamming (Optional optimization)
        -- For now, we force update to ensure it works.
        
        C_Spell.PickupSpell(spellInfo.spellID)
        
        if GetCursorInfo() then
            PlaceAction(GHOST_SLOT)
            ClearCursor()
            print("|cff00ff00SBA Ghost:|r Auto-installed spell into slot "..GHOST_SLOT..".")
        end
    else
        print("|cffFF0000SBA Ghost:|r Could not find spell to auto-install.")
    end
end

-- LOOP
local timer = 0
f:SetScript("OnUpdate", function(self, elapsed)
    timer = timer + elapsed
    if timer > 0.1 then
        UpdateGhost()
        timer = 0
    end
end)

-- INIT EVENT
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        InitDB()
        self:ClearAllPoints()
        self:SetPoint(SBAGhostDB.point, UIParent, SBAGhostDB.point, SBAGhostDB.x, SBAGhostDB.y)
        
        print("|cff00ff00SBA Ghost:|r Loaded. Auto-installing in 2 seconds...")
        
        -- DELAYED EXECUTION: Wait 2 seconds to ensure Spellbook is ready
        C_Timer.After(2, InstallSBA)
    end
end)

-- MANUAL SLASH COMMAND (Backup)
SLASH_SBAGHOST1 = "/sbaghost"
SlashCmdList["SBAGHOST"] = function(msg)
    local cmd = msg:lower()
    if cmd == "install" then
        InstallSBA() -- Call the same function manually
    else
        print("Usage: /sbaghost install (Manual override)")
    end
end