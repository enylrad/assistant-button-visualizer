-- ============================================================================
-- CONFIGURATION & CONSTANTS
-- ============================================================================
local TARGET_SPELL_ID = 1229376 

local GHOST_SLOT = 88 
local FRAME_SIZE = 64
local BASE_ALPHA = 0.3 
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
            y = 0,
            locked = false,
            visibility = "ALWAYS" -- "ALWAYS" or "COMBAT"
        }
    end
end

-- ============================================================================
-- GLOBAL API
-- ============================================================================

-- Function to lock/unlock the frame
function AssistantButton_SetLock(locked)
    if not ABV_MainFrame then return end
    
    if locked then
        ABV_MainFrame:EnableMouse(false)
        ABV_MainFrame:SetMovable(false)
        print("|cff00ff00ABV:|r Frame Locked.")
    else
        ABV_MainFrame:EnableMouse(true)
        ABV_MainFrame:SetMovable(true)
        print("|cff00ff00ABV:|r Frame Unlocked.")
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
    -- Check Visibility Check
    if AssistantButtonVisualizerDB.visibility == "COMBAT" and not InCombatLockdown() then
        mainFrame:Hide()
        return
    end

    -- GetActionTexture is safe to call on protected buttons.
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
-- Checks if the spell is already there to avoid redundant writing.
local function InstallSpellToSlot()
    if InCombatLockdown() then 
        -- Silent return or debug print during development
        return 
    end

    -- 1. Check what is currently in the slot.
    -- GetActionInfo returns: type, id, subType
    local actionType, actionID = GetActionInfo(GHOST_SLOT)

    -- 2. If the correct spell is already there, do nothing.
    if actionType == "spell" and actionID == TARGET_SPELL_ID then
        -- The spell is already installed correctly. Exit function.
        return
    end

    -- 3. If we are here, the slot is empty or has the wrong spell. Attempt to install.
    local spellInfo = C_Spell.GetSpellInfo(TARGET_SPELL_ID)
    
    if spellInfo and spellInfo.spellID then
        C_Spell.PickupSpell(spellInfo.spellID)
        
        -- Verify cursor has the spell before placing
        if GetCursorInfo() then
            PlaceAction(GHOST_SLOT)
            ClearCursor()
            print("|cff00ff00ABV:|r Spell installed to slot " .. GHOST_SLOT)
        end
    else
        -- Only print error if manually triggered or debugging, to avoid login spam if ID is wrong
        -- print("|cffFF0000ABV Error:|r Invalid Spell ID or spell not learned.")
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
mainFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
mainFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
mainFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
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
        
        -- Delay installation to ensure Spellbook is fully loaded.
        C_Timer.After(2, InstallSpellToSlot)

        -- Apply lock state
        if AssistantButtonVisualizerDB.locked then
            AssistantButton_SetLock(true)
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Combat started. Show frame immediately to ensure OnUpdate loop runs
        -- and can evaluate the visibility logic (which checks InCombatLockdown).
        self:Show()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" or event == "TRAIT_CONFIG_UPDATED" then
        -- Re-install spell when talents or specialization change.
        -- We add a small delay to ensure the spellbook has processed the changes.
        C_Timer.After(1, InstallSpellToSlot)
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
        print("|cff00ff00ABV:|r Forcing manual check/installation...")
        InstallSpellToSlot()
        
    else
        print("|cff00ff00ABV Commands:|r")
        print("/abv reset   - Resets the frame position to the center.")
        print("/abv install - Checks slot " .. GHOST_SLOT .. " and installs the spell if missing.")
    end
end