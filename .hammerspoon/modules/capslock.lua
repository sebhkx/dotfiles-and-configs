-- hold Caps/F18 + UIOJKLM → 4561230
-- virtual Caps Lock → letters become uppercase
-- Requires Karabiner-Elements to remap Caps → F18

local M = {}

local virtualCapsOn = false
local capsHeld = false

local keyDown = hs.eventtap.event.types.keyDown
local keyUp = hs.eventtap.event.types.keyUp

local f18 = hs.keycodes.map.f18

local numMap = {
    [hs.keycodes.map.u] = hs.keycodes.map["4"],
    [hs.keycodes.map.i] = hs.keycodes.map["5"],
    [hs.keycodes.map.o] = hs.keycodes.map["6"],

    [hs.keycodes.map.j] = hs.keycodes.map["1"],
    [hs.keycodes.map.k] = hs.keycodes.map["2"],
    [hs.keycodes.map.l] = hs.keycodes.map["3"],

    [hs.keycodes.map.m] = hs.keycodes.map["0"],
}

local letterMap = {}
for _, k in ipairs({
    "a", "b", "c", "d", "e", "f", "g",
    "h", "i", "j", "k", "l", "m", "n",
    "o", "p", "q", "r", "s", "t", "u",
    "v", "w", "x", "y", "z",
}) do
    letterMap[hs.keycodes.map[k]] = true
end

local activeNumKeys = {}
local activeCapsLetters = {}

local function addShift(e)
    local flags = e:getFlags()
    flags.shift = true
    e:setFlags(flags)
end

local tap = hs.eventtap.new({ keyDown, keyUp }, function(e)
    local keyCode = e:getKeyCode()
    local eventType = e:getType()

    -- Caps/F18 hold layer
    if keyCode == f18 then
        capsHeld = eventType == keyDown
        return true
    end

    -- Release transformed number key correctly
    if eventType == keyUp and activeNumKeys[keyCode] then
        e:setKeyCode(activeNumKeys[keyCode])
        activeNumKeys[keyCode] = nil
        return false
    end

    -- Caps + UIOJKLM → 4561230
    if capsHeld and eventType == keyDown then
        local outputKeyCode = numMap[keyCode]

        if outputKeyCode then
            activeNumKeys[keyCode] = outputKeyCode
            e:setKeyCode(outputKeyCode)
            e:setFlags({})
            return false
        end
    end

    -- Release transformed uppercase letter correctly
    if eventType == keyUp and activeCapsLetters[keyCode] then
        addShift(e)
        activeCapsLetters[keyCode] = nil
        return false
    end

    -- Virtual Caps Lock mode
    if virtualCapsOn and letterMap[keyCode] then
        local flags = e:getFlags()

        -- Let shortcuts pass through normally:
        -- Cmd+A, Ctrl+A, Option+key, Cmd+Shift+A, etc.
        if flags.cmd or flags.ctrl or flags.alt or flags.fn then
            return false
        end

        if eventType == keyDown then
            activeCapsLetters[keyCode] = true
        end

        -- Shift+a remain A
        if not flags.shift then
            addShift(e)
        end

        return false
    end

    return false
end)

function M.start()
    tap:start()
end

function M.stop()
    tap:stop()
end

function M.toggle()
    virtualCapsOn = not virtualCapsOn
end

function M.isOn()
    return virtualCapsOn
end

function M.set(value)
    virtualCapsOn = value == true
end

return M