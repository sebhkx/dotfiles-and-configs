require("hs.ipc")
local caps = require("modules.capslock")
caps.start()

-- Modules

local MODULES = {
    "modules.drag-to-space",
    "modules.current-wattage",
    "modules.auto-hide-apps",
    "modules.preview-snap",

    -- testing
    "test.watcher",
}

local modules = {}

-- Root Menubar
-- =========================================================

local menubar = hs.menubar.new()
menubar:setTitle("⚡")

local function buildCapsMenu()
    local ok, isOn = pcall(function()
        return caps.isOn and caps.isOn()
    end)

    return {
        {
            title = ok and isOn and "✓ Caps Lock ON" or "Caps Lock OFF",
            fn = function()
                if caps.toggle then
                    caps.toggle()
                    refreshMenu()
                else
                    hs.alert("caps.toggle missing")
                end
            end
        }
    }
end

function buildMenu()
    local menu = {}

    -- Caps Lock section
    for _, item in ipairs(buildCapsMenu()) do
        table.insert(menu, item)
    end

    table.insert(menu, { title = "-" })

    -- Module sections
    for _, mod in ipairs(modules) do
        if mod.menu then
            local ok, items = pcall(mod.menu)

            if ok and type(items) == "table" then
                if mod.title then
                    table.insert(menu, {
                        title = mod.title,
                        disabled = true,
                    })
                end

                for _, item in ipairs(items) do
                    table.insert(menu, item)
                end

                table.insert(menu, { title = "-" })
            else
                print("Menu error:", mod.title or "Unknown", items)
            end
        end
    end

    -- Remove trailing separator
    if menu[#menu] and menu[#menu].title == "-" then
        table.remove(menu, #menu)
    end

    return menu
end

-- Loader
-- =========================================================

local function loadModule(name)
    local ok, mod = pcall(require, name)

    if not ok then
        hs.alert("Failed: " .. name)
        print(mod)
        return
    end

    if type(mod) ~= "table" then
        error(name .. " must return a table")
    end

    table.insert(modules, mod)

    if mod.init then
        local okInit, err = pcall(mod.init)
        if not okInit then
            hs.alert("Init failed: " .. name)
            print(err)
        end
    end
end

function refreshMenu()
    menubar:setMenu(function()
        return buildMenu()
    end)
end

for _, name in ipairs(MODULES) do
    loadModule(name)
end

refreshMenu()

-- =========================================================
-- Global Hotkeys
-- =========================================================

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "R", hs.reload)
hs.alert("Hammerspoon loaded")