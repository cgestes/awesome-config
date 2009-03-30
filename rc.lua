-- Standard awesome library
require("awful")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- The default is a dark theme
theme_path = "/usr/local/share/awesome/themes/default/theme"
-- Uncommment this for a lighter theme
-- theme_path = "/usr/local/share/awesome/themes/sky/theme"

home = os.getenv("HOME")
theme_path = home .. "/.config/awesome/themes/default/theme"

-- Actually load theme
beautiful.init(theme_path)

-- This is used later as the default terminal and editor to run.
terminal = "xterm"

terminal = "gnome-terminal"

editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}

-- Table of clients that should be set floating. The index may be either
-- the application class or instance. The instance is useful when running
-- a console app in a terminal like (Music on Console)
--    xterm -name mocp -e mocp
floatapps =
{
    -- by class
    ["MPlayer"] = true,
    ["pinentry"] = true,
    ["gimp"] = true,
    ["Pidgin"]          = true,
    ["Gajim"]           = true,

    -- by instance
    ["mocp"] = true
}

-- Applications to be moved to a pre-defined tag by class or instance.
-- Use the screen and tags indices.
apptags =
{
  ["Emacs"]             = { screen = 1, tag = 4 },
  ["Thunderbird"]       = { screen = 1, tag = 2 },
  ["Navigator"]         = { screen = 1, tag = 2 },
  ["Epiphany"]          = { screen = 1, tag = 2 },
  ["Pidgin"]            = { screen = 1, tag = 5 },
  ["Vncviewer"]         = { screen = 1, tag = 7 },

    -- ["Firefox"] = { screen = 1, tag = 2 },
    -- ["mocp"] = { screen = 2, tag = 4 },
}

-- Define if we want to use titlebar on all applications.
use_titlebar = false
-- }}}

-- {{{ Tags
-- Define tags table.
tags = {}

tags_name   = {
   "1:main",
   "2:www",
   "3:plop",
   "4:prog",
   "5:im",
   "6:float",
   "7:vnc"
}

tags_layout = {
   awful.layout.suit.fair,
   awful.layout.suit.max,
   awful.layout.suit.max,
   awful.layout.suit.max,
   awful.layout.suit.floating,
   awful.layout.suit.floating,
   awful.layout.suit.max,
}


for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = {}
    -- Create 9 tags per screen.
    for tagnumber, tagname in ipairs(tags_name) do
        tags[s][tagnumber] = tag( tagname )
        --tags[s][tagnumber] = tag( { name = tagname, layouts[tags_layout[tagnumber]] } )
        -- Add tags to screen one by one
        tags[s][tagnumber].screen = s
        awful.layout.set(tags_layout[tagnumber], tags[s][tagnumber])
    end
    -- I'm sure you want to see at least one tag.
    tags[s][1].selected = true
end
-- }}}

-- {{{ Wibox
-- Create a textbox widget
mytextbox = widget({ type = "textbox", align = "right" })
-- Set the default text in textbox
mytextbox.text = "<b><small> " .. AWESOME_RELEASE .. " </small></b>"

-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu.new({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                        { "open terminal", terminal } ,
                                        { "thunderbird", "thunderbird3" } ,
                                        { "epiphany", "epiphany" } ,
                                        { "firefox", "firefox" } ,
                                        { "halt", "sudo /sbin/halt" },
                                        { "reboot", "sudo /sbin/reboot" }
                                      }
                            })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })

-- Create a systray
mysystray = widget({ type = "systray", align = "right" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = { button({ }, 1, awful.tag.viewonly),
                      button({ modkey }, 1, awful.client.movetotag),
                      button({ }, 3, function (tag) tag.selected = not tag.selected end),
                      button({ modkey }, 3, awful.client.toggletag),
                      button({ }, 4, awful.tag.viewnext),
                      button({ }, 5, awful.tag.viewprev) }
mytasklist = {}
mytasklist.buttons = { button({ }, 1, function (c)
                                          if not c:isvisible() then
                                              awful.tag.viewonly(c:tags()[1])
                                          end
                                          client.focus = c
                                          c:raise()
                                      end),
                       button({ }, 3, function () if instance then instance:hide() instance = nil else instance = awful.menu.clients({ width=250 }) end end),
                       button({ }, 4, function ()
                                          awful.client.focus.byidx(1)
                                          if client.focus then client.focus:raise() end
                                      end),
                       button({ }, 5, function ()
                                          awful.client.focus.byidx(-1)
                                          if client.focus then client.focus:raise() end
                                      end) }

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = widget({ type = "textbox", align = "left" })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = widget({ type = "imagebox", align = "right" })
    mylayoutbox[s]:buttons({ button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                             button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                             button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                             button({ }, 5, function () awful.layout.inc(layouts, -1) end) })
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist.new(function(c)
                                                  return awful.widget.tasklist.label.currenttags(c, s)
                                              end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = wibox({ position = "top", fg = beautiful.fg_normal, bg = beautiful.bg_normal })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = { mylauncher,
                           mytaglist[s],
                           mytasklist[s],
                           mypromptbox[s],
                           mytextbox,
                           mylayoutbox[s],
                           s == 1 and mysystray or nil }
    mywibox[s].screen = s
end
-- }}}

-- {{{ Mouse bindings
root.buttons({
    button({ }, 3, function () mymainmenu:toggle() end),
    button({ }, 4, awful.tag.viewnext),
    button({ }, 5, awful.tag.viewprev)
})
-- }}}

-- {{{ ctaf function
local capi =
{
    screen = screen,
    client = client
}
--- Give the focus to a screen, and move pointer.
-- @param i Relative screen number.
function nomousefocus(i)
   local s = awful.util.cycle(capi.screen.count(), i)
   local c = awful.client.focus.history.get(s, 0)
   if c then capi.client.focus = c end
   -- dont move the mouse => xinemara fail otherwise...
   -- Move the mouse on the screen
   -- capi.mouse.screen = s
end

-- function getscreen()
--    if capi.client then
--    if awful.client.focus then
--       return awful.client.focus.screen
--    end
--    return mouse.screen
-- end

-- }}}


-- {{{ Key bindings
globalkeys =
{
--     key({ modkey,           }, "Left",   awful.tag.viewprev       ),
--     key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    key({ modkey,           }, "Escape", awful.tag.history.restore),

    key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

    -- Layout manipulation
    key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end),
    key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end),
    key({ modkey, "Control" }, "j", function () awful.screen.focus( 1)       end),
    key({ modkey, "Control" }, "k", function () awful.screen.focus(-1)       end),
    key({ modkey,           }, "u", awful.client.urgent.jumpto),
    key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    key({ modkey, "Control" }, "r", awesome.restart),
    key({ modkey, "Shift"   }, "q", awesome.quit),

    key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    key({ modkey, "Control" }, "space", function () awful.layout.inc(layouts,  1) end),
    key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    key({ modkey }, "F1",
        function ()
            awful.prompt.run({ prompt = "Run: " },
            mypromptbox[mouse.screen],
            awful.util.spawn, awful.completion.shell,
            awful.util.getdir("cache") .. "/history")
        end),

    key({ modkey }, "F4",
        function ()
            awful.prompt.run({ prompt = "Run Lua code: " },
            mypromptbox[mouse.screen],
            awful.util.eval, nil,
            awful.util.getdir("cache") .. "/history_eval")
        end),

    key({ modkey }, "F2", function() awful.util.spawn(terminal)                 end),
    key({ modkey }, "F5", function() awful.util.spawn("nautilus --no-desktop")  end),
    key({ modkey }, "F6", function() awful.util.spawn("epiphany")               end),
    key({ modkey }, "F7", function() awful.util.spawn("thunderbird3")           end),
    key({ modkey }, "F8", function() awful.util.spawn("totem")                  end),



    key({ modkey, "Ctrl" }, "i",
        function ()
           local s = mouse.screen
           if mypromptbox[s].text then
              mypromptbox[s].text = nil
           elseif client.focus then
              mypromptbox[s].text = nil
              if client.focus.class then
                 mypromptbox[s].text = "Class: " .. client.focus.class .. " "
              end
              if client.focus.instance then
                 mypromptbox[s].text = mypromptbox[s].text .. "Instance: ".. client.focus.instance .. " "
              end
              if client.focus.role then
                 mypromptbox[s].text = mypromptbox[s].text .. "Role: ".. client.focus.role
              end
           end
        end),
    key({ modkey }, "Up", function () nomousefocus(1) end),
    key({ modkey }, "Down", function () nomousefocus(2) end),

    key({ modkey,         }, "Left",
        function ()
           awful.client.focus.byidx(-1);
           if client.focus then
              client.focus:raise()
           end
        end),
    key({ modkey,         }, "Right",
        function ()
           awful.client.focus.byidx(1);
           if client.focus then
              client.focus:raise()
           end
        end),
--      key({ modkey, "Shift"   }, "Left",   awful.tag.viewprev       ),
--      key({ modkey, "Shift"   }, "Right",  awful.tag.viewnext       ),

}

-- Client awful tagging: this is useful to tag some clients and then do stuff like move to tag on them
clientkeys =
{
    key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    key({ modkey }, "t", awful.client.togglemarked),
    key({ modkey,}, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
    key({ "Mod1",           }, "c",      function (c) c:kill()                         end),
}

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

tagkeys = { '#10', '#11', '#12', '#13', '#14', '#15', '#16', '#17', '#18', '#19', '#20' }
for i = 1, keynumber do
    table.insert(globalkeys,
        key({ modkey }, tagkeys[i],
            function ()
                local screen = focusedscreen
                if tags[screen][i] then
                    awful.tag.viewonly(tags[screen][i])
                end
            end))
    table.insert(globalkeys,
        key({ modkey, "Control" }, tagkeys[i],
            function ()
                local screen = focusedscreen
                if tags[screen][i] then
                    tags[screen][i].selected = not tags[screen][i].selected
                end
            end))
    table.insert(globalkeys,
        key({ modkey, "Shift" }, tagkeys[i],
            function ()
                if client.focus and tags[client.focus.screen][i] then
                    awful.client.movetotag(tags[client.focus.screen][i])
                end
            end))
    table.insert(globalkeys,
        key({ modkey, "Control", "Shift" }, tagkeys[i],
            function ()
                if client.focus and tags[client.focus.screen][i] then
                    awful.client.toggletag(tags[client.focus.screen][i])
                end
            end))
    table.insert(globalkeys,
        key({ modkey, "Shift" }, "F" .. i,
            function ()
                local screen = focusedscreen
                if tags[screen][i] then
                    for k, c in pairs(awful.client.getmarked()) do
                        awful.client.movetotag(tags[screen][i], c)
                    end
                end
            end))
end


-- Set keys
root.keys(globalkeys)
-- }}}

-- remember last focused screen
focusedscreen = mouse.screen

-- {{{ Hooks
-- Hook function to execute when focusing a client.
awful.hooks.focus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_focus
        focusedscreen = c.screen
    end
end)

-- Hook function to execute when unfocusing a client.
awful.hooks.unfocus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_normal
    end
end)

-- Hook function to execute when marking a client
awful.hooks.marked.register(function (c)
    c.border_color = beautiful.border_marked
end)

-- Hook function to execute when unmarking a client.
awful.hooks.unmarked.register(function (c)
    c.border_color = beautiful.border_focus
end)

-- Hook function to execute when the mouse enters a client.
awful.hooks.mouse_enter.register(function (c)
    -- Sloppy focus, but disabled for magnifier layout
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)


-- Hook function to execute when a new client appears.
awful.hooks.manage.register(function (c, startup)
    -- If we are not managing this application at startup,
    -- move it to the screen where the mouse is.
    -- We only do it for filtered windows (i.e. no dock, etc).
    if not startup and awful.client.focus.filter(c) then
        c.screen = mouse.screen
    end

    if use_titlebar then
        -- Add a titlebar
        awful.titlebar.add(c, { modkey = modkey })
    end
    -- Add mouse bindings
    c:buttons({
        button({ }, 1, function (c) client.focus = c; c:raise() end),
        button({ modkey }, 1, awful.mouse.client.move),
        button({ modkey }, 3, awful.mouse.client.resize)
    })
    -- New client may not receive focus
    -- if they're not focusable, so set border anyway.
    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal

    -- Check if the application should be floating.
    local cls = c.class
    local inst = c.instance
    if floatapps[cls] then
        awful.client.floating.set(c, floatapps[cls])
    elseif floatapps[inst] then
        awful.client.floating.set(c, floatapps[inst])
    end

    -- Check application->screen/tag mappings.
    local target
    if apptags[cls] then
        target = apptags[cls]
    elseif apptags[inst] then
        target = apptags[inst]
    end
    if target then
        c.screen = target.screen
        awful.client.movetotag(tags[target.screen][target.tag], c)
        -- switch to the selected tag
        --viewnone(target.screen)
        --viewonly(target.tag)
        -- manualy deselect previous tag, then select the target one
        for i, t in pairs(tags[target.screen]) do
           t.selected = false
        end
        tags[target.screen][target.tag].selected = true
    end

    -- Do this after tag mapping, so you don't see it on the wrong tag for a split second.
    client.focus = c

    -- Set key bindings
    c:keys(clientkeys)

    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- awful.client.setslave(c)

    -- Honor size hints: if you want to drop the gaps between windows, set this to false.
    c.size_hints_honor = false
end)

-- Hook function to execute when arranging the screen.
-- (tag switch, new client, etc)
awful.hooks.arrange.register(function (screen)
    local layout = awful.layout.getname(awful.layout.get(screen))
    if layout and beautiful["layout_" ..layout] then
        mylayoutbox[screen].image = image(beautiful["layout_" .. layout])
    else
        mylayoutbox[screen].image = nil
    end

    -- Give focus to the latest client in history if no window has focus
    -- or if the current window is a desktop or a dock one.
    if not client.focus then
        local c = awful.client.focus.history.get(screen, 0)
        if c then client.focus = c end
    end
end)

-- Hook called every minute
awful.hooks.timer.register(60, function ()
    mytextbox.text = os.date(" %a %b %d, %H:%M ")
end)
-- }}}




-- {{{ ctaf function
function getscreen()
   return focusedscreen
--    if capi.client.focus then
--        return capi.client.focus.screen
--    end
--    return mouse.screen
end



-- }}}

table.insert(globalkeys,
             key({ modkey, "Shift"   }, "Left",
                 function ()
                    awful.tag.viewidx(-1, getscreen())
                 end))

table.insert(globalkeys,
             key({ modkey, "Shift"   }, "Right",
                 function ()
                    awful.tag.viewidx(1, getscreen())
                 end))

--scratchpad replacement
-- simply toggle a tag on/off
table.insert(globalkeys,
             key({ modkey, }, "space",
                 function ()
                    local tscreen    = 1
                    local ttag       = 2

                    if tags[tscreen][ttag].selected then
                       -- scratchpad active => load previous tag
                       awful.tag.history.restore(tscreen)
                    else
                       -- unselect each tag, then select scrachpad
                       for i, t in pairs(tags[tscreen]) do
                          t.selected = false
                       end
                       tags[tscreen][ttag].selected = true
                    end
                    scratchpadactive = not scratchpadactive
                 end))

-- Set keys
root.keys(globalkeys)
-- }}}
