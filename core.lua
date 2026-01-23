-- CONFIGURATION
-- IMPORTANTE: Si juegas en español, esto DEBE ser "Asistente de botón único"
local SPELL_NAME = "Single-Button Assistant" 
local GHOST_SLOT = 88 
local FRAME_SIZE = 64
local BASE_ALPHA = 0.7 -- 30% Transparency (0.7 Opacity)

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
    -- GetActionTexture es seguro. Blizzard permite ver el icono.
    local icon = GetActionTexture(GHOST_SLOT)
    
    if icon then
        f.texture:SetTexture(icon)
        f.texture:SetDesaturated(false)
        f:SetAlpha(BASE_ALPHA) -- Transparencia fija al 30%
        f:Show()
    else
        -- Muestra un cuadro rojo si el slot está vacío (útil para saber si se ha cargado)
        f.texture:SetColorTexture(1, 0, 0, 0.5)
        f:SetAlpha(1.0)
        f:Show()
    end
end

-- LOOP
local timer = 0
f:SetScript("OnUpdate", function(self, elapsed)
    timer = timer + elapsed
    -- Actualizamos cada 0.1s para que el cambio de icono sea rápido
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
        print("|cff00ff00SBA Ghost:|r Loaded Stable Mode. Transparency set to 30%.")
    end
end)

-- SETUP COMMAND
SLASH_SBAGHOST1 = "/sbaghost"
SlashCmdList["SBAGHOST"] = function(msg)
    local cmd = msg:lower()
    
    if cmd == "install" then
        if InCombatLockdown() then
            print("|cffFF0000Error:|r Cannot perform installation during combat.")
            return
        end
        
        print("Attempting to find and install '"..SPELL_NAME.."' into slot "..GHOST_SLOT.."...")
        
        -- Use Modern API to find ID
        local spellInfo = C_Spell.GetSpellInfo(SPELL_NAME)
        
        if spellInfo and spellInfo.spellID then
            C_Spell.PickupSpell(spellInfo.spellID)
            
            if GetCursorInfo() then
                PlaceAction(GHOST_SLOT)
                ClearCursor()
                print("|cff00ff00Success:|r Spell installed in slot "..GHOST_SLOT..".")
            else
                print("|cffFF0000Failed:|r Could not pick up the spell.")
            end
        else
            print("|cffFF0000Error:|r Spell '"..SPELL_NAME.."' not found.")
            print("Check core.lua if you need to translate the spell name.")
        end
        
    else
        print("Usage: /sbaghost install")
    end
end