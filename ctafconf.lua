---------------------------------------------------------------------------
-- @author Cedric Gestes &lt;ctaf42@gmail.com&gt;
-- @copyright 2009 Cedric Gestes
-- @release Awesome 3.4
---------------------------------------------------------------------------
-- remember last focused screen
local focusedscreen = mouse.screen

client.add_signal("focus", function(c)
                               focusedscreen = c.screen
                           end)

--- Give the focus to a screen, and move pointer.
-- @param i Relative screen number.
function no_mouse_focus_screen(i)
    local s = awful.util.cycle(screen.count(), i)
    local c = awful.client.focus.history.get(s, 0)
    if c then client.focus = c end
    -- dont move the mouse => xinemara fail otherwise...
    -- Move the mouse on the screen
    -- capi.mouse.screen = s
end

function get_screen()
    return screen[focusedscreen]
    --    if capi.client.focus then
    --        return capi.client.focus.screen
    --    end
    --    return mouse.screen
end

-- scratchpad replacement
-- specify a screen and a tag and it will act like ion scratchpad
-- TODO check if we are on the good screen too
function toggle_scratchpad(tag, tscreen)
    local cscreen = tscreen or mouse.screen
    if tags[cscreen][tag].selected then
        -- scratchpad active => load previous tag
        awful.tag.history.restore(cscreen)
    else
        no_mouse_focus_screen(cscreen)
        -- unselect each tag, then select scrachpad
        awful.tag.viewonly(tags[cscreen][tag])
--         for i, t in pairs(tags[cscreen]) do
--             t.selected = false
--         end
--         tags[thescreen][tag].selected = true
   end
end


--{{{ functions / taginfo
function tag_info()
    local t = awful.tag.selected()
    local v = ""

    v = v .. "<span font_desc=\"Verdana Bold 20\">" .. t.name .. "</span>\n"
    v = v .. tostring(t) .. "\n\n"
    v = v .. "clients: " .. #t:clients() .. "\n\n"

    local i = 1
    for op, val in pairs(awful.tag.getdata(t)) do
        if op == "layout" then val = awful.layout.getname(val) end
        if op == "keys" then val = '#' .. #val end
        v = v .. string.format("%2s: %-12s = %s\n", i, op, tostring(val))
        i = i + 1
    end

    naughty.notify{ text = v:sub(1,#v-1), timeout = 0, margin = 10 }
end
--}}}

--{{{ functions / clientinfo
function client_info()
    local v = ""

    -- object
    local c = client.focus
    v = v .. tostring(c)

    -- geometry
    local cc = c:geometry()
    local signx = (cc.x > 0 and "+") or ""
    local signy = (cc.y > 0 and "+") or ""
    v = v .. " @ " .. cc.width .. 'x' .. cc.height .. signx .. cc.x .. signy .. cc.y .. "\n\n"

    local inf = {
        "name", "icon_name", "type", "class", "role", "instance", "pid",
        "icon_name", "skip_taskbar", "id", "group_id", "leader_id", "machine",
        "screen", "hide", "minimize", "size_hints_honor", "titlebar", "urgent",
        "focus", "opacity", "ontop", "above", "below", "fullscreen", "transient_for"
    }

    for i = 1, #inf do
        v = v .. string.format("%2s: %-16s = %s\n", i, inf[i], tostring(c[inf[i]]))
    end

    naughty.notify{ text = v:sub(1,#v-1), timeout = 0, margin = 10 }
end
--}}}

function autotab_start()
    client.add_signal("manage", function (c, startup)
        local sel       = client.focus
        local index     = nil
        --if the current client is already focused => get prev from history
        if sel == c then
            sel = awful.client.focus.history.get(c.screen, 1)
        end
        index = awful.tab.client_tabindex(sel)
        --do nothing on startup
        -- or floating or dock or not on the same tab as current focus
        if startup or awful.client.dockable.get(c) or awful.client.floating.get(c) then
            return
        end
        if index ~= nil then
            -- Currently focused client is tabbed,
            -- add the new window to the tabbed display
            awful.tab.add(index, c)
        end
    end)
end

-- }}}
