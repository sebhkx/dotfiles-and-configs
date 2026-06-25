local M = {}

local INTERVAL_MIN = 10
local INTERVAL = INTERVAL_MIN * 60

M.title = ("Hide Apps (%dm)"):format(INTERVAL_MIN)

local appList = {
    "Calendar",
    "Fantastical",
    "Reminders",
    "TextEdit",
    "Notes",
    "UpNote",
    "Notion",
    "ChatGPT",
    "Gemini",
    "QSpace Pro",
    "Terminal",
    "com.TickTick.task.mac",
    "TickTick Web"
}

local apps = {}
for _, name in ipairs(appList) do
    apps[name] = true
end

local timer
local autoHide = hs.settings.get("hideAppsEnabled") or false

local function hideApps()
    local front = hs.application.frontmostApplication()
    local frontName = front and front:name()

    for _, name in ipairs(appList) do
        if apps[name] then
            local app = hs.application.get(name)

            if app and app:isRunning() and app:name() ~= frontName then
                app:hide()
            end
        end
    end
end

local function quitApp(name)
    local app = hs.application.get(name)

    if app and app:isRunning() then
        app:kill()
        hs.alert("Quit " .. name)
    else
        hs.alert(name .. " not running")
    end
end

local function stopTimer()
    if timer then
        timer:stop()
        timer = nil
    end
end

local function startTimer()
    stopTimer()
    timer = hs.timer.doEvery(INTERVAL, hideApps)
end

local function updateAutoHide(enabled)
    autoHide = enabled
    hs.settings.set("hideAppsEnabled", enabled)

    if enabled then
        startTimer()
    else
        stopTimer()
    end

    refreshMenu()
end

local function launchApp(name)
    hs.application.launchOrFocus(name)
end

function M.init()
    if autoHide then
        startTimer()
    end
end

function M.menu()
    local menu = {
        {
            title = autoHide and "✓ Auto Hide" or "Auto Hide",
            fn = function()
                updateAutoHide(not autoHide)
            end
        },
        {
            title = "Hide Now",
            fn = hideApps
        },
        {
            title = "-"
        }
    }

    for _, name in ipairs(appList) do
        table.insert(menu, {
            title = name,
            menu = {
                {
                    title = apps[name] and "✓ Auto-hide enabled" or "Auto-hide disabled",
                    fn = function()
                        apps[name] = not apps[name]
                        refreshMenu()
                    end
                },
                {
                    title = "Open app",
                    fn = function()
                        launchApp(name)
                    end
                },
                {
                    title = "Quit app",
                    fn = function()
                        quitApp(name)
                    end
                }
            }
        })
    end

    return menu
end

return M