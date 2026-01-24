-- ============================================================================
-- CONFIGURATION & CONSTANTS
-- ============================================================================
local TARGET_SPELL_ID = 1229376 

local SLOT = 88 
local FRAME_SIZE = 64
local UPDATE_INTERVAL = 0.1
local ABV_PREFIX = "|cff00ff00ABV:|r"

-- ============================================================================
-- DATABASE INITIALIZATION
-- ============================================================================
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
            visibility = "ALWAYS", -- "ALWAYS" or "COMBAT"
            alpha = 0.3,
            size = 64, -- Default size
            slot = 88 -- Default hidden action slot
        }
    end
    -- Migration/Safety check for existing DBs
    if not AssistantButtonVisualizerDB.slot then
        AssistantButtonVisualizerDB.slot = 88
    end
    if not AssistantButtonVisualizerDB.size then
        AssistantButtonVisualizerDB.size = 64
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
        print(ABV_PREFIX .. " Frame Locked.")
    else
        ABV_MainFrame:EnableMouse(true)
        ABV_MainFrame:SetMovable(true)
        print(ABV_PREFIX .. " Frame Unlocked.")
    end
end

-- Function to set the opacity
function AssistantButton_SetAlpha(value)
    if not AssistantButtonVisualizerDB then return end
    AssistantButtonVisualizerDB.alpha = value
    -- Apply immediately if frame exists
    if ABV_MainFrame then
        ABV_MainFrame:SetAlpha(value)
    end
end

-- Function to set the size
function AssistantButton_SetSize(value)
    if not AssistantButtonVisualizerDB then return end
    AssistantButtonVisualizerDB.size = value
    -- Apply immediately if frame exists
    if ABV_MainFrame then
        ABV_MainFrame:SetSize(value, value)
    end
end

-- Function to set the action slot
function AssistantButton_SetSlot(value)
    if not AssistantButtonVisualizerDB then return end
    
    local oldSlot = AssistantButtonVisualizerDB.slot
    
    -- If the slot has changed, we should try to clear the old one
    if oldSlot and oldSlot ~= value then
         if not InCombatLockdown() then
            -- Clear the old slot
            PickupAction(oldSlot)
            ClearCursor()
            print(ABV_PREFIX .. " Cleared old slot " .. oldSlot)
         else
            print(ABV_PREFIX .. " Cannot clear old slot " .. oldSlot .. " while in combat.")
         end
    end

    AssistantButtonVisualizerDB.slot = value
    
    -- Try to install to new slot immediately if not in combat
    if not InCombatLockdown() then
        InstallSpellToSlot()
    else
        print(ABV_PREFIX .. " Slot changed to " .. value .. ". Re-installation pending combat end.")
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

    local currentSlot = AssistantButtonVisualizerDB.slot or 88
    -- GetActionTexture is safe to call on protected buttons.
    local icon = GetActionTexture(currentSlot)
    
    if icon then
        mainFrame.texture:SetTexture(icon)
        mainFrame.texture:SetDesaturated(false)
        mainFrame:SetAlpha(AssistantButtonVisualizerDB.alpha or 0.3) 
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
function InstallSpellToSlot(force) -- Made global-ish for access from API
    if InCombatLockdown() then 
        -- Silent return or debug print during development
        return 
    end

    local currentSlot = AssistantButtonVisualizerDB.slot or 88

    -- 1. Check what is currently in the slot.
    -- GetActionInfo returns: type, id, subType
    local actionType, actionID = GetActionInfo(currentSlot)

    -- 2. If we are not forcing, and there is already a spell, assume it is correct.
    -- This prevents overwriting metamorphic spells (like Rake/Shred) that change ID,
    -- and avoids the annoying pickup sound on every login/talent change.
    if not force and actionType == "spell" then
        return
    end

    -- 3. If we are here, the slot is empty, has wrong type, or we are forcing. Attempt to install.
    local spellInfo = C_Spell.GetSpellInfo(TARGET_SPELL_ID)
    
    if spellInfo and spellInfo.spellID then
        C_Spell.PickupSpell(spellInfo.spellID)
        
        -- Verify cursor has the spell before placing
        if GetCursorInfo() then
            PlaceAction(currentSlot)
            ClearCursor()
            print(ABV_PREFIX .. " Spell installed to slot " .. currentSlot)
        end
    else
        -- Only print error if manually triggered or debugging, to avoid login spam if ID is wrong
        if force then
            print(ABV_PREFIX .. " Error: Invalid Spell ID or spell not learned.")
        end
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
        timer = timer - UPDATE_INTERVAL 
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
        C_Timer.After(2, function() InstallSpellToSlot(false) end)

        -- Apply lock state
        if AssistantButtonVisualizerDB.locked then
            AssistantButton_SetLock(true)
        end
        
        -- Restore alpha
        if AssistantButtonVisualizerDB.alpha then
             self:SetAlpha(AssistantButtonVisualizerDB.alpha)
        end

        -- Restore size
        if AssistantButtonVisualizerDB.size then
            self:SetSize(AssistantButtonVisualizerDB.size, AssistantButtonVisualizerDB.size)
        else
            self:SetSize(FRAME_SIZE, FRAME_SIZE)
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Combat started. Show frame immediately to ensure OnUpdate loop runs
        -- and can evaluate the visibility logic (which checks InCombatLockdown).
        self:Show()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" or event == "TRAIT_CONFIG_UPDATED" then
        -- Re-install spell when talents or specialization change.
        -- We add a small delay to ensure the spellbook has processed the changes.
        C_Timer.After(1, function() InstallSpellToSlot(false) end)
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
        
        print(ABV_PREFIX .. " Position reset to center.")
        
    elseif cmd == "install" then
        print(ABV_PREFIX .. " Forcing manual check/installation...")
        InstallSpellToSlot(true)
        
    else
        print(ABV_PREFIX .. " Commands:|r")
        print("/abv reset   - Resets the frame position to the center.")
        print("/abv install - Checks slot " .. SLOT .. " and installs the spell if missing.")
    end
end