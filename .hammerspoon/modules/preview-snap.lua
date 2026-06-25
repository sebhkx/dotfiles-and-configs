local M = {}

M.title = "Preview Snap"

local TARGET_WIDTH = 1224
local RESIZE_DELAY = 0.1

local previewSnap = hs.settings.get("previewZoomRightEnabled")
if previewSnap == nil then previewSnap = true end

local zoom = hs.settings.get("zoomEnabled")
if zoom == nil then zoom = true end

local snapSide = hs.settings.get("snapSide")
if snapSide ~= "left" and snapSide ~= "right" then
    snapSide = "right"
end

local function toggle(key, value)
    value = not value
    hs.settings.set(key, value)
    refreshMenu()
    return value
end

local function setSnapSide(side)
    snapSide = side
    hs.settings.set("snapSide", side)
    refreshMenu()
end

function M.init()
    local previewFilter = hs.window.filter.new("Preview")

    previewFilter:subscribe(hs.window.filter.windowCreated, function(win)
        if not previewSnap then return end

        hs.timer.doAfter(0.3, function()
            if not win or not win:isStandard() then return end

            local f = win:screen():frame()

            win:setFrame({
                x = snapSide == "right" and (f.x + f.w - TARGET_WIDTH) or f.x,
                y = f.y,
                w = TARGET_WIDTH,
                h = f.h
            })

            if zoom then
                hs.timer.doAfter(RESIZE_DELAY, function()
                    win:focus()
                    hs.eventtap.keyStroke({"cmd"}, "0")
                end)
            end
        end)
    end)
end

function M.menu()
    return {
        {
            title = previewSnap and "✓ Preview Snap" or "Preview Snap",
            fn = function()
                previewSnap = toggle("previewZoomRightEnabled", previewSnap)
                hs.alert(previewSnap and "Snap ON" or "Snap OFF")
            end
        },
        {
            title = zoom and "✓ Zoom Cmd+0" or "Zoom Cmd+0",
            fn = function()
                zoom = toggle("zoomEnabled", zoom)
                hs.alert(zoom and "Zoom ON" or "Zoom OFF")
            end
        },
        {
            title = "Snap Side",
            menu = {
                {
                    title = snapSide == "left" and "● Left" or "Left",
                    fn = function()
                        setSnapSide("left")
                        hs.alert("Snap Side: Left")
                    end
                },
                {
                    title = snapSide == "right" and "● Right" or "Right",
                    fn = function()
                        setSnapSide("right")
                        hs.alert("Snap Side: Right")
                    end
                }
            }
        }
    }
end

return M