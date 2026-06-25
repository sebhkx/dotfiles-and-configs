local M = {}

M.title = "Current Wattage"

local function showWattage()
    local output = hs.execute("system_profiler SPPowerDataType")
    local wattage = output:match("Wattage %(W%): (%d+)")

    hs.alert(wattage and ("Wattage (W): " .. wattage) or "No charger detected")
end

function M.menu()
    return {
        {
            title = "Show Charger Wattage",
            fn = showWattage
        }
    }
end

return M