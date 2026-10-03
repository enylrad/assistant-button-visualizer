--[[----------------------------------------------------------------------------
    AssistantButtonVisualizer - Core
    Addon namespace, event dispatching, internal message bus and shared helpers.

    Every other file receives the same private namespace table (`ns`) through
    the vararg passed by the client when the file is loaded.
------------------------------------------------------------------------------]]

local ADDON_NAME, ns = ...

ns.name = ADDON_NAME
ns.title = "Assistant Button Visualizer"
ns.coloredTitle = "|cff3fd47bAssistant Button|r Visualizer"

-- Expose the namespace globally for debugging (/dump AssistantButtonVisualizer)
-- and for the addon compartment callback, which must be reachable by name.
_G.AssistantButtonVisualizer = ns

--------------------------------------------------------------------------------
-- Module registry
--------------------------------------------------------------------------------

-- Modules are plain tables stored on the namespace. The bootstrap calls their
-- optional lifecycle hooks in registration order (which follows the TOC order):
--   module:OnInitialize()  saved variables are available (ADDON_LOADED)
--   module:OnLogin()       character data is available (PLAYER_LOGIN)
ns.modules = {}

--- Creates and registers a new module, also reachable as ns[name].
function ns:NewModule(name)
    local module = { moduleName = name }
    ns[name] = module
    ns.modules[#ns.modules + 1] = module
    return module
end

--- Invokes a lifecycle hook on every module that implements it.
function ns:CallModules(hook, ...)
    for i = 1, #ns.modules do
        local module = ns.modules[i]
        if module[hook] then
            module[hook](module, ...)
        end
    end
end

--------------------------------------------------------------------------------
-- Game event dispatching
--------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
local eventHandlers = {}

--- Checks whether the running client knows an event, so registering it is safe.
local function IsEventValid(event)
    if C_EventUtils and C_EventUtils.IsEventValid then
        return C_EventUtils.IsEventValid(event)
    end
    local probe = CreateFrame("Frame")
    local ok = pcall(probe.RegisterEvent, probe, event)
    probe:UnregisterAllEvents()
    return ok
end

--- Registers a handler for a game event. Several handlers per event are allowed.
--- Events unknown to the running client are ignored and false is returned.
--- @param event string
--- @param handler fun(event: string, ...)
--- @return boolean registered
function ns:RegisterEvent(event, handler)
    local handlers = eventHandlers[event]
    if not handlers then
        if not IsEventValid(event) then
            return false
        end
        handlers = {}
        eventHandlers[event] = handlers
        eventFrame:RegisterEvent(event)
    end
    handlers[#handlers + 1] = handler
    return true
end

eventFrame:SetScript("OnEvent", function(_, event, ...)
    local handlers = eventHandlers[event]
    if not handlers then
        return
    end
    for i = 1, #handlers do
        handlers[i](event, ...)
    end
end)

--------------------------------------------------------------------------------
-- Internal message bus (decouples the modules from the UI)
--------------------------------------------------------------------------------

local messageHandlers = {}

--- Subscribes to an internal addon message.
function ns:RegisterMessage(message, handler)
    local handlers = messageHandlers[message]
    if not handlers then
        handlers = {}
        messageHandlers[message] = handlers
    end
    handlers[#handlers + 1] = handler
end

--- Broadcasts an internal addon message to every subscriber.
function ns:SendMessage(message, ...)
    local handlers = messageHandlers[message]
    if not handlers then
        return
    end
    for i = 1, #handlers do
        handlers[i](message, ...)
    end
end

--------------------------------------------------------------------------------
-- Output
--------------------------------------------------------------------------------

local CHAT_PREFIX = "|cff3fd47bABV|r: "

--- Prints a message to the default chat frame with the addon prefix.
function ns:Print(message, ...)
    if select("#", ...) > 0 then
        message = message:format(...)
    end
    DEFAULT_CHAT_FRAME:AddMessage(CHAT_PREFIX .. tostring(message))
end

--------------------------------------------------------------------------------
-- Generic helpers
--------------------------------------------------------------------------------

--- Clamps a number into the [low, high] range.
function ns.Clamp(value, low, high)
    if value < low then
        return low
    elseif value > high then
        return high
    end
    return value
end

--- Rounds a number to the given amount of decimals.
function ns.Round(value, decimals)
    local factor = 10 ^ (decimals or 0)
    return math.floor(value * factor + 0.5) / factor
end

--- Recursively fills missing keys of `target` with copies of `defaults`.
function ns.ApplyDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = ns.DeepCopy(value)
            else
                ns.ApplyDefaults(target[key], value)
            end
        elseif target[key] == nil then
            target[key] = value
        end
    end
    return target
end

--- Returns a deep copy of a plain data table.
function ns.DeepCopy(source)
    if type(source) ~= "table" then
        return source
    end
    local copy = {}
    for key, value in pairs(source) do
        copy[key] = ns.DeepCopy(value)
    end
    return copy
end
