local M = {}

M.title = "Watcher Test"

local watcher

local function createWatcher()
    return hs.application.watcher.new(function(appName, eventType, app)
        if eventType ~= hs.application.watcher.activated then
            return
        end

        local name = app and app:name() or appName or "Unknown"
        local bundleID = app and app:bundleID() or "Unknown"

        print(string.format("%s | %s", name, bundleID))
    end)
end

local function toggleWatcher()
    if watcher then
        watcher:stop()
        watcher = nil
        hs.alert("Watcher OFF")
    else
        watcher = createWatcher()
        watcher:start()
        hs.alert("Watcher ON")
    end

    refreshMenu()
end

function M.menu()
    return {
        {
            title = watcher and "✓ Application Watcher" or "Application Watcher",
            fn = toggleWatcher
        }
    }
end

return M