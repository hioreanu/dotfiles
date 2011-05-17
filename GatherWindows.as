-- If you periodically turn off the second monitor, but Mac OS doesn't
-- realize this and keeps windows on the extended desktop, moves windows
-- back to the main desktop.

set screen_width to 1920
set screen_height to 1200
tell application "System Events"
    repeat with curProc in application processes
        if name of curProc is not "Google Chrome Helper" then
            tell curProc
                repeat with curWin in windows
                    set winPos to position of curWin
                    set x to item 1 of winPos
                    set y to item 2 of winPos
                    if (x < 0 or x > screen_width or y < 0 or y > screen_height) then
                        set position of curWin to {0, 22}
                    end if
                end repeat
            end tell
        end if
    end repeat
end tell

