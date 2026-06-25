local M = {}

M.title = "Drag to Space"

local TITLEBAR_X = 80
local TITLEBAR_Y = 14
local DRAG_DELAY = 0.15
local RELEASE_DELAY = 0.35

local function titlebarGrabPoint(win)
    local f = win:frame()

    return {
        x = f.x + TITLEBAR_X,
        y = f.y + TITLEBAR_Y,
    }
end

local function dragWindowToDesktop(desktopNumber)
    local win = hs.window.focusedWindow()

    if not win then
        hs.alert("No focused window")
        return
    end

    local point = titlebarGrabPoint(win)

    win:focus()
    hs.mouse.absolutePosition(point)

    hs.timer.doAfter(DRAG_DELAY, function()
        hs.eventtap.event
            .newMouseEvent(hs.eventtap.event.types.leftMouseDown, point)
            :post()

        hs.eventtap.keyStroke({"ctrl"}, tostring(desktopNumber), 0)

        hs.timer.doAfter(RELEASE_DELAY, function()
            hs.eventtap.event
                .newMouseEvent(hs.eventtap.event.types.leftMouseUp, point)
                :post()

            hs.alert("Moved to Desktop " .. desktopNumber)
        end)
    end)
end

local function screenLabel(screen, index)
    local name = screen:name() or ("Display " .. index)
    return "Display " .. index .. " — " .. name
end

function M.menu()
    local menu = {}
    local allSpaces = hs.spaces.allSpaces() or {}
    local focusedSpace = hs.spaces.focusedSpace()
    local desktopNumber = 1

    local mouseScreen = hs.mouse.getCurrentScreen()
    local screens = hs.screen.allScreens()

    for screenIndex, screen in ipairs(screens) do
        local uuid = screen:getUUID()
        local spaces = allSpaces[uuid] or {}
        local isActiveDisplay = mouseScreen and screen:id() == mouseScreen:id()

        table.insert(menu, {
            title = screenLabel(screen, screenIndex),
            disabled = not isActiveDisplay,
            fn = function() end
        })

        table.insert(menu, { title = "-" })

        for _, spaceId in ipairs(spaces) do
            local n = desktopNumber
            local isCurrent = spaceId == focusedSpace

            table.insert(menu, {
                title = isCurrent
                    and ("✓ Desktop " .. n)
                    or ("Move to Desktop " .. n),

                disabled = isCurrent or not isActiveDisplay,

                fn = function()
                    if isActiveDisplay and not isCurrent then
                        dragWindowToDesktop(n)
                    end
                end
            })

            desktopNumber = desktopNumber + 1
        end

        if screenIndex < #screens then
            table.insert(menu, { title = "-" })
        end
    end

    return menu
end

return M