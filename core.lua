-- ============================================================================
-- CONFIGURATION & CONSTANTS
-- ============================================================================
-- NOTE: If the client language is not English, change this value to the localized spell name.
-- Example for Spanish: "Asistente de botón único"
local SPELL_NAME = "Single-Button Assistant" 
local GHOST_SLOT = 88 
local FRAME_SIZE = 64
local BASE_ALPHA = 0.7 
local UPDATE_INTERVAL = 0.1

-- ============================================================================
-- DATABASE INITIALIZATION
-- ============================================================================
local function InitializeDatabase()
    if not AssistantButtonVisualizerDB then
        AssistantButtonVisualizerDB = { 
            point = "CENTER", 
            relativePoint = "CENTER", 
            x = 0, 
            y = 0 
        }
    end
end

-- ============================================================================
-- FRAME CONSTRUCTION
-- ============================================================================
local mainFrame = CreateFrame("Frame", "ABV_MainFrame", UIParent)
mainFrame:SetSize(FRAME_SIZE, FRAME_SIZE)
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")

-- Texture setup
local texture = mainFrame:CreateTexture(nil, "BACKGROUND")
texture:SetAllPoints(mainFrame)
mainFrame.texture = texture

-- Drag Event Handlers
mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    
    -- Persist position to SavedVariables
    local point, _, relativePoint, x, y = self:GetPoint()
    AssistantButtonVisualizerDB.point = point
    AssistantButtonVisualizerDB.relativePoint = relativePoint
    AssistantButtonVisualizerDB.x = x
    AssistantButtonVisualizerDB.y = y
end)

-- ============================================================================
-- CORE LOGIC
-- ============================================================================

-- Updates the visual representation based on the hidden action slot state.
local function UpdateVisuals()
    -- GetActionTexture is safe to call on protected buttons (does not trigger 'Secret Value' errors).
    local icon = GetActionTexture(GHOST_SLOT)
    
    if icon then
        mainFrame.texture:SetTexture(icon)
        mainFrame.texture:SetDesaturated(false)
        mainFrame:SetAlpha(BASE_ALPHA) 
        mainFrame:Show()
    else
        -- Render a placeholder if the slot is empty or not loaded yet.
        mainFrame.texture:SetColorTexture(1, 0, 0, 0.5)
        mainFrame:SetAlpha(1.0)
        mainFrame:Show()
    end
end

-- Attempts to assign the spell to the hidden action slot.
local function InstallSpellToSlot()
    if InCombatLockdown() then 
        print("|cffFF0000ABV Error:|r Cannot modify action bars during combat.")
        return 
    end

    local spellInfo = C_Spell.GetSpellInfo(SPELL_NAME)
    
    if spellInfo and spellInfo.spellID then
        C_Spell.PickupSpell(spellInfo.spellID)
        
        if GetCursorInfo() then
            PlaceAction(GHOST_SLOT)
            ClearCursor()
            -- Installation successful; silent execution to avoid chat spam on login.
        end
    else
        -- Silent fail is preferred during login; use slash command for debug.
    end
end

-- ============================================================================
-- UPDATE LOOP & EVENTS
-- ============================================================================

local timer = 0
mainFrame:SetScript("OnUpdate", function(self, elapsed)
    timer = timer + elapsed
    if timer >= UPDATE_INTERVAL then
        UpdateVisuals()
        timer = 0
    end
end)

mainFrame:RegisterEvent("PLAYER_LOGIN")
mainFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        InitializeDatabase()
        
        -- Restore position from SavedVariables
        self:ClearAllPoints()
        self:SetPoint(
            AssistantButtonVisualizerDB.point or "CENTER", 
            UIParent, 
            AssistantButtonVisualizerDB.relativePoint or "CENTER", 
            AssistantButtonVisualizerDB.x or 0, 
            AssistantButtonVisualizerDB.y or 0
        )
        
        print("|cff00ff00Assistant Button Visualizer:|r Loaded. Initializing...")
        
        -- Delay installation to ensure Spellbook is fully loaded.
        C_Timer.After(2, InstallSpellToSlot)
    end
end)

-- ============================================================================
-- SLASH COMMANDS
-- ============================================================================
SLASH_ABV1 = "/abv"
SlashCmdList["ABV"] = function(msg)
    local cmd = msg:lower()
    
    if cmd == "reset" then
        mainFrame:ClearAllPoints()
        mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        
        AssistantButtonVisualizerDB.point = "CENTER"
        AssistantButtonVisualizerDB.relativePoint = "CENTER"
        AssistantButtonVisualizerDB.x = 0
        AssistantButtonVisualizerDB.y = 0
        
        print("|cff00ff00ABV:|r Position reset to center.")
        
    elseif cmd == "install" then
        print("|cff00ff00ABV:|r Attempting manual installation...")
        InstallSpellToSlot()
        
    else
        print("|cff00ff00ABV Commands:|r")
        print("/abv reset   - Resets the frame position to the center.")
        print("/abv install - Manually forces the spell installation to slot " .. GHOST_SLOT .. ".")
    end
end